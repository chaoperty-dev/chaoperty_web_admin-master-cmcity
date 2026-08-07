// ============================================================================
// license_request_detail_service.dart
// ============================================================================
// Service — โหลด "รายละเอียดคำขอ" ตาม UUID (สำหรับหน้า Request Detail Step 1)
// - เรียก API: GET /admin/approvals/{uuid}/review
// - ใช้ read_GC_ReviewsUuid() ที่มีอยู่ใน unity/API_requests_reviews.dart
// - Parse JSON → ReviewDetail (Model/ReviewUuid_Model.dart)
// ============================================================================

import 'dart:convert';

import '../../../Model/ReviewUuid_Model.dart';
import '../../../unity/API_requests_reviews.dart';

class LicenseRequestDetailService {
  LicenseRequestDetailService();

  /// โหลดรายละเอียดคำขอจาก UUID
  /// return ReviewDetail (parsed) หรือ throw error
  Future<ReviewDetail> fetchReviewDetail({required String uuid}) async {
    if (uuid.isEmpty) {
      throw Exception('UUID is required');
    }

    final response = await read_GC_ReviewsUuid(uuid);
    if (response == null) {
      throw Exception('ไม่สามารถเชื่อมต่อ API ได้');
    }
    if (response.statusCode != 200) {
      throw Exception(
          'โหลดข้อมูลไม่สำเร็จ (status: ${response.statusCode})');
    }

    final result = json.decode(response.body);
    if (result is! Map || result['data'] is! Map) {
      throw Exception('รูปแบบข้อมูลไม่ถูกต้อง');
    }

    return ReviewDetail.fromJson(result['data'] as Map<String, dynamic>);
  }
}
