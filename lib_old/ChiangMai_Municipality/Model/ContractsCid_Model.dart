import 'ReviewUuid_Model.dart';

// class ContractsCidModel {
//   int? id;
//   String? uuid;
//   String? status;

//   List<ContractDocuments>? contractDocuments;
//   List<ContractAttachments>? contractAttachments;
//   List<ReceiptDocuments>? receiptDocuments;
//   List<CheckupDocuments>? checkupDocuments;
//   List<ApproveDocuments>? approveDocuments;

//   ContractsCidModel({
//     this.id,
//     this.uuid,
//     this.status,
//     this.contractDocuments,
//     this.contractAttachments,
//     this.receiptDocuments,
//     this.checkupDocuments,
//     this.approveDocuments,
//   });

//   ContractsCidModel.fromJson(Map<String, dynamic> json) {
//     id = json['id'] as int?;
//     uuid = json['uuid'] as String?;
//     status = json['status'] as String?;

//     // NOTE: ปรับเป็น snake_case ให้สอดคล้องกับคีย์อื่น ๆ
//     if (json['contract_documents'] != null) {
//       contractDocuments = (json['contract_documents'] as List)
//           .map((v) => ContractDocuments.fromJson(v as Map<String, dynamic>))
//           .toList();
//     }

//     if (json['contract_attachments'] != null) {
//       contractAttachments = (json['contract_attachments'] as List)
//           .map((v) => ContractAttachments.fromJson(v as Map<String, dynamic>))
//           .toList();
//     }

//     if (json['receipt_documents'] != null) {
//       receiptDocuments = (json['receipt_documents'] as List)
//           .map((v) => ReceiptDocuments.fromJson(v as Map<String, dynamic>))
//           .toList();
//     }

//     if (json['checkup_documents'] != null) {
//       checkupDocuments = (json['checkup_documents'] as List)
//           .map((v) => CheckupDocuments.fromJson(v as Map<String, dynamic>))
//           .toList();
//     }

//     if (json['approve_documents'] != null) {
//       approveDocuments = (json['approve_documents'] as List)
//           .map((v) => ApproveDocuments.fromJson(v as Map<String, dynamic>))
//           .toList();
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final data = <String, dynamic>{
//       'id': id,
//       'uuid': uuid,
//       'status': status,
//       if (contractDocuments != null)
//         'contract_documents':
//             contractDocuments!.map((v) => v.toJson()).toList(),
//       if (contractAttachments != null)
//         'contract_attachments':
//             contractAttachments!.map((v) => v.toJson()).toList(),
//       if (receiptDocuments != null)
//         'receipt_documents': receiptDocuments!.map((v) => v.toJson()).toList(),
//       if (checkupDocuments != null)
//         'checkup_documents': checkupDocuments!.map((v) => v.toJson()).toList(),
//       if (approveDocuments != null)
//         'approve_documents': approveDocuments!.map((v) => v.toJson()).toList(),
//     };
//     return data;
//   }
// }
class ContractsCidModel {
  int? id;
  String? uuid;
  String? status;

  ClientsModel? clients;

  List<ContractDocuments>? contractDocuments;
  List<ContractAttachments>? contractAttachments;
  List<ReceiptDocuments>? receiptDocuments;
  List<CheckupDocuments>? checkupDocuments;
  List<ApproveDocuments>? approveDocuments;

  ContractsCidModel({
    this.id,
    this.uuid,
    this.status,
    this.clients,
    this.contractDocuments,
    this.contractAttachments,
    this.receiptDocuments,
    this.checkupDocuments,
    this.approveDocuments,
  });

  /// ✅ ใช้กับ response ที่มี {message, data}
  factory ContractsCidModel.fromResponse(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    return ContractsCidModel.fromJson(data);
  }

  ContractsCidModel.fromJson(Map<String, dynamic> json) {
    id = _asInt(json['id']);
    uuid = json['uuid']?.toString();
    status = json['status']?.toString();

    // ✅ clients
    final c = json['clients'];
    if (c is Map<String, dynamic>) {
      clients = ClientsModel.fromJson(c);
    }

    // ✅ รองรับทั้ง camelCase / snake_case
    contractDocuments = _list(json, 'contractDocuments', 'contract_documents')
        ?.map((v) => ContractDocuments.fromJson(v))
        .toList();

    contractAttachments =
        _list(json, 'contractAttachments', 'contract_attachments')
            ?.map((v) => ContractAttachments.fromJson(v))
            .toList();

    receiptDocuments = _list(json, 'receiptDocuments', 'receipt_documents')
        ?.map((v) => ReceiptDocuments.fromJson(v))
        .toList();

    checkupDocuments = _list(json, 'checkupDocuments', 'checkup_documents')
        ?.map((v) => CheckupDocuments.fromJson(v))
        .toList();

    approveDocuments = _list(json, 'approveDocuments', 'approve_documents')
        ?.map((v) => ApproveDocuments.fromJson(v))
        .toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'status': status,
        'clients': clients?.toJson(),
        'contractDocuments': contractDocuments?.map((e) => e.toJson()).toList(),
        'contract_attachments':
            contractAttachments?.map((e) => e.toJson()).toList(),
        'receipt_documents': receiptDocuments?.map((e) => e.toJson()).toList(),
        'checkup_documents': checkupDocuments?.map((e) => e.toJson()).toList(),
        'approve_documents': approveDocuments?.map((e) => e.toJson()).toList(),
      };

  // ---------- helpers ----------
  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static List<Map<String, dynamic>>? _list(
    Map<String, dynamic> json,
    String key1,
    String key2,
  ) {
    final raw = json[key1] ?? json[key2];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return null;
  }
}

// ---------- ContractAddressJson ----------
class AddressJsonModel {
  final String? number;
  final String? moo;
  final String? soi;
  final String? road;
  final String? tambon;
  final String? amphoe;
  final String? province;
  final String? raw;

  const AddressJsonModel({
    this.number,
    this.moo,
    this.soi,
    this.road,
    this.tambon,
    this.amphoe,
    this.province,
    this.raw,
  });

  factory AddressJsonModel.fromJson(Map<String, dynamic> json) {
    return AddressJsonModel(
      number: json['number']?.toString(),
      moo: json['moo']?.toString(),
      soi: json['soi']?.toString(),
      road: json['road']?.toString(),
      tambon: json['tambon']?.toString(),
      amphoe: json['amphoe']?.toString(),
      province: json['province']?.toString(),
      raw: json['raw']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'moo': moo,
        'soi': soi,
        'road': road,
        'tambon': tambon,
        'amphoe': amphoe,
        'province': province,
        'raw': raw,
      };
}

// ---------- ContractClients ----------
class ClientsModel {
  final String? uuid;
  final int? ser;
  final int? user;
  final int? rser;

  final String? datex;
  final String? timex;

  final String? custno;
  final String? taxno;

  final String? scname;
  final String? sname;
  final String? stype;
  final int? typeser;
  final String? type;

  final String? cname;
  final String? branch;
  final String? attn;

  final String? addr1;
  final String? addr2;
  final AddressJsonModel? json;

  final String? zip;
  final String? tel;
  final String? tax;
  final String? fax;
  final String? email;
  final String? lineid;

  final String? lastday;
  final String? status;
  final int? st;

  final String? national;
  final int? age;

  const ClientsModel({
    this.uuid,
    this.ser,
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
    this.addr1,
    this.addr2,
    this.json,
    this.zip,
    this.tel,
    this.tax,
    this.fax,
    this.email,
    this.lineid,
    this.lastday,
    this.status,
    this.st,
    this.national,
    this.age,
  });

  factory ClientsModel.fromJson(Map<String, dynamic> map) {
    final addrJson = map['json'];
    return ClientsModel(
      uuid: map['uuid']?.toString(),
      ser: _asInt(map['ser']),
      user: _asInt(map['user']),
      rser: _asInt(map['rser']),
      datex: map['datex']?.toString(),
      timex: map['timex']?.toString(),
      custno: map['custno']?.toString(),
      taxno: map['taxno']?.toString(),
      scname: map['scname']?.toString(),
      sname: map['sname']?.toString(),
      stype: map['stype']?.toString(),
      typeser: _asInt(map['typeser']),
      type: map['type']?.toString(),
      cname: map['cname']?.toString(),
      branch: map['branch']?.toString(),
      attn: map['attn']?.toString(),
      addr1: map['addr_1']?.toString(),
      addr2: map['addr_2']?.toString(),
      json: (addrJson is Map<String, dynamic>)
          ? AddressJsonModel.fromJson(addrJson)
          : null,
      zip: map['zip']?.toString(),
      tel: map['tel']?.toString(),
      tax: map['tax']?.toString(),
      fax: map['fax']?.toString(),
      email: map['email']?.toString(),
      lineid: map['lineid']?.toString(),
      lastday: map['lastday']?.toString(),
      status: map['status']?.toString(),
      st: _asInt(map['st']),
      national: map['national']?.toString(),
      age: _asInt(map['age']),
    );
  }

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'ser': ser,
        'user': user,
        'rser': rser,
        'datex': datex,
        'timex': timex,
        'custno': custno,
        'taxno': taxno,
        'scname': scname,
        'sname': sname,
        'stype': stype,
        'typeser': typeser,
        'type': type,
        'cname': cname,
        'branch': branch,
        'attn': attn,
        'addr_1': addr1,
        'addr_2': addr2,
        'json': json?.toJson(),
        'zip': zip,
        'tel': tel,
        'tax': tax,
        'fax': fax,
        'email': email,
        'lineid': lineid,
        'lastday': lastday,
        'status': status,
        'st': st,
        'national': national,
        'age': age,
      };

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

// ---------- ContractDocuments ----------

class ContractDocuments {
  int? id;
  String? uuid;
  String? requestUuid;
  String? runningUuid;
  int? documentTypeId; // <- เก็บเป็น int เสมอ
  String? documentNo;
  String? publishedAt;
  String? createdBy;
  String? updatedBy; // null -> toString() ได้ null-safe
  bool? active; // <- เก็บเป็น bool เสมอ
  String? createdAt;
  String? updatedAt;
  String? documentname;

  List<Attachments>? attachments;

  ContractDocuments({
    this.id,
    this.uuid,
    this.requestUuid,
    this.runningUuid,
    this.documentTypeId,
    this.documentNo,
    this.publishedAt,
    this.createdBy,
    this.updatedBy,
    this.active,
    this.createdAt,
    this.updatedAt,
    this.documentname,
    this.attachments,
  });

  // ✅ แปลงชนิดที่สลับได้อย่างปลอดภัย
  // factory ContractDocuments.fromJson(Map<String, dynamic> json) {
  //   // document_type_id: อาจเป็น int หรือ String
  //   final dtIdRaw = json['document_type_id'];
  //   int? dtId;
  //   if (dtIdRaw is int) {
  //     dtId = dtIdRaw;
  //   } else if (dtIdRaw is String) {
  //     dtId = int.tryParse(dtIdRaw);
  //   }

  //   // active: อาจเป็น bool หรือ num (0/1)
  //   final activeVal = json['active'];
  //   bool? activeParsed;
  //   if (activeVal is bool) {
  //     activeParsed = activeVal;
  //   } else if (activeVal is num) {
  //     activeParsed = activeVal != 0;
  //   }

  //   // attachments: อาจไม่มี หรือว่าง
  //   List<Attachments>? atts;
  //   final attsRaw = json['attachments'];
  //   if (attsRaw is List) {
  //     atts = attsRaw
  //         .whereType<Map<String, dynamic>>()
  //         .map((e) => Attachments.fromJson(e))
  //         .toList();
  //   }

  //   return ContractDocuments(
  //     id: json['id'] as int?,
  //     uuid: json['uuid'] as String?,
  //     requestUuid: json['request_uuid'] as String?,
  //     runningUuid: json['running_uuid'] as String?,
  //     documentTypeId: dtId,
  //     documentNo: json['document_no'] as String?,
  //     publishedAt: json['published_at'] as String?,
  //     createdBy: json['created_by'] as String?,
  //     updatedBy: json['updated_by']?.toString(),
  //     active: activeParsed,
  //     createdAt: json['created_at'] as String?,
  //     updatedAt: json['updated_at'] as String?,
  //     documentname: json['document_name'] as String?,
  //     attachments: atts,
  //   );
  // }
  factory ContractDocuments.fromJson(Map<String, dynamic> json) {
    // document_type_id: อาจเป็น int หรือ String
    final dtIdRaw = json['document_type_id'];
    int? dtId;
    if (dtIdRaw is int) {
      dtId = dtIdRaw;
    } else if (dtIdRaw is String) {
      dtId = int.tryParse(dtIdRaw);
    }

    // active: อาจเป็น bool หรือ num (0/1)
    final activeVal = json['active'];
    bool? activeParsed;
    if (activeVal is bool) {
      activeParsed = activeVal;
    } else if (activeVal is num) {
      activeParsed = activeVal != 0;
    }

    // ✅ attachments: รองรับทั้ง attachment (object เดียว) และ attachments (list)
    List<Attachments>? atts;
    if (json['attachments'] is List) {
      atts = (json['attachments'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => Attachments.fromJson(e))
          .toList();
    } else if (json['attachment'] is Map<String, dynamic>) {
      atts = [Attachments.fromJson(json['attachment'])];
    }

    return ContractDocuments(
      id: json['id'] as int?,
      uuid: json['uuid'] as String?,
      requestUuid: json['request_uuid'] as String?,
      runningUuid: json['running_uuid'] as String?,
      documentTypeId: dtId,
      documentNo: json['document_no'] as String?,
      publishedAt: json['published_at'] as String?,
      createdBy: json['created_by'] as String?,
      updatedBy: json['updated_by']?.toString(),
      active: activeParsed,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      documentname: json['document_name'] as String?,
      attachments: atts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'request_uuid': requestUuid,
      'running_uuid': runningUuid,
      'document_type_id': documentTypeId,
      'document_no': documentNo,
      'published_at': publishedAt,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'active': active,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'document_name': documentname,
      if (attachments != null)
        'attachments': attachments!.map((v) => v.toJson()).toList(),
    };
  }

  // ✅ helper: แปลงทั้ง list
  static List<ContractDocuments> listFromJson(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map((e) => ContractDocuments.fromJson(e))
          .toList();
    }
    return const [];
  }
}

// ---------- Attachments (ของ ContractDocuments) ----------

class Attachments {
  int? id;
  String? uuid;
  String? requestUuid;
  String? documentUuid;
  int? documentTypeId;
  String? fileName;
  String? filePath;
  String? fileType;
  int? fileSize;
  String? description;
  bool? active;
  String? createdAt;
  String? updatedAt;

  Attachments({
    this.id,
    this.uuid,
    this.requestUuid,
    this.documentUuid,
    this.documentTypeId,
    this.fileName,
    this.filePath,
    this.fileType,
    this.fileSize,
    this.description,
    this.active,
    this.createdAt,
    this.updatedAt,
  });

  factory Attachments.fromJson(Map<String, dynamic> json) {
    // document_type_id: อาจเป็น int หรือ String
    final dtIdRaw = json['document_type_id'];
    int? dtId;
    if (dtIdRaw is int) {
      dtId = dtIdRaw;
    } else if (dtIdRaw is String) {
      dtId = int.tryParse(dtIdRaw);
    }

    // active: อาจเป็น 0/1 หรือ bool
    final activeVal = json['active'];
    bool? activeParsed;
    if (activeVal is bool) {
      activeParsed = activeVal;
    } else if (activeVal is num) {
      activeParsed = activeVal != 0;
    }

    return Attachments(
      id: json['id'] as int?,
      uuid: json['uuid'] as String?,
      requestUuid: json['request_uuid'] as String?,
      documentUuid: json['document_uuid'] as String?,
      documentTypeId: dtId,
      fileName: json['file_name'] as String?,
      filePath: json['file_path'] as String?,
      fileType: json['file_type'] as String?,
      fileSize: (json['file_size'] is int)
          ? json['file_size'] as int
          : int.tryParse('${json['file_size']}'),
      description: json['description'] as String?,
      active: activeParsed,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'request_uuid': requestUuid,
      'document_uuid': documentUuid,
      'document_type_id': documentTypeId,
      'file_name': fileName,
      'file_path': filePath,
      'file_type': fileType,
      'file_size': fileSize,
      'description': description,
      'active': active,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// ---------- ContractAttachments (document + attachment ย่อ) ----------

class ContractAttachments {
  Document? document;
  Attachment? attachment;

  ContractAttachments({this.document, this.attachment});

  ContractAttachments.fromJson(Map<String, dynamic> json) {
    document = json['document'] != null
        ? Document.fromJson(json['document'] as Map<String, dynamic>)
        : null;
    attachment = json['attachment'] != null
        ? Attachment.fromJson(json['attachment'] as Map<String, dynamic>)
        : null;
  }

  Map<String, dynamic> toJson() {
    return {
      if (document != null) 'document': document!.toJson(),
      if (attachment != null) 'attachment': attachment!.toJson(),
    };
  }
}

// ---------- Document (เมทาดาต้าเอกสาร) ----------

class Document {
  int? id;
  String? code;
  String? nameTh;
  int? required;
  int? showAfterSubmit;
  String? docId; // เดิมเป็น Null? ปรับเป็น String? (หรือ dynamic)

  Document({
    this.id,
    this.code,
    this.nameTh,
    this.required,
    this.showAfterSubmit,
    this.docId,
  });

  Document.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    code = json['code'] as String?;
    nameTh = json['name_th'] as String?;
    required = json['required'] as int?;
    showAfterSubmit = json['show_after_submit'] as int?;
    docId = json['docId']?.toString(); // รองรับทั้ง int/string
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name_th': nameTh,
      'required': required,
      'show_after_submit': showAfterSubmit,
      'docId': docId,
    };
  }
}

// ---------- Attachment (ของ ContractAttachments/CheckupDocuments) ----------

class Attachment {
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
  bool? active;
  String? uploadedAt;
  String? reviewedBy;
  String? reviewer;
  String? reviewedAt;

  Attachment({
    this.id,
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
    this.reviewedAt,
  });

  Attachment.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    uuid = json['uuid'] as String?;
    requestUuid = json['request_uuid'] as String?;
    clientDocumentId = json['client_document_id'] as int?;
    fileName = json['file_name'] as String?;
    filePath = json['file_path'] as String?;
    fileType = json['file_type'] as String?;
    fileSize = (json['file_size'] is int)
        ? json['file_size'] as int
        : (json['file_size'] is num)
            ? (json['file_size'] as num).toInt()
            : null;
    status = json['status'] as String?;
    statusLabel = json['status_label'] as String?;
    final activeVal = json['active'];
    if (activeVal is bool) {
      active = activeVal;
    } else if (activeVal is num) {
      active = activeVal != 0;
    } else {
      active = null;
    }
    uploadedAt = json['uploaded_at'] as String?;
    reviewedBy = json['reviewed_by']?.toString();
    reviewer = json['reviewer']?.toString();
    reviewedAt = json['reviewed_at'] as String?;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'request_uuid': requestUuid,
      'client_document_id': clientDocumentId,
      'file_name': fileName,
      'file_path': filePath,
      'file_type': fileType,
      'file_size': fileSize,
      'status': status,
      'status_label': statusLabel,
      'active': active,
      'uploaded_at': uploadedAt,
      'reviewed_by': reviewedBy,
      'reviewer': reviewer,
      'reviewed_at': reviewedAt,
    };
  }
}

// ---------- ApproveDocuments / ApproveAttachment ----------

class ApproveDocuments {
  final int? id;
  final int? moduleId;
  final String? nameTh;
  final String? code;
  final int? required; // ถ้าอยากเป็น bool ก็ map 0/1 เองภายนอกได้
  final ApproveAttachment? approveAttachment;
  final List<ApproveAttachment>? approveAttachments;

  ApproveDocuments({
    this.id,
    this.moduleId,
    this.nameTh,
    this.code,
    this.required,
    this.approveAttachment,
    this.approveAttachments,
  });

  factory ApproveDocuments.fromJson(Map<String, dynamic> json) {
    return ApproveDocuments(
      id: json['id'] as int?,
      moduleId: json['module_id'] as int?,
      nameTh: json['name_th'] as String?,
      code: json['code'] as String?,
      required: json['required'] as int?,
      approveAttachment: json['approve_attachment'] != null
          ? ApproveAttachment.fromJson(
              json['approve_attachment'] as Map<String, dynamic>,
            )
          : null,
      approveAttachments: (json['approve_attachments'] as List?)
          ?.map((e) => ApproveAttachment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'module_id': moduleId,
      'name_th': nameTh,
      'code': code,
      'required': required,
      if (approveAttachment != null)
        'approve_attachment': approveAttachment!.toJson(),
      if (approveAttachments != null)
        'approve_attachments':
            approveAttachments!.map((e) => e.toJson()).toList(),
    };
  }
}

class ApproveAttachment {
  String? uuid;
  String? fileName;
  String? fileType;
  int? version;
  String? createdAt;
  String? caption;

  ApproveAttachment({
    this.uuid,
    this.fileName,
    this.fileType,
    this.version,
    this.createdAt,
    this.caption,
  });

  factory ApproveAttachment.fromJson(Map<String, dynamic> json) {
    return ApproveAttachment(
      uuid: json['uuid'] as String?,
      fileName: json['file_name'] as String?,
      fileType: json['file_type'] as String?,
      version: (json['version'] is int)
          ? json['version'] as int
          : (json['version'] is num)
              ? (json['version'] as num).toInt()
              : null,
      createdAt: json['created_at'] as String?,
      caption: json['caption'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'file_name': fileName,
      'file_type': fileType,
      'version': version,
      'created_at': createdAt,
      'caption': caption,
    };
  }
}

// ---------- CheckupDocuments ----------

class CheckupDocuments {
  Document? document;
  Attachment? attachment;

  CheckupDocuments({this.document, this.attachment});

  CheckupDocuments.fromJson(Map<String, dynamic> json) {
    document = json['document'] != null
        ? Document.fromJson(json['document'] as Map<String, dynamic>)
        : null;
    attachment = json['attachment'] != null
        ? Attachment.fromJson(json['attachment'] as Map<String, dynamic>)
        : null;
  }

  Map<String, dynamic> toJson() {
    return {
      if (document != null) 'document': document!.toJson(),
      if (attachment != null) 'attachment': attachment!.toJson(),
    };
  }
}
