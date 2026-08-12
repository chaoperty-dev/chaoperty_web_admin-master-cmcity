// ============================================================================
// license_payment_detail_service.dart
// ============================================================================
// Service — โหลด/บันทึก "การรับชำระ" ตาม Payment UUID
// ใช้ endpoint ตาม Postman "Chao RAPI - Payment v2 Receipts":
//   - GET    {domain_v1}/v2/payments/{uuid}        → ตรวจสอบรายการ
//   - GET    {domain_v1}/v2/payments/{uuid}/receipt → ใบเสร็จ/สรุป
//   - POST   {domain_v1}/v2/payments/{uuid}/pay     → บันทึกการรับชำระ
// ใช้ MyHeaders.build() + http package (เหมือน service อื่นๆ ในระบบ)
// ============================================================================

import 'dart:convert';

import 'package:chaoperty/Constant/Myconstant.dart';
import 'package:http/http.dart' as http;

import '../models/license_payment_detail_model.dart';

class LicensePaymentDetailService {
  LicensePaymentDetailService();

  Uri _uri(String path) => Uri.parse('${MyConstant().domain_v1}/$path');

  // ---------- 1. ตรวจสอบรายการรับชำระ ----------
  Future<PaymentDetail> fetchPaymentDetail({required String uuid}) async {
    if (uuid.trim().isEmpty) throw Exception('Payment UUID is required');

    final headers = await MyHeaders.build();
    final res = await http
        .get(_uri('v2/payments/$uuid'), headers: headers)
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('โหลดรายการรับชำระไม่สำเร็จ (status: ${res.statusCode})');
    }

    final body = json.decode(res.body) as Map<String, dynamic>;
    final data = body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body;
    return PaymentDetail.fromJson(data);
  }

  // ---------- 2. ใบเสร็จ / สรุปการรับชำระ ----------
  Future<PaymentReceipt> fetchReceipt({required String uuid}) async {
    if (uuid.trim().isEmpty) throw Exception('Payment UUID is required');

    final headers = await MyHeaders.build();
    final res = await http
        .get(_uri('v2/payments/$uuid/receipt'), headers: headers)
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 404) {
      // ยังไม่บันทึกชำระ → ไม่มีใบเสร็จ (ไม่ใช่ error)
      return PaymentReceipt.empty();
    }
    if (res.statusCode != 200) {
      throw Exception('โหลดใบเสร็จไม่สำเร็จ (status: ${res.statusCode})');
    }

    final body = json.decode(res.body) as Map<String, dynamic>;
    final data = body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body;
    return PaymentReceipt.fromJson(data);
  }

  // ---------- 3. บันทึกการรับชำระ ----------
  Future<PaymentDetail> pay({
    required String uuid,
    required double amountReceived,
    String? receiptNo,
    String? bookNo,
    String? bookDate,
  }) async {
    if (uuid.trim().isEmpty) throw Exception('Payment UUID is required');

    final payload = <String, dynamic>{
      'amount_received': amountReceived,
    };
    if (receiptNo != null && receiptNo.trim().isNotEmpty) {
      payload['receipt_no'] = receiptNo.trim();
    }
    if (bookNo != null && bookNo.trim().isNotEmpty) {
      payload['book_no'] = bookNo.trim();
    }
    if (bookDate != null && bookDate.trim().isNotEmpty) {
      payload['book_date'] = bookDate.trim();
    }

    final headers = await MyHeaders.build();
    final res = await http
        .post(
          _uri('v2/payments/$uuid/pay'),
          headers: {
            ...headers,
            'Content-Type': 'application/json',
          },
          body: json.encode(payload),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200 && res.statusCode != 201) {
      String msg = 'บันทึกการรับชำระไม่สำเร็จ (status: ${res.statusCode})';
      try {
        final b = json.decode(res.body);
        if (b is Map && b['message'] is String) msg = b['message'] as String;
      } catch (_) {}
      throw Exception(msg);
    }

    final body = json.decode(res.body) as Map<String, dynamic>;
    final data = body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body;
    return PaymentDetail.fromJson(data);
  }
}
