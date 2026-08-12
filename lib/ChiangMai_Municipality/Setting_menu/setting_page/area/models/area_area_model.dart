// ============================================================================
// area_area_model.dart
// ============================================================================
// Model: Area (พื้นที่เช่า) สำหรับหน้า "จัดการ Area"
// เขียนใหม่ทั้งหมด ไม่ reuse AreaModel เดิม
// ============================================================================

class AreaAreaModel {
  /// id ของ area
  final String ser;

  /// รหัสพื้นที่ (ln)
  final String ln;

  /// ชื่อย่อ (sn)
  final String sn;

  /// ชื่อเต็ม (sname)
  final String sname;

  /// ลำดับแสดงผล (sw)
  final String sw;

  /// รหัส/เลขลำดับพื้นที่ (lncode)
  final String lncode;

  /// ขนาดพื้นที่ (area) — ตร.ม.
  final String area;

  /// ค่าบริการหลัก (rent) — ต่องวด
  final String rent;

  /// ค่าบริการล็อกเสียบ (rent_maket) — ต่องวด
  final String rentMaket;

  /// id โซน
  final String zone;

  /// ชื่อโซน (zn) — เช่น "UATV4"
  final String zn;

  /// id ประเภท area
  final String typeId;

  /// ชื่อประเภท area (ถ้ามี)
  final String typeName;

  /// id rental
  final String rser;

  /// รหัสสัญญาเช่า (cid) — ถ้ามีค่าแสดงว่า "ไม่ว่าง" (มีผู้เช่า)
  final String cid;

  /// ชื่อผู้เช่า (cname)
  final String cname;

  /// สถานะพื้นที่ (stype)
  final String stype;

  /// จำนวนที่ถูกใช้งาน (quantity)
  final String quantity;

  const AreaAreaModel({
    required this.ser,
    required this.ln,
    required this.sn,
    required this.sname,
    required this.sw,
    this.lncode = '',
    this.area = '',
    this.rent = '0',
    this.rentMaket = '0',
    required this.zone,
    this.zn = '',
    this.typeId = '',
    this.typeName = '',
    this.rser = '0',
    this.cid = '',
    this.cname = '',
    this.stype = '',
    this.quantity = '0',
  });

  factory AreaAreaModel.fromJson(Map<String, dynamic> json) {
    return AreaAreaModel(
      ser: (json['ser'] ?? '0').toString(),
      ln: (json['ln'] ?? '').toString(),
      sn: (json['sn'] ?? '').toString(),
      sname: (json['sname'] ?? '').toString(),
      sw: (json['sw'] ?? '0').toString(),
      lncode: (json['lncode'] ?? '').toString(),
      area: (json['area'] ?? '').toString(),
      rent: (json['rent'] ?? '0').toString(),
      rentMaket: (json['rent_maket'] ?? json['rentMaket'] ?? '0').toString(),
      zone: (json['zone'] ?? json['zser'] ?? '0').toString(),
      zn: (json['zn'] ?? '').toString(),
      typeId:
          (json['type_id'] ?? json['typeId'] ?? json['tser'] ?? '').toString(),
      typeName: (json['type_name'] ??
              json['typeName'] ??
              json['tn'] ??
              json['tname'] ??
              json['stype'] ??
              '')
          .toString(),
      rser: (json['rser'] ?? '0').toString(),
      cid: (json['cid'] ?? '').toString(),
      cname: (json['cname'] ?? '').toString(),
      stype: (json['stype'] ?? '').toString(),
      quantity: (json['quantity'] ?? '0').toString(),
    );
  }

  /// ไม่ว่าง = true เมื่อ cid มีค่า (มีสัญญาเช่า)
  bool get isOccupied => cid.trim().isNotEmpty;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'ser': ser,
        'ln': ln,
        'sn': sn,
        'sname': sname,
        'sw': sw,
        'lncode': lncode,
        'area': area,
        'rent': rent,
        'rent_maket': rentMaket,
        'zone': zone,
        'type_id': typeId,
        'rser': rser,
      };
}
