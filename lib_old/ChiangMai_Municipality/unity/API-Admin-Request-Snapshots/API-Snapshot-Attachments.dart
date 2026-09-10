import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../Constant/Myconstant.dart';
import 'Models/snapshot_attachment_model.dart';

class APISnapshotAttachments {
  // ใช้ MyConstant().domain_v1 และ MyHeaders.build() เหมือนกับโปรเจคอื่นๆ

  /// ดึงรายการ Attachments ของ Snapshot ตาม snapshotUuid
  ///
  /// [snapshotUuid] - UUID ของ snapshot ที่ต้องการดึง attachments
  ///
  /// Returns [SnapshotAttachmentsResponse] หรือ throw Exception ถ้าเกิด error
  static Future<SnapshotAttachmentsResponse> getAttachments(
      String snapshotUuid) async {
    final url = Uri.parse(
        '${MyConstant().domain_v1}/admin/request-snapshots/$snapshotUuid/attachments');

    try {
      final headers = await MyHeaders.build();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return SnapshotAttachmentsResponse.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to load attachments: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching attachments: $e');
    }
  }

  /// ดึงรายการ Attachments แบบคืนค่าเป็น List โดยตรง
  ///
  /// [snapshotUuid] - UUID ของ snapshot ที่ต้องการดึง attachments
  ///
  /// Returns [List<SnapshotAttachmentModel>] หรือ empty list ถ้าไม่มีข้อมูล
  static Future<List<SnapshotAttachmentModel>> getAttachmentsList(
      String snapshotUuid) async {
    print(
        '[API-Snapshot-Attachments] 🚀 เริ่มดึง attachments สำหรับ snapshotUuid: $snapshotUuid');
    try {
      final response = await getAttachments(snapshotUuid);
      final data = response.data ?? [];
      print(
          '[API-Snapshot-Attachments] ✅ ดึง attachments สำเร็จ: ${data.length} รายการ');
      for (var i = 0; i < data.length; i++) {
        print(
            '[API-Snapshot-Attachments]   [$i] File: ${data[i].fileName}, Type: ${data[i].fileType}, Size: ${data[i].fileSize}');
      }
      return data;
    } catch (e) {
      print('[API-Snapshot-Attachments] ❌ Error getting attachments list: $e');
      return [];
    }
  }

  /// ตัวอย่างการใช้งาน
  static void exampleUsage() async {
    try {
      // ดึงรายการ attachments
      final attachments =
          await getAttachmentsList('019e24a8-282b-71d0-a2c5-b505bafeaf8d');

      for (var attachment in attachments) {
        print('File: ${attachment.fileName}');
        print('Type: ${attachment.fileType}');
        print('Size: ${attachment.fileSize} bytes');
        print('Path: ${attachment.filePath}');
        print('---');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
