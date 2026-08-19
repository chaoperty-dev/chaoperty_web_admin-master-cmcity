// ============================================================================
// license_verify_checklist_model.dart
// ============================================================================
// Data models for /api/v1/admin/requests/{uuid}/checklist/preview
// ============================================================================

class LicenseverifyChecklistSigner {
  final String uuid;
  final String name;
  final String position;
  final String? signaturePath;
  final DateTime? signedAt;

  const LicenseverifyChecklistSigner({
    required this.uuid,
    required this.name,
    required this.position,
    this.signaturePath,
    this.signedAt,
  });

  factory LicenseverifyChecklistSigner.fromJson(Map<String, dynamic> json) {
    return LicenseverifyChecklistSigner(
      uuid: json['uuid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      position: json['position'] as String? ?? '',
      signaturePath: json['signature_path'] as String?,
      signedAt: _parseDateTime(json['signed_at']),
    );
  }
}

class LicenseverifyChecklistAttachment {
  final int clientDocumentId;
  final String code;
  final String nameTh;
  final bool required;
  final int showAfterSubmit;
  final String? attachmentUuid;
  final String? fileName;
  final String? fileType;
  final int? fileSize;
  final DateTime? uploadedAt;
  final String? reviewStatus;

  const LicenseverifyChecklistAttachment({
    required this.clientDocumentId,
    required this.code,
    required this.nameTh,
    required this.required,
    required this.showAfterSubmit,
    this.attachmentUuid,
    this.fileName,
    this.fileType,
    this.fileSize,
    this.uploadedAt,
    this.reviewStatus,
  });

  factory LicenseverifyChecklistAttachment.fromJson(Map<String, dynamic> json) {
    return LicenseverifyChecklistAttachment(
      clientDocumentId: json['client_document_id'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      nameTh: json['name_th'] as String? ?? '',
      required: json['required'] as bool? ?? false,
      showAfterSubmit: json['show_after_submit'] as int? ?? 0,
      attachmentUuid: json['attachment_uuid'] as String?,
      fileName: json['file_name'] as String?,
      fileType: json['file_type'] as String?,
      fileSize: json['file_size'] as int?,
      uploadedAt: _parseDateTime(json['uploaded_at']),
      reviewStatus: json['review_status'] as String?,
    );
  }

  bool get hasFile => attachmentUuid != null && fileName != null;
}

class LicenseverifyChecklistRequestNews {
  final int zser;
  final String zn;
  final int aser;
  final String ln;

  const LicenseverifyChecklistRequestNews({
    required this.zser,
    required this.zn,
    required this.aser,
    required this.ln,
  });

  factory LicenseverifyChecklistRequestNews.fromJson(
      Map<String, dynamic> json) {
    return LicenseverifyChecklistRequestNews(
      zser: json['zser'] as int? ?? 0,
      zn: json['zn'] as String? ?? '',
      aser: json['aser'] as int? ?? 0,
      ln: json['ln'] as String? ?? '',
    );
  }

  String get plotLabel => 'โฉนดที่ ${zser == 0 ? '-' : zser}';
  String get lockLabel => 'ล็อคที่ ${ln.isEmpty ? '-' : ln}';
}

class LicenseverifyChecklistPayload {
  final List<LicenseverifyChecklistAttachment> attachments;
  final LicenseverifyChecklistSigner? signer;
  final LicenseverifyChecklistRequestNews? requestNews;

  const LicenseverifyChecklistPayload({
    required this.attachments,
    this.signer,
    this.requestNews,
  });

  factory LicenseverifyChecklistPayload.fromJson(Map<String, dynamic> json) {
    final attachmentsJson = json['attachments'] as List<dynamic>? ?? [];
    final signerJson = json['signer'] as Map<String, dynamic>?;
    final requestNewsJson = json['request_news'] as Map<String, dynamic>?;

    return LicenseverifyChecklistPayload(
      attachments: attachmentsJson
          .whereType<Map<String, dynamic>>()
          .map(LicenseverifyChecklistAttachment.fromJson)
          .toList(),
      signer: signerJson == null
          ? null
          : LicenseverifyChecklistSigner.fromJson(signerJson),
      requestNews: requestNewsJson == null
          ? null
          : LicenseverifyChecklistRequestNews.fromJson(requestNewsJson),
    );
  }
}

class LicenseverifyChecklistPreview {
  final String requestUuid;
  final LicenseverifyChecklistPayload payload;

  /// Metadata จาก saved checklist (มีเฉพาะตอนโหลดจาก GET /checklist)
  final String? checklistUuid;
  final String? checklistNo;
  final int? version;
  final DateTime? checkedAt;

  const LicenseverifyChecklistPreview({
    required this.requestUuid,
    required this.payload,
    this.checklistUuid,
    this.checklistNo,
    this.version,
    this.checkedAt,
  });

  /// true ถ้ามาจาก saved checklist (มี version + checklist_no)
  bool get isSaved => checklistNo != null;

  factory LicenseverifyChecklistPreview.fromJson(Map<String, dynamic> json) {
    final payloadJson = json['payload'] as Map<String, dynamic>? ?? {};
    return LicenseverifyChecklistPreview(
      requestUuid: json['request_uuid'] as String? ?? '',
      payload: LicenseverifyChecklistPayload.fromJson(payloadJson),
    );
  }

  /// Parse response จาก GET /admin/requests/{uuid}/checklist
  factory LicenseverifyChecklistPreview.fromSavedJson(
      Map<String, dynamic> json) {
    final payloadJson = json['payload'] as Map<String, dynamic>? ?? {};
    return LicenseverifyChecklistPreview(
      requestUuid: json['request_uuid'] as String? ?? '',
      payload: LicenseverifyChecklistPayload.fromJson(payloadJson),
      checklistUuid: json['uuid'] as String?,
      checklistNo: json['checklist_no'] as String?,
      version: json['version'] as int?,
      checkedAt: _parseDateTime(json['signed_at']) ??
          _parseDateTime(payloadJson['checked_at']),
    );
  }
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
  return null;
}

