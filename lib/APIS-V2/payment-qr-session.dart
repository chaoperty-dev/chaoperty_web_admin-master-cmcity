import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../Constant/Myconstant.dart';
import 'config-intents.dart';

Future<http.Response?> postPaymentIntentsQRsession({
  required String cusNo,
  required String intentsUuid,
  required int bankMerchantId,
  required int bankMerchantType,
  String? ref1,
  required String ref2,
}) async {
  try {
    final headers = await MyHeaders.build();
    // ensure Content-Type
    final mergedHeaders = {
      'Content-Type': 'application/json',
      ...headers,
    };

    final url = Uri.parse(
      '${MyconfigIntents().domainIntents}/payment-intents/$intentsUuid/qr-session',
    );

    final body = jsonEncode({
      // ใช้ snake_case ให้สอดคล้องกับ API อื่นในระบบคุณ
      'customer_no': cusNo,
      'bank_merchant_id': bankMerchantId,
      "bank_merchant_type": bankMerchantType,
      // 'ref1': ref1,
      'ref2': ref2,
      // ถ้า API ต้องการ intents_uuid ใน body ด้วยค่อยใส่เพิ่ม:
      // 'intents_uuid': intentsUuid,
    });

    debugPrint('POST $url');
    debugPrint('Headers: $mergedHeaders');
    debugPrint('📦 Body: $body');

    final response = await http.post(url, headers: mergedHeaders, body: body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      debugPrint('✅ POST qr-session Success: ${response.body}');
      return response;
    } else {
      try {
        final respJson = jsonDecode(response.body);
        debugPrint(
            '❌ POST qr-session Failed [${response.statusCode}]: $respJson');
      } catch (_) {
        debugPrint(
            '❌ POST qr-session Failed [${response.statusCode}]: ${response.body}');
      }
      return response;
    }
  } catch (e, stack) {
    debugPrint('❌ Exception in POST qr-session: $e');
    debugPrint('🧭 StackTrace:\n$stack');
    return null;
  }
}

Future<http.Response?> putPaymentIntentsQRsession({
  required String intentsUuid, // เช่น '9eac64fc-a318-433c-92e4-be84993f5d52'
  required String bankMerchantId, // เช่น 1
  required String bankMerchantType,
  String? ref2, // ส่งค่าว่างได้ ""
  Duration timeout = const Duration(seconds: 20),
}) async {
  final url = Uri.parse(
    '${MyconfigIntents().domainIntents}/payment-intents/$intentsUuid/qr-session/renew',
  );
  final headers = await MyHeaders.build();
  // final headers = <String, String>{
  //   'X-Tenant': tenant,
  //   'Accept': 'application/json',
  //   'Content-Type': 'application/json',
  // };

  // body ตามตัวอย่างของคุณ
  final body = jsonEncode({
    'bank_merchant_id': int.parse(bankMerchantId),
    "bank_merchant_type": int.parse(bankMerchantType),
    'ref2': ref2 ?? '',
  });
  debugPrint('✅ body: ${body}');
  try {
    final resp =
        await http.put(url, headers: headers, body: body).timeout(timeout);

    // log สั้น ๆ
    debugPrint('PUT $url -> ${resp.statusCode}');
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      debugPrint('✅ Success: ${resp.body}');
    } else {
      debugPrint('❌ Failed: ${resp.statusCode} ${resp.body}');
    }
    return resp;
  } catch (e, st) {
    debugPrint('💥 Exception: $e');
    debugPrint('$st');
    return null;
  }
}
