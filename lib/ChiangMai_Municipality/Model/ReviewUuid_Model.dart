import 'dart:convert';

class ReviewDetail {
  final int id;
  final String uuid;
  final Module module;
  final Client client;
  final NewRequest newRequest;
  final String status;
  final List<Attachment> attachments;
  final List<ApprovalStep> approvalStep;
  ReviewDetail({
    required this.id,
    required this.uuid,
    required this.module,
    required this.client,
    required this.newRequest,
    required this.status,
    required this.attachments,
    required this.approvalStep,
  });
  factory ReviewDetail.fromJson(Map<String, dynamic> json) {
    return ReviewDetail(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      module: json['module'] != null
          ? Module.fromJson(json['module'])
          : Module(id: 0, nameTh: ''),
      client: json['client'] != null
          ? Client.fromJson(json['client'])
          : Client.empty(),
      newRequest: json['new_request'] != null
          ? NewRequest.fromJson(json['new_request'])
          : NewRequest.empty(),
      status: json['status'] ?? '',
      attachments: (json['attachments'] as List?)
              ?.map((e) => Attachment.fromJson(e))
              .toList() ??
          [],
      approvalStep: (json['approval_steps'] as List?)
              ?.map((e) => ApprovalStep.fromJson(e))
              .toList() ??
          [],
    );
  }

  // factory ReviewDetail.fromJson(Map<String, dynamic> json) {
  //   return ReviewDetail(
  //     id: json['id'],
  //     uuid: json['uuid'],
  //     module: Module.fromJson(json['module']),
  //     client: Client.fromJson(json['client']),
  //     newRequest: NewRequest.fromJson(json['new_request']),
  //     status: json['status'],
  //     attachments: (json['attachments'] as List)
  //         .map((e) => Attachment.fromJson(e))
  //         .toList(),
  //     approvalStep: (json['approval_steps'] != null)
  //         ? (json['approval_steps'] as List)
  //             .map((e) => ApprovalStep.fromJson(e))
  //             .toList()
  //         : [],
  //   );
  // }
}

class Module {
  final int id;
  final String nameTh;

  Module({required this.id, required this.nameTh});

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'],
      nameTh: json['name_th'],
    );
  }

  /// ✅ เมธอดสำหรับ fallback default
  static Module empty() {
    return Module(
      id: 0,
      nameTh: '',
    );
  }
}

class Client {
  final String uuid;
  final int ser;
  final int user;
  final int rser;
  final String datex;
  final String timex;
  final String custno;
  final String taxno;
  final String scname;
  final String sname;
  final String stype;
  final int typeser;
  final String type;
  final String cname;
  final String branch;
  final String attn;
  final String addr1;
  final String addr2;
  final ClientJsonAddress json;
  final String zip;
  final String tel;
  final String tax;
  final String fax;
  final String email;
  final String lineid;
  final String lastday;
  final String status;
  final int st;
  final String userName;
  final String passw;
  final String? createdAt;
  final String? updatedAt;

  Client({
    required this.uuid,
    required this.ser,
    required this.user,
    required this.rser,
    required this.datex,
    required this.timex,
    required this.custno,
    required this.taxno,
    required this.scname,
    required this.sname,
    required this.stype,
    required this.typeser,
    required this.type,
    required this.cname,
    required this.branch,
    required this.attn,
    required this.addr1,
    required this.addr2,
    required this.json,
    required this.zip,
    required this.tel,
    required this.tax,
    required this.fax,
    required this.email,
    required this.lineid,
    required this.lastday,
    required this.status,
    required this.st,
    required this.userName,
    required this.passw,
    this.createdAt,
    this.updatedAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      uuid: json['uuid'] ?? '',
      ser: json['ser'] ?? 0,
      user: json['user'] ?? 0,
      rser: json['rser'] ?? 0,
      datex: json['datex'] ?? '',
      timex: json['timex'] ?? '',
      custno: json['custno'] ?? '',
      taxno: json['taxno'] ?? '',
      scname: json['scname'] ?? '',
      sname: json['sname'] ?? '',
      stype: json['stype'] ?? '',
      typeser: json['typeser'] ?? 0,
      type: json['type'] ?? '',
      cname: json['cname'] ?? '',
      branch: json['branch'] ?? '',
      attn: json['attn'] ?? '',
      addr1: json['addr_1'] ?? '',
      addr2: json['addr_2'] ?? '',
      json: json['json'] is String
          ? ClientJsonAddress.fromJson(jsonDecode(json['json']))
          : ClientJsonAddress.fromJson(json['json']),
      zip: json['zip'] ?? '',
      tel: json['tel'] ?? '',
      tax: json['tax'] ?? '',
      fax: json['fax'] ?? '',
      email: json['email'] ?? '',
      lineid: json['lineid'] ?? '',
      lastday: json['lastday'] ?? '',
      status: json['status'] ?? '',
      st: json['st'] ?? 0,
      userName: json['user_name'] ?? '',
      passw: json['passw'] ?? '',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  // ✅ เพิ่มเมธอดนี้
  static Client empty() {
    return Client(
      uuid: '',
      ser: 0,
      user: 0,
      rser: 0,
      datex: '',
      timex: '',
      custno: '',
      taxno: '',
      scname: '',
      sname: '',
      stype: '',
      typeser: 0,
      type: '',
      cname: '',
      branch: '',
      attn: '',
      addr1: '',
      addr2: '',
      json: ClientJsonAddress.empty(),
      zip: '',
      tel: '',
      tax: '',
      fax: '',
      email: '',
      lineid: '',
      lastday: '',
      status: '',
      st: 0,
      userName: '',
      passw: '',
      createdAt: null,
      updatedAt: null,
    );
  }
}

class ClientJsonAddress {
  final String number;
  final String moo;
  final String? soi;
  final String? road;
  final String tambon;
  final String amphoe;
  final String province;
  final String? raw;

  ClientJsonAddress({
    required this.number,
    required this.moo,
    this.soi,
    this.road,
    required this.tambon,
    required this.amphoe,
    required this.province,
    this.raw,
  });

  factory ClientJsonAddress.fromJson(Map<String, dynamic> json) {
    return ClientJsonAddress(
      number: json['number'] ?? '',
      moo: json['moo'] ?? '',
      soi: json['soi'],
      road: json['road'],
      tambon: json['tambon'] ?? '',
      amphoe: json['amphoe'] ?? '',
      province: json['province'] ?? '',
      raw: json['raw'],
    );
  }

  /// ✅ เพิ่มฟังก์ชันนี้เข้าไป
  static ClientJsonAddress empty() {
    return ClientJsonAddress(
      number: '',
      moo: '',
      soi: null,
      road: null,
      tambon: '',
      amphoe: '',
      province: '',
      raw: null,
    );
  }
}

class NewRequest {
  final String uuid;
  final String requestUuid;
  final String leaseNumber;
  final int propertyId;
  final int leaseTermMonths;
  final String desiredStartDate;
  final int subzoneser;
  final int zser;
  final String zn;
  final int aser;
  final String ln;
  final String sdate;
  final String ldate;
  final int sertype;
  final String type;
  final int qty;
  final String comment;

  NewRequest({
    required this.uuid,
    required this.requestUuid,
    required this.leaseNumber,
    required this.propertyId,
    required this.leaseTermMonths,
    required this.desiredStartDate,
    required this.subzoneser,
    required this.zser,
    required this.zn,
    required this.aser,
    required this.ln,
    required this.sdate,
    required this.ldate,
    required this.sertype,
    required this.type,
    required this.qty,
    required this.comment,
  });

  factory NewRequest.fromJson(Map<String, dynamic> json) {
    return NewRequest(
      uuid: json['uuid'],
      requestUuid: json['request_uuid'],
      leaseNumber: json['lease_number'],
      propertyId: json['property_id'],
      leaseTermMonths: json['lease_term_months'],
      desiredStartDate: json['desired_start_date'],
      subzoneser: json['subzoneser'],
      zser: json['zser'],
      zn: json['zn'],
      aser: json['aser'],
      ln: json['ln'],
      sdate: json['sdate'],
      ldate: json['ldate'],
      sertype: json['sertype'],
      type: json['type'],
      qty: json['qty'],
      comment: json['comment'],
    );
  }

  /// ✅ เมธอดสำหรับ fallback default
  static NewRequest empty() {
    return NewRequest(
      uuid: '',
      requestUuid: '',
      leaseNumber: '',
      propertyId: 0,
      leaseTermMonths: 0,
      desiredStartDate: '',
      subzoneser: 0,
      zser: 0,
      zn: '',
      aser: 0,
      ln: '',
      sdate: '',
      ldate: '',
      sertype: 0,
      type: '',
      qty: 0,
      comment: '',
    );
  }
}

class Attachment {
  final int id;
  final String uuid;
  final String requestUuid;
  final int clientDocumentId;
  final String fileName;
  final String filePath;
  final String fileType;
  final int fileSize;
  final String status;
  final String statusLabel;
  final int active;
  final String uploadedAt;

  Attachment({
    required this.id,
    required this.uuid,
    required this.requestUuid,
    required this.clientDocumentId,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    required this.status,
    required this.statusLabel,
    required this.active,
    required this.uploadedAt,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'],
      uuid: json['uuid'],
      requestUuid: json['request_uuid'],
      clientDocumentId: json['client_document_id'],
      fileName: json['file_name'],
      filePath: json['file_path'],
      fileType: json['file_type'],
      fileSize: json['file_size'],
      status: json['status'] ?? '',
      statusLabel: json['status_label'] ?? '',
      active: json['active'],
      uploadedAt: json['uploaded_at'] ?? '',
    );
  }

  static Attachment empty() {
    return Attachment(
      id: 0,
      uuid: '',
      requestUuid: '',
      clientDocumentId: 0,
      fileName: '',
      filePath: '',
      fileType: '',
      fileSize: 0,
      status: '',
      statusLabel: '',
      active: 1,
      uploadedAt: '',
    );
  }
}


class ApprovalStep {
  final FlowModel flow;
  final ApprovalModel? approval; // เปลี่ยนจาก required เป็น nullable

  ApprovalStep({required this.flow, this.approval});

  factory ApprovalStep.fromJson(Map<String, dynamic> json) {
    return ApprovalStep(
      flow: FlowModel.fromJson(json['flow']),
      approval: json['approval'] != null
          ? ApprovalModel.fromJson(json['approval'])
          : null,
    );
  }
}

class FlowModel {
  final String uuid;
  final String flowName;
  final int stepOrder;
  final int stepRole;
  final int stepMinLevel;

  FlowModel({
    required this.uuid,
    required this.flowName,
    required this.stepOrder,
    required this.stepRole,
    required this.stepMinLevel,
  });

  factory FlowModel.fromJson(Map<String, dynamic> json) {
    return FlowModel(
      uuid: json['uuid'],
      flowName: json['flow_name'],
      stepOrder: json['step_order'],
      stepRole: json['step_role'],
      stepMinLevel: json['step_min_level'],
    );
  }

  /// ✅ เมธอดสำหรับ fallback default
  static FlowModel empty() {
    return FlowModel(
      uuid: '',
      flowName: '',
      stepOrder: 0,
      stepRole: 0,
      stepMinLevel: 0,
    );
  }
}

class ApprovalModel {
  final String uuid;
  final String requestUuid;
  final String status;

  ApprovalModel({
    required this.uuid,
    required this.requestUuid,
    required this.status,
  });

  factory ApprovalModel.fromJson(Map<String, dynamic> json) {
    return ApprovalModel(
      uuid: json['uuid'],
      requestUuid: json['request_uuid'],
      status: json['status'],
    );
  }

  /// ✅ เมธอดสำหรับ fallback default
  static ApprovalModel empty() {
    return ApprovalModel(
      uuid: '',
      requestUuid: '',
      status: '',
    );
  }
}
