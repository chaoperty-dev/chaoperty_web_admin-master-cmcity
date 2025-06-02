import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Constant/Myconstant.dart';

import '../../Model/GetExp_type_auto.dart';
import '../../Model/GetRenTal_Model.dart';
import '../Model/Payments_Model.dart';

Future<List<PaymentsModelCMM>> read_GC_payment() async {
  final url = '${MyConstant().domain_v1}/lookup/payments';
  print('🧾 payment url: $url');
  try {
    final response = await http.get(Uri.parse(url));
    final jsonRes = json.decode(response.body);

    print('🧾 Raw JSON: $jsonRes');

    if (jsonRes is Map && jsonRes['methods'] is List) {
      final list = jsonRes['methods'] as List;
      print('✅ Found methods: ${list.length}');

      return list
          .map<PaymentsModelCMM>((item) => PaymentsModelCMM.fromJson(item))
          .toList();
    } else {
      print('⚠️ ไม่พบ methods หรือไม่ใช่ List');
    }
  } catch (e, stack) {
    print('❌ Error: $e');
    print('🪵 Stack: $stack');
  }

  return [];
}

// Future<List<PaymentsModelCMM>> read_GC_payment() async {
//   SharedPreferences preferences = await SharedPreferences.getInstance();
//   var ren = preferences.getString('renTalSer');
//   var ser_user = preferences.getString('ser');

//   String url = '${MyConstant().domain_v1}/lookup/payments';

//   try {
//     final response = await http.get(Uri.parse(url));
//     final jsonRes = json.decode(response.body);

//     if (jsonRes != null && jsonRes['methods'] is List) {
//       final List list = jsonRes['methods'];
//       return list.map((e) => PaymentsModelCMM.fromJson(e)).toList();
//     }
//   } catch (e, stackTrace) {
//     print('❌ Error in read_GC_payment: $e');
//     print('🪵 StackTrace: $stackTrace');
//   }

//   return [];
// }
// Future<List<PaymentsModelCMM>> read_GC_payment() async {
//   SharedPreferences preferences = await SharedPreferences.getInstance();
//   var ren = preferences.getString('renTalSer');
//   var ser_user = preferences.getString('ser');

//   String url = '${MyConstant().domain_v1}/lookup/payments';

//   try {
//     final response = await http.get(Uri.parse(url));
//     final result = json.decode(response.body);

//     if (result != null && result is List && result.isNotEmpty) {
//       final map = result.first;
//       final paymentsmodel = PaymentsModelCMM.fromJson(map);
//       // เพิ่ม ser_user ให้กับ model ถ้าต้องการ
//       return paymentsmodel;
//     }
//   } catch (e, stackTrace) {
//     print('❌ เกิดข้อผิดพลาดใน read_GC_payment: $e');
//     print('🪵 StackTrace:\n$stackTrace');
//   }

//   return null;
// }

// Future<void> Post_GC_payment({
//   required String requestUuid,
//   required int paymentMethodId,
//   required int paymentMethodCode,
//   required int bankaccountId,
//   required String paidat,
//   required String referencecode,
//   required String reference1,
//   required String reference2,
//   required double paymentAmount,
// }) async {
//   final headers = {
//     'Accept': 'application/json',
//     'Content-Type': 'application/json',
//     // 'Authorization': 'Bearer YOUR_TOKEN', // เพิ่มถ้ามีระบบ Auth
//   };

//   final url = Uri.parse('${MyConstant().domain_v1}/payments');
//   final body = json.encode({
//     "request_uuid": requestUuid,
//     "payment_method_id": paymentMethodId,
//     "payment_method_code": paymentMethodCode,
//     "bank_account_id": bankaccountId,
//     "paid_at": DateTime.parse(paidat.toString())
//         .toIso8601String()
//         .toString(), // หรือ DateTime.parse(...).toIso8601String()
//     "reference_code": referencecode ?? "",
//     "reference1": reference1 ?? "",
//     "reference2": reference2 ?? "",
//     "amount": paymentAmount,
//   });

//   final request = http.Request('POST', url)
//     ..headers.addAll(headers)
//     ..body = body;

//   try {
//     final response = await request.send();
//     final responseBody = await response.stream.bytesToString();

//     if (response.statusCode == 200) {
//       print('✅ Payment Success: $responseBody');
//     } else {
//       print('❌ Payment Failed [${response.statusCode}]: $responseBody');
//     }
//   } catch (e, stack) {
//     print('❌ Exception during payment request: $e');
//     print('🧭 StackTrace:\n$stack');
//   }
// }
Future<http.Response?> Post_GC_payment({
  required String requestUuid,
  required int paymentMethodId,
  required int paymentMethodCode,
  required int bankaccountId,
  required String paidat,
  required String referencecode,
  required String reference1,
  required String reference2,
  required double paymentAmount,
  required double paymentReceived,
  required List<Map<String, dynamic>> jsonx,
}) async {
  final headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  final url = Uri.parse('${MyConstant().domain_v1}/payments');
  final body = json.encode({
    "request_uuid": requestUuid,
    "payment_method_id": paymentMethodId,
    "bank_account_id": bankaccountId,
    "paid_at": paidat,
    "reference_code": referencecode,
    "reference1": reference1,
    "reference2": reference2,
    "amount": paymentAmount,
    "amount_received": paymentReceived,
    "json": jsonx, // ✅ ไม่ต้องใส่ []
  });
  print(body);
  try {
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 409) {
      print('✅ Post Payment Success: ${response.body}');
    } else {
      print('❌ Post Payment Failed [${response.statusCode}]: ${response.body}');
    }
    return response;
  } catch (e, stack) {
    print('❌ Exception during payment request: $e');
    print('🧭 StackTrace:\n$stack');
    return null;
  }
}

Future<http.Response?> PUT_GC_payment({
  required String requestUuid,
  required int paymentMethodId,
  required int paymentMethodCode,
  required int bankaccountId,
  required String paidat,
  required String referencecode,
  required String reference1,
  required String reference2,
  required double paymentAmount,
  required double paymentReceived,
  required String uuidPayment,
  required String slipDate,
  required String slipPdate,
  required String slipTime,
}) async {
  final headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  final url = Uri.parse('${MyConstant().domain_v1}/payments/$uuidPayment');
  print(url);
  final body = json.encode({
    "request_uuid": requestUuid,
    "payment_method_id": paymentMethodId,
    "bank_account_id": bankaccountId,
    "paid_at": paidat,
    "reference_code": referencecode == '' ? '-' : referencecode,
    "reference1": reference1 == '' ? '-' : reference1,
    "reference2": reference2 == '' ? '-' : reference2,
    "amount": paymentAmount,
    "amount_received": paymentReceived,
    "slip_date": slipDate ?? paidat,
    "slip_pdate": slipPdate ?? paidat,
    "slip_time": slipTime,
  });
  print(body);
  try {
    final response = await http.put(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      print('✅ Payment Submitted Success: ${response.body}');
    } else {
      print(
          '❌ Payment Submitted Failed [${response.statusCode}]: ${response.body}');
    }
  } catch (e, stack) {
    print('❌ Exception during payment Submitted request: $e');
    print('🧭 StackTrace:\n$stack');
  }
}
// ✅ วิธีการเรียกใช้:
// await Post_GC_payment(
//   requestUuid: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx',
//   paymentMethodId: 1,
//   paymentAmount: 1500.00,
// );
