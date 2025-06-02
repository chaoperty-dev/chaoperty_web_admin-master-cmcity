import 'dart:io';
import 'dart:js';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../PeopleChao/Pays_.dart';
import 'unity_pdf_cmm/perviewpdf1_cmm.dart';
import 'unity_pdf_cmm/unitypdf_cmm.dart';

Future<dynamic> GeneratePDF_License_CMM(BuildContext context, int type) async {
  final pdf = pw.Document();
  final ttf = await font1();
  final ttf2 = await font2();
  final iconImage =
      await loadImagePDFCMM('images/logo3.png'); // 👈 รอให้โหลดเสร็จก่อน
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
          mainAxisAlignment: pw.MainAxisAlignment.start,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // pw.Container(
            //   height: 60,
            //   width: 60,
            //   decoration: pw.BoxDecoration(
            //     border: pw.Border.all(color: PdfColors.grey300),
            //   ),
            //   // child: pw.Image(imageLogo),
            // ),
            // pw.SizedBox(width: 10),
            pw.Align(
              alignment: pw.Alignment.center,
              child: pw.Text('ใบอนุญาต',
                  style: pw.TextStyle(
                      font: ttf, fontSize: 15, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Align(
              alignment: pw.Alignment.center,
              child: pw.Text('ใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ',
                  style: pw.TextStyle(
                      font: ttf, fontSize: 15, fontWeight: pw.FontWeight.bold)),
            ),
          ],
        );
      },
      build: (context) => [
        pw.SizedBox(height: 20),
        pw.Text('ทำที่ สำนักงานเทศบาลนครเชียงใหม่',
            style: pw.TextStyle(
                font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.Text(
            'เล่ม ............ เลข ........................ ปี ...............',
            style: pw.TextStyle(
                font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            Textx(
              value: ' ' * 12 + 'อนุญาตให้',
              font: ttf,
            ),
            labeledLine(
              value: name, // example: 'สมชาย ใจดี'
              flex: 4,
              font: ttf,
            ),
            Textx(
              value: 'สัญชาติ',
              font: ttf,
            ),
            labeledLine(
              value: 'ไทย',
              flex: 2,
              font: ttf,
            ),
            Textx(
              value: 'อยู่บ้าน/สำนัก',
              font: ttf,
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            Textx(
              value: 'งานเลขที่',
              font: ttf,
            ),
            labeledLine(
              value:
                  '55/99 หมู่ที่ 1 ตรอก/ซอย ของกิน ถนน อร่อยไม่อั้น  ตำบล ชิมก่อน อำเภอ อิ่มท้อ จังหวัด ของกินเพียบ 44444',
              flex: 1,
              font: ttf,
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            Textx(
              value: 'เบอร์โทร',
              font: ttf,
            ),
            labeledLine(
              value: 'xxx-xxxx-xx',
              flex: 1,
              font: ttf,
            ),
            pw.Expanded(flex: 2, child: pw.SizedBox())
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Row(
          children: [
            Textx(
              value: ' ' * 12 + 'ข้อ 1 จำหน่ายสินค้าในที่หรือทางสาธารณะ ประเภท',
              font: ttf,
            ),
            labeledLine(
              value: 'xx.xx',
              flex: 1,
              font: ttf,
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            Textx(
              value: 'ค่าธรรมเนียม',
              font: ttf,
            ),
            labeledLine(
              value: '500.00',
              flex: 1,
              font: ttf,
            ),
            Textx(
              value: 'บาท ใบเสร็จรับเงินเล่มที่',
              font: ttf,
            ),
            labeledLine(
              value: 'RE68/05',
              flex: 1,
              font: ttf,
            ),
            Textx(
              value: 'เลขที่',
              font: ttf,
            ),
            labeledLine(
              value: 'RE68-xx-xxxxx',
              flex: 1,
              font: ttf,
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            Textx(
              value: 'ลงวันที่',
              font: ttf,
            ),
            labeledLine(
              value: 'xx-xx-xxxx',
              flex: 1,
              font: ttf,
            ),
            Textx(
              value: 'พื้นที่ประกอบการ',
              font: ttf,
            ),
            labeledLine(
              value: 'xx.xx',
              flex: 1,
              font: ttf,
            ),
            Textx(
              value: 'ตารางเมตร',
              font: ttf,
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            Textx(
              value: 'ตั้งอยู่ ณ เลขที่',
              font: ttf,
            ),
            labeledLine(
              value:
                  '55/99 หมู่ที่ 1 ตรอก/ซอย ของกิน ถนน อร่อยไม่อั้น  ตำบล ชิมก่อน อำเภอ อิ่มท้อ จังหวัด ของกินเพียบ 44444',
              flex: 1,
              font: ttf,
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            Textx(
              value: 'โทรศัพท์',
              font: ttf,
            ),
            labeledLine(
              value: 'xxx-xxxx-xx',
              flex: 2,
              font: ttf,
            ),
            Textx(
              value: 'โทรสาร ',
              font: ttf,
            ),
            labeledLine(
              value: 'xxx-xxxx-xx xx',
              flex: 2,
              font: ttf,
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                  ' ' * 12 +
                      'ข้อ 2 ผู้ได้รับอนุญาตต้องปฏิบัติตามเงื่อนไขโดยเฉพาะ ดังต่อไปนี้',
                  style: pw.TextStyle(
                      font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text(
                  ' ' * 16 +
                      '(1) ประกาศเทศบาลนครเชียงใหม่ เรื่อง หลักเกณฑ์ เงื่อนไข การกำหนดในการจัดระเบียบ',
                  style: pw.TextStyle(
                      font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text(
                  ' ' * 16 +
                      'การจำหน่ายสินค้าในพื้นที่ผ่อนผัน ลงวันที่ 31 ตุลาคม พ.ศ.2559',
                  style: pw.TextStyle(
                      font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text(' ' * 16 + '(2) ปฏิบัติตามมาตรการป้องกันทางสาธารณสุข',
                  style: pw.TextStyle(
                      font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Row(
                children: [
                  Textx(
                    value: 'ใบอนุญาตฉบับนี้ให้ใช้ถึง วันที่',
                    font: ttf,
                  ),
                  labeledLine(
                    value: 'xx-xx-xxxx',
                    flex: 2,
                    font: ttf,
                  ),
                  Textx(
                    value: 'ออกให้ ณ วันที่ ',
                    font: ttf,
                  ),
                  labeledLine(
                    value: 'xx-xx-xxxx',
                    flex: 2,
                    font: ttf,
                  ),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 30),
        pw.Align(
            alignment: pw.Alignment.center,
            child: pw.SizedBox(
              child: pw.Column(children: [
                Textx(
                  value: '(ลงชื่อ)',
                  font: ttf,
                ),
                pw.SizedBox(height: 30),
                Signature_PDF(
                    value: '',
                    font: ttf,
                    height: 35,
                    width: 35,
                    signatureImage: iconImage),
                Textx(
                  value: '(นายกฤษฎ์ กาญจนเกตุ)',
                  font: ttf,
                ),
                Textx(
                  value:
                      'รองนายกเทศมนตรี ปฏิบัติราชการแทน\nนายกเทศมนตรีนครเชียงใหม่',
                  font: ttf,
                ),
              ]),
            )),
        // pw.Align(
        //   alignment: pw.Alignment.center,
        //   child: pw.Column(
        //     crossAxisAlignment: pw.CrossAxisAlignment.center,
        //     children: [
        //       Textx(
        //         value: 'ลงชื่อ',
        //         font: ttf,
        //       ),
        //       pw.SizedBox(height: 30),
        //       Textx(
        //         value: '(นายกฤษฎ์ กาญจนเกตุ)',
        //         font: ttf,
        //       ),
        //       Textx(
        //         value:
        //             'รองนายกเทศมนตรี ปฏิบัติราชการแทน\nนายกเทศมนตรีนครเชียงใหม่',
        //         font: ttf,
        //       ),
        //     ],
        //   ),
        // )
      ],
    ),
  );

  // final List<int> bytes = await pdf.save();
  // final Uint8List data = Uint8List.fromList(bytes);
  // MimeType type = MimeType.PDF;
  // final dir = await FileSaver.instance.saveFile(
  //     "ใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ", data, "pdf",
  //     mimeType: type);
  if (type == 0) {
    return pdf;
  } else {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewPdfgen1_CMM(
              doc: pdf, title: 'ใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ'),
        ));
  }
}
