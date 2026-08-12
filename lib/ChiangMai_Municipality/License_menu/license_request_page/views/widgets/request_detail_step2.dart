// ============================================================================
// request_detail_step2.dart
// ============================================================================
// Step 2 — ค่ายอดสัญญา (Payment) — read-only view
// - ใช้ ViewModel: LicenseRequestDetailStep2ViewModel (./viewmodels/...)
// - ใช้ Service: LicenseRequestBillingService (./services/...)
// - เรียก API: GET {domain_v1}/admin/requests/{uuid}/prepayment
// - UI สไตล์เดียวกับ BillingTable (license_contract_page)
//   - DD-MM-YYYY date format
//   - Gradient add button
//   - Badge for term
//   - Pill for total (ยอดสุทธิ)
//   - Gradient grand total card
//   - Responsive width (เต็มจอ / ไม่จำกัด 1400)
//   - ใช้ Table widget (FlexColumnWidth) เพื่อให้คอลัมน์ขยายเต็มจอ
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../services/license_request_billing_service.dart';
import '../../viewmodels/license_request_detail_step2_view_model.dart';
import '../theme/license_request_theme.dart';

// ============================================================================
// Main widget
// ============================================================================

class RequestDetailStep2 extends StatefulWidget {
  final String? requestUuid;

  const RequestDetailStep2({super.key, this.requestUuid});

  @override
  State<RequestDetailStep2> createState() => _RequestDetailStep2State();
}

class _RequestDetailStep2State extends State<RequestDetailStep2> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<LicenseRequestDetailStep2ViewModel>();
      final uuid = widget.requestUuid?.trim() ?? '';
      if (uuid.isNotEmpty) {
        vm.loadFromUuid(uuid);
      } else {
        vm.disposeState();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseRequestDetailStep2ViewModel>();

    if (vm.isLoading && vm.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(LrSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Toolbar (gradient add + counter) ───
          Row(
            children: [
              _GradientAddButton(onPressed: () => _onAddRow(context)),
              const SizedBox(width: 12),
              _RowCounter(count: vm.items.length),
              const Spacer(),
              if (vm.items.isNotEmpty)
                Text(
                  'รวม ${vm.items.length} รายการ',
                  style: LrText.caption,
                ),
            ],
          ),
          const SizedBox(height: LrSpace.md),

          // ─── Main Table / Empty State ───
          if (vm.items.isEmpty) _EmptyState() else _buildTable(vm.items),
          const SizedBox(height: LrSpace.md),

          // ─── Grand Total Card ───
          if (vm.items.isNotEmpty) _buildGrandTotal(vm.items),
        ],
      ),
    );
  }

  // ─── Handlers ───
  void _onAddRow(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _ItemFormDialog(
        onSave: (created) {
          context.read<LicenseRequestDetailStep2ViewModel>().addItem(created);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('เพิ่มรายการสำเร็จ (ยังไม่ได้บันทึก)'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  void _onEditRow(BuildContext context, BillingItem item) {
    showDialog<void>(
      context: context,
      builder: (_) => _ItemFormDialog(
        initial: item,
        onSave: (updated) {
          context
              .read<LicenseRequestDetailStep2ViewModel>()
              .updateItem(updated);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('แก้ไขรายการสำเร็จ (ยังไม่ได้บันทึก)'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  Future<void> _onDeleteRow(BuildContext context, BillingItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('ต้องการลบ "${item.expname}" หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    if (!context.mounted) return;
    await context
        .read<LicenseRequestDetailStep2ViewModel>()
        .deleteItem(item.ser);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('ลบรายการสำเร็จ (ยังไม่ได้บันทึก)'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildTable(List<BillingItem> items) {
    final table = Table(
      border: TableBorder(
        horizontalInside:
            BorderSide(color: LrColors.border.withOpacity(.4), width: 0.6),
      ),
      columnWidths: const {
        0: FlexColumnWidth(2.5), // ประเภทค่าบริการ
        1: FlexColumnWidth(1.2), // ความถี่
        2: FlexColumnWidth(1.0), // จำนวนงวด
        3: FlexColumnWidth(1.8), // วันเริ่มต้น
        4: FlexColumnWidth(1.2), // ยอด (บาท)
        5: FlexColumnWidth(1.0), // ประเภท VAT
        6: FlexColumnWidth(1.0), // VAT
        7: FlexColumnWidth(1.0), // ประเภท WHT
        8: FlexColumnWidth(1.0), // WHT
        9: FlexColumnWidth(1.3), // ยอดสุทธิ
        10: FlexColumnWidth(0.6), // action
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        _buildTableHeaderRow(),
        for (int i = 0; i < items.length; i++)
          _buildTableDataRow(items[i], isAlt: i.isEven),
      ],
    );

    return Container(
      decoration: LrDecor.card(),
      clipBehavior: Clip.antiAlias,
      width: double.infinity,
      // ✅ ใช้ LayoutBuilder แยก mobile vs desktop
      // - Mobile (< 600px): SingleChildScrollView (scroll แนวนอน)
      // - Desktop (≥ 600px): Table ขยายเต็มจอโดยตรง (FlexColumnWidth กระจายเต็มพื้นที่)
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                },
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 1100),
                  child: table,
                ),
              ),
            );
          }
          // Desktop: Table fills the full width
          return table;
        },
      ),
    );
  }

  TableRow _buildTableHeaderRow() {
    Widget headerCell(String text) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        color: LrColors.surfaceMuted,
        child: Text(text, style: LrText.tableHeader),
      );
    }

    return TableRow(
      decoration: const BoxDecoration(color: LrColors.surfaceMuted),
      children: [
        headerCell('ประเภทค่าบริการ'),
        headerCell('ความถี่'),
        headerCell('จำนวนงวด'),
        headerCell('วันเริ่มต้น'),
        headerCell('ยอด (บาท)'),
        headerCell('ประเภท VAT'),
        headerCell('VAT'),
        headerCell('ประเภท WHT'),
        headerCell('WHT'),
        headerCell('ยอดสุทธิ'),
        const SizedBox.shrink(),
      ],
    );
  }

  TableRow _buildTableDataRow(BillingItem row, {required bool isAlt}) {
    final bg = isAlt ? LrColors.cardBg : LrColors.surfaceMuted.withOpacity(.5);

    Widget textCell(String text,
        {TextAlign align = TextAlign.left, bool bold = false, Color? color}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Text(
          text.isEmpty ? '-' : text,
          textAlign: align,
          style: LrText.tableCell.copyWith(
            fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            color: color,
          ),
        ),
      );
    }

    Widget chipCell(String text, {Color? color, Color? bg}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: LrText.tableCell.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      );
    }

    Widget dateCell(String text) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: LrColors.surfaceMuted,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: LrColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.event_outlined,
                  size: 14, color: LrColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                text.isEmpty ? 'เลือกวันที่' : _formatDate(text),
                style: LrText.tableCell.copyWith(
                  color:
                      text.isEmpty ? LrColors.textMuted : LrColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget selectCell(String text) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: LrColors.surfaceMuted.withOpacity(.5),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: LrColors.border),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: LrText.tableCell.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    Widget pillNet(String text) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: LrColors.primaryLight,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            text,
            textAlign: TextAlign.right,
            style: LrText.tableCell.copyWith(
              fontWeight: FontWeight.w700,
              color: LrColors.primaryDark,
            ),
          ),
        ),
      );
    }

    return TableRow(
      decoration: BoxDecoration(color: bg),
      children: [
        textCell(row.expname, bold: true),
        selectCell(row.unit.isEmpty ? '-' : row.unit),
        chipCell(row.term,
            color: LrColors.primaryDark, bg: LrColors.primaryLight),
        dateCell(row.sdate),
        textCell(_formatMoney(row.amount), align: TextAlign.right, bold: true),
        selectCell(row.vatRate > 0 ? 'มี' : 'ไม่มี'),
        textCell(row.vatRate.toStringAsFixed(2), align: TextAlign.right),
        selectCell(row.whtRate > 0 ? 'มี' : 'ไม่มี'),
        textCell(row.whtRate.toStringAsFixed(2), align: TextAlign.right),
        pillNet(_formatMoney(row.net)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'แก้ไข',
                icon: const Icon(Icons.edit_outlined,
                    color: LrColors.primaryDark, size: 18),
                onPressed: () => _onEditRow(context, row),
              ),
              IconButton(
                tooltip: 'ลบ',
                icon: const Icon(Icons.delete_outline,
                    color: LrColors.statusRejectedFg, size: 18),
                onPressed: () => _onDeleteRow(context, row),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGrandTotal(List<BillingItem> items) {
    final total = items.fold(0.0, (sum, e) => sum + e.net);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: LrSpace.lg, vertical: LrSpace.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            LrColors.primaryLight.withOpacity(.6),
            LrColors.primary.withOpacity(.08),
          ],
        ),
        borderRadius: BorderRadius.circular(LrRadius.lg),
        border: Border.all(color: LrColors.primary.withOpacity(.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: LrColors.primary,
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
                  const Text('ยอดรวมทั้งหมด', style: LrText.label),
                  const SizedBox(height: 2),
                  Text(
                    'รวม ${items.length} รายการ',
                    style: LrText.caption,
                  ),
                ],
              ),
            ],
          ),
          Text(
            '${total.toStringAsFixed(2)} บาท',
            style: const TextStyle(
              fontFamily: LrText.fontBold,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: LrColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMoney(double v) => NumberFormat("#,##0.00", "en_US").format(v);

  /// ใช้ format DD-MM-YYYY (มี dash) ให้ตรงกับ BillingTable
  String _formatDate(String raw) {
    if (raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd-MM-yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }
}

// ============================================================================
// Sub widgets
// ============================================================================

class _GradientAddButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _GradientAddButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(LrRadius.md),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [LrColors.primary, LrColors.primaryAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(LrRadius.md),
            boxShadow: [
              BoxShadow(
                color: LrColors.primary.withOpacity(.3),
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
                    fontFamily: LrText.fontBold,
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

class _RowCounter extends StatelessWidget {
  final int count;
  const _RowCounter({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: LrColors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: LrColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.list_alt_rounded,
              size: 14, color: LrColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            'จำนวน $count แถว',
            style: LrText.caption.copyWith(
              color: LrColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LrSpace.lg),
      decoration: LrDecor.card(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: LrColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_rounded,
                size: 32, color: LrColors.primary),
          ),
          const SizedBox(height: LrSpace.md),
          const Text('ยังไม่มีรายการค่าบริการ', style: LrText.h2),
          const SizedBox(height: 6),
          const Text('กดปุ่ม "เพิ่มรายการ" เพื่อเริ่มต้น',
              style: LrText.bodyMuted),
        ],
      ),
    );
  }
}

// ============================================================================
// Item form dialog (mock — ไม่เรียก POST จริง)
// ============================================================================

class _ItemFormDialog extends StatefulWidget {
  final BillingItem? initial;
  final void Function(BillingItem) onSave;

  const _ItemFormDialog({
    required this.onSave,
    this.initial,
  });

  @override
  State<_ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<_ItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _periods = TextEditingController(text: '1');
  final _sdate = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );
  final _ldate = TextEditingController(
    text: DateFormat('yyyy-MM-dd')
        .format(DateTime.now().add(const Duration(days: 365))),
  );
  final _unit = TextEditingController(text: 'รายปี');
  final _vatRate = TextEditingController(text: '0');
  final _whtRate = TextEditingController(text: '0');
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    if (i != null) {
      _name.text = i.expname;
      _amount.text = i.amount.toStringAsFixed(2);
      _periods.text = i.term;
      _sdate.text = i.sdate;
      _ldate.text = i.ldate;
      _unit.text = i.unit;
      _vatRate.text = i.vatRate.toStringAsFixed(0);
      _whtRate.text = i.whtRate.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _periods.dispose();
    _sdate.dispose();
    _ldate.dispose();
    _unit.dispose();
    _vatRate.dispose();
    _whtRate.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final amount = double.tryParse(_amount.text.trim()) ?? 0;
    final periods = int.tryParse(_periods.text.trim()) ?? 1;
    final vatRate = double.tryParse(_vatRate.text.trim()) ?? 0;
    final whtRate = double.tryParse(_whtRate.text.trim()) ?? 0;
    final ser =
        widget.initial?.ser ?? DateTime.now().millisecondsSinceEpoch.toString();
    final item = BillingItem(
      ser: ser,
      expname: _name.text.trim(),
      sdate: _sdate.text.trim(),
      ldate: _ldate.text.trim(),
      unit: _unit.text.trim(),
      term: periods.toString(),
      amount: amount,
      vatRate: vatRate,
      whtRate: whtRate,
    );
    widget.onSave(item);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return Dialog(
      backgroundColor: LrColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LrRadius.lg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(LrSpace.lg),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text(
                              isEdit ? 'แก้ไขค่าใช้จ่าย' : 'เพิ่มค่าใช้จ่าย',
                              style: LrText.h1)),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: LrSpace.md),
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(
                      labelText: 'ชื่อรายการ',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'กรุณากรอกชื่อ'
                        : null,
                  ),
                  const SizedBox(height: LrSpace.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _amount,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}$')),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'ยอด/งวด (บาท)',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'กรอกยอด';
                            if (double.tryParse(v) == null)
                              return 'ตัวเลขเท่านั้น';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _unit,
                          decoration: const InputDecoration(
                            labelText: 'หน่วย',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: LrSpace.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _periods,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'จำนวนงวด',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _sdate,
                          decoration: const InputDecoration(
                            labelText: 'วันเริ่มต้น (YYYY-MM-DD)',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: LrSpace.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ldate,
                          decoration: const InputDecoration(
                            labelText: 'วันสิ้นสุด (YYYY-MM-DD)',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _vatRate,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}$')),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'VAT (%)',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: LrSpace.sm),
                  TextFormField(
                    controller: _whtRate,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}$')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'WHT (%)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: LrSpace.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _submitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('ยกเลิก'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _submitting ? null : _submit,
                        icon: _submitting
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const Icon(Icons.save_rounded, size: 16),
                        label: Text(isEdit ? 'บันทึก' : 'เพิ่ม'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: LrColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
