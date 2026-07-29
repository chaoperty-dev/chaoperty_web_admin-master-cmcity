// ============================================================================
// billing_table.dart
// ============================================================================
// View สำหรับ BillingTable — ใช้ BillingViewModel ผ่าน Provider
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/billing_models.dart';
import '../../viewmodels/billing_view_model.dart';
import '../theme/license_contract_theme.dart';

class BillingTable extends StatelessWidget {
  final Function(List<LcExpTransModel>)? onRowsChanged;

  const BillingTable({
    super.key,
    this.onRowsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<BillingViewModel>(
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
            // ─── Toolbar ───
            Row(
              children: [
                _GradientAddButton(
                  onPressed: () => _showAddDialog(context, vm),
                ),
                const SizedBox(width: 12),
                _RowCounter(count: vm.rows.length),
                const Spacer(),
                if (vm.rows.isNotEmpty)
                  Text(
                    'รวม ${vm.rows.length} รายการ',
                    style: LcText.caption,
                  ),
              ],
            ),
            const SizedBox(height: LcSpace.md),

            // ─── Main Table / Empty State ───
            if (vm.rows.isEmpty)
              _EmptyState(onAdd: () => _showAddDialog(context, vm))
            else
              Container(
                decoration: LcDecor.card(),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width > 1200
                          ? (MediaQuery.of(context).size.width - 320)
                              .clamp(1100, 1400)
                          : 1100,
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
                                value: vm.units.any((u) => u.ser == row.unitser)
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
                                    border: Border.all(color: LcColors.border),
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
                                                DateTime.tryParse(row.sdate!) ??
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
                ),
              ),
            const SizedBox(height: LcSpace.md),

            // ─── Grand Total Card ───
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
              child: Row(
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
                          Text('ยอดรวมทั้งหมด', style: LcText.label),
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
              ),
            ),
          ],
        );
      },
    );
  }

  static final _displayDateFormat = DateFormat('dd-MM-yyyy');

  Future<void> _pickDate(
      BuildContext context, BillingViewModel vm, LcExpTransModel row) async {
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

  void _showAddDialog(BuildContext context, BillingViewModel vm) {
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
          Text('ยังไม่มีรายการค่าบริการ', style: LcText.h2),
          const SizedBox(height: 6),
          Text('กดปุ่ม "เพิ่มรายการ" เพื่อเริ่มต้น', style: LcText.bodyMuted),
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
  final BillingViewModel vm;
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
                    final matchedRows = vm.rows
                        .asMap()
                        .entries
                        .where((e) => e.value.exptser == type.ser)
                        .toList();

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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: LcColors.primaryLight,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '${matchedRows.length} รายการ',
                                    style: LcText.caption.copyWith(
                                      color: LcColors.primaryDark,
                                      fontWeight: FontWeight.w700,
                                    ),
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
                                setState(() {
                                  _selectedTypeSer = type.ser;
                                  _selectedExpName = val;
                                });
                                final selected = items.firstWhere(
                                  (e) => e.expname == val,
                                  orElse: () => LcAutoExpModel(),
                                );
                                if (selected.expname == null) return;
                                vm.addRow(selected);
                                widget.onAdd();
                                Future.microtask(() {
                                  if (mounted) {
                                    setState(() {
                                      _selectedExpName = null;
                                    });
                                  }
                                });
                              },
                            ),
                          ),

                          // ─── Mini table ───
                          if (matchedRows.isNotEmpty)
                            Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: LcColors.border),
                                ),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columnSpacing: 18,
                                  headingRowHeight: 36,
                                  dataRowMinHeight: 40,
                                  dataRowMaxHeight: 52,
                                  headingRowColor: MaterialStateColor.resolveWith(
                                      (states) => LcColors.surfaceMuted),
                                  headingTextStyle: LcText.tableHeader,
                                  dataTextStyle: LcText.tableCell,
                                  columns: const [
                                    DataColumn(label: Text('ประเภท')),
                                    DataColumn(label: Text('ความถี่')),
                                    DataColumn(label: Text('งวด')),
                                    DataColumn(label: Text('ราคา')),
                                    DataColumn(label: Text('ยอดสุทธิ')),
                                    DataColumn(label: Text('')),
                                  ],
                                  rows: matchedRows.map((entry) {
                                    final i = entry.key;
                                    final row = entry.value;
                                    return DataRow(cells: [
                                      DataCell(Text(row.expname ?? '-')),
                                      DataCell(Text(row.unit ?? '-')),
                                      DataCell(Text(row.term ?? '0')),
                                      DataCell(Text(row.amt ?? '0')),
                                      DataCell(Text(
                                        row.total ?? '0.00',
                                        style: LcText.tableCell.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: LcColors.primaryDark,
                                        ),
                                      )),
                                      DataCell(IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: LcColors.danger, size: 18),
                                        onPressed: () {
                                          setState(() {
                                            vm.removeRow(i);
                                          });
                                          widget.onAdd();
                                        },
                                      )),
                                    ]);
                                  }).toList(),
                                ),
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
