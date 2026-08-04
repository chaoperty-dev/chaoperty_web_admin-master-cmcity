// ============================================================================
// license_attach_checklist_model.dart
// ============================================================================
// Data models for /api/v1/admin/requests/{uuid}/checklist/preview
// ============================================================================

class LicenseAttachChecklistSigner {
  final String uuid;
  final String name;
  final String position;
  final String? signaturePath;
  final DateTime? signedAt;

  const LicenseAttachChecklistSigner({
    required this.uuid,
    required this.name,
    required this.position,
    this.signaturePath,
    this.signedAt,
  });

  factory LicenseAttachChecklistSigner.fromJson(Map<String, dynamic> json) {
    return LicenseAttachChecklistSigner(
      uuid: json['uuid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      position: json['position'] as String? ?? '',
      signaturePath: json['signature_path'] as String?,
      signedAt: _parseDateTime(json['signed_at']),
    );
  }
}

class LicenseAttachChecklistAttachment {
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

  const LicenseAttachChecklistAttachment({
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

  factory LicenseAttachChecklistAttachment.fromJson(Map<String, dynamic> json) {
    return LicenseAttachChecklistAttachment(
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

class LicenseAttachChecklistRequestNews {
  final int zser;
  final String zn;
  final int aser;
  final String ln;

  const LicenseAttachChecklistRequestNews({
    required this.zser,
    required this.zn,
    required this.aser,
    required this.ln,
  });

  factory LicenseAttachChecklistRequestNews.fromJson(
      Map<String, dynamic> json) {
    return LicenseAttachChecklistRequestNews(
      zser: json['zser'] as int? ?? 0,
      zn: json['zn'] as String? ?? '',
      aser: json['aser'] as int? ?? 0,
      ln: json['ln'] as String? ?? '',
    );
  }

  String get plotLabel => 'โฉนดที่ ${zser == 0 ? '-' : zser}';
  String get lockLabel => 'ล็อคที่ ${ln.isEmpty ? '-' : ln}';
}

class LicenseAttachChecklistPayload {
  final List<LicenseAttachChecklistAttachment> attachments;
  final LicenseAttachChecklistSigner? signer;
  final LicenseAttachChecklistRequestNews? requestNews;

  const LicenseAttachChecklistPayload({
    required this.attachments,
    this.signer,
    this.requestNews,
  });

  factory LicenseAttachChecklistPayload.fromJson(Map<String, dynamic> json) {
    final attachmentsJson = json['attachments'] as List<dynamic>? ?? [];
    final signerJson = json['signer'] as Map<String, dynamic>?;
    final requestNewsJson = json['request_news'] as Map<String, dynamic>?;

    return LicenseAttachChecklistPayload(
      attachments: attachmentsJson
          .whereType<Map<String, dynamic>>()
          .map(LicenseAttachChecklistAttachment.fromJson)
          .toList(),
      signer: signerJson == null
          ? null
          : LicenseAttachChecklistSigner.fromJson(signerJson),
      requestNews: requestNewsJson == null
          ? null
          : LicenseAttachChecklistRequestNews.fromJson(requestNewsJson),
    );
  }
}

class LicenseAttachChecklistPreview {
  final String requestUuid;
  final LicenseAttachChecklistPayload payload;

  const LicenseAttachChecklistPreview({
    required this.requestUuid,
    required this.payload,
  });

  factory LicenseAttachChecklistPreview.fromJson(Map<String, dynamic> json) {
    final payloadJson = json['payload'] as Map<String, dynamic>? ?? {};
    return LicenseAttachChecklistPreview(
      requestUuid: json['request_uuid'] as String? ?? '',
      payload: LicenseAttachChecklistPayload.fromJson(payloadJson),
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
