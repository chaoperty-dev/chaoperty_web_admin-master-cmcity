// ============================================================================
// access_rights_user.dart
// ============================================================================
// Model: ผู้ใช้งาน (Admin user) ในระบบ CMM
// - เขียนใหม่ทั้งหมด ไม่ reuse User_ModelCMM เดิม
// - ใช้กับหน้า "สิทธิ์การเข้าถึง" ใน setting_page
// ============================================================================

import 'access_rights_role.dart';

class AccessRightsUser {
  /// UUID ของผู้ใช้ (ใช้อ้างอิงกับ API)
  final String uuid;

  /// ชื่อผู้ใช้ (login)
  final String username;

  /// อีเมล
  final String email;

  /// คำนำหน้า
  final String prefix;

  /// ชื่อ
  final String firstName;

  /// นามสกุล
  final String lastName;

  /// เบอร์โทร
  final String phone;

  /// เลขบัตรประชาชน
  final String citizenId;

  /// ตำแหน่งเตรียมไว้กรอก (prepostion)
  final String prepostion;

  /// id ของตำแหน่ง/ลำดับลายเซ็น
  final int? positionId;

  /// ชื่อตำแหน่ง (สำหรับแสดงผล)
  final String positionName;

  /// รายการ role ที่ผู้ใช้ได้รับ
  final List<AccessRightsRole> roles;

  /// UUID ของลายเซ็น (ถ้ามี) — ใช้สร้าง preview URL
  final String? signatureUuid;

  const AccessRightsUser({
    required this.uuid,
    required this.username,
    required this.email,
    this.prefix = '',
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.citizenId = '',
    this.prepostion = '',
    this.positionId,
    this.positionName = '',
    this.roles = const <AccessRightsRole>[],
    this.signatureUuid,
  });

  /// ชื่อ-นามสกุลเต็ม (fallback เป็น username ถ้าว่าง)
  String get fullName {
    final n = '$firstName $lastName'.trim();
    if (n.isEmpty) return username;
    return n;
  }

  /// level ของ role แรก (ใช้เรียง + แสดงผล)
  int get primaryRoleLevel => roles.isEmpty ? 0 : roles.first.level;

  factory AccessRightsUser.fromJson(Map<String, dynamic> json) {
    final profile = (json['profile'] as Map?)?.cast<String, dynamic>() ?? const {};
    final rawRoles = (json['roles'] as List?) ?? const [];
    final List<AccessRightsRole> mapped = rawRoles
        .whereType<Map<String, dynamic>>()
        .map(AccessRightsRole.fromJson)
        .toList();

    // รองรับทั้ง positions[0] (array) และ position (object)
    int? positionId;
    String positionName = '';
    if (json['positions'] is List && (json['positions'] as List).isNotEmpty) {
      final first = (json['positions'] as List).first;
      if (first is Map) {
        positionId = int.tryParse(first['id']?.toString() ?? '');
        positionName = first['name_th']?.toString() ??
            first['nameTh']?.toString() ??
            '';
      }
    } else if (json['position'] is Map) {
      final p = (json['position'] as Map).cast<String, dynamic>();
      positionId = int.tryParse(p['id']?.toString() ?? '');
      positionName = p['name_th']?.toString() ?? p['nameTh']?.toString() ?? '';
    }

    // ลายเซ็น
    String? sigUuid;
    if (json['signatures'] is List &&
        (json['signatures'] as List).isNotEmpty) {
      final first = (json['signatures'] as List).first;
      if (first is Map) {
        sigUuid = first['uuid']?.toString();
      }
    }

    return AccessRightsUser(
      uuid: (json['uuid'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      prefix: (profile['prefix'] ?? '').toString(),
      firstName: (profile['first_name'] ?? '').toString(),
      lastName: (profile['last_name'] ?? '').toString(),
      phone: (profile['phone'] ?? '').toString(),
      citizenId: (profile['citizen_id'] ?? '').toString(),
      prepostion: (profile['prepostion'] ?? '').toString(),
      positionId: positionId,
      positionName: positionName,
      roles: mapped,
      signatureUuid: sigUuid,
    );
  }
}
