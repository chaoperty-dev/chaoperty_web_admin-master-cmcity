import 'dart:convert';
import 'dart:io';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../Constant/Myconstant.dart';
import '../../PeopleChao/Pays_.dart';
import '../../Style/loadAndCacheImage.dart';
import '../Model/FlowModel_Model.dart';
import '../Model/ReviewUuid_Model.dart';
import '../unity/API_requests_reviewsflow.dart';
import '../unity/FormatIDCard.dart';
import '../unity/FormatPhone.dart';
import '../unity/thai_date_utils.dart';
import 'unity_pdf_cmm/perviewpdf1_cmm.dart';
import 'unity_pdf_cmm/unitypdf_cmm.dart';

Future<dynamic> GeneratePDF_ApplicationForm3_CMM(
  BuildContext context,
  int type,
  List<ReviewDetail> dataDetail, // ✅ ใส่ type ให้พารามิเตอร์
  String requestUuid,
) async {
  final pdf = pw.Document();
  final ttf = await font1();
  final ttf2 = await font2();

  // ป้องกันกรณีลิสต์ว่าง
  if (dataDetail.isEmpty) {
    // debugPrint('⚠️ dataDetail ว่าง: ยกเลิกการสร้าง PDF');
    return;
  }

  final reviewDetail = dataDetail; // ชื่อสั้น/คงเดิมได้ตามสะดวก
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
  String Age = orDash(reviewDetail.first.client.age?.toString());

  final desiredstartdate = reviewDetail.first.newRequest.desiredStartDate ?? '';

  DateTime? safeDay;
  if (desiredstartdate.isNotEmpty) {
    try {
      safeDay = DateTime.parse(desiredstartdate);
    } catch (_) {
      // debugPrint('❌ วันที่ไม่ถูกต้อง: $desiredstartdate');
    }
  }

  String day = '', monthName = '', year = '', thaiDate = '', thaiYear = '';
  if (safeDay != null) {
    day = safeDay.day.toString().padLeft(2, '0');
    monthName = getThaiMonthName(safeDay.month);
    year = (safeDay.year + 543).toString();
    thaiYear = toThaiNumber((safeDay.year + 543).toString());
    thaiDate = toThaiNumber(safeDay.day.toString());

    // ถ้าต้องการแปลงตัวเลขไทยในฟิลด์อื่น ๆ เฉพาะตอนมีวันที่
    // idCard = toThaiNumber(idCard);
    // tel = toThaiNumber(tel);
    // addr1 = toThaiNumber(addr1);
    // ln     = toThaiNumber(ln);
  } else {
    //  debugPrint('⚠️ ไม่สามารถแปลงวันที่ได้');
  }

  // โหลดโลโก้ (await อยู่แล้ว ✅)
  final iconImage = await loadImagePDFCMM('images/logo3.png');

  // ---------- หาเอกสารลายเซ็น clientDocumentId == 9 แบบปลอดภัย ----------
  String? signatureUuid;
  final reqDocs = reviewDetail.first.requiredDocs; // สมมติเป็น List อยู่แล้ว
  if (reqDocs.isNotEmpty) {
    final sigCandidates =
        reqDocs.where((d) => d.attachment?.clientDocumentId == 9);
    if (sigCandidates.isNotEmpty) {
      final doc = sigCandidates.first;
      signatureUuid = doc.attachment?.uuid;
    } else {
      //  debugPrint('ℹ️ ไม่พบเอกสารลายเซ็น (clientDocumentId=9)');
    }
  } else {
    //  debugPrint('ℹ️ requiredDocs ว่าง');
  }

  // ---------- สร้าง URL เฉพาะเมื่อมี UUID จริง ----------
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
    // ถ้าเมธอดรองรับ null ให้ส่งไปตรง ๆ; ถ้าไม่รองรับให้ส่ง '' แล้วให้ widget handle เอง
    signatureImageUrl: signatureUrl,
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
        final rawFlows = data?['flows']; // dynamic
        flows = FlowModelStep.listFromJson(rawFlows);
        //  debugPrint('มี ${flows.length} flows');
      } else {
        //   debugPrint('error (status: ${response?.statusCode})');
      }
    } catch (e, st) {
      //   debugPrint('exception: $e\n$st');
    }
  }

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
                        color: PdfColors.black,
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
              'ส่วนราชการ: สำนักปลัดเทศบาล ฝ่ายปกครอง งานรักษาความสงบเรียบร้อย โทร.053-232175-6',
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
                value: 'ที่ ชม 52001.2/',
                font: ttf,
              ),
            ),
          ),
          pw.Expanded(
            flex: 1,
            child: pw.Align(
              alignment: pw.Alignment.topLeft,
              child: Textx(
                value: 'วันที่  - ',
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
                  value: '$name', // example: 'สมชาย ใจดี'
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
                  value: '$Age',
                  flex: 1,
                  font: ttf,
                ),
                Textx(
                  value: 'ปี สัญชาติ',
                  font: ttf,
                ),
                labeledLine(
                  value: '$Nationality',
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
                  value: '$addr1',
                  flex: 3,
                  font: ttf,
                ),
                Textx(
                  value: 'เบอร์โทรศัพท์',
                  font: ttf,
                ),
                labeledLine(
                  value: '$tel',
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
                      'ได้ยื่นขอต่ออายุใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะประเภทจำหน่ายสินค้าเป็นปกติในพื้นที่ที่ตั้งของเทศบาลนครเชียงใหม่ ประจำปี',
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
                  value: '$subzone',
                  flex: 1,
                  font: ttf,
                ),
                Textx(
                  value: 'เลขที่',
                  font: ttf,
                ),
                labeledLine(
                  value: '$ln',
                  flex: 1,
                  font: ttf,
                ),
                Textx(
                  value: 'เพื่อจำหน่ายสินค้า',
                  font: ttf,
                ),
                labeledLine(
                  value: '$stype',
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
                                  value: '$subzone',
                                  flex: 2,
                                  font: ttf,
                                ),
                                Textx(
                                  value: 'ประกาศ ณ วันที่',
                                  font: ttf,
                                ),
                                labeledLine(
                                  value: ' - ',
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
                                    // widget_Signature,
                                    Textx_mini(
                                      value: (flows[0].approvedSign == null ||
                                              flows[0].approvedSign == '' ||
                                              flows[0].approvedSign!.isEmpty)
                                          ? 'รออนุมัติ'
                                          : 'อนุมัติแล้ว',
                                      font: ttf,
                                    ),
                                    Textx_mini(
                                      value:
                                          '( ${flows[0].approvedBy ?? '______________'} )',
                                      font: ttf,
                                    ),
                                    Textx_mini(
                                      value: flows[0].stepPositionName ??
                                          'ผู้ตรวจสอบเอกสารหลักฐาน',
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
                                        // widget_Signature,
                                        Textx_mini(
                                          value: (flows[1].approvedSign ==
                                                      null ||
                                                  flows[1].approvedSign == '' ||
                                                  flows[1]
                                                      .approvedSign!
                                                      .isEmpty)
                                              ? 'รออนุมัติ'
                                              : 'อนุมัติแล้ว',
                                          font: ttf,
                                        ),
                                        Textx_mini(
                                          value:
                                              '( ${flows[1].approvedBy ?? '______________'} )',
                                          // value: 'ตำแหน่ง ______________',
                                          font: ttf,
                                        ),
                                        Textx_mini(
                                          value: flows[1].stepPositionName ??
                                              'ผู้ตรวจสอบเอกสารหลักฐาน',
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
                              value: ' ' + '-เพื่อโปรดพิจารณา',
                              font: ttf,
                            ),
                            Textx_mini(
                              value: ' ' +
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
                                        // widget_Signature,
                                        Textx_mini(
                                          value: (flows[2].approvedSign ==
                                                      null ||
                                                  flows[2].approvedSign == '' ||
                                                  flows[2]
                                                      .approvedSign!
                                                      .isEmpty)
                                              ? 'รออนุมัติ'
                                              : 'อนุมัติแล้ว',
                                          font: ttf,
                                        ),
                                        Textx_mini(
                                          value:
                                              '( ${flows[2].approvedBy ?? '______________'} )',
                                          font: ttf,
                                        ),
                                        Textx_mini(
                                          value: flows[2].stepPositionName ??
                                              'ผู้ตรวจสอบเอกสารหลักฐาน',
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
                              value: ' ' + '-เพื่อโปรดพิจารณา',
                              font: ttf,
                            ),
                            Textx_mini(
                              value: ' ' + '-ควรดำเนินการตามเสนอ',
                              font: ttf,
                            ),
                            pw.Align(
                                alignment: pw.Alignment.center,
                                child: pw.SizedBox(
                                  child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.center,
                                      children: [
                                        Textx_mini(
                                          value: (flows[3].approvedSign ==
                                                      null ||
                                                  flows[3].approvedSign == '' ||
                                                  flows[3]
                                                      .approvedSign!
                                                      .isEmpty)
                                              ? 'รออนุมัติ'
                                              : 'อนุมัติแล้ว',
                                          font: ttf,
                                        ),
                                        Textx_mini(
                                          value:
                                              '( ${flows[3].approvedBy ?? '______________'} )',
                                          font: ttf,
                                        ),
                                        Textx_mini(
                                          value: flows[3].stepPositionName ??
                                              'ผู้ตรวจสอบเอกสารหลักฐาน',
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
                              value: ' ' + '-เพื่อโปรดพิจารณา',
                              font: ttf,
                            ),
                            Textx_mini(
                              value: ' ' + '-ควรดำเนินการตามเสนอ',
                              font: ttf,
                            ),
                            pw.Align(
                                alignment: pw.Alignment.center,
                                child: pw.SizedBox(
                                  child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.center,
                                      children: [
                                        Textx_mini(
                                          value: (flows[4].approvedSign ==
                                                      null ||
                                                  flows[4].approvedSign == '' ||
                                                  flows[4]
                                                      .approvedSign!
                                                      .isEmpty)
                                              ? 'รออนุมัติ'
                                              : 'อนุมัติแล้ว',
                                          font: ttf,
                                        ),
                                        Textx_mini(
                                          value:
                                              '( ${flows[4].approvedBy ?? '______________'} )',
                                          font: ttf,
                                        ),
                                        Textx_mini(
                                          value: flows[4].stepPositionName ??
                                              'ผู้ตรวจสอบเอกสารหลักฐาน',
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
                              value: ' ' + '-เพื่อโปรดพิจารณา',
                              font: ttf,
                            ),
                            Textx_mini(
                              value: ' ' + '-ควรดำเนินการตามเสนอ',
                              font: ttf,
                            ),
                            pw.Align(
                                alignment: pw.Alignment.center,
                                child: pw.SizedBox(
                                  child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.center,
                                      children: [
                                        Textx_mini(
                                          value: (flows[5].approvedSign ==
                                                      null ||
                                                  flows[5].approvedSign == '' ||
                                                  flows[5]
                                                      .approvedSign!
                                                      .isEmpty)
                                              ? 'รออนุมัติ'
                                              : 'อนุมัติแล้ว',
                                          font: ttf,
                                        ),
                                        Textx_mini(
                                          value:
                                              '( ${flows[5].approvedBy ?? '______________'} )',
                                          font: ttf,
                                        ),
                                        Textx_mini(
                                          value: flows[5].stepPositionName ??
                                              'ผู้ตรวจสอบเอกสารหลักฐาน',
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
                              value: ' ' + '-อนุญาตตามเสนอ',
                              font: ttf,
                            ),
                            Textx_mini(
                              value: ' ' + '-ลงนามแล้ว',
                              font: ttf,
                            ),
                            pw.Align(
                                alignment: pw.Alignment.center,
                                child: pw.SizedBox(
                                  child: pw.Column(children: [
                                    Textx_mini(
                                      value: (flows[6].approvedSign == null ||
                                              flows[6].approvedSign == '' ||
                                              flows[6].approvedSign!.isEmpty)
                                          ? 'รออนุมัติ'
                                          : 'อนุมัติแล้ว',
                                      font: ttf,
                                    ),
                                    Textx_mini(
                                      value:
                                          '( ${flows[6].approvedBy ?? '______________'} )',
                                      font: ttf,
                                    ),
                                    Textx_mini(
                                      value: flows[6].stepPositionName ??
                                          'ผู้ตรวจสอบเอกสารหลักฐาน',
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
