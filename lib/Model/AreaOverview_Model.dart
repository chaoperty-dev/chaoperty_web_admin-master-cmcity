// ============================================================================
// AreaOverview_Model.dart
// ============================================================================
// Model — parse response จาก API overview ของพื้นที่เช่า
//
// API (ใหม่ — มีค่า aser):
//   GET {domain_v2}/admin/areas/overview?zser=<zoneSer>&sort_by=lock&sort_dir=asc&page=1
//   Header: Authorization Bearer ...
//   Response shape:
//   {
//     "data": {
//       "date": "2026-09-02",
//       "announcement_uuid": null,
//       "total_area": 175,
//       "total_leased": 11,
//       "total_vacant": 164,
//       "duplicate_leases": 0,
//       "items": [
//         {
//           "aser": 21,
//           "zser": 4,
//           "subzone": "กาดหลวง",
//           "zone": "Test",
//           "lock": "T1",
//           "requester": null,        // ชื่อผู้ติดต่อ (string) หรือ null
//           "customer_no": null,
//           "customer_tel": null,
//           "sdate": null,
//           "ldate": null,
//           "status": null            // EN key ของคำขอ เช่น "in_progress"
//         }
//       ]
//     }
//   }
//
// หมายเหตุ: รองรับทั้ง requester เป็น string (API ใหม่) และ object (API เก่า)
// ============================================================================

class AreaOverviewResponse {
  final String? date;
  final String? announcementUuid;
  final int? totalArea;
  final int? totalLeased;
  final int? totalVacant;
  final int? duplicateLeases;
  final List<AreaOverviewItem> items;

  const AreaOverviewResponse({
    this.date,
    this.announcementUuid,
    this.totalArea,
    this.totalLeased,
    this.totalVacant,
    this.duplicateLeases,
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
      duplicateLeases: _asInt(json['duplicate_leases']),
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
  // ── id จริง (API ใหม่) ──
  final String? aser; // area serial — join กับ area.ser
  final String? zser; // zone serial

  // ── zone / subzone ──
  final String? subzone;
  final int? subzoneQty; // API เก่าเท่านั้น
  final String? zone;
  final int? zoneQty; // API เก่าเท่านั้น

  // ── lock ──
  final String? lock;       // รหัสล็อก (เช่น "T1")
  final String? lockCode;   // API เก่าเท่านั้น
  final dynamic area;       // ขนาดพื้นที่ (API เก่าเท่านั้น)
  final dynamic lockRent;   // ค่าเช่า (API เก่าเท่านั้น)
  final dynamic lockStatus; // API เก่าเท่านั้น

  // ── requester — string (ชื่อ, API ใหม่) หรือ object (API เก่า) ──
  final Object? requester;

  // ── customer ──
  final String? customerNo;
  final String? customerTel;
  final String? customerUuid; // API เก่าเท่านั้น

  // ── สัญญา / คำขอ ──
  final String? sdate;
  final String? ldate;
  final String? requestUuid; // API เก่าเท่านั้น
  final String? status;      // EN key เช่น "in_progress"

  const AreaOverviewItem({
    this.aser,
    this.zser,
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
    this.customerNo,
    this.customerTel,
    this.customerUuid,
    this.sdate,
    this.ldate,
    this.requestUuid,
    this.status,
  });

  factory AreaOverviewItem.fromJson(Map<String, dynamic> json) {
    return AreaOverviewItem(
      aser: json['aser']?.toString(),
      zser: json['zser']?.toString(),
      subzone: json['subzone']?.toString(),
      subzoneQty: AreaOverviewResponse._asInt(json['subzone_qty']),
      zone: json['zone']?.toString(),
      zoneQty: AreaOverviewResponse._asInt(json['zone_qty']),
      lock: json['lock']?.toString(),
      lockCode: json['lock_code']?.toString(),
      area: json['area'],
      lockRent: json['lock_rent'],
      lockStatus: json['lock_status'],
      requester: json['requester'],
      customerNo: json['customer_no']?.toString(),
      customerTel: json['customer_tel']?.toString(),
      customerUuid: json['customer_uuid']?.toString(),
      sdate: json['sdate']?.toString(),
      ldate: json['ldate']?.toString(),
      requestUuid: json['request_uuid']?.toString(),
      status: json['status']?.toString(),
    );
  }

  // ── helpers ──

  /// requester เป็น object (API เก่า) → Map, ไม่ใช่ → null
  Map<String, dynamic>? get requesterMap {
    final r = requester;
    if (r is Map<String, dynamic>) return r;
    if (r is Map) return Map<String, dynamic>.from(r);
    return null;
  }

  /// requester เป็น string ชื่อผู้ติดต่อ (API ใหม่)
  String? get requesterName {
    final r = requester;
    if (r is String) return r.isEmpty ? null : r;
    if (r is num) return r.toString();
    return null;
  }

  /// ล็อกนี้ "มี request" หรือไม่
  bool get hasRequest =>
      (requesterName != null && requesterName!.trim().isNotEmpty) ||
      (requesterMap != null && requesterMap!.isNotEmpty) ||
      (requestUuid != null && requestUuid!.trim().isNotEmpty) ||
      (customerUuid != null && customerUuid!.trim().isNotEmpty) ||
      (status != null && status!.trim().isNotEmpty);

  /// string สั้นๆ ของ lock code (ใช้เปรียบเทียบ/แสดง)
  String? get lncode => lock ?? lockCode;
}