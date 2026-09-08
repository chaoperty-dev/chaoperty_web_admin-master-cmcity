// ============================================================================
// license_verify_document.dart
// ============================================================================
// DocumentModel + ClientDocument (ของตัวเองใน license_verify_page)
// ไม่ใช้ Document_Model.dart ที่อยู่ใน ChiangMai_Municipality/Model/
// ============================================================================

bool? _parseApiBool(dynamic value) {
  if (value == null) return null;
  if (value == true || value == 1) return true;
  if (value == false || value == 0) return false;
  final text = value.toString().trim().toLowerCase();
  if (text == '1' || text == 'true') return true;
  if (text == '0' || text == 'false') return false;
  return null;
}

/// เอกสารที่ต้องแนบ 1 รายการ (พร้อม attachments ที่แนบแล้ว)
class LicenseverifyDocument {
  dynamic id;
  dynamic uuid;
  dynamic code;
  dynamic nameTh;
  dynamic required;
  dynamic description;
  dynamic active;
  dynamic createdAt;
  dynamic updatedAt;
  List<LicenseverifyAttachment> attachments;

  LicenseverifyDocument({
    this.id,
    this.uuid,
    this.code,
    this.nameTh,
    this.required,
    this.description,
    this.active,
    this.createdAt,
    this.updatedAt,
    List<LicenseverifyAttachment>? attachments,
  }) : attachments = attachments ?? [];

  factory LicenseverifyDocument.fromJson(Map<String, dynamic> json) {
    // รองรับทั้ง direct document และ shape {document: {...}, attachment: {...}}
    final document = json['document'] is Map
        ? Map<String, dynamic>.from(json['document'] as Map)
        : json;

    final attachments = <LicenseverifyAttachment>[];
    final rawAttachments = json['attachments'] ?? document['attachments'];
    if (rawAttachments is List) {
      attachments.addAll(
        rawAttachments.whereType<Map>().map(
              (x) => LicenseverifyAttachment.fromJson(
                Map<String, dynamic>.from(x),
              ),
            ),
      );
    } else if (json['attachment'] is Map) {
      attachments.add(
        LicenseverifyAttachment.fromJson(
          Map<String, dynamic>.from(json['attachment'] as Map),
        ),
      );
    }

    return LicenseverifyDocument(
      id: document['id'],
      uuid: document['uuid'],
      code: document['code'],
      nameTh: document['name_th'] ?? document['nameTh'],
      required: document['required'],
      description: document['description'],
      active: document['active'],
      createdAt: document['created_at'] ?? document['createdAt'],
      updatedAt: document['updated_at'] ?? document['updatedAt'],
      attachments: attachments,
    );
  }

  /// API ส่ง required ได้ทั้ง 1 / true / "1" / "true"
  bool get isRequired {
    if (required == true || required == 1) return true;
    final value = required?.toString().trim().toLowerCase();
    return value == '1' || value == 'true';
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
      'attachments': attachments.map((x) => x.toJson()).toList(),
    };
  }
}

/// ClientDocument (ข้อมูลประเภทเอกสาร — embedded ใน attachment)
class LicenseverifyClientDocument {
  dynamic id;
  dynamic uuid;
  dynamic code;
  dynamic nameTh;
  bool? required;
  dynamic description;
  bool? active;
  dynamic createdAt;

  LicenseverifyClientDocument({
    this.id,
    this.uuid,
    this.code,
    this.nameTh,
    this.required,
    this.description,
    this.active,
    this.createdAt,
  });

  factory LicenseverifyClientDocument.fromJson(Map<String, dynamic> json) {
    return LicenseverifyClientDocument(
      id: json['id'],
      uuid: json['uuid'],
      code: json['code'],
      nameTh: json['name_th'] ?? json['nameTh'],
      required: _parseApiBool(json['required']),
      description: json['description'],
      active: _parseApiBool(json['active']),
      createdAt: json['created_at'] ?? json['createdAt'],
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
    };
  }
}

// ============================================================================
// LicenseverifyAttachment — ไฟล์แนบ 1 รายการ
// ============================================================================

class LicenseverifyAttachment {
  dynamic id;
  dynamic uuid;
  dynamic requestUuid;
  dynamic filePath;
  dynamic fileName;
  dynamic fileType;
  dynamic clientDocumentId;
  dynamic active;
  dynamic status;
  dynamic status_label;
  LicenseverifyClientDocument? clientDocument;
  dynamic reviewAt;
  dynamic createdAt;
  dynamic uploadedAt;

  LicenseverifyAttachment({
    this.id,
    this.uuid,
    this.requestUuid,
    this.filePath,
    this.fileName,
    this.fileType,
    this.clientDocumentId,
    this.active,
    this.status,
    this.status_label,
    this.clientDocument,
    this.reviewAt,
    this.createdAt,
    this.uploadedAt,
  });

  factory LicenseverifyAttachment.fromJson(Map<String, dynamic> json) {
    return LicenseverifyAttachment(
      id: json['id'],
      uuid: json['uuid'],
      requestUuid: json['request_uuid'] ?? json['requestUuid'],
      filePath: json['file_path'] ?? json['filePath'],
      fileName: json['file_name'] ?? json['fileName'],
      fileType: json['file_type'] ?? json['fileType'],
      clientDocumentId: json['client_document_id'] ?? json['clientDocumentId'],
      active: json['active'],
      status: json['status'],
      status_label: json['status_label'] ?? json['statusLabel'],
      clientDocument: json['client_document'] != null
          ? LicenseverifyClientDocument.fromJson(
              Map<String, dynamic>.from(json['client_document'] as Map))
          : (json['clientDocument'] != null
              ? LicenseverifyClientDocument.fromJson(
                  Map<String, dynamic>.from(json['clientDocument'] as Map))
              : null),
      reviewAt: json['review_at'] ?? json['reviewAt'],
      createdAt: json['created_at'] ?? json['createdAt'],
      uploadedAt: json['uploaded_at'] ?? json['uploadedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id': id,
      'uuid': uuid,
      'request_uuid': requestUuid,
      'file_path': filePath,
      'file_name': fileName,
      'file_type': fileType,
      'client_document_id': clientDocumentId,
      'active': active,
      'status': status,
      'status_label': status_label,
      if (clientDocument != null) 'client_document': clientDocument!.toJson(),
      'review_at': reviewAt,
      'created_at': createdAt,
      'uploaded_at': uploadedAt,
    };
    return data;
  }
}

