import 'dart:convert';
import 'dart:io'
    show File; // ❗ ถ้ารองรับ web ต้องแยกไฟล์ หรือใช้ conditional import
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../../Constant/Myconstant.dart';
import 'config-intents.dart';

/// เลือกรูปสลิป + อัปโหลดไปที่ /payment-intents/{intentUuid}/upload-slip
/// คืนค่า: { base64, extension } ถ้าสำเร็จ, null ถ้ายกเลิกหรือพัง
Future<Map<String, String>?> payPickAndUpload({
  required String reportedDate, // รูปแบบที่ backend ต้องการ เช่น '2025-10-15'
  required String intentUuid,
}) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['png', 'jpg', 'jpeg'],
  );

  if (result == null) {
    print('⚠️ The user has not selected a file. ผู้ใช้ไม่ได้เลือกไฟล์');
    return null;
  }

  final file = result.files.first;

  if (kIsWeb) {
    // ----- WEB: ใช้ bytes -----
    if (file.bytes == null) {
      print('🚫 Unable to read bytes on the web ไม่สามารถอ่าน bytes ได้บนเว็บ');
      return null;
    }

    final response = await addFilePaymentWeb(
      intentUuid: intentUuid,
      fileBytes: file.bytes!,
      filename: file.name,
      reportedDate: reportedDate,
    );

    print('📡 Web Upload Response: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        'base64': base64Encode(file.bytes!),
        'extension': file.extension ?? 'jpg',
      };
    } else {
      print('❌ Upload to Web server failed: ${response.statusCode}');
      print('📄 Response body: ${response.body}');
      return null;
    }
  } else {
    // ----- MOBILE / DESKTOP: ใช้ไฟล์ path -----
    if (file.path == null) {
      print(
          '🚫 There is no path for this file (mobile) ไม่มี path สำหรับไฟล์นี้');
      return null;
    }

    final ioFile = File(file.path!);
    final response = await addFilePaymentMobile(
      intentUuid: intentUuid,
      file: ioFile,
      reportedDate: reportedDate,
    );

    print('📡 Mobile Upload Response: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final bytes = await ioFile.readAsBytes();
      return {
        'base64': base64Encode(bytes),
        'extension': file.extension ?? 'jpg',
      };
    } else {
      print('❌ Upload to Mobile server failed: ${response.statusCode}');
      print('📄 Response body: ${response.body}');
      return null;
    }
  }
}

Future<http.Response> addFilePaymentWeb({
  required String intentUuid,
  required List<int> fileBytes,
  required String filename,
  required String reportedDate, // 'YYYY-MM-DD'
}) async {
  final uri = Uri.parse(
    '${MyconfigIntents().domainIntents}/payment-intents/$intentUuid/upload-slip',
  );
  print('🌐 Web upload URI: $uri');
  print('intent_uuid: $intentUuid');

  final headers = await MyHeaders.build(); // รวม Auth / X-Tenant ฯลฯ

  final request = http.MultipartRequest('POST', uri)
    ..headers.addAll(headers)
    ..fields['reported_date'] = reportedDate
    ..files.add(
      http.MultipartFile.fromBytes(
        'slip_file',
        fileBytes,
        filename: filename,
      ),
    );

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200 || response.statusCode == 201) {
    print('✅ Web Upload succeed อัปโหลดสำเร็จ: ${response.body}');
  } else {
    print('❌ Web Upload failed อัปโหลดล้มเหลว : ${response.statusCode}');
    print('📄 ตอบกลับ(response): ${response.body}');
  }

  return response;
}

Future<http.Response> addFilePaymentMobile({
  required String intentUuid,
  required File file,
  required String reportedDate, // 'YYYY-MM-DD'
}) async {
  final uri = Uri.parse(
    '${MyconfigIntents().domainIntents}/payment-intents/$intentUuid/upload-slip',
  );
  print('📱 Mobile upload URI: $uri');
  print('intent_uuid: $intentUuid');

  final headers = await MyHeaders.build();

  final request = http.MultipartRequest('POST', uri)
    ..headers.addAll(headers)
    ..fields['reported_date'] = reportedDate
    ..files.add(
      await http.MultipartFile.fromPath(
        'slip_file',
        file.path,
        filename: path.basename(file.path),
      ),
    );

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200 || response.statusCode == 201) {
    print('✅ Mobile/Desktop Upload succeed อัปโหลดสำเร็จ: ${response.body}');
  } else {
    print(
        '❌ Mobile/Desktop Upload failed อัปโหลดล้มเหลว: ${response.statusCode}');
    print('📄 ตอบกลับ(response): ${response.body}');
  }

  return response;
}
