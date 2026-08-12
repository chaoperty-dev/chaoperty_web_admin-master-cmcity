class AnnounceMentActiveModel {
  int? id;
  String? uuid;
  String? announcementUuid;
  int? version;
  String? cDateStart;
  String? cDateEnd;
  String? publishedAt;
  String? effectiveAt;
  String? expiredAt;
  int? active;
  String? createdBy;
  String? createdAt;
  String? updatedAt;
  String? computedStatus;
  bool? canEditZone;
  bool? canEditSchedule;
  Announcement? announcement;

  AnnounceMentActiveModel(
      {this.id,
      this.uuid,
      this.announcementUuid,
      this.version,
      this.cDateStart,
      this.cDateEnd,
      this.publishedAt,
      this.effectiveAt,
      this.expiredAt,
      this.active,
      this.createdBy,
      this.createdAt,
      this.updatedAt,
      this.computedStatus,
      this.canEditZone,
      this.canEditSchedule,
      this.announcement});

  AnnounceMentActiveModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    announcementUuid = json['announcement_uuid'];
    version = json['version'];
    cDateStart = json['c_date_start'];
    cDateEnd = json['c_date_end'];
    publishedAt = json['published_at'];
    effectiveAt = json['effective_at'];
    expiredAt = json['expired_at'];
    active = json['active'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    computedStatus = json['computed_status'];
    canEditZone = json['can_edit_zone'];
    canEditSchedule = json['can_edit_schedule'];

    // 2 shape ที่รองรับ:
    // (a) /active → { "announcement": { "content": {...}, "properties": [...] } }
    // (b) /{uuid} → { "content": {...}, "properties": [...], "schedule": {...} } (top-level)
    if (json['announcement'] != null) {
      announcement = Announcement.fromJson(
          Map<String, dynamic>.from(json['announcement']));
    } else if (json['content'] != null || json['properties'] != null) {
      // Flatten ให้ Announcement.fromJson อ่านได้
      announcement = Announcement.fromJson(Map<String, dynamic>.from(json));
    } else {
      announcement = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uuid'] = this.uuid;
    data['announcement_uuid'] = this.announcementUuid;
    data['version'] = this.version;
    data['c_date_start'] = this.cDateStart;
    data['c_date_end'] = this.cDateEnd;
    data['published_at'] = this.publishedAt;
    data['effective_at'] = this.effectiveAt;
    data['expired_at'] = this.expiredAt;
    data['active'] = this.active;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['computed_status'] = this.computedStatus;
    data['can_edit_zone'] = this.canEditZone;
    data['can_edit_schedule'] = this.canEditSchedule;
    if (this.announcement != null) {
      data['announcement'] = this.announcement!.toJson();
    }
    return data;
  }
}

class Announcement {
  int? id;
  String? uuid;
  String? createdBy;
  String? status;
  Content? content;
  List<Properties>? properties;

  Announcement(
      {this.id,
      this.uuid,
      this.createdBy,
      this.status,
      this.content,
      this.properties});

  Announcement.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    createdBy = json['created_by'];
    status = json['status'];
    content =
        json['content'] != null ? new Content.fromJson(json['content']) : null;
    if (json['properties'] != null) {
      properties = <Properties>[];
      json['properties'].forEach((v) {
        properties!.add(new Properties.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uuid'] = this.uuid;
    data['created_by'] = this.createdBy;
    data['status'] = this.status;
    if (this.content != null) {
      data['content'] = this.content!.toJson();
    }
    if (this.properties != null) {
      data['properties'] = this.properties!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Content {
  int? id;
  String? uuid;
  String? announcementUuid;
  String? langCode;
  String? title;
  String? content;
  List<Meta>? meta;
  int? version;
  int? active;
  String? createdBy;
  String? createdAt;
  String? updatedAt;

  Content(
      {this.id,
      this.uuid,
      this.announcementUuid,
      this.langCode,
      this.title,
      this.content,
      this.meta,
      this.version,
      this.active,
      this.createdBy,
      this.createdAt,
      this.updatedAt});

  Content.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    announcementUuid = json['announcement_uuid'];
    langCode = json['lang_code'];
    title = json['title'];
    content = json['content'];
    if (json['meta'] != null) {
      meta = <Meta>[];
      json['meta'].forEach((v) {
        meta!.add(new Meta.fromJson(v));
      });
    }
    version = json['version'];
    active = json['active'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uuid'] = this.uuid;
    data['announcement_uuid'] = this.announcementUuid;
    data['lang_code'] = this.langCode;
    data['title'] = this.title;
    data['content'] = this.content;
    if (this.meta != null) {
      data['meta'] = this.meta!.map((v) => v.toJson()).toList();
    }
    data['version'] = this.version;
    data['active'] = this.active;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Meta {
  String? key;
  String? value;

  Meta({this.key, this.value});

  Meta.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['value'] = this.value;
    return data;
  }
}

class Properties {
  int? id;
  String? uuid;
  String? announcementUuid;
  int? propertyId;
  String? propertyPn;
  int? zoneId;
  String? zonePn;
  int? subzoneId;
  String? subzonePn;
  int? active;
  String? createdBy;
  String? createdAt;
  String? updatedAt;

  Properties(
      {this.id,
      this.uuid,
      this.announcementUuid,
      this.propertyId,
      this.propertyPn,
      this.zoneId,
      this.zonePn,
      this.subzoneId,
      this.subzonePn,
      this.active,
      this.createdBy,
      this.createdAt,
      this.updatedAt});

  Properties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    announcementUuid = json['announcement_uuid'];
    propertyId = json['property_id'];
    propertyPn = json['property_pn'];
    zoneId = json['zone_id'];
    zonePn = json['zone_pn'];
    subzoneId = json['subzone_id'];
    subzonePn = json['subzone_pn'];
    active = json['active'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uuid'] = this.uuid;
    data['announcement_uuid'] = this.announcementUuid;
    data['property_id'] = this.propertyId;
    data['property_pn'] = this.propertyPn;
    data['zone_id'] = this.zoneId;
    data['zone_pn'] = this.zonePn;
    data['subzone_id'] = this.subzoneId;
    data['subzone_pn'] = this.subzonePn;
    data['active'] = this.active;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
