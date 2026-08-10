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

////////// (รายงานผู้เช่า-ยกเลิกสัญญา)
class Excgen_TeNantCancelReport_Choice {
  static void exportExcel_TeNantCancelReport_Choice(
      context,
      namereport,
      NameFile_,
      _verticalGroupValue_NameFile,
      renTal_name,
      Value_Chang_Zone_People_Cancel,
      teNantModels_Cancel,
      Mon_PeopleCancel_Mon,
      YE_PeopleCancel_Mon) async {
    var nFormat = NumberFormat("#,##0.00", "en_US");
    var nFormat2 = NumberFormat("###0.00", "en_US");
    DateTime datex = DateTime.now();
    String day_ =
        '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}'; //// GC_billPay_SalesTaxFullReport_ _Choice

    String Tim_ =
        '${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}';
    final x.Workbook workbook = x.Workbook();

    final x.Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'รายงานยกเลิกสัญญาเช่า';
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
          (Value_Chang_Zone_People_Cancel == null)
              ? '$namereport (กรุณาเลือกโซน)'
              : '$namereport (โซน : $Value_Chang_Zone_People_Cancel)',
        );
    sheet
        .getRangeByName('A2')
        .setText('ประจำเดือน ${Mon_PeopleCancel_Mon} ${YE_PeopleCancel_Mon}');
    sheet.getRangeByName('A3').setText(
        'ชื่อสถานประกอบการ บริษัท ชอยส์มินิสโตร์ จำกัด เลขประจำตัวผู้เสียภาษี 0-1055-31085-43-4');
    sheet.getRangeByName('A4').setText('ชื่อสถานประกอบการ เซเว่นอีเลฟเว่น');
    sheet
        .getRangeByName('A5')
        .setText('ทั้งหมด :${teNantModels_Cancel.length}');
    sheet.getRangeByName('I5').setText('อัพเดต ณ :${DateTime.now()}');
// ExcelSheetProtectionOption
    final x.ExcelSheetProtectionOption options = x.ExcelSheetProtectionOption();
    options.all = true;

//     sheet.getRangeByName('A1').setText(
//           (Value_Chang_Zone_People_Cancel == null)
//               ? 'รายงานยกเลิกสัญญาเช่า ประจำเดือน ${Mon_PeopleCancel_Mon} ${YE_PeopleCancel_Mon} (กรุณาเลือกโซน)'
//               : 'รายงานยกเลิกสัญญาเช่า ประจำเดือน ${Mon_PeopleCancel_Mon} ${YE_PeopleCancel_Mon} (โซน : $Value_Chang_Zone_People_Cancel)',
//         );

// // ExcelSheetProtectionOption
//     final x.ExcelSheetProtectionOption options = x.ExcelSheetProtectionOption();
//     options.all = true;

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
      sheet.getRangeByName('N${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('O${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('P${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('Q${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('R${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('S${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('T${index + 1}').cellStyle = globalStyle220;

      sheet.getRangeByName('U${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('V${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('W${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('X${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('Y${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('Z${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('AA${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('AB${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('AC${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('AD${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('AE${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('AF${index + 1}').cellStyle = globalStyle220;

      sheet.getRangeByName('AG${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('AH${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('AI${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('AJ${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('AK${index + 1}').cellStyle = globalStyle220;

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
    sheet.getRangeByName('N6').cellStyle = globalStyle1;
    sheet.getRangeByName('O6').cellStyle = globalStyle1;
    sheet.getRangeByName('P6').cellStyle = globalStyle1;
    sheet.getRangeByName('Q6').cellStyle = globalStyle1;
    sheet.getRangeByName('R6').cellStyle = globalStyle1;
    sheet.getRangeByName('S6').cellStyle = globalStyle1;
    sheet.getRangeByName('T6').cellStyle = globalStyle1;
    sheet.getRangeByName('U6').cellStyle = globalStyle1;
    sheet.getRangeByName('V6').cellStyle = globalStyle1;
    sheet.getRangeByName('W6').cellStyle = globalStyle1;
    sheet.getRangeByName('X6').cellStyle = globalStyle1;
    sheet.getRangeByName('Y6').cellStyle = globalStyle1;
    sheet.getRangeByName('Z6').cellStyle = globalStyle1;
    sheet.getRangeByName('AA6').cellStyle = globalStyle1;
    sheet.getRangeByName('AB6').cellStyle = globalStyle1;
    sheet.getRangeByName('AC6').cellStyle = globalStyle1;
    sheet.getRangeByName('AD6').cellStyle = globalStyle1;
    sheet.getRangeByName('AE6').cellStyle = globalStyle1;
    sheet.getRangeByName('AF6').cellStyle = globalStyle1;

    sheet.getRangeByName('AG6').cellStyle = globalStyle1;
    sheet.getRangeByName('AH6').cellStyle = globalStyle1;
    sheet.getRangeByName('AI6').cellStyle = globalStyle1;
    sheet.getRangeByName('AJ6').cellStyle = globalStyle1;
    sheet.getRangeByName('AK6').cellStyle = globalStyle1;

    sheet.getRangeByName('A6').columnWidth = 10;
    sheet.getRangeByName('B6').columnWidth = 20;
    sheet.getRangeByName('C6').columnWidth = 20;
    sheet.getRangeByName('D6').columnWidth = 25;
    sheet.getRangeByName('E6').columnWidth = 25;
    sheet.getRangeByName('F6').columnWidth = 25;
    sheet.getRangeByName('G6').columnWidth = 35;
    sheet.getRangeByName('H6').columnWidth = 25;
    sheet.getRangeByName('I6').columnWidth = 25;
    sheet.getRangeByName('J6').columnWidth = 25;
    sheet.getRangeByName('K6').columnWidth = 25;
    sheet.getRangeByName('L6').columnWidth = 25;
    sheet.getRangeByName('M6').columnWidth = 25;
    sheet.getRangeByName('N6').columnWidth = 25;
    sheet.getRangeByName('O6').columnWidth = 25;
    sheet.getRangeByName('P6').columnWidth = 20;
    sheet.getRangeByName('Q6').columnWidth = 30;
    sheet.getRangeByName('R6').columnWidth = 20;
    sheet.getRangeByName('S6').columnWidth = 20;
    sheet.getRangeByName('T6').columnWidth = 20;
    sheet.getRangeByName('U6').columnWidth = 20;
    sheet.getRangeByName('V6').columnWidth = 20;
    sheet.getRangeByName('W6').columnWidth = 20;
    sheet.getRangeByName('X6').columnWidth = 20;
    sheet.getRangeByName('Y6').columnWidth = 20;
    sheet.getRangeByName('Z6').columnWidth = 20;
    sheet.getRangeByName('AA6').columnWidth = 20;
    sheet.getRangeByName('AB6').columnWidth = 20;
    sheet.getRangeByName('AC6').columnWidth = 20;
    sheet.getRangeByName('AD6').columnWidth = 20;
    sheet.getRangeByName('AE6').columnWidth = 20;
    sheet.getRangeByName('AF6').columnWidth = 20;
    sheet.getRangeByName('AG6').columnWidth = 20;
    sheet.getRangeByName('AH6').columnWidth = 20;
    sheet.getRangeByName('AI6').columnWidth = 20;
    sheet.getRangeByName('AJ6').columnWidth = 20;
    sheet.getRangeByName('AK6').columnWidth = 20;

    sheet.getRangeByName('A6').setText('ลำดับที่');
    sheet.getRangeByName('B6').setText('เลขที่สัญญา');
    sheet.getRangeByName('C6').setText('เลขที่สัญญา-เดิม');
    sheet.getRangeByName('D6').setText('van');
    sheet.getRangeByName('E6').setText('รหัสสาขา');
    sheet.getRangeByName('F6').setText('ชื่อสาขา');
    sheet.getRangeByName('G6').setText('เลขล็อค');
    sheet.getRangeByName('H6').setText('ชื่อ-สกุล ผู้เช่า');
    sheet.getRangeByName('I6').setText('ที่อยู่');
    sheet.getRangeByName('J6').setText('เบอร์ติดต่อ');
    sheet.getRangeByName('K6').setText('วันที่เริ่มเช่า');

    sheet.getRangeByName('L6').setText('วันที่สิ้นสุดสัญญา');
    sheet.getRangeByName('M6').setText('ประเภทสินค้า');
    sheet.getRangeByName('N6').setText('น้ำ + ไฟ');
    sheet.getRangeByName('O6').setText('กำหนดยกเลิกล่วงหน้า');
    sheet.getRangeByName('P6').setText('วันที่ยกเลิกสัญญา');
    sheet.getRangeByName('Q6').setText('วันที่ยกเลิกสัญญา(ในระบบ)');
    sheet.getRangeByName('R6').setText('เงินประกัน+VAT7%');
    sheet.getRangeByName('S6').setText('วันที่ใบเสร็จ(เงินประกัน)');
    sheet.getRangeByName('T6').setText('เลขที่ใบเสร็จ(เงินประกัน)');

    sheet.getRangeByName('U6').setText('เงินประกัน');
    sheet.getRangeByName('V6').setText('ค่าเช่าพื้นที่ดิน');
    sheet.getRangeByName('W6').setText('ค่าเช่าพื้นที่');
    sheet.getRangeByName('X6').setText('ค่าบริการ');

    sheet.getRangeByName('Y6').setText('ค่าน้ำ+VAT7%');
    sheet.getRangeByName('Z6').setText('ค่าไฟ+VAT7%');
    sheet.getRangeByName('AA6').setText('ค่าปรับ');

    sheet.getRangeByName('AB6').setText('เรียกเก็บ');
    sheet.getRangeByName('AC6').setText('ชำระ');
    sheet.getRangeByName('AD6').setText('วันที่ชำระ');
    sheet.getRangeByName('AE6').setText('หัก');
    sheet.getRangeByName('AF6').setText('คงเหลือจ่าย');
    sheet.getRangeByName('AG6').setText('ผู้ดูแล');
    sheet.getRangeByName('AH6').setText('หมายเหตุ');
    sheet.getRangeByName('AI6').setText('เลขที่แจ้งหนี้วางบิล');
    // sheet.getRangeByName('AH6').setText('วันที่ทำรายการ');
    sheet.getRangeByName('AJ6').setText('อ้างอิง');
    sheet.getRangeByName('AK6').setText('สถานะ');

    int index1 = 0;
    int indextotol = 0;
    List cid_number = [];

    for (int index = 0; index < teNantModels_Cancel.length; index++) {
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
      sheet.getRangeByName('O${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('P${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('Q${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('R${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('S${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('T${index + 7}').cellStyle = numberColor;

      sheet.getRangeByName('U${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('V${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('W${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('X${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('Y${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('Z${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('AA${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('AB${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('AC${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('AD${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('AE${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('AF${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('AG${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('AH${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('AI${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('AJ${index + 7}').cellStyle = numberColor;
      sheet.getRangeByName('AK${index + 7}').cellStyle = numberColor;
////////----------------------->

////////----------------------->
      sheet.getRangeByName('A${index + 7}').setText('${index + 1}');
      sheet
          .getRangeByName('B${index + 7}')
          .setText('${teNantModels_Cancel[index].cid}');
      sheet
          .getRangeByName('C${index + 7}')
          .setText('${teNantModels_Cancel[index].renew_cid}');
      sheet.getRangeByName('D${index + 7}').setText('');

      sheet.getRangeByName('E${index + 7}').setText(
            (teNantModels_Cancel[index].zn != null)
                ? (teNantModels_Cancel[index].zn!.split('_')[0].length <= 4)
                    ? 'CMN0${teNantModels_Cancel[index].zn!.split('_')[0]}'
                    : 'CMN${teNantModels_Cancel[index].zn!.split('_')[0]}'
                : (teNantModels_Cancel[index].zn1!.split('_')[0].length <= 4)
                    ? 'CMN0${teNantModels_Cancel[index].zn1!.split('_')[0]}'
                    : 'CMN${teNantModels_Cancel[index].zn1!.split('_')[0]}',
            // (teNantModels_Cancel[index].zser != null)
            //     ? '${teNantModels_Cancel[index].zser}'
            //     : '${teNantModels_Cancel[index].zser1}'
          );
      sheet.getRangeByName('F${index + 7}').setText(
            (teNantModels_Cancel[index].zn != null)
                ? '${teNantModels_Cancel[index].zn}'
                : '${teNantModels_Cancel[index].zn1}',
          );

      sheet
          .getRangeByName('G${index + 7}')
          .setText('${teNantModels_Cancel[index].ln}');

      sheet
          .getRangeByName('H${index + 7}')
          .setText('${teNantModels_Cancel[index].cname}');

      sheet
          .getRangeByName('I${index + 7}')
          .setText('${teNantModels_Cancel[index].addr}');

      sheet
          .getRangeByName('J${index + 7}')
          .setText('${teNantModels_Cancel[index].tel}');

      try {
        sheet.getRangeByName('K${index + 7}').cellStyle.numberFormat =
            'dd-MM-yyyy';
        sheet.getRangeByName('K${index + 7}').setValue(
              (teNantModels_Cancel[index].sdate == null ||
                      teNantModels_Cancel[index].sdate.toString() == '')
                  ? null
                  : DateTime.parse('${teNantModels_Cancel[index].sdate}'),
            );
      } catch (e) {
        sheet.getRangeByName('K${index + 7}').setText(
              (teNantModels_Cancel[index].sdate == null ||
                      teNantModels_Cancel[index].sdate.toString() == '')
                  ? ''
                  : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${teNantModels_Cancel[index].sdate}'))}',
              // '${teNantModels_Cancel[index].sdate}'
            );
      }
      try {
        sheet.getRangeByName('L${index + 7}').cellStyle.numberFormat =
            'dd-MM-yyyy';
        sheet.getRangeByName('L${index + 7}').setValue(
              (teNantModels_Cancel[index].ldate == null ||
                      teNantModels_Cancel[index].ldate.toString() == '')
                  ? null
                  : DateTime.parse('${teNantModels_Cancel[index].ldate}'),
            );
      } catch (e) {
        sheet.getRangeByName('L${index + 7}').setText(
              (teNantModels_Cancel[index].ldate == null ||
                      teNantModels_Cancel[index].ldate.toString() == '')
                  ? ''
                  : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${teNantModels_Cancel[index].ldate}'))}',
              // '${teNantModels_Cancel[index].ldate}'
            );
      }

      sheet
          .getRangeByName('M${index + 7}')
          .setText('${teNantModels_Cancel[index].stype}');

      sheet.getRangeByName('N${index + 7}').setText(
          '${(teNantModels_Cancel[index].water_electri == null) ? '' : teNantModels_Cancel[index].water_electri.toString()}');
      try {
        sheet.getRangeByName('O${index + 7}').cellStyle.numberFormat =
            'dd-MM-yyyy';
        sheet.getRangeByName('O${index + 7}').setValue(
              (teNantModels_Cancel[index].cc_date == null ||
                      teNantModels_Cancel[index].cc_date.toString() == '')
                  ? null
                  : DateTime.parse('${teNantModels_Cancel[index].cc_date}'),
            );
      } catch (e) {
        sheet.getRangeByName('O${index + 7}').setText(
              (teNantModels_Cancel[index].cc_date == null ||
                      teNantModels_Cancel[index].cc_date.toString() == '')
                  ? ''
                  : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${teNantModels_Cancel[index].cc_date}'))}',
              // '${teNantModels_Cancel[index].cc_date}'
            );
      }

      if (teNantModels_Cancel[index].st.toString() == 'สัญญาปัจจุบัน') {
        sheet.getRangeByName('P${index + 7}').setText('');
      } else {
        try {
          sheet.getRangeByName('P${index + 7}').cellStyle.numberFormat =
              'dd-MM-yyyy';
          sheet.getRangeByName('P${index + 7}').setValue(
                (teNantModels_Cancel[index].cdate == null ||
                        teNantModels_Cancel[index].cdate.toString() == '')
                    ? null
                    : DateTime.parse('${teNantModels_Cancel[index].cdate}'),
              );
        } catch (e) {
          sheet.getRangeByName('P${index + 7}').setText(
                (teNantModels_Cancel[index].cdate == null ||
                        teNantModels_Cancel[index].cdate.toString() == '')
                    ? ''
                    : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${teNantModels_Cancel[index].cdate}'))}',
                // '${teNantModels_Cancel[index].cc_date}'
              );
        }
      }

      if (teNantModels_Cancel[index].st.toString() == 'สัญญาปัจจุบัน' ||
          teNantModels_Cancel[index].w1.toString() == '0000-00-00') {
        sheet.getRangeByName('Q${index + 7}').setText('');
      } else {
        if (teNantModels_Cancel[index].w1.toString() == '0000-00-00') {
          sheet.getRangeByName('Q${index + 7}').setText('');
        } else {
          try {
            sheet.getRangeByName('Q${index + 7}').cellStyle.numberFormat =
                'dd-MM-yyyy';
            sheet.getRangeByName('Q${index + 7}').setValue(
                  (teNantModels_Cancel[index].w1 == null ||
                          teNantModels_Cancel[index].w1.toString() == '')
                      ? null
                      : DateTime.parse('${teNantModels_Cancel[index].w1}'),
                );
          } catch (e) {
            sheet.getRangeByName('Q${index + 7}').setText(
                  (teNantModels_Cancel[index].w1 == null ||
                          teNantModels_Cancel[index].w1.toString() == '')
                      ? ''
                      : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${teNantModels_Cancel[index].w1}'))}',
                  // '${teNantModels_Cancel[index].cc_date}'
                );
          }
        }
      }

      sheet.getRangeByName('R${index + 7}').setNumber(
            (teNantModels_Cancel[index].pakan_total == null)
                ? 0.00
                : double.parse('${teNantModels_Cancel[index].pakan_total}'),
          );

      try {
        sheet.getRangeByName('S${index + 7}').cellStyle.numberFormat =
            'dd-MM-yyyy';
        sheet.getRangeByName('SR${index + 7}').setValue(
              (teNantModels_Cancel[index].min_pdate == null ||
                      teNantModels_Cancel[index].min_pdate.toString() == '')
                  ? null
                  : DateTime.parse('${teNantModels_Cancel[index].min_pdate}'),
            );
      } catch (e) {
        sheet.getRangeByName('S${index + 7}').setText(
              (teNantModels_Cancel[index].min_pdate == null ||
                      teNantModels_Cancel[index].min_pdate.toString() == '')
                  ? ''
                  : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${teNantModels_Cancel[index].min_pdate}'))}',
              // (teNantModels_Cancel[index].min_pdate == null)
              //     ? ''
              //     : '${teNantModels_Cancel[index].min_pdate}'
            );
      }

      sheet.getRangeByName('T${index + 7}').setText(
          (teNantModels_Cancel[index].min_doctax == null &&
                  teNantModels_Cancel[index].min_docno == null)
              ? ''
              : (teNantModels_Cancel[index].min_doctax == null ||
                      teNantModels_Cancel[index].min_doctax.toString() == '')
                  ? '${teNantModels_Cancel[index].min_docno}'
                  : '${teNantModels_Cancel[index].min_doctax}');

      sheet.getRangeByName('U${index + 7}').setNumber(
          (teNantModels_Cancel[index].pakan_pvat == null)
              ? 0.00
              : double.parse('${teNantModels_Cancel[index].pakan_pvat}'));

      sheet.getRangeByName('V${index + 7}').setNumber(
          (teNantModels_Cancel[index].land_pvat == null)
              ? 0.00
              : double.parse('${teNantModels_Cancel[index].land_pvat}'));

      sheet.getRangeByName('W${index + 7}').setNumber(
          (teNantModels_Cancel[index].rent_pvat == null)
              ? 0.00
              : double.parse('${teNantModels_Cancel[index].rent_pvat}'));

      ///---

      sheet.getRangeByName('X${index + 7}').setNumber(
          (teNantModels_Cancel[index].service_pvat == null)
              ? 0.00
              : double.parse('${teNantModels_Cancel[index].service_pvat}'));

      sheet.getRangeByName('Y${index + 7}').setNumber(
          (teNantModels_Cancel[index].water == null)
              ? 0.00
              : double.parse('${teNantModels_Cancel[index].water}'));
      sheet.getRangeByName('Z${index + 7}').setNumber(
          (teNantModels_Cancel[index].electricity == null)
              ? 0.00
              : double.parse('${teNantModels_Cancel[index].electricity}'));

      sheet.getRangeByName('AA${index + 7}').setNumber(
          (teNantModels_Cancel[index].fine == null)
              ? 0.00
              : double.parse('${teNantModels_Cancel[index].fine}'));
      sheet
          .getRangeByName('AB${index + 7}')
          .setFormula('=SUM(V${index + 7}:AA${index + 7})'
              // '=SUM(U${index + 7})-SUM(V${index + 7}:AA${index + 7})'

              );
      // sheet
      //     .getRangeByName('AB${index + 7}')
      //     .setFormula('=SUM(U${index + 7}:Z${index + 7})');

      // sheet.getRangeByName('W${index + 7}').setNumber(
      //     (teNantModels_Cancel[index].total_bill == null)
      //         ? 0.00
      //         : double.parse('${teNantModels_Cancel[index].total_bill}'));

      sheet.getRangeByName('AC${index + 7}').setNumber(0.00
          // (teNantModels_Cancel[index].total_pay == null)
          //     ? 0.00
          //     : double.parse('${teNantModels_Cancel[index].total_pay}')
          );
      sheet.getRangeByName('AD${index + 7}').setText('');
      // try {
      //   sheet.getRangeByName('AC${index + 7}').cellStyle.numberFormat =
      //       'dd-MM-yyyy';
      //   sheet.getRangeByName('AC${index + 7}').setValue(
      //         (teNantModels_Cancel[index].pdate == null ||
      //                 teNantModels_Cancel[index].pdate.toString() == '')
      //             ? null
      //             : DateTime.parse('${teNantModels_Cancel[index].pdate}'),
      //       );
      // } catch (e) {
      //   sheet.getRangeByName('AC${index + 7}').setText(
      //         (teNantModels_Cancel[index].pdate == null ||
      //                 teNantModels_Cancel[index].pdate.toString() == '')
      //             ? ''
      //             : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${teNantModels_Cancel[index].pdate}'))}',
      //         // (teNantModels_Cancel[index].pdate == null)
      //         //     ? ''
      //         //     : '${teNantModels_Cancel[index].pdate}'
      //       );
      // }

      sheet.getRangeByName('AE${index + 7}').setNumber(0.00
          // (teNantModels_Cancel[index].total_bill == null)
          //     ? 0.00
          //     : double.parse('${teNantModels_Cancel[index].total_bill}')
          );

      sheet.getRangeByName('AF${index + 7}').setNumber(0.00
          // (teNantModels_Cancel[index].total_bill == null)
          //     ? 0.00 - double.parse('${teNantModels_Cancel[index].pakan_pvat}')
          //     : double.parse('${teNantModels_Cancel[index].total_bill}') -
          //         double.parse('${teNantModels_Cancel[index].pakan_pvat}')
          );

      sheet
          .getRangeByName('AG${index + 7}')
          .setText('${teNantModels_Cancel[index].name_user}');
      sheet
          .getRangeByName('AH${index + 7}')
          .setText('${teNantModels_Cancel[index].cc_remark}');
      sheet.getRangeByName('AI${index + 7}').setText(
          (teNantModels_Cancel[index].inv == null)
              ? ''
              : '${teNantModels_Cancel[index].inv}');
      sheet.getRangeByName('AJ${index + 7}').setText(
          (teNantModels_Cancel[index].wnote == null)
              ? ''
              : '${teNantModels_Cancel[index].wnote}');
      sheet
          .getRangeByName('AK${index + 7}')
          .setText((teNantModels_Cancel[index].st == null)
              ? ''
              : (teNantModels_Cancel[index].st.toString() == 'สัญญาปัจจุบัน')
                  ? 'รอดำเนินการยกเลิกสัญญา'
                  : '${teNantModels_Cancel[index].st}');
      indextotol = indextotol + 1;
    }
/////////---------------------------->
    sheet.getRangeByName('Q${indextotol + 7 + 0}').setText('รวมทั้งหมด: ');
    sheet
        .getRangeByName('R${indextotol + 7 + 0}')
        .setFormula('=SUM(R3:R${indextotol + 7 - 1})');
    sheet
        .getRangeByName('U${indextotol + 7 + 0}')
        .setFormula('=SUM(U3:U${indextotol + 7 - 1})');
    sheet
        .getRangeByName('V${indextotol + 7 + 0}')
        .setFormula('=SUM(V3:V${indextotol + 7 - 1})');
    sheet
        .getRangeByName('W${indextotol + 7 + 0}')
        .setFormula('=SUM(W3:W${indextotol + 7 - 1})');
    sheet
        .getRangeByName('X${indextotol + 7 + 0}')
        .setFormula('=SUM(X3:X${indextotol + 7 - 1})');
    sheet
        .getRangeByName('Y${indextotol + 7 + 0}')
        .setFormula('=SUM(Y3:Y${indextotol + 7 - 1})');
    sheet
        .getRangeByName('Z${indextotol + 7 + 0}')
        .setFormula('=SUM(Z3:Z${indextotol + 7 - 1})');
    sheet
        .getRangeByName('AA${indextotol + 7 + 0}')
        .setFormula('=SUM(AA3:AA${indextotol + 7 - 1})');
    sheet
        .getRangeByName('AB${indextotol + 7 + 0}')
        .setFormula('=SUM(AB3:AB${indextotol + 7 - 1})');
    sheet
        .getRangeByName('AC${indextotol + 7 + 0}')
        .setFormula('=SUM(AC3:AC${indextotol + 7 - 1})');
    sheet
        .getRangeByName('AE${indextotol + 7 + 0}')
        .setFormula('=SUM(AE3:AE${indextotol + 7 - 1})');
    sheet
        .getRangeByName('AF${indextotol + 7 + 0}')
        .setFormula('=SUM(AF3:AF${indextotol + 7 - 1})');

    sheet.getRangeByName('Q${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet.getRangeByName('R${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet.getRangeByName('S${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet.getRangeByName('T${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet.getRangeByName('U${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet.getRangeByName('V${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet.getRangeByName('W${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet.getRangeByName('X${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet.getRangeByName('Y${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet.getRangeByName('Z${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet.getRangeByName('AA${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet.getRangeByName('AB${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet.getRangeByName('AC${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet.getRangeByName('AD${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet.getRangeByName('AE${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet.getRangeByName('AF${indextotol + 7 + 0}').cellStyle = globalStyle7;
/////////---------------------------->
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    Uint8List data = Uint8List.fromList(bytes);
    MimeType type = MimeType.MICROSOFTEXCEL;
    String path = await FileSaver.instance.saveFile(
        (Value_Chang_Zone_People_Cancel == null)
            ? '$namereport ประจำเดือน ${Mon_PeopleCancel_Mon} ${YE_PeopleCancel_Mon}'
            : '$namereport ประจำเดือน ${Mon_PeopleCancel_Mon} ${YE_PeopleCancel_Mon}',
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
