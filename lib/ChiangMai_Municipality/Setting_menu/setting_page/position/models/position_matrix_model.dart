// ============================================================================
// position_matrix_model.dart
// ============================================================================
// Model: ตำแหน่ง (position) + สิทธิ์ที่ผูกอยู่ (roles) ของหน้า "จัดการตำแหน่ง"
// จาก API: GET {domain_v2}/admin/role-positions/matrix
// ============================================================================

/// สิทธิ์ 1 รายการที่ผูกกับตำแหน่ง
class PositionRoleAssignment {
  /// id ของ role (จาก roles/tree)
  final String roleId;

  /// โค้ดสิทธิ์ เช่น ACCESS_PERMISSION, area_manager
  final String code;

  /// ชื่อสิทธิ์ (ภาษาไทย)
  final String nameTh;

  /// สถานะว่าตำแหน่งนี้มีสิทธิ์นี้หรือไม่ (mutable — เพื่อ optimistic toggle)
  bool enabled;

  PositionRoleAssignment({
    required this.roleId,
    required this.code,
    required this.nameTh,
    required this.enabled,
  });

  factory PositionRoleAssignment.fromJson(Map<String, dynamic> json) {
    return PositionRoleAssignment(
      roleId: (json['id'] ?? json['role_id'] ?? '0').toString(),
      code: (json['code'] ?? '').toString(),
      nameTh: (json['name_th'] ?? json['name'] ?? '').toString(),
      enabled: json['enabled'] == true,
    );
  }
}

/// ตำแหน่ง 1 รายการ (เช่น superadmin, ผู้ใช้งานทั่วไป)
class PositionMatrixModel {
  /// id ของตำแหน่ง (ใช้กับ POST /admin/role-positions)
  final String id;

  final String uuid;

  /// โค้ดตำแหน่ง เช่น admin, user
  final String code;

  /// ชื่อตำแหน่ง (ภาษาไทย)
  final String nameTh;

  /// สิทธิ์ทั้งหมดของตำแหน่ง (ครบทุก role — enabled = มีสิทธิ์)
  final List<PositionRoleAssignment> roles;

  PositionMatrixModel({
    required this.id,
    required this.uuid,
    required this.code,
    required this.nameTh,
    required this.roles,
  });

  /// จำนวนสิทธิ์ที่เปิดอยู่
  int get enabledCount => roles.where((r) => r.enabled).length;

  /// ชื่อแสดง — ใช้ name_th ก่อน ถ้าว่างใช้ code
  String get displayName => nameTh.isNotEmpty ? nameTh : code;

  factory PositionMatrixModel.fromJson(Map<String, dynamic> json) {
    final rolesRaw = json['roles'];
    return PositionMatrixModel(
      id: (json['id'] ?? '0').toString(),
      uuid: (json['uuid'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      nameTh: (json['name_th'] ?? json['name'] ?? '').toString(),
      roles: (rolesRaw is List)
          ? rolesRaw
              .whereType<Map>()
              .map((e) => PositionRoleAssignment.fromJson(
                  e.cast<String, dynamic>()))
              .toList()
          : <PositionRoleAssignment>[],
    );
  }

  /// parse จาก body ของ GET /admin/role-positions/matrix
  static List<PositionMatrixModel> listFromMatrixBody(
      Map<String, dynamic> body) {
    final data = body['data'];
    final list = data is Map ? data['positions_all'] : null;
    if (list is! List) return <PositionMatrixModel>[];
    return list
        .whereType<Map>()
        .map(
            (e) => PositionMatrixModel.fromJson(e.cast<String, dynamic>()))
        .toList();
  }
}
