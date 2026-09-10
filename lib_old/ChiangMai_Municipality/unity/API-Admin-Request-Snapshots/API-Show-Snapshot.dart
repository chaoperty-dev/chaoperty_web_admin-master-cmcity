import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../Constant/Myconstant.dart';
import 'Models/snapshot_detail_model.dart';

class APIShowSnapshot {
  // ใช้ MyConstant().domain_v1 และ MyHeaders.build() เหมือนกับโปรเจคอื่นๆ

  /// ดึงข้อมูล Snapshot Detail ตาม snapshotUuid
  ///
  /// [snapshotUuid] - UUID ของ snapshot ที่ต้องการดึงข้อมูล
  ///
  /// Returns [SnapshotDetailResponse] หรือ throw Exception ถ้าเกิด error
  static Future<SnapshotDetailResponse> getSnapshot(String snapshotUuid) async {
    final url = Uri.parse(
        '${MyConstant().domain_v1}/admin/request-snapshots/$snapshotUuid');

    try {
      final headers = await MyHeaders.build();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return SnapshotDetailResponse.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to load snapshot: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching snapshot: $e');
    }
  }

  /// ดึงข้อมูล Snapshot แบบคืนค่าเป็น Model โดยตรง
  ///
  /// [snapshotUuid] - UUID ของ snapshot ที่ต้องการดึงข้อมูล
  ///
  /// Returns [SnapshotDetailModel?] หรือ null ถ้าไม่มีข้อมูล
  static Future<SnapshotDetailModel?> getSnapshotData(
      String snapshotUuid) async {
    try {
      final response = await getSnapshot(snapshotUuid);
      return response.data;
    } catch (e) {
      print('Error getting snapshot data: $e');
      return null;
    }
  }

  /// ตัวอย่างการใช้งาน
  static void exampleUsage() async {
    try {
      // ดึงข้อมูล snapshot
      final snapshot =
          await getSnapshotData('019e24a8-282b-71d0-a2c5-b505bafeaf8d');

      if (snapshot != null) {
        print('UUID: ${snapshot.uuid}');
        print('Version: ${snapshot.snapshotVersion}');
        print('Status: ${snapshot.sourceStatus}');
        print('Client: ${snapshot.client?.cname}');
        print('Client Address: ${snapshot.client?.addr1}');
        print('Attachments Count: ${snapshot.attachments?.length}');

        // แสดงรายการ attachments
        if (snapshot.attachments != null) {
          for (var attachment in snapshot.attachments!) {
            print('  - ${attachment.fileName} (${attachment.fileType})');
          }
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
