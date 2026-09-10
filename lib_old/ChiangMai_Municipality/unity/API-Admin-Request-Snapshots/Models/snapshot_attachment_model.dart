// Model สำหรับ Snapshot Attachment
class SnapshotAttachmentModel {
  String? uuid;
  String? requestSnapshotUuid;
  String? sourceRequestAttachmentUuid;
  String? sourceClientDocumentUuid;
  int? sourceClientDocumentId;
  String? fileName;
  String? filePath;
  String? fileType;
  int? fileSize;
  bool? sourceActive;
  String? uploadedRequestAttachmentUuid;
  String? uploadedAt;
  String? sourceCreatedAt;
  String? sourceUpdatedAt;
  SnapshotInfo? snapshot;
  dynamic clientDocument;
  dynamic importedRequestAttachment;
  String? createdAt;
  String? updatedAt;

  SnapshotAttachmentModel({
    this.uuid,
    this.requestSnapshotUuid,
    this.sourceRequestAttachmentUuid,
    this.sourceClientDocumentUuid,
    this.sourceClientDocumentId,
    this.fileName,
    this.filePath,
    this.fileType,
    this.fileSize,
    this.sourceActive,
    this.uploadedRequestAttachmentUuid,
    this.uploadedAt,
    this.sourceCreatedAt,
    this.sourceUpdatedAt,
    this.snapshot,
    this.clientDocument,
    this.importedRequestAttachment,
    this.createdAt,
    this.updatedAt,
  });

  SnapshotAttachmentModel.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    requestSnapshotUuid = json['request_snapshot_uuid'];
    sourceRequestAttachmentUuid = json['source_request_attachment_uuid'];
    sourceClientDocumentUuid = json['source_client_document_uuid'];
    sourceClientDocumentId = json['source_client_document_id'];
    fileName = json['file_name'];
    filePath = json['file_path'];
    fileType = json['file_type'];
    fileSize = json['file_size'];
    sourceActive = json['source_active'];
    uploadedRequestAttachmentUuid = json['uploaded_request_attachment_uuid'];
    uploadedAt = json['uploaded_at'];
    sourceCreatedAt = json['source_created_at'];
    sourceUpdatedAt = json['source_updated_at'];
    snapshot = json['snapshot'] != null
        ? SnapshotInfo.fromJson(json['snapshot'])
        : null;
    clientDocument = json['client_document'];
    importedRequestAttachment = json['imported_request_attachment'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['request_snapshot_uuid'] = requestSnapshotUuid;
    data['source_request_attachment_uuid'] = sourceRequestAttachmentUuid;
    data['source_client_document_uuid'] = sourceClientDocumentUuid;
    data['source_client_document_id'] = sourceClientDocumentId;
    data['file_name'] = fileName;
    data['file_path'] = filePath;
    data['file_type'] = fileType;
    data['file_size'] = fileSize;
    data['source_active'] = sourceActive;
    data['uploaded_request_attachment_uuid'] = uploadedRequestAttachmentUuid;
    data['uploaded_at'] = uploadedAt;
    data['source_created_at'] = sourceCreatedAt;
    data['source_updated_at'] = sourceUpdatedAt;
    if (snapshot != null) {
      data['snapshot'] = snapshot!.toJson();
    }
    data['client_document'] = clientDocument;
    data['imported_request_attachment'] = importedRequestAttachment;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

// Model สำหรับ Snapshot Info (nested object)
class SnapshotInfo {
  String? uuid;
  String? sourceRequestUuid;
  String? clientsUuid;
  int? snapshotVersion;

  SnapshotInfo({
    this.uuid,
    this.sourceRequestUuid,
    this.clientsUuid,
    this.snapshotVersion,
  });

  SnapshotInfo.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    sourceRequestUuid = json['source_request_uuid'];
    clientsUuid = json['clients_uuid'];
    snapshotVersion = json['snapshot_version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['source_request_uuid'] = sourceRequestUuid;
    data['clients_uuid'] = clientsUuid;
    data['snapshot_version'] = snapshotVersion;
    return data;
  }
}

// Model สำหรับ Response List Attachments
class SnapshotAttachmentsResponse {
  List<SnapshotAttachmentModel>? data;

  SnapshotAttachmentsResponse({this.data});

  SnapshotAttachmentsResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <SnapshotAttachmentModel>[];
      json['data'].forEach((v) {
        data!.add(SnapshotAttachmentModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// Model สำหรับ Response Single Attachment (Preview)
class SnapshotAttachmentPreviewResponse {
  SnapshotAttachmentModel? data;

  SnapshotAttachmentPreviewResponse({this.data});

  SnapshotAttachmentPreviewResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null
        ? SnapshotAttachmentModel.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}
