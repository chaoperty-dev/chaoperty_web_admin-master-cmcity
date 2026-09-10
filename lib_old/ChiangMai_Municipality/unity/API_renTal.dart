import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../Constant/Myconstant.dart';

import '../../Model/GetExp_type_auto.dart';
import '../../Model/GetRenTal_Model.dart';

Future<RenTalModel?> read_GC_rental() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  var ren = preferences.getString('renTalSer');
  var ser_user = preferences.getString('ser');
  final headers = await MyHeaders.build(); // ✅ ต้อง await
  String url =
      '${MyConstant().domain}/GC_rental_setring.php?isAdd=true&ren=$ren';

  try {
    final response = await http.get(Uri.parse(url))
      ..headers.addAll(headers); // ✅ ต้องใส่ headers ด้วย
    final result = json.decode(response.body);

    if (result != null && result is List && result.isNotEmpty) {
      final map = result.first;
      final renTalModel = RenTalModel.fromJson(map);
      // เพิ่ม ser_user ให้กับ model ถ้าต้องการ
      return renTalModel;
    }
  } catch (e, stackTrace) {
    //print('❌ เกิดข้อผิดพลาดใน read_GC_rental: $e');
    //print('🪵 StackTrace:\n$stackTrace');
  }

  return null;
}
