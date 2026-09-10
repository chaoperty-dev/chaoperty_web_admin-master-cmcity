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

import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class Excgen_GetPakanReport_Choice {
  static void exportExcel_GetPakanReport_Choice(
      context,
      NameFile_,
      _verticalGroupValue_NameFile,
      renTal_name,
      Value_Chang_Zone_Pakan,
      contractxPakanModels,
      Mon_GetPakan_Mon,
      YE_GetPakan_Mon) async {
    var nFormat = NumberFormat("#,##0.00", "en_US");
    var nFormat2 = NumberFormat("###0.00", "en_US");
    DateTime datex = DateTime.now();
    String day_ =
        '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}';

    String Tim_ =
        '${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}';
    final x.Workbook workbook = x.Workbook();

    final x.Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'รายงานรับเงินประกันผู้เช่า';
    sheet.pageSetup.topMargin = 1;
    sheet.pageSetup.bottomMargin = 1;
    sheet.pageSetup.leftMargin = 1;
    sheet.pageSetup.rightMargin = 1;

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
    x.Style globalStyle220 = workbook.styles.add('globalStyle220');
    globalStyle220.backColorRgb = Color(0xC7F5F7FA);
    globalStyle220.numberFormat = '_(\* #,##0.00_)';
    globalStyle220.fontSize = 12;
    globalStyle220.numberFormat;
    globalStyle220.hAlign = x.HAlignType.center;

    x.Style globalStyle2220 = workbook.styles.add('globalStyle2220');
    globalStyle2220.backColorRgb = Color.fromARGB(255, 71, 168, 224);
    globalStyle2220.fontName = 'Angsana New';
    globalStyle2220.numberFormat = '_(\* #,##0.00_)';
    globalStyle2220.hAlign = x.HAlignType.center;
    globalStyle2220.fontSize = 16;
    globalStyle2220.bold = true;
    globalStyle2220.borders;
    globalStyle2220.fontColorRgb = Color.fromARGB(255, 3, 3, 3);

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

    // sheet.getRangeByName('A1').cellStyle = globalStyle22;
    // sheet.getRangeByName('B1').cellStyle = globalStyle22;
    // sheet.getRangeByName('C1').cellStyle = globalStyle22;
    // sheet.getRangeByName('D1').cellStyle = globalStyle22;
    // sheet.getRangeByName('E1').cellStyle = globalStyle22;
    // sheet.getRangeByName('F1').cellStyle = globalStyle22;
    // sheet.getRangeByName('G1').cellStyle = globalStyle22;
    // sheet.getRangeByName('H1').cellStyle = globalStyle22;
    // sheet.getRangeByName('I1').cellStyle = globalStyle22;
    // sheet.getRangeByName('J1').cellStyle = globalStyle22;
    // sheet.getRangeByName('K1').cellStyle = globalStyle22;

    // sheet.getRangeByName('L1').cellStyle = globalStyle22;
    // sheet.getRangeByName('M1').cellStyle = globalStyle22;
    // sheet.getRangeByName('N1').cellStyle = globalStyle22;

    // final x.Range range = sheet.getRangeByName('D1');
    // range.setText(
    //   (Value_Chang_Zone_Pakan == null)
    //       ? 'รายงานรับเงินประกัน ประจำเดือน ${Mon_GetPakan_Mon} ${YE_GetPakan_Mon} (กรุณาเลือกโซน)'
    //       : 'รายงานรับเงินประกัน ประจำเดือน ${Mon_GetPakan_Mon} ${YE_GetPakan_Mon} (โซน : $Value_Chang_Zone_Pakan)',
    // );
    sheet.getRangeByName('A1:P1').merge();
    sheet.getRangeByName('A2:P2').merge();
    sheet.getRangeByName('A3:P3').merge();
    sheet.getRangeByName('A4:P4').merge();

    sheet.getRangeByName('A1').setText(
          (Value_Chang_Zone_Pakan == null)
              ? 'รายงานรับเงินประกัน  (กรุณาเลือกโซน)'
              : 'รายงานรับเงินประกัน  (โซน : $Value_Chang_Zone_Pakan)',
        );
    sheet.getRangeByName('A2').setText(
        'ตั้งแต่ครั้งแรก ถึงเดือน: ${Mon_GetPakan_Mon} ${YE_GetPakan_Mon}');
    sheet.getRangeByName('A3').setText(
        'ชื่อสถานประกอบการ บริษัท ชอยส์มินิสโตร์ จำกัด เลขประจำตัวผู้เสียภาษี 0-1055-31085-43-4');
    sheet.getRangeByName('A4').setText('ชื่อสถานประกอบการ เซเว่นอีเลฟเว่น');
// ExcelSheetProtectionOption
    sheet
        .getRangeByName('A5')
        .setText('ทั้งหมด :${contractxPakanModels.length}');
    sheet.getRangeByName('O5').setText('อัพเดต ณ :${DateTime.now()}');
    final x.ExcelSheetProtectionOption options = x.ExcelSheetProtectionOption();
    options.all = true;

    for (int index = 0; index < 6; index++) {
      ////
      sheet.getRangeByName('A${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('B${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('C${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('D${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('E${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('F${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('G${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('H${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('I${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('J${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('K${index + 1}').cellStyle = globalStyle220;

      sheet.getRangeByName('L${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('M${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('N${index + 1}').cellStyle = globalStyle220;

      sheet.getRangeByName('O${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('P${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('Q${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('R${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('S${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('W${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('T${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('U${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('V${index + 1}').cellStyle = globalStyle220;
      // sheet.getRangeByName('Q${index + 1}').cellStyle = globalStyle220;
      // sheet.getRangeByName('R${index + 1}').cellStyle = globalStyle220;
      ////
    }

    sheet.getRangeByName('A5').cellStyle = globalStyle22;
    sheet.getRangeByName('B5').cellStyle = globalStyle22;
    sheet.getRangeByName('C5').cellStyle = globalStyle22;
    sheet.getRangeByName('D5').cellStyle = globalStyle22;
    sheet.getRangeByName('E5').cellStyle = globalStyle22;
    sheet.getRangeByName('F5').cellStyle = globalStyle22;
    sheet.getRangeByName('G5').cellStyle = globalStyle22;
    sheet.getRangeByName('H5').cellStyle = globalStyle22;
    sheet.getRangeByName('I5').cellStyle = globalStyle22;
    sheet.getRangeByName('J5').cellStyle = globalStyle22;
    sheet.getRangeByName('K5').cellStyle = globalStyle22;

    sheet.getRangeByName('L5').cellStyle = globalStyle22;
    sheet.getRangeByName('M5').cellStyle = globalStyle22;
    sheet.getRangeByName('N5').cellStyle = globalStyle22;
    sheet.getRangeByName('O5').cellStyle = globalStyle22;
    sheet.getRangeByName('P5').cellStyle = globalStyle22;
    sheet.getRangeByName('Q5').cellStyle = globalStyle22;
    sheet.getRangeByName('RP5').cellStyle = globalStyle22;
    sheet.getRangeByName('S5').cellStyle = globalStyle22;
    sheet.getRangeByName('T5').cellStyle = globalStyle22;
    sheet.getRangeByName('U5').cellStyle = globalStyle22;
    sheet.getRangeByName('V5').cellStyle = globalStyle22;
    // sheet.getRangeByName('G1').setText(
    //       (Mon_GetPakan_Mon == null || YE_GetPakan_Mon == null)
    //           ? 'เดือน: กรุณาเลือก'
    //           : 'เดือน: ${Mon_GetPakan_Mon}(${YE_GetPakan_Mon})',
    //     );
    // sheet.getRangeByName('G2').setText(
    //       '$day_',
    //     );

    // sheet.getRangeByName('H2').setText(' ข้อมูล ณ วันที่: ${day_}');
    globalStyle2.hAlign = x.HAlignType.center;
    sheet.getRangeByName('A6').cellStyle = globalStyle1;
    sheet.getRangeByName('B6').cellStyle = globalStyle1;
    sheet.getRangeByName('C6').cellStyle = globalStyle1;
    sheet.getRangeByName('D6').cellStyle = globalStyle1;
    sheet.getRangeByName('E6').cellStyle = globalStyle1;
    sheet.getRangeByName('F6').cellStyle = globalStyle1;
    sheet.getRangeByName('G6').cellStyle = globalStyle1;
    sheet.getRangeByName('H6').cellStyle = globalStyle1;
    sheet.getRangeByName('I6').cellStyle = globalStyle1;
    sheet.getRangeByName('J6').cellStyle = globalStyle1;
    sheet.getRangeByName('K6').cellStyle = globalStyle1;
    sheet.getRangeByName('L6').cellStyle = globalStyle1;
    sheet.getRangeByName('M6').cellStyle = globalStyle1;
    sheet.getRangeByName('N6').cellStyle = globalStyle1;
    sheet.getRangeByName('O6').cellStyle = globalStyle1;
    sheet.getRangeByName('P6').cellStyle = globalStyle1;
    sheet.getRangeByName('Q6').cellStyle = globalStyle1;
    sheet.getRangeByName('R6').cellStyle = globalStyle1;
    sheet.getRangeByName('S6').cellStyle = globalStyle1;
    sheet.getRangeByName('T6').cellStyle = globalStyle1;
    sheet.getRangeByName('U6').cellStyle = globalStyle1;
    sheet.getRangeByName('V6').cellStyle = globalStyle1;

    sheet.getRangeByName('A6').columnWidth = 10;
    sheet.getRangeByName('B6').columnWidth = 25;
    sheet.getRangeByName('C6').columnWidth = 20;
    sheet.getRangeByName('D6').columnWidth = 15;
    sheet.getRangeByName('E6').columnWidth = 25;
    sheet.getRangeByName('F6').columnWidth = 25;
    sheet.getRangeByName('G6').columnWidth = 18;
    sheet.getRangeByName('H6').columnWidth = 30;
    sheet.getRangeByName('I6').columnWidth = 18;
    sheet.getRangeByName('J6').columnWidth = 18;
    sheet.getRangeByName('K6').columnWidth = 18;
    sheet.getRangeByName('L6').columnWidth = 25;
    sheet.getRangeByName('M6').columnWidth = 25;
    sheet.getRangeByName('N6').columnWidth = 25;
    sheet.getRangeByName('O6').columnWidth = 25;
    sheet.getRangeByName('P6').columnWidth = 20;
    sheet.getRangeByName('Q6').columnWidth = 20;
    sheet.getRangeByName('R6').columnWidth = 20;
    sheet.getRangeByName('S6').columnWidth = 20;
    sheet.getRangeByName('T6').columnWidth = 20;
    sheet.getRangeByName('U6').columnWidth = 20;
    sheet.getRangeByName('V6').columnWidth = 20;

    sheet.getRangeByName('A6').setText('ลำดับ');
    sheet.getRangeByName('B6').setText('ใบเสร็จเงินประกัน(ครั้งแรก)');
    sheet.getRangeByName('C6').setText('เลขที่สัญญา');
    sheet.getRangeByName('D6').setText('เลขที่สัญญาเดิม');
    sheet.getRangeByName('E6').setText('รหัสสาขา');
    sheet.getRangeByName('F6').setText('ชื่อสาขา');
    sheet.getRangeByName('G6').setText('ล็อค');

    sheet.getRangeByName('H6').setText('บัตรประชาชน');
    sheet.getRangeByName('I6').setText('ชื่อผู้เช่า');
    sheet.getRangeByName('J6').setText('รายละเอียดสินค้า');

    sheet.getRangeByName('K6').setText('เงินประกัน(ก่อนVAT)');
    sheet.getRangeByName('L6').setText('เริ่มสัญญา(สัญญาเดิม)');
    sheet.getRangeByName('M6').setText('สิ้นสุดสัญญา(สัญญาเดิม)');
    sheet.getRangeByName('N6').setText('เริ่มสัญญา(สัญญาล่าสุด)');
    sheet.getRangeByName('O6').setText('สิ้นสุดสัญญา(สัญญาล่าสุด)');
    sheet.getRangeByName('P6').setText('เดือน');
    sheet.getRangeByName('Q6').setText('วันที่ชำระเงินประกันล่าสุด');
    sheet.getRangeByName('R6').setText('สถานะ');
    sheet.getRangeByName('S6').setText('เลขอ้างอิง');
    sheet.getRangeByName('T6').setText('ref1');
    sheet.getRangeByName('U6').setText('ref2');
    sheet.getRangeByName('V6').setText('ref-chao');
    int index1 = 0;
    int indextotol = 0;
    List cid_number = [];
    for (int index = 0; index < contractxPakanModels.length; index++) {
      // // dynamic numberColor = (0 * teNantModels.length + index) % 2 == 0
      // //     ? globalStyle22
      // //     : globalStyle222;

      // // String newCid = '${teNantModels[index].cid}';
      // if (!cid_number.contains(newCid)) {
      //   indextotol = indextotol + 1;
      //   cid_number.add(newCid);
      // } else {
      //   // The value already exists in cid_number, handle it as needed.
      // }
      dynamic numberColor = ((index % 2) == 0) ? globalStyle22 : globalStyle222;

      sheet.getRangeByName('A${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('B${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('C${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('D${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('E${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('F${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('G${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('H${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('I${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('J${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('K${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('L${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('M${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('N${index + 7}').cellStyle = numberColor;
      // sheet.getRangeByName('O${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('P${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('Q${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('R${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('S${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('T${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('U${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('V${index + 7}').cellStyle = numberColor;

      sheet.getRangeByName('O${index + 7}').cellStyle.fontSize = 12;
      sheet.getRangeByName('O${index + 7}').cellStyle.hAlign =
          x.HAlignType.left;
      sheet.getRangeByName('P${index + 7}').cellStyle.fontColorRgb =
          (contractxPakanModels[index].st == null)
              ? Color(0xFFC52611)
              : (contractxPakanModels[index].st == 'ยกเลิกสัญญา')
                  ? Color(0xFFC52611)
                  : datex.isAfter(DateTime.parse(
                                  '${contractxPakanModels[index].ldate} 00:00:00.000')
                              .subtract(const Duration(days: 0))) ==
                          true
                      ? Color.fromARGB(255, 209, 149, 18)
                      : Color.fromARGB(255, 72, 190, 78);

      sheet.getRangeByName('O${index + 7}').cellStyle.backColorRgb =
          ((index % 2) == 0) ? Color(0xC7F5F7FA) : Color(0xC7E1E2E6);
      sheet.getRangeByName('L${index + 7}').cellStyle.numberFormat =
          'dd-MM-yyyy';
      sheet.getRangeByName('M${index + 7}').cellStyle.numberFormat =
          'dd-MM-yyyy';
      sheet.getRangeByName('N${index + 7}').cellStyle.numberFormat =
          'dd-MM-yyyy';
      sheet.getRangeByName('O${index + 7}').cellStyle.numberFormat =
          'dd-MM-yyyy';
      // sheet.getRangeByName('P${index + 7}').cellStyle.numberFormat =
      //     'MM/yyyy';
      sheet.getRangeByName('Q${index + 7}').cellStyle.numberFormat =
          'dd-MM-yyyy';

      sheet.getRangeByName('A${index + 7}').setText('${index + 1}');
      sheet.getRangeByName('B${index + 7}').setText(
            (contractxPakanModels[index].doctax == null ||
                    contractxPakanModels[index].doctax.toString() == '')
                ? (contractxPakanModels[index].docno == null)
                    ? ''
                    : '${contractxPakanModels[index].docno}'
                : '${contractxPakanModels[index].doctax}',
          );
      sheet
          .getRangeByName('C${index + 7}')
          .setText('${contractxPakanModels[index].cid}');
      sheet
          .getRangeByName('D${index + 7}')
          .setText('${contractxPakanModels[index].renew_cid}');

      sheet.getRangeByName('E${index + 7}').setText(
            (contractxPakanModels[index].zn != null)
                ? (contractxPakanModels[index].zn!.split('_')[0].length <= 4)
                    ? 'CMN0${contractxPakanModels[index].zn!.split('_')[0]}'
                    : 'CMN${contractxPakanModels[index].zn!.split('_')[0]}'
                : (contractxPakanModels[index].zn1!.split('_')[0].length <= 4)
                    ? 'CMN0${contractxPakanModels[index].zn1!.split('_')[0]}'
                    : 'CMN${contractxPakanModels[index].zn1!.split('_')[0]}',
            // (contractxPakanModels[index].zser != null)
            //     ? '${contractxPakanModels[index].zser}'
            //     : '${contractxPakanModels[index].zser1}',
          );

      sheet.getRangeByName('F${index + 7}').setText(
          (contractxPakanModels[index].zn != null)
              ? '${contractxPakanModels[index].zn}'
              : '${contractxPakanModels[index].zn1}');

      sheet.getRangeByName('G${index + 7}').setText(
            '${contractxPakanModels[index].ln}',
          );

      sheet.getRangeByName('H${index + 7}').setText(
            '${contractxPakanModels[index].tax}',
          );

      sheet.getRangeByName('I${index + 7}').setText(
            (contractxPakanModels[index].cname == null)
                ? '${contractxPakanModels[index].remark}'
                : '${contractxPakanModels[index].cname}',
          );
      sheet.getRangeByName('J${index + 7}').setText(
            '${contractxPakanModels[index].stype}',
          );

      sheet.getRangeByName('K${index + 7}').setNumber(
            (contractxPakanModels[index].pvat == null)
                ? 0.00
                : double.parse('${contractxPakanModels[index].pvat}'),
          );
      sheet.getRangeByName('L${index + 7}').setValue(
            (contractxPakanModels[index].min_sdate == null ||
                    contractxPakanModels[index].min_sdate.toString() == '')
                ? null
                : DateTime.parse('${contractxPakanModels[index].min_sdate}'),
          );

      // sheet.getRangeByName('L${index + 7}').setText(
      //     (contractxPakanModels[index].min_sdate == null ||
      //             contractxPakanModels[index].min_sdate.toString() == '')
      //         ? ''
      //         : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${contractxPakanModels[index].min_sdate}'))}'
      //     // '${contractxPakanModels[index].sdate}',
      //     );
      sheet.getRangeByName('M${index + 7}').setValue(
            (contractxPakanModels[index].min_ldate == null ||
                    contractxPakanModels[index].min_ldate.toString() == '')
                ? null
                : DateTime.parse('${contractxPakanModels[index].min_ldate}'),
          );
      // sheet.getRangeByName('M${index + 7}').setText(
      //     (contractxPakanModels[index].min_ldate == null ||
      //             contractxPakanModels[index].min_ldate.toString() == '')
      //         ? ''
      //         : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${contractxPakanModels[index].min_ldate}'))}'
      //     // '${contractxPakanModels[index].ldate}',
      //     );
      sheet.getRangeByName('N${index + 7}').setValue(
            (contractxPakanModels[index].sdate == null ||
                    contractxPakanModels[index].sdate.toString() == '')
                ? null
                : DateTime.parse('${contractxPakanModels[index].sdate}'),
          );
      // sheet.getRangeByName('N${index + 7}').setText(
      //     (contractxPakanModels[index].sdate == null ||
      //             contractxPakanModels[index].sdate.toString() == '')
      //         ? ''
      //         : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${contractxPakanModels[index].sdate}'))}'
      //     // '${contractxPakanModels[index].sdate}',
      //     );
      sheet.getRangeByName('O${index + 7}').setValue(
            (contractxPakanModels[index].ldate == null ||
                    contractxPakanModels[index].ldate.toString() == '')
                ? null
                : DateTime.parse('${contractxPakanModels[index].ldate}'),
          );
      // sheet.getRangeByName('O${index + 7}').setText(
      //     (contractxPakanModels[index].ldate == null ||
      //             contractxPakanModels[index].ldate.toString() == '')
      //         ? ''
      //         : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${contractxPakanModels[index].ldate}'))}'
      //     // '${contractxPakanModels[index].ldate}',
      //     );
      // sheet.getRangeByName('P${index + 7}').setValue(
      //       (contractxPakanModels[index].pdate == null ||
      //               contractxPakanModels[index].pdate.toString() == '')
      //           ? null
      //           : DateTime.parse('${contractxPakanModels[index].pdate}'),
      //     );
      sheet.getRangeByName('P${index + 7}').setText(
          (contractxPakanModels[index].pdate == null ||
                  contractxPakanModels[index].pdate.toString() == '')
              ? ''
              : '${contractxPakanModels[index].pdate}');
      sheet.getRangeByName('Q${index + 7}').setValue(
            (contractxPakanModels[index].max_date == null ||
                    contractxPakanModels[index].max_date.toString() == '')
                ? null
                : DateTime.parse('${contractxPakanModels[index].max_date}'),
          );
      // sheet.getRangeByName('Q${index + 7}').setText(
      //     (contractxPakanModels[index].max_date == null ||
      //             contractxPakanModels[index].max_date.toString() == '')
      //         ? ''
      //         : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${contractxPakanModels[index].max_date}'))}'

      //     );
      sheet.getRangeByName('R${index + 7}').setText(
            (contractxPakanModels[index].st == null)
                ? ''
                : (contractxPakanModels[index].st == 'ยกเลิกสัญญา')
                    ? 'ยกเลิกสัญญา'
                    : datex.isAfter(DateTime.parse(
                                    '${contractxPakanModels[index].ldate} 00:00:00.000')
                                .subtract(const Duration(days: 0))) ==
                            true
                        ? 'หมดสัญญา'
                        : '${contractxPakanModels[index].st}',
          );
      sheet.getRangeByName('S${index + 7}').setText(
            (contractxPakanModels[index].wnote == null)
                ? ''
                : '${contractxPakanModels[index].wnote}',
          );

      sheet.getRangeByName('T${index + 7}').setText(
            (contractxPakanModels[index].ref2 == null)
                ? ''
                : '${contractxPakanModels[index].ref2}',
          );
      sheet.getRangeByName('U${index + 7}').setText(
            (contractxPakanModels[index].ref4 == null)
                ? ''
                : '${contractxPakanModels[index].ref4}',
          );
      sheet.getRangeByName('V${index + 7}').setText(
            (contractxPakanModels[index].ref1 == null)
                ? ''
                : '${contractxPakanModels[index].ref1}',
          );
      indextotol = indextotol + 1;
    }
/////////---------------------------->
    sheet.getRangeByName('J${indextotol + 7 + 0}').setText('รวมทั้งหมด: ');
    sheet
        .getRangeByName('K${indextotol + 7 + 0}')
        .setFormula('=SUM(K7:K${indextotol + 7 - 1})');
    sheet.getRangeByName('J${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet.getRangeByName('K${indextotol + 7 + 0}').cellStyle = globalStyle7;

/////////---------------------------->
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    Uint8List data = Uint8List.fromList(bytes);
    MimeType type = MimeType.MICROSOFTEXCEL;
    String path = await FileSaver.instance.saveFile(
        (Value_Chang_Zone_Pakan == null)
            ? 'รายงานรับเงินประกัน ตั้งแต่ครั้งแรกถึงเดือน ${Mon_GetPakan_Mon} ${YE_GetPakan_Mon} (กรุณาเลือกโซน)'
            : 'รายงานรับเงินประกัน ตั้งแต่ครั้งแรกถึงเดือน ${Mon_GetPakan_Mon} ${YE_GetPakan_Mon}',
        data,
        "xlsx",
        mimeType: type);
    log(path);
    cid_number.clear();
    // if (_verticalGroupValue_NameFile.toString() == 'จากระบบ') {
    //   String path = await FileSaver.instance.saveFile(
    //       "ผู้เช่า(${Status[Status_ - 1]})(ณ วันที่${day_})", data, "xlsx",
    //       mimeType: type);
    //   log(path);
    // } else {
    //   String path = await FileSaver.instance
    //       .saveFile("$NameFile_", data, "xlsx", mimeType: type);
    //   log(path);
    // }
  }
}
