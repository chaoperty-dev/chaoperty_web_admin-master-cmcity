import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as path;

import '../../Constant/Myconstant.dart';

// import 'Addfile_Document.dart'; // <== อย่าลืม import

// Future<File?> PaypickAndUpload(String uuid) async {
//   final result = await FilePicker.platform.pickFiles();

//   if (result == null) {
//     print('⚠️ ผู้ใช้ไม่ได้เลือกไฟล์');
//     return null; // ❗ ต้องคืนค่า null อย่างชัดเจน
//   }

//   final file = result.files.first;

//   if (kIsWeb) {
//     if (file.bytes == null) {
//       print('🚫 ไม่สามารถอ่าน bytes ได้บนเว็บ');
//       return null;
//     }
//     await Addfile_Payment_Web(uuid, file.bytes!, file.name);
//   } else {
//     if (file.path == null) {
//       print('🚫 ไม่มี path สำหรับไฟล์นี้ (mobile)');
//       return null;
//     }
//     final ioFile = File(file.path!);
//     await Addfile_Payment_Mobile(uuid, ioFile);
//     return ioFile; // ✅ คืนค่าไฟล์บน Mobile/Desktop
//   }

//   return null; // ✅ คืนค่า default
// }
// Future<File?> PaypickAndUpload(String uuid, String uuid_request) async {
//   final result = await FilePicker.platform.pickFiles(
//     type: FileType.custom,
//     allowedExtensions: ['png', 'jpg', 'jpeg'],
//   );

//   if (result == null) {
//     print('⚠️ ผู้ใช้ไม่ได้เลือกไฟล์');
//     return null;
//   }

//   final file = result.files.first;

//   if (kIsWeb) {
//     if (file.bytes == null) {
//       print('🚫 ไม่สามารถอ่าน bytes ได้บนเว็บ');
//       return null;
//     }
//     await Addfile_Payment_Web(uuid, file.bytes!, file.name, uuid_request);
//   } else {
//     if (file.path == null) {
//       print('🚫 ไม่มี path สำหรับไฟล์นี้ (mobile)');
//       return null;
//     }
//     final ioFile = File(file.path!);
//     await Addfile_Payment_Mobile(uuid, ioFile, uuid_request);
//     return ioFile;
//   }

//   return null;
// }
Future<dynamic> PaypickAndUpload(String uuid, String uuid_request) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['png', 'jpg', 'jpeg'],
  );

  if (result == null) {
    print('⚠️ ผู้ใช้ไม่ได้เลือกไฟล์');
    return null;
  }

  final file = result.files.first;

  if (kIsWeb) {
    if (file.bytes == null) {
      print('🚫 ไม่สามารถอ่าน bytes ได้บนเว็บ');
      return null;
    }

    final response =
        await Addfile_Payment_Web(uuid, file.bytes!, file.name, uuid_request);
    print('📡 Web Upload Response: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        'base64': base64Encode(file.bytes!),
        'extension': file.extension ?? 'jpg'
      };
    } else {
      print('❌ Upload to Web server failed');
      return null;
    }
  } else {
    if (file.path == null) {
      print('🚫 ไม่มี path สำหรับไฟล์นี้ (mobile)');
      return null;
    }

    final ioFile = File(file.path!);
    final response = await Addfile_Payment_Mobile(uuid, ioFile, uuid_request);
    print('📡 Mobile Upload Response: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        'base64': base64Encode(await ioFile.readAsBytes()),
        'extension': file.extension ?? 'jpg'
      };
    } else {
      print('❌ Upload to Mobile server failed');
      return null;
    }
  }
}

Future<http.Response> Addfile_Payment_Web(String uuid, List<int> fileBytes,
    String filename, String uuid_request) async {
  final uri = Uri.parse('${MyConstant().domain_v1}/payments/$uuid/attachments');
  print(uri);
  print('uuid_request');
  print(uuid_request);
  var request = http.MultipartRequest('POST', uri)
    ..headers.addAll({
      'Accept': 'application/json',
      'Authorization':
          'Bearer 7|Xm7Hdf184i16Y45avEiYkalUofL6XstNlUQJDDiLe79fc995',
    })
    ..fields['document_id'] = '8'
    ..fields['request_uuid'] = uuid_request.toString()
    ..files.add(
      http.MultipartFile.fromBytes('file', fileBytes, filename: filename),
    );

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200 || response.statusCode == 201) {
    print('✅ Web อัปโหลดสำเร็จ: ${response.body}');
  } else {
    print('❌ Web อัปโหลดล้มเหลว: ${response.statusCode}');
    print('📄 ตอบกลับ: ${response.body}');
  }

  return response;
}

Future<http.Response> Addfile_Payment_Mobile(
    String uuid, File file, String uuid_request) async {
  final uri = Uri.parse('${MyConstant().domain_v1}/payments/$uuid/attachments');
  print(uri);
  print('uuid_request');
  print(uuid_request);
  var request = http.MultipartRequest('POST', uri)

    /// 0ddc7ea6-9636-4e2a-ba44-0e86d211f7cd
    ..headers.addAll({
      'Accept': 'application/json',
      'Authorization':
          'Bearer 7|Xm7Hdf184i16Y45avEiYkalUofL6XstNlUQJDDiLe79fc995',
    })
    ..fields['document_id'] = '8'
    ..fields['request_uuid'] = uuid_request.toString()
    ..files.add(
      await http.MultipartFile.fromPath('file', file.path,
          filename: path.basename(file.path)),
    );

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200 || response.statusCode == 201) {
    print('✅ Mobile/Desktop อัปโหลดสำเร็จ');
  } else {
    print('❌ Mobile/Desktop อัปโหลดล้มเหลว: ${response.statusCode}');
    print('📄 ตอบกลับ: ${response.body}');
  }

  return response;
}
