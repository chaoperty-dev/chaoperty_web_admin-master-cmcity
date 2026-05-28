import 'dart:convert';
import 'dart:io';
import 'dart:js';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:path/path.dart' as path;

import '../../Constant/Myconstant.dart';

Future<http.Response?> read_AnnounceMent_All() async {
  final headers = await MyHeaders.build(); // ✅ ต้อง await

  final url = Uri.parse('${MyConstant().domain_v1}/admin/announcement');
  //print('GET AnnounceMent_All : $url');
  //print('GET headers : $headers');
  try {
    final response = await http.get(url, headers: headers);
    //print('[${response.statusCode}]');

    if (response.statusCode == 200) {
      //print('✅ Get AnnounceMent_All Success');
      // //print(response.body);
    } else {
      //print(
      //  '❌ Get AnnounceMent_All Failed [${response.statusCode}]: ${response.body}');
    }

    return response;
  } catch (e, stack) {
    //print('❌ Exception during AnnounceMent_All request: $e');
    //print('🧭 StackTrace:\n$stack');
    return null;
  }
}

Future<http.Response?> read_AnnounceMent_Active() async {
  final headers = await MyHeaders.build(); // ✅ ต้อง await

  final url = Uri.parse('${MyConstant().domain_v1}/admin/announcement/active');
  //print('GET AnnounceMent_Active : $url');
  //print('GET headers : $headers');
  try {
    final response = await http.get(url, headers: headers);
    //print('[${response.statusCode}]');

    if (response.statusCode == 200) {
      //print('✅ Get AnnounceMent_Active Success');
      // //print(response.body);
    } else {
      //print(
      // '❌ Get AnnounceMent_Active Failed [${response.statusCode}]: ${response.body}');
    }

    return response;
  } catch (e, stack) {
    //print('❌ Exception during AnnounceMent_Active request: $e');
    //print('🧭 StackTrace:\n$stack');
    return null;
  }
}

Future<http.Response?> read_AnnounceMent_History() async {
  final headers = await MyHeaders.build(); // ✅ ต้อง await

  final url = Uri.parse('${MyConstant().domain_v1}/admin/announcement/history');
  //print('GET AnnounceMent_History : $url');
  //print('GET headers : $headers');
  try {
    final response = await http.get(url, headers: headers);
    //print('[${response.statusCode}]');

    if (response.statusCode == 200) {
      //print('✅ Get AnnounceMent_History Success');
      // //print(response.body);
    } else {
      //print(
      //  '❌ Get AnnounceMent_History Failed [${response.statusCode}]: ${response.body}');
    }

    return response;
  } catch (e, stack) {
    //print('❌ Exception during AnnounceMent_History request: $e');
    //print('🧭 StackTrace:\n$stack');
    return null;
  }
}

Future<http.Response?> read_AnnounceMent_Details(
    {required String announcementUuid}) async {
  final headers = await MyHeaders.build(); // ✅ ต้อง await

  final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/announcement/$announcementUuid');
  //print('GET AnnounceMent_Details : $url');
  //print('GET headers : $headers');
  try {
    final response = await http.get(url, headers: headers);
    //print('[${response.statusCode}]');

    if (response.statusCode == 200) {
      //print('✅ Get AnnounceMent_Details Success');
      // //print(response.body);
    } else {
      //print(
      //  '❌ Get AnnounceMent_Details Failed [${response.statusCode}]: ${response.body}');
    }

    return response;
  } catch (e, stack) {
    //print('❌ Exception during AnnounceMent_Details request: $e');
    //print('🧭 StackTrace:\n$stack');
    return null;
  }
}

Future<http.Response?> read_AnnounceMent_Getzone(
    {required String zoneid}) async {
  final headers = await MyHeaders.build(); // ✅ ต้อง await

  final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/announcement/getzone?zoneid=$zoneid');
  //print('GET AnnounceMent_Getzone : $url');
  //print('GET headers : $headers');
  try {
    final response = await http.get(url, headers: headers);
    //print('[${response.statusCode}]');

    if (response.statusCode == 200) {
      //print('✅ Get AnnounceMent_Getzone Success');
      // //print(response.body);
    } else {
      //print(
      //  '❌ Get AnnounceMent_Getzone Failed [${response.statusCode}]: ${response.body}');
    }

    return response;
  } catch (e, stack) {
    //print('❌ Exception during AnnounceMent_Getzone request: $e');
    //print('🧭 StackTrace:\n$stack');
    return null;
  }
}

Future<Uint8List?> read_Announcement_Preview({
  required String announcementUuid,
}) async {
  final headers = await MyHeaders.build();

  var request = http.Request(
    'GET',
    Uri.parse(
        '${MyConstant().domain_v1}/admin/announcement/$announcementUuid/preview'),
  );

  request.headers.addAll(headers);

  try {
    http.StreamedResponse streamedResponse = await request.send();

    if (streamedResponse.statusCode == 200) {
      final bytes = await streamedResponse.stream.toBytes(); // ✅ binary
      return bytes;
    } else {
      //print(
      // "Error ${streamedResponse.statusCode}: ${streamedResponse.reasonPhrase}");
      return null;
    }
  } catch (e) {
    //print("Exception occurred: $e");
    return null;
  }
}

Future<http.Response?> read_Announcement_Delete({
  required String announcementUuid,
}) async {
  final headers = await MyHeaders.build(); // ✅ ต้อง await

  final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/announcement/$announcementUuid/delete');
  //print('POST Announcement_Delete : $url');
  //print('POST headers : $headers');
  try {
    final response = await http.post(url, headers: headers);
    //print('[${response.statusCode}]');

    if (response.statusCode == 200) {
      //print('✅ Get Announcement_Delete Success');
      // //print(response.body);
    } else {
      //print(
      //  '❌ Get Announcement_Delete Failed [${response.statusCode}]: ${response.body}');
    }

    return response;
  } catch (e, stack) {
    //print('❌ Exception during Announcement_Delete request: $e');
    //print('🧭 StackTrace:\n$stack');
    return null;
  }
}

Future<http.Response?> MainPost_AnnounceMent({
  fileBytes,
  filename,
  file,
  required String lang,
  required String title,
  required String content,
  required List<Map<String, dynamic>> meta,
  required List<Map<String, dynamic>> zones,
  required String cDateStart,
  required String cDateEnd,
  required String effectiveAt,
  required String expiredAt,
  required String publishedAt,
}) async {
  //print('📝 LANG: $lang');
  //print('📝 TITLE: $title');
  //print('📝 META: ${json.encode(meta)}');
  //print('📝 ZONES: ${json.encode(zones)}');
  // filename:
  // '${filename.endsWith(".pdf") ? filename : "$filename.pdf"}';
  if (fileBytes != null || file != null) {
    //print('fileBytes != null || file != null');
    if (kIsWeb) {
      return Post_AnnounceMentFile_Web(
        fileBytes,
        filename,
        lang,
        title,
        content,
        meta,
        zones,
        cDateStart,
        cDateEnd,
        effectiveAt,
        expiredAt,
        publishedAt,
      );
    } else {
      return Post_AnnounceMentFile_Mobile(
        file,
        filename,
        lang,
        title,
        content,
        meta,
        zones,
        cDateStart,
        cDateEnd,
        effectiveAt,
        expiredAt,
        publishedAt,
      );
    }
  } else {
    // //print('Post_AnnounceMentNotFile');
    return Post_AnnounceMentNotFile(
        lang: lang,
        title: title,
        content: content,
        meta: meta,
        zones: zones,
        cDateStart: cDateStart,
        cDateEnd: cDateEnd,
        effectiveAt: effectiveAt,
        expiredAt: expiredAt,
        publishedAt: publishedAt);
  }
}

//////////------------------------------------------------------------------->
Future<dynamic> PaypickAndUpload() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['png', 'jpg', 'jpeg'],
  );

  if (result == null) {
    //print('⚠️ The user has not selected a file. ผู้ใช้ไม่ได้เลือกไฟล์');
    return null;
  }

  final file = result.files.first;

  if (kIsWeb) {
    if (file.bytes == null) {
      //print('🚫 Unable to read bytes on the web ไม่สามารถอ่าน bytes ได้บนเว็บ');
      return null;
    }

    return file.bytes;
  } else {
    if (file.path == null) {
      //print(
      //    '🚫 There is no Not path for this File (mobile) ไม่มี Not path สำหรับ File นี้ (mobile)');
      return null;
    }

    final ioFile = File(file.path!);
    return ioFile;
  }
}

Future<http.Response?> Post_AnnounceMentNotFile(
    {required String lang,
    required String title,
    required String content,
    required List<Map<String, dynamic>> meta,
    required List<Map<String, dynamic>> zones,
    required String cDateStart,
    required String cDateEnd,
    required String effectiveAt,
    required String expiredAt,
    required String publishedAt}) async {
  final headers = await MyHeaders.build(); // ✅ ต้อง await
  final url = Uri.parse('${MyConstant().domain_v1}/admin/announcement');
  final body = json.encode({
    "lang": lang,
    "title": title,
    "content": content,
    "meta": meta,
    "zones": zones,
    "c_date_start": cDateStart,
    "c_date_end": cDateEnd,
    "effective_at": effectiveAt,
    "expired_at": expiredAt,
    "published_at": publishedAt
  });
  //print(body);
  try {
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 409) {
      //print(
      // '✅ Post AnnounceMentNotFile Success: ${json.decode(response.body)}');
    } else {
      //print(
      // '❌ Post AnnounceMentNotFile Failed [${response.statusCode}]: ${json.decode(response.body)}');
    }
    return response;
  } catch (e, stack) {
    //print('❌ Exception during AnnounceMentNotFile request: $e');
    //print('🧭 StackTrace:\n$stack');
    return null;
  }
}

Future<http.Response> Post_AnnounceMentFile_Web(
  List<int> fileBytes,
  String filename,
  String lang,
  String title,
  String content,
  List<Map<String, dynamic>> meta,
  List<Map<String, dynamic>> zones,
  String cDateStart,
  String cDateEnd,
  String effectiveAt,
  String expiredAt,
  String publishedAt,
) async {
  final url = Uri.parse('${MyConstant().domain_v1}/admin/announcement');
  //print(url);

  final headers = await MyHeaders.build(); // ✅ ต้อง await
  var request = http.MultipartRequest('POST', url)
    ..headers.addAll(headers)
    ..fields['lang'] = lang
    ..fields['title'] = title
    ..fields['content'] = content
    // ..fields['meta'] = jsonEncode(meta)
    // ..fields['zones'] = jsonEncode(zones)
    ..fields['c_date_start'] = cDateStart
    ..fields['c_date_end'] = cDateEnd
    ..fields['effective_at'] = effectiveAt
    ..fields['expired_at'] = expiredAt
    ..fields['published_at'] = publishedAt
    ..files.add(
      http.MultipartFile.fromBytes('file', fileBytes,
          filename:
              '${filename.endsWith(".pdf") ? filename : "$filename.pdf"}'),
    );
// ส่ง meta เป็น array
  for (var i = 0; i < meta.length; i++) {
    request.fields['meta[$i][key]'] = meta[i]['key'];
    request.fields['meta[$i][value]'] = meta[i]['value'];
  }

// ส่ง zones เป็น array
  for (var i = 0; i < zones.length; i++) {
    request.fields['zones[$i][property_id]'] =
        zones[i]['property_id'].toString();
    request.fields['zones[$i][property_pn]'] = zones[i]['property_pn'];
    request.fields['zones[$i][zone_id]'] = zones[i]['zone_id'].toString();
    request.fields['zones[$i][zone_pn]'] = zones[i]['zone_pn'];
    request.fields['zones[$i][subzone_id]'] = zones[i]['subzone_id'].toString();
    request.fields['zones[$i][subzone_pn]'] = zones[i]['subzone_pn'];
  }
  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200 || response.statusCode == 201) {
    //print('✅ Web Upload succeed อัปโหลดสำเร็จ: ${response.body}');
  } else {
    //print('❌ Web Upload failed อัปโหลดล้มเหลว : ${response.statusCode}');
    //print('📄 ตอบกลับ(response): ${response.body}');
  }

  return response;
}

Future<http.Response> Post_AnnounceMentFile_Mobile(
  File file,
  String filename,
  String lang,
  String title,
  String content,
  List<Map<String, dynamic>> meta,
  List<Map<String, dynamic>> zones,
  String cDateStart,
  String cDateEnd,
  String effectiveAt,
  String expiredAt,
  String publishedAt,
) async {
  final url = Uri.parse('${MyConstant().domain_v1}/admin/announcement');
  //print(url);

  final headers = await MyHeaders.build(); // ✅ ต้อง await
  var request = http.MultipartRequest('POST', url)
    ..headers.addAll(headers)
    ..fields['lang'] = lang
    ..fields['title'] = title
    ..fields['content'] = content
    ..fields['meta'] = jsonEncode(meta)
    ..fields['zones'] = jsonEncode(zones)
    ..fields['c_date_start'] = cDateStart
    ..fields['c_date_end'] = cDateEnd
    ..fields['effective_at'] = effectiveAt
    ..fields['expired_at'] = expiredAt
    ..fields['published_at'] = publishedAt
    ..files.add(
      await http.MultipartFile.fromPath('file', file.path,
          filename: path.basename(file.path)),
    );

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200 || response.statusCode == 201) {
    //print('✅ Mobile/Desktop Upload Receipt succeed อัปโหลดสำเร็จ');
  } else {
    //print(
    // '❌ Mobile/Desktop Upload Receipt failed อัปโหลดล้มเหลว: ${response.statusCode}');
    //print('📄 ตอบกลับ(response): ${response.body}');
  }

  return response;
}
