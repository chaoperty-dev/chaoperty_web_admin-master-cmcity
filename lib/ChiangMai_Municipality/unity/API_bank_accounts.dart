import 'dart:convert';
import 'dart:html';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../Constant/Myconstant.dart';

Future<http.Response?> getBankAccounts({
  required String serpay,
}) async {
  final headers = await MyHeaders.build();

  final url = Uri.parse(
    '${MyConstant().domain_v1}/lookup/payments/bank-accounts/$serpay/bser',
  );

  try {
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      // 👇 ระบุ type ให้ชัด
      final Map<String, dynamic> responseJson =
          jsonDecode(response.body) as Map<String, dynamic>;

      // กัน null / โครงสร้างไม่ตรง
      final bank = responseJson['bank_account'];
      if (bank is Map<String, dynamic>) {
        final acuuid = bank['uuid']?.toString();
        if (acuuid != null && acuuid.isNotEmpty) {
          // 👇 รอให้ลบเสร็จก่อน (ไม่ทิ้ง Future ลอย)
          await delBankAccounts(acuuid: acuuid);
        } else {
          // debugPrint('bank_account.uuid is null or empty');
        }
      } else {
        // debugPrint('bank_account is not a Map: $bank');
      }
    } else {
      // debugPrint(
      //   '❌ getBankAccounts Failed [${response.statusCode}]: ${response.body}',
      // );
    }

    return response;
  } catch (e, stack) {
    // debugPrint('❌ Exception during getBankAccounts request: $e');
    // debugPrint('🧭 StackTrace:\n$stack');
    return null;
  }
}

Future<http.Response?> delBankAccounts({
  required String acuuid,
}) async {
  final headers = await MyHeaders.build();

  final url = Uri.parse(
    '${MyConstant().domain_v1}/lookup/payments/bank-accounts/$acuuid',
  );

  try {
    final response = await http.delete(url, headers: headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // debugPrint('✅ delBankAccounts Success: ${response.statusCode}');
    } else {
      // debugPrint(
      //   '❌ delBankAccounts Failed [${response.statusCode}]: ${response.body}',
      // );
    }

    return response;
  } catch (e, stack) {
    // debugPrint('❌ Exception during delBankAccounts request: $e');
    // debugPrint('🧭 StackTrace:\n$stack');
    return null;
  }
}

Future<http.Response?> postBankAccounts({
  required String code, // "BANK_TRANSFER" หรือ "QR_CODE"
  required String bankName, // bank_name
  required String accountName, // account_name
  required String accountNumber, // account_number
  required String bser, // จาก ser c_payment
  required String bcode, // code รูปแบบ/ประเภทธนาคาร
  String? imagePath, // optional
  String? branch, // optional
  String? note, // optional
}) async {
  final headers = await MyHeaders.build();
  final url = Uri.parse(
    '${MyConstant().domain_v1}/lookup/payments/bank-accounts',
  );

  final body = jsonEncode({
    "code": code, // ex: "BANK_TRANSFER" หรือ "QR_CODE"
    "bank_name": bankName, // ex: "ธนาคารกรุงเทพ"
    "account_name": accountName, // ex: "บริษัท เอ บี ซี จำกัด"
    "account_number": accountNumber, // ex: "123-456-7890"
    "bser": bser, // จาก ser c_payment
    "bcode": bcode, // type รูป ธนาคาร ฯลฯ
    if (imagePath != '') "image_path": imagePath ?? "", // มี/ไม่มีก็ได้
    if (imagePath != '') "branch": branch ?? "", // มี/ไม่มีก็ได้
    if (imagePath != '') "note": note ?? "", // มี/ไม่มีก็ได้
  });
  print('✅ POST bank-accounts success: ${body}');
  try {
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('✅ POST bank-accounts success: ${response.body}');
      return response;
    } else {
      final responseJson = jsonDecode(response.body);
      print(
          '❌ POST bank-accounts failed [${response.statusCode}]: $responseJson');
      return response;
    }
  } catch (e, stack) {
    print('💥 Exception in postBankAccounts: $e');
    print(stack.toString());
    return null;
  }
}
