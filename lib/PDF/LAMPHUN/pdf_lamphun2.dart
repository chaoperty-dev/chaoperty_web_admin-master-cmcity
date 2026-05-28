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

class Pdfgen_Agreementlamphun2 {
//////////---------------------------------------------------->( **** เอกสารสัญญาเช่าอาคารพาณิชย์  )

  static void exportPDF_Agreementlamphun2(
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
    teNantModels,
    contractPhotoModels,
    FormName1_choice,
    FormName2_choice,
    FormName3_choice,
    FormName4_choice,
  ) async {
    ////

    final pdf = pw.Document();
    // final fontData = await rootBundle.load("ThaiFonts/Sarabun-Medium.ttf");
    // var dataint = fontData.buffer
    //     .asUint8List(fontData.offsetInBytes, fontData.lengthInBytes);
    // final PdfFont font = PdfFont.of(pdf, data: dataint);
    final font = await rootBundle.load("fonts/THSarabunNew.ttf");
    final fontBold = await rootBundle.load('fonts/SarabunBold.ttf');
    var Colors_pd = PdfColors.black;

    final ttf = pw.Font.ttf(font);
    final ttfBold = pw.Font.ttf(fontBold);
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

    final remarkList = teNantModels.where((item) => item.remark != '').toList();
    final remark = remarkList.isNotEmpty ? remarkList.first.remark : '-';

    final filteredListchao = quotxSelectModels
        .where(
            (item) => (item.dtype ?? '').trim() == "KR" && item.expser == '1')
        .toList();
    final totalchaoNumber = filteredListchao.fold<double>(
      0.00,
      (double sum, dynamic item) =>
          sum + (item.pvat != null ? double.parse(item.pvat!) : 0.00),
    ); // ค่าเช่า เดือนละ (ตัวเลข)
    final totalchao =
        nFormat.format(totalchaoNumber); // ค่าเช่า เดือนละ (String)

    final filteredListpakan = quotxSelectModels
        .where((item) => (item.dtype ?? '').trim() == "KD")
        .toList();
    final totalpakanNumber = filteredListpakan.fold<double>(
      0.00,
      (double sum, dynamic item) =>
          sum + (item.pvat != null ? double.parse(item.pvat!) : 0.00),
    );
    final totalpakan = nFormat.format(totalpakanNumber);

    pw.Widget Textx({
      // required String label,
      required String value,
      // int dotLength = 40,
      required pw.Font font,
      double fontSize = 12.5,
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

    pw.Widget Textr({
      // required String label,
      required String value,
      // int dotLength = 40,
      required pw.Font font,
      double fontSize = 12.5,
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

    pw.Widget labeledLine({
      required String value,
      required pw.Font font,
      double fontSize = 12.5,
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
      double fontSize = 12.5,
      required int flex,
      PdfColor? color,
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
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
          ));
    }

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

    DateTime? parseThaiDateFlexible(String input) {
      try {
        // รองรับ yyyy-MM-dd, dd-MM-yyyy, dd/MM/yyyy
        if (input.contains('-')) {
          final parts = input.split('-');
          if (parts.length == 3) {
            // ถ้า year อยู่หน้าสุด
            if (parts[0].length == 4) {
              return DateTime(
                int.parse(parts[0]),
                int.parse(parts[1]),
                int.parse(parts[2]),
              );
            } else {
              // day-month-year
              return DateTime(
                int.parse(parts[2]),
                int.parse(parts[1]),
                int.parse(parts[0]),
              );
            }
          }
        } else if (input.contains('/')) {
          final parts = input.split('/');
          if (parts.length == 3) {
            return DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        }
        // fallback: parse แบบปกติ
        return DateTime.parse(input);
      } catch (e) {
        return null;
      }
    }

    // แยกตัวแปรวันที่แบบไทยออกมาใช้ได้
    Map<String, dynamic>? getThaiDateComponents(String input) {
      final dt = parseThaiDateFlexible(input);
      if (dt == null) return null;
      return {
        'day': dt.day,
        'monthName': thaiMonths[dt.month],
        'yearBE': dt.year + 543,
      };
    }

    // รูปแบบ: วันที่ 1 เดือน มกราคม พ.ศ. 2568
    String formatThaiDate(String input) {
      final components = getThaiDateComponents(input);
      if (components == null) return input;
      return 'วันที่ ${components['day']} เดือน ${components['monthName']} พ.ศ. ${components['yearBE']}';
    }

    // รูปแบบ: 1 มกราคม 2568
    String formatThaiDateS(String input) {
      final components = getThaiDateComponents(input);
      if (components == null) return input;
      return '${components['day']} ${components['monthName']} ${components['yearBE']}';
    }

    // ดึงข้อมูลวันที่แบบแยกส่วนเพื่อใช้ใน PDF
    final Datex = getThaiDateComponents(Datex_text.text); // สำหรับวันที่ทำสัญญา
    final DateStart =
        getThaiDateComponents(Form_sdate); // สำหรับวันที่เริ่มสัญญา
    final DateEnd =
        getThaiDateComponents(Form_ldate); // สำหรับวันที่สิ้นสุดสัญญา

    final Namex = 'นางสาว สุราทิน ลาพิงค์'; // ผู้ให้เช่า
    final Name1 = 'นาง รุจิกาญจน์ รัตนนันท์พงษ์'; // พยาน1
    final Name2 = 'นางสาว นิตยา ญาณพันธ์'; // พยาน2

///////////////////////------------------------------------------------->
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginBottom: 30.00,
          marginLeft: 30.00,
          marginRight: 30.00,
          marginTop: 30.00,
        ),

        build: (context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                Textx(
                    value: 'สัญญาเช่าอาคารพาณิชย์',
                    font: ttf,
                    fontSize: font_Size + 4),
              ],
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Row(
                      children: [
                        Textx(
                          value: 'สัญญาเลขที่ ',
                          font: ttf,
                        ),
                        pw.Container(
                            width: 100,
                            child: labeledLine1(
                                value: Get_Value_cid, font: ttf, flex: 1)),
                      ],
                    ),
                    Textx(
                      value: '$bill_name',
                      font: ttf,
                      textAlign: pw.TextAlign.right,
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    Textx(
                      value: '$bill_addr',
                      font: ttf,
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                Textx(value: 'วันที่', font: ttf),
                pw.Container(
                  child: labeledLine1(
                      value: '${Datex?['day']}', font: ttf, flex: 1),
                ),
                Textx(value: 'เดือน', font: ttf),
                pw.Container(
                  child: labeledLine1(
                      value: '${Datex?['monthName']}', font: ttf, flex: 2),
                ),
                Textx(value: 'พ.ศ.', font: ttf),
                pw.Container(
                  child: labeledLine1(
                      value: '${Datex?['yearBE']}', font: ttf, flex: 1),
                )
              ],
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Row(children: [
              Textx(value: '${' ' * 24}สัญญานี้ทำขึ้นโดย', font: ttf),
              labeledLine1(value: Form_nameshop, font: ttf, flex: 1),
              Textx(value: 'เลขประจําตัว', font: ttf),
              labeledLine1(value: Form_tax, font: ttf, flex: 1),
            ]),
            pw.Row(children: [
              Textx(value: 'อยู่บ้านเลขที่', font: ttf),
              labeledLine1(value: Form_address, font: ttf, flex: 1),
            ]),
            pw.Row(children: [
              Textx(value: 'โทรศัพท์ (มือถือ)', font: ttf),
              labeledLine1(value: Form_tel, font: ttf, flex: 1),
              Textx(
                  value:
                      'ซึ่งต่อไปนี้ในสัญญานี้เรียกว่า “ผู้เช่า” ไว้ให้แก่ ${bill_name} เลขทะเบียน ${bill_tax}',
                  font: ttf),
            ]),
            Textx(value: 'ซึ่งต่อไปนี้สัญญาเรียกว่า “ผู้ให้เช่า”', font: ttf),
            Textx(value: '${' ' * 24}มีรายละเอียดสัญญาดังนี้', font: ttf),
            pw.Row(children: [
              Textx(
                  value:
                      '${' ' * 24}ข้อ 1. ผู้เช่าตาลงเช่าและให้ผู้เช่าตกลงให้เช่า อาคารพาณิชย์',
                  font: ttf),
              labeledLine1(
                  value: ' - ', font: ttf, flex: 1, color: PdfColors.white),
              Textx(value: 'คูหา เลขที่', font: ttf),
              labeledLine1(
                  value: ' - ', font: ttf, flex: 1, color: PdfColors.white),
              Textx(value: 'หมู่ที่ 18 ตำบลป่าสัก อำเภอเมืองลำพูน', font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      'เพื่อประกอบกิจการค้าอันเป็นกิจการค้าของผู้เช่า ประเภทกิจการ',
                  font: ttf),
              labeledLine1(value: Form_typeshop, font: ttf, flex: 2),
              Textx(value: 'มีกำหนด', font: ttf),
              labeledLine1(value: Form_period, font: ttf, flex: 1),
              Textx(value: 'เดือน ', font: ttf),
            ]),
            pw.Row(children: [
              Textx(value: 'นับตั้งแต่วันที่ ', font: ttf),
              pw.Container(
                child: labeledLine1(
                    value: formatThaiDateS(Form_sdate), font: ttf, flex: 1),
              ),
              Textx(value: 'ถึงวันที่ ', font: ttf),
              pw.Container(
                child: labeledLine1(
                    value: formatThaiDateS(Form_ldate), font: ttf, flex: 1),
              ),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      '${' ' * 24}ผู้เช่าได้ตรวจดูอาคารที่เช่านี้แล้ว พอใจในสถาพของที่เช่าตามที่ปรากฏ และได้รับมอบอาคารที่เช่าจากผู้เช่าจากผู้ให้เช่าแล้วนับตั้งแต่วันทำสัญญานี้',
                  font: ttf),
            ]),
            Textx(value: 'เป็นต้นไป', font: ttf),
            pw.Row(children: [
              Textx(
                  value:
                      '${' ' * 24}ข้อ 2 ผู้เช่าและผู้ให้เช่าตกลงค่าเช่ากันในอัตราเดือนละ',
                  font: ttf),
              labeledLine1(value: totalchao, font: ttf, flex: 1),
              Textx(value: 'บาท', font: ttf),
              labeledLine1(
                  value: '( ${convertToThaiBaht(double.parse(totalchao))} )',
                  font: ttf,
                  flex: 1)
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      'โดยผู้เช่าตกลงจะชำระค่าเช่าให้กับผู้ให้เช่าภายในวันที่ 1 - 10 ของเดือน ณ ที่สำนักงานของผู้ให้เช่า ผู้ให้เช่าจะออกหลักฐานใบเสร็จรับเงินแก่ผู้เช่าทุกครั้ง ผู้เช่าและผู้ให้',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      'เช่าตกลงให้ถือว่า ใบเสร็จรับเงินค่าเช่าออกโดยผู้ให้เช่าเท่านั้นที่ถือเป็นหลักฐานการชำระค่าเช่าโดยสมบูรณ์ในกรณีที่ผู้เช่าผิดนัดโดยไม่ชำระค่าเช่าตามที่กำหนดและภาย',
                  font: ttf)
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      'ในเวลาที่ได้ระบุไว้ในวรรคก่อน  หรือกรณีที่ผู้เช่าไม่มาขายสินค้าใน  "พื้นที่เช่า"  เมื่อผู้ให้เช่ามีหนังสือแจ้งเตือนผู้เช่าให้ชำระค่าเช่าค่าเช่าหรือให้กลับมาขายสินค้าภายใน',
                  font: ttf)
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      'เวลาที่ผู้ให้เช่ากำหนดแล้ว ผู้เช่ายังไม่ชำระค่าเช่าหรือไม่กลับมาขายสินค้า ให้ถือว่าสัญญาเช่านี้เป็นอันสิ้นสุดลง',
                  font: ttf)
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      '${' ' * 24}ข้อ 3 ในวันสัญญานี้ ผู้เช่าได้วางเงินประกันค่าเสีนหายแก่ผู้ให้เช่าเป็นจำนวน',
                  font: ttf),
              labeledLine1(value: totalpakan, font: ttf, flex: 1),
              Textx(value: 'บาท', font: ttf),
            ]),
            pw.Row(children: [
              labeledLine1(
                  value: '( ${convertToThaiBaht(double.parse(totalpakan))} )',
                  font: ttf,
                  flex: 2),
              Textx(
                  value:
                      'เงินประกันดังกล่าวถือเป็นเงินประกันค่าเสีนหาย ที่ผู้เช่าหรือบริวารของผู้เช่าก่อขึ้นแก่อาคารที่เช่า',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      'หรือค่าเสียหายอื่นๆ อันเกี่ยวแก่สัญญาเช่า รวมทั้งเป็นประกันค่าเช่าที่ผู้เช่าค้างชำระ ตามสัญญาเช่าฉบับนี้ด้วย',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      '${' ' * 24}ผู้เช่าไม่มีสิทธิขอหักเงินประกันชำระค่าเช่าชำระหนี้แก่ผู้ให้เช่า เงินประกันดังกล่าว ผู้ให้เช่าจะคืนให้ผู้เช่าต่อเมื่อ สัญญาเช่าสิ้นสุดลง และได้หักชำระ',
                  font: ttf),
            ]),
            Textx(
                value: 'ค่าเสียหาย หรือค่าเช่าค้างชำระดังกล่าวแล้ว', font: ttf),
            pw.Row(children: [
              Textx(
                  value:
                      '${' ' * 24}ข้อ 4. ห้ามมิให้ผู้เช่านำอาคารที่เช่าแม้แต่ส่วนหนึ่งส่วนใด ออกให้ผู้อื่นเช่าหรือช่วงโอนสิทธิการเช่าให้แก่บุคคลอื่นเว้นแต่จะได้รับความยินยอมตกลง',
                  font: ttf),
            ]),
            Textx(value: 'เป็นหนังสือจากผู้ให้เช่า', font: ttf),
            pw.Row(children: [
              Textx(
                  value:
                      '${' ' * 24}ข้อ 5. หากผู้เช่าจะดำเนินการแก้ไขปรับปรุงแต่งเติมหรือกระทำการใดๆต่ออาคารที่เช่า ผู้เช่าต้องแจ้งให้ผู้ให้เช่าทราบเป็นลายลักษณ์อักษรและผู้เช่า',
                  font: ttf),
            ]),
            Textx(
                value:
                    'ต้องได้รับอนุญาตเป็นรายลักษณ์อักษรผู้ให้เช่าก่อน ผู้เช่าถึงจะดำเนินการได้',
                font: ttf),
            pw.Row(children: [
              Textx(
                  value:
                      '${' ' * 24}ข้อ 6. ผู้เช่าจะต้องรักษาอาคารที่เช่าตามสัญญานี้ เสมือนหนึ่งเป็นทรัพย์สินของผู้เช่าเอง การตกแต่งอาคารที่เช่าแม้จะเป็นกรณีที่ผู้เช่าสามารถทำได้',
                  font: ttf),
            ]),
            Textx(
                value:
                    'โดยไม่ต้องขออนุญาต เพราะไม่ต้องเข้ากรณีตามสัญญาข้อ 5 แต่ผู้เช่าก็จะต้องแจ้งผู้ให้เช่าให้ทราบก่อนทุกครั้ง',
                font: ttf),
            pw.Row(children: [
              Textx(
                  value:
                      '${' ' * 24}ข้อ 7. ผู้เช่าเป็นผู้ออกค่าภาษีที่ดินและสิ่งปลูกสร้าง  ภาษีป้าย  ค่าน้ำประปา  ค่าไฟฟ้า  ใช้เป็นส่วนกลางรวมทั้งค่าใช้จ่ายอื่นๆ อันเนื่องมาจากการใช้',
                  font: ttf),
            ]),
            Textx(
                value:
                    'อาคารที่เช่า ตลอดเวลาครอบครองที่เช่า จนกว่าจะออกไปและส่งมอบอาคารที่เช่าคืนแก่ผู้ให้เช่าหากผู้เช่าผิดสัญญาไม่ชำระเงินต่างๆตามสัญญาข้อนี้ ถือว่าผู้เช่าผิดสัญญาเช่าในข้อสำคัญ',
                font: ttf),
            pw.Row(children: [
              Textx(
                  value:
                      '${' ' * 24}ข้อ 8. หากผู้เช่าประสงค์จะเช่าอาคารที่เช่านี้ต่อไป  ผู้เช่าต้องแจ้งความประสงค์ให้ผู้ให้เช่าทราบอย่างช้า 3 เดือนก่อนครบกำหนดสัญญาเช่า  เพื่อทั้ง',
                  font: ttf),
            ]),
            Textx(
                value:
                    'สองฝ่ายจะได้ทำความตกลง กำหนดข้อสัญญาเช่ากันใหม่ มิฉะนั้น ผู้เให้เช่าสามารถนำอาคารที่เช่าออกให้บุคคลอื่นเช่าได้ทันที',
                font: ttf),
            pw.Row(children: [
              Textx(
                  value:
                      '${' ' * 24}ข้อ 9. หากผู้เช่าผิดนัดชำระค่าเช่าแม้แต่งวดใด หรือผิดสัญญานี้แม้แต่ข้อหนึ่งข้อใด ผู้ให้เช่ามีสิทธิบอกเลิกสัญญาเช่าได้ทันทีโดยไม่ต้องบอกกล่าวก่อน',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      '${' ' * 24}ข้อ 10. ผู้เช่าจะไม่ทำการหรือยินยอมให้มีการกระทำการใดๆ ใน "พื้นที่เช่า" อันเป็นการขัดต่อกฎหมาย  ขัดต่อความสงบเรียบร้อยหรือศิลธรรมอันดี',
                  font: ttf),
            ]),
            Textx(
                value:
                    'หรือก่อให้เกิดความเดือดร้อนรำคาญแก่ผู้เช่า "พื้นที่เช่า" คนอื่นๆ หรือแก่ผู้ใกล้เคียง',
                font: ttf),
            pw.Row(children: [
              Textx(
                  value:
                      '${' ' * 24}ข้อ 11. เมื่อครบกำหนดสัญญาเช่า หรือสัญญาเช่าสิ้นสุดลงในกรณีอื่น ผู้เช่าจะต้องขนย้ายทรัพย์สินและบริวารของผู้เช่าออกไปจากอาคารที่เช่าทันที',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      'ในกรณีที่ผู้เช่ายังค้างชำระ หรือมีความเสียหายใดๆที่ผู้เช่าจะต้องรับผิดต่อให้ผู้เช่า ผู้เช่ามีสิทธิหักเงินประกันก่อนคืนส่วนที่เหลือผู้เช่า  หากเงินประกันไม่พอหัก ผู้ให้เช่ามี',
                  font: ttf),
            ]),
            Textx(
                value: 'สิทธ์เรียกผู้ให้เช่าจ่ายส่วนที่ขาดได้ทันที', font: ttf),
            pw.Spacer(),
            pw.Align(
              alignment: pw.Alignment.bottomRight,
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  Textx(
                    value: '${'...' * 30} ผู้เช่า   ',
                    font: ttf,
                  ),
                  pw.SizedBox(height: 2 * PdfPageFormat.mm),
                  Textx(
                    value: '${'...' * 30} ผู้ให้เช่า',
                    font: ttf,
                  ),
                ],
              ),
            ),
            pw.NewPage(),
            pw.Row(children: [
              Textx(
                  value:
                      '${' ' * 24}ข้อ 12. เมื่อสัญญาเช่าสิ้นสุดลงเพราะครบกำหนดเวลาเช่า หรือมีการยกเลิกสัญญา หรือในกรณีอื่นๆ ผู้เช่ายินยอมให้ผู้ให้เช่าเข้าไปตรวจตราสภาพ',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      'อาคารที่เช่า หรือกลับเข้าครอบครองอาคารที่เช่าได้ทันที ในกรณีที่ผู้เช่าทิ้งที่เช่า ผู้ให้เช่ามีสิทธ์เข้าไปในอาคารที่เช่าโดยใช้กุญแจสำรอง หรือทำลายกุญแจหรือเครื่องกีด',
                  font: ttf),
            ]),
            Textx(
                value:
                    'ขวางที่ผู้เช่าทำไว้เพื่อเข้าตรวจสอบความเสียหายและเข้าไปครอบครองที่เช่า',
                font: ttf),
            Textx(
                value:
                    '${' ' * 24}เมื่อสัญญาเช่าสิ้นสุดลงดังกล่าว ผู้ให้เช่ามีสิทธิ์เลิกหรือแจ้งเลิกการใช้น้ำประปาและไฟฟ้า สำหรับอาคารที่เช่าทันที',
                font: ttf),
            pw.Row(children: [
              Textx(
                  value:
                      '${' ' * 24}เมื่อสัญญาเช่าสิ้นสุดลงดังกล่าว   หากผู้เช่าไม่ยอมขนย้ายทรัพย์สิน    หรือบริวารของผู้เช่าออกไปจากอาคารที่เช่า   ผู้เช่าจะต้องเสียค่าปรับวันละ',
                  font: ttf),
            ]),
            pw.Row(children: [
              pw.Container(
                child: labeledLine1(value: ' 1,000 ', font: ttf, flex: 1),
              ),
              Textx(value: 'บาท', font: ttf),
              pw.Container(
                child: labeledLine1(
                    value: '( หนึ่งพันบาทถ้วน )', font: ttf, flex: 1),
              ),
              Textx(value: 'จนกว่าจะออก', font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      '${' ' * 24}ข้อ 13. หนี้เงินซึ่งผู้เช่าและผู้ให้เช่าจะต้องรับผิดชอบต่อกันตามสัญญานี้ คู่สัญญาตกลงให้คิดดอกเบี้ย  แก่กันได้ร้อยละ 15 ต่อปีนับตั้งแต่วันผิดนัด',
                  font: ttf),
            ]),
            Textx(value: 'หรือวันที่จะต้องชำระแก่กันเป็นต้นไป', font: ttf),
            pw.Row(children: [
              Textx(
                  value:
                      '${' ' * 24}สัญญานี้ทำขึ้นเป็นสองฉบับมีความตรงกัน คู่สัญญาทั้งสองฝ่ายได้อ่านข้อความในสัญญานี้ เป็นอย่างดีแล้วเห็นว่าตรงกับความประสงค์ของตน จึงได้',
                  font: ttf),
            ]),
            Textx(value: 'ลงลายมือชื่อไว้เป็นหลักฐาน ต่อหน้าพยาน', font: ttf),
            pw.SizedBox(height: 20 * PdfPageFormat.mm),
            pw.Spacer(),
            pw.Row(children: [
              if (_verticalGroupValue == 'องค์กร/นิติบุคคล') ...[
                pw.Expanded(
                  flex: 1,
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      Textx(
                        value: 'ลงชื่อ${'...' * 30} ผู้เช่า',
                        font: ttf,
                      ),
                      Textx(
                        value: (Form_bussscontact.toString().isNotEmpty)
                            ? '(  $Form_bussscontact  )'
                            : '(${'...' * 30})',
                        font: ttf,
                      ),
                      if (_verticalGroupValue == 'องค์กร/นิติบุคคล')
                        Textx(
                          value: (Form_nameshop.toString().isNotEmpty)
                              ? '  $Form_nameshop  '
                              : '',
                          font: ttf,
                        ),
                      pw.SizedBox(height: 6 * PdfPageFormat.mm),
                      Textx(
                        value: 'ลงชื่อ${'...' * 30} ผู้ให้เช่า',
                        font: ttf,
                      ),
                      Textx(
                        value: '$bill_name โดย',
                        font: ttf,
                      ),
                      Textx(
                        value: '(  $FormName1_choice  )',
                        font: ttf,
                      ),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      Textx(
                        value: 'ลงชื่อ${'...' * 30} พยาน',
                        font: ttf,
                      ),
                      Textx(
                        value: '(  $FormName3_choice  )',
                        font: ttf,
                      ),
                      Textx(
                        value: '$bill_name',
                        font: ttf,
                      ),
                      pw.SizedBox(height: 6 * PdfPageFormat.mm),
                      Textx(
                        value: 'ลงชื่อ${'...' * 30} พยาน',
                        font: ttf,
                      ),
                      Textx(
                        value: '(  $FormName4_choice  )',
                        font: ttf,
                      ),
                      Textx(
                        value: '$bill_name',
                        font: ttf,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                pw.Expanded(flex: 1, child: pw.SizedBox()),
                pw.Expanded(
                  flex: 1,
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      Textx(
                        value: 'ลงชื่อ${'...' * 30} ผู้เช่า',
                        font: ttf,
                      ),
                      Textx(
                        value: (Form_bussscontact.toString().isNotEmpty)
                            ? '(  $Form_bussscontact  )'
                            : '(${'...' * 30})',
                        font: ttf,
                      ),
                      pw.SizedBox(height: 6 * PdfPageFormat.mm),
                      Textx(
                        value: 'ลงชื่อ${'...' * 30} ผู้ให้เช่า',
                        font: ttf,
                      ),
                      Textx(
                        value: '$bill_name โดย',
                        font: ttf,
                      ),
                      Textx(
                        value: '(  $FormName1_choice  )',
                        font: ttf,
                      ),
                      Textx(
                        value: 'ลงชื่อ${'...' * 30} พยาน',
                        font: ttf,
                      ),
                      Textx(
                        value: '(  $FormName3_choice  )',
                        font: ttf,
                      ),
                      Textx(
                        value: '$bill_name',
                        font: ttf,
                      ),
                      pw.SizedBox(height: 6 * PdfPageFormat.mm),
                      Textx(
                        value: 'ลงชื่อ${'...' * 30} พยาน',
                        font: ttf,
                      ),
                      Textx(
                        value: '(  $FormName4_choice  )',
                        font: ttf,
                      ),
                      Textx(
                        value: '$bill_name',
                        font: ttf,
                      ),
                    ],
                  ),
                ),
              ],
            ]),
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
            Get_Value_cid: Get_Value_cid,
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
