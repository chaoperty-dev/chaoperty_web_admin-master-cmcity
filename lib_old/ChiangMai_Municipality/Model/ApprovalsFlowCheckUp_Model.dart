class ApprovalsFlowCheckUpModel {
  int? id;
  String? uuid;
  String? status;
  String? submittedAt;
  String? submittedBy;
  String? feeAmount;
  String? createdAt;
  Module? module;
  Client? client;
  NewRequest? newRequest;
  List<RequestDocument>? requestDocument;
  List<ApproveDocuments>? approveDocuments;

  ApprovalsFlowCheckUpModel(
      {this.id,
      this.uuid,
      this.status,
      this.submittedAt,
      this.submittedBy,
      this.feeAmount,
      this.createdAt,
      this.module,
      this.client,
      this.newRequest,
      this.requestDocument,
      this.approveDocuments});

  ApprovalsFlowCheckUpModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    status = json['status'];
    submittedAt = json['submitted_at'];
    submittedBy = json['submitted_by'];
    feeAmount = json['fee_amount'];
    createdAt = json['created_at'];
    module =
        json['module'] != null ? new Module.fromJson(json['module']) : null;
    client =
        json['client'] != null ? new Client.fromJson(json['client']) : null;
    newRequest = json['new_request'] != null
        ? new NewRequest.fromJson(json['new_request'])
        : null;
    if (json['request_document'] != null) {
      requestDocument = <RequestDocument>[];
      json['request_document'].forEach((v) {
        requestDocument!.add(new RequestDocument.fromJson(v));
      });
    }
    if (json['approve_documents'] != null) {
      approveDocuments = <ApproveDocuments>[];
      json['approve_documents'].forEach((v) {
        approveDocuments!.add(new ApproveDocuments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uuid'] = this.uuid;
    data['status'] = this.status;
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
    if (this.requestDocument != null) {
      data['request_document'] =
          this.requestDocument!.map((v) => v.toJson()).toList();
    }
    if (this.approveDocuments != null) {
      data['approve_documents'] =
          this.approveDocuments!.map((v) => v.toJson()).toList();
    }
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
    data['addr_1'] = addr1;
    data['addr_2'] = addr2;
    data['json'] = jsonData?.toJson(); // ✅ ปลอดภัย
    data['tel'] = tel;
    data['tax'] = tax;
    return data;
  }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = {};
  //   data['uuid'] = uuid;
  //   data['ser'] = ser;
  //   data['custno'] = custno;
  //   data['scname'] = scname;
  //   data['addr_1'] = addr1;
  //   data['addr_2'] = addr2;
  //   if (jsonData != null) {
  //     data['json'] = jsonData!.toJson();
  //   }
  //   data['tel'] = tel;
  //   data['tax'] = tax;
  //   return data;
  // }
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

class NewRequest {
  String? uuid;
  String? requestUuid;
  String? leaseNumber;
  int? propertyId;
  int? subzoneser;
  String? zn;
  String? ln;
  String? sdate;
  String? ldate;

  NewRequest(
      {this.uuid,
      this.requestUuid,
      this.leaseNumber,
      this.propertyId,
      this.subzoneser,
      this.zn,
      this.ln,
      this.sdate,
      this.ldate});

  NewRequest.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    requestUuid = json['request_uuid'];
    leaseNumber = json['lease_number'];
    propertyId = json['property_id'];
    subzoneser = json['subzoneser'];
    zn = json['zn'];
    ln = json['ln'];
    sdate = json['sdate'];
    ldate = json['ldate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uuid'] = this.uuid;
    data['request_uuid'] = this.requestUuid;
    data['lease_number'] = this.leaseNumber;
    data['property_id'] = this.propertyId;
    data['subzoneser'] = this.subzoneser;
    data['zn'] = this.zn;
    data['ln'] = this.ln;
    data['sdate'] = this.sdate;
    data['ldate'] = this.ldate;
    return data;
  }
}

class RequestDocument {
  int? id;
  String? code;
  String? nameTh;
  int? required;
  int? showAfterSubmit;
  RequestAttachments? requestAttachments;

  RequestDocument(
      {this.id,
      this.code,
      this.nameTh,
      this.required,
      this.showAfterSubmit,
      this.requestAttachments});

  RequestDocument.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    nameTh = json['name_th'];
    required = json['required'];
    showAfterSubmit = json['show_after_submit'];
    requestAttachments = json['request_attachments'] != null
        ? new RequestAttachments.fromJson(json['request_attachments'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['name_th'] = this.nameTh;
    data['required'] = this.required;
    data['show_after_submit'] = this.showAfterSubmit;
    if (this.requestAttachments != null) {
      data['request_attachments'] = this.requestAttachments!.toJson();
    }
    return data;
  }
}

class RequestAttachments {
  String? uuid;
  String? fileName;
  String? fileType;
  String? createdAt;
  Reviews? reviews;

  RequestAttachments(
      {this.uuid, this.fileName, this.fileType, this.createdAt, this.reviews});

  RequestAttachments.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    fileName = json['file_name'];
    fileType = json['file_type'];
    createdAt = json['created_at'];
    reviews =
        json['reviews'] != null ? new Reviews.fromJson(json['reviews']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uuid'] = this.uuid;
    data['file_name'] = this.fileName;
    data['file_type'] = this.fileType;
    data['created_at'] = this.createdAt;
    data['reviewer'] = reviews?.toJson();

    // if (this.reviews != null) {
    //   // data['reviews'] = this.reviews!.toJson();
    // }
    return data;
  }
}

class Reviews {
  String? status;
  String? reviewedAt;
  Reviewer? reviewer;

  Reviews({this.status, this.reviewedAt, this.reviewer});

  Reviews.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    reviewedAt = json['reviewed_at'];
    reviewer = json['reviewer'] != null
        ? new Reviewer.fromJson(json['reviewer'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['reviewed_at'] = this.reviewedAt;
    if (this.reviewer != null) {
      data['reviewer'] = this.reviewer!.toJson();
    }
    return data;
  }
}

class Reviewer {
  String? uuid;
  String? fullName;
  String? positionTh;

  Reviewer({this.uuid, this.fullName, this.positionTh});

  Reviewer.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    fullName = json['full_name'];
    positionTh = json['position_th'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uuid'] = this.uuid;
    data['full_name'] = this.fullName;
    data['position_th'] = this.positionTh;
    return data;
  }
}

class ApproveDocuments {
  int? id;
  int? moduleId;
  String? nameTh;
  String? code;
  int? required;
  ApproveAttachment? approveAttachment;
  List<ApproveAttachments>? approveAttachments;

  ApproveDocuments(
      {this.id,
      this.moduleId,
      this.nameTh,
      this.code,
      this.required,
      this.approveAttachment,
      this.approveAttachments});

  ApproveDocuments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    moduleId = json['module_id'];
    nameTh = json['name_th'];
    code = json['code'];
    required = json['required'];
    approveAttachment = json['approve_attachment'] != null
        ? new ApproveAttachment.fromJson(json['approve_attachment'])
        : null;
    if (json['approve_attachments'] != null) {
      approveAttachments = <ApproveAttachments>[];
      json['approve_attachments'].forEach((v) {
        approveAttachments!.add(new ApproveAttachments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['module_id'] = this.moduleId;
    data['name_th'] = this.nameTh;
    data['code'] = this.code;
    data['required'] = this.required;
    if (this.approveAttachment != null) {
      data['approve_attachment'] = this.approveAttachment!.toJson();
    }
    if (this.approveAttachments != null) {
      data['approve_attachments'] =
          this.approveAttachments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ApproveAttachment {
  String? uuid;
  String? fileName;
  String? fileType;
  int? version;
  String? createdAt;

  ApproveAttachment(
      {this.uuid, this.fileName, this.fileType, this.version, this.createdAt});

  ApproveAttachment.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    fileName = json['file_name'];
    fileType = json['file_type'];
    version = json['version'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uuid'] = this.uuid;
    data['file_name'] = this.fileName;
    data['file_type'] = this.fileType;
    data['version'] = this.version;
    data['created_at'] = this.createdAt;
    return data;
  }
}

class ApproveAttachments {
  String? uuid;
  String? caption;
  String? captionVersion;
  String? captionDatetime;
  String? fileName;
  String? fileType;
  int? version;
  String? createdAt;

  ApproveAttachments(
      {this.uuid,
      this.caption,
      this.captionVersion,
      this.captionDatetime,
      this.fileName,
      this.fileType,
      this.version,
      this.createdAt});

  ApproveAttachments.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    caption = json['caption'];
    captionVersion = json['caption_version'];
    captionDatetime = json['caption_datetime'];
    fileName = json['file_name'];
    fileType = json['file_type'];
    version = json['version'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uuid'] = this.uuid;
    data['caption'] = this.caption;
    data['caption_version'] = this.captionVersion;
    data['caption_datetime'] = this.captionDatetime;
    data['file_name'] = this.fileName;
    data['file_type'] = this.fileType;
    data['version'] = this.version;
    data['created_at'] = this.createdAt;
    return data;
  }
}
