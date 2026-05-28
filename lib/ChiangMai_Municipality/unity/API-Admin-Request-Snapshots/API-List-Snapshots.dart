import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../Constant/Myconstant.dart';
import 'Models/snapshot_list_model.dart';

class APIListSnapshots {
  // ใช้ MyConstant().domain_v1 และ MyHeaders.build() เหมือนกับโปรเจคอื่นๆ

  /// ดึงรายการ Snapshots ตาม clients_uuid
  ///
  /// [clientsUuid] - UUID ของ client ที่ต้องการดึง snapshots
  /// [page] - หมายเลขหน้า (default: 1)
  ///
  /// Returns [SnapshotListResponse] หรือ throw Exception ถ้าเกิด error
  static Future<SnapshotListResponse> getSnapshots(String clientsUuid,
      {int page = 1}) async {
    final url = Uri.parse(
        '${MyConstant().domain_v1}/admin/request-snapshots?clients_uuid=$clientsUuid&page=$page');

    try {
      final headers = await MyHeaders.build();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return SnapshotListResponse.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to load snapshots: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching snapshots: $e');
    }
  }

  /// ดึงรายการ Snapshots แบบคืนค่าเป็น List โดยตรง
  ///
  /// [clientsUuid] - UUID ของ client ที่ต้องการดึง snapshots
  /// [page] - หมายเลขหน้า (default: 1)
  ///
  /// Returns [List<SnapshotListItemModel>] หรือ empty list ถ้าไม่มีข้อมูล
  static Future<List<SnapshotListItemModel>> getSnapshotsList(
      String clientsUuid,
      {int page = 1}) async {
    print(
        '[API-List-Snapshots] 🚀 เริ่มดึง snapshots สำหรับ clientsUuid: $clientsUuid');
    try {
      final response = await getSnapshots(clientsUuid, page: page);
      final data = response.data ?? [];
      print(
          '[API-List-Snapshots] ✅ ดึง snapshots สำเร็จ: ${data.length} รายการ');
      for (var i = 0; i < data.length; i++) {
        print(
            '[API-List-Snapshots]   [$i] UUID: ${data[i].uuid}, Version: ${data[i].snapshotVersion}, Attachments: ${data[i].attachmentsCount}');
      }
      return data;
    } catch (e) {
      print('[API-List-Snapshots] ❌ Error getting snapshots list: $e');
      return [];
    }
  }

  /// ตัวอย่างการใช้งาน
  static void exampleUsage() async {
    try {
      // ดึงรายการ snapshots
      final snapshots =
          await getSnapshotsList('654b2987-1ebd-11f1-bf86-bc241148938e');

      for (var snapshot in snapshots) {
        print('UUID: ${snapshot.uuid}');
        print('Version: ${snapshot.snapshotVersion}');
        print('Status: ${snapshot.sourceStatus}');
        print('Client: ${snapshot.client?.cname}');
        print('Attachments Count: ${snapshot.attachmentsCount}');
        print('---');
      }

      // ดึงข้อมูลพร้อม pagination
      final response =
          await getSnapshots('654b2987-1ebd-11f1-bf86-bc241148938e');
      print('Current Page: ${response.meta?.currentPage}');
      print('Total: ${response.meta?.total}');
      print('Per Page: ${response.meta?.perPage}');
    } catch (e) {
      print('Error: $e');
    }
  }
}
