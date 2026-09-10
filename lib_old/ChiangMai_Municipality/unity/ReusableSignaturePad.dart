import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../Constant/Myconstant.dart';
import 'Enum.dart';

Future<dynamic> handleSave(
  String uuid,
  int docId,
  GlobalKey<SfSignaturePadState> key,
  SignatureActionType type,
) async {
  try {
    final signature = key.currentState;
    if (signature == null) return null; // return null for an empty state

    final image = await signature.toImage();
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      print('❌ ไม่สามารถแปลงลายเซ็นเป็นรูปภาพได้');
      // **Option 1: Return a specific non-null error response here too**
      return http.Response('{"message": "Conversion failed"}', 400);
    }

    final pngBytes = byteData.buffer.asUint8List();
    print('✅ แปลงลายเซ็นสำเร็จ: ${pngBytes.lengthInBytes} bytes');

    switch (type) {
      case SignatureActionType.preview:
      case SignatureActionType.saveToFile:
        // ✅ Implement ดาวน์โหลดไฟล์ลายเซ็น
        if (kIsWeb) {
          // Web: สร้าง Blob และดาวน์โหลดผ่าน anchor
          final blob = html.Blob([pngBytes], 'image/png');
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.AnchorElement(href: url)
            ..setAttribute('download',
                'signature_${DateTime.now().millisecondsSinceEpoch}.png')
            ..click();
          html.Url.revokeObjectUrl(url);
          print('✅ ดาวน์โหลดไฟล์ลายเซ็นสำเร็จ (Web)');
        } else {
          // Mobile/Desktop: บันทึกลง documents directory
          final dir = await getApplicationDocumentsDirectory();
          final fileName =
              'signature_${DateTime.now().millisecondsSinceEpoch}.png';
          final file = File('${dir.path}/$fileName');
          await file.writeAsBytes(pngBytes);
          print('✅ บันทึกไฟล์ลายเซ็นสำเร็จ: ${file.path}');
        }
        return null;

      case SignatureActionType.upload_user:
        final response = await uploadSignature_user(uuid, docId, pngBytes);
        return response;

      case SignatureActionType.upload_admin:
        final response = await uploadSignature_amin(pngBytes);
        return response;
    }
  } catch (e) {
    print('🚫 เกิดข้อผิดพลาดใน handleSave: $e');

    // -------------------------------------------------------------------
    // 🔥 CRITICAL FIX: Instead of returning null, return a dummy HTTP
    // Response object with a server error status code (500).
    // This prevents the NoSuchMethodError in the calling function.
    // -------------------------------------------------------------------
    return http.Response('{"error": "Network or internal upload failed"}', 500);
  }
}

// Future<http.Response> uploadSignature(Uint8List pngBytes) async {
//   final uri =
//       Uri.parse('${MyConstant().domain_v1}/admin/requests/$uuid/attachments');
//   //print(uri);

//   var request = http.MultipartRequest('POST', uri)
//     ..headers.addAll({
//       'Accept': 'application/json',
//       'Authorization':
//           'Bearer 7|Xm7Hdf184i16Y45avEiYkalUofL6XstNlUQJDDiLe79fc995',
//     })
//     ..fields['document_id'] = docId.toString()
//     ..files.add(
//       http.MultipartFile.fromBytes('file', fileBytes, filename: filename),
//     );

//   final streamedResponse = await request.send();
//   final response = await http.Response.fromStream(streamedResponse);

//   if (response.statusCode == 200) {
//     //print('✅ Web อัปโหลดสำเร็จ: ${response.body}');
//   } else {
//     //print('❌ Web อัปโหลดล้มเหลว: ${response.statusCode}');
//     //print('📄 ตอบกลับ: ${response.body}');
//   }

//   return response;
// }
Future<http.Response> uploadSignature_user(
    String uuid, int docId, Uint8List pngBytes) async {
  // final uri = Uri.parse('http://your-api/upload');
  final uri =
      Uri.parse('${MyConstant().domain_v1}/admin/requests/$uuid/attachments');
  final headers = await MyHeaders.build(); // ✅ ต้อง await
  //print('$uri');
  //print('ID : $docId');
  var request = http.MultipartRequest('POST', uri)
    ..headers.addAll(headers)
    ..fields['document_id'] = '$docId'
    ..files.add(
      http.MultipartFile.fromBytes('file', pngBytes, filename: 'sign.png'),
    );

  try {
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ อัปโหลดสำเร็จ: ${response.body}');
    } else {
      print('❌ อัปโหลดล้มเหลว: ${response.statusCode}');
      print('📄 ข้อความ: ${response.body}');
    }

    return response;
  } catch (e) {
    print('🚫 Exception: $e');
    rethrow;
  }
}

Future<Uint8List> uploadSignature_amin(Uint8List pngBytes) async {
  return pngBytes;
}

class ReusableSignaturePad extends StatelessWidget {
  final GlobalKey<SfSignaturePadState> signatureKey;
  final VoidCallback? onUp;
  final VoidCallback? onSave;
  final VoidCallback? onClear;
  final VoidCallback? onLoad; // โหลดลายเซ็นจากระบบ
  final double? height;
  final double? width;

  const ReusableSignaturePad({
    super.key,
    required this.signatureKey,
    this.onUp,
    this.onSave,
    this.onClear,
    this.onLoad,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child: Column(
          children: [
            Container(
              height: height ?? 150, // default fallback
              width: width,
              padding: const EdgeInsets.all(2.0),
              child: SfSignaturePad(
                key: signatureKey,
                backgroundColor: Colors.white,
                strokeColor: Colors.black,
                minimumStrokeWidth: 1.0,
                maximumStrokeWidth: 4.0,
              ),
            ),
            Container(
              width: width,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (onUp != null)
                    TextButton(
                      onPressed: onUp,
                      child: const AutoSizeText(
                        'อัพโหลด',
                        minFontSize: 12,
                        maxFontSize: 16,
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontFamily: 'THSarabun',
                        ),
                      ),
                    ),
                  TextButton(
                    onPressed: onSave,
                    child: const AutoSizeText(
                      'ดาวน์โหลด',
                      minFontSize: 12,
                      maxFontSize: 16,
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontFamily: 'THSarabun',
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onClear,
                    child: const AutoSizeText(
                      'ยกเลิก',
                      // 'เคลียร์',
                      minFontSize: 12,
                      maxFontSize: 16,
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontFamily: 'THSarabun',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/////////------------------->
// Future<void> handleSave(GlobalKey<SfSignaturePadState> key) async {
//   final data = await key.currentState?.toImage();
//   final bytes = await data?.toByteData(format: ui.ImageByteFormat.png);
//   if (bytes != null) {
//     // ทำอะไรกับ bytes เช่น บันทึกไฟล์ อัปโหลด ฯลฯ
//     //print('✅ บันทึกลายเซ็นสำเร็จ ขนาด: ${bytes.lengthInBytes}');
//   } else {
//     //print('❌ ไม่สามารถแปลงลายเซ็นเป็นรูปภาพได้');
//   }
// }

// Future<void> saveSignatureToFile(Uint8List pngBytes) async {
//   final dir = await getApplicationDocumentsDirectory();
//   final file = File('${dir.path}/signature.png');
//   await file.writeAsBytes(pngBytes);
//   //print('📁 บันทึกลายเซ็นไว้ที่: ${file.path}');
// }
