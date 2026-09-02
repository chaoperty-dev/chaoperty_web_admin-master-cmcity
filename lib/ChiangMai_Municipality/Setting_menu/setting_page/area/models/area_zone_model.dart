// ============================================================================
// area_zone_model.dart
// ============================================================================
// Model: ใช้แทนทั้ง "หมวดโซน" (group) และ "โซน" (zone) ของหน้า "จัดการ Area"
// - fromGroup(...): สร้าง row สำหรับ group (ไม่มี parent)
// - fromZone(...): สร้าง row สำหรับ zone (มี groupSer)
// ============================================================================

class AreaZoneModel {
  /// id
  final String ser;

  /// id หมวดโซน (parent) — มีเฉพาะ zone
  final String? groupSer;

  /// rental id (เก็บไว้สำหรับ compat เก่า — ตอนนี้ใช้ groupSer แทน)
  final String rser;

  /// ชื่อ (zn)
  final String zn;

  /// จำนวน (qty)
  final String qty;

  /// path รูป (เก็บไว้ ไม่ใช้งานในหน้านี้)
  final String img;

  /// last update
  final String dataUpdate;

  const AreaZoneModel({
    required this.ser,
    required this.rser,
    required this.zn,
    this.groupSer,
    this.qty = '0',
    this.img = '0',
    this.dataUpdate = '',
  });

  /// Factory สำหรับ row "หมวดโซน" (group)
  factory AreaZoneModel.fromGroup(Map<String, dynamic> json) {
    return AreaZoneModel(
      ser: (json['ser'] ?? '0').toString(),
      rser: (json['ser'] ?? '0').toString(),
      zn: (json['zn'] ?? '').toString(),
      qty: (json['qty'] ?? '0').toString(),
      img: (json['img'] ?? '0').toString(),
      dataUpdate: (json['data_update'] ?? '').toString(),
    );
  }

  /// Factory สำหรับ row "โซน" (zone) — ต้องมี groupSer
  factory AreaZoneModel.fromZone(Map<String, dynamic> json) {
    return AreaZoneModel(
      ser: (json['ser'] ?? '0').toString(),
      groupSer: (json['group_ser'] ?? '0').toString(),
      rser: (json['group_ser'] ?? '0').toString(),
      zn: (json['zn'] ?? '').toString(),
      qty: (json['qty'] ?? '0').toString(),
      img: (json['img'] ?? '0').toString(),
      dataUpdate: (json['data_update'] ?? '').toString(),
    );
  }

  /// Fallback JSON — รองรับทั้ง group และ zone shape
  factory AreaZoneModel.fromJson(Map<String, dynamic> json) {
    final hasGroup = json.containsKey('group_ser');
    return hasGroup
        ? AreaZoneModel.fromZone(json)
        : AreaZoneModel.fromGroup(json);
  }

  bool get isAll => ser == '0' && zn == 'ทั้งหมด';
}