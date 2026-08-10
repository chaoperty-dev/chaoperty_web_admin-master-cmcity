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

class Pdfgen_Agreementnim4 {
//////////---------------------------------------------------->(เอกสารแนบท้ายสัญญาหมายเลข 2)

  static void exportPDF_Agreementnim4(
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

    final filteredListchao = quotxSelectModels
        .where((item) =>
            (item.dtype ?? '').trim() == "KR" && item.expser == '1' ||
            item.expser == '8')
        .toList();
    for (var item in filteredListchao) {
      try {
        if (item.trans_array != null && item.trans_array != '') {
          String raw = item.trans_array.trim();

          // ซ่อม format ให้เป็น JSON มาตรฐาน
          // 1. ตัดเครื่องหมาย \"
          raw = raw.replaceAll(r'\"', '"');

          // 2. ถ้ายังไม่มี { ให้เพิ่ม
          if (!raw.contains('{')) {
            raw = raw
                .replaceAll('\"date\":', '{"date":') // แปลงตัวแรก
                .replaceAll('},\"date\":', '},{"date":') // เชื่อมแต่ละตัว
                .replaceAll('}]\"', '}]'); // ปิดท้าย
          }

          // 3. ถ้าเปิดมาด้วย ["date": ก็แปลงให้เปิดด้วย [{
          raw = raw
              .replaceAll('["date":', '[{"date":')
              .replaceAll('},\"date\":', '},{"date":');

          // 4. ลอง decode อีกครั้ง
          final List<dynamic> transList = jsonDecode(raw);

          // 5. เรียงวันที่
          transList.sort((a, b) {
            final dateA = DateTime.parse(a['date']);
            final dateB = DateTime.parse(b['date']);
            return dateA.compareTo(dateB);
          });

          // 6. เก็บกลับ
          item.trans_array = jsonEncode(transList);
        }
        print('⚠ raw data trans_array : ${item.trans_array}');
      } catch (e) {
        print('❌ Error sorting trans_array for item ${item.expname}: $e');
        // debug print raw string จะได้เห็นว่ามันยังผิดตรงไหน
        // print('⚠ raw data: ${item.trans_array}');
      }
    }
    final totalchao_serv = nFormat.format((filteredListchao.fold<double>(
      0.00,
      (double sum, dynamic item) =>
          sum + (item.pvat != null ? double.parse(item.pvat!) : 0.00),
    ))); // ค่าเช่า + ค่าบริการ เดือนละ

    // final filteredListserv = quotxSelectModels
    //     .where(
    //         (item) => (item.dtype ?? '').trim() == "KR" && item.expser == '8')
    //     .toList();
    // final totalserv = nFormat.format((filteredListserv.fold<double>(
    //   0.00,
    //   (double sum, dynamic item) =>
    //       sum + (item.pvat != null ? double.parse(item.pvat!) : 0.00),
    // ))); // ค่าเช่า เดือนละ

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

    // ✅ แทนที่/เพิ่มฟังก์ชัน formatThaiDate ให้รับ DateTime โดยตรง
    String formatThaiDate(dynamic input) {
      DateTime? dt;

      if (input is DateTime) {
        dt = input;
      } else if (input is String) {
        try {
          dt = DateFormat('dd-MM-yyyy').parseStrict(input);
        } catch (_) {
          return input;
        }
      } else {
        return input.toString();
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

      final beYear = dt.year + 543;
      final monthName = thaiMonths[dt.month];
      return '${dt.day} เดือน $monthName พ.ศ. $beYear';
    }

    String formatThaiDate_(String input) {
      final parts = input.split('-');
      if (parts.length != 3) return input;

      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final day = int.tryParse(parts[2]);

      if (year == null || month == null || day == null) return input;

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

      final beYear = year + 543;
      final monthName = thaiMonths[month];
      return '$day เดือน $monthName พ.ศ. $beYear';
    }

    DateTime _sameMonthDayNewYear(DateTime base, int newYear) {
      final m = base.month;
      final d = base.day;
      final lastDay = DateTime(newYear, m + 1, 0).day;
      final safeDay = (d > lastDay) ? lastDay : d;
      return DateTime(newYear, m, safeDay);
    }

    // pw.Widget buildDateWithCheck({
    //   required String formSdate,
    //   required String formLdate,
    //   required pw.Font ttf,
    // }) {
    //   final df = DateFormat('dd-MM-yyyy');
    //   DateTime sDate, lDate;

    //   try {
    //     sDate = df.parseStrict(formSdate);
    //     lDate = df.parseStrict(formLdate);
    //   } catch (e) {
    //     print('⚠️ parse error: $e');
    //     return pw.Row(children: [
    //       labeledLine1(value: formSdate, font: ttf, flex: 1),
    //       Textx(value: 'ถึงวันที่', font: ttf),
    //       labeledLine1(value: formLdate, font: ttf, flex: 1),
    //     ]);
    //   }

    //   final sYear = sDate.year;
    //   final lYear = lDate.year;
    //   final totalYears = (lYear - sYear) + 1;

    //   final widgets = <pw.Widget>[];

    //   for (int i = 0; i < totalYears; i++) {
    //     final startI = _sameMonthDayNewYear(sDate, sYear + i);
    //     final endI =
    //         _sameMonthDayNewYear(lDate, sYear + i); // ✅ ปีเดียวกันกับ startI

    //     // ถ้า endI เกินวันสุดท้ายของสัญญา ให้ตัดลงวันสุดท้ายจริง
    //     final fixedEnd = endI.isAfter(lDate) ? lDate : endI;

    //     widgets.add(
    //       pw.Row(
    //         children: [
    //           Textx(
    //             value:
    //                 '                        1.${i + 1}  ปีที่ ${i + 1} ตั้งแต่วันที่',
    //             font: ttf,
    //           ),
    //           labeledLine1(value: formatThaiDate(startI), font: ttf, flex: 1),
    //           Textx(value: 'ถึงวันที่', font: ttf),
    //           labeledLine1(value: formatThaiDate(fixedEnd), font: ttf, flex: 1),
    //         ],
    //       ),
    //     );

    //     widgets.add(
    //       pw.Row(
    //         children: [
    //           Textx(
    //               value: '                               ในอัตราเดือนละ',
    //               font: ttf),
    //           labeledLine1(
    //             value:
    //                 '$totalchao_serv บาท(${convertToThaiBaht(double.tryParse(totalchao_serv.replaceAll(',', '')) ?? 0.00)})',
    //             font: ttf,
    //             flex: 1,
    //           ),
    //         ],
    //       ),
    //     );

    //     // if (i == 0) {
    //     //   // widgets.add(
    //     //   //   pw.Row(
    //     //   //     children: [
    //     //   //       Textx(value: 'ในอัตราค่าเช่าเดือนละ', font: ttf),
    //     //   //       labeledLine1(
    //     //   //         value:
    //     //   //             '$totalchao_serv บาท(${convertToThaiBaht(double.tryParse(totalchao_serv.replaceAll(',', '')) ?? 0.00)})',
    //     //   //         font: ttf,
    //     //   //         flex: 1,
    //     //   //       ),
    //     //   //     ],
    //     //   //   ),
    //     //   // );
    //     //   // widgets.add(
    //     //   //   pw.Row(
    //     //   //     children: [
    //     //   //       Textx(value: 'และค่าบริการ', font: ttf),
    //     //   //       labeledLine1(
    //     //   //         value:
    //     //   //             '$totalserv บาท(${convertToThaiBaht(double.tryParse(totalserv.replaceAll(',', '')) ?? 0.00)})',
    //     //   //         font: ttf,
    //     //   //         flex: 1,
    //     //   //       ),
    //     //   //     ],
    //     //   //   ),
    //     //   // );
    //     // } else {
    //     //   // widgets.add(
    //     //   //   pw.Row(
    //     //   //     children: [
    //     //   //       Textx(
    //     //   //         value:
    //     //   //             'ผู้เช่าตกลงและยินยอมให้ผู้ให้เช่า มีสิทธิปรับขึ้นอัตราค่าเช่าและค่าบริการในส่วนของพื้นที่เช่าในอัตราร้อยละ 20 (ยี่สิบ) – 30 (สามสิบ)',
    //     //   //         font: ttf,
    //     //   //       ),
    //     //   //     ],
    //     //   //   ),
    //     //   // );
    //     //   // widgets.add(
    //     //   //   pw.Row(
    //     //   //     children: [
    //     //   //       Textx(
    //     //   //         value: 'ของค่าเช่าและค่าบริการปีที่ $i',
    //     //   //         font: ttf,
    //     //   //       ),
    //     //   //     ],
    //     //   //   ),
    //     //   // );
    //     // }
    //   }

    //   return pw.Column(
    //     crossAxisAlignment: pw.CrossAxisAlignment.start,
    //     children: widgets,
    //   );
    // }

    pw.Widget buildDateWithCheck({
      required String formSdate,
      required String formLdate,
      required pw.Font ttf,
      required String Form_rtname,
      required String Form_period,
      required String totalchao_serv,
    }) {
      final df = DateFormat('dd-MM-yyyy');
      DateTime sDate, lDate;

      try {
        sDate = df.parseStrict(formSdate);
        lDate = df.parseStrict(formLdate);
      } catch (e) {
        print('⚠️ parse error: $e');
        return pw.Row(children: [
          labeledLine1(value: formSdate, font: ttf, flex: 1),
          Textx(value: 'ถึงวันที่', font: ttf),
          labeledLine1(value: formLdate, font: ttf, flex: 1),
        ]);
      }

      // ✅ คำนวณจำนวนปีจาก Form_rtname และ Form_period
      int period = int.tryParse(Form_period) ?? 0;
      int totalYears = 0;

      if (Form_rtname == 'รายวัน') {
        totalYears = period ~/ 365;
      } else if (Form_rtname == 'รายเดือน') {
        totalYears = period ~/ 12;
      } else if (Form_rtname == 'รายปี') {
        totalYears = period;
      } else {
        // fallback: ใช้จากวันที่จริง
        totalYears = lDate.year - sDate.year;
        if (lDate.month >= sDate.month && lDate.day >= sDate.day) {
          totalYears += 1;
        }
      }

      // ป้องกันกรณี totalYears น้อยกว่า 1 → ให้มีอย่างน้อย 1 ปี
      if (totalYears < 1) totalYears = 1;

      final widgets = <pw.Widget>[];

      for (int i = 0; i < totalYears; i++) {
        final startI = DateTime(sDate.year + i, sDate.month, sDate.day);
        final endI = DateTime(sDate.year + i + 1, sDate.month, sDate.day)
            .subtract(const Duration(days: 1));

        // ถ้า endI เกินวันสุดท้ายของสัญญา → ตัดให้ตรง
        final fixedEnd = endI.isAfter(lDate) ? lDate : endI;

        widgets.add(
          pw.Row(
            children: [
              Textx(
                value:
                    '                        1.${i + 1}  ปีที่ ${i + 1} ตั้งแต่วันที่',
                font: ttf,
              ),
              labeledLine1(value: formatThaiDate(startI), font: ttf, flex: 1),
              Textx(value: 'ถึงวันที่', font: ttf),
              labeledLine1(value: formatThaiDate(fixedEnd), font: ttf, flex: 1),
            ],
          ),
        );

        widgets.add(
          pw.Row(
            children: [
              Textx(
                  value: '                               ในอัตราเดือนละ',
                  font: ttf),
              labeledLine1(
                value:
                    '$totalchao_serv บาท(${convertToThaiBaht(double.tryParse(totalchao_serv.replaceAll(",", "")) ?? 0.00)})',
                font: ttf,
                flex: 1,
              ),
            ],
          ),
        );
      }

      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: widgets,
      );
    }

    // pw.Widget buildDateWithCheck({
    //   required String formSdate,
    //   required String formLdate,
    //   required pw.Font ttf,
    // }) {
    //   final df = DateFormat('dd-MM-yyyy');
    //   DateTime sDate, lDate;

    //   try {
    //     sDate = df.parseStrict(formSdate);
    //     lDate = df.parseStrict(formLdate);
    //   } catch (e) {
    //     print('⚠️ parse error: $e');
    //     return pw.Row(children: [
    //       labeledLine1(value: formSdate, font: ttf, flex: 1),
    //       Textx(value: 'ถึงวันที่', font: ttf),
    //       labeledLine1(value: formLdate, font: ttf, flex: 1),
    //     ]);
    //   }

    //   // ✅ คำนวณจำนวนปีจริง (ตามเดือน/วัน)
    //   int totalYears = lDate.year - sDate.year;
    //   if (lDate.month >= sDate.month && lDate.day >= sDate.day) {
    //     totalYears += 1;
    //   }

    //   final widgets = <pw.Widget>[];

    //   for (int i = 0; i < totalYears; i++) {
    //     final startI = DateTime(sDate.year + i, sDate.month, sDate.day);
    //     final endI = DateTime(sDate.year + i + 1, sDate.month, sDate.day)
    //         .subtract(const Duration(days: 1));

    //     // ถ้า endI เกินวันสุดท้ายของสัญญา → ตัดให้ตรง
    //     final fixedEnd = endI.isAfter(lDate) ? lDate : endI;

    //     widgets.add(
    //       pw.Row(
    //         children: [
    //           Textx(
    //             value:
    //                 '                        1.${i + 1}  ปีที่ ${i + 1} ตั้งแต่วันที่',
    //             font: ttf,
    //           ),
    //           labeledLine1(value: formatThaiDate(startI), font: ttf, flex: 1),
    //           Textx(value: 'ถึงวันที่', font: ttf),
    //           labeledLine1(value: formatThaiDate(fixedEnd), font: ttf, flex: 1),
    //         ],
    //       ),
    //     );

    //     widgets.add(
    //       pw.Row(
    //         children: [
    //           Textx(
    //               value: '                               ในอัตราเดือนละ',
    //               font: ttf),
    //           labeledLine1(
    //             value:
    //                 '$totalchao_serv บาท(${convertToThaiBaht(double.tryParse(totalchao_serv.replaceAll(",", "")) ?? 0.00)})',
    //             font: ttf,
    //             flex: 1,
    //           ),
    //         ],
    //       ),
    //     );
    //   }

    //   return pw.Column(
    //     crossAxisAlignment: pw.CrossAxisAlignment.start,
    //     children: widgets,
    //   );
    // }

    // pw.Widget buildDateWithCheckSimple({
    //   required String formSdate, // เอาไว้โชว์เฉย ๆ
    //   required String formLdate, // เอาไว้โชว์เฉย ๆ
    //   required pw.Font ttf,
    //   required int totalYears, // 👉 ตั้งเลขมาเอง เช่น 1,2,3,4
    // }) {
    //   return pw.Column(
    //     crossAxisAlignment: pw.CrossAxisAlignment.start,
    //     children: [
    //       // ปีแรก (1.1)
    //       pw.Row(children: [
    //         Textx(
    //             value: '                        1.1 ปีที่ 1 ตั้งแต่วันที่',
    //             font: ttf),
    //         labeledLine1(value: formatThaiDate(formSdate), font: ttf, flex: 1),
    //         Textx(value: 'ถึงวันที่', font: ttf),
    //         labeledLine1(value: formatThaiDate(formLdate), font: ttf, flex: 1),
    //       ]),
    //       pw.Row(children: [
    //         Textx(value: 'ในอัตราค่าเช่าเดือนละ', font: ttf),
    //       ]),

    //       // ปีถัด ๆ ไป (2..totalYears)
    //       for (int yearIndex = 2; yearIndex <= totalYears; yearIndex++) ...[
    //         pw.Row(children: [
    //           Textx(
    //               value:
    //                   '                        1.$yearIndex ปีที่ $yearIndex ตั้งแต่วันที่',
    //               font: ttf),
    //           labeledLine1(
    //               value: formatThaiDate(formSdate), font: ttf, flex: 1),
    //           Textx(value: 'ถึงวันที่', font: ttf),
    //           labeledLine1(
    //               value: formatThaiDate(formLdate), font: ttf, flex: 1),
    //         ]),
    //         pw.Row(children: [
    //           Textx(
    //             value:
    //                 'ผู้เช่าตกลงและยินยอมให้ผู้ให้เช่า มีสิทธิปรับขึ้นอัตราค่าเช่าและค่าบริการในส่วนของพื้นที่เช่าในอัตราร้อยละ 20 (ยี่สิบ) – 30 (สามสิบ)',
    //             font: ttf,
    //           ),
    //         ]),
    //         pw.Row(children: [
    //           Textx(
    //               value: 'ของค่าเช่าและค่าบริการปีที่ ${yearIndex - 1}',
    //               font: ttf),
    //         ]),
    //       ],
    //     ],
    //   );
    // }

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
        build: (context) {
          return [
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                Textx(
                  value: 'เอกสารแนบท้ายสัญญาหมายเลข 2',
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
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            ตามที่คู่สัญญาทั้งสองฝ่ายได้ตกลงทำสัญญาเช่าพื้นที่  และได้กำหนดระยะเวลาอายุสัญญาการเช่าพื้นที่ในศูนย์การค้านิ่มซิตี้',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(value: 'พื้นที่เลขที่ ', font: ttf),
                labeledLine1(
                    flex: 1,
                    value: '$Form_ln',
                    font: ttf), //พื้นที่ด้านทิศเหนือ ???
                Textx(value: ' รวมขนาดพื้นที่จำนวน ', font: ttf),
                labeledLine1(
                  flex: 1,
                  value:
                      '$Form_area ( ${thaiIntegerFromAmount(double.tryParse(Form_area) ?? 0.00)} )',
                  font: ttf,
                ),
                Textx(
                    value: ' ตารางเมตร ซึ่งตั้งอยู่ 199/8 ถนนมหิดล ตำบลหายยา',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        ' อำเภอเมืองเชียงใหม่ จังหวัดเชียงใหม่ เริ่มตั้งแต่วันที่',
                    font: ttf),
                labeledLine1(
                  flex: 1,
                  value: '${formatThaiDate(Form_sdate)}',
                  // value: '$Form_sdate',
                  font: ttf,
                ),
                Textx(value: 'ถึงวันที่', font: ttf),
                labeledLine1(
                  flex: 1,
                  value: '${formatThaiDate(Form_ldate)}',
                  font: ttf,
                ),
              ]),
              pw.Row(children: [
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
                Textx(value: 'ฉบับลงวันที่', font: ttf),
                labeledLine1(
                  flex: 2,
                  value:
                      // '-', // วันที่ชำระภาษีอากร??  value: formatThaiDate(Datex_text.text),
                      // formatThaiDate_y(contractPhotoModels[0].datex),
                      formatThaiDate(Datex_text.text),
                  font: ttf,
                ),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ที่อ้างถึงข้างต้น (ซึ่งคู่สัญญาทั้งสองฝ่ายได้อ่านและเข้าใจสัญญาโดยตลอดแล้วนั้น)',
                    font: ttf),
              ]),
            ]),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            คู่สัญญาทั้งสองฝ่ายได้ตกลงทำเอกสารแนบท้ายฉบับนี้ขึ้น เพื่อเป็นหลักฐานสำคัญว่า เอกสารแนบท้ายสัญญาหมายเลข 2',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(value: 'ประกอบด้วย เอกสารดังต่อไปนี้', font: ttf),
              ]),
            ]),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            1. ผู้เช่าตกลงทำการชำระค่าเช่าและค่าบริการ เป็นการล่วงหน้าให้แก่ผู้ให้เช่าภายในทุกวันที่ 5 ของทุก ๆ เดือน ดังนี้',
                    font: ttf),
              ]),
              // pw.Column(
              //   children: [
              //     buildDateWithCheck(
              //       formSdate: Form_sdate,
              //       formLdate: Form_ldate,
              //       ttf: ttf,
              //       Form_period: Form_period,
              //       Form_rtname: Form_rtname,
              //       totalchao_serv: totalchao_serv,
              //     ),
              //   ],
              // ),
              pw.Wrap(
                spacing: 0,
                // runSpacing: 2 * PdfPageFormat.mm,
                children: [
                  for (int i = 0; i < filteredListchao.length; i++) ...[
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        Textx(
                          value:
                              '                  1.${i + 1} ${filteredListchao[i].expname}',
                          font: ttf,
                        ),
                      ],
                    ),
                    if (filteredListchao[i].trans_array != null &&
                        filteredListchao[i].trans_array!.isNotEmpty)
                      ...() {
                        // ✅ แปลง JSON ที่เรียงวันที่แล้ว (มีขั้นตอน sort ข้างบนอยู่แล้ว)
                        final List<dynamic> transList =
                            jsonDecode(filteredListchao[i].trans_array!);

                        // ✅ รวมงวดที่ total เท่ากันต่อเนื่องกัน
                        final List<Map<String, dynamic>> grouped = [];
                        if (transList.isNotEmpty) {
                          int start = 1;
                          String currentTotal = transList.first['pvat'];
                          for (int idx = 1; idx < transList.length; idx++) {
                            if (transList[idx]['pvat'] != currentTotal) {
                              grouped.add({
                                'start': start,
                                'end': idx,
                                'pvat': currentTotal,
                                'startDate': transList[start - 1]['date'],
                                'endDate': transList[idx - 1]['date'],
                              });
                              start = idx + 1;
                              currentTotal = transList[idx]['pvat'];
                            }
                          }
                          // ✅ เพิ่มกลุ่มสุดท้าย
                          grouped.add({
                            'start': start,
                            'end': transList.length,
                            'pvat': currentTotal,
                            'startDate': transList[start - 1]['date'],
                            'endDate': transList.last['date'],
                          });
                        }

                        // ✅ เตรียม widget list สำหรับแต่ละกลุ่ม
                        final List<pw.Widget> widgets = [];

                        for (int gi = 0; gi < grouped.length; gi++) {
                          final g = grouped[gi];

                          int termCount = (g['end'] - g['start']) + 1;
                          double pricePerTerm =
                              double.tryParse(g['pvat'].toString()) ?? 0.0;
                          // double totalGroup = termCount * pricePerTerm;
                          double totalGroup = pricePerTerm;

                          // ------------------------------
                          // แยกวันจาก Form_ldate (dd-MM-yyyy)
                          final formParts = Form_ldate.split('-');
                          int formDay = int.tryParse(formParts[0]) ?? 1;

                          // แยกเดือน/ปีจาก endDate (yyyy-MM-dd)
                          final endParts = g['endDate'].split('-');
                          int endYear = int.tryParse(endParts[0]) ?? 2025;
                          int endMonth = int.tryParse(endParts[1]) ?? 1;

                          // รวมใหม่: ใช้วันจาก Form_ldate แต่เดือน/ปีจาก endDate
                          final combinedEndDate =
                              DateTime(endYear, endMonth, formDay);

                          // แปลงให้เป็น string ที่ formatThaiDate_ เข้าใจ (yyyy-MM-dd)
                          final combinedEndDateStr =
                              '${combinedEndDate.year}-${combinedEndDate.month.toString().padLeft(2, '0')}-${combinedEndDate.day.toString().padLeft(2, '0')}';

                          final endDateDisplay =
                              formatThaiDate_(combinedEndDateStr);

                          // ---- แสดงแถวปีที่ ...
                          widgets.add(
                            pw.Row(
                              children: [
                                Textx(
                                    value:
                                        '                        1.${i + 1}.${gi + 1} ปีที่ ${gi + 1}',
                                    font: ttf),
                                Textx(value: ' ตั้งแต่วันที่', font: ttf),
                                labeledLine1(
                                  value: formatThaiDate_(g['startDate']),
                                  font: ttf,
                                  flex: 1,
                                ),
                                Textx(value: 'ถึงวันที่', font: ttf),
                                labeledLine1(
                                  value: endDateDisplay,
                                  font: ttf,
                                  flex: 1,
                                ),
                              ],
                            ),
                          );

                          // ---- จำนวนเงิน
                          widgets.add(
                            pw.Row(
                              children: [
                                Textx(
                                    value:
                                        '                                ในอัตราเดือนละ',
                                    font: ttf),
                                labeledLine1(
                                  flex: 1,
                                  value:
                                      ' ${nFormat.format(totalGroup)} บาท (${convertToThaiBaht(totalGroup)})',
                                  font: ttf,
                                ),
                              ],
                            ),
                          );
                        }

                        return widgets;
                      }(),
                  ],
                ],
              ),
              // pw.Column(
              //   children: [
              //     buildDateWithCheckSimple(
              //       formSdate: Form_sdate,
              //       formLdate: Form_ldate,
              //       ttf: ttf,
              //       totalYears: 4, // 👈 ปรับเอาเองตามต้องการ
              //     ),
              //   ],
              // ),
            ]),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            ทั้งนี้ อัตราค่าเช่าตามข้อ 1. ดังกล่าวข้างต้น ไม่ได้รวมภาษีต่าง ๆ ที่เกี่ยวข้องตามที่กฎหมายกำหนดอันเป็นภาระและหน้าที่',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ผู้เช่า และการปรับขึ้นอัตราค่าเช่าตามข้อ 1. ผู้เช่ารับทราบและตกลงว่าเป็นสิทธิเด็ดขาดของผู้ให้เช่าแต่เพียงฝ่ายเดียวในการพิจารณา',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'ตามภายใต้เงื่อนไขดังกล่าวข้างต้น  โดยผู้ให้เช่าจะทำการแจ้งให้ผู้เช่าทราบเป็นการล่วงหน้าก่อนระยะเวลาที่จะมีการเรียกเก็บและคู่',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'สัญญาทั้งสองฝ่ายตกลงทำบันทึกเป็นลายลักษณ์อักษรทุกครั้ง และให้ข้อตกลงเปลี่ยนแปลงดังกล่าวถือเป็นส่วนหนึ่งของสัญญานี้ด้วย',
                    font: ttf),
              ]),
            ]),
            pw.NewPage(),
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [Textx(value: '/ เอกสารแนบท้าย..', font: ttf)]),
            pw.Column(children: [
              pw.Row(children: [
                Textx(
                    value:
                        '            เอกสารแนบท้ายสัญญาฉบับนี้ทำขึ้นเป็น 2 ฉบับ มีข้อความถูกต้องตรงกัน  คู่สัญญาทั้งสองฝ่ายได้อ่านและเข้าใจข้อความใน',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'สัญญานี้เป็นอย่างดี เห็นว่าเป็นที่ถูกต้อง  ครบถ้วน  เรียบร้อย ตรงตามเจตนาทุกประการ  ปราศจากการบังคับ ขู่เข็ญ  หรือสำคัญผิด',
                    font: ttf),
              ]),
              pw.Row(children: [
                Textx(
                    value:
                        'แต่อย่างใด คู่สัญญามีสติสัมปชัญญะครบถ้วนสมบูรณ์ทุกประการ  จึงได้ลงลายมือชื่อ/พิมพ์ลายนิ้วมือ และตราประทับ (ถ้ามี) เป็นของ',
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
