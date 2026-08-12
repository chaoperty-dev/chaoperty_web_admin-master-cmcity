// ============================================================================
// license_payment_service.dart
// ============================================================================
// Service — CRUD operations สำหรับ "การรับชำระ" (Payment v2)
// ใช้ endpoint ตาม Postman "Chao RAPI - Payment v2 Receipts":
//   - POST  {domain_v1}/v2/payments              → สร้าง draft (internal / external)
//   - GET   {domain_v1}/v2/payments?...         → list / search
// ใช้ MyHeaders.build() + http package เหมือน service อื่นๆ ในระบบ
// ============================================================================

import 'dart:convert';

import 'package:chaoperty/Constant/Myconstant.dart';
import 'package:http/http.dart' as http;

import '../models/license_payment_detail_model.dart';

class LicensePaymentService {
  LicensePaymentService();

  Uri _uri(String path) => Uri.parse('${MyConstant().domain_v1}/$path');

  // ---------- 1. สร้าง Payment Draft (Internal / External) ----------
  /// POST /v2/payments
  Future<PaymentDetail> createPaymentDraft({
    required String requestUuid,
    required String paymentSystem,
    required String payType,
    int? paymentMethodId,
    double? amount,
  }) async {
    if (requestUuid.trim().isEmpty) {
      throw Exception('Request UUID is required');
    }
    if (paymentSystem != 'internal' && paymentSystem != 'external') {
      throw Exception('payment_system ต้องเป็น internal หรือ external');
    }

    final payload = <String, dynamic>{
      'request_uuid': requestUuid,
      'payment_system': paymentSystem,
      'pay_type': payType,
    };
    if (paymentSystem == 'internal' && paymentMethodId != null) {
      payload['payment_method_id'] = paymentMethodId;
    }
    if (amount != null) {
      payload['amount'] = amount;
    }

    final headers = await MyHeaders.build();
    final res = await http
        .post(
          _uri('v2/payments'),
          headers: {
            ...headers,
            'Content-Type': 'application/json',
          },
          body: json.encode(payload),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200 && res.statusCode != 201) {
      String msg = 'สร้าง Payment draft ไม่สำเร็จ (status: ${res.statusCode})';
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

  // ---------- 2. List Payments (Search / Filter) ----------
  /// GET /v2/payments?q&sort_by=created_at&sort_dir=desc
  /// Returns list of PaymentDetail (data array)
  Future<List<PaymentDetail>> listPayments({
    String? paymentUuid,
    String? paymentNo,
    String? dateTo,
    String? bookNo,
    String? receiptNo,
    int? perPage,
    String? sortBy,
    String sortDir = 'desc',
  }) async {
    final queryParams = <String, String>{};
    if (paymentUuid != null && paymentUuid.trim().isNotEmpty) {
      queryParams['q'] = paymentUuid;
    }
    if (paymentNo != null && paymentNo.trim().isNotEmpty) {
      queryParams['q'] = paymentNo;
    }
    if (dateTo != null && dateTo.trim().isNotEmpty) {
      queryParams['date_to'] = dateTo;
    }
    if (bookNo != null && bookNo.trim().isNotEmpty) {
      queryParams['book_no'] = bookNo;
    }
    if (receiptNo != null && receiptNo.trim().isNotEmpty) {
      queryParams['receipt_no'] = receiptNo;
    }
    if (perPage != null) {
      queryParams['per_page'] = perPage.toString();
    }
    if (sortBy != null && sortBy.trim().isNotEmpty) {
      queryParams['sort_by'] = sortBy;
    }
    queryParams['sort_dir'] = sortDir;

    final headers = await MyHeaders.build();
    final uri = _uri('v2/payments').replace(
      queryParameters: {
        ...queryParams,
        if (queryParams['q'] == null) 'q': '',
      },
    );
    final res = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      String msg = 'โหลดรายการ Payment ไม่สำเร็จ (status: ${res.statusCode})';
      try {
        final b = json.decode(res.body);
        if (b is Map && b['message'] is String) msg = b['message'] as String;
      } catch (_) {}
      throw Exception(msg);
    }

    final body = json.decode(res.body) as Map<String, dynamic>;
    final rawList = body['data'];
    if (rawList is! List) return <PaymentDetail>[];

    return rawList
        .whereType<Map>()
        .map((m) => PaymentDetail.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }
}
