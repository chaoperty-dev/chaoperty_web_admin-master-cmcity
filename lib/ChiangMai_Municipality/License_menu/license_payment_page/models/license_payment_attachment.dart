// ============================================================================
// license_payment_attachment.dart
// ============================================================================
// Model — รายการ "ประวัติ / กิจกรรม / ไฟล์แนบ" ของ Payment
//
// map ตาม JSON จาก endpoint ตระกูล Payment v2:
//   - GET /api/v2/payments/{uuid}/history        → ประวัติสถานะ
//   - GET /api/v2/payments/{uuid}/activity       → activity log
//   - GET /api/v2/payments/attachments/{uuid}/preview → รูปไฟล์แนบ (bytes)
//   - POST /api/v2/payments/{uuid}/attachments   → อัปโหลดไฟล์แนบ
// ============================================================================

/// แถวประวัติ (history) — เก็บ state change ของ payment
class PaymentHistoryItem {
  final String uuid;
  final String? status;
  final String? action;
  final String? note;
  final String? actorName;
  final String? createdAt;
  final Map<String, dynamic> raw;

  const PaymentHistoryItem({
    this.uuid = '',
    this.status,
    this.action,
    this.note,
    this.actorName,
    this.createdAt,
    this.raw = const {},
  });

  factory PaymentHistoryItem.fromJson(Map<String, dynamic> json) {
    String s(dynamic v) => v == null ? '' : v.toString();
    final actor = json['actor'];
    final actorName = actor is Map
        ? (actor['name'] ?? actor['fullname'] ?? '').toString()
        : s(json['actor_name']);
    return PaymentHistoryItem(
      uuid: s(json['uuid']),
      status: json['status']?.toString(),
      action: json['action']?.toString(),
      note: json['note']?.toString() ?? json['description']?.toString(),
      actorName: actorName.isEmpty ? null : actorName,
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString(),
      raw: json,
    );
  }
}

/// แถว activity log — คล้าย history แต่ละเอียดกว่า (action + meta)
class PaymentActivityItem {
  final String uuid;
  final String? action;
  final String? description;
  final String? actorName;
  final String? createdAt;
  final Map<String, dynamic> raw;

  const PaymentActivityItem({
    this.uuid = '',
    this.action,
    this.description,
    this.actorName,
    this.createdAt,
    this.raw = const {},
  });

  factory PaymentActivityItem.fromJson(Map<String, dynamic> json) {
    final actor = json['actor'] ?? json['user'];
    final actorName = actor is Map
        ? (actor['name'] ?? actor['fullname'] ?? '').toString()
        : (json['actor_name'] ?? '').toString();
    return PaymentActivityItem(
      uuid: (json['uuid'] ?? '').toString(),
      action: (json['action'] ?? json['event'] ?? '').toString(),
      description:
          (json['description'] ?? json['note'] ?? json['message'] ?? '')
              .toString(),
      actorName: actorName.isEmpty ? null : actorName,
      createdAt: (json['created_at'] ?? json['createdAt'] ?? '').toString(),
      raw: json,
    );
  }
}

/// Wrapper — list response: { "data": [...] }
class PaymentHistoryListResponse {
  final List<PaymentHistoryItem> items;
  const PaymentHistoryListResponse({this.items = const []});

  factory PaymentHistoryListResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'] ?? json['history'] ?? json;
    final list = raw is List ? raw : const [];
    return PaymentHistoryListResponse(
      items: list
          .whereType<Map>()
          .map((e) => PaymentHistoryItem.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  bool get isEmpty => items.isEmpty;
}

class PaymentActivityListResponse {
  final List<PaymentActivityItem> items;
  const PaymentActivityListResponse({this.items = const []});

  factory PaymentActivityListResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'] ?? json['activity'] ?? json;
    final list = raw is List ? raw : const [];
    return PaymentActivityListResponse(
      items: list
          .whereType<Map>()
          .map((e) => PaymentActivityItem.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  bool get isEmpty => items.isEmpty;
}

/// ไฟล์แนบ (response จาก POST /attachments หรือ GET history ที่มี attachments)
class PaymentAttachment {
  final String uuid;
  final String? paymentUuid; // ← uuid ของ payment ที่ไฟล์นี้ถูกแนบ
  final String? filename;
  final String? mimeType;
  final int? size;
  final String? url;
  final String? previewUrl;
  final String? uploadedAt;
  final Map<String, dynamic> raw;

  const PaymentAttachment({
    this.uuid = '',
    this.paymentUuid,
    this.filename,
    this.mimeType,
    this.size,
    this.url,
    this.previewUrl,
    this.uploadedAt,
    this.raw = const {},
  });

  factory PaymentAttachment.fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic v) => v is int ? v : int.tryParse('${v ?? ''}');
    return PaymentAttachment(
      uuid: (json['uuid'] ?? '').toString(),
      paymentUuid:
          (json['payment_uuid'] ?? json['paymentUuid'])?.toString(),
      filename: (json['filename'] ?? json['name'] ?? json['file_name'])?.toString(),
      mimeType: (json['mime_type'] ?? json['mimeType'] ?? json['type'])?.toString(),
      size: toInt(json['size'] ?? json['file_size']),
      url: (json['url'] ?? json['path'])?.toString(),
      previewUrl:
          (json['preview_url'] ?? json['previewUrl'])?.toString(),
      uploadedAt:
          (json['uploaded_at'] ?? json['created_at'])?.toString(),
      raw: json,
    );
  }

  factory PaymentAttachment.empty() => const PaymentAttachment();
}
