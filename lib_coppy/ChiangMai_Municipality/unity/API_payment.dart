import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Constant/Myconstant.dart';

import '../../Model/GetExp_type_auto.dart';
import '../../Model/GetRenTal_Model.dart';
import '../Model/AutoExpTrans_ModelCMM.dart';
import '../Model/Payments_Model.dart';

Future<List<PaymentsModelCMM>> read_GC_payment() async {
  final headers = await MyHeaders.build(); // ✅ สร้าง header
  final url = '${MyConstant().domain_v1}/lookup/payments';
  //print('🧾 payment url: $url');

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: headers, // ✅ ต้องใส่ตรงนี้
    );

    // ตรวจสถานะก่อน
    if (response.statusCode != 200) {
      //print('⚠️ HTTP ${response.statusCode}: ${response.reasonPhrase}');
      return [];
    }

    // Decode JSON
    final jsonRes = json.decode(response.body);
    //print('🧾 Raw JSON: $jsonRes');

    // ตรวจว่ามี methods เป็น List
    if (jsonRes is Map && jsonRes['methods'] is List) {
      final list = jsonRes['methods'] as List;
      //print('✅ Found methods: ${list.length}');

      // แปลงเป็น List<PaymentsModelCMM>
      final payments = list
          .map<PaymentsModelCMM>((item) =>
              PaymentsModelCMM.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      // log ตัวอย่าง
      for (final p in payments) {
        //print('➡️ Method: ${p.code} (${p.meta?.length ?? 0} meta)');
      }

      return payments;
    } else {
      //print('⚠️ ไม่พบ methods หรือไม่ใช่ List');
    }
  } catch (e, stack) {
    //print('❌ Error: $e');
    //print('🪵 Stack: $stack');
  }

  return [];
}

// Future<List<PaymentsModelCMM>> read_GC_payment() async {
//   final headers = await MyHeaders.build(); // ✅ ต้อง await
//   final url = '${MyConstant().domain_v1}/lookup/payments';
//   //print('🧾 payment url: $url');
//   try {
//     final response = await http.get(Uri.parse(url))
//       ..headers.addAll(headers); // ✅ ต้องใส่ headers ด้วย
//     final jsonRes = json.decode(response.body);

//     //print('🧾 Raw JSON: $jsonRes');

//     if (jsonRes is Map && jsonRes['methods'] is List) {
//       final list = jsonRes['methods'] as List;
//       //print('✅ Found methods: ${list.length}');

//       return list
//           .map<PaymentsModelCMM>((item) => PaymentsModelCMM.fromJson(item))
//           .toList();
//     } else {
//       //print('⚠️ ไม่พบ methods หรือไม่ใช่ List');
//     }
//   } catch (e, stack) {
//     //print('❌ Error: $e');
//     //print('🪵 Stack: $stack');
//   }

//   return [];
// }

Future<http.Response?> readPrepayment({
  required String requestUuid,
}) async {
  final headers = await MyHeaders.build(); // ✅ ต้อง await

  final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/requests/$requestUuid/prepayment');
  //print('GET Prepayment : $url');
  //print('GET headers : $headers');
  try {
    final response = await http.get(url, headers: headers);
    //print('[${response.statusCode}]');

    if (response.statusCode == 200) {
      //print('✅ Get Prepayment Success');
      // //print(response.body);
    } else {
      //print(
      // '❌ Get Prepayment Failed [${response.statusCode}]: ${response.body}');
    }

    return response;
  } catch (e, stack) {
    //print('❌ Exception during Prepayment request: $e');
    //print('🧭 StackTrace:\n$stack');
    return null;
  }
}

Future<http.Response?> readDocnoPayment({
  required String requestUuid,
}) async {
  final headers = await MyHeaders.build(); // ✅ ต้อง await

  final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/requests/$requestUuid/prepayment');
  //print('GET docno payment : $url');
  //print('GET headers : $headers');
  try {
    final response = await http.get(url, headers: headers);
    //print('[${response.statusCode}]');

    if (response.statusCode == 200) {
      //print('✅ Get docno payment Success');
      // //print(response.body);
    } else {
      //print(
      //  '❌ Get docno payment Failed [${response.statusCode}]: ${response.body}');
    }

    return response;
  } catch (e, stack) {
    //print('❌ Exception during docno payment request: $e');
    //print('🧭 StackTrace:\n$stack');
    return null;
  }
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
//     //print('❌ Error in read_GC_payment: $e');
//     //print('🪵 StackTrace: $stackTrace');
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
//     //print('❌ เกิดข้อผิดพลาดใน read_GC_payment: $e');
//     //print('🪵 StackTrace:\n$stackTrace');
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
//       //print('✅ Payment Success: $responseBody');
//     } else {
//       //print('❌ Payment Failed [${response.statusCode}]: $responseBody');
//     }
//   } catch (e, stack) {
//     //print('❌ Exception during payment request: $e');
//     //print('🧭 StackTrace:\n$stack');
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
  required List<AutoExpTransModelCMM> jsonx,
  // required List<Map<String, dynamic>> jsonx,
}) async {
  // final headers = {
  //   'Accept': 'application/json',
  //   'Content-Type': 'application/json',
  // };
  final headers = await MyHeaders.build(); // ✅ ต้อง await
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
    "json": jsonx, //jsonx, // ✅ ไม่ต้องใส่ []
  });
  //print(body);
  try {
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 409) {
      //print('✅ Post Payment Success: ${response.body}');
    } else {
      //print('❌ Post Payment Failed [${response.statusCode}]: ${response.body}');
    }
    return response;
  } catch (e, stack) {
    //print('❌ Exception during payment request: $e');
    //print('🧭 StackTrace:\n$stack');
    return null;
  }
}

Future<http.Response?> Post_GC_payment_addon({
  required String uuidPayment,
  required String nobill,
  required String docnobill,
  required String billdate,
  String payType = '',
}) async {
  final headers = await MyHeaders.build();
  final url =
      Uri.parse('${MyConstant().domain_v1}/payments/$uuidPayment/addon');
  final Map<String, dynamic> bodyMap = {
    "payment_uuid": uuidPayment,
    "book_no": docnobill,
    "book_date": billdate,
    "no": nobill,
  };

  if (payType.isNotEmpty) {
    bodyMap["pay_type"] = payType;
  }

  final body = json.encode(bodyMap);
  print(body);
  try {
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    print('✅ Post_GC_payment_addon statusCode: ${response.statusCode}');
    if (response.statusCode == 200) {
      print('✅ Post_GC_payment_addon Success: ${response.body}');
      // final response_paymentonly =
      //     await POST_docno_paymentonly(requestUuid: requestUuid);
      return response;
    } else {
      print(
          '❌ Post_GC_payment_addon Failed [${response.statusCode}]: ${response.body}');
      return response;
    }
  } catch (e, stack) {
    print('❌ Exception during Post_GC_payment_addon: $e');
    print('🧭 StackTrace:\n$stack');
    return null;
  }
}

Future<http.Response?> Get_GC_payment_addon({
  required String uuidPayment,
}) async {
  final headers = await MyHeaders.build();
  final url =
      Uri.parse('${MyConstant().domain_v1}/payments/$uuidPayment/addon');
  try {
    final response = await http.get(url, headers: headers);
    print('✅ Get_GC_payment_addon statusCode: ${response.statusCode}');
    return response;
  } catch (e) {
    print('❌ Exception during Get_GC_payment_addon: $e');
    return null;
  }
}

Future<http.Response?> PUT_GC_payment({
  required String requestUuid,
  required int paymentMethodId,
  // required int paymentMethodCode,
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
  // final headers = {
  //   'Accept': 'application/json',
  //   'Content-Type': 'application/json',
  // };
  final headers = await MyHeaders.build(); // ✅ ต้อง await
  final url = Uri.parse('${MyConstant().domain_v1}/payments/$uuidPayment');
  //print(url);
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
  // //print(body);
  try {
    final response = await http.put(
      url,
      headers: headers,
      body: body,
    );
    //print('✅ PUT_GC_payment statusCode: ${response.statusCode}');
    if (response.statusCode == 200) {
      //print('✅ Payment Submitted Success: ${response.body}');
      // final response_paymentonly =
      //     await POST_docno_paymentonly(requestUuid: requestUuid);
      return response;
    } else {
      //print(
      //  '❌ Payment Submitted Failed [${response.statusCode}]: ${response.body}');
      return null;
    }
  } catch (e, stack) {
    //print('❌ Exception during payment Submitted request: $e');
    //print('🧭 StackTrace:\n$stack');
    return null;
  }
}

Future<http.Response?> POST_docno_paymentonly({
  required String requestUuid,
}) async {
  final headers = await MyHeaders.build(); // ✅ ต้อง await
  final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/documents/$requestUuid?a=PAYMENT');
  //print(url);
  final body = json.encode({
    // "request_uuid": requestUuid,
  });
  //print(body);
  try {
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      //print(
      //    '✅ Docno Payment Only Submitted Success: ${jsonDecode(response!.body)}');
      return response;
    } else {
      //print(
      //  '❌Docno Payment Only Submitted Failed [${response.statusCode}]: ${response.body}');
    }
    return response;
  } catch (e, stack) {
    //print('❌ Exception during Docno payment Only Submitted request: $e');
    //print('🧭 StackTrace:\n$stack');
    return null;
  }
}





// ✅ วิธีการเรียกใช้:
// await Post_GC_payment(
//   requestUuid: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx',
//   paymentMethodId: 1,
//   paymentAmount: 1500.00,
// );
