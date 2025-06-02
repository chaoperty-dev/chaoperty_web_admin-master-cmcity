import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../Constant/Myconstant.dart';

Future<http.Response?> read_GC_Reviews() async {
  final headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization':
        'Bearer 2|cwoWiBqMSaTaX7DH0cgJ2Z0Z9NrqDGAQjhULhTyu89b57898',
  };

  final url = Uri.parse('${MyConstant().domain_v1}/admin/reviews');
  print('GET Reviews : $url');

  try {
    final response = await http.get(url, headers: headers);
    print('[${response.statusCode}]');

    if (response.statusCode == 200) {
      print('✅ Get Reviews Success');
    } else {
      print('❌ Get Reviews Failed [${response.statusCode}]: ${response.body}');
    }

    return response;
  } catch (e, stack) {
    print('❌ Exception during Reviews request: $e');
    print('🧭 StackTrace:\n$stack');
    return null;
  }
}

Future<http.Response?> read_GC_ReviewsUuid(String? UuidRequest) async {
  if (UuidRequest == null || UuidRequest.isEmpty) {
    print('⚠️ UuidRequest is null or empty');
    return null;
  }

  final headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization':
        'Bearer 2|cwoWiBqMSaTaX7DH0cgJ2Z0Z9NrqDGAQjhULhTyu89b57898',
  };

  final url = Uri.parse('${MyConstant().domain_v1}/admin/reviews/$UuidRequest');
  print('🔎 GET Reviews by Uuid: $url');

  try {
    final response = await http.get(url, headers: headers);
    print('📥 Status: [${response.statusCode}]');

    if (response.statusCode == 200) {
      print('🔓✅ Get Reviews Uuid Success');
    } else {
      print(
          '❌ Get Reviews Uuid Failed [${response.statusCode}]: ${response.body}');
    }

    return response;
  } catch (e, stack) {
    print('❌ Exception during Reviews Uuid request: $e');
    print('🧭 StackTrace:\n$stack');
    return null;
  }
}

Future<http.Response?> Post_ReviewsAttachMents({
  required String requestUuid,
  required String attachmentsUuid,
  required String staTus,
  required String descripTion,
}) async {
  final headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization':
        'Bearer 2|cwoWiBqMSaTaX7DH0cgJ2Z0Z9NrqDGAQjhULhTyu89b57898',
  };

  final url = Uri.parse('${MyConstant().domain_v1}/admin/reviews/$requestUuid');
  final body = json.encode({
    "attachment_uuid": attachmentsUuid,
    "status": staTus,
    "description": descripTion,
  });
  print('Post_ReviewsAttachMents : $url');

  print(body);
  try {
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    print('[${response.statusCode}]');
    if (response.statusCode == 201 || response.statusCode == 409) {
      print('✅ Post Reviews Success: ${response.body}');
    } else {
      print('❌ Post Reviews Failed [${response.statusCode}]: ${response.body}');
    }
    return response;
  } catch (e, stack) {
    print('❌ Exception during Reviews request: $e');
    print('🧭 StackTrace:\n$stack');
    return null;
  }
}
