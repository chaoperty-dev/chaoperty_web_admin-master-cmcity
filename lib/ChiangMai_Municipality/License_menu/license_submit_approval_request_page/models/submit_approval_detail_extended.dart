// ============================================================================
// submit_approval_detail_extended.dart
// ============================================================================
// Models — parse JSON จาก GET /v2/admin/approvals/{requestUuid}
// โครงสร้าง response:
//   data {
//     request_uuid, can_open_round, gates, module,
//     current_round { round, state, opened_at, current_step_order, steps[] },
//     history[]
//   }
// ============================================================================

/// Step 1 ขั้นใน current_round.steps[]
class ApprovalStepV2 {
  final String uuid;
  final int? stepOrder;
  final String stepName;
  final int? positionId;
  final String positionName;
  final String? gate;
  final String status;
  final String? statusLabel;
  final String? actedBy;
  final String? actedAt;
  final String? remark;
  final bool isCurrent;
  final bool canAct;

  const ApprovalStepV2({
    this.uuid = '',
    this.stepOrder,
    this.stepName = '',
    this.positionId,
    this.positionName = '',
    this.gate,
    this.status = '',
    this.statusLabel,
    this.actedBy,
    this.actedAt,
    this.remark,
    this.isCurrent = false,
    this.canAct = false,
  });

  factory ApprovalStepV2.fromJson(Map<String, dynamic> json) {
    final position = json['position'];
    int? posId;
    String posName = '';
    if (position is Map) {
      posId = int.tryParse('${position['id'] ?? ''}');
      posName = (position['name_th'] ?? position['name'] ?? '').toString();
    }

    return ApprovalStepV2(
      uuid: (json['uuid'] ?? '').toString(),
      stepOrder: int.tryParse('${json['step_order'] ?? ''}'),
      stepName: (json['step_name'] ?? '').toString(),
      positionId: posId,
      positionName: posName,
      gate: json['gate']?.toString(),
      status: (json['status'] ?? '').toString(),
      statusLabel: json['status_label']?.toString(),
      actedBy: json['acted_by']?.toString(),
      actedAt: json['acted_at']?.toString(),
      remark: json['remark']?.toString(),
      isCurrent: json['is_current'] == true,
      canAct: json['can_act'] == true,
    );
  }
}

/// current_round block
class ApprovalCurrentRound {
  final int? round;
  final String? state;
  final String? openedAt;
  final int? currentStepOrder;
  final List<ApprovalStepV2> steps;

  const ApprovalCurrentRound({
    this.round,
    this.state,
    this.openedAt,
    this.currentStepOrder,
    this.steps = const [],
  });

  factory ApprovalCurrentRound.fromJson(Map<String, dynamic> json) {
    final stepsRaw = json['steps'];
    final steps = stepsRaw is List
        ? stepsRaw
            .whereType<Map>()
            .map((e) => ApprovalStepV2.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <ApprovalStepV2>[];

    return ApprovalCurrentRound(
      round: int.tryParse('${json['round'] ?? ''}'),
      state: json['state']?.toString(),
      openedAt: json['opened_at']?.toString(),
      currentStepOrder: int.tryParse('${json['current_step_order'] ?? ''}'),
      steps: steps,
    );
  }
}

/// Module (ขอเช่าสถานที่ / อื่นๆ)
class ApprovalModule {
  final int? id;
  final String nameTh;

  const ApprovalModule({this.id, this.nameTh = ''});

  factory ApprovalModule.fromJson(Map<String, dynamic> json) {
    return ApprovalModule(
      id: int.tryParse('${json['id'] ?? ''}'),
      nameTh: (json['name_th'] ?? json['name'] ?? '').toString(),
    );
  }
}

/// Gates (แนบเอกสาร/ตรวจสอบ/ชำระ)
class ApprovalGates {
  final bool attachments;
  final bool inspection;
  final bool payment;

  const ApprovalGates({
    this.attachments = false,
    this.inspection = false,
    this.payment = false,
  });

  factory ApprovalGates.fromJson(Map<String, dynamic> json) {
    return ApprovalGates(
      attachments: json['attachments'] == true,
      inspection: json['inspection'] == true,
      payment: json['payment'] == true,
    );
  }
}

/// History entry (ในตัวอย่างยังว่าง — โครงสร้างคาดเดา)
class ApprovalHistoryEntry {
  final String? round;
  final String? stepName;
  final String? actedBy;
  final String? actedAt;
  final String? remark;
  final String? status;

  const ApprovalHistoryEntry({
    this.round,
    this.stepName,
    this.actedBy,
    this.actedAt,
    this.remark,
    this.status,
  });

  factory ApprovalHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ApprovalHistoryEntry(
      round: json['round']?.toString(),
      stepName: json['step_name']?.toString(),
      actedBy: json['acted_by']?.toString(),
      actedAt: json['acted_at']?.toString(),
      remark: json['remark']?.toString(),
      status: json['status']?.toString(),
    );
  }
}

/// Top-level response
class ApprovalDetailResponse {
  final String requestUuid;
  final ApprovalModule? module;
  final bool canOpenRound;
  final ApprovalGates gates;
  final ApprovalCurrentRound? currentRound;
  final List<ApprovalHistoryEntry> history;

  const ApprovalDetailResponse({
    this.requestUuid = '',
    this.module,
    this.canOpenRound = false,
    this.gates = const ApprovalGates(),
    this.currentRound,
    this.history = const [],
  });

  factory ApprovalDetailResponse.fromJson(Map<String, dynamic> json) {
    final moduleRaw = json['module'];
    final gatesRaw = json['gates'];
    final roundRaw = json['current_round'];
    final historyRaw = json['history'];

    return ApprovalDetailResponse(
      requestUuid: (json['request_uuid'] ?? '').toString(),
      module: moduleRaw is Map
          ? ApprovalModule.fromJson(Map<String, dynamic>.from(moduleRaw))
          : null,
      canOpenRound: json['can_open_round'] == true,
      gates: gatesRaw is Map
          ? ApprovalGates.fromJson(Map<String, dynamic>.from(gatesRaw))
          : const ApprovalGates(),
      currentRound: roundRaw is Map
          ? ApprovalCurrentRound.fromJson(
              Map<String, dynamic>.from(roundRaw))
          : null,
      history: historyRaw is List
          ? historyRaw
              .whereType<Map>()
              .map((e) => ApprovalHistoryEntry.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList()
          : <ApprovalHistoryEntry>[],
    );
  }
}
