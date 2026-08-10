import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Constant/Myconstant.dart';
import '../Model/Properties_Model.dart';

Future<List<PropertiesModel>> read_GC_properties(
    String? zser, String? aser, String? length) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  var ren = preferences.getString('renTalSer');
  var ser_user = preferences.getString('ser');
  final headers = await MyHeaders.build(); // ✅ ต้อง await
  String url = (zser == null ||
          zser.toString() == '' ||
          zser.toString() == 'null' ||
          zser.toString() == '0')
      ? '${MyConstant().domain_v1}/admin/requests/properties?per_page=5000'
      : '${MyConstant().domain_v1}/admin/requests/properties?per_page=1000&q=$zser';
  print(url);
  try {
    final response = await http.get(Uri.parse(url), headers: headers);

    final jsonRes = json.decode(response.body);

    if (jsonRes != null && jsonRes['data'] is List) {
      final List list = jsonRes['data'];
      // ✅ กรองรายการที่ parse ไม่ผ่านออก — บาง entry มี field ผิด type (เช่น payment_json เป็น object ไม่ใช่ string)
      final out = <PropertiesModel>[];
      for (final e in list) {
        try {
          out.add(PropertiesModel.fromJson(e));
        } catch (parseErr) {
          print('⚠️ skip malformed property entry: $parseErr');
        }
      }
      return out;
    }
    print(jsonRes);
  } catch (e, stackTrace) {
    print('❌ Error in read_GC_properties: $e');
    print('🪵 StackTrace: $stackTrace');
  }

  return [];
}

// Future<List<PropertiesModel>> read_GC_properties(
//     String? zser, String? aser) async {
//   SharedPreferences preferences = await SharedPreferences.getInstance();
//   var ren = preferences.getString('renTalSer');
//   var ser_user = preferences.getString('ser');
//   String url = '${MyConstant().domain_v1}/admin/requests/properties';
//   try {
//     final response = await http.get(Uri.parse(url));
//     final result = json.decode(response.body);
//     //print('🪵 StackTrace:\n$result');
//     if (result != null && result is List) {
//       return result
//           .map<PropertiesModel>((json) => PropertiesModel.fromJson(json))
//           .toList();
//     }
//   } catch (e, stackTrace) {
//     //print('❌ เกิดข้อผิดพลาดใน read_GC_properties: $e');
//     //print('🪵 StackTrace:\n$stackTrace');
//   }

//   return [];
// }

// Future<List<PropertiesModel>> read_GC_properties(
//     String? zser, String? aser) async {
//   SharedPreferences preferences = await SharedPreferences.getInstance();
//   var ren = preferences.getString('renTalSer');
//   var ser_user = preferences.getString('ser');

//   String url = '${MyConstant().domain_v1}/admin/requests/properties';

//   try {
//     final response = await http.get(Uri.parse(url));
//     final result = json.decode(response.body);

//     if (result != null &&
//         result is Map<String, dynamic> &&
//         result['data'] != null &&
//         result['data'] is List) {
//       return (result['data'] as List)
//           .map<PropertiesModel>((json) => PropertiesModel.fromJson(json))
//           .toList();
//     }
//   } catch (e, stackTrace) {
//     //print('❌ เกิดข้อผิดพลาดใน read_GC_properties: $e');
//     //print('🪵 StackTrace:\n$stackTrace');
//   }

//   return [];
// }
