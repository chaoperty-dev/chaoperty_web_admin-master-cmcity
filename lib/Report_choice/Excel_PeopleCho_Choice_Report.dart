import 'dart:convert';
import 'dart:typed_data';
import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as x;
import 'package:pdf/widgets.dart' as pw;
import 'dart:math' as math;

class Excgen_PeopleChoChoiceReport {
  static void exportExcel_PeopleChoChoiceReport(
      expModels,
      context,
      NameFile_,
      _verticalGroupValue_NameFile,
      zone_name,
      Status_pe,
      teNantModels,
      // contractPhotoModels,
      // quotxSelectModels,
      open_set_date) async {
    var nFormat = NumberFormat("#,##0.00", "en_US");
    DateTime datex = DateTime.now();
    String day_ =
        '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}';
    //Adding a picture
    // final ByteData bytes_image = await rootBundle.load('images/LOGO.png');
    // final Uint8List image = bytes_image.buffer
    //     .asUint8List(bytes_image.offsetInBytes, bytes_image.lengthInBytes);
    DateTime date = DateTime.now();
    var formatter = new DateFormat.MMMMd('th_TH');
    String thaiDate = formatter.format(date);
    String Tim_ =
        '${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}';
    final x.Workbook workbook = x.Workbook();
    final x.Worksheet sheet = workbook.worksheets[0];
    sheet.pageSetup.topMargin = 1;
    sheet.pageSetup.bottomMargin = 1;
    sheet.pageSetup.leftMargin = 1;
    sheet.pageSetup.rightMargin = 1;

    List<String> columns = [];

// Add column names from A to Z
    for (int i = 0; i < 26; i++) {
      columns.add(String.fromCharCode(65 + i)); // A-Z
    }

// Add column names from A to Z followed by A to Z (AA to AZ)
    for (int i = 0; i < 26; i++) {
      for (int j = 0; j < 26; j++) {
        columns.add(String.fromCharCode(65 + i) +
            String.fromCharCode(65 + j)); // A-Z followed by A-Z (AA-AZ)
      }
    }

    x.Style globalStyle = workbook.styles.add('style');
    globalStyle.fontName = 'Angsana New';
    globalStyle.numberFormat = '_(\$* #,##0_)';
    globalStyle.fontSize = 20;

    x.Style globalStyle1 = workbook.styles.add('style1');
    globalStyle1.backColorRgb = Color(0xFFD4E6A3);
    globalStyle1.fontName = 'Angsana New';
    globalStyle1.numberFormat = '_(\* #,##0.00_)';
    globalStyle1.hAlign = x.HAlignType.center;
    globalStyle1.fontSize = 16;
    globalStyle1.bold = true;
    globalStyle1.borders;
    globalStyle1.fontColorRgb = Color.fromARGB(255, 3, 3, 3);

    x.Style globalStyle22 = workbook.styles.add('style22');
    globalStyle22.backColorRgb = Color(0xC7F5F7FA);
    globalStyle22.numberFormat = '_(\* #,##0.00_)';
    globalStyle22.fontSize = 12;
    globalStyle22.numberFormat;
    globalStyle22.hAlign = x.HAlignType.left;

    x.Style globalStyle222 = workbook.styles.add('style222');
    globalStyle222.backColorRgb = Color(0xC7E1E2E6);
    globalStyle222.numberFormat = '_(\* #,##0.00_)';
    // globalStyle222.numberFormat;
    globalStyle222.fontSize = 12;
    globalStyle222.hAlign = x.HAlignType.left;
////////////-------------------------------------------------------->
    x.Style globalStyle220 = workbook.styles.add('style220');
    globalStyle220.backColorRgb = Color(0xC7F5F7FA);
    globalStyle220.numberFormat = '_(\* #,##0.00_)';
    globalStyle220.fontSize = 12;
    globalStyle220.numberFormat;
    globalStyle220.hAlign = x.HAlignType.center;
    globalStyle220.fontColorRgb = Color.fromARGB(255, 37, 127, 179);

    x.Style globalStyle2220 = workbook.styles.add('style2220');
    globalStyle2220.backColorRgb = Color(0xC7E1E2E6);
    globalStyle2220.numberFormat = '_(\* #,##0.00_)';
    // globalStyle222.numberFormat;
    globalStyle2220.fontSize = 12;
    globalStyle2220.hAlign = x.HAlignType.center;
    globalStyle2220.fontColorRgb = Color.fromARGB(255, 37, 127, 179);

    x.Style globalStyle220D = workbook.styles.add('style220D');
    globalStyle220D.backColorRgb = Color(0xC7F5F7FA);
    globalStyle220D.numberFormat = '_(\* #,##0.00_)';
    globalStyle220D.fontSize = 12;
    globalStyle220D.numberFormat;
    globalStyle220D.hAlign = x.HAlignType.center;
    globalStyle220D.fontColorRgb = Color(0xFFC52611);

    x.Style globalStyle2220D = workbook.styles.add('style2220D');
    globalStyle2220D.backColorRgb = Color(0xC7E1E2E6);
    globalStyle2220D.numberFormat = '_(\* #,##0.00_)';
    // globalStyle222.numberFormat;
    globalStyle2220D.fontSize = 12;
    globalStyle2220D.hAlign = x.HAlignType.center;
    globalStyle2220D.fontColorRgb = Color(0xFFC52611);
////////////-------------------------------------------------------->
    x.Style globalStyle7 = workbook.styles.add('style7');
    globalStyle7.backColorRgb = Color.fromARGB(255, 230, 199, 163);
    globalStyle7.fontName = 'Angsana New';
    globalStyle7.numberFormat = '_(\* #,##0.00_)';
    globalStyle7.hAlign = x.HAlignType.center;
    globalStyle7.fontSize = 15;
    globalStyle7.bold = true;
    globalStyle7.fontColorRgb = Color(0xFFC52611);

    x.Style globalStyle77 = workbook.styles.add('style77');
    globalStyle7.backColorRgb = Color.fromARGB(255, 230, 199, 163);
    globalStyle77.fontName = 'Angsana New';
    globalStyle77.numberFormat = '_(\* #,##0.00_)';
    globalStyle77.hAlign = x.HAlignType.center;
    globalStyle77.fontSize = 15;
    globalStyle77.bold = true;
    globalStyle77.fontColorRgb = Color(0xFFC52611);

    x.Style globalStyle8 = workbook.styles.add('style8');
    globalStyle8.backColorRgb = Color(0xC7F5F7FA);
    globalStyle8.fontName = 'Angsana New';
    globalStyle8.numberFormat = '_(\* #,##0.00_)';
    globalStyle8.hAlign = x.HAlignType.center;
    globalStyle8.fontSize = 15;
    globalStyle8.bold = true;
    // globalStyle8.fontColorRgb = Color(0xFFC52611);

    x.Style globalStyle88 = workbook.styles.add('style88');
    globalStyle88.backColorRgb = Color(0xC7E1E2E6);
    globalStyle88.fontName = 'Angsana New';
    globalStyle88.numberFormat = '_(\* #,##0.00_)';
    globalStyle88.hAlign = x.HAlignType.center;
    globalStyle88.fontSize = 15;
    globalStyle88.bold = true;
    // globalStyle88.fontColorRgb = Color(0xFFC52611);

    globalStyle.backColorRgb = const Color.fromARGB(255, 90, 192, 59);
    x.Style globalStyle2 = workbook.styles.add('style2');
    globalStyle2.backColorRgb = const Color.fromARGB(255, 147, 223, 124);

///////////////////////////////----------------------->
    sheet.getRangeByName('A1').cellStyle = globalStyle22;
    sheet.getRangeByName('B1').cellStyle = globalStyle22;
    sheet.getRangeByName('C1').cellStyle = globalStyle22;
    sheet.getRangeByName('D1').cellStyle = globalStyle22;
    sheet.getRangeByName('E1').cellStyle = globalStyle22;
    sheet.getRangeByName('F1').cellStyle = globalStyle22;
    sheet.getRangeByName('G1').cellStyle = globalStyle22;
    sheet.getRangeByName('H1').cellStyle = globalStyle22;
    sheet.getRangeByName('I1').cellStyle = globalStyle22;
    sheet.getRangeByName('J1').cellStyle = globalStyle22;
    sheet.getRangeByName('L1').cellStyle = globalStyle22;
    sheet.getRangeByName('M1').cellStyle = globalStyle22;
    sheet.getRangeByName('N1').cellStyle = globalStyle22;
    sheet.getRangeByName('K1').cellStyle = globalStyle22;

    sheet.getRangeByName('O1').cellStyle = globalStyle22;
    sheet.getRangeByName('P1').cellStyle = globalStyle22;

    sheet.getRangeByName('A3').setText('ผู้เช่า : ${Status_pe}');
    sheet
        .getRangeByName('E2')
        .setText('รายงาน ข้อมูลผู้เช่า (โซน : $zone_name)');
    // sheet
    //     .getRangeByName('J1')
    //     .setText((zone_name == null) ? 'โซน : ทั้งหมด' : 'โซน : $zone_name');
    // sheet
    //     .getRangeByName('J1')
    //     .setText('โทรศัพท์ : ${renTalModels[0].bill_tel}');

// ExcelSheetProtectionOption
    final x.ExcelSheetProtectionOption options = x.ExcelSheetProtectionOption();
    options.all = true;

// Protecting the Worksheet by using a Password

    sheet.getRangeByName('A2').cellStyle = globalStyle22;
    sheet.getRangeByName('B2').cellStyle = globalStyle22;
    sheet.getRangeByName('C2').cellStyle = globalStyle22;
    sheet.getRangeByName('D2').cellStyle = globalStyle22;
    sheet.getRangeByName('E2').cellStyle = globalStyle22;
    sheet.getRangeByName('F2').cellStyle = globalStyle22;
    sheet.getRangeByName('G2').cellStyle = globalStyle22;
    sheet.getRangeByName('H2').cellStyle = globalStyle22;
    sheet.getRangeByName('I2').cellStyle = globalStyle22;
    sheet.getRangeByName('J2').cellStyle = globalStyle22;
    sheet.getRangeByName('K2').cellStyle = globalStyle22;
    sheet.getRangeByName('L2').cellStyle = globalStyle22;
    sheet.getRangeByName('M2').cellStyle = globalStyle22;
    sheet.getRangeByName('N2').cellStyle = globalStyle22;
    sheet.getRangeByName('O2').cellStyle = globalStyle22;
    sheet.getRangeByName('P2').cellStyle = globalStyle22;

    // sheet.getRangeByName('A2').setText('${renTalModels[0].bill_addr}');
    // sheet.getRangeByName('J2').setText('อีเมล : ${renTalModels[0].bill_email}');

    sheet.getRangeByName('A3').cellStyle = globalStyle22;
    sheet.getRangeByName('B3').cellStyle = globalStyle22;
    sheet.getRangeByName('C3').cellStyle = globalStyle22;
    sheet.getRangeByName('D3').cellStyle = globalStyle22;
    sheet.getRangeByName('E3').cellStyle = globalStyle22;
    sheet.getRangeByName('F3').cellStyle = globalStyle22;
    sheet.getRangeByName('G3').cellStyle = globalStyle22;
    sheet.getRangeByName('H3').cellStyle = globalStyle22;
    sheet.getRangeByName('I3').cellStyle = globalStyle22;
    sheet.getRangeByName('J3').cellStyle = globalStyle22;
    sheet.getRangeByName('K3').cellStyle = globalStyle22;
    sheet.getRangeByName('L3').cellStyle = globalStyle22;
    sheet.getRangeByName('M3').cellStyle = globalStyle22;
    sheet.getRangeByName('N3').cellStyle = globalStyle22;
    sheet.getRangeByName('O3').cellStyle = globalStyle22;
    sheet.getRangeByName('P3').cellStyle = globalStyle22;

    sheet.getRangeByName('I3').setText('ข้อมูล ณ : ${DateTime.now()}');

    globalStyle2.hAlign = x.HAlignType.center;
    sheet.getRangeByName('A4').cellStyle = globalStyle1;
    sheet.getRangeByName('B4').cellStyle = globalStyle1;
    sheet.getRangeByName('C4').cellStyle = globalStyle1;
    sheet.getRangeByName('D4').cellStyle = globalStyle1;
    sheet.getRangeByName('E4').cellStyle = globalStyle1;
    sheet.getRangeByName('F4').cellStyle = globalStyle1;
    sheet.getRangeByName('G4').cellStyle = globalStyle1;
    sheet.getRangeByName('H4').cellStyle = globalStyle1;
    sheet.getRangeByName('I4').cellStyle = globalStyle1;
    sheet.getRangeByName('J4').cellStyle = globalStyle1;
    sheet.getRangeByName('k4').cellStyle = globalStyle1;
    sheet.getRangeByName('L4').cellStyle = globalStyle1;
    sheet.getRangeByName('M4').cellStyle = globalStyle1;
    sheet.getRangeByName('N4').cellStyle = globalStyle1;
    sheet.getRangeByName('O4').cellStyle = globalStyle1;
    sheet.getRangeByName('P4').cellStyle = globalStyle1;

    sheet.getRangeByName('A4').columnWidth = 18;
    sheet.getRangeByName('B4').columnWidth = 18;
    sheet.getRangeByName('C4').columnWidth = 18;
    sheet.getRangeByName('D4').columnWidth = 18;
    sheet.getRangeByName('E4').columnWidth = 18;
    sheet.getRangeByName('F4').columnWidth = 18;
    sheet.getRangeByName('G4').columnWidth = 18;
    sheet.getRangeByName('H4').columnWidth = 18;
    sheet.getRangeByName('I4').columnWidth = 18;
    sheet.getRangeByName('J4').columnWidth = 28;
    sheet.getRangeByName('L4').columnWidth = 28;
    sheet.getRangeByName('M4').columnWidth = 28;
    sheet.getRangeByName('N4').columnWidth = 28;
    sheet.getRangeByName('O4').columnWidth = 28;
    sheet.getRangeByName('P4').columnWidth = 28;

    sheet.getRangeByName('A4').setText('เลขที่สัญญา');
    sheet.getRangeByName('B4').setText('เลขที่สัญญาเดิม');
    sheet.getRangeByName('C4').setText('ชื่อผู้ติดต่อ');
    sheet.getRangeByName('D4').setText('TAX/ID');
    sheet.getRangeByName('E4').setText('ที่อยู่');
    sheet.getRangeByName('F4').setText('ประเภทร้านค้า');
    sheet.getRangeByName('G4').setText('เบอร์ติดต่อ');

    sheet.getRangeByName('H4').setText('รหัสโซน');
    sheet.getRangeByName('I4').setText('โซนพื้นที่');
    sheet.getRangeByName('J4').setText('รหัสพื้นที่');
    sheet.getRangeByName('K4').setText('ขนาดพื้นที่(ต.ร.ม.)');
    sheet.getRangeByName('L4').setText('ระยะเวลาการเช่า');
    sheet.getRangeByName('M4').setText('วันเริ่มสัญญา');
    sheet.getRangeByName('N4').setText('วันสิ้นสุดสัญญา');
    sheet.getRangeByName('O4').setText('ประเภทสัญญา');
    sheet.getRangeByName('P4').setText('สถานะ');
    // sheet.getRangeByName('N4').setText('รูปผู้เช่า');
    // sheet.getRangeByName('O4').setText('รูปร้านค้า');
    // sheet.getRangeByName('P4').setText('รูปแผนผัง');

    for (int i = 0; i < expModels.length; i++) {
      sheet.getRangeByName('${columns[16 + i]}1').cellStyle = globalStyle22;
      sheet.getRangeByName('${columns[16 + i]}2').cellStyle = globalStyle22;
      sheet.getRangeByName('${columns[16 + i]}3').cellStyle = globalStyle22;

      sheet.getRangeByName('${columns[16 + i]}4').cellStyle = globalStyle1;
      sheet.getRangeByName('${columns[16 + i]}4').columnWidth = 35;
      sheet
          .getRangeByName('${columns[16 + i]}4')
          .setText('${expModels[i].expname}');

      // if (i + 1 == expModels.length) {
      //   sheet.getRangeByName('${columns[12 + i + 1]}4').cellStyle =
      //       globalStyle1;
      //   sheet.getRangeByName('${columns[12 + i + 1]}4').columnWidth = 35;
      //   sheet.getRangeByName('${columns[14 + i + 1]}4').setText('อื่นๆ');
      // }
    }
    sheet
        .getRangeByName('${columns[expModels.length + 16]}4')
        .setText('อ้างอิง');

    sheet.getRangeByName('${columns[expModels.length + 16]}1').cellStyle =
        globalStyle22;
    sheet.getRangeByName('${columns[expModels.length + 16]}2').cellStyle =
        globalStyle22;
    sheet.getRangeByName('${columns[expModels.length + 16]}3').cellStyle =
        globalStyle22;
    sheet.getRangeByName('${columns[expModels.length + 16]}4').cellStyle =
        globalStyle22;
    // sheet.getRangeByName('${columns[expModels.length + 15]}3').cellStyle =
    //     globalStyle22;
    // sheet.getRangeByName('${columns[expModels.length + 16]}3').cellStyle =
    //     globalStyle22;

    int indextotol = 0;
    int indextotol_ = 0;
    for (int i = 0; i < teNantModels.length; i++) {
      var index = indextotol;
      dynamic numberColor = i % 2 == 0 ? globalStyle22 : globalStyle222;

      indextotol = indextotol + 1;

      ///---------------------------------------------------------->contractPhotoModels
      sheet.getRangeByName('A${i + 5}').cellStyle = numberColor;
      sheet.getRangeByName('B${i + 5}').cellStyle = numberColor;
      sheet.getRangeByName('C${i + 5}').cellStyle = numberColor;
      sheet.getRangeByName('D${i + 5}').cellStyle = numberColor;
      sheet.getRangeByName('E${i + 5}').cellStyle = numberColor;
      sheet.getRangeByName('F${i + 5}').cellStyle = numberColor;
      sheet.getRangeByName('G${i + 5}').cellStyle = numberColor;
      sheet.getRangeByName('H${i + 5}').cellStyle = numberColor;
      sheet.getRangeByName('I${i + 5}').cellStyle = numberColor;
      sheet.getRangeByName('J${i + 5}').cellStyle = numberColor;
      sheet.getRangeByName('K${i + 5}').cellStyle = numberColor;
      sheet.getRangeByName('L${i + 5}').cellStyle = numberColor;
      sheet.getRangeByName('M${i + 5}').cellStyle = numberColor;
      sheet.getRangeByName('N${i + 5}').cellStyle = numberColor;
      sheet.getRangeByName('O${i + 5}').cellStyle = numberColor;
      sheet.getRangeByName('P${i + 5}').cellStyle = numberColor;

      sheet.getRangeByName('A${i + 5}').setText(
            teNantModels[i].cid == null ? '' : '${teNantModels[i].cid}',
          );
      sheet.getRangeByName('B${i + 5}').setText(
          teNantModels[i].renew_cid == null
              ? ''
              : '${teNantModels[i].renew_cid}');

      sheet.getRangeByName('C${i + 5}').setText(
          teNantModels[i].cname == null ? '' : '${teNantModels[i].cname}');
      sheet.getRangeByName('D${i + 5}').setText(
            teNantModels[i].tax == null ? '' : '${teNantModels[i].tax}',
          );
      sheet.getRangeByName('E${i + 5}').setText(
            teNantModels[i].addr == null ? '' : '${teNantModels[i].addr}',
          );
      sheet.getRangeByName('F${i + 5}').setText(
            teNantModels[i].stype == null ? '' : '${teNantModels[i].stype}',
          );
      sheet.getRangeByName('G${i + 5}').setText(
            teNantModels[i].tel == null ? '' : '${teNantModels[i].tel}',
          );
      sheet.getRangeByName('H${i + 5}').setText(
            (teNantModels[index].zn != null)
                ? (teNantModels[index].zn!.split('_')[0].length <= 4)
                    ? 'CMN0${teNantModels[index].zn!.split('_')[0]}'
                    : 'CMN${teNantModels[index].zn!.split('_')[0]}'
                : (teNantModels[index].zn1!.split('_')[0].length <= 4)
                    ? 'CMN0${teNantModels[index].zn1!.split('_')[0]}'
                    : 'CMN${teNantModels[index].zn1!.split('_')[0]}',
          );
      sheet.getRangeByName('I${i + 5}').setText(
            '${teNantModels[index].zn}',
          );
      sheet.getRangeByName('J${i + 5}').setText(
            teNantModels[i].ln == null ? '' : '${teNantModels[i].ln}',
          );
      sheet.getRangeByName('K${i + 5}').setText(
            teNantModels[i].area == null ? '' : '${teNantModels[i].area}',
          );
      sheet.getRangeByName('L${i + 5}').setText(
            teNantModels[i].period == null
                ? ''
                : '${teNantModels[i].period}  ${teNantModels[i].rtname!.substring(3)}',
          );

      try {
        sheet.getRangeByName('M${index + 5}').cellStyle.numberFormat =
            'dd-MM-yyyy';
        sheet.getRangeByName('M${index + 5}').setValue(
              (teNantModels[index].sdate == null)
                  ? null
                  : DateTime.parse('${teNantModels[index].sdate} 00:00:00'),
            );
      } catch (e) {
        sheet.getRangeByName('M${i + 5}').setText(
              teNantModels[i].sdate == null
                  ? ''
                  : DateFormat('dd-MM-yyyy')
                      .format(
                          DateTime.parse('${teNantModels[i].sdate} 00:00:00'))
                      .toString(),
            );
      }

      try {
        sheet.getRangeByName('N${index + 5}').cellStyle.numberFormat =
            'dd-MM-yyyy';
        sheet.getRangeByName('N${index + 5}').setValue(
              (teNantModels[index].ldate == null)
                  ? null
                  : DateTime.parse('${teNantModels[index].ldate} 00:00:00'),
            );
      } catch (e) {
        sheet.getRangeByName('N${i + 5}').setText(
              teNantModels[i].ldate == null
                  ? ''
                  : DateFormat('dd-MM-yyyy')
                      .format(
                          DateTime.parse('${teNantModels[i].ldate} 00:00:00'))
                      .toString(),
            );
      }

      sheet.getRangeByName('O${i + 5}').setText(
            (teNantModels[index].type_cid == null ||
                    teNantModels[index].type_cid == '')
                ? '-'
                : '${teNantModels[index].type_cid}',
          );
      sheet.getRangeByName('P${i + 5}').setText(
            (datex.isAfter(
                        DateTime.parse('${teNantModels[i].ldate} 00:00:00.000')
                            .subtract(const Duration(days: 0))) ==
                    true)
                ? 'หมดสัญญา'
                : datex.isAfter(DateTime.parse(
                                '${teNantModels[i].ldate} 00:00:00.000')
                            .subtract(Duration(days: open_set_date))) ==
                        true
                    ? 'ใกล้หมดสัญญา'
                    : '${teNantModels[index].st}',
            // teNantModels[i].quantity == '1'
            //     ? datex.isAfter(DateTime.parse(
            //                     '${teNantModels[i].ldate} 00:00:00.000')
            //                 .subtract(const Duration(days: 0))) ==
            //             true
            //         ? 'หมดสัญญา'
            //         :
            // datex.isAfter(DateTime.parse(
            //                         '${teNantModels[i].ldate} 00:00:00.000')
            //                     .subtract(const Duration(days: 30))) ==
            //                 true
            //             ? 'ใกล้หมดสัญญา'
            //             : 'เช่าอยู่'
            //     : teNantModels[i].quantity == '2'
            //         ? 'เสนอราคา'
            //         : teNantModels[i].quantity == '3'
            //             ? 'เสนอราคา(มัดจำ)'
            //             : 'ว่าง',
          );

      String textdata = '${teNantModels[i].exp_array}';
      List<dynamic> dataList = [];

// Check if textdata is not null or empty, and then decode
      if (textdata.isNotEmpty) {
        try {
          dataList = json.decode(textdata) as List<dynamic>;
        } catch (e) {
          // Handle any errors in JSON decoding
          // print('Invalid JSON data: $e');
          dataList = [];
        }
      }

      int count_01 = 15;
      for (int index2 = 0; index2 < expModels.length; index2++) {
        count_01 = count_01 + 1;
        sheet.getRangeByName('${columns[count_01]}${index + 5}').cellStyle =
            numberColor;
        int data_ok = dataList
            .whereType<Map<String, dynamic>>()
            .where((element) =>
                element['ser_exp'].toString() == '${expModels[index2].ser}')
            .map((element) => element['etype_exp'].toString() ?? '0.00')
            .length;
        String etype = (dataList.isEmpty)
            ? ''
            : dataList
                    .whereType<Map<String, dynamic>>()
                    .where((element) =>
                        element['ser_exp'].toString() ==
                        '${expModels[index2].ser}')
                    .map(
                        (element) => element['etype_exp']?.toString() ?? '0.00')
                    .isNotEmpty
                ? dataList
                    .whereType<Map<String, dynamic>>()
                    .where((element) =>
                        element['ser_exp'].toString() ==
                        '${expModels[index2].ser}')
                    .map(
                        (element) => element['etype_exp']?.toString() ?? '0.00')
                    .first
                : '0.00'; // Default value if no matches found

        String ele_ty = (dataList.isEmpty)
            ? ''
            : dataList
                    .whereType<Map<String, dynamic>>()
                    .where((element) =>
                        element['ser_exp'].toString() ==
                        '${expModels[index2].ser}')
                    .map((element) =>
                        element['ele_ty_exp']?.toString() ?? '0.00')
                    .isNotEmpty
                ? dataList
                    .whereType<Map<String, dynamic>>()
                    .where((element) =>
                        element['ser_exp'].toString() ==
                        '${expModels[index2].ser}')
                    .map((element) =>
                        element['ele_ty_exp']?.toString() ?? '0.00')
                    .first
                : '0.00'; // Default value if no matches found

        String qty = (dataList.isEmpty)
            ? ''
            : dataList
                    .whereType<Map<String, dynamic>>()
                    .where((element) =>
                        element['ser_exp'].toString() ==
                        '${expModels[index2].ser}')
                    .map((element) => element['qty_exp']?.toString() ?? '0.00')
                    .isNotEmpty
                ? dataList
                    .whereType<Map<String, dynamic>>()
                    .where((element) =>
                        element['ser_exp'].toString() ==
                        '${expModels[index2].ser}')
                    .map((element) => element['qty_exp']?.toString() ?? '0.00')
                    .first
                : '0.00'; // Default value if no matches found

        double amt = (dataList.isEmpty)
            ? 0.00
            : dataList
                .whereType<Map<String, dynamic>>()
                .where((element) =>
                    element['ser_exp'].toString() == '${expModels[index2].ser}')
                .map((element) =>
                    double.tryParse(element['amt_exp'].toString()) ?? 0.00)
                .fold(0, (prev, wht) => prev + wht);

        double total = (dataList.isEmpty)
            ? 0.00
            : dataList
                .whereType<Map<String, dynamic>>()
                .where((element) =>
                    element['ser_exp'].toString() == '${expModels[index2].ser}')
                .map((element) =>
                    double.tryParse(element['total_exp'].toString()) ?? 0.00)
                .fold(0, (prev, wht) => prev + wht);

        sheet
            .getRangeByName('${columns[count_01]}${index + 5}')
            .setText((data_ok == 0)
                ? ''
                : (etype.toString() == 'F')
                    ? '${nFormat.format(amt)} / บาท'
                    : (ele_ty.toString() == '0' || (ele_ty.toString() == '0.00')
                        ? (qty.toString() == '0.00' || qty == '0')
                            ? '${nFormat.format(total)} / งวด'
                            : '${nFormat.format(double.tryParse(qty) ?? 0.0)} / หน่วย'
                        : 'อัตราพิเศษ'));
      }
      sheet.getRangeByName('${columns[count_01 + 1]}${index + 5}').cellStyle =
          numberColor;
      sheet.getRangeByName('${columns[count_01 + 1]}${index + 5}').setText(
            '${teNantModels[index].wnote}',
          );
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    Uint8List data = Uint8List.fromList(bytes);
    MimeType type = MimeType.MICROSOFTEXCEL;

    if (_verticalGroupValue_NameFile.toString() == 'จากระบบ') {
      String path = await FileSaver.instance.saveFile(
          "ผู้เช่า(${Status_pe}โซน$zone_name)", data, "xlsx",
          mimeType: type);
      log(path);
    } else {
      String path = await FileSaver.instance
          .saveFile("$NameFile_", data, "xlsx", mimeType: type);
      log(path);
    }
  }
}
//2470 / 7 =
