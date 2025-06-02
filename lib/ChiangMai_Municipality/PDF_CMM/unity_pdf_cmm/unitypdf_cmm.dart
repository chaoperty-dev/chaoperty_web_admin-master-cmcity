import 'dart:io';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Uint8List? cachedLogo;

Future<Uint8List> loadImagePDFCMM(String img) async {
  if (cachedLogo != null) return cachedLogo!;
  final data = await rootBundle.load(img);
  cachedLogo = data.buffer.asUint8List();
  return cachedLogo!;
}

Future<pw.Font> font1() async {
  final font = await rootBundle.load("fonts/THSarabunNew.ttf");
  return pw.Font.ttf(font);
}

Future<pw.Font> font2() async {
  final font = await rootBundle.load("fonts/THSarabunNew.ttf");
  return pw.Font.ttf(font);
}

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

pw.Widget Signature_PDF({
  required String value,
  required pw.Font font,
  required double height,
  required double width,
  required Uint8List? signatureImage, // ระบุประเภทชัดเจน และเป็น nullable
}) {
  return pw.Container(
    height: height,
    width: width,
    decoration: pw.BoxDecoration(
      color: PdfColors.white,
      // border: pw.Border.all(color: PdfColors.grey300),
    ),
    child: signatureImage != null
        ? pw.Image(
            pw.MemoryImage(signatureImage),
            height: height,
            width: width,
            fit: pw.BoxFit.contain,
          )
        : pw.Center(
            child: pw.Text(
              '',
              style: pw.TextStyle(
                font: font,
                fontSize: 10,
                color: PdfColors.grey,
              ),
            ),
          ),
  );
}
