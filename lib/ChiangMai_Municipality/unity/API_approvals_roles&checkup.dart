import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import '../../Constant/Myconstant.dart';
import '../Model/Review_Model.dart';
import 'API_approvals_lastaction.dart';
import 'SecurePrefs_helper.dart';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:http_parser/http_parser.dart';

Future<ReviewResponse> read_GC_ApprovalsRoles({
  String? urlCustom,
  String query = '',
  int perPage = 1, // <- ใช้ค่าที่คุณตั้งไว้/ค่าจาก state ส่งเข้ามา
  String? orderBy,
  String? sortDir,
  String? zn,
}) async {
  final headers = await MyHeaders.build();

  try {
    final baseDomain =
        Uri.parse('${MyConstant().domain_v1}/admin/approvals/roles');
    Uri uri;
    if (urlCustom != null && urlCustom.isNotEmpty) {
      // ใช้ params จากลิงก์ next/prev แต่บังคับ Domain/Protocol และ Search State ของเรา
      final u = Uri.parse(urlCustom);
      final qp = Map<String, String>.from(u.queryParameters);
      qp['per_page'] = '50';
      qp['q'] = query; // บังคับเขียนทับเพื่อให้ตรงกับ UI ปัจจุบัน
      if (zn != null && zn.isNotEmpty)
        qp['zn'] = zn ?? ''; // บังคับเขียนทับเพื่อให้ตรงกับ UI ปัจจุบัน
      // เพิ่ม order_by และ sort_dir ถ้ามี
      if (orderBy != null && orderBy.isNotEmpty) {
        qp['order_by'] = orderBy;
      }
      if (sortDir != null && sortDir.isNotEmpty) {
        qp['sort_dir'] = sortDir;
      }

      // บังคับใช้ scheme/host จาก MyConstant เสมอ
      uri = baseDomain
          .replace(queryParameters: {...baseDomain.queryParameters, ...qp});
    } else {
      // ครั้งแรก: เราสร้าง URL เอง
      final params = (zn != null && zn.isNotEmpty)
          ? <String, String>{
              'per_page': '$perPage',
              'q': query,
              'zn': zn ?? '',
              'order_by': orderBy!,
              'sort_dir': sortDir!,
            }
          : <String, String>{
              'per_page': '$perPage',
              'q': query,
              'order_by': orderBy!,
              'sort_dir': sortDir!,
            };

      // เพิ่ม order_by และ sort_dir ถ้ามี
      if (orderBy != null && orderBy.isNotEmpty) {
        params['order_by'] = orderBy;
      }
      if (sortDir != null && sortDir.isNotEmpty) {
        params['sort_dir'] = sortDir;
      }

      uri = baseDomain
          .replace(queryParameters: {...baseDomain.queryParameters, ...params});
    }

    print('[GET] $uri');
    final resp = await http.get(uri, headers: headers);

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      //print('[ERR] ${resp.statusCode} ${resp.reasonPhrase}');
      //print('[BODY] ${resp.body}');
      return ReviewResponse(
          data: [], currentPage: 0, lastPage: 0, perPage: 0, total: 0);
    }

    final decoded = json.decode(resp.body);
    if (decoded is! Map) {
      //print('❌ unexpected JSON shape (not a Map)');
      return ReviewResponse(
          data: [], currentPage: 0, lastPage: 0, perPage: 0, total: 0);
    }
    final map = decoded as Map;

    // meta
    final int currentPage = int.tryParse('${map['current_page']}') ?? 0;
    final int lastPage = int.tryParse('${map['last_page']}') ?? 0;
    final int perPageVal = int.tryParse('${map['per_page']}') ?? 0;
    final int total = int.tryParse('${map['total']}') ?? 0;

    // links
    final String? linksFirst = map['first_page_url']?.toString();
    final String? linksLast = map['last_page_url']?.toString();
    final String? linksPrev = map['prev_page_url']?.toString();
    final String? linksNext = map['next_page_url']?.toString();

    // data
    List<ReviewModel> list = [];
    final data = map['data'];
    if (data is List) {
      list = data
          .whereType<Map<String, dynamic>>()
          .map(ReviewModel.fromJson)
          .toList();
      //print(
      //   '✅ ได้ข้อมูลทั้งหมด ${list.length} รายการ | prev=$linksPrev next=$linksNext');
    } else {
      //print('❌ "data" ไม่ใช่ List');
    }

    return ReviewResponse(
      data: list,
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: perPageVal,
      total: total,
      linksFirst: linksFirst,
      linksLast: linksLast,
      linksPrev: linksPrev,
      linksNext: linksNext,
    );
  } catch (e) {
    //print('Exception: $e');
    return ReviewResponse(
        data: [], currentPage: 0, lastPage: 0, perPage: 0, total: 0);
  }
}
// Future<http.Response?> read_GC_ApprovalsRoles() async {
//   final headers = await MyHeaders.build(); // ✅ ต้อง await

//   final url = Uri.parse('${MyConstant().domain_v1}/admin/approvals/roles');
//   //print('GET ApprovalsRoles : $url');
//   //print('GET headers : $headers');
//   try {
//     final response = await http.get(url, headers: headers);
//     //print('[${response.statusCode}]');

//     if (response.statusCode == 200) {
//       //print('✅ Get ApprovalsRoles Success');
//       // //print(response.body);
//     } else {
//       //print(
//           '❌ Get ApprovalsRoles Failed [${response.statusCode}]: ${response.body}');
//     }

//     return response;
//   } catch (e, stack) {
//     //print('❌ Exception during ApprovalsRoles request: $e');
//     //print('🧭 StackTrace:\n$stack');
//     return null;
//   }
// }

Future<http.Response?> read_GC_ApprovalsCheckUp(String? UuidRequest) async {
  final headers = await MyHeaders.build(); // ✅ ต้อง await

  final url =
      Uri.parse('${MyConstant().domain_v1}/admin/approvals/$UuidRequest/check');
  //print('GET ApprovalsCheckUp : $url');
  //print('GET headers : $headers');
  try {
    final response = await http.get(url, headers: headers);
    //print('[${response.statusCode}]');

    if (response.statusCode == 200) {
      //print('✅ Get ApprovalsCheckUp Success');
      // //print(response.body);
    } else {
      //print(
      //  '❌ Get ApprovalsCheckUp Failed [${response.statusCode}]: ${response.body}');
    }

    return response;
  } catch (e, stack) {
    //print('❌ Exception during ApprovalsCheckUp request: $e');
    //print('🧭 StackTrace:\n$stack');
    return null;
  }
}

Future<http.Response?> img_ApprovalsRequests(String? attachmentUuid) async {
  final headers = await MyHeaders.build(); // 🔐 สร้าง headers พร้อม token

  final url = Uri.parse(
    '${MyConstant().domain_v1}/admin/requests/attachments/${attachmentUuid}/preview',
  );

  //print('📤 GET Image ApprovalsRequests: $url');
  // //print('🧾 Headers: $headers');

  try {
    final response = await http.get(url, headers: headers);
    //print('[${response.statusCode}]');

    if (response.statusCode == 200) {
      //print('✅ ApprovalsRequests image loaded successfully');
    } else {
      //print(
      // '❌ Failed to load image [${response.statusCode}]: ${response.body}');
    }

    return response;
  } catch (e, stackTrace) {
    //print('❌ Exception occurred: $e');
    // //print('🧭 Stack trace:\n$stackTrace');
    return null;
  }
}

// Future<http.Response?> pdf_ApprovalsCheckUp(
//   String? uuidRequest,
//   String? attachmentUuid,
// ) async {
//   if (uuidRequest == null || attachmentUuid == null) {
//     //print('❌ uuidRequest หรือ attachmentUuid เป็น null');
//     return null;
//   }

//   final headers = await MyHeaders.build();

//   final url = Uri.parse(
//     '${MyConstant().domain_v1}/admin/approvals/$uuidRequest/check/$attachmentUuid/preview',
//   );

//   //print('📤 GET Image ApprovalsCheckUp: $url');

//   try {
//     final response = await http.get(url, headers: headers);
//     //print('[${response.statusCode}]');

//     if (response.statusCode == 200) {
//       //print('✅ ApprovalsCheckUp image loaded successfully');
//       //print('🧾 Content-Type: ${response.headers['content-type']}');
//     } else {
//       //print(
//           '❌ Failed to load image [${response.statusCode}]: ${response.body}');
//     }

//     return response;
//   } catch (e, stackTrace) {
//     //print('❌ Exception occurred: $e');
//     return null;
//   }
// }

Future<http.Response?> img_ApprovalsCheckUp(
    String? uuidRequest, String? attachmentUuid) async {
  final headers = await MyHeaders.build(); // 🔐 สร้าง headers พร้อม token

  final url = Uri.parse(
    '${MyConstant().domain_v1}/admin/approvals/$uuidRequest/check/$attachmentUuid/preview',
  );

  //print('📤 GET Image ApprovalsCheckUp: $url');
  // //print('🧾 Headers: $headers');

  try {
    final response = await http.get(url, headers: headers);
    //print('[${response.statusCode}]');

    if (response.statusCode == 200) {
      //print('✅ ApprovalsCheckUp image loaded successfully');
    } else {
      //print(
      // '❌ Failed to load image [${response.statusCode}]: ${response.body}');
    }

    return response;
  } catch (e, stackTrace) {
    //print('❌ Exception occurred: $e');
    // //print('🧭 Stack trace:\n$stackTrace');
    return null;
  }
}

/////--------------------------------->

// Future<dynamic> pickAndUpload_CheckUp(String uuidRequest, int docId) async {
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

//       final response = await Addfile_Document_Web_CheckUp(
//           uuidRequest, file.bytes!, file.name, docId);
//       //print('📡 Web upload response: ${response.statusCode}');
//       return response;
//     } else {
//       if (file.path == null) {
//         //print('🚫 ไม่มี path สำหรับไฟล์นี้ (mobile)');
//         return null;
//       }

//       final ioFile = File(file.path!);
//       final response =
//           await Addfile_Document_Mobile_CheckUp(uuidRequest, ioFile, docId);
//       //print('📡 Mobile upload response: ${response!.statusCode}');
//       return response;
//     }
//   } catch (e, stack) {
//     //print('❌ เกิดข้อผิดพลาดระหว่างอัปโหลด: $e');
//     //print('🧱 StackTrace:\n$stack');
//     return null;
//   }
// }
Future<dynamic> pickAndUpload_CheckUp(String uuid, int docId) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf'],
  );

  if (result == null) {
    //print('⚠️ ผู้ใช้ไม่ได้เลือกไฟล์');
    return null;
  }

  final file = result.files.first;

  try {
    if (kIsWeb) {
      if (file.bytes == null) {
        //print('🚫 ไม่สามารถอ่าน bytes ได้บนเว็บ');
        return null;
      }

      final response = await Addfile_Document_Web_CheckUp(
          uuid, file.bytes!, file.name, docId);
      //print('📡 Web upload response: ${response.statusCode}');
      return response;
    } else {
      if (file.path == null) {
        //print('🚫 ไม่มี path สำหรับไฟล์นี้ (mobile)');
        return null;
      }

      final ioFile = File(file.path!);
      final response =
          await Addfile_Document_Mobile_CheckUp(uuid, ioFile, docId);
      //print('📡 Mobile upload response: ${response!.statusCode}');
      return response;
    }
  } catch (e, stack) {
    //print('❌ เกิดข้อผิดพลาดระหว่างอัปโหลด: $e');
    //print('🧱 StackTrace:\n$stack');
    return null;
  }
}

Future<http.Response> Addfile_Document_Web_CheckUp(
    String uuidRequest, List<int> fileBytes, String filename, int docId) async {
  final uri = Uri.parse(
      '${MyConstant().domain_v1}/admin/approvals/$uuidRequest/check/attachments');
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

Future<http.Response?> Addfile_Document_Mobile_CheckUp(
    String uuidRequest, File file, int docId) async {
  final uri = Uri.parse(
      '${MyConstant().domain_v1}/admin/approvals/$uuidRequest/check/attachments');
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
