// ============================================================================
// add_billing_view_model.dart
// ============================================================================
// ViewModel สำหรับ AddBillingTable (license_request_page)
// - copy มาจาก license_contract_page/viewmodels/billing_view_model.dart
// - ใช้ AutoExpService ของตัวเอง (ไม่บล็อก etype F)
// - ใช้โมเดลจาก ../models/auto_exp_models.dart
// ============================================================================

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/auto_exp_models.dart';
import '../services/auto_exp_service.dart';

/// UUID v7 (time-ordered, random) — RFC 9562 §5.7
/// 48-bit unix_ms | 4-bit ver(7) | 12-bit rand_a | 2-bit var(10) | 62-bit rand_b
/// ใช้ hex-string แทน bit ops เพื่อ compatibility กับ platform ที่ int ops จำกัด
String _uuidV7() {
  final rand = Random.secure();
  // 48-bit timestamp as big-endian hex (12 chars)
  var tsHex = DateTime.now().millisecondsSinceEpoch.toRadixString(16);
  if (tsHex.length > 12) {
    tsHex = tsHex.substring(tsHex.length - 12);
  } else {
    tsHex = tsHex.padLeft(12, '0');
  }
  // byte 6: version '7' + high nibble of rand_a
  final verHex = '7${rand.nextInt(0x10).toRadixString(16)}';
  // byte 7: rand_a low byte
  final raLo = rand.nextInt(0x100).toRadixString(16).padLeft(2, '0');
  // byte 8: variant '10' + 6 bits of rand_b
  final varByte =
      (0x80 | rand.nextInt(0x40)).toRadixString(16).padLeft(2, '0');
  // byte 9: rand_b next byte
  final rb1 = rand.nextInt(0x100).toRadixString(16).padLeft(2, '0');
  // bytes 10-15: 6 random bytes
  final r1 = rand.nextInt(0x100).toRadixString(16).padLeft(2, '0');
  final r2 = rand.nextInt(0x100).toRadixString(16).padLeft(2, '0');
  final r3 = rand.nextInt(0x100).toRadixString(16).padLeft(2, '0');
  final r4 = rand.nextInt(0x100).toRadixString(16).padLeft(2, '0');
  final r5 = rand.nextInt(0x100).toRadixString(16).padLeft(2, '0');
  final r6 = rand.nextInt(0x100).toRadixString(16).padLeft(2, '0');

  final body =
      tsHex + verHex + raLo + varByte + rb1 + r1 + r2 + r3 + r4 + r5 + r6;
  return '${body.substring(0, 8)}-'
      '${body.substring(8, 12)}-'
      '${body.substring(12, 16)}-'
      '${body.substring(16, 20)}-'
      '${body.substring(20, 32)}';
}

class AddBillingViewModel extends ChangeNotifier {
  AddBillingViewModel({
    required this.cidSdate,
    required this.cidLdate,
    required this.cidZser,
    AutoExpService? service,
  }) : _service = service ?? AutoExpService();

  final String cidSdate;
  final String cidLdate;
  final String cidZser;
  final AutoExpService _service;

  // ---------- State ----------
  final List<LcExpTypeModel> expTypes = [];
  final List<LcAutoExpModel> autoExps = [];
  final List<LcUnitModel> units = [];
  final List<LcVatModel> vats = [];
  final List<LcWhtModel> whts = [];
  final List<LcExpTransModel> rows = [];

  bool isLoading = true;
  String? error;

  final _dateFormat = DateFormat('yyyy-MM-dd');

  // ---------- Load ----------
  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.loadExpTypes(),
        _service.loadUnits(),
        _service.loadVats(),
        _service.loadWhts(),
      ]);

      expTypes
        ..clear()
        ..addAll(results[0] as List<LcExpTypeModel>);
      units
        ..clear()
        ..addAll(results[1] as List<LcUnitModel>);
      vats
        ..clear()
        ..addAll(results[2] as List<LcVatModel>);
      whts
        ..clear()
        ..addAll(results[3] as List<LcWhtModel>);

      final payStatusFine = await _service.loadPayStatusFine();
      final auto = await _service.loadAutoExps(payStatusFine);
      autoExps
        ..clear()
        ..addAll(auto);

      _addAutoRows();
    } catch (e) {
      error = 'โหลดข้อมูลไม่สำเร็จ: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ---------- Auto rows ----------
  void _addAutoRows() {
    if (rows.isNotEmpty) return;
    for (final exp in autoExps.where((e) => e.auto == '1')) {
      final unit = units.firstWhere(
        (u) => u.ser == exp.unitser,
        orElse: () => LcUnitModel(),
      );
      final vat = vats.firstWhere(
        (v) => v.ser == exp.vat,
        orElse: () => LcVatModel(),
      );
      final wht = whts.firstWhere(
        (w) => w.ser == exp.wht,
        orElse: () => LcWhtModel(),
      );

      rows.add(LcExpTransModel(
        uuid: _uuidV7(),
        ser: exp.ser,
        expname: exp.expname,
        exptser: exp.exptser,
        unitser: exp.unitser,
        unit: exp.unit ?? unit.unit,
        day: unit.day,
        term: exp.term ?? '1',
        sdate:
            cidSdate.isNotEmpty ? cidSdate : _dateFormat.format(DateTime.now()),
        ldate:
            cidLdate.isNotEmpty ? cidLdate : _dateFormat.format(DateTime.now()),
        qty: exp.qty ?? '1',
        amt: exp.priAuto ?? '0.0',
        vser: vat.ser ?? '1',
        vtype: vat.vat ?? '',
        nvat: vat.pct ?? '0',
        wser: wht.ser ?? '1',
        wtype: wht.wht ?? '',
        nwht: wht.pct ?? '0',
      ));
    }
    recalculateAll();
  }

  // ---------- Calculation ----------
  void recalculate(LcExpTransModel row) {
    final price = double.tryParse(row.amt ?? '0') ?? 0;
    final qty = double.tryParse(row.qty ?? '1') ?? 1;
    final vatRate = double.tryParse(row.nvat ?? '0') ?? 0;
    final whtRate = (double.tryParse(row.nwht ?? '0') ?? 0) / 100;

    double basePrice = price;
    double vat = 0;
    double total = 0;

    switch (row.vser) {
      case '2': // รวม VAT แล้ว
        basePrice = price / (1 + vatRate / 100);
        vat = price - basePrice;
        total = price * qty;
        break;
      case '3': // บวก VAT เพิ่ม
        vat = price * (vatRate / 100);
        basePrice = price;
        total = (price + vat) * qty;
        break;
      case '1': // ไม่มี VAT
      default:
        basePrice = price;
        vat = 0;
        total = price * qty;
        break;
    }

    final wht = basePrice * qty * whtRate;
    final netTotal = total - wht;

    row.pvat = basePrice.toStringAsFixed(2);
    row.vat = vat.toStringAsFixed(2);
    row.wht = wht.toStringAsFixed(2);
    row.total = netTotal.toStringAsFixed(2);
  }

  void recalculateAll() {
    for (final row in rows) {
      recalculate(row);
    }
    notifyListeners();
  }

  // ---------- Installments ----------
  int countInstallments(LcExpTransModel row) {
    if (row.sdate == null || row.ldate == null) return 0;
    final start = DateTime.tryParse(row.sdate!);
    final end = DateTime.tryParse(row.ldate!);
    if (start == null || end == null || end.isBefore(start)) return 0;

    final unit = (row.unit ?? '').trim();
    switch (unit) {
      case 'รายปี':
        int y = end.year - start.year;
        if (end.month < start.month ||
            (end.month == start.month && end.day < start.day)) y -= 1;
        return y + 1;
      case 'รายเดือน':
        int m = (end.year - start.year) * 12 + (end.month - start.month);
        if (end.day < start.day) m -= 1;
        return m + 1;
      case 'รายสัปดาห์':
        return ((end.difference(start).inDays + 1) / 7).ceil();
      case 'รายวัน':
        return end.difference(start).inDays + 1;
      case 'ครั้งเดียว':
      case 'เหมาจ่าย':
        return 1;
      default:
        final days = int.tryParse(row.day ?? '0') ?? 0;
        if (days <= 0) return 0;
        return ((end.difference(start).inDays + 1) / days).ceil();
    }
  }

  // ---------- Mutations ----------
  void updateUnit(LcExpTransModel row, String? unitSer) {
    final selected = units.firstWhere(
      (u) => u.ser == unitSer,
      orElse: () => LcUnitModel(),
    );
    row.unitser = selected.ser;
    row.unit = selected.unit;
    row.day = selected.day;
    row.term = countInstallments(row).toString();
    recalculate(row);
    notifyListeners();
  }

  void updateAmount(LcExpTransModel row, String value) {
    row.amt = value;
    recalculate(row);
    notifyListeners();
  }

  void updateDate(LcExpTransModel row, DateTime picked) {
    row.sdate = _dateFormat.format(picked);
    row.term = countInstallments(row).toString();
    recalculate(row);
    notifyListeners();
  }

  void addRow(LcAutoExpModel selected) {
    final unit = units.firstWhere(
      (u) => u.ser == selected.unitser,
      orElse: () => LcUnitModel(),
    );
    final vat = vats.firstWhere(
      (v) => v.ser == selected.vat,
      orElse: () => LcVatModel(),
    );
    final wht = whts.firstWhere(
      (w) => w.ser == selected.wht,
      orElse: () => LcWhtModel(),
    );

    final newRow = LcExpTransModel(
      uuid: _uuidV7(),
      ser: selected.ser,
      expname: selected.expname,
      exptser: selected.exptser,
      unitser: selected.unitser,
      unit: selected.unit ?? unit.unit,
      day: unit.day,
      term: selected.term ?? '1',
      sdate:
          cidSdate.isNotEmpty ? cidSdate : _dateFormat.format(DateTime.now()),
      ldate:
          cidLdate.isNotEmpty ? cidLdate : _dateFormat.format(DateTime.now()),
      qty: selected.qty ?? '1',
      amt: selected.priAuto ?? '0.0',
      vser: vat.ser ?? '1',
      vtype: vat.vat ?? '',
      nvat: vat.pct ?? '0',
      wser: wht.ser ?? '1',
      wtype: wht.wht ?? '',
      nwht: wht.pct ?? '0',
    );
    rows.add(newRow);
    recalculate(newRow);
    notifyListeners();
  }

  void removeRow(int index) {
    rows.removeAt(index);
    notifyListeners();
  }

  /// ค้นหา expType object จาก ser
  LcExpTypeModel? findExpType(String? ser) {
    if (ser == null) return null;
    for (final t in expTypes) {
      if (t.ser == ser) return t;
    }
    return null;
  }

  /// ดึงรายการ autoExps ที่อยู่ในประเภท (exptser) ที่ระบุ
  List<LcAutoExpModel> itemsForExpType(String? exptser) {
    if (exptser == null) return [];
    return autoExps.where((e) => e.exptser == exptser).toList();
  }

  /// อัปเดตประเภท VAT (vser/vtype/nvat)
  void updateVat(LcExpTransModel row, String? vser) {
    final selected = vats.firstWhere(
      (v) => v.ser == vser,
      orElse: () => LcVatModel(),
    );
    row.vser = selected.ser ?? '1';
    row.vtype = selected.vat ?? '';
    row.nvat = selected.pct ?? '0';
    recalculate(row);
    notifyListeners();
  }

  /// อัปเดตประเภท WHT (wser/wtype/nwht)
  void updateWht(LcExpTransModel row, String? wser) {
    final selected = whts.firstWhere(
      (w) => w.ser == wser,
      orElse: () => LcWhtModel(),
    );
    row.wser = selected.ser ?? '1';
    row.wtype = selected.wht ?? '';
    row.nwht = selected.pct ?? '0';
    recalculate(row);
    notifyListeners();
  }

  /// คืนรายการที่จัดกลุ่มตาม exptser — ใช้สำหรับ dialog แบบ grouped
  List<MapEntry<LcExpTypeModel, List<LcAutoExpModel>>> get groupedAutoExps {
    final entries = <MapEntry<LcExpTypeModel, List<LcAutoExpModel>>>[];
    for (final type in expTypes) {
      final items = itemsForExpType(type.ser);
      if (items.isNotEmpty) {
        entries.add(MapEntry(type, items));
      }
    }
    return entries;
  }

  double get grandTotal {
    return rows.fold(
      0.0,
      (sum, row) => sum + (double.tryParse(row.total ?? '0') ?? 0),
    );
  }
}
