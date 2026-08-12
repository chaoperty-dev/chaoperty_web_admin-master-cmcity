// ============================================================================
// license_request_billing_service.dart
// ============================================================================
// Service — โหลด "รายการค่าใช้จ่าย" (Step 2 — การชำระ) จาก API
// - เรียก API โดยตรง: GET {domain_v1}/admin/requests/{uuid}/prepayment
// - ใช้ MyHeaders.build() สำหรับ Authorization (เหมือน service อื่นๆ ในระบบ)
// - Parse JSON: body → data → details → List<BillingItem>
// ============================================================================

import 'dart:convert';

import 'package:chaoperty/Constant/Myconstant.dart';
import 'package:http/http.dart' as http;

/// โมเดลรายการค่าใช้จ่าย (Prepayment Detail) — map ตาม JSON ที่ API ส่งกลับ
/// {
///   "ser": "1",
///   "expname": "ค่าเช่าพื้นที่",
///   "sdate": "2026-01-01",
///   "ldate": "2026-12-31",
///   "unit": "เดือน",
///   "term": "12",
///   "total": "500.00",
///   "vat": "7",
///   "wht": "3"
/// }
class BillingItem {
  final String ser;
  final String expname;
  final String sdate;
  final String ldate;
  final String unit;
  final String term;
  final double amount; // ยอดต่องวด
  final double vatRate;
  final double whtRate;

  const BillingItem({
    required this.ser,
    required this.expname,
    required this.sdate,
    required this.ldate,
    required this.unit,
    required this.term,
    required this.amount,
    this.vatRate = 0,
    this.whtRate = 0,
  });

  /// จำนวนงวด (int) — parse จาก term string (null-safe)
  int get periods {
    final n = int.tryParse(term);
    return n ?? 0;
  }

  /// ยอดรวมทั้งหมด = amount * periods
  double get totalAmount => amount * periods;

  /// ยอดสุทธิ (หัก WHT)
  double get net => totalAmount - (totalAmount * whtRate / 100);

  factory BillingItem.fromJson(Map<String, dynamic> json) {
    return BillingItem(
      ser: (json['ser'] ?? '0').toString(),
      expname: (json['expname'] ?? '').toString(),
      sdate: (json['sdate'] ?? '').toString(),
      ldate: (json['ldate'] ?? '').toString(),
      unit: (json['unit'] ?? '').toString(),
      term: (json['term'] ?? '0').toString(),
      // ใช้ total เป็นยอดต่องวด (null-safe + tryParse)
      amount: double.tryParse((json['total'] ?? '0').toString()) ?? 0,
      vatRate: double.tryParse((json['vat'] ?? '0').toString()) ?? 0,
      whtRate: double.tryParse((json['wht'] ?? '0').toString()) ?? 0,
    );
  }
}

class LicenseRequestBillingService {
  LicenseRequestBillingService();

  /// โหลดรายการค่าใช้จ่ายจาก Request UUID
  /// - Endpoint: GET {domain_v1}/admin/requests/{uuid}/prepayment
  /// - Response: { "data": { "details": [ {...}, ... ] } }
  /// - throw Exception เมื่อเกิด error (เพื่อให้ caller จัดการต่อ)
  Future<List<BillingItem>> fetchBillingItems({required String requestUuid}) async {
    if (requestUuid.trim().isEmpty) {
      throw Exception('Request UUID is required');
    }

    final headers = await MyHeaders.build();
    final url = Uri.parse(
        '${MyConstant().domain_v1}/admin/requests/$requestUuid/prepayment');

    final response = await http
        .get(url, headers: headers)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
          'โหลดข้อมูลค่าใช้จ่ายไม่สำเร็จ (status: ${response.statusCode})');
    }

    final body = json.decode(response.body);
    if (body is! Map) {
      throw Exception('รูปแบบข้อมูลไม่ถูกต้อง (body is not a Map)');
    }

    final data = body['data'];
    if (data is! Map) {
      throw Exception('รูปแบบข้อมูลไม่ถูกต้อง (data is not a Map)');
    }

    final details = data['details'];
    if (details is! List) {
      // ไม่มีรายการ → return empty list (ไม่ใช่ error)
      return <BillingItem>[];
    }

    return details
        .whereType<Map<String, dynamic>>()
        .map(BillingItem.fromJson)
        .toList();
  }

  /// โหลดรายการค่าใช้จ่าย — return null เมื่อ error (สำหรับ UI ที่แค่อยากแสดง empty)
  /// ใช้ใน widget ที่ไม่ต้องการ throw exception
  Future<({List<BillingItem> items, String? error})> fetchBillingItemsSafe(
      {required String requestUuid}) async {
    try {
      final items = await fetchBillingItems(requestUuid: requestUuid);
      return (items: items, error: null);
    } catch (e) {
      return (items: <BillingItem>[], error: e.toString());
    }
  }
}
