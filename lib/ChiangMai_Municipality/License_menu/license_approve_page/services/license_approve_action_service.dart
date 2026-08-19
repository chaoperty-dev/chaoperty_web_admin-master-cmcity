// ============================================================================
// license_approve_action_service.dart
// ============================================================================
// Service — approve/reject approval step (ใช้จากหน้า detail ของผู้อนุมัติ)
// - POST /v2/admin/approvals/{requestUuid}/steps/{stepUuid}/approve
// - POST /v2/admin/approvals/{requestUuid}/steps/{stepUuid}/reject
// ============================================================================

import 'dart:convert';

import 'package:chaoperty/Constant/Myconstant.dart';
import 'package:http/http.dart' as http;

class LicenseApproveActionService {
  LicenseApproveActionService();

  Uri _uriV2(String path) {
    final base = MyConstant().domain_v1;
    // base = https://.../api/v1  →  https://.../api
    final apiRoot = base.replaceFirst(RegExp(r'/v1/?$'), '');
    return Uri.parse('$apiRoot/$path');
  }

  /// POST /v2/admin/approvals/{requestUuid}/steps/{stepUuid}/approve
  Future<void> approveStep({
    required String requestUuid,
    required String stepUuid,
    String remark = '',
  }) async {
    if (requestUuid.trim().isEmpty) {
      throw Exception('Request UUID is required');
    }
    if (stepUuid.trim().isEmpty) {
      throw Exception('Step UUID is required');
    }
    final headers = await MyHeaders.build();
    final res = await http
        .post(
          _uriV2(
              'v2/admin/approvals/$requestUuid/steps/$stepUuid/approve'),
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
    if (requestUuid.trim().isEmpty) {
      throw Exception('Request UUID is required');
    }
    if (stepUuid.trim().isEmpty) {
      throw Exception('Step UUID is required');
    }
    if (remark.trim().isEmpty) {
      throw Exception('กรุณาระบุเหตุผล');
    }
    final headers = await MyHeaders.build();
    final res = await http
        .post(
          _uriV2(
              'v2/admin/approvals/$requestUuid/steps/$stepUuid/reject'),
          headers: {...headers, 'Content-Type': 'application/json'},
          body: json.encode({'remark': remark.trim()}),
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
}
