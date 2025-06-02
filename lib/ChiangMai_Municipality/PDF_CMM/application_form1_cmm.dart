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

Future<dynamic> GeneratePDF_ApplicationForm1_CMM(
    BuildContext context, int type) async {
  final pdf = pw.Document();
  final ttf = await font1();
  final ttf2 = await font2();
  // final imageLogo = pw.MemoryImage(logoFile.readAsBytesSync());
  String name = 'นายสมชายสมชายสมชาย ใจดีใจดีใจดีใจดี';
  String idCard = '1234567890123';
  final iconImage =
      await loadImagePDFCMM('images/logo3.png'); // 👈 รอให้โหลดเสร็จก่อน
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
              child: pw.Text('คำขอต่ออายุ',
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
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('ทำที่ สำนักงานเทศบาลนครเชียงใหม่',
              style: pw.TextStyle(
                  font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
        ),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
              'วันที่ ............ เดือน ........................ พ.ศ. ...............',
              style: pw.TextStyle(
                  font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
        ),

        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            Textx(
              value: ' ' * 12 + 'ข้าพเจ้า',
              font: ttf,
            ),
            labeledLine(
              value: name, // example: 'สมชาย ใจดี'
              flex: 4,
              font: ttf,
            ),
            Textx(
              value: 'เลขบัตรประจำตัวประชาชน',
              font: ttf,
            ),
            labeledLine(
              value: idCard,
              flex: 2,
              font: ttf,
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            Textx(
              value: 'อายุ',
              font: ttf,
            ),
            labeledLine(
              value: '30', // example: 'สมชาย ใจดี'
              flex: 1,
              font: ttf,
            ),
            // Textx(
            //   value: 'ปี',
            //   font: ttf,
            // ),
            Textx(
              value: 'ปี สัญชาติ',
              font: ttf,
            ),
            labeledLine(
              value: 'ไทย',
              flex: 2,
              font: ttf,
            ),
            Textx(
              value: 'โทรศัพท์',
              font: ttf,
            ),
            labeledLine(
              value: 'xxx-xxxx-xx',
              flex: 2,
              font: ttf,
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            Textx(
              value: 'อยู่บ้านเลขที่',
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
        // pw.SizedBox(height: 4),
        pw.SizedBox(height: 10),
        pw.Text(
            ' ' * 12 +
                'ขอยื่นต่ออายุใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ ประเภทจัดจำหน่ายสินค้าปกติ',
            style: pw.TextStyle(
                font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
        // pw.Text(
        //     'ในพื้นที่ผิวถนนของเทศบาลนครเชียงใหม่ บริเวณ .....................................................',
        //     style: pw.TextStyle(
        //         font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            Textx(
              value: 'ในพื้นที่ผิวถนนของเทศบาลนครเชียงใหม่ บริเวณ',
              font: ttf,
            ),
            labeledLine(
              value: 'ถนนรัษฎาแยกที่',
              flex: 2,
              font: ttf,
            ),
            Textx(
              value: 'โซน',
              font: ttf,
            ),
            labeledLine(
              value: 'xxx',
              flex: 2,
              font: ttf,
            ),
            Textx(
              value: 'ล็อกที่',
              font: ttf,
            ),
            labeledLine(
              value: 'xxx',
              flex: 1,
              font: ttf,
            ),
          ],
        ),
        // pw.SizedBox(height: 4),
        // pw.Row(
        //   children: [
        //     Textx(
        //       value: 'โซน',
        //       font: ttf,
        //     ),
        //     labeledLine(
        //       value: 'xxx',
        //       flex: 1,
        //       font: ttf,
        //     ),
        //     Textx(
        //       value: 'ล็อกที่',
        //       font: ttf,
        //     ),
        //     labeledLine(
        //       value: 'xxx',
        //       flex: 1,
        //       font: ttf,
        //     ),
        //   ],
        // ),
        pw.SizedBox(height: 4),
        // pw.Text(
        //     'ถนนรัษฎาแยกที่ .............. โซน ................... ล็อกที่ ...................',
        //     style: pw.TextStyle(
        //         font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Text('ต่อขอทางเทศบาลนครเชียงใหม่',
            style: pw.TextStyle(
                font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Text(
            ' ' * 12 + 'พร้อมคำขอ ข้าพเจ้าได้แนบเอกสารและหลักฐานต่างๆ ดังนี้',
            style: pw.TextStyle(
                font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.Text(
            ' ' * 12 +
                '1. รูปถ่าย (หน้าตรง ไม่สวมหมวก) ขนาด 2 นิ้ว จำนวน 2 รูป',
            style: pw.TextStyle(
                font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
        // pw.Text(' ' * 12 + '2. รูปถ่ายผู้เกี่ยวร้านค้าและสินค้า 1 รูป',
        //     style: pw.TextStyle(
        //         font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Text(' ' * 12 + '2. ใบรับรองแพทย์',
            style: pw.TextStyle(
                font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.Text(' ' * 12 + '3. ใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ',
            style: pw.TextStyle(
                font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.Text(' ' * 12 + '4. บัตรประจำตัวผู้ค้า',
            style: pw.TextStyle(
                font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.Text(
            ' ' * 12 +
                '5. ใบเสร็จรับเงินค่าธรรมเนียมใบอนุญาตฯ จำนวน 500.00 บาท',
            style: pw.TextStyle(
                font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
        // pw.Text(' ' * 12 + '7. ใบรับรองผ่านการอบรมหลักสูตรการสุขาภิบาลอาหาร',
        //     style: pw.TextStyle(
        //         font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 2),
        pw.Row(
          children: [
            Textx(
              value: ' ' * 12 + '6. ประเภทสินค้า',
              font: ttf,
            ),
            labeledLine(
              value: 'ถนนรัษฎาแยกที่',
              flex: 1,
              font: ttf,
            ),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Row(
          children: [
            Textx(
              value: ' ' * 12 + '7. อื่น ๆ ',
              font: ttf,
            ),
            labeledLine(
              value: 'ถนนรัษฎาแยกที่',
              flex: 1,
              font: ttf,
            ),
          ],
        ),
        // pw.Text(
        //     ' ' * 12 +
        //         '8. ประเภทสินค้า ..............................................',
        //     style: pw.TextStyle(
        //         font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
        // pw.Text(
        //     ' ' * 12 +
        //         '9. อื่น ๆ ..........................................................',
        //     style: pw.TextStyle(
        //         font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 20),
        pw.Text(
            ' ' * 12 +
                'ข้าพเจ้าขอรับรองว่าข้อความในแบบคำขอนี้เป็นความจริงทุกประการ',
            style: pw.TextStyle(
                font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 20),
        pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.SizedBox(
              child: pw.Column(children: [
                Signature_PDF(
                    value: '',
                    font: ttf,
                    height: 35,
                    width: 35,
                    signatureImage: iconImage),
                Textx_mini(
                  value: '(ลงชื่อ) $name',
                  font: ttf,
                ),
                Textx_mini(
                  value: 'ผู้ขอรับใบอนุญาต',
                  font: ttf,
                ),
              ]),
            )),
        // pw.Align(
        //   alignment: pw.Alignment.centerRight,
        //   child: pw.Container(
        //     width: 250,
        //     child: pw.Row(
        //       children: [
        //         Textx(
        //           value: '(ลงชื่อ) ',
        //           font: ttf,
        //         ),
        //         labeledLine(
        //           value: 'XXXXX',
        //           flex: 1,
        //           font: ttf,
        //         ),
        //         Textx(
        //           value: ' ผู้ขอรับใบอนุญาต',
        //           font: ttf,
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        pw.SizedBox(height: 2),
        // pw.Align(
        //   alignment: pw.Alignment.centerRight,
        //   child: pw.Container(
        //     width: 250,
        //     child: pw.Row(
        //       children: [
        //         Textx(
        //           value: ' ' * 12 + '( ',
        //           font: ttf,
        //         ),
        //         labeledLine(
        //           value: '',
        //           flex: 1,
        //           font: ttf,
        //         ),
        //         Textx(
        //           value: ' )' + ' ' * 12,
        //           font: ttf,
        //         ),
        //       ],
        //     ),
        //   ),
        // ),

        // pw.Row(
        //   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        //   children: [
        //     pw.Text(
        //         '(ลงชื่อ) ..................................................',
        //         style: pw.TextStyle(
        //             font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
        //     pw.Text('ผู้ขอรับใบอนุญาต',
        //         style: pw.TextStyle(
        //             font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
        //   ],
        // ),
        // pw.Row(
        //   mainAxisAlignment: pw.MainAxisAlignment.end,
        //   children: [
        //     pw.Text('....................................................',
        //         style: pw.TextStyle(
        //             font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
        //   ],
        // ),
      ],
    ),
  );

  // final List<int> bytes = await pdf.save();
  // final Uint8List data = Uint8List.fromList(bytes);
  // MimeType type = MimeType.PDF;
  // final dir = await FileSaver.instance.saveFile(
  //     "ใบคำร้องขอต่อใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ", data, "pdf",
  //     mimeType: type);
  // Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => PreviewPdfgen_Billsplay(
  //           doc: pdf,
  //           title: 'ใบคำร้องขอต่อใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ'),
  //     ));

  if (type == 0) {
    return pdf;
  } else {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewPdfgen1_CMM(
              doc: pdf,
              title: 'ใบคำร้องขอต่อใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ'),
        ));
  }
}
