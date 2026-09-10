import 'dart:convert';
import 'dart:html';
import 'package:http/http.dart' as http;

import '../../Constant/Myconstant.dart';

Future<http.Response?> POST_Reject({
  required String requestUuid,
  required String flowUid,
  required String profileUuid,
  required String signUuid,
  required String comMent,
}) async {
  final headers = await MyHeaders.build(); // ✅ ต้อง await
  final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/approvals/${requestUuid}/flow/${flowUid}/reject');
  //print(url);
  final body = json.encode({
    "profile_uuid": "$profileUuid",
    "sign_uuid": "$signUuid",
    "comment": "$comMent"
  });
  // //print(body);
  try {
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      //print('✅ Reject Submitted Success: ${jsonDecode(response!.body)}');
      return response;
    } else {
      final responseJson = jsonDecode(response.body);
      //print(
      //'❌Reject Submitted Failed [${response.statusCode}]: ${responseJson}');
    }
    return response;
  } catch (e, stack) {
    //print('❌ Exception during Reject Submitted request: $e');
    //print('🧭 StackTrace:\n$stack');
    return null;
  }
}
