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

//////////รายงานภาษีขาย
class Excgen_SalesTax_FutureReport_Choice {
  static void exportExcel_SalesTax_FutureReport_Choice(
      context,
      NameFile_,
      _verticalGroupValue_NameFile,
      renTal_name,
      Value_Chang_Zone_billpayMon,
      billpay_Mon,
      Mon_billpay_Mon,
      YE_billpay_Mon,
      expModels,
      Type_vat) async {
    var nFormat = NumberFormat("#,##0.00", "en_US");
    var nFormat2 = NumberFormat("###0.00", "en_US");
    DateTime datex = DateTime.now();
    String day_ =
        '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}';

    String Tim_ =
        '${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}';
    final x.Workbook workbook = x.Workbook();
///////----------------------------->
    List<String> columns = [];

///////-----------------------------> Add column names from A to Z
    for (int i = 0; i < 26; i++) {
      columns.add(String.fromCharCode(65 + i)); // A-Z
    }

///////-----------------------------> Add column names from A to Z followed by A to Z (AA to AZ)
    for (int i = 0; i < 26; i++) {
      for (int j = 0; j < 26; j++) {
        columns.add(String.fromCharCode(65 + i) +
            String.fromCharCode(65 + j)); // A-Z followed by A-Z (AA-AZ)
      }
    }
////////------------------------------>
    final x.Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'รายงานค่าเช่าพื้นที่ดิน-ค่าเช่า-บริการรับล่วงหน้า';
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

    x.Style globalStyle01 = workbook.styles.add('globalStyle01');
    globalStyle01.backColorRgb = Color(0xFFD4E6A3);
    globalStyle01.fontName = 'Angsana New';
    globalStyle01.numberFormat = '_(\* #,##0.00_)';
    globalStyle01.hAlign = x.HAlignType.center;
    globalStyle01.fontSize = 16;
    globalStyle01.bold = true;
    globalStyle01.borders;
    globalStyle01.fontColorRgb = Color.fromARGB(255, 127, 14, 192);

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

    sheet.getRangeByName('A1:K1').merge();
    sheet.getRangeByName('A2:K2').merge();
    sheet.getRangeByName('A3:K3').merge();
    sheet.getRangeByName('A4:K4').merge();

    sheet.getRangeByName('A1').setText(
          (Value_Chang_Zone_billpayMon == null)
              ? 'รายงานค่าเช่าพื้นที่ดิน-ค่าเช่า-บริการ(รับล่วงหน้าประจำเดือน/ชำระแล้ว)  (กรุณาเลือกโซน)'
              : 'รายงานค่าเช่าพื้นที่ดิน-ค่าเช่า-บริการ(รับล่วงหน้าประจำเดือน/ชำระแล้ว)  (โซน : $Value_Chang_Zone_billpayMon)',
        );
    sheet.getRangeByName('A2').setText('${Mon_billpay_Mon}');
    sheet.getRangeByName('A3').setText(
        'ชื่อสถานประกอบการ บริษัท ชอยส์มินิสโตร์ จำกัด เลขประจำตัวผู้เสียภาษี 0-1055-31085-43-4');
    sheet.getRangeByName('A4').setText('ชื่อสถานประกอบการ เซเว่นอีเลฟเว่น');

// ExcelSheetProtectionOption
    final x.ExcelSheetProtectionOption options = x.ExcelSheetProtectionOption();
    options.all = true;
    /////////---------->
    int columns_now =
        int.parse('${expModels.length}') * int.parse('${Type_vat.length}');
    /////////---------->
// Protecting the Worksheet by using a Password
    for (int index = 0; index < 6; index++) {
      ////
      sheet.getRangeByName('A${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('B${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('C${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('D${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('E${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('F${index + 1}').cellStyle = globalStyle220; //5
      sheet.getRangeByName('G${index + 1}').cellStyle = globalStyle220; //6
      sheet.getRangeByName('H${index + 1}').cellStyle = globalStyle220; //6
      sheet.getRangeByName('I${index + 1}').cellStyle = globalStyle220; //6
      /////////------------->
      int xx_count_1 = 0;
      for (int i = 0; i < expModels.length; i++) {
        for (int x = 0; x < Type_vat.length; x++) {
          xx_count_1 = xx_count_1 + 1;
          sheet
              .getRangeByName('${columns[8 + xx_count_1]}${index + 1}')
              .cellStyle = globalStyle220;
        }
      }

      sheet
          .getRangeByName('${columns[9 + columns_now]}${index + 1}')
          .cellStyle = globalStyle220;
      sheet
          .getRangeByName('${columns[10 + columns_now]}${index + 1}')
          .cellStyle = globalStyle220;
      sheet
          .getRangeByName('${columns[11 + columns_now]}${index + 1}')
          .cellStyle = globalStyle220;
      sheet
          .getRangeByName('${columns[12 + columns_now]}${index + 1}')
          .cellStyle = globalStyle220;
      sheet
          .getRangeByName('${columns[13 + columns_now]}${index + 1}')
          .cellStyle = globalStyle220;
      sheet
          .getRangeByName('${columns[14 + columns_now]}${index + 1}')
          .cellStyle = globalStyle220;
      sheet
          .getRangeByName('${columns[15 + columns_now]}${index + 1}')
          .cellStyle = globalStyle220;
      sheet
          .getRangeByName('${columns[16 + columns_now]}${index + 1}')
          .cellStyle = globalStyle220;
      sheet
          .getRangeByName('${columns[17 + columns_now]}${index + 1}')
          .cellStyle = globalStyle220;
      sheet
          .getRangeByName('${columns[18 + columns_now]}${index + 1}')
          .cellStyle = globalStyle220;
      sheet
          .getRangeByName('${columns[19 + columns_now]}${index + 1}')
          .cellStyle = globalStyle220;
      sheet
          .getRangeByName('${columns[20 + columns_now]}${index + 1}')
          .cellStyle = globalStyle220;
      // sheet.getRangeByName('G${index + 1}').cellStyle = globalStyle220;
      // sheet.getRangeByName('H${index + 1}').cellStyle = globalStyle220;
      // sheet.getRangeByName('I${index + 1}').cellStyle = globalStyle220;
      // sheet.getRangeByName('J${index + 1}').cellStyle = globalStyle220;
      // sheet.getRangeByName('K${index + 1}').cellStyle = globalStyle220;

      // sheet.getRangeByName('L${index + 1}').cellStyle = globalStyle220;
      // sheet.getRangeByName('M${index + 1}').cellStyle = globalStyle220;
      // sheet.getRangeByName('N${index + 1}').cellStyle = globalStyle220;

      // sheet.getRangeByName('O${index + 1}').cellStyle = globalStyle220;
      // sheet.getRangeByName('P${index + 1}').cellStyle = globalStyle220;
      // sheet.getRangeByName('Q${index + 1}').cellStyle = globalStyle220;
      // sheet.getRangeByName('R${index + 1}').cellStyle = globalStyle220;
      ////
    }

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
    ////---------->
    int xx_count_2 = 0;
    for (int i = 0; i < expModels.length; i++) {
      for (int x = 0; x < Type_vat.length; x++) {
        xx_count_2 = xx_count_2 + 1;
        sheet.getRangeByName('${columns[8 + xx_count_2]}6').cellStyle =
            globalStyle1;
        // sheet.getRangeByName('${columns[6 + xx_count_2]}6').cellStyle =
        //     globalStyle01;
        sheet.getRangeByName('${columns[8 + xx_count_2]}6').columnWidth = 25;
      }
    }
    sheet.getRangeByName('${columns[9 + columns_now]}6').cellStyle =
        globalStyle1;
    sheet.getRangeByName('${columns[10 + columns_now]}6').cellStyle =
        globalStyle1;
    sheet.getRangeByName('${columns[11 + columns_now]}6').cellStyle =
        globalStyle1;
    sheet.getRangeByName('${columns[12 + columns_now]}6').cellStyle =
        globalStyle1;
    sheet.getRangeByName('${columns[13 + columns_now]}6').cellStyle =
        globalStyle1;
    sheet.getRangeByName('${columns[14 + columns_now]}6').cellStyle =
        globalStyle1;
    sheet.getRangeByName('${columns[15 + columns_now]}6').cellStyle =
        globalStyle1;
    sheet.getRangeByName('${columns[16 + columns_now]}6').cellStyle =
        globalStyle1;
    sheet.getRangeByName('${columns[17 + columns_now]}6').cellStyle =
        globalStyle1;
    sheet.getRangeByName('${columns[18 + columns_now]}6').cellStyle =
        globalStyle1;

    sheet.getRangeByName('${columns[19 + columns_now]}6').cellStyle =
        globalStyle1;
    sheet.getRangeByName('${columns[20 + columns_now]}6').cellStyle =
        globalStyle1;
    sheet.getRangeByName('${columns[7 + columns_now]}6').columnWidth = 25;
    sheet.getRangeByName('${columns[8 + columns_now]}6').columnWidth = 25;
    sheet.getRangeByName('${columns[9 + columns_now]}6').columnWidth = 25;
    sheet.getRangeByName('${columns[10 + columns_now]}6').columnWidth = 25;
    sheet.getRangeByName('${columns[11 + columns_now]}6').columnWidth = 25;
    sheet.getRangeByName('${columns[12 + columns_now]}6').columnWidth = 25;
    sheet.getRangeByName('${columns[13 + columns_now]}6').columnWidth = 25;
    sheet.getRangeByName('${columns[14 + columns_now]}6').columnWidth = 25;
    sheet.getRangeByName('${columns[15 + columns_now]}6').columnWidth = 25;
    sheet.getRangeByName('${columns[16 + columns_now]}6').columnWidth = 25;
    sheet.getRangeByName('${columns[17 + columns_now]}6').columnWidth = 25;
    sheet.getRangeByName('${columns[18 + columns_now]}6').columnWidth = 25;
    sheet.getRangeByName('${columns[19 + columns_now]}6').columnWidth = 25;
    sheet.getRangeByName('${columns[20 + columns_now]}6').columnWidth = 25;
    // sheet.getRangeByName('G6').cellStyle = globalStyle1;
    // sheet.getRangeByName('H6').cellStyle = globalStyle1;
    // sheet.getRangeByName('I6').cellStyle = globalStyle1;
    // sheet.getRangeByName('J6').cellStyle = globalStyle1;
    // sheet.getRangeByName('K6').cellStyle = globalStyle1;
    // sheet.getRangeByName('L6').cellStyle = globalStyle1;
    // sheet.getRangeByName('M6').cellStyle = globalStyle1;
    // sheet.getRangeByName('N6').cellStyle = globalStyle1;
    // sheet.getRangeByName('O6').cellStyle = globalStyle1;
    // sheet.getRangeByName('P6').cellStyle = globalStyle1;
    // sheet.getRangeByName('Q6').cellStyle = globalStyle1;
    // sheet.getRangeByName('R6').cellStyle = globalStyle1;

    sheet.getRangeByName('A6').columnWidth = 10;
    sheet.getRangeByName('B6').columnWidth = 25;
    sheet.getRangeByName('C6').columnWidth = 25;
    sheet.getRangeByName('D6').columnWidth = 25;
    sheet.getRangeByName('E6').columnWidth = 25;
    sheet.getRangeByName('F6').columnWidth = 25;
    sheet.getRangeByName('G6').columnWidth = 25;
    sheet.getRangeByName('H6').columnWidth = 25;
    sheet.getRangeByName('I6').columnWidth = 25;
    // sheet.getRangeByName('J6').columnWidth = 25;
    // sheet.getRangeByName('K6').columnWidth = 30;
    // sheet.getRangeByName('L6').columnWidth = 25;
    // sheet.getRangeByName('M6').columnWidth = 25;
    // sheet.getRangeByName('N6').columnWidth = 25;
    // sheet.getRangeByName('O6').columnWidth = 25;
    // sheet.getRangeByName('P6').columnWidth = 25;
    // sheet.getRangeByName('Q6').columnWidth = 25;
    // sheet.getRangeByName('R6').columnWidth = 25;

    sheet.getRangeByName('A6').setText('ลำดับที่');
    sheet.getRangeByName('B6').setText('วันที่ชำระ');
    sheet.getRangeByName('C6').setText('เลขใบกำกับภาษี');
    sheet.getRangeByName('D6').setText('รายชื่อลูกค้า');
    sheet.getRangeByName('E6').setText('รหัสสาขา');
    sheet.getRangeByName('F6').setText('ชื่อสาขา');
    sheet.getRangeByName('G6').setText('เลขประจำตัวผู้เสียภาษี');
    sheet.getRangeByName('H6').setText('ประเภทร้านค้า');
    sheet.getRangeByName('I6').setText('เบอร์ติดต่อ');
    /////////---------->
    int xx_count = 0;
    for (int i = 0; i < expModels.length; i++) {
      for (int x = 0; x < Type_vat.length; x++) {
        xx_count = xx_count + 1;
        sheet.getRangeByName('${columns[8 + xx_count]}6').setText(
              '${expModels[i].expname}(${Type_vat[x]["pn"].toString()})',
            );
      }
    }
    sheet
        .getRangeByName('${columns[9 + columns_now]}6')
        .setText('ส่วนลดทั้งใบเสร็จ');
    sheet
        .getRangeByName('${columns[10 + columns_now]}6')
        .setText('หักณที่จ่ายทั้งใบเสร็จ');
    sheet
        .getRangeByName('${columns[11 + columns_now]}6')
        .setText('จำนวนเงินรวม(+VAT/ไม่รวมส่วนลดใบเสร็จ)');
    sheet.getRangeByName('${columns[12 + columns_now]}6').setText('สถานะ');
    sheet.getRangeByName('${columns[13 + columns_now]}6').setText('อ้างอิง');

    sheet.getRangeByName('${columns[14 + columns_now]}6').setText('ref1');
    sheet.getRangeByName('${columns[15 + columns_now]}6').setText('ref2');
    sheet.getRangeByName('${columns[16 + columns_now]}6').setText('ref-chao');
    sheet.getRangeByName('${columns[17 + columns_now]}6').setText('อ้างถึง');
    sheet
        .getRangeByName('${columns[18 + columns_now]}6')
        .setText('ช่องทางชำระ');
    sheet
        .getRangeByName('${columns[19 + columns_now]}6')
        .setText('เลขที่สัญญา');
    sheet
        .getRangeByName('${columns[20 + columns_now]}6')
        .setText('วันที่เริ่มสัญญา');
    // sheet.getRangeByName('G6').setText('ค่าเช่าพื้นที่ดิน');
    // sheet
    //     .getRangeByName('H6')
    //     .setText('ภาษีมูลค่าเพิ่ม 7% (ค่าเช่าพื้นที่ดิน)');
    // sheet.getRangeByName('I6').setText('ค่าเช่า');
    // sheet.getRangeByName('J6').setText('ภาษีมูลค่าเพิ่ม 7% (ค่าเช่า)');
    // sheet.getRangeByName('K6').setText('ค่าบริการพื้นที่');
    // sheet.getRangeByName('L6').setText('ภาษีมูลค่าเพิ่ม 7% (ค่าบริการพื้นที่)');
    // sheet.getRangeByName('M6').setText(' จำนวนเงินรวม ');

    int index1 = 0;
    int indextotol = 0;
    List cid_number = [];
    for (int index = 0; index < billpay_Mon.length; index++) {
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

      int xx_count_Color = 0;
      for (int i = 0; i < expModels.length; i++) {
        for (int x = 0; x < Type_vat.length; x++) {
          xx_count_Color = xx_count_Color + 1;
          sheet
              .getRangeByName('${columns[8 + xx_count_Color]}${index + 7}')
              .cellStyle = numberColor;
        }
      }
      sheet
          .getRangeByName('${columns[9 + columns_now]}${index + 7}')
          .cellStyle = numberColor;
      sheet
          .getRangeByName('${columns[10 + columns_now]}${index + 7}')
          .cellStyle = numberColor;
      sheet
          .getRangeByName('${columns[11 + columns_now]}${index + 7}')
          .cellStyle = numberColor;
      sheet
          .getRangeByName('${columns[12 + columns_now]}${index + 7}')
          .cellStyle = numberColor;
      sheet
          .getRangeByName('${columns[13 + columns_now]}${index + 7}')
          .cellStyle = numberColor;
      sheet
          .getRangeByName('${columns[14 + columns_now]}${index + 7}')
          .cellStyle = numberColor;
      sheet
          .getRangeByName('${columns[15 + columns_now]}${index + 7}')
          .cellStyle = numberColor;
      sheet
          .getRangeByName('${columns[16 + columns_now]}${index + 7}')
          .cellStyle = numberColor;
      sheet
          .getRangeByName('${columns[17 + columns_now]}${index + 7}')
          .cellStyle = numberColor;
      sheet
          .getRangeByName('${columns[18 + columns_now]}${index + 7}')
          .cellStyle = numberColor;
      sheet
          .getRangeByName('${columns[19 + columns_now]}${index + 7}')
          .cellStyle = numberColor;
      sheet
          .getRangeByName('${columns[20 + columns_now]}${index + 7}')
          .cellStyle = numberColor;
      // sheet.getRangeByName('H${index + 7}').cellStyle = numberColor;
      // sheet.getRangeByName('I${index + 7}').cellStyle = numberColor;
      // sheet.getRangeByName('J${index + 7}').cellStyle = numberColor;
      // sheet.getRangeByName('K${index + 7}').cellStyle = numberColor;
      // sheet.getRangeByName('L${index + 7}').cellStyle = numberColor;
      // sheet.getRangeByName('M${index + 7}').cellStyle = numberColor;
      // sheet.getRangeByName('N${index + 7}').cellStyle = numberColor;
      // sheet.getRangeByName('O${index + 7}').cellStyle = numberColor;
      // sheet.getRangeByName('P${index + 7}').cellStyle = numberColor;
      // sheet.getRangeByName('Q${index + 7}').cellStyle = numberColor;
      // sheet.getRangeByName('R${index + 7}').cellStyle = numberColor;

      sheet.getRangeByName('A${index + 7}').setText('${index + 1}');
      try {
        sheet.getRangeByName('B${index + 7}').cellStyle.numberFormat =
            'dd-MM-yyyy';
        sheet.getRangeByName('B${index + 7}').setValue(
              (billpay_Mon[index].pdate == null ||
                      billpay_Mon[index].pdate.toString() == '')
                  ? null
                  : DateTime.parse('${billpay_Mon[index].pdate}'),
            );
      } catch (e) {
        sheet.getRangeByName('B${index + 7}').setText(
            (billpay_Mon[index].pdate == null)
                ? ''
                : '${DateFormat('dd-MM').format(DateTime.parse('${billpay_Mon[index].pdate} 00:00:00'))}-${DateTime.parse('${billpay_Mon[index].pdate} 00:00:00').year + 0}'
            // '${billpay_Mon[index].pdate}'
            );
      }

      sheet.getRangeByName('C${index + 7}').setText(
          (billpay_Mon[index].doctax == null ||
                  billpay_Mon[index].doctax.toString() == '')
              ? '${billpay_Mon[index].docno}'
              : '${billpay_Mon[index].doctax}');

      sheet.getRangeByName('D${index + 7}').setText(
            (billpay_Mon[index].cname != null)
                ? '${billpay_Mon[index].cname}'
                : '${billpay_Mon[index].remark}',
          );

      sheet.getRangeByName('E${index + 7}').setText(
            (billpay_Mon[index].zn != null)
                ? (billpay_Mon[index].zn!.split('_')[0].length <= 4)
                    ? 'CMN0${billpay_Mon[index].zn!.split('_')[0]}'
                    : 'CMN${billpay_Mon[index].zn!.split('_')[0]}'
                : (billpay_Mon[index].zn1!.split('_')[0].length < 4)
                    ? 'CMN0${billpay_Mon[index].zn1!.split('_')[0]}'
                    : 'CMN${billpay_Mon[index].zn1!.split('_')[0]}',
          );
      sheet.getRangeByName('F${index + 7}').setText(
          (billpay_Mon[index].zn != null)
              ? '${billpay_Mon[index].zn}'
              : '${billpay_Mon[index].znn}');

      sheet.getRangeByName('G${index + 7}').setText(
            (billpay_Mon[index].tax != null) ? '${billpay_Mon[index].tax}' : '',
          );
      sheet.getRangeByName('H${index + 7}').setText(
            (billpay_Mon[index].stype != null)
                ? '${billpay_Mon[index].stype}'
                : '',
          );
      sheet.getRangeByName('I${index + 7}').setText(
            (billpay_Mon[index].tel != null) ? '${billpay_Mon[index].tel}' : '',
          );
      //////////----------------------->
      String textdata = '${billpay_Mon[index].exp_array}';
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
      int count_01 = 8;
      for (int index2 = 0; index2 < expModels.length; index2++) {
        double pvat = (dataList.isEmpty)
            ? 0.00
            : dataList
                .whereType<Map<String, dynamic>>()
                .where((element) =>
                    element['ser_exp'].toString() == '${expModels[index2].ser}')
                .map((element) => double.parse(element['pvat_exp'].toString()))
                .fold(0, (prev, wht) => prev + wht);

        double vat = (dataList.isEmpty)
            ? 0.00
            : dataList
                .whereType<Map<String, dynamic>>()
                .where((element) =>
                    element['ser_exp'].toString() == '${expModels[index2].ser}')
                .map((element) => double.parse(element['vat_exp'].toString()))
                .fold(0, (prev, wht) => prev + wht);
        double wht = (dataList.isEmpty)
            ? 0.00
            : dataList
                .whereType<Map<String, dynamic>>()
                .where((element) =>
                    element['ser_exp'].toString() == '${expModels[index2].ser}')
                .map((element) => double.parse(element['wht_exp'].toString()))
                .fold(0, (prev, wht) => prev + wht);
        double total = (dataList.isEmpty)
            ? 0.00
            : dataList
                .whereType<Map<String, dynamic>>()
                .where((element) =>
                    element['ser_exp'].toString() == '${expModels[index2].ser}')
                .map((element) => double.parse(element['total_exp'].toString()))
                .fold(0, (prev, wht) => prev + wht);
        // {"ser": "1", "st": "1", "type": "pvat", "pn": "ก่อนVAT"},
        // {"ser": "2", "st": "0", "type": "vat", "pn": "VAT"},
        // {"ser": "3", "st": "0", "type": "total", "pn": "รวมVAT"},

        for (int x = 0; x < Type_vat.length; x++) {
          count_01 = count_01 + 1;
          sheet.getRangeByName('${columns[count_01]}${index + 7}').setNumber(
                (Type_vat[x]['type'].toString() == 'pvat')
                    ? pvat
                    : (Type_vat[x]['type'].toString() == 'vat')
                        ? vat
                        : (Type_vat[x]['type'].toString() == 'wht')
                            ? wht
                            : total,
              );
        }
      }
      sheet.getRangeByName('${columns[9 + columns_now]}${index + 7}').setNumber(
          (billpay_Mon[index].total_dis == null)
              ? 0.00
              : double.parse('${billpay_Mon[index].total_dis}'));
      sheet
          .getRangeByName('${columns[10 + columns_now]}${index + 7}')
          .setNumber((billpay_Mon[index].total_wht == null)
              ? 0.00
              : double.parse('${billpay_Mon[index].total_wht}'));

      double total_subbill = (dataList.isEmpty)
          ? 0.00
          : dataList
              .whereType<Map<String, dynamic>>()
              .map((element) => double.parse(element['total_exp'].toString()))
              .fold(0, (prev, wht) => prev + wht);
      sheet
          .getRangeByName('${columns[11 + columns_now]}${index + 7}')
          .setNumber(
            total_subbill,
          );
      // sheet.getRangeByName('${columns[7 + columns_now]}${index + 7}').setFormula(
      //     '=SUM(G${index + 7}:${columns[7 + columns_now - 1]}${index + 7})');
      sheet.getRangeByName('${columns[12 + columns_now]}${index + 7}').setText(
          (billpay_Mon[index].st == null) ? '' : '${billpay_Mon[index].st}');

      sheet.getRangeByName('${columns[13 + columns_now]}${index + 7}').setText(
          (billpay_Mon[index].wnote == null)
              ? ''
              : '${billpay_Mon[index].wnote}');
      sheet.getRangeByName('${columns[14 + columns_now]}${index + 7}').setText(
          (billpay_Mon[index].ref2 == null)
              ? ''
              : '${billpay_Mon[index].ref2}');
      sheet.getRangeByName('${columns[15 + columns_now]}${index + 7}').setText(
          (billpay_Mon[index].ref4 == null)
              ? ''
              : '${billpay_Mon[index].ref4}');
      sheet.getRangeByName('${columns[16 + columns_now]}${index + 7}').setText(
          (billpay_Mon[index].ref1 == null)
              ? ''
              : '${billpay_Mon[index].ref1}');
      sheet.getRangeByName('${columns[17 + columns_now]}${index + 7}').setText(
          (billpay_Mon[index].inv == null) ? '' : '${billpay_Mon[index].inv}');
      sheet.getRangeByName('${columns[18 + columns_now]}${index + 7}').setText(
          (billpay_Mon[index].type == null)
              ? ''
              : '${billpay_Mon[index].type}');
      sheet
          .getRangeByName('${columns[19 + columns_now]}${index + 7}')
          .setText('${billpay_Mon[index].cid}');

      try {
        sheet
            .getRangeByName('${columns[20 + columns_now]}${index + 7}')
            .cellStyle
            .numberFormat = 'dd-MM-yyyy';
        sheet
            .getRangeByName('${columns[20 + columns_now]}${index + 7}')
            .setValue(
              (billpay_Mon[index].sdate == null ||
                      billpay_Mon[index].sdate.toString() == '')
                  ? null
                  : DateTime.parse('${billpay_Mon[index].sdate}'),
            );
      } catch (e) {
        sheet
            .getRangeByName('${columns[20 + columns_now]}${index + 7}')
            .setText((billpay_Mon[index].sdate == null)
                ? ''
                : '${DateFormat('dd-MM').format(DateTime.parse('${billpay_Mon[index].sdate} 00:00:00'))}-${DateTime.parse('${billpay_Mon[index].sdate} 00:00:00').year + 0}');
      }

      //////////----------------------->
      // sheet.getRangeByName('G${index + 7}').setNumber(
      //     (billpay_Mon[index].rent_pvat == null)
      //         ? 0.00
      //         : double.parse('${billpay_Mon[index].rent_pvat}'));

      // sheet.getRangeByName('H${index + 7}').setNumber(
      //     (billpay_Mon[index].land_vat == null)
      //         ? 0.00
      //         : double.parse('${billpay_Mon[index].land_vat}'));
      // sheet.getRangeByName('I${index + 7}').setNumber(
      //     (billpay_Mon[index].land_pvat == null)
      //         ? 0.00
      //         : double.parse('${billpay_Mon[index].land_pvat}'));

      // sheet.getRangeByName('J${index + 7}').setNumber(
      //     (billpay_Mon[index].rent_vat == null)
      //         ? 0.00
      //         : double.parse('${billpay_Mon[index].rent_vat}'));

      // sheet.getRangeByName('K${index + 7}').setNumber(
      //     (billpay_Mon[index].service_pvat == null)
      //         ? 0.00
      //         : double.parse('${billpay_Mon[index].service_pvat}'));

      // sheet.getRangeByName('L${index + 7}').setNumber(
      //     (billpay_Mon[index].service_vat == null)
      //         ? 0.00
      //         : double.parse('${billpay_Mon[index].service_vat}'));

      // sheet
      //     .getRangeByName('M${index + 7}')
      //     .setFormula('=SUM(G${index + 7}:L${index + 7})');

      indextotol = indextotol + 1;
    }
/////////---------------------------->
    int count_SUM = 8;
    sheet.getRangeByName('I${indextotol + 7 + 0}').setText('รวมทั้งหมด: ');
    for (int index2 = 0; index2 < expModels.length; index2++) {
      for (int x = 0; x < Type_vat.length; x++) {
        count_SUM = count_SUM + 1;
        sheet
            .getRangeByName('${columns[count_SUM]}${indextotol + 7 + 0}')
            .setFormula(
                '=SUM(${columns[count_SUM]}7:${columns[count_SUM]}${indextotol + 7 - 1})');
        sheet
            .getRangeByName('${columns[count_SUM]}${indextotol + 7 + 0}')
            .cellStyle = globalStyle7;
      }
    }
    sheet
        .getRangeByName('${columns[9 + columns_now]}${indextotol + 7 + 0}')
        .setFormula(
            '=SUM(${columns[9 + columns_now]}7:${columns[9 + columns_now]}${indextotol + 7 - 1})');
    sheet
        .getRangeByName('${columns[10 + columns_now]}${indextotol + 7 + 0}')
        .setFormula(
            '=SUM(${columns[10 + columns_now]}7:${columns[10 + columns_now]}${indextotol + 7 - 1})');
    sheet
        .getRangeByName('${columns[11 + columns_now]}${indextotol + 7 + 0}')
        .setFormula(
            '=SUM(${columns[11 + columns_now]}7:${columns[11 + columns_now]}${indextotol + 7 - 1})');

    sheet
        .getRangeByName('${columns[9 + columns_now]}${indextotol + 7 + 0}')
        .cellStyle = globalStyle7;
    sheet
        .getRangeByName('${columns[10 + columns_now]}${indextotol + 7 + 0}')
        .cellStyle = globalStyle7;
    sheet
        .getRangeByName('${columns[11 + columns_now]}${indextotol + 7 + 0}')
        .cellStyle = globalStyle7;
    // sheet
    //     .getRangeByName('H${indextotol + 7 + 0}')
    //     .setFormula('=SUM(H7:H${indextotol + 7 - 1})');
    // sheet
    //     .getRangeByName('I${indextotol + 7 + 0}')
    //     .setFormula('=SUM(I7:I${indextotol + 7 - 1})');
    // sheet
    //     .getRangeByName('J${indextotol + 7 + 0}')
    //     .setFormula('=SUM(J7:J${indextotol + 7 - 1})');
    // sheet
    //     .getRangeByName('K${indextotol + 7 + 0}')
    //     .setFormula('=SUM(K7:K${indextotol + 7 - 1})');
    // sheet
    //     .getRangeByName('L${indextotol + 7 + 0}')
    //     .setFormula('=SUM(L7:L${indextotol + 7 - 1})');
    // sheet
    //     .getRangeByName('M${indextotol + 7 + 0}')
    //     .setFormula('=SUM(M7:M${indextotol + 7 - 1})');
    // sheet
    //     .getRangeByName('N${indextotol + 7 + 0}')
    //     .setFormula('=SUM(N7:N${indextotol + 7 - 1})');

    // sheet
    //     .getRangeByName('O${indextotol + 7 + 0}')
    //     .setFormula('=SUM(O7:O${indextotol + 7 - 1})');
    // sheet
    //     .getRangeByName('P${indextotol + 7 + 0}')
    //     .setFormula('=SUM(P7:P${indextotol + 7 - 1})');
    // sheet
    //     .getRangeByName('Q${indextotol + 7 + 0}')
    //     .setFormula('=SUM(Q7:Q${indextotol + 7 - 1})');

    sheet
        .getRangeByName('${columns[9 + columns_now]}${indextotol + 7 + 0}')
        .cellStyle = globalStyle7;
    sheet.getRangeByName('I${indextotol + 7 + 0}').cellStyle = globalStyle7;
    // sheet.getRangeByName('H${indextotol + 7 + 0}').cellStyle = globalStyle7;
    // sheet.getRangeByName('I${indextotol + 7 + 0}').cellStyle = globalStyle7;
    // sheet.getRangeByName('J${indextotol + 7 + 0}').cellStyle = globalStyle7;
    // sheet.getRangeByName('K${indextotol + 7 + 0}').cellStyle = globalStyle7;
    // sheet.getRangeByName('L${indextotol + 7 + 0}').cellStyle = globalStyle7;
    // sheet.getRangeByName('M${indextotol + 7 + 0}').cellStyle = globalStyle7;
    // sheet.getRangeByName('N${indextotol + 7 + 0}').cellStyle = globalStyle7;
    // sheet.getRangeByName('O${indextotol + 7 + 0}').cellStyle = globalStyle7;
    // sheet.getRangeByName('P${indextotol + 7 + 0}').cellStyle = globalStyle7;
    // sheet.getRangeByName('Q${indextotol + 7 + 0}').cellStyle = globalStyle7;

/////////---------------------------->
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    Uint8List data = Uint8List.fromList(bytes);
    MimeType type = MimeType.MICROSOFTEXCEL;
    String path = await FileSaver.instance.saveFile(
        (Value_Chang_Zone_billpayMon == null)
            ? 'รายงานค่าเช่าพื้นที่ดิน-ค่าเช่า-บริการ(รับล่วงหน้าประจำเดือน/ชำระแล้ว)(กรุณาเลือกโซน)'
            : 'รายงานค่าเช่าพื้นที่ดิน-ค่าเช่า-บริการ(รับล่วงหน้าประจำเดือน/ชำระแล้ว)',
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
