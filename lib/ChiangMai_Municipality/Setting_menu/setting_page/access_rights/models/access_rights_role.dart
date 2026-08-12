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
    required this.permissionId,
    required this.nameTh,
    this.nameEn,
    this.level = 0,
    this.enabled = true,
  });

  factory AccessRightsRole.fromJson(Map<String, dynamic> json) {
    return AccessRightsRole(
      id: _parseInt(json['id']),
      permissionId: _parseInt(json['permission_id'] ?? json['id']),
      nameTh: (json['name_th'] ?? json['nameTh'] ?? '').toString(),
      nameEn: json['name_en']?.toString() ?? json['nameEn']?.toString(),
      level: _parseInt(json['level'] ?? json['sort'] ?? 0),
      enabled: json['enabled'] == true,
    );
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  AccessRightsRole copyWith({
    int? id,
    int? permissionId,
    String? nameTh,
    String? nameEn,
    int? level,
    bool? enabled,
  }) {
    return AccessRightsRole(
      id: id ?? this.id,
      permissionId: permissionId ?? this.permissionId,
      nameTh: nameTh ?? this.nameTh,
      nameEn: nameEn ?? this.nameEn,
      level: level ?? this.level,
      enabled: enabled ?? this.enabled,
    );
  }
}
