// ============================================================================
// license_verify_checklist_service.dart
// ============================================================================
// Service for /api/v1/admin/requests/{uuid}/checklist/preview
// + /api/v1/admin/requests/{uuid}/checklist  (POST submit)
// ============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:chaoperty/Constant/Myconstant.dart';

import '../models/license_verify_checklist_model.dart';

/// ผลลัพธ์จากการ submit checklist
class LicenseverifyChecklistSubmitResult {
  final bool success;
  final int statusCode;
  final String? message;
  final String? rawBody;

  const LicenseverifyChecklistSubmitResult({
    required this.success,
    required this.statusCode,
    this.message,
    this.rawBody,
  });
}

class LicenseverifyChecklistService {
  static Future<LicenseverifyChecklistPreview> fetchByUuid(
      String? requestUuid) async {
    final uuid = requestUuid ?? 'a2c54e97-8c06-4dca-8007-9f6b34d9e93f';
    final headers = await MyHeaders.build();
    final url = Uri.parse(
        '${MyConstant().domain_v1}/admin/requests/$uuid/checklist/preview');
    final request = http.Request('GET', url)..headers.addAll(headers);

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
    final body = await response.stream.bytesToString();
    final jsonBody = json.decode(body) as Map<String, dynamic>;
    return LicenseverifyChecklistPreview.fromJson(
        jsonBody['data'] as Map<String, dynamic>);
  }

  /// POST /api/v1/admin/requests/{uuid}/checklist
  /// submit checklist หลังจากผู้ใช้กดบันทึกใน step 2
  static Future<LicenseverifyChecklistSubmitResult> submitChecklist(
    String? requestUuid, {
    Map<String, String>? extraHeaders,
  }) async {
    final uuid = requestUuid ?? 'a2c54e97-8c06-4dca-8007-9f6b34d9e93f';
    final baseHeaders = await MyHeaders.build();
    final headers = <String, String>{
      ...baseHeaders,
      'Accept': 'application/json',
      if (extraHeaders != null) ...extraHeaders,
    };

    final url =
        Uri.parse('${MyConstant().domain_v1}/admin/requests/$uuid/checklist');
    final request = http.Request('POST', url)..headers.addAll(headers);

    try {
      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();
      final ok = streamed.statusCode == 200;
      String? message;
      try {
        final j = json.decode(body);
        if (j is Map && j['message'] is String) {
          message = j['message'] as String;
        }
      } catch (_) {}
      return LicenseverifyChecklistSubmitResult(
        success: ok,
        statusCode: streamed.statusCode,
        message: message ?? streamed.reasonPhrase,
        rawBody: body,
      );
    } catch (e) {
      debugPrint('Submit checklist error: $e');
      return LicenseverifyChecklistSubmitResult(
        success: false,
        statusCode: -1,
        message: e.toString(),
      );
    }
  }
}

