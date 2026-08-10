import 'dart:convert';
import 'dart:io';
import 'dart:js';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../Constant/Myconstant.dart';
import '../../PeopleChao/Pays_.dart';
import '../Model/FlowModel_Model.dart';
import '../Model/ReviewUuid_Model.dart';
import '../unity/API_requests_reviewsflow.dart';
import '../unity/FormatIDCard.dart';
import '../unity/FormatPhone.dart';
import '../unity/thai_date_utils.dart';
import 'unity_pdf_cmm/perviewpdf1_cmm.dart';
import 'unity_pdf_cmm/unitypdf_cmm.dart';

Future<dynamic> GeneratePDF_License_CMM(
  BuildContext context,
  int type,
  List<ReviewDetail> dataDetail, // ✅ ระบุ type ให้ชัด
  String requestUuid,
) async {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  final pdf = pw.Document();
  final ttf = await font1();
  final ttf2 = await font2();

  if (dataDetail.isEmpty) {
    //  debugPrint('⚠️ dataDetail ว่าง: ยกเลิกการสร้าง PDF');
    return;
  }

  final reviewDetail = dataDetail;
  String orDash(String? v) => (v == null || v.trim().isEmpty) ? '-' : v;

  String name = orDash(reviewDetail.first.client.cname);
  String idCard = orDash(formatThaiIdCard(reviewDetail.first.client.tax));
  String tel = orDash(formatPhoneNumber(reviewDetail.first.client.tel));
  String addr1 = orDash(reviewDetail.first.client.addr1);
  String stype = orDash(reviewDetail.first.client.stype);
  String subzone = orDash(reviewDetail.first.newRequest.subzone);
  String zn = orDash(reviewDetail.first.newRequest.zn);
  String ln = orDash(reviewDetail.first.newRequest.ln);
  String qty = orDash(reviewDetail.first.newRequest.qty.toString());
  String comment = orDash(reviewDetail.first.newRequest.comment);
  String sdatex = orDash(reviewDetail.first.newRequest.sdate);
  String ldatex = orDash(reviewDetail.first.newRequest.ldate);
  String Nationality = orDash(reviewDetail.first.client.national);
  String Age = orDash(reviewDetail.first.client.age?.toString());
  String slipPdate = orDash(reviewDetail.first.payment.slipPdate?.toString());
  String amount = orDash(reviewDetail.first.payment.amount?.toString());
  final desiredStartDate = reviewDetail.first.newRequest.desiredStartDate ?? '';

  DateTime? safeDay;
  DateTime? safeSDay;
  DateTime? safeLDay;
  DateTime? safePdate;

  // ✅ กันค่าว่างก่อน parse
  if (desiredStartDate.isNotEmpty) {
    try {
      safeDay = DateTime.parse(desiredStartDate);
    } catch (_) {
      // debugPrint('❌ วันที่ไม่ถูกต้อง: $desiredStartDate');
    }
  }
  if (sdatex.isNotEmpty) {
    try {
      safeSDay = DateTime.parse(sdatex);
    } catch (_) {
      //    debugPrint('❌ วันที่ไม่ถูกต้อง: $sdatex');
    }
  }
  if (ldatex.isNotEmpty) {
    try {
      safeLDay = DateTime.parse(ldatex);
    } catch (_) {
      //  debugPrint('❌ วันที่ไม่ถูกต้อง: $ldatex');
    }
  }
  if (slipPdate.isNotEmpty) {
    try {
      safePdate = DateTime.parse(slipPdate);
    } catch (_) {
      //debugPrint('❌ วันที่ไม่ถูกต้อง: $slipPdate');
    }
  }
  String day = '', monthName = '', year = '', thaiDate = '', thaiYear = '';
  String sdate = '', ldate = '';

  if (safeDay != null) {
    day = safeDay.day.toString().padLeft(2, '0');
    monthName = getThaiMonthName(safeDay.month);
    year = (safeDay.year + 543).toString();
    thaiYear = (safeDay.year + 543).toString();
    thaiDate = safeDay.day.toString();
    // ถ้าต้องการเลขไทยค่อยใช้:
    // thaiYear = toThaiNumber(thaiYear);
    // thaiDate = toThaiNumber(thaiDate);
  } else {
    //  debugPrint('⚠️ ไม่สามารถแปลง desiredStartDate ได้');
  }

  if (safeSDay != null) {
    final smonthName = getThaiMonthName(safeSDay.month);
    final sthaiYear = (safeSDay.year + 543).toString();
    final sthaiDate = safeSDay.day.toString();
    sdate = '$sthaiDate $smonthName $sthaiYear';
  } else {
    // debugPrint('⚠️ ไม่สามารถแปลง sdate ได้');
  }

  if (safeLDay != null) {
    final lmonthName = getThaiMonthName(safeLDay.month);
    final lthaiYear = (safeLDay.year + 543).toString();
    final lthaiDate = safeLDay.day.toString();
    ldate = '$lthaiDate $lmonthName $lthaiYear';
  } else {
    //('⚠️ ไม่สามารถแปลง ldate ได้');
  }

  if (safePdate != null) {
    final pPdatemonthName = getThaiMonthName(safePdate.month);
    final pPdatethaiYear = (safePdate.year + 543).toString();
    final pPdatethaiDate = safePdate.day.toString();
    slipPdate = '$pPdatethaiDate $pPdatemonthName $pPdatethaiYear';
  } else {
    // debugPrint('⚠️ ไม่สามารถแปลง ldate ได้');
  }
  // โหลดโลโก้
  final iconImage = await loadImagePDFCMM('images/logo3.png');

  // ---------- หาเอกสารลายเซ็น clientDocumentId == 9 แบบปลอดภัย ----------
  String? signatureUuid;
  final reqDocs = reviewDetail.first.requiredDocs;
  if (reqDocs.isNotEmpty) {
    final sigDoc = reqDocs.firstWhere(
      (d) => d.attachment?.clientDocumentId == 9,
      orElse: () => reqDocs.firstWhere(
        (d) => false,
        orElse: () => reqDocs.first, // หรือโยนทิ้งให้เป็น no-op
      ),
    );
    if (sigDoc.attachment?.clientDocumentId == 9) {
      signatureUuid = sigDoc.attachment?.uuid;
    } else {
      //  debugPrint('ℹ️ ไม่พบเอกสารลายเซ็น (clientDocumentId=9)');
    }
  } else {
    // debugPrint('ℹ️ requiredDocs ว่าง');
  }

  // ✅ สร้าง URL เฉพาะเมื่อมี UUID จริง
  String? signatureUrl;
  if (signatureUuid != null && signatureUuid.isNotEmpty) {
    signatureUrl =
        '${MyConstant().domain_v1}/admin/requests/attachments/$signatureUuid/preview';
  }

  final widget_Signature = await Signature_PDF(
    value: '',
    font: ttf,
    height: 50,
    width: 150,
    signatureImageUrl:
        signatureUrl, // ถ้า null ให้ widget จัดการ placeholder เอง
  );

  // ---------- โหลด flows จาก requestUuid (non-nullable) ----------
  List<FlowModelStep> flows = [];
  if (requestUuid.isNotEmpty) {
    // ✅ แทนการเช็ค != null
    try {
      final response = await read_GC_ReviewsFlowUuid(UuidRequest: requestUuid);
      if (response != null && response.statusCode == 200) {
        final result = json.decode(response.body) as Map<String, dynamic>;
        final data = result['data'] as Map<String, dynamic>?;
        final rawFlows = data?['flows'];
        flows = FlowModelStep.listFromJson(rawFlows);
        //   debugPrint('มี ${flows.length} flows');
      } else {
        //     debugPrint('error (status: ${response?.statusCode})');
      }
    } catch (e, st) {
      //  debugPrint('exception: $e\n$st');
    }
  }

  /////////---------------------------->

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.copyWith(
        marginBottom: 38.00,
        marginLeft: 38.00,
        marginRight: 38.00,
        marginTop: 38.00,
      ),
      header: (context) {
        return pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Container(
              height: 30,
              width: 30,
              // decoration: pw.BoxDecoration(
              //   border: pw.Border.all(color: PdfColors.grey300),
              // ),
              child: iconImage != null
                  ? pw.Image(
                      pw.MemoryImage(iconImage),
                      height: 30,
                      width: 30,
                    )
                  : null,
            ),
            pw.SizedBox(width: 10),
            pw.Row(
              children: [
                pw.Expanded(flex: 1, child: pw.SizedBox()),
                pw.Expanded(
                    flex: 3,
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.SizedBox(
                          height: 10,
                        ),
                        pw.Align(
                          alignment: pw.Alignment.center,
                          child: pw.Text('ใบอนุญาต',
                              style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 15,
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Align(
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                              'ใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ',
                              style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 15,
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    )),
                pw.Expanded(
                    flex: 1,
                    child: pw.SizedBox(
                        child: pw.Align(
                      alignment: pw.Alignment.topRight,
                      child: pw.Container(
                        height: 60,
                        width: 60,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                        ),
                        // child: pw.Image(imageLogo),
                      ),
                    ))),
              ],
            )
          ],
        );
      },
      build: (context) => [
        pw.SizedBox(height: 20),
        pw.Text('ทำที่ สำนักงานเทศบาลนครเชียงใหม่',
            style: pw.TextStyle(
                font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(
          width: 200,
          child: pw.Row(
            children: [
              Textx(
                value: ' ' * 0 + 'เล่ม',
                font: ttf,
              ),
              labeledLine(
                value: ' - ', // example: 'สมชาย ใจดี'
                flex: 1,
                font: ttf,
              ),
              Textx(
                value: 'เลข',
                font: ttf,
              ),
              labeledLine(
                value: '-',
                flex: 1,
                font: ttf,
              ),
              Textx(
                value: 'ปี',
                font: ttf,
              ),
              labeledLine(
                value: '-',
                flex: 1,
                font: ttf,
              ),
            ],
          ),
        ),
        // pw.Text(
        //     'เล่ม ............ เลข ........................ ปี ...............',
        //     style: pw.TextStyle(
        //         font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            Textx(
              value: ' ' * 12 + 'อนุญาตให้',
              font: ttf,
            ),
            labeledLine(
              value: '$name', // example: 'สมชาย ใจดี'
              flex: 4,
              font: ttf,
            ),
            Textx(
              value: 'สัญชาติ',
              font: ttf,
            ),
            labeledLine(
              value: '$Nationality',
              flex: 2,
              font: ttf,
            ),
            // Textx(
            //   value: 'อยู่บ้าน/สำนัก',
            //   font: ttf,
            // ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            Textx(
              value: 'อยู่บ้าน/สำนักงานเลขที่',
              font: ttf,
            ),
            labeledLine(
              value: '$addr1',
              flex: 3,
              font: ttf,
            ),
            Textx(
              value: 'เบอร์โทร',
              font: ttf,
            ),
            labeledLine(
              value: '$tel',
              flex: 1,
              font: ttf,
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        // pw.Row(
        //   children: [
        //     Textx(
        //       value: 'เบอร์โทร',
        //       font: ttf,
        //     ),
        //     labeledLine(
        //       value: '$tel',
        //       flex: 1,
        //       font: ttf,
        //     ),
        //     pw.Expanded(flex: 2, child: pw.SizedBox())
        //   ],
        // ),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            Textx(
              value: ' ' * 12 + 'ข้อ 1 จำหน่ายสินค้าในที่หรือทางสาธารณะ ประเภท',
              font: ttf,
            ),
            labeledLine(
              value: '$stype',
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
              value:
                  '${(nFormat.format(double.parse(amount ?? "500"))).toString()}',
              flex: 1,
              font: ttf,
            ),
            Textx(
              value: 'บาท ใบเสร็จรับเงินเล่มที่',
              font: ttf,
            ),
            labeledLine(
              value: ' - ',
              flex: 1,
              font: ttf,
            ),
            Textx(
              value: 'เลขที่',
              font: ttf,
            ),
            labeledLine(
              value: ' - ',
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
              value: ' ${slipPdate} ',
              flex: 1,
              font: ttf,
            ),
            Textx(
              value: 'พื้นที่ประกอบการ',
              font: ttf,
            ),
            labeledLine(
              value: ' $qty ',
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
              value: '-',
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
              value: '-',
              flex: 2,
              font: ttf,
            ),
            Textx(
              value: 'โทรสาร ',
              font: ttf,
            ),
            labeledLine(
              value: '-',
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
              pw.Text(' ' * 16 + 'การจำหน่ายสินค้าในพื้นที่ผ่อนผัน ลงวันที่ -',
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
                    // value: '-',
                    value: '$sdate ถึง $ldate',
                    flex: 2,
                    font: ttf,
                  ),
                  Textx(
                    value: 'ออกให้ ณ วันที่ ',
                    font: ttf,
                  ),
                  labeledLine(
                    value: '$sdate',
                    flex: 1,
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
                Textx_mini(
                  value: (flows[6].approvedSign == null ||
                          flows[6].approvedSign == '' ||
                          flows[6].approvedSign!.isEmpty)
                      ? 'รออนุมัติ'
                      : 'อนุมัติแล้ว',
                  font: ttf,
                ),
                Textx_mini(
                  value: '( ${flows[6].approvedBy ?? '______________'} )',
                  font: ttf,
                ),
                Textx_mini(
                  value: flows[6].stepPositionName ??
                      'รองนายกเทศมนตรี ปฏิบัติราชการแทน\nนายกเทศมนตรีนครเชียงใหม่',
                  font: ttf,
                ),
                // widget_Signature,
                // Textx(
                //   value: '(นายกฤษฎ์ กาญจนเกตุ)',
                //   font: ttf,
                // ),
                // Textx(
                //   value:
                //       'รองนายกเทศมนตรี ปฏิบัติราชการแทน\nนายกเทศมนตรีนครเชียงใหม่',
                //   font: ttf,
                // ),
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
