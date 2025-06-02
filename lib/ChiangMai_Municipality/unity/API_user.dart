import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Constant/Myconstant.dart';
import '../Model/Properties_Model.dart';
import '../Model/User_ModelCMM.dart';

Future<List<UserModelCMM>> read_GC_UserCMM() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  var ren = preferences.getString('renTalSer');
  var ser_user = preferences.getString('ser');

  String url = '${MyConstant().domain_v1}/admin/users';

  try {
    final response = await http.get(Uri.parse(url));
    final jsonRes = json.decode(response.body);

    if (jsonRes != null && jsonRes['data'] is List) {
      final List list = jsonRes['data'];
      print('📦 JSON Response: ${json.encode(jsonRes)}');

      return list.map((e) => UserModelCMM.fromJson(e)).toList();
    }
  } catch (e, stackTrace) {
    print('❌ Error in read_GC_User: $e');
    print('🪵 StackTrace: $stackTrace');
  }

  return [];
}

Future<http.Response?> read_GC_UserUuidCMM(String usersuuid) async {
  String url = '${MyConstant().domain_v1}/admin/users/$usersuuid';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      print('✅ UserUuid Success: ${response.body}');
    } else {
      print('❌ UserUuid Failed [${response.statusCode}]: ${response.body}');
    }
    return response;
  } catch (e, stack) {
    print('❌ Exception during UserUuid request: $e');
    print('🧭 StackTrace:\n$stack');
    return null;
  }
}
// Future<List<UserModelCMM>> read_GC_UserUuidCMM(String usersuuid) async {
//   SharedPreferences preferences = await SharedPreferences.getInstance();
//   var ren = preferences.getString('renTalSer');
//   var ser_user = preferences.getString('ser');

//   String url = '${MyConstant().domain_v1}/admin/users/$usersuuid';

//   try {
//     final response = await http.get(Uri.parse(url));
//     final jsonRes = json.decode(response.body);

//     // ✅ แก้ตรงนี้: เช็กว่า data เป็น Map
//     if (jsonRes != null && jsonRes['data'] is Map<String, dynamic>) {
//       final dataMap = jsonRes['data'];
//       print('📦 UserUuid JSON Response: ${json.encode(jsonRes)}');

//       // ✅ คืน List จาก user เดียว (ตาม signature เดิม)
//       return [UserModelCMM.fromJson(dataMap)];
//     }
//   } catch (e, stackTrace) {
//     print('❌ Error in read_GC_User: $e');
//     print('🪵 StackTrace: $stackTrace');
//   }

//   return [];
// }

// Future<List<UserModelCMM>> read_GC_UserUuidCMM(String usersuuid) async {
//   String url = '${MyConstant().domain_v1}/admin/users/$usersuuid';

//   try {
//     final response = await http.get(Uri.parse(url));
//     final jsonRes = json.decode(response.body);

//     if (jsonRes != null && jsonRes['data'] is Map<String, dynamic>) {
//       final dataMap = jsonRes['data'];
//       return [UserModelCMM.fromJson(dataMap)];
//     }
//   } catch (e, stackTrace) {
//     print('❌ Error in read_GC_UserUuidCMM: $e');
//     print('🪵 StackTrace: $stackTrace');
//   }

//   return [];
// }
