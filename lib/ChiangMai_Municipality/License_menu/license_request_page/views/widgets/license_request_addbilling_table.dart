// ============================================================================
// license_request_addbilling_table.dart
// ============================================================================
// ตารางเพิ่มรายการค่าบริการ (Add-only) สำหรับ Request Step 2
// - UI/logic เหมือน BillingTable (license_contract_page) เกือบ 100%
// - กดบันทึก → รวมรายการใหม่กับรายการเดิม + ยิง API POST /prepayment ทันที
// - คืน true = บันทึกสำเร็จ, false = บันทึกไม่สำเร็จ, null = ผู้ใช้ยกเลิก
// ============================================================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/auto_exp_models.dart';
import '../../services/license_request_billing_service.dart';
import '../../viewmodels/add_billing_view_model.dart';
import '../theme/add_billing_theme.dart';
import '../theme/license_request_theme.dart';

class AddBillingTable extends StatelessWidget {
  final Function(List<LcExpTransModel>)? onRowsChanged;

  const AddBillingTable({
    super.key,
    this.onRowsChanged,
  });

  /// เปิด full-page เพิ่มรายการ
  /// - กดบันทึก → รวมรายการใหม่ (จากหน้านี้) กับ existingItems + ยิง API
  /// - คืน true = สำเร็จ, false = ล้มเหลว, null = ผู้ใช้ยกเลิก/ปิดหน้า
  static Future<bool?> show(
    BuildContext context, {
    required String requestUuid,
    required List<BillingItem> existingItems,
    String cidSdate = '',
    String cidLdate = '',
    String cidZser = '',
  }) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ChangeNotifierProvider<AddBillingViewModel>(
          create: (_) => AddBillingViewModel(
            cidSdate: cidSdate,
            cidLdate: cidLdate,
            cidZser: cidZser,
          )..load(),
          child: _AddBillingPage(
            requestUuid: requestUuid,
            existingItems: existingItems,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddBillingViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (vm.error != null) {
          return Center(
            child: Text(vm.error!,
                style: LcText.body.copyWith(color: LcColors.danger)),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Toolbar (responsive) ───
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                final toolbar = [
                  _GradientAddButton(
                    onPressed: () => _showAddDialog(context, vm),
                  ),
                  const SizedBox(width: 12),
                  _RowCounter(count: vm.rows.length),
                  if (!isMobile) const Spacer(),
                  if (!isMobile && vm.rows.isNotEmpty)
                    Text(
                      'รวม ${vm.rows.length} รายการ',
                      style: LcText.caption,
                    ),
                ];
                if (isMobile) {
                  return Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: toolbar,
                  );
                }
                return Row(children: toolbar);
              },
            ),
            const SizedBox(height: LcSpace.md),

            // ─── Main Table / Empty State ───
            if (vm.rows.isEmpty)
              _EmptyState(onAdd: () => _showAddDialog(context, vm))
            else
              Container(
                decoration: LcDecor.card(),
                clipBehavior: Clip.antiAlias,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth.clamp(1100, 1400),
                        ),
                        child: DataTable(
                          columnSpacing: 22,
                          headingRowHeight: 46,
                          dataRowMinHeight: 56,
                          dataRowMaxHeight: 68,
                          headingRowColor: MaterialStateColor.resolveWith(
                            (states) => LcColors.surfaceMuted,
                          ),
                          headingTextStyle: LcText.tableHeader,
                          dataTextStyle: LcText.tableCell,
                          dividerThickness: 0.6,
                          showBottomBorder: true,
                          columns: const [
                            DataColumn(label: Text('ประเภทค่าบริการ')),
                            DataColumn(label: Text('ความถี่')),
                            DataColumn(label: Text('จำนวนงวด'), numeric: true),
                            DataColumn(label: Text('วันเริ่มต้น')),
                            DataColumn(label: Text('ยอด (บาท)'), numeric: true),
                            DataColumn(label: Text('ประเภท VAT')),
                            DataColumn(label: Text('VAT'), numeric: true),
                            DataColumn(label: Text('ประเภท WHT')),
                            DataColumn(label: Text('WHT'), numeric: true),
                            DataColumn(label: Text('ยอดสุทธิ'), numeric: true),
                            DataColumn(label: Text('')),
                          ],
                          rows: vm.rows.asMap().entries.map((entry) {
                            final i = entry.key;
                            final row = entry.value;
                            final isAlt = i.isEven;
                            return DataRow(
                              color: MaterialStateColor.resolveWith((states) {
                                return isAlt
                                    ? LcColors.cardBg
                                    : LcColors.surfaceMuted.withOpacity(.5);
                              }),
                              cells: [
                                DataCell(
                                  Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 180),
                                    child: Text(
                                      row.expname ?? '-',
                                      style: LcText.tableCell.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  _InlineDropdown<String>(
                                    value: vm.units
                                            .any((u) => u.ser == row.unitser)
                                        ? row.unitser
                                        : null,
                                    hint: 'เลือก',
                                    items: vm.units
                                        .map((u) => DropdownMenuItem<String>(
                                              value: u.ser,
                                              child: Text(u.unit ?? ''),
                                            ))
                                        .toList(),
                                    onChanged: (val) {
                                      vm.updateUnit(row, val);
                                      onRowsChanged?.call(vm.rows);
                                    },
                                  ),
                                ),
                                DataCell(Center(
                                  child: _Badge(
                                    text: row.term ?? '0',
                                    tone: LcColors.primaryDark,
                                    bg: LcColors.primaryLight,
                                  ),
                                )),
                                DataCell(
                                  InkWell(
                                    onTap: () => _pickDate(context, vm, row),
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: LcColors.surfaceMuted,
                                        borderRadius: BorderRadius.circular(6),
                                        border:
                                            Border.all(color: LcColors.border),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.event_outlined,
                                              size: 14,
                                              color: LcColors.textSecondary),
                                          const SizedBox(width: 6),
                                          Text(
                                            (row.sdate == null ||
                                                    row.sdate!.isEmpty)
                                                ? 'เลือกวันที่'
                                                : _displayDateFormat.format(
                                                    DateTime.tryParse(
                                                            row.sdate!) ??
                                                        DateTime.now(),
                                                  ),
                                            style: LcText.tableCell.copyWith(
                                              color: (row.sdate == null ||
                                                      row.sdate!.isEmpty)
                                                  ? LcColors.textMuted
                                                  : LcColors.primaryDark,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 90,
                                    child: TextFormField(
                                      initialValue: row.amt,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9.]')),
                                      ],
                                      textAlign: TextAlign.right,
                                      style: LcText.tableCell.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      decoration:
                                          LcDecor.inputDecor(hintText: '0.00'),
                                      onChanged: (val) {
                                        vm.updateAmount(row, val);
                                        onRowsChanged?.call(vm.rows);
                                      },
                                    ),
                                  ),
                                ),
                                DataCell(
                                  _InlineDropdown<String>(
                                    value: vm.vats.any((v) => v.ser == row.vser)
                                        ? row.vser
                                        : null,
                                    hint: 'เลือก',
                                    items: vm.vats
                                        .map((v) => DropdownMenuItem<String>(
                                              value: v.ser,
                                              child: Text(v.vat ?? ''),
                                            ))
                                        .toList(),
                                    onChanged: (val) {
                                      vm.updateVat(row, val);
                                      onRowsChanged?.call(vm.rows);
                                    },
                                  ),
                                ),
                                DataCell(Text(
                                  row.vat ?? '0.00',
                                  textAlign: TextAlign.right,
                                  style: LcText.tableCell,
                                )),
                                DataCell(
                                  _InlineDropdown<String>(
                                    value: vm.whts.any((w) => w.ser == row.wser)
                                        ? row.wser
                                        : null,
                                    hint: 'เลือก',
                                    items: vm.whts
                                        .map((w) => DropdownMenuItem<String>(
                                              value: w.ser,
                                              child: Text(w.wht ?? ''),
                                            ))
                                        .toList(),
                                    onChanged: (val) {
                                      vm.updateWht(row, val);
                                      onRowsChanged?.call(vm.rows);
                                    },
                                  ),
                                ),
                                DataCell(Text(
                                  row.wht ?? '0.00',
                                  textAlign: TextAlign.right,
                                  style: LcText.tableCell,
                                )),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: LcColors.primaryLight,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      row.total ?? '0.00',
                                      textAlign: TextAlign.right,
                                      style: LcText.tableCell.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: LcColors.primaryDark,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  IconButton(
                                    tooltip: 'ลบแถว',
                                    icon: const Icon(Icons.delete_outline,
                                        color: LcColors.danger, size: 20),
                                    onPressed: () {
                                      vm.removeRow(i);
                                      onRowsChanged?.call(vm.rows);
                                    },
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: LcSpace.md),

            // ─── Grand Total Card (responsive) ───
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: LcSpace.lg, vertical: LcSpace.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    LcColors.primaryLight.withOpacity(.6),
                    LcColors.primary.withOpacity(.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(LcRadius.lg),
                border: Border.all(color: LcColors.primary.withOpacity(.2)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 520;
                  if (isMobile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: LcColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.summarize_rounded,
                                  size: 18, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('ยอดรวมทั้งหมด',
                                    style: LcText.label),
                                const SizedBox(height: 2),
                                Text(
                                  'รวม ${vm.rows.length} รายการ',
                                  style: LcText.caption,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${vm.grandTotal.toStringAsFixed(2)} บาท',
                          style: const TextStyle(
                            fontFamily: LcText.fontBold,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: LcColors.primaryDark,
                          ),
                        ),
                      ],
                    );
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: LcColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.summarize_rounded,
                                size: 18, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('ยอดรวมทั้งหมด', style: LcText.label),
                              const SizedBox(height: 2),
                              Text(
                                'รวม ${vm.rows.length} รายการ',
                                style: LcText.caption,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        '${vm.grandTotal.toStringAsFixed(2)} บาท',
                        style: const TextStyle(
                          fontFamily: LcText.fontBold,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: LcColors.primaryDark,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  static final _displayDateFormat = DateFormat('dd-MM-yyyy');

  Future<void> _pickDate(
      BuildContext context, AddBillingViewModel vm, LcExpTransModel row) async {
    final initial = DateTime.tryParse(row.sdate ?? '') ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: LcColors.primary,
              primary: LcColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      vm.updateDate(row, picked);
      onRowsChanged?.call(vm.rows);
    }
  }

  void _showAddDialog(BuildContext context, AddBillingViewModel vm) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(.45),
      builder: (context) => _AddRowDialog(
        vm: vm,
        onAdd: () => onRowsChanged?.call(vm.rows),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Page shell — Scaffold + Header (เหมือน RequestDetailHeader) + AddBillingTable + Footer
// ═══════════════════════════════════════════════════════════════════════════
class _AddBillingPage extends StatefulWidget {
  final String requestUuid;
  final List<BillingItem> existingItems;

  const _AddBillingPage({
    required this.requestUuid,
    required this.existingItems,
  });

  @override
  State<_AddBillingPage> createState() => _AddBillingPageState();
}

class _AddBillingPageState extends State<_AddBillingPage> {
  bool _isSaving = false;

  final LicenseRequestBillingService _service = LicenseRequestBillingService();

  Future<void> _onSave() async {
    final vm = context.read<AddBillingViewModel>();
    if (vm.rows.isEmpty) return;

    setState(() => _isSaving = true);

    // รวมรายการใหม่ (vm.rows) + รายการเดิม (existingItems)
    // ✅ gen ser ใหม่ให้ unique — กัน API ลบรายการซ้ำแล้วลบทีเดียวลบหมด
    var seq = DateTime.now().millisecondsSinceEpoch;
    final existingSers = widget.existingItems.map((e) => e.ser).toSet();
    final newItems = vm.rows.map((row) {
      final item = BillingItem.fromDebtJson(row.toJson());
      var ser = item.ser;
      if (ser.isEmpty || existingSers.contains(ser)) {
        ser = (seq++).toString();
      }
      existingSers.add(ser);
      return BillingItem(
        ser: ser,
        expname: item.expname,
        sdate: item.sdate,
        ldate: item.ldate,
        unit: item.unit,
        term: item.term,
        amount: item.amount,
        vatRate: item.vatRate,
        whtRate: item.whtRate,
      );
    }).toList();

    final combined = <BillingItem>[
      ...widget.existingItems,
      ...newItems,
    ];

    try {
      final response = await _service.saveBillingItems(
        requestUuid: widget.requestUuid,
        items: combined,
      );
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        String errMsg = 'บันทึกไม่สำเร็จ (${response.statusCode})';
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body['message'] is String) {
            errMsg = body['message'] as String;
          }
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errMsg),
            backgroundColor: LrColors.statusRejectedFg,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _isSaving = false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('บันทึกไม่สำเร็จ: $e'),
          backgroundColor: LrColors.statusRejectedFg,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LrColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Header (เหมือน RequestDetailHeader) ───
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [LrColors.headerBg, LrColors.headerAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: LrColors.primary.withOpacity(.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _HeaderIconButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'ยกเลิก',
                    onTap: _isSaving ? null : () => Navigator.pop(context),
                  ),
                  const SizedBox(width: LrSpace.md),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: LrColors.primary.withOpacity(.18),
                      borderRadius: BorderRadius.circular(LrRadius.md),
                      border: Border.all(
                        color: LrColors.primaryAccent.withOpacity(.35),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.playlist_add_rounded,
                      color: LrColors.primaryAccent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: LrSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ADD BILLING',
                          style: LrText.label.copyWith(
                            color: LrColors.primaryAccent.withOpacity(.9),
                            letterSpacing: 1.6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'เพิ่มรายการค่าบริการ',
                          style: LrText.h1.copyWith(
                            color: LrColors.textInverse,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ─── Body (scrollable) ───
            const Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(LcSpace.lg),
                child: AddBillingTable(),
              ),
            ),

            // ─── Footer (บันทึก → ยิง API รวมรายการใหม่+เดิม) — เหมือน RequestDetailFooter ───
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: LrSpace.lg, vertical: LrSpace.md),
              decoration: const BoxDecoration(
                color: LrColors.surfaceMuted,
                border: Border(top: BorderSide(color: LrColors.border, width: 1)),
              ),
              child: Consumer<AddBillingViewModel>(
                builder: (context, vm, _) => Row(
                  children: [
                    Icon(
                      vm.rows.isEmpty
                          ? Icons.edit_note_rounded
                          : Icons.task_alt_rounded,
                      size: 14,
                      color: LrColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      vm.rows.isEmpty
                          ? 'เลือกรายการอย่างน้อย 1 รายการ'
                          : 'พร้อมบันทึก',
                      style: LrText.caption,
                    ),
                    const Spacer(),
                    _FooterCancelButton(
                      onTap:
                          _isSaving ? null : () => Navigator.pop(context),
                    ),
                    const SizedBox(width: LrSpace.sm),
                    _FooterSaveButton(
                      isSaving: _isSaving,
                      count: vm.rows.length,
                      onTap: (vm.rows.isEmpty || _isSaving)
                          ? null
                          : () => _onSave(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Widget — Header Icon Button (like _IconButton ใน RequestDetailHeader)
// ═══════════════════════════════════════════════════════════════════════════
class _HeaderIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_HeaderIconButton> createState() => _HeaderIconButtonState();
}

class _HeaderIconButtonState extends State<_HeaderIconButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _hover
                  ? Colors.white.withOpacity(.18)
                  : Colors.white.withOpacity(.08),
              borderRadius: BorderRadius.circular(LrRadius.sm),
              border: Border.all(
                color: Colors.white.withOpacity(.20),
                width: 1,
              ),
            ),
            child: Icon(widget.icon, size: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Widget — Footer Cancel Button (like _CancelButton ใน RequestDetailFooter)
// ═══════════════════════════════════════════════════════════════════════════
class _FooterCancelButton extends StatefulWidget {
  final VoidCallback? onTap;
  const _FooterCancelButton({this.onTap});

  @override
  State<_FooterCancelButton> createState() => _FooterCancelButtonState();
}

class _FooterCancelButtonState extends State<_FooterCancelButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;
    return MouseRegion(
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) {
        if (!disabled) setState(() => _hover = true);
      },
      onExit: (_) {
        if (!disabled) setState(() => _hover = false);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: disabled
                ? LrColors.surfaceMuted
                : (_hover ? LrColors.statusRejectedBg : Colors.white),
            borderRadius: BorderRadius.circular(LrRadius.md),
            border: Border.all(
              color: disabled
                  ? LrColors.border
                  : (_hover
                      ? LrColors.statusRejectedFg
                      : LrColors.borderStrong),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.close_rounded,
                size: 16,
                color: disabled
                    ? LrColors.textMuted
                    : (_hover
                        ? LrColors.statusRejectedFg
                        : LrColors.textSecondary),
              ),
              const SizedBox(width: 6),
              Text(
                'ยกเลิก',
                style: TextStyle(
                  color: disabled
                      ? LrColors.textMuted
                      : (_hover
                          ? LrColors.statusRejectedFg
                          : LrColors.textSecondary),
                  fontFamily: LrText.fontBold,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Widget — Footer Save Button (like _SaveButton ใน RequestDetailFooter)
// ═══════════════════════════════════════════════════════════════════════════
class _FooterSaveButton extends StatefulWidget {
  final VoidCallback? onTap;
  final int count;
  final bool isSaving;
  const _FooterSaveButton({
    required this.onTap,
    required this.count,
    required this.isSaving,
  });

  @override
  State<_FooterSaveButton> createState() => _FooterSaveButtonState();
}

class _FooterSaveButtonState extends State<_FooterSaveButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;
    return MouseRegion(
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) {
        if (!disabled) setState(() => _hover = true);
      },
      onExit: (_) {
        if (!disabled) setState(() => _hover = false);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Opacity(
          opacity: disabled ? 0.5 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: (_hover && !disabled)
                    ? [LrColors.primaryDark, LrColors.primary]
                    : [LrColors.primary, LrColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(LrRadius.md),
              boxShadow: [
                BoxShadow(
                  color: LrColors.primary.withOpacity(disabled
                      ? 0
                      : (_hover ? .35 : .25)),
                  blurRadius: _hover ? 12 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isSaving)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  const Icon(Icons.check_circle_rounded,
                      size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  widget.isSaving
                      ? 'กำลังบันทึก...'
                      : 'บันทึก ${widget.count} รายการ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: LrText.fontBold,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Widget — Gradient Add Button
// ═══════════════════════════════════════════════════════════════════════════
class _GradientAddButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _GradientAddButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(LcRadius.md),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [LcColors.primary, LcColors.primaryAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(LcRadius.md),
            boxShadow: [
              BoxShadow(
                color: LcColors.primary.withOpacity(.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text(
                  'เพิ่มรายการ',
                  style: TextStyle(
                    fontFamily: LcText.fontBold,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Widget — Inline Dropdown (cleaner cell look)
// ═══════════════════════════════════════════════════════════════════════════
class _InlineDropdown<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _InlineDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: LcColors.surfaceMuted.withOpacity(.5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: LcColors.border),
      ),
      child: DropdownButton<T>(
        value: value,
        hint: Text(hint, style: LcText.caption),
        isDense: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down,
            size: 18, color: LcColors.textSecondary),
        style: LcText.tableCell.copyWith(fontWeight: FontWeight.w600),
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Widget — Badge
// ═══════════════════════════════════════════════════════════════════════════
class _Badge extends StatelessWidget {
  final String text;
  final Color tone;
  final Color bg;
  const _Badge({required this.text, required this.tone, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: LcText.fontBold,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: tone,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Widget — Row Counter Chip
// ═══════════════════════════════════════════════════════════════════════════
class _RowCounter extends StatelessWidget {
  final int count;
  const _RowCounter({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: LcColors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: LcColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.list_alt_rounded,
              size: 14, color: LcColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            'จำนวน $count แถว',
            style: LcText.caption.copyWith(
              color: LcColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Widget — Empty State
// ═══════════════════════════════════════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LcSpace.xl),
      decoration: LcDecor.card(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: LcColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_rounded,
                size: 32, color: LcColors.primary),
          ),
          const SizedBox(height: LcSpace.md),
          const Text('ยังไม่มีรายการค่าบริการ', style: LcText.h2),
          const SizedBox(height: 6),
          const Text('กดปุ่ม "เพิ่มรายการ" เพื่อเริ่มต้น',
              style: LcText.bodyMuted),
          const SizedBox(height: LcSpace.lg),
          _GradientAddButton(onPressed: onAdd),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Dialog — เพิ่มรายการ (Grouped by expType)
// ═══════════════════════════════════════════════════════════════════════════
class _AddRowDialog extends StatefulWidget {
  final AddBillingViewModel vm;
  final VoidCallback onAdd;

  const _AddRowDialog({
    required this.vm,
    required this.onAdd,
  });

  @override
  State<_AddRowDialog> createState() => _AddRowDialogState();
}

class _AddRowDialogState extends State<_AddRowDialog> {
  String? _selectedTypeSer;
  String? _selectedExpName;

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(LcRadius.lg)),
      ),
      backgroundColor: LcColors.cardBg,
      insetPadding: const EdgeInsets.all(LcSpace.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── Header ───
            Container(
              padding: const EdgeInsets.fromLTRB(
                  LcSpace.lg, LcSpace.md, LcSpace.md, LcSpace.md),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [LcColors.primary, LcColors.primaryAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(LcRadius.lg),
                  topRight: Radius.circular(LcRadius.lg),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add_circle_outline_rounded,
                      color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'เพิ่มรายการค่าบริการ',
                      style: TextStyle(
                        fontFamily: LcText.fontBold,
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'ปิด',
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 22),
                    onPressed: () {
                      widget.onAdd();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            // ─── Body (scrollable) ───
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(LcSpace.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: vm.groupedAutoExps.map((entry) {
                    final type = entry.key;
                    final items = entry.value;

                    return Container(
                      margin: const EdgeInsets.only(bottom: LcSpace.md),
                      decoration: BoxDecoration(
                        color: LcColors.cardBg,
                        borderRadius: BorderRadius.circular(LcRadius.md),
                        border: Border.all(color: LcColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ─── Section Header ───
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: LcSpace.md, vertical: LcSpace.sm),
                            decoration: const BoxDecoration(
                              color: LcColors.surfaceMuted,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(LcRadius.md - 1),
                                topRight: Radius.circular(LcRadius.md - 1),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.category_rounded,
                                    size: 16, color: LcColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'ประเภท : ${type.bills ?? 'ไม่ทราบประเภท'}',
                                    style: LcText.h2.copyWith(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ─── Add row dropdown ───
                          Padding(
                            padding: const EdgeInsets.all(LcSpace.md),
                            child: _StyledDropdown<String>(
                              hint: 'เลือกรายการเพื่อเพิ่ม',
                              value: items.any((e) =>
                                          e.expname == _selectedExpName) &&
                                      vm.findExpType(_selectedTypeSer)?.ser ==
                                          type.ser
                                  ? _selectedExpName
                                  : null,
                              items: items.map((exp) {
                                return DropdownMenuItem<String>(
                                  value: exp.expname,
                                  child: Text(exp.expname ?? ''),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val == null) return;
                                final selected = items.firstWhere(
                                  (e) => e.expname == val,
                                  orElse: () => LcAutoExpModel(),
                                );
                                if (selected.expname == null) return;
                                vm.addRow(selected);
                                widget.onAdd();
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // ─── Footer ───
            Container(
              padding: const EdgeInsets.all(LcSpace.md),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: LcColors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('ปิด'),
                    style: TextButton.styleFrom(
                      foregroundColor: LcColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Widget — Styled Dropdown (used in dialog sections)
// ═══════════════════════════════════════════════════════════════════════════
class _StyledDropdown<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _StyledDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: LcColors.surfaceMuted.withOpacity(.6),
        borderRadius: BorderRadius.circular(LcRadius.sm),
        border: Border.all(color: LcColors.border),
      ),
      child: DropdownButton<T>(
        value: value,
        hint: Row(
          children: [
            const Icon(Icons.add, size: 16, color: LcColors.primary),
            const SizedBox(width: 6),
            Text(hint, style: LcText.body.copyWith(color: LcColors.textMuted)),
          ],
        ),
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: LcColors.textSecondary),
        style: LcText.body,
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}
