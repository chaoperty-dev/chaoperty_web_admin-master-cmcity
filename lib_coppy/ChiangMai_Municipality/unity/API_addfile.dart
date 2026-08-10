import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

import '../../Constant/Myconstant.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

// import 'Addfile_Document.dart'; // <== อย่าลืม import
// Future<File?> pickAndUpload(String uuid, int docId) async {
//   final result = await FilePicker.platform.pickFiles();

//   if (result == null) {
//     //print('⚠️ ผู้ใช้ไม่ได้เลือกไฟล์');
//     return null; // ❗ ต้องคืนค่า null อย่างชัดเจน
//   }

//   final file = result.files.first;

//   if (kIsWeb) {
//     if (file.bytes == null) {
//       //print('🚫 ไม่สามารถอ่าน bytes ได้บนเว็บ');
//       return null;
//     }
//     final response =
//         await Addfile_Document_Web(uuid, file.bytes!, file.name, docId);
//   } else {
//     if (file.path == null) {
//       //print('🚫 ไม่มี path สำหรับไฟล์นี้ (mobile)');
//       return null;
//     }
//     final ioFile = File(file.path!);
//     final response = await Addfile_Document_Mobile(uuid, ioFile, docId);
//     return response; // ✅ คืนค่าไฟล์บน Mobile/Desktop
//   }

//   return null; // ✅ คืนค่า default
// }
enum UploadAction { file, camera }

enum BatchStatus { idle, queued, uploading, success, failed }

class BatchItem {
  BatchItem({required this.doc});
  final dynamic doc; // documentModels[i]
  PlatformFile? file; // ไฟล์ที่จับคู่กับ doc นี้
  double progress = 0; // 0..1
  BatchStatus status = BatchStatus.idle;
  String? error;
}

Future<bool> ensureCameraPermission() async {
  if (kIsWeb) return true; // web ให้เบราว์เซอร์จัดการ
  final status = await Permission.camera.request();
  return status.isGranted;
}
// ถ้าจะใช้ fallback เขียน temp file บนมือถือ ให้เพิ่ม:
// import 'package:path_provider/path_provider.dart';

Future<dynamic> pickAndUpload(
  String uuid,
  int docId, {
  bool useCamera = false,

  // ✅ เพิ่มทางเลือกให้รับไฟล์ที่เลือกไว้แล้ว
  PlatformFile? selectedFile,
  Uint8List? bytes,
  String? filename,
  String? path,
}) async {
  try {
    // -------------------- กรณีส่งไฟล์เข้ามาให้แล้ว (batch) --------------------
    if (selectedFile != null || bytes != null || path != null) {
      final _name = filename ?? selectedFile?.name ?? 'upload.bin';
      final _ext = (_name.split('.').length > 1)
          ? _name.split('.').last.toLowerCase()
          : '';
      if (kIsWeb) {
        // เว็บ: ต้องใช้ bytes เท่านั้น
        final webBytes = bytes ?? selectedFile?.bytes;
        if (webBytes == null) {
          //   //print('🚫 [web] ไม่มี bytes สำหรับอัปโหลด');
          return null;
        }
        final response =
            await Addfile_Document_Web(uuid, webBytes, _name, docId);
        //  //print('📡 Web upload response: ${response.statusCode}');
        return response;
      } else {
        // มือถือ/เดสก์ท็อป: ถ้ามี path ใช้ path → File ได้เลย (เร็วสุด)
        final p = path ?? selectedFile?.path;
        if (p != null) {
          final ioFile = File(p);
          final response = await Addfile_Document_Mobile(uuid, ioFile, docId);
          //  //print('📡 Mobile upload response: ${response?.statusCode}');
          return response;
        }

        // ไม่มี path แต่มี bytes → จะต้องเขียนเป็นไฟล์ชั่วคราวก่อนส่ง (หาก Addfile_Document_Mobile ต้องการ File)
        if (bytes != null || selectedFile?.bytes != null) {
          final raw = bytes ?? selectedFile!.bytes!;
          // ---- ถ้าคุณอยากเขียนไฟล์ชั่วคราว ให้ uncomment โค้ดด้านล่าง ----
          // final dir = await getTemporaryDirectory();
          // final tmp = File('${dir.path}/$_name');
          // await tmp.writeAsBytes(raw, flush: true);
          // final response = await Addfile_Document_Mobile(uuid, tmp, docId);
          // //print('📡 Mobile upload (temp) response: ${response?.statusCode}');
          // return response;

          // หรือถ้าคุณมีฟังก์ชัน Addfile_Document_*** ที่รับ bytes บน mobile ด้วย
          // ก็สามารถสร้างเวอร์ชัน Addfile_Document_MobileBytes(...) แล้วเรียกแทนได้
          ////print(
          //  '⚠️ ไม่มี path บน mobile และยังไม่ได้รองรับ upload-from-bytes ตรงๆ');
          return null;
        }

        ////print('🚫 mobile/desktop: ไม่พบ path หรือ bytes');
        return null;
      }
    }

    // -------------------- กรณี Interactive เดิม (กล้อง/ไฟล์ picker) --------------------
    if (useCamera) {
      final picked = await ImagePicker().pickImage(source: ImageSource.camera);
      if (picked == null) {
        ////print('⚠️ ผู้ใช้กดยกเลิกกล้อง');
        return null;
      }
      final file = File(picked.path);
      final response = await Addfile_Document_Mobile(uuid, file, docId);
      ////print('📡 Camera upload response: ${response?.statusCode}');
      return response;
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: (docId == 9)
            ? ['png', 'jpg', 'jpeg', 'pdf']
            : ['png', 'jpg', 'jpeg', 'pdf'],
      );
      if (result == null) {
        //print('⚠️ ผู้ใช้ไม่ได้เลือกไฟล์');
        return null;
      }
      final file = result.files.first;

      if (kIsWeb) {
        if (file.bytes == null) {
          //print('🚫 ไม่สามารถอ่าน bytes ได้บนเว็บ');
          return null;
        }
        final response =
            await Addfile_Document_Web(uuid, file.bytes!, file.name, docId);
        //print('📡 Web upload response: ${response.statusCode}');
        return response;
      } else {
        if (file.path == null) {
          //print('🚫 ไม่มี path สำหรับไฟล์นี้ (mobile)');
          return null;
        }
        final ioFile = File(file.path!);
        final response = await Addfile_Document_Mobile(uuid, ioFile, docId);
        //print('📡 Mobile upload response: ${response?.statusCode}');
        return response;
      }
    }
  } catch (e, stack) {
    //print('❌ เกิดข้อผิดพลาดระหว่างอัปโหลด: $e');
    //print('🧱 StackTrace:\n$stack');
    return null;
  }
}

// Future<dynamic> pickAndUpload(String uuid, int docId,
//     {bool useCamera = false}) async {
//   try {
//     if (useCamera) {
//       // 📸 เปิดกล้อง
//       final picked = await ImagePicker().pickImage(source: ImageSource.camera);
//       if (picked == null) {
//         //print('⚠️ ผู้ใช้กดยกเลิกกล้อง');
//         return null;
//       }

//       final file = File(picked.path);
//       final response = await Addfile_Document_Mobile(uuid, file, docId);
//       //print('📡 Camera upload response: ${response?.statusCode}');
//       return response;
//     } else {
//       // 📂 เลือกไฟล์จากเครื่อง
//       final result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf'],
//       );

//       if (result == null) {
//         //print('⚠️ ผู้ใช้ไม่ได้เลือกไฟล์');
//         return null;
//       }

//       final file = result.files.first;

//       if (kIsWeb) {
//         if (file.bytes == null) {
//           //print('🚫 ไม่สามารถอ่าน bytes ได้บนเว็บ');
//           return null;
//         }
//         final response =
//             await Addfile_Document_Web(uuid, file.bytes!, file.name, docId);
//         //print('📡 Web upload response: ${response.statusCode}');
//         return response;
//       } else {
//         if (file.path == null) {
//           //print('🚫 ไม่มี path สำหรับไฟล์นี้ (mobile)');
//           return null;
//         }
//         final ioFile = File(file.path!);
//         final response = await Addfile_Document_Mobile(uuid, ioFile, docId);
//         //print('📡 Mobile upload response: ${response?.statusCode}');
//         return response;
//       }
//     }
//   } catch (e, stack) {
//     //print('❌ เกิดข้อผิดพลาดระหว่างอัปโหลด: $e');
//     //print('🧱 StackTrace:\n$stack');
//     return null;
//   }
// }

// Future<dynamic> pickAndUpload(String uuid, int docId) async {
//   final result = await FilePicker.platform.pickFiles(
//     type: FileType.custom,
//     allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf'],
//   );

//   if (result == null) {
//     //print('⚠️ ผู้ใช้ไม่ได้เลือกไฟล์');
//     return null;
//   }

//   final file = result.files.first;

//   try {
//     if (kIsWeb) {
//       if (file.bytes == null) {
//         //print('🚫 ไม่สามารถอ่าน bytes ได้บนเว็บ');
//         return null;
//       }

//       final response =
//           await Addfile_Document_Web(uuid, file.bytes!, file.name, docId);
//       //print('📡 Web upload response: ${response.statusCode}');
//       return response;
//     } else {
//       if (file.path == null) {
//         //print('🚫 ไม่มี path สำหรับไฟล์นี้ (mobile)');
//         return null;
//       }

//       final ioFile = File(file.path!);
//       final response = await Addfile_Document_Mobile(uuid, ioFile, docId);
//       //print('📡 Mobile upload response: ${response!.statusCode}');
//       return response;
//     }
//   } catch (e, stack) {
//     //print('❌ เกิดข้อผิดพลาดระหว่างอัปโหลด: $e');
//     //print('🧱 StackTrace:\n$stack');
//     return null;
//   }
// }

Future<http.Response> Addfile_Document_Web(
    String uuid, List<int> fileBytes, String filename, int docId) async {
  final uri =
      Uri.parse('${MyConstant().domain_v1}/admin/requests/$uuid/attachments');
  //print(uri);
  final headers = await MyHeaders.build(); // ✅ ต้อง await
  var request = http.MultipartRequest('POST', uri)
    ..headers.addAll(headers
        //   {
        //   'Accept': 'application/json',
        //   'Authorization':
        //       'Bearer 7|Xm7Hdf184i16Y45avEiYkalUofL6XstNlUQJDDiLe79fc995',
        // }
        )
    ..fields['document_id'] = docId.toString()
    ..files.add(
      http.MultipartFile.fromBytes('file', fileBytes, filename: filename),
    );

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200 || response.statusCode == 201) {
    //print('✅ Web อัปโหลดสำเร็จ: ${response.body}');
  } else {
    //print('❌ Web อัปโหลดล้มเหลว: ${response.statusCode}');
    //print('📄 ตอบกลับ: ${response.body}');
  }

  return response;
}

Future<http.Response?> Addfile_Document_Mobile(
    String uuid, File file, int docId) async {
  final uri =
      Uri.parse('${MyConstant().domain_v1}/admin/requests/$uuid/attachments');
  //print(uri);
  final headers = await MyHeaders.build(); // ✅ ต้อง await
  var request = http.MultipartRequest('POST', uri)
    ..headers.addAll(headers
        //   {
        //   'Accept': 'application/json',
        //   'Authorization':
        //       'Bearer 7|Xm7Hdf184i16Y45avEiYkalUofL6XstNlUQJDDiLe79fc995',
        // }
        )
    ..fields['document_id'] = docId.toString()
    ..files.add(await http.MultipartFile.fromPath('file', file.path,
        filename: path.basename(file.path)));

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200 || response.statusCode == 201) {
    //print('✅ Mobile/Desktop อัปโหลดสำเร็จ');
  } else {
    //print('❌ Mobile/Desktop อัปโหลดล้มเหลว: ${response.statusCode}');
    //print('📄 ตอบกลับ: ${response.body}');
  }

  return response;
}

/// อัปโหลดไฟล์เป็น bytes ผูกกับหัวข้อเอกสาร (docId) และคำร้อง (requestUuid)
/// - [baseUrl] เช่น https://api.yourdomain.com
/// - [endpoint] path ของอัปโหลด เช่น /reviews/attachments
/// - [authToken] ใส่ถ้ามี Bearer token
/// คืนค่า: Response จากเซิร์ฟเวอร์ (โยน exception ถ้าล้มเหลว)
Future<Response<dynamic>> uploadBytes({
  required String baseUrl,
  required String endpoint,
  required String requestUuid,
  required int docId,
  required String filename,
  required Uint8List bytes,
  String? authToken,
  void Function(int sent, int total)? onSendProgress,
  Map<String, dynamic>? extraFields, // เผื่อส่งฟิลด์อื่นๆ
}) async {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    headers: {
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    },
  ));

  // เดา MIME จากชื่อไฟล์
  final mime = lookupMimeType(filename) ?? 'application/octet-stream';

  final formData = FormData.fromMap({
    // ปรับชื่อฟิลด์ให้ตรงกับ API ฝั่งคุณ
    'request_uuid': requestUuid,
    'document_id': docId.toString(),
    if (extraFields != null) ...extraFields,
    'file': MultipartFile.fromBytes(
      bytes,
      filename: filename,
      // contentType: HeadersContentType.parse(mime),
    ),
  });

  final resp = await dio.post(
    endpoint,
    data: formData,
    onSendProgress: onSendProgress,
    options: Options(
      // ถ้าเซิร์ฟเวอร์คาดหวัง multipart/form-data ไม่ต้องระบุ content-type เอง
      // dio จะใส่ boundary ให้
      responseType: ResponseType.json,
    ),
  );

  // ตรวจสถานะเองตามโปรโตคอลของคุณ
  if (resp.statusCode != 200 && resp.statusCode != 201) {
    throw DioException(
      requestOptions: resp.requestOptions,
      response: resp,
      message: 'Upload failed (${resp.statusCode})',
      type: DioExceptionType.badResponse,
    );
  }
  return resp;
}
