// ============================================================================
// license_payment_detail_service.dart
// ============================================================================
// Service — โหลด/บันทึก "การรับชำระ" ตาม Payment UUID
//
// ใช้ endpoint ตาม Postman "Chao RAPI - Payment v2 Receipts":
//   - POST   {api_root}/v2/payments                 → สร้าง draft
//   - GET    {api_root}/v2/payments/{uuid}/receipt  → ใบเสร�จ/สรุป
//   - POST   {api_root}/v2/payments/{uuid}/pay      → บันทึกการรับชำระ
//
// หมายเหตุ: GET /api/v2/payments/{uuid} ตอบ 404 (ไม่มีบน nginx)
// uuid ที่ list ส่งมาคือ request_uuid ไม่ใช่ payment_uuid
// จึงต้อง lookup ผ่าน v1 /admin/approvals?uuid=... (เหมือน license_submit_approval_detail_service)
// ============================================================================

import 'dart:convert';
import 'dart:typed_data';

import 'package:chaoperty/Constant/Myconstant.dart';
import 'package:http/http.dart' as http;

import '../../license_request_page/services/license_request_service.dart';
import '../models/license_payment_attachment.dart';
import '../models/license_payment_detail_model.dart';
import '../models/license_payment_method.dart';
import '../models/license_prepayment_model.dart';

class LicensePaymentDetailService {
  LicensePaymentDetailService({LicenseRequestService? requestService})
      : _requestService = requestService ?? LicenseRequestService();

  final LicenseRequestService _requestService;

  Uri _uri(String path) => Uri.parse('${MyConstant().domain_v1}/$path');

  /// สร้าง URL สำหรับ v2 API (`/api/v2/...`) — strip `/v1` ออกจาก domain_v1
  Uri _uriV2(String path) {
    final base = MyConstant().domain_v1;
    final apiRoot = base.replaceFirst(RegExp(r'/v1/?$'), '');
    return Uri.parse('$apiRoot/$path');
  }

  /// ตัด string ให้สั้นลงเพื่อไม่ให้ print() ล้น buffer (Flutter limit ~16KB/line)
  static String _truncate(String s, int maxLen) {
    if (s.length <= maxLen) return s;
    return '${s.substring(0, maxLen)}...[truncated ${s.length - maxLen}b]';
  }

  // ---------- 1. ตรวจสอบรายการรับชำระ ----------
  /// ใช้ v1 /admin/approvals?uuid=<uuid> (เพราะ /api/v2/payments/{uuid} → 404)
  /// uuid ที่ list ส่งมา = request_uuid ของ "คำขอ" ไม่ใช่ payment_uuid
  /// (ดูตัวอย่างใน license_submit_approval_detail_service.dart:38-74)
  Future<PaymentDetail> fetchPaymentDetail({required String uuid}) async {
    if (uuid.trim().isEmpty) throw Exception('Payment UUID is required');

    print('============================================================');
    print('[fetchPaymentDetail] lookup uuid=$uuid via v1 /admin/approvals');
    print('============================================================');

    try {
      final response = await _requestService.fetchRequests(
        query: uuid,
        perPage: 1,
        searchField: 'uuid',
      );

      print('[fetchPaymentDetail] v1 returned ${response.data.length} row(s)');

      if (response.data.isEmpty) {
        throw Exception('ไม่พบรายการที่ตรงกับ uuid=$uuid');
      }

      final r = response.data.first;
      final detail = PaymentDetail(
        uuid: r.uuid ?? uuid,
        paymentNo: r.newRequest?.leaseNumber ?? '-',
        paymentSystem: 'internal', // default
        payType: r.newRequest?.zn ?? '-',
        status: r.status ?? 'draft',
        methodName: r.newRequest?.ln ?? '-',
        payerName: r.client?.cname ?? '-',
        clientTel: r.client?.tel ?? '',
        clientTax: r.client?.tax ?? '',
        clientAddr: '',
        amount: double.tryParse('${r.feeAmount ?? 0}') ?? 0,
        amountReceived: null,
        paidAt: r.newRequest?.ldate,
        createdAt: r.createdAt,
        addons: const [],
      );

      print(
          '[fetchPaymentDetail] mapped: uuid=${detail.uuid} status=${detail.status} paymentNo=${detail.paymentNo} amount=${detail.amount}');
      return detail;
    } catch (e) {
      print('[fetchPaymentDetail][ERROR] $e');
      rethrow;
    }
  }

  // ---------- 1.5 ตรวจสอบการจ่ายล่วงหน้า (Prepayment) ----------
  /// GET {domain_v1}/admin/requests/{uuid}/prepayment
  /// คืนค่า PrepaymentData (หรือ null หากยังไม่มีรายการ)
  Future<PrepaymentData?> fetchPrepayment({required String uuid}) async {
    if (uuid.trim().isEmpty) return null;

    final headers = await MyHeaders.build();
    final uri = _uri('admin/requests/$uuid/prepayment');

    print('============================================================');
    print('[fetchPrepayment] uuid = $uuid');
    print('[fetchPrepayment] URL  = $uri');
    print('============================================================');

    try {
      final res = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      print('[fetchPrepayment] status=${res.statusCode}');

      if (res.statusCode == 404) {
        // ยังไม่มีรายการจ่ายล่วงหน้า → ไม่ใช่ error
        return null;
      }
      if (res.statusCode != 200) {
        print('[fetchPrepayment][ERROR body] ${_truncate(res.body, 200)}');
        throw Exception(
            'โหลดข้อมูลการจ่ายล่วงหน้าไม่สำเร็จ (status: ${res.statusCode})');
      }

      print('[fetchPrepayment][OK body] ${_truncate(res.body, 400)}');

      final body = json.decode(res.body) as Map<String, dynamic>;
      final resp = PrepaymentResponse.fromJson(body);
      return resp.data;
    } catch (e) {
      print('[fetchPrepayment][ERROR] $e');
      rethrow;
    }
  }

  // ---------- 1.5b รายการชำระทั้งหมดของคำขอ (สถานะ) ----------
  /// GET {api_root}/api/v2/requests/{uuid}/payments
  /// คืนค่า RequestPaymentsResponse (data = รายการชำระ + สถานะ)
  Future<RequestPaymentsResponse> fetchRequestPayments(
      {required String uuid}) async {
    if (uuid.trim().isEmpty) {
      return const RequestPaymentsResponse();
    }

    final headers = await MyHeaders.build();
    final uri = _uriV2('v2/requests/$uuid/payments');

    print('============================================================');
    print('[fetchRequestPayments] uuid = $uuid');
    print('[fetchRequestPayments] URL  = $uri');
    print('============================================================');

    try {
      final res = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      print('[fetchRequestPayments] status=${res.statusCode}');

      if (res.statusCode != 200) {
        print('[fetchRequestPayments][ERROR body] ${_truncate(res.body, 200)}');
        throw Exception(
            'โหลดรายการชำระไม่สำเร็จ (status: ${res.statusCode})');
      }

      print('[fetchRequestPayments][OK body] ${_truncate(res.body, 400)}');

      final body = json.decode(res.body) as Map<String, dynamic>;
      return RequestPaymentsResponse.fromJson(body);
    } catch (e) {
      print('[fetchRequestPayments][ERROR] $e');
      rethrow;
    }
  }

  // ---------- 1.6 สร้างรายการรับชำระ (Draft) ----------
  /// POST {api_root}/v2/payments
  /// body: request_uuid, debt_line_uuid, payment_system, pay_type, amount
  /// คืนค่า PaymentDetail ที่สร้างแล้ว (status = draft)
  Future<PaymentDetail> createPayment({
    required String requestUuid,
    required String debtLineUuid,
    required String payType,
    required double amount,
    String paymentSystem = 'external',
    int? paymentMethodId,
  }) async {
    if (requestUuid.trim().isEmpty) {
      throw Exception('request_uuid is required');
    }
    if (debtLineUuid.trim().isEmpty) {
      throw Exception('debt_line_uuid is required');
    }

    final payload = <String, dynamic>{
      'request_uuid': requestUuid.trim(),
      'debt_line_uuid': debtLineUuid.trim(),
      'payment_system': paymentSystem,
      'pay_type': payType.trim(),
      'amount': amount,
      if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
    };

    final headers = await MyHeaders.build();
    final uri = _uriV2('v2/payments');

    print('============================================================');
    print('[createPayment] URL     = $uri');
    print('[createPayment] payload = $payload');
    print('============================================================');

    final res = await http
        .post(
          uri,
          headers: {
            ...headers,
            'Content-Type': 'application/json',
          },
          body: json.encode(payload),
        )
        .timeout(const Duration(seconds: 15));

    print('[createPayment] status=${res.statusCode}');

    if (res.statusCode != 200 && res.statusCode != 201) {
      print('[createPayment][ERROR body] ${_truncate(res.body, 200)}');
      String msg = 'สร้างรายการรับชำระไม่สำเร็จ (status: ${res.statusCode})';
      try {
        final b = json.decode(res.body);
        if (b is Map && b['message'] is String) msg = b['message'] as String;
      } catch (_) {}
      throw Exception(msg);
    }

    print('[createPayment][OK body] ${_truncate(res.body, 400)}');

    final body = json.decode(res.body) as Map<String, dynamic>;
    final data = body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body;
    return PaymentDetail.fromJson(data);
  }

  // ---------- 1.7 ช่องทางการรับชำระ (Lookup) ----------
  /// GET {api_root}/lookup/payments
  /// คืนค่ารายการช่องทาง (เงินสด/โอน/QR ฯลฯ) + บัญชีรับเงิน
  Future<List<LicensePaymentMethod>> fetchPaymentMethods() async {
    final headers = await MyHeaders.build();
    final uri = _uri('lookup/payments');

    print('============================================================');
    print('[fetchPaymentMethods] URL = $uri');
    print('============================================================');

    try {
      final res = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      print('[fetchPaymentMethods] status=${res.statusCode}');

      if (res.statusCode != 200) {
        print('[fetchPaymentMethods][ERROR body] ${_truncate(res.body, 200)}');
        throw Exception(
            'โหลดช่องทางรับชำระไม่สำเร็จ (status: ${res.statusCode})');
      }

      print('[fetchPaymentMethods][OK body] ${_truncate(res.body, 400)}');

      final body = json.decode(res.body);
      final Map<String, dynamic> map =
          body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{};
      return LicensePaymentMethodList.fromJson(map).methods;
    } catch (e) {
      print('[fetchPaymentMethods][ERROR] $e');
      rethrow;
    }
  }

  // ---------- 2. ใบเสร็จ / สรุปการรับชำระ ----------
  Future<PaymentReceipt> fetchReceipt({required String uuid}) async {
    if (uuid.trim().isEmpty) throw Exception('Payment UUID is required');

    final headers = await MyHeaders.build();
    final uri = _uriV2('v2/payments/$uuid/receipt');

    print('============================================================');
    print('[fetchReceipt] uuid = $uuid');
    print('[fetchReceipt] URL  = $uri');
    print('============================================================');

    final res = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 15));

    print('[fetchReceipt] status=${res.statusCode}');

    if (res.statusCode == 404) {
      // ยังไม่บันทึก�ำระ → ไม่มีใบเสร็จ (ไม่ใช่ error)
      return PaymentReceipt.empty();
    }
    if (res.statusCode != 200) {
      print('[fetchReceipt][ERROR body] ${_truncate(res.body, 200)}');
      throw Exception('โหลดใบเสร็จไม่สำเร็จ (status: ${res.statusCode})');
    }

    print('[fetchReceipt][OK body] ${_truncate(res.body, 200)}');

    final body = json.decode(res.body) as Map<String, dynamic>;
    final data = body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body;
    return PaymentReceipt.fromJson(data);
  }

  // ---------- 3. บันทึกการรับชำระ ----------
  /// paymentSystem:
  ///   - 'internal' → body: { amount_received }   (ช่องทางในระบบ — ไม่ต้องมี receipt_no/book_no)
  ///   - 'external' → body: { amount_received, receipt_no, book_no, book_date }
  Future<PaymentDetail> pay({
    required String uuid,
    required double amountReceived,
    String paymentSystem = 'external',
    String? receiptNo,
    String? bookNo,
    String? bookDate,
  }) async {
    if (uuid.trim().isEmpty) throw Exception('Payment UUID is required');

    final isInternal = paymentSystem.toLowerCase() == 'internal';
    final payload = <String, dynamic>{
      'amount_received': amountReceived,
    };
    if (!isInternal) {
      if (receiptNo != null && receiptNo.trim().isNotEmpty) {
        payload['receipt_no'] = receiptNo.trim();
      }
      if (bookNo != null && bookNo.trim().isNotEmpty) {
        payload['book_no'] = bookNo.trim();
      }
      if (bookDate != null && bookDate.trim().isNotEmpty) {
        payload['book_date'] = bookDate.trim();
      }
    }

    final headers = await MyHeaders.build();
    final uri = _uriV2('v2/payments/$uuid/pay');

    print('============================================================');
    print('[pay] uuid    = $uuid');
    print('[pay] URL     = $uri');
    print('[pay] payload = $payload');
    print('============================================================');

    final res = await http
        .post(
          uri,
          headers: {
            ...headers,
            'Content-Type': 'application/json',
          },
          body: json.encode(payload),
        )
        .timeout(const Duration(seconds: 15));

    print('[pay] status=${res.statusCode}');
    if (res.statusCode != 200 && res.statusCode != 201) {
      print('[pay][ERROR body] ${_truncate(res.body, 200)}');
      String msg = 'บันทึกการรับชำระไม่สำเร็จ (status: ${res.statusCode})';
      try {
        final b = json.decode(res.body);
        if (b is Map && b['message'] is String) msg = b['message'] as String;
      } catch (_) {}
      throw Exception(msg);
    }

    print('[pay][OK body] ${_truncate(res.body, 200)}');

    final body = json.decode(res.body) as Map<String, dynamic>;
    final data = body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body;
    return PaymentDetail.fromJson(data);
  }

  // ---------- 4. ประวัติการเปลี่ยนสถานะ (History) ----------
  /// GET {api_root}/v2/payments/{uuid}/history
  /// คืนค่ารายการ history (status change + note + actor)
  Future<PaymentHistoryListResponse> fetchPaymentHistory(
      {required String uuid}) async {
    if (uuid.trim().isEmpty) {
      throw Exception('Payment UUID is required');
    }

    final headers = await MyHeaders.build();
    final uri = _uriV2('v2/payments/$uuid/history');

    print('============================================================');
    print('[fetchPaymentHistory] uuid = $uuid');
    print('[fetchPaymentHistory] URL = $uri');
    print('============================================================');

    try {
      final res = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      print('[fetchPaymentHistory] status=${res.statusCode}');

      if (res.statusCode != 200) {
        print('[fetchPaymentHistory][ERROR body] ${_truncate(res.body, 200)}');
        throw Exception(
            'โหลดประวัติการชำระไม่สำเร็จ (status: ${res.statusCode})');
      }

      print('[fetchPaymentHistory][OK body] ${_truncate(res.body, 400)}');

      final body = json.decode(res.body);
      final Map<String, dynamic> map =
          body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{};
      return PaymentHistoryListResponse.fromJson(map);
    } catch (e) {
      print('[fetchPaymentHistory][ERROR] $e');
      rethrow;
    }
  }

  // ---------- 5. Activity log ----------
  /// GET {api_root}/v2/payments/{uuid}/activity
  /// คืนค่ารายการ activity (event + actor + meta)
  Future<PaymentActivityListResponse> fetchPaymentActivity(
      {required String uuid}) async {
    if (uuid.trim().isEmpty) {
      throw Exception('Payment UUID is required');
    }

    final headers = await MyHeaders.build();
    final uri = _uriV2('v2/payments/$uuid/activity');

    print('============================================================');
    print('[fetchPaymentActivity] uuid = $uuid');
    print('[fetchPaymentActivity] URL = $uri');
    print('============================================================');

    try {
      final res = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      print('[fetchPaymentActivity] status=${res.statusCode}');

      if (res.statusCode != 200) {
        print('[fetchPaymentActivity][ERROR body] ${_truncate(res.body, 200)}');
        throw Exception(
            'โหลด activity log ไม่สำเร็จ (status: ${res.statusCode})');
      }

      print('[fetchPaymentActivity][OK body] ${_truncate(res.body, 400)}');

      final body = json.decode(res.body);
      final Map<String, dynamic> map =
          body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{};
      return PaymentActivityListResponse.fromJson(map);
    } catch (e) {
      print('[fetchPaymentActivity][ERROR] $e');
      rethrow;
    }
  }

  // ---------- 6. อัปโหลดไฟล์แนบ ----------
  /// POST {api_root}/v2/payments/{uuid}/attachments  (multipart/form-data)
  /// field: "file" (single file)
  /// คืนค่า PaymentAttachment ที่อัปโหลดสำเร็จ
  ///
  /// รองรับทั้ง mobile (จาก path) และ web (จาก bytes) — ส่งมาอย่างใดอย่างหนึ่ง
  Future<PaymentAttachment> uploadPaymentAttachment({
    required String uuid,
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
    String fieldName = 'file',
  }) async {
    if (uuid.trim().isEmpty) {
      throw Exception('Payment UUID is required');
    }
    if ((filePath == null || filePath.trim().isEmpty) &&
        (fileBytes == null)) {
      throw Exception('filePath หรือ fileBytes ต้องระบุอย่างใดอย่างหนึ่ง');
    }

    final headers = await MyHeaders.build();
    final uri = _uriV2('v2/payments/$uuid/attachments');

    print('============================================================');
    print('[uploadPaymentAttachment] uuid      = $uuid');
    print('[uploadPaymentAttachment] filePath  = $filePath');
    print('[uploadPaymentAttachment] fileBytes = ${fileBytes?.length ?? '-'}');
    print('[uploadPaymentAttachment] URL       = $uri');
    print('============================================================');

    try {
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      if (fileBytes != null) {
        // web-safe: ส่งเป็น bytes ตรงๆ (ไม่ต้องมี path)
        final name = fileName?.isNotEmpty == true
            ? fileName!
            : 'slip_${DateTime.now().millisecondsSinceEpoch}.jpg';
        request.files.add(
          http.MultipartFile.fromBytes(fieldName, fileBytes, filename: name),
        );
      } else if (filePath != null && filePath.trim().isNotEmpty) {
        // mobile: ใช้ path
        request.files.add(
          await http.MultipartFile.fromPath(fieldName, filePath),
        );
      }

      final streamed = await request.send().timeout(
            const Duration(seconds: 30),
          );

      print('[uploadPaymentAttachment] status=${streamed.statusCode}');

      final body = await streamed.stream.bytesToString();
      print('[uploadPaymentAttachment][body] ${_truncate(body, 400)}');

      if (streamed.statusCode != 200 && streamed.statusCode != 201) {
        String msg =
            'อัปโหลดไฟล์แนบไม่สำเร็จ (status: ${streamed.statusCode})';
        try {
          final b = json.decode(body);
          if (b is Map && b['message'] is String) msg = b['message'] as String;
        } catch (_) {}
        throw Exception(msg);
      }

      final decoded = json.decode(body);
      final Map<String, dynamic> map = decoded is Map
          ? Map<String, dynamic>.from(decoded)
          : <String, dynamic>{};
      final data = map['data'] is Map
          ? Map<String, dynamic>.from(map['data'] as Map)
          : map;
      return PaymentAttachment.fromJson(data);
    } catch (e) {
      print('[uploadPaymentAttachment][ERROR] $e');
      rethrow;
    }
  }

  // ---------- 6.5 รายการไฟล์แนบทั้งหมดของ payment ----------
  /// GET {api_root}/v2/payments/{uuid}/attachments
  /// คืนค่ารายการ attachments (เพื่อเช็คว่าเคยอัปโหลดแล้วหรือยัง)
  /// หาก 404 → คืน [] (ไม่ใช่ error)
  Future<List<PaymentAttachment>> listPaymentAttachments({
    required String uuid,
  }) async {
    if (uuid.trim().isEmpty) return const [];

    final headers = await MyHeaders.build();
    final uri = _uriV2('v2/payments/$uuid/attachments');

    print('============================================================');
    print('[listPaymentAttachments] uuid = $uuid');
    print('[listPaymentAttachments] URL  = $uri');
    print('============================================================');

    try {
      final res = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      print('[listPaymentAttachments] status=${res.statusCode}');

      if (res.statusCode == 404) {
        return const [];
      }
      if (res.statusCode != 200) {
        print('[listPaymentAttachments][ERROR body] ${_truncate(res.body, 200)}');
        return const [];
      }

      final body = json.decode(res.body);
      // รองรับหลายรูปแบบ: { data: [...] } | [...] | { attachments: [...] }
      List raw = const [];
      if (body is List) {
        raw = body;
      } else if (body is Map) {
        final m = body as Map<String, dynamic>;
        if (m['data'] is List) {
          raw = m['data'] as List;
        } else if (m['attachments'] is List) {
          raw = m['attachments'] as List;
        }
      }

      print('[listPaymentAttachments] count=${raw.length}');

      return raw
          .whereType<Map>()
          .map((e) => PaymentAttachment.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      print('[listPaymentAttachments][ERROR] $e');
      return const [];
    }
  }

  // ---------- 7. ดูตัวอย่างไฟล์แนบ ----------
  /// GET {api_root}/v2/payments/attachments/{uuid}/preview
  /// คืนค่าเป็น bytes ของไฟล์ (รูป/PDF) — caller แปลงเป็น Image.memory หรือ save เอง
  /// หาก 404 → คืน null (ไม่ใช่ error)
  Future<Uint8List?> previewPaymentAttachment(
      {required String attachmentUuid}) async {
    if (attachmentUuid.trim().isEmpty) {
      throw Exception('Attachment UUID is required');
    }

    final headers = await MyHeaders.build();
    final uri = _uriV2('v2/payments/attachments/$attachmentUuid/preview');

    print('============================================================');
    print('[previewPaymentAttachment] uuid = $attachmentUuid');
    print('[previewPaymentAttachment] URL  = $uri');
    print('============================================================');

    try {
      final res = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 20));

      print('[previewPaymentAttachment] status=${res.statusCode}');

      if (res.statusCode == 404) {
        // ไม่มีไฟล์ → ไม่ใช่ error
        return null;
      }
      if (res.statusCode != 200) {
        print('[previewPaymentAttachment][ERROR body] ${_truncate(res.body, 200)}');
        throw Exception(
            'โหลดตัวอย่างไฟล์แนบไม่สำเร็จ (status: ${res.statusCode})');
      }

      print('[previewPaymentAttachment] bytes=${res.bodyBytes.length}');

      return res.bodyBytes;
    } catch (e) {
      print('[previewPaymentAttachment][ERROR] $e');
      rethrow;
    }
  }

  // ---------- 8. ดูตัวอย่างลายเซ็นเจ้าหน้าที่ ----------
  /// GET {api_root}/v2/signatures/{uuid}/preview
  /// คืนค่าเป็น bytes ของรูปลายเซ็น (PNG/JPG) — หาก 404 → null
  Future<Uint8List?> previewSignature({required String signatureUuid}) async {
    if (signatureUuid.trim().isEmpty) return null;

    final headers = await MyHeaders.build();
    final uri = _uriV2('v2/signatures/$signatureUuid/preview');

    print('============================================================');
    print('[previewSignature] uuid = $signatureUuid');
    print('[previewSignature] URL  = $uri');
    print('============================================================');

    try {
      final res = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 20));

      print('[previewSignature] status=${res.statusCode}');

      if (res.statusCode == 404) {
        return null;
      }
      if (res.statusCode != 200) {
        print('[previewSignature][ERROR body] ${_truncate(res.body, 200)}');
        throw Exception(
            'โหลดลายเซ็นไม่สำเร็จ (status: ${res.statusCode})');
      }

      print('[previewSignature] bytes=${res.bodyBytes.length}');
      return res.bodyBytes;
    } catch (e) {
      print('[previewSignature][ERROR] $e');
      rethrow;
    }
  }
}
