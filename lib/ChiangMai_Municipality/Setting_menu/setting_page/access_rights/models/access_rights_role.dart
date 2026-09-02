// ============================================================================
// access_rights_role.dart
// ============================================================================
// Model: สิทธิ์การเข้าถึง (Role)
// - เขียนใหม่ทั้งหมด ไม่ reuse class เดิมใน Models/Permission_Model.dart
// - ใช้กับ UI หน้า "สิทธิ์การเข้าถึง" ใน setting_page
// ============================================================================

class AccessRightsRole {
  /// id ของ role
  final int id;

  /// uuid ของ role (API v2 /admin/roles ไม่มี id เลข — join ผ่าน code)
  final String uuid;

  /// code ของ role — ใช้ join integer id กับ role-positions
  final String code;

  /// id ของ permission (อาจต่างจาก id)
  final int permissionId;

  /// ชื่อภาษาไทย
  final String nameTh;

  /// ชื่อภาษาอังกฤษ (อาจว่างได้)
  final String? nameEn;

  /// ลำดับการลงลายมือชื่อ (level) — ยิ่งน้อยยิ่งเซ็นก่อน
  final int level;

  /// เปิดใช้งานอยู่หรือไม่ (จาก API)
  final bool enabled;

  const AccessRightsRole({
    required this.id,
    this.uuid = '',
    this.code = '',
    required this.permissionId,
    required this.nameTh,
    this.nameEn,
    this.level = 0,
    this.enabled = true,
  });

  factory AccessRightsRole.fromJson(Map<String, dynamic> json) {
    // v2 /admin/roles: active เป็น int (1) — v1: enabled เป็น bool
    final dynamic active = json['active'] ?? json['enabled'];
    final bool isEnabled = active == 1 || active == true;
    return AccessRightsRole(
      id: _parseInt(json['id']),
      uuid: (json['uuid'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      permissionId: _parseInt(json['permission_id'] ?? json['id']),
      nameTh: (json['name_th'] ?? json['nameTh'] ?? '').toString(),
      nameEn: json['name_en']?.toString() ?? json['nameEn']?.toString(),
      level: _parseInt(json['level'] ?? json['sort'] ?? 0),
      enabled: isEnabled,
    );
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  AccessRightsRole copyWith({
    int? id,
    String? uuid,
    String? code,
    int? permissionId,
    String? nameTh,
    String? nameEn,
    int? level,
    bool? enabled,
  }) {
    return AccessRightsRole(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      code: code ?? this.code,
      permissionId: permissionId ?? this.permissionId,
      nameTh: nameTh ?? this.nameTh,
      nameEn: nameEn ?? this.nameEn,
      level: level ?? this.level,
      enabled: enabled ?? this.enabled,
    );
  }
}
