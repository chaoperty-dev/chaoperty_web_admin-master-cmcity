import 'dart:convert';

class ReviewDetail {
  final int id;
  final String uuid;
  final Module module;
  final Client client;
  final NewRequest newRequest;
  final Payment payment;
  final String status;
  // final List<Attachment> attachments;
  final List<ApprovalStep> approvalStep;
  late final List<RequiredDocument> requiredDocs;
  late final List<Submitteddocuments> submitteddocuments;
  late final List<ReceiptDocuments> receiptDocuments;
  ReviewDetail({
    required this.id,
    required this.uuid,
    required this.module,
    required this.client,
    required this.newRequest,
    required this.payment,
    required this.status,
    // required this.attachments,
    required this.approvalStep,
    required this.requiredDocs,
    required this.submitteddocuments,
    required this.receiptDocuments,
  });

  factory ReviewDetail.fromJson(Map<String, dynamic> json) {
    return ReviewDetail(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      module: json['module'] != null
          ? Module.fromJson(json['module'])
          : Module.empty(),
      client: json['client'] != null
          ? Client.fromJson(json['client'])
          : Client.empty(),
      newRequest: json['new_request'] != null
          ? NewRequest.fromJson(json['new_request'])
          : NewRequest.empty(),
      payment: json['payment'] != null
          ? Payment.fromJson(json['payment'])
          : Payment.empty(),
      status: json['status'] ?? '',
      // attachments: (json['attachments'] as List?)
      //         ?.map((e) => Attachment.fromJson(e))
      //         .toList() ??
      //     [],
      approvalStep: (json['approval_steps'] as List?)
              ?.map((e) => ApprovalStep.fromJson(e))
              .toList() ??
          [],
      requiredDocs: (json['required_documents'] as List?)
              ?.map((e) => RequiredDocument.fromJson(e))
              .toList() ??
          [],
      submitteddocuments: (json['submitted_documents'] as List?)
              ?.map((e) => Submitteddocuments.fromJson(e))
              .toList() ??
          [],
      receiptDocuments: (json['receipt_documents'] as List?)
              ?.map((e) => ReceiptDocuments.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Module {
  final int id;
  final String nameTh;

  Module({required this.id, required this.nameTh});

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'] ?? 0,
      nameTh: json['name_th'] ?? '',
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
  final int age;
  final String? national;
  final String? religion;

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
    required this.age,
    this.national,
    this.religion,
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
      age: json['age'] ?? 0,
      national: json['national'] ?? '',
      religion: json['religion'] ?? '',
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
      age: 0,
      national: '',
      religion: '',
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
  final String subzone;
  final String zn;
  final int aser;
  final String ln;
  final String sdate;
  final String ldate;
  final int sertype;
  final String type;
  final String qty;
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
    required this.subzone,
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
      uuid: json['uuid'] ?? '',
      requestUuid: json['request_uuid'] ?? '',
      leaseNumber: json['lease_number'] ?? '',
      propertyId: json['property_id'] ?? 0,
      leaseTermMonths: json['lease_term_months'] ?? 0,
      desiredStartDate: json['desired_start_date'] ?? '',
      subzoneser: json['subzoneser'] ?? 0,
      zser: json['zser'] ?? 0,
      subzone: json['subzone'] ?? '',
      zn: json['zn'] ?? '',
      aser: json['aser'] ?? 0,
      ln: json['ln'] ?? '',
      sdate: json['sdate'] ?? '',
      ldate: json['ldate'] ?? '',
      sertype: json['sertype'] ?? 0,
      type: json['type'] ?? '',
      qty: json['qty'] ?? '0',
      comment: json['comment'] ?? '',
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
      subzone: '',
      zn: '',
      aser: 0,
      ln: '',
      sdate: '',
      ldate: '',
      sertype: 0,
      type: '',
      qty: '0',
      comment: '',
    );
  }
}

class RequiredDocument {
  final Document document;
  late final Attachment? attachment; // บางรายการอาจไม่มี attachment

  RequiredDocument({
    required this.document,
    this.attachment,
  });

  factory RequiredDocument.fromJson(Map<String, dynamic> json) {
    return RequiredDocument(
      document: Document.fromJson(json['document']),
      attachment: json['attachment'] != null
          ? Attachment.fromJson(json['attachment'])
          : null,
    );
  }
}

class Submitteddocuments {
  final Document document;
  late final Attachment? attachment; // บางรายการอาจไม่มี attachment

  Submitteddocuments({
    required this.document,
    this.attachment,
  });

  factory Submitteddocuments.fromJson(Map<String, dynamic> json) {
    return Submitteddocuments(
      document: Document.fromJson(json['document']),
      attachment: json['attachment'] != null
          ? Attachment.fromJson(json['attachment'])
          : null,
    );
  }
}

class Document {
  final int id;
  final String code;
  final String nameTh;
  final int required;

  Document({
    required this.id,
    required this.code,
    required this.nameTh,
    required this.required,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      nameTh: json['name_th'] ?? '',
      required: json['required'] ?? 0,
    );
  }
}

class Attachment {
  final int id;
  final String uuid;
  final String requestUuid;
  final int clientDocumentId;
  late final String fileName;
  final String filePath;
  final String fileType;
  final int fileSize;
  final String status;
  final String statusLabel;
  final int active;
  final String uploadedAt;
  final String reviewedAt;

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
    required this.reviewedAt,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      requestUuid: json['request_uuid'] ?? '',
      clientDocumentId: json['client_document_id'] ?? 0,
      fileName: json['file_name'] ?? '',
      filePath: json['file_path'] ?? '',
      fileType: json['file_type'] ?? '',
      fileSize: json['file_size'] ?? 0,
      status: json['status'] ?? '',
      statusLabel: json['status_label'] ?? '',
      active: json['active'] ?? 1,
      uploadedAt: json['uploaded_at'] ?? '',
      reviewedAt: json['reviewed_at'] ?? '',
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
      reviewedAt: '',
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
      uuid: json['uuid'] ?? '',
      flowName: json['flow_name'] ?? '',
      stepOrder: json['step_order'] ?? 0,
      stepRole: json['step_role'] ?? 0,
      stepMinLevel: json['step_min_level'] ?? 0,
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
      uuid: json['uuid'] ?? '',
      requestUuid: json['request_uuid'] ?? '',
      status: json['status'] ?? '',
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

class receiptdocuments {
  List<ReceiptDocuments>? receiptDocuments;

  receiptdocuments({this.receiptDocuments});

  receiptdocuments.fromJson(Map<String, dynamic> json) {
    if (json['receipt_documents'] != null) {
      receiptDocuments = <ReceiptDocuments>[];
      json['receipt_documents'].forEach((v) {
        receiptDocuments!.add(new ReceiptDocuments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.receiptDocuments != null) {
      data['receipt_documents'] =
          this.receiptDocuments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ReceiptDocuments {
  DocumentReceipt? document;
  AttachmentReceipt? attachment;

  ReceiptDocuments({this.document, this.attachment});

  ReceiptDocuments.fromJson(Map<String, dynamic> json) {
    document = json['document'] != null
        ? new DocumentReceipt.fromJson(json['document'])
        : null;
    attachment = json['attachment'] != null
        ? new AttachmentReceipt.fromJson(json['attachment'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.document != null) {
      data['document'] = this.document!.toJson();
    }
    if (this.attachment != null) {
      data['attachment'] = this.attachment!.toJson();
    }
    return data;
  }
}

class DocumentReceipt {
  int? id;
  String? code;
  String? nameTh;
  int? required;
  int? showAfterSubmit;
  int? docId;

  DocumentReceipt(
      {this.id,
      this.code,
      this.nameTh,
      this.required,
      this.showAfterSubmit,
      this.docId});

  DocumentReceipt.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    nameTh = json['name_th'];
    required = json['required'];
    showAfterSubmit = json['show_after_submit'];
    docId = json['docId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['name_th'] = this.nameTh;
    data['required'] = this.required;
    data['show_after_submit'] = this.showAfterSubmit;
    data['docId'] = this.docId;
    return data;
  }
}

class AttachmentReceipt {
  int? id;
  String? uuid;
  String? requestUuid;
  int? clientDocumentId;
  String? fileName;
  String? filePath;
  String? fileType;
  int? fileSize;
  String? status;
  String? statusLabel;
  int? active;
  String? uploadedAt;
  Null? reviewedBy;
  Null? reviewer;
  Null? reviewedAt;

  AttachmentReceipt(
      {this.id,
      this.uuid,
      this.requestUuid,
      this.clientDocumentId,
      this.fileName,
      this.filePath,
      this.fileType,
      this.fileSize,
      this.status,
      this.statusLabel,
      this.active,
      this.uploadedAt,
      this.reviewedBy,
      this.reviewer,
      this.reviewedAt});

  AttachmentReceipt.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    requestUuid = json['request_uuid'];
    clientDocumentId = json['client_document_id'];
    fileName = json['file_name'];
    filePath = json['file_path'];
    fileType = json['file_type'];
    fileSize = json['file_size'];
    status = json['status'];
    statusLabel = json['status_label'];
    active = json['active'];
    uploadedAt = json['uploaded_at'];
    reviewedBy = json['reviewed_by'];
    reviewer = json['reviewer'];
    reviewedAt = json['reviewed_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uuid'] = this.uuid;
    data['request_uuid'] = this.requestUuid;
    data['client_document_id'] = this.clientDocumentId;
    data['file_name'] = this.fileName;
    data['file_path'] = this.filePath;
    data['file_type'] = this.fileType;
    data['file_size'] = this.fileSize;
    data['status'] = this.status;
    data['status_label'] = this.statusLabel;
    data['active'] = this.active;
    data['uploaded_at'] = this.uploadedAt;
    data['reviewed_by'] = this.reviewedBy;
    data['reviewer'] = this.reviewer;
    data['reviewed_at'] = this.reviewedAt;
    return data;
  }
}

// class payments {
//   Payment? payment;

//   payments({this.payment});

//   payments.fromJson(Map<String, dynamic> json) {
//     payment =
//         json['payment'] != null ? new Payment.fromJson(json['payment']) : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.payment != null) {
//       data['payment'] = this.payment!.toJson();
//     }
//     return data;
//   }

//   /// ✅ เมธอดสำหรับ fallback default
//   static NewRequest empty() {
//     return NewRequest(
//       uuid: '',
//       requestUuid: '',
//       leaseNumber: '',
//       propertyId: 0,
//       leaseTermMonths: 0,
//       desiredStartDate: '',
//       subzoneser: 0,
//       zser: 0,
//       zn: '',
//       aser: 0,
//       ln: '',
//       sdate: '',
//       ldate: '',
//       sertype: 0,
//       type: '',
//       qty: 0,
//       comment: '',
//     );
//   }
// }

class Payment {
  String? uuid;
  String? requestUuid;
  int? paymentMethodId;
  int? bankAccountId;
  String? amount;
  String? amountReceived;
  String? changeAmount;
  String? paidAt;
  String? slipPdate;
  String? slipDate;
  String? slipTime;
  String? referenceCode;
  String? reference1;
  String? reference2;
  String? status;
  String? json;
  String? createdAt;
  PayAttachment? payAttachment;

  Payment({
    this.uuid,
    this.requestUuid,
    this.paymentMethodId,
    this.bankAccountId,
    this.amount,
    this.amountReceived,
    this.changeAmount,
    this.paidAt,
    this.slipPdate,
    this.slipDate,
    this.slipTime,
    this.referenceCode,
    this.reference1,
    this.reference2,
    this.status,
    this.json,
    this.createdAt,
    this.payAttachment,
  });

  Payment.fromJson(Map<String, dynamic> map) {
    uuid = map['uuid'];
    requestUuid = map['request_uuid'];
    paymentMethodId = map['payment_method_id'];
    bankAccountId = map['bank_account_id'];
    amount = map['amount'];
    amountReceived = map['amount_received'];
    changeAmount = map['change_amount'];
    paidAt = map['paid_at'];
    slipPdate = map['slip_pdate'];
    slipDate = map['slip_date'];
    slipTime = map['slip_time'];
    referenceCode = map['reference_code'];
    reference1 = map['reference1'];
    reference2 = map['reference2'];
    status = map['status'];
    json = map['json']; // ✅ fixed bug
    createdAt = map['created_at'];
    payAttachment = map['payAttachment'] != null
        ? PayAttachment.fromJson(map['payAttachment'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['uuid'] = uuid;
    data['request_uuid'] = requestUuid;
    data['payment_method_id'] = paymentMethodId;
    data['bank_account_id'] = bankAccountId;
    data['amount'] = amount;
    data['amount_received'] = amountReceived;
    data['change_amount'] = changeAmount;
    data['paid_at'] = paidAt;
    data['slip_pdate'] = slipPdate;
    data['slip_date'] = slipDate;
    data['slip_time'] = slipTime;
    data['reference_code'] = referenceCode;
    data['reference1'] = reference1;
    data['reference2'] = reference2;
    data['status'] = status;
    data['json'] = json;
    data['created_at'] = createdAt;
    if (payAttachment != null) {
      data['payAttachment'] = payAttachment!.toJson();
    }
    return data;
  }

  /// ✅ fallback instance
  static Payment empty() {
    return Payment(
      uuid: '',
      requestUuid: '',
      paymentMethodId: 0,
      bankAccountId: 0,
      amount: '0.00',
      amountReceived: '0.00',
      changeAmount: '0.00',
      paidAt: '',
      slipPdate: '',
      slipDate: '',
      slipTime: '',
      referenceCode: '',
      reference1: '',
      reference2: '',
      status: '',
      json: '',
      createdAt: '',
      payAttachment: null,
    );
  }
}

class PayAttachment {
  String? uuid;
  String? requestUuid;
  int? clientDocumentId;
  String? fileName;
  String? fileType;
  int? fileSize;
  String? createdAt;

  PayAttachment(
      {this.uuid,
      this.requestUuid,
      this.clientDocumentId,
      this.fileName,
      this.fileType,
      this.fileSize,
      this.createdAt});

  PayAttachment.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    requestUuid = json['request_uuid'];
    clientDocumentId = json['client_document_id'];
    fileName = json['file_name'];
    fileType = json['file_type'];
    fileSize = json['file_size'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uuid'] = this.uuid;
    data['request_uuid'] = this.requestUuid;
    data['client_document_id'] = this.clientDocumentId;
    data['file_name'] = this.fileName;
    data['file_type'] = this.fileType;
    data['file_size'] = this.fileSize;
    data['created_at'] = this.createdAt;
    return data;
  }
}
