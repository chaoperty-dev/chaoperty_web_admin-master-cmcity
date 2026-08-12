// ============================================================================
// license_announce_item.dart
// ============================================================================
// Model: ประกาศ (Announcement) สำหรับหน้า "ประกาศ"
// ใช้ API v1: /admin/announcement/{active|history|...}
// ============================================================================

/// Item หลัก — map จาก AnnounceMentActiveModel (API v1)
class LicenseAnnounceItem {
  final String announcementUuid;
  final String title;
  final String content;
  final String sdate; // effective_at (วันเริ่มรับคำร้อง)
  final String edate; // expired_at (วันสิ้นสุด)
  final String announceDate; // published_at (วันที่ประกาศ)
  final String? zonePn; // ชื่อโซน (จาก announcement.properties[0].zonePn)
  final int? zoneId; // id โซน
  final String computedStatus; // "active" / "pending" / ...
  final String? version;
  final String? cDateStart; // วันที่ออกใบอนุญาต
  final String? cDateEnd; // วันที่หมดอายุใบอนุญาต

  const LicenseAnnounceItem({
    required this.announcementUuid,
    required this.title,
    required this.content,
    required this.sdate,
    required this.edate,
    required this.announceDate,
    required this.computedStatus,
    this.zonePn,
    this.zoneId,
    this.version,
    this.cDateStart,
    this.cDateEnd,
  });

  /// Map จาก API v1 (AnnounceMentActiveModel) → LicenseAnnounceItem
  factory LicenseAnnounceItem.fromActiveModel(dynamic model) {
    // ป้องกัน null ทุกระดับ
    final ann = model.announcement;
    final contentObj = ann?.content;
    final propsList = ann?.properties;
    final props =
        (propsList is List && propsList.isNotEmpty) ? propsList.first : null;

    return LicenseAnnounceItem(
      announcementUuid:
          model.announcementUuid?.toString() ?? model.uuid?.toString() ?? '',
      title: contentObj?.title?.toString() ?? '',
      content: contentObj?.content?.toString() ?? '',
      sdate: model.effectiveAt?.toString() ?? '',
      edate: model.expiredAt?.toString() ?? '',
      announceDate: model.publishedAt?.toString() ?? '',
      zonePn: props?.zonePn?.toString(),
      zoneId: (props?.zoneId is int) ? props.zoneId as int : null,
      computedStatus: model.computedStatus?.toString() ?? '',
      version: model.version?.toString(),
      cDateStart: model.cDateStart?.toString(),
      cDateEnd: model.cDateEnd?.toString(),
    );
  }

  /// Map จาก JSON ดิบ (สำรอง)
  factory LicenseAnnounceItem.fromJson(Map<String, dynamic> json) {
    final ann = json['announcement'] as Map<String, dynamic>?;
    final content = ann?['content'] as Map<String, dynamic>?;
    final propsList = ann?['properties'] as List?;
    final props = (propsList != null && propsList.isNotEmpty)
        ? propsList.first as Map<String, dynamic>?
        : null;

    return LicenseAnnounceItem(
      announcementUuid: json['announcement_uuid']?.toString() ??
          json['uuid']?.toString() ??
          '',
      title: content?['title']?.toString() ?? '',
      content: content?['content']?.toString() ?? '',
      sdate: json['effective_at']?.toString() ?? '',
      edate: json['expired_at']?.toString() ?? '',
      announceDate: json['published_at']?.toString() ?? '',
      zonePn: props?['zone_pn']?.toString(),
      zoneId: (props?['zone_id'] is int) ? props!['zone_id'] as int : null,
      computedStatus: json['computed_status']?.toString() ?? '',
      version: json['version']?.toString(),
      cDateStart: json['c_date_start']?.toString(),
      cDateEnd: json['c_date_end']?.toString(),
    );
  }

  bool get isActive {
    final s = computedStatus.toLowerCase();
    return s == 'active' || s == 'published' || s == '1';
  }
}

/// โซน — map จาก ZoneModel (ใช้ GC_zone.php เดิม)
class LicenseAnnounceZone {
  final String ser;
  final String zn;
  final String? rser;
  final String? subZone;
  final String? qty;
  final String? status;

  const LicenseAnnounceZone({
    required this.ser,
    required this.zn,
    this.rser,
    this.subZone,
    this.qty,
    this.status,
  });

  factory LicenseAnnounceZone.fromJson(Map<String, dynamic> json) {
    return LicenseAnnounceZone(
      ser: (json['ser'] ?? '0').toString(),
      zn: (json['zn'] ?? json['name'] ?? '').toString(),
      rser: json['rser']?.toString(),
      subZone: json['sub_zone']?.toString(),
      qty: json['qty']?.toString(),
      status: json['status']?.toString(),
    );
  }
}

/// หมวดโซนพื้นที่ — map จาก SubZoneModel (ใช้ GC_zone_sub.php เดิม)
class LicenseAnnounceSubZone {
  final String ser;
  final String? zn;
  final String? rser;

  const LicenseAnnounceSubZone({
    required this.ser,
    this.zn,
    this.rser,
  });

  factory LicenseAnnounceSubZone.fromJson(Map<String, dynamic> json) {
    return LicenseAnnounceSubZone(
      ser: (json['ser'] ?? '0').toString(),
      zn: json['zn']?.toString(),
      rser: json['rser']?.toString(),
    );
  }
}
