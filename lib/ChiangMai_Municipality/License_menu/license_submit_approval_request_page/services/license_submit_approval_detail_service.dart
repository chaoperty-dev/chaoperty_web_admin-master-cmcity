// ============================================================================
// license_submit_approval_detail_service.dart
// ============================================================================
// Service — โหลด/บันทึก "ส่งคำร้องขออนุมัติ" ตาม Payment UUID
// ใช้ endpoint ตาม Postman "Chao RAPI - Payment v2 Receipts":
//   - GET    {domain_v1}/v2/payments/{uuid}        → ตรวจสอบรายการ
//   - GET    {domain_v1}/v2/payments/{uuid}/receipt → หลักฐาน/สรุป
//   - POST   {domain_v1}/v2/payments/{uuid}/pay     → บันทึกส่งคำร้องขออนุมัติ
// ใช้ MyHeaders.build() + http package (เหมือน service อื่นๆ ในระบบ)
// ============================================================================

import 'dart:convert';

import 'package:chaoperty/Constant/Myconstant.dart';
import 'package:http/http.dart' as http;

import '../../license_request_page/services/license_request_service.dart';
import '../models/license_submit_approval_detail_model.dart';
import '../models/submit_approval_detail_extended.dart';
import '../models/submit_approval_rounds_models.dart';

class LicenseSubmitApprovalDetailService {
  LicenseSubmitApprovalDetailService({LicenseRequestService? requestService})
      : _requestService = requestService ?? LicenseRequestService();

  final LicenseRequestService _requestService;

  Uri _uri(String path) => Uri.parse('${MyConstant().domain_v1}/$path');

  /// v2 admin/approvals endpoints อยู่ที่ /api/v2/ ตรงๆ (ไม่ผ่าน /api/v1/)
  Uri _uriV2(String path) {
    final base = MyConstant().domain_v1;
    // base = https://.../api/v1  →  https://.../api
    final apiRoot = base.replaceFirst(RegExp(r'/v1/?$'), '');
    return Uri.parse('$apiRoot/$path');
  }

  // ---------- 1. ตรวจสอบรายส่งคำร้องขออนุมัติ ----------
  /// ใช้ v1 API `/admin/approvals` (เหมือน list) — เพราะ list โหลดจาก v1
  /// ถ้าใช้ v2 `/v2/payments/{uuid}` UUID จะไม่ตรงกัน (v1 = review uuid, v2 = payment uuid)
  Future<SubmitApprovalDetail> fetchSubmitApprovalDetail({required String uuid}) async {
    if (uuid.trim().isEmpty) {
      throw Exception('Payment UUID is required');
    }

    final response = await _requestService.fetchRequests(
      query: uuid,
      perPage: 1,
      searchField: 'uuid',
    );

    if (response.data.isEmpty) {
      // ไม่พบข้อมูล → return empty (ให้ UI แสดง empty state)
      return const SubmitApprovalDetail();
    }

    final r = response.data.first;
    return SubmitApprovalDetail(
      uuid: r.uuid ?? '',
      paymentNo: r.newRequest?.leaseNumber ?? '-',
      paymentSystem: r.newRequest?.subzone ?? '-',
      payType: r.newRequest?.zn ?? '-',
      status: r.status ?? 'draft',
      methodName: r.newRequest?.ln ?? '-',
      payerName: r.client?.cname ?? '-',
      clientTel: r.client?.tel ?? '',
      clientTax: r.client?.tax ?? '',
      clientAddr1: r.client?.addr1 ?? '',
      amount: 0,
      amountReceived: null,
      paidAt: r.newRequest?.ldate,
      createdAt: null,
    );
  }

  // ---------- 2. หลักฐาน / สรุปส่งคำร้องขออนุมัติ ----------
  Future<SubmitApprovalReceipt> fetchReceipt({required String uuid}) async {
    if (uuid.trim().isEmpty) throw Exception('Payment UUID is required');

    final headers = await MyHeaders.build();
    final res = await http
        .get(_uri('v2/payments/$uuid/receipt'), headers: headers)
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 404) {
      // ยังไม่บันทึกส่งคำร้อง → ไม่มีหลักฐาน (ไม่ใช่ error)
      return SubmitApprovalReceipt.empty();
    }
    if (res.statusCode != 200) {
      throw Exception('โหลดหลักฐานไม่สำเร็จ (status: ${res.statusCode})');
    }

    final body = json.decode(res.body) as Map<String, dynamic>;
    final data = body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body;
    return SubmitApprovalReceipt.fromJson(data);
  }

  // ---------- 3. บันทึกส่งคำร้องขออนุมัติ ----------
  Future<SubmitApprovalDetail> pay({
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
      String msg = 'บันทึกส่งคำร้องขออนุมัติไม่สำเร็จ (status: ${res.statusCode})';
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
    return SubmitApprovalDetail.fromJson(data);
  }

  // ==========================================================================
  // Rounds + Steps (v2 admin/approvals)
  // ==========================================================================

  /// POST /v2/admin/approvals/{requestUuid}/rounds
  /// เปิดรอบตรวจใหม่ — body ว่าง, response คืน uuid ของ round
  Future<ApprovalRound> startRound({required String requestUuid}) async {
    if (requestUuid.trim().isEmpty) {
      throw Exception('Request UUID is required');
    }
    final headers = await MyHeaders.build();
    final res = await http
        .post(
          _uriV2('v2/admin/approvals/$requestUuid/rounds'),
          headers: {...headers, 'Content-Type': 'application/json'},
          body: '{}',
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200 && res.statusCode != 201) {
      String msg = 'เปิดรอบตรวจไม่สำเร็จ (status: ${res.statusCode})';
      try {
        final b = json.decode(res.body);
        if (b is Map && b['message'] is String) msg = b['message'] as String;
      } catch (_) {}
      throw Exception(msg);
    }

    final body = json.decode(res.body);
    final data = (body is Map && body['data'] is Map)
        ? Map<String, dynamic>.from(body['data'] as Map)
        : (body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{});
    return ApprovalRound.fromJson(data);
  }

  /// GET /v2/admin/approvals/me
  /// ดึงรายการ step ทั้งหมดที่ admin คนนี้ต้องอนุมัติ
  Future<ApprovalMeData> fetchMyApprovals() async {
    final headers = await MyHeaders.build();
    final res = await http
        .get(_uriV2('v2/admin/approvals/me'), headers: headers)
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('โหลดรายการอนุมัติไม่สำเร็จ (status: ${res.statusCode})');
    }

    final body = json.decode(res.body);
    final data = (body is Map && body['data'] is Map)
        ? Map<String, dynamic>.from(body['data'] as Map)
        : (body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{});
    return ApprovalMeData.fromJson(data);
  }

  /// POST /v2/admin/approvals/{requestUuid}/steps/{stepUuid}/approve
  Future<void> approveStep({
    required String requestUuid,
    required String stepUuid,
    required String remark,
  }) async {
    if (requestUuid.trim().isEmpty) throw Exception('Request UUID required');
    if (stepUuid.trim().isEmpty) throw Exception('Step UUID required');
    final headers = await MyHeaders.build();
    final res = await http
        .post(
          _uriV2('v2/admin/approvals/$requestUuid/steps/$stepUuid/approve'),
          headers: {...headers, 'Content-Type': 'application/json'},
          body: json.encode({'remark': remark}),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200 && res.statusCode != 201) {
      String msg = 'อนุมัติไม่สำเร็จ (status: ${res.statusCode})';
      try {
        final b = json.decode(res.body);
        if (b is Map && b['message'] is String) msg = b['message'] as String;
      } catch (_) {}
      throw Exception(msg);
    }
  }

  /// POST /v2/admin/approvals/{requestUuid}/steps/{stepUuid}/reject
  Future<void> rejectStep({
    required String requestUuid,
    required String stepUuid,
    required String remark,
  }) async {
    if (requestUuid.trim().isEmpty) throw Exception('Request UUID required');
    if (stepUuid.trim().isEmpty) throw Exception('Step UUID required');
    final headers = await MyHeaders.build();
    final res = await http
        .post(
          _uriV2('v2/admin/approvals/$requestUuid/steps/$stepUuid/reject'),
          headers: {...headers, 'Content-Type': 'application/json'},
          body: json.encode({'remark': remark}),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200 && res.statusCode != 201) {
      String msg = 'ปฏิเสธไม่สำเร็จ (status: ${res.statusCode})';
      try {
        final b = json.decode(res.body);
        if (b is Map && b['message'] is String) msg = b['message'] as String;
      } catch (_) {}
      throw Exception(msg);
    }
  }

  /// GET /v2/admin/approvals/{requestUuid}
  /// ดึงรายละเอียด approval ของ request — current_round + steps + history
  Future<ApprovalDetailResponse> fetchApprovalDetail(
      {required String requestUuid}) async {
    if (requestUuid.trim().isEmpty) {
      throw Exception('Request UUID is required');
    }
    final headers = await MyHeaders.build();
    final res = await http
        .get(_uriV2('v2/admin/approvals/$requestUuid'), headers: headers)
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception(
          'โหลดรายละเอียด approval ไม่สำเร็จ (status: ${res.statusCode})');
    }

    final body = json.decode(res.body);
    final data = (body is Map && body['data'] is Map)
        ? Map<String, dynamic>.from(body['data'] as Map)
        : (body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{});
    return ApprovalDetailResponse.fromJson(data);
  }
}
