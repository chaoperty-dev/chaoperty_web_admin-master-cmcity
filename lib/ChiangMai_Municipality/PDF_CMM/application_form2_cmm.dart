import 'dart:io';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../PeopleChao/Pays_.dart';
import 'unity_pdf_cmm/perviewpdf1_cmm.dart';
import 'unity_pdf_cmm/unitypdf_cmm.dart';

Future<dynamic> GeneratePDF_ApplicationForm2_CMM(
    BuildContext context, int type) async {
  final pdf = pw.Document();
  final ttf = await font1();
  final ttf2 = await font2();
  // final imageLogo = pw.MemoryImage(logoFile.readAsBytesSync());
  String name = 'นายสมชายสมชายสมชาย ใจดีใจดีใจดีใจดี';
  String idCard = '1234567890123';

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.copyWith(
        marginBottom: 18.00,
        marginLeft: 18.00,
        marginRight: 18.00,
        marginTop: 18.00,
      ),
      header: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: [
            // pw.Container(
            //   height: 60,
            //   width: 60,
            //   decoration: pw.BoxDecoration(
            //     border: pw.Border.all(color: PdfColors.grey300),
            //   ),
            //   // child: pw.Image(imageLogo),
            // ),
            pw.SizedBox(width: 10),
            pw.Text('เรียน  ปลัดเทศบาล',
                style: pw.TextStyle(
                    font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Text('เรียน  หัวหน้าสำนักปลัดเทศบาล',
                style: pw.TextStyle(
                    font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Text('เรียน  หัวหน้าฝ่ายปกครอง',
                style: pw.TextStyle(
                    font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
          ],
        );
      },
      build: (context) => [
        pw.SizedBox(height: 20),
        Textx(
          value:
              'ด้วย ผู้ค้าได้รับอนุญาตให้จำหน่ายสินค้าในที่หรือทางสาธารณะ\n\n'
              'บริเวณ.............................................ยื่นคำขอต่อ\n\n'
              'อายุใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ ประจำปี 2568\n\n'
              'งานรักษาความเรียบร้อย ฝ่ายปกครอง สำนักปลัดเทศบาล ได้ตรวจสอบความถูกต้องของเอกสารการชำระค่าธรรมเนียมเขียน '
              'และข้อระเบียบกฎหมายแล้ว มีความถูกต้อง ครบถ้วน จึงเห็นควรเสนอ นายกเทศมนตรีนครเชียงใหม่ '
              'ในฐานะเจ้าพนักงานท้องถิ่น เพื่อพิจารณาอนุญาตตามคำขอ และลงนามในใบอนุญาตฯ ต่อไป\n\n'
              'จึงเรียนมาเพื่อโปรดพิจารณา',
          font: ttf,
        ),
        pw.Align(
          alignment: pw.Alignment.center,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.SizedBox(height: 50),
              Textx(
                value: '(...........................................)',
                font: ttf,
              ),
              Textx(
                value: 'หัวหน้างานรักษาความเรียบร้อย',
                font: ttf,
              ),
              pw.SizedBox(height: 30),
              Textx(
                value: '(...........................................)',
                font: ttf,
              ),
              Textx(
                value: 'หัวหน้าฝ่ายปกครอง',
                font: ttf,
              ),
              pw.SizedBox(height: 30),
              Textx(
                value: '(...........................................)',
                font: ttf,
              ),
              Textx(
                value: 'หัวหน้าสำนักปลัดเทศบาล',
                font: ttf,
              ),
              pw.SizedBox(height: 30),
              pw.SizedBox(height: 30),
              Textx(
                value: '(...........................................)',
                font: ttf,
              ),
              Textx(
                value: 'รองปลัดเทศบาล ปฏิบัติราชการแทน\nปลัดเทศบาลนครเชียงใหม่',
                font: ttf,
              ),
              pw.SizedBox(height: 30),
              Textx(
                value: 'ลงนามแล้ว',
                font: ttf,
              ),
              pw.SizedBox(height: 30),
              Textx(
                value: '(...........................................)',
                font: ttf,
              ),
              Textx(
                value:
                    'รองนายกเทศมนตรี ปฏิบัติราชการแทน\nนายกเทศมนตรีนครเชียงใหม่',
                font: ttf,
              ),
            ],
          ),
        )
      ],
    ),
  );

  // final List<int> bytes = await pdf.save();
  // final Uint8List data = Uint8List.fromList(bytes);
  // MimeType type = MimeType.PDF;
  // final dir = await FileSaver.instance.saveFile(
  //     "ใบพิจารณาคำขอต่อใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ", data, "pdf",
  //     mimeType: type);
  if (type == 0) {
    return pdf;
  } else {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewPdfgen1_CMM(
              doc: pdf,
              title:
                  'ใบพิจารณาคำขอต่อใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ'),
        ));
  }
}
