// ============================================================================
// license_verify_result.dart
// ============================================================================
// ผลลัพธ์จากการบันทึก (Result class) — ของตัวเองใน license_verify_page
// ไม่ใช้ LicenseContractResult จาก license_contract_page
// ============================================================================

/// ผลลัพธ์ที่ส่งกลับเมื่อบันทึกสำเร็จ
class LicenseVerifyResult {
  /// UUID ของ request ที่ถูกสร้าง/อัปเดต
  final String? uuid;

  /// Request UUID (alias สำหรับ uuid — บางจุดใช้ชื่อนี้)
  final String? requestUuid;

  /// ข้อความตอบกลับจาก server (เช่น "บันทึกสำเร็จ")
  final String? message;

  /// HTTP status code
  final int? statusCode;

  /// Raw data จาก response (เผื่อ caller อยากใช้ข้อมูลอื่น)
  final Map<String, dynamic>? data;

  const LicenseVerifyResult({
    this.uuid,
    this.requestUuid,
    this.message,
    this.statusCode,
    this.data,
  });

  factory LicenseVerifyResult.fromJson(Map<String, dynamic> json) {
    String? extractUuid(dynamic v) {
      if (v is Map && v['uuid'] != null) return v['uuid'].toString();
      if (v is String) return v;
      return null;
    }

    String? uuid = extractUuid(json['uuid']);
    uuid ??= extractUuid(json['data']?['uuid']);
    uuid ??= extractUuid(json['request_uuid'] ?? json['requestUuid']);

    return LicenseVerifyResult(
      uuid: uuid,
      requestUuid: uuid,
      message: json['message']?.toString(),
      statusCode: json['status_code'] is int
          ? json['status_code'] as int
          : null,
      data: json['data'] is Map
          ? Map<String, dynamic>.from(json['data'] as Map)
          : null,
    );
  }

  bool get success =>
      (statusCode == 200 || statusCode == 201) && (uuid?.isNotEmpty ?? false);

  @override
  String toString() =>
      'LicenseVerifyResult(uuid: $uuid, message: $message, status: $statusCode)';
}
