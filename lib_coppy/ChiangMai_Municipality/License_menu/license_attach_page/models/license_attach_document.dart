// ============================================================================
// license_attach_document.dart
// ============================================================================
// DocumentModel + ClientDocument (ของตัวเองใน license_attach_page)
// ไม่ใช้ Document_Model.dart ที่อยู่ใน ChiangMai_Municipality/Model/
// ============================================================================

/// เอกสารที่ต้องแนบ 1 รายการ (พร้อม attachments ที่แนบแล้ว)
class LicenseAttachDocument {
  dynamic id;
  dynamic uuid;
  dynamic code;
  dynamic nameTh;
  dynamic required;
  dynamic description;
  dynamic active;
  dynamic createdAt;
  dynamic updatedAt;
  List<LicenseAttachAttachment> attachments;

  LicenseAttachDocument({
    this.id,
    this.uuid,
    this.code,
    this.nameTh,
    this.required,
    this.description,
    this.active,
    this.createdAt,
    this.updatedAt,
    List<LicenseAttachAttachment>? attachments,
  }) : attachments = attachments ?? [];

  factory LicenseAttachDocument.fromJson(Map<String, dynamic> json) {
    return LicenseAttachDocument(
      id: json['id'],
      uuid: json['uuid'],
      code: json['code'],
      nameTh: json['name_th'] ?? json['nameTh'],
      required: json['required'],
      description: json['description'],
      active: json['active'],
      createdAt: json['created_at'] ?? json['createdAt'],
      updatedAt: json['updated_at'] ?? json['updatedAt'],
      attachments: json['attachments'] != null
          ? List<LicenseAttachAttachment>.from(
              (json['attachments'] as List)
                  .map((x) => LicenseAttachAttachment.fromJson(
                      Map<String, dynamic>.from(x as Map))),
            )
          : <LicenseAttachAttachment>[],
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
      'attachments': attachments.map((x) => x.toJson()).toList(),
    };
  }
}

/// ClientDocument (ข้อมูลประเภทเอกสาร — embedded ใน attachment)
class LicenseAttachClientDocument {
  dynamic id;
  dynamic uuid;
  dynamic code;
  dynamic nameTh;
  bool? required;
  dynamic description;
  bool? active;
  dynamic createdAt;

  LicenseAttachClientDocument({
    this.id,
    this.uuid,
    this.code,
    this.nameTh,
    this.required,
    this.description,
    this.active,
    this.createdAt,
  });

  factory LicenseAttachClientDocument.fromJson(Map<String, dynamic> json) {
    return LicenseAttachClientDocument(
      id: json['id'],
      uuid: json['uuid'],
      code: json['code'],
      nameTh: json['name_th'] ?? json['nameTh'],
      required: json['required'] as bool?,
      description: json['description'],
      active: json['active'] as bool?,
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
// LicenseAttachAttachment — ไฟล์แนบ 1 รายการ
// ============================================================================

class LicenseAttachAttachment {
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
  LicenseAttachClientDocument? clientDocument;
  dynamic reviewAt;
  dynamic createdAt;
  dynamic uploadedAt;

  LicenseAttachAttachment({
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

  factory LicenseAttachAttachment.fromJson(Map<String, dynamic> json) {
    return LicenseAttachAttachment(
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
          ? LicenseAttachClientDocument.fromJson(
              Map<String, dynamic>.from(json['client_document'] as Map))
          : (json['clientDocument'] != null
              ? LicenseAttachClientDocument.fromJson(
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
