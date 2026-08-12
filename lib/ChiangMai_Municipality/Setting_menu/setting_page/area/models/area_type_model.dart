// ============================================================================
// area_type_model.dart
// ============================================================================
// Model: ประเภทของ Area (AreaType)
// เขียนใหม่ทั้งหมด ไม่ reuse Areatype เดิม
// ============================================================================

class AreaTypeModel {
  final String ser;
  final String tn;
  final String? desc;

  const AreaTypeModel({
    required this.ser,
    required this.tn,
    this.desc,
  });

  factory AreaTypeModel.fromJson(Map<String, dynamic> json) {
    return AreaTypeModel(
      ser: (json['ser'] ?? '0').toString(),
      tn: (json['tn'] ?? '').toString(),
      desc: json['desc']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'ser': ser,
        'tn': tn,
        'desc': desc,
      };
}
