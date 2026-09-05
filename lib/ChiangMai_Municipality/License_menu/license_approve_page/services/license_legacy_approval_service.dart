// ============================================================================
// license_legacy_approval_service.dart
// ============================================================================
// Service สำหรับ "ลายเซ็นผู้อนุมัติ + V1 flow approve" — own implementation
// ไม่ delegate ไป unity/API_admin_signature.dart หรือ
// unity/API_requests_reviewsflow.dart — เขียน HTTP calls เองทั้งหมด
//
// Endpoints (v1 + v2 + v3):
//   GET  {domain_v1}/admin/know                                       → admin signature meta
//   GET  {domain_v2}/signatures/{uuid}/preview                        → signature image bytes
//   GET  {domain_v1}/admin/approvals/{requestUuid}/flow               → flow uuid list
//   POST {domain_v1}/admin/approvals/{requestUuid}/flow/{flowUuid}/approve  → approve
//   POST {domain_v2}/admin/approvals/bulk/approve                     → bulk approve (≤50/round)
//   GET  {domain_v3}/api/preview/{path}/{requestUuid}                 → generated PDFs
// ============================================================================

import 'dart:convert';

import 'package:chaoperty/Constant/Myconstant.dart';
import 'package:http/http.dart' as http;

/// Service สำหรับเรียก API ที่เกี่ยวกับ "ลายเซ็นผู้อนุมัติ + V1 flow approve"
class LicenseLegacyApprovalService {
  // ─── Admin signature meta + image ───
  /// GET /admin/know → ข้อมูล profile + signature uuid
  Future<http.Response?> readAdminSignature() async {
    final headers = await MyHeaders.build();
    final url = Uri.parse('${MyConstant().domain_v1}/admin/know');
    try {
      final response = await http.get(url, headers: headers);
      return response;
    } catch (_) {
      return null;
    }
  }

  /// GET /v2/signatures/{uuid}/preview → image bytes
  Future<http.Response?> loadSignatureImage({
    required String? signatureUuid,
  }) async {
    if (signatureUuid == null || signatureUuid.isEmpty) return null;
    final headers = await MyHeaders.build();
    final url = Uri.parse(
      '${MyConstant().domain_v2}/signatures/$signatureUuid/preview',
    );
    try {
      final response = await http.get(url, headers: headers);
      return response;
    } catch (_) {
      return null;
    }
  }

  // ─── V1 flow ───
  /// GET /admin/approvals/{requestUuid}/flow → list of flows (หา flow_uuid)
  Future<http.Response?> readFlowUuid({required String? requestUuid}) async {
    if (requestUuid == null || requestUuid.isEmpty) return null;
    final headers = await MyHeaders.build();
    final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/approvals/$requestUuid/flow',
    );
    try {
      final response = await http.get(url, headers: headers);
      return response;
    } catch (_) {
      return null;
    }
  }

  /// POST /admin/approvals/{requestUuid}/flow/{flowUuid}/approve
  /// body: { profile_uuid, sign_uuid, comment }
  /// returns decoded JSON body (null on network exception)
  Future<dynamic> approveFlow({
    required String requestUuid,
    required String flowUuid,
    required String profileUuid,
    required String signUuid,
    required String comment,
  }) async {
    final headers = await MyHeaders.build();
    final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/approvals/$requestUuid/flow/$flowUuid/approve',
    );
    final body = json.encode({
      'profile_uuid': profileUuid,
      'sign_uuid': signUuid,
      'comment': comment,
    });
    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode != 200 && response.statusCode != 201) {
        return {'error': true, 'status': response.statusCode, 'body': response.body};
      }
      return json.decode(response.body);
    } catch (_) {
      return null;
    }
  }

  // ─── V2 bulk approve (≤50 รายการต่อรอบ) ───
  /// จำนวน step_uuids สูงสุดต่อ 1 POST (backend limit)
  static const int maxBulkBatchSize = 50;

  /// POST /api/v2/admin/approvals/bulk/approve
  /// body: { "step_uuids": ["uuid1", ...] }  (≤ maxBulkBatchSize)
  /// returns decoded JSON หรือ { error, status, body } ถ้า status != 200/201
  Future<dynamic> bulkApproveSteps({
    required List<String> stepUuids,
  }) async {
    if (stepUuids.isEmpty) {
      return {'error': true, 'status': 0, 'body': 'empty step_uuids'};
    }
    if (stepUuids.length > maxBulkBatchSize) {
      return {
        'error': true,
        'status': 0,
        'body': 'exceeds maxBulkBatchSize (${stepUuids.length}/$maxBulkBatchSize)',
      };
    }
    final headers = await MyHeaders.build();
    final url = Uri.parse('${MyConstant().domain_v2}/admin/approvals/bulk/approve');
    final body = json.encode({'step_uuids': stepUuids});
    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode != 200 && response.statusCode != 201) {
        return {
          'error': true,
          'status': response.statusCode,
          'body': response.body,
        };
      }
      return json.decode(response.body);
    } catch (_) {
      return null;
    }
  }

  /// chunked variant — แบ่ง list เป็น batch ละ maxBulkBatchSize แล้วยิงทีละ batch
  /// คืน list ของผลลัพธ์ (1 ผลลัพธ์ต่อ batch, ลำดับเดียวกับ batch)
  Future<List<dynamic>> bulkApproveStepsChunked({
    required List<String> stepUuids,
  }) async {
    if (stepUuids.isEmpty) return const [];
    final results = <dynamic>[];
    for (var i = 0; i < stepUuids.length; i += maxBulkBatchSize) {
      final end = (i + maxBulkBatchSize > stepUuids.length)
          ? stepUuids.length
          : i + maxBulkBatchSize;
      final batch = stepUuids.sublist(i, end);
      results.add(await bulkApproveSteps(stepUuids: batch));
    }
    return results;
  }

  // ─── Generated PDFs ───
  /// คืน URL สำหรับ preview PDF (GeneratePDF_{1,2,3})
  String resolvePdfUrl({
    required String key,
    required String requestUuid,
  }) {
    final base = MyConstant().domain_v3;
    switch (key) {
      case 'GeneratePDF_1':
        return '$base/api/preview/req-vendor-license-2/$requestUuid';
      case 'GeneratePDF_2':
        return '$base/api/preview/memo-vendor-license-2/$requestUuid';
      case 'GeneratePDF_3':
        return '$base/api/preview/vendor-license-2/$requestUuid';
      default:
        return '';
    }
  }

  /// list ของเอกสารประกอบ 3 อัน (hardcoded)
  static const List<Map<String, String>> previewDocs = [
    {'ser': '1', 'key': 'GeneratePDF_1', 'title': 'คำร้องต่อใบอนุญาต'},
    {
      'ser': '2',
      'key': 'GeneratePDF_2',
      'title': 'ใบพิจารณาคำขอต่อใบอนุญาต',
    },
    {
      'ser': '3',
      'key': 'GeneratePDF_3',
      'title': 'ใบอนุญาต',
    },
  ];
}
