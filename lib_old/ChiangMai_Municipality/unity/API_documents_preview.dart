import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Constant/Myconstant.dart';

import '../../Model/GetExp_type_auto.dart';
import '../../Model/GetRenTal_Model.dart';
import '../Model/AutoExpTrans_ModelCMM.dart';
import '../Model/Payments_Model.dart';

Future<http.Response?> documentsPreview(
    String? uuidRequest, String? documentuuid) async {
  final headers = await MyHeaders.build(); // 🔐 สร้าง headers พร้อม token

  final url = Uri.parse(
    '${MyConstant().domain_v1}/admin/documents/$documentuuid/preview',
  );

  //print('📤 GET Image ApprovalsCheckUp: $url');
  // //print('🧾 Headers: $headers');

  try {
    final response = await http.get(url, headers: headers);
    //print('[${response.statusCode}]');

    if (response.statusCode == 200) {
      //print('✅ ApprovalsCheckUp image loaded successfully');
    } else {
      //print(
      //   '❌ Failed to load image [${response.statusCode}]: ${response.body}');
    }

    return response;
  } catch (e, stackTrace) {
    //print('❌ Exception occurred: $e');
    // //print('🧭 Stack trace:\n$stackTrace');
    return null;
  }
}
