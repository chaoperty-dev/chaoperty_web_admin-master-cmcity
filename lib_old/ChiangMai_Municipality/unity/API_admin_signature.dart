import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import '../../Constant/Myconstant.dart';
import 'SecurePrefs_helper.dart';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<http.Response?> read_AdminSignature() async {
  final headers = await MyHeaders.build(); // ✅ ต้อง await

  final url = Uri.parse('${MyConstant().domain_v1}/admin/know');
  print('[API_AdminSignature] 📤 GET: $url');

  try {
    final response = await http.get(url, headers: headers);
    print('[API_AdminSignature] 📤 Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      print('[API_AdminSignature] ✅ Get Admin Signature Success');
      print('[API_AdminSignature] 📄 Body: ${response.body}');
    } else {
      print(
          '[API_AdminSignature] ❌ Failed [${response.statusCode}]: ${response.body}');
    }

    return response;
  } catch (e, stack) {
    print('[API_AdminSignature] ❌ Exception: $e');
    print('[API_AdminSignature] 🧭 StackTrace:\n$stack');
    return null;
  }
}

Future<http.Response?> img_signatureUuid(
    {required String? signatureUuid}) async {
  final headers = await MyHeaders.build(); // 🔐 สร้าง headers พร้อม token

  final url = Uri.parse(
    '${MyConstant().domain_v1}/admin/users/signatures/${signatureUuid}/preview',
  );

  print('[API_AdminSignature] 📤 GET Image: $url');

  try {
    final response = await http.get(url, headers: headers);
    print('[API_AdminSignature] 📤 Image Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      print(
          '[API_AdminSignature] ✅ Image loaded: ${response.bodyBytes.lengthInBytes} bytes');
    } else {
      print(
          '[API_AdminSignature] ❌ Failed to load image [${response.statusCode}]: ${response.body}');
    }

    return response;
  } catch (e, stackTrace) {
    print('[API_AdminSignature] ❌ Exception: $e');
    print('[API_AdminSignature] 🧭 Stack trace:\n$stackTrace');
    return null;
  }
}
