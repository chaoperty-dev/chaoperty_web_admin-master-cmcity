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
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'dart:math' as math;
import 'Report_Screen.dart';
import 'package:http/http.dart' as http;

// Future<Uint8List> _loadImage() async {
//   String imageUrl =
//       'https://www.syncfusion.com/uploads/user/kb/flut/flut-3261/flut-3261_img3.jpeg';
//   List<int> imageData = await _readImageData(imageUrl);
//   // Encode the image data to base64
//   final String imageBase64 = base64.encode(imageData);

//   // Add image to Excel worksheet
//   sheet.pictures.addBase64(1, 1, imageBase64);

//   // Save and launch the Excel
//   final List<int> bytes = workbook.saveAsStream();
//   // You can save the bytes to a file or use it as needed

//   // Dispose the document
//   workbook.dispose();
// }

Future<List<int>> _readImageData(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return response.bodyBytes;
  } else {
    throw Exception('Failed to load image data');
  }
}

class Excgen_TaxReport {
  static void exportExcel_TaxReport(
      ser_type_repro,
      context,
      NameFile_,
      _verticalGroupValue_NameFile,
      Value_Report,
      TransReBillModels,
      TranHisBillModels,
      renTal_name,
      renTal_namesub,
      renTal_addr,
      renTal_tax,
      zoneModels_report,
      zone_name_Trans_Mon,
      Mon_Trans_Mon,
      YE_Trans_Mon,
      Value_TransDate_Daily,
      userModels,
      renTal_url,
      Type_Ref,
      ReportValue_typeZone) async {
    final x.Workbook workbook = x.Workbook(1);

    final x.Worksheet sheet = workbook.worksheets[0];
    // final x.Worksheet sheet2 = workbook.worksheets[1];
    sheet.name = 'Sheet1';
    sheet.pageSetup.topMargin = 1;
    sheet.pageSetup.bottomMargin = 1;
    sheet.pageSetup.leftMargin = 1;
    sheet.pageSetup.rightMargin = 1;

    // sheet2.name = 'สรุปผู้ทำรายการ';
    // sheet2.pageSetup.topMargin = 1;
    // sheet2.pageSetup.bottomMargin = 1;
    // sheet2.pageSetup.leftMargin = 1;
    // sheet2.pageSetup.rightMargin = 1;

//     //Adding a picture
//     final ByteData bytes_image = await rootBundle.load('images/LOGO.png');
//     final Uint8List image = bytes_image.buffer
//         .asUint8List(bytes_image.offsetInBytes, bytes_image.lengthInBytes);
// // Adding an image.
//     sheet.pictures.addStream(1, 1, image);
//     final x.Picture picture = sheet.pictures[0];

// // Re-size an image
//     picture.height = 200;
//     picture.width = 200;

// // rotate an image.
//     picture.rotation = 100;

// // Flip an image.
//     picture.horizontalFlip = true;
    //////////--------------------------->
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

    x.Style globalStyle1x = workbook.styles.add('style1x');
    globalStyle1x.backColorRgb = Color.fromARGB(255, 181, 206, 112);
    globalStyle1x.fontName = 'Angsana New';
    globalStyle1x.numberFormat = '_(\* #,##0.00_)';
    globalStyle1x.hAlign = x.HAlignType.center;
    globalStyle1x.fontSize = 16;
    globalStyle1x.bold = true;
    globalStyle1x.borders;
    globalStyle1x.fontColorRgb = Color.fromARGB(255, 3, 3, 3);

    x.Style globalStyle1D = workbook.styles.add('globalStyle1D');
    globalStyle1D.backColorRgb = Color.fromARGB(255, 230, 179, 163);
    globalStyle1D.fontName = 'Angsana New';
    globalStyle1D.numberFormat = '_(\* #,##0.00_)';
    globalStyle1D.hAlign = x.HAlignType.center;
    globalStyle1D.fontSize = 16;
    globalStyle1D.bold = true;
    globalStyle1D.borders;
    globalStyle1D.fontColorRgb = Color.fromARGB(255, 3, 3, 3);

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
////////////-------------------------------------------------------->
    x.Style globalStyle220x = workbook.styles.add('globalStyle220x');
    globalStyle220x.backColorRgb = Color(0xC7F5F7FA);
    globalStyle220x.numberFormat = '_(\* #,##0.00_)';
    globalStyle220x.fontSize = 12;
    globalStyle220x.numberFormat;
    globalStyle220x.hAlign = x.HAlignType.left;
    ////////////-------------------------------------------------------->
    x.Style globalStyle220_2 = workbook.styles.add('globalStyle220_2');
    globalStyle220_2.backColorRgb = Color(0xC7F5F7FA);
    globalStyle220_2.numberFormat = '_(\* #,##0.00_)';
    globalStyle220_2.fontSize = 12;
    globalStyle220_2.numberFormat;
    globalStyle220_2.hAlign = x.HAlignType.center;

    globalStyle.backColorRgb = const Color.fromARGB(255, 90, 192, 59);
    x.Style globalStyle2 = workbook.styles.add('style2');
    globalStyle2.backColorRgb = const Color.fromARGB(255, 147, 223, 124);

    x.Style globalStyle7 = workbook.styles.add('style7');
    globalStyle7.backColorRgb = Color.fromARGB(255, 230, 199, 163);
    globalStyle7.fontName = 'Angsana New';
    globalStyle7.numberFormat = '_(\* #,##0.00_)';
    globalStyle7.hAlign = x.HAlignType.center;
    globalStyle7.fontSize = 15;
    globalStyle7.bold = true;
    globalStyle7.fontColorRgb = Color(0xFFC52611);

    x.Style globalStyle2220 = workbook.styles.add('globalStyle2220');
    globalStyle2220.backColorRgb = Color.fromARGB(255, 71, 168, 224);
    globalStyle2220.fontName = 'Angsana New';
    globalStyle2220.numberFormat = '_(\* #,##0.00_)';
    globalStyle2220.hAlign = x.HAlignType.center;
    globalStyle2220.fontSize = 16;
    globalStyle2220.bold = true;
    globalStyle2220.borders;
    globalStyle2220.fontColorRgb = Color.fromARGB(255, 3, 3, 3);
    int data_type_zone =
        (ReportValue_typeZone.toString() == '1โซน/พื้นที่') ? 0 : 1;
/////////--------------------------------------------->
    try {
      String imageUrl = '$renTal_url';
      List<int> imageData = await _readImageData(imageUrl);

      // Encode the image data to base64
      final String imageBase64 = base64.encode(imageData);

      // Add image to Excel worksheet at A5 (row 5, column 1)
      sheet.pictures.addBase64(1, 7, imageBase64);
      final Picture picture = sheet.pictures[0];
      picture.height = 100;
      picture.width = 100;

      // Set the height of row 5 to 80
      sheet.getRangeByName('G1').rowHeight = 80;
    } catch (e) {
      // Handle the error
      print('An error occurred: $e');
      // You can also log the error or show a message to the user
    }

    /////////--------------------------------------------->
    sheet.getRangeByName('A1:K1').merge();
    sheet.getRangeByName('A2:K2').merge();
    sheet.getRangeByName('A3:K3').merge();
    sheet.getRangeByName('A4:D4').merge();
    sheet.getRangeByName('A5:D5').merge();
    sheet.getRangeByName('A6:D6').merge();

    sheet.getRangeByName('A2').setText(
          (zone_name_Trans_Mon == null) ? '$NameFile_' : '$NameFile_',
        );
    sheet.getRangeByName('A3').setText(
        (Value_TransDate_Daily == null && YE_Trans_Mon != null)
            ? 'ประจำเดือน ${Mon_Trans_Mon} ${int.parse(YE_Trans_Mon ?? 0) + 543}'
            : 'ประจำวันที่ $Value_TransDate_Daily'
        // 'ประจำวัน ${Value_TransDate_Daily}'
        );
    // renTal_name,
    // renTal_namesub,
    // renTal_addr,
    // renTal_tax,
    sheet.getRangeByName('A4').setText('ชื่อสถานประกอบการ : $renTal_name');

    sheet.getRangeByName('A5').setText('ชื่อสถานประกอบการ : $renTal_namesub');
    sheet.getRangeByName('A6').setText('ที่อยู่ : $renTal_addr');
    sheet
        .getRangeByName('J4')
        .setText('เลขประจำตัวผู้เสีบภาษีอากร : $renTal_tax');
    sheet
        .getRangeByName('J5')
        .setText('โซน : ${zone_name_Trans_Mon ?? 'ทั้งหมด'}');
    sheet.getRangeByName('J6').setText('ใบเสร็จ : ${TransReBillModels.length}');
    sheet.getRangeByName('K6').setText('อัพเดต ณ :${DateTime.now()}');
// ExcelSheetProtectionOption globalStyle220x
    final x.ExcelSheetProtectionOption options = x.ExcelSheetProtectionOption();
    options.all = true;
    for (var i = 1; i < 7; i++) {
      sheet.getRangeByName('A$i').cellStyle =
          (i < 4) ? globalStyle220 : globalStyle220x;
      sheet.getRangeByName('B$i').cellStyle =
          (i < 4) ? globalStyle220 : globalStyle220x;
      sheet.getRangeByName('C$i').cellStyle =
          (i < 4) ? globalStyle220 : globalStyle220x;
      sheet.getRangeByName('D$i').cellStyle =
          (i < 4) ? globalStyle220 : globalStyle220x;
      sheet.getRangeByName('E$i').cellStyle =
          (i < 4) ? globalStyle220 : globalStyle220x;
      sheet.getRangeByName('F$i').cellStyle =
          (i < 4) ? globalStyle220 : globalStyle220x;
      sheet.getRangeByName('G$i').cellStyle =
          (i < 4) ? globalStyle220 : globalStyle220x;
      sheet.getRangeByName('H$i').cellStyle =
          (i < 4) ? globalStyle220 : globalStyle220x;
      sheet.getRangeByName('I$i').cellStyle =
          (i < 4) ? globalStyle220 : globalStyle220x;
      sheet.getRangeByName('J$i').cellStyle =
          (i < 4) ? globalStyle220 : globalStyle220x;
      sheet.getRangeByName('K$i').cellStyle =
          (i < 4) ? globalStyle220 : globalStyle220x;
      sheet.getRangeByName('L$i').cellStyle =
          (i < 4) ? globalStyle220 : globalStyle220x;

      for (var i_Ref = 0; i_Ref < Type_Ref.length; i_Ref++) {
        if (i_Ref == 0)
          sheet.getRangeByName('M$i').cellStyle =
              (i < 4) ? globalStyle220 : globalStyle220x;
        if (i_Ref == 1)
          sheet.getRangeByName('N$i').cellStyle =
              (i < 4) ? globalStyle220 : globalStyle220x;
        if (i_Ref == 2)
          sheet.getRangeByName('O$i').cellStyle =
              (i < 4) ? globalStyle220 : globalStyle220x;

        if (i_Ref == 3)
          sheet.getRangeByName('P$i').cellStyle =
              (i < 4) ? globalStyle220 : globalStyle220x;
      }
    }

    for (var i = 7; i < 9; i++) {
      if (i == 7) {
        sheet.getRangeByName('A$i').cellStyle = globalStyle1x;
        sheet.getRangeByName('B$i').cellStyle = globalStyle1x;
        sheet.getRangeByName('C$i').cellStyle = globalStyle1x;
        sheet.getRangeByName('D$i').cellStyle = globalStyle1x;
        sheet.getRangeByName('E$i').cellStyle = globalStyle1x;
        sheet.getRangeByName('F$i').cellStyle = globalStyle1x;
        sheet.getRangeByName('G$i').cellStyle = globalStyle1x;
        sheet.getRangeByName('H$i').cellStyle = globalStyle1x;
        sheet.getRangeByName('I$i').cellStyle = globalStyle1x;
        sheet.getRangeByName('J$i').cellStyle = globalStyle1x;
        sheet.getRangeByName('K$i').cellStyle = globalStyle1x;
        sheet.getRangeByName('L$i').cellStyle = globalStyle1x;
        for (var i_Ref = 0; i_Ref < Type_Ref.length; i_Ref++) {
          if (i_Ref == 0) sheet.getRangeByName('M$i').cellStyle = globalStyle1x;
          if (i_Ref == 1) sheet.getRangeByName('N$i').cellStyle = globalStyle1x;
          if (i_Ref == 2) sheet.getRangeByName('O$i').cellStyle = globalStyle1x;
          if (i_Ref == 3) sheet.getRangeByName('P$i').cellStyle = globalStyle1x;
        }
      } else {
        sheet.getRangeByName('A$i').cellStyle = globalStyle1;
        sheet.getRangeByName('B$i').cellStyle = globalStyle1;
        sheet.getRangeByName('C$i').cellStyle = globalStyle1;
        sheet.getRangeByName('D$i').cellStyle = globalStyle1;
        sheet.getRangeByName('E$i').cellStyle = globalStyle1;
        sheet.getRangeByName('F$i').cellStyle = globalStyle1;
        sheet.getRangeByName('G$i').cellStyle = globalStyle1;
        sheet.getRangeByName('H$i').cellStyle = globalStyle1;
        sheet.getRangeByName('I$i').cellStyle = globalStyle1;
        sheet.getRangeByName('J$i').cellStyle = globalStyle1;
        sheet.getRangeByName('K$i').cellStyle = globalStyle1;
        sheet.getRangeByName('L$i').cellStyle = globalStyle1;
        for (var i_Ref = 0; i_Ref < Type_Ref.length; i_Ref++) {
          if (i_Ref == 0) sheet.getRangeByName('M$i').cellStyle = globalStyle1;
          if (i_Ref == 1) sheet.getRangeByName('N$i').cellStyle = globalStyle1;
          if (i_Ref == 2) sheet.getRangeByName('O$i').cellStyle = globalStyle1;
          if (i_Ref == 2) sheet.getRangeByName('P$i').cellStyle = globalStyle1;
        }
      }
      sheet.getRangeByName('A$i').columnWidth = 10;
      sheet.getRangeByName('B$i').columnWidth = 15;
      sheet.getRangeByName('C$i').columnWidth = 20;
      sheet.getRangeByName('D$i').columnWidth = 35;
      sheet.getRangeByName('E$i').columnWidth = 25;
      sheet.getRangeByName('F$i').columnWidth = 25;
      sheet.getRangeByName('G$i').columnWidth = 35;
      sheet.getRangeByName('H$i').columnWidth = 25;
      sheet.getRangeByName('I$i').columnWidth = 25;
      sheet.getRangeByName('J$i').columnWidth = 25;
      sheet.getRangeByName('K$i').columnWidth = 25;
      sheet.getRangeByName('L$i').columnWidth = 35;
      for (var i_Ref = 0; i_Ref < Type_Ref.length; i_Ref++) {
        if (i_Ref == 0) sheet.getRangeByName('M$i').columnWidth = 30;
        if (i_Ref == 1) sheet.getRangeByName('N$i').columnWidth = 30;
        if (i_Ref == 2) sheet.getRangeByName('O$i').columnWidth = 30;
        if (i_Ref == 2) sheet.getRangeByName('P$i').columnWidth = 30;
      }
      if (i == 7) {
        sheet.getRangeByName('B$i:C$i').merge();
        // sheet.getRangeByName('A$i').setText('');
        sheet.getRangeByName('B$i').setText('ใบกำกับ');
        // sheet.getRangeByName('C$i').setText('เล่มที่/เลขที่');
        // sheet.getRangeByName('D$i').setText('');
        // sheet.getRangeByName('E$i').setText('');
        // sheet.getRangeByName('F$i').setText('');
        // sheet.getRangeByName('G$i').setText('');
        sheet.getRangeByName('H$i').setText('มูลค่าสินค้า');
        // sheet.getRangeByName('I$i').setText('');
        // sheet.getRangeByName('J$i').setText('');
        // sheet.getRangeByName('K$i').setText('');
      } else {
        sheet.getRangeByName('A$i').setText('ลำดับ');
        sheet.getRangeByName('B$i').setText('วัน-เดือน-ปี');
        sheet.getRangeByName('C$i').setText('เล่มที่/เลขที่');
        sheet.getRangeByName('D$i').setText('ชื่อผู้ขายสินค้า/ผู้ให้บริการ');
        sheet.getRangeByName('E$i').setText('เลขประจำตัวผู้เสียภาษี');
        sheet.getRangeByName('F$i').setText('สาขา');
        sheet.getRangeByName('G$i').setText('พื้นที่');
        sheet.getRangeByName('H$i').setText('ไม่มีภาษี');
        sheet.getRangeByName('I$i').setText('มูลค่าสินค้า');
        sheet.getRangeByName('J$i').setText('ภาษีมูลค่าเพิ่ม');
        sheet.getRangeByName('K$i').setText('หักณที่จ่าย');
        sheet.getRangeByName('L$i').setText('รวม');
        for (var i_Ref = 0; i_Ref < Type_Ref.length; i_Ref++) {
          // Set text in the appropriate cell based on the index
          if (i_Ref == 0) {
            sheet
                .getRangeByName('M$i')
                .setText('${Type_Ref[i_Ref]['pn'].toString()}');
          } else if (i_Ref == 1) {
            sheet
                .getRangeByName('N$i')
                .setText('${Type_Ref[i_Ref]['pn'].toString()}');
          } else if (i_Ref == 2) {
            sheet
                .getRangeByName('O$i')
                .setText('${Type_Ref[i_Ref]['pn'].toString()}');
          } else if (i_Ref == 3) {
            sheet
                .getRangeByName('P$i')
                .setText('${Type_Ref[i_Ref]['pn'].toString()}');
          }
        }
      }
    }
    int indextotol = 0;
    int indextotol_ = 0;

    for (var index1 = 0; index1 < TransReBillModels.length; index1++) {
      var index = indextotol;
      dynamic numberColor = index1 % 2 == 0 ? globalStyle22 : globalStyle222;

      dynamic numberColor_s =
          index1 % 2 == 0 ? globalStyle220 : globalStyle2220;

      indextotol = indextotol + 1;
      // sheet.getRangeByName('A${indextotol + 5 - 1}').cellStyle = numberColor;
      sheet.getRangeByName('A${indextotol + 9 - 1}').cellStyle = numberColor;
      sheet.getRangeByName('B${indextotol + 9 - 1}').cellStyle = numberColor;
      sheet.getRangeByName('C${indextotol + 9 - 1}').cellStyle = numberColor;
      sheet.getRangeByName('D${indextotol + 9 - 1}').cellStyle = numberColor;
      sheet.getRangeByName('E${indextotol + 9 - 1}').cellStyle = numberColor;
      sheet.getRangeByName('F${indextotol + 9 - 1}').cellStyle = numberColor;
      sheet.getRangeByName('G${indextotol + 9 - 1}').cellStyle = numberColor;
      sheet.getRangeByName('H${indextotol + 9 - 1}').cellStyle = numberColor;
      sheet.getRangeByName('I${indextotol + 9 - 1}').cellStyle = numberColor;
      sheet.getRangeByName('J${indextotol + 9 - 1}').cellStyle = numberColor;
      sheet.getRangeByName('K${indextotol + 9 - 1}').cellStyle = numberColor;
      sheet.getRangeByName('L${indextotol + 9 - 1}').cellStyle = numberColor;

      for (var i_Ref = 0; i_Ref < Type_Ref.length; i_Ref++) {
        if (i_Ref == 0)
          sheet.getRangeByName('M${indextotol + 9 - 1}').cellStyle =
              numberColor;
        if (i_Ref == 1)
          sheet.getRangeByName('N${indextotol + 9 - 1}').cellStyle =
              numberColor;
        if (i_Ref == 2)
          sheet.getRangeByName('O${indextotol + 9 - 1}').cellStyle =
              numberColor;
        if (i_Ref == 3)
          sheet.getRangeByName('P${indextotol + 9 - 1}').cellStyle =
              numberColor;
      }
///////------------------------------------->
      sheet.getRangeByName('A${indextotol + 9 - 1}').setText('${index1 + 1}');
      sheet.getRangeByName('B${indextotol + 9 - 1}').setText((TransReBillModels[
                      index1]
                  .dateacc ==
              null)
          ? ''
          : '${DateFormat('dd/MM').format(DateTime.parse('${TransReBillModels[index1].dateacc}'))}/${int.parse('${DateFormat('yyyy').format(DateTime.parse('${TransReBillModels[index1].dateacc}'))}') + 543}');
      sheet.getRangeByName('C${indextotol + 9 - 1}').setText(
            (TransReBillModels[index1].doctax != '')
                ? '${TransReBillModels[index1].doctax}'
                : TransReBillModels[index1].docno == ''
                    ? '${TransReBillModels[index1].refno}'
                    : '${TransReBillModels[index1].docno}',
          );
      sheet.getRangeByName('D${indextotol + 9 - 1}').setText(
            (TransReBillModels[index1].cname == null ||
                    TransReBillModels[index1].cname.toString() == '' ||
                    TransReBillModels[index1].cname.toString() == 'null')
                ? '${TransReBillModels[index1].remark}'
                : '${TransReBillModels[index1].cname}',
          );
      sheet.getRangeByName('E${indextotol + 9 - 1}').setText(
            (TransReBillModels[index1].tax == null)
                ? ''
                : '${TransReBillModels[index1].tax}',
          );
      sheet.getRangeByName('F${indextotol + 9 - 1}').setText(
            (TransReBillModels[index1].zn == null)
                ? '${TransReBillModels[index1].znn}'
                : (data_type_zone == 0)
                    ? '${TransReBillModels[index1].zn}'
                    : '${TransReBillModels[index1].zn2}',
          );
      sheet
          .getRangeByName('G${indextotol + 9 - 1}')
          .setText((TransReBillModels[index1].ln == null)
              ? '${TransReBillModels[index1].room_number}'
              : (data_type_zone == 0)
                  ? '${TransReBillModels[index1].ln}'
                  : '${TransReBillModels[index1].ln2}');

      sheet.getRangeByName('H${indextotol + 9 - 1}').setNumber(
          (TransReBillModels[index1].sum_pvat == null)
              ? 0.00
              : double.parse(TransReBillModels[index1].sum_pvat!)
          // +
          //     double.parse((TransReBillModels[index1].sum_wht == null)
          //         ? 0.00
          //         : TransReBillModels[index1].sum_wht!)
          );
      // sheet
      //     .getRangeByName('H${indextotol + 9 - 1}')
      //     .setFormula('=I${indextotol + 9 - 1}-J${indextotol + 9 - 1}');
      sheet.getRangeByName('I${indextotol + 9 - 1}').setNumber(
          (TransReBillModels[index1].total_bill == null)
              ? 0.00
              : double.parse(TransReBillModels[index1].total_bill!));
      sheet.getRangeByName('J${indextotol + 9 - 1}').setNumber(
          (TransReBillModels[index1].sum_vat == null)
              ? 0.00
              : double.parse(TransReBillModels[index1].sum_vat!));
      sheet.getRangeByName('K${indextotol + 9 - 1}').setNumber(
          (TransReBillModels[index1].sum_wht == null)
              ? 0.00
              : double.parse(TransReBillModels[index1].sum_wht!));
      // sheet
      //     .getRangeByName('K${indextotol + 9 - 1}')
      //     .setFormula('=H${indextotol + 9 - 1}+J${indextotol + 9 - 1}');
      sheet.getRangeByName('L${indextotol + 9 - 1}').setNumber(
          (TransReBillModels[index1].total_bill == null)
              ? 0.00
              : double.parse(TransReBillModels[index1].total_bill!));
      for (var i_Ref = 0; i_Ref < Type_Ref.length; i_Ref++) {
        var data_ref;

        // Determine the reference based on the type
        if (Type_Ref[i_Ref]['type'].toString() == 'ref1') {
          data_ref =
              TransReBillModels[index1].ref1; // Assuming ref1 is a single value
        } else if (Type_Ref[i_Ref]['type'].toString() == 'ref2') {
          data_ref =
              TransReBillModels[index1].ref2; // Assuming ref2 is a single value
        } else if (Type_Ref[i_Ref]['type'].toString() == 'ref-chao') {
          data_ref =
              TransReBillModels[index1].ref4; // Assuming ref4 is a single value
        } else if (Type_Ref[i_Ref]['type'].toString() == 'inv') {
          data_ref =
              TransReBillModels[index1].inv; // Assuming ref4 is a single value
        } else {
          data_ref = ''; // Default case if no type matches
        }

        // Set the value in the appropriate column based on the index
        if (i_Ref == 0) {
          sheet.getRangeByName('M${indextotol + 9 - 1}').setText('$data_ref');
        } else if (i_Ref == 1) {
          sheet.getRangeByName('N${indextotol + 9 - 1}').setText('$data_ref');
        } else if (i_Ref == 2) {
          sheet.getRangeByName('O${indextotol + 9 - 1}').setText('$data_ref');
        } else if (i_Ref == 3) {
          sheet.getRangeByName('P${indextotol + 9 - 1}').setText('$data_ref');
        }
      }
    }
    /////////////////////////////////------------------------------------------------>
    sheet.getRangeByName('G${indextotol + 9 + 0}').setText('รวม: ');
    sheet
        .getRangeByName('H${indextotol + 9 + 0}')
        .setFormula('=SUM(H9:H${indextotol + 9 - 1})');
    sheet
        .getRangeByName('I${indextotol + 9 + 0}')
        .setFormula('=SUM(I9:I${indextotol + 9 - 1})');
    sheet
        .getRangeByName('J${indextotol + 9 + 0}')
        .setFormula('=SUM(J9:J${indextotol + 9 - 1})');
    sheet
        .getRangeByName('K${indextotol + 9 + 0}')
        .setFormula('=SUM(K9:K${indextotol + 9 - 1})');
    sheet
        .getRangeByName('L${indextotol + 9 + 0}')
        .setFormula('=SUM(L9:L${indextotol + 9 - 1})');
    for (var index = 0; index < 1; index++) {
      sheet.getRangeByName('G${indextotol + 9 + index}').cellStyle =
          globalStyle7;
      sheet.getRangeByName('H${indextotol + 9 + index}').cellStyle =
          globalStyle7;
      sheet.getRangeByName('I${indextotol + 9 + index}').cellStyle =
          globalStyle7;
      sheet.getRangeByName('J${indextotol + 9 + index}').cellStyle =
          globalStyle7;
      sheet.getRangeByName('K${indextotol + 9 + index}').cellStyle =
          globalStyle7;
      sheet.getRangeByName('L${indextotol + 9 + index}').cellStyle =
          globalStyle7;
    }
/////////////////////////////////------------------------------------------------>

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    Uint8List data = Uint8List.fromList(bytes);
    MimeType type = MimeType.MICROSOFTEXCEL;

    if (_verticalGroupValue_NameFile.toString() == 'จากระบบ') {
      String path = await FileSaver.instance.saveFile(
          (Value_TransDate_Daily == null && YE_Trans_Mon != null)
              ? 'รายงานภาษีขายประจำเดือน${Mon_Trans_Mon}${int.parse(YE_Trans_Mon ?? 0) + 543}'
              : 'รายงานภาษีขายประจำวัน',
          data,
          "xlsx",
          mimeType: type);
      log(path);
    } else {
      String path = await FileSaver.instance
          .saveFile("$NameFile_", data, "xlsx", mimeType: type);
      log(path);
    }
  }
}
