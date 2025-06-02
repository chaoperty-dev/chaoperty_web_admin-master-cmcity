import 'dart:convert';
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

class Excgen_teNanDtae_Report_Choice {
  static void exportExcel_teNantDate_Report_Choice(
      context,
      renTal_name,
      teNantModels,
      zone_name_Pe_Mon,
      YE_Pe_Mon,
      Mon_Pe_Mon,
      nameTital,
      teNantModels_New,
      teNantModels_Renew) async {
    DateTime datex = DateTime.now();

    final x.Workbook workbook = x.Workbook(3);

    final x.Worksheet sheet = workbook.worksheets[0];
    final x.Worksheet sheet2 = workbook.worksheets[1];
    final x.Worksheet sheet3 = workbook.worksheets[2];
    sheet.name = 'ผู้เช่า';
    sheet2.name = 'เช่าใหม่';
    sheet3.name = 'ต่อสัญญา';
    // final x.Worksheet sheet = workbook.worksheets[0];
    // sheet.pageSetup.topMargin = 1;
    // sheet.pageSetup.bottomMargin = 1;
    // sheet.pageSetup.leftMargin = 1;
    // sheet.pageSetup.rightMargin = 1;

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
    List<dynamic> Type_exp = [
      {"ser": "35", "st": "1", "pn": "ค่าเช่าพื้นที่ดิน"},

      ///------------------>
      {"ser": "1", "st": "1", "pn": "ค่าเช่าพื้นที่"},

      ///------------------>
      {"ser": "16", "st": "1", "pn": "ค่าบริการ"},

      ///------------------>
      // {"ser": "19", "st": "1", "pn": "ค่าผ้ากันเปื้อน"},
    ];
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
    sheet.getRangeByName('K1').cellStyle = globalStyle22;
    // sheet.getRangeByName('L1').cellStyle = globalStyle22;
    // sheet.getRangeByName('M1').cellStyle = globalStyle22;
    // sheet.getRangeByName('N1').cellStyle = globalStyle22;
    // sheet.getRangeByName('O1').cellStyle = globalStyle22;
    sheet.getRangeByName('A1:I1').merge();
    sheet.getRangeByName('A1:K1').merge();
    sheet.getRangeByName('A2:K2').merge();
    sheet.getRangeByName('A3:K3').merge();
    sheet.getRangeByName('A4:K4').merge();

    sheet2.getRangeByName('A1:I1').merge();
    sheet2.getRangeByName('A1:K1').merge();
    sheet2.getRangeByName('A2:K2').merge();
    sheet2.getRangeByName('A3:K3').merge();
    sheet2.getRangeByName('A4:K4').merge();
    sheet3.getRangeByName('A1:I1').merge();
    sheet3.getRangeByName('A1:K1').merge();
    sheet3.getRangeByName('A2:K2').merge();
    sheet3.getRangeByName('A3:K3').merge();
    sheet3.getRangeByName('A4:K4').merge();
    sheet.getRangeByName('A1').setText(
          (zone_name_Pe_Mon == null)
              ? '$nameTital  (กรุณาเลือกโซน)'
              : '$nameTital  (โซน : $zone_name_Pe_Mon)',
        );
    sheet.getRangeByName('A2').setText(
        (Mon_Pe_Mon.toString() == 'null' || Mon_Pe_Mon == null)
            ? ''
            : 'เดือน ${Mon_Pe_Mon} ${YE_Pe_Mon}');
    sheet.getRangeByName('A3').setText(
        'ชื่อสถานประกอบการ บริษัท ชอยส์มินิสโตร์ จำกัด เลขประจำตัวผู้เสียภาษี 0-1055-31085-43-4');
    sheet.getRangeByName('A4').setText('ชื่อสถานประกอบการ เซเว่นอีเลฟเว่น');
    /////////----------------------------------------->
    sheet2.getRangeByName('A1').setText(
          (zone_name_Pe_Mon == null)
              ? 'รายงานผู้เช่ารายใหม่  (กรุณาเลือกโซน)'
              : 'รายงานผู้เช่ารายใหม่  (โซน : $zone_name_Pe_Mon)',
        );
    sheet2.getRangeByName('A2').setText(
        (Mon_Pe_Mon.toString() == 'null' || Mon_Pe_Mon == null)
            ? ''
            : 'เดือน ${Mon_Pe_Mon} ${YE_Pe_Mon}');
    sheet2.getRangeByName('A3').setText(
        'ชื่อสถานประกอบการ บริษัท ชอยส์มินิสโตร์ จำกัด เลขประจำตัวผู้เสียภาษี 0-1055-31085-43-4');
    sheet2.getRangeByName('A4').setText('ชื่อสถานประกอบการ เซเว่นอีเลฟเว่น');
    sheet2.getRangeByName('A5').setText('ทั้งหมด :${teNantModels_New.length}');
    sheet2.getRangeByName('H5').setText('อัพเดต ณ :${DateTime.now()}');

    /////////----------------------------------------->
    sheet3.getRangeByName('A1').setText(
          (zone_name_Pe_Mon == null)
              ? 'รายงานผู้เช่าต่อสัญญา (กรุณาเลือกโซน)'
              : 'รายงานผู้เช่าต่อสัญญา (โซน : $zone_name_Pe_Mon)',
        );
    sheet3.getRangeByName('A2').setText(
        (Mon_Pe_Mon.toString() == 'null' || Mon_Pe_Mon == null)
            ? ''
            : 'ประจำเดือน ${Mon_Pe_Mon} ${YE_Pe_Mon}');
    sheet3.getRangeByName('A3').setText(
        'ชื่อสถานประกอบการ บริษัท ชอยส์มินิสโตร์ จำกัด เลขประจำตัวผู้เสียภาษี 0-1055-31085-43-4');
    sheet3.getRangeByName('A4').setText('ชื่อสถานประกอบการ เซเว่นอีเลฟเว่น');
    sheet3
        .getRangeByName('A5')
        .setText('ทั้งหมด :${teNantModels_Renew.length}');
    sheet3.getRangeByName('I5').setText('อัพเดต ณ :${DateTime.now()}');
    /////////----------------------------------------->
// ExcelSheetProtectionOption
    final x.ExcelSheetProtectionOption options = x.ExcelSheetProtectionOption();
    options.all = true;

    globalStyle2.hAlign = x.HAlignType.center;
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
      // sheet.getRangeByName('N${index + 1}').cellStyle = globalStyle220;
      // sheet.getRangeByName('O${index + 1}').cellStyle = globalStyle220;
    }
    for (int index = 0; index < 6; index++) {
      dynamic globalStyle_x = (index == 5) ? globalStyle1 : globalStyle220;
      ////---------------->
      sheet2.getRangeByName('A${index + 1}').cellStyle = globalStyle_x;
      sheet2.getRangeByName('B${index + 1}').cellStyle = globalStyle_x;
      sheet2.getRangeByName('C${index + 1}').cellStyle = globalStyle_x;
      sheet2.getRangeByName('D${index + 1}').cellStyle = globalStyle_x;
      sheet2.getRangeByName('E${index + 1}').cellStyle = globalStyle_x;
      sheet2.getRangeByName('F${index + 1}').cellStyle = globalStyle_x;
      sheet2.getRangeByName('G${index + 1}').cellStyle = globalStyle_x;
      sheet2.getRangeByName('H${index + 1}').cellStyle = globalStyle_x;
      sheet2.getRangeByName('I${index + 1}').cellStyle = globalStyle_x;

      sheet2.getRangeByName('J${index + 1}').cellStyle = globalStyle_x;
      sheet2.getRangeByName('K${index + 1}').cellStyle = globalStyle_x;
      sheet2.getRangeByName('L${index + 1}').cellStyle = globalStyle_x;
      sheet2.getRangeByName('M${index + 1}').cellStyle = globalStyle_x;
      sheet2.getRangeByName('N${index + 1}').cellStyle = globalStyle_x;
      sheet2.getRangeByName('O${index + 1}').cellStyle = globalStyle_x;
      sheet2.getRangeByName('P${index + 1}').cellStyle = globalStyle_x;
      sheet2.getRangeByName('Q${index + 1}').cellStyle = globalStyle_x;
      sheet2.getRangeByName('R${index + 1}').cellStyle = globalStyle_x;
      sheet2.getRangeByName('S${index + 1}').cellStyle = globalStyle_x;
      sheet2.getRangeByName('T${index + 1}').cellStyle = globalStyle_x;
      sheet2.getRangeByName('U${index + 1}').cellStyle = globalStyle_x;
      sheet2.getRangeByName('V${index + 1}').cellStyle = globalStyle_x;
      sheet2.getRangeByName('W${index + 1}').cellStyle = globalStyle_x;
      sheet2.getRangeByName('X${index + 1}').cellStyle = globalStyle_x;
      sheet2.getRangeByName('Y${index + 1}').cellStyle = globalStyle_x;
      sheet2.getRangeByName('Z${index + 1}').cellStyle = globalStyle_x;
      sheet2.getRangeByName('AA${index + 1}').cellStyle = globalStyle_x;
      sheet2.getRangeByName('AB${index + 1}').cellStyle = globalStyle_x;
      ////---------------->
      sheet3.getRangeByName('A${index + 1}').cellStyle = globalStyle_x;
      sheet3.getRangeByName('B${index + 1}').cellStyle = globalStyle_x;
      sheet3.getRangeByName('C${index + 1}').cellStyle = globalStyle_x;
      sheet3.getRangeByName('D${index + 1}').cellStyle = globalStyle_x;
      sheet3.getRangeByName('E${index + 1}').cellStyle = globalStyle_x;
      sheet3.getRangeByName('F${index + 1}').cellStyle = globalStyle_x;
      sheet3.getRangeByName('G${index + 1}').cellStyle = globalStyle_x;
      sheet3.getRangeByName('H${index + 1}').cellStyle = globalStyle_x;
      sheet3.getRangeByName('I${index + 1}').cellStyle = globalStyle_x;

      sheet3.getRangeByName('J${index + 1}').cellStyle = globalStyle_x;
      sheet3.getRangeByName('K${index + 1}').cellStyle = globalStyle_x;
      sheet3.getRangeByName('L${index + 1}').cellStyle = globalStyle_x;
      sheet3.getRangeByName('M${index + 1}').cellStyle = globalStyle_x;
      sheet3.getRangeByName('N${index + 1}').cellStyle = globalStyle_x;
      sheet3.getRangeByName('O${index + 1}').cellStyle = globalStyle_x;
      sheet3.getRangeByName('P${index + 1}').cellStyle = globalStyle_x;
      sheet3.getRangeByName('Q${index + 1}').cellStyle = globalStyle_x;
      sheet3.getRangeByName('R${index + 1}').cellStyle = globalStyle_x;
      sheet3.getRangeByName('S${index + 1}').cellStyle = globalStyle_x;
      sheet3.getRangeByName('T${index + 1}').cellStyle = globalStyle_x;
      sheet3.getRangeByName('U${index + 1}').cellStyle = globalStyle_x;
      sheet3.getRangeByName('V${index + 1}').cellStyle = globalStyle_x;
      sheet3.getRangeByName('W${index + 1}').cellStyle = globalStyle_x;
      sheet3.getRangeByName('X${index + 1}').cellStyle = globalStyle_x;
      sheet3.getRangeByName('Y${index + 1}').cellStyle = globalStyle_x;
      sheet3.getRangeByName('Z${index + 1}').cellStyle = globalStyle_x;
      sheet3.getRangeByName('AA${index + 1}').cellStyle = globalStyle_x;
      sheet3.getRangeByName('AB${index + 1}').cellStyle = globalStyle_x;
    }

    sheet.getRangeByName('A5').setText('ทั้งหมด :${teNantModels.length}');
    sheet.getRangeByName('I5').setText('อัพเดต ณ :${DateTime.now()}');
    // sheet.getRangeByName('I5').setText(' ทั้งหมด: ${teNantModels.length}');
    // sheet.getRangeByName('I5').setText(' ข้อมูล ณ วันที่: ${datex}');

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
    // sheet.getRangeByName('N6').cellStyle = globalStyle1;
    // sheet.getRangeByName('O6').cellStyle = globalStyle1;

    sheet.getRangeByName('A6').columnWidth = 10;
    sheet.getRangeByName('B6').columnWidth = 18;
    sheet.getRangeByName('C6').columnWidth = 25;
    sheet.getRangeByName('D6').columnWidth = 25;
    sheet.getRangeByName('E6').columnWidth = 18;
    sheet.getRangeByName('F6').columnWidth = 25;
    sheet.getRangeByName('G6').columnWidth = 18;
    sheet.getRangeByName('H6').columnWidth = 25;
    sheet.getRangeByName('I6').columnWidth = 18;
    // sheet.getRangeByName('I4:K4').merge();
    sheet.getRangeByName('J4').columnWidth = 25;
    sheet.getRangeByName('K4').columnWidth = 25;

    sheet.getRangeByName('L4').columnWidth = 18;
    sheet.getRangeByName('M4').columnWidth = 18;
///////----------------------->
    sheet2.getRangeByName('A6').columnWidth = 10;
    sheet2.getRangeByName('B6').columnWidth = 18;
    sheet2.getRangeByName('C6').columnWidth = 25;
    sheet2.getRangeByName('D6').columnWidth = 25;
    sheet2.getRangeByName('E6').columnWidth = 18;
    sheet2.getRangeByName('F6').columnWidth = 25;
    sheet2.getRangeByName('G6').columnWidth = 18;
    sheet2.getRangeByName('H6').columnWidth = 25;
    sheet2.getRangeByName('I6').columnWidth = 18;
    sheet2.getRangeByName('J4').columnWidth = 25;
    sheet2.getRangeByName('K4').columnWidth = 25;
    sheet2.getRangeByName('L4').columnWidth = 18;
    sheet2.getRangeByName('M4').columnWidth = 18;
    sheet2.getRangeByName('N4').columnWidth = 18;
    sheet2.getRangeByName('O4').columnWidth = 18;
    sheet2.getRangeByName('P4').columnWidth = 18;
    sheet2.getRangeByName('Q4').columnWidth = 18;
    sheet2.getRangeByName('R4').columnWidth = 18;
    sheet2.getRangeByName('S4').columnWidth = 18;
    sheet2.getRangeByName('T4').columnWidth = 18;
    sheet2.getRangeByName('U4').columnWidth = 18;
    sheet2.getRangeByName('V4').columnWidth = 18;
    sheet2.getRangeByName('W4').columnWidth = 18;
    sheet2.getRangeByName('X4').columnWidth = 18;
    sheet2.getRangeByName('Y4').columnWidth = 18;
    sheet2.getRangeByName('Z4').columnWidth = 18;
    sheet2.getRangeByName('AA4').columnWidth = 18;
    sheet2.getRangeByName('AB4').columnWidth = 18;
///////----------------------->
    sheet3.getRangeByName('A6').columnWidth = 10;
    sheet3.getRangeByName('B6').columnWidth = 18;
    sheet3.getRangeByName('C6').columnWidth = 25;
    sheet3.getRangeByName('D6').columnWidth = 25;
    sheet3.getRangeByName('E6').columnWidth = 18;
    sheet3.getRangeByName('F6').columnWidth = 25;
    sheet3.getRangeByName('G6').columnWidth = 18;
    sheet3.getRangeByName('H6').columnWidth = 25;
    sheet3.getRangeByName('I6').columnWidth = 18;
    sheet3.getRangeByName('J4').columnWidth = 25;
    sheet3.getRangeByName('K4').columnWidth = 25;
    sheet3.getRangeByName('L4').columnWidth = 18;
    sheet3.getRangeByName('M4').columnWidth = 18;
    sheet3.getRangeByName('N4').columnWidth = 18;
    sheet3.getRangeByName('O4').columnWidth = 18;
    sheet3.getRangeByName('P4').columnWidth = 18;
    sheet3.getRangeByName('Q4').columnWidth = 18;
    sheet3.getRangeByName('R4').columnWidth = 18;
    sheet3.getRangeByName('S4').columnWidth = 18;
    sheet3.getRangeByName('T4').columnWidth = 18;
    sheet3.getRangeByName('U4').columnWidth = 18;
    sheet3.getRangeByName('V4').columnWidth = 18;
    sheet3.getRangeByName('W4').columnWidth = 18;
    sheet3.getRangeByName('X4').columnWidth = 18;
    sheet3.getRangeByName('Y4').columnWidth = 18;
    sheet3.getRangeByName('Z4').columnWidth = 18;
    sheet3.getRangeByName('AA4').columnWidth = 18;
    sheet3.getRangeByName('AB4').columnWidth = 18;
///////----------------------->
    sheet.getRangeByName('A6').setText('ลำดับ');
    sheet.getRangeByName('B6').setText('เลขที่สัญญา');
    sheet.getRangeByName('C6').setText('เลขที่สัญญาเดิม');
    // sheet.getRangeByName('D6').setText('ชื่อร้านค้า/บริษัท');
    sheet.getRangeByName('D6').setText('ชื่อผู้ติดต่อ');
    sheet.getRangeByName('E6').setText('รหัสสาขา');
    sheet.getRangeByName('F6').setText('โซนพื้นที่');
    sheet.getRangeByName('G6').setText('รหัสพื้นที่');
    sheet.getRangeByName('H6').setText('ประเภท');
    sheet.getRangeByName('I6').setText('วันเริ่มสัญญา');
    sheet.getRangeByName('J6').setText('วันสิ้นสุดสัญญา');
    // sheet.getRangeByName('L6').setText('เหตุผล');
    sheet.getRangeByName('K6').setText('สถานะ');
    sheet.getRangeByName('L6').setText('ผู้ดูแล');
    sheet.getRangeByName('M6').setText('อ้างอิง');
    ///////----------------------------->
    sheet2.getRangeByName('A6').setText('ลำดับ');
    sheet2.getRangeByName('B6').setText('เลขที่สัญญา');
    sheet2.getRangeByName('C6').setText('เลขที่สัญญาเดิม');
    sheet2.getRangeByName('D6').setText('ชื่อผู้ติดต่อ');
    sheet2.getRangeByName('E6').setText('รหัสสาขา');
    sheet2.getRangeByName('F6').setText('โซนพื้นที่');
    sheet2.getRangeByName('G6').setText('รหัสพื้นที่');
    sheet2.getRangeByName('H6').setText('ประเภทสินค้า');
    sheet2.getRangeByName('I6').setText('ประเภท');
    sheet2.getRangeByName('J6').setText('วันเริ่มสัญญา');
    sheet2.getRangeByName('K6').setText('วันสิ้นสุดสัญญา');

    sheet2.getRangeByName('L6').setText('ระยะเวลาการเช่า');
    sheet2.getRangeByName('M6').setText('ค่าเช่าพื้นที่ดิน');
    sheet2.getRangeByName('N6').setText('VAT7% ค่าเช่าพื้นที่ดิน');
    sheet2.getRangeByName('O6').setText('ค่าเช่าพื้นที่ดินรวมVAT');

    sheet2.getRangeByName('P6').setText('ค่าเช่าพื้นที่');
    sheet2.getRangeByName('Q6').setText('VAT7% ค่าเช่าพื้นที่');
    sheet2.getRangeByName('R6').setText('ค่าเช่าพื้นที่รวมVAT');

    sheet2.getRangeByName('S6').setText('ค่าบริการ');
    sheet2.getRangeByName('T6').setText('VAT7% ค่าบริการ');
    sheet2.getRangeByName('U6').setText('ค่าบริการรวมVAT');

    sheet2.getRangeByName('V6').setText('เงินประกัน');
    sheet2.getRangeByName('W6').setText('VAT7% เงินประกัน');
    sheet2.getRangeByName('X6').setText('เงินประกันรวมVAT');
    sheet2.getRangeByName('Y6').setText('ผ้ากันเปื้อน');
    // sheet.getRangeByName('L6').setText('เหตุผล');
    sheet2.getRangeByName('Z6').setText('สถานะ');
    sheet2.getRangeByName('AA6').setText('ผู้ดูแล');
    sheet2.getRangeByName('AB6').setText('อ้างอิง');
    ///////----------------------------->
    sheet3.getRangeByName('A6').setText('ลำดับ');
    sheet3.getRangeByName('B6').setText('เลขที่สัญญา');
    sheet3.getRangeByName('C6').setText('เลขที่สัญญาเดิม');
    sheet3.getRangeByName('D6').setText('ชื่อผู้ติดต่อ');
    sheet3.getRangeByName('E6').setText('รหัสสาขา');
    sheet3.getRangeByName('F6').setText('โซนพื้นที่');
    sheet3.getRangeByName('G6').setText('รหัสพื้นที่');
    sheet3.getRangeByName('H6').setText('ประเภทสินค้า');
    sheet3.getRangeByName('I6').setText('ประเภท');
    sheet3.getRangeByName('J6').setText('วันเริ่มสัญญา');
    sheet3.getRangeByName('K6').setText('วันสิ้นสุดสัญญา');

    sheet3.getRangeByName('L6').setText('ระยะเวลาการเช่า');
    sheet3.getRangeByName('M6').setText('ค่าเช่าพื้นที่ดิน');
    sheet3.getRangeByName('N6').setText('VAT7% ค่าเช่าพื้นที่ดิน');
    sheet3.getRangeByName('O6').setText('ค่าเช่าพื้นที่ดินรวมVAT');

    sheet3.getRangeByName('P6').setText('ค่าเช่าพื้นที่');
    sheet3.getRangeByName('Q6').setText('VAT7% ค่าเช่าพื้นที่');
    sheet3.getRangeByName('R6').setText('ค่าเช่าพื้นที่รวมVAT');

    sheet3.getRangeByName('S6').setText('ค่าบริการ');
    sheet3.getRangeByName('T6').setText('VAT7% ค่าบริการ');
    sheet3.getRangeByName('U6').setText('ค่าบริการรวมVAT');

    sheet3.getRangeByName('V6').setText('เงินประกัน');
    sheet3.getRangeByName('W6').setText('VAT7% เงินประกัน');
    sheet3.getRangeByName('X6').setText('เงินประกันรวมVAT');
    sheet3.getRangeByName('Y6').setText('วันที่ทำรายการต่อสัญญา');
    // sheet.getRangeByName('L6').setText('เหตุผล');
    sheet3.getRangeByName('Z6').setText('สถานะ');
    sheet3.getRangeByName('AA6').setText('ผู้ดูแล');
    sheet3.getRangeByName('AB6').setText('อ้างอิง');
    ///////----------------------------->
    // sheet.getRangeByName('L4').setText('ราคาก่อน Vat');
    // sheet.getRangeByName('M4').setText('ราคารวม Vat');
    // sheet.getRangeByName('N4').setText('ส่วนลด');
    int indextotol = 0;
    for (var index = 0; index < teNantModels.length; index++) {
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
      // sheet.getRangeByName('N${index + 7}').cellStyle = numberColor;
      // sheet.getRangeByName('O${index + 7}').cellStyle = numberColor;
      // sheet
      //     .getRangeByName('I${indextotol + 5 - 1}:K${indextotol + 5 - 1}')
      //     .merge();
      sheet.getRangeByName('A${index + 7}').setText(
            '${index + 1}',
          );
      sheet.getRangeByName('B${index + 7}').setText(
            '${teNantModels[index].cid}',
          );
      sheet.getRangeByName('C${index + 7}').setText(
            '${teNantModels[index].renew_cid}',
          );
      // sheet.getRangeByName('D${index + 7}').setText(
      //       '${teNantModels[index].sname}',
      //     );
      sheet.getRangeByName('D${index + 7}').setText(
            '${teNantModels[index].cname}',
          );
      sheet.getRangeByName('E${index + 7}').setText(
            (teNantModels[index].zn!.split('_')[0].length <= 4)
                ? 'CMN0${teNantModels[index].zn!.split('_')[0]}'
                : 'CMN${teNantModels[index].zn!.split('_')[0]}',
          );

      sheet.getRangeByName('F${index + 7}').setText(
            '${teNantModels[index].zn}',
          );
      sheet.getRangeByName('G${index + 7}').setText(
            '${teNantModels[index].ln}',
          );
      sheet.getRangeByName('H${index + 7}').setText(
            '${teNantModels[index].rtname}',
          );
      try {
        sheet.getRangeByName('I${index + 7}').cellStyle.numberFormat =
            'dd-MM-yyyy';
        sheet.getRangeByName('I${index + 7}').setValue(
              (teNantModels[index].sdate == null)
                  ? null
                  : DateTime.parse('${teNantModels[index].sdate} 00:00:00'),
            );
      } catch (e) {
        sheet.getRangeByName('I${index + 7}').setText(
              (teNantModels[index].sdate == null)
                  ? '${teNantModels[index].sdate}'
                  : '${DateFormat('dd-MM').format(DateTime.parse('${teNantModels[index].sdate} 00:00:00'))}-${DateTime.parse('${teNantModels[index].sdate} 00:00:00').year + 0}',
            );
      }
      try {
        sheet.getRangeByName('J${index + 7}').cellStyle.numberFormat =
            'dd-MM-yyyy';
        sheet.getRangeByName('J${index + 7}').setValue(
              (teNantModels[index].ldate == null)
                  ? null
                  : DateTime.parse('${teNantModels[index].ldate} 00:00:00'),
            );
      } catch (e) {
        sheet.getRangeByName('J${index + 7}').setText(
              (teNantModels[index].ldate == null)
                  ? '${teNantModels[index].ldate}'
                  : '${DateFormat('dd-MM').format(DateTime.parse('${teNantModels[index].ldate} 00:00:00'))}-${DateTime.parse('${teNantModels[index].ldate} 00:00:00').year + 0}',
            );
      }

      sheet
          .getRangeByName('K${index + 7}')
          .setText('${teNantModels[index].st}');
      sheet
          .getRangeByName('L${index + 7}')
          .setText('${teNantModels[index].name_user}');
      sheet
          .getRangeByName('M${index + 7}')
          .setText('${teNantModels[index].wnote}');
    }
/////------------------------------------------------------->
    for (var index = 0; index < teNantModels_New.length; index++) {
      dynamic numberColor = ((index % 2) == 0) ? globalStyle22 : globalStyle222;
      sheet2.getRangeByName('A${index + 7}').cellStyle = numberColor;
      sheet2.getRangeByName('B${index + 7}').cellStyle = numberColor;
      sheet2.getRangeByName('C${index + 7}').cellStyle = numberColor;
      sheet2.getRangeByName('D${index + 7}').cellStyle = numberColor;
      sheet2.getRangeByName('E${index + 7}').cellStyle = numberColor;
      sheet2.getRangeByName('F${index + 7}').cellStyle = numberColor;
      sheet2.getRangeByName('G${index + 7}').cellStyle = numberColor;
      sheet2.getRangeByName('H${index + 7}').cellStyle = numberColor;
      sheet2.getRangeByName('I${index + 7}').cellStyle = numberColor;

      sheet2.getRangeByName('J${index + 7}').cellStyle = numberColor;
      sheet2.getRangeByName('K${index + 7}').cellStyle = numberColor;
      sheet2.getRangeByName('L${index + 7}').cellStyle = numberColor;
      sheet2.getRangeByName('M${index + 7}').cellStyle = numberColor;
      sheet2.getRangeByName('N${index + 7}').cellStyle = numberColor;
      sheet2.getRangeByName('O${index + 7}').cellStyle = numberColor;
      sheet2.getRangeByName('P${index + 7}').cellStyle = numberColor;
      sheet2.getRangeByName('Q${index + 7}').cellStyle = numberColor;
      sheet2.getRangeByName('R${index + 7}').cellStyle = numberColor;
      sheet2.getRangeByName('S${index + 7}').cellStyle = numberColor;
      sheet2.getRangeByName('T${index + 7}').cellStyle = numberColor;
      sheet2.getRangeByName('U${index + 7}').cellStyle = numberColor;
      sheet2.getRangeByName('V${index + 7}').cellStyle = numberColor;
      sheet2.getRangeByName('W${index + 7}').cellStyle = numberColor;
      sheet2.getRangeByName('X${index + 7}').cellStyle = numberColor;
      sheet2.getRangeByName('Y${index + 7}').cellStyle = numberColor;
      sheet2.getRangeByName('Z${index + 7}').cellStyle = numberColor;
      sheet2.getRangeByName('AA${index + 7}').cellStyle = numberColor;
      sheet2.getRangeByName('AB${index + 7}').cellStyle = numberColor;
      // sheet.getRangeByName('N${index + 7}').cellStyle = numberColor;
      // sheet.getRangeByName('O${index + 7}').cellStyle = numberColor;
      // sheet
      //     .getRangeByName('I${indextotol + 5 - 1}:K${indextotol + 5 - 1}')
      //     .merge();
      sheet2.getRangeByName('A${index + 7}').setText(
            '${index + 1}',
          );
      sheet2.getRangeByName('B${index + 7}').setText(
            '${teNantModels_New[index].cid}',
          );
      sheet2.getRangeByName('C${index + 7}').setText(
            '${teNantModels_New[index].renew_cid}',
          );
      // sheet.getRangeByName('D${index + 7}').setText(
      //       '${teNantModels[index].sname}',
      //     );
      sheet2.getRangeByName('D${index + 7}').setText(
            '${teNantModels_New[index].cname}',
          );
      sheet2.getRangeByName('E${index + 7}').setText(
            (teNantModels_New[index].zn!.split('_')[0].length <= 4)
                ? 'CMN0${teNantModels_New[index].zn!.split('_')[0]}'
                : 'CMN${teNantModels_New[index].zn!.split('_')[0]}',
          );

      sheet2.getRangeByName('F${index + 7}').setText(
            '${teNantModels_New[index].zn}',
          );
      sheet2.getRangeByName('G${index + 7}').setText(
            '${teNantModels_New[index].ln}',
          );
      sheet2.getRangeByName('H${index + 7}').setText(
            '${teNantModels_New[index].stype}',
          );
      sheet2.getRangeByName('I${index + 7}').setText(
            '${teNantModels_New[index].rtname}',
          );
      try {
        sheet2.getRangeByName('J${index + 7}').cellStyle.numberFormat =
            'dd-MM-yyyy';
        sheet2.getRangeByName('J${index + 7}').setValue(
              (teNantModels_New[index].sdate == null)
                  ? null
                  : DateTime.parse('${teNantModels_New[index].sdate} 00:00:00'),
            );
      } catch (e) {
        sheet2.getRangeByName('J${index + 7}').setText(
              (teNantModels_New[index].sdate == null)
                  ? '${teNantModels_New[index].sdate}'
                  : '${DateFormat('dd-MM').format(DateTime.parse('${teNantModels_New[index].sdate} 00:00:00'))}-${DateTime.parse('${teNantModels_New[index].sdate} 00:00:00').year + 0}',
            );
      }
      try {
        sheet2.getRangeByName('K${index + 7}').cellStyle.numberFormat =
            'dd-MM-yyyy';
        sheet2.getRangeByName('K${index + 7}').setValue(
              (teNantModels_New[index].ldate == null)
                  ? null
                  : DateTime.parse('${teNantModels_New[index].ldate} 00:00:00'),
            );
      } catch (e) {
        sheet2.getRangeByName('K${index + 7}').setText(
              (teNantModels_New[index].ldate == null)
                  ? '${teNantModels_New[index].ldate}'
                  : '${DateFormat('dd-MM').format(DateTime.parse('${teNantModels_New[index].ldate} 00:00:00'))}-${DateTime.parse('${teNantModels_New[index].ldate} 00:00:00').year + 0}',
            );
      }

      sheet2.getRangeByName('L${index + 7}').setText(
            (teNantModels_New[index].rtname.toString() == 'รายวัน')
                ? '${teNantModels_New[index].period}  วัน'
                : (teNantModels_New[index].rtname.toString() == 'รายสัปดาห์')
                    ? '${teNantModels_New[index].period}  สัปดาห์'
                    : (teNantModels_New[index].rtname.toString() == 'รายเดือน')
                        ? '${teNantModels_New[index].period}  เดือน'
                        : '${teNantModels_New[index].period}  ${teNantModels_New[index].rtname}',
          );
      //////////----------------------->
      String textdata = '${teNantModels_New[index].exp_array}';
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
      double total_apron = (dataList.isEmpty)
          ? 0.00
          : dataList
              .whereType<Map<String, dynamic>>()
              .where((element) => element['ser_exp'].toString() == '19')
              .map((element) => double.parse(element['total_exp'].toString()))
              .fold(0, (prev, wht) => prev + wht);
      for (int index2 = 0; index2 < Type_exp.length; index2++) {
        double pvat = (dataList.isEmpty)
            ? 0.00
            : dataList
                .whereType<Map<String, dynamic>>()
                .where((element) =>
                    element['ser_exp'].toString() ==
                    '${Type_exp[index2]["ser"]}')
                .map((element) => double.parse(element['pvat_exp'].toString()))
                .fold(0, (prev, wht) => prev + wht);

        double vat = (dataList.isEmpty)
            ? 0.00
            : dataList
                .whereType<Map<String, dynamic>>()
                .where((element) =>
                    element['ser_exp'].toString() ==
                    '${Type_exp[index2]["ser"]}')
                .map((element) => double.parse(element['vat_exp'].toString()))
                .fold(0, (prev, wht) => prev + wht);
        double total = (dataList.isEmpty)
            ? 0.00
            : dataList
                .whereType<Map<String, dynamic>>()
                .where((element) =>
                    element['ser_exp'].toString() ==
                    '${Type_exp[index2]["ser"]}')
                .map((element) => double.parse(element['total_exp'].toString()))
                .fold(0, (prev, wht) => prev + wht);

        if (index2 == 0) sheet2.getRangeByName('M${index + 7}').setNumber(pvat);

        if (index2 == 0) sheet2.getRangeByName('N${index + 7}').setNumber(vat);

        if (index2 == 0)
          sheet2.getRangeByName('O${index + 7}').setNumber(total);

        if (index2 == 1) sheet2.getRangeByName('P${index + 7}').setNumber(pvat);

        if (index2 == 1) sheet2.getRangeByName('Q${index + 7}').setNumber(vat);

        if (index2 == 1)
          sheet2.getRangeByName('R${index + 7}').setNumber(total);

        if (index2 == 2)
          sheet2.getRangeByName('S${index + 7}')..setNumber(pvat);

        if (index2 == 2) sheet2.getRangeByName('T${index + 7}').setNumber(vat);

        if (index2 == 2)
          sheet2.getRangeByName('U${index + 7}').setNumber(total);
      }
      sheet2.getRangeByName('V${index + 7}').setNumber(
          (teNantModels_New[index].pvat_pakan == null)
              ? 0.00
              : double.parse('${teNantModels_New[index].pvat_pakan}'));

      sheet2.getRangeByName('W${index + 7}').setNumber(
          (teNantModels_New[index].pakan_vat == null)
              ? 0.00
              : double.parse('${teNantModels_New[index].pakan_vat}'));

      sheet2.getRangeByName('X${index + 7}').setNumber(
          (teNantModels_New[index].total_pakan == null)
              ? 0.00
              : double.parse('${teNantModels_New[index].total_pakan}'));

      sheet2.getRangeByName('Y${index + 7}').setNumber(total_apron);
      sheet2
          .getRangeByName('Z${index + 7}')
          .setText('${teNantModels_New[index].st}');
      sheet2
          .getRangeByName('AA${index + 7}')
          .setText('${teNantModels_New[index].name_user}');
      sheet2
          .getRangeByName('AB${index + 7}')
          .setText('${teNantModels_New[index].wnote}');
    }
/////------------------------------------------------------->
    for (var index = 0; index < teNantModels_Renew.length; index++) {
      dynamic numberColor = ((index % 2) == 0) ? globalStyle22 : globalStyle222;
      sheet3.getRangeByName('A${index + 7}').cellStyle = numberColor;
      sheet3.getRangeByName('B${index + 7}').cellStyle = numberColor;
      sheet3.getRangeByName('C${index + 7}').cellStyle = numberColor;
      sheet3.getRangeByName('D${index + 7}').cellStyle = numberColor;
      sheet3.getRangeByName('E${index + 7}').cellStyle = numberColor;
      sheet3.getRangeByName('F${index + 7}').cellStyle = numberColor;
      sheet3.getRangeByName('G${index + 7}').cellStyle = numberColor;
      sheet3.getRangeByName('H${index + 7}').cellStyle = numberColor;
      sheet3.getRangeByName('I${index + 7}').cellStyle = numberColor;

      sheet3.getRangeByName('J${index + 7}').cellStyle = numberColor;
      sheet3.getRangeByName('K${index + 7}').cellStyle = numberColor;
      sheet3.getRangeByName('L${index + 7}').cellStyle = numberColor;
      sheet3.getRangeByName('M${index + 7}').cellStyle = numberColor;
      sheet3.getRangeByName('N${index + 7}').cellStyle = numberColor;
      sheet3.getRangeByName('O${index + 7}').cellStyle = numberColor;
      sheet3.getRangeByName('P${index + 7}').cellStyle = numberColor;
      sheet3.getRangeByName('Q${index + 7}').cellStyle = numberColor;
      sheet3.getRangeByName('R${index + 7}').cellStyle = numberColor;
      sheet3.getRangeByName('S${index + 7}').cellStyle = numberColor;
      sheet3.getRangeByName('T${index + 7}').cellStyle = numberColor;
      sheet3.getRangeByName('U${index + 7}').cellStyle = numberColor;
      sheet3.getRangeByName('V${index + 7}').cellStyle = numberColor;
      sheet3.getRangeByName('W${index + 7}').cellStyle = numberColor;
      sheet3.getRangeByName('X${index + 7}').cellStyle = numberColor;
      sheet3.getRangeByName('Y${index + 7}').cellStyle = numberColor;
      sheet3.getRangeByName('Z${index + 7}').cellStyle = numberColor;
      sheet3.getRangeByName('AA${index + 7}').cellStyle = numberColor;
      sheet3.getRangeByName('AB${index + 7}').cellStyle = numberColor;
      // sheet.getRangeByName('N${index + 7}').cellStyle = numberColor;
      // sheet.getRangeByName('O${index + 7}').cellStyle = numberColor;
      // sheet
      //     .getRangeByName('I${indextotol + 5 - 1}:K${indextotol + 5 - 1}')
      //     .merge();
      sheet3.getRangeByName('A${index + 7}').setText(
            '${index + 1}',
          );
      sheet3.getRangeByName('B${index + 7}').setText(
            '${teNantModels_Renew[index].cid}',
          );
      sheet3.getRangeByName('C${index + 7}').setText(
            '${teNantModels_Renew[index].fid}',
          );
      // sheet.getRangeByName('D${index + 7}').setText(
      //       '${teNantModels[index].sname}',
      //     );
      sheet3.getRangeByName('D${index + 7}').setText(
            '${teNantModels_Renew[index].cname}',
          );
      sheet3.getRangeByName('E${index + 7}').setText(
            (teNantModels_Renew[index].zn!.split('_')[0].length <= 4)
                ? 'CMN0${teNantModels_Renew[index].zn!.split('_')[0]}'
                : 'CMN${teNantModels_Renew[index].zn!.split('_')[0]}',
          );

      sheet3.getRangeByName('F${index + 7}').setText(
            '${teNantModels_Renew[index].zn}',
          );
      sheet3.getRangeByName('G${index + 7}').setText(
            '${teNantModels_Renew[index].ln}',
          );
      sheet3.getRangeByName('H${index + 7}').setText(
            '${teNantModels_Renew[index].stype}',
          );
      sheet3.getRangeByName('I${index + 7}').setText(
            '${teNantModels_Renew[index].rtname}',
          );
      try {
        sheet3.getRangeByName('J${index + 7}').cellStyle.numberFormat =
            'dd-MM-yyyy';
        sheet3.getRangeByName('J${index + 7}').setValue(
              (teNantModels_Renew[index].sdate == null)
                  ? null
                  : DateTime.parse(
                      '${teNantModels_Renew[index].sdate} 00:00:00'),
            );
      } catch (e) {
        sheet3.getRangeByName('J${index + 7}').setText(
              (teNantModels_Renew[index].sdate == null)
                  ? '${teNantModels_Renew[index].sdate}'
                  : '${DateFormat('dd-MM').format(DateTime.parse('${teNantModels_Renew[index].sdate} 00:00:00'))}-${DateTime.parse('${teNantModels_Renew[index].sdate} 00:00:00').year + 0}',
            );
      }
      try {
        sheet3.getRangeByName('K${index + 7}').cellStyle.numberFormat =
            'dd-MM-yyyy';
        sheet3.getRangeByName('K${index + 7}').setValue(
              (teNantModels_Renew[index].ldate == null)
                  ? null
                  : DateTime.parse(
                      '${teNantModels_Renew[index].ldate} 00:00:00'),
            );
      } catch (e) {
        sheet3.getRangeByName('K${index + 7}').setText(
              (teNantModels_Renew[index].ldate == null)
                  ? '${teNantModels_Renew[index].ldate}'
                  : '${DateFormat('dd-MM').format(DateTime.parse('${teNantModels_Renew[index].ldate} 00:00:00'))}-${DateTime.parse('${teNantModels_Renew[index].ldate} 00:00:00').year + 0}',
            );
      }

      sheet3.getRangeByName('L${index + 7}').setText(
            (teNantModels_Renew[index].rtname.toString() == 'รายวัน')
                ? '${teNantModels_Renew[index].period}  วัน'
                : (teNantModels_Renew[index].rtname.toString() == 'รายสัปดาห์')
                    ? '${teNantModels_Renew[index].period}  สัปดาห์'
                    : (teNantModels_Renew[index].rtname.toString() ==
                            'รายเดือน')
                        ? '${teNantModels_Renew[index].period}  เดือน'
                        : '${teNantModels_Renew[index].period}  ${teNantModels_Renew[index].rtname}',
          );
      //////////----------------------->
      String textdata = '${teNantModels_Renew[index].exp_array}';
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

      for (int index2 = 0; index2 < Type_exp.length; index2++) {
        double pvat = (dataList.isEmpty)
            ? 0.00
            : dataList
                .whereType<Map<String, dynamic>>()
                .where((element) =>
                    element['ser_exp'].toString() ==
                    '${Type_exp[index2]["ser"]}')
                .map((element) => double.parse(element['pvat_exp'].toString()))
                .fold(0, (prev, wht) => prev + wht);

        double vat = (dataList.isEmpty)
            ? 0.00
            : dataList
                .whereType<Map<String, dynamic>>()
                .where((element) =>
                    element['ser_exp'].toString() ==
                    '${Type_exp[index2]["ser"]}')
                .map((element) => double.parse(element['vat_exp'].toString()))
                .fold(0, (prev, wht) => prev + wht);
        double total = (dataList.isEmpty)
            ? 0.00
            : dataList
                .whereType<Map<String, dynamic>>()
                .where((element) =>
                    element['ser_exp'].toString() ==
                    '${Type_exp[index2]["ser"]}')
                .map((element) => double.parse(element['total_exp'].toString()))
                .fold(0, (prev, wht) => prev + wht);

        if (index2 == 0) sheet3.getRangeByName('M${index + 7}').setNumber(pvat);

        if (index2 == 0) sheet3.getRangeByName('N${index + 7}').setNumber(vat);

        if (index2 == 0)
          sheet3.getRangeByName('O${index + 7}').setNumber(total);

        if (index2 == 1) sheet3.getRangeByName('P${index + 7}').setNumber(pvat);

        if (index2 == 1) sheet3.getRangeByName('Q${index + 7}').setNumber(vat);

        if (index2 == 1)
          sheet3.getRangeByName('R${index + 7}').setNumber(total);

        if (index2 == 2)
          sheet3.getRangeByName('S${index + 7}')..setNumber(pvat);

        if (index2 == 2) sheet3.getRangeByName('T${index + 7}').setNumber(vat);

        if (index2 == 2)
          sheet3.getRangeByName('U${index + 7}').setNumber(total);
      }

      sheet3.getRangeByName('V${index + 7}').setNumber(
          (teNantModels_Renew[index].pvat_deposit == null)
              ? 0.00
              : double.parse('${teNantModels_Renew[index].pvat_deposit}'));

      sheet3.getRangeByName('W${index + 7}').setNumber(
          (teNantModels_Renew[index].vat_deposit == null)
              ? 0.00
              : double.parse('${teNantModels_Renew[index].vat_deposit}'));

      sheet3.getRangeByName('X${index + 7}').setNumber(
          (teNantModels_Renew[index].deposit == null)
              ? 0.00
              : double.parse('${teNantModels_Renew[index].deposit}'));

      // sheet3.getRangeByName('Y${index + 7}').setText('');
      try {
        sheet3.getRangeByName('Y${index + 7}').cellStyle.numberFormat =
            'dd-MM-yyyy';
        sheet3.getRangeByName('Y${index + 7}').setValue(
              (teNantModels_Renew[index].datex == null ||
                      teNantModels_Renew[index].datex.toString() == '')
                  ? null
                  : DateTime.parse('${teNantModels_Renew[index].datex}'),
            );
      } catch (e) {
        sheet3.getRangeByName('DY${index + 7}').setText(
              (teNantModels_Renew[index].datex == null ||
                      teNantModels_Renew[index].datex.toString() == '')
                  ? ''
                  : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${teNantModels_Renew[index].datex}'))}',
            );
      }
      sheet3
          .getRangeByName('Z${index + 7}')
          .setText('${teNantModels_Renew[index].st}');
      sheet3
          .getRangeByName('AA${index + 7}')
          .setText('${teNantModels_Renew[index].name_user}');
      sheet3
          .getRangeByName('AB${index + 7}')
          .setText('${teNantModels_Renew[index].wnote}');
    }
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    Uint8List data = Uint8List.fromList(bytes);
    MimeType type = MimeType.MICROSOFTEXCEL;
    String path = await FileSaver.instance.saveFile(
        (Mon_Pe_Mon.toString() == 'null' || Mon_Pe_Mon == null)
            ? "$nameTital"
            : "$nameTital (เดือน${Mon_Pe_Mon}(${YE_Pe_Mon})",
        data,
        "xlsx",
        mimeType: type);
    log(path);
    // if (_verticalGroupValue_NameFile.toString() == 'จากระบบ') {
    //   String path = await FileSaver.instance.saveFile(
    //       "รายงานทะเบียนลูกค้า(ณ วันที่${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day})",
    //       data,
    //       "xlsx",
    //       mimeType: type);
    //   log(path);
    // } else {
    //   String path = await FileSaver.instance
    //       .saveFile("$NameFile_", data, "xlsx", mimeType: type);
    //   log(path);
    // }
  }
}
