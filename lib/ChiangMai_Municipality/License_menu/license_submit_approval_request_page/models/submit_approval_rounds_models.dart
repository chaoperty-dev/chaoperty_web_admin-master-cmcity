// ============================================================================
// submit_approval_rounds_models.dart
// ============================================================================
// Models — parse JSON จาก v2 admin/approvals endpoints
// - GET  /v2/admin/approvals/me            → ApprovalMeData
// - POST /v2/admin/approvals/{uuid}/rounds → ApprovalRound
// - POST /v2/admin/approvals/{uuid}/steps/{step}/approve|reject → void
// ============================================================================

/// รอบตรวจ 1 รอบ (POST /rounds response)
class ApprovalRound {
  final String uuid;
  final String? requestUuid;
  final int? round;
  final String? state;
  final String? createdAt;
  final String? comment;

  const ApprovalRound({
    this.uuid = '',
    this.requestUuid,
    this.round,
    this.state,
    this.createdAt,
    this.comment,
  });

  factory ApprovalRound.fromJson(Map<String, dynamic> json) {
    return ApprovalRound(
      uuid: (json['uuid'] ?? '').toString(),
      requestUuid: json['request_uuid']?.toString(),
      round: int.tryParse('${json['round'] ?? json['rounds'] ?? ''}'),
      state: json['state']?.toString(),
      createdAt: json['created_at']?.toString(),
      comment: json['comment']?.toString(),
    );
  }

  /// fallback: response อาจส่ง uuid ตรงๆ ก็ได้
  factory ApprovalRound.fromRaw(dynamic raw) {
    if (raw is String) return ApprovalRound(uuid: raw);
    if (raw is Map) {
      return ApprovalRound.fromJson(Map<String, dynamic>.from(raw));
    }
    return const ApprovalRound();
  }
}

/// Step item ใน /me response — สิ่งที่ admin ต้องอนุมัติ
class ApprovalStepItem {
  final String stepUuid;
  final String instanceUuid;
  final String requestUuid;
  final int? round;
  final int? stepOrder;
  final String stepName;
  final String? moduleName;
  final bool viaDelegation;

  const ApprovalStepItem({
    this.stepUuid = '',
    this.instanceUuid = '',
    this.requestUuid = '',
    this.round,
    this.stepOrder,
    this.stepName = '',
    this.moduleName,
    this.viaDelegation = false,
  });

  factory ApprovalStepItem.fromJson(Map<String, dynamic> json) {
    final module = json['module'];
    String? moduleName;
    if (module is Map) {
      moduleName = (module['name_th'] ?? module['name'] ?? '').toString();
    }

    return ApprovalStepItem(
      stepUuid: (json['step_uuid'] ?? '').toString(),
      instanceUuid: (json['instance_uuid'] ?? '').toString(),
      requestUuid: (json['request_uuid'] ?? '').toString(),
      round: int.tryParse('${json['round'] ?? ''}'),
      stepOrder: int.tryParse('${json['step_order'] ?? ''}'),
      stepName: (json['step_name'] ?? '').toString(),
      moduleName: moduleName,
      viaDelegation: json['via_delegation'] == true,
    );
  }
}

/// Position (ตำแหน่ง) — ครอบ items ทั้งหมดที่ admin คนนี้ต้องอนุมัติ
class ApprovalPosition {
  final int? positionId;
  final String positionName;
  final List<ApprovalStepItem> items;

  const ApprovalPosition({
    this.positionId,
    this.positionName = '',
    this.items = const [],
  });

  factory ApprovalPosition.fromJson(Map<String, dynamic> json) {
    final pos = json['position'];
    int? posId;
    String posName = '';
    if (pos is Map) {
      posId = int.tryParse('${pos['id'] ?? ''}');
      posName = (pos['name_th'] ?? pos['name'] ?? '').toString();
    }

    final itemsRaw = json['items'];
    final items = itemsRaw is List
        ? itemsRaw
            .whereType<Map>()
            .map((e) => ApprovalStepItem.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <ApprovalStepItem>[];

    return ApprovalPosition(
      positionId: posId,
      positionName: posName,
      items: items,
    );
  }
}

/// Top-level response จาก GET /me
class ApprovalMeData {
  final String adminUuid;
  final List<ApprovalPosition> positions;

  const ApprovalMeData({
    this.adminUuid = '',
    this.positions = const [],
  });

  factory ApprovalMeData.fromJson(Map<String, dynamic> json) {
    final positionsRaw = json['positions'];
    final positions = positionsRaw is List
        ? positionsRaw
            .whereType<Map>()
            .map((e) => ApprovalPosition.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <ApprovalPosition>[];

    return ApprovalMeData(
      adminUuid: (json['admin_uuid'] ?? '').toString(),
      positions: positions,
    );
  }

  /// รวม step ทั้งหมดจากทุก positions
  List<ApprovalStepItem> get allSteps =>
      positions.expand((p) => p.items).toList(growable: false);

  /// Filter step ตาม requestUuid
  List<ApprovalStepItem> stepsForRequest(String requestUuid) =>
      allSteps.where((s) => s.requestUuid == requestUuid).toList();
}
