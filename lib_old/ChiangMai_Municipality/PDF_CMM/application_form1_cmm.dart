import 'dart:convert';
import 'dart:io';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../Constant/Myconstant.dart';
import '../../PeopleChao/Pays_.dart';
import '../Model/ReviewUuid_Model.dart';
import '../unity/API_admin_signature.dart';
import '../unity/API_requests_reviewsflow.dart';
import '../unity/FormatIDCard.dart';
import '../unity/FormatPhone.dart';
import '../unity/thai_date_utils.dart';
import 'unity_pdf_cmm/perviewpdf1_cmm.dart';
import 'unity_pdf_cmm/unitypdf_cmm.dart';

// class PdfAssetsCache {
//   static pw.Font? _fontPrimary;
//   static pw.Font? _fontSecondary;
//   static Uint8List? _logoBytes;

//   static Future<void> ensureLoaded() async {
//     // โหลดครั้งเดียว (subsequent calls คือ O(1))
//     _fontPrimary ??=
//         pw.Font.ttf(await rootBundle.load('assets/fonts/THSarabunNew.ttf'));
//     _fontSecondary ??= pw.Font.ttf(
//         await rootBundle.load('assets/fonts/THSarabunNew_Bold.ttf'));
//     _logoBytes ??=
//         (await rootBundle.load('images/logo3.png')).buffer.asUint8List();
//   }

//   static pw.Font get fontPrimary => _fontPrimary!;
//   static pw.Font get fontSecondary => _fontSecondary!;
//   static Uint8List get logoBytes => _logoBytes!;
// }

// Future<dynamic> GeneratePDF_ApplicationForm1_CMM(
//     BuildContext context, int type, DataDetail) async {

Future<dynamic> GeneratePDF_ApplicationForm1_CMM(
  BuildContext context,
  int type,
  List<ReviewDetail> reviewDetail,
  String requestUuid, // อย่าใช้ชื่อนี้ซ้ำอีกด้านล่าง
) async {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  // print('GeneratePDF_ApplicationForm1_CMM');
  final pdf = pw.Document();
  final ttf = await font1();
  final ttf2 = await font2();

  String orDash(String? value) =>
      (value == null || value.trim().isEmpty) ? '-' : value;

  String name = orDash(reviewDetail.first.client.cname);
  String idCard = orDash(formatThaiIdCard(reviewDetail.first.client.tax));
  String tel = orDash(formatPhoneNumber(reviewDetail.first.client.tel));
  String addr1 = orDash(reviewDetail.first.client.addr1);
  String stype = orDash(reviewDetail.first.client.stype);
  String subzone = orDash(reviewDetail.first.newRequest.subzone);
  String zn = orDash(reviewDetail.first.newRequest.zn);
  String ln = orDash(reviewDetail.first.newRequest.ln);
  String comment = orDash(reviewDetail.first.newRequest.comment);
  String Nationality = orDash(reviewDetail.first.client.national);
  String Age = orDash(reviewDetail.first.client.age.toString());
  String amount = orDash(reviewDetail.first.payment.amount?.toString());
  final desiredstartdate = reviewDetail.first.newRequest.desiredStartDate ?? '';
  DateTime? safeDay;
  try {
    if (desiredstartdate.isNotEmpty) {
      safeDay = DateTime.parse(desiredstartdate);
    }
  } catch (_) {
    //  print('❌ วันที่ไม่ถูกต้อง: $desiredstartdate');
  }
  String day = '', monthName = '', year = '', thaiDate = '', thaiYear = '';
  if (safeDay != null) {
    thaiDate = safeDay.day.toString().padLeft(2, '0');
    monthName = getThaiMonthName(safeDay.month);
    year = (safeDay.year + 543).toString();
    thaiYear = (safeDay.year + 543).toString();
  } else {
    //  print('⚠️ ไม่สามารถแปลงวันที่ได้');
  }

  // ---------- หาเอกสารลายเซ็น (clientDocumentId == 9) แบบปลอดภัย ----------
  String? signatureUuid;
  String? requestUuidFromDoc;

  final reqDocs = reviewDetail.first.requiredDocs;
  final sigCandidates = reqDocs.where(
    (d) => d.attachment?.clientDocumentId == 9,
  );

  if (sigCandidates.isNotEmpty) {
    final doc = sigCandidates.first;
    signatureUuid = doc.attachment?.uuid;
    requestUuidFromDoc = doc.attachment?.requestUuid;
  } else {
    // print('ℹ️ ไม่พบเอกสารลายเซ็น (clientDocumentId=9)');
  }

  // ---------- ใช้ URL เฉพาะเมื่อมี signatureUuid ----------
  String? signatureUrl;
  if (signatureUuid != null && signatureUuid!.isNotEmpty) {
    signatureUrl =
        '${MyConstant().domain_v1}/admin/requests/attachments/$signatureUuid/preview';
    // print(signatureUrl);
  }

  final widget_Signature = await Signature_PDF(
    value: '',
    font: ttf,
    height: 50,
    width: 150,
    // ถ้าไม่มีรูป ให้ส่ง null หรือปล่อยว่างตามสัญญาเมธอดของคุณ
    signatureImageUrl: signatureUrl,
  );

  // ---------- Build PDF ----------

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
            // pw.Align(
            //   alignment: pw.Alignment.center,
            //   child: pw.Text('คำขอต่ออายุ',
            //       style: pw.TextStyle(
            //           font: ttf, fontSize: 15, fontWeight: pw.FontWeight.bold)),
            // ),
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
              // 'วันที่ $desiredstartdate',
              'วันที่ $thaiDate เดือน $monthName พ.ศ. $thaiYear',
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
              value: '$Age', // example: 'สมชาย ใจดี'
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
              value: '$Nationality',
              flex: 2,
              font: ttf,
            ),
            Textx(
              value: 'อยู่บ้านเลขที่',
              font: ttf,
            ),
            labeledLine(
              value: '$addr1',
              flex: 4,
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
              value: '$tel',
              flex: 1,
              font: ttf,
            ),
            pw.Expanded(flex: 2, child: pw.SizedBox())
          ],
        ),
        // pw.SizedBox(height: 4),
        pw.SizedBox(height: 10),
        pw.Text(
            ' ' * 12 +
                'ขอยื่นต่ออายุใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ ประเภทจัดจำหน่ายสินค้าปกติ ในพื้นที่ผิวถนนของเทศบาลนครเชียงใหม่ ',
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
              value: 'บริเวณ',
              // 'ในพื้นที่ผิวถนนของเทศบาลนครเชียงใหม่ บริเวณ',
              font: ttf,
            ),
            labeledLine(
              value: '$subzone',
              flex: 2,
              font: ttf,
            ),
            Textx(
              value: 'โซน',
              font: ttf,
            ),
            labeledLine(
              value: '$zn',
              flex: 2,
              font: ttf,
            ),
            Textx(
              value: 'ล็อกที่',
              font: ttf,
            ),
            labeledLine(
              value: '$ln',
              flex: 1,
              font: ttf,
            ),
          ],
        ),

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
                '1. รูปถ่าย (หน้าตรง ไม่สวมหมวก) ขนาด ${toThaiNumber((2).toString())} นิ้ว จำนวน ${toThaiNumber((2).toString())} รูป',
            style: pw.TextStyle(
                font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
        // pw.Text(' ' * 12 + '2. รูปถ่ายผู้เกี่ยวร้านค้าและสินค้า 1 รูป',
        //     style: pw.TextStyle(
        //         font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Text(' ' * 12 + '2. รูปถ่ายคู่กับร้านค้าและสินค้า 1 รูป',
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
                '5. ใบเสร็จรับเงินค่าธรรมเนียมใบอนุญาตฯ จำนวน ${(nFormat.format(double.parse(amount ?? "500"))).toString()} บาท',
            // ' ' * 12 +
            //     '5. ใบเสร็จรับเงินค่าธรรมเนียมใบอนุญาตฯ จำนวน ${toThaiNumber((500).toString())}บาท',
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
              value: '$stype',
              flex: 1,
              font: ttf,
            ),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Row(
          children: [
            Textx(
              value: ' ' * 12 +
                  '7. ใบรับรองผ่านการอบรมหลักสูตรการสุขาภิบาลอาหาร สำหรับผู้สัมผัสอาหารตามกฎกระทรวงสาธารณสุข',
              font: ttf,
            ),
            // labeledLine(
            //   value: '$comment',
            //   flex: 1,
            //   font: ttf,
            // ),
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
                widget_Signature,
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

        pw.SizedBox(height: 2),
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
