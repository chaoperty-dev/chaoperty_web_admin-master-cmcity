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
import '../../Model/GetContract_Photo_Model.dart';
import '../../PeopleChao/Rental_Information.dart';
import '../../Style/ThaiBaht.dart';
import '../../Style/loadAndCacheImage.dart';

class Pdfgen_Agreementnim2 {
//////////---------------------------------------------------->( **** เอกสารสัญญาเช่า ปกติ  )

  static void exportPDF_Agreementnim2(
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
    //// ------------>(สัญญาบริการ)

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
    final filteredListchao = quotxSelectModels
        .where(
            (item) => (item.dtype ?? '').trim() == "KR" && item.expser == '8')
        .toList();
    final totalchao = nFormat.format((filteredListchao.fold<double>(
      0.00,
      (double sum, dynamic item) =>
          sum + (item.pvat != null ? double.parse(item.pvat!) : 0.00),
    ))); // ค่าเช่า/ค่าบริการหลัก + น้ำไฟ เดือนละ

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
        // header: (context) {
        //   return pw.Column(children: []);
        // },
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
                  value: 'สัญญาบริการ',
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
                        final service = decoded['service']?.toString() ?? '';
                        return service.isNotEmpty ? service : '-';
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
                    '"ผู้ให้บริการ"',
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
                              'เชียงใหม่  50100  ทะเบียน  นิติบุคคล   เลขที่ 0-5055-55010-14-7   ซึ่งต่อไปในสัญญานี้เรียกว่า  ‘‘ผู้ให้บริการ’’',
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
                    '"ผู้รับบริการ"',
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
                            value: '‘‘ผู้รับบริการ’’ อีกฝ่ายหนึ่ง',
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
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            โดยที่ผู้รับบริการได้ทำสัญญาเช่าพื้นที่เช่าบางส่วนของ ศูนย์การค้านิ่มซิตี้ ',
                    font: ttf),
                labeledLine1(flex: 1, value: 'โซน $Form_zn', font: ttf),
                Textx(value: ' ฉบับเลขที่ ', font: ttf),
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
                Textx(value: 'ลงวันที่', font: ttf),
                labeledLine1(
                  flex: 2,
                  value:
                      // '-', // วันที่ชำระภาษีอากร??  value: formatThaiDate(Datex_text.text),
                      // formatThaiDate_y(contractPhotoModels[0].datex),
                      formatThaiDate(Datex_text.text),
                  font: ttf,
                ),
                Textx(value: ' เพื่อเช่าพื้นที่เลขที่ ', font: ttf),
                labeledLine1(flex: 1, value: '$Form_ln', font: ttf),
                Textx(
                    value: ' รวมจำนวนพื้นที่ให้เช่าทั้งสิ้นประมาณ ', font: ttf),
              ]),
              pw.Row(children: [
                labeledLine1(
                  flex: 1,
                  value:
                      '$Form_area ( ${thaiIntegerFromAmount(double.tryParse(Form_area) ?? 0.00)} )',
                  font: ttf,
                ),
                Textx(value: ' ตารางเมตร เพื่อประกอบกิจการ ', font: ttf),
                labeledLine1(
                  flex: 2,
                  value: '$Form_typeshop',
                  font: ttf,
                ),
                Textx(value: ' ชื่อร้านค้า ', font: ttf),
              ]),
              pw.Row(children: [
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
                        'ยี่ห้อสินค้า – ซึ่งผู้รับบริการเป็นผู้มีสิทธิที่จะใช้ยี่ห้อสินค้าดังกล่าวผู้เช่าตกลงจะเข้าทำสัญญาบริการ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'เพื่อรับบริการต่างๆในส่วนที่เกี่ยวข้องกับสถานที่เช่า',
                    font: ttf),
              ]),
              pw.SizedBox(height: 2 * PdfPageFormat.mm),
              pw.Row(children: [
                Textx(
                    value:
                        '            ทั้งสองฝ่ายจึงตกลงทำสัญญา ดังมีข้อความ เงื่อนไขและรายละเอียด ดังต่อไปนี้',
                    font: ttf),
              ]),
              pw.SizedBox(height: 2 * PdfPageFormat.mm),
              pw.Row(children: [
                Textx(
                    value: '            ข้อ 1)  ขอบเขตของการบริการ', font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '                        ผู้ให้บริการตกลงให้บริการ และผู้รับบริการตกลงรับบริการตามรายละเอียด ดังต่อไปนี้ซึ่งต่อไปนี้ในสัญญาบริการ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(value: 'ฉบับนี้เรียกว่า “บริการ” ', font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '                        1.1 การให้บริการแก่สถานที่เช่า',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value: '                              1.1.1	ระบบไฟฟ้าหลัก',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '                              1.1.2	ระบบน้ำประปาหลัก (กรณีมีการต่อท่อน้ำประปา)',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '                              1.1.3	เครื่องปรับอากาศ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '            ผู้ให้บริการอาจจัดให้มีบริการอื่นๆเพิ่มเติม สำหรับสถานที่เช่า   ซึ่งผู้ให้บริการจะได้กำหนดต่อไป และสามารถแก้ไขเปลี่ยน',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'แปลงบริการและข้อกำหนดได้ตามความเหมาะสมและตามที่เห็นสมควร',
                    font: ttf),
              ]),
            ]),

            pw.NewPage(),
            pw.Row(children: [
              Textx(
                  value:
                      '                        1.2 การให้บริการแก่พื้นที่ส่วนกลาง',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      '                              1.2.1	การทำความสะอาดบริเวณที่ใช้ประโยชน์ร่วมกัน',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      '                              1.2.2	ระบบสุขาภิบาลทั่วไป สำหรับบริเวณที่ใช้ประโยชน์ร่วมกัน เช่น ห้องน้ำ ท่อระบายน้ำ และระบบน้ำใช้',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      '                              1.2.3	ยามและหน่วยรักษาความปลอดภัย',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value: '                              1.2.4	ไฟฟ้าแสงสว่าง',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      '                              1.2.5	การโฆษณาประชาสัมพันธ์  และการตกแต่งสถานที่ในเทศกาลต่างๆ',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      '                              1.2.6	การบริการจราจรโดยรอบศูนย์การค้าฯ',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      '                              1.2.7	การจัดการดูแลสวน ความสะอาดโดยรอบศูนย์การค้าฯ',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      '                              1.2.8	การจัดเก็บขยะจากจุดที่กำหนดโดยผู้ให้บริการ',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      '                              1.2.9	การระบายน้ำทิ้งสู่สาธารณะจากจุดที่กำหนดโดยผู้ให้บริการ',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value: '                              1.2.10 ถังดับเพลิง',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value: '                              1.2.11 สถานที่จอด',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      '                              1.2.12 สถานที่สูบบุหรี่',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      '                              1.2.13 ระบบกล้องวงจรปิด',
                  font: ttf),
            ]),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Row(children: [
              Textx(value: '            ข้อ 2)	ค่าบริการ', font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      '                        2.1  ผู้รับบริการตกลงทำการชำระค่าบริการที่เกี่ยวข้องกับสถานที่เช่าให้แก่ผู้ให้บริการ ดังนี้',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      '                              2.1.1	ค่าไฟฟ้า		อัตราหน่วยละ 7.00 บาท (เจ็ดบาทถ้วน)',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      '                              2.1.2	ค่าน้ำประปา	อัตราหน่วยละ 35.00 บาท (สามสิบห้าบาทถ้วน)',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      '                              2.1.3 	ค่าบริการเครื่องปรับอากาศ อัตราเดือนละ 0.00 บาท (ศูนย์บาทถ้วน) ถ้ามี',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      '                              2.1.4 	ค่าไฟฟ้าป้าย	อัตราเดือนละ 0.00 บาท (ศูนย์บาทถ้วน) ถ้ามี',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      '                              2.1.5 	ค่าบริการส่วนกลาง อัตราตารางเมตรละ 250.00 บาท (สองร้อยห้าสิบบบาทถ้วน) ต่อเดือน',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value: '                        รวมเป็นจำนวนเงินเดือนละ ',
                  font: ttf),
              labeledLine1(
                  flex: 1,
                  value:
                      '$totalchao บาท(${convertToThaiBaht(double.tryParse(totalchao.replaceAll(',', '')) ?? 0.00)})',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      ' อัตราค่าบริการตามข้อ 2.1 ข้างต้นยังไม่รวมภาษีมูลค่าเพิ่ม',
                  font: ttf),
            ]),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '                        2.2 สำหรับอัตราค่าบริการตามข้อ 2.1 ตลอดจนค่าใช้จ่ายอื่นๆ ที่ผู้ให้บริการเรียกเก็บจากผู้รับบริการตามสัญญา',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'บริการนี้อาจเปลี่ยนแปลงอัตราค่าบริการได้ตามความเหมาะสมกับต้นทุนค่าใช้จ่ายที่เปลี่ยนแปลงไป โดยผู้ให้บริการจะทำการแจ้งให้ผู้',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'รับบริการทราบเป็นลายลักษณ์อักษร ล่วงหน้าก่อนระยะเวลาเรียกเก็บ ไม่น้อยกว่า 15 (สิบห้า)วัน และคู่สัญญาทั้งสองฝ่าย ลงนามใน',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'บันทึกข้อตกลงและให้ถือบันทึกข้อตกลงดังกล่าวเป็นส่วนหนึ่งของสัญญาบริการฉบับนี้ด้วย',
                    font: ttf),
              ]),
            ]),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '                        2.3 ในกรณีที่กฎหมายกำหนดให้ผู้รับบริการมีหน้าที่หักภาษีเงินได้ ณ ที่จ่ายจากเงินใดๆ ที่ผู้รับบริการจ่ายให้แก่ผู้',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ให้บริการตามสัญญาฉบับนี้  ผู้รับบริการจะต้องหักภาษีเงินได้ ณ ที่จ่ายให้ถูกต้องครบถ้วน  และนำส่งต่อสรรพากรภายในระยะเวลาที่',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'กฎมายกำหนด ในการนี้ผู้รับบริการจะต้องออกหนังสือรับรองการหักภาษี ณ ที่จ่าย และส่งมอบสำเนาไว้ให้แก่ผู้ให้บริการเพื่อเป็นหลัก',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(value: 'ฐานด้วยทุกครั้งไป', font: ttf),
              ]),
            ]),
            pw.NewPage(),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value: '            ข้อ 3) ระยะเวลาของสัญญาบริการ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '            ให้ถือว่าสัญญาบริการฉบับนี้เป็นส่วนหนึ่งของสัญญาเช่าอาคารสถานที่โดยมีระยะเวลาตามระยะเวลาการเช่าของสัญญาเช่า',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'อาคาร/สถานที่ ดังนั้นในกรณีที่สัญญาเช่าอาคารสิ้นสุดลงไม่ว่าด้วยเหตุใดๆก็ตามให้ถือว่าสัญญาบริการฉบับนี้สิ้นสุดลงด้วย',
                    font: ttf),
              ]),
            ]),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            ข้อ 4) กฎระเบียบ ข้อบังคับในการใช้บริการ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '            ผู้รับบริการและบริวารตกลงและยินยอมปฏิบัติตามกฎระเบียบ  ข้อบังคับของผู้ให้บริการ  ซึ่งแสดงรายละเอียดของบริการ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'เงื่อนไข บทลงโทษ และอัตราค่าปรับใดๆ ไว้ในคู่มือผู้เช่าและผู้รับบริการในโดยไม่มีเงื่อนไข',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '            ผู้ให้บริการสงวนสิทธิในการเปลี่ยนแปลงแก้ไขกฎระเบียบ ข้อบังคับ ตามความเหมาะสม เพื่อคงไว้ซึ่งความเป็นระเบียบเรียบ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ร้อยและการให้บริการโดยรวมแก่ผู้รับบริการ  รวมถึงลูกค้าที่เข้ามาใช้บริการในศูนย์การค้าฯ  โดยจะทำการประกาศหรือแจ้งให้ทราบ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'เป็นลายลักษณ์อักษรไม่น้อยกว่า 7(เจ็ด)วัน ก่อนที่จะเริ่มใช้กฎระเบียบใหม่',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '            ทั้งนี้คู่มือผู้เช่าและผู้รับบริการ ถือเป็นส่วนหนึ่งของสัญญาบริการ  หากผู้รับบริการและบริวารฝ่าฝืนและกระทำการอันก่อให้',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'เกิดความเสียหายใดๆ  ผู้รับบริการต้องรับผิดชอบในการสูญหายหรือเสียหายใดๆ  อันอาจเกิดขึ้นแก่ผู้ให้บริการหรือลูกค้า  และหากได้',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'รับการเตือนโดยบอกกล่าวหรือลายลักษณ์อักษรแล้วผู้รับบริการและบริวารไม่กระทำการแก้ไขหรือหยุดการกระทำดังกล่าวถือว่าจงใจ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ฝ่าฝืนและกระทำการอันขัดต่อสัญญาเช่าและสัญญาบริการ  ซึ่งมีผลให้สัญญานี้สิ้นสุดลง',
                    font: ttf),
              ]),
            ]),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            ข้อ 5) การชำระค่าบริการภาษี และอากรแสตมป์',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '            ผู้รับบริการตกลงจะนำค่าบริการ  ตามระบุในข้อ2.1  ข้างต้น  ผู้รับบริการจะชำระค่าบริการให้แก่ผู้ให้บริการเป็นรายเดือน',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'พร้อมกับการชำระค่าเช่าสถานที่เช่า โดยวิธีชำระผ่านบัญชี ธนาคารกรุงไทย จำกัด (มหาชน) สาขา สี่แยกสนามบินเชียงใหม่ ชื่อบัญชี',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'บริษัท นิ่มซิตี้ เดลี่ จำกัด เลขที่บัญชี 771-0-01967-6 หรือวิธีอื่นใดตามที่ผู้ให้เช่ากำหนด',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '            โดยที่การให้บริการตามสัญญาบริการฉบับนี้มีขึ้นเพื่อให้เป็นไปตามเจตนารมณ์ของผู้รับบริการ  ตามสัญญาเช่าอาคาร/สถาน',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ที่ ดังนั้น ผู้รับบริการจึงตกลงชำระค่าตอบแทนการให้บริการตามสัญญาบริการฉบับนี้แก่ผู้ให้บริการ ตลอดระยะเวลาของสัญญาเช่าอา',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'คาร ตลอดจนยินยอมชำระค่าอากรแสตมป์ปิดสัญญาบริการ ซึ่งต้องชำระตามกฎหมายรวมทั้งภาษีมูลค่าเพิ่ม (ยกเว้นภาษีเงินได้ของผู้',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ให้บริการ) ตลอดระยะเวลาการให้บริการของสัญญาบริการฉบับนี้ หากผู้ให้บริการได้ชำระเงินต่างๆดังกล่าวไปก่อนแล้ว ผู้รับบริการจะ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ต้องชดใช้คืนแก่ผู้ให้บริการภายใน 5(ห้า) วัน นับแต่วันที่ได้รับคำบอกกล่าวจากผู้ให้บริการ',
                    font: ttf),
              ]),
              pw.SizedBox(height: 2 * PdfPageFormat.mm),
              pw.Row(children: [
                Textx(
                    value:
                        '            ผู้รับบริการตกลงจะชำระค่าบริการดังกล่าวแก่ ผู้ให้บริการตลอดระยะเวลาที่ตนยังครอบครองสถานที่ เช่าภายใต้สัญญาเช่า',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ไม่ว่าจะสิ้นสุดกำหนดระยะเวลาในการเช่าแล้วหรือไม่ก็ตาม  จนกว่าผู้รับบริการจะได้ส่งมอบการครอบครองสถานที่เช่าคืนแก่ผู้ให้บริ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(value: 'การเรียบร้อยแล้ว', font: ttf),
              ]),
            ]),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            ข้อ 6) การผิดนัดชำระค่าบริการ ค่าไฟฟ้า น้ำประปา และเงินอื่นใด',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '            หากผู้รับบริการผิดนัดชำระค่าบริการหรือเงินอื่นใดตามกำหนดในสัญญาบริการฉบับนี้  ผู้รับบริการยินยอมชำระเบี้ยปรับให้',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'แก่ผู้ให้บริการในอัตราร้อยละ 2(สอง) ต่อเดือนของจำนวนวันของจำนวนเงินที่ค้างชำระ โดยคำนวณตั้งแต่วันผิดนัดชำระจนถึงวันที่ชำ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ระครบถ้วน  และหากการผิดนัดดังกล่าวดำเนินไปเกินกว่า 30 (สามสิบ)วัน  สัญญาบริการฉบับนี้ และสัญญาเช่าอาคาร/สถานที่  เป็น',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'อันสิ้นสุดทันทีโดยผู้ให้บริการไม่จำเป็นต้องบอกกล่าวล่วงหน้า  ผู้ให้บริการมีสิทธิระงับการให้บริการทุกประการแก่ผู้รับบริการ รวมทั้ง',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'มีสิทธิเข้าไปในสถานที่เช่าเพื่อกระทำการใดๆ  ในการรักษาสิทธิของผู้ให้บริการ   ผู้รับบริการตกลงสละสิทธิในการฟ้องร้องผู้ให้บริการ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ตัวแทน หรือลูกจ้างของผู้ให้บริการทั้งทางแพ่งและทางอาญา',
                    font: ttf),
              ]),
            ]),
            pw.NewPage(),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value: '            ข้อ 7) ข้อสัญญาของผู้ให้บริการ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '            ผู้ให้บริการจะจัดให้มีบริการต่างๆ  ตามสัญญาบริการฉบับนี้ทุกวันตามเวลาเปิดบริการของศูนย์การค้านิ่มซิตี้  หรือตามเวลา',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ที่ผู้ให้บริการกำหนดตามความเหมาะสม  แต่หากผู้รับบริการมีความจำเป็นต้องการใช้บริการ นอกเหนือจากเวลาดังกล่าว  ผู้ให้บริการ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'อาจจะขยายหรือเปลี่ยนแปลงเวลาการให้บริการดังกล่าวได้  แต่ทั้งนี้ผู้ให้บริการสงวนสิทธิที่จะคิดค่าบริการในส่วนที่เพิ่มขึ้นจากผู้รับ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(value: 'บริการได้ตามความเหมาะสม', font: ttf),
              ]),
            ]),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value: '            ข้อ 8) การขัดข้องในการให้บริการ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '            ในกรณีถ้าการให้บริการ  หรือส่วนใดส่วนหนึ่งของการให้บริการภายใต้สัญญาบริการฉบับนี้ เกิดขัดข้องขึ้นไม่ว่าด้วยเหตุใดๆ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ผู้ให้บริการตกลงที่จะดำเนินการซ่อมแซมและทำให้การให้บริการดังกล่าวกลับคืนสู่สภาพดีเช่นเดิมโดยเร็ว โดยผู้รับบริการจะไม่ถือเอา',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'การขัดข้องของการให้บริการดังกล่าวเป็นเหตุในการบอกเลิกสัญญาหรือเรียกร้องค่าเสียหายใดๆ  จากผู้ให้บริการรวมทั้งพนักงานและ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(value: 'ตัวแทนของผู้ให้บริการทั้งสิ้น', font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '            การที่ผู้ให้บริการจัดให้มียามและหน่วยรักษาความปลอดภัยแก่พื้นที่ส่วนกลางนั้นมิให้ถือว่าผู้ให้บริการต้องรับผิดชอบในการ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'สูญหายหรือเสียหายใดๆอันอาจเกิดขึ้นแก่ผู้รับบริการหรือลูกค้าของผู้รับบริการ',
                    font: ttf),
              ]),
            ]),
            pw.Column(children: [
              pw.Row(children: [
                Textx(value: '            ข้อ 9) เหตุสุดวิสัย', font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '            หากการปฏิบัติหน้าที่ใดๆตามสัญญาบริการฉบับนี้ของคู่สัญญาฝ่ายใดฝ่ายหนึ่งถูกขัดขวางถูกจำกัด หรือถูกรบกวน คู่สัญญา',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ที่ได้รับผลกระทบกระเทือนจากการนั้น เมื่อได้ให้คำบอกกล่าวแก่คู่สัญญาอีกฝ่ายหนึ่งโดยทันทีแล้ว จะได้รับการยกเว้นจากการปฏิบัติ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'หน้าที่เช่นว่านั้นทั้งนี้เฉพาะเหตุจากการขัดขวาง การจำกัด หรือถูกรบกวน อันเนื่องจาก',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '            9.1 อัคคีภัย การระเบิด แผ่นดินไหว การนัดหยุดงาน การปิดงาน ข้อพิพาทแรงงาน วินาศภัย หรืออุบัติเหตุ โรคระบาด',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'อุทกภัย การขาดหรือการไม่ปฏิบัติการของแหล่งจัดหาแรงงาน กำลังไฟฟ้า หรือสัมภาระ หรือ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '            9.2 สงคราม การปฏิวัติ การก่อความไม่สงบของพลเรือนการกระทำของศัตรูการปิดเมืองท่าหรือการห้ามส่งสินค้า หรือ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '            9.3 กฎหมาย คำสั่งประกาศ ข้อบังคับ เทศบัญญัติ การเรียกร้อง หรือความต้องการใดๆของรัฐบาล หรือของหน่วยงาน เจ้า',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value: 'หน้าที่ หรือผู้แทนใดๆของรัฐบาลเช่นว่านั้น',
                    font: ttf),
              ]),
              pw.SizedBox(height: 2 * PdfPageFormat.mm),
              pw.Column(children: [
                pw.Row(children: [
                  Textx(
                      value: '            ข้อ 10) การโอนสิทธิตามสัญญา',
                      font: ttf),
                ]),
                pw.Row(children: [
                  Textx(
                      value:
                          '            ผู้รับบริการจะไม่โอนสิทธิตามสัญญาบริการฉบับนี้ไม่ว่าทั้งหมด หรือบางส่วนให้แก่บุคคลอื่น  หรือยินยอมให้บุคคลอื่นได้ใช้',
                      font: ttf),
                ]),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ประโยชน์ตามสัญญาบริการฉบับนี้ เว้นแต่จะได้รับความยินยอมเป็นลายลักษณ์อักษรจากผู้ให้บริการก่อน โดยการโอนสิทธิตามสัญญา',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'บริการฉบับนี้จะกระทำได้ต่อเมื่อผู้รับบริการได้โอนสิทธิตามสัญญาเช่าไปด้วยผู้ให้บริการ  มีสิทธิที่จะโอนสิทธิตามสัญญาบริการฉบับนี้',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ทั้งหมด  หรือบางส่วนให้กับบุคคลที่ผู้ให้บริการเห็นสมควร',
                    font: ttf),
              ]),
            ]),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Column(children: [
              pw.Row(children: [
                Textx(value: '            ข้อ 11) ข้อบังคับอื่นๆ', font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '            ผู้รับบริการตกลงที่จะปฏิบัติตามกฎระเบียบข้อบังคับต่างๆ อันเกี่ยวเนื่องกับการให้บริการและการให้บริการตามที่ได้ระบุไว้',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ในสัญญาบริการฉบับนี้ หรือตามที่ผู้ให้บริการจะได้กำหนดขึ้น',
                    font: ttf),
              ]),
            ]),
            pw.Column(children: [
              pw.Row(children: [
                Textx(value: '            ข้อ 12) การบอกเลิกสัญญา', font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '            หากในระหว่างระยะเวลาของสัญญาบริการฉบับนี้ผู้รับบริการปฏิบัติผิดข้อกำหนดข้อใดข้อหนึ่งของสัญญาบริการฉบับนี้และ',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ไม่แก้ไขให้ถูกต้องภายในกำหนดระยะเวลา  15(สิบห้า)  วัน  นับตั้งแต่มีหนังสือบอกกล่าวจากผู้ให้บริการ  ผู้ให้บริการมีสิทธิบอกเลิก',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(value: 'สัญญาบริการฉบับนี้ทันที', font: ttf),
              ]),
            ]),
            pw.NewPage(),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            เนื่องจากความเกี่ยวพันกันของสัญญาเช่าอาคาร/สถานที่และสัญญาบริการ การที่ผู้รับบริการปฏิบัติผิดสัญญาบริการฉบับนี้',
                    font: ttf)
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ย่อมถือเป็นการปฏิบัติผิดสัญญาเช่าด้วยและในทางกลับกัน  การปฏิบัติผิดสัญญาเช่า  ย่อมเป็นการปฏิบัติผิดสัญญาบริการฉบับนี้ด้วย',
                    font: ttf)
              ]),
              pw.Row(children: [Textx(value: 'เช่นกัน', font: ttf)]),
              pw.Row(children: [
                Textx(
                    value:
                        '            เมื่อสัญญาบริการฉบับนี้ถือเป็นอันยกเลิก  ผู้ให้บริการมีสิทธิระงับการให้บริการทุกประการแก่ผู้รับบริการ รวมทั้งมีสิทธิเข้า',
                    font: ttf)
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ไปในสถานที่เช่าเพื่อกระทำการใดๆ  ในการรักษาสิทธิของผู้ให้บริการ  ผู้รับบริการตกลงสละสิทธิในการฟ้องร้องผู้ให้บริการ  ตัวแทน',
                    font: ttf)
              ]),
              pw.Row(children: [
                Textx(
                    value: 'หรือลูกจ้างของผู้ให้บริการทั้งทางแพ่งและทางอาญา',
                    font: ttf)
              ]),
            ]),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Column(children: [
              pw.Row(children: [
                Textx(value: '            ข้อ 13) การบอกกล่าว', font: ttf)
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '            หนังสือบอกกล่าวหรือการติดต่อสื่อสารใดๆตามสัญญาบริการฉบับนี้  หรือที่เกี่ยวกับสัญญาบริการฉบับนี้  ให้ทำเป็นหนังสือ',
                    font: ttf)
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ลงลายมือชื่อโดยคู่สัญญาฝ่ายที่ส่งคำบอกกล่าว  หรือการติดต่อสื่อสารนั้นหรือโดยตัวแทนผู้มีอำนาจโดยชอบของคู่สัญญาดังกล่าวแล้ว',
                    font: ttf)
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'นำส่งโดยพนักงานส่งหนังสือหรือส่งทางไปรษณีย์ลงทะเบียนถึงผู้รับตามที่อยู่ในสัญญาบริการฉบับนี้  หรือที่อยู่อื่นหรือช่องทางสื่อสาร',
                    font: ttf)
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'อื่นซึ่งผู้รับได้แจ้งให้ผู้ส่งทราบเป็นลายลักษณ์อักษรแล้ว',
                    font: ttf)
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '            อนึ่ง  คำบอกกล่าวใดๆ ที่ผู้ให้บริการมีถึงผู้รับบริการ และได้ปิดโดยเปิดเผย ณ สถานที่เช่า ให้ถือว่าเป็นการส่งคำบอกกล่าว',
                    font: ttf)
              ]),
              pw.Row(children: [
                Textx(
                    value: 'โดยชอบแล้วนับตั้งแต่วันที่ได้ส่งหรือปิดไว้นั้น',
                    font: ttf)
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        '            สัญญาบริการฉบับนี้ทำขึ้นเป็น  2  ฉบับ  มีข้อความถูกต้องตรงกัน  คู่สัญญาทั้งสองฝ่ายได้อ่านและเข้าใจข้อความในสัญญา',
                    font: ttf)
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'นี้เป็นอย่างดี เห็นว่าเป็นที่ถูกต้อง ครบถ้วน เรียบร้อย ตรงตามเจตนาทุกประการปราศจากการบังคับ ขู่เข็ญ หรือสำคัญผิดแต่อย่างใด',
                    font: ttf)
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'คู่สัญญามีสติสัมปชัญญะ  ครบถ้วนสมบูรณ์ทุกประการ  จึงได้ลงลายมือชื่อ/พิมพ์ลายนิ้วมือ  และตราประทับ(ถ้ามี)  เป็นของผู้ให้',
                    font: ttf)
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'บริการ และผู้รับบริการจริง ไว้เป็นสำคัญต่อหน้าพยาน ในวัน และ ณ สถานที่ดังกล่าวข้างต้น',
                    font: ttf)
              ]),
            ]),

            pw.SizedBox(height: 14 * PdfPageFormat.mm),
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
                                : '$Form_bussshop โดย $Form_bussscontact',
                            font: ttf,
                          ),
                          pw.SizedBox(height: 2 * PdfPageFormat.mm),
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
      return '/ 1.2 การให้บริการ..';
    case 2:
      return '/ ข้อ 3) ระยะเวลา..';
    case 3:
      return '/ ข้อ 7) ข้อสัญญา..';
    case 4:
      return '/ เนื่องจากความ..';
    default:
      return ''; // หน้าอื่นไม่แสดงข้อความ (หรือจะใส่ default text ก็ได้)
  }
}
