class FlowModelStep {
  final String flowUuid;
  final String flowName;
  final int stepOrder;
  final int stepPosition;
  final String stepPositionName;
  final bool approved;

  final String? approvedBy;
  final String? approvedSign;
  final String? approvedPosition;
  final String? approvedAt;
  final String statusLabel;
  final String? comment;

  const FlowModelStep({
    required this.flowUuid,
    required this.flowName,
    required this.stepOrder,
    required this.stepPosition,
    required this.stepPositionName,
    required this.approved,
    this.approvedBy,
    this.approvedSign,
    this.approvedPosition,
    this.approvedAt,
    required this.statusLabel,
    this.comment,
  });

  factory FlowModelStep.fromJson(Map<String, dynamic> j) {
    return FlowModelStep(
      flowUuid: (j['flow_uuid'] as String?) ?? '',
      flowName: (j['flow_name'] as String?) ?? '',
      stepOrder: (j['step_order'] as num?)?.toInt() ?? 0,
      stepPosition: (j['step_position'] as num?)?.toInt() ?? 0,
      stepPositionName: (j['step_position_name'] as String?) ?? '',
      approved: (j['approved'] as bool?) ?? false,
      approvedBy: j['approved_by'] as String?,
      approvedSign: j['approved_sign'] as String?,
      approvedPosition: j['approved_position'] as String?,
      approvedAt: j['approved_at'] as String?,
      statusLabel: (j['status_label'] as String?) ?? '',
      comment: j['comment'] as String?,
    );
  }

  // 💡 สำคัญ: เมธอด static สำหรับแปลง list ให้เรียกใช้จากภายนอกได้
  static List<FlowModelStep> listFromJson(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map<String, dynamic>>()
          .map((m) => FlowModelStep.fromJson(m))
          .toList();
    }
    return const [];
  }
}
