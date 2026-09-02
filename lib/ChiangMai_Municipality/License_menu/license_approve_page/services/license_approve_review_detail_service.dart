// ============================================================================
// license_approve_review_detail_service.dart
// ============================================================================
// Service — โหลด ReviewModel ตาม uuid (single item)
//
// ใช้ endpoint:
//   - GET {domain}/admin/approvals/{uuid}/review
//
// หมายเหตุ: หน้า Approve detail ต้องโหลด "คำขอ" ตาม uuid ตรงๆ — ไม่ใช่ list
// query เพราะ /admin/approvals ไม่รองรับ filter ?uuid=
// ============================================================================

import 'dart:convert';

import 'package:chaoperty/Constant/Myconstant.dart';
import 'package:http/http.dart' as http;

import '../unity/API_requests_reviews.dart';
import '../../../Model/Review_Model.dart';

class LicenseApproveReviewDetailService {
  LicenseApproveReviewDetailService();

  /// GET /admin/approvals/{uuid}/review
  /// คืน ReviewModel หรือ throw error
  Future<ReviewModel> fetchReviewByUuid({required String uuid}) async {
    if (uuid.trim().isEmpty) {
      throw Exception('UUID is required');
    }

    final response = await read_GC_ReviewsUuid(uuid);
    if (response == null) {
      throw Exception('ไม่สามารถเชื่อมต่อ API ได้');
    }
    if (response.statusCode != 200) {
      throw Exception('โหลดข้อมูลไม่สำเร็จ (status: ${response.statusCode})');
    }

    final result = json.decode(response.body);
    if (result is! Map || result['data'] is! Map) {
      throw Exception('รูปแบบข้อมูลไม่ถูกต้อง');
    }

    final data = Map<String, dynamic>.from(result['data'] as Map);
    return ReviewModel.fromJson(data);
  }
}