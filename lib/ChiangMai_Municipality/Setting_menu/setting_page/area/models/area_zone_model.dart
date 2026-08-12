// ============================================================================
// area_zone_model.dart
// ============================================================================
// Model: โซน (Zone) สำหรับหน้า "จัดการ Area"
// เขียนใหม่ทั้งหมด ไม่ reuse ZoneModel เดิม
// ============================================================================

class AreaZoneModel {
  final String ser;
  final String rser;
  final String zn;
  final String? subZone;
  final String qty;
  final String img;
  final String dataUpdate;

  const AreaZoneModel({
    required this.ser,
    required this.rser,
    required this.zn,
    this.subZone,
    this.qty = '0',
    this.img = '0',
    this.dataUpdate = '',
  });

  factory AreaZoneModel.fromJson(Map<String, dynamic> json) {
    return AreaZoneModel(
      ser: (json['ser'] ?? '0').toString(),
      rser: (json['rser'] ?? '0').toString(),
      zn: (json['zn'] ?? '').toString(),
      subZone: json['sub_zone']?.toString() ?? json['subZone']?.toString(),
      qty: (json['qty'] ?? '0').toString(),
      img: (json['img'] ?? '0').toString(),
      dataUpdate: (json['data_update'] ?? '').toString(),
    );
  }
}
