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

class Pdfgen_Agreementlamphun {
//////////---------------------------------------------------->( **** เอกสารสัญญาเช่า ปกติ  )

  static void exportPDF_Agreementlamphun(
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
      contractPhotoModels) async {
    ////

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
    final Name2_ = 'นางสาว นิตยา ญาณพันธ์'; // พยาน2

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
                    value: 'สัญญาเช่าพื้นที่เช่าในตลาดลำพูนจตุจักร',
                    font: ttf,
                    fontSize: font_Size + 4),
              ],
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    Textx(
                      value: 'สัญญาเช่านี้ทำขึ้นที่ $renTal_name',
                      font: ttf,
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
              Textx(value: '${' ' * 24}ข้าพเจ้า', font: ttf),
              labeledLine1(value: Form_nameshop, font: ttf, flex: 1),
              Textx(value: 'เลขประจําตัวผู้เสียภาษี', font: ttf),
              labeledLine1(value: Form_tax, font: ttf, flex: 1),
            ]),
            pw.Row(children: [
              Textx(value: 'ปัจจุบันอยู่บ้านเลขที่', font: ttf),
              labeledLine1(value: Form_address, font: ttf, flex: 1),
            ]),
            pw.Row(children: [
              Textx(value: 'โทรศัพท์บ้าน', font: ttf),
              labeledLine1(value: '-', font: ttf, flex: 1),
              Textx(value: 'โทรศัพท์ (มือถือ)', font: ttf),
              labeledLine1(value: Form_tel, font: ttf, flex: 1),
              Textx(value: 'ซึ่งต่อไปนี้ในสัญญานี้เรียกว่า', font: ttf),
            ]),
            pw.Row(
              children: [
                Textx(
                    value:
                        '“ผู้เช่า”  ฝ่ายหนึ่ง ขอทำสัญญาเช่านี้ไว้แก่  บริษัท ลำพูนจตุจักร จำกัด โดย $Namex ผู้จัดการฝ่ายสถานที่  ผู้มีอำนาจลงนามผูกพันบริษัทฯ   ซึ่งต่อไปนี้',
                    font: ttf),
              ],
            ),
            Textx(value: 'สัญญาเรียกว่า “ผู้ให้เช่า” อีกฝ่ายหนึ่ง', font: ttf),
            Textx(value: '${' ' * 24}มีข้อความดังนี้', font: ttf),
            Textx(value: '${' ' * 24}ข้อ 1 ทรัพย์สินที่ให้เช่า', font: ttf),
            pw.Row(children: [
              Textx(
                  value:
                      '${' ' * 24}ผู้ให้เช่าตาลงให้เช่าและผู้เช่าตกลงเช่า   พื้นที่ส่วนหนึ่งในตลาดลำพูนจตุจักร   เป็นพื้นที่เช่า   ซึ่งต่อไปในสัญญาเรียกว่า  “ห้องเช่า”  หมายเลขล็อค',
                  font: ttf),
            ]),
            pw.Row(children: [
              labeledLine1(value: Form_ln, font: ttf, flex: 1),
              Textx(value: 'ขนาด', font: ttf),
              labeledLine1(value: Form_area, font: ttf, flex: 1),
              Textx(value: 'จำนวน', font: ttf),
              labeledLine1(value: Form_qty, font: ttf, flex: 1),
              Textx(value: 'ล็อค เนื้อที่รวม', font: ttf),
              labeledLine1(value: ' - ', font: ttf, flex: 1),
              Textx(value: 'ตารางเมตร', font: ttf),
            ]),
            Textx(
                value: '${' ' * 24}ข้อ 2 วัตถุที่ประสงค์และระยะเวลาการเช่า',
                font: ttf),
            pw.Row(children: [
              Textx(
                  value:
                      '${' ' * 24}ผู้ให้เช่าตกลงให้เช่าพื้นที่ตามที่กล่าวไว้ในข้อ 1 เพื่อให้ผู้เช่าใช้เป็นสถานที่ในการวางขายสินค้าประเภท',
                  font: ttf),
              labeledLine1(value: Form_typeshop, font: ttf, flex: 1),
            ]),
            pw.Row(children: [
              Textx(
                  value: 'ของผู้เช่า มีกำหนดเวลานับตั้งแต่ วันที่', font: ttf),
              labeledLine1(
                  value: formatThaiDateS(Form_sdate), font: ttf, flex: 1),
              Textx(value: 'ถึงวันที่', font: ttf),
              labeledLine1(
                  value: formatThaiDateS(Form_ldate), font: ttf, flex: 1),
              Textx(value: 'ในอัตราเดือนละ', font: ttf),
              labeledLine1(value: totalchao, font: ttf, flex: 1),
              Textx(value: 'บาท', font: ttf),
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
            Textx(
                value: '${' ' * 24}ข้อ 3 ผู้เช่าขอสัญญาแก่ผู้ให้เช่าว่า',
                font: ttf),
            Textx(
                value:
                    '${' ' * 24}3.1 ผู้เช่าจะไม่ทำการแต่งเติม หรือดัดแปลง "พื้นที่เช่า" เว้นแต่จะได้รับความยินยอมเป็นลายลักษณ์อักษรจากผู้ให้เช่า',
                font: ttf),
            Textx(
                value:
                    '${' ' * 30}3.1.1 ในกรณีผู้ให้เช่ายินยอม ผู้เช่าต้องปฏิบัติดังนี้',
                font: ttf),
            pw.Row(children: [
              Textx(
                  value:
                      '${' ' * 30}(ก) ผู้เช่าจะต้องไม่ทำการแต่งเติม หรือดัดแปลง "พื้นที่เช่า" ฝ่าฝืนต่อข้อบัญญัติขององค์การบริหารส่วนท้องถิ่นหรือข้อบังคับของสาธารณสุขหรือ',
                  font: ttf),
            ]),
            Textx(value: 'กฏหมายอื่นใดที่เกี่ยวข้อง', font: ttf),
            pw.Row(children: [
              Textx(
                  value:
                      '${' ' * 30}(ข) ผู้เช่าจะไม่ก่อให้เกิดความเสียหายแก่อาคารหรืออุปกรณ์ต่าง  ๆ   ที่ผู้ให้เช่าได้ติดตั้งไว้หรือทำให้ทรัพย์สินของผู้เช่ารายอื่นหรือทรัพย์สินของ',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      'บุคคลอื่นที่นำเข้ามาในบริเวณตลาดเสียหาย หากผู้เช่าก่อให้เกิดความเสียหายขึ้นผู้เช่าจะต้องรับผิดชอบความเสียหายนั้น',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      '${' ' * 30}3.1.2 ในกณีที่ผู้ให้เช่ามิได้ยินยอมแต่ผู้เช่าฝ่าฝืนทำการแต่งเติม ดัดแปลง "พื้นที่เช่า" เมื่อผู้ให้เช่าพบและแจ้งให้ผู้เช่ารื้อถอนส่วนที่ต่อเติมดังแปลง',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      'นั้นแล้วผู้เช่าจะต้องปฏิบัติตามคำสั่งของผู้ให้เช่าภายในเวลาที่กำหนด  โดยผู้เช่าจะต้องเป็นผู้ออกค่าใช้จ่ายเองเอง   ทั้งยังจะต้องรับผิดต่อผู้ให้เช่าในความเสียหายที่เกิดขึ้น',
                  font: ttf),
            ]),
            Textx(value: 'เพราะการฝ่าฝืนนั้น', font: ttf),
            pw.Row(children: [
              Textx(
                  value:
                      '${' ' * 24}3.2 ผู้เช่าจะไม่โอนสิทธิการเช่า "พื้นที่เช่า" แก่บุคคลอื่น หรือนำ "พื้นที่เช่า" ออกให้บุคคลอื่นเช่าช่วงไม่ว่าทั้งหมดหรือแต่บางส่วน ถ้าผู้เช่าผิดสัญญาข้อ',
                  font: ttf),
            ]),
            Textx(value: 'นี้ให้สัญญาเช่าเป็นอันสิ้นสุดลง', font: ttf),
            pw.Row(children: [
              Textx(
                  value:
                      '${' ' * 24}3.3 ผู้เช่าจะไม่ทำการหรือยินยอมให้มีการกระทำใดๆ ใน "พื้นที่เช่า" อันเป็นการขัดต่อกฎหมาย ขัดต่อความสงบเรียบร้อยหรือศิลธรรมอันดีหรือก่อให้',
                  font: ttf),
            ]),
            Textx(
                value:
                    'เกิดความเดือดร้อนรำคาญแก่ผู้เช่า "พื้นที่เช่า" คนอื่นๆ หรือแก่ผู้อยู่ใกล้เคียง',
                font: ttf),
            Textx(
                value:
                    '${' ' * 24}3.4 ผู้เช่าจะปฏิบัติตามกฏ ระเบียบ ข้อบังคับของตลาดลำพูนจตุจักร โดยเคร่งครัด',
                font: ttf),
            Textx(
                value: '${' ' * 24}ข้อ 4 ค่าใช้จ่ายต่าง ๆ ในที่เช่า',
                font: ttf),
            pw.Row(children: [
              Textx(
                  value:
                      '${' ' * 24}ผู้เช่าตกลงจะเป็นผู้ชำระค่าไฟฟ้า  ค่าน้ำประปา  ค่าภาษีที่ดินและสิ่งปลูกสร้าง  ค่าบำรุงรักษา  และค่าจัดการใดๆ  ของตลาดตลอดอายุการเช่าตาม',
                  font: ttf),
            ]),
            Textx(
                value: 'สัญญานี้ หรือตลอดเวลาที่ผู้เช่ายังไม่ออกไปจากที่เช่า',
                font: ttf),
            Textx(
                value:
                    '${' ' * 24}ข้อ 5 ผู้ให้เช่ามีสิทธิเข้าไปตรวจตราสถานที่เช่า',
                font: ttf),
            Textx(
                value:
                    '${' ' * 24}ผู้เช่าตกลงยินยอมให้ผู้ให้เช่าหรือตัวแทนของผู้ให้เช่าเข้าไปตรวจตรา "พื้นที่เช่า" ที่เช่านี้ได้ตลอดเวลา',
                font: ttf),
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
                  pw.SizedBox(height: 2 * PdfPageFormat.mm),
                  Textx(
                    value: '${'...' * 30} พยาน  ',
                    font: ttf,
                  ),
                  pw.SizedBox(height: 2 * PdfPageFormat.mm),
                  Textx(
                    value: '${'...' * 30} พยาน  ',
                    font: ttf,
                  ),
                ],
              ),
            ),
            pw.NewPage(),
            Textx(value: '${' ' * 24}ข้อ 6 กรณีผู้ให้เช่าเลิกสัญญา', font: ttf),
            Textx(
                value:
                    '${' ' * 24}ในกรณีที่ผู้เช่าผิดสัญญาข้อหนึ่งข้อใดหรือหลายข้อก็ดี  ผู้ให้เช่ามีสิทธิบอกเลิกสัญญาได้ทันที  โดยไม่จำเป็นต้องบอกกล่าวให้ปฏิบัติตามสัญญาก่อน',
                font: ttf),
            Textx(value: '${' ' * 24}ข้อ 7 กรณีที่ผู้เช่าเลิกสัญญา', font: ttf),
            Textx(
                value:
                    '${' ' * 24}ในกรณีที่ผู้เช่าประสงค์จะบอกเลิกสัญญา    ก่อนครบกำหนดระยะเวลาเช่าตามสัญญานี้    ผู้เช่าต้องแจ้งให้ผู้ให้เช่าทราบล่วงหน้า   เป็นลายลักษณ์',
                font: ttf),
            Textx(value: 'อย่างน้อย 1 เดือน', font: ttf),
            Textx(value: '${' ' * 24}ข้อ 8 กรณีสัญญาเช่าสิ้นสุดลง', font: ttf),
            pw.Row(children: [
              Textx(
                  value:
                      '${' ' * 24}เมื่อสัญญาเช่านี้สิ้นสุดลงเพราะการบอกเลิกสัญญาของฝ่ายหนึ่งฝ่ายใด  หรือเพราะเหตุใดๆ  ก็ตาม  ผู้เช่าเป็นอันสิ้นสิทธิ์ทุกอย่างใน "พื้นที่เช่า" ผู้เช่า',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      'ต้องขนย้ายทรัพย์สินทั้งปวงออกไปจาก "พื้นที่เช่า" ทันที และให้ถือว่า "พื้นที่เช่า" ได้คืนการครอบครองแก่ผู้ให้เช่าทันทีเช่นเดียวกัน ผู้ให้เช่าในฐานะเจ้าของกรรมสิทธิ์และ',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      'ผู้ทรงสิทธิครอบครอง มีสิทธิเข้าไปใน "พื้นที่เช่า"  เพื่อยึดถือครอบครอง ให้บุคคลใดๆ ออกไปจาก "พื้นที่เช่า" หรือนำทรัพย์สินหรือสิ่งของออกไปเก็บไว้ที่อื่น  ปิดกั้นหรือ',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      'ติดกุญแจ "พื้นที่เช่า" หรืองัดประตู ทำลายกุญแจที่ติดไว้ก่อน และสามารถนำ "พื้นที่เช่า" ออกให้บุคคลอื่นเช่าได้ทันที',
                  font: ttf),
            ]),
            pw.SizedBox(height: 10 * PdfPageFormat.mm),
            pw.Row(children: [
              Textx(
                  value:
                      '${' ' * 24}สัญญานี้ทำขึ้นเป็นสองฉบับมีข้อความถูกต้องตรงกันทุกประการ คู่สัญญาทั้งสองฝ่ายต่างได้อ่านและรับทราบข้อความนี้โดยตลอดดีแล้วเห็นว่าถูกต้อง',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(
                  value:
                      'ตรงตามเจตนาของคู่สัญญา เพื่อเป็นหลักฐานคู่สัญญาจึงได้ลงลายมือชื่อไว้เป็นสำคัญต่อหน้าพยานแล้ว',
                  font: ttf),
            ]),
            pw.SizedBox(height: 20 * PdfPageFormat.mm),
            pw.Row(children: [
              pw.Expanded(
                flex: 1,
                child: pw.Container(),
              ),
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
                      value: (Form_nameshop.toString().isNotEmpty)
                          ? '(  $Form_nameshop  )'
                          : '(${'...' * 30})',
                      font: ttf,
                    ),
                    pw.SizedBox(height: 6 * PdfPageFormat.mm),
                    Textx(
                      value: 'ลงชื่อ${'...' * 30} ผู้ให้เช่า',
                      font: ttf,
                    ),
                    Textx(
                      value: '(  $Namex  )',
                      font: ttf,
                    ),
                    pw.SizedBox(height: 6 * PdfPageFormat.mm),
                    Textx(
                      value: 'ลงชื่อ${'...' * 30} พยาน',
                      font: ttf,
                    ),
                    Textx(
                      value: '(  $Name1  )',
                      font: ttf,
                    ),
                    pw.SizedBox(height: 6 * PdfPageFormat.mm),
                    Textx(
                      value: 'ลงชื่อ${'...' * 30} พยาน',
                      font: ttf,
                    ),
                    Textx(
                      value: '(  $Name2_  )',
                      font: ttf,
                    ),
                  ],
                ),
              ),
            ]),
            pw.NewPage(),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
              Textx(value: 'บันทึกข้อตกลง', font: ttf, fontSize: font_Size + 4)
            ]),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    Textx(
                      value: 'สัญญาเช่านี้ทำขึ้นที่ $renTal_name',
                      font: ttf,
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
              Textx(value: '${' ' * 24}ข้าพเจ้า', font: ttf),
              labeledLine1(value: Form_nameshop, font: ttf, flex: 1),
              Textx(value: 'เลขประจําตัวผู้เสียภาษี', font: ttf),
              labeledLine1(value: Form_tax, font: ttf, flex: 1),
            ]),
            pw.Row(children: [
              Textx(value: 'ปัจจุบันอยู่บ้านเลขที่', font: ttf),
              labeledLine1(value: Form_address, font: ttf, flex: 1),
            ]),
            pw.Row(children: [
              Textx(value: 'โทรศัพท์บ้าน', font: ttf),
              labeledLine1(value: '-', font: ttf, flex: 1),
              Textx(value: 'โทรศัพท์ (มือถือ)', font: ttf),
              labeledLine1(value: Form_tel, font: ttf, flex: 1),
              Textx(value: 'ซึ่งต่อไปนี้ในสัญญานี้เรียกว่า', font: ttf),
            ]),
            pw.Row(
              children: [
                Textx(
                    value:
                        '“ผู้ทำบันทึก” ฝ่ายหนึ่ง  ขอทำสัญญาเช่านี้ไว้แก่  บริษัท ลำพูนจตุจักร จำกัด โดย $Namex ผู้จัดการฝ่ายสถานที่ ผู้มีอำนาจลงนามผูกพันบริษัทฯ  ซึ่งต่อ',
                    font: ttf),
              ],
            ),
            Textx(
                value: 'ไปนี้สัญญาเรียกว่า “ผู้รับบันทึก” อีกฝ่ายหนึ่ง',
                font: ttf),
            Textx(
                value:
                    '${' ' * 24}เพื่อเป็นหลักฐานว่าตามที่ข้าพเจ้าได้เช่า   "พื้นที่เช่า"   ของบริษัท   บริษัท   ลำพูนจตุจักร  จำกัด   ตามสัญญาเช่าพื้นที่เช่าในตลาดลำพูนจตุจักร',
                font: ttf),
            pw.Row(children: [
              Textx(value: 'ฉบับลงวันที่', font: ttf),
              labeledLine1(value: '${Datex?['day']}', font: ttf, flex: 1),
              Textx(value: 'เดือน', font: ttf),
              labeledLine1(value: '${Datex?['monthName']}', font: ttf, flex: 2),
              Textx(value: 'พ.ศ.', font: ttf),
              labeledLine1(value: '${Datex?['yearBE']}', font: ttf, flex: 1),
              Textx(
                  value:
                      'นั้นข้าพเจ้าตกลงยินยอมชำระเงินค่าบำรุงรักษา และค่าจัดการใดๆ ของตลาด',
                  font: ttf),
            ]),
            pw.Row(children: [
              Textx(value: 'ตลอดระยะเวลาของการเช่าให้แก่', font: ttf),
              labeledLine1(value: bill_name, font: ttf, flex: 1),
              Textx(value: 'โดย $Namex ผู้รับมอบอำนาจ', font: ttf),
            ]),
            pw.Row(children: [
              Textx(value: 'เป็นจำนวนเงิน', font: ttf),
              pw.Container(
                child: labeledLine1(value: totalchao, font: ttf, flex: 1),
              ),
              Textx(value: 'บาท ', font: ttf),
              Textx(
                  value: '( ${convertToThaiBaht(totalchaoNumber)} )',
                  font: ttf),
            ]),
            pw.SizedBox(height: 20 * PdfPageFormat.mm),
            pw.Row(children: [
              pw.Expanded(
                flex: 1,
                child: pw.Container(),
              ),
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
                      value: (Form_nameshop.toString().isNotEmpty)
                          ? '(  $Form_nameshop  )'
                          : '(${'...' * 30})',
                      font: ttf,
                    ),
                    pw.SizedBox(height: 6 * PdfPageFormat.mm),
                    Textx(
                      value: 'ลงชื่อ${'...' * 30} ผู้ให้เช่า',
                      font: ttf,
                    ),
                    Textx(
                      value: '(  $Namex  )',
                      font: ttf,
                    ),
                    pw.SizedBox(height: 6 * PdfPageFormat.mm),
                    Textx(
                      value: 'ลงชื่อ${'...' * 30} พยาน',
                      font: ttf,
                    ),
                    Textx(
                      value: '(  $Name1  )',
                      font: ttf,
                    ),
                    pw.SizedBox(height: 6 * PdfPageFormat.mm),
                    Textx(
                      value: 'ลงชื่อ${'...' * 30} พยาน',
                      font: ttf,
                    ),
                    Textx(
                      value: '(  $Name2_  )',
                      font: ttf,
                    ),
                  ],
                ),
              ),
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
            context: context, Get_Value_cid: Get_Value_cid,
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
