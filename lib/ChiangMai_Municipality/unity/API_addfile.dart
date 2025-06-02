import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as path;

import '../../Constant/Myconstant.dart';

// import 'Addfile_Document.dart'; // <== อย่าลืม import

// Future<File?> pickAndUpload(String uuid, int docId) async {
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
//     final response =
//         await Addfile_Document_Web(uuid, file.bytes!, file.name, docId);
//   } else {
//     if (file.path == null) {
//       print('🚫 ไม่มี path สำหรับไฟล์นี้ (mobile)');
//       return null;
//     }
//     final ioFile = File(file.path!);
//     final response = await Addfile_Document_Mobile(uuid, ioFile, docId);
//     return response; // ✅ คืนค่าไฟล์บน Mobile/Desktop
//   }

//   return null; // ✅ คืนค่า default
// }
Future<dynamic> pickAndUpload(String uuid, int docId) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf'],
  );

  if (result == null) {
    print('⚠️ ผู้ใช้ไม่ได้เลือกไฟล์');
    return null;
  }

  final file = result.files.first;

  try {
    if (kIsWeb) {
      if (file.bytes == null) {
        print('🚫 ไม่สามารถอ่าน bytes ได้บนเว็บ');
        return null;
      }

      final response =
          await Addfile_Document_Web(uuid, file.bytes!, file.name, docId);
      print('📡 Web upload response: ${response.statusCode}');
      return response;
    } else {
      if (file.path == null) {
        print('🚫 ไม่มี path สำหรับไฟล์นี้ (mobile)');
        return null;
      }

      final ioFile = File(file.path!);
      final response = await Addfile_Document_Mobile(uuid, ioFile, docId);
      print('📡 Mobile upload response: ${response!.statusCode}');
      return response;
    }
  } catch (e, stack) {
    print('❌ เกิดข้อผิดพลาดระหว่างอัปโหลด: $e');
    print('🧱 StackTrace:\n$stack');
    return null;
  }
}

Future<http.Response> Addfile_Document_Web(
    String uuid, List<int> fileBytes, String filename, int docId) async {
  final uri =
      Uri.parse('${MyConstant().domain_v1}/admin/requests/$uuid/attachments');
  print(uri);

  var request = http.MultipartRequest('POST', uri)
    ..headers.addAll({
      'Accept': 'application/json',
      'Authorization':
          'Bearer 7|Xm7Hdf184i16Y45avEiYkalUofL6XstNlUQJDDiLe79fc995',
    })
    ..fields['document_id'] = docId.toString()
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

Future<http.Response?> Addfile_Document_Mobile(
    String uuid, File file, int docId) async {
  final uri =
      Uri.parse('${MyConstant().domain_v1}/admin/requests/$uuid/attachments');
  print(uri);

  var request = http.MultipartRequest('POST', uri)
    ..headers.addAll({
      'Accept': 'application/json',
      'Authorization':
          'Bearer 7|Xm7Hdf184i16Y45avEiYkalUofL6XstNlUQJDDiLe79fc995',
    })
    ..fields['document_id'] = docId.toString()
    ..files.add(await http.MultipartFile.fromPath('file', file.path,
        filename: path.basename(file.path)));

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

// Future<void> Addfile_Document_Mobile(String uuid, File file, int docId) async {
//   final uri =
//       Uri.parse('${MyConstant().domain_v1}/admin/requests/$uuid/attachments');
//   print(uri);
//   var request = http.MultipartRequest('POST', uri)
//     ..headers.addAll({
//       'Accept': 'application/json',
//       'Authorization':
//           'Bearer 7|Xm7Hdf184i16Y45avEiYkalUofL6XstNlUQJDDiLe79fc995',
//     })
//     ..fields['document_id'] = docId.toString()
//     ..files.add(
//       await http.MultipartFile.fromPath('file', file.path,
//           filename: path.basename(file.path)),
//     );

//   final response = await request.send();
//   final body = await response.stream.bytesToString();

//   if (response.statusCode == 200) {
//     print('✅ Mobile/Desktop อัปโหลดสำเร็จ: ');
//   } else {
//     print('❌ Mobile/Desktop อัปโหลดล้มเหลว: ${response.statusCode}');
//     print('📄 ตอบกลับ: $body');
//   }
// }
