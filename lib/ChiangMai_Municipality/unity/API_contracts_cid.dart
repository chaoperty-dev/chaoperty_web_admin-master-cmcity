import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Constant/Myconstant.dart';

Future<http.Response?> readContractsCid({
  required String cid,
}) async {
  final headers = await MyHeaders.build(); // ✅ ต้อง await

  final url = Uri.parse('${MyConstant().domain_v1}/admin/contracts/$cid');
  print('GET ContractsCid : $url');
  print('GET headers : $headers');
  try {
    final response = await http.get(url, headers: headers);
    // print('[${response.body}]');

    if (response.statusCode == 200) {
      //print('✅ Get ContractsCid Success');
      // //print(response.body);
    } else {
      //print(
      // '❌ Get ContractsCid Failed [${response.statusCode}]: ${response.body}');
    }

    return response;
  } catch (e, stack) {
    //print('❌ Exception during ContractsCid request: $e');
    //print('🧭 StackTrace:\n$stack');
    return null;
  }
}
