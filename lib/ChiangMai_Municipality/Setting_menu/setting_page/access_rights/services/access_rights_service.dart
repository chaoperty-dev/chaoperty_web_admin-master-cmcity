// ============================================================================
// access_rights_service.dart
// ============================================================================
// Service — เรียก API ทั้งหมดที่หน้า "สิทธิ์การเข้าถึง" ต้องใช้
// - เขียนใหม่ทั้งหมด ไม่ reuse API_user/API_permission/API_admin_signature เดิม
// - ใช้ MyHeaders.build() (จาก Constant/Myconstant.dart) เพื่อแนบ Bearer token
// - endpoint อ้างอิง MyConstant().domain_v2 (/admin/*)
// ============================================================================

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../../Constant/Myconstant.dart';
import '../models/access_rights_role_position.dart';
import '../models/access_rights_role.dart';
import '../models/access_rights_user.dart';

class AccessRightsService {
  AccessRightsService();

  // เปลี่ยนไปใช้ API v2 (cmcity-test-api.chaoperties.com/api/v2)
  String get _base => '${MyConstant().domain_v2}/admin';

  /// โหลดรายการผู้ใช้ทั้งหมด
  Future<List<AccessRightsUser>> fetchUsers() async {
    final headers = await MyHeaders.build();
    final uri = Uri.parse('$_base/users');
    debugPrint('[AR] GET $uri');
    try {
      final response = await http.get(uri, headers: headers);
      debugPrint('[AR] users status=${response.statusCode} '
          'len=${response.body.length} body=${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}');
      if (response.statusCode != 200) return <AccessRightsUser>[];
      final jsonRes = json.decode(response.body);
      final data = jsonRes is Map ? jsonRes['data'] : null;
      if (data is! List) return <AccessRightsUser>[];
      return data
          .whereType<Map<String, dynamic>>()
          .map(AccessRightsUser.fromJson)
          .toList();
    } catch (e) {
      debugPrint('[AR] users ERROR $e');
      return <AccessRightsUser>[];
    }
  }

  /// โหลดผู้ใช้รายเดียว (ใช้ตอนแก้ไข)
  Future<AccessRightsUser?> fetchUser(String uuid) async {
    if (uuid.isEmpty) return null;
    final headers = await MyHeaders.build();
    final uri = Uri.parse('$_base/users/$uuid');
    debugPrint('[AR] GET $uri');
    try {
      final response = await http.get(uri, headers: headers);
      debugPrint('[AR] user status=${response.statusCode}');
      if (response.statusCode != 200) return null;
      final jsonRes = json.decode(response.body);
      final data = jsonRes is Map ? jsonRes['data'] : null;
      if (data is! Map) return null;
      return AccessRightsUser.fromJson(data.cast<String, dynamic>());
    } catch (_) {
      return null;
    }
  }

  /// โหลดรายการ role (GET /admin/roles — API v2)
  /// - วนทุกหน้าตาม meta.last_page
  /// - รายการนี้ไม่มี integer id (มีแต่ uuid/code) — VM จะ join id
  ///   ผ่าน code กับ role-positions ภายหลัง
  Future<List<AccessRightsRole>> fetchRoles() async {
    final headers = await MyHeaders.build();
    final out = <AccessRightsRole>[];
    int page = 1;
    int lastPage = 1;
    try {
      while (page <= lastPage) {
        final uri = Uri.parse('$_base/roles?page=$page');
        debugPrint('[AR] GET $uri');
        final response = await http.get(uri, headers: headers);
        debugPrint('[AR] roles p$page status=${response.statusCode}');
        if (response.statusCode != 200) break;
        final jsonRes = json.decode(response.body);
        if (jsonRes is! Map) break;
        final data = jsonRes['data'];
        if (data is List) {
          out.addAll(data
              .whereType<Map<String, dynamic>>()
              .map(AccessRightsRole.fromJson));
        }
        final meta = jsonRes['meta'];
        if (meta is Map) {
          lastPage = int.tryParse(meta['last_page']?.toString() ?? '1') ?? 1;
        }
        page++;
      }
    } catch (e) {
      debugPrint('[AR] roles ERROR $e');
    }
    return out;
  }

  /// โหลด mapping role<->position (GET /admin/role-positions)
  /// — วนทุกหน้าตาม meta.last_page
  Future<List<AccessRightsRolePosition>> fetchRolePositions() async {
    final headers = await MyHeaders.build();
    final out = <AccessRightsRolePosition>[];
    int page = 1;
    int lastPage = 1;
    try {
      while (page <= lastPage) {
        final uri = Uri.parse('$_base/role-positions?page=$page');
        debugPrint('[AR] GET $uri');
        final response = await http.get(uri, headers: headers);
        debugPrint('[AR] role-positions p$page status=${response.statusCode}');
        if (response.statusCode != 200) break;
        final jsonRes = json.decode(response.body);
        if (jsonRes is! Map) break;
        final data = jsonRes['data'];
        if (data is List) {
          out.addAll(data
              .whereType<Map<String, dynamic>>()
              .map(AccessRightsRolePosition.fromJson));
        }
        final meta = jsonRes['meta'];
        if (meta is Map) {
          lastPage = int.tryParse(meta['last_page']?.toString() ?? '1') ?? 1;
        }
        page++;
      }
    } catch (e) {
      debugPrint('[AR] role-positions ERROR $e');
    }
    return out;
  }

  /// สร้างผู้ใช้ใหม่ (JSON POST — API v2)
  /// คืน record (statusCode, uuid ของผู้ใช้ใหม่)
  Future<(int, String)> createUser({
    required String username,
    required String email,
    required String password,
    required String prefix,
    required String firstName,
    required String lastName,
    required String citizenId,
    required String phone,
    required String prepostion,
    required int positionId,
    required List<int> roleIds,
  }) async {
    final headers = await MyHeaders.build();
    final uri = Uri.parse('$_base/users');
    final body = json.encode(<String, dynamic>{
      'username': username,
      'email': email,
      'password': password,
      'password_confirmation': password,
      'profile': <String, dynamic>{
        'prefix': prefix,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'prepostion': prepostion,
        'citizen_id': citizenId,
      },
      'role_ids': roleIds,
      'position_id': positionId,
    });

    try {
      final response = await http.post(uri, headers: headers, body: body);
      String newUuid = '';
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final jsonRes = json.decode(response.body);
          final data = jsonRes is Map ? jsonRes['data'] : null;
          if (data is Map) newUuid = data['uuid']?.toString() ?? '';
        } catch (_) {}
      }
      return (response.statusCode, newUuid);
    } catch (_) {
      return (0, '');
    }
  }

  /// แก้ไขผู้ใช้ (PUT JSON) — ถ้า password ว่าง จะไม่ส่ง password fields
  Future<int> updateUser({
    required String userUuid,
    required String username,
    required String email,
    required String password,
    required String prefix,
    required String firstName,
    required String lastName,
    required String citizenId,
    required String phone,
    required String prepostion,
    required int positionId,
    required List<int> roleIds,
  }) async {
    final headers = await MyHeaders.build();
    final uri = Uri.parse('$_base/users/$userUuid');

    final Map<String, dynamic> body = <String, dynamic>{
      'username': username,
      'email': email,
      'position_id': positionId,
      'profile': <String, dynamic>{
        'prefix': prefix,
        'first_name': firstName,
        'last_name': lastName,
        'citizen_id': citizenId,
        'phone': phone,
        'prepostion': prepostion,
      },
      'role_ids': roleIds,
    };
    if (password.isNotEmpty) {
      body['password'] = password;
      body['password_confirmation'] = password;
    }

    try {
      final response = await http.put(
        uri,
        headers: headers,
        body: json.encode(body),
      );
      return response.statusCode;
    } catch (_) {
      return 0;
    }
  }

  /// อัปโหลดลายเซ็นของผู้ใช้ (multipart)
  Future<int> uploadSignature({
    required String userUuid,
    required Uint8List fileData,
  }) async {
    if (userUuid.isEmpty || fileData.isEmpty) return 0;
    final headers = await MyHeaders.build();
    final uri = Uri.parse('$_base/users/$userUuid/signatures');
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..files.add(
        http.MultipartFile.fromBytes('file', fileData, filename: 'signature.png'),
      );
    try {
      final response = await request.send();
      return response.statusCode;
    } catch (_) {
      return 0;
    }
  }

  /// โหลดรูปลายเซ็นเป็น bytes (ใช้แสดง preview)
  Future<Uint8List?> fetchSignatureImage(String signatureUuid) async {
    if (signatureUuid.isEmpty) return null;
    final headers = await MyHeaders.build();
    final uri =
        Uri.parse('$_base/users/signatures/$signatureUuid/preview');
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode != 200) return null;
      return response.bodyBytes;
    } catch (_) {
      return null;
    }
  }
}
