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

import '../../Man_PDF/Preview_PDF/Preview_Agreement.dart';
import '../../PeopleChao/Rental_Information.dart';
import '../../Style/ThaiBaht.dart';
import '../../Style/loadAndCacheImage.dart';

class Pdfgen_Agreementnim1 {
//////////---------------------------------------------------->( **** เอกสารสัญญาเช่าอาคารนิ่ม  )

  static void exportPDF_Agreementnim1(
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
    //// ------------>(สัญญาเช่าอาคาร)

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
    var nFormat2 = NumberFormat("#0", "en_US");
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

    // double total_1 = 0.00;
    // for (int index = 0; index < quotxSelectModels.length; index++) {
    //   total_1 = double.tryParse(
    //           quotxSelectModels[index].total?.toString() ?? "0.00") ??
    //       0.00;
    // } // มั่ว ยอดชำระค่าเช่าเดือนละ

    final filteredListchao = quotxSelectModels
        .where(
            (item) => (item.dtype ?? '').trim() == "KR" && item.expser == '1')
        .toList();
    final totalchao = nFormat.format((filteredListchao.fold<double>(
      0.00,
      (double sum, dynamic item) =>
          sum + (item.pvat != null ? double.parse(item.pvat!) : 0.00),
    ))); // ค่าเช่า เดือนละ

    final filteredListpakan = quotxSelectModels
        .where((item) => (item.dtype ?? '').trim() == "KD")
        .toList();
    final totalpakan = nFormat.format((filteredListpakan.fold<double>(
      0.00,
      (double sum, dynamic item) =>
          sum + (item.pvat != null ? double.parse(item.pvat!) : 0.00),
    ))); // ค่าประกันเดือนละ

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
    } // ' ' * 2 + value + ' ' * 2,

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

    String formatThaiTime(String timeStr) {
      try {
        // แยกเฉพาะ ชั่วโมง:นาที จาก string เช่น "18:00:00"
        final parts = timeStr.split(':');
        if (parts.length >= 2) {
          final hour = parts[0].padLeft(2, '0');
          final minute = parts[1].padLeft(2, '0');
          return '$hour:$minute น.';
        }
        return timeStr;
      } catch (e) {
        return timeStr;
      }
    }

    String getThaiOpenDays(Map<String, dynamic> days) {
      // mapping ไทย
      const dayNames = [
        'วันจันทร์',
        'วันอังคาร',
        'วันพุธ',
        'วันพฤหัสบดี',
        'วันศุกร์',
        'วันเสาร์',
        'วันอาทิตย์',
      ];

      // เอาเฉพาะวันที่เปิด (0 = เปิด, 1 = ปิด)
      final openDays = <int>[];
      for (int i = 1; i <= 7; i++) {
        final val = days['d$i']?.toString() ?? '1';
        if (val == '0') openDays.add(i);
      }

      if (openDays.isEmpty) return '-'; // ไม่มีวันเปิดเลย

      // ถ้าทุกวันเปิด
      if (openDays.length == 7) return 'วันจันทร์ ถึง วันอาทิตย์';

      // ถ้าเปิดเรียงกันต่อเนื่อง
      if (openDays.length > 1 &&
          openDays.last - openDays.first == openDays.length - 1) {
        return '${dayNames[openDays.first - 1]} ถึง ${dayNames[openDays.last - 1]}';
      }

      // ถ้าเปิดแบบไม่เรียง เช่น จันทร์ พุธ ศุกร์
      final dayList = openDays.map((i) => dayNames[i - 1]).toList().join(', ');
      return dayList;
    }

    final days = {
      'd1': contractPhotoModels[0].d1,
      'd2': contractPhotoModels[0].d2,
      'd3': contractPhotoModels[0].d3,
      'd4': contractPhotoModels[0].d4,
      'd5': contractPhotoModels[0].d5,
      'd6': contractPhotoModels[0].d6,
      'd7': contractPhotoModels[0].d7,
    };

///////////////////////------------------------------------------------->
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginBottom: 80.00,
          marginLeft: 60.00, //18
          marginRight: 60.00, //18
          marginTop: 80.00,
        ),
        header: (context) {
          return pw.Column(children: []);
        },
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
                  value: 'สัญญาเช่าอาคาร',
                  font: ttf,
                  // fontWeight: pw.FontWeight.bold,
                ),
              ],
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                Textx(value: 'สัญญาเลขที่ ', font: ttf),
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
              ],
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  Textxx(
                      value:
                          '            สัญญาฉบับนี้ทำขึ้นที่ บริษัท นิ่มซิตี้ เดลี่ จำกัด ที่อยู่ 197,199/8-9 ถนนมหิดล  ตำบลหายยา อำเภอเมืองเชียงใหม่จังหวัด',
                      font: ttf),
                  pw.Row(children: [
                    Textx(
                      value: 'เชียงใหม่ 50100 เมื่อวันที่ ',
                      font: ttf,
                    ),
                    pw.Container(
                      child: labeledLine1(
                        flex: 1,
                        value:
                            // '-', // วันที่ชำระภาษีอากร??  value: formatThaiDate(Datex_text.text),
                            // formatThaiDate_y(contractPhotoModels[0].datex),
                            formatThaiDate(Datex_text.text),
                        font: ttf,
                      ),
                    )
                  ]),
                ]),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            Textx(
              value:
                  'หนังสือสัญญาฉบับนี้ทำขึ้นพร้อมด้วยผู้รู้เห็นเป็นพยานระหว่าง',
              font: ttf,
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
            // pw.SizedBox(height: 2 * PdfPageFormat.mm),
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
                          value: '$Form_bussshop โดย $Form_bussscontact',
                          font: ttf,
                          flex: 2,
                        ),
                        Textxx(
                          value:
                              ' กรรมการซึ่งลงชื่อผูกพันบริษัทฯได้ สำนักงานแห่งใหญ่',
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
            Textx(
              value:
                  '            โดยผู้ให้เช่ามีความประสงค์ที่จะแบ่งพื้นที่บางส่วนของศูนย์การค้านิ่มซิตี้ ให้ผู้เช่าทำการเช่า และโดยที่ผู้เช่ามีความประสงค์',
              font: ttf,
            ),
            Textx(value: 'ที่จะเช่า', font: ttf),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            Textx(
                value:
                    '            ทั้งสองฝ่ายจึงตกลงทำสัญญาเช่ากันมีข้อความ เงื่อนไขและรายละเอียด ดังต่อไปนี้',
                font: ttf),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            Textx(value: '            ข้อ 1) สถานที่เช่า', font: ttf),
            pw.Column(
              children: [
                pw.Row(
                  children: [
                    Textx(
                      value:
                          '            ผู้ให้เช่าตกลงให้เช่าและผู้เช่าตกลงเช่าพื้นที่บางส่วน ณ พื้นที่เลขที่ ',
                      font: ttf,
                    ),
                    labeledLine1(
                      flex: 1,
                      value: '$Form_ln',
                      font: ttf,
                    ),
                    Textx(
                      value: ' รวมจำนวนพื้นที่ให้เช่าทั้งสิ้นประมาณ',
                      font: ttf,
                    ),
                  ],
                ),
                pw.Row(children: [
                  labeledLine1(
                    flex: 1,
                    value:
                        '$Form_area ( ${thaiIntegerFromAmount(double.tryParse(Form_area) ?? 0.00)} )',
                    font: ttf,
                  ),
                  Textx(
                    value: 'ตารางเมตร ในศูนย์การค้านิ่มซิตี้',
                    font: ttf,
                  ),
                  labeledLine1(
                    flex: 1,
                    value: ' โซน $Form_zn',
                    font: ttf,
                  ),
                  Textx(
                    value: 'ซึ่งตั้งอยู่',
                    font: ttf,
                  ),
                  Textx(
                    value: ' 197 ถนนมหิดล ตำบลหายยา',
                    font: ttf,
                  ),
                ]),
                pw.Row(children: [
                  Textx(
                    value:
                        'อำเภอเมืองเชียงใหม่   จังหวัดเชียงใหม่   50100  ( รายละเอียดปรากฏตาม เอกสารแนบท้าย สัญญาหมายเลข 1 และให้ถือเป็นส่วน',
                    font: ttf,
                  ),
                ]),
                pw.Row(children: [
                  Textx(
                    value:
                        'หนึ่งของสัญญาฉบับนี้ด้วย ) ซึ่งต่อไปในสัญญานี้รวมเรียกว่า ‘‘สถานที่เช่า’’ เพื่อประกอบกิจการ ',
                    font: ttf,
                  ),
                  labeledLine1(
                    flex: 1,
                    value: '$Form_typeshop',
                    font: ttf,
                  ),
                ]),
                pw.Row(children: [
                  Textx(
                    value: 'ชื่อร้านค้า',
                    font: ttf,
                  ),
                  labeledLine1(
                    flex: 1,
                    value: (Form_nameshop == null ||
                            Form_nameshop.toString() == 'null')
                        ? "$Form_bussshop"
                        : "$Form_nameshop",
                    font: ttf,
                  ),
                  Textx(
                    value:
                        'ยี่ห้อสินค้า - ซึ่งผู้เช่าเป็นผู้มีสิทธิที่จะใช้ยี่ห้อสินค้าดังกล่าวอย่างถูกต้องตามกฎหมาย',
                    font: ttf,
                  ),
                ]),
                pw.Row(children: [
                  Textx(value: 'โดยระยะเวลาการเช่ามีกำหนด', font: ttf),
                  pw.Container(
                    child: labeledLine1(
                      flex: 1,
                      value: '$Form_period',
                      font: ttf,
                    ),
                  ),
                  Textx(
                      value: (Form_rtname.toString() == 'รายวัน')
                          ? 'วัน '
                          : (Form_rtname.toString() == 'รายเดือน')
                              ? 'เดือน '
                              : (Form_rtname.toString() == 'รายปี')
                                  ? 'ปี '
                                  : '$Form_rtname ',
                      font: ttf),
                  Textx(value: ' ตั้งแต่วันที่', font: ttf),
                  labeledLine1(
                    flex: 1,
                    value: '${formatThaiDate(Form_sdate)}',
                    font: ttf,
                  ),
                  Textx(value: ' ถึงวันที่ ', font: ttf),
                  labeledLine1(
                    flex: 1,
                    value: '${formatThaiDate(Form_ldate)}',
                    font: ttf,
                  ),
                ]),
              ],
            ),

            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            Textx(value: '            ข้อ 2) ค่าเช่าและ เงินประกัน', font: ttf),
            Textx(value: '            2.1 ค่าเช่า ', font: ttf),
            pw.Row(children: [
              Textx(
                value:
                    '            ผู้เช่าตกลงชำระค่าเช่าแก่ผู้ให้เช่าในอัตราเดือนละ',
                font: ttf,
              ),
              labeledLine1(
                flex: 1,
                value:
                    '$totalchao บาท(${convertToThaiBaht(double.tryParse(totalchao.replaceAll(',', '')) ?? 0.00)})',
                font: ttf,
              ),
            ]),
            Textxx(
              value:
                  'สำหรับการพิจารณาทบทวนอัตราค่าเช่าที่เรียกเก็บตามสัญญานี้ คู่สัญญาทั้งสองฝ่ายตกลงรับทราบว่า อาจเปลี่ยนแปลงได้ตามความ เหมาะสม โดยตกลงกันเป็นลายลักษณ์อักษรก่อนระยะเวลาที่จะมีการเรียกเก็บ และเมื่อมีการตกลงเปลี่ยนแปลงเป็นประการใดให้ถือ บันทึกข้อตกลงดังกล่าวเป็น ส่วนหนึ่งของสัญญาฉบับนี้',
              font: ttf,
            ),
            Textx(
                value:
                    '            อนึ่ง ผู้เช่ายินยอมให้ผู้ให้เช่าขึ้นค่าเช่าได้ทุกปีในอัตราขั้นต่ำ ร้อยละ 15 (สิบห้า) และไม่เกิน ร้อยละ 40 (สี่สิบ) ต่อปีของค่า เช่าในขณะนั้น',
                font: ttf),

            pw.NewPage(),
            ///////////////////--------> (page 2)
            Textx(value: '            2.2 เงินประกันและค่าใช้จ่าย', font: ttf),
            Textx(
              value:
                  '            ผู้เช่าตกลงทำการวางเงินเพื่อเป็นประกันการชำระค่าเช่า, ค่าบริการ, สาธารณูปโภค และประกันความเสียหายทรัพย์สินไว้',
              font: ttf,
            ),
            pw.Row(
              children: [
                Textx(
                  value: 'ต่อผู้ให้เช่าเป็นเงินจำนวน',
                  font: ttf,
                ),
                labeledLine1(
                  flex: 1,
                  value:
                      '$totalpakan บาท(${convertToThaiBaht(double.tryParse(totalpakan.replaceAll(',', '')) ?? 0.00)})',
                  font: ttf,
                ),
                Textx(
                  value: 'ผู้เช่าตกลงชำระเงินประกัน',
                  font: ttf,
                ),
              ],
            ),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                  value:
                      'ดังกล่าวให้ครบถ้วนก่อนกำหนดการรับมอบสถานที่เช่า  โดยเมื่อสัญญาสิ้นสุดลง เพราะครบกำหนดระยะเวลาการเช่า  หรือไม่ว่าด้วย',
                  font: ttf,
                ),
              ]),
              pw.Row(children: [
                Textx(
                  value:
                      'เหตุใดก็ตามซึ่งมิใช่ความผิดของผู้เช่า  และผู้ให้เช่าได้ทำการตรวจสอบทรัพย์สินที่เช่าแล้วมิได้เกิดความเสียหายใดทั้งสิ้นผู้ให้เช่าจะทำ',
                  font: ttf,
                ),
              ]),
              pw.Row(children: [
                Textx(
                  value:
                      'การชำระคืนเงินประกันการเช่าดังกล่าวให้แก่ผู้เช่าภายในกำหนดเวลา 30(สามสิบ) วันนับแต่ผู้เช่าได้ขนย้ายทรัพย์สิน และบริวารออก',
                  font: ttf,
                ),
              ]),
              pw.Row(children: [
                Textx(
                  value:
                      'จากทรัพย์สินที่เช่าและส่งมอบสถานที่เช่าคืนให้แก่ผู้ให้เช่า  ทั้งนี้ผู้เช่าจะต้องไม่ค้างชำระค่าเช่า หรือค้างชำระหนี้อื่นใดแก่ผู้ให้เช่าตาม',
                  font: ttf,
                ),
              ]),
              pw.Row(children: [
                Textx(
                  value:
                      'สัญญานี้ในกรณีที่ผู้เช่าติดค้างชำระค่าเช่า  หรือหนี้สินอื่นใดที่ต้องชำระให้แก่ผู้ให้เช่า รวมถึงค่าชดเชยรายได้อันเกิดจากการที่ผู้เช่าทำ',
                  font: ttf,
                ),
              ]),
              pw.Row(children: [
                Textx(
                  value:
                      'การบอกเลิกสัญญา  ก่อนครบกำหนดสัญญาเช่า ผู้เช่าตกลงยินยอมให้ผู้ให้เช่ามีสิทธิในการหักชำระหนี้  และเงินชดเชยรายได้จากเงิน',
                  font: ttf,
                ),
              ]),
              pw.Row(children: [
                Textx(
                  value:
                      'ประกันดังกล่าวของผู้เช่าได้หากเงินประกันนี้ ไม่พอ เพียงกับหนี้ที่ค้างชำระคงขาดอยู่เท่าใดผู้เช่าตกลงทำการนำเงินมาชำระให้แก่ผู้ให้',
                  font: ttf,
                ),
              ]),
              pw.Row(children: [
                Textx(
                  value: 'เช่าจนครบจำนวนมูลหนี้นั้น ๆ',
                  font: ttf,
                ),
              ]),
            ]),

            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                  value:
                      '            ภายใต้ข้อสัญญาในวรรคก่อน เมื่อการเช่าสิ้นสุดลง ถ้าปรากฏว่าทรัพย์สินที่เช่าได้รับความเสียหาย เนื่องจากการกระทำของ',
                  font: ttf,
                ),
              ]),
              pw.Row(children: [
                Textx(
                  value:
                      'ผู้เช่า และหรือบริวารของ ผู้เช่าและผู้เช่ามิได้จัดการซ่อมแซมให้คืนดีอยู่ในสภาพเดิม ผู้ให้เช่ามีสิทธิยึดเงินประกันนี้ไว้ เป็นค่าซ่อมแซม',
                  font: ttf,
                ),
              ]),
              pw.Row(children: [
                Textx(
                  value:
                      'ทรัพย์สินที่เช่า และค่าเสียหายใดๆ อันเกิดจาก ผู้เช่ารวมทั้งค่าใช้จ่ายในการให้บริการวิชาชีพทางกฎหมาย ตามความเสียหายที่เกิดขึ้น',
                  font: ttf,
                ),
              ]),
              pw.Row(children: [
                Textx(
                  value:
                      'เงินประกันคงเหลือเท่าใดจึงคืนให้แก่ผู้เช่าไป หากเงินประกันนี้ ไม่พอ กับค่าใช้จ่ายในการซ่อมแซม ผู้เช่ารับว่าจะดำเนินการ ชำระเงิน',
                  font: ttf,
                ),
              ]),
              pw.Row(children: [
                Textx(
                  value: 'ส่วนที่ขาดให้แก่ผู้ให้เช่าจนครบจำนวนค่าซ่อมแซมนั้น ๆ',
                  font: ttf,
                ),
              ]),
            ]),

            pw.SizedBox(height: 4 * PdfPageFormat.mm),
            Textx(value: '            ข้อ 3) การชำระค่าเช่า', font: ttf),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                  value:
                      '            3.1 ผู้เช่าจะนำค่าเช่ารายเดือนตามระบุในข้อ2  ของสัญญาเช่าฉบับนี้  ไปชำระล่วงหน้าให้แก่ผู้ให้เช่า  ณ  ภูมิลำเนาตามกฎ',
                  font: ttf,
                ),
              ]),
              pw.Row(children: [
                Textx(
                  value:
                      'หมายของผู้ให้เช่าซึ่งปรากฏ  ในสัญญาฉบับนี้ ภายในวันที่ 5 (ห้า) ของทุกเดือน   หากวันที่ 5 (ห้า)ของเดือนใดเป็นวันหยุดทำการของผู้',
                  font: ttf,
                ),
              ]),
              pw.Row(children: [
                Textx(
                  value:
                      'ให้เช่าก็ให้ถือเอาวันทำการถัดไปแทน  โดยวิธีชำระ ผ่านบัญชี  ธนาคารกสิกรไทย จำกัด (มหาชน) สาขาถนนราชวงศ์ เชียงใหม่ ชื่อบัญ',
                  font: ttf,
                ),
              ]),
              pw.Row(children: [
                Textx(
                  value:
                      'ชี บริษัท นิ่มซิตี้ เดลี่ จำกัด เลขที่บัญชี 159-2-53964-7 หรือวิธีอื่นใดตาม ที่ผู้ให้เช่ากำหนดทั้งนี้ไม่ว่าผู้ให้เช่า จะเรียกให้ผู้เช่าชำระค่า',
                  font: ttf,
                ),
              ]),
              pw.Row(children: [
                Textx(
                  value:
                      'เช่าหรือไม่ก็ตาม และไม่ว่า ผู้เช่าจะประกอบธุรกิจในสถานที่เช่าหรือไม่ก็ตาม ให้ถือว่าผู้เช่าครอบ ครองสถานที่เช่า นับตั้งแต่วันรับมอบ',
                  font: ttf,
                ),
              ]),
              pw.Row(children: [
                Textx(
                  value:
                      'พื้นที่เช่าจนกว่าผู้เช่าจะได้ส่งมอบการครอบครองสถานที่เช่าคืนให้แก่ผู้ให้เช่าถูกต้องตามเงื่อนไขที่กำหนดโดยสัญญาเช่าฉบับนี้',
                  font: ttf,
                ),
              ]),
            ]),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                  value:
                      '            หากผู้เช่าผิดนัดชำระค่าเช่า  ผู้เช่ายินยอมชำระเบี้ยปรับให้แก่ผู้ให้เช่าในอัตราร้อยละ 2(สอง) ต่อเดือน ของจำนวนวันของจำ',
                  font: ttf,
                ),
              ]),
              pw.Row(children: [
                Textx(
                  value:
                      'นวนเงินที่ค้างชำระ โดย คำนวณตั้งแต่วันครบกำหนดชำระจนกว่าจะชำระเสร็จสิ้น และหากผู้เช่าผิดนัดให้มีผลทันที ไม่ต้องบอกกล่าว',
                  font: ttf,
                ),
              ]),
              pw.Row(children: [
                Textx(
                  value:
                      'ก่อนโดยให้ผู้เช่าดำเนินการให้แล้วเสร็จภายใน  30(สามสิบ) วัน หากเกินกว่า 30 (สามสิบ) วัน  ถือว่าผู้เช่าจงใจประพฤติผิดสัญญาเช่า',
                  font: ttf,
                ),
              ]),
              pw.Row(children: [
                Textx(
                  value:
                      'และผู้ให้เช่ามีสิทธิบอกเลิกสัญญาเช่าฉบับนี้ได้ทันที โดยผู้ให้เช่าไม่ จำเป็นต้องบอกกล่าวล่วงหน้าผู้ให้เช่ามีสิทธิระงับการให้บริการทุก',
                  font: ttf,
                ),
              ]),
              pw.Row(children: [
                Textx(
                  value:
                      'ประการแก่ผู้เช่ารวมทั้งมีสิทธิ เข้าไปในสถานที่เช่าเพื่อกระทำการใดๆ ในการรักษาสิทธิของผู้ให้เช่าผู้เช่าตกลงสละสิทธิในการฟ้องร้อง',
                  font: ttf,
                ),
              ]),
              pw.Row(children: [
                Textx(
                  value:
                      'ผู้ให้เช่า ตัวแทน หรือลูกจ้างของผู้ให้เช่าทั้งทางแพ่งและทางอาญา',
                  font: ttf,
                ),
              ]),
            ]),

            // pw.Row(
            //   mainAxisAlignment: pw.MainAxisAlignment.end,
            //   children: [
            //     Textx(value: '/   3.2 การหักภาษี..', font: ttf),
            //   ],
            // ),
            pw.NewPage(),
            ////////////////////--------> (page 3)
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            3.2 การหักภาษี ณ ที่จ่าย ในกรณีที่ กฎหมายกำหนดให้ผู้เช่ามีหน้าที่หักภาษี ณ ที่จ่ายจากเงินค่าเช่าที่ผู้เช่าดำเนินการชำระ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ให้แก่ผู้ให้เช่าตามสัญญาฉบับนี้ผู้เช่าจะต้องหักภาษีเงินได้ ณ ที่จ่ายให้ถูกต้องครบถ้วน และนำส่งต่อกรมสรรพากร ภายในระยะเวลาที่',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'กฎหมายกำหนด ในการนี้ผู้เช่าจะต้องออกหนังสือรับรองการหักภาษี ณ ที่จ่ายและส่งมอบสำเนาไว้ให้แก่ผู้ให้เช่าเพื่อเป็นหลักฐานด้วย',
                    font: ttf),
              ]),
            ]),
            pw.Row(
              children: [
                pw.Container(
                    child:
                        labeledLine(value: 'ทุกครั้งไป', font: ttf, flex: 2)),
              ],
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            Textx(
                value: '            ข้อ 4)  การส่งมอบสิทธิในสถานที่เช่า',
                font: ttf),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            ในวันนี้ ผู้ให้เช่าตกลงทำการส่งมอบสิทธิในการครอบครองทรัพย์สินที่เช่าให้กับผู้เช่าแล้วและผู้เช่าได้เข้าทำการตรวจดูทรัพย์',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'สินที่เช่าแล้วเห็นว่าทุกสิ่งอยู่ในสภาพเรียบร้อยและเป็นปกติที่ผู้เช่าจะได้รับประโยชน์หรือจะได้ใช้ตามวัตถุประสงค์แห่งการเช่านี้ทุกประ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'การแล้วจึงได้ทำการรับมอบการครอบครอง ทรัพย์สินที่เช่าไปในวันและเวลาเดียวกัน',
                    font: ttf),
              ]),
            ]),

            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            Textx(
                value: '            ข้อ 5) การใช้ประโยชน์ในสถานที่เช่า',
                font: ttf),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            5.1  ผู้เช่าตกลงใช้สถานที่เช่าเพื่อวัตถุประสงค์ในการประกอบกิจการค้า เฉพาะประเภทที่ได้ระบุไว้ใน ข้อ 1. ของสัญญาเช่า',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ฉบับนี้เท่านั้น  หากผู้เช่า  ประสงค์จะเปลี่ยนแปลงประเภทกิจการค้า  ชื่อร้านค้าหรือยี่ห้อสินค้า  ผู้เช่าต้องทำการแจ้งให้ผู้ให้เช่าทราบ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ล่วงหน้าไม่น้อยกว่า 30 (สามสิบ) วันและจะดำเนินการเปลี่ยนแปลงได้ต่อเมื่อได้รับความยินยอมเป็นลายลักษณ์อักษรจากผู้ให้เช่าแล้ว',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'เท่านั้น ทั้งนี้หากผู้เช่าฝ่าฝืนให้ถือว่าสัญญาเช่าฉบับนี้ เป็นอันสิ้นสุด ยุติลงทันทีโดยผู้ให้เช่า ไม่จำต้องทำการบอกกล่าวให้แก่ผู้เช่าทราบ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(value: 'แต่อย่างใด', font: ttf),
              ]),
            ]),

            Textxx(
                value:
                    '            5.2 ผู้เช่าสัญญาว่าจะดำเนินกิจการตามวัตถุประสงค์ที่ได้ระบุไว้ในสัญญาเช่าตลอดเวลาที่ศูนย์การค้านิ่มซิตี้ เปิดดำเนินการ',
                font: ttf),
            pw.Row(
              children: [
                Textx(
                  value: 'และเปิดให้บริการ ',
                  font: ttf,
                ),
                labeledLine1(
                  flex: 1,
                  // value:
                  //     'ตั้งแต่เวลา ${contractPhotoModels[0].stime} - ${contractPhotoModels[0].ltime}',
                  value:
                      '${getThaiOpenDays(days)} ตั้งแต่เวลา ${formatThaiTime(contractPhotoModels[0].stime)} - ${formatThaiTime(contractPhotoModels[0].ltime)}',
                  font: ttf,
                ),
                Textx(
                    value: 'โดยประกอบกิจการดังกล่าวต่อเนื่องกันไปตลอด',
                    font: ttf)
              ],
            ),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        'ระยะเวลาเช่าโดยไม่มีวันหยุด เว้นแต่ได้รับอนุญาตเป็นหนังสือจากผู้ให้เช่าก่อน หากผู้เช่าละทิ้งสถานที่เช่า ให้อยู่ในลักษณะปราศจาก',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'การประกอบกิจการหรือการครอบครองดูแลของผู้เช่าหรือ  บริวารอันแท้จริงของผู้เช่าไม่ว่าเวลาใดๆ  เป็นระยะเวลาตั้งแต่ 2 (สอง)วัน',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ต่อเดือน  ผู้เช่ายินยอมให้ผู้ให้เช่าปรับเป็นรายวันในอัตราวันละ 100 บาท(หนึ่งร้อยบาทถ้วน)  ต่อ 1(หนึ่ง)  ตารางเมตร  และหากการ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ปิดสถานที่เช่าดังกล่าวเกิดขึ้นเป็นระยะเวลากว่า 15(สิบห้า) วันติดต่อกันขึ้นไป โดยผู้เช่ามิได้แจ้งเหตุขัดข้อง หรือเหตุจำเป็นให้ผู้ให้เช่า',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ทราบเป็นหนังสือ และผู้ให้เช่าก็มิได้ให้ความยินยอมแล้วให้ถือว่าผู้เช่าได้แสดงเจตนาเลิกสัญญาเช่าฉบับนี้แล้วการปิดสถานที่เช่าโดยใส่',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'กุญแจหรือไม่ก็ตาม  ให้ถือว่าเป็นการทอดทิ้งสถานที่เช่าให้อยู่ในลักษณะปราศจากการครอบครองแล้วเช่นกัน',
                    font: ttf),
              ]),
            ]),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Row(children: [
              Textx(
                  value:
                      '            หากปรากฏว่าผู้เช่าปฏิบัติฝ่าฝืนข้อ 5.1 หรือ 5.2 ดังกล่าวข้างต้น ถือว่าผู้เช่าจงใจผิดสัญญาเช่า ในข้อสาระสำคัญ และผู้ให้',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      'เช่ามีสิทธิเลิกสัญญาเช่า ฉบับนี้ได้ทันทีก่อนครบกำหนดระยะเวลาการเช่า  โดยมิต้องบอกกล่าวผู้เช่าล่วงหน้าแต่อย่างใด',
                  font: ttf),
            ]),

            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            Textx(value: '            ข้อ 6)  การประกันภัย', font: ttf),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            ผู้เช่าต้องทำประกันวินาศภัยและประกันอัคคีภัยสำหรับทรัพย์สินภายในสถานที่เช่าของตน ตลอดระยะเวลาการเช่า โดยผู้',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'เช่าเป็นฝ่ายชำระเบี้ยประกัน ดังกล่าวนั้นแต่ฝ่ายเดียวโดยกำหนดให้ผู้ให้เช่าเป็นผู้รับผลประโยชน์ในกรมธรรม์ดังกล่าว โดยผู้เช่าต้อง',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'แจ้งให้ผู้ให้เช่าทราบเป็นลายลักษณ์อักษรและต้องส่งสำเนากรมธรรม์ประกันภัยให้แก่ผู้ให้เช่าไว้เป็นหลักฐานภายใน 1(หนึ่ง) เดือนนับ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value: 'แต่วันที่สัญญาเช่าฉบับนี้มีผลใช้บังคับ', font: ttf),
              ]),
            ]),

            // pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
            //   Textx(value: '/  ข้อ 7)  ข้อสัญญาและ..', font: ttf)
            // ]),
            pw.NewPage(),
            Textx(
                value: '            ข้อ 7)  ข้อสัญญาและหน้าที่ของผู้เช่า',
                font: ttf),
            Textx(
                value:
                    '            7.1  ผู้เช่าจะชำระเงินทั้งปวงให้แก่ผู้ให้เช่า เมื่อถึงกำหนดชำระตามสัญญาเช่าฉบับนี้',
                font: ttf),

            Textx(
                value:
                    '            7.2  ผู้เช่าจะรับมอบสถานที่เช่าจากผู้ให้เช่าในวันที่ผู้ให้เช่ากำหนดและแจ้งให้ทราบ',
                font: ttf),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            7.3  ผู้เช่าต้องตกแต่งสถานที่เช่าให้แล้วเสร็จพร้อมเปิดดำเนินกิจการได้ตามที่แจ้งกำหนดการเป็นลายลักษณ์อักษรไว้กับศูนย์',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'การค้านิ่มซิตี้หากผู้เช่าไม่สามารถดำเนินการได้ทันกำหนดผู้เช่ายินยอมให้ผู้ให้เช่าปรับเงินอัตราวันละ 100 บาท(หนึ่งร้อยบาทถ้วน) ต่อ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'พื้นที่เช่า 1 (หนึ่ง)ตารางเมตร และหากการ ปรับดังกล่าวดำเนินไปเกินกว่า 60 (หกสิบ)วัน ผู้ให้เช่ามีสิทธิ บอกเลิกสัญญาเช่า ฉบับนี้ได้',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ทันที และมีสิทธิริบบรรดาเงินทั้งหลายที่ผู้เช่าได้ชำระไว้แล้วก่อน วันบอกเลิกสัญญา  รวมทั้งสงวนสิทธิที่จะเรียกค่าเสียหายที่ผู้ให้เช่าได้',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(value: 'รับอีกส่วนหนึ่งด้วย', font: ttf),
              ]),
            ]),
            Textx(
                value:
                    '            7.4  ผู้เช่าจะใช้และครอบครองสถานที่เช่าเพื่อวัตถุประสงค์ตามที่กำหนดไว้ในสัญญาเช่าฉบับนี้เท่านั้น',
                font: ttf),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            7.5  หากผู้เช่ามีวัตถุประสงค์การเช่าตามสัญญาเช่าฉบับนี้  เป็นการประกอบกิจการร้านอาหารภัตตาคาร  ร้านทำผม หรือ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ร้านเสริมความงาม ผู้เช่าจะต้องจัดทำระบบพื้นกันซึมทั้งพื้นที่ของสถานที่เช่า บ่อดักไขมัน และถังบำบัดน้ำเสีย เพื่อบำบัดน้ำเสียก่อน',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ปล่อยลงสู่ท่อน้ำทิ้งรวม  พร้อมทั้งติดตั้งปล่อง  ควันเพื่อระบายอากาศและระบบกำจัดควัน  ระบบป้องกันอัคคีภัย  รวมทั้งการกำจัด',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'หนูปลวก และแมลง ทั้งนี้ต้องเป็นระบบที่ผู้ให้เช่าให้ความเห็นชอบ เป็นลายลักษณ์อักษรเพื่อความปลอดภัย ความสะอาด และความ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ถูกสุขลักษณะของสถานที่เช่า  และปฏิบัติให้ถูกต้องตามที่กฎหมายกำหนด ไว้ทุกประการ',
                    font: ttf),
              ]),
            ]),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            7.6  ผู้เช่าจะรับผิดชอบและชำระภาษีที่ดินและสิ่งปลูกสร้างตามจำนวนพื้นที่ของสถานที่เช่าและภาษีอากร หรือเงินอื่นใดที่',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ผู้ให้เช่าและหรือหน่วยงาน ของรัฐเรียกเก็บทั้งหมดที่เกี่ยวกับสถานที่เช่าซึ่งต้องชำระตามกฎหมาย (ยกเว้นภาษีเงินได้ของผู้ให้เช่าที่คำ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'นวณจากค่าเช่า) ตลอดอายุสัญญาเช่าหากผู้ให้เช่า ได้ชำระเงินต่างๆ ดังกล่าวไปก่อนแล้ว  ผู้เช่าจะต้องชดใช้คืนให้แก่ผู้ให้เช่าภายใน 5',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value: '(ห้า)วัน นับแต่วันที่ได้รับคำบอกกล่าวจากผู้ให้เช่า',
                    font: ttf),
              ]),
            ]),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            7.7  ผู้ให้เช่าไม่ต้องรับผิดชอบต่อความเสียหาย หรือสูญหายใดๆของบุคคล ทรัพย์สินและสิทธิประโยชน์ของผู้เช่าหรือบุคคล',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'อื่นใดที่เกิดขึ้นในสถานที่ เช่าผู้เช่าต้องรับผิดชอบเองในทุกกรณี',
                    font: ttf),
              ]),
            ]),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            7.8  เมื่อผู้ให้เช่า หรือตัวแทนได้กระทำการ หรืองดเว้นการกระทำใดๆ ไปตามสิทธิของผู้ให้เช่าตามสัญญาเช่าฉบับนี้แล้ว  ผู้',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'เช่าจะกล่าวหา หรือฟ้อง ร้องผู้ให้เช่า หรือตัวแทนของผู้ให้เช่าทั้งทางแพ่งและทางอาญาไม่ได้เป็นอันขาดไม่ว่ากรณีใดๆ ทั้งสิ้น',
                    font: ttf),
              ]),
            ]),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            7.9  ผู้เช่าจะปฏิบัติตามกฎระเบียบทั้งปวง  และที่ปรากฏอยู่ในสัญญาเช่า  และคู่มือผู้เช่าและผู้รับบริการ  ที่ผู้ให้เช่ากำหนด',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'กฎระเบียบ ข้อบังคับ และ ได้ส่งมอบแก่ผู้เช่าพื้นที่เช่า ของศูนย์การค้านิ่มซิตี้ ทั้งหลาย รวมทั้งกฎระเบียบต่างๆในบริเวณที่จอดรถ กฎ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ระเบียบ เหล่านี้อาจมีการแก้ไขเปลี่ยนแปลง หรือ ปรับปรุงได้ตามที่ผู้ให้เช่าเห็นสมควร  แต่ทั้งนี้ผู้ให้เช่าจะแจ้งให้ผู้เช่าทราบไม่น้อยกว่า',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value: ' 7(เจ็ด)วัน  ก่อนที่จะเริ่มใช้กฎระเบียบใหม่นั้น',
                    font: ttf),
              ]),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      '            ผู้เช่ารับทราบและตกลงยินยอมปฏิบัติตาม กฎระเบียบ ข้อบังคับอื่นๆ ตาม คู่มือผู้เช่าและผู้รับบริการ ซึ่งถือเป็นส่วนหนึ่งของ',
                  font: ttf),
            ]),

            Textx(value: 'สัญญาเช่าฉบับนี้', font: ttf),

            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            Textx(value: '            ข้อ 8) การให้เช่าช่วง', font: ttf),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            ผู้เช่าไม่มีสิทธินำสถานที่เช่านี้ออกไปให้เช่าช่วง หรือให้บุคคลอื่นเข้าใช้ประโยชน์ ในสถานที่เช่าเว้นแต่จะได้รับความยินยอม',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'เป็นหนังสือจากผู้ให้เช่าแล้ว  ทั้งนี้ผู้เช่าช่วงจะต้องยินยอมเข้าผูกพันตามข้อกำหนดและเงื่อนไขในสัญญาเช่าฉบับนี้สืบต่อจากผู้เช่าเดิม',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value: 'ทุกประการหรือตามที่ผู้ให้เช่าจะกำหนดเพิ่มเติม',
                    font: ttf),
              ]),
            ]),

            pw.NewPage(),
            Textx(value: '            ข้อ 9) การโอนสิทธิการเช่า', font: ttf),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            9.1 ผู้เช่าไม่มีสิทธิโอนสิทธิการเช่าตามสัญญาเช่าฉบับนี้ให้แก่บุคคลอื่น เว้นแต่จะได้รับความยินยอมเป็นหนังสือจากผู้ให้เช่า',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'แล้ว โดยผู้รับโอนสิทธิจาก ผู้เช่าต้องเป็นผู้ประกอบการอาชีพโดยสุจริต และมีความประพฤติเรียบร้อย และต้องยินยอมเข้าผูกพันตาม',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ข้อกำหนดและเงื่อนไข แห่งสัญญาเช่าฉบับนี้ต่อ จากผู้เช่าเดิมทุกประการ',
                    font: ttf),
              ]),
            ]),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            ในกรณีที่ผู้ให้เช่ายินยอมให้ผู้เช่า โอนสิทธิการเช่าสถานที่ ตามความในวรรคก่อน ผู้เช่าต้องชำระค่าธรรมเนียม โอนสิทธิการ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        ' เช่าให้แก่ผู้ให้เช่าในอัตรา 2,000 บาท (สองพันบาทถ้วน) ต่อ 1(หนึ่ง)ตารางเมตรของสถานที่เช่า',
                    font: ttf),
              ]),
            ]),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            9.2 ในกรณีที่ผู้เช่าประสงค์จะนำสิทธิตามสัญญาเช่าฉบับนี้ไปเป็นหลักทรัพย์ค้ำประกันต่อเจ้าหนี้ ต้องได้รับอนุญาตจากผู้ให้',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(value: 'เช่าเป็นลายลักษณ์อักษร ก่อน', font: ttf),
              ]),
            ]),

            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            Textx(value: '            ข้อ 10)  การต่อสัญญาเช่า', font: ttf),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            ก่อนอายุสัญญาเช่าฉบับสิ้นสุดลง โดยคู่สัญญาทั้งสองฝ่ายตกลงให้ถือเป็นสาระสำคัญของสัญญาหากผู้เช่ามีความประสงค์จะ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ทำการเช่าทรัพย์สินต่อไป อีกโดย ทำหนังสือแจ้งความจำนงดังกล่าวไปถึงผู้ให้เช่า เป็นการล่วงหน้าไม่น้อยกว่า 60 (หกสิบ)วัน ผู้ให้เช่า',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ตกลงว่าจะทำการพิจารณา ต่ออายุสัญญาเช่าให้ แก่ผู้เช่าออกไปอีกโดยอาจมีการเปลี่ยนแปลง ข้อตกลงและอัตราค่าเช่าทรัพย์สินซึ่งผู้',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'เช่ารับทราบและตกลงว่า เป็นสิทธิเด็ดขาดของผู้ให้เช่าแต่เพียงฝ่ายเดียวใน การพิจารณา โดยจะทำการแจ้งให้ผู้เช่าทราบก่อนทำการ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(value: 'ต่ออายุการเช่าทรัพย์สินต่อไป', font: ttf),
              ]),
            ]),

            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            Textx(
                value: '            ข้อ 11)  การบอกเลิกสัญญาก่อนกำหนด',
                font: ttf),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            11.1 คู่สัญญาทั้งสองฝ่ายตกลงและให้ถือเป็นสาระสำคัญแห่งบันทึกฉบับนี้ว่า ผู้ให้เช่ามีสิทธิที่จะขอคืน และเข้าครอบครอง',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'พื้นที่ตามข้อ 1 และมีสิทธิ บอกเลิกสัญญาเช่าฉบับนี้ ได้ทุกเมื่อตามความประสงค์ของผู้ให้เช่า แต่ทั้งนี้ผู้ให้เช่า จะต้องทำการแจ้งเป็น',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ลายลักษณ์ให้ผู้เช่าทราบเป็นการล่วงหน้าไม่น้อย 30 วัน (สามสิบวัน) ผู้เช่าตกลงและให้คำมั่นสัญญาว่าเมื่อผู้เช่าได้รับแจ้งจากผู้ให้เช่า',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'แล้วไซร้ ผู้เช่าตกลงจะดำเนินการส่งมอบพื้นที่ตามข้อ 1 แห่งบันทึกฉบับนี้ ให้แก่ผู้ให้เช่าทันที ภายใต้เงื่อนไขและข้อตกลงดังกล่าวข้าง',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(value: ' ต้น โดยปราศจากเงื่อนไขใด ๆ ทั้งสิ้น', font: ttf),
              ]),
            ]),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            ในกรณีที่ผู้ให้เช่าใช้สิทธิ ตามความในวรรคก่อน ซึ่งเป็นไปตามข้อตกลงแห่งคู่สัญญา ผู้เช่าตกลงจะไม่ดำเนินการใดๆ อันเป็น',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'การโต้แย้งสิทธิของผู้ให้ เช่าและรับทราบว่าผู้เช่าไม่มีสิทธิเรียกร้องค่าเสียหายใด ๆ จากผู้ให้เช่าแต่ประการใดทั้งสิ้น ',
                    font: ttf),
              ]),
            ]),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            11.2 กรณีที่ผู้เช่ามีความประสงค์ที่จะทำการบอกกล่าวยกเลิกสัญญาก่อนครบกำหนดตามข้อ 1 ผู้เช่าต้องทำการแจ้งเป็นลาย',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ลักษณ์ให้ผู้ให้เช่าทราบ เป็นการล่วงหน้าไม่น้อยกว่า 30 (สามสิบ) วัน โดยกรณีนี้ทางฝ่ายผู้ให้เช่าสามารถเรียกเก็บ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'หรือจะไม่เรียกเก็บ เงินค่าปรับจำนวน 1 เดือน จากผู้เช่ากรณีบอก กล่าวยกเลิกสัญญา ก่อนครบกำหนดตามข้อ 1 ซึ่งการดำเนินการนี้',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'แล้วแต่ จะมีการเจรจาตกลงของคู่สัญญาทั้งสองฝ่ายอีกครั้งหนึ่งและเมื่อครบกำหนดระยะเวลาดังกล่าวผู้เช่าสัญญาว่าจะทำการขนย้าย',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ทรัพย์สินและส่งมอบทรัพย์ที่เช่าคืนแก่ผู้ให้เช่าทันที',
                    font: ttf),
              ]),
            ]),

            pw.NewPage(),
            Textx(
                value: '            ข้อ 12)  การประพฤติผิดสัญญาเช่า',
                font: ttf),
            pw.Row(
              children: [
                Textx(
                  value:
                      '            นอกจากสิทธิอื่นๆของผู้ให้เช่า ที่กำหนดไว้ในสัญญา เช่าฉบับนี้แล้ว ',
                  font: ttf,
                ),
                pw.Container(
                  child: labeledLine(
                    value: 'หากผู้เช่าได้กระทำผิดข้อสัญญาใดๆที่ได้มีการตกลงกำ',
                    font: ttf,
                    flex: 2,
                  ),
                ),
              ],
            ),

            pw.Row(
              children: [
                pw.Container(
                  child: labeledLine(
                    value: 'หนดไว้ในสัญญาเช่าฉบับนี้หรือสัญญาบริการ',
                    font: ttf,
                    flex: 2,
                  ),
                ),
                Textx(
                  value: ' เลขที่ ',
                  font: ttf,
                ),
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
                Textx(value: ' ลงวันที่ ', font: ttf),
                labeledLine1(
                    flex: 2, value: formatThaiDate(Datex_text.text), font: ttf),
              ],
            ),
            pw.Row(
              children: [
                Textx(
                  value:
                      'ซึ่งถือเป็นส่วนหนึ่งของสัญญาเช่าฉบับนี้และผู้ให้เช่าได้มีหนังสือเตือนให้ผู้เช่าแก้ไขให้ถูกต้องภายในกำหนดเวลาแล้วแต่ผู้เช่าไม่ดำเนิน',
                  font: ttf,
                ),
              ],
            ),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                  value: 'การแก้ไขให้ถูกต้องภายในกำหนดเวลาดังกล่าว ',
                  font: ttf,
                ),
                pw.Container(
                    child: labeledLine(
                        value:
                            'ผู้เช่ายินยอมให้ผู้ให้เช่า  บอกเลิกสัญญาเช่าฉบับนี้ได้ทันที พร้อมทั้งยินยอมให้ผู้ให้เช่า',
                        font: ttf,
                        flex: 2)),
              ]),
            ]),
            pw.Container(
                child: labeledLine(
                    value:
                        'เรียกค่าเสียหายและค่าใช้จ่ายใดๆที่ผู้เช่าได้ก่อขึ้นอันเนื่องมาจากการผิดสัญญาของผู้เช่า',
                    font: ttf,
                    flex: 2)),

            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            ในกรณีที่สัญญาเช่าฉบับนี้สิ้นสุดลงเพราะเหตุที่ผู้เช่าผิดสัญญา ไม่ว่าด้วยเหตุใดๆตามที่กำหนดไว้ในสัญญาเช่าฉบับนี้ผู้เช่ายิน',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ยอมให้ผู้ให้เช่าริบบรรดา เงินใดๆทั้งหมดที่ผู้เช่าได้ชำระไว้ต่อผู้ให้เช่าก่อนหน้าวันบอกเลิกสัญญา โดยผู้ให้เช่ามีสิทธินำสถานที่เช่าออก',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ไปให้ผู้อื่นเช่าต่อไปได้ทันทีโดยผู้เช่าไม่มีสิทธิเรียก ร้องใดๆ',
                    font: ttf),
              ]),
            ]),

            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            Textx(
                value: '            ข้อ 13) การสิ้นสุดของสัญญาเช่า', font: ttf),
            Textxx(
                value:
                    '            13.1 เป็นที่ตกลงกันอย่างแจ้งชัดว่า เมื่อระยะเวลาในการเช่าตามสัญญาเช่าฉบับนี้ครบกำหนดสัญญาเช่าเป็นอันระงับทันที โดยผู้ให้เช่าไม่จำเป็นต้อง บอกกล่าวอีกโดยผู้เช่าไม่มีสิทธิเรียกร้องค่าขนย้ายหรือค่าตอบแทนใดๆทั้งสิ้นจากผู้ให้เช่า',
                font: ttf),
            pw.Row(children: [
              Textx(
                  value:
                      '            13.2  เมื่อสัญญาฉบับนี้สิ้นสุดลง  ไม่ว่าด้วยเหตุประการใด  ผู้ให้เช่ามีสิทธิเข้าครอบครองสถานที่เช่าทันที  ผู้เช่าต้องขนย้าย',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      'ทรัพย์สินและบริวารออกจากสถานที่เช่าภายในกำหนดที่สัญญาฉบับนี้สิ้นสุดลง และคืนสถานที่เช่าให้ผู้ให้เช่าในสภาพที่ได้รับมอบหรือ',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      'ชำระเงินในจำนวนที่เพียงพอต่อการซ่อมแซมหรือ ปรับปรุงให้อยู่ในสภาพเดิม พร้อมทั้งคืนกุญแจทั้งหมด',
                  font: ttf),
            ]),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            13.3 เมื่อสัญญาเช่าสิ้นสุดลงไม่ว่ากรณีใดก็ตาม ผู้เช่าต้องดำเนินการขนย้ายทรัพย์สินและบริวารออกจากทรัพย์สินที่เช่าและ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ส่งมอบทรัพย์สินที่เช่าคืน ให้แก่ผู้ให้เช่าทันที หากผู้เช่าไม่ดำเนินการดังกล่าวมา ผู้ให้เช่าคงสิทธิในการเรียกปรับผู้เช่าได้ใน อัตราวันละ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '5,000.00 บาท (ห้าพันบาทถ้วน) ทั้งนี้จนกว่าผู้ เช่าจะดำเนินการข้างต้นเป็นที่เสร็จสิ้นเรียบร้อย',
                    font: ttf),
              ]),
            ]),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            เมื่อสัญญาเช่าฉบับนี้สิ้นสุดลงไม่ว่าด้วยเหตุใดๆหากผู้เช่าไม่ขนย้ายทรัพย์สินและบริวารออจากสถานที่เช่าหรือไม่ส่งมอบการ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ครอบครองสถานที่เช่าให้ แก่ผู้ให้เช่า  ผู้เช่าตกลงยินยอมให้ผู้ให้เช่าหรือตัวแทนผู้ให้เช่ามีอำนาจในการดำเนินการที่จำเป็น ทุกประการ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'รวมทั้งการทำลายกุญแจหรือเครื่องกีดขวางใดๆ เพื่อให้การกลับเข้าครอบครอง สถานที่เช่าตามสิทธิของผู้ให้เช่าตามข้อ 13.2 บรรลุผล',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'โดยไม่ถือว่าผู้ให้เช่าหรือตัวแทนผู้ให้เช่าได้บุกรุกหรือละเมิดสิทธิของผู้ เช่าบริวารของผู้ให้เช่าหรือบุคคลอื่นแต่อย่างใด กับทั้งให้ผู้ให้เช่า',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'หรือตัวแทนของผู้ให้เช่ามีอำนาจเข้าครอบครองยึดหน่วงทรัพย์สินของผู้เช่า หรือของบุคคล อื่นใดที่อยู่ในสถานที่เช่า หรือขนย้ายบุคคล',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'หรือทรัพย์สินดังเช่นว่านั้นออกจากสถานที่เช่าแล้วแต่ผู้ให้เช่าจะเห็นสมควรโดยผู้เช่ายินยอมที่จะรับค่าใช้จ่ายต่างๆรวมตลอดถึงค่าเสีย',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'หายที่เกิดขึ้น รวมทั้งผู้ให้เช่ามีสิทธิที่จะล็อคกุญแจเพื่อมิให้ผู้เช่าเข้าไปในสถานที่เช่าอีกต่อไปได้ โดยผู้เช่าจะไม่ดำเนินการเรียกร้องหรือ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ดำเนินการฟ้องร้องทางแพ่ง  ทางอาญา กับผู้ให้เช่า หรือตัวแทนของผู้ให้เช่าอีกต่อไป',
                    font: ttf),
              ]),
            ]),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            13.4 เมื่อสัญญาฉบับนี้สิ้นสุดลง ไม่ว่าด้วยเหตุใดๆผู้เช่ายินยอมให้ผู้ให้เช่าหรือตัวแทนของผู้ให้เช่ามีสิทธิในการจัดการ สถาน',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ที่เช่าและสาธารณูปโภค เช่น ไฟฟ้า ประปา ในบริเวณสถานที่เช่าตามที่ผู้ให้เช่าเห็นสมควร โดยผู้เช่าจะต้องรับผิดชอบชดใช้ค่าเสียหาย',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'และหรือค่าใช้จ่ายอื่นใดทั้งหมด ที่เกิดขึ้นเนื่อง จากการผิดสัญญาของ ผู้เช่าให้แก่ผู้ให้เช่าหรือตัวแทนผู้ให้เช่า และ/หรือบุคคลภายนอก',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'และผู้เช่าจะไม่โต้แย้งหรือเรียกร้องค่าเสียหายใดๆจากผู้ให้เช่าทั้งสิ้น',
                    font: ttf),
              ]),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      '            13.5  ในกรณีที่สัญญาเช่าฉบับนี้สิ้นสุดลง  ไม่ว่าด้วยเหตุประการใดผู้เช่ายินยอม  ที่จะอำนวยความสะดวกให้แก่ผู้ให้เช่าเพื่อ',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      'ดำเนินการใดๆที่จำเป็นสำหรับการดำเนินการยกเลิกสัญญาเช่าฉบับนี้',
                  font: ttf),
            ]),
            pw.NewPage(),
            Textx(value: '            ข้อ 14) เหตุสุดวิสัย', font: ttf),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            คู่สัญญาทั้งสองฝ่ายตกลงและรับทราบดีว่าในกรณีที่ ทรัพย์สินที่เช่าถูกเวนคืนตามกฎหมายของทางราชการก่อนครบกำหนด',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'การเช่าหรือหากการปฏิบัติหน้าที่ใดๆตามสัญญาเช่าฉบับนี้ของคู่สัญญาฝ่ายใดฝ่ายหนึ่งถูกขัดขวาง  ถูกจำกัด  หรือถูกรบกวน คู่สัญญา',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ที่ได้รับผลกระทบกระเทือนจากการนั้น  เมื่อได้ให้คำบอกกล่าวแก่คู่สัญญาอีกฝ่ายหนึ่งโดยทันทีแล้ว  ได้รับยกเว้นจากการปฏิบัติหน้าที่',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'เช่นว่านั้นตามขอบข่ายของการขัดขวาง การจำกัด หรือถูกรบ กวนอันเนื่องจาก',
                    font: ttf),
              ]),
            ]),

            Textxx(
                value:
                    '            14.1 อัคคีภัย  การระเบิด  แผ่นดินไหว  การนัดหยุดงาน  การปิดงาน  ข้อพิพาทแรงงาน  วินาศภัย  หรืออุบัติเหตุ  โรคระบาด  อุทกภัย  การขาด หรือการไม่ปฏิบัติการของแหล่งจัดหาแรงงาน  กำลังไฟฟ้า หรือสัมภาระ หรือ',
                font: ttf),
            Textx(
                value:
                    '            14.2 สงคราม การปฏิวัติก่อความไม่สงบของพลเรือน การกระทำของศัตรู การปิดเมืองท่า หรือการห้ามส่งสินค้า หรือ',
                font: ttf),
            Textxx(
                value:
                    '            14.3 กฎหมาย คำสั่งประกาศ ข้อบังคับ เทศบัญญัติ การเรียกร้อง หรือความต้องการใดๆของรัฐบาล หรือของหน่วยงาน เจ้าหน้าที่ หรือผู้แทนใดๆ ของรัฐบาลเช่นว่านั้น',
                font: ttf),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            โดยไม่ใช่ความผิดของผู้เช่าหรือเกิดภัยพิบัติต่างๆ กับทรัพย์สินที่เช่าตามสัญญานี้จนเป็นเหตุให้ผู้เช่าไม่สามารถใช้ทรัพย์สินที่',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'เช่าได้ตามวัตถุประสงค์ใน การเช่าได้อีกต่อไป ให้ถือว่าสัญญาเช่าฉบับนี้เป็นอันสิ้นสุดยุติลงโดยทันทีคู่สัญญาทั้งสองฝ่ายตกลงกันให้ถือ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ว่าสัญญาเช่าฉบับนี้เป็นอันระงับสิ้นสุดลงและต่าง ฝ่ายต่างไม่ติดใจเรียกร้องค่าเสียหายประการใดต่อกันอีก',
                    font: ttf),
              ]),
            ]),

            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            Textx(value: '            ข้อ 15) การบอกกล่าว', font: ttf),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            หนังสือบอกกล่าวหรือการติดต่อสื่อสารใดๆตามสัญญาเช่าฉบับนี้  หรือที่เกี่ยวกับสัญญาเช่าฉบับนี้  ให้ทำเป็นหนังสือลงลาย',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'มือชื่อโดยคู่สัญญาฝ่ายที่ ส่งคำบอกกล่าว  หรือการติดต่อสื่อสารนั้น  หรือโดยตัวแทนผู้มีอำนาจโดยชอบของคู่สัญญาดังกล่าว  แล้วนำ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ส่งโดยพนักงานส่งหนังสือหรือส่งทางไปรษณีย์ลงทะเบียนถึงผู้รับตามที่อยู่ในสัญญาเช่าฉบับนี้ หรือที่อยู่อื่นหรือช่องทางสื่อสารอื่นซึ่งผู้',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value: 'รับได้แจ้งให้ผู้ส่งทราบเป็นลายลักษณ์อักษรแล้ว',
                    font: ttf),
              ]),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      '            อนึ่ง คำบอกกล่าวใดๆที่ผู้ให้เช่ามีถึงผู้เช่า และได้ปิดโดยเปิดเผย ณ สถานที่เช่าให้ถือว่าเป็นการส่งคำบอกกล่าวโดยชอบแล้ว',
                  font: ttf),
            ]),
            Textx(value: 'นับตั้งแต่วันที่ได้ส่งหรือปิดไว้นั้น', font: ttf),

            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            Textx(value: '            ข้อ 16) เบ็ดเตล็ด', font: ttf),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            16.1 การรับค่าเช่าโดยผู้ให้เช่า ไม่ถือเป็นการสละสิทธิของผู้ให้เช่าในอันที่จะดำเนินการกับผู้เช่าในเรื่องการผิดสัญญา เมื่อผู้',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'เช่าประพฤติผิดข้อตกลง ข้อจำกัด ข้อกำหนด และเงื่อนไขใดๆตามสัญญาเช่าฉบับนี้',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '            16.2 การที่ผู้ให้เช่าละเลยไม่บังคับตามสิทธิของตนต่อผู้เช่าเมื่อผู้เช่าไม่ปฏิบัติตามสัญญาไม่ถือเป็นการสละสิทธิของผู้ให้เช่า',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ที่จะบังคับตามสัญญา หรือเป็นการสละสิทธิที่บังคับตามสิทธิอื่นๆของผู้ให้เช่าตามที่ระบุไว้ในสัญญาเช่าฉบับนี้',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '            16.3 สัญญาเช่าฉบับนี้ถือเป็นข้อตกลงทั้งหมดระหว่างคู่สัญญาในทุกเรื่องที่ได้ระบุไว้ในสัญญาเช่าฉบับนี้และมีผลใช้บังคับผูก',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'พันกับผู้สืบสิทธิ ผู้รับโอน สิทธิ ทายาท ผู้จัดการมรดก หรือผู้จัดการทรัพย์สินของคู่สัญญาด้วย',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '            16.4 ในกรณีข้อกำหนดแห่งสัญญาเช่าฉบับนี้ข้อใดข้อหนึ่งตกเป็นโมฆะ หรือใช้บังคับไม่ได้ตามกฎหมาย คู่สัญญาทั้งสองฝ่าย',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value: 'ตกลงให้ข้อกำหนดอื่นๆ ยังคงมีผลใช้บังคับกันได้ต่อไป',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '            16.5  การแก้ไขเปลี่ยนแปลงสัญญาเช่าฉบับนี้ไม่อาจทำได้  เว้นแต่คู่สัญญาทั้งสองฝ่าย  จะได้ทำความตกลงเป็นลายลักษณ์',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'อักษร และให้ถือว่าข้อตกลง ดังกล่าวเป็นส่วนหนึ่งของสัญญาเช่าฉบับนี้',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '            16.6 ชื่อหัวข้อที่ปรากฏในสัญญาเช่าฉบับนี้ ไม่มีผลกระทบกับการตีความรายละเอียดแห่งข้อสัญญาแต่อย่างใด แต่เป็นเพียง',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'การระบุเพื่อให้เกิดความ ชัดเจนและสะดวกในการทำความเข้าใจสัญญาเท่านั้น',
                    font: ttf),
              ]),
            ]),

            pw.NewPage(),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            ข้อ 17) สัญญาเช่าฉบับนี้มีเงื่อนไขและข้อตกลงเพิ่มเติมในส่วนของสัญญาข้อ 2 รายละเอียดปรากฏตาม',
                    font: ttf),
                labeledLine1(flex: 1, value: 'เอกสารแนบท้าย', font: ttf),
              ]),
              pw.Row(children: [
                labeledLine1(flex: 1, value: 'สัญญาหมายเลข 2, 3 ', font: ttf),
                Textx(
                    value:
                        ' และคู่มือผู้เช่าและผู้รับบริการทั้งนี้คู่สัญญาทั้งสองฝ่ายตกลงให้ถือเป็นสาระสำคัญแห่งสัญญาฉบับนี้',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value: 'และให้ถือเป็นส่วนหนึ่งของสัญญาฉบับนี้ด้วย',
                    font: ttf),
              ]),
            ]),

            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            สัญญาฉบับนี้ทำขึ้นเป็น  2  ฉบับ มีข้อความถูกต้องตรงกัน  คู่สัญญาทั้งสองฝ่ายได้อ่าน  และเข้าใจข้อความในสัญญานี้เป็น',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'อย่างดี เห็นว่าเป็นที่ถูกต้อง ครบถ้วน เรียบร้อย ตรงตามเจตนาทุกประการ  ปราศจากการบังคับ ขู่เข็ญ  หรือสำคัญผิด แต่อย่างใดคู่',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'สัญญามีสติสัมปชัญญะครบถ้วนสมบูรณ์ทุกประการ  จึงได้ลงลายมือชื่อ/พิมพ์ลายนิ้วมือ และตราประทับ(ถ้ามี) เป็นของผู้ให้เช่า และ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ผู้เช่าจริง ไว้เป็นสำคัญต่อหน้าพยาน ในวัน และ ณ สถานที่ดังกล่าวข้างต้น',
                    font: ttf),
              ]),
            ]),

            pw.SizedBox(height: 30 * PdfPageFormat.mm),
            pw.Row(
              children: [
                // คอลัมน์ซ้าย 30% (จะโล่ง ๆ ไม่ใส่เนื้อหาอะไร)
                pw.Expanded(
                  flex: 3, // ใช้ 3 ส่วนจากทั้งหมด 10 ส่วน
                  child: pw.Container(
                      // พื้นที่ฝั่งซ้ายไม่ใส่เนื้อหา

                      ),
                ),

                // คอลัมน์ขวา 70%
                pw.Expanded(
                  flex: 7, // ใช้ 7 ส่วนจากทั้งหมด 10 ส่วน
                  child: pw.Column(
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Container(
                            height: 10 * PdfPageFormat.mm,
                          ),
                          Textx(
                              value:
                                  'ลงชื่อ..........................................................................................ผู้ให้เช่า',
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
                          pw.SizedBox(height: 2 * PdfPageFormat.mm),
                          Textx(
                              value:
                                  'โดยดร.ปราณี สุวิทย์ศักดานนท์ และนายชวลิต สุวิทย์ศักดานนท์',
                              font: ttf),
                          pw.SizedBox(height: 2 * PdfPageFormat.mm),
                          Textx(
                              value: 'กรรมการซึ่งลงชื่อผูกพันบริษัทฯ ได้',
                              font: ttf),
                        ],
                      ),
                      pw.SizedBox(height: 20 * PdfPageFormat.mm),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          Textx(
                              value:
                                  'ลงชื่อ..........................................................................................ผู้เช่า',
                              font: ttf),
                          pw.SizedBox(height: 2 * PdfPageFormat.mm),
                          Textx(
                            value: (Form_bussshop == null ||
                                    Form_bussshop.toString() == '')
                                ? '(.............................................................................................) '
                                : '$Form_bussshop โดย $Form_bussscontact',
                            font: ttf,
                          ),
                          pw.SizedBox(height: 2 * PdfPageFormat.mm),
                          Textx(
                              value: 'กรรมการซึ่งลงชื่อผูกพันบริษัทฯ ได้',
                              font: ttf),
                        ],
                      ),
                      pw.SizedBox(height: 20 * PdfPageFormat.mm),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          Textx(
                              value:
                                  'ลงชื่อ..........................................................................................พยาน',
                              font: ttf),
                          pw.SizedBox(height: 2 * PdfPageFormat.mm),
                          Textx(
                              value: '(     นางสาวกัลยา บัวระวงค์     )',
                              font: ttf),
                        ],
                      ),
                      pw.SizedBox(height: 20 * PdfPageFormat.mm),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          Textx(
                              value:
                                  'ลงชื่อ..........................................................................................พยาน',
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
      return '/ 2.2 เงินประกันและ..';
    case 2:
      return '/ 3.2 การหักภาษี..';
    case 3:
      return '/ ข้อ 7) ข้อสัญญาและ..';
    case 4:
      return '/ ข้อ 9) การโอนสิทธิ..';
    case 5:
      return '/ ข้อ 12) การประพฤติ..';
    case 6:
      return '/ ข้อ 14) เหตุสุดวิสัย..';
    case 7:
      return '/ ข้อ 17) สัญญาเช่า…';
    default:
      return ''; // หน้าอื่นไม่แสดงข้อความ (หรือจะใส่ default text ก็ได้)
  }
}
