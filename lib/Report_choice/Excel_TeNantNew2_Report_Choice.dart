import 'dart:convert';
import 'dart:typed_data';
import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:excel/excel.dart';
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

//////////รายงานผู้เช่ารายใหม่
class Excgen_TeNantNew2Report_Choice {
  static void exportExcel_TeNantNew2Report_Choice(
      context,
      NameFile_,
      _verticalGroupValue_NameFile,
      renTal_name,
      Value_Chang_Zone_People_TeNantNew,
      teNantModels_New,
      Mon_PeopleTeNantNew_Mon,
      YE_PeopleTeNantNew_Mon,
      expModels) async {
    var nFormat = NumberFormat("#,##0.00", "en_US");
    var nFormat2 = NumberFormat("###0.00", "en_US");
    DateTime datex = DateTime.now();
    String day_ =
        '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}'; //// GC_billPay_SalesTaxFullReport_ _Choice

    String Tim_ =
        '${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}';
    final x.Workbook workbook = x.Workbook(4);

    final x.Worksheet sheet1 = workbook.worksheets[0];
    final x.Worksheet sheet2 = workbook.worksheets[1];
    final x.Worksheet sheet3 = workbook.worksheets[2];
    final x.Worksheet sheet4 = workbook.worksheets[3];
    // final x.Worksheet sheet4 = workbook.worksheets[3];
    // final x.Worksheet sheet5 = workbook.worksheets[4];
    // final x.Worksheet sheet6 = workbook.worksheets[5];

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
    sheet1.name = 'ปะหน้าใบเสร็จ_รายงานผู้เช่ารายใหม่2';
    // sheet2.name = 'งปก.(รายงานผู้เช่ารายใหม่-2)';
    // sheet3.name = 'เช่า 06.67';
    // sheet4.name = 'เช่า07.67 ';
    sheet2.name = 'ค่าเช่า_ค่าบริการ_ค่าเช่าพื้นที่ดิน';
    sheet3.name = 'ผ้ากันเปื้อน';
    sheet4.name = 'เงินประกัน';
    //////////--------------------------->
    sheet1.pageSetup.topMargin = 1;
    sheet1.pageSetup.bottomMargin = 1;
    sheet1.pageSetup.leftMargin = 1;
    sheet1.pageSetup.rightMargin = 1;
    //////////--------------------------->
    sheet2.pageSetup.topMargin = 1;
    sheet2.pageSetup.bottomMargin = 1;
    sheet2.pageSetup.leftMargin = 1;
    sheet2.pageSetup.rightMargin = 1;
    //////////--------------------------->
    sheet3.pageSetup.topMargin = 1;
    sheet3.pageSetup.bottomMargin = 1;
    sheet3.pageSetup.leftMargin = 1;
    sheet3.pageSetup.rightMargin = 1;
    //////////--------------------------->
    // sheet4.pageSetup.topMargin = 1;
    // sheet4.pageSetup.bottomMargin = 1;
    // sheet4.pageSetup.leftMargin = 1;
    // sheet4.pageSetup.rightMargin = 1;
    // //////////--------------------------->
    // sheet5.pageSetup.topMargin = 1;
    // sheet5.pageSetup.bottomMargin = 1;
    // sheet5.pageSetup.leftMargin = 1;
    // sheet5.pageSetup.rightMargin = 1;
    // //////////--------------------------->
    // sheet6.pageSetup.topMargin = 1;
    // sheet6.pageSetup.bottomMargin = 1;
    // sheet6.pageSetup.leftMargin = 1;
    // sheet6.pageSetup.rightMargin = 1;
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
/////////--------------------------------------------->
    sheet1.getRangeByName('A1:I1').merge();
    sheet1.getRangeByName('A1:K1').merge();
    sheet1.getRangeByName('A2:K2').merge();
    sheet1.getRangeByName('A3:K3').merge();
    sheet1.getRangeByName('A4:K4').merge();

    sheet2.getRangeByName('A1:K1').merge();
    sheet2.getRangeByName('A2:K2').merge();
    sheet2.getRangeByName('A3:K3').merge();
    sheet2.getRangeByName('A4:K4').merge();

    sheet3.getRangeByName('A1:I1').merge();
    sheet3.getRangeByName('A2:I2').merge();
    sheet3.getRangeByName('A3:I3').merge();
    sheet3.getRangeByName('A4:I4').merge();

    sheet4.getRangeByName('A1:K1').merge();
    sheet4.getRangeByName('A2:K2').merge();
    sheet4.getRangeByName('A3:K3').merge();
    sheet4.getRangeByName('A4:K4').merge();

    // sheet5.getRangeByName('A1:K1').merge();
    // sheet5.getRangeByName('A2:K2').merge();
    // sheet5.getRangeByName('A3:K3').merge();
    // sheet5.getRangeByName('A4:K4').merge();

    // sheet6.getRangeByName('A1:K1').merge();
    // sheet6.getRangeByName('A2:K2').merge();
    // sheet6.getRangeByName('A3:K3').merge();
    // sheet6.getRangeByName('A4:K4').merge();

    sheet1.getRangeByName('A1').setText(
          (Value_Chang_Zone_People_TeNantNew == null)
              ? 'รายงานผู้เช่ารายใหม่-2  (กรุณาเลือกโซน)'
              : 'รายงานผู้เช่ารายใหม่-2  (โซน : $Value_Chang_Zone_People_TeNantNew)',
        );
    sheet2.getRangeByName('A1').setText(
          (Value_Chang_Zone_People_TeNantNew == null)
              ? 'รายงานผู้เช่ารายใหม่-2  (กรุณาเลือกโซน)'
              : 'รายงานผู้เช่ารายใหม่-2  (โซน : $Value_Chang_Zone_People_TeNantNew)',
        );
    sheet3.getRangeByName('A1').setText(
          (Value_Chang_Zone_People_TeNantNew == null)
              ? 'รายงานผู้เช่ารายใหม่-2  (กรุณาเลือกโซน)'
              : 'รายงานผู้เช่ารายใหม่-2  (โซน : $Value_Chang_Zone_People_TeNantNew)',
        );
    sheet4.getRangeByName('A1').setText(
          (Value_Chang_Zone_People_TeNantNew == null)
              ? 'รายงานผู้เช่ารายใหม่-2  (กรุณาเลือกโซน)'
              : 'รายงานผู้เช่ารายใหม่-2  (โซน : $Value_Chang_Zone_People_TeNantNew)',
        );
    // sheet4.getRangeByName('A1').setText(
    //       (Value_Chang_Zone_People_TeNantNew == null)
    //           ? 'รายงานผู้เช่ารายใหม่-2  (กรุณาเลือกโซน)'
    //           : 'รายงานผู้เช่ารายใหม่-2  (โซน : $Value_Chang_Zone_People_TeNantNew)',
    //     );
    // sheet5.getRangeByName('A1').setText(
    //       (Value_Chang_Zone_People_TeNantNew == null)
    //           ? 'รายงานผู้เช่ารายใหม่-2  (กรุณาเลือกโซน)'
    //           : 'รายงานผู้เช่ารายใหม่-2  (โซน : $Value_Chang_Zone_People_TeNantNew)',
    //     );
    // sheet6.getRangeByName('A1').setText(
    //       (Value_Chang_Zone_People_TeNantNew == null)
    //           ? 'รายงานผู้เช่ารายใหม่-2  (กรุณาเลือกโซน)'
    //           : 'รายงานผู้เช่ารายใหม่-2  (โซน : $Value_Chang_Zone_People_TeNantNew)',
    //     );

    sheet1
        .getRangeByName('A2')
        .setText('เดือน ${Mon_PeopleTeNantNew_Mon} ${YE_PeopleTeNantNew_Mon}');
    sheet2
        .getRangeByName('A2')
        .setText('เดือน ${Mon_PeopleTeNantNew_Mon} ${YE_PeopleTeNantNew_Mon}');
    sheet3
        .getRangeByName('A2')
        .setText('เดือน ${Mon_PeopleTeNantNew_Mon} ${YE_PeopleTeNantNew_Mon}');
    sheet4
        .getRangeByName('A2')
        .setText('เดือน ${Mon_PeopleTeNantNew_Mon} ${YE_PeopleTeNantNew_Mon}');
    // sheet5
    //     .getRangeByName('A2')
    //     .setText('เดือน ${Mon_PeopleTeNantNew_Mon} ${YE_PeopleTeNantNew_Mon}');
    // sheet6
    //     .getRangeByName('A2')
    //     .setText('เดือน ${Mon_PeopleTeNantNew_Mon} ${YE_PeopleTeNantNew_Mon}');
    sheet1.getRangeByName('A3').setText(
        'ชื่อสถานประกอบการ บริษัท ชอยส์มินิสโตร์ จำกัด เลขประจำตัวผู้เสียภาษี 0-1055-31085-43-4');
    sheet2.getRangeByName('A3').setText(
        'ชื่อสถานประกอบการ บริษัท ชอยส์มินิสโตร์ จำกัด เลขประจำตัวผู้เสียภาษี 0-1055-31085-43-4');
    sheet3.getRangeByName('A3').setText(
        'ชื่อสถานประกอบการ บริษัท ชอยส์มินิสโตร์ จำกัด เลขประจำตัวผู้เสียภาษี 0-1055-31085-43-4');
    sheet4.getRangeByName('A3').setText(
        'ชื่อสถานประกอบการ บริษัท ชอยส์มินิสโตร์ จำกัด เลขประจำตัวผู้เสียภาษี 0-1055-31085-43-4');
    // sheet5.getRangeByName('A3').setText(
    //     'ชื่อสถานประกอบการ บริษัท ชอยส์มินิสโตร์ จำกัด เลขประจำตัวผู้เสียภาษี 0-1055-31085-43-4');
    // sheet6.getRangeByName('A3').setText(
    //     'ชื่อสถานประกอบการ บริษัท ชอยส์มินิสโตร์ จำกัด เลขประจำตัวผู้เสียภาษี 0-1055-31085-43-4');
    sheet1.getRangeByName('A4').setText('ชื่อสถานประกอบการ เซเว่นอีเลฟเว่น');
    sheet2.getRangeByName('A4').setText('ชื่อสถานประกอบการ เซเว่นอีเลฟเว่น');
    sheet3.getRangeByName('A4').setText('ชื่อสถานประกอบการ เซเว่นอีเลฟเว่น');
    sheet4.getRangeByName('A4').setText('ชื่อสถานประกอบการ เซเว่นอีเลฟเว่น');
    // sheet5.getRangeByName('A4').setText('ชื่อสถานประกอบการ เซเว่นอีเลฟเว่น');
    // sheet6.getRangeByName('A4').setText('ชื่อสถานประกอบการ เซเว่นอีเลฟเว่น');
    sheet1.getRangeByName('A5').setText('ทั้งหมด :${teNantModels_New.length}');
    sheet1.getRangeByName('H5').setText('อัพเดต ณ :${DateTime.now()}');
/////////--------------------------------------------->
// ExcelSheetProtectionOption
    final x.ExcelSheetProtectionOption options = x.ExcelSheetProtectionOption();
    options.all = true;
    int columns_now = int.parse('${expModels.length}') * 3;
// Protecting the Worksheet by using a Password
    for (int index = 0; index < 6; index++) {
      ////
      sheet1.getRangeByName('A${index + 1}').cellStyle = globalStyle220;
      sheet1.getRangeByName('B${index + 1}').cellStyle = globalStyle220;
      sheet1.getRangeByName('C${index + 1}').cellStyle = globalStyle220;
      sheet1.getRangeByName('D${index + 1}').cellStyle = globalStyle220;
      sheet1.getRangeByName('E${index + 1}').cellStyle = globalStyle220;
      sheet1.getRangeByName('F${index + 1}').cellStyle = globalStyle220;
      sheet1.getRangeByName('G${index + 1}').cellStyle = globalStyle220;
      sheet1.getRangeByName('H${index + 1}').cellStyle = globalStyle220;
      sheet1.getRangeByName('I${index + 1}').cellStyle = globalStyle220;

      sheet1.getRangeByName('J${index + 1}').cellStyle = globalStyle220;
      sheet1.getRangeByName('K${index + 1}').cellStyle = globalStyle220;
      sheet1.getRangeByName('L${index + 1}').cellStyle = globalStyle220;
      sheet1.getRangeByName('M${index + 1}').cellStyle = globalStyle220;
      sheet1.getRangeByName('N${index + 1}').cellStyle = globalStyle220;
      sheet1.getRangeByName('O${index + 1}').cellStyle = globalStyle220;
      sheet1.getRangeByName('P${index + 1}').cellStyle = globalStyle220;
      sheet1.getRangeByName('Q${index + 1}').cellStyle = globalStyle220;
      sheet1.getRangeByName('R${index + 1}').cellStyle = globalStyle220;
      sheet1.getRangeByName('S${index + 1}').cellStyle = globalStyle220;
      sheet1.getRangeByName('T${index + 1}').cellStyle = globalStyle220;
      sheet1.getRangeByName('U${index + 1}').cellStyle = globalStyle220;
      sheet1.getRangeByName('V${index + 1}').cellStyle = globalStyle220;
      /////////---------->
      int xx_count_1 = 0;
      for (int i = 0; i < expModels.length; i++) {
        for (int x = 0; x < 3; x++) {
          xx_count_1 = xx_count_1 + 1;
          sheet1
              .getRangeByName('${columns[21 + xx_count_1]}${index + 1}')
              .cellStyle = globalStyle220;
        }
      }
      /////////---------->
      for (int i2 = 0; i2 < 11; i2++) {
        sheet1
            .getRangeByName('${columns[(22 + i2) + columns_now]}${index + 1}')
            .cellStyle = globalStyle220;
      }

      ///////////////-------------------------->

      sheet2.getRangeByName('A${index + 1}').cellStyle = globalStyle220;
      sheet2.getRangeByName('B${index + 1}').cellStyle = globalStyle220;
      sheet2.getRangeByName('C${index + 1}').cellStyle = globalStyle220;
      sheet2.getRangeByName('D${index + 1}').cellStyle = globalStyle220;
      sheet2.getRangeByName('E${index + 1}').cellStyle = globalStyle220;
      sheet2.getRangeByName('F${index + 1}').cellStyle = globalStyle220;
      sheet2.getRangeByName('G${index + 1}').cellStyle = globalStyle220;
      sheet2.getRangeByName('H${index + 1}').cellStyle = globalStyle220;
      sheet2.getRangeByName('I${index + 1}').cellStyle = globalStyle220;

      sheet2.getRangeByName('J${index + 1}').cellStyle = globalStyle220;
      sheet2.getRangeByName('K${index + 1}').cellStyle = globalStyle220;
      sheet2.getRangeByName('L${index + 1}').cellStyle = globalStyle220;
      sheet2.getRangeByName('M${index + 1}').cellStyle = globalStyle220;
      sheet2.getRangeByName('N${index + 1}').cellStyle = globalStyle220;
      sheet2.getRangeByName('O${index + 1}').cellStyle = globalStyle220;

      ///////////////-------------------------->

      sheet3.getRangeByName('A${index + 1}').cellStyle = globalStyle220;
      sheet3.getRangeByName('B${index + 1}').cellStyle = globalStyle220;
      sheet3.getRangeByName('C${index + 1}').cellStyle = globalStyle220;
      sheet3.getRangeByName('D${index + 1}').cellStyle = globalStyle220;
      sheet3.getRangeByName('E${index + 1}').cellStyle = globalStyle220;
      sheet3.getRangeByName('F${index + 1}').cellStyle = globalStyle220;
      sheet3.getRangeByName('G${index + 1}').cellStyle = globalStyle220;
      sheet3.getRangeByName('H${index + 1}').cellStyle = globalStyle220;
      sheet3.getRangeByName('I${index + 1}').cellStyle = globalStyle220;
      sheet3.getRangeByName('J${index + 1}').cellStyle = globalStyle220;
      sheet3.getRangeByName('K${index + 1}').cellStyle = globalStyle220;

      ///////////////-------------------------->

      sheet4.getRangeByName('A${index + 1}').cellStyle = globalStyle220;
      sheet4.getRangeByName('B${index + 1}').cellStyle = globalStyle220;
      sheet4.getRangeByName('C${index + 1}').cellStyle = globalStyle220;
      sheet4.getRangeByName('D${index + 1}').cellStyle = globalStyle220;
      sheet4.getRangeByName('E${index + 1}').cellStyle = globalStyle220;
      sheet4.getRangeByName('F${index + 1}').cellStyle = globalStyle220;
      sheet4.getRangeByName('G${index + 1}').cellStyle = globalStyle220;
      sheet4.getRangeByName('H${index + 1}').cellStyle = globalStyle220;
      sheet4.getRangeByName('I${index + 1}').cellStyle = globalStyle220;
      sheet4.getRangeByName('J${index + 1}').cellStyle = globalStyle220;
      sheet4.getRangeByName('L${index + 1}').cellStyle = globalStyle220;
      // ///////////////-------------------------->

      // sheet5.getRangeByName('A${index + 1}').cellStyle = globalStyle220;
      // sheet5.getRangeByName('B${index + 1}').cellStyle = globalStyle220;
      // sheet5.getRangeByName('C${index + 1}').cellStyle = globalStyle220;
      // sheet5.getRangeByName('D${index + 1}').cellStyle = globalStyle220;
      // sheet5.getRangeByName('E${index + 1}').cellStyle = globalStyle220;
      // sheet5.getRangeByName('F${index + 1}').cellStyle = globalStyle220;
      // sheet5.getRangeByName('G${index + 1}').cellStyle = globalStyle220;
      // sheet5.getRangeByName('H${index + 1}').cellStyle = globalStyle220;
      // sheet5.getRangeByName('I${index + 1}').cellStyle = globalStyle220;

      // ///////////////-------------------------->

      // sheet6.getRangeByName('A${index + 1}').cellStyle = globalStyle220;
      // sheet6.getRangeByName('B${index + 1}').cellStyle = globalStyle220;
      // sheet6.getRangeByName('C${index + 1}').cellStyle = globalStyle220;
      // sheet6.getRangeByName('D${index + 1}').cellStyle = globalStyle220;
      // sheet6.getRangeByName('E${index + 1}').cellStyle = globalStyle220;
      // sheet6.getRangeByName('F${index + 1}').cellStyle = globalStyle220;
      // sheet6.getRangeByName('G${index + 1}').cellStyle = globalStyle220;
      // sheet6.getRangeByName('H${index + 1}').cellStyle = globalStyle220;
      // sheet5.getRangeByName('I${index + 1}').cellStyle = globalStyle220;
    }

    globalStyle2.hAlign = x.HAlignType.center;
    sheet1.getRangeByName('A6').cellStyle = globalStyle1;
    sheet1.getRangeByName('B6').cellStyle = globalStyle1;
    sheet1.getRangeByName('C6').cellStyle = globalStyle1;
    sheet1.getRangeByName('D6').cellStyle = globalStyle1;
    sheet1.getRangeByName('E6').cellStyle = globalStyle1;
    sheet1.getRangeByName('F6').cellStyle = globalStyle1;
    sheet1.getRangeByName('G6').cellStyle = globalStyle1;
    sheet1.getRangeByName('H6').cellStyle = globalStyle1;
    sheet1.getRangeByName('I6').cellStyle = globalStyle1;
    sheet1.getRangeByName('J6').cellStyle = globalStyle1;
    sheet1.getRangeByName('K6').cellStyle = globalStyle1;
    sheet1.getRangeByName('L6').cellStyle = globalStyle1;
    sheet1.getRangeByName('M6').cellStyle = globalStyle1;
    sheet1.getRangeByName('N6').cellStyle = globalStyle1;
    sheet1.getRangeByName('O6').cellStyle = globalStyle1;
    sheet1.getRangeByName('P6').cellStyle = globalStyle1;
    sheet1.getRangeByName('Q6').cellStyle = globalStyle1;
    sheet1.getRangeByName('R6').cellStyle = globalStyle1;
    sheet1.getRangeByName('S6').cellStyle = globalStyle1;
    sheet1.getRangeByName('T6').cellStyle = globalStyle1;
    sheet1.getRangeByName('U6').cellStyle = globalStyle1;
    sheet1.getRangeByName('V6').cellStyle = globalStyle1;
    ////---------->
    int xx_count_2 = 0;
    for (int i = 0; i < expModels.length; i++) {
      for (int x = 0; x < 3; x++) {
        xx_count_2 = xx_count_2 + 1;
        sheet1.getRangeByName('${columns[21 + xx_count_2]}6').cellStyle =
            globalStyle1D;
        sheet1.getRangeByName('${columns[21 + xx_count_2]}6').columnWidth = 30;
      }
    }

    /////////---------->
    for (int i2 = 0; i2 < 11; i2++) {
      sheet1.getRangeByName('${columns[(22 + i2) + columns_now]}6').cellStyle =
          ((i2 + 1) > 7) ? globalStyle1 : globalStyle1;
    }

    ///////////////-------------------------->
    // sheet1.getRangeByName('S6').cellStyle = globalStyle1;
    // sheet1.getRangeByName('T6').cellStyle = globalStyle1;
    // sheet1.getRangeByName('U6').cellStyle = globalStyle1;
    // sheet1.getRangeByName('V6').cellStyle = globalStyle1;
    // sheet1.getRangeByName('W6').cellStyle = globalStyle1;
    // sheet1.getRangeByName('X6').cellStyle = globalStyle1;
    // sheet1.getRangeByName('Y6').cellStyle = globalStyle1;
    // sheet1.getRangeByName('Z6').cellStyle = globalStyle1;
    // sheet1.getRangeByName('AA6').cellStyle = globalStyle1;
    // sheet1.getRangeByName('AB6').cellStyle = globalStyle1;
    // sheet1.getRangeByName('AC6').cellStyle = globalStyle1;
    // sheet1.getRangeByName('AD6').cellStyle = globalStyle1;
    // sheet1.getRangeByName('AE6').cellStyle = globalStyle1;

    // sheet1.getRangeByName('AF6').cellStyle = globalStyle2220;
    // sheet1.getRangeByName('AG6').cellStyle = globalStyle2220;
    // sheet1.getRangeByName('AH6').cellStyle = globalStyle2220;

    sheet1.getRangeByName('A6').columnWidth = 10;
    sheet1.getRangeByName('B6').columnWidth = 20;
    sheet1.getRangeByName('C6').columnWidth = 20;
    sheet1.getRangeByName('D6').columnWidth = 25;
    sheet1.getRangeByName('E6').columnWidth = 20;
    sheet1.getRangeByName('F6').columnWidth = 25;
    sheet1.getRangeByName('G6').columnWidth = 25;
    sheet1.getRangeByName('H6').columnWidth = 20;
    sheet1.getRangeByName('I6').columnWidth = 20;
    sheet1.getRangeByName('J6').columnWidth = 20;
    sheet1.getRangeByName('K6').columnWidth = 20;
    sheet1.getRangeByName('L6').columnWidth = 20;
    sheet1.getRangeByName('M6').columnWidth = 20;
    sheet1.getRangeByName('N6').columnWidth = 20;
    sheet1.getRangeByName('O6').columnWidth = 20;
    sheet1.getRangeByName('P6').columnWidth = 20;
    sheet1.getRangeByName('Q6').columnWidth = 20;
    sheet1.getRangeByName('R6').columnWidth = 25;
    sheet1.getRangeByName('S6').columnWidth = 25;
    sheet1.getRangeByName('T6').columnWidth = 25;
    sheet1.getRangeByName('U6').columnWidth = 25;
    sheet1.getRangeByName('V6').columnWidth = 25;
    sheet1.getRangeByName('${columns[(21 + 0) + columns_now]}6').columnWidth =
        25;
    sheet1.getRangeByName('${columns[(21 + 1) + columns_now]}6').columnWidth =
        25;
    sheet1.getRangeByName('${columns[(21 + 2) + columns_now]}6').columnWidth =
        25;
    sheet1.getRangeByName('${columns[(21 + 3) + columns_now]}6').columnWidth =
        25;
    sheet1.getRangeByName('${columns[(21 + 4) + columns_now]}6').columnWidth =
        25;
    sheet1.getRangeByName('${columns[(21 + 5) + columns_now]}6').columnWidth =
        25;
    sheet1.getRangeByName('${columns[(21 + 6) + columns_now]}6').columnWidth =
        25;
    sheet1.getRangeByName('${columns[(21 + 7) + columns_now]}6').columnWidth =
        25;
    sheet1.getRangeByName('${columns[(21 + 8) + columns_now]}6').columnWidth =
        25;
    sheet1.getRangeByName('${columns[(21 + 9) + columns_now]}6').columnWidth =
        25;
    sheet1.getRangeByName('${columns[(21 + 10) + columns_now]}6').columnWidth =
        25;
    sheet1.getRangeByName('${columns[(21 + 11) + columns_now]}6').columnWidth =
        25;
    sheet1.getRangeByName('${columns[(21 + 12) + columns_now]}6').columnWidth =
        25;
    sheet1.getRangeByName('${columns[(21 + 13) + columns_now]}6').columnWidth =
        25;
    sheet1.getRangeByName('${columns[(21 + 14) + columns_now]}6').columnWidth =
        25;
    sheet1.getRangeByName('${columns[(21 + 15) + columns_now]}6').columnWidth =
        25;
    sheet1.getRangeByName('${columns[(21 + 16) + columns_now]}6').columnWidth =
        35;
    sheet1.getRangeByName('A6').setText('ลำดับที่');
    sheet1.getRangeByName('B6').setText('วันที่');
    sheet1.getRangeByName('C6').setText('เลขใบกำกับภาษี');
    sheet1.getRangeByName('D6').setText('รายชื่อลูกค้า');
    sheet1.getRangeByName('E6').setText('รหัสสาขา');
    sheet1.getRangeByName('F6').setText('ชื่อสาขา');
    sheet1.getRangeByName('G6').setText('เลขประจำตัวผู้เสียภาษี');
    sheet1.getRangeByName('H6').setText('เงินประกัน');
    sheet1.getRangeByName('I6').setText('VAT-(เงินประกัน)');
    sheet1.getRangeByName('J6').setText('รวมเงินประกัน');
////////---------->
    sheet1.getRangeByName('K6').setText('ค่าเช่าพื้นที่ดิน');
    sheet1.getRangeByName('L6').setText('VAT-(ค่าเช่าพื้นที่ดิน)');
    sheet1.getRangeByName('M6').setText('WHT-(ค่าเช่าพื้นที่ดิน)');
    sheet1.getRangeByName('N6').setText('รวมค่าเช่าพื้นที่ดิน');
////////---------->
    sheet1.getRangeByName('O6').setText('ค่าเช่าพื้นที่');
    sheet1.getRangeByName('P6').setText('VAT-(ค่าเช่าพื้นที่)');
    sheet1.getRangeByName('Q6').setText('WHT-(ค่าเช่าพื้นที่)');
    sheet1.getRangeByName('R6').setText('รวมค่าเช่าพื้นที่');
////////---------->
    sheet1.getRangeByName('S6').setText('ค่าบริการพื้นที่');
    sheet1.getRangeByName('T6').setText('VAT-(ค่าบริการพื้นที่)');
    sheet1.getRangeByName('U6').setText('WHT-(ค่าบริการพื้นที่)');
    sheet1.getRangeByName('V6').setText('รวมค่าบริการพื้นที่');
    /////////---------->
    int xx_count = 0;
    for (int i = 0; i < expModels.length; i++) {
      for (int x = 0; x < 3; x++) {
        xx_count = xx_count + 1;
        sheet1.getRangeByName('${columns[21 + xx_count]}6').setText(
              (x == 0)
                  ? '${expModels[i].expname}'
                  : (x == 1)
                      ? 'VAT-(${expModels[i].expname})'
                      : 'รวม${expModels[i].expname}',
            );
      }
    }

    // sheet1.getRangeByName('S6').setText('ค่าอุปกรณ์');
    // sheet1.getRangeByName('T6').setText('ภาษีมูลค่าเพิ่ม 7% (ค่าอุปกรณ์)');
    // sheet1.getRangeByName('U6').setText('รวมค่าอุปกรณ์');

    sheet1
        .getRangeByName('${columns[(22 + 0) + columns_now]}6')
        .setText('ค่าเช่าพื้นที่ดินรับล่วงหน้า');
    sheet1
        .getRangeByName('${columns[(22 + 1) + columns_now]}6')
        .setText('ค่าเช่ารับล่วงหน้า');
    sheet1
        .getRangeByName('${columns[(22 + 2) + columns_now]}6')
        .setText('ค่าบริการล่วงหน้า');

    sheet1
        .getRangeByName('${columns[(22 + 3) + columns_now]}6')
        .setText(' หัก ณ ที่ จ่าย');

    sheet1
        .getRangeByName('${columns[(22 + 4) + columns_now]}6')
        .setText('จำนวนเงินรวมทั้งสิ้น');

    sheet1
        .getRangeByName('${columns[(22 + 5) + columns_now]}6')
        .setText('เริ่มต้นสัญญา');
    // sheet1.getRangeByName('AA6').setText('วันที่เริ่มต้นสัญญา');
    // sheet1.getRangeByName('AB6').setText('เดือนที่เริ่มต้นสัญญา');
    // sheet1.getRangeByName('AC6').setText('ปีที่เริ่มต้นสัญญา');
    sheet1
        .getRangeByName('${columns[(22 + 6) + columns_now]}6')
        .setText('สถานะ');
    sheet1
        .getRangeByName('${columns[(22 + 7) + columns_now]}6')
        .setText('อ้างอิง');

    sheet1
        .getRangeByName('${columns[(22 + 8) + columns_now]}6')
        .setText('ref1');
    sheet1
        .getRangeByName('${columns[(22 + 9) + columns_now]}6')
        .setText('ref2');
    sheet1
        .getRangeByName('${columns[(22 + 10) + columns_now]}6')
        .setText('ref-chao');

//////////-------------------------------------------------->
    sheet2.getRangeByName('A6').cellStyle = globalStyle1;
    sheet2.getRangeByName('B6').cellStyle = globalStyle1;
    sheet2.getRangeByName('C6').cellStyle = globalStyle1;
    sheet2.getRangeByName('D6').cellStyle = globalStyle1;
    sheet2.getRangeByName('E6').cellStyle = globalStyle1;
    sheet2.getRangeByName('F6').cellStyle = globalStyle1;
    sheet2.getRangeByName('G6').cellStyle = globalStyle1;
    sheet2.getRangeByName('H6').cellStyle = globalStyle1;
    sheet2.getRangeByName('I6').cellStyle = globalStyle1;
    sheet2.getRangeByName('J6').cellStyle = globalStyle1;
    sheet2.getRangeByName('K6').cellStyle = globalStyle1;
    sheet2.getRangeByName('L6').cellStyle = globalStyle1;
    sheet2.getRangeByName('M6').cellStyle = globalStyle1;
    sheet2.getRangeByName('N6').cellStyle = globalStyle1;
    sheet2.getRangeByName('O6').cellStyle = globalStyle1;
    // sheet2.getRangeByName('P6').cellStyle = globalStyle1;
    sheet2.getRangeByName('A6').columnWidth = 10;
    sheet2.getRangeByName('B6').columnWidth = 20;
    sheet2.getRangeByName('C6').columnWidth = 20;
    sheet2.getRangeByName('D6').columnWidth = 25;
    sheet2.getRangeByName('E6').columnWidth = 20;
    sheet2.getRangeByName('F6').columnWidth = 30;
    sheet2.getRangeByName('G6').columnWidth = 25;
    sheet2.getRangeByName('H6').columnWidth = 30;
    sheet2.getRangeByName('I6').columnWidth = 25;
    sheet2.getRangeByName('J6').columnWidth = 35;
    sheet2.getRangeByName('K6').columnWidth = 35;
    sheet2.getRangeByName('L6').columnWidth = 35;
    sheet2.getRangeByName('M6').columnWidth = 25;
    sheet2.getRangeByName('N6').columnWidth = 25;
    sheet2.getRangeByName('O6').columnWidth = 25;
    // sheet2.getRangeByName('P6').columnWidth = 25;

    sheet2.getRangeByName('A6').setText('ลำดับที่');
    sheet2.getRangeByName('B6').setText('วันที่');
    sheet2.getRangeByName('C6').setText('เลขใบกำกับภาษี');
    sheet2.getRangeByName('D6').setText('รายชื่อลูกค้า');
    sheet2.getRangeByName('E6').setText('รหัสสาขา');
    sheet2.getRangeByName('F6').setText('ชื่อสาขา');
    sheet2.getRangeByName('G6').setText('เลขประจำตัวผู้เสียภาษี');
    sheet2.getRangeByName('H6').setText('ค่าเช่าพื้นที่ดิน');
    // sheet2.getRangeByName('I6').setText('VAT-(ค่าเช่าพื้นที่ดิน)');

    sheet2.getRangeByName('I6').setText('ค่าเช่าพื้นที่');
    // sheet2.getRangeByName('K6').setText('VAT-(ค่าเช่าพื้นที่)');
    sheet2.getRangeByName('J6').setText('ค่าบริการ,ค่าธรรมเนียมใช้น้ำไฟน้ำ');
    sheet2
        .getRangeByName('K6')
        .setText('ค่าบริการ,ค่าธรรมเนียมใช้น้ำไฟน้ำ(VAT)');
    sheet2
        .getRangeByName('L6')
        .setText('ค่าบริการ,ค่าธรรมเนียมใช้น้ำไฟน้ำ(+VAT)');
    sheet2.getRangeByName('M6').setText(' จำนวนเงินรวม ');
    sheet2.getRangeByName('N6').setText(' หัก ณ ที่ จ่าย');
    sheet2.getRangeByName('O6').setText(' อ้างอิง');
//////////-------------------------------------------------->
    sheet3.getRangeByName('A6').cellStyle = globalStyle1;
    sheet3.getRangeByName('B6').cellStyle = globalStyle1;
    sheet3.getRangeByName('C6').cellStyle = globalStyle1;
    sheet3.getRangeByName('D6').cellStyle = globalStyle1;
    sheet3.getRangeByName('E6').cellStyle = globalStyle1;
    sheet3.getRangeByName('F6').cellStyle = globalStyle1;
    sheet3.getRangeByName('G6').cellStyle = globalStyle1;
    sheet3.getRangeByName('H6').cellStyle = globalStyle1;
    sheet3.getRangeByName('I6').cellStyle = globalStyle1;
    sheet3.getRangeByName('J6').cellStyle = globalStyle1;
    sheet3.getRangeByName('K6').cellStyle = globalStyle1;
    // sheet3.getRangeByName('I6').cellStyle = globalStyle1;

    sheet3.getRangeByName('A6').columnWidth = 10;
    sheet3.getRangeByName('B6').columnWidth = 20;
    sheet3.getRangeByName('C6').columnWidth = 20;
    sheet3.getRangeByName('D6').columnWidth = 25;
    sheet3.getRangeByName('E6').columnWidth = 25;
    sheet3.getRangeByName('F6').columnWidth = 25;
    sheet3.getRangeByName('G6').columnWidth = 25;
    sheet3.getRangeByName('H6').columnWidth = 30;
    sheet3.getRangeByName('I6').columnWidth = 30;
    sheet3.getRangeByName('J6').columnWidth = 30;
    sheet3.getRangeByName('K6').columnWidth = 30;
    // sheet3.getRangeByName('I6').columnWidth = 25;

    sheet3.getRangeByName('A6').setText('ลำดับที่');
    sheet3.getRangeByName('B6').setText('วันที่');
    sheet3.getRangeByName('C6').setText('เลขใบกำกับภาษี');
    sheet3.getRangeByName('D6').setText('รายชื่อลูกค้า');
    sheet3.getRangeByName('E6').setText('รหัสสาขา');
    sheet3.getRangeByName('F6').setText('ชื่อสาขา');
    sheet3.getRangeByName('G6').setText('เลขประจำตัวผู้เสียภาษี');
    sheet3.getRangeByName('H6').setText('จำนวนเงิน');
    sheet3.getRangeByName('I6').setText('VAT');
    sheet3.getRangeByName('J6').setText('จำนวนเงินรวม');
    sheet3.getRangeByName('K6').setText('อ้างอิง');
    // sheet3.getRangeByName('G6').setText('ผ้ากันเปื้อน');
    // sheet3.getRangeByName('H6').setText('ภาษีมูลค่าเพิ่ม 7%(ผ้ากันเปื้อน)');
    // sheet3.getRangeByName('I6').setText('จำนวนเงินรวม');

//////////-------------------------------------------------->
    sheet4.getRangeByName('A6').cellStyle = globalStyle1;
    sheet4.getRangeByName('B6').cellStyle = globalStyle1;
    sheet4.getRangeByName('C6').cellStyle = globalStyle1;
    sheet4.getRangeByName('D6').cellStyle = globalStyle1;
    sheet4.getRangeByName('E6').cellStyle = globalStyle1;
    sheet4.getRangeByName('F6').cellStyle = globalStyle1;
    sheet4.getRangeByName('G6').cellStyle = globalStyle1;
    sheet4.getRangeByName('H6').cellStyle = globalStyle1;
    sheet4.getRangeByName('I6').cellStyle = globalStyle1;
    sheet4.getRangeByName('J6').cellStyle = globalStyle1;
    sheet4.getRangeByName('K6').cellStyle = globalStyle1;
    sheet4.getRangeByName('L6').cellStyle = globalStyle1;

    sheet4.getRangeByName('A6').columnWidth = 10;
    sheet4.getRangeByName('B6').columnWidth = 20;
    sheet4.getRangeByName('C6').columnWidth = 20;
    sheet4.getRangeByName('D6').columnWidth = 25;
    sheet4.getRangeByName('E6').columnWidth = 25;
    sheet4.getRangeByName('F6').columnWidth = 25;
    sheet4.getRangeByName('G6').columnWidth = 25;
    sheet4.getRangeByName('H6').columnWidth = 30;
    sheet4.getRangeByName('I6').columnWidth = 25;
    sheet4.getRangeByName('J6').columnWidth = 25;
    sheet4.getRangeByName('K6').columnWidth = 25;
    sheet4.getRangeByName('L6').columnWidth = 25;

    sheet4.getRangeByName('A6').setText('ลำดับที่');
    sheet4.getRangeByName('B6').setText('วันที่ชำระใบเสร็จเงินประกัน');
    sheet4.getRangeByName('C6').setText('เลขใบกำกับภาษี');
    sheet4.getRangeByName('D6').setText('รายชื่อลูกค้า');
    sheet4.getRangeByName('E6').setText('รหัสสาขา');
    sheet4.getRangeByName('F6').setText('ชื่อสาขา');
    sheet4.getRangeByName('G6').setText('เลขประจำตัวผู้เสียภาษี');
    sheet4.getRangeByName('H6').setText('เงินประกันการเช่า');
    sheet4.getRangeByName('I6').setText('เงินประกันบริการ');
    sheet4.getRangeByName('J6').setText('เงินประกันบริการ(VAT)');
    sheet4.getRangeByName('K6').setText('จำนวนเงินรวม');
    sheet4.getRangeByName('L6').setText('อ้างอิง');

//////////-------------------------------------------------->
    int index1 = 0;
    int indextotol = 0;
    int indextotol_sheet2 = 0;
    List cid_number = [];

    for (int index = 0; index < teNantModels_New.length; index++) {
      dynamic numberColor = ((index % 2) == 0) ? globalStyle22 : globalStyle222;
      sheet1.getRangeByName('A${index + 7}').cellStyle = numberColor;
      sheet1.getRangeByName('B${index + 7}').cellStyle = numberColor;
      sheet1.getRangeByName('C${index + 7}').cellStyle = numberColor;
      sheet1.getRangeByName('D${index + 7}').cellStyle = numberColor;
      sheet1.getRangeByName('E${index + 7}').cellStyle = numberColor;
      sheet1.getRangeByName('F${index + 7}').cellStyle = numberColor;
      sheet1.getRangeByName('G${index + 7}').cellStyle = numberColor;
      sheet1.getRangeByName('H${index + 7}').cellStyle = numberColor;
      sheet1.getRangeByName('I${index + 7}').cellStyle = numberColor;

      sheet1.getRangeByName('J${index + 7}').cellStyle = numberColor;
      sheet1.getRangeByName('K${index + 7}').cellStyle = numberColor;
      sheet1.getRangeByName('L${index + 7}').cellStyle = numberColor;
      sheet1.getRangeByName('M${index + 7}').cellStyle = numberColor;
      sheet1.getRangeByName('N${index + 7}').cellStyle = numberColor;
      sheet1.getRangeByName('O${index + 7}').cellStyle = numberColor;
      sheet1.getRangeByName('P${index + 7}').cellStyle = numberColor;
      sheet1.getRangeByName('Q${index + 7}').cellStyle = numberColor;
      sheet1.getRangeByName('R${index + 7}').cellStyle = numberColor;
      sheet1.getRangeByName('S${index + 7}').cellStyle = numberColor;
      sheet1.getRangeByName('T${index + 7}').cellStyle = numberColor;
      sheet1.getRangeByName('U${index + 7}').cellStyle = numberColor;
      sheet1.getRangeByName('V${index + 7}').cellStyle = numberColor;
      int xx_count_Color = 0;
      for (int i = 0; i < expModels.length; i++) {
        for (int x = 0; x < 3; x++) {
          xx_count_Color = xx_count_Color + 1;
          sheet1
              .getRangeByName('${columns[21 + xx_count_Color]}${index + 7}')
              .cellStyle = numberColor;
        }
      }
      /////////---------->
      for (int i2 = 0; i2 < 11; i2++) {
        sheet1
            .getRangeByName('${columns[(22 + i2) + columns_now]}${index + 7}')
            .cellStyle = numberColor;
      }
      // sheet1.getRangeByName('S${index + 7}').cellStyle = numberColor;
      // sheet1.getRangeByName('T${index + 7}').cellStyle = numberColor;
      // sheet1.getRangeByName('U${index + 7}').cellStyle = numberColor;
      // sheet1.getRangeByName('V${index + 7}').cellStyle = numberColor;
      // sheet1.getRangeByName('W${index + 7}').cellStyle = numberColor;
      // sheet1.getRangeByName('X${index + 7}').cellStyle = numberColor;
      // sheet1.getRangeByName('Y${index + 7}').cellStyle = numberColor;
      // sheet1.getRangeByName('Z${index + 7}').cellStyle = numberColor;
      // sheet1.getRangeByName('AA${index + 7}').cellStyle = numberColor;
      // sheet1.getRangeByName('AB${index + 7}').cellStyle = numberColor;
      // sheet1.getRangeByName('AC${index + 7}').cellStyle = numberColor;
      // sheet1.getRangeByName('AD${index + 7}').cellStyle = numberColor;
      // sheet1.getRangeByName('AE${index + 7}').cellStyle = numberColor;
      // sheet1.getRangeByName('AF${index + 7}').cellStyle = numberColor;
      // sheet1.getRangeByName('AG${index + 7}').cellStyle = numberColor;
      // sheet1.getRangeByName('AH${index + 7}').cellStyle = numberColor;

      sheet1.getRangeByName('A${index + 7}').setText('${index + 1}');
      try {
        sheet1.getRangeByName('B${index + 7}').cellStyle.numberFormat =
            'dd-MM-yyyy';
        sheet1.getRangeByName('B${index + 7}').setValue(
              (teNantModels_New[index].pakan_daterec == null ||
                      teNantModels_New[index].pakan_daterec.toString() == '')
                  ? null
                  : DateTime.parse('${teNantModels_New[index].pakan_daterec}'),
            );
      } catch (e) {
        sheet1.getRangeByName('B${index + 7}').setText(
              (teNantModels_New[index].pakan_daterec == null)
                  ? ''
                  : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${teNantModels_New[index].pakan_daterec}'))}',
            );
      }

      sheet1.getRangeByName('C${index + 7}').setText(
            (teNantModels_New[index].pakan_doc == null)
                ? ''
                : '${teNantModels_New[index].pakan_doc}',
          );
      sheet1.getRangeByName('D${index + 7}').setText(
            (teNantModels_New[index].cname != null)
                ? '${teNantModels_New[index].cname}'
                : '${teNantModels_New[index].remark}',
          );

      sheet1.getRangeByName('E${index + 7}').setText(
            (teNantModels_New[index].zn != null)
                ? (teNantModels_New[index].zn!.split('_')[0].length <= 4)
                    ? 'CMN0${teNantModels_New[index].zn!.split('_')[0]}'
                    : 'CMN${teNantModels_New[index].zn!.split('_')[0]}'
                : (teNantModels_New[index].zn1!.split('_')[0].length < 4)
                    ? 'CMN0${teNantModels_New[index].zn1!.split('_')[0]}'
                    : 'CMN${teNantModels_New[index].zn1!.split('_')[0]}',
          );
      sheet1.getRangeByName('F${index + 7}').setText(
            (teNantModels_New[index].zn != null)
                ? '${teNantModels_New[index].zn}'
                : '${teNantModels_New[index].znn}',
          );

      sheet1.getRangeByName('G${index + 7}').setText(
            (teNantModels_New[index].tax != null)
                ? '${teNantModels_New[index].tax}'
                : '',
          );

      sheet1.getRangeByName('H${index + 7}').setNumber(
          (teNantModels_New[index].pvat_pakan == null ||
                  teNantModels_New[index].pvat_pakan.toString() == '')
              ? 0.00
              : double.parse('${teNantModels_New[index].pvat_pakan}'));

      sheet1.getRangeByName('I${index + 7}').setNumber(
          (teNantModels_New[index].pakan_vat == null ||
                  teNantModels_New[index].pakan_vat.toString() == '')
              ? 0.00
              : double.parse('${teNantModels_New[index].pakan_vat}'));

      sheet1.getRangeByName('J${index + 7}').setNumber(
          (teNantModels_New[index].total_pakan == null ||
                  teNantModels_New[index].total_pakan.toString() == '')
              ? 0.00
              : double.parse('${teNantModels_New[index].total_pakan}'));
      ////////------------------------>
      sheet1.getRangeByName('K${index + 7}').setNumber(
          (teNantModels_New[index].land_pvat == null ||
                  teNantModels_New[index].land_pvat.toString() == '')
              ? 0.00
              : double.parse('${teNantModels_New[index].land_pvat}'));
      sheet1.getRangeByName('L${index + 7}').setNumber(
          (teNantModels_New[index].land_vat == null ||
                  teNantModels_New[index].land_vat.toString() == '')
              ? 0.00
              : double.parse('${teNantModels_New[index].land_vat}'));
      sheet1.getRangeByName('M${index + 7}').setNumber(
          (teNantModels_New[index].land_wht == null ||
                  teNantModels_New[index].land_wht.toString() == '')
              ? 0.00
              : double.parse('${teNantModels_New[index].land_wht}'));
      sheet1.getRangeByName('N${index + 7}').setNumber(
          (teNantModels_New[index].land_total == null ||
                  teNantModels_New[index].land_total.toString() == '')
              ? 0.00
              : double.parse('${teNantModels_New[index].land_total}'));
      ////////------------------------>
      sheet1.getRangeByName('O${index + 7}').setNumber(
          (teNantModels_New[index].rent_pvat == null ||
                  teNantModels_New[index].rent_pvat.toString() == '')
              ? 0.00
              : double.parse('${teNantModels_New[index].rent_pvat}'));
      sheet1.getRangeByName('P${index + 7}').setNumber(
          (teNantModels_New[index].rent_vat == null ||
                  teNantModels_New[index].rent_vat.toString() == '')
              ? 0.00
              : double.parse('${teNantModels_New[index].rent_vat}'));
      sheet1.getRangeByName('Q${index + 7}').setNumber(
          (teNantModels_New[index].rent_wht == null ||
                  teNantModels_New[index].rent_wht.toString() == '')
              ? 0.00
              : double.parse('${teNantModels_New[index].rent_wht}'));
      sheet1.getRangeByName('R${index + 7}').setNumber(
          (teNantModels_New[index].rent_total == null ||
                  teNantModels_New[index].rent_total.toString() == '')
              ? 0.00
              : double.parse('${teNantModels_New[index].rent_total}'));
      //////////----------------------->
      sheet1.getRangeByName('S${index + 7}').setNumber(
          (teNantModels_New[index].service_pvat == null ||
                  teNantModels_New[index].service_pvat.toString() == '')
              ? 0.00
              : double.parse('${teNantModels_New[index].service_pvat}'));

      sheet1.getRangeByName('T${index + 7}').setNumber(
          (teNantModels_New[index].service_vat == null ||
                  teNantModels_New[index].service_vat.toString() == '')
              ? 0.00
              : double.parse('${teNantModels_New[index].service_vat}'));
      sheet1.getRangeByName('U${index + 7}').setNumber(
          (teNantModels_New[index].service_wht == null ||
                  teNantModels_New[index].service_wht.toString() == '')
              ? 0.00
              : double.parse('${teNantModels_New[index].service_wht}'));
      sheet1.getRangeByName('V${index + 7}').setNumber(
          (teNantModels_New[index].service_total == null ||
                  teNantModels_New[index].service_total.toString() == '')
              ? 0.00
              : double.parse('${teNantModels_New[index].service_total}'));

      //////////----------------------->
      String textdata = '${teNantModels_New[index].exp_array}';
      List<dynamic> dataList = [];

// Check if textdata is not null or empty, and then decode
      if (textdata.isNotEmpty) {
        try {
          dataList = json.decode(textdata) as List<dynamic>;
        } catch (e) {
          // Handle any errors in JSON decoding
          //   print('Invalid JSON data: $e');
          dataList = [];
        }
      }
      int count_01 = 21;
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

        for (int x = 0; x < 3; x++) {
          count_01 = count_01 + 1;
          sheet1.getRangeByName('${columns[count_01]}${index + 7}').setNumber(
                (x == 0)
                    ? pvat
                    : (x == 1)
                        ? vat
                        : total,
              );
        }
      }
      /////////----------------------------->
      sheet1
          .getRangeByName('${columns[(22 + 0) + columns_now]}${index + 7}')
          .setNumber((teNantModels_New[index].land_total_future == null ||
                  teNantModels_New[index].land_total_future.toString() == '')
              ? 0.00
              : double.parse('${teNantModels_New[index].land_total_future}'));
      sheet1
          .getRangeByName('${columns[(22 + 1) + columns_now]}${index + 7}')
          .setNumber((teNantModels_New[index].rent_total_future == null ||
                  teNantModels_New[index].rent_total_future.toString() == '')
              ? 0.00
              : double.parse('${teNantModels_New[index].rent_total_future}'));
      sheet1
          .getRangeByName('${columns[(22 + 2) + columns_now]}${index + 7}')
          .setNumber((teNantModels_New[index].service_total_future == null ||
                  teNantModels_New[index].service_total_future.toString() == '')
              ? 0.00
              : double.parse(
                  '${teNantModels_New[index].service_total_future}'));

      double total_all = (dataList.isEmpty)
          ? 0.00
          : dataList
              .whereType<Map<String, dynamic>>()
              .where((element) => element['total_exp'].toString() != '')
              .map((element) => double.parse(element['total_exp'].toString()))
              .fold(0, (prev, wht) => prev + wht);
      sheet1
          .getRangeByName('${columns[(22 + 3) + columns_now]}${index + 7}')
          .setNumber((teNantModels_New[index].total_wht == null ||
                  teNantModels_New[index].total_wht.toString() == '')
              ? 0.00
              : double.parse('${teNantModels_New[index].total_wht}'));

      sheet1
          .getRangeByName('${columns[(22 + 4) + columns_now]}${index + 7}')
          .setNumber(total_all);
      // sheet1.getRangeByName('U${index + 7}').setNumber(
      //     (teNantModels_New[index].total_bill == null ||
      //             teNantModels_New[index].total_bill.toString() == '')
      //         ? 0.00
      //         : double.parse('${teNantModels_New[index].total_bill}'));

      try {
        sheet1
            .getRangeByName('${columns[(22 + 5) + columns_now]}${index + 7}')
            .cellStyle
            .numberFormat = 'dd-MM-yyyy';
        sheet1
            .getRangeByName('${columns[(22 + 5) + columns_now]}${index + 7}')
            .setValue(
              (teNantModels_New[index].sdate == null ||
                      teNantModels_New[index].sdate.toString() == '')
                  ? null
                  : DateTime.parse('${teNantModels_New[index].sdate}'),
            );
      } catch (e) {
        sheet1
            .getRangeByName('${columns[(22 + 5) + columns_now]}${index + 7}')
            .setText(
              (teNantModels_New[index].sdate == null ||
                      teNantModels_New[index].sdate.toString() == '')
                  ? ''
                  : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${teNantModels_New[index].sdate}'))}',
            );
      }
      // sheet1
      //     .getRangeByName('${columns[(19 + 4) + columns_now]}${index + 7}')
      //     .setText((teNantModels_New[index].sdate != null ||
      //             teNantModels_New[index].sdate.toString() != '')
      //         ? '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${teNantModels_New[index].sdate}'))}'
      //         : 'ล็อกเสียบ');

      // sheet1.getRangeByName('${columns[23 + columns_now]}${index + 7}').setText(
      //     (teNantModels_New[index].sdate != null ||
      //             teNantModels_New[index].sdate.toString() != '')
      //         ? '${DateFormat('dd').format(DateTime.parse('${teNantModels_New[index].sdate}'))}'
      //         : 'ล็อกเสียบ');
      // sheet1.getRangeByName('${columns[24 + columns_now]}${index + 7}').setText(
      //     (teNantModels_New[index].sdate != null ||
      //             teNantModels_New[index].sdate.toString() != '')
      //         ? '${DateFormat('MM').format(DateTime.parse('${teNantModels_New[index].sdate}'))}'
      //         : 'ล็อกเสียบ');
      // sheet1.getRangeByName('${columns[25 + columns_now]}${index + 7}').setText(
      //     (teNantModels_New[index].sdate != null ||
      //             teNantModels_New[index].sdate.toString() != '')
      //         ? '${DateFormat('yyyy').format(DateTime.parse('${teNantModels_New[index].sdate}'))}'
      //         : 'ล็อกเสียบ');
      sheet1
          .getRangeByName('${columns[(22 + 6) + columns_now]}${index + 7}')
          .setText((teNantModels_New[index].st == null)
              ? ''
              : '${teNantModels_New[index].st}');
      sheet1
          .getRangeByName('${columns[(22 + 7) + columns_now]}${index + 7}')
          .setText((teNantModels_New[index].wnote == null)
              ? ''
              : '${teNantModels_New[index].wnote}');
      sheet1
          .getRangeByName('${columns[(22 + 8) + columns_now]}${index + 7}')
          .setText((teNantModels_New[index].ref2 == null)
              ? ''
              : '${teNantModels_New[index].ref2}');
      sheet1
          .getRangeByName('${columns[(22 + 9) + columns_now]}${index + 7}')
          .setText((teNantModels_New[index].ref4 == null)
              ? ''
              : '${teNantModels_New[index].ref4}');
      sheet1
          .getRangeByName('${columns[(22 + 10) + columns_now]}${index + 7}')
          .setText((teNantModels_New[index].ref1 == null)
              ? ''
              : '${teNantModels_New[index].ref1}');
      indextotol = indextotol + 1;
    }

    for (int index = 0; index < teNantModels_New.length; index++) {
      // Choose style based on index
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
      //   sheet2.getRangeByName('P${index + 7}').cellStyle = numberColor;

      sheet2
          .getRangeByName('A${index + 7}')
          .setText(sheet1.getRangeByName('A${index + 7}').text);
      try {
        sheet2.getRangeByName('B${index + 7}').cellStyle.numberFormat =
            'dd-MM-yyyy';
        sheet2.getRangeByName('B${index + 7}').setValue(
              (teNantModels_New[index].pakan_daterec == null ||
                      teNantModels_New[index].pakan_daterec.toString() == '')
                  ? null
                  : DateTime.parse('${teNantModels_New[index].pakan_daterec}'),
            );
      } catch (e) {
        sheet2.getRangeByName('B${index + 7}').setText(
            (teNantModels_New[index].pakan_daterec == null ||
                    teNantModels_New[index].pakan_daterec.toString() == '')
                ? ''
                : '${teNantModels_New[index].pakan_daterec}');
      }

      sheet2
          .getRangeByName('C${index + 7}')
          .setText(sheet1.getRangeByName('C${index + 7}').text);
      sheet2
          .getRangeByName('D${index + 7}')
          .setText(sheet1.getRangeByName('D${index + 7}').text);
      sheet2
          .getRangeByName('E${index + 7}')
          .setText(sheet1.getRangeByName('E${index + 7}').text);
      sheet2
          .getRangeByName('F${index + 7}')
          .setText(sheet1.getRangeByName('F${index + 7}').text);
      sheet2
          .getRangeByName('G${index + 7}')
          .setText(sheet1.getRangeByName('G${index + 7}').text);
      //////////------------------->
      sheet2
          .getRangeByName('H${index + 7}')
          .setNumber(sheet1.getRangeByName('K${index + 7}').number);
      //   sheet2
      //       .getRangeByName('I${index + 7}')
      //       .setNumber(sheet1.getRangeByName('L${index + 7}').number);

      sheet2
          .getRangeByName('I${index + 7}')
          .setNumber(sheet1.getRangeByName('O${index + 7}').number);
      //   sheet2
      //       .getRangeByName('K${index + 7}')
      //       .setNumber(sheet1.getRangeByName('O${index + 7}').number);
      ///--------------------------------------->

      String textdata = '${teNantModels_New[index].exp_array}';
      List<dynamic> dataList = [];
      if (textdata.isNotEmpty) {
        try {
          dataList = json.decode(textdata) as List<dynamic>;
        } catch (e) {
          // Handle any errors in JSON decoding
          //   print('Invalid JSON data: $e');
          dataList = [];
        }
      }
      double pvat = (dataList.isEmpty)
          ? 0.00
          : dataList
              .whereType<Map<String, dynamic>>()
              .where((element) =>
                  element['ser_exp'].toString() == '20' ||
                  element['ser_exp'].toString() == '21')
              .map((element) => double.parse(element['pvat_exp'].toString()))
              .fold(0, (prev, wht) => prev + wht);

      double vat = (dataList.isEmpty)
          ? 0.00
          : dataList
              .whereType<Map<String, dynamic>>()
              .where((element) =>
                  element['ser_exp'].toString() == '20' ||
                  element['ser_exp'].toString() == '21')
              .map((element) => double.parse(element['vat_exp'].toString()))
              .fold(0, (prev, wht) => prev + wht);
      double total = (dataList.isEmpty)
          ? 0.00
          : dataList
              .whereType<Map<String, dynamic>>()
              .where((element) =>
                  element['ser_exp'].toString() == '20' ||
                  element['ser_exp'].toString() == '21')
              .map((element) => double.parse(element['total_exp'].toString()))
              .fold(0, (prev, wht) => prev + wht);

      ///
      sheet2.getRangeByName('J${index + 7}').setNumber(double.parse(
              sheet1.getRangeByName('S${index + 7}').number.toString()) +
          pvat);

      sheet2.getRangeByName('K${index + 7}').setNumber(double.parse(
              sheet1.getRangeByName('T${index + 7}').number.toString()) +
          vat);

      sheet2.getRangeByName('L${index + 7}').setNumber(double.parse(
              sheet1.getRangeByName('V${index + 7}').number.toString()) +
          total);

      ///--------------------------------------->
      //   sheet2
      //       .getRangeByName('M${index + 7}')
      //       .setNumber(sheet1.getRangeByName('R${index + 7}').number);
      sheet2
          .getRangeByName('M${index + 7}')
          .setFormula('=SUM(H${index + 7}:I${index + 7})+L${index + 7}');
      //   sheet2.getRangeByName('L${index + 7}').setText('');

      sheet2.getRangeByName('N${index + 7}').setNumber(
          (teNantModels_New[index].total_wht == null ||
                  teNantModels_New[index].total_wht.toString() == '')
              ? 0.00
              : double.parse('${teNantModels_New[index].total_wht}'));

      sheet2.getRangeByName('O${index + 7}').setText(
          (teNantModels_New[index].wnote == null)
              ? ''
              : '${teNantModels_New[index].wnote}');
      indextotol_sheet2 = indextotol_sheet2 + 1;
    }
////////---------------------->
    int index_sheet3 = 0;
    for (int index = 0; index < teNantModels_New.length; index++) {
      String textdata_3 = '${teNantModels_New[index].exp_array}';
      List<dynamic> dataList_3 = [];

      if (textdata_3.isNotEmpty) {
        try {
          dataList_3 = json.decode(textdata_3) as List<dynamic>;
        } catch (e) {
          // Handle any errors in JSON decoding
          //   print('Invalid JSON data: $e');
          dataList_3 = [];
        }
      }
      double pvat = (dataList_3.isEmpty)
          ? 0.00
          : dataList_3
              .whereType<Map<String, dynamic>>()
              .where((element) => element['ser_exp'].toString() == '19')
              .map((element) => double.parse(element['pvat_exp'].toString()))
              .fold(0, (prev, wht) => prev + wht);

      double vat = (dataList_3.isEmpty)
          ? 0.00
          : dataList_3
              .whereType<Map<String, dynamic>>()
              .where((element) => element['ser_exp'].toString() == '19')
              .map((element) => double.parse(element['vat_exp'].toString()))
              .fold(0, (prev, wht) => prev + wht);

      double total = (dataList_3.isEmpty)
          ? 0.00
          : dataList_3
              .whereType<Map<String, dynamic>>()
              .where((element) => element['ser_exp'].toString() == '19')
              .map((element) => double.parse(element['total_exp'].toString()))
              .fold(0, (prev, wht) => prev + wht);

      if (total != 0.00) {
        // Choose style based on index
        dynamic numberColor =
            ((index_sheet3 % 2) == 0) ? globalStyle22 : globalStyle222;

        sheet3.getRangeByName('A${index_sheet3 + 7}').cellStyle = numberColor;
        sheet3.getRangeByName('B${index_sheet3 + 7}').cellStyle = numberColor;
        sheet3.getRangeByName('C${index_sheet3 + 7}').cellStyle = numberColor;
        sheet3.getRangeByName('D${index_sheet3 + 7}').cellStyle = numberColor;
        sheet3.getRangeByName('E${index_sheet3 + 7}').cellStyle = numberColor;
        sheet3.getRangeByName('F${index_sheet3 + 7}').cellStyle = numberColor;
        sheet3.getRangeByName('G${index_sheet3 + 7}').cellStyle = numberColor;
        sheet3.getRangeByName('H${index_sheet3 + 7}').cellStyle = numberColor;
        sheet3.getRangeByName('I${index_sheet3 + 7}').cellStyle = numberColor;
        sheet3.getRangeByName('J${index_sheet3 + 7}').cellStyle = numberColor;
        sheet3.getRangeByName('K${index_sheet3 + 7}').cellStyle = numberColor;

        sheet3
            .getRangeByName('A${index_sheet3 + 7}')
            .setText('${index_sheet3 + 1}');
        try {
          sheet3.getRangeByName('B${index_sheet3 + 7}').cellStyle.numberFormat =
              'dd-MM-yyyy';
          sheet3.getRangeByName('B${index_sheet3 + 7}').setValue(
                (teNantModels_New[index].pakan_daterec == null ||
                        teNantModels_New[index].pakan_daterec.toString() == '')
                    ? null
                    : DateTime.parse(
                        '${teNantModels_New[index].pakan_daterec}'),
              );
        } catch (e) {
          sheet3.getRangeByName('B${index_sheet3 + 7}').setText((teNantModels_New[
                              index]
                          .pakan_daterec ==
                      null ||
                  teNantModels_New[index].pakan_daterec.toString() == '')
              ? ''
              : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${teNantModels_New[index].pakan_daterec}'))}');
        }

        sheet3
            .getRangeByName('C${index_sheet3 + 7}')
            .setText(sheet1.getRangeByName('C${index + 7}').text);
        sheet3
            .getRangeByName('D${index_sheet3 + 7}')
            .setText(sheet1.getRangeByName('D${index + 7}').text);
        sheet3
            .getRangeByName('E${index_sheet3 + 7}')
            .setText(sheet1.getRangeByName('E${index + 7}').text);
        sheet3
            .getRangeByName('F${index_sheet3 + 7}')
            .setText(sheet1.getRangeByName('F${index + 7}').text);
        sheet3
            .getRangeByName('G${index_sheet3 + 7}')
            .setText(sheet1.getRangeByName('G${index + 7}').text);

        //////////----------------------->

        sheet3.getRangeByName('H${index_sheet3 + 7}').setNumber(pvat);
        sheet3.getRangeByName('I${index_sheet3 + 7}').setNumber(vat);
        sheet3.getRangeByName('J${index_sheet3 + 7}').setNumber(total);

        sheet3.getRangeByName('K${index_sheet3 + 7}').setText(
            (teNantModels_New[index].wnote == null)
                ? ''
                : '${teNantModels_New[index].wnote}');
        index_sheet3 = index_sheet3 + 1;
      }
    }
    ///////--------------------------------->
    for (int index = 0; index < teNantModels_New.length; index++) {
      // Choose style based on index
      dynamic numberColor = ((index % 2) == 0) ? globalStyle22 : globalStyle222;

      sheet4.getRangeByName('A${index + 7}').cellStyle = numberColor;
      sheet4.getRangeByName('B${index + 7}').cellStyle = numberColor;
      sheet4.getRangeByName('C${index + 7}').cellStyle = numberColor;
      sheet4.getRangeByName('D${index + 7}').cellStyle = numberColor;
      sheet4.getRangeByName('E${index + 7}').cellStyle = numberColor;
      sheet4.getRangeByName('F${index + 7}').cellStyle = numberColor;
      sheet4.getRangeByName('G${index + 7}').cellStyle = numberColor;
      sheet4.getRangeByName('H${index + 7}').cellStyle = numberColor;
      sheet4.getRangeByName('I${index + 7}').cellStyle = numberColor;
      sheet4.getRangeByName('J${index + 7}').cellStyle = numberColor;
      sheet4.getRangeByName('K${index + 7}').cellStyle = numberColor;
      sheet4.getRangeByName('L${index + 7}').cellStyle = numberColor;

      sheet4
          .getRangeByName('A${index + 7}')
          .setText(sheet1.getRangeByName('A${index + 7}').text);
      try {
        sheet4.getRangeByName('B${index + 7}').cellStyle.numberFormat =
            'dd-MM-yyyy';
        sheet4.getRangeByName('B${index + 7}').setValue(
              (teNantModels_New[index].pakan_daterec == null ||
                      teNantModels_New[index].pakan_daterec.toString() == '')
                  ? null
                  : DateTime.parse('${teNantModels_New[index].pakan_daterec}'),
            );
      } catch (e) {
        sheet4.getRangeByName('B${index + 7}').setText(
            (teNantModels_New[index].pakan_daterec == null ||
                    teNantModels_New[index].pakan_daterec.toString() == '')
                ? ''
                : DateTime.parse('${teNantModels_New[index].pakan_daterec}')
                    .toString());
      }

      sheet4
          .getRangeByName('C${index + 7}')
          .setText(sheet1.getRangeByName('C${index + 7}').text);
      sheet4
          .getRangeByName('D${index + 7}')
          .setText(sheet1.getRangeByName('D${index + 7}').text);
      sheet4
          .getRangeByName('E${index + 7}')
          .setText(sheet1.getRangeByName('E${index + 7}').text);
      sheet4
          .getRangeByName('F${index + 7}')
          .setText(sheet1.getRangeByName('F${index + 7}').text);
      sheet4
          .getRangeByName('G${index + 7}')
          .setText(sheet1.getRangeByName('G${index + 7}').text);
      //////////------------------->
      sheet4.getRangeByName('H${index + 7}').setNumber(
          (teNantModels_New[index].rent_pvat_pakan == null ||
                  teNantModels_New[index].rent_pvat_pakan.toString() == '')
              ? 0.00
              : double.parse('${teNantModels_New[index].rent_pvat_pakan}'));

      sheet4.getRangeByName('I${index + 7}').setNumber(
          (teNantModels_New[index].service_pvat_pakan == null ||
                  teNantModels_New[index].service_pvat_pakan.toString() == '')
              ? 0.00
              : double.parse('${teNantModels_New[index].service_pvat_pakan}'));

      sheet4.getRangeByName('J${index + 7}').setNumber(
          (teNantModels_New[index].service_vat_pakan == null ||
                  teNantModels_New[index].service_vat_pakan.toString() == '')
              ? 0.00
              : double.parse('${teNantModels_New[index].service_vat_pakan}'));

      sheet4
          .getRangeByName('K${index + 7}')
          .setFormula('=SUM(H${index + 7}:J${index + 7})');

      sheet4.getRangeByName('L${index + 7}').setText(
          (teNantModels_New[index].wnote == null)
              ? ''
              : '${teNantModels_New[index].wnote}');
      indextotol_sheet2 = indextotol_sheet2 + 1;
    }
    /////////---------------------------->

    sheet1.getRangeByName('G${indextotol + 7 + 0}').setText('รวมทั้งหมด: ');
    sheet1
        .getRangeByName('H${indextotol + 7 + 0}')
        .setFormula('=SUM(H7:H${indextotol + 7 - 1})');
    sheet1
        .getRangeByName('I${indextotol + 7 + 0}')
        .setFormula('=SUM(I7:I${indextotol + 7 - 1})');
    sheet1
        .getRangeByName('J${indextotol + 7 + 0}')
        .setFormula('=SUM(J7:J${indextotol + 7 - 1})');
    sheet1
        .getRangeByName('K${indextotol + 7 + 0}')
        .setFormula('=SUM(K7:K${indextotol + 7 - 1})');
    sheet1
        .getRangeByName('L${indextotol + 7 + 0}')
        .setFormula('=SUM(L7:L${indextotol + 7 - 1})');
    sheet1
        .getRangeByName('M${indextotol + 7 + 0}')
        .setFormula('=SUM(M7:M${indextotol + 7 - 1})');
    sheet1
        .getRangeByName('N${indextotol + 7 + 0}')
        .setFormula('=SUM(N7:N${indextotol + 7 - 1})');
    sheet1
        .getRangeByName('O${indextotol + 7 + 0}')
        .setFormula('=SUM(O7:O${indextotol + 7 - 1})');
    sheet1
        .getRangeByName('P${indextotol + 7 + 0}')
        .setFormula('=SUM(P7:P${indextotol + 7 - 1})');
    sheet1
        .getRangeByName('Q${indextotol + 7 + 0}')
        .setFormula('=SUM(Q7:Q${indextotol + 7 - 1})');
    sheet1
        .getRangeByName('R${indextotol + 7 + 0}')
        .setFormula('=SUM(R7:R${indextotol + 7 - 1})');
    sheet1
        .getRangeByName('S${indextotol + 7 + 0}')
        .setFormula('=SUM(S7:S${indextotol + 7 - 1})');
    /////////---------->
    int xx_count_SUM = 0;
    for (int i = 0; i < expModels.length; i++) {
      for (int x = 0; x < 3; x++) {
        xx_count_SUM = xx_count_SUM + 1;
        sheet1
            .getRangeByName(
                '${columns[18 + xx_count_SUM]}${indextotol + 7 + 0}')
            .setFormula(
                '=SUM(${columns[18 + xx_count_SUM]}7:${columns[18 + xx_count_SUM]}${indextotol + 7 - 1})');
      }
    }
    /////////---------->
    sheet1
        .getRangeByName(
            '${columns[(19 + 0) + columns_now]}${indextotol + 7 + 0}')
        .setFormula(
            '=SUM(${columns[(19 + 0) + columns_now]}7:${columns[(19 + 0) + columns_now]}${indextotol + 7 - 1})');
    sheet1
        .getRangeByName(
            '${columns[(19 + 1) + columns_now]}${indextotol + 7 + 0}')
        .setFormula(
            '=SUM(${columns[(19 + 1) + columns_now]}7:${columns[(19 + 1) + columns_now]}${indextotol + 7 - 1})');
    sheet1
        .getRangeByName(
            '${columns[(19 + 2) + columns_now]}${indextotol + 7 + 0}')
        .setFormula(
            '=SUM(${columns[(19 + 2) + columns_now]}7:${columns[(19 + 2) + columns_now]}${indextotol + 7 - 1})');
    sheet1
        .getRangeByName(
            '${columns[(19 + 3) + columns_now]}${indextotol + 7 + 0}')
        .setFormula(
            '=SUM(${columns[(19 + 3) + columns_now]}7:${columns[(19 + 3) + columns_now]}${indextotol + 7 - 1})');
    sheet1
        .getRangeByName(
            '${columns[(19 + 4) + columns_now]}${indextotol + 7 + 0}')
        .setFormula(
            '=SUM(${columns[(19 + 4) + columns_now]}7:${columns[(19 + 4) + columns_now]}${indextotol + 7 - 1})');
    sheet1
        .getRangeByName(
            '${columns[(20 + 4) + columns_now]}${indextotol + 7 + 0}')
        .setFormula(
            '=SUM(${columns[(20 + 4) + columns_now]}7:${columns[(20 + 4) + columns_now]}${indextotol + 7 - 1})');
    sheet1
        .getRangeByName(
            '${columns[(21 + 4) + columns_now]}${indextotol + 7 + 0}')
        .setFormula(
            '=SUM(${columns[(21 + 4) + columns_now]}7:${columns[(21 + 4) + columns_now]}${indextotol + 7 - 1})');
    sheet1
        .getRangeByName(
            '${columns[(22 + 4) + columns_now]}${indextotol + 7 + 0}')
        .setFormula(
            '=SUM(${columns[(22 + 4) + columns_now]}7:${columns[(22 + 4) + columns_now]}${indextotol + 7 - 1})');
    /////////---------------------------->

    sheet2.getRangeByName('G${indextotol + 7 + 0}').setText('รวมทั้งหมด: ');
    sheet2
        .getRangeByName('H${indextotol + 7 + 0}')
        .setFormula('=SUM(H7:H${indextotol + 7 - 1})');
    sheet2
        .getRangeByName('I${indextotol + 7 + 0}')
        .setFormula('=SUM(I7:I${indextotol + 7 - 1})');
    sheet2
        .getRangeByName('J${indextotol + 7 + 0}')
        .setFormula('=SUM(J7:J${indextotol + 7 - 1})');
    sheet2
        .getRangeByName('K${indextotol + 7 + 0}')
        .setFormula('=SUM(K7:K${indextotol + 7 - 1})');
    sheet2
        .getRangeByName('L${indextotol + 7 + 0}')
        .setFormula('=SUM(L7:L${indextotol + 7 - 1})');
    sheet2
        .getRangeByName('M${indextotol + 7 + 0}')
        .setFormula('=SUM(M7:M${indextotol + 7 - 1})');
    sheet2
        .getRangeByName('N${indextotol + 7 + 0}')
        .setFormula('=SUM(N7:N${indextotol + 7 - 1})');
    /////////---------------------------->

    sheet3.getRangeByName('G${index_sheet3 + 7 + 0}').setText('รวมทั้งหมด: ');
    sheet3
        .getRangeByName('H${index_sheet3 + 7 + 0}')
        .setFormula('=SUM(H7:H${index_sheet3 + 7 - 1})');
    sheet3
        .getRangeByName('I${index_sheet3 + 7 + 0}')
        .setFormula('=SUM(I7:I${index_sheet3 + 7 - 1})');
    sheet3
        .getRangeByName('J${index_sheet3 + 7 + 0}')
        .setFormula('=SUM(J7:J${index_sheet3 + 7 - 1})');
    // sheet3
    //     .getRangeByName('H${indextotol + 7 + 0}')
    //     .setFormula('=SUM(H7:H${indextotol + 7 - 1})');
    // sheet3
    //     .getRangeByName('I${indextotol + 7 + 0}')
    //     .setFormula('=SUM(I7:I${indextotol + 7 - 1})');
/////////---------------------------->

    sheet4.getRangeByName('G${indextotol + 7 + 0}').setText('รวมทั้งหมด: ');
    sheet4
        .getRangeByName('H${indextotol + 7 + 0}')
        .setFormula('=SUM(H7:H${indextotol + 7 - 1})');
    sheet4
        .getRangeByName('I${indextotol + 7 + 0}')
        .setFormula('=SUM(I7:I${indextotol + 7 - 1})');
    sheet4
        .getRangeByName('J${indextotol + 7 + 0}')
        .setFormula('=SUM(J7:J${indextotol + 7 - 1})');
    sheet4
        .getRangeByName('K${indextotol + 7 + 0}')
        .setFormula('=SUM(K7:K${indextotol + 7 - 1})');
    // sheet1.getRangeByName('F${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet1.getRangeByName('G${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet1.getRangeByName('H${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet1.getRangeByName('I${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet1.getRangeByName('J${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet1.getRangeByName('K${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet1.getRangeByName('L${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet1.getRangeByName('M${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet1.getRangeByName('N${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet1.getRangeByName('O${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet1.getRangeByName('P${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet1.getRangeByName('Q${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet1.getRangeByName('R${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet1.getRangeByName('S${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet1.getRangeByName('T${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet1.getRangeByName('U${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet1.getRangeByName('V${indextotol + 7 + 0}').cellStyle = globalStyle7;
    int Color_count_SUM = 0;
    for (int i = 0; i < expModels.length; i++) {
      for (int x = 0; x < 3; x++) {
        Color_count_SUM = Color_count_SUM + 1;
        sheet1
            .getRangeByName(
                '${columns[21 + Color_count_SUM]}${indextotol + 7 + 0}')
            .cellStyle = globalStyle7;
      }
    }

    for (int Color_SUM = 0; Color_SUM < 5; Color_SUM++) {
      sheet1
          .getRangeByName(
              '${columns[(22 + Color_SUM) + columns_now]}${indextotol + 7 + 0}')
          .cellStyle = globalStyle7;
    }

    // sheet1.getRangeByName('T${indextotol + 7 + 0}').cellStyle = globalStyle7;
    // sheet1.getRangeByName('U${indextotol + 7 + 0}').cellStyle = globalStyle7;
    /////////---------------------------->
    // sheet2.getRangeByName('F${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet2.getRangeByName('G${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet2.getRangeByName('H${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet2.getRangeByName('I${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet2.getRangeByName('J${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet2.getRangeByName('K${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet2.getRangeByName('L${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet2.getRangeByName('M${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet2.getRangeByName('N${indextotol + 7 + 0}').cellStyle = globalStyle7;
    /////////---------------------------->
    // sheet3.getRangeByName('F${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet3.getRangeByName('G${index_sheet3 + 7 + 0}').cellStyle = globalStyle7;
    sheet3.getRangeByName('H${index_sheet3 + 7 + 0}').cellStyle = globalStyle7;
    sheet3.getRangeByName('I${index_sheet3 + 7 + 0}').cellStyle = globalStyle7;
    sheet3.getRangeByName('J${index_sheet3 + 7 + 0}').cellStyle = globalStyle7;

    // sheet4.getRangeByName('F${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet4.getRangeByName('G${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet4.getRangeByName('H${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet4.getRangeByName('I${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet4.getRangeByName('J${indextotol + 7 + 0}').cellStyle = globalStyle7;
    sheet4.getRangeByName('K${indextotol + 7 + 0}').cellStyle = globalStyle7;

/////////---------------------------->
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    Uint8List data = Uint8List.fromList(bytes);
    MimeType type = MimeType.MICROSOFTEXCEL;

    String path = await FileSaver.instance.saveFile(
        (Value_Chang_Zone_People_TeNantNew == null)
            ? 'รายงานผู้เช่ารายใหม่_2 ประจำเดือน ${Mon_PeopleTeNantNew_Mon} ${YE_PeopleTeNantNew_Mon}'
            : 'รายงานผู้เช่ารายใหม่_2 ประจำเดือน ${Mon_PeopleTeNantNew_Mon} ${YE_PeopleTeNantNew_Mon}',
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
