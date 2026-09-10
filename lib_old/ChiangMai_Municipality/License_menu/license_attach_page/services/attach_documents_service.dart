// ============================================================================
// attach_documents_service.dart
// ============================================================================
// Service — โหลด "รายการเอกสารที่ต้องแนบ" + อัปโหลด/ลบไฟล์แนบ
//
// เป็น service อิสระของ License Attach Detail Page
// ใช้ model ของตัวเอง (LicenseAttachDocument / LicenseAttachAttachment)
// ไม่ import / อ้างอิงไฟล์ใน Make_contract_CMM โดยตรง
// ============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../../../../Constant/Myconstant.dart';
import '../models/license_attach_document.dart';

/// ผลลัพธ์หลังอัปโหลด (status + parsed body)
class UploadResult {
  final int statusCode;
  final Map<String, dynamic>? body;
  const UploadResult(this.statusCode, this.body);

  bool get ok => statusCode == 200 || statusCode == 201;
}

/// Service สำหรับเรียก API จัดการเอกสารแนบของ License Attach
class AttachDocumentsService {
  AttachDocumentsService();

  /// โหลดรายการเอกสาร (พร้อม attachments ที่แนบแล้ว) ตาม request uuid
  /// คืน List<LicenseAttachDocument> (แต่ละ doc มี attachments ครบ)
  Future<List<LicenseAttachDocument>> fetchDocuments(String requestUuid) async {
    final headers = await MyHeaders.build();
    final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/requests/$requestUuid',
    );

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode != 200) {
        return <LicenseAttachDocument>[];
      }

      final jsonBody = json.decode(response.body);
      final documentsRaw = _findKeyAnywhere(jsonBody, 'documents');
      if (documentsRaw is! List) return <LicenseAttachDocument>[];

      return documentsRaw
          .whereType<Map<String, dynamic>>()
          .map<LicenseAttachDocument>((e) => LicenseAttachDocument.fromJson(e))
          .toList();
    } catch (_) {
      return <LicenseAttachDocument>[];
    }
  }

  /// อัปโหลดไฟล์แนบ → ผูกกับ document id
  ///
  /// [bytes] + [filename] สำหรับ web
  /// [file] (File) สำหรับ mobile/desktop
  Future<UploadResult> uploadAttachment({
    required String requestUuid,
    required int documentId,
    Uint8List? bytes,
    String? filename,
    File? file,
  }) async {
    final headers = await MyHeaders.build();
    final uri = Uri.parse(
      '${MyConstant().domain_v1}/admin/requests/$requestUuid/attachments',
    );

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..fields['document_id'] = documentId.toString();

    if (kIsWeb) {
      if (bytes == null || filename == null) {
        return const UploadResult(0, null);
      }
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: filename),
      );
    } else {
      if (file == null) {
        return const UploadResult(0, null);
      }
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: p.basename(file.path),
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    Map<String, dynamic>? body;
    try {
      body = json.decode(response.body) as Map<String, dynamic>;
    } catch (_) {
      body = null;
    }

    return UploadResult(response.statusCode, body);
  }

  /// ลบไฟล์แนบ (ตาม attachment uuid)
  Future<bool> deleteAttachment({
    required String requestUuid,
    required String attachmentUuid,
  }) async {
    final headers = await MyHeaders.build();
    final uri = Uri.parse(
      '${MyConstant().domain_v1}/admin/requests/$requestUuid/attachments/$attachmentUuid',
    );
    try {
      final response = await http.delete(uri, headers: headers);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  // ==========================================================================
  // Picker helpers (FilePicker / Camera)
  // ==========================================================================

  /// เปิด FilePicker แล้วคืน [bytes/filename] (web) หรือ [File] (mobile)
  /// คืน null ถ้าผู้ใช้ยกเลิก / ไฟล์มีปัญหา
  Future<PickedFile?> pickFromDevice() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;

    if (kIsWeb) {
      if (file.bytes == null) return null;
      return PickedFile.web(bytes: file.bytes!, name: file.name);
    } else {
      if (file.path == null) return null;
      return PickedFile.mobile(file: File(file.path!), name: file.name);
    }
  }

  /// เปิดกล้องถ่ายรูป (mobile only — web คืน null)
  Future<PickedFile?> pickFromCamera() async {
    if (kIsWeb) return null;
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked == null) return null;
    return PickedFile.mobile(
      file: File(picked.path),
      name: picked.name,
    );
  }

  /// โหลด bytes ของไฟล์แนบ (ใช้แสดง thumbnail / preview)
  ///
  /// - ถ้า [LicenseAttachAttachment.filePath] เป็น full URL → ใช้ตรงๆ พร้อม auth header
  /// - ถ้าเป็น relative path → ต่อกับ domain_v1
  /// - ถ้ามี [LicenseAttachAttachment.uuid] → ใช้ endpoint
  ///   `/request-snapshot-attachments/{uuid}/preview` ซึ่งรองรับ auth
  Future<Uint8List?> fetchAttachmentBytes(LicenseAttachAttachment att) async {
    final uuid = att.uuid?.toString() ?? '';
    final filePath = att.filePath?.toString() ?? '';
    final fileName = att.fileName?.toString() ?? '';
    if (uuid.isEmpty && filePath.isEmpty) {
      // ignore: avoid_print
      print('[fetchAttachmentBytes] ❌ ไม่มีทั้ง uuid และ filePath');
      return null;
    }

    final headers = await MyHeaders.build();
    String url;
    if (uuid.isNotEmpty) {
      // ✨ ใช้ endpoint ที่ถูกต้อง: /admin/requests/attachments/{uuid}/preview
      url =
          '${MyConstant().domain_v1}/admin/requests/attachments/$uuid/preview';
    } else if (filePath.startsWith('http')) {
      url = filePath;
    } else {
      final base = MyConstant().domain_v1;
      url = filePath.startsWith('/') ? '$base$filePath' : '$base/$filePath';
    }

    // ignore: avoid_print
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    // ignore: avoid_print
    print('🔍 [fetchAttachmentBytes]');
    // ignore: avoid_print
    print('  fileName: $fileName');
    // ignore: avoid_print
    print('  uuid: $uuid');
    // ignore: avoid_print
    print('  filePath: $filePath');
    // ignore: avoid_print
    print('  url: $url');
    // ignore: avoid_print
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      // ignore: avoid_print
      print('📥 [fetchAttachmentBytes] Status: ${response.statusCode}');
      // ignore: avoid_print
      print(
          '📥 [fetchAttachmentBytes] Content-Length: ${response.contentLength}');
      // ignore: avoid_print
      print(
          '📥 [fetchAttachmentBytes] Content-Type: ${response.headers['content-type']}');
      // ignore: avoid_print
      print(
          '📥 [fetchAttachmentBytes] Body bytes: ${response.bodyBytes.length}');

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      } else {
        // ignore: avoid_print
        print(
            '❌ [fetchAttachmentBytes] ไม่สำเร็จ — Status ${response.statusCode}, bytes=${response.bodyBytes.length}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('❌ [fetchAttachmentBytes] Exception: $e');
    }
    return null;
  }

  // ==========================================================================
  // Utils
  // ==========================================================================

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
}

/// ข้อมูลไฟล์ที่เลือก (รองรับทั้ง web/mobile)
class PickedFile {
  final Uint8List? bytes;
  final File? file;
  final String name;

  PickedFile.web({required this.bytes, required this.name}) : file = null;

  PickedFile.mobile({required this.file, required this.name}) : bytes = null;
}
