// ============================================================================
// access_rights_role_position.dart
// ============================================================================
// Model: mapping Role <-> Position (API v2 /admin/role-positions)
// - in-use: filter roles allowed for selected position in user dialog
// ============================================================================

class AccessRightsRolePosition {
  final int id;
  final String uuid;
  final int roleId;

  /// code ของ role (ใช้ join กับ /admin/roles ซึ่งไม่มี integer id)
  final String roleCode;
  final int positionId;

  /// code / ชื่อของ position (ใช้ derive รายการตำแหน่งถ้า /lookup ใช้ไม่ได้)
  final String positionCode;
  final String positionName;
  final bool active;

  const AccessRightsRolePosition({
    required this.id,
    this.uuid = '',
    required this.roleId,
    this.roleCode = '',
    required this.positionId,
    this.positionCode = '',
    this.positionName = '',
    this.active = true,
  });

  factory AccessRightsRolePosition.fromJson(Map<String, dynamic> json) {
    final role = (json['role'] as Map?)?.cast<String, dynamic>() ?? const {};
    final position =
        (json['position'] as Map?)?.cast<String, dynamic>() ?? const {};
    return AccessRightsRolePosition(
      id: _parseInt(json['id']),
      uuid: (json['uuid'] ?? '').toString(),
      roleId: _parseInt(role['id']),
      roleCode: (role['code'] ?? '').toString(),
      positionId: _parseInt(position['id']),
      positionCode: (position['code'] ?? '').toString(),
      positionName: (position['name_th'] ?? position['nameTh'] ?? '')
          .toString(),
      active: json['active'] != false,
    );
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}
