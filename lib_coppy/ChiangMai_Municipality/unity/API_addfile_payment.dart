import 'dart:convert';
import 'dart:io';
import 'dart:js';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:path/path.dart' as path;

import '../../Constant/Myconstant.dart';
import '../PDF_CMM/receipt_cmm.dart';

Future<dynamic> PaypickAndUpload(String uuid, String uuid_request) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['png', 'jpg', 'jpeg'],
  );

  if (result == null) {
    //  print('⚠️ The user has not selected a file. ผู้ใช้ไม่ได้เลือกไฟล์');
    return null;
  }

  final file = result.files.first;

  if (kIsWeb) {
    if (file.bytes == null) {
      // print('🚫 Unable to read bytes on the web ไม่สามารถอ่าน bytes ได้บนเว็บ');
      return null;
    }

    final response =
        await Addfile_Payment_Web(uuid, file.bytes!, file.name, uuid_request);
    // print('📡 Web Upload Response: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        'base64': base64Encode(file.bytes!),
        'extension': file.extension ?? 'jpg'
      };
    } else {
      //  print('❌ Upload to Web server failed');
      return null;
    }
  } else {
    if (file.path == null) {
      // print(
      //   '🚫 There is no Not path for this File (mobile) ไม่มี Not path สำหรับ File นี้ (mobile)');
      return null;
    }

    final ioFile = File(file.path!);
    final response = await Addfile_Payment_Mobile(uuid, ioFile, uuid_request);
    // print('📡 Mobile Upload Response: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        'base64': base64Encode(await ioFile.readAsBytes()),
        'extension': file.extension ?? 'jpg'
      };
    } else {
      //  print('❌ Upload to Mobile server failed');
      return null;
    }
  }
}

Future<http.Response> Addfile_Payment_Web(String uuid, List<int> fileBytes,
    String filename, String uuid_request) async {
  final uri = Uri.parse('${MyConstant().domain_v1}/payments/$uuid/attachments');
  // print(uri);
  // print('uuid_request');
  // print(uuid_request);
  final headers = await MyHeaders.build(); // ✅ ต้อง await
  var request = http.MultipartRequest('POST', uri)
    ..headers.addAll(headers
        //   {
        //   'Accept': 'application/json',
        //   'Authorization':
        //       'Bearer 7|Xm7Hdf184i16Y45avEiYkalUofL6XstNlUQJDDiLe79fc995',
        // }
        )
    ..fields['document_id'] = '8'
    ..fields['request_uuid'] = uuid_request.toString()
    ..files.add(
      http.MultipartFile.fromBytes('file', fileBytes, filename: filename),
    );

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200 || response.statusCode == 201) {
    //  print('✅ Web Upload succeed อัปโหลดสำเร็จ: ${response.body}');
  } else {
    // print('❌ Web Upload failed อัปโหลดล้มเหลว : ${response.statusCode}');
    // print('📄 ตอบกลับ(response): ${response.body}');
  }

  return response;
}

Future<http.Response> Addfile_Payment_Mobile(
    String uuid, File file, String uuid_request) async {
  final uri = Uri.parse('${MyConstant().domain_v1}/payments/$uuid/attachments');
  // print(uri);
  // print('uuid_request');
  // print(uuid_request);
  final headers = await MyHeaders.build(); // ✅ ต้อง await
  var request = http.MultipartRequest('POST', uri)
    ..headers.addAll(headers
        //   {
        //   'Accept': 'application/json',
        //   'Authorization':
        //       'Bearer 7|Xm7Hdf184i16Y45avEiYkalUofL6XstNlUQJDDiLe79fc995',
        // }
        )
    ..fields['document_id'] = '8'
    ..fields['request_uuid'] = uuid_request.toString()
    ..files.add(
      await http.MultipartFile.fromPath('file', file.path,
          filename: path.basename(file.path)),
    );

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200 || response.statusCode == 201) {
    //  print('✅ Mobile/Desktop Upload succeed อัปโหลดสำเร็จ');
  } else {
    // print(
    //    '❌ Mobile/Desktop Upload failed อัปโหลดล้มเหลว: ${response.statusCode}');
    // print('📄 ตอบกลับ(response): ${response.body}');
  }

  return response;
}

//////////--------------------->
Future<dynamic> PaypickAndUpload_Receipt(
    BuildContext context,
    String uuid,
    String uuidRequest,
    String uuidReceipt,
    String typeFile, // "PDF" หรือ "image"
    dynamic reviewDetail,
    dynamic expAutoModels,
    dynamic receiptmodel,
    Uint8List? Signature_user,
    // String Signature_user,
    String fullNameAdmin,
    String positionAdmin) async {
  Uint8List? fileBytes;
  String fileName = '';
  String fileExtension = '';

  if (typeFile == 'PDF') {
    if (kIsWeb) {
      // ✅ สร้าง PDF แล้วแปลงเป็น bytes
      final pdf = await GeneratePDF_Receipt_CMM(
          context: context,
          type: 0,
          DataDetail: reviewDetail,
          expAutoModels: expAutoModels,
          receiptmodel: receiptmodel,
          Signature_user: Signature_user,
          fullNameAdmin: fullNameAdmin,
          positionAdmin: positionAdmin
          // context,
          // 0, // สร้างไฟล์ ไม่ preview
          // reviewDetail,
          // expAutoModels,
          // receiptmodel,
          // Signature_user,
          // fullNameAdmin,
          // positionAdmin
          );
      final bytes = await pdf.save();
      fileBytes = Uint8List.fromList(bytes);
      fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.pdf';
      fileExtension = 'pdf';
    } else {
      // ✅ แสดง Preview เท่านั้น (Mobile)
      await GeneratePDF_Receipt_CMM(
          context: context,
          type: 1,
          DataDetail: reviewDetail,
          expAutoModels: expAutoModels,
          receiptmodel: receiptmodel,
          Signature_user: Signature_user,
          fullNameAdmin: fullNameAdmin,
          positionAdmin: positionAdmin
          // context, 1, reviewDetail, expAutoModels,
          //   receiptmodel, Signature_user, fullNameAdmin, positionAdmin
          );
      return null;
    }
  } else {
    // ✅ เลือกรูปภาพ
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
    );

    if (result == null) {
      //  print('⚠️ ผู้ใช้ไม่ได้เลือกไฟล์');
      return null;
    }

    final file = result.files.first;
    fileName = file.name;
    fileExtension = file.extension ?? 'jpg';

    if (kIsWeb) {
      fileBytes = file.bytes;
    } else {
      final path = file.path;
      if (path == null) {
        //  print('🚫 ไม่พบ path สำหรับไฟล์มือถือ');
        return null;
      }
      fileBytes = await File(path).readAsBytes();
    }
  }

  // ✅ ส่งไฟล์ไปยัง Server
  http.Response? response;
  if (kIsWeb) {
    response = await MainPayment_Receipt_Web(
      uuid,
      fileBytes!,
      fileName,
      uuidRequest,
      uuidReceipt,
    );
  } else {
    final file = File.fromRawPath(fileBytes!);
    response = await MainPayment_Receipt_Mobile(
      uuid,
      file,
      uuidRequest,
      uuidReceipt,
    );
  }

  // ✅ ตรวจสอบผลลัพธ์
  if (response != null &&
      (response.statusCode == 200 || response.statusCode == 201)) {
    // print('✅ Upload สำเร็จ $typeFile: ${response.statusCode}');
    return {
      'base64': base64Encode(fileBytes!),
      'extension': fileExtension,
    };
  } else {
    // print('❌ Upload $typeFile ล้มเหลว');
    return null;
  }
}

// Future<dynamic> PaypickAndUpload_Receipt(
//     context,
//     String uuid,
//     String uuid_request,
//     String Uuid_receipt,
//     String Typefile,
//     reviewDetail,
//     expAutoModels) async {
//   if (Typefile == 'PDF') {
//     final result =
//         await GeneratePDF_Receipt_CMM(context, 1, reviewDetail, expAutoModels);
//   } else {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['png', 'jpg', 'jpeg'],
//     );

//     if (result == null) {
//       print('⚠️ The user has not selected a file. ผู้ใช้ไม่ได้เลือกไฟล์');
//       return null;
//     }

//     final file = result.files.first;

//     if (kIsWeb) {
//       if (file.bytes == null) {
//         print(
//             '🚫 Unable to read bytes on the web ไม่สามารถอ่าน bytes ได้บนเว็บ');
//         return null;
//       }

//       final response = await MainPayment_Receipt_Web(
//           uuid, file.bytes!, file.name, uuid_request, Uuid_receipt);
//       print('📡 Web Upload Response: ${response!.statusCode}');

//       if (response!.statusCode == 200 || response.statusCode == 201) {
//         return {
//           'base64': base64Encode(file.bytes!),
//           'extension': file.extension ?? 'jpg'
//         };
//       } else {
//         print('❌ Upload to Web server failed');
//         return null;
//       }
//     } else {
//       if (file.path == null) {
//         print(
//             '🚫 There is no Not path for this File (mobile) ไม่มี Not path สำหรับ File นี้ (mobile)');
//         return null;
//       }

//       final ioFile = File(file.path!);
//       final response = await MainPayment_Receipt_Mobile(
//           uuid, ioFile, uuid_request, Uuid_receipt);
//       print('📡 Mobile Upload Response: ${response!.statusCode}');

//       if (response!.statusCode == 200 || response!.statusCode == 201) {
//         return {
//           'base64': base64Encode(await ioFile.readAsBytes()),
//           'extension': file.extension ?? 'jpg'
//         };
//       } else {
//         print('❌ Upload to Mobile server failed');
//         return null;
//       }
//     }
//   }
// }

Future<http.Response?> MainPayment_Receipt_Web(String uuid, List<int> fileBytes,
    String filename, String uuidRequest, String Uuid_receipt) async {
  try {
    final responseStep1 = await Addfile_Payment_Receipt_Web(
        uuid, fileBytes, filename, uuidRequest);

    if (responseStep1.statusCode == 200 || responseStep1.statusCode == 201) {
      //  print('✅ Upload Receipt Step 1 สำเร็จ');

      final documentUuid = Uuid_receipt.toString();

      // final responseStep2 = await Addfile_Payment_Documents_Web(
      //     documentUuid, fileBytes, filename, uuidRequest);

      return responseStep1;
    } else {
      //  print('❌ Step 1 ล้มเหลว: ${responseStep1.statusCode}');
      return responseStep1;
    }
  } catch (e) {
    //  print('❌ เกิดข้อผิดพลาดระหว่างอัปโหลด: $e');
    return null;
  }
}

Future<http.Response?> MainPayment_Receipt_Mobile(
    String uuid, File file, String uuidRequest, String Uuid_receipt) async {
  try {
    final responseStep1 =
        await Addfile_Payment_Receip_Mobile(uuid, file, uuidRequest);

    if (responseStep1.statusCode == 200 || responseStep1.statusCode == 201) {
      // print('✅ Upload Receipt Step 1 สำเร็จ');
      final documentUuid = Uuid_receipt.toString();

      // final responseStep2 = await Addfile_Payment_Documents_Mobile(
      //     documentUuid, file, uuidRequest);
      return responseStep1;
    } else {
      //  print('❌ Step 1 ล้มเหลว: ${responseStep1.statusCode}');
      return responseStep1;
    }
  } catch (e) {
    //print('❌ Exception: $e');
    return null;
  }
}

//////////--------------------->

Future<http.Response> Addfile_Payment_Receipt_Web(String uuid,
    List<int> fileBytes, String filename, String uuid_request) async {
  final uri = Uri.parse(
      '${MyConstant().domain_v1}/admin/approvals/$uuid_request/receipt');
  // print(uri);
  // print('uuid_request');
  // print(uuid_request);
  final headers = await MyHeaders.build(); // ✅ ต้อง await
  var request = http.MultipartRequest('POST', uri)
    ..headers.addAll(headers)
    // ..fields['document_id'] = '8'
    // ..fields['request_uuid'] = uuid_request.toString()
    ..files.add(
      http.MultipartFile.fromBytes('file', fileBytes, filename: filename),
    );

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200 || response.statusCode == 201) {
    // print('✅ Web Upload Receipt succeed อัปโหลดสำเร็จ: ${response.body}');
  } else {
    // print(
    //     '❌ Web Upload Receipt failed Web อัปโหลดล้มเหลว : ${response.statusCode}');
    // print('📄 ตอบกลับ(response): ${response.body}');
  }

  return response;
}

Future<http.Response> Addfile_Payment_Receip_Mobile(
    String uuid, File file, String uuid_request) async {
  final uri = Uri.parse(
      '${MyConstant().domain_v1}/admin/approvals/$uuid_request/receipt');
  // print(uri);
  // print('uuid_request');
  // print(uuid_request);
  final headers = await MyHeaders.build(); // ✅ ต้อง await
  var request = http.MultipartRequest('POST', uri)
    ..headers.addAll(headers
        //   {
        //   'Accept': 'application/json',
        //   'Authorization':
        //       'Bearer 7|Xm7Hdf184i16Y45avEiYkalUofL6XstNlUQJDDiLe79fc995',
        // }
        )
    // ..fields['document_id'] = '8'
    // ..fields['request_uuid'] = uuid_request.toString()
    ..files.add(
      await http.MultipartFile.fromPath('file', file.path,
          filename: path.basename(file.path)),
    );

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200 || response.statusCode == 201) {
    // print('✅ Mobile/Desktop Upload Receipt succeed อัปโหลดสำเร็จ');
  } else {
    //  print(
    //      '❌ Mobile/Desktop Upload Receipt failed อัปโหลดล้มเหลว: ${response.statusCode}');
    // print('📄 ตอบกลับ(response): ${response.body}');
  }

  return response;
}

Future<http.Response> Addfile_Payment_Documents_Web(String uuid,
    List<int> fileBytes, String filename, String uuid_request) async {
  final uri =
      Uri.parse('${MyConstant().domain_v1}/admin/documents/$uuid/attchment');
  // print(uri);
  // print('uuid_request');
  // print(uuid_request);
  final headers = await MyHeaders.build(); // ✅ ต้อง await
  var request = http.MultipartRequest('POST', uri)
    ..headers.addAll(headers)
    // ..fields['document_id'] = '8'
    // ..fields['request_uuid'] = uuid_request.toString()
    ..files.add(
      http.MultipartFile.fromBytes('file', fileBytes, filename: filename),
    );

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200 || response.statusCode == 201) {
    // print('✅ Web Upload Receipt succeed อัปโหลดสำเร็จ: ${response.body}');
  } else {
    //  print(
    //      '❌ Web Upload Receipt failed Web อัปโหลดล้มเหลว : ${response.statusCode}');
    //  print('📄 ตอบกลับ(response): ${response.body}');
  }

  return response;
}

Future<http.Response> Addfile_Payment_Documents_Mobile(
    String uuid, File file, String uuid_request) async {
  final uri =
      Uri.parse('${MyConstant().domain_v1}/admin/documents/$uuid/attchment');
  // print(uri);
  // print('uuid_request');
  // print(uuid_request);
  final headers = await MyHeaders.build(); // ✅ ต้อง await
  var request = http.MultipartRequest('POST', uri)
    ..headers.addAll(headers)
    // ..fields['document_id'] = '8'
    // ..fields['request_uuid'] = uuid_request.toString()
    ..files.add(
      await http.MultipartFile.fromPath('file', file.path,
          filename: path.basename(file.path)),
    );

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200 || response.statusCode == 201) {
    // print('✅ Mobile/Desktop Upload Receipt succeed อัปโหลดสำเร็จ');
  } else {
    //  print(
    //      '❌ Mobile/Desktop Upload Receipt failed อัปโหลดล้มเหลว: ${response.statusCode}');
    //   print('📄 ตอบกลับ(response): ${response.body}');
  }

  return response;
}
