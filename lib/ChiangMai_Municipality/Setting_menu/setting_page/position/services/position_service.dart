// ============================================================================
// position_service.dart
// ============================================================================
// Service — API ของหน้า "จัดการตำแหน่ง" (Admin v2 - Role Positions)
//
// Endpoints:
//   GET    {domain_v2}/admin/role-positions/matrix   → full grid (positions × roles)
//   POST   {domain_v2}/admin/role-positions          → create/enable mapping
//          body: {role_id, position_id, active}
//   (PUT/DELETE /admin/role-positions/{id} — ใช้กับ mapping id ซึ่ง matrix
//    ไม่ได้ส่งมา จึงยังไม่ใช้ในหน้านี้)
// ============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../../Constant/Myconstant.dart';
import '../models/position_matrix_model.dart';

class PositionService {
  String get _baseV2 => MyConstant().domain_v2;

  /// GET /admin/role-positions/matrix → ตำแหน่งทั้งหมด + สิทธิ์ครบทุก role
  Future<List<PositionMatrixModel>> fetchMatrix() async {
    final url = Uri.parse('$_baseV2/admin/role-positions/matrix');
    try {
      final headers = await MyHeaders.build();
      debugPrint('[PositionService] 📤 GET $url');
      final response = await http.get(url, headers: headers);
      debugPrint(
          '[PositionService] ✅ status=${response.statusCode} '
          'bytes=${response.bodyBytes.lengthInBytes}');
      if (response.statusCode != 200) {
        debugPrint('[PositionService] ❌ body=${response.body}');
        return <PositionMatrixModel>[];
      }
      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic>) return <PositionMatrixModel>[];
      return PositionMatrixModel.listFromMatrixBody(body);
    } catch (e) {
      debugPrint('[PositionService] fetchMatrix error: $e');
      return <PositionMatrixModel>[];
    }
  }

  /// POST /admin/role-positions — เปิด/ปิดสิทธิ์ 1 คู่ (position × role)
  /// - เปิด: active = true / ปิด: active = false
  /// คืน true ถ้า server ตอบ 2xx
  Future<bool> setRoleActive({
    required String positionId,
    required String roleId,
    required bool active,
  }) async {
    final url = Uri.parse('$_baseV2/admin/role-positions');
    final body = jsonEncode({
      'role_id': int.tryParse(roleId) ?? roleId,
      'position_id': int.tryParse(positionId) ?? positionId,
      'active': active,
    });
    debugPrint('[PositionService] 📤 POST $url');
    debugPrint('[PositionService] 📦 body=$body');
    try {
      final headers = await MyHeaders.build();
      final response = await http.post(url, headers: headers, body: body);
      final ok = response.statusCode == 200 || response.statusCode == 201;
      if (!ok) {
        debugPrint(
            '[PositionService] ❌ status=${response.statusCode} '
            'body=${response.body}');
      } else {
        debugPrint('[PositionService] ✅ status=${response.statusCode}');
      }
      return ok;
    } catch (e) {
      debugPrint('[PositionService] setRoleActive error: $e');
      return false;
    }
  }
}
