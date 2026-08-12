// ============================================================================
// license_approve_step2_service.dart
// ============================================================================
// Service — โหลดข้อมูล + เรียก API สำหรับหน้า "อนุมัติคำขอ" (Step 2)
// - ReviewDetail + ApproveDocuments + ลายเซ็นผู้อนุมัติ
// - Upload หลักฐาน + Preview รูป
// - Approve / Reject คำขอ
// ============================================================================

import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'package:chaoperty/Constant/Myconstant.dart';

import '../../../Model/ReviewUuid_Model.dart';
import '../../../unity/API_admin_reject.dart';
import '../../../unity/API_admin_signature.dart';
import '../../../unity/API_approvals_roles%26checkup.dart';
import '../../../unity/API_requests_reviews.dart';
import '../../../unity/API_requests_reviewsflow.dart';
import '../viewmodels/license_approve_detail_step2_view_model.dart';

/// Service — จัดการ API ทั้งหมดของ Step 2
class LicenseApproveStep2Service {
  // ===========================================================================
  // Auth headers (สำหรับเรียก PDF preview)
  // ===========================================================================

  /// สร้าง auth headers (ใช้ token เดียวกับ API อื่นๆ)
  Future<Map<String, String>> buildAuthHeaders() async {
    return await MyHeaders.build();
  }

  // ===========================================================================
  // ReviewDetail + ApproveDocuments
  // ===========================================================================

  /// โหลด ReviewDetail ตาม requestUuid
  Future<ReviewDetail?> fetchReviewDetail(String? uuid) async {
    if (uuid == null || uuid.isEmpty) return null;
    final resp = await read_GC_ReviewsUuid(uuid);
    if (resp == null || resp.statusCode != 200) return null;
    try {
      final result = json.decode(resp.body) as Map<String, dynamic>;
      return ReviewDetail.fromJson(result['data'] as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// โหลด ApproveDocuments (รายการเอกสาร + ไฟล์แนบของผู้ตรวจสอบ)
  /// และ RequestDocuments (รายการเอกสารที่ผู้เช่า/ผู้ค้าส่งมา)
  Future<(List<LaApproveDocument>, List<LaRequestDocument>)>
      fetchApprovalsCheckUp(String? uuid) async {
    if (uuid == null || uuid.isEmpty) {
      return (<LaApproveDocument>[], <LaRequestDocument>[]);
    }
    final resp = await read_GC_ApprovalsCheckUp(uuid);
    if (resp == null || resp.statusCode != 200) {
      return (<LaApproveDocument>[], <LaRequestDocument>[]);
    }
    try {
      final jsonMap = json.decode(resp.body) as Map<String, dynamic>;
      final data = jsonMap['data'] as Map<String, dynamic>?;
      if (data == null) return (<LaApproveDocument>[], <LaRequestDocument>[]);

      final List<LaApproveDocument> approves = <LaApproveDocument>[];
      if (data['approve_documents'] is List) {
        approves.addAll((data['approve_documents'] as List)
            .whereType<Map<String, dynamic>>()
            .map(LaApproveDocument.fromJson));
      }

      final List<LaRequestDocument> requests = <LaRequestDocument>[];
      if (data['request_document'] is List) {
        requests.addAll((data['request_document'] as List)
            .whereType<Map<String, dynamic>>()
            .map(LaRequestDocument.fromJson));
      }

      return (approves, requests);
    } catch (_) {
      return (<LaApproveDocument>[], <LaRequestDocument>[]);
    }
  }

  // ===========================================================================
  // Image / thumbnail fetchers
  // ===========================================================================

  /// โหลดไฟล์ภาพจาก approve attachment (สำหรับผู้ตรวจสอบ)
  Future<Uint8List?> fetchApproveImage({
    required String? requestUuid,
    required String? attachmentUuid,
  }) async {
    final resp = await img_ApprovalsCheckUp(requestUuid, attachmentUuid);
    if (resp == null || resp.statusCode != 200) return null;
    return resp.bodyBytes;
  }

  /// โหลดไฟล์ภาพจาก reviewer attachment (สำหรับผู้เช่า)
  Future<Uint8List?> fetchRequesterImage(String? attachmentUuid) async {
    final resp = await img_ApprovalsRequests(attachmentUuid);
    if (resp == null || resp.statusCode != 200) return null;
    return resp.bodyBytes;
  }

  // ===========================================================================
  // Upload examiner file
  // ===========================================================================

  /// เปิด file picker + อัปโหลดไฟล์หลักฐาน
  /// คืนค่า http.Response? (status 200/201 = สำเร็จ)
  Future<http.Response?> pickAndUploadFile({
    required String uuid,
    required int docId,
  }) async {
    return await pickAndUpload_CheckUp(uuid, docId);
  }

  // ===========================================================================
  // Approver signature
  // ===========================================================================

  /// โหลดลายเซ็นผู้อนุมัติ (profile + signature image)
  Future<LaApproverSignature?> fetchApproverSignature() async {
    try {
      final resp = await read_AdminSignature();
      if (resp == null || resp.statusCode != 200) return null;
      final result = json.decode(resp.body);
      if (result is! Map) return null;
      final data = result['data'];
      if (data is! Map) return null;
      final profileUuid = data['profile_uuid']?.toString() ?? '';
      final signatureUuid = data['signature_uuid']?.toString() ?? '';
      final profileName = data['profile']?.toString() ?? '';
      final positionName = data['position_name']?.toString() ?? '';

      Uint8List? bytes;
      if (signatureUuid.isNotEmpty) {
        final imgResp = await img_signatureUuid(signatureUuid: signatureUuid);
        if (imgResp != null && imgResp.statusCode == 200) {
          bytes = imgResp.bodyBytes;
        }
      }

      return LaApproverSignature(
        profileUuid: profileUuid,
        signatureUuid: signatureUuid,
        profileName: profileName,
        positionName: positionName,
        signatureBytes: bytes,
      );
    } catch (_) {
      return null;
    }
  }

  // ===========================================================================
  // Flow / Approve / Reject
  // ===========================================================================

  /// ดึง flowUuid (triggered_approval_uuid) สำหรับ approve/reject
  Future<String?> fetchFlowUuid(String? requestUuid) async {
    if (requestUuid == null || requestUuid.isEmpty) return null;
    final resp = await read_GC_ReviewsFlowUuid(UuidRequest: requestUuid);
    if (resp == null || resp.statusCode != 200) return null;
    try {
      final result = json.decode(resp.body) as Map<String, dynamic>;
      final data = result['data'] as Map<String, dynamic>?;
      if (data == null) return null;
      return data['triggered_approval_uuid']?.toString();
    } catch (_) {
      return null;
    }
  }

  /// ยิง API อนุมัติ (Post_ReviewsFlowApprove)
  Future<http.Response?> approve({
    required String requestUuid,
    required String flowUuid,
    required String profileUuid,
    required String signUuid,
    String comment = '',
  }) async {
    return await Post_ReviewsFlowApprove(
      requestUuid: requestUuid,
      flowUuid: flowUuid,
      profileUuid: profileUuid,
      signUuid: signUuid,
      comment: comment,
    );
  }

  /// ยิง API ปฏิเสธ (POST_Reject)
  Future<http.Response?> reject({
    required String requestUuid,
    required String flowUid,
    required String profileUuid,
    required String signUuid,
    required String comMent,
  }) async {
    return await POST_Reject(
      requestUuid: requestUuid,
      flowUid: flowUid,
      profileUuid: profileUuid,
      signUuid: signUuid,
      comMent: comMent,
    );
  }
}
