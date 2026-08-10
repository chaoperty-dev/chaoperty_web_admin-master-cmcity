class AnnouncementZone {
  String? uuid;
  String? status;
  String? computedStatus;
  int? payStatus;
  String? payStatusPn;
  String? publishedAt;
  String? expiredAt;
  String? cDateStart;
  String? cDateEnd;
  ZoneProperty? zoneProperty;

  AnnouncementZone(
      {this.uuid,
      this.status,
      this.computedStatus,
      this.payStatus,
      this.payStatusPn,
      this.publishedAt,
      this.expiredAt,
      this.cDateStart,
      this.cDateEnd,
      this.zoneProperty});

  AnnouncementZone.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    status = json['status'];
    computedStatus = json['computed_status'];
    payStatus = json['pay_status'];
    payStatusPn = json['pay_status_pn'];
    publishedAt = json['published_at'];
    expiredAt = json['expired_at'];
    cDateStart = json['c_date_start'];
    cDateEnd = json['c_date_end'];
    zoneProperty = json['zone_property'] != null
        ? new ZoneProperty.fromJson(json['zone_property'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uuid'] = this.uuid;
    data['status'] = this.status;
    data['computed_status'] = this.computedStatus;
    data['pay_status'] = this.payStatus;
    data['pay_status_pn'] = this.payStatusPn;
    data['published_at'] = this.publishedAt;
    data['expired_at'] = this.expiredAt;
    data['c_date_start'] = this.cDateStart;
    data['c_date_end'] = this.cDateEnd;
    if (this.zoneProperty != null) {
      data['zone_property'] = this.zoneProperty!.toJson();
    }
    return data;
  }
}

class ZoneProperty {
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

  ZoneProperty(
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

  ZoneProperty.fromJson(Map<String, dynamic> json) {
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
