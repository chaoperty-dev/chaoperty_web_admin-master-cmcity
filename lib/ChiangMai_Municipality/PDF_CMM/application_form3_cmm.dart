import 'dart:io';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../PeopleChao/Pays_.dart';
import '../../Style/loadAndCacheImage.dart';
import 'unity_pdf_cmm/perviewpdf1_cmm.dart';
import 'unity_pdf_cmm/unitypdf_cmm.dart';

Future<dynamic> GeneratePDF_ApplicationForm3_CMM(
    BuildContext context, int type) async {
  final pdf = pw.Document();
  final ttf = await font1();
  final ttf2 = await font2();
  // final imageLogo = pw.MemoryImage(logoFile.readAsBytesSync());
  String name = 'นายสมชายสมชายสมชาย ใจดีใจดีใจดีใจดี';
  String idCard = '1234567890123';
  // final iconImage =
  //     (await rootBundle.load('images/logo3.png')).buffer.asUint8List();
  // late final Uint8List logoData;

  final iconImage =
      await loadImagePDFCMM('images/logo3.png'); // 👈 รอให้โหลดเสร็จก่อน
  List netImage = [];
  List netImage_QR = [];
  Uint8List? resizedLogo = await getResizedLogo();
  var Colors_pd = PdfColors.black;
//////////---------------------------------->
  pw.Widget Header(context) {
    return pw.Column(children: [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            height: 45,
            width: 45,
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              // border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: iconImage != null
                ? pw.Image(
                    pw.MemoryImage(iconImage),
                    height: 45,
                    width: 45,
                  )
                : pw.Center(
                    child: pw.Text(
                      'bill_name ',
                      maxLines: 1,
                      style: pw.TextStyle(
                        fontSize: 10,
                        font: ttf,
                        color: Colors_pd,
                      ),
                    ),
                  ),
          ),
          pw.SizedBox(width: 1 * PdfPageFormat.mm),
          pw.Container(
            // color: PdfColors.grey200,
            width: 400,
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              mainAxisSize: pw.MainAxisSize.min,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: Textx(
                    value: 'บันทึกข้อความ',
                    font: ttf,
                  ),
                ),
                pw.SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
      pw.Align(
        alignment: pw.Alignment.topLeft,
        child: Textx(
          value:
              'ส่วนราชการ: สำนักงานเทศบาล ส่ายปกรร งานบริหาราชานเลียร์ไชย โทร. 053-232175-6',
          font: ttf,
        ),
      ),
      pw.SizedBox(height: 8),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 1,
            child: pw.Align(
              alignment: pw.Alignment.topLeft,
              child: Textx(
                value: 'ที่ ชอ 52001.2/',
                font: ttf,
              ),
            ),
          ),
          pw.Expanded(
            flex: 1,
            child: pw.Align(
              alignment: pw.Alignment.topLeft,
              child: Textx(
                value: 'วันที่',
                font: ttf,
              ),
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 8),
      pw.Align(
        alignment: pw.Alignment.topLeft,
        child: Textx(
          value: 'เรื่อง การต่ออายุใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ',
          font: ttf,
        ),
      ),
      pw.Align(
        alignment: pw.Alignment.topLeft,
        child: Textx(
          value: 'เรียน หัวหน้าฝ่ายการคลัง',
          font: ttf,
        ),
      ),
      pw.SizedBox(height: 12),
    ]);
  }

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.copyWith(
        marginBottom: 18.00,
        marginLeft: 18.00,
        marginRight: 18.00,
        marginTop: 18.00,
      ),
      header: (context) {
        return Header(context);
      },
      build: (context) => [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // pw.SizedBox(height: 8),
            pw.Row(
              children: [
                Textx(
                  value: 'ตามที่',
                  font: ttf,
                ),
                labeledLine(
                  value: '...', // example: 'สมชาย ใจดี'
                  flex: 2,
                  font: ttf,
                ),
                // Textx(
                //   value: 'ปี',
                //   font: ttf,
                // ),
                Textx(
                  value: 'อายุ',
                  font: ttf,
                ),
                labeledLine(
                  value: '...',
                  flex: 1,
                  font: ttf,
                ),
                Textx(
                  value: 'ปี สัญชาติ',
                  font: ttf,
                ),
                labeledLine(
                  value: '...',
                  flex: 1,
                  font: ttf,
                ),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              children: [
                Textx(
                  value: 'อยู่บ้านเลขที่',
                  font: ttf,
                ),
                labeledLine(
                  value: '...',
                  flex: 1,
                  font: ttf,
                ),
              ],
            ),
            pw.SizedBox(height: 5),
            // Textx(
            //   value:
            //       'ตามที่.......................................................... อายุ.......ปี สัญชาติ........... อยู่บ้านเลขที่.............',
            //   font: ttf,
            // ),
            // Textx(
            //   value:
            //       'หมู่ที่....... ตรอก/ซอย........... ถนน.......................... ตำบล............... อำเภอ................ จังหวัด................ เบอร์โทรศัพท์.........................',
            //   font: ttf,
            // ),
            pw.SizedBox(height: 5),
            // Textx(
            //   value:
            //       'ได้ยื่นขอต่ออายุใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะประเภทจำหน่ายสินค้าเป็นปกติในพื้นที่ที่ตั้งของเทศบาลนครลำปาง ประจำปี...........',
            //   font: ttf,
            // ),
            pw.Row(
              children: [
                Textx(
                  value:
                      'ได้ยื่นขอต่ออายุใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะประเภทจำหน่ายสินค้าเป็นปกติในพื้นที่ที่ตั้งของเทศบาลนครลำปาง ประจำปี',
                  font: ttf,
                ),
                labeledLine(
                  value: '...',
                  flex: 1,
                  font: ttf,
                ),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              children: [
                Textx(
                  value: 'บริเวณ',
                  font: ttf,
                ),
                labeledLine(
                  value: '...',
                  flex: 1,
                  font: ttf,
                ),
                Textx(
                  value: 'เลขที่',
                  font: ttf,
                ),
                labeledLine(
                  value: '...',
                  flex: 1,
                  font: ttf,
                ),
                Textx(
                  value: 'เพื่อจำหน่ายสินค้า',
                  font: ttf,
                ),
                labeledLine(
                  value: '...',
                  flex: 1,
                  font: ttf,
                ),
                Textx(
                  value: 'นั้น',
                  font: ttf,
                ),
              ],
            ),
            // Textx(
            //   value:
            //       'บริเวณ............................................ เลขที่.................. เพื่อจำหน่ายสินค้า.................................',
            //   font: ttf,
            // ),
            // pw.SizedBox(height: 12),
            pw.SizedBox(height: 20),
            pw.Container(
              height: 200,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey, width: 1),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Container(
                        height: 200,
                        padding: pw.EdgeInsets.all(2),
                        decoration: pw.BoxDecoration(
                          border:
                              pw.Border.all(color: PdfColors.grey, width: 1),
                        ),
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            Textx_mini(
                              value:
                                  'ให้ตรวจสอบเอกสารและหลักฐานต่าง ๆ ตามประกาศเทศบาลนครเชียงใหม่ เมื่อข้าพเจ้า/เราได้ขอใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะบริเวณ',
                              font: ttf,
                            ),
                            pw.Row(
                              children: [
                                labeledLine(
                                  value: '...',
                                  flex: 2,
                                  font: ttf,
                                ),
                                Textx(
                                  value: 'ประกาศ ณ วันที่',
                                  font: ttf,
                                ),
                                labeledLine(
                                  value: 'xx-xx-xxxx',
                                  flex: 1,
                                  font: ttf,
                                ),
                                // labeledLine(
                                //   value:
                                //       'พร้อมทั้งหลักฐานที่ข้าพเจ้า/เรานำมาประกอบแล้วปรากฏว่าเอกสารหลักฐานต่าง ๆ ดังกล่าวถูกต้องครบถ้วนประกาศ',
                                //   flex: 1,
                                //   font: ttf,
                                // ),
                              ],
                            ),
                            pw.SizedBox(height: 5),
                            Textx_mini(
                              value:
                                  'พร้อมทั้งหลักฐานที่ข้าพเจ้า/เรานำมาประกอบแล้วปรากฏว่าเอกสารหลักฐานต่าง ๆ ดังกล่าวถูกต้องครบถ้วนประกาศ',
                              font: ttf,
                            ),
                            Textx_mini(
                              value:
                                  'เห็นควรแจ้งเจ้าหน้าที่เทศกิจประจำเขตประจำโซนตวรจสอบข้อเท็จจริงต่อไป',
                              font: ttf,
                            ),
                            pw.Align(
                                alignment: pw.Alignment.center,
                                child: pw.SizedBox(
                                  child: pw.Column(children: [
                                    Signature_PDF(
                                        value: '',
                                        font: ttf,
                                        height: 35,
                                        width: 35,
                                        signatureImage: iconImage),
                                    Textx_mini(
                                      value: 'ตำแหน่ง ______________',
                                      font: ttf,
                                    ),
                                    Textx_mini(
                                      value: 'ผู้ตรวจสอบเอกสารหลักฐาน',
                                      font: ttf,
                                    ),
                                  ]),
                                )),
                          ],
                        )),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Container(
                        height: 200,
                        padding: pw.EdgeInsets.all(2),
                        decoration: pw.BoxDecoration(
                          border:
                              pw.Border.all(color: PdfColors.grey, width: 1),
                        ),
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            Textx_mini(
                              value:
                                  'ข้าพเจ้าได้ตรวจสอบข้อเท็จจริงเกี่ยวกับคุณสมบัติของผู้ขอใบอนุญาตและผลการดำเนินการแล้ว เห็นว่าผู้ขอฯ มีคุณสมบัติครบถ้วนตามประกาศเทศบาลฯ ที่ออกไว้แล้ว จึงอนุญาตให้ดำเนินการขอใบอนุญาตต่อไป',
                              font: ttf,
                            ),
                            Textx_mini(
                              value:
                                  'เห็นควรนำเรียนผู้บังคับบัญชาตามลำดับขั้นพิจารณาอนุญาติต่อไป',
                              font: ttf,
                            ),
                            pw.Align(
                                alignment: pw.Alignment.center,
                                child: pw.SizedBox(
                                  child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.center,
                                      children: [
                                        Signature_PDF(
                                            value: '',
                                            font: ttf,
                                            height: 35,
                                            width: 35,
                                            signatureImage: iconImage),
                                        Textx_mini(
                                          value: 'ตำแหน่ง ______________',
                                          font: ttf,
                                        ),
                                        Textx_mini(
                                          value: 'ผู้ตรวจสอบเอกสารหลักฐาน',
                                          font: ttf,
                                        ),
                                      ]),
                                )),
                          ],
                        )),
                  ),
                ],
              ),
            ),
            pw.Container(
              height: 180,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey, width: 1),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Container(
                        height: 180,
                        padding: pw.EdgeInsets.all(2),
                        decoration: pw.BoxDecoration(
                          border:
                              pw.Border.all(color: PdfColors.grey, width: 1),
                        ),
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            Textx_mini(
                              value: 'เรียน หัวหน้าฝ่ายเทศกิจ',
                              font: ttf,
                            ),
                            Textx_mini(
                              value: '-เพื่อโปรดพิจารณา',
                              font: ttf,
                            ),
                            Textx_mini(
                              value:
                                  '-อันเนื่องจากผู้ขอได้ต่อใบอนุญาตพร้อมเอกสารครบถ้วน\nขอเทศบาลฯ เห็นชอบในฐานะเจ้าหน้าที่งานฝ่ายฯ แล้ว\nเพื่อเสนอหัวหน้างานสุขาฯ และออกใบอนุญาตฯ ที่แนบมา\nพร้อมนี้',
                              font: ttf,
                            ),
                            pw.Align(
                                alignment: pw.Alignment.center,
                                child: pw.SizedBox(
                                  child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.center,
                                      children: [
                                        Signature_PDF(
                                            value: '',
                                            font: ttf,
                                            height: 35,
                                            width: 35,
                                            signatureImage: iconImage),
                                        Textx_mini(
                                          value: 'ตำแหน่ง ______________',
                                          font: ttf,
                                        ),
                                        Textx_mini(
                                          value: 'ผู้ตรวจสอบเอกสารหลักฐาน',
                                          font: ttf,
                                        ),
                                      ]),
                                )),
                          ],
                        )),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Container(
                        height: 180,
                        padding: pw.EdgeInsets.all(2),
                        decoration: pw.BoxDecoration(
                          border:
                              pw.Border.all(color: PdfColors.grey, width: 1),
                        ),
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            Textx_mini(
                              value: 'เรียน หัวหน้าสำนักปลัดเทศบาล',
                              font: ttf,
                            ),
                            Textx_mini(
                              value: '-เพื่อโปรดพิจารณา',
                              font: ttf,
                            ),
                            Textx_mini(
                              value: '-ควรดำเนินการตามเสนอ',
                              font: ttf,
                            ),
                            pw.Align(
                                alignment: pw.Alignment.center,
                                child: pw.SizedBox(
                                  child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.center,
                                      children: [
                                        Signature_PDF(
                                            value: '',
                                            font: ttf,
                                            height: 35,
                                            width: 35,
                                            signatureImage: iconImage),
                                        Textx_mini(
                                          value: 'ตำแหน่ง ______________',
                                          font: ttf,
                                        ),
                                        Textx_mini(
                                          value: 'ผู้ตรวจสอบเอกสารหลักฐาน',
                                          font: ttf,
                                        ),
                                      ]),
                                )),
                          ],
                        )),
                  ),
                ],
              ),
            ),
            pw.Container(
              height: 160,
              // decoration: pw.BoxDecoration(
              //   border: pw.Border.all(color: PdfColors.grey, width: 1),
              // ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Container(
                        height: 160,
                        padding: pw.EdgeInsets.all(2),
                        decoration: pw.BoxDecoration(
                          border:
                              pw.Border.all(color: PdfColors.grey, width: 1),
                        ),
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            Textx_mini(
                              value: 'เรียน ปลัดเทศบาล',
                              font: ttf,
                            ),
                            Textx_mini(
                              value: '-เพื่อโปรดพิจารณา',
                              font: ttf,
                            ),
                            Textx_mini(
                              value: '-ควรดำเนินการตามเสนอ',
                              font: ttf,
                            ),
                            pw.Align(
                                alignment: pw.Alignment.center,
                                child: pw.SizedBox(
                                  child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.center,
                                      children: [
                                        Signature_PDF(
                                            value: '',
                                            font: ttf,
                                            height: 35,
                                            width: 35,
                                            signatureImage: iconImage),
                                        Textx_mini(
                                          value: 'ตำแหน่ง ______________',
                                          font: ttf,
                                        ),
                                        Textx_mini(
                                          value: 'ผู้ตรวจสอบเอกสารหลักฐาน',
                                          font: ttf,
                                        ),
                                      ]),
                                )),
                          ],
                        )),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Container(
                        height: 160,
                        padding: pw.EdgeInsets.all(2),
                        decoration: pw.BoxDecoration(
                          border:
                              pw.Border.all(color: PdfColors.grey, width: 1),
                        ),
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            Textx_mini(
                              value: 'เรียน นายกเทศมนตรีนครเชียงใหม่',
                              font: ttf,
                            ),
                            Textx_mini(
                              value: '-เพื่อโปรดพิจารณา',
                              font: ttf,
                            ),
                            Textx_mini(
                              value: '-ควรดำเนินการตามเสนอ',
                              font: ttf,
                            ),
                            pw.Align(
                                alignment: pw.Alignment.center,
                                child: pw.SizedBox(
                                  child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.center,
                                      children: [
                                        Signature_PDF(
                                            value: '',
                                            font: ttf,
                                            height: 35,
                                            width: 35,
                                            signatureImage: iconImage),
                                        Textx_mini(
                                          value: 'ตำแหน่ง ______________',
                                          font: ttf,
                                        ),
                                        Textx_mini(
                                          value: 'ผู้ตรวจสอบเอกสารหลักฐาน',
                                          font: ttf,
                                        ),
                                      ]),
                                )),
                          ],
                        )),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Container(
                        height: 160,
                        decoration: pw.BoxDecoration(
                          border:
                              pw.Border.all(color: PdfColors.grey, width: 1),
                        ),
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            Textx_mini(
                              value: 'อนุญาตตามเสนอ',
                              font: ttf,
                            ),
                            Textx_mini(
                              value: 'ลงนามแล้ว',
                              font: ttf,
                            ),
                            pw.Align(
                                alignment: pw.Alignment.center,
                                child: pw.SizedBox(
                                  child: pw.Column(children: [
                                    Signature_PDF(
                                        value: '',
                                        font: ttf,
                                        height: 35,
                                        width: 35,
                                        signatureImage: iconImage),
                                    Textx_mini(
                                      value: 'ตำแหน่ง ______________',
                                      font: ttf,
                                    ),
                                    Textx_mini(
                                      value: 'ผู้ตรวจสอบเอกสารหลักฐาน',
                                      font: ttf,
                                    ),
                                  ]),
                                )),
                          ],
                        )),
                  ),
                ],
              ),
            ),
          ],
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
              doc: pdf, title: 'ใบคำร้องต่อใบอนุญาตแก่ปลัดเทศบาล'),
        ));
  }
}
