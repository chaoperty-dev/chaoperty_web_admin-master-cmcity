// ============================================================================
// license_attach_checklist_service.dart
// ============================================================================
// Service for /api/v1/admin/requests/{uuid}/checklist/preview
// + /api/v1/admin/requests/{uuid}  (full request — ดึงเอกสารทั้งหมด)
// + /api/v1/admin/requests/{uuid}/checklist  (POST submit)
// ============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:chaoperty/Constant/Myconstant.dart';

import '../models/license_attach_checklist_model.dart';

/// ผลลัพธ์จากการ submit checklist
class LicenseAttachChecklistSubmitResult {
  final bool success;
  final int statusCode;
  final String? message;
  final String? rawBody;

  /// ข้อมูลจาก response.data (กรณีบันทึกสำเร็จ)
  final String? checklistUuid;
  final String? checklistNo;
  final String? signerName;
  final String? signerPosition;
  final DateTime? signedAt;

  /// status ของ request ที่ response กลับมา (เช่น documents_submitted)
  final String? requestStatus;

  const LicenseAttachChecklistSubmitResult({
    required this.success,
    required this.statusCode,
    this.message,
    this.rawBody,
    this.checklistUuid,
    this.checklistNo,
    this.signerName,
    this.signerPosition,
    this.signedAt,
    this.requestStatus,
  });
}

class LicenseAttachChecklistService {
  /// ดึง checklist ที่บันทึกแล้ว (GET /admin/requests/{uuid}/checklist)
  /// คืนข้อมูล attachments + signer + version + checked_at
  /// ถ้ายังไม่เคยบันทึก → 404 → fallback ไปใช้ preview
  static Future<LicenseAttachChecklistPreview?> fetchSavedChecklist(
      String? requestUuid) async {
    final uuid = requestUuid ?? '';
    final headers = await MyHeaders.build();
    final url =
        Uri.parse('${MyConstant().domain_v1}/admin/requests/$uuid/checklist');
    try {
      final request = http.Request('GET', url)..headers.addAll(headers);
      final response = await request.send();
      if (response.statusCode != 200) return null;
      final body = await response.stream.bytesToString();
      final jsonBody = json.decode(body) as Map<String, dynamic>;
      final data = jsonBody['data'] as Map<String, dynamic>?;
      if (data == null) return null;
      return LicenseAttachChecklistPreview.fromSavedJson(data);
    } catch (_) {
      return null;
    }
  }

  /// ดึง checklist preview (เฉพาะเอกสารที่แนบแล้ว)
  static Future<LicenseAttachChecklistPreview> fetchByUuid(
      String? requestUuid) async {
    final uuid = requestUuid ?? '';
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
    return LicenseAttachChecklistPreview.fromJson(
        jsonBody['data'] as Map<String, dynamic>);
  }

  /// ดึง status ของ request (GET /admin/requests/{uuid})
  /// คืน string เช่น 'draft', 'documents_submitted', 'in_progress' — หรือ null ถ้าดึงไม่ได้
  static Future<String?> fetchRequestStatus(String? requestUuid) async {
    final uuid = requestUuid ?? '';
    try {
      final headers = await MyHeaders.build();
      final url = Uri.parse('${MyConstant().domain_v1}/admin/requests/$uuid');
      final response = await http.get(url, headers: headers);
      if (response.statusCode != 200) return null;
      final body = json.decode(response.body);
      // status อยู่ใต้ data (ตาม standard response shape)
      final data = body is Map ? body['data'] : null;
      if (data is Map) {
        final s = data['status'];
        if (s is String && s.isNotEmpty) return s;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// POST /api/v1/admin/requests/{uuid}/submit
  /// ยิงเมื่อ request ยังอยู่ในสถานะ `draft` เพื่อเปลี่ยนเป็น `documents_submitted`
  /// ก่อนจะยิง checklist POST ตามมา
  static Future<LicenseAttachChecklistSubmitResult> submitRequest(
    String? requestUuid, {
    Map<String, String>? extraHeaders,
  }) async {
    final uuid = requestUuid ?? '';
    final baseHeaders = await MyHeaders.build();
    final headers = <String, String>{
      ...baseHeaders,
      'Accept': 'application/json',
      if (extraHeaders != null) ...extraHeaders,
    };

    final url =
        Uri.parse('${MyConstant().domain_v1}/admin/requests/$uuid/submit');
    final request = http.Request('POST', url)..headers.addAll(headers);
    print('LicenseAttachChecklistSubmitResult: $url');
    try {
      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();
      final ok = streamed.statusCode >= 200 && streamed.statusCode < 300;
      String? message;
      String? requestStatus;
      try {
        final j = json.decode(body);
        if (j is Map) {
          if (j['message'] is String) message = j['message'] as String;
          final data = j['data'];
          if (data is Map && data['status'] is String) {
            requestStatus = data['status'] as String;
          }
        }
      } catch (_) {}
      return LicenseAttachChecklistSubmitResult(
        success: ok,
        statusCode: streamed.statusCode,
        message: message ?? streamed.reasonPhrase,
        rawBody: body,
        requestStatus: requestStatus,
      );
    } catch (e) {
      debugPrint('Submit request (draft) error: $e');
      return LicenseAttachChecklistSubmitResult(
        success: false,
        statusCode: -1,
        message: e.toString(),
      );
    }
  }

  /// ดึงข้อมูล request ทั้งหมด (รวมเอกสารที่ต้องแนบทั้งหมด — ทั้งอัพแล้วและยังไม่อัพ)
  /// Endpoint: GET /admin/requests/{uuid}
  /// คืนแค่ list ของ attachments (ทั้งหมด)
  static Future<List<LicenseAttachChecklistAttachment>> fetchAllAttachments(
      String? requestUuid) async {
    final uuid = requestUuid ?? '';
    final headers = await MyHeaders.build();
    final url = Uri.parse('${MyConstant().domain_v1}/admin/requests/$uuid');
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode != 200) return [];
      final jsonBody = json.decode(response.body);
      final docsRaw = _findKeyAnywhere(jsonBody, 'documents');
      if (docsRaw is! List) return [];

      final result = <LicenseAttachChecklistAttachment>[];
      for (final doc in docsRaw) {
        if (doc is! Map) continue;
        final map = Map<String, dynamic>.from(doc);
        // รวม attachments ของ doc นี้ (ถ้ามี)
        final atts = map['attachments'];
        if (atts is List && atts.isNotEmpty) {
          // ใช้ attachment แรกเป็นตัวแทนของ doc
          final first = atts.first;
          if (first is Map) {
            final att = LicenseAttachChecklistAttachment.fromJson(
              Map<String, dynamic>.from(first),
            );
            result.add(att);
          }
        } else {
          // ไม่มี attachment — สร้าง placeholder สำหรับเอกสารที่ยังไม่อัพ
          final clientDoc = map['client_document'] is Map
              ? Map<String, dynamic>.from(map['client_document'] as Map)
              : null;
          final id = _toInt(
                  map['id'] ?? map['client_document_id'] ?? clientDoc?['id']) ??
              0;
          final nameTh = (map['name_th'] ??
                  map['nameTh'] ??
                  clientDoc?['name_th'] ??
                  clientDoc?['nameTh'] ??
                  '')
              .toString();
          final code = (map['code'] ?? clientDoc?['code'] ?? '').toString();
          final required = map['required'] == true ||
              clientDoc?['required'] == true ||
              map['is_required'] == true;
          result.add(LicenseAttachChecklistAttachment(
            clientDocumentId: id,
            code: code,
            nameTh: nameTh,
            required: required,
            showAfterSubmit: 0,
          ));
        }
      }
      return result;
    } catch (_) {
      return [];
    }
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    if (v is double) return v.toInt();
    return null;
  }

  /// หา key ซ้อนลึกใน JSON (ใช้กับ response ของ API ที่ห่อหลายชั้น)
  static dynamic _findKeyAnywhere(dynamic json, String key) {
    if (json is Map<String, dynamic>) {
      if (json.containsKey(key)) return json[key];
      for (final v in json.values) {
        final r = _findKeyAnywhere(v, key);
        if (r != null) return r;
      }
    } else if (json is List) {
      for (final item in json) {
        final r = _findKeyAnywhere(item, key);
        if (r != null) return r;
      }
    }
    return null;
  }

  /// POST /api/v1/admin/requests/{uuid}/checklist
  /// submit checklist หลังจากผู้ใช้กดบันทึกใน step 2
  static Future<LicenseAttachChecklistSubmitResult> submitChecklist(
    String? requestUuid, {
    Map<String, String>? extraHeaders,
  }) async {
    final uuid = requestUuid ?? '';
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
      // รับทั้ง 200 OK และ 201 Created
      final ok = streamed.statusCode >= 200 && streamed.statusCode < 300;
      String? message;
      String? checklistUuid;
      String? checklistNo;
      String? signerName;
      String? signerPosition;
      DateTime? signedAt;
      try {
        final j = json.decode(body);
        if (j is Map) {
          if (j['message'] is String) message = j['message'] as String;
          final data = j['data'];
          if (data is Map) {
            checklistUuid = data['uuid'] as String?;
            checklistNo = data['checklist_no'] as String?;
            signerName = data['signer_name'] as String?;
            signerPosition = data['signer_position'] as String?;
            signedAt = _parseDateTime(data['signed_at']);
          }
        }
      } catch (_) {}
      return LicenseAttachChecklistSubmitResult(
        success: ok,
        statusCode: streamed.statusCode,
        message: message ?? streamed.reasonPhrase,
        rawBody: body,
        checklistUuid: checklistUuid,
        checklistNo: checklistNo,
        signerName: signerName,
        signerPosition: signerPosition,
        signedAt: signedAt,
      );
    } catch (e) {
      debugPrint('Submit checklist error: $e');
      return LicenseAttachChecklistSubmitResult(
        success: false,
        statusCode: -1,
        message: e.toString(),
      );
    }
  }

  static DateTime? _parseDateTime(dynamic value) {
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
}
