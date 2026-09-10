// ============================================================================
// attachment_utils.dart
// ============================================================================
// Helper functions สำหรับจัดการ attachments
// ไม่ดึงจาก unity/API_admin_requests.dart (ของ Make_contract_CMM)
// ============================================================================

import '../models/license_attach_document.dart';

/// หา attachment ที่ตรงกับ document id (ตาม clientDocumentId)
///
/// คืน `LicenseAttachAttachment?` — null ถ้าไม่เจอ
LicenseAttachAttachment? findAttachmentByDocId(
  List<LicenseAttachAttachment> attachments,
  dynamic docId,
) {
  if (attachments.isEmpty) return null;
  final target = docId?.toString() ?? '';
  if (target.isEmpty) return attachments.first;

  for (final att in attachments) {
    final idStr = att.clientDocumentId?.toString() ?? '';
    if (idStr == target) return att;
  }
  return attachments.first;
}

/// ตรวจว่า attachment เป็นรูปภาพหรือไม่
bool isImageAttachment(LicenseAttachAttachment att) {
  final fileType = (att.fileType ?? '').toString().toLowerCase();
  final fileName = (att.fileName ?? att.filePath ?? '').toString().toLowerCase();
  final combined = '$fileType $fileName';
  return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'image/']
      .any((ext) => combined.contains(ext));
}

/// ตรวจว่า attachment เป็น PDF หรือไม่
bool isPdfAttachment(LicenseAttachAttachment att) {
  final fileType = (att.fileType ?? '').toString().toLowerCase();
  final fileName = (att.fileName ?? att.filePath ?? '').toString().toLowerCase();
  return '$fileType $fileName'.contains('pdf');
}

/// ดึง doc id เป็น int (รองรับ int / num / String)
int extractDocId(dynamic raw) {
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  if (raw is String) return int.tryParse(raw) ?? 0;
  return 0;
}
