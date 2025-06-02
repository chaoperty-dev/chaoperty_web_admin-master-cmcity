import 'dart:convert';

class ClientModel {
  dynamic ser;
  dynamic uuid;
  dynamic user;
  dynamic rser;
  dynamic datex;
  dynamic timex;
  dynamic custno;
  dynamic taxno;
  dynamic scname;
  dynamic sname;
  dynamic stype;
  dynamic typeser;
  dynamic type;
  dynamic cname;
  dynamic branch;
  dynamic attn;
  dynamic addr_1;
  dynamic addr_2;
  dynamic zip;
  dynamic tel;
  dynamic tax;
  dynamic fax;
  dynamic email;
  dynamic lineid;
  dynamic lastday;
  dynamic status;
  dynamic st;
  dynamic user_name;
  dynamic passw;
  dynamic data_update;

  /// ✅ ใช้ Map เพื่อความปลอดภัยในการเข้าถึง field
  Map<String, dynamic>? json;

  ClientModel({
    this.ser,
    this.uuid,
    this.user,
    this.rser,
    this.datex,
    this.timex,
    this.custno,
    this.taxno,
    this.scname,
    this.sname,
    this.stype,
    this.typeser,
    this.type,
    this.cname,
    this.branch,
    this.attn,
    this.addr_1,
    this.addr_2,
    this.zip,
    this.tel,
    this.tax,
    this.fax,
    this.email,
    this.lineid,
    this.lastday,
    this.status,
    this.st,
    this.user_name,
    this.passw,
    this.data_update,
    this.json,
  });

  factory ClientModel.fromJson(Map<String, dynamic> map) {
    // 👉 ตรวจสอบว่า json เป็น String แล้วแปลงเป็น Map
    Map<String, dynamic>? parsedJson;
    final rawJson = map['json'];
    if (rawJson is String) {
      try {
        parsedJson = jsonDecode(rawJson);
      } catch (_) {
        parsedJson = null;
      }
    } else if (rawJson is Map<String, dynamic>) {
      parsedJson = rawJson;
    }

    return ClientModel(
      ser: map['ser'],
      uuid: map['uuid'],
      user: map['user'],
      rser: map['rser'],
      datex: map['datex'],
      timex: map['timex'],
      custno: map['custno'],
      taxno: map['taxno'],
      scname: map['scname'],
      sname: map['sname'],
      stype: map['stype'],
      typeser: map['typeser'],
      type: map['type'],
      cname: map['cname'],
      branch: map['branch'],
      attn: map['attn'],
      addr_1: map['addr_1'],
      addr_2: map['addr_2'],
      zip: map['zip'],
      tel: map['tel'],
      tax: map['tax'],
      fax: map['fax'],
      email: map['email'],
      lineid: map['lineid'],
      lastday: map['lastday'],
      status: map['status'],
      st: map['st'],
      user_name: map['user_name'],
      passw: map['passw'],
      data_update: map['data_update'],
      json: parsedJson,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['ser'] = ser;
    data['uuid'] = uuid;
    data['user'] = user;
    data['rser'] = rser;
    data['datex'] = datex;
    data['timex'] = timex;
    data['custno'] = custno;
    data['taxno'] = taxno;
    data['scname'] = scname;
    data['sname'] = sname;
    data['stype'] = stype;
    data['typeser'] = typeser;
    data['type'] = type;
    data['cname'] = cname;
    data['branch'] = branch;
    data['attn'] = attn;
    data['addr_1'] = addr_1;
    data['addr_2'] = addr_2;
    data['zip'] = zip;
    data['tel'] = tel;
    data['tax'] = tax;
    data['fax'] = fax;
    data['email'] = email;
    data['lineid'] = lineid;
    data['lastday'] = lastday;
    data['status'] = status;
    data['st'] = st;
    data['user_name'] = user_name;
    data['passw'] = passw;
    data['data_update'] = data_update;
    data['json'] = json;
    return data;
  }
}

//////////////---------------------->
class DocumentModel {
  dynamic id;
  dynamic uuid;
  dynamic code;
  dynamic nameTh;
  dynamic required;
  dynamic description;
  dynamic active;
  dynamic createdAt;
  dynamic updatedAt;
  List<AttachmentsModel>? attachments;

  DocumentModel({
    this.id,
    this.uuid,
    this.code,
    this.nameTh,
    this.required,
    this.description,
    this.active,
    this.createdAt,
    this.updatedAt,
    List<AttachmentsModel>? attachments,
  }) : attachments = attachments ?? [];

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'],
      uuid: json['uuid'],
      code: json['code'],
      nameTh: json['name_th'],
      required: json['required'],
      description: json['description'],
      active: json['active'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      attachments: json['attachments'] != null
          ? List<AttachmentsModel>.from(
              json['attachments'].map((x) => AttachmentsModel.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'code': code,
      'name_th': nameTh,
      'required': required,
      'description': description,
      'active': active,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'attachments': attachments?.map((x) => x.toJson()).toList(),
    };
  }
}

///------------------------->
class AttachmentsModel {
  dynamic id;
  dynamic uuid;
  dynamic requestUuid;
  dynamic filePath;
  dynamic fileName;
  dynamic fileType;
  dynamic clientDocumentId;
  dynamic active;
  dynamic status_label;
  ClientDocument? clientDocument;
  dynamic reviewAt;
  dynamic createdAt;
  dynamic uploadedAt;

  AttachmentsModel(
      {this.id,
      this.uuid,
      this.requestUuid,
      this.filePath,
      this.fileName,
      this.fileType,
      this.clientDocumentId,
      this.active,
      this.status_label,
      this.clientDocument,
      this.reviewAt,
      this.createdAt,
      this.uploadedAt});

  AttachmentsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    requestUuid = json['request_uuid'];
    filePath = json['file_path'];
    fileName = json['file_name'];
    fileType = json['file_type'];
    clientDocumentId = json['client_document_id'];
    active = json['active'];
    status_label = json['status_label'];
    clientDocument = json['client_document'] != null
        ? new ClientDocument.fromJson(json['client_document'])
        : null;
    reviewAt = json['review_at'];
    createdAt = json['created_at'];
    uploadedAt = json['uploaded_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uuid'] = this.uuid;
    data['request_uuid'] = this.requestUuid;
    data['file_path'] = this.filePath;
    data['file_name'] = this.fileName;
    data['file_type'] = this.fileType;
    data['client_document_id'] = this.clientDocumentId;
    data['active'] = this.active;
    data['status_label'] = this.status_label;
    if (this.clientDocument != null) {
      data['client_document'] = this.clientDocument!.toJson();
    }
    data['review_at'] = this.reviewAt;
    data['created_at'] = this.createdAt;
    data['uploaded_at'] = this.uploadedAt;
    return data;
  }
}

class ClientDocument {
  dynamic id;
  dynamic uuid;
  dynamic code;
  dynamic nameTh;
  bool? required;
  dynamic description;
  bool? active;
  dynamic createdAt;

  ClientDocument(
      {this.id,
      this.uuid,
      this.code,
      this.nameTh,
      this.required,
      this.description,
      this.active,
      this.createdAt});

  ClientDocument.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    code = json['code'];
    nameTh = json['name_th'];
    required = json['required'];
    description = json['description'];
    active = json['active'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uuid'] = this.uuid;
    data['code'] = this.code;
    data['name_th'] = this.nameTh;
    data['required'] = this.required;
    data['description'] = this.description;
    data['active'] = this.active;
    data['created_at'] = this.createdAt;
    return data;
  }
}

//////////////---------------------->
class DetailsModel {
  int? id;
  String? uuid;
  String? requestUuid;
  int? propertyId;
  int? leaseTermMonths;
  String? desiredStartDate;
  int? subzoneser;
  int? zser;
  String? zn;
  int? aser;
  String? ln;
  String? sdate;
  String? ldate;
  int? sertype;
  String? type;
  int? qty;
  String? comment;
  String? createdAt;
  String? updatedAt;

  DetailsModel(
      {this.id,
      this.uuid,
      this.requestUuid,
      this.propertyId,
      this.leaseTermMonths,
      this.desiredStartDate,
      this.subzoneser,
      this.zser,
      this.zn,
      this.aser,
      this.ln,
      this.sdate,
      this.ldate,
      this.sertype,
      this.type,
      this.qty,
      this.comment,
      this.createdAt,
      this.updatedAt});

  DetailsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    requestUuid = json['request_uuid'];
    propertyId = json['property_id'];
    leaseTermMonths = json['lease_term_months'];
    desiredStartDate = json['desired_start_date'];
    subzoneser = json['subzoneser'];
    zser = json['zser'];
    zn = json['zn'];
    aser = json['aser'];
    ln = json['ln'];
    sdate = json['sdate'];
    ldate = json['ldate'];
    sertype = json['sertype'];
    type = json['type'];
    qty = json['qty'];
    comment = json['comment'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uuid'] = this.uuid;
    data['request_uuid'] = this.requestUuid;
    data['property_id'] = this.propertyId;
    data['lease_term_months'] = this.leaseTermMonths;
    data['desired_start_date'] = this.desiredStartDate;
    data['subzoneser'] = this.subzoneser;
    data['zser'] = this.zser;
    data['zn'] = this.zn;
    data['aser'] = this.aser;
    data['ln'] = this.ln;
    data['sdate'] = this.sdate;
    data['ldate'] = this.ldate;
    data['sertype'] = this.sertype;
    data['type'] = this.type;
    data['qty'] = this.qty;
    data['comment'] = this.comment;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
