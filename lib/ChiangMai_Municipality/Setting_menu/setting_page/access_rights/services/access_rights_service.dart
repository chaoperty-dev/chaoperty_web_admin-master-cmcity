// ============================================================================
// access_rights_service.dart
// ============================================================================
// Service — เรียก API ทั้งหมดที่หน้า "สิทธิ์การเข้าถึง" ต้องใช้
// - เขียนใหม่ทั้งหมด ไม่ reuse API_user/API_permission/API_admin_signature เดิม
// - ใช้ MyHeaders.build() (จาก Constant/Myconstant.dart) เพื่อแนบ Bearer token
// - endpoint อ้างอิง MyConstant().domain_v1 เดิม
// ============================================================================

import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../../../../Constant/Myconstant.dart';
import '../models/access_rights_position.dart';
import '../models/access_rights_role.dart';
import '../models/access_rights_user.dart';

class AccessRightsService {
  AccessRightsService();

  String get _base => '${MyConstant().domain_v1}/admin';
  String get _lookup => '${MyConstant().domain_v1}/lookup';

  /// โหลดรายการผู้ใช้ทั้งหมด
  Future<List<AccessRightsUser>> fetchUsers() async {
    final headers = await MyHeaders.build();
    final uri = Uri.parse('$_base/users');
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode != 200) return <AccessRightsUser>[];
      final jsonRes = json.decode(response.body);
      final data = jsonRes is Map ? jsonRes['data'] : null;
      if (data is! List) return <AccessRightsUser>[];
      return data
          .whereType<Map<String, dynamic>>()
          .map(AccessRightsUser.fromJson)
          .toList();
    } catch (_) {
      return <AccessRightsUser>[];
    }
  }

  /// โหลดผู้ใช้รายเดียว (ใช้ตอนแก้ไข)
  Future<AccessRightsUser?> fetchUser(String uuid) async {
    if (uuid.isEmpty) return null;
    final headers = await MyHeaders.build();
    final uri = Uri.parse('$_base/users/$uuid');
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode != 200) return null;
      final jsonRes = json.decode(response.body);
      final data = jsonRes is Map ? jsonRes['data'] : null;
      if (data is! Map) return null;
      return AccessRightsUser.fromJson(data.cast<String, dynamic>());
    } catch (_) {
      return null;
    }
  }

  /// โหลดรายการตำแหน่ง / ลำดับลายเซ็น
  Future<List<AccessRightsPosition>> fetchPositions() async {
    final headers = await MyHeaders.build();
    final uri = Uri.parse('$_lookup/permission');
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode != 200) return <AccessRightsPosition>[];
      final jsonRes = json.decode(response.body);
      if (jsonRes is! Map) return <AccessRightsPosition>[];
      final positions = jsonRes['positions_all'];
      if (positions is! List) return <AccessRightsPosition>[];
      return positions
          .whereType<Map<String, dynamic>>()
          .map(AccessRightsPosition.fromJson)
          .toList();
    } catch (_) {
      return <AccessRightsPosition>[];
    }
  }

  /// โหลดรายการ role (ทั้งหมด)
  Future<List<AccessRightsRole>> fetchRoles() async {
    final headers = await MyHeaders.build();
    final uri = Uri.parse('$_lookup/permission');
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode != 200) return <AccessRightsRole>[];
      final jsonRes = json.decode(response.body);
      if (jsonRes is! Map) return <AccessRightsRole>[];
      final roles = jsonRes['roles_all'];
      if (roles is! List) return <AccessRightsRole>[];
      return roles
          .whereType<Map<String, dynamic>>()
          .map(AccessRightsRole.fromJson)
          .toList();
    } catch (_) {
      return <AccessRightsRole>[];
    }
  }

  /// สร้างผู้ใช้ใหม่ (multipart)
  Future<int> createUser({
    required Uint8List fileData,
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
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers);

    if (fileData.isNotEmpty) {
      request.files.add(
        http.MultipartFile.fromBytes('file', fileData, filename: 'signature.png'),
      );
    }

    request.fields['username'] = username;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['password_confirmation'] = password;
    request.fields['position_id'] = positionId.toString();
    request.fields['profile[prefix]'] = prefix;
    request.fields['profile[first_name]'] = firstName;
    request.fields['profile[last_name]'] = lastName;
    request.fields['profile[citizen_id]'] = citizenId;
    request.fields['profile[phone]'] = phone;
    request.fields['profile[prepostion]'] = prepostion;

    for (var i = 0; i < roleIds.length; i++) {
      request.fields['role_ids[$i]'] = roleIds[i].toString();
    }

    try {
      final response = await request.send();
      return response.statusCode;
    } catch (_) {
      return 0;
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
