import 'dart:io';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;

import '../../../Constant/Myconstant.dart';

Uint8List? cachedLogo;
pw.Font? _cachedFont;
Uint8List? _cachedFontBytes;
Uint8List? _cachedCheckBytes;
Uint8List? _cachedSquareBytes;

Future<Uint8List> fontRawBytes() async {
  if (_cachedFontBytes != null) return _cachedFontBytes!;
  final data = await rootBundle.load("fonts/THSarabunNew.ttf");
  _cachedFontBytes = data.buffer.asUint8List();
  return _cachedFontBytes!;
}

Future<Uint8List> checkImageBytes() async {
  if (_cachedCheckBytes != null) return _cachedCheckBytes!;
  final data = await rootBundle.load("images/check1.png");
  _cachedCheckBytes = data.buffer.asUint8List();
  return _cachedCheckBytes!;
}

Future<Uint8List> squareImageBytes() async {
  if (_cachedSquareBytes != null) return _cachedSquareBytes!;
  final data = await rootBundle.load("images/square3.png");
  _cachedSquareBytes = data.buffer.asUint8List();
  return _cachedSquareBytes!;
}

Future<Uint8List> loadImagePDFCMM(String img) async {
  if (cachedLogo != null) return cachedLogo!;
  final data = await rootBundle.load(img);
  cachedLogo = data.buffer.asUint8List();
  return cachedLogo!;
}

Future<pw.Font> font1() async {
  if (_cachedFont != null) return _cachedFont!;
  final font = await rootBundle.load("fonts/THSarabunNew.ttf");
  _cachedFont = pw.Font.ttf(font);
  return _cachedFont!;
}

Future<pw.Font> font2() async => font1();

pw.Widget Textx({
  // required String label,
  required String value,
  // int dotLength = 40,
  required pw.Font font,
  double fontSize = 14,
}) {
  var Colors_pd = PdfColors.black;
  // final filled = value.padRight(dotLength, '.');
  return pw.Text(
    value,
    textAlign: pw.TextAlign.center,
    style: pw.TextStyle(
        font: font, fontSize: fontSize, fontWeight: pw.FontWeight.bold),
  );
}

pw.Widget Textxright({
  // required String label,
  required String value,
  // int dotLength = 40,
  required pw.Font font,
  double fontSize = 14,
}) {
  var Colors_pd = PdfColors.black;
  // final filled = value.padRight(dotLength, '.');
  return pw.Text(
    value,
    textAlign: pw.TextAlign.right,
    style: pw.TextStyle(
        font: font, fontSize: fontSize, fontWeight: pw.FontWeight.bold),
  );
}

pw.Widget Textx_mini({
  // required String label,
  required String value,
  // int dotLength = 40,
  required pw.Font font,
  double fontSize = 13,
}) {
  var Colors_pd = PdfColors.black;
  // final filled = value.padRight(dotLength, '.');
  return pw.Text(
    value,
    textAlign: pw.TextAlign.center,
    style: pw.TextStyle(
        font: font, fontSize: fontSize, fontWeight: pw.FontWeight.bold),
  );
}

pw.Widget labeledLine({
  required String value,
  required pw.Font font,
  double fontSize = 14,
  required int flex,
}) {
  var Colors_pd = PdfColors.black;

  return pw.Expanded(
      flex: flex,
      child: pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(
              color: Colors_pd,
              width: 0.3,
            ),
          ),
        ),
        padding: const pw.EdgeInsets.only(bottom: -3.5),
        child: pw.Text(
          ' ' * 2 + value + ' ' * 2,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
              font: font, fontSize: fontSize, fontWeight: pw.FontWeight.bold),
        ),
      ));
}

Future<Uint8List?> fetchImageBytes(String url) async {
  final headers = await MyHeaders.build(); // ✅ ต้อง await
  final uri = Uri.parse(url);
  try {
    final response = await http.get(uri, headers: headers);
    // final response = await http.get(Uri.parse(url));
    // print('🔍 Content-Type: $url');
    final contentType = response.headers['content-type'] ?? '';
    // print('🔍 Content-Type: $contentType');

    if (response.statusCode == 200 && contentType.startsWith('image/')) {
      return response.bodyBytes;
    } else {
      //  print('❌ ไม่ใช่ภาพ: $contentType');
    }
  } catch (e) {
    // print('❌ Error fetching image: $e');
  }
  return null;
}

Future<pw.Widget> Signature_PDF({
  required String value,
  required pw.Font font,
  required double height,
  required double width,
  String? signatureImageUrl,
  Uint8List? imageBytes,
}) async {
  Uint8List? finalImageBytes;

  // ถ้ามี URL
  if (signatureImageUrl != null) {
    try {
      finalImageBytes = await fetchImageBytes(signatureImageUrl);
    } catch (e) {
      // print('❌ Failed to load image from URL: $e');
    }
  }

  // ถ้าไม่มีหรือโหลดจาก URL ไม่สำเร็จ ให้ fallback เป็น imageBytes
  final usableBytes = (finalImageBytes != null && finalImageBytes.isNotEmpty)
      ? finalImageBytes
      : (imageBytes != null && imageBytes.isNotEmpty)
          ? imageBytes
          : null;

  return pw.Container(
    height: height,
    width: width,
    decoration: pw.BoxDecoration(
      color: PdfColors.white,
    ),
    child: usableBytes != null
        ? pw.Image(
            pw.MemoryImage(usableBytes),
            height: height,
            width: width,
            fit: pw.BoxFit.contain,
          )
        : pw.Center(
            child: pw.Text(
              '', // หรือใส่ข้อความแสดงว่า "ไม่มีลายเซ็น"
              style: pw.TextStyle(
                font: font,
                fontSize: 10,
                color: PdfColors.grey,
              ),
            ),
          ),
  );
}



// pw.Widget Signature_PDF({
//   required String value,
//   required pw.Font font,
//   required double height,
//   required double width,
//   required Uint8List? signatureImage, // ระบุประเภทชัดเจน และเป็น nullable
// }) {
//   return pw.Container(
//     height: height,
//     width: width,
//     decoration: pw.BoxDecoration(
//       color: PdfColors.white,
//       // border: pw.Border.all(color: PdfColors.grey300),
//     ),
//     child: signatureImage != null
//         ? pw.Image(
//             pw.MemoryImage(signatureImage),
//             height: height,
//             width: width,
//             fit: pw.BoxFit.contain,
//           )
//         : pw.Center(
//             child: pw.Text(
//               '',
//               style: pw.TextStyle(
//                 font: font,
//                 fontSize: 10,
//                 color: PdfColors.grey,
//               ),
//             ),
//           ),
//   );
// }
