import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

import '../../Constant/Myconstant.dart';
import '../../Man_PDF/Preview_PDF/Preview_Agreement.dart';
import '../../PeopleChao/Rental_Information.dart';
import '../../Style/ThaiBaht.dart';
import '../../Style/loadAndCacheImage.dart';
import 'package:http/http.dart' as http;

Future<Uint8List?> loadImageFromUrl(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
      return response.bodyBytes;
    } else {
      print('⚠️ โหลดรูปไม่สำเร็จ: $url');
      return null;
    }
  } catch (e) {
    print('❌ loadImageFromUrl error: $e');
    return null;
  }
}

class Pdfgen_Agreementnim3 {
//////////---------------------------------------------------->( **** เอกสารแนบท้ายสัญญาหมายเลข 1  )

  static void exportPDF_Agreementnim3(
      context,
      Get_Value_NameShop_index,
      Get_Value_cid,
      _verticalGroupValue,
      Form_nameshop,
      Form_typeshop,
      Form_bussshop,
      Form_bussscontact,
      Form_address,
      Form_tel,
      Form_email,
      Form_tax,
      Form_ln,
      Form_zn,
      Form_area,
      Form_qty,
      Form_sdate,
      Form_ldate,
      Form_period,
      Form_rtname,
      quotxSelectModels,
      _TransModels,
      renTal_name,
      bill_addr,
      bill_email,
      bill_tel,
      bill_tax,
      bill_name,
      newValuePDFimg,
      tableData00,
      TitleType_Default_Receipt_Name,
      Datex_text,
      FormName1_choice,
      FormName2_choice,
      FormName3_choice,
      FormName4_choice,
      contractPhotoModels) async {
    ////
    //// ------------>(ใบเสนอราคา)

    final pdf = pw.Document();
    // final fontData = await rootBundle.load("ThaiFonts/Sarabun-Medium.ttf");
    // var dataint = fontData.buffer
    //     .asUint8List(fontData.offsetInBytes, fontData.lengthInBytes);
    // final PdfFont font = PdfFont.of(pdf, data: dataint);
    final font = await rootBundle.load("fonts/THSarabunNew.ttf");
    var Colors_pd = PdfColors.black;

    final ttf = pw.Font.ttf(font);

    double font_Size = 12.5;
    DateTime date = DateTime.now();
    // var formatter = DateFormat('MMMMd', 'th');
    String thaiDate = DateFormat('d เดือน MMM', 'th').format(date);
    var nFormat = NumberFormat("#,##0.00", "en_US");
    var nFormat2 = NumberFormat("###0.00", "en_US");
    final iconImage =
        (await rootBundle.load('images/LOGO.png')).buffer.asUint8List();
    List netImage = [];
    Uint8List? resizedLogo = await getResizedLogo();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int pageCount = 1; // Initialize the page count
    String? base64Image_1 = preferences.getString('base64Image1');
    // String? base64Image_2 = preferences.getString('base64Image2');
    // String? base64Image_3 = preferences.getString('base64Image3');
    // String? base64Image_4 = preferences.getString('base64Image4');
    String base64Image_new1 = (base64Image_1 == null) ? '' : base64Image_1;
    // String base64Image_new2 = (base64Image_2 == null) ? '' : base64Image_2;
    // String base64Image_new3 = (base64Image_3 == null) ? '' : base64Image_3;
    // String base64Image_new4 = (base64Image_4 == null) ? '' : base64Image_4;
    // Uint8List data1 = base64Decode(base64Image_new1);
    // Uint8List data2 = base64Decode(base64Image_new2);
    // Uint8List data3 = base64Decode(base64Image_new3);
    // Uint8List data4 = base64Decode(base64Image_new4);

    // for (int i = 0; i < newValuePDFimg.length; i++) {
    //   netImage.add(await networkImage('${newValuePDFimg[i]}'));
    // }
    // final tableData = [
    //   for (int index = 0; index < quotxSelectModels.length; index++)
    //     [
    //       '${nFormat.format(int.parse(quotxSelectModels[index].term!) * double.parse(quotxSelectModels[index].total!))}',
    //     ],
    // ];
    // double Sumtotal = 0;
    // for (int index = 0; index < quotxSelectModels.length; index++)
    //   Sumtotal = Sumtotal +
    //       (int.parse(quotxSelectModels[index].term!) *
    //           double.parse(quotxSelectModels[index].total!));
    Uint8List? photo_pic_plan;
    if (contractPhotoModels.isNotEmpty &&
        (contractPhotoModels[0].pic_plan ?? '').isNotEmpty) {
      photo_pic_plan = await loadImageFromUrl(
        '${MyConstant().domain}/files/nimcity/contract/${contractPhotoModels[0].pic_plan!}',
      );
    } // รูปแปลน

    Uint8List? photo_pic_shop;
    if (contractPhotoModels.isNotEmpty &&
        (contractPhotoModels[0].pic_shop ?? '').isNotEmpty) {
      photo_pic_shop = await loadImageFromUrl(
        '${MyConstant().domain}/files/nimcity/contract/${contractPhotoModels[0].pic_shop!}',
      );
    } //รูปสถานที่
    pw.Widget Textx({
      // required String label,
      required String value,
      // int dotLength = 40,
      required pw.Font font,
      double fontSize = 14,
      textAlign = pw.TextAlign.left,
    }) {
      var Colors_pd = PdfColors.black;
      // final filled = value.padRight(dotLength, '.');
      return pw.Text(
        value,
        textAlign: pw.TextAlign.left,
        style: pw.TextStyle(
          font: font,
          fontSize: fontSize,
          fontWeight: pw.FontWeight.bold,
        ),
      );
    }

    pw.Widget Textxx({
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
        textAlign: pw.TextAlign.justify,
        style: pw.TextStyle(
          font: font,
          fontSize: fontSize,
          fontWeight: pw.FontWeight.bold,
        ),
      );
    }

    pw.Widget Textr({
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
          font: font,
          fontSize: fontSize,
          // fontWeight: pw.FontWeight.bold,
        ),
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
        textAlign: pw.TextAlign.left,
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
            padding: const pw.EdgeInsets.only(bottom: -5, top: -5),
            margin: const pw.EdgeInsets.only(bottom: 5, top: 5),
            //  padding: const pw.EdgeInsets.only(bottom: -3.5),
            child: pw.Text(
              // ' ' * 2 + value + ' ' * 2,
              value,
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                  font: font,
                  fontSize: fontSize,
                  fontWeight: pw.FontWeight.bold),
            ),
          ));
    }

    pw.Widget labeledLine1({
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
                  color: PdfColors.grey,
                  width: 0.05, // ปรับให้บางลงกว่าเดิม
                ),
              ),
            ),
            padding: const pw.EdgeInsets.only(bottom: -5, top: -5),
            margin: const pw.EdgeInsets.only(bottom: 5, top: 5),
            //  padding: const pw.EdgeInsets.only(bottom: -3.5),
            child: pw.Text(
              ' ' * 2 + value + ' ' * 2,
              // value,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                  font: font,
                  fontSize: fontSize,
                  fontWeight: pw.FontWeight.bold),
            ),
          ));
    }

    String formatThaiDate(String input) {
      final parts = input.split('-');
      if (parts.length != 3) return input; // กันพัง

      final day = int.tryParse(parts[0]) ?? 1;
      final month = int.tryParse(parts[1]) ?? 1;
      final year = int.tryParse(parts[2]) ?? 1970;

      const thaiMonths = [
        '', // index 0
        'มกราคม',
        'กุมภาพันธ์',
        'มีนาคม',
        'เมษายน',
        'พฤษภาคม',
        'มิถุนายน',
        'กรกฎาคม',
        'สิงหาคม',
        'กันยายน',
        'ตุลาคม',
        'พฤศจิกายน',
        'ธันวาคม',
      ];

      final beYear = year + 543;
      final monthName = (month >= 1 && month <= 12) ? thaiMonths[month] : '';

      return '$day เดือน $monthName พ.ศ. $beYear';
    }

    String formatThaiDate_y(String input) {
      try {
        final dt = DateTime.parse(input); // แปลงจาก string -> DateTime
        const thaiMonths = [
          '',
          'มกราคม',
          'กุมภาพันธ์',
          'มีนาคม',
          'เมษายน',
          'พฤษภาคม',
          'มิถุนายน',
          'กรกฎาคม',
          'สิงหาคม',
          'กันยายน',
          'ตุลาคม',
          'พฤศจิกายน',
          'ธันวาคม',
        ];

        final day = dt.day.toString().padLeft(2, '0');
        final monthName = thaiMonths[dt.month];
        final yearBE = dt.year + 543;

        return '$day เดือน $monthName พ.ศ. $yearBE';
      } catch (e) {
        return input; // ถ้า parse ไม่ได้ คืนค่าตามเดิม
      }
    }

///////////////////////------------------------------------------------->
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginBottom: 80.00,
          marginLeft: 60.00, //18
          marginRight: 60.00, //18
          marginTop: 80.00,
        ),
        footer: (context) {
          final text = _footerLabel(context.pageNumber);
          if (text.isEmpty) return pw.SizedBox();

          return pw.Container(
            alignment: pw.Alignment.centerRight,
            padding: const pw.EdgeInsets.only(top: 8),
            child: pw.Text(
              text,
              style: pw.TextStyle(
                font: ttf,
                fontSize: 14,
                color: PdfColors.black,
                fontWeight: pw.FontWeight.bold,
              ),
              textAlign: pw.TextAlign.right,
            ),
          );
        },
        build: (context) {
          return [
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                Textx(
                  value: 'เอกสารแนบท้ายสัญญาหมายเลข 1',
                  font: ttf,
                ),
              ],
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Row(
              children: [
                Textx(
                    value: '            อ้างถึงหนังสือสัญญาเช่าพื้นที่ เลขที่',
                    font: ttf),
                pw.Container(
                  child: labeledLine1(
                    flex: 1,
                    value: (() {
                      final data = contractPhotoModels[0].sub_cid;
                      if (data == null || data.toString().isEmpty) return '-';
                      try {
                        final decoded = jsonDecode(data);
                        final lease = decoded['lease']?.toString() ?? '';
                        return lease.isNotEmpty ? lease : '-';
                      } catch (e) {
                        // JSON พัง / decode ไม่ได้
                        return '-';
                      }
                    })(),
                    font: ttf,
                  ),
                ),
                Textx(value: 'ฉบับลงวันที่', font: ttf),
                pw.Container(
                  child: labeledLine1(
                    flex: 1,
                    value:
                        // '-', // วันที่ชำระภาษีอากร??  value: formatThaiDate(Datex_text.text),
                        // formatThaiDate_y(contractPhotoModels[0].datex),
                        formatThaiDate(Datex_text.text),
                    font: ttf,
                  ),
                ),
                Textx(value: 'ระหว่าง', font: ttf),
              ],
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Row(
              children: [
                pw.Container(
                  width: 60,
                  height: 80,
                  // color: PdfColors.grey300,
                  child: pw.Text(
                    '"ผู้ให้เช่า"',
                    style: pw.TextStyle(
                      fontSize: 14,
                      font: ttf,
                      color: Colors_pd,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Container(
                  // color: PdfColors.green200,
                  width: 410, //480
                  height: 80,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(children: [
                        Textx(
                          value:
                              'บริษัท นิ่มซิตี้ เดลี่ จำกัด โดยดร.ปราณี สุวิทย์ศักดานนท์ และนายชวลิต สุวิทย์ศักดานนท์ กรรมการซึ่งลงชื่อผูกพัน',
                          font: ttf,
                        ),
                      ]),
                      pw.Row(children: [
                        Textx(
                          value:
                              'บริษัทฯได้ สำนักงานแห่งใหญ่ตั้งอยู่ที่เลขที่ 197,199/8-9 ถนนมหิดล ตำบลหายยา  อำเภอเมืองเชียงใหม่  จังหวัด',
                          font: ttf,
                        ),
                      ]),
                      pw.Row(children: [
                        Textx(
                          value:
                              'เชียงใหม่   50100   ทะเบียน   นิติบุคคล   เลขที่ 0-5055-55010-14-7   ซึ่งต่อไปในสัญญานี้เรียกว่า  ‘‘ผู้ให้เช่า’’',
                          font: ttf,
                        ),
                      ]),
                      pw.Row(children: [
                        Textx(
                          value: 'ฝ่ายหนึ่ง กับ',
                          font: ttf,
                        ),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
            pw.Row(
              children: [
                pw.Container(
                  width: 60,
                  height: 80,
                  // color: PdfColors.grey300,
                  child: pw.Text(
                    '"ผู้เช่า"',
                    style: pw.TextStyle(
                      fontSize: 14,
                      font: ttf,
                      color: Colors_pd,
                    ),
                  ),
                ),
                pw.Container(
                  width: 410,
                  height: 80,
                  // color: PdfColors.grey200,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(children: [
                        labeledLine1(
                          value: (_verticalGroupValue == 'องค์กร/นิติบุคคล')
                              ? '$Form_bussshop โดย $Form_bussscontact'
                              : '$Form_bussshop',
                          font: ttf,
                          flex: 2,
                        ),
                        Textx(
                          value: (_verticalGroupValue == 'องค์กร/นิติบุคคล')
                              ? ' กรรมการซึ่งลงชื่อผูกพันบริษัทฯได้ สำนักงานแห่งใหญ่'
                              : ' ผู้มีอำนาจลงนามสัญญา สำนักงานแห่งใหญ่',
                          font: ttf,
                        ),
                      ]),
                      pw.Row(children: [
                        Textxx(
                          value: 'ตั้งอยู่ที่เลขที่ ',
                          font: ttf,
                        ),
                        labeledLine1(
                          value: '$Form_address',
                          font: ttf,
                          flex: 2,
                        ),
                      ]),
                      pw.Row(
                        children: [
                          Textxx(
                            value:
                                'ทะเบียนนิติบุคคล/บัตรประจำตัวประชาชนเลขที่ ',
                            font: ttf,
                          ),
                          labeledLine1(
                            flex: 1,
                            value: '$Form_tax',
                            font: ttf,
                          ),
                          Textxx(
                            value: ' ซึ่งต่อไปในสัญญานี้เรียกว่า',
                            font: ttf,
                          ),
                        ],
                      ),
                      pw.Row(
                        children: [
                          Textxx(
                            value: '‘‘ผู้เช่า’’ อีกฝ่ายหนึ่ง',
                            font: ttf,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Column(
              children: [
                pw.Row(children: [
                  Textx(
                      value:
                          'ตามที่คู่สัญญาทั้งสองฝ่าย    ได้ตกลงทำสัญญาเช่าพื้นที่   และได้กำหนดระยะเวลาอายุสัญญา   การเช่าพื้นที่ใน   ศูนย์การค้านิ่มซิตี้',
                      font: ttf),
                ]),
                pw.Row(children: [
                  labeledLine1(flex: 1, value: 'โซน $Form_zn', font: ttf),
                  Textx(value: 'ณ พื้นที่ห้อง ', font: ttf),
                  labeledLine1(flex: 1, value: '$Form_ln', font: ttf),
                  Textx(value: 'รวมขนาดพื้นที่จำนวน', font: ttf),
                  labeledLine1(
                    flex: 1,
                    value:
                        '$Form_area ( ${thaiIntegerFromAmount(double.tryParse(Form_area) ?? 0.00)} )',
                    font: ttf,
                  ),
                  Textx(value: 'ตารางเมตร ซึ่งตั้งอยู่', font: ttf),
                ]),
                pw.Row(children: [
                  Textx(
                      value:
                          ' 199/8 ถนนมหิดล ตำบลหายยา อำเภอเมืองเชียงใหม่ จังหวัดเชียงใหม่ 50100 เริ่มตั้งแต่วันที่',
                      font: ttf),
                  labeledLine1(
                    flex: 1,
                    value: '${formatThaiDate(Form_sdate)}',
                    font: ttf,
                  ),
                ]),
                pw.Row(children: [
                  Textx(value: 'ถึงวันที่', font: ttf),
                  labeledLine1(
                    flex: 1,
                    value: '${formatThaiDate(Form_ldate)}',
                    font: ttf,
                  ),
                  Textx(
                      value: 'รายละเอียดปรากฏตามหนังสือสัญญาเช่าพื้นที่เลขที่',
                      font: ttf),
                  labeledLine1(
                    flex: 1,
                    value: (() {
                      final data = contractPhotoModels[0].sub_cid;
                      if (data == null || data.toString().isEmpty) return '-';
                      try {
                        final decoded = jsonDecode(data);
                        final lease = decoded['lease']?.toString() ?? '';
                        return lease.isNotEmpty ? lease : '-';
                      } catch (e) {
                        // JSON พัง / decode ไม่ได้
                        return '-';
                      }
                    })(),
                    font: ttf,
                  ),
                ]),
                pw.Row(children: [
                  Textx(value: 'ฉบับลงวันที่', font: ttf),
                  labeledLine1(
                    flex: 1,
                    value:
                        // '-', // วันที่ชำระภาษีอากร??  value: formatThaiDate(Datex_text.text),
                        // formatThaiDate_y(contractPhotoModels[0].datex),
                        formatThaiDate(Datex_text.text),
                    font: ttf,
                  ),
                  Textx(
                      value:
                          'ที่อ้างถึงข้างต้น (ซึ่งคู่สัญญาทั้งสองฝ่ายได้อ่านและเข้าใจสัญญาโดยตลอดแล้วนั้น)',
                      font: ttf),
                ]),
              ],
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Row(children: [
              Textx(
                  value:
                      '            คู่สัญญาทั้งสองฝ่ายได้ตกลงทำเอกสารแนบท้ายฉบับนี้ขึ้น  เพื่อเป็นหลักฐานสำคัญว่า  เอกสารแนบท้ายสัญญาหมายเลข 1',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(value: 'ประกอบด้วย เอกสารดังต่อไปนี้', font: ttf),
            ]),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Row(children: [
              pw.Container(
                width: 12 * PdfPageFormat.mm,
              ),
              pw.Container(
                child: labeledLine(
                    value: 'แบบแปลนพื้นที่สถานที่เช่า', font: ttf, flex: 2),
              ),
            ]),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Container(
              child: (photo_pic_plan != null)
                  ? pw.Image(
                      pw.MemoryImage(photo_pic_plan),
                      height: 300,
                      width: 480,
                      fit: pw.BoxFit.contain,
                    )
                  : pw.Container(
                      color: PdfColors.white,
                      height: 300,
                      width: 480,
                    ),
            ),
            pw.NewPage(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [Textx(value: '/  รูปถ่ายสถานที่..', font: ttf)],
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Row(children: [
              pw.Container(
                width: 12 * PdfPageFormat.mm,
              ),
              pw.Container(
                child: labeledLine(
                    value: 'รูปถ่ายสถานที่เช่าจริง', font: ttf, flex: 2),
              ),
            ]),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Container(
              child: (photo_pic_shop != null)
                  ? pw.Image(
                      pw.MemoryImage(photo_pic_shop),
                      height: 300,
                      width: 480,
                      fit: pw.BoxFit.contain,
                    )
                  : pw.Container(
                      color: PdfColors.white,
                      height: 300,
                      width: 480,
                    ),
            ),
            pw.NewPage(),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            เอกสารแนบท้ายสัญญาฉบับนี้ทำขึ้นเป็น  2  ฉบับ  มีข้อความถูกต้องตรงกัน  คู่สัญญาทั้งสองฝ่ายได้อ่านและเข้าใจข้อความ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ในสัญญา นี้เป็นอย่างดี เห็นว่าเป็นที่ถูกต้อง ครบถ้วน เรียบร้อย ตรงตามเจตนาทุกประการ ปราศจากการบังคับ ขู่เข็ญ หรือสำคัญผิด',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'แต่อย่างใด คู่สัญญามีสติสัมปชัญญะครบถ้วนสมบูรณ์ทุกประการ  จึงได้ลงลายมือชื่อ/พิมพ์ลายนิ้วมือ และตราประทับ(ถ้ามี) เป็นของ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ผู้ให้บริการ และผู้รับบริการจริง ไว้เป็นสำคัญต่อหน้าพยาน ในวัน และ ณ สถานที่ดังกล่าวข้างต้น',
                    font: ttf),
              ]),
            ]),
            pw.SizedBox(height: 16 * PdfPageFormat.mm),
            pw.Row(
              children: [
                // คอลัมน์ซ้าย 30% (จะโล่ง ๆ ไม่ใส่เนื้อหาอะไร)
                pw.Expanded(
                  flex: 2, // ใช้ 3 ส่วนจากทั้งหมด 10 ส่วน
                  child: pw.Container(
                      // พื้นที่ฝั่งซ้ายไม่ใส่เนื้อหา

                      ),
                ),

                // คอลัมน์ขวา 70%
                pw.Expanded(
                  flex: 8, // ใช้ 7 ส่วนจากทั้งหมด 10 ส่วน
                  child: pw.Column(
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          Textx(
                              value:
                                  'ลงชื่อ..................................................................................................................ผู้ให้เช่า',
                              font: ttf),
                          pw.SizedBox(height: 2 * PdfPageFormat.mm),
                          // pw.Text(
                          //   (FormName3_choice == null ||
                          //           FormName3_choice.toString() == '')
                          //       ? '(___________________________) '
                          //       : '( $FormName3_choice ) ',
                          //   textAlign: pw.TextAlign.justify,
                          //   style: pw.TextStyle(
                          //     color: Colors_pd,
                          //     fontSize: font_Size,
                          //     font: ttf,
                          //     fontWeight: pw.FontWeight.bold,
                          //   ),
                          // ),
                          Textx(
                              value: 'บริษัท นิ่มซิตี้ เดลี่ จำกัด', font: ttf),
                          Textx(
                              value:
                                  'โดยดร.ปราณี สุวิทย์ศักดานนท์ และนายชวลิต สุวิทย์ศักดานนท์',
                              font: ttf),
                          Textx(
                              value: 'กรรมการซึ่งลงชื่อผูกพันบริษัทฯ ได้',
                              font: ttf),
                        ],
                      ),
                      pw.SizedBox(height: 10 * PdfPageFormat.mm),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          Textx(
                              value:
                                  'ลงชื่อ..................................................................................................................ผู้เช่า',
                              font: ttf),
                          pw.SizedBox(height: 2 * PdfPageFormat.mm),
                          Textx(
                            value: (Form_bussshop == null ||
                                    Form_bussshop.toString() == '')
                                ? '(.............................................................................................) '
                                : (_verticalGroupValue == 'องค์กร/นิติบุคคล')
                                    ? '$Form_bussshop โดย $Form_bussscontact'
                                    : '$Form_bussshop',
                            font: ttf,
                          ),
                          pw.SizedBox(height: 2 * PdfPageFormat.mm),
                          Textx(
                              value: (_verticalGroupValue == 'องค์กร/นิติบุคคล')
                                  ? 'กรรมการซึ่งลงชื่อผูกพันบริษัทฯ ได้'
                                  : 'ผู้มีอำนาจลงนามสัญญา',
                              font: ttf),
                        ],
                      ),
                      pw.SizedBox(height: 10 * PdfPageFormat.mm),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          Textx(
                              value:
                                  'ลงชื่อ..................................................................................................................พยาน',
                              font: ttf),
                          pw.SizedBox(height: 2 * PdfPageFormat.mm),
                          Textx(
                              value: '(     นางสาวกัลยา บัวระวงค์     )',
                              font: ttf),
                        ],
                      ),
                      pw.SizedBox(height: 10 * PdfPageFormat.mm),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          Textx(
                              value:
                                  'ลงชื่อ..................................................................................................................พยาน',
                              font: ttf),
                          pw.SizedBox(height: 2 * PdfPageFormat.mm),
                          Textx(
                              value: '(    นางสาวอังคณา ใจยาบุตร     )',
                              font: ttf),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ];
        },
        // footer: (context) {
        //   return pw.Column(
        //     mainAxisSize: pw.MainAxisSize.min,
        //     children: [
        //       pw.Align(
        //         alignment: pw.Alignment.bottomRight,
        //         child: pw.Text(
        //           'หน้า ${context.pageNumber} / ${context.pagesCount} ',
        //           textAlign: pw.TextAlign.left,
        //           style: pw.TextStyle(
        //             fontSize: 10,
        //             font: ttf,
        //             color: Colors_pd,
        //             // fontWeight: pw.FontWeight.bold
        //           ),
        //         ),
        //       )
        //     ],
        //   );
        // },
      ),
    ); // final bytes = await pdf.save();
///////////////////////------------------------------------------------->

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RentalInforman_Agreement(
            doc: pdf,
            context: context,
            ////////////------------------->
            ///
            // Get_Value_NameShop_index: Get_Value_NameShop_index,
            // Get_Value_cid: Get_Value_cid,
            // verticalGroupValue: _verticalGroupValue,
            // Form_nameshop: Form_nameshop,
            // Form_typeshop: Form_typeshop,
            // Form_bussshop: Form_bussshop,
            // Form_bussscontact: Form_bussscontact,
            // Form_address: Form_address,
            // Form_tel: Form_tel,
            // Form_email: Form_email,
            // Form_tax: Form_tax,
            // Form_ln: Form_ln,
            // Form_zn: Form_zn,
            // Form_area: Form_area,
            // Form_qty: Form_qty,
            // Form_sdate: Form_sdate,
            // Form_ldate: Form_ldate,
            // Form_period: Form_period,
            // Form_rtname: Form_rtname,
            // quotxSelectModels: quotxSelectModels,
            // TransModels: _TransModels,
            // renTal_name: renTal_name,
            // bill_addr: bill_addr,
            // bill_email: bill_email,
            // bill_tel: bill_tel,
            // bill_tax: bill_tax,
            // bill_name: bill_name,
            // newValuePDFimg: newValuePDFimg,
          ),
        ));
  }
}

// 1) ฟังก์ชันคืนข้อความ footer ตามหมายเลขหน้า
String _footerLabel(int page) {
  switch (page) {
    case 1:
      return '';
    case 2:
      return '/ เอกสารแนบท้าย..';
    default:
      return ''; // หน้าอื่นไม่แสดงข้อความ (หรือจะใส่ default text ก็ได้)
  }
}
