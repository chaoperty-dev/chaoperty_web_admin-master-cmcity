// ============================================================================
// rental_general_models.dart
// ============================================================================
// Models รวมสำหรับหน้า "ข้อมูลทั่วไป" (Status_ == 1)
// Port จาก Status1_Web() ใน lib/Setting/SettingScreen.dart
//
// Fields จาก:
// - GC_rental_setring.php  → RentalGeneralModel
// - GC_package.php         → PackageSummaryModel
// - GC_areaCount.php       → AreaCountModel
// - GC_zone.php            → ZoneImageModel (สำหรับ upload/delete image)
// ============================================================================

/// Model รวมจาก GC_rental_setring.php + GC_package.php + GC_areaCount.php
class RentalGeneralModel {
  // ───────── From GC_rental_setring ─────────
  final String? ser;
  final String? pn; // ชื่อสถานที่ (renname)
  final String? rtname; // การคิดค่าเช่า
  final String? type; // ลักษณะการใช้งาน
  final String? typex; // ลักษณะ/ประเภทพื้นที่เช่า
  final String? pk; // package name
  final int? pkqty; // จำนวนพื้นที่ (ล็อก/แผง)
  final int? pkuser; // จำนวนสิทธิ์ผู้ใช้งาน
  final String? dbn; // folder name
  final String? img; // รูปแผนผัง (Map*.png)
  final String? imglogo; // รูปโลโก้
  final String? imglineqr; // LINE QR url (NetworkImage)
  final int? openSetDate; // ระยะเวลาแจ้งใกล้หมดสัญญา (วัน)
  final int? massOn; // เปิดแจ้งผ่านไลน์ (0/1)
  final String? lineqr; // LINE OA URL (for PrettyQr)

  // ───────── From GC_areaCount ─────────
  final int? countArea; // จำนวนพื้นที่ที่ใช้ไป

  const RentalGeneralModel({
    this.ser,
    this.pn,
    this.rtname,
    this.type,
    this.typex,
    this.pk,
    this.pkqty,
    this.pkuser,
    this.dbn,
    this.img,
    this.imglogo,
    this.imglineqr,
    this.openSetDate,
    this.massOn,
    this.lineqr,
    this.countArea,
  });

  /// พื้นที่คงเหลือ = pkqty - countArea
  int get remainingArea {
    final total = pkqty ?? 0;
    final used = countArea ?? 0;
    final r = total - used;
    return r < 0 ? 0 : r;
  }

  bool get isMassOn => massOn == 1;

  /// URL รูปแผนผัง (full URL)
  String? get contractImageUrl =>
      (img != null && img!.isNotEmpty && dbn != null && dbn!.isNotEmpty)
          ? '$_baseUrl/files/$dbn/contract/$img'
          : null;

  /// URL รูปโลโก้ (full URL)
  String? get logoImageUrl =>
      (imglogo != null && imglogo!.isNotEmpty && dbn != null && dbn!.isNotEmpty)
          ? '$_baseUrl/files/$dbn/logo/$imglogo'
          : null;

  String? get lineQrImageUrl =>
      (imglineqr != null && imglineqr!.isNotEmpty) ? imglineqr : null;

  factory RentalGeneralModel.empty() => const RentalGeneralModel();

  RentalGeneralModel copyWith({
    String? pn,
    int? openSetDate,
    int? massOn,
    int? countArea,
  }) {
    return RentalGeneralModel(
      ser: ser,
      pn: pn ?? this.pn,
      rtname: rtname,
      type: type,
      typex: typex,
      pk: pk,
      pkqty: pkqty,
      pkuser: pkuser,
      dbn: dbn,
      img: img,
      imglogo: imglogo,
      imglineqr: imglineqr,
      openSetDate: openSetDate ?? this.openSetDate,
      massOn: massOn ?? this.massOn,
      lineqr: lineqr,
      countArea: countArea ?? this.countArea,
    );
  }

  // base url — service จะ set ให้ผ่าน setter
  static String _baseUrl = '';
  static void setBaseUrl(String url) => _baseUrl = url;
}

/// Model จาก GC_zone.php — ใช้แสดง "รูปภาพโซนพื้นที่"
class ZoneImageModel {
  final String? ser;
  final String? rser;
  final String? zn; // ชื่อโซน
  final String? qty;
  final String? img; // ชื่อไฟล์รูป
  final String? dataUpdate;

  const ZoneImageModel({
    this.ser,
    this.rser,
    this.zn,
    this.qty,
    this.img,
    this.dataUpdate,
  });

  /// URL รูปโซน (full URL)
  String? get imageUrl => (img != null && img!.isNotEmpty)
      ? '${RentalGeneralModel._baseUrl}/files/${_folderFor(rser)}/zone/$img'
      : null;

  /// folder ตาม ser
  static String? _folderFor(String? rser) {
    // ใช้ dbn จาก RentalGeneralModel (set ใน service)
    return RentalGeneralModel._baseUrl.isNotEmpty ? _zoneFolder : null;
  }

  static String _zoneFolder = '';
  static void setFolder(String folder) => _zoneFolder = folder;

  factory ZoneImageModel.fromJson(Map<String, dynamic> json) {
    return ZoneImageModel(
      ser: json['ser']?.toString(),
      rser: json['rser']?.toString(),
      zn: json['zn']?.toString(),
      qty: json['qty']?.toString(),
      img: json['img']?.toString(),
      dataUpdate: json['data_update']?.toString(),
    );
  }
}

/// Sealed events
sealed class RentalGeneralEvent {
  const RentalGeneralEvent();
}

class LoadingRentalGeneral extends RentalGeneralEvent {
  const LoadingRentalGeneral();
}

class LoadedRentalGeneral extends RentalGeneralEvent {
  final RentalGeneralModel data;
  const LoadedRentalGeneral(this.data);
}

class LoadedZoneImages extends RentalGeneralEvent {
  final List<ZoneImageModel> zones;
  const LoadedZoneImages(this.zones);
}

class ErrorRentalGeneral extends RentalGeneralEvent {
  final String message;
  const ErrorRentalGeneral(this.message);
}

class UpdatedRentalGeneral extends RentalGeneralEvent {
  final String field;
  final String? message;
  const UpdatedRentalGeneral(this.field, {this.message});
}

class UploadedRentalGeneral extends RentalGeneralEvent {
  final String path; // 'logo' | 'contract' | 'zone'
  final String? zoneName;
  const UploadedRentalGeneral(this.path, {this.zoneName});
}

class DeletedRentalGeneral extends RentalGeneralEvent {
  final String path;
  const DeletedRentalGeneral(this.path);
}
