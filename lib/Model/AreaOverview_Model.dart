// ============================================================================
// AreaOverview_Model.dart
// ============================================================================
// Model — parse response จาก API overview ของพื้นที่เช่า (ล็อกทั้งหมด + join requester)
// ใช้แทน GC_areaAll.php + properties join ใน LicenseContractViewModel
//
// API:
//   GET {domain_v2}/admin/reports/areas/overview?zser=<zoneSer>
//   Header: Authorization Bearer ...
//   Response shape:
//   {
//     "data": {
//       "date": "2026-08-31",
//       "announcement_uuid": null,
//       "total_area": 175,
//       "total_leased": 10,
//       "total_vacant": 165,
//       "items": [
//         {
//           "subzone": "ถนนท่าแพ",
//           "subzone_qty": 5,
//           "zone": "ท่าแพ",
//           "zone_qty": 10,
//           "lock": "TP1",
//           "lock_code": "TP1",
//           "area": 2,
//           "lock_rent": 500,
//           "lock_status": 1,
//           "requester": null,
//           "customer_uuid": null,
//           "request_uuid": null,
//           "status": null
//         }
//       ]
//     }
//   }
// ============================================================================

class AreaOverviewResponse {
  final String? date;
  final String? announcementUuid;
  final int? totalArea;
  final int? totalLeased;
  final int? totalVacant;
  final List<AreaOverviewItem> items;

  const AreaOverviewResponse({
    this.date,
    this.announcementUuid,
    this.totalArea,
    this.totalLeased,
    this.totalVacant,
    this.items = const [],
  });

  factory AreaOverviewResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = <AreaOverviewItem>[];
    if (rawItems is List) {
      for (final e in rawItems) {
        if (e is Map<String, dynamic>) {
          items.add(AreaOverviewItem.fromJson(e));
        } else if (e is Map) {
          items.add(AreaOverviewItem.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return AreaOverviewResponse(
      date: json['date']?.toString(),
      announcementUuid: json['announcement_uuid']?.toString(),
      totalArea: _asInt(json['total_area']),
      totalLeased: _asInt(json['total_leased']),
      totalVacant: _asInt(json['total_vacant']),
      items: items,
    );
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }
}

class AreaOverviewItem {
  // ── zone / subzone ──
  final String? subzone;
  final int? subzoneQty;
  final String? zone;
  final int? zoneQty;

  // ── lock ──
  final String? lock;       // รหัสล็อก (เช่น "TP1")
  final String? lockCode;   // รหัสล็อก (เช่น "TP1") — บาง API ส่งซ้ำ
  final dynamic area;       // ขนาดพื้นที่ (number or string เช่น "2.00")
  final dynamic lockRent;   // ค่าเช่า
  final dynamic lockStatus; // 1 = ว่าง?, 0 = ไม่ว่าง?, อื่นๆ ตามสเปค server

  // ── requester (join) — null ถ้าล็อกว่าง ──
  final Map<String, dynamic>? requester;

  // ── customer (join) — null ถ้าล็อกว่าง ──
  final String? customerUuid;

  // ── request (join) — null ถ้าล็อกว่าง ──
  final String? requestUuid;
  final dynamic status;

  const AreaOverviewItem({
    this.subzone,
    this.subzoneQty,
    this.zone,
    this.zoneQty,
    this.lock,
    this.lockCode,
    this.area,
    this.lockRent,
    this.lockStatus,
    this.requester,
    this.customerUuid,
    this.requestUuid,
    this.status,
  });

  factory AreaOverviewItem.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? asMap(dynamic v) {
      if (v is Map<String, dynamic>) return v;
      if (v is Map) return Map<String, dynamic>.from(v);
      return null;
    }

    return AreaOverviewItem(
      subzone: json['subzone']?.toString(),
      subzoneQty: AreaOverviewResponse._asInt(json['subzone_qty']),
      zone: json['zone']?.toString(),
      zoneQty: AreaOverviewResponse._asInt(json['zone_qty']),
      lock: json['lock']?.toString(),
      lockCode: json['lock_code']?.toString(),
      area: json['area'],
      lockRent: json['lock_rent'],
      lockStatus: json['lock_status'],
      requester: asMap(json['requester']),
      customerUuid: json['customer_uuid']?.toString(),
      requestUuid: json['request_uuid']?.toString(),
      status: json['status'],
    );
  }

  // ── helpers ──

  /// ล็อกนี้ "มี request" หรือไม่ (ใช้แทน AreaModel.properties.isNotEmpty เดิม)
  bool get hasRequest =>
      (requestUuid != null && requestUuid!.trim().isNotEmpty) ||
      (customerUuid != null && customerUuid!.trim().isNotEmpty) ||
      (requester != null && requester!.isNotEmpty);

  /// string สั้นๆ ของ lock code (ใช้เปรียบเทียบ/แสดง)
  String? get lncode => lock ?? lockCode;
}
