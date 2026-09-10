import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../Constant/Myconstant.dart';

import '../../Model/GetExp_type_auto.dart';

Future<List<ExpAutoModel>> read_GC_ExpAuto() async {
  List<ExpAutoModel> expAutoModels = [];
  SharedPreferences preferences = await SharedPreferences.getInstance();
  var ren = preferences.getString('renTalSer');
  final headers = await MyHeaders.build(); // ✅ ต้อง await
  final url = '${MyConstant().domain}/GC_exp_setring.php?isAdd=true&ren=$ren';

  try {
    final response = await http.get(Uri.parse(url))
      ..headers.addAll(headers); // ✅ ต้องใส่ headers ด้วย

    // ตรวจสอบสถานะ HTTP
    if (response.statusCode == 200) {
      final body = response.body;

      try {
        final decoded = json.decode(body);

        if (decoded is List) {
          for (var i = 0; i < decoded.length; i++) {
            final item = decoded[i];
            if (item is Map<String, dynamic>) {
              final auto = item['auto'];
              if (auto == '1' || auto == 1) {
                try {
                  expAutoModels.add(ExpAutoModel.fromJson(item));
                } catch (e) {
                  //print('❌ Error แปลงข้อมูลที่ index $i: $e\n📄 ข้อมูล: $item');
                }
              } else {
                // //print('ℹ️ ข้าม item (auto != 1) ที่ index $i');
              }
            } else {
              //print('⚠️ ข้อมูลที่ index $i ไม่ใช่ Map<String, dynamic>: $item');
            }
          }
        } else {
          //print('❌ รูปแบบ JSON ไม่ใช่ List: $decoded');
        }
      } catch (jsonErr) {
        //print('❌ ผิดพลาดขณะแปลง JSON: $jsonErr');
        //print('📦 ตอบกลับที่ได้: $body');
      }
    } else {
      //print('❌ HTTP ${response.statusCode} : ${response.reasonPhrase}');
    }
  } catch (e, s) {
    //print('❌ ข้อผิดพลาดขณะเชื่อมต่อ HTTP: $e');
    //print('🧭 Stack trace: $s');
  }

  return expAutoModels;
}
