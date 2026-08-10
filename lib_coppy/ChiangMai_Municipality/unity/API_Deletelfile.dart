import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../Constant/Myconstant.dart';

Future<bool> Deletelfile_Document(String uuid, String docuuid) async {
  final uri = Uri.parse(
      '${MyConstant().domain_v1}/admin/requests/$uuid/attachments/$docuuid');
  final headers = await MyHeaders.build();

  print(uri);
  print('🗑️ Deleting file with UUID: $docuuid from request: $uuid');
  try {
    final response = await http.delete(
      uri,
      headers: headers,
    );
    if (response.statusCode == 200) {
      print('✅ Deletelfile_Document Success');
      return true;
    } else {
      print(
          '❌ Deletelfile_Document Failed [${response.statusCode}]: ${response.body}');
      return false;
    }
  } catch (e, stack) {
    print('❌ Exception during Deletelfile_Document: $e');
    print('🧭 StackTrace:\n$stack');
    return false;
  }
}
