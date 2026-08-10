import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Constant/Myconstant.dart';
import '../../Model/request_properties_model.dart';

/// API Service สำหรับดึงข้อมูล Request Properties
///
/// ใช้สำหรับดึง clients_uuid จาก request uuid
class APIRequestProperties {
  /// ดึงข้อมูล Request ตาม uuid
  ///
  /// [requestUuid] - UUID ของ request ที่ต้องการดึงข้อมูล
  ///
  /// Returns [RequestPropertiesResponseModel] หรือ throw Exception ถ้าเกิด error
  static Future<RequestPropertiesResponseModel> getRequestProperties(
      String requestUuid) async {
    final url =
        Uri.parse('${MyConstant().domain_v1}/admin/requests/$requestUuid');

    try {
      final headers = await MyHeaders.build();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return RequestPropertiesResponseModel.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to load request properties: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching request properties: $e');
    }
  }

  /// ดึง clients_uuid จาก request uuid แบบคืนค่าเป็น String โดยตรง
  ///
  /// [requestUuid] - UUID ของ request
  ///
  /// Returns [String?] clients_uuid หรือ null ถ้าไม่มีข้อมูล
  static Future<String?> getClientsUuid(String requestUuid) async {
    try {
      final response = await getRequestProperties(requestUuid);
      return response.data?.client?.uuid;
    } catch (e) {
      print('Error getting clients uuid: $e');
      return null;
    }
  }
}
