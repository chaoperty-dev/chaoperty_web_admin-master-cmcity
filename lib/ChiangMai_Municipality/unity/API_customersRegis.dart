import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Constant/Myconstant.dart';

Future<http.Response?> readCustomersRemember({
  required String cusUuid,
}) async {
  final headers = await MyHeaders.build(); // ✅ ต้อง await

  final url =
      Uri.parse('${MyConstant().domain_v1}/admin/customers/$cusUuid/remember');
  //print('GET ContractsCid : $url');
  //print('GET headers : $headers');
  try {
    final response = await http.get(url, headers: headers);
    //print('[${response.body}]');

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

Future<http.Response?> readCustomersTuser({
  required String cusUuid,
}) async {
  final headers = await MyHeaders.build(); // ✅ ต้อง await

  final url =
      Uri.parse('${MyConstant().domain_v1}/admin/customers/$cusUuid/tuser');
  //print('GET ContractsCid : $url');
  //print('GET headers : $headers');
  try {
    final response = await http.get(url, headers: headers);
    //print('[${response.body}]');

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

Future<http.Response?> postCustomersRegister({
  required String cusUuid,
  // required String? newPassword,
  // required String? newPasswordConfirmation,
  // required String? rememberToken,
}) async {
  final headers = await MyHeaders.build();
  final url =
      Uri.parse('${MyConstant().domain_v1}/admin/customers/$cusUuid/register');

  // final body = jsonEncode({
  //   "new_password": newPassword ?? "123456789",
  //   "new_password_confirmation": newPasswordConfirmation ?? "123456789",
  //   "remember_token": rememberToken ??
  //       "ZMoIZbWqLm43NPGvH55XTgSrmOp9yJHDgu62fa45iTMLprSbOXbKArkfJ5vK"
  // });
  // print('✅ POST bank-accounts success: ${body}');
  try {
    final response = await http.post(
      url,
      headers: headers,
      // body: body,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print(
          '✅ POST postCustomersRegister success: ${jsonDecode(response.body)}');
      return response;
    } else {
      final responseJson = jsonDecode(response.body);
      print(
          '❌ POST bank-accounts failed [${response.statusCode}]: $responseJson');
      return response;
    }
  } catch (e, stack) {
    print('💥 Exception in postCustomersRegister: $e');
    print(stack.toString());
    return null;
  }
}

Future<http.Response?> postCustomersRemember({
  required String cusUuid,
  required String? newPassword,
  required String? newPasswordConfirmation,
  required String? rememberToken,
}) async {
  final headers = await MyHeaders.build();
  final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/customers/$cusUuid/change-password');

  final body = jsonEncode({
    "new_password": newPassword ?? "",
    "new_password_confirmation": newPasswordConfirmation ?? "",
    "remember_token": rememberToken ?? ""
  });
  print('✅ POST change-password success: ${body}');
  try {
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('✅ POST change-password success: ${response.body}');
      return response;
    } else {
      final responseJson = jsonDecode(response.body);
      print(
          '❌ POST change-password failed [${response.statusCode}]: $responseJson');
      return response;
    }
  } catch (e, stack) {
    print('💥 Exception in postBankAccounts: $e');
    print(stack.toString());
    return null;
  }
}
