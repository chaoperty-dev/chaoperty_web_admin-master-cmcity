// ============================================================================
// request_detail_step2.dart
// ============================================================================
// Step 3 — การชำระ (Payment)
// - เขียนใหม่ทั้งหมด ไม่ดึง class/method จาก new_contract_cmm.dart
// - ใช้ UI style เลียนแบบ billing_table.dart แต่ปรับใช้ Lr* theme
// - เรียก API จริง: read_GC_ExpAuto + read_GC_ExpType (เท่าที่มีใน step 3 เดิม)
// - CRUD เป็น local-only (mock) เพราะ step 3 เดิมไม่ได้เรียก POST/PUT/DELETE
// ============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../Constant/Myconstant.dart';
import '../theme/license_request_theme.dart';

// ============================================================================
// Local models (สร้างใหม่ ไม่ reuse class เดิม)
// ============================================================================

/// รายการ expAuto (ค่าใช้จ่ายอัตโนมัติ)
class LrExpAuto {
  final String ser;
  final String expname;
  final String freq; // ความถี่ เช่น "เดือน", "ปี"
  final int periods; // จำนวนงวด
  final String sdate; // วันเริ่มต้น
  final double amount; // ยอดเงิน
  final String? vatType;
  final double vatRate;
  final String? whtType;
  final double whtRate;

  const LrExpAuto({
    required this.ser,
    required this.expname,
    required this.freq,
    required this.periods,
    required this.sdate,
    required this.amount,
    this.vatType,
    this.vatRate = 0,
    this.whtType,
    this.whtRate = 0,
  });

  double get net => amount - (amount * whtRate / 100);

  factory LrExpAuto.fromJson(Map<String, dynamic> json) {
    return LrExpAuto(
      ser: (json['ser'] ?? '0').toString(),
      expname: (json['expname'] ?? json['name'] ?? '').toString(),
      freq: (json['freq'] ?? json['frequency'] ?? '').toString(),
      periods: int.tryParse((json['periods'] ?? json['qty'] ?? '0').toString()) ?? 0,
      sdate: (json['sdate'] ?? json['start_date'] ?? '').toString(),
      amount: double.tryParse((json['amount'] ?? json['total'] ?? '0').toString()) ?? 0,
      vatType: json['vat_type']?.toString() ?? json['vatType']?.toString(),
      vatRate: double.tryParse((json['vat_rate'] ?? json['vat'] ?? '0').toString()) ?? 0,
      whtType: json['wht_type']?.toString() ?? json['whtType']?.toString(),
      whtRate: double.tryParse((json['wht_rate'] ?? json['wht'] ?? '0').toString()) ?? 0,
    );
  }
}

/// ประเภท expAuto (PayType)
class LrExpType {
  final String ser;
  final String tn;

  const LrExpType({required this.ser, required this.tn});

  factory LrExpType.fromJson(Map<String, dynamic> json) {
    return LrExpType(
      ser: (json['ser'] ?? '0').toString(),
      tn: (json['tn'] ?? json['name'] ?? '').toString(),
    );
  }
}

// ============================================================================
// Private service (สร้างใหม่ ไม่ reuse API_expauto หรือ service เดิม)
// ============================================================================

class _LrExpService {
  final String _base = MyConstant().domain;

  Future<List<LrExpAuto>> fetchExpAuto(String rser) async {
    final url = '$_base/GC_expauto.php?isAdd=true&ren=$rser';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return <LrExpAuto>[];
      final body = json.decode(response.body);
      if (body is! List) return <LrExpAuto>[];
      return body
          .whereType<Map<String, dynamic>>()
          .map(LrExpAuto.fromJson)
          .toList();
    } catch (e) {
      debugPrint('_LrExpService.fetchExpAuto error: $e');
      return <LrExpAuto>[];
    }
  }

  Future<List<LrExpType>> fetchExpType(String rser) async {
    final url = '$_base/GC_exptype.php?isAdd=true&ren=$rser';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return <LrExpType>[];
      final body = json.decode(response.body);
      if (body is! List) return <LrExpType>[];
      return body
          .whereType<Map<String, dynamic>>()
          .map(LrExpType.fromJson)
          .toList();
    } catch (e) {
      debugPrint('_LrExpService.fetchExpType error: $e');
      return <LrExpType>[];
    }
  }
}

// ============================================================================
// Main widget
// ============================================================================

class RequestDetailStep2 extends StatefulWidget {
  const RequestDetailStep2({super.key});

  @override
  State<RequestDetailStep2> createState() => _RequestDetailStep2State();
}

class _RequestDetailStep2State extends State<RequestDetailStep2> {
  final _service = _LrExpService();

  List<LrExpAuto> _items = [];
  List<LrExpType> _types = [];
  bool _isLoading = true;
  String? _rser;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _rser = prefs.getString('renTalSer') ?? '';
    } catch (e) {
      debugPrint('SharedPreferences error: $e');
    }
    await _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final rser = _rser ?? '';
    final results = await Future.wait([
      _service.fetchExpAuto(rser),
      _service.fetchExpType(rser),
    ]);
    if (!mounted) return;
    setState(() {
      _items = results[0] as List<LrExpAuto>;
      _types = results[1] as List<LrExpType>;
      _isLoading = false;
    });
  }

  Future<void> _refresh() => _load();

  Future<void> _deleteItem(LrExpAuto item) async {
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
    if (!mounted) return;
    setState(() => _items.removeWhere((e) => e.ser == item.ser));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ลบ "${item.expname}" (local)'),
        backgroundColor: LrColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _editItem(LrExpAuto item) {
    showDialog<void>(
      context: context,
      builder: (_) => _ItemFormDialog(
        types: _types,
        initial: item,
        onSave: (updated) {
          if (!mounted) return;
          setState(() {
            final i = _items.indexWhere((e) => e.ser == updated.ser);
            if (i >= 0) _items[i] = updated;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('แก้ไขเรียบร้อย (local)'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  void _addItem() {
    showDialog<void>(
      context: context,
      builder: (_) => _ItemFormDialog(
        types: _types,
        onSave: (created) {
          if (!mounted) return;
          setState(() => _items.add(created));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('เพิ่มเรียบร้อย (local)'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  String _fmtMoney(double v) {
    final f = NumberFormat("#,##0.00", "en_US");
    return f.format(v);
  }

  String _fmtDate(String raw) {
    if (raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }

  double get _totalNet => _items.fold(0.0, (sum, e) => sum + e.net);

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(LrSpace.lg),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── Header pill ───
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: LrSpace.md, vertical: LrSpace.sm),
                  decoration: BoxDecoration(
                    color: LrColors.primaryLight.withOpacity(.25),
                    borderRadius: BorderRadius.circular(LrRadius.md),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.payments_rounded,
                          size: 18, color: LrColors.primaryDark),
                      const SizedBox(width: 8),
                      const Text('การชำระ', style: LrText.h2),
                      const Spacer(),
                      _AddButton(onPressed: _addItem),
                    ],
                  ),
                ),
                const SizedBox(height: LrSpace.md),

                // ─── Counter bar (เลียนแบบ billing_table) ───
                Row(
                  children: [
                    _RowCounter(count: _items.length),
                    const Spacer(),
                    if (_items.isNotEmpty)
                      Text(
                        'รวม ${_items.length} รายการ',
                        style: LrText.caption,
                      ),
                  ],
                ),
                const SizedBox(height: LrSpace.md),

                // ─── Main Table / Empty State ───
                if (_items.isEmpty)
                  _EmptyState(onAdd: _addItem)
                else
                  Container(
                    decoration: LrDecor.card(),
                    clipBehavior: Clip.antiAlias,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 1100),
                        child: DataTable(
                          columnSpacing: 22,
                          headingRowHeight: 46,
                          dataRowMinHeight: 56,
                          dataRowMaxHeight: 68,
                          headingRowColor:
                              MaterialStateColor.resolveWith(
                                  (_) => LrColors.surfaceMuted),
                          headingTextStyle: LrText.tableHeader,
                          dataTextStyle: LrText.tableCell,
                          dividerThickness: 0.6,
                          showBottomBorder: true,
                          columns: const [
                            DataColumn(label: Text('ประเภทค่าบริการ')),
                            DataColumn(label: Text('ความถี่')),
                            DataColumn(
                                label: Text('จำนวนงวด'), numeric: true),
                            DataColumn(label: Text('วันเริ่มต้น')),
                            DataColumn(
                                label: Text('ยอด (บาท)'), numeric: true),
                            DataColumn(label: Text('VAT (%)')),
                            DataColumn(label: Text('WHT (%)')),
                            DataColumn(
                                label: Text('ยอดสุทธิ'), numeric: true),
                            DataColumn(label: Text('')),
                          ],
                          rows: _items
                              .asMap()
                              .entries
                              .map((entry) => _buildRow(entry.key, entry.value))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: LrSpace.lg),

                // ─── Total ───
                if (_items.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(LrSpace.md),
                    decoration: LrDecor.softCard(),
                    child: Row(
                      children: [
                        const Icon(Icons.summarize_rounded,
                            size: 18, color: LrColors.primary),
                        const SizedBox(width: 8),
                        Text('ยอดรวมสุทธิ',
                            style: LrText.bodyMuted
                                .copyWith(fontFamily: LrText.fontBold)),
                        const Spacer(),
                        Text(
                          _fmtMoney(_totalNet),
                          style: LrText.h2.copyWith(
                            color: LrColors.primary,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('บาท', style: LrText.caption),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(int i, LrExpAuto row) {
    final isAlt = i.isEven;
    return DataRow(
      color: MaterialStateColor.resolveWith(
        (_) => isAlt ? LrColors.cardBg : LrColors.surfaceMuted.withOpacity(.5),
      ),
      cells: [
        DataCell(
          Text(row.expname.isEmpty ? '-' : row.expname,
              style: LrText.tableCell),
        ),
        DataCell(
          Text(row.freq.isEmpty ? '-' : row.freq, style: LrText.tableCell),
        ),
        DataCell(
          Center(child: Text('${row.periods}', style: LrText.tableCell)),
        ),
        DataCell(
          Text(_fmtDate(row.sdate), style: LrText.tableCell),
        ),
        DataCell(
          Text(_fmtMoney(row.amount),
              style: LrText.tableCell
                  .copyWith(fontFamily: LrText.fontBold)),
        ),
        DataCell(
          Center(
            child: Text(row.vatRate > 0 ? row.vatRate.toStringAsFixed(0) : '-',
                style: LrText.tableCell),
          ),
        ),
        DataCell(
          Center(
            child: Text(row.whtRate > 0 ? row.whtRate.toStringAsFixed(0) : '-',
                style: LrText.tableCell),
          ),
        ),
        DataCell(
          Text(_fmtMoney(row.net),
              style: LrText.tableCell.copyWith(
                color: LrColors.primary,
                fontFamily: LrText.fontBold,
              )),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconAction(
                icon: Icons.edit_rounded,
                color: LrColors.statusInfoFg,
                onPressed: () => _editItem(row),
              ),
              const SizedBox(width: 4),
              _IconAction(
                icon: Icons.delete_rounded,
                color: LrColors.statusRejectedFg,
                onPressed: () => _deleteItem(row),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Sub widgets (เลียนแบบ billing_table.dart)
// ============================================================================

class _AddButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _AddButton({required this.onPressed});
  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
  bool _hover = false;
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _down
                ? LrColors.primaryDark
                : (_hover ? LrColors.primary : LrColors.primaryAccent),
            borderRadius: BorderRadius.circular(LrRadius.pill),
            boxShadow: _hover
                ? [
                    BoxShadow(
                      color: LrColors.primary.withOpacity(.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.add_rounded, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Text('เพิ่มค่าใช้จ่าย',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'LINESeed1',
                    fontWeight: FontWeight.w600,
                  )),
            ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: LrColors.primaryLight,
        borderRadius: BorderRadius.circular(LrRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.list_alt_rounded,
              size: 14, color: LrColors.primaryDark),
          const SizedBox(width: 6),
          Text(
            '$count รายการ',
            style: LrText.caption.copyWith(
              color: LrColors.primaryDark,
              fontFamily: LrText.fontBold,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  const _IconAction({
    required this.icon,
    required this.color,
    required this.onPressed,
  });
  @override
  State<_IconAction> createState() => _IconActionState();
}

class _IconActionState extends State<_IconAction> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _hover ? widget.color.withOpacity(.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(LrRadius.sm),
          ),
          child: Icon(widget.icon, size: 16, color: widget.color),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LrDecor.card(),
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: LrColors.primary.withOpacity(.10),
              borderRadius: BorderRadius.circular(LrRadius.lg),
            ),
            child: const Icon(Icons.payments_outlined,
                size: 36, color: LrColors.primary),
          ),
          const SizedBox(height: LrSpace.md),
          const Text('ยังไม่มีรายการค่าใช้จ่าย',
              style: LrText.h2, textAlign: TextAlign.center),
          const SizedBox(height: LrSpace.sm),
          const Text('กดปุ่ม "เพิ่มค่าใช้จ่าย" เพื่อเริ่มต้น',
              style: LrText.bodyMuted, textAlign: TextAlign.center),
          const SizedBox(height: LrSpace.lg),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('เพิ่มค่าใช้จ่าย'),
            style: OutlinedButton.styleFrom(
              foregroundColor: LrColors.primary,
              side: const BorderSide(color: LrColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}


// ============================================================================
// Item form dialog (mock — ไม่เรียก POST จริง)
// ============================================================================

class _ItemFormDialog extends StatefulWidget {
  final List<LrExpType> types;
  final LrExpAuto? initial;
  final void Function(LrExpAuto) onSave;

  const _ItemFormDialog({
    required this.types,
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
  final _vatRate = TextEditingController(text: '0');
  final _whtRate = TextEditingController(text: '0');
  String? _type;
  String? _freq;
  bool _submitting = false;

  static const _freqOptions = ['เดือน', 'ปี', 'ครั้งเดียว', 'ไตรมาส'];

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    if (i != null) {
      _name.text = i.expname;
      _amount.text = i.amount.toStringAsFixed(2);
      _periods.text = i.periods.toString();
      _sdate.text = i.sdate;
      _vatRate.text = i.vatRate.toStringAsFixed(0);
      _whtRate.text = i.whtRate.toStringAsFixed(0);
      _type = i.vatType;
      _freq = i.freq;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _periods.dispose();
    _sdate.dispose();
    _vatRate.dispose();
    _whtRate.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_freq == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกความถี่')),
      );
      return;
    }
    setState(() => _submitting = true);
    final amount = double.tryParse(_amount.text.trim()) ?? 0;
    final periods = int.tryParse(_periods.text.trim()) ?? 1;
    final vatRate = double.tryParse(_vatRate.text.trim()) ?? 0;
    final whtRate = double.tryParse(_whtRate.text.trim()) ?? 0;
    final ser = widget.initial?.ser ??
        DateTime.now().millisecondsSinceEpoch.toString();
    final item = LrExpAuto(
      ser: ser,
      expname: _name.text.trim(),
      freq: _freq!,
      periods: periods,
      sdate: _sdate.text.trim(),
      amount: amount,
      vatType: _type,
      vatRate: vatRate,
      whtType: _type,
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
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'กรุณากรอกชื่อ' : null,
                  ),
                  const SizedBox(height: LrSpace.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _amount,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}$')),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'ยอด (บาท)',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'กรอกยอด';
                            if (double.tryParse(v) == null) return 'ตัวเลขเท่านั้น';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _freq,
                          decoration: const InputDecoration(
                            labelText: 'ความถี่',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: _freqOptions
                              .map((f) => DropdownMenuItem<String>(
                                    value: f,
                                    child: Text(f),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _freq = v),
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
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _type,
                          decoration: const InputDecoration(
                            labelText: 'ประเภท (PayType)',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: <DropdownMenuItem<String>>[
                            const DropdownMenuItem<String>(
                                value: null, child: Text('- ไม่ระบุ -')),
                            for (final t in widget.types)
                              DropdownMenuItem<String>(
                                value: t.ser,
                                child: Text(t.tn),
                              ),
                          ],
                          onChanged: (v) => setState(() => _type = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _vatRate,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
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
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
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
