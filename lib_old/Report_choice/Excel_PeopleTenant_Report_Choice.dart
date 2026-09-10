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

//////////รายงานประวัติผู้เช่า
class Excgen_PeopleTenantReport_Choice {
  static void exportExcel_PeopleTenantReport_Choice(
      context,
      NameFile_,
      _verticalGroupValue_NameFile,
      renTal_name,
      Value_Chang_Zone_People_TeNant,
      teNantModels,
      Mon_PeopleTeNant_Mon,
      YE_PeopleTeNant_Mon,
      expModels,
      Type_vat,
      Status_pe_History) async {
    var nFormat = NumberFormat("#,##0.00", "en_US");
    var nFormat2 = NumberFormat("###0.00", "en_US");
    DateTime datex = DateTime.now();
    String day_ =
        '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}'; //// GC_billPay_SalesTaxFullReport_ _Choice

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
    sheet.name = 'รายงานประวัติผู้เช่า';
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
    // x.Style globalStyle22x = workbook.styles.add('style22');
    // globalStyle22.backColorRgb = Color(0xC7F5F7FA);
    // globalStyle22.numberFormat = '_(\* #,##0.00_)';
    // globalStyle22.fontSize = 12;
    // globalStyle22.numberFormat;
    // globalStyle22.hAlign = x.HAlignType.left;

    // x.Style globalStyle222x = workbook.styles.add('style222');
    // globalStyle222.backColorRgb = Color(0xC7E1E2E6);
    // globalStyle222.numberFormat = '_(\* #,##0.00_)';
    // // globalStyle222.numberFormat;
    // globalStyle222.fontSize = 12;
    // globalStyle222.hAlign = x.HAlignType.left;
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
    // sheet.getRangeByName('A1:I1').merge();
    // // sheet.getRangeByName('A2:I2').merge();
    // // sheet.getRangeByName('A3:I3').merge();
    // // sheet.getRangeByName('A4:I4').merge();

    // sheet.getRangeByName('A1').setText(
    //       (Value_Chang_Zone_People_TeNant == null)
    //           ? 'รายงานประวัติผู้เช่า  (กรุณาเลือกโซน)'
    //           : 'รายงานประวัติผู้เช่า  (โซน : $Value_Chang_Zone_People_TeNant)',
    //     );

    sheet.getRangeByName('A1:K1').merge();
    sheet.getRangeByName('A2:K2').merge();
    sheet.getRangeByName('A3:K3').merge();
    sheet.getRangeByName('A4:K4').merge();

    sheet.getRangeByName('A1').setText(
          (Value_Chang_Zone_People_TeNant == null)
              ? 'รายงานประวัติผู้เช่า  (กรุณาเลือกโซน)'
              : 'รายงานประวัติผู้เช่า  (โซน : $Value_Chang_Zone_People_TeNant)',
        );
    sheet.getRangeByName('A2').setText(
        'ข้อมูลถึงเดือน ${Mon_PeopleTeNant_Mon} ${YE_PeopleTeNant_Mon}');
    sheet.getRangeByName('A3').setText(
        'ชื่อสถานประกอบการ บริษัท ชอยส์มินิสโตร์ จำกัด เลขประจำตัวผู้เสียภาษี 0-1055-31085-43-4');
    sheet.getRangeByName('A4').setText('ชื่อสถานประกอบการ เซเว่นอีเลฟเว่น');
    sheet.getRangeByName('A5').setText('สถานะ :${Status_pe_History}');
    sheet.getRangeByName('C5').setText('ทั้งหมด :${teNantModels.length}');
    sheet.getRangeByName('H5').setText('อัพเดต ณ :${DateTime.now()}');
// ExcelSheetProtectionOption
    final x.ExcelSheetProtectionOption options = x.ExcelSheetProtectionOption();
    options.all = true;
    /////////---------->
    int columns_now =
        int.parse('${expModels.length}') * int.parse('${Type_vat.length}');
    // (Type_vat.where((element) => element["st"].toString() == '1')
    //     .toList()
    //     .length);
    /////////---------->
// Protecting the Worksheet by using a Password
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
      sheet.getRangeByName('M${index + 1}').cellStyle = globalStyle220; //12
      /////////------------->
      int xx_count_1 = 0;
      for (int i = 0; i < expModels.length; i++) {
        for (int x = 0; x < Type_vat.length; x++) {
          xx_count_1 = xx_count_1 + 1;
          sheet
              .getRangeByName('${columns[12 + xx_count_1]}${index + 1}')
              .cellStyle = globalStyle220;
        }
      }

      // sheet.getRangeByName('N${index + 1}').cellStyle = globalStyle220;
      // sheet.getRangeByName('O${index + 1}').cellStyle = globalStyle220;
      // sheet.getRangeByName('P${index + 1}').cellStyle = globalStyle220;
      // sheet.getRangeByName('Q${index + 1}').cellStyle = globalStyle220;
      // sheet.getRangeByName('R${index + 1}').cellStyle = globalStyle220;
      // sheet.getRangeByName('S${index + 1}').cellStyle = globalStyle220;
      /////////------------->
      // sheet.getRangeByName('T${index + 1}').cellStyle = globalStyle220;
      // sheet.getRangeByName('U${index + 1}').cellStyle = globalStyle220;
      // sheet.getRangeByName('V${index + 1}').cellStyle = globalStyle220;
      for (int x = 0; x < Type_vat.length; x++) {
        if (Type_vat[x]["type"].toString() == 'pvat') {
          sheet
              .getRangeByName('${columns[(13 + x) + columns_now]}${index + 1}')
              .cellStyle = globalStyle220;
        } else if (Type_vat[x]["type"].toString() == 'vat') {
          sheet
              .getRangeByName('${columns[(13 + x) + columns_now]}${index + 1}')
              .cellStyle = globalStyle220;
        } else if (Type_vat[x]["type"].toString() == 'total') {
          sheet
              .getRangeByName('${columns[(13 + x) + columns_now]}${index + 1}')
              .cellStyle = globalStyle220;
        }
      }
      sheet
          .getRangeByName(
              '${columns[(13 + int.parse('${Type_vat.length}')) + columns_now]}${index + 1}')
          .cellStyle = globalStyle220;
      sheet
          .getRangeByName(
              '${columns[(14 + int.parse('${Type_vat.length}')) + columns_now]}${index + 1}')
          .cellStyle = globalStyle220;
      sheet
          .getRangeByName(
              '${columns[(15 + int.parse('${Type_vat.length}')) + columns_now]}${index + 1}')
          .cellStyle = globalStyle220;
      sheet
          .getRangeByName(
              '${columns[(16 + int.parse('${Type_vat.length}')) + columns_now]}${index + 1}')
          .cellStyle = globalStyle220;
      // sheet.getRangeByName('W${index + 1}').cellStyle = globalStyle220;
      // sheet.getRangeByName('X${index + 1}').cellStyle = globalStyle220;
      // sheet.getRangeByName('Y${index + 1}').cellStyle = globalStyle220;
      // sheet.getRangeByName('Z${index + 1}').cellStyle = globalStyle220;

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
    sheet.getRangeByName('J6').cellStyle = globalStyle1;
    sheet.getRangeByName('K6').cellStyle = globalStyle1;
    sheet.getRangeByName('L6').cellStyle = globalStyle1;
    sheet.getRangeByName('M6').cellStyle = globalStyle1; //13
    ////---------->
    int xx_count_2 = 0;
    for (int i = 0; i < expModels.length; i++) {
      for (int x = 0; x < Type_vat.length; x++) {
        xx_count_2 = xx_count_2 + 1;
        sheet.getRangeByName('${columns[12 + xx_count_2]}6').cellStyle =
            globalStyle01;
      }
    }

    for (int x = 0; x < Type_vat.length; x++) {
      if (Type_vat[x]["type"].toString() == 'pvat') {
        sheet.getRangeByName('${columns[(13 + x) + columns_now]}6').cellStyle =
            globalStyle1;
      } else if (Type_vat[x]["type"].toString() == 'vat') {
        sheet.getRangeByName('${columns[(13 + x) + columns_now]}6').cellStyle =
            globalStyle1;
      } else if (Type_vat[x]["type"].toString() == 'total') {
        sheet.getRangeByName('${columns[(13 + x) + columns_now]}6').cellStyle =
            globalStyle1;
      }
    }
    // sheet.getRangeByName('T6').cellStyle = globalStyle1;
    // sheet.getRangeByName('U6').cellStyle = globalStyle1;
    // sheet.getRangeByName('V6').cellStyle = globalStyle1;

    sheet
        .getRangeByName(
            '${columns[(13 + int.parse('${Type_vat.length}')) + columns_now]}6')
        .cellStyle = globalStyle1;
    sheet
        .getRangeByName(
            '${columns[(14 + int.parse('${Type_vat.length}')) + columns_now]}6')
        .cellStyle = globalStyle1;
    sheet
        .getRangeByName(
            '${columns[(15 + int.parse('${Type_vat.length}')) + columns_now]}6')
        .cellStyle = globalStyle1;
    sheet
        .getRangeByName(
            '${columns[(16 + int.parse('${Type_vat.length}')) + columns_now]}6')
        .cellStyle = globalStyle1;

    ////---------->
    sheet.getRangeByName('A6').columnWidth = 10;
    sheet.getRangeByName('B6').columnWidth = 20;
    sheet.getRangeByName('C6').columnWidth = 20;
    sheet.getRangeByName('D6').columnWidth = 25;
    sheet.getRangeByName('E6').columnWidth = 35;
    sheet.getRangeByName('F6').columnWidth = 25;
    sheet.getRangeByName('G6').columnWidth = 18;
    sheet.getRangeByName('H6').columnWidth = 30;
    sheet.getRangeByName('I6').columnWidth = 18;
    sheet.getRangeByName('J6').columnWidth = 18;
    sheet.getRangeByName('K6').columnWidth = 18;
    sheet.getRangeByName('L6').columnWidth = 18;
    sheet.getRangeByName('M6').columnWidth = 18; //12
    /////////---------->
    int xx_count_3 = 0;
    for (int i = 0; i < expModels.length; i++) {
      for (int x = 0; x < Type_vat.length; x++) {
        xx_count_3 = xx_count_3 + 1;
        sheet.getRangeByName('${columns[12 + xx_count_3]}6').columnWidth = 20;
      }
    }
    for (int x = 0; x < Type_vat.length; x++) {
      sheet.getRangeByName('${columns[(13 + x) + columns_now]}6').columnWidth =
          20;
    }
    // sheet.getRangeByName('N6').columnWidth = 18;
    // sheet.getRangeByName('O6').columnWidth = 18;
    // sheet.getRangeByName('P6').columnWidth = 18;
    // sheet.getRangeByName('Q6').columnWidth = 18;
    // sheet.getRangeByName('R6').columnWidth = 18;
    // sheet.getRangeByName('S6').columnWidth = 18;
    /////////---------->
    // sheet.getRangeByName('T6').columnWidth = 18;
    // sheet.getRangeByName('U6').columnWidth = 18;
    // sheet.getRangeByName('V6').columnWidth = 18;
    sheet
        .getRangeByName(
            '${columns[(13 + int.parse('${Type_vat.length}')) + columns_now]}6')
        .columnWidth = 18;
    sheet
        .getRangeByName(
            '${columns[(14 + int.parse('${Type_vat.length}')) + columns_now]}6')
        .columnWidth = 18;
    sheet
        .getRangeByName(
            '${columns[(15 + int.parse('${Type_vat.length}')) + columns_now]}6')
        .columnWidth = 18;
    sheet
        .getRangeByName(
            '${columns[(16 + int.parse('${Type_vat.length}')) + columns_now]}6')
        .columnWidth = 18;

    sheet.getRangeByName('A6').setText('ลำดับที่');
    sheet.getRangeByName('B6').setText('ชื่อ-สกุล ผู้เช่า');
    sheet.getRangeByName('C6').setText('เลขบปช.');
    sheet.getRangeByName('D6').setText('รหัสสาขา');
    sheet.getRangeByName('E6').setText('ชื่อสาขา');
    sheet.getRangeByName('F6').setText('เลขที่สัญญา');
    sheet.getRangeByName('G6').setText('เลขสัญญาเก่า');
    sheet.getRangeByName('H6').setText('เลขที่สัญญาประกัน');
    sheet.getRangeByName('I6').setText('เลขล็อค');
    sheet.getRangeByName('J6').setText('วันที่เริ่มเช่า');
    sheet.getRangeByName('K6').setText('วันที่สิ้นสุดสัญญา');
    sheet.getRangeByName('L6').setText('ประเภทสินค้า');
    sheet.getRangeByName('M6').setText('น้ำ + ไฟ'); //12
    /////////---------->
    int xx_count = 0;
    for (int i = 0; i < expModels.length; i++) {
      for (int x = 0; x < Type_vat.length; x++) {
        xx_count = xx_count + 1;
        sheet.getRangeByName('${columns[12 + xx_count]}6').setText(
              '${expModels[i].expname}(${Type_vat[x]["pn"].toString()})',
            );
      }
    }
    // sheet.getRangeByName('N6').setText('ค่าเช่า(ก่อนVAT)');
    // sheet.getRangeByName('O6').setText('ค่าเช่า(VAT)');
    // sheet.getRangeByName('P6').setText('ค่าเช่า(รวมVAT)');
    // sheet.getRangeByName('Q6').setText('ค่าบริการ(ก่อนVAT)');
    // sheet.getRangeByName('R6').setText('ค่าบริการ(VAT)');
    // sheet.getRangeByName('S6').setText('ค่าบริการ(รวมVAT)');

    // sheet
    //     .getRangeByName('${columns[13 + columns_now]}6')
    //     .setText('เงินประกัน(ก่อนVAT)');
    // sheet
    //     .getRangeByName('${columns[14 + columns_now]}6')
    //     .setText('เงินประกัน(VAT)');
    // sheet
    //     .getRangeByName('${columns[15 + columns_now]}6')
    //     .setText('เงินประกัน(รวมVAT)');
    for (int x = 0; x < Type_vat.length; x++) {
      if (Type_vat[x]["type"].toString() == 'pvat') {
        sheet
            .getRangeByName('${columns[(13 + x) + columns_now]}6')
            .setText('เงินประกัน(ก่อนVAT)');
      } else if (Type_vat[x]["type"].toString() == 'vat') {
        sheet
            .getRangeByName('${columns[(13 + x) + columns_now]}6')
            .setText('เงินประกัน(VAT)');
      } else if (Type_vat[x]["type"].toString() == 'total') {
        sheet
            .getRangeByName('${columns[(13 + x) + columns_now]}6')
            .setText('เงินประกัน(รวมVAT)');
      }
    }
    sheet
        .getRangeByName(
            '${columns[(13 + int.parse('${Type_vat.length}')) + columns_now]}6')
        .setText('วันที่ยกเลิก');
    sheet
        .getRangeByName(
            '${columns[(14 + int.parse('${Type_vat.length}')) + columns_now]}6')
        .setText('ผู้ดูแล');
    sheet
        .getRangeByName(
            '${columns[(15 + int.parse('${Type_vat.length}')) + columns_now]}6')
        .setText('เลขอ้างอิง');
    sheet
        .getRangeByName(
            '${columns[(16 + int.parse('${Type_vat.length}')) + columns_now]}6')
        .setText('สถานะ');

    int index1 = 0;
    int indextotol = 0;
    List cid_number = [];

    for (int index = 0; index < teNantModels.length; index++) {
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

      // sheet.getRangeByName('R${index + 7}').cellStyle.numberFormat =
      //     'dd-MM-yyyy';
      int xx_count_Color = 0;
      for (int i = 0; i < expModels.length; i++) {
        for (int x = 0; x < Type_vat.length; x++) {
          xx_count_Color = xx_count_Color + 1;
          sheet
              .getRangeByName('${columns[12 + xx_count_Color]}${index + 7}')
              .cellStyle = numberColor;
        }
      }
      for (int x = 0; x < Type_vat.length; x++) {
        sheet
            .getRangeByName('${columns[(13 + x) + columns_now]}${index + 7}')
            .cellStyle = numberColor;
      }
      sheet
          .getRangeByName(
              '${columns[(13 + int.parse('${Type_vat.length}')) + columns_now]}${index + 7}')
          .cellStyle = numberColor;
      sheet
          .getRangeByName(
              '${columns[(14 + int.parse('${Type_vat.length}')) + columns_now]}${index + 7}')
          .cellStyle = numberColor;
      sheet
          .getRangeByName(
              '${columns[(15 + int.parse('${Type_vat.length}')) + columns_now]}${index + 7}')
          .cellStyle = numberColor;
      sheet
          .getRangeByName(
              '${columns[(16 + int.parse('${Type_vat.length}')) + columns_now]}${index + 7}')
          .cellStyle
          .backColorRgb = ((index % 2) ==
              0)
          ? Color(0xC7F5F7FA)
          : Color(0xC7E1E2E6);

      sheet
          .getRangeByName(
              '${columns[(16 + int.parse('${Type_vat.length}')) + columns_now]}${index + 7}')
          .cellStyle
          .fontSize = 12;
      sheet.getRangeByName('${columns[(16 + int.parse('${Type_vat.length}')) + columns_now]}${index + 7}').cellStyle.fontColorRgb =
          (teNantModels[index].st == null)
              ? Color.fromARGB(255, 3, 3, 3)
              : (teNantModels[index].st.toString() == 'ยกเลิกสัญญา')
                  ? Color(0xFFC52611)
                  : datex.isAfter(DateTime.parse(
                                  '${teNantModels[index].ldate} 00:00:00.000')
                              .subtract(const Duration(days: 0))) ==
                          true
                      ? Color.fromARGB(255, 197, 119, 17)
                      : Color.fromARGB(255, 54, 131, 24);

      sheet.getRangeByName('A${index + 7}').setText('${index + 1}');
      sheet
          .getRangeByName('B${index + 7}')
          .setText('${teNantModels[index].cname}');
      sheet
          .getRangeByName('C${index + 7}')
          .setText('${teNantModels[index].tax}');
      sheet.getRangeByName('D${index + 7}').setText(
            (teNantModels[index].zn != null)
                ? (teNantModels[index].zn!.split('_')[0].length <= 4)
                    ? 'CMN0${teNantModels[index].zn!.split('_')[0]}'
                    : 'CMN${teNantModels[index].zn!.split('_')[0]}'
                : (teNantModels[index].zn1!.split('_')[0].length < 4)
                    ? 'CMN0${teNantModels[index].zn1!.split('_')[0]}'
                    : 'CMN${teNantModels[index].zn1!.split('_')[0]}',
            // (teNantModels[index].zser != null)
            //     ? '${teNantModels[index].zser}'
            //     : '${teNantModels[index].zser1}'
          );
      sheet.getRangeByName('E${index + 7}').setText(
          (teNantModels[index].zn != null)
              ? '${teNantModels[index].zn}'
              : '${teNantModels[index].zn1}');
      sheet.getRangeByName('F${index + 7}').setText(
          (teNantModels[index].cid == null)
              ? ''
              : '${teNantModels[index].cid}');
      sheet.getRangeByName('G${index + 7}').setText(
          (teNantModels[index].fid == null)
              ? ''
              : '${teNantModels[index].fid}');
      sheet.getRangeByName('H${index + 7}').setText(
          (teNantModels[index].docno == null)
              ? ''
              : '${teNantModels[index].docno}');
      sheet
          .getRangeByName('I${index + 7}')
          .setText('${teNantModels[index].ln}');

      try {
        sheet.getRangeByName('J${index + 7}').cellStyle.numberFormat =
            'dd-MM-yyyy';
        sheet.getRangeByName('J${index + 7}').setValue(
              (teNantModels[index].sdate == null ||
                      teNantModels[index].sdate.toString() == '')
                  ? null
                  : DateTime.parse('${teNantModels[index].sdate}'),
            );
      } catch (e) {
        sheet.getRangeByName('J${index + 7}').setText(
              (teNantModels[index].sdate == null)
                  ? '${teNantModels[index].sdate}'
                  : '${DateFormat('dd-MM').format(DateTime.parse('${teNantModels[index].sdate} 00:00:00'))}-${DateTime.parse('${teNantModels[index].sdate} 00:00:00').year + 0}',
            );
      }

      // sheet.getRangeByName('J${index + 7}').setText((teNantModels[index]
      //             .sdate ==
      //         null)
      //     ? ''
      //     : '${DateFormat('dd-MM').format(DateTime.parse('${teNantModels[index].sdate} 00:00:00'))}-${DateTime.parse('${teNantModels[index].sdate} 00:00:00').year + 0}');
      try {
        sheet.getRangeByName('K${index + 7}').cellStyle.numberFormat =
            'dd-MM-yyyy';
        sheet.getRangeByName('K${index + 7}').setValue(
              (teNantModels[index].ldate == null ||
                      teNantModels[index].ldate.toString() == '')
                  ? null
                  : DateTime.parse('${teNantModels[index].ldate}'),
            );
      } catch (e) {
        sheet.getRangeByName('K${index + 7}').setText(
            (teNantModels[index].ldate == null)
                ? ''
                : '${DateFormat('dd-MM').format(DateTime.parse('${teNantModels[index].ldate} 00:00:00'))}-${DateTime.parse('${teNantModels[index].ldate} 00:00:00').year + 0}'

            // '${teNantModels[index].ldate}'
            );
      }

      sheet
          .getRangeByName('L${index + 7}')
          .setText('${teNantModels[index].stype}');
      sheet.getRangeByName('M${index + 7}').setText(
          '${(teNantModels[index].water_electri == null) ? '' : teNantModels[index].water_electri.toString()}');
      //////////----------------------->
      String textdata = '${teNantModels[index].exp_array}';
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
      int count_01 = 12;
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
        double total = (dataList.isEmpty)
            ? 0.00
            : dataList
                .whereType<Map<String, dynamic>>()
                .where((element) =>
                    element['ser_exp'].toString() == '${expModels[index2].ser}')
                .map((element) => double.parse(element['total_exp'].toString()))
                .fold(0, (prev, wht) => prev + wht);

        for (int x = 0; x < Type_vat.length; x++) {
          count_01 = count_01 + 1;
          sheet.getRangeByName('${columns[count_01]}${index + 7}').setNumber(
                (x == 0)
                    ? pvat
                    : (x == 1)
                        ? vat
                        : total,
              );
        }
      }

      //////////----------------------->
      // sheet.getRangeByName('N${index + 7}').setNumber(
      //     (teNantModels[index].rent_pvat == null)
      //         ? 0.00
      //         : double.parse('${teNantModels[index].rent_pvat}'));
      // sheet.getRangeByName('O${index + 7}').setNumber(
      //     (teNantModels[index].rent_vat == null)
      //         ? 0.00
      //         : double.parse('${teNantModels[index].rent_vat}'));
      // sheet.getRangeByName('P${index + 7}').setNumber(
      //     (teNantModels[index].rent_total == null)
      //         ? 0.00
      //         : double.parse('${teNantModels[index].rent_total}'));

      // sheet.getRangeByName('Q${index + 7}').setNumber(
      //     (teNantModels[index].service_pvat == null)
      //         ? 0.00
      //         : double.parse('${teNantModels[index].service_pvat}'));
      // sheet.getRangeByName('R${index + 7}').setNumber(
      //     (teNantModels[index].service_vat == null)
      //         ? 0.00
      //         : double.parse('${teNantModels[index].service_vat}'));
      // sheet.getRangeByName('S${index + 7}').setNumber(
      //     (teNantModels[index].service_total == null)
      //         ? 0.00
      //         : double.parse('${teNantModels[index].service_total}'));
      //////////----------------------->
      for (int x = 0; x < Type_vat.length; x++) {
        if (Type_vat[x]["type"].toString() == 'pvat') {
          sheet
              .getRangeByName('${columns[(13 + x) + columns_now]}${index + 7}')
              .setNumber((teNantModels[index].pvat_pakan == null)
                  ? 0.00
                  : double.parse('${teNantModels[index].pvat_pakan}'));
        } else if (Type_vat[x]["type"].toString() == 'vat') {
          sheet
              .getRangeByName('${columns[(13 + x) + columns_now]}${index + 7}')
              .setNumber((teNantModels[index].pakan_vat == null)
                  ? 0.00
                  : double.parse('${teNantModels[index].pakan_vat}'));
        } else if (Type_vat[x]["type"].toString() == 'total') {
          sheet
              .getRangeByName('${columns[(13 + x) + columns_now]}${index + 7}')
              .setNumber((teNantModels[index].total_pakan == null)
                  ? 0.00
                  : double.parse('${teNantModels[index].total_pakan}'));
        }
      }
      //////////----------------------->
      sheet
          .getRangeByName(
              '${columns[(13 + int.parse('${Type_vat.length}')) + columns_now]}${index + 7}')
          .setText((teNantModels[index].cc_date.toString() == '0000-00-00')
              ? ''
              : (teNantModels[index].cc_date == null)
                  ? ''
                  : '${DateFormat('dd-MM').format(DateTime.parse('${teNantModels[index].cc_date} 00:00:00'))}-${DateTime.parse('${teNantModels[index].cc_date} 00:00:00').year + 0}');

      sheet
          .getRangeByName(
              '${columns[(14 + int.parse('${Type_vat.length}')) + columns_now]}${index + 7}')
          .setText('${teNantModels[index].name_user}');
      sheet
          .getRangeByName(
              '${columns[(15 + int.parse('${Type_vat.length}')) + columns_now]}${index + 7}')
          .setText((teNantModels[index].wnote == null)
              ? ''
              : '${teNantModels[index].wnote}');

      sheet
          .getRangeByName(
              '${columns[(16 + int.parse('${Type_vat.length}')) + columns_now]}${index + 7}')
          .setText((teNantModels[index].st == null)
              ? ''
              : (teNantModels[index].st.toString() == 'ยกเลิกสัญญา')
                  ? 'ยกเลิกสัญญา'
                  : datex.isAfter(DateTime.parse(
                                  '${teNantModels[index].ldate} 00:00:00.000')
                              .subtract(const Duration(days: 0))) ==
                          true
                      ? 'หมดสัญญา'
                      : '${teNantModels[index].st}');

      indextotol = indextotol + 1;
    }
/////////---------------------------->
    // sheet.getRangeByName('M${indextotol + 3 + 0}').setText('รวมทั้งหมด: ');
    // sheet
    //     .getRangeByName('N${indextotol + 3 + 0}')
    //     .setFormula('=SUM(N3:N${indextotol + 3 - 1})');
    // sheet
    //     .getRangeByName('O${indextotol + 3 + 0}')
    //     .setFormula('=SUM(O3:O${indextotol + 3 - 1})');

    // sheet.getRangeByName('M${indextotol + 3 + 0}').cellStyle = globalStyle7;
    // sheet.getRangeByName('N${indextotol + 3 + 0}').cellStyle = globalStyle7;
    // sheet.getRangeByName('O${indextotol + 3 + 0}').cellStyle = globalStyle7;

/////////---------------------------->
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    Uint8List data = Uint8List.fromList(bytes);
    MimeType type = MimeType.MICROSOFTEXCEL;
    String path = await FileSaver.instance.saveFile(
        (Value_Chang_Zone_People_TeNant == null)
            ? 'รายงานประวัติผู้เช่า  (กรุณาเลือกโซน)'
            : 'รายงานประวัติผู้เช่า  (โซน : $Value_Chang_Zone_People_TeNant)',
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
