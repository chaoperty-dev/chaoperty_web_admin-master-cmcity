class ReviewModel {
  int? id;
  String? uuid;
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

  ReviewModel(
      {this.id,
      this.uuid,
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
      this.needsUpdate});

  ReviewModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    clientsUuid = json['clients_uuid'];
    submittedAt = json['submitted_at'];
    submittedBy = json['submitted_by'];
    feeAmount = json['fee_amount'];
    createdAt = json['created_at'];
    module =
        json['module'] != null ? new Module.fromJson(json['module']) : null;
    client =
        json['client'] != null ? new Client.fromJson(json['client']) : null;
    newRequest = json['new_request'] != null
        ? NewRequestModel.fromJson(json['new_request'])
        : null;
    status = json['status'];
    statusLabel = json['status_label'];
    reviewStatus = json['review_status'];
    reviewBadges = json['review_badges'] != null
        ? new ReviewBadges.fromJson(json['review_badges'])
        : null;
    hasNewAttachment = json['has_new_attachment'];
    latestAttachmentUploadedAt = json['latest_attachment_uploaded_at'];
    allAttachmentsApproved = json['all_attachments_approved'];
    needReview = json['need_review'];
    needsUpdate = json['needs_update'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uuid'] = this.uuid;
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
    return data;
  }
}

class Module {
  int? id;
  String? nameTh;

  Module({this.id, this.nameTh});

  Module.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nameTh = json['name_th'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name_th'] = this.nameTh;
    return data;
  }
}

class Client {
  String? uuid;
  int? ser;
  String? custno;
  String? scname;
  String? cname;
  String? addr1;
  String? addr2;
  Json? jsonData;
  String? tel;
  String? tax;

  Client({
    this.uuid,
    this.ser,
    this.custno,
    this.scname,
    this.cname,
    this.addr1,
    this.addr2,
    this.jsonData,
    this.tel,
    this.tax,
  });

  Client.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    ser = json['ser'];
    custno = json['custno'];
    scname = json['scname'];
    cname = json['cname'];
    addr1 = json['addr_1'];
    addr2 = json['addr_2'];
    jsonData = json['json'] != null ? Json.fromJson(json['json']) : null;
    tel = json['tel'];
    tax = json['tax'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['uuid'] = uuid;
    data['ser'] = ser;
    data['custno'] = custno;
    data['scname'] = scname;
    data['cname'] = cname;
    data['addr_1'] = addr1;
    data['addr_2'] = addr2;
    if (jsonData != null) {
      data['json'] = jsonData!.toJson();
    }
    data['tel'] = tel;
    data['tax'] = tax;
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

  NewRequestModel.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    requestUuid = json['request_uuid'];
    leaseNumber = json['lease_number'];
    propertyId = json['property_id'];
    subzoneser = json['subzoneser'];
    subzone = json['subzone'];
    zn = json['zn'];
    ln = json['ln'];
    sdate = json['sdate'];
    ldate = json['ldate'];
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





// class ReviewModel {
//   final int id;
//   final String uuid;
//   final ModuleModel module;
//   final ClientModel client;
//   final NewRequestModel newRequest;
//   final String status;
//   final int needReviewCount;
//   final bool needReview;
//   final String? statusLabel;
//   final String? flowUuid;
//   final String? flowName;

//   ReviewModel({
//     required this.id,
//     required this.uuid,
//     required this.module,
//     required this.client,
//     required this.newRequest,
//     required this.status,
//     required this.needReviewCount,
//     required this.needReview,
//     this.statusLabel,
//     this.flowUuid,
//     this.flowName,
//   });

//   factory ReviewModel.fromJson(Map<String, dynamic> json) {
//     return ReviewModel(
//       id: json['id'],
//       uuid: json['uuid'],
//       module: ModuleModel.fromJson(json['module']),
//       client: ClientModel.fromJson(json['client']),
//       newRequest: NewRequestModel.fromJson(json['new_request']),
//       status: json['status'],
//       needReviewCount: json['need_review_count'],
//       needReview: json['need_review'],
//       statusLabel: json['status_label'],
//       flowUuid: json['flow_uuid'],
//       flowName: json['flow_name'],
//     );
//   }
// }

// class ModuleModel {
//   final int id;
//   final String nameTh;

//   ModuleModel({required this.id, required this.nameTh});

//   factory ModuleModel.fromJson(Map<String, dynamic> json) {
//     return ModuleModel(
//       id: json['id'],
//       nameTh: json['name_th'],
//     );
//   }
// }

// class ClientModel {
//   final String uuid;
//   final int ser;
//   final String custno;
//   final String scname;
//   final String addr1;
//   final String addr2;
//   final Map<String, dynamic> jsonDetail;
//   final String tel;
//   final String tax;

//   ClientModel({
//     required this.uuid,
//     required this.ser,
//     required this.custno,
//     required this.scname,
//     required this.addr1,
//     required this.addr2,
//     required this.jsonDetail,
//     required this.tel,
//     required this.tax,
//   });

//   factory ClientModel.fromJson(Map<String, dynamic> json) {
//     return ClientModel(
//       uuid: json['uuid'],
//       ser: json['ser'],
//       custno: json['custno'],
//       scname: json['scname'],
//       addr1: json['addr_1'],
//       addr2: json['addr_2'],
//       jsonDetail: json['json'] ?? {},
//       tel: json['tel'],
//       tax: json['tax'],
//     );
//   }
// }

// class NewRequestModel {
//   final String uuid;
//   final String requestUuid;
//   final String leaseNumber;
//   final int propertyId;
//   final int subzoneSer;
//   final String zn;
//   final String ln;
//   final String sdate;
//   final String ldate;

//   NewRequestModel({
//     required this.uuid,
//     required this.requestUuid,
//     required this.leaseNumber,
//     required this.propertyId,
//     required this.subzoneSer,
//     required this.zn,
//     required this.ln,
//     required this.sdate,
//     required this.ldate,
//   });

//   factory NewRequestModel.fromJson(Map<String, dynamic> json) {
//     return NewRequestModel(
//       uuid: json['uuid'],
//       requestUuid: json['request_uuid'],
//       leaseNumber: json['lease_number'],
//       propertyId: json['property_id'],
//       subzoneSer: json['subzoneser'],
//       zn: json['zn'],
//       ln: json['ln'],
//       sdate: json['sdate'],
//       ldate: json['ldate'],
//     );
//   }
// }
