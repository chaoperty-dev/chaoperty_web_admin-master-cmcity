// ============================================================================
// license_request_detail_service.dart
// ============================================================================
// Service — โหลด "รายละเอียดคำขอ" ตาม UUID (สำหรับหน้า Request Detail Step 1)
// - เรียก API: GET /admin/approvals/{uuid}/review
// - ใช้ read_GC_ReviewsUuid() ที่มีอยู่ใน unity/API_requests_reviews.dart
// - Parse JSON → ReviewDetail (Model/ReviewUuid_Model.dart)
// - API ยกเลิกคำขอ (POST /v1/admin/requests/{uuid}/cancel) อยู่ในนี้ — ไม่แยกไฟล์อื่น
// ============================================================================

import 'dart:convert';

import 'package:chaoperty/Constant/Myconstant.dart';
import 'package:http/http.dart' as http;

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
      throw Exception('โหลดข้อมูลไม่สำเร็จ (status: ${response.statusCode})');
    }

    final result = json.decode(response.body);
    if (result is! Map || result['data'] is! Map) {
      throw Exception('รูปแบบข้อมูลไม่ถูกต้อง');
    }

    print('fetchReviewDetail: result = $result');

    return ReviewDetail.fromJson(result['data'] as Map<String, dynamic>);
  }

  /// ยกเลิกคำขอ — POST {domain_v2}/admin/requests/{uuid}/reject
  /// คืน true ถ้าสำเร็จ (status 200), throw error ถ้าล้มเหลว
  /// HTTP call อยู่ใน service เลย — ไม่แยกไฟล์ใน unity/
  Future<bool> cancelRequest({
    required String uuid,
    String? comment,
  }) async {
    if (uuid.isEmpty) {
      throw Exception('UUID is required');
    }
    final headers = await MyHeaders.build();
    final url =
        Uri.parse('${MyConstant().domain_v2}/admin/requests/$uuid/reject');
    final body = json.encode({
      if (comment != null) 'comment': comment,
    });
    // ignore: avoid_print
    print('[cancelRequest] URL = $url');
    // ignore: avoid_print
    print('[cancelRequest] HEADERS = $headers');
    // ignore: avoid_print
    print('[cancelRequest] BODY = $body');
    http.Response response;
    try {
      response = await http.post(url, headers: headers, body: body);
      // ignore: avoid_print
      print(
          '[cancelRequest] RESPONSE status=${response.statusCode} body=${response.body}');
    } catch (e) {
      throw Exception('ไม่สามารถเชื่อมต่อ API ได้: $e');
    }
    if (response.statusCode != 200) {
      throw Exception('ยกเลิกคำขอไม่สำเร็จ (status: ${response.statusCode})');
    }
    // ignore: avoid_print
    print('[LicenseRequestDetailService] cancelRequest ok uuid=$uuid');
    return true;
  }
}
