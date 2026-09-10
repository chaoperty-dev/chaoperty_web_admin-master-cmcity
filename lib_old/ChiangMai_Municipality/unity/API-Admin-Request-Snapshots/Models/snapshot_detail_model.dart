// Model สำหรับ Snapshot Detail (Show Snapshot)
// Reuse models จาก snapshot_list_model.dart
import 'snapshot_list_model.dart';

// Model สำหรับ Attachment ใน Snapshot Detail
class SnapshotDetailAttachmentModel {
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
  dynamic clientDocument;
  dynamic importedRequestAttachment;
  String? createdAt;
  String? updatedAt;

  SnapshotDetailAttachmentModel({
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
    this.clientDocument,
    this.importedRequestAttachment,
    this.createdAt,
    this.updatedAt,
  });

  SnapshotDetailAttachmentModel.fromJson(Map<String, dynamic> json) {
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
    data['client_document'] = clientDocument;
    data['imported_request_attachment'] = importedRequestAttachment;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

// Model สำหรับ Snapshot Detail
class SnapshotDetailModel {
  String? uuid;
  String? sourceRequestUuid;
  int? snapshotVersion;
  bool? active;
  String? clientsUuid;
  String? sourceClientsUuid;
  String? referencedRequestUuid;
  String? referencedAt;
  ModuleModel? module;
  ClientModel? client;
  dynamic sourceRequest;
  dynamic referencedRequest;
  String? sourceAnnouncementUuid;
  String? sourceParentUuid;
  String? sourceStatus;
  String? sourceSubmittedAt;
  String? sourceSubmittedBy;
  dynamic sourceSubmittedProfile;
  dynamic sourceSubmittedSignature;
  String? sourceCompletedAt;
  String? sourceFeeAmount;
  bool? sourceCreatedByAdmin;
  String? sourceCreatedBy;
  String? sourceUpdatedBy;
  String? sourceCreatedAt;
  String? sourceUpdatedAt;
  String? snapshottedAt;
  List<SnapshotDetailAttachmentModel>? attachments;
  String? createdAt;
  String? updatedAt;

  SnapshotDetailModel({
    this.uuid,
    this.sourceRequestUuid,
    this.snapshotVersion,
    this.active,
    this.clientsUuid,
    this.sourceClientsUuid,
    this.referencedRequestUuid,
    this.referencedAt,
    this.module,
    this.client,
    this.sourceRequest,
    this.referencedRequest,
    this.sourceAnnouncementUuid,
    this.sourceParentUuid,
    this.sourceStatus,
    this.sourceSubmittedAt,
    this.sourceSubmittedBy,
    this.sourceSubmittedProfile,
    this.sourceSubmittedSignature,
    this.sourceCompletedAt,
    this.sourceFeeAmount,
    this.sourceCreatedByAdmin,
    this.sourceCreatedBy,
    this.sourceUpdatedBy,
    this.sourceCreatedAt,
    this.sourceUpdatedAt,
    this.snapshottedAt,
    this.attachments,
    this.createdAt,
    this.updatedAt,
  });

  SnapshotDetailModel.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    sourceRequestUuid = json['source_request_uuid'];
    snapshotVersion = json['snapshot_version'];
    active = json['active'];
    clientsUuid = json['clients_uuid'];
    sourceClientsUuid = json['source_clients_uuid'];
    referencedRequestUuid = json['referenced_request_uuid'];
    referencedAt = json['referenced_at'];
    module =
        json['module'] != null ? ModuleModel.fromJson(json['module']) : null;
    client =
        json['client'] != null ? ClientModel.fromJson(json['client']) : null;
    sourceRequest = json['source_request'];
    referencedRequest = json['referenced_request'];
    sourceAnnouncementUuid = json['source_announcement_uuid'];
    sourceParentUuid = json['source_parent_uuid'];
    sourceStatus = json['source_status'];
    sourceSubmittedAt = json['source_submitted_at'];
    sourceSubmittedBy = json['source_submitted_by'];
    sourceSubmittedProfile = json['source_submitted_profile'];
    sourceSubmittedSignature = json['source_submitted_signature'];
    sourceCompletedAt = json['source_completed_at'];
    sourceFeeAmount = json['source_fee_amount'];
    sourceCreatedByAdmin = json['source_created_by_admin'];
    sourceCreatedBy = json['source_created_by'];
    sourceUpdatedBy = json['source_updated_by'];
    sourceCreatedAt = json['source_created_at'];
    sourceUpdatedAt = json['source_updated_at'];
    snapshottedAt = json['snapshotted_at'];
    if (json['attachments'] != null) {
      attachments = <SnapshotDetailAttachmentModel>[];
      json['attachments'].forEach((v) {
        attachments!.add(SnapshotDetailAttachmentModel.fromJson(v));
      });
    }
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['source_request_uuid'] = sourceRequestUuid;
    data['snapshot_version'] = snapshotVersion;
    data['active'] = active;
    data['clients_uuid'] = clientsUuid;
    data['source_clients_uuid'] = sourceClientsUuid;
    data['referenced_request_uuid'] = referencedRequestUuid;
    data['referenced_at'] = referencedAt;
    if (module != null) {
      data['module'] = module!.toJson();
    }
    if (client != null) {
      data['client'] = client!.toJson();
    }
    data['source_request'] = sourceRequest;
    data['referenced_request'] = referencedRequest;
    data['source_announcement_uuid'] = sourceAnnouncementUuid;
    data['source_parent_uuid'] = sourceParentUuid;
    data['source_status'] = sourceStatus;
    data['source_submitted_at'] = sourceSubmittedAt;
    data['source_submitted_by'] = sourceSubmittedBy;
    data['source_submitted_profile'] = sourceSubmittedProfile;
    data['source_submitted_signature'] = sourceSubmittedSignature;
    data['source_completed_at'] = sourceCompletedAt;
    data['source_fee_amount'] = sourceFeeAmount;
    data['source_created_by_admin'] = sourceCreatedByAdmin;
    data['source_created_by'] = sourceCreatedBy;
    data['source_updated_by'] = sourceUpdatedBy;
    data['source_created_at'] = sourceCreatedAt;
    data['source_updated_at'] = sourceUpdatedAt;
    data['snapshotted_at'] = snapshottedAt;
    if (attachments != null) {
      data['attachments'] = attachments!.map((v) => v.toJson()).toList();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

// Model สำหรับ Response Show Snapshot
class SnapshotDetailResponse {
  SnapshotDetailModel? data;

  SnapshotDetailResponse({this.data});

  SnapshotDetailResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null
        ? SnapshotDetailModel.fromJson(json['data'])
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
