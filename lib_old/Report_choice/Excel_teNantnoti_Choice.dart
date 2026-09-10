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

class Excgen_teNantnoti_Report_Choice {
  static void exportExcel_teNantnoti_Report_Choice(
      context,
      renTal_name,
      teNantModels_noti,
      zone_name_Cannotice_Mon,
      YE_Cannotice_Mon,
      Mon_Cannotice_Mon) async {
    final x.Workbook workbook = x.Workbook();

    final x.Worksheet sheet = workbook.worksheets[0];
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

    sheet.getRangeByName('A1').setText(
          (zone_name_Cannotice_Mon == null)
              ? 'รายงานยกเลิกสัญญาผู้เช่าล่วงหน้า  (กรุณาเลือกโซน)'
              : 'รายงานยกเลิกสัญญาผู้เช่าล่วงหน้า  (โซน : $zone_name_Cannotice_Mon)',
        );
    sheet
        .getRangeByName('A2')
        .setText('เดือน ${Mon_Cannotice_Mon} ${YE_Cannotice_Mon}');
    sheet.getRangeByName('A3').setText(
        'ชื่อสถานประกอบการ บริษัท ชอยส์มินิสโตร์ จำกัด เลขประจำตัวผู้เสียภาษี 0-1055-31085-43-4');
    sheet.getRangeByName('A4').setText('ชื่อสถานประกอบการ เซเว่นอีเลฟเว่น');
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
      sheet.getRangeByName('N${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('O${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('P${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('Q${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('R${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('S${index + 1}').cellStyle = globalStyle220;
      sheet.getRangeByName('T${index + 1}').cellStyle = globalStyle220;
    }

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
    sheet.getRangeByName('N4').columnWidth = 18;

    sheet.getRangeByName('O4').columnWidth = 18;
    sheet.getRangeByName('P4').columnWidth = 18;
    sheet.getRangeByName('Q4').columnWidth = 18;
    sheet.getRangeByName('R4').columnWidth = 18;
    sheet.getRangeByName('S4').columnWidth = 18;
    sheet.getRangeByName('T4').columnWidth = 18;
    // sheet.getRangeByName('U4').columnWidth = 18;
    // sheet.getRangeByName('V4').columnWidth = 18;
    // sheet.getRangeByName('O4').columnWidth = 18;

    sheet.getRangeByName('A6').setText('ลำดับ');
    sheet.getRangeByName('B6').setText('เลขที่สัญญา');
    sheet.getRangeByName('C6').setText('เลขที่สัญญาเดิม');
    sheet.getRangeByName('D6').setText('ชื่อร้านค้า/บริษัท');
    sheet.getRangeByName('E6').setText('ชื่อผู้ติดต่อ');
    sheet.getRangeByName('F6').setText('รหัสสาขา');
    sheet.getRangeByName('G6').setText('โซนพื้นที่');
    sheet.getRangeByName('H6').setText('รหัสพื้นที่');
    sheet.getRangeByName('I6').setText('ประเภท');
    sheet.getRangeByName('J6').setText('กำหนดยกเลิกล่วงหน้า');
    sheet.getRangeByName('K6').setText('วันเริ่มสัญญา');
    sheet.getRangeByName('L6').setText('วันสิ้นสุดสัญญา');
    sheet.getRangeByName('M6').setText('ใบเสร็จเงินประกัน');
    sheet.getRangeByName('N6').setText('เงินประกัน(ก่อน VAT)');
    sheet.getRangeByName('O6').setText('เงินประกัน(VAT)');
    sheet.getRangeByName('P6').setText('เงินประกันทั้งหมด(+VAT)');
    sheet.getRangeByName('Q6').setText('เหตุผล');
    sheet.getRangeByName('R6').setText('สถานะ');
    sheet.getRangeByName('S6').setText('ผู้ดูแล');
    sheet.getRangeByName('T6').setText('อ้างอิง');
    // sheet.getRangeByName('M4').setText('รหัสโซนพื้นที่');
    // sheet.getRangeByName('L4').setText('ราคาก่อน Vat');
    // sheet.getRangeByName('M4').setText('ราคารวม Vat');
    // sheet.getRangeByName('N4').setText('ส่วนลด');
    int indextotol = 0;
    for (var index = 0; index < teNantModels_noti.length; index++) {
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

      // sheet
      //     .getRangeByName('I${indextotol + 5 - 1}:K${indextotol + 5 - 1}')
      //     .merge();
      sheet.getRangeByName('A${index + 7}').setText(
            '${index + 1}',
          );
      sheet.getRangeByName('B${index + 7}').setText(
            '${teNantModels_noti[index].cid}',
          );
      sheet.getRangeByName('C${index + 7}').setText(
            '${teNantModels_noti[index].renew_cid}',
          );
      sheet.getRangeByName('D${index + 7}').setText(
            '${teNantModels_noti[index].sname}',
          );
      sheet.getRangeByName('E${index + 7}').setText(
            '${teNantModels_noti[index].cname}',
          );
      sheet.getRangeByName('F${index + 7}').setText(
            (teNantModels_noti[index].zn!.split('_')[0].length <= 4)
                ? 'CMN0${teNantModels_noti[index].zn!.split('_')[0]}'
                : 'CMN${teNantModels_noti[index].zn!.split('_')[0]}',
          );

      sheet.getRangeByName('G${index + 7}').setText(
            '${teNantModels_noti[index].zn}',
          );
      sheet.getRangeByName('H${index + 7}').setText(
            '${teNantModels_noti[index].ln}',
          );
      sheet.getRangeByName('I${index + 7}').setText(
            '${teNantModels_noti[index].rtname}',
          );
      // sheet.getRangeByName('J${index + 7}').cellStyle.numberFormat =
      //     'dd-MM-yyyy';
      // sheet.getRangeByName('K${index + 7}').cellStyle.numberFormat =
      //     'dd-MM-yyyy';
      // sheet.getRangeByName('L${index + 7}').cellStyle.numberFormat =
      //     'dd-MM-yyyy';
      try {
        sheet.getRangeByName('J${index + 7}').cellStyle.numberFormat =
            'dd-MM-yyyy';
        sheet.getRangeByName('J${index + 7}').setValue(
              (teNantModels_noti[index].cc_date == null)
                  ? null
                  : DateTime.parse(
                      '${teNantModels_noti[index].cc_date} 00:00:00'),
            );
      } catch (e) {
        sheet.getRangeByName('J${index + 7}').setText(
              (teNantModels_noti[index].cc_date == null)
                  ? '${teNantModels_noti[index].cc_date}'
                  : '${DateFormat('dd-MM').format(DateTime.parse('${teNantModels_noti[index].cc_date} 00:00:00'))}-${DateTime.parse('${teNantModels_noti[index].cc_date} 00:00:00').year + 0}',
            );
      }
      try {
        sheet.getRangeByName('K${index + 7}').cellStyle.numberFormat =
            'dd-MM-yyyy';
        sheet.getRangeByName('K${index + 7}').setValue(
              (teNantModels_noti[index].sdate == null)
                  ? null
                  : DateTime.parse(
                      '${teNantModels_noti[index].sdate} 00:00:00'),
            );
      } catch (e) {
        sheet.getRangeByName('K${index + 7}').setText(
              (teNantModels_noti[index].sdate == null)
                  ? '${teNantModels_noti[index].sdate}'
                  : '${DateFormat('dd-MM').format(DateTime.parse('${teNantModels_noti[index].sdate} 00:00:00'))}-${DateTime.parse('${teNantModels_noti[index].sdate} 00:00:00').year + 0}',
            );
      }
      try {
        sheet.getRangeByName('L${index + 7}').cellStyle.numberFormat =
            'dd-MM-yyyy';
        sheet.getRangeByName('L${index + 7}').setValue(
              (teNantModels_noti[index].ldate == null)
                  ? null
                  : DateTime.parse(
                      '${teNantModels_noti[index].ldate} 00:00:00'),
            );
      } catch (e) {
        sheet.getRangeByName('L${index + 7}').setText(
              (teNantModels_noti[index].ldate == null)
                  ? '${teNantModels_noti[index].ldate}'
                  : '${DateFormat('dd-MM').format(DateTime.parse('${teNantModels_noti[index].ldate} 00:00:00'))}-${DateTime.parse('${teNantModels_noti[index].ldate} 00:00:00').year + 0}',
            );
      }

      sheet.getRangeByName('M${index + 7}').setText(
            (teNantModels_noti[index].pakan_pvat == null ||
                    teNantModels_noti[index].pakan_pvat.toString() == 'null')
                ? ''
                : '${teNantModels_noti[index].min_docno}',
          );
      sheet.getRangeByName('N${index + 7}').setNumber(
            (teNantModels_noti[index].pakan_pvat == null)
                ? 0.00
                : double.parse('${teNantModels_noti[index].pakan_pvat}'),
          );
      sheet.getRangeByName('O${index + 7}').setNumber(
            (teNantModels_noti[index].pakan_vat == null)
                ? 0.00
                : double.parse('${teNantModels_noti[index].pakan_vat}'),
          );
      sheet.getRangeByName('P${index + 7}').setNumber(
            (teNantModels_noti[index].pakan_total == null)
                ? 0.00
                : double.parse('${teNantModels_noti[index].pakan_total}'),
          );
      sheet
          .getRangeByName('Q${index + 7}')
          .setText('${teNantModels_noti[index].cc_remark}');
      sheet
          .getRangeByName('R${index + 7}')
          .setText('${teNantModels_noti[index].st}');
      sheet
          .getRangeByName('S${index + 7}')
          .setText('${teNantModels_noti[index].name_user}');
      sheet
          .getRangeByName('T${index + 7}')
          .setText('${teNantModels_noti[index].wnote}');
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    Uint8List data = Uint8List.fromList(bytes);
    MimeType type = MimeType.MICROSOFTEXCEL;
    String path = await FileSaver.instance.saveFile(
        "รายงานยกเลิกสัญญาผู้เช่าล่วงหน้า (เดือน${Mon_Cannotice_Mon}(${YE_Cannotice_Mon})",
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
