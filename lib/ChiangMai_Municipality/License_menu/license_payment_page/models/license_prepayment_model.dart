// ============================================================================
// license_prepayment_model.dart
// ============================================================================
// Model — ข้อมูล "การจ่ายล่วงหน้า (Prepayment)" ของคำขอ
// map ตาม JSON จาก
//   GET {api_root}/api/v1/admin/requests/{uuid}/prepayment
// ============================================================================

import 'package:intl/intl.dart';

/// แถวรายการค่าใช้จ่ายใน prepayment (fee / fine / ...)
class PrepaymentItem {
  final String uuid;
  final String ser;
  final String expname;
  final String exptser;
  final String unitser;
  final String unit;
  final String? day;
  final String? term;
  final String? sdate;
  final String? ldate;
  final String? qty;
  final String? amt;
  final String? vser;
  final String? vtype;
  final String? nvat;
  final String? vat;
  final String? pvat;
  final String? wser;
  final String? wtype;
  final String? nwht;
  final String? wht;
  final String? total;

  const PrepaymentItem({
    this.uuid = '',
    this.ser = '',
    this.expname = '',
    this.exptser = '',
    this.unitser = '',
    this.unit = '',
    this.day,
    this.term,
    this.sdate,
    this.ldate,
    this.qty,
    this.amt,
    this.vser,
    this.vtype,
    this.nvat,
    this.vat,
    this.pvat,
    this.wser,
    this.wtype,
    this.nwht,
    this.wht,
    this.total,
  });

  factory PrepaymentItem.fromJson(Map<String, dynamic> json) {
    String s(dynamic v) => (v ?? '').toString();
    return PrepaymentItem(
      uuid: s(json['uuid']),
      ser: s(json['ser']),
      expname: s(json['expname']),
      exptser: s(json['exptser']),
      unitser: s(json['unitser']),
      unit: s(json['unit']),
      day: json['day']?.toString(),
      term: json['term']?.toString(),
      sdate: json['sdate']?.toString(),
      ldate: json['ldate']?.toString(),
      qty: json['qty']?.toString(),
      amt: json['amt']?.toString(),
      vser: json['vser']?.toString(),
      vtype: json['vtype']?.toString(),
      nvat: json['nvat']?.toString(),
      vat: json['vat']?.toString(),
      pvat: json['pvat']?.toString(),
      wser: json['wser']?.toString(),
      wtype: json['wtype']?.toString(),
      nwht: json['nwht']?.toString(),
      wht: json['wht']?.toString(),
      total: json['total']?.toString(),
    );
  }

  double get amount => double.tryParse((amt ?? '0').toString()) ?? 0;
  double get totalAmount => double.tryParse((total ?? '0').toString()) ?? 0;

  String get amountDisplay => formatMoney(amount);
  String get totalDisplay => formatMoney(totalAmount);
}

/// ข้อมูล prepayment ทั้งก้อน (data)
class PrepaymentData {
  final int? id;
  final String? uuid;
  final String? requestUuid;
  final List<PrepaymentItem> details;
  final int? active;
  final String? createdAt;
  final String? updatedAt;

  const PrepaymentData({
    this.id,
    this.uuid,
    this.requestUuid,
    this.details = const [],
    this.active,
    this.createdAt,
    this.updatedAt,
  });

  factory PrepaymentData.fromJson(Map<String, dynamic> json) {
    final list = json['details'];
    final details = list is List
        ? list
            .whereType<Map<String, dynamic>>()
            .map(PrepaymentItem.fromJson)
            .toList()
        : <PrepaymentItem>[];

    return PrepaymentData(
      id: json['id'] is int
          ? json['id']
          : int.tryParse((json['id'] ?? '').toString()),
      uuid: (json['uuid'] ?? '').toString(),
      requestUuid: (json['request_uuid'] ?? '').toString(),
      details: details,
      active: json['active'] is int
          ? json['active']
          : int.tryParse((json['active'] ?? '').toString()),
      createdAt: (json['created_at'] ?? '').toString(),
      updatedAt: (json['updated_at'] ?? '').toString(),
    );
  }

  double get grandTotal =>
      details.fold(0.0, (sum, e) => sum + e.totalAmount);

  String get grandTotalDisplay => formatMoney(grandTotal);

  bool get hasDetails => details.isNotEmpty;
}

/// Response wrapper — { "data": { ... } }
class PrepaymentResponse {
  final PrepaymentData? data;

  const PrepaymentResponse({this.data});

  factory PrepaymentResponse.fromJson(Map<String, dynamic> json) {
    final d = json['data'];
    return PrepaymentResponse(
      data: d is Map
          ? PrepaymentData.fromJson(d as Map<String, dynamic>)
          : null,
    );
  }
}

/// Helper format (ทำซ้ำจาก detail model เพื่อไม่ให้เกิด circular import)
String formatMoney(double v) =>
    NumberFormat('#,##0.00', 'en_US').format(v);

String formatPrepayDate(String? raw) {
  if (raw == null || raw.isEmpty) return '-';
  try {
    final dt = DateTime.parse(raw);
    return DateFormat('dd-MM-yyyy').format(dt);
  } catch (_) {
    return raw;
  }
}
