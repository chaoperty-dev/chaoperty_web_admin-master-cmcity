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

Future<dynamic> GeneratePDF_Receipt_CMM(BuildContext context, int type) async {
  final pdf = pw.Document();
  final ttf = await font1();
  final ttf2 = await font2();
  // final imageLogo = pw.MemoryImage(logoFile.readAsBytesSync());
  String name = 'นายสมชายสมชายสมชาย ใจดีใจดีใจดีใจดี';
  String idCard = '1234567890123';
  final image = pw.MemoryImage(
    (await rootBundle.load('images/kindpng.png')).buffer.asUint8List(),
  );
  final image2 = pw.MemoryImage(
    (await rootBundle.load('images/pngegg2.png')).buffer.asUint8List(),
  );
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.copyWith(
        marginBottom: 18.00,
        marginLeft: 18.00,
        marginRight: 18.00,
        marginTop: 18.00,
      ),
      // header: (context) {
      //   return pw.Column(
      //     crossAxisAlignment: pw.CrossAxisAlignment.start,
      //     mainAxisAlignment: pw.MainAxisAlignment.start,
      //     children: [
      //       // pw.Container(
      //       //   height: 60,
      //       //   width: 60,
      //       //   decoration: pw.BoxDecoration(
      //       //     border: pw.Border.all(color: PdfColors.grey300),
      //       //   ),
      //       //   // child: pw.Image(imageLogo),
      //       // ),
      //       pw.SizedBox(width: 10),
      //       pw.Text('เรียน  ปลัดเทศบาล',
      //           style: pw.TextStyle(
      //               font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
      //       pw.Text('เรียน  หัวหน้าสำนักปลัดเทศบาล',
      //           style: pw.TextStyle(
      //               font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
      //       pw.Text('เรียน  หัวหน้าฝ่ายปกครอง',
      //           style: pw.TextStyle(
      //               font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
      //     ],
      //   );
      // },
      build: (context) => [
        pw.SizedBox(height: 20),
        Textx(
          value: 'สำนักงานเทศบาล',
          font: ttf,
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            Textx(
              value: 'ใบเสร็จรับเงิน เลขที่',
              font: ttf,
            ),
            Textx(
              value: 'วันที่ 30 เดือน 10 พ.ศ. 2567',
              font: ttf,
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                  padding: pw.EdgeInsets.all(2),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.Row(children: [
                        Textx(
                          value: 'ได้รับเงินจาก',
                          font: ttf,
                        ),
                        labeledLine(
                          value: 'xxxxxx',
                          flex: 2,
                          font: ttf,
                        ),
                      ]),
                      pw.Row(children: [
                        Textx(
                          value: 'ชำระค่า',
                          font: ttf,
                        ),
                        labeledLine(
                          value: 'ใบอนุญาต',
                          flex: 2,
                          font: ttf,
                        ),
                      ]),
                      pw.SizedBox(height: 10),
                      Textx(
                        value: 'ไว้แล้วเป็นเงิน (ตัวอักษร)',
                        font: ttf,
                      ),
                      pw.SizedBox(height: 2),
                      pw.SizedBox(
                        height: 25,
                        child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Expanded(
                                  flex: 1,
                                  child: pw.Stack(
                                    children: [
                                      // Background image
                                      pw.Positioned.fill(
                                        child: pw.Image(
                                          image,
                                          fit: pw.BoxFit.fill,
                                        ),
                                      ),

                                      // Foreground content with border and background color
                                      pw.Align(
                                        alignment: pw.Alignment.center,
                                        child: pw.Container(
                                          padding: const pw.EdgeInsets.all(10),
                                          // decoration: pw.BoxDecoration(
                                          //   color: PdfColors.grey300,
                                          //   border:
                                          //       pw.Border.all(color: PdfColors.grey600),
                                          // ),
                                          child: pw.Text(
                                            'ห้าร้อยบาทถ้วน',
                                            style: pw.TextStyle(
                                                font: ttf, fontSize: 16),
                                          ),
                                        ),
                                      ),
                                      pw.Positioned.fill(
                                        child: pw.Image(
                                          image2,
                                          fit: pw.BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ))
                            ]),
                      ),
                    ],
                  )),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                  padding: pw.EdgeInsets.all(5),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.Table(
                        border: pw.TableBorder.all(),
                        columnWidths: {
                          0: pw.FixedColumnWidth(30),
                          1: pw.FlexColumnWidth(),
                          2: pw.FixedColumnWidth(100),
                        },
                        children: [
                          pw.TableRow(children: [
                            Textx(
                              value: 'ที่',
                              font: ttf,
                            ),
                            Textx(
                              value: 'รายการ',
                              font: ttf,
                            ),
                            Textx(
                              value: 'จำนวนเงิน',
                              font: ttf,
                            ),
                          ]),
                          pw.TableRow(children: [
                            Textx(
                              value: '1',
                              font: ttf,
                            ),
                            Textx(
                              value: 'ค่าธรรมเนียมต่ออายุใบอนุญาต',
                              font: ttf,
                            ),
                            Textx(
                              value: '500 บาท',
                              font: ttf,
                            ),
                          ]),
                        ],
                      ),
                      pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: Textx(
                          value: 'รวมเงิน: 500 บาท',
                          font: ttf,
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        Textx(
          value: 'ลงชื่อผู้รับเงิน .....................................',
          font: ttf,
        ),
        Textx(
          value: 'ผู้ตรวจสอบบัญชี .....................................',
          font: ttf,
        ),
        pw.SizedBox(height: 10),
        Textx(
          value: '(ตราประทับเทศบาล)',
          font: ttf,
        ),
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
              doc: pdf, title: 'ใบเสร็จรับเงิน(สำนักงานเทศบาล)'),
        ));
  }
}
