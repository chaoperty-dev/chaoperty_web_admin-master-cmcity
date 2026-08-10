import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../Constant/Myconstant.dart';
import 'Models/snapshot_attachment_model.dart';

class APIPreviewSnapshotAttachment {
  // ใช้ MyConstant().domain_v1 และ MyHeaders.build() เหมือนกับโปรเจคอื่นๆ

  /// ดึงข้อมูล Preview ของ Attachment ตาม attachmentUuid
  ///
  /// [attachmentUuid] - UUID ของ attachment ที่ต้องการดึง preview
  ///
  /// Returns [SnapshotAttachmentPreviewResponse] หรือ throw Exception ถ้าเกิด error
  static Future<SnapshotAttachmentPreviewResponse> getPreview(
      String attachmentUuid) async {
    final url = Uri.parse(
        '${MyConstant().domain_v1}/admin/request-snapshot-attachments/$attachmentUuid/preview');

    try {
      final headers = await MyHeaders.build();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return SnapshotAttachmentPreviewResponse.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to load attachment preview: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching attachment preview: $e');
    }
  }

  /// ดึงข้อมูล Preview แบบคืนค่าเป็น Model โดยตรง
  ///
  /// [attachmentUuid] - UUID ของ attachment ที่ต้องการดึง preview
  ///
  /// Returns [SnapshotAttachmentModel?] หรือ null ถ้าไม่มีข้อมูล
  static Future<SnapshotAttachmentModel?> getPreviewData(
      String attachmentUuid) async {
    try {
      final response = await getPreview(attachmentUuid);
      return response.data;
    } catch (e) {
      print('Error getting preview data: $e');
      return null;
    }
  }

  /// ตัวอย่างการใช้งาน
  static void exampleUsage() async {
    try {
      // ดึงข้อมูล preview
      final preview =
          await getPreviewData('019e24d8-8465-7142-acaa-79787f157664');

      if (preview != null) {
        print('File: ${preview.fileName}');
        print('Type: ${preview.fileType}');
        print('Size: ${preview.fileSize} bytes');
        print('Path: ${preview.filePath}');
        print('Snapshot UUID: ${preview.snapshot?.uuid}');
        print('Snapshot Version: ${preview.snapshot?.snapshotVersion}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
