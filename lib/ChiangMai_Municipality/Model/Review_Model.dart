class ReviewModel {
  int? id;
  String? uuid; // step_uuid (ของ step instance)
  String? instanceUuid; // instance_uuid (uuid ของ instance ที่ step นี้สังกัด)
  String? requestUuid; // request_uuid (uuid ของ request ต้นทาง)
  String? clientsUuid;
  String? submittedAt;
  String? submittedBy;
  String? feeAmount;
  String? createdAt;
  Module? module;
  Client? client;
  // newRequest? newRequest;
  NewRequestModel? newRequest;
  String? status;
  String? statusLabel;
  String? reviewStatus;
  ReviewBadges? reviewBadges;
  bool? hasNewAttachment;
  String? latestAttachmentUploadedAt;
  bool? allAttachmentsApproved;
  bool? needReview;
  bool? needsUpdate;

  // ─── new API (v2 /admin/approvals/me) extras ───
  int? round;
  int? stepOrder;
  String? stepName;
  bool? viaDelegation;

  ReviewModel(
      {this.id,
      this.uuid,
      this.instanceUuid,
      this.requestUuid,
      this.clientsUuid,
      this.submittedAt,
      this.submittedBy,
      this.feeAmount,
      this.createdAt,
      this.module,
      this.client,
      this.newRequest,
      this.status,
      this.statusLabel,
      this.reviewStatus,
      this.reviewBadges,
      this.hasNewAttachment,
      this.latestAttachmentUploadedAt,
      this.allAttachmentsApproved,
      this.needReview,
      this.needsUpdate,
      this.round,
      this.stepOrder,
      this.stepName,
      this.viaDelegation});

  /// รองรับทั้ง 2 shape:
  /// - v1: { uuid, client, new_request }
  /// - v2: { step_uuid, customer, details }
  ReviewModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = (json['step_uuid'] ?? json['uuid'])?.toString();
    instanceUuid = (json['instance_uuid'])?.toString();
    requestUuid = (json['request_uuid'])?.toString();
    clientsUuid = json['clients_uuid'];
    submittedAt = json['submitted_at'];
    submittedBy = json['submitted_by'];
    feeAmount = json['fee_amount'];
    createdAt = (json['created_at'])?.toString();
    module =
        json['module'] != null ? new Module.fromJson(json['module']) : null;

    // v2: customer → client ; v1: client → client
    final customerJson = json['customer'] ?? json['client'];
    client = customerJson != null
        ? new Client.fromJson(customerJson as Map<String, dynamic>)
        : null;

    // v2: details → newRequest ; v1: new_request → newRequest
    final detailsJson = json['details'] ?? json['new_request'];
    newRequest = detailsJson != null
        ? NewRequestModel.fromJson(detailsJson as Map<String, dynamic>)
        : null;

    status = json['status']?.toString();
    statusLabel = json['status_label']?.toString();
    reviewStatus = json['review_status'];
    reviewBadges = json['review_badges'] != null
        ? new ReviewBadges.fromJson(json['review_badges'])
        : null;
    hasNewAttachment = json['has_new_attachment'];
    latestAttachmentUploadedAt = json['latest_attachment_uploaded_at'];
    allAttachmentsApproved = json['all_attachments_approved'];
    needReview = json['need_review'];
    needsUpdate = json['needs_update'];

    // v2 extras
    round = json['round'] is int
        ? json['round']
        : int.tryParse(json['round']?.toString() ?? '');
    stepOrder = json['step_order'] is int
        ? json['step_order']
        : int.tryParse(json['step_order']?.toString() ?? '');
    stepName = json['step_name']?.toString();
    viaDelegation = json['via_delegation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uuid'] = this.uuid;
    data['instance_uuid'] = this.instanceUuid;
    data['request_uuid'] = this.requestUuid;
    data['clients_uuid'] = this.clientsUuid;
    data['submitted_at'] = this.submittedAt;
    data['submitted_by'] = this.submittedBy;
    data['fee_amount'] = this.feeAmount;
    data['created_at'] = this.createdAt;
    if (this.module != null) {
      data['module'] = this.module!.toJson();
    }
    if (this.client != null) {
      data['client'] = this.client!.toJson();
    }
    if (this.newRequest != null) {
      data['new_request'] = this.newRequest!.toJson();
    }
    data['status'] = this.status;
    data['status_label'] = this.statusLabel;
    data['review_status'] = this.reviewStatus;
    if (this.reviewBadges != null) {
      data['review_badges'] = this.reviewBadges!.toJson();
    }
    data['has_new_attachment'] = this.hasNewAttachment;
    data['latest_attachment_uploaded_at'] = this.latestAttachmentUploadedAt;
    data['all_attachments_approved'] = this.allAttachmentsApproved;
    data['need_review'] = this.needReview;
    data['needs_update'] = this.needsUpdate;
    data['round'] = this.round;
    data['step_order'] = this.stepOrder;
    data['step_name'] = this.stepName;
    data['via_delegation'] = this.viaDelegation;
    return data;
  }
}

class Module {
  int? id;
  String? nameTh;
  String? code; // v2: module.code เพิ่มเข้ามา

  Module({this.id, this.nameTh, this.code});

  Module.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nameTh = json['name_th']?.toString();
    code = json['code']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name_th'] = this.nameTh;
    data['code'] = this.code;
    return data;
  }
}

class Client {
  String? uuid;
  int? ser;
  String? custno;
  String? scname;
  String? sname; // v2
  String? cname;
  String? branch; // v2
  String? attn; // v2
  String? addr1; // v2 ส่งเป็น addr_1
  String? addr2; // v2 ส่งเป็น addr_2
  String? zip; // v2
  String? tel;
  String? email; // v2
  String? tax;
  String? taxno; // v2
  String? type; // v2
  String? stype; // v2
  int? active; // v2
  String? requestUuid; // v2: customer.request_uuid
  Json? jsonData;
  String? customerCreatedAt; // v2: customer.created_at
  String? customerUpdatedAt; // v2: customer.updated_at

  Client({
    this.uuid,
    this.ser,
    this.custno,
    this.scname,
    this.sname,
    this.cname,
    this.branch,
    this.attn,
    this.addr1,
    this.addr2,
    this.zip,
    this.tel,
    this.email,
    this.tax,
    this.taxno,
    this.type,
    this.stype,
    this.active,
    this.requestUuid,
    this.jsonData,
    this.customerCreatedAt,
    this.customerUpdatedAt,
  });

  Client.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid']?.toString();
    ser = json['ser'] is int
        ? json['ser']
        : int.tryParse(json['ser']?.toString() ?? '');
    custno = json['custno']?.toString();
    scname = json['scname']?.toString();
    sname = json['sname']?.toString();
    cname = json['cname']?.toString();
    branch = json['branch']?.toString();
    attn = json['attn']?.toString();
    // v2 ใช้ addr_1/addr_2 — fallback เผื่อ v1 ใช้ addr1/addr2
    addr1 = (json['addr_1'] ?? json['addr1'])?.toString();
    addr2 = (json['addr_2'] ?? json['addr2'])?.toString();
    zip = json['zip']?.toString();
    tel = json['tel']?.toString();
    email = json['email']?.toString();
    tax = json['tax']?.toString();
    taxno = json['taxno']?.toString();
    type = json['type']?.toString();
    stype = json['stype']?.toString();
    active = json['active'] is int
        ? json['active']
        : int.tryParse(json['active']?.toString() ?? '');
    requestUuid = json['request_uuid']?.toString();
    jsonData = json['json'] != null ? Json.fromJson(json['json']) : null;
    customerCreatedAt = json['created_at']?.toString();
    customerUpdatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['uuid'] = uuid;
    data['ser'] = ser;
    data['custno'] = custno;
    data['scname'] = scname;
    data['sname'] = sname;
    data['cname'] = cname;
    data['branch'] = branch;
    data['attn'] = attn;
    data['addr_1'] = addr1;
    data['addr_2'] = addr2;
    data['zip'] = zip;
    data['tel'] = tel;
    data['email'] = email;
    data['tax'] = tax;
    data['taxno'] = taxno;
    data['type'] = type;
    data['stype'] = stype;
    data['active'] = active;
    data['request_uuid'] = requestUuid;
    if (jsonData != null) {
      data['json'] = jsonData!.toJson();
    }
    data['created_at'] = customerCreatedAt;
    data['updated_at'] = customerUpdatedAt;
    return data;
  }
}

class Json {
  String? number;
  String? moo;
  String? soi;
  String? road;
  String? tambon;
  String? amphoe;
  String? province;
  String? raw;

  Json(
      {this.number,
      this.moo,
      this.soi,
      this.road,
      this.tambon,
      this.amphoe,
      this.province,
      this.raw});

  Json.fromJson(Map<String, dynamic> json) {
    number = json['number'];
    moo = json['moo'];
    soi = json['soi'];
    road = json['road'];
    tambon = json['tambon'];
    amphoe = json['amphoe'];
    province = json['province'];
    raw = json['raw'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['number'] = this.number;
    data['moo'] = this.moo;
    data['soi'] = this.soi;
    data['road'] = this.road;
    data['tambon'] = this.tambon;
    data['amphoe'] = this.amphoe;
    data['province'] = this.province;
    data['raw'] = this.raw;
    return data;
  }
}

class NewRequestModel {
  String? uuid;
  String? requestUuid;
  String? leaseNumber;
  int? propertyId;
  int? subzoneser;
  String? subzone;
  String? zn;
  String? ln;
  String? sdate;
  String? ldate;
  int? requestStep;

  NewRequestModel(
      {this.uuid,
      this.requestUuid,
      this.leaseNumber,
      this.propertyId,
      this.subzoneser,
      this.subzone,
      this.zn,
      this.ln,
      this.sdate,
      this.ldate,
      this.requestStep});

  /// v2: details มีแค่ { subzone, zn, ln } — อ่าน key เดิมด้วยเพื่อ backward-compat
  NewRequestModel.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid']?.toString();
    requestUuid = (json['request_uuid'] ?? json['requestUuid'])?.toString();
    leaseNumber = (json['lease_number'] ?? json['leaseNumber'])?.toString();
    propertyId = json['property_id'] is int
        ? json['property_id']
        : int.tryParse(json['property_id']?.toString() ?? '');
    subzoneser = json['subzoneser'] is int
        ? json['subzoneser']
        : int.tryParse(json['subzoneser']?.toString() ?? '');
    subzone = (json['subzone'])?.toString();
    zn = (json['zn'])?.toString();
    ln = (json['ln'])?.toString();
    sdate = json['sdate']?.toString();
    ldate = json['ldate']?.toString();
    requestStep = json['request_step'] is int
        ? json['request_step']
        : int.tryParse(json['request_step']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uuid'] = this.uuid;
    data['request_uuid'] = this.requestUuid;
    data['lease_number'] = this.leaseNumber;
    data['property_id'] = this.propertyId;
    data['subzoneser'] = this.subzoneser;
    data['subzone'] = this.subzone;
    data['zn'] = this.zn;
    data['ln'] = this.ln;
    data['sdate'] = this.sdate;
    data['ldate'] = this.ldate;
    return data;
  }
}

class ReviewBadges {
  int? total;
  int? needReview;
  int? needsUpdate;
  int? approved;
  int? rejected;
  int? newUploaded;

  ReviewBadges(
      {this.total,
      this.needReview,
      this.needsUpdate,
      this.approved,
      this.rejected,
      this.newUploaded});

  ReviewBadges.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    needReview = json['need_review'];
    needsUpdate = json['needs_update'];
    approved = json['approved'];
    rejected = json['rejected'];
    newUploaded = json['new_uploaded'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total'] = this.total;
    data['need_review'] = this.needReview;
    data['needs_update'] = this.needsUpdate;
    data['approved'] = this.approved;
    data['rejected'] = this.rejected;
    data['new_uploaded'] = this.newUploaded;
    return data;
  }
}