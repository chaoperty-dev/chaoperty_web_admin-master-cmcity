// ============================================================================
// area_count_model.dart
// ============================================================================
// Model: จำนวน Area ทั้งหมด (ใช้แสดง count badge)
// เขียนใหม่ทั้งหมด ไม่ reuse AreaCountModel เดิม
// ============================================================================

class AreaCountModel {
  final String ser;
  final String counta;

  const AreaCountModel({
    required this.ser,
    required this.counta,
  });

  factory AreaCountModel.fromJson(Map<String, dynamic> json) {
    return AreaCountModel(
      ser: (json['ser'] ?? '0').toString(),
      counta: (json['counta'] ?? '0').toString(),
    );
  }
}
