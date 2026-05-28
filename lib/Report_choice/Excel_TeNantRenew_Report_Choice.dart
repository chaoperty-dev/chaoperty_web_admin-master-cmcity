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
class Excgen_TeNantRenewReport_Choice {
  static void exportExcel_TeNantRenewReport_Choice(
      context,
      NameFile_,
      _verticalGroupValue_NameFile,
      renTal_name,
      Value_Chang_Zone_People_Renew,
      teNantModels_Renew,
      Mon_PeopleRenew_Mon,
      YE_PeopleRenew_Mon,
      Type_vat) async {
    var nFormat = NumberFormat("#,##0.00", "en_US");
    var nFormat2 = NumberFormat("###0.00", "en_US");
    DateTime datex = DateTime.now();
    String day_ =
        '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}'; //// GC_billPay_SalesTaxFullReport_ _Choice

    String Tim_ =
        '${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}';
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
    final x.Workbook workbook = x.Workbook();

    final x.Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'รายงานผู้เช่าต่อสัญญา';
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

    sheet.getRangeByName('A1:G1').merge();
    sheet.getRangeByName('A2:G2').merge();
    sheet.getRangeByName('A3:G3').merge();
    sheet.getRangeByName('A4:G4').merge();

    sheet.getRangeByName('A1').setText(
          (Value_Chang_Zone_People_Renew == null)
              ? 'รายงานผู้เช่าต่อสัญญา (กรุณาเลือกโซน)'
              : 'รายงานผู้เช่าต่อสัญญา (โซน : $Value_Chang_Zone_People_Renew)',
        );
    sheet
        .getRangeByName('A2')
        .setText('ประจำเดือน ${Mon_PeopleRenew_Mon} ${YE_PeopleRenew_Mon}');
    sheet.getRangeByName('A3').setText(
        'ชื่อสถานประกอบการ บริษัท ชอยส์มินิสโตร์ จำกัด เลขประจำตัวผู้เสียภาษี 0-1055-31085-43-4');
    sheet.getRangeByName('A4').setText('ชื่อสถานประกอบการ เซเว่นอีเลฟเว่น');
    sheet.getRangeByName('A5').setText('ทั้งหมด :${teNantModels_Renew.length}');
    sheet.getRangeByName('I5').setText('อัพเดต ณ :${DateTime.now()}');
// ExcelSheetProtectionOption
    final x.ExcelSheetProtectionOption options = x.ExcelSheetProtectionOption();
    options.all = true;

    List<dynamic> Type_exp = [
      {"ser": "1", "st": "1", "pn": "ค่าเช่าพื้นที่"},

      ///------------------>
      {"ser": "16", "st": "1", "pn": "ค่าบริการ"},

      ///------------------>
      {"ser": "35", "st": "1", "pn": "ค่าเช่าพื้นที่ดิน"},
    ];
    int columns_now =
        int.parse('${Type_exp.length}') * int.parse('${Type_vat.length}');

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
      sheet.getRangeByName('M${index + 1}').cellStyle = globalStyle220;
      /////////------------->
      int xx_count_1 = 0;
      for (int i = 0; i < Type_exp.length; i++) {
        for (int x = 0; x < Type_vat.length; x++) {
          xx_count_1 = xx_count_1 + 1;
          sheet
              .getRangeByName('${columns[12 + xx_count_1]}${index + 1}')
              .cellStyle = globalStyle220;
        }
      }

      sheet
          .getRangeByName('${columns[(13) + columns_now]}${index + 1}')
          .cellStyle = globalStyle220;
      sheet
          .getRangeByName('${columns[(14) + columns_now]}${index + 1}')
          .cellStyle = globalStyle220;
      sheet
          .getRangeByName('${columns[(15) + columns_now]}${index + 1}')
          .cellStyle = globalStyle220;
      sheet
          .getRangeByName('${columns[(16) + columns_now]}${index + 1}')
          .cellStyle = globalStyle220;
      sheet
          .getRangeByName('${columns[(17) + columns_now]}${index + 1}')
          .cellStyle = globalStyle220;
      sheet
          .getRangeByName('${columns[(18) + columns_now]}${index + 1}')
          .cellStyle = globalStyle220;
      sheet
          .getRangeByName('${columns[(19) + columns_now]}${index + 1}')
          .cellStyle = globalStyle220;
      sheet
          .getRangeByName('${columns[(20) + columns_now]}${index + 1}')
          .cellStyle = globalStyle220;
      sheet
          .getRangeByName('${columns[(21) + columns_now]}${index + 1}')
          .cellStyle = globalStyle220;

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
    sheet.getRangeByName('M6').cellStyle = globalStyle1;
    int xx_count_2 = 0;
    for (int i = 0; i < Type_exp.length; i++) {
      for (int x = 0; x < Type_vat.length; x++) {
        xx_count_2 = xx_count_2 + 1;
        sheet.getRangeByName('${columns[12 + xx_count_2]}6').cellStyle =
            globalStyle1;
        sheet.getRangeByName('${columns[12 + xx_count_2]}6').columnWidth = 25;
        sheet.getRangeByName('${columns[12 + xx_count_2]}6').setText(
              '${Type_exp[i]["pn"]}(${Type_vat[x]["pn"].toString()})',
            );
      }
    }
    for (int ix = 0; ix < 9; ix++) {
      sheet.getRangeByName('${columns[(13 + ix) + columns_now]}6').cellStyle =
          globalStyle1;
      sheet.getRangeByName('${columns[(13 + ix) + columns_now]}6').columnWidth =
          25;
    }
    sheet.getRangeByName('A6').columnWidth = 10;
    sheet.getRangeByName('B6').columnWidth = 20;
    sheet.getRangeByName('C6').columnWidth = 20;
    sheet.getRangeByName('D6').columnWidth = 25;
    sheet.getRangeByName('E6').columnWidth = 25;
    sheet.getRangeByName('F6').columnWidth = 25;
    sheet.getRangeByName('G6').columnWidth = 25;
    sheet.getRangeByName('H6').columnWidth = 30;
    sheet.getRangeByName('I6').columnWidth = 25;
    sheet.getRangeByName('J6').columnWidth = 25;
    sheet.getRangeByName('K6').columnWidth = 25;
    sheet.getRangeByName('L6').columnWidth = 25;
    sheet.getRangeByName('M6').columnWidth = 25;

    sheet.getRangeByName('A6').setText('ลำดับที่');
    sheet.getRangeByName('B6').setText('เลขที่สัญญา');
    sheet.getRangeByName('C6').setText('เลขที่สัญญาเดิม');
    sheet.getRangeByName('D6').setText('วันที่ทำรายการ');
    sheet.getRangeByName('E6').setText('รหัสสาขา');
    sheet.getRangeByName('F6').setText('ชื่อสาขา');
    sheet.getRangeByName('G6').setText('เลขล็อค');
    sheet.getRangeByName('H6').setText('ชื่อ-สกุล ผู้เช่า');
    sheet.getRangeByName('I6').setText('วันที่เริ่มเช่า');
    sheet.getRangeByName('J6').setText('วันที่สิ้นสุดสัญญา');
    sheet.getRangeByName('K6').setText('ระยะเวลา');
    sheet.getRangeByName('L6').setText('ประเภทสินค้า');
    sheet.getRangeByName('M6').setText('น้ำ + ไฟ');

    sheet
        .getRangeByName('${columns[(13) + columns_now]}6')
        .setText('เงินประกัน+VAT7%');

    sheet
        .getRangeByName('${columns[(14) + columns_now]}6')
        .setText('วันที่ใบเสร็จเงินประกัน');
    sheet
        .getRangeByName('${columns[(15) + columns_now]}6')
        .setText('เลขที่ใบเสร็จเงินประกัน');
    sheet.getRangeByName('${columns[(16) + columns_now]}6').setText('ผู้ดูแล');
    sheet.getRangeByName('${columns[(17) + columns_now]}6').setText('สถานะ');
    sheet.getRangeByName('${columns[(18) + columns_now]}6').setText('อ้างอิง');
    sheet
        .getRangeByName('${columns[(19) + columns_now]}6')
        .setText('เงินประกันรับเพิ่มต่อสัญญา(+VAT7%)');
    sheet
        .getRangeByName('${columns[(20) + columns_now]}6')
        .setText('วันที่ใบเสร็จเงินประกันรับเพิ่มต่อสัญญา');
    sheet
        .getRangeByName('${columns[(21) + columns_now]}6')
        .setText('เลขที่ใบเสร็จเงินประกันรับเพิ่มต่อสัญญา');

    int index1 = 0;
    int indextotol = 0;
    List cid_number = [];

    for (int index = 0; index < teNantModels_Renew.length; index++) {
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
      int xx_count_Color = 0;
      for (int i = 0; i < Type_exp.length; i++) {
        for (int x = 0; x < Type_vat.length; x++) {
          xx_count_Color = xx_count_Color + 1;
          sheet
              .getRangeByName('${columns[12 + xx_count_Color]}${index + 7}')
              .cellStyle = numberColor;
        }
      }
      for (int ix = 0; ix < 9; ix++) {
        sheet
            .getRangeByName('${columns[(13 + ix) + columns_now]}${index + 7}')
            .cellStyle = numberColor;
      }

      sheet.getRangeByName('A${index + 7}').setText('${index + 1}');
      sheet
          .getRangeByName('B${index + 7}')
          .setText('${teNantModels_Renew[index].cid}');
      sheet
          .getRangeByName('C${index + 7}')
          .setText('${teNantModels_Renew[index].fid}');
      try {
        sheet.getRangeByName('D${index + 7}').cellStyle.numberFormat =
            'dd-MM-yyyy';
        sheet.getRangeByName('D${index + 7}').setValue(
              (teNantModels_Renew[index].datex == null ||
                      teNantModels_Renew[index].datex.toString() == '')
                  ? null
                  : DateTime.parse('${teNantModels_Renew[index].datex}'),
            );
      } catch (e) {
        sheet.getRangeByName('D${index + 7}').setText(
              (teNantModels_Renew[index].datex == null ||
                      teNantModels_Renew[index].datex.toString() == '')
                  ? ''
                  : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${teNantModels_Renew[index].datex}'))}',
            );
      }

      sheet.getRangeByName('E${index + 7}').setText(
            (teNantModels_Renew[index].zn != null)
                ? (teNantModels_Renew[index].zn!.split('_')[0].length <= 4)
                    ? 'CMN0${teNantModels_Renew[index].zn!.split('_')[0]}'
                    : 'CMN${teNantModels_Renew[index].zn!.split('_')[0]}'
                : (teNantModels_Renew[index].zn1!.split('_')[0].length <= 4)
                    ? 'CMN0${teNantModels_Renew[index].zn1!.split('_')[0]}'
                    : 'CMN${teNantModels_Renew[index].zn1!.split('_')[0]}',
            // (teNantModels_Renew[index].zser != null)
            //     ? '${teNantModels_Renew[index].zser}'
            //     : '${teNantModels_Renew[index].zser1}'
          );

      sheet.getRangeByName('F${index + 7}').setText(
          (teNantModels_Renew[index].zn != null)
              ? '${teNantModels_Renew[index].zn}'
              : '${teNantModels_Renew[index].zn1}');

      sheet
          .getRangeByName('G${index + 7}')
          .setText('${teNantModels_Renew[index].ln}');

      sheet
          .getRangeByName('H${index + 7}')
          .setText('${teNantModels_Renew[index].cname}');
      try {
        sheet.getRangeByName('I${index + 7}').cellStyle.numberFormat =
            'dd-MM-yyyy';
        sheet.getRangeByName('I${index + 7}').setValue(
              (teNantModels_Renew[index].sdate == null ||
                      teNantModels_Renew[index].sdate.toString() == '')
                  ? null
                  : DateTime.parse('${teNantModels_Renew[index].sdate}'),
            );
      } catch (e) {
        sheet.getRangeByName('I${index + 7}').setText(
              (teNantModels_Renew[index].sdate == null ||
                      teNantModels_Renew[index].sdate.toString() == '')
                  ? ''
                  : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${teNantModels_Renew[index].sdate}'))}',
            );
      }
      try {
        sheet.getRangeByName('J${index + 7}').cellStyle.numberFormat =
            'dd-MM-yyyy';
        sheet.getRangeByName('J${index + 7}').setValue(
              (teNantModels_Renew[index].ldate == null ||
                      teNantModels_Renew[index].ldate.toString() == '')
                  ? null
                  : DateTime.parse('${teNantModels_Renew[index].ldate}'),
            );
      } catch (e) {
        sheet.getRangeByName('J${index + 7}').setText(
              (teNantModels_Renew[index].ldate == null ||
                      teNantModels_Renew[index].ldate.toString() == '')
                  ? ''
                  : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${teNantModels_Renew[index].ldate}'))}',
              // '${teNantModels_Renew[index].ldate}'
            );
      }

      sheet
          .getRangeByName('K${index + 7}')
          .setText('${teNantModels_Renew[index].nday}');
      sheet
          .getRangeByName('L${index + 7}')
          .setText('${teNantModels_Renew[index].stype}');

      sheet.getRangeByName('M${index + 7}').setText(
          '${(teNantModels_Renew[index].water_electri == null) ? '' : teNantModels_Renew[index].water_electri.toString()}');

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
      int count_01 = 12;
      // double getExpenseTotal(String key, String serExp) {
      //   return (dataList.isEmpty)
      //       ? 0.00
      //       : dataList
      //           .whereType<Map<String, dynamic>>()
      //           .where((element) => element['ser_exp'].toString() == serExp)
      //           .map((element) =>
      //               double.parse(element[key]?.toString() ?? '0.00'))
      //           .fold(0, (prev, exp) => prev + exp);
      // }

      for (int index2 = 0; index2 < Type_exp.length; index2++) {
        // String serExp = '${Type_exp[index2]["ser"]}';
        // double pvat = getExpenseTotal('pvat_exp', serExp);
        // double vat = getExpenseTotal('vat_exp', serExp);
        // double total = getExpenseTotal('total_exp', serExp);
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
      sheet
          .getRangeByName('${columns[(13) + columns_now]}${index + 7}')
          .setNumber((teNantModels_Renew[index].deposit == null)
              ? 0.00
              : double.parse('${teNantModels_Renew[index].deposit}'));
      try {
        sheet
            .getRangeByName('${columns[(14) + columns_now]}${index + 7}')
            .cellStyle
            .numberFormat = 'dd-MM-yyyy';
        sheet
            .getRangeByName('${columns[(14) + columns_now]}${index + 7}')
            .setValue(
              (teNantModels_Renew[index].daterec == null ||
                      teNantModels_Renew[index].daterec.toString() == '')
                  ? null
                  : DateTime.parse('${teNantModels_Renew[index].daterec}'),
            );
      } catch (e) {
        sheet
            .getRangeByName('${columns[(14) + columns_now]}${index + 7}')
            .setText(
              (teNantModels_Renew[index].daterec == null ||
                      teNantModels_Renew[index].daterec.toString() == '')
                  ? ''
                  : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${teNantModels_Renew[index].daterec}'))}',
              // '${teNantModels_Renew[index].daterec}'
            );
      }

      sheet
          .getRangeByName('${columns[(15) + columns_now]}${index + 7}')
          .setText((teNantModels_Renew[index].doctax == null &&
                  teNantModels_Renew[index].docno == null)
              ? ''
              : (teNantModels_Renew[index].doctax == null ||
                      teNantModels_Renew[index].doctax.toString() == '')
                  ? '${teNantModels_Renew[index].docno}'
                  : '${teNantModels_Renew[index].doctax}');

      sheet
          .getRangeByName('${columns[(16) + columns_now]}${index + 7}')
          .setText('${teNantModels_Renew[index].name_user}');
      sheet
          .getRangeByName('${columns[(17) + columns_now]}${index + 7}')
          .setText('${teNantModels_Renew[index].st}');
      sheet
          .getRangeByName('${columns[(18) + columns_now]}${index + 7}')
          .setText('${teNantModels_Renew[index].wnote}');
      sheet
          .getRangeByName('${columns[(19) + columns_now]}${index + 7}')
          .setNumber((teNantModels_Renew[index].pakan_new == null)
              ? 0.00
              : double.parse('${teNantModels_Renew[index].pakan_new}'));
      try {
        sheet
            .getRangeByName('${columns[(20) + columns_now]}${index + 7}')
            .cellStyle
            .numberFormat = 'dd-MM-yyyy';
        sheet
            .getRangeByName('${columns[(20) + columns_now]}${index + 7}')
            .setValue(
              (teNantModels_Renew[index].pdate_pakan_new == null ||
                      teNantModels_Renew[index].pdate_pakan_new.toString() ==
                          '')
                  ? null
                  : DateTime.parse(
                      '${teNantModels_Renew[index].pdate_pakan_new}'),
            );
      } catch (e) {
        sheet
            .getRangeByName('${columns[(20) + columns_now]}${index + 7}')
            .setText(
              (teNantModels_Renew[index].pdate_pakan_new == null ||
                      teNantModels_Renew[index].pdate_pakan_new.toString() ==
                          '')
                  ? ''
                  : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${teNantModels_Renew[index].pdate_pakan_new}'))}',
              // '${teNantModels_Renew[index].daterec}'
            );
      }
      sheet
          .getRangeByName('${columns[(21) + columns_now]}${index + 7}')
          .setText((teNantModels_Renew[index].pakan_new_docno == null)
              ? ''
              : '${teNantModels_Renew[index].pakan_new_docno}');
      indextotol = indextotol + 1;
    }
/////////---------------------------->
    sheet.getRangeByName('M${indextotol + 7 + 0}').setText('รวมทั้งหมด: ');
    sheet.getRangeByName('M${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet
        .getRangeByName('${columns[(13) + columns_now]}${indextotol + 7 + 0}')
        .cellStyle = globalStyle7;
    int xx_count_sum = 0;
    for (int i = 0; i < Type_exp.length; i++) {
      for (int x = 0; x < Type_vat.length; x++) {
        xx_count_sum = xx_count_sum + 1;
        sheet
            .getRangeByName(
                '${columns[12 + xx_count_sum]}${indextotol + 7 + 0}')
            .cellStyle = globalStyle7;
        sheet
            .getRangeByName(
                '${columns[12 + xx_count_sum]}${indextotol + 7 + 0}')
            .setFormula(
                '=SUM(${columns[12 + xx_count_sum]}3:${columns[12 + xx_count_sum]}${indextotol + 7 - 1})');
      }
    }
    sheet
        .getRangeByName('${columns[(13) + columns_now]}${indextotol + 7 + 0}')
        .setFormula(
            '=SUM(${columns[(13) + columns_now]}3:${columns[(13) + columns_now]}${indextotol + 7 - 1})');
/////////---------------------------->
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    Uint8List data = Uint8List.fromList(bytes);
    MimeType type = MimeType.MICROSOFTEXCEL;
    String path = await FileSaver.instance.saveFile(
        (Value_Chang_Zone_People_Renew == null)
            ? 'รายงานผู้เช่าต่อสัญญา ประจำเดือน ${Mon_PeopleRenew_Mon} ${YE_PeopleRenew_Mon}'
            : 'รายงานผู้เช่าต่อสัญญา ประจำเดือน ${Mon_PeopleRenew_Mon} ${YE_PeopleRenew_Mon}',
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
