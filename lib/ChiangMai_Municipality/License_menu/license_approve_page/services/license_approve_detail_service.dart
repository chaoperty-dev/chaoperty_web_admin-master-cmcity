// ============================================================================
// license_approve_detail_service.dart
// ============================================================================
// Service — ดึง timeline ของ approval (read-only) ตาม requestUuid
//
// ใช้ endpoint:
//   - GET {domain}/v2/admin/approvals/{requestUuid}
//     → current_round.steps + history (ใช้แสดง timeline)
//
// หมายเหตุ: Service นี้เป็น read-only (โหลด timeline อย่างเดียว) — ไม่มี
// logic สำหรับ "บันทึก/ส่งคำร้องขออนุมัติ" ตามที่ผู้ใช้ระบุ
// ============================================================================

import 'dart:convert';

import 'package:chaoperty/Constant/Myconstant.dart';
import 'package:http/http.dart' as http;

import '../models/license_approve_detail_extended.dart';

class LicenseApproveDetailService {
  LicenseApproveDetailService();

  Uri _uriV2(String path) {
    final base = MyConstant().domain_v1;
    // base = https://.../api/v1  →  https://.../api
    final apiRoot = base.replaceFirst(RegExp(r'/v1/?$'), '');
    return Uri.parse('$apiRoot/$path');
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

    if (res.statusCode == 404) {
      // ยังไม่เคยเปิดรอบอนุมัติ → return empty (ให้ UI แสดง empty state)
      return const ApprovalDetailResponse();
    }
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
