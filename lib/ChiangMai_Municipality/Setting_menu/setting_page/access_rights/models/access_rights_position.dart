// ============================================================================
// access_rights_position.dart
// ============================================================================
// Model: ตำแหน่ง / ลำดับการลงลายมือชื่อ
// - เขียนใหม่ทั้งหมด ไม่ reuse PositionsAll เดิม
// - เก็บรายการ role ที่แนะนำ (template) เพื่อให้ UI แสดงเป็นค่าเริ่มต้น
// ============================================================================

import 'access_rights_role.dart';

class AccessRightsPosition {
  final int id;
  final String nameTh;
  final String? nameEn;
  final int level;
  final bool enabled;

  /// Role ที่ผูกกับตำแหน่งนี้ (template / ค่าเริ่มต้น)
  final List<AccessRightsRole> roles;

  const AccessRightsPosition({
    required this.id,
    required this.nameTh,
    this.nameEn,
    this.level = 0,
    this.enabled = true,
    this.roles = const <AccessRightsRole>[],
  });

  factory AccessRightsPosition.fromJson(Map<String, dynamic> json) {
    final rawRoles = (json['roles'] as List?) ?? const [];
    final List<AccessRightsRole> mapped = rawRoles
        .whereType<Map<String, dynamic>>()
        .map(AccessRightsRole.fromJson)
        .toList();
    return AccessRightsPosition(
      id: _parseInt(json['id']),
      nameTh: (json['name_th'] ?? json['nameTh'] ?? '').toString(),
      nameEn: json['name_en']?.toString() ?? json['nameEn']?.toString(),
      level: _parseInt(json['level'] ?? 0),
      enabled: json['enabled'] != false,
      roles: mapped,
    );
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}
