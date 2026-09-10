import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../PeopleChao/Rental_Information.dart';
import '../../../../Style/ThaiBaht.dart';
import '../../Constant/Myconstant.dart';
import '../../Man_PDF/Preview_PDF/Preview_Agreement.dart';
import '../../Model/GetC_Quot_Select_Model.dart';
import '../../Style/loadAndCacheImage.dart';

class RentGroup {
  final String startDate;
  final String endDate;
  final String amount;
  final String amountText;

  RentGroup({
    required this.startDate,
    required this.endDate,
    required this.amount,
    required this.amountText,
  });
}

class Pdfgen_Agreement_Choice8 {
//////////---------------------------------------------------->( **** เอกสารสัญญาเช่า  Choice_v1)

  static void exportPDF_Agreement_Choice8(
    context,
    Get_Value_NameShop_index,
    Get_Value_cid,
    _verticalGroupValue,
    Form_nameshop,
    Form_typeshop,
    Form_bussshop,
    Form_bussscontact,
    Form_address,
    Form_tel,
    Form_email,
    Form_tax,
    Form_ln,
    Form_zn,
    Form_area,
    Form_qty,
    Form_sdate,
    Form_ldate,
    Form_period,
    Form_rtname,
    quotxSelectModels,
    _TransModels,
    renTal_name,
    bill_addr,
    bill_email,
    bill_tel,
    bill_tax,
    bill_name,
    newValuePDFimg,
    tableData00,
    TitleType_Default_Receipt_Name,
    Datex_text,
    _ReportValue_type_docOttor,
    Form_fid,
    Form_renew_cid,
    Form_PakanSdate,
    Form_PakanLdate,
    Form_PakanSdate_Doc,
    Form_PakanLdate_Doc,
    Form_PakanAll_amt,
    Form_PakanAll_pvat,
    Form_PakanAll_vat,
    Form_PakanAll_Total,
    Form_wnote,
    FormPeriod_choice,
    DatexChoice_Sub2_3text, //ให้ผู้เช่าครอบครองวันที่
  ) async {
    pw.Widget Textx({
      // required String label,
      required String value,
      // int dotLength = 40,
      required pw.Font font,
      double fontSize = 12.5,
    }) {
      var Colors_pd = PdfColors.black;
      // final filled = value.padRight(dotLength, '.');
      return pw.Text(
        value,
        textAlign: pw.TextAlign.left,
        style: pw.TextStyle(
          font: font,
          fontSize: fontSize,
          fontWeight: pw.FontWeight.bold,
        ),
      );
    }

    pw.Widget labeledLine({
      required String value,
      required pw.Font font,
      double fontSize = 12.5,
      required int flex,
    }) {
      var Colors_pd = PdfColors.black;

      return pw.Expanded(
          flex: flex,
          child: pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: Colors_pd,
                  width: 0.3,
                ),
              ),
            ),
            // padding: const pw.EdgeInsets.only(bottom: -5, top: -5),
            // margin: const pw.EdgeInsets.only(bottom: 5, top: 5),
            //  padding: const pw.EdgeInsets.only(bottom: -3.5),
            child: pw.Text(
              ' ' * 2 + value + ' ' * 2,
              // value,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                  font: font,
                  fontSize: fontSize,
                  fontWeight: pw.FontWeight.bold),
            ),
          ));
    }

    ////
    //// ------------>(J Space Sansai)
    ///////
    final pdf = pw.Document();
    // final fontData = await rootBundle.load("ThaiFonts/Sarabun-Medium.ttf");
    // var dataint = fontData.buffer
    //     .asUint8List(fontData.offsetInBytes, fontData.lengthInBytes);
    // final PdfFont font = PdfFont.of(pdf, data: dataint);
    final font = await rootBundle.load("fonts/THSarabunNew.ttf");
    final font2 = await rootBundle.load("fonts/THSarabunNew.ttf");
    var Colors_pd = PdfColors.black;
    var Colors_pd2 = PdfColors.grey;
    var Colors_pd3 = PdfColors.black;
    final ttf = pw.Font.ttf(font);
    final ttf2 = pw.Font.ttf(font2);
    double font_Size = 12.5;
    int space_Size = 10;
    DateTime date = DateTime.now();
    // var formatter = DateFormat('MMMMd', 'th');
    String thaiDate = DateFormat('d เดือน MMM', 'th').format(date);
    var nFormat = NumberFormat("#,##0.00", "en_US");
    var nFormat2 = NumberFormat("###0.00", "en_US");
    final iconImage =
        (await rootBundle.load('images/LOGO.png')).buffer.asUint8List();
    final ByteData image = await rootBundle.load('images/image7-11.png');
    final ByteData BG_PDF = await rootBundle.load('images/Choice_BG_PDF.png');
    final ByteData LG_PDF = await rootBundle.load('images/choice_logo2.png');
    Uint8List imageData = (image).buffer.asUint8List();
    Uint8List imageBG = (BG_PDF).buffer.asUint8List();
    Uint8List imageLG = (LG_PDF).buffer.asUint8List();
    // List netImage = [];
    // List signature_Image1 = [];
    // List signature_Image2 = [];
    // List signature_Image3 = [];
    // List signature_Image4 = [];
    List footImage = [];
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? Name1_choice = preferences.getString('Name1_choice');
    // String? Name2_choice = preferences.getString('Name2_choice');
    String? Name3_choice = preferences.getString('Name3_choice');
    String? Name4_choice = preferences.getString('Name4_choice');
    int pageCount = 1; // Initialize the page count

    // String? base64Image_3 = preferences.getString('base64Image3');
    // String? base64Image_4 = preferences.getString('base64Image4');
    // String base64Image_new1 = (base64Image_1 == null) ? '' : base64Image_1;
    List newValuePDFimg2 = [
      'https://img.wongnai.com/p/1920x0/2022/05/10/ad606822c67d4c08a2bc6b5125be3861.jpg'
    ];

    // String base64Image_new3 = (base64Image_3 == null) ? '' : base64Image_3;
    // String base64Image_new4 = (base64Image_4 == null) ? '' : base64Image_4;
    // Uint8List data1 = base64Decode(base64Image_new2);
    // Uint8List data2 = base64Decode(base64Image_new2);
    // Uint8List data3 = base64Decode(base64Image_new3);
    // Uint8List data4 = base64Decode(base64Image_new4);
    Uint8List? resizedLogo = await getResizedLogo();
    // for (int i = 0; i < newValuePDFimg.length; i++) {
    //   netImage.add(await networkImage('${newValuePDFimg[i]}'));
    // }
    ////////////--------------------->
    // for (int i = 0; i < newValuePDFimg2.length; i++) {
    //   signature_Image1.add(await networkImage('${newValuePDFimg2[i]}'));
    // }
    // for (int i = 0; i < newValuePDFimg.length; i++) {
    //   signature_Image2.add(await networkImage('${newValuePDFimg[i]}'));
    // }
    // for (int i = 0; i < newValuePDFimg.length; i++) {
    //   signature_Image3.add(await networkImage('${newValuePDFimg[i]}'));
    // }
    // for (int i = 0; i < newValuePDFimg.length; i++) {
    //   signature_Image4.add(await networkImage('${newValuePDFimg[i]}'));
    // }
    var licence_name1 = 'สิริกร พรหมปัญญา';
    var licence_name2 = 'สิริกร พรหมปัญญา';
    var licence_name3 = 'สิริกร พรหมปัญญา';
    var licence_name4 = 'สิริกร พรหมปัญญา';
    var refid = 'LLJZX20241';
    final imageBytes_manager = await loadAndCacheImage(
        '${MyConstant().domain}/gen_licence_img.php?isAdd=true&ren=106&ref_id=$refid&name_id=$licence_name1&doc_id=$Get_Value_cid&extension=.png');
    // final signature_Image1 = await loadAndCacheImage(
    //     '${MyConstant().domain}/gen_licence_img.php?isAdd=true&ren=50&ref_id=$refid&name_id=$licence_name1&doc_id=$Get_Value_cid&extension=.png');
    // final signature_Image2 = await loadAndCacheImage(
    //     '${MyConstant().domain}/gen_licence_img.php?isAdd=true&ren=50&ref_id=$refid&name_id=$licence_name2&doc_id=$Get_Value_cid&extension=.png');
    // final signature_Image3 = await loadAndCacheImage(
    //     '${MyConstant().domain}/gen_licence_img.php?isAdd=true&ren=50&ref_id=$refid&name_id=$licence_name2&doc_id=$Get_Value_cid&extension=.png');
    // final signature_Image4 = await loadAndCacheImage(
    //     '${MyConstant().domain}/gen_licence_img.php?isAdd=true&ren=50&ref_id=$refid&name_id=$licence_name2&doc_id=$Get_Value_cid&extension=.png');

    // final tableData = [
    //   for (int index = 0; index < quotxSelectModels.length; index++)
    //     [
    //       '${nFormat.format(int.parse(quotxSelectModels[index].term!) * double.parse(quotxSelectModels[index].total!))}',
    //     ],
    // ];
    // double Sumtotal = 0;
    // for (int index = 0; index < quotxSelectModels.length; index++)
    //   Sumtotal = Sumtotal +
    //       (int.parse(quotxSelectModels[index].term!) *
    //           double.parse(quotxSelectModels[index].total!));
    int exp_check = 35;

    String Howday = (Form_rtname.toString() == 'รายวัน')
        ? 'วัน'
        : (Form_rtname.toString() == 'รายเดือน')
            ? 'เดือน'
            : (Form_rtname.toString() == 'รายปี')
                ? 'ปี'
                : '$Form_rtname';
    double widths = await MediaQuery.of(context).size.width;
    int pange = 1;

    List<double> data2 = [0.00, 0.00, 0.00];
    String Rent_List = (quotxSelectModels
                .where((e) =>
                    e.expser.toString() == '$exp_check' &&
                    // e.unitser.toString() == '1' &&
                    e.amt_ty.toString() != '')
                .length ==
            0)
        ? '0.00, 0.00, 0.00'
        : quotxSelectModels
            .where((e) =>
                e.expser.toString() == '$exp_check' &&
                // e.unitser.toString() == '1' &&
                e.amt_ty.toString() != '')
            .map((e) => e.amt_ty)
            .toString();

    // Step 1: Remove parentheses
    Rent_List = Rent_List.replaceAll('(', '').replaceAll(')', '');

    // Step 2: Split the string by commas
    List<String> rentStringList = Rent_List.split(',');

    // Step 3: Convert the list of strings to a list of doubles
    List<double> rentList =
        (rentStringList.map((e) => double.parse(e)).toList() == 0)
            ? data2
            : rentStringList.map((e) => double.parse(e)).toList();

///////////////////////------------------------------------------------->

    List<RentGroup> rentGroup = [];

    for (int index = 0; index < rentList.length; index++) {
      String sdate = '';
      String ldate = '';

      if (quotxSelectModels
          .where((e) =>
              e.expser.toString() == '$exp_check' && e.amt_ty.toString() != '')
          .isNotEmpty) {
        DateTime baseDate =
            DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_sdate 00:00:00');

        if (Form_rtname == 'รายวัน') {
          DateTime start = baseDate.add(Duration(days: index));
          DateTime end = baseDate
              .add(Duration(days: index + 1))
              .subtract(const Duration(days: 1));
          sdate =
              '${DateFormat('dd MMM', 'th').format(start)} ${start.year + 543}';
          ldate = '${DateFormat('dd MMM', 'th').format(end)} ${end.year + 543}';
        } else if (Form_rtname == 'รายเดือน') {
          DateTime start =
              DateTime(baseDate.year, baseDate.month + index, baseDate.day);
          DateTime end =
              DateTime(baseDate.year, baseDate.month + index + 1, baseDate.day)
                  .subtract(const Duration(days: 1));
          sdate =
              '${DateFormat('dd MMM', 'th').format(start)} ${start.year + 543}';
          ldate = '${DateFormat('dd MMM', 'th').format(end)} ${end.year + 543}';
        } else if (Form_rtname == 'รายปี') {
          DateTime start =
              DateTime(baseDate.year + index, baseDate.month, baseDate.day);
          DateTime end =
              DateTime(baseDate.year + index + 1, baseDate.month, baseDate.day)
                  .subtract(const Duration(days: 1));
          sdate =
              '${DateFormat('dd MMM', 'th').format(start)} ${start.year + 543}';
          ldate = '${DateFormat('dd MMM', 'th').format(end)} ${end.year + 543}';
        }
      }

      final currentAmount = rentList[index].toStringAsFixed(2);
      final currentAmountText =
          convertToThaiBaht(double.parse(rentList[index].toString()));

      // หาในกลุ่มที่มียอดเดียวกัน
      final existing = rentGroup.indexWhere((e) => e.amount == currentAmount);

      if (existing != -1) {
        // ถ้ามีอยู่แล้ว ให้อัปเดต endDate ของรายการนั้น
        rentGroup[existing] = RentGroup(
          startDate: rentGroup[existing].startDate,
          endDate: ldate, // ใช้ตัวใหม่
          amount: currentAmount,
          amountText: currentAmountText,
        );
      } else {
        // ยังไม่มีก็เพิ่มใหม่
        rentGroup.add(
          RentGroup(
            startDate: sdate,
            endDate: ldate,
            amount: currentAmount,
            amountText: currentAmountText,
          ),
        );
      }
    }
    for (int i = 0; i < rentGroup.length; i++) {
      final g = rentGroup[i];
      // นับลำดับเดือน
      int startMonthIndex = 0;
      int endMonthIndex = 0;

      for (int j = 0, count = 0; j < rentList.length; j++) {
        final amt = rentList[j].toStringAsFixed(2);
        if (amt == g.amount) {
          if (startMonthIndex == 0) {
            startMonthIndex = j + 1; // เดือนแรกที่เจอ
          }
          endMonthIndex = j + 1; // เดือนสุดท้ายที่เจอ
        }
      }

      // print(
      //   'ลำดับที่ ${i + 1}. ตั้งแต่เดือนที่ $startMonthIndex ถึงเดือนที่ $endMonthIndex '
      //   'ยอด ${g.amount} บาท (~${g.amountText}~)',
      // );
    }

    // print('rentGroup.length');
    // print(rentGroup.length);
    // for (int index = 0; index < rentGroup.length; index++) {
    //   print(
    //       'ลำดับที่ ${index + 1}. วันที่ ${rentGroup[index].startDate} ถึง ${rentGroup[index].endDate} ยอด ${rentGroup[index].amount}');
    // }

///////////////////////------------------------------------------------->
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginBottom: 5.00,
          marginLeft: 0.00,
          marginRight: 0.00,
          marginTop: 0.00,
        ),
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: PdfPageFormat.a4.width + 100,
                color: PdfColors.green900,
                height: 13,
              ),
              pw.SizedBox(height: 1 * PdfPageFormat.mm),
              pw.Row(
                children: [
                  pw.Container(
                    width: 30,
                    height: 10,
                  ),
                  pw.Container(
                    height: 60,
                    width: 70,
                    decoration: (resizedLogo != null)
                        ? null
                        : pw.BoxDecoration(
                            color: PdfColors.grey200,
                            border: pw.Border.all(color: PdfColors.grey300),
                          ),
                    child: resizedLogo != null
                        ? pw.Image(
                            pw.MemoryImage(resizedLogo),
                            height: 60,
                            width: 70,
                          )
                        : pw.Center(
                            child: Textx(
                              value: '$bill_name',
                              font: ttf,
                              fontSize: 10,
                            ),
                          ),
                  ),
                  pw.SizedBox(width: 1 * PdfPageFormat.mm),
                  pw.Container(
                    width: 350,
                    child: pw.Column(
                      mainAxisSize: pw.MainAxisSize.min,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        Textx(
                          value: bill_name.toString().trim(),
                          font: ttf,
                        ), //   maxLines: 2,
                        Textx(
                            value: bill_addr.toString().trim(),
                            font: ttf), //   maxLines: 3,
                        Textx(
                            value: 'เลขประจำตัวผู้เสียภาษี : $bill_tax',
                            font: ttf), //   maxLines: 2,
                      ],
                    ),
                  ),
                  pw.Spacer(),
                  if (TitleType_Default_Receipt_Name != null &&
                      TitleType_Default_Receipt_Name.toString().trim() != '')
                    pw.Padding(
                      padding: const pw.EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: pw.Container(
                        width: 80,
                        decoration: pw.BoxDecoration(
                          // color: PdfColors.grey400,
                          borderRadius: const pw.BorderRadius.only(
                              topLeft: pw.Radius.circular(10),
                              topRight: pw.Radius.circular(10),
                              bottomLeft: pw.Radius.circular(10),
                              bottomRight: pw.Radius.circular(10)),
                          border: pw.Border.all(color: Colors_pd3, width: 1),
                        ),
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Center(
                          child: pw.Text(
                            '$TitleType_Default_Receipt_Name',
                            maxLines: 1,
                            style: pw.TextStyle(
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              font: ttf,
                              color: Colors_pd3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (TitleType_Default_Receipt_Name != null &&
                      TitleType_Default_Receipt_Name.toString().trim() != '')
                    pw.Spacer(),
                ],
              ),
              // pw.Text(
              //   'Header - Page ${context.pageNumber} of ${context.pagesCount}',
              //   style:
              //       pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              // ),
              // pw.SizedBox(height: 1 * PdfPageFormat.mm),
              // pw.Divider(height: 2),
              // pw.SizedBox(height: 1 * PdfPageFormat.mm),
              pw.SizedBox(height: 2 * PdfPageFormat.mm),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  (context.pageNumber.toString() == '1')
                      ? Textx(
                          value: 'สัญญาเช่า', font: ttf, fontSize: font_Size)
                      : pw.SizedBox(),
                ],
              ),
              pw.Container(
                width: PdfPageFormat.a4.width,
                padding: const pw.EdgeInsets.fromLTRB(50, 0, 50, 0),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    if (context.pageNumber.toString() == '1')
                      Textx(
                          value: 'สาขา $Form_zn',
                          font: ttf,
                          fontSize: font_Size),
                    pw.Spacer(),
                    pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          if (context.pageNumber.toString() == '1' ||
                              context.pageNumber.toString() == '2') ...[
                            Textx(value: 'ส่วนที่ 1', font: ttf),
                          ],
                          if (context.pageNumber.toString() != '1' &&
                              context.pageNumber.toString() != '2') ...[
                            Textx(value: 'ส่วนที่ 2', font: ttf),
                          ],
                          Textx(
                              value: 'สัญญาเลขที่  $Get_Value_cid', font: ttf),
                          if (context.pageNumber.toString() != '1')
                            pw.SizedBox(height: 2 * PdfPageFormat.mm),
                        ]),
                  ],
                ),
              ),
              // pw.SizedBox(height: 2 * PdfPageFormat.mm),
            ],
          );
        },
        build: (context) {
          return [
            pw.Container(
              decoration: pw.BoxDecoration(
                image: pw.DecorationImage(
                  image: pw.MemoryImage(
                    imageBG,
                  ),
                  fit: pw.BoxFit.fill,
                ),
              ),
              width: PdfPageFormat.a4.width,
              padding: const pw.EdgeInsets.fromLTRB(50, 0, 50, 0),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    children: [
                      pw.Spacer(),
                      pw.Container(
                        width: 180,
                        child: pw.Column(
                          mainAxisSize: pw.MainAxisSize.min,
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            Textx(
                                value: (Form_wnote.toString() == '' ||
                                        Form_wnote == null)
                                    ? 'อ้างอิงสัญญาเดิมเลขที่________________'
                                    : 'อ้างอิงสัญญาเดิมเลขที่ $Form_wnote',
                                font: ttf),
                            Textx(
                                value: 'ทำที่ บริษัท ชอยส์ มินิสโตร์ จำกัด',
                                font: ttf)
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      Textx(
                          value:
                              'วันที่ ${DateFormat('dd MMM', 'th').format(DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_sdate 00:00:00')}"))} ${DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_sdate 00:00:00')}").year + 543}',
                          font: ttf)
                      //   'วันที่ ${DateFormat('dd MMM', 'th').format(DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_sdate 00:00:00')}"))} ${DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_sdate 00:00:00')}").year + 543}',
                      //   // 'วันที่ ${DateFormat('dd MMM', 'TH').format(DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('${Datex_text.text} 00:00:00')}"))} ${DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('${Datex_text.text} 00:00:00')}").year + 543}',
                      //   //  'วันที่  ${Datex_text.text} ',
                    ],
                  ),
                  pw.SizedBox(height: 2 * PdfPageFormat.mm),
                  Textx(value: 'ข้อ 1. รายละเอียดคู่สัญญา', font: ttf),
                  pw.Row(children: [
                    Textx(
                        value:
                            '${' ' * 12}สัญญาฉบับนี้ทำขึ้นระหว่าง   บริษัท ชอยส์ มินิสโตร์ จำกัด   โดย นางฤทัยรัตน์ วิสิทธิ์   และนายวธัญญู ตันตรานนท์   กรรมการผู้มีอำนาจลงนาม',
                        font: ttf)
                  ]),
                  pw.Row(children: [
                    Textx(
                        value:
                            'สำนักงานใหญ่ตั้งอยู่เลขที่  7/2  หมู่ที่  5  ตำบลท่าศาลา  อำเภอเมืองเชียงใหม่  จังหวัดเชียงใหม่  ซึ่งต่อไปในสัญญานี้จะเรียกว่า  “ผู้ให้เช่า”  ฝ่ายหนึ่ง  กับ',
                        font: ttf)
                  ]),
                  pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  pw.Row(
                    children: [
                      labeledLine(
                        value: '$Form_bussshop',
                        font: ttf,
                        fontSize: font_Size,
                        flex: 1,
                      ),
                      Textx(value: 'โดย', font: ttf),
                      labeledLine(
                        value: (_verticalGroupValue.toString() ==
                                'องค์กร/นิติบุคคล')
                            ? " $Form_bussscontact "
                            : " - ",
                        font: ttf,
                        fontSize: font_Size,
                        flex: 1,
                      ),
                      Textx(value: 'ผู้มีอำนาจลงนาม', font: ttf),
                      Textx(value: 'เลขประจำตัว', font: ttf),
                    ],
                  ),
                  pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  pw.Row(
                    children: [
                      Textx(
                          value: 'ประชาชน/ทะเบียนนิติบุคคล เลขที่', font: ttf),
                      pw.Container(
                        child: labeledLine(
                          value: '$Form_tax',
                          font: ttf,
                          fontSize: font_Size,
                          flex: 1,
                        ),
                      ),
                      Textx(value: 'ที่อยู่/สำนักงานใหญ่ ตั้งอยู่', font: ttf),
                      labeledLine(
                        value: '$Form_address',
                        font: ttf,
                        fontSize: font_Size,
                        flex: 2,
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  pw.Row(
                    children: [
                      Textx(value: 'โทรศัพท์', font: ttf),
                      pw.Container(
                        child: labeledLine(
                          value: '$Form_tel',
                          font: ttf,
                          fontSize: font_Size,
                          flex: 1,
                        ),
                      ),
                      Textx(
                          value:
                              'ซึ่งต่อไปในสัญญานี้จะเรียกว่า “ผู้เช่า” อีกฝ่ายหนึ่ง คู่สัญญาได้ตกลงกันมีข้อความดังต่อไปนี้',
                          font: ttf),
                    ],
                  ),
                  pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  Textx(value: 'ข้อ 2. รายละเอียดสถานที่เช่า', font: ttf),
                  pw.Row(
                    children: [
                      Textx(
                          value:
                              '${' ' * 12}ผู้ให้เช่าตกลงให้เช่าและผู้เช่าตกลงเช่า ล็อกเลขที่',
                          font: ttf),
                      labeledLine(
                        value: '$Form_ln',
                        font: ttf,
                        fontSize: font_Size,
                        flex: 2,
                      ),
                      Textx(value: 'ขนาดพื้นที่เช่า', font: ttf),
                      labeledLine(
                        value: '$Form_area',
                        font: ttf,
                        fontSize: font_Size,
                        flex: 1,
                      ),
                      Textx(value: 'ตร.ม.', font: ttf),
                      Textx(value: ' จำนวน', font: ttf),
                      labeledLine(
                        value: '$Form_qty',
                        font: ttf,
                        fontSize: font_Size,
                        flex: 1,
                      ),
                      Textx(value: 'ห้อง', font: ttf),
                    ],
                  ),
                  pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  Textx(value: 'ข้อ 3. วัตถุประสงค์ของการเช่า', font: ttf),
                  pw.Row(
                    children: [
                      Textx(
                          value:
                              '${' ' * 12}ผู้เช่าตกลงเช่าทรัพย์สินที่เช่าเพื่อดำเนินกิจการร้าน',
                          font: ttf),
                      pw.Container(
                        child: labeledLine(
                          value: (Form_typeshop == null ||
                                  Form_typeshop.toString() == 'null')
                              ? "$Form_typeshop"
                              : "$Form_typeshop",
                          // (Form_nameshop == null ||
                          //         Form_nameshop.toString() == 'null')
                          //     ? "$Form_bussshop"
                          //     : "$Form_nameshop",
                          font: ttf,
                          fontSize: font_Size,
                          flex: 1,
                        ),
                      ),
                      Textx(value: 'เท่านั้น', font: ttf),
                    ],
                  ),
                  pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  Textx(
                      value:
                          'ข้อ 4. ระยะเวลาการเช่าและวันส่งมอบทรัพย์สินที่เช่า',
                      font: ttf),
                  pw.Row(
                    children: [
                      Textx(
                          value:
                              '${' ' * 12}คู่สัญญาตกลงเช่าทรัพย์สินตามข้อ 2. สัญญาเริ่มตั้งแต่วันที่',
                          font: ttf),
                      labeledLine(
                          value: (Form_sdate == null)
                              ? ''
                              : '${DateFormat('dd MMM', 'th').format(DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_sdate 00:00:00')}"))} ${DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_sdate 00:00:00')}").year + 543}',
                          // "$Form_sdate", font: ttf, flex: 1)
                          font: ttf,
                          flex: 1),
                      Textx(value: 'ถึงวันที่', font: ttf),
                      labeledLine(
                          value: (Form_ldate == null)
                              ? ''
                              : '${DateFormat('dd MMM', 'th').format(DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_ldate 00:00:00')}"))} ${DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_ldate 00:00:00')}").year + 543}',
                          // "$Form_ldate",
                          font: ttf,
                          flex: 1),
                    ],
                  ),
                  pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  pw.Row(
                    children: [
                      Textx(value: 'ระยะเวลาการเช่า', font: ttf),
                      labeledLine(
                          value: "$FormPeriod_choice", // "$Form_period",
                          font: ttf,
                          flex: 1),
                      Textx(
                          value: (Form_rtname.toString() == 'รายวัน')
                              ? 'วัน และผู้ให้เช่าตกลงส่งมอบทรัพย์สินที่เช่าให้แก่ผู้เช่าครอบครองในวันที่ '
                              : (Form_rtname.toString() == 'รายเดือน')
                                  ? 'เดือน และผู้ให้เช่าตกลงส่งมอบทรัพย์สินที่เช่าให้แก่ผู้เช่าครอบครองในวันที่ '
                                  : (Form_rtname.toString() == 'รายปี')
                                      ? 'ปี และผู้ให้เช่าตกลงส่งมอบทรัพย์สินที่เช่าให้แก่ผู้เช่าครอบครองในวันที่ '
                                      : '$Form_rtname และผู้ให้เช่าตกลงส่งมอบทรัพย์สินที่เช่าให้แก่ผู้เช่าครอบครองในวันที่ ', //  'ปี และผู้ให้เช่าตกลงส่งมอบพื้นที่เช่าให้แก่ผู้เช่าครอบครองในวันที่ ',
                          font: ttf),
                      labeledLine(
                          value: (DatexChoice_Sub2_3text == null)
                              ? '-'
                              : '${DateFormat('dd MMM', 'th').format(DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_sdate 00:00:00')}"))} ${DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_sdate 00:00:00')}").year + 543}',
                          // : '${DateFormat('dd MMM', 'th').format(DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$DatexChoice_Sub2_3text 00:00:00')}"))} ${DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$DatexChoice_Sub2_3text 00:00:00')}").year + 543}',
                          // (Form_ldate == null)
                          //     ? ''
                          //     : '${DateFormat('dd MMM', 'th').format(DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_ldate 00:00:00')}"))} ${DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_ldate 00:00:00')}").year + 543}',
                          // "$Form_ldate",
                          font: ttf,
                          flex: 1),
                    ],
                  ),
                  pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  Textx(
                      value:
                          'หากกรณีผู้เช่าเปิดดำเนินกิจการก่อนวันที่สัญญาเริ่มต้นผู้เช่าจะต้องจ่ายค่าเช่าตามจริง',
                      font: ttf),

                  pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  Textx(value: 'ข้อ 5. อัตราค่าเช่า', font: ttf),
                  Textx(
                      value:
                          '${' ' * 12}ผู้เช่าตกลงชำระค่าเช่าเป็นรายเดือน ให้แก่ผู้ให้เช่า ในอัตราค่าเช่า ดังนี้',
                      font: ttf),
                  // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  ((quotxSelectModels
                              .where((e) =>
                                  e.expser.toString() == '$exp_check' &&
                                  // e.unitser.toString() == '1' &&
                                  e.amt_ty.toString() == '')
                              .length !=
                          0))
                      ? pw.Column(children: [
                          pw.SizedBox(
                              child: pw.Column(
                                  mainAxisAlignment: pw.MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                pw.Row(
                                  children: [
                                    Textx(
                                        value: (Form_rtname.toString() ==
                                                'รายวัน')
                                            ? '${' ' * 12}5.1 อัตราค่าเช่าในวันที่'
                                            : (Form_rtname.toString() ==
                                                    'รายเดือน')
                                                ? '${' ' * 12}5.1 อัตราค่าเช่าในเดือนที่'
                                                : (Form_rtname.toString() ==
                                                        'รายปี')
                                                    ? '${' ' * 12}5.1 อัตราค่าเช่าในปีที่'
                                                    : '${' ' * 12}5.1 อัตราค่าเช่าใน$Form_rtnameที่',
                                        // ' ' * 12 +
                                        //     '5.${index + 1} อัตราค่าเช่าในปีที่',
                                        font: ttf),
                                    pw.Container(
                                      child: labeledLine(
                                          value: '1 - $FormPeriod_choice',
                                          // ((quotxSelectModels
                                          //             .where((e) =>
                                          //                 e.expser.toString() ==
                                          //                     '$exp_check' &&
                                          //                 // e.unitser.toString() == '1' &&
                                          //                 e.amt_ty.toString() !=
                                          //                     '')
                                          //             .length ==
                                          //         0))
                                          //     ? ' '
                                          //     : "  ${index + 1} ",s
                                          font: ttf,
                                          flex: 1),
                                    ),
                                    Textx(value: 'ตั้งแต่วันที่', font: ttf),
                                    labeledLine(
                                        value: (Form_sdate == '0000-00-00' ||
                                                Form_sdate == '' ||
                                                Form_sdate == null)
                                            ? '-'
                                            : '${DateFormat('dd MMM', 'th').format(DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_sdate 00:00:00')}"))} ${DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_sdate 00:00:00')}").year + 543}',
                                        font: ttf,
                                        flex: 1),
                                    Textx(value: 'ถึงวันที่', font: ttf),
                                    labeledLine(
                                        value: (Form_ldate == '0000-00-00' ||
                                                Form_ldate == '' ||
                                                Form_ldate == null)
                                            ? '-'
                                            : '${DateFormat('dd MMM', 'th').format(DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_ldate 00:00:00')}"))} ${DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_ldate 00:00:00')}").year + 543}',
                                        font: ttf,
                                        flex: 1),
                                  ],
                                ),
                                pw.SizedBox(height: 1 * PdfPageFormat.mm),
                                pw.Row(
                                  children: [
                                    Textx(
                                        value: '${' ' * 17}ชำระค่าเช่าเดือนละ',
                                        font: ttf),
                                    pw.Container(
                                      child: labeledLine(
                                          value: (quotxSelectModels
                                                      .where((e) =>
                                                          e.expser.toString() ==
                                                              '$exp_check' &&
                                                          e.unitser
                                                                  .toString() ==
                                                              '2')
                                                      .length ==
                                                  0)
                                              ? ' 0.00'
                                              : ' ${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '$exp_check' && e.unitser.toString() == '2').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b))}',
                                          // ' ${nFormat.format(double.parse(rentGroup[index].amount.toString()))}  บาท (~${rentGroup[index].amountText}~)',
                                          font: ttf,
                                          flex: 1),
                                    ),
                                    Textx(value: 'บาท', font: ttf),
                                    pw.Container(
                                      child: labeledLine(
                                          value:
                                              '( ${convertToThaiBaht(quotxSelectModels.where((e) => e.expser.toString() == '$exp_check' && e.unitser.toString() == '2').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b))} )',
                                          // ' ${nFormat.format(double.parse(rentGroup[index].amount.toString()))}  บาท (~${rentGroup[index].amountText}~)',
                                          font: ttf,
                                          flex: 1),
                                    ),
                                  ],
                                ),
                                pw.SizedBox(height: 1 * PdfPageFormat.mm),
                              ]))
                        ])
                      :
                      // for (int index = 0; index < rentGroup.length; index++)
                      pw.Column(
                          children: List.generate(rentGroup.length, (index) {
                            final g = rentGroup[index];

                            // ค้นหาลำดับเดือนที่เริ่มต้นและสิ้นสุด
                            int startMonthIndex = 0;
                            int endMonthIndex = 0;

                            for (int j = 0; j < rentList.length; j++) {
                              final amt = rentList[j].toStringAsFixed(2);
                              if (amt == g.amount) {
                                if (startMonthIndex == 0) {
                                  startMonthIndex = j + 1;
                                }
                                endMonthIndex = j + 1;
                              }
                            }

                            return pw.SizedBox(
                                child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                  pw.Row(
                                    children: [
                                      pw.Text(
                                        (Form_rtname.toString() == 'รายวัน')
                                            ? '${' ' * 12}5.${index + 1} อัตราค่าเช่าในวันที่'
                                            : (Form_rtname.toString() ==
                                                    'รายเดือน')
                                                ? '${' ' * 12}5.${index + 1} อัตราค่าเช่าในเดือนที่'
                                                : (Form_rtname.toString() ==
                                                        'รายปี')
                                                    ? '${' ' * 12}5.${index + 1} อัตราค่าเช่าในปีที่'
                                                    : '${' ' * 12}5.${index + 1} อัตราค่าเช่าใน$Form_rtnameที่',
                                        // ' ' * 12 +
                                        //     '5.${index + 1} อัตราค่าเช่าในปีที่',
                                        textAlign: pw.TextAlign.left,
                                        style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          color: Colors_pd,
                                        ),
                                      ),
                                      pw.Container(
                                        width: 40,
                                        height: 14,
                                        decoration: pw.BoxDecoration(
                                            border: pw.Border(
                                                bottom: pw.BorderSide(
                                          color: Colors_pd,
                                          width: 0.3, // Underline thickness
                                        ))),
                                        child: pw.Text(
                                          '$startMonthIndex - $endMonthIndex ',
                                          // ((quotxSelectModels
                                          //             .where((e) =>
                                          //                 e.expser.toString() ==
                                          //                     '$exp_check' &&
                                          //                 // e.unitser.toString() == '1' &&
                                          //                 e.amt_ty.toString() !=
                                          //                     '')
                                          //             .length ==
                                          //         0))
                                          //     ? ' '
                                          //     : "  ${index + 1} ",
                                          textAlign: pw.TextAlign.center,
                                          style: pw.TextStyle(
                                            color: Colors_pd,
                                            fontSize: font_Size,
                                            fontWeight: pw.FontWeight.bold,
                                            font: ttf,
                                          ),
                                        ),
                                      ),
                                      pw.Text(
                                        'ตั้งแต่วันที่',
                                        textAlign: pw.TextAlign.left,
                                        style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          color: Colors_pd,
                                        ),
                                      ),
                                      pw.Expanded(
                                          flex: 1,
                                          child: pw.Container(
                                            height: 14,
                                            decoration: pw.BoxDecoration(
                                                border: pw.Border(
                                                    bottom: pw.BorderSide(
                                              color: Colors_pd,
                                              width: 0.3, // Underline thickness
                                            ))),
                                            child: pw.Text(
                                              rentGroup[index].startDate,
                                              textAlign: pw.TextAlign.center,
                                              style: pw.TextStyle(
                                                color: Colors_pd,
                                                fontSize: font_Size,
                                                fontWeight: pw.FontWeight.bold,
                                                font: ttf,
                                              ),
                                            ),
                                          )),
                                      pw.Text(
                                        'ถึงวันที่',
                                        textAlign: pw.TextAlign.left,
                                        style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          color: Colors_pd,
                                        ),
                                      ),
                                      pw.Expanded(
                                          flex: 1,
                                          child: pw.Container(
                                            height: 14,
                                            decoration: pw.BoxDecoration(
                                                border: pw.Border(
                                                    bottom: pw.BorderSide(
                                              color: Colors_pd,
                                              width: 0.3, // Underline thickness
                                            ))),
                                            child: pw.Text(
                                              rentGroup[index].endDate,
                                              textAlign: pw.TextAlign.center,
                                              style: pw.TextStyle(
                                                color: Colors_pd,
                                                fontSize: font_Size,
                                                fontWeight: pw.FontWeight.bold,
                                                font: ttf,
                                              ),
                                            ),
                                          )),
                                    ],
                                  ),
                                  pw.SizedBox(height: 1 * PdfPageFormat.mm),
                                  pw.Row(
                                    children: [
                                      Textx(
                                          value:
                                              '${' ' * 17}ชำระค่าเช่าเดือนละ',
                                          font: ttf),
                                      pw.Container(
                                        child: labeledLine(
                                            value: nFormat.format(double.parse(
                                                rentGroup[index]
                                                    .amount
                                                    .toString())),
                                            font: ttf,
                                            flex: 1),
                                      ),
                                      Textx(value: 'บาท', font: ttf),
                                      pw.Container(
                                        child: labeledLine(
                                            value:
                                                '( ${rentGroup[index].amountText} )',
                                            font: ttf,
                                            flex: 1),
                                      ),
                                    ],
                                  ),
                                  pw.SizedBox(height: 1 * PdfPageFormat.mm),
                                  // (rentList.length == 0 || rentList.length == 3)
                                  //     ? pw.SizedBox(
                                  //         height: 10 * PdfPageFormat.mm)
                                  //     : (rentList.length == 2 ||
                                  //             rentList.length == 1)
                                  //         ? pw.SizedBox(
                                  //             height: 20 * PdfPageFormat.mm)
                                  //         : pw.SizedBox(
                                  //             height: 1 * PdfPageFormat.mm),
                                ]));
                          }),
                        ),

                  // (rentList.length == 0 || rentList.length == 3)
                  //     ? pw.SizedBox(height: 10 * PdfPageFormat.mm)
                  //     : (rentList.length == 2 || rentList.length == 1)
                  //         ? pw.SizedBox(height: 20 * PdfPageFormat.mm)
                  //         : pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  Textx(
                      value:
                          '${' ' * 12}ผู้เช่าต้องชำระค่าเช่าล่วงหน้าตั้งแต่วันที่  25  ถึงวันสุดท้ายของแต่ละเดือน  โดยถือเป็นค่าเช่ารายเดือนของเดือนถัดไป หากผู้เช่าไม่ทำการชำระ',
                      font: ttf),
                  // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  pw.Row(
                    children: [
                      Textx(
                          value:
                              'ภายในเวลาที่กำหนด ผู้ให้เช่ามีสิทธิคิดค่าปรับวันละ ',
                          font: ttf),
                      labeledLine(
                          value: (quotxSelectModels
                                      .where((e) => e.expser.toString() == '17')
                                      .length ==
                                  0)
                              // ? '0.00 (~${convertToThaiBaht(0.00)}~)'
                              ? '0.00'
                              : nFormat.format(quotxSelectModels
                                  .where((e) => e.expser.toString() == '17')
                                  .map((e) => e.amt != null
                                      ? double.parse(e.amt.toString())
                                      : 0.00)
                                  .fold(0.00, (a, b) => a + b)),
                          font: ttf,
                          flex: 1),
                      Textx(value: 'บาท', font: ttf),
                      labeledLine(
                        value:
                            '( ${convertToThaiBaht(quotxSelectModels.where((e) => e.expser.toString() == '17').map((e) => e.amt != null ? double.parse(e.amt.toString()) : 0.00).fold(0.00, (a, b) => a + b))} )',
                        font: ttf,
                        flex: 1,
                      ),
                      Textx(value: 'นับตั้งแต่วันที่เลยกำหนดชำระ', font: ttf),
                    ],
                  ),
                  pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  pw.Row(
                    children: [
                      Textx(
                          value:
                              'และหากผู้เช่ายังไม่ชำระค่าเช่าและค่าปรับภายในวันที่',
                          font: ttf),
                      pw.Container(
                        child: labeledLine(value: '5', font: ttf, flex: 1),
                      ),
                      Textx(
                          value:
                              'ของเดือนถัดไป  ผู้ให้เช่ามีสิทธิบอกเลิกสัญญาได้ทันที',
                          font: ttf),
                    ],
                  ),
                  pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  Textx(value: 'ข้อ 6. เงินประกัน', font: ttf),
                  // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  Textx(value: '${' ' * 12}6.1 ประกันการเช่า', font: ttf),
                  pw.Row(
                    children: [
                      Textx(
                          value:
                              '${' ' * 12}ผู้เช่าจะต้องวางเงินประกันการเช่าแก่ผู้ให้เช่า เป็นจำนวนเงิน',
                          font: ttf),
                      labeledLine(
                          value: (quotxSelectModels
                                      .where((e) => e.expser.toString() == '2')
                                      .length ==
                                  0)
                              ? '-'
                              : nFormat.format(quotxSelectModels
                                  .where((e) => e.expser.toString() == '2')
                                  .map((e) => e.total != null
                                      ? double.parse(e.total.toString())
                                      : 0.00)
                                  .fold(0.00, (a, b) => a + b)),
                          font: ttf,
                          flex: 1),
                      Textx(value: 'บาท', font: ttf),
                      labeledLine(
                          value: (quotxSelectModels
                                  .where((e) => e.expser.toString() == '2')
                                  .isEmpty)
                              ? '( - )'
                              : "(${convertToThaiBaht(
                                  quotxSelectModels
                                      .where((e) => e.expser.toString() == '2')
                                      .map((e) => e.total != null
                                          ? double.parse(e.total.toString())
                                          : 0.00)
                                      .fold(0.00, (a, b) => a + b),
                                )})",
                          font: ttf,
                          flex: 1),
                    ],
                  ),
                  pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  pw.Row(
                    children: [
                      Textx(
                          value:
                              'โดยเงินจำนวนดังกล่าว เป็นเงินมาจาก ประกันการเช่าจากสัญญาเดิม สัญญาเลขที่',
                          font: ttf),
                      labeledLine(
                          value: (Get_Value_cid.toString() ==
                                  Form_renew_cid.toString())
                              ? '-'
                              : '$Form_renew_cid',
                          font: ttf,
                          flex: 1),
                    ],
                  ),
                  pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  pw.Row(
                    children: [
                      Textx(value: 'จำนวน', font: ttf),
                      labeledLine(
                          value: (Get_Value_cid.toString() ==
                                  Form_renew_cid.toString())
                              ? "-"
                              : (Form_PakanAll_Total == null ||
                                      Form_PakanAll_Total.toString() == '')
                                  ? '0.00'
                                  : nFormat.format(
                                      double.parse('$Form_PakanAll_Total')),
                          font: ttf,
                          flex: 1),
                      Textx(value: 'บาท', font: ttf),
                      labeledLine(
                          value: (Get_Value_cid.toString() ==
                                  Form_renew_cid.toString())
                              ? '( - )'
                              : "(${convertToThaiBaht(Form_PakanAll_Total != null && Form_PakanAll_Total.toString() != '' ? double.parse(Form_PakanAll_Total.toString()) : 0.00)})",
                          font: ttf,
                          flex: 1),
                      Textx(
                          value: 'และผู้เช่าทำการวางเงินประกันการเช่าเพิ่มอีก',
                          font: ttf),
                    ],
                  ),
                  pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  pw.Row(
                    children: [
                      Textx(value: 'จำนวน', font: ttf),
                      pw.Container(
                        width: 50,
                        child: labeledLine(value: ' - ', font: ttf, flex: 1),
                      ),
                      Textx(value: 'บาท', font: ttf),
                      pw.Container(
                        width: 50,
                        child: labeledLine(value: '( - )', font: ttf, flex: 1),
                      ),
                      Textx(value: 'โดยมีกำหนดชำระภายในวันที่', font: ttf),
                      pw.Container(
                        width: 100,
                        child: labeledLine(value: ' - ', font: ttf, flex: 1),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  Textx(value: '${' ' * 12}6.2 ประกันการตกแต่ง', font: ttf),
                  pw.Row(
                    children: [
                      Textx(
                          value:
                              '${' ' * 12}ผู้เช่าทำการตกแต่งอาคารที่เช่า ไม่ว่าจะเป็นภายนอกอาคาร  หรือภายในอาคารก็ตาม  ผู้เช่าจะต้องวางเงินประกันการตกแต่งให้แก่ผู้ให้เช่าเป็น',
                          font: ttf),
                    ],
                  ),
                  pw.Row(
                    children: [
                      Textx(value: 'จำนวน', font: ttf),
                      pw.Container(
                        width: 100,
                        child: labeledLine(value: ' - ', font: ttf, flex: 1),
                      ),
                      Textx(value: 'บาท', font: ttf),
                      pw.Container(
                        width: 100,
                        child: labeledLine(value: "( - )", font: ttf, flex: 1),
                      ),
                      Textx(value: 'โดยมีกำหนดชำระ ภายในวันที่', font: ttf),
                      pw.Container(
                        width: 100,
                        child: labeledLine(value: ' - ', font: ttf, flex: 1),
                      ),
                    ],
                  ),
                  // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  // pw.NewPage(),
                  pw.SizedBox(height: 10 * PdfPageFormat.mm),

                  Textx(
                      value: 'ข้อ 7. ค่าเช่าสาธารณูปโภคและการชำระ', font: ttf),
                  Textx(
                      value:
                          '${' ' * 12}ผู้เช่าตกลงชำระค่าสาธารณูปโภคตลอดอายุสัญญาให้แก่ผู้ให้เช่า ตามรายการใบแจ้งหนี้ของทางผู้ให้เช่า ดังนี้ ',
                      font: ttf),
                  Textx(value: '${' ' * 12}7.1 อัตราค่าไฟฟ้า', font: ttf),
                  pw.Row(
                    children: [
                      Textx(
                          value:
                              '${' ' * 12}- ค่าธรรมเนียมในการขอใช้มิเตอร์ไฟฟ้าครั้งแรก จำนวน',
                          font: ttf),
                      labeledLine(
                          value: (quotxSelectModels
                                      .where((e) => e.expser.toString() == '20')
                                      .length ==
                                  0)
                              ? ' - '
                              : nFormat.format(quotxSelectModels
                                  .where((e) => e.expser.toString() == '20')
                                  .map((e) => e.total != null &&
                                          e.total.toString() != ''
                                      ? double.parse(e.total.toString())
                                      : 0.00)
                                  .reduce((a, b) => a + b)),
                          font: ttf,
                          flex: 1),
                      Textx(value: 'บาท', font: ttf),
                      labeledLine(
                        value: (quotxSelectModels
                                .where((e) => e.expser.toString() == '20')
                                .isEmpty)
                            ? '( - )'
                            : '(${convertToThaiBaht(quotxSelectModels.where((e) => e.expser.toString() == '20').map((e) => e.total != null && e.total.toString() != '' ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b))})',
                        font: ttf,
                        flex: 1,
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  pw.Row(
                    children: [
                      Textx(value: '${' ' * 12}- ค่าไฟฟ้า หน่วยละ', font: ttf),
                      pw.Container(
                        child: labeledLine(
                            value: (quotxSelectModels
                                        .where(
                                            (e) => e.expser.toString() == '6')
                                        .length ==
                                    0)
                                ? '0.00 บาท '
                                : " ${quotxSelectModels.where((model) => model.expser == '6').map((model) => model.qty).join(', ')}",
                            font: ttf,
                            flex: 1),
                      ),
                      Textx(value: 'บาท', font: ttf),
                      pw.Container(
                        child: labeledLine(
                          value: (quotxSelectModels
                                  .where((e) => e.expser.toString() == '6')
                                  .isEmpty)
                              ? '( - )'
                              : '(${convertToThaiBaht(
                                  quotxSelectModels
                                      .where((e) => e.expser.toString() == '6')
                                      .map((e) => e.qty != null
                                          ? double.tryParse(e.qty.toString()) ??
                                              0.00
                                          : 0.00)
                                      .fold(0.00, (a, b) => a + b),
                                )})',
                          font: ttf,
                          flex: 1,
                        ),
                      ),
                      Textx(value: 'พร้อมภาษีมูลค่าเพิ่ม', font: ttf),
                    ],
                  ),
                  pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  pw.Row(
                    children: [
                      Textx(
                          value:
                              '${' ' * 12}- ค่าไฟฟ้า “แบบเหมาจ่าย” ในอัตราเดือนละ',
                          font: ttf),
                      pw.Container(
                        width: 50,
                        child: labeledLine(value: ' - ', font: ttf, flex: 1),
                      ),
                      Textx(value: 'บาท', font: ttf),
                      pw.Container(
                        width: 50,
                        child: labeledLine(value: '( - )', font: ttf, flex: 1),
                      ),
                      Textx(value: 'พร้อมภาษีมูลค่าเพิ่ม', font: ttf),
                    ],
                  ),
                  pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  Textx(value: '${' ' * 12}7.2 ค่าน้ำประปา ', font: ttf),
                  pw.Row(
                    children: [
                      Textx(
                          value:
                              '${' ' * 12}ค่าธรรมเนียมในการขอใช้มิเตอร์น้ำประปาครั้งแรก จำนวน',
                          font: ttf),
                      labeledLine(
                          value: (quotxSelectModels
                                      .where((e) => e.expser.toString() == '21')
                                      .length ==
                                  0)
                              ? ' - '
                              : nFormat.format(quotxSelectModels
                                  .where((e) => e.expser.toString() == '21')
                                  .map((e) => e.total != null &&
                                          e.total.toString() != ''
                                      ? double.parse(e.total.toString())
                                      : 0.00)
                                  .reduce((a, b) => a + b)),
                          font: ttf,
                          flex: 1),
                      Textx(value: 'บาท', font: ttf),
                      labeledLine(
                        value: (quotxSelectModels
                                .where((e) => e.expser.toString() == '21')
                                .isEmpty)
                            ? '( - )'
                            : '(${convertToThaiBaht(quotxSelectModels.where((e) => e.expser.toString() == '21').map((e) => e.total != null && e.total.toString() != '' ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b))})',
                        font: ttf,
                        flex: 1,
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  pw.Row(
                    children: [
                      Textx(
                          value: '${' ' * 12}- ค่าน้ำประปา หน่วยละ', font: ttf),
                      pw.Container(
                        child: labeledLine(
                            value: (quotxSelectModels
                                        .where(
                                            (e) => e.expser.toString() == '7')
                                        .length ==
                                    0)
                                ? '0.00 บาท'
                                : " ${quotxSelectModels.where((model) => model.expser == '7').map((model) => model.qty).join(', ')}",
                            font: ttf,
                            flex: 1),
                      ),
                      Textx(value: 'บาท', font: ttf),
                      pw.Container(
                        child: labeledLine(
                          value: (quotxSelectModels
                                  .where((e) => e.expser.toString() == '7')
                                  .isEmpty)
                              ? '( - )'
                              : '(${convertToThaiBaht(
                                  quotxSelectModels
                                      .where((e) => e.expser.toString() == '7')
                                      .map((e) => e.qty != null
                                          ? double.tryParse(e.qty.toString()) ??
                                              0.00
                                          : 0.00)
                                      .fold(0.00, (a, b) => a + b),
                                )})',
                          font: ttf,
                          flex: 1,
                        ),
                      ),
                      Textx(value: 'พร้อมภาษีมูลค่าเพิ่ม', font: ttf),
                    ],
                  ),
                  pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  pw.Row(
                    children: [
                      Textx(
                          value:
                              '${' ' * 12}- ค่าน้ำประปา “แบบเหมาจ่าย” ในอัตราเดือนละ',
                          font: ttf),
                      pw.Container(
                          width: 50,
                          child: labeledLine(value: ' - ', font: ttf, flex: 1)),
                      Textx(value: 'บาท', font: ttf),
                      pw.Container(
                          width: 50,
                          child:
                              labeledLine(value: '( - )', font: ttf, flex: 1)),
                      Textx(value: 'พร้อมภาษีมูลค่าเพิ่ม', font: ttf),
                    ],
                  ),
                  pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  Textx(value: 'ข้อ 8. ค่าบริการพื้นที่ส่วนกลาง', font: ttf),
                  Textx(
                      value:
                          '${' ' * 12}ผู้เช่าตกลงชำระค่าบริการพื้นที่ส่วนกลางรายเดือนพร้อมภาษีมูลค่าเพิ่ม ตามอัตราที่ผู้ให้เช่ากำหนด ดังนี้',
                      font: ttf),
                  pw.Row(children: [
                    Textx(value: '${' ' * 12}ตั้งแต่วันที่', font: ttf),
                    labeledLine(value: ' - ', font: ttf, flex: 1),
                    Textx(value: 'ถึงวันที่', font: ttf),
                    labeledLine(value: ' - ', font: ttf, flex: 1),
                    Textx(value: 'ในอัตราเดือนละ', font: ttf),
                    labeledLine(value: ' - ', font: ttf, flex: 1),
                    Textx(
                        value: 'บาท/ตารางเมตร/เดือน  เป็นจำนวนเงิน', font: ttf),
                  ]),
                  pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  pw.Row(children: [
                    Textx(value: '${' ' * 12}เดือนละ', font: ttf),
                    pw.Container(
                      width: 50,
                      child: labeledLine(value: ' - ', font: ttf, flex: 1),
                    ),
                    Textx(value: 'บาท โดยมีกำหนดชำระภายในวันที่', font: ttf),
                    pw.Container(
                      width: 50,
                      child: labeledLine(value: ' - ', font: ttf, flex: 1),
                    ),
                  ]),
                  pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  Textx(
                      value: 'ข้อ 9. ภาษีที่ดินสิ่งปลูกสร้าง และภาษีอื่นๆ',
                      font: ttf),
                  pw.Row(children: [
                    Textx(
                        value:
                            '${' ' * 12}ผู้เช่าตกลงรับภาระในภาษีที่ดินและสิ่งปลูกสร้าง  และภาษีอื่นใดที่เกี่ยวข้องกับทรัพย์สินที่เช่า  หรือเกิดจากการประกอบกิจการของผู้เช่าตามกฎ',
                        font: ttf),
                  ]),
                  pw.Row(children: [
                    Textx(
                        value: '${' ' * 12}หมายเป็นรายเดือน เดือนละ',
                        font: ttf),
                    labeledLine(value: ' - ', font: ttf, flex: 1),
                    Textx(value: 'บาท', font: ttf),
                    labeledLine(value: '( - )', font: ttf, flex: 1),
                    Textx(value: ') /รายปี ปีละ', font: ttf),
                    labeledLine(value: ' - ', font: ttf, flex: 1),
                    Textx(value: 'บาท', font: ttf),
                    labeledLine(value: '( - )', font: ttf, flex: 1),
                  ]),
                  pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  pw.Row(children: [
                    Textx(
                        value: '${' ' * 12}โดยมีกำหนดชำระภายในวันที่',
                        font: ttf),
                    pw.Container(
                      width: 100,
                      child: labeledLine(value: ' - ', font: ttf, flex: 1),
                    ),
                  ]),

                  pw.SizedBox(height: 10 * PdfPageFormat.mm),
                  pw.Row(children: [
                    pw.Expanded(
                        flex: 1,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Container(
                              width: 200,
                              padding: const pw.EdgeInsets.fromLTRB(4, 0, 4, 0),
                              child: pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.center,
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                // mainAxisAlignment:
                                //     pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text(
                                    'ลงชื่อ',
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                  pw.Expanded(
                                      flex: 2,
                                      child: pw.Container(
                                        // width: 120,
                                        decoration: const pw.BoxDecoration(
                                          // color: PdfColors.green100,
                                          border: pw.Border(
                                            bottom: pw.BorderSide(
                                                width: 0.5,
                                                color: PdfColors.grey600),
                                          ),
                                        ),
                                        padding: const pw.EdgeInsets.all(8.0),
                                        height: 30,
                                      )),
                                  pw.Text(
                                    'ผู้ให้เช่า',
                                    textAlign: pw.TextAlign.left,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 2 * PdfPageFormat.mm),
                            pw.Text(
                              '( ${Name1_choice.toString()} ) ',
                              // '( นางฤทัยรัตน์ วิสิทธิ์ และ นายวธัญญู ตันตรานนท์ ) ',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                color: Colors_pd,
                                fontSize: font_Size,
                                font: ttf2,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        )),
                    pw.SizedBox(width: 5 * PdfPageFormat.mm),
                    pw.Expanded(
                        flex: 1,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Container(
                              width: 200,
                              // decoration: const pw.BoxDecoration(
                              //   // color: PdfColors.green100,
                              //   border: pw.Border(
                              //     bottom: pw.BorderSide(
                              //         width: 0.5, color: PdfColors.grey600),
                              //   ),
                              // ),
                              padding: const pw.EdgeInsets.fromLTRB(4, 0, 4, 0),
                              child: pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.center,
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                // mainAxisAlignment:
                                //     pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text(
                                    'ลงชื่อ',
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                  pw.Expanded(
                                      flex: 2,
                                      child: pw.Container(
                                        // width: 120,
                                        decoration: const pw.BoxDecoration(
                                          // color: PdfColors.green100,
                                          border: pw.Border(
                                            bottom: pw.BorderSide(
                                                width: 0.5,
                                                color: PdfColors.grey600),
                                          ),
                                        ),
                                        padding: const pw.EdgeInsets.all(8.0),
                                        height: 30,
                                      )),
                                  pw.Text(
                                    'ผู้เช่า',
                                    textAlign: pw.TextAlign.left,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 2 * PdfPageFormat.mm),
                            pw.Text(
                              (_verticalGroupValue.toString() ==
                                      'องค์กร/นิติบุคคล')
                                  ? "( $Form_bussscontact )"
                                  : "( $Form_bussshop )",
                              // '( $Form_bussshop ) ',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                color: Colors_pd,
                                fontSize: font_Size,
                                font: ttf2,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        )),
                  ]),
                  pw.SizedBox(height: 10 * PdfPageFormat.mm),
                  pw.Row(children: [
                    pw.Expanded(
                        flex: 1,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Container(
                              width: 200,
                              padding: const pw.EdgeInsets.fromLTRB(4, 0, 4, 0),
                              child: pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.center,
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                // mainAxisAlignment:
                                //     pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text(
                                    'ลงชื่อ',
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                  pw.Expanded(
                                      flex: 2,
                                      child: pw.Container(
                                        // width: 120,
                                        decoration: const pw.BoxDecoration(
                                          // color: PdfColors.green100,
                                          border: pw.Border(
                                            bottom: pw.BorderSide(
                                                width: 0.5,
                                                color: PdfColors.grey600),
                                          ),
                                        ),
                                        padding: const pw.EdgeInsets.all(8.0),
                                        height: 30,
                                      )),
                                  pw.Text(
                                    'พยาน',
                                    textAlign: pw.TextAlign.left,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 2 * PdfPageFormat.mm),
                            pw.Text(
                              '( ${Name3_choice.toString()} ) ',
                              // '( นางสาวชนิดาพร ส่งเจริญ ) ',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                color: Colors_pd,
                                fontSize: font_Size,
                                font: ttf2,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        )),
                    pw.SizedBox(width: 5 * PdfPageFormat.mm),
                    pw.Expanded(
                        flex: 1,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Container(
                              width: 200,
                              // decoration: const pw.BoxDecoration(
                              //   // color: PdfColors.green100,
                              //   border: pw.Border(
                              //     bottom: pw.BorderSide(
                              //         width: 0.5, color: PdfColors.grey600),
                              //   ),
                              // ),
                              padding: const pw.EdgeInsets.fromLTRB(4, 0, 4, 0),
                              child: pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.center,
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                // mainAxisAlignment:
                                //     pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text(
                                    'ลงชื่อ',
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                  pw.Expanded(
                                      flex: 2,
                                      child: pw.Container(
                                        // width: 120,
                                        decoration: const pw.BoxDecoration(
                                          // color: PdfColors.green100,
                                          border: pw.Border(
                                            bottom: pw.BorderSide(
                                                width: 0.5,
                                                color: PdfColors.grey600),
                                          ),
                                        ),
                                        padding: const pw.EdgeInsets.all(8.0),
                                        height: 30,
                                      )),
                                  pw.Text(
                                    'พยาน',
                                    textAlign: pw.TextAlign.left,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 2 * PdfPageFormat.mm),
                            pw.Text(
                              (Name4_choice == null ||
                                      Name4_choice.toString() == '' ||
                                      Name4_choice.toString() == 'null')
                                  ? '(___________________________) '
                                  : '( ${Name4_choice.toString()} ) ',
                              // '(___________________________) ',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                color: Colors_pd,
                                fontSize: font_Size,
                                font: ttf,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        )),
                  ]),
                ],
              ),
            ),
            pw.NewPage(),

            // --------------------------------------------------------------------------------------- >
            //                                        [ ส่วนที่ 2 ]
            // --------------------------------------------------------------------------------------- >

            pw.Container(
              decoration: pw.BoxDecoration(
                image: pw.DecorationImage(
                  image: pw.MemoryImage(
                    imageBG,
                  ),
                  fit: pw.BoxFit.fill,
                ),
              ),
              width: PdfPageFormat.a4.width,
              padding: const pw.EdgeInsets.fromLTRB(50, 0, 50, 0),
              child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // pw.SizedBox(height: 2 * PdfPageFormat.mm),
                    Textx(value: 'ข้อ 1. การต่ออายุสัญญา', font: ttf),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}1.1 ผู้ให้เช่ามีสิทธิกำหนดอัตราค่าเช่าใหม่เพิ่มขึ้นทุกๆ ปี ปีละไม่เกิน ',
                          font: ttf),
                      pw.Container(
                        child: labeledLine(value: ' 10% ', font: ttf, flex: 1),
                      )
                    ]),
                    pw.SizedBox(height: 1 * PdfPageFormat.mm),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}1.2 หากครบกำหนดอายุสัญญาเช่านี้แล้ว ผู้เช่ามีความประสงค์จะต่ออายุสัญญา ผู้เช่าต้องแจ้งความจำนงเป็นลายลักษณ์อักษรให้ผู้ให้เช่าทราบล่วง',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}หน้าไม่น้อยกว่า 90 วัน ก่อนสิ้นสุดอายุสัญญาเช่านี้ ผู้ให้เช่าจะพิจารณาให้ผู้เช่าเช่าต่อไปหรือไม่ก็ได้  หากให้เช่าต่อ  ผู้เช่าจะต้องทำสัญญาฉบับใหม่',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}กับผู้ให้เช่าทุกคราวที่มีการต่อสัญญาก่อนสัญญานี้จะสิ้นสุดลง   หากผู้เช่าไม่แจ้งความจำนงว่าจะขอเช่าต่อหรือผู้เช่าไม่ทำสัญญาฉบับใหม่กับผู้ให้เช่า',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}ก่อนที่สัญญานี้จะสิ้นสุดลง ให้ถือว่าไม่มีการเช่าต่อภายหลังครบกำหนดอายุสัญญานี้กันอีกต่อไป',
                          font: ttf),
                    ]),
                    pw.SizedBox(height: 1 * PdfPageFormat.mm),
                    Textx(
                        value: 'ข้อ 2. ข้อรับรองและสัญญาของผู้เช่า', font: ttf),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}2.1 ผู้เช่าจะต้องดูแลรักษาทรัพย์สินที่เช่าเสมือนวิญญูชนจะพึงดูแลรักษาทรัพย์ของตนและผู้เช่าจะต้องเป็นผู้เสียค่าใช้จ่ายใน   การบำรุงรักษาและ',
                          font: ttf),
                    ]),
                    Textx(
                        value: '${' ' * 12}ซ่อมแซมอาคารที่เช่าเอง', font: ttf),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}2.2 ผู้เช่าจะต้องไม่นำวัตถุไวไฟหรือวัตถุอันตรายอื่นใดมาเก็บรักษาไว้ในอาคารที่เช่า พร้อมจัดเตรียมถังดับเพลิงให้เหมาะสม หากเกิดความเสียอัน',
                          font: ttf),
                    ]),
                    Textx(
                        value:
                            '${' ' * 12}สืบเนื่องจากความผิดของผู้เช่าเอง ต้องชดใช้ค่าเสียหายทั้งหมดที่เกิดขึ้น',
                        font: ttf),
                    Textx(
                        value:
                            '${' ' * 12}2.3 ผู้เช่าจะต้องไม่กระทำการใดๆ ให้เป็นที่รบกวนหรือก่อให้เกิดความรำคาญแก่เจ้าของอาคารข้างเคียง',
                        font: ttf),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}2.4 ผู้เช่าจะไม่ตกแต่ง ดัดแปลง ต่อเติม ภายในและภายนอกอาคารสถานที่เช่าดังกล่าวโดยปราศจากการอนุมัติจากผู้ให้เช่าก่อนเท่านั้น  หากผู้เช่า',
                          font: ttf),
                    ]),
                    Textx(
                        value:
                            '${' ' * 12}ไม่ปฏิบัติดังกล่าว ทั้งนี้ผู้เช่าจะต้องรับผิดชดใช้ค่าใช้จ่ายที่เกิดขึ้นทั้งหมด ',
                        font: ttf),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}2.5 ผู้เช่าต้องรับผิดชอบและชดใช้ค่าใช้จ่ายทั้งปวงอันเกี่ยวกับอุบัติเหตุ  หรือความเสียหายใด ๆ ต่อบุคคลทรัพย์สิน ซึ่งเกิดในหรือจากสถานที่เช่า',
                          font: ttf),
                    ]),
                    Textx(
                        value:
                            '${' ' * 12}หรือการดำเนินงานในสถานที่เช่าของผู้เช่า นับตั้งแต่วันที่ผู้เช่าเข้าครอบครองพื้นที่',
                        font: ttf),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}2.6 การติดตั้งป้ายชื่อร้าน ป้ายโฆษณา ภาษีป้าย หรือสิ่งใดๆ ก็ตามของผู้เช่าที่แสดงต่อสาธารณชน  อันเกิดจากการประกอบกิจการของผู้เช่า ต้อง',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}ได้รับความยินยอมจากผู้ให้เช่าเสียก่อน    หากฝ่าฝืนผู้ให้เช่ามีสิทธิที่จะถอดถอนป้ายที่มิได้รับอนุญาตนั้นออกโดยมิต้องรับผิดชอบต่อความเสียหาย',
                          font: ttf),
                    ]),
                    Textx(
                        value: '${' ' * 12}และสูญหายใดๆ ที่เกิดขึ้นแก่ผู้เช่า',
                        font: ttf),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}2.7 ผู้ให้เช่าหรือตัวแทนมีสิทธิเข้าไปและตรวจตราในสถานที่เช่าได้ตลอด ผู้เช่า ลูกจ้างและบริวารของผู้เช่าจะต้องอำนวยความสะดวกให้แก่ผู้ให้เช่า',
                          font: ttf),
                    ]),
                    Textx(value: '${' ' * 12}หรือตัวแทนเสมอ', font: ttf),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}2.8 ผู้เช่าจะต้องไม่ประกอบกิจการในลักษณะเดียวกันหรือคล้ายคลึงกันกับกิจการของผู้ให้เช่าในการประกอบการค้าประเภทมินิมาร์ท, คอนวีเนี่ยน',
                          font: ttf),
                    ]),
                    Textx(
                        value:
                            '${' ' * 12}สโตร์ หรือซุปเปอร์มาร์เก็ต รวมตลอดทั้งกิจการที่ผู้ให้เช่าเห็นว่ามีลักษณะในทำนองเดียวกันกับธุรกิจการค้าของผู้ให้เช่าเป็นอันขาด',
                        font: ttf),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}2.9 เงินประกันการชำระค่าเช่า  และประกันการปฏิบัติตามสัญญานี้  รวมถึงค่าเสียหายใดๆ ที่ผู้เช่าต้องรับผิดตามสัญญานี้ โดยหากมีการต่อสัญญา',
                          font: ttf),
                    ]),
                    Textx(
                        value:
                            '${' ' * 12}แล้วผู้ให้เช่าปรับอัตราค่าเช่าเพิ่มขึ้น ผู้เช่าจะต้องวางเงินประกันเพิ่มตามการปรับอัตราค่าเช่า',
                        font: ttf),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}อนึ่ง เมื่อสัญญานี้สิ้นสุดลงผู้เช่าได้ส่งมอบสถานที่เช่าคืนให้แก่ผู้ให้เช่าและผู้เช่าได้ตรวจรับมอบสถานที่เช่าเรียบร้อยแล้วไม่ปรากฎความเสียหายใดๆ',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}ผู้ให้เช่าจะคืนเงินประกันการเช่าดังกล่าวโดยไม่มีดอกเบี้ยให้แก่ผู้เช่าภายในระยะเวลา  45  วัน  กรณีที่ผู้เช่ามี',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}หนี้สินที่ค้างชำระต่อผู้ให้เช่า ผู้ให้เช่ามีสิทธิหักเงินประกันนี้ได้ และหากยังมีเงินเหลืออยู่  ผู้ให้เช่าจะคืนให้แก่ผู้เช่า  แต่หากหักหนี้สินที่ค้างชำระจาก',
                          font: ttf),
                    ]),
                    Textx(
                        value:
                            '${' ' * 12}เงินประกันแล้ว ยังไม่คุ้มกับเงินที่ผู้เช่าค้างชำระ ผู้ให้เช่ามีสิทธิเรียกร้องจากผู้เช่าจนครบ',
                        font: ttf),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}2.10  ผู้เช่าจะต้องจัดทำประกันภัยประเภท  "การเสี่ยงภัยทรัพย์สิน (All Risk Insurance)" ในโครงสร้างอาคารของทรัพย์สินที่เช่า  และประกันภัย',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}ความรับผิดตามกฎหมายต่อบุคคลภายนอก กับบริษัทประกันภัยที่ผู้ให้เช่าจัดหาให้ หรือบริษัทประกันภัยที่ผู้เช่าจัดหามาเองของ  โดยผู้เช่าเป็นผู้รับ',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}ภาระเรื่องค่าใช้จ่าย และคำเนินการให้กรมธรรม์ดังกล่าวมีผลคุ้มครองตั้งแต่วันที่ผู้เช่ารับมอบทรัพยสินที่เช่า จนถึงตลอดระยะเวลาการเช่า และระบุ',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}ให้ผู้ให้เช่าเป็นผู้รับผลประ โยชน์ตลอดอายุสัญญาเช่าทั้งนี้ผู้เช่าต้องส่งมอบสำเนากรมธรรม์ประกันภัยที่จัดทำหรือกรมธรรม์ประกันภัยต่ออายุให้กับ',
                          font: ttf),
                    ]),
                    Textx(
                        value:
                            '${' ' * 12}ผู้ให้เช่าด้วยเมื่อได้รับการร้องขอจากผู้ให้เช่า',
                        font: ttf),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}2.11 กรณีที่ผู้เช่าชำระค่าไฟฟ้าและค่าประปาแก่การไฟฟ้าและการประปาส่วนภูมิภาคผู้เช่าต้องชำระค่าไฟฟ้าและค่าประปาที่ใช้ในสถานที่เช่าตลอด',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}อายุสัญญา ตามรายการใบแจ้งค่าไฟฟ้าของการไฟฟ้าส่วนภูมิภาค  และใบแจ้งค่าประปาของการประปาส่วนภูมิภาค  โดยผู้เช่าช่วงจะต้องทำการส่ง',
                          font: ttf),
                    ]),
                    Textx(
                        value:
                            '${' ' * 12}สำเนารายการใบแจ้งค่าไฟฟ้าและประปาปา พร้อมหลักฐานการจำผู้ให้เช่าช่วงทุกๆ เดือน',
                        font: ttf),
                    pw.SizedBox(height: 8 * PdfPageFormat.mm),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}2.12 การชำระเงินประกันการตกแต่ง  ขณะที่ผู้เช่าทำการตกแต่งอาคารที่เช่า ไม่ว่าจะเป็นภายนอกอาคาร หรือภายในอาคารก็ตาม กรณีเกิดความ',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}เสียหายใดๆ อันเกิดจากการตกแต่งที่ผู้เช่าต้องรับผิดตามสัญญานี้หรือหากความเสียหายยังไม่เพียงพอผู้ให้เช่ามีสิทธิเรียกค่าเสียหายเพิ่มเติมจนกว่า',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}จะได้รับชำระจนครบถ้วนเมื่อผู้เช่าทำการตกแต่งอาคารที่เช่าเสร็จสิ้นแล้วผู้ให้เช่าจะคืนเงินประกันการตกแต่งภายใน 45 วัน นับตั้งแต่ตัวแทนของ',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}ผู้ให้เช่าได้ทำการตรวจสอบความเสียหายเรียบร้อยและไม่ปรากฏความเสียหายใด ๆ อันเกิดจากการตกแต่งอาคารที่เช่า',
                          font: ttf),
                    ]),
                    Textx(
                        value:
                            '${' ' * 12}2.13 ผู้ให้เช่าตกลงให้บริการ และผู้เช่าตกลงรับบริการต่างๆ โดยผู้เช่าเป็นผู้รับภาระค่าบริการดังต่อไปนี้',
                        font: ttf),
                    Textx(
                        value:
                            '${' ' * 12}-  การจัดให้มีระบบไฟฟ้า แสงสว่างบริเวณภายนอกสถานที่เช่าภายในบริเวณโครงการ',
                        font: ttf),
                    Textx(
                        value:
                            '${' ' * 12}-  การจัดให้มีระบบน้ำประปาบริเวณภายนอกสถานที่เช่าภายในบริเวณโครงการ',
                        font: ttf),
                    Textx(
                        value: '${' ' * 12}-  การจัดให้มีบริการที่จอดรถ',
                        font: ttf),
                    Textx(
                        value:
                            '${' ' * 12}-  การจัดให้มีแม่บ้านและบริการบำรุงรักษาความสะอาดบริเวณภายนอกสถานที่เช่า',
                        font: ttf),
                    Textx(
                        value:
                            '${' ' * 12}-  จัดให้มีบริการบำรุงรักษาและซ่อมแซมห้องสุขาของโครงการเพื่อประโยชน์ของสถานที่เช่า',
                        font: ttf),
                    Textx(
                        value:
                            '${' ' * 12}-  จัดให้มีการตกแต่ง ซ่อมแซม และบริการอื่นๆ ที่จำเป็นในบริเวณภายนอกสถานที่เช่าที่ผู้ให้เช่าเห็นว่าเหมาะสม',
                        font: ttf),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}2.14 ผู้เช่าตกลงรับภาระในภาษีที่ดินและสิ่งปลูกสร้าง  และภาษีอื่นใดที่เกี่ยวข้องกับทรัพย์สินที่เช่า  หรือเกิดจากการประกอบกิจการของผู้เช่า ซึ่ง',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}จะต้องชำระตามอัตราที่กฎหมายกำหนดในแต่ละปี ตั้งแต่วันที่เริ่มสัญญาตลอดจนสิ้นอายุของสัญญานี้ หากผู้เช่ามิได้ชำระค่าภาษีใดๆ หรือได้ชำระ',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}แล้ว แต่ขาดเงินไปจำนวนเท่าใด และผู้เช่าได้ชำระค่าภาษีนั้นให้แล้ว  ผู้เช่าจะต้องชดใช้ค่าภาษีที่ผู้ให้เช่าได้ชำระให้ทั้งหมดให้ผู้เช่าช่วง ภายในเวลา',
                          font: ttf),
                    ]),
                    pw.SizedBox(height: 1 * PdfPageFormat.mm),
                    Textx(
                        value: 'ข้อ 3. กรณีบอกเลิกหรือสิ้นสุดสัญญา', font: ttf),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}3.1 หากการประกอบธุรกิจการค้าของผู้เช่าไม่เป็นไปตามเป้าหมาย  และผู้เช่าต้องการบอกเลิกสัญญาเช่าก่อนครบกำหนดตามสัญญา  จะต้องบอก',
                          font: ttf),
                    ]),
                    Textx(
                        value:
                            '${' ' * 12}กล่าวแก่ผู้ให้เช่าไม่น้อยกว่า 90 วัน โดยผู้ให้เช่ามีสิทธิเรียกค่าเสียหายอันเกิดแต่การบอกเลิกสัญญาดังกล่าว และริบเงินประกันการเช่าทั้งหมด',
                        font: ttf),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}3.2 หากผู้เช่าผิดสัญญาเช่าข้อหนึ่งข้อใด หรือถูกยึดทรัพย์บังคับคดี หรือถูกฟ้องให้เป็นบุคคลล้มละลาย ผู้ให้เช่า มีสิทธิเลิกสัญญาเช่าได้ทันทีโดยไม่',
                          font: ttf),
                    ]),
                    Textx(
                        value: '${' ' * 12}ต้องบอกกล่าวก่อนล่วงหน้า',
                        font: ttf),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}3.3 ผู้เช่าจะไม่นำทรัพย์สินที่เช่าหรือแบ่งสถานที่เช่าให้บุคคลอื่นเช่าช่วงต่อ รวมทั้งเปลี่ยนแปลงประเภทกิจการ ตลอดจนชื่อทางการค้าต่างจากเดิม',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}โดยปราศจากการอนุมัติจากผู้ให้เช่าก่อน  และไม่ประกอบกิจการอันนำมาซึ่งความเสียหายและเป็นที่ต้องห้ามของกฎหมาย ผู้ให้เช่ามีสิทธิบอกเลิก',
                          font: ttf),
                    ]),

                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}3.4 ผู้เช่าจะไม่ใช้พื้นที่เกินกว่าที่ระบุไว้ในสัญญาเช่านี้  หากฝ่าฝืนและผู้ให้เช่าตรวจพบว่าใช้พื้นที่เกินจากสัญญาผู้ให้เช่ามีสิทธิบอกเลิกสัญญา  หรือ',
                          font: ttf),
                    ]),
                    Textx(value: '${' ' * 12}ปรับได้', font: ttf),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}3.5 หากผู้เช่าไม่เริ่มประกอบกิจการค้าในสถานที่เช่าภายในกำหนดเวลาวันเริ่มสัญญาเช่านี้ให้ถือว่าผู้เช่าผิดสัญญาและผู้ให้เช่ามีสิทธิบอกเลิกสัญญา',
                          font: ttf),
                    ]),
                    Textx(
                        value: '${' ' * 12}และยึดเงินประกันการเช่านี้ได้',
                        font: ttf),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}3.6 เมื่อสัญญาเช่านี้สิ้นสุดลงไม่ว่าจะเนื่องจากสาเหตุประการใดก็ตามรวมทั้งเนื่องจากการครบอายุของสัญญาเช่า ถ้าผู้ให้เช่าประสงค์ให้ผู้เช่ารื้อถอน',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}บรรดาสิ่งแก้ไขเปลี่ยนแปลงเพิ่มเติมออกไป  ผู้เช่าจะต้องรื้อถอนปรับปรุงพื้นที่เพื่อส่งมอบพื้นที่เช่า  และอุปกรณ์ทั้งหมดให้คืนสู่สภาพเดิมด้วยค่าใช้',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}จ่ายของผู้เช่าเอง หากผู้เช่าไม่รื้อถอนปรับปรุง ผู้ให้เช่ามีสิทธิเข้าไปรื้อถอนปรับปรุงสถานที่เช่าได้เองโดยผู้เช่าเป็นผู้รับผิดชอบค่าใช้จ่ายให้แก่ผู้ให้เช่า',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}3.7 ผู้เช่าต้องขนย้ายทรัพย์สินและบริวารออกไปจากสถานที่เช่าให้เสร็จเรียบร้อยภายใน 15 วัน  นับแต่วันที่สัญญาเช่าสิ้นสุดลง  กรณีที่ผู้เช่าต้องรื้อ',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}ถอนปรับปรุงพื้นที่ สถานที่เช่าให้กลับคืนสู่สภาพเดิม ผู้เช่าต้องดำเนินการให้แล้วเสร็จภายใน 30 วัน  นับแต่วันที่สัญญาเช่าสิ้นสุดลง และหากพ้นกำ',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}หนดระยะเวลาตามที่กล่าวมาข้างต้น  แล้วผู้เช่ายังไม่ขนย้ายทรัพย์สิน บริวาร และ/หรือ รื้อถอนปรับปรุงพื้นที่  สถานที่เช่าให้กลับคืนสู่สภาพเดิมให้',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}แล้วเสร็จตามสัญญา ผู้เช่าตกลงชำระค่าปรับในอัตราวันละ  1,000   บาท (หนึ่งพันบาทถ้วน) โดยหากผู้เช่ายังคงปล่อยทิ้งทรัพย์สินไว้ในพื้นที่เช่าให้',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}ทรัพย์สินนั้นตกเป็นกรรมสิทธิ์ของผู้ให้เช่าทันที โดยให้ผู้ให้เช่า มีสิทธิ จำหน่าย จ่าย โอน หรือจัดการทรัพย์สิน ยึดเงินประกัน',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}ตลอดจนเรียกร้องค่าใช้จ่าย  อันเกิดแต่การจัดการทรัพย์สินของผู้เช่า และ/หรือรื้อถอน ปรับปรุงพื้นที่สถานที่เช่าให้กลับคืนสู่สภาพเดิมจากผู้เช่าโดย',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}ผู้เช่าไม่มีสิทธิเรียกร้องทรัพย์สิน หรือเรียกร้องค่าเสียหายใด ๆ ทั้งสิ้นจากผู้ให้เช่า',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}3.8 หากผู้ให้เช่าช่วงมีความจำเป็นต้องใช้ประโยชน์ในสถานที่เช่าช่วง ผู้ให้เช่าช่วงสามารถใช้สิทธิบอกเลิกสัญญาเช่าก่อนครบกำหนดสัญญานี้ได้ โดย',
                          font: ttf),
                    ]),
                    Textx(
                        value:
                            '${' ' * 12}จะแจ้งให้ผู้เช่าทราบล่วงหน้าไม่น้อยกว่า 1 เดือน',
                        font: ttf),
                    pw.SizedBox(height: 10 * PdfPageFormat.mm),
                    Textx(
                        value: 'ข้อ 4. การแจ้งการประมวลผลข้อมูลส่วนบุคคล',
                        font: ttf),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}4.1 การเก็บ และใช้ข้อมูลส่วนบุคคล  ผู้ให้เช่าได้เก็บรวบรวมและหรือใช้ข้อมูลส่วนบุคคลของผู้เช่าได้แก่  สำเนาบัตรประจำตัวประชาชน  ,สำเนา',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}ทะเบียนบ้าน ,สำเนาบัญชีธนาคารเอกสารสำคัญใด ๆ  ที่มีข้อมูลส่วนบุคคล (“ข้อมูลส่วนบุคคล”) เป็นระยะเวลาทั้งหมด 10 ปี (สิบปี) นับจากวันที่',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}สัญญาฉบับนี้สิ้นสุดลงโดยมีวัตถุประสงค์เพื่อตรวจสอบความเป็นตัวตนของผู้เช่าเป็นหลักฐานในการก่อตั้งสิทธิเรียกร้องและเพื่อใช้ตามวัตถุประสงค์',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}ตามสัญญาฉบับนี้เรียกร้อง  และเพื่อใช้ตามวัตถุประสงค์ตามสัญญาฉบับนี้เท่านั้น  โดยไม่นำข้อมูลส่วนบุคคลดังกล่าวไปใช้เพื่อวัตถุประสงค์อื่นใด',
                          font: ttf),
                    ]),
                    Textx(
                        value: '${' ' * 12}นอกจากสัญญาฉบับนี้แต่อย่างใด',
                        font: ttf),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}ทั้งนี้ หากผู้เช่าไม่ส่งมอบข้อมูลส่วนบุคคลดังกล่าวแก่ผู้ให้เช่า  จะทำให้การจัดทำสัญญาฉบับนี้ไม่สมบูรณ์ อันเป็นฐานการประมวลผลเพื่อเป็นการ',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}จำเป็นเพื่อการปฏิบัติตามสัญญาและเป็นการจำเป็นเพื่อประโยชน์โดยชอบด้วยกฎหมาย ตามมาตรา 24 (3),(5)ของพระราชบัญญัติคุ้มครองข้อมูล',
                          font: ttf),
                    ]),
                    Textx(value: '${' ' * 12}ส่วนบุคคล พ.ศ. 2562', font: ttf),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}ทั้งนี้ผู้เช่าในฐานะเจ้าของข้อมูลส่วนบุคคลรับทราบว่าตนเองมีสิทธิดังนี้ (1) สิทธิในการเข้าถึงและรับสำเนาข้อมูลส่วนบุคคลที่ผู้ให้เช่าได้ทำการเก็บ',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}รวบรวมและหรือใช้ได้   ตลอดจนสิทธิในการคัดค้าน  การประมวลผลข้อมูลส่วนบุคคล (2)  เมื่อพ้นระยะเวลาทั้งหมด  10 ปี (สิบปี)  นับจากวันที่',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}สัญญาฉบับนี้สิ้นสุดลง  ผู้ให้เช่าจะทำการลบหรือทำลายข้อมูลส่วนบุคคล (3)  สิทธิในการขอให้ผู้ให้เช่าระงับการใช้ข้อมูลส่วนบุคคล  หากผู้ให้เช่า',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}ได้ใช้ข้อมูลส่วนบุคคลไม่เป็นไป ตามวัตถุประสงค์ตามวรรคแรกข้างต้น (4) สิทธิในการขอแก้ไขข้อมูลส่วนบุคคลให้ถูกต้องเป็นปัจจุบัน สมบูรณ์และ',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}ไม่ก่อให้เกิดความเข้าใจผิด  (5)  สิทธิในการร้องเรียนผู้ให้เช่า  การใช้สิทธิข้างต้นจะต้องจัดทำเป็นลายลักษณ์อักษรและแจ้งต่อผู้ให้เช่าภายในระยะ',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}เวลาอันสมควร และไม่เกินระยะเวลาที่กฎหมายกำหนดโดยผู้ให้เช่าจะปฏิบัติตามข้อกำหนดทางกฎหมายที่เกี่ยวข้องกับสิทธิของเจ้าของข้อมูลส่วน',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}บุคคล และผู้ให้เช่าขอสงวนสิทธิ์ในการคิดค่าบริการใดๆ ที่เกี่ยวข้องและจำเป็นต่อการใช้สิทธิดังกล่าว',
                          font: ttf),
                    ]),
                    Textx(value: '  4.2 การเปิดเผยข้อมูลส่วนบุคคล', font: ttf),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}เพื่อประโยชน์ของผู้เช่าตามวัตถุประสงค์ในสัญญาเช่า  ผู้ให้บริการอาจเปิดเผยข้อมูลของผู้เช่าให้กับหน่วยงานอื่นของผู้ให้เช่า  รวมถึงบริษัทในเครือ',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}และบริษัทย่อย เพื่อวัตถุประสงค์ในการปฏิบัติตามภาระผูกพันตามสัญญาประโยชน์ที่ชอบด้วยกฎหมาย การปฏิบัติตามกฎหมาย และวัตถุประสงค์',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}อื่น ๆ ภายใต้กฎหมายไทยผู้เช่ารับทราบว่าหากมี   เหตุร้องเรียนเกี่ยวกับข้อมูลส่วนบุคคลสามารถติดต่อประสานงานมายังเจ้าหน้าที่คุ้มครองข้อมูล',
                          font: ttf),
                    ]),
                    Textx(
                        value: '${' ' * 12}ส่วนบุคคลได้ในช่องทางดังนี้',
                        font: ttf),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}เจ้าหน้าที่คุ้มครองข้อมูลส่วนบุคคล  (Data Protection Officer: DPO)  /   ผู้ควบคุมข้อมูลส่วนบุคคล (Data Controller)บริษัท ชอยส์ มินิสโตร์',
                          font: ttf),
                    ]),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}จำกัด เลขที่ 7/2 หมู่ที่ 5 ตำบลท่าศาลา อำเภอเมืองเชียงใหม่ จังหวัดเชียงใหม่ 50000Email Address : privacy@choice.co.th',
                          font: ttf),
                    ]),
                    pw.SizedBox(height: 1 * PdfPageFormat.mm),
                    Textx(value: 'ข้อ 5. การบอกกล่าว', font: ttf),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}การบอกกล่าวตามสัญญานี้ หากฝ่ายหนึ่งฝ่ายใดได้ทำเป็นหนังสือและจัดส่งทางไปรษณีย์ลงทะเบียนไปยังคู่สัญญาอีกฝ่ายหนึ่ง ตามที่อยู่ที่ระบุไว้ข้าง',
                          font: ttf),
                    ]),
                    Textx(
                        value:
                            'ต้นในสัญญานี้ ให้ถือว่าเป็นการบอกกล่าวที่ชอบด้วยกฎหมาย และคู่สัญญาอีกฝ่ายหนึ่งได้รับทราบแล้ว',
                        font: ttf),
                    pw.SizedBox(height: 2 * PdfPageFormat.mm),
                    pw.Row(children: [
                      Textx(
                          value:
                              '${' ' * 12}สัญญานี้ทำขึ้นเป็น  2  ฉบับ  มีข้อความถูกต้องตรงกันทุกประการ  ทั้งสองฝ่ายต่างได้อ่านและเข้าใจข้อความทั้งหมดในสัญญาดีโดยตลอดเห็นว่าถูก',
                          font: ttf),
                    ]),
                    Textx(
                        value:
                            'ต้องตามเจตนาและความประสงค์ทุกประการแล้ว จึงได้ลงลายมือชื่อไว้เป็นหลักฐานต่อหน้าพยาน และต่างเก็บรักษาไว้ฝ่ายละ 1 ฉบับ',
                        font: ttf),
                    pw.SizedBox(height: 10 * PdfPageFormat.mm),
                    pw.Row(children: [
                      pw.Expanded(
                          flex: 1,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              pw.Container(
                                width: 200,
                                padding:
                                    const pw.EdgeInsets.fromLTRB(4, 0, 4, 0),
                                child: pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.center,
                                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                                  // mainAxisAlignment:
                                  //     pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text(
                                      'ลงชื่อ',
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: font_Size,
                                        font: ttf,
                                        fontWeight: pw.FontWeight.bold,
                                        color: Colors_pd,
                                      ),
                                    ),
                                    pw.Expanded(
                                        flex: 2,
                                        child: pw.Container(
                                          // width: 120,
                                          decoration: const pw.BoxDecoration(
                                            // color: PdfColors.green100,
                                            border: pw.Border(
                                              bottom: pw.BorderSide(
                                                  width: 0.5,
                                                  color: PdfColors.grey600),
                                            ),
                                          ),
                                          padding: const pw.EdgeInsets.all(8.0),
                                          height: 30,
                                        )),
                                    pw.Text(
                                      'ผู้ให้เช่า',
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                        fontSize: font_Size,
                                        font: ttf,
                                        fontWeight: pw.FontWeight.bold,
                                        color: Colors_pd,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              pw.SizedBox(height: 2 * PdfPageFormat.mm),
                              pw.Text(
                                '( ${Name1_choice.toString()} ) ',
                                // '( นางฤทัยรัตน์ วิสิทธิ์ และ นายวธัญญู ตันตรานนท์ ) ',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  color: Colors_pd,
                                  fontSize: font_Size,
                                  font: ttf2,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          )),
                      pw.SizedBox(width: 5 * PdfPageFormat.mm),
                      pw.Expanded(
                          flex: 1,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              pw.Container(
                                width: 200,
                                // decoration: const pw.BoxDecoration(
                                //   // color: PdfColors.green100,
                                //   border: pw.Border(
                                //     bottom: pw.BorderSide(
                                //         width: 0.5, color: PdfColors.grey600),
                                //   ),
                                // ),
                                padding:
                                    const pw.EdgeInsets.fromLTRB(4, 0, 4, 0),
                                child: pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.center,
                                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                                  // mainAxisAlignment:
                                  //     pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text(
                                      'ลงชื่อ',
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        fontSize: font_Size,
                                        font: ttf,
                                        fontWeight: pw.FontWeight.bold,
                                        color: Colors_pd,
                                      ),
                                    ),
                                    pw.Expanded(
                                        flex: 2,
                                        child: pw.Container(
                                          // width: 120,
                                          decoration: const pw.BoxDecoration(
                                            // color: PdfColors.green100,
                                            border: pw.Border(
                                              bottom: pw.BorderSide(
                                                  width: 0.5,
                                                  color: PdfColors.grey600),
                                            ),
                                          ),
                                          padding: const pw.EdgeInsets.all(8.0),
                                          height: 30,
                                        )),
                                    pw.Text(
                                      'ผู้เช่า',
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                        fontSize: font_Size,
                                        font: ttf,
                                        fontWeight: pw.FontWeight.bold,
                                        color: Colors_pd,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              pw.SizedBox(height: 2 * PdfPageFormat.mm),
                              pw.Text(
                                (_verticalGroupValue.toString() ==
                                        'องค์กร/นิติบุคคล')
                                    ? "( $Form_bussscontact )"
                                    : "( $Form_bussshop )",
                                // '( $Form_bussshop ) ',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  color: Colors_pd,
                                  fontSize: font_Size,
                                  font: ttf2,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          )),
                    ]),
                    pw.SizedBox(height: 10 * PdfPageFormat.mm),
                    pw.Row(
                      children: [
                        pw.Expanded(
                            flex: 1,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Container(
                                  width: 200,
                                  padding:
                                      const pw.EdgeInsets.fromLTRB(4, 0, 4, 0),
                                  child: pw.Row(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.end,
                                    // mainAxisAlignment:
                                    //     pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text(
                                        'ลงชื่อ',
                                        textAlign: pw.TextAlign.right,
                                        style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: Colors_pd,
                                        ),
                                      ),
                                      pw.Expanded(
                                          flex: 2,
                                          child: pw.Container(
                                            // width: 120,
                                            decoration: const pw.BoxDecoration(
                                              // color: PdfColors.green100,
                                              border: pw.Border(
                                                bottom: pw.BorderSide(
                                                    width: 0.5,
                                                    color: PdfColors.grey600),
                                              ),
                                            ),
                                            padding:
                                                const pw.EdgeInsets.all(8.0),
                                            height: 30,
                                          )),
                                      pw.Text(
                                        'พยาน',
                                        textAlign: pw.TextAlign.left,
                                        style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: Colors_pd,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                pw.SizedBox(height: 2 * PdfPageFormat.mm),
                                pw.Text(
                                  '( ${Name3_choice.toString()} ) ',
                                  // '( นางสาวชนิดาพร ส่งเจริญ ) ',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    color: Colors_pd,
                                    fontSize: font_Size,
                                    font: ttf2,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            )),
                        pw.SizedBox(width: 5 * PdfPageFormat.mm),
                        pw.Expanded(
                            flex: 1,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Container(
                                  width: 200,
                                  // decoration: const pw.BoxDecoration(
                                  //   // color: PdfColors.green100,
                                  //   border: pw.Border(
                                  //     bottom: pw.BorderSide(
                                  //         width: 0.5, color: PdfColors.grey600),
                                  //   ),
                                  // ),
                                  padding:
                                      const pw.EdgeInsets.fromLTRB(4, 0, 4, 0),
                                  child: pw.Row(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.end,
                                    // mainAxisAlignment:
                                    //     pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text(
                                        'ลงชื่อ',
                                        textAlign: pw.TextAlign.right,
                                        style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: Colors_pd,
                                        ),
                                      ),
                                      pw.Expanded(
                                          flex: 2,
                                          child: pw.Container(
                                            // width: 120,
                                            decoration: const pw.BoxDecoration(
                                              // color: PdfColors.green100,
                                              border: pw.Border(
                                                bottom: pw.BorderSide(
                                                    width: 0.5,
                                                    color: PdfColors.grey600),
                                              ),
                                            ),
                                            padding:
                                                const pw.EdgeInsets.all(8.0),
                                            height: 30,
                                          )),
                                      pw.Text(
                                        'พยาน',
                                        textAlign: pw.TextAlign.left,
                                        style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: Colors_pd,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                pw.SizedBox(height: 2 * PdfPageFormat.mm),
                                pw.Text(
                                  (Name4_choice == null ||
                                          Name4_choice.toString() == '' ||
                                          Name4_choice.toString() == 'null')
                                      ? '(___________________________) '
                                      : '( ${Name4_choice.toString()} ) ',
                                  // '(___________________________) ',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    color: Colors_pd,
                                    fontSize: font_Size,
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ),
                  ]), //
            ),
            // pw.NewPage(),

            // pw.Container(
            //     decoration: pw.BoxDecoration(
            //       image: pw.DecorationImage(
            //         image: pw.MemoryImage(
            //           imageBG,
            //         ),
            //         fit: pw.BoxFit.fill,
            //       ),
            //     ),
            //     width: PdfPageFormat.a4.width,
            //     padding: const pw.EdgeInsets.fromLTRB(50, 0, 50, 0),
            //     child: pw.Column(
            //         mainAxisAlignment: pw.MainAxisAlignment.start,
            //         crossAxisAlignment: pw.CrossAxisAlignment.start,
            //         children: [
            //           // pw.Row(children: [
            //           //   Textx(
            //           //       value:
            //           //           '${' ' * 12}สัญญานี้ทำขึ้นเป็น  2  ฉบับ  มีข้อความถูกต้องตรงกันทุกประการ  ทั้งสองฝ่ายต่างได้อ่านและเข้าใจข้อความทั้งหมดในสัญญาดีโดยตลอดเห็นว่าถูก',
            //           //       font: ttf),
            //           // ]),
            //           // Textx(
            //           //     value:
            //           //         'ต้องตามเจตนาและความประสงค์ทุกประการแล้ว จึงได้ลงลายมือชื่อไว้เป็นหลักฐานต่อหน้าพยาน และต่างเก็บรักษาไว้ฝ่ายละ 1 ฉบับ',
            //           //     font: ttf),
            //           // pw.SizedBox(height: 10 * PdfPageFormat.mm),
            //           // pw.Row(children: [
            //           //   pw.Expanded(
            //           //       flex: 1,
            //           //       child: pw.Column(
            //           //         crossAxisAlignment: pw.CrossAxisAlignment.center,
            //           //         children: [
            //           //           pw.Container(
            //           //             width: 200,
            //           //             padding:
            //           //                 const pw.EdgeInsets.fromLTRB(4, 0, 4, 0),
            //           //             child: pw.Row(
            //           //               mainAxisAlignment:
            //           //                   pw.MainAxisAlignment.center,
            //           //               crossAxisAlignment:
            //           //                   pw.CrossAxisAlignment.end,
            //           //               // mainAxisAlignment:
            //           //               //     pw.MainAxisAlignment.spaceBetween,
            //           //               children: [
            //           //                 pw.Text(
            //           //                   'ลงชื่อ',
            //           //                   textAlign: pw.TextAlign.right,
            //           //                   style: pw.TextStyle(
            //           //                     fontSize: font_Size,
            //           //                     font: ttf,
            //           //                     fontWeight: pw.FontWeight.bold,
            //           //                     color: Colors_pd,
            //           //                   ),
            //           //                 ),
            //           //                 pw.Expanded(
            //           //                     flex: 2,
            //           //                     child: pw.Container(
            //           //                       // width: 120,
            //           //                       decoration: const pw.BoxDecoration(
            //           //                         // color: PdfColors.green100,
            //           //                         border: pw.Border(
            //           //                           bottom: pw.BorderSide(
            //           //                               width: 0.5,
            //           //                               color: PdfColors.grey600),
            //           //                         ),
            //           //                       ),
            //           //                       padding:
            //           //                           const pw.EdgeInsets.all(8.0),
            //           //                       height: 30,
            //           //                     )),
            //           //                 pw.Text(
            //           //                   'ผู้ให้เช่า',
            //           //                   textAlign: pw.TextAlign.left,
            //           //                   style: pw.TextStyle(
            //           //                     fontSize: font_Size,
            //           //                     font: ttf,
            //           //                     fontWeight: pw.FontWeight.bold,
            //           //                     color: Colors_pd,
            //           //                   ),
            //           //                 ),
            //           //               ],
            //           //             ),
            //           //           ),
            //           //           pw.SizedBox(height: 2 * PdfPageFormat.mm),
            //           //           pw.Text(
            //           //             '( ${Name1_choice.toString()} ) ',
            //           //             // '( นางฤทัยรัตน์ วิสิทธิ์ และ นายวธัญญู ตันตรานนท์ ) ',
            //           //             textAlign: pw.TextAlign.center,
            //           //             style: pw.TextStyle(
            //           //               color: Colors_pd,
            //           //               fontSize: font_Size,
            //           //               font: ttf2,
            //           //               fontWeight: pw.FontWeight.bold,
            //           //             ),
            //           //           ),
            //           //         ],
            //           //       )),
            //           //   pw.SizedBox(width: 5 * PdfPageFormat.mm),
            //           //   pw.Expanded(
            //           //       flex: 1,
            //           //       child: pw.Column(
            //           //         crossAxisAlignment: pw.CrossAxisAlignment.center,
            //           //         children: [
            //           //           pw.Container(
            //           //             width: 200,
            //           //             // decoration: const pw.BoxDecoration(
            //           //             //   // color: PdfColors.green100,
            //           //             //   border: pw.Border(
            //           //             //     bottom: pw.BorderSide(
            //           //             //         width: 0.5, color: PdfColors.grey600),
            //           //             //   ),
            //           //             // ),
            //           //             padding:
            //           //                 const pw.EdgeInsets.fromLTRB(4, 0, 4, 0),
            //           //             child: pw.Row(
            //           //               mainAxisAlignment:
            //           //                   pw.MainAxisAlignment.center,
            //           //               crossAxisAlignment:
            //           //                   pw.CrossAxisAlignment.end,
            //           //               // mainAxisAlignment:
            //           //               //     pw.MainAxisAlignment.spaceBetween,
            //           //               children: [
            //           //                 pw.Text(
            //           //                   'ลงชื่อ',
            //           //                   textAlign: pw.TextAlign.right,
            //           //                   style: pw.TextStyle(
            //           //                     fontSize: font_Size,
            //           //                     font: ttf,
            //           //                     fontWeight: pw.FontWeight.bold,
            //           //                     color: Colors_pd,
            //           //                   ),
            //           //                 ),
            //           //                 pw.Expanded(
            //           //                     flex: 2,
            //           //                     child: pw.Container(
            //           //                       // width: 120,
            //           //                       decoration: const pw.BoxDecoration(
            //           //                         // color: PdfColors.green100,
            //           //                         border: pw.Border(
            //           //                           bottom: pw.BorderSide(
            //           //                               width: 0.5,
            //           //                               color: PdfColors.grey600),
            //           //                         ),
            //           //                       ),
            //           //                       padding:
            //           //                           const pw.EdgeInsets.all(8.0),
            //           //                       height: 30,
            //           //                     )),
            //           //                 pw.Text(
            //           //                   'ผู้เช่า',
            //           //                   textAlign: pw.TextAlign.left,
            //           //                   style: pw.TextStyle(
            //           //                     fontSize: font_Size,
            //           //                     font: ttf,
            //           //                     fontWeight: pw.FontWeight.bold,
            //           //                     color: Colors_pd,
            //           //                   ),
            //           //                 ),
            //           //               ],
            //           //             ),
            //           //           ),
            //           //           pw.SizedBox(height: 2 * PdfPageFormat.mm),
            //           //           pw.Text(
            //           //             (_verticalGroupValue.toString() ==
            //           //                     'องค์กร/นิติบุคคล')
            //           //                 ? "( $Form_bussscontact )"
            //           //                 : "( $Form_bussshop )",
            //           //             // '( $Form_bussshop ) ',
            //           //             textAlign: pw.TextAlign.center,
            //           //             style: pw.TextStyle(
            //           //               color: Colors_pd,
            //           //               fontSize: font_Size,
            //           //               font: ttf2,
            //           //               fontWeight: pw.FontWeight.bold,
            //           //             ),
            //           //           ),
            //           //         ],
            //           //       )),
            //           // ]),
            //           // pw.SizedBox(height: 10 * PdfPageFormat.mm),
            //           // pw.Row(
            //           //   children: [
            //           //     pw.Expanded(
            //           //         flex: 1,
            //           //         child: pw.Column(
            //           //           crossAxisAlignment:
            //           //               pw.CrossAxisAlignment.center,
            //           //           children: [
            //           //             pw.Container(
            //           //               width: 200,
            //           //               padding: const pw.EdgeInsets.fromLTRB(
            //           //                   4, 0, 4, 0),
            //           //               child: pw.Row(
            //           //                 mainAxisAlignment:
            //           //                     pw.MainAxisAlignment.center,
            //           //                 crossAxisAlignment:
            //           //                     pw.CrossAxisAlignment.end,
            //           //                 // mainAxisAlignment:
            //           //                 //     pw.MainAxisAlignment.spaceBetween,
            //           //                 children: [
            //           //                   pw.Text(
            //           //                     'ลงชื่อ',
            //           //                     textAlign: pw.TextAlign.right,
            //           //                     style: pw.TextStyle(
            //           //                       fontSize: font_Size,
            //           //                       font: ttf,
            //           //                       fontWeight: pw.FontWeight.bold,
            //           //                       color: Colors_pd,
            //           //                     ),
            //           //                   ),
            //           //                   pw.Expanded(
            //           //                       flex: 2,
            //           //                       child: pw.Container(
            //           //                         // width: 120,
            //           //                         decoration:
            //           //                             const pw.BoxDecoration(
            //           //                           // color: PdfColors.green100,
            //           //                           border: pw.Border(
            //           //                             bottom: pw.BorderSide(
            //           //                                 width: 0.5,
            //           //                                 color: PdfColors.grey600),
            //           //                           ),
            //           //                         ),
            //           //                         padding:
            //           //                             const pw.EdgeInsets.all(8.0),
            //           //                         height: 30,
            //           //                       )),
            //           //                   pw.Text(
            //           //                     'พยาน',
            //           //                     textAlign: pw.TextAlign.left,
            //           //                     style: pw.TextStyle(
            //           //                       fontSize: font_Size,
            //           //                       font: ttf,
            //           //                       fontWeight: pw.FontWeight.bold,
            //           //                       color: Colors_pd,
            //           //                     ),
            //           //                   ),
            //           //                 ],
            //           //               ),
            //           //             ),
            //           //             pw.SizedBox(height: 2 * PdfPageFormat.mm),
            //           //             pw.Text(
            //           //               '( ${Name3_choice.toString()} ) ',
            //           //               // '( นางสาวชนิดาพร ส่งเจริญ ) ',
            //           //               textAlign: pw.TextAlign.center,
            //           //               style: pw.TextStyle(
            //           //                 color: Colors_pd,
            //           //                 fontSize: font_Size,
            //           //                 font: ttf2,
            //           //                 fontWeight: pw.FontWeight.bold,
            //           //               ),
            //           //             ),
            //           //           ],
            //           //         )),
            //           //     pw.SizedBox(width: 5 * PdfPageFormat.mm),
            //           //     pw.Expanded(
            //           //         flex: 1,
            //           //         child: pw.Column(
            //           //           crossAxisAlignment:
            //           //               pw.CrossAxisAlignment.center,
            //           //           children: [
            //           //             pw.Container(
            //           //               width: 200,
            //           //               // decoration: const pw.BoxDecoration(
            //           //               //   // color: PdfColors.green100,
            //           //               //   border: pw.Border(
            //           //               //     bottom: pw.BorderSide(
            //           //               //         width: 0.5, color: PdfColors.grey600),
            //           //               //   ),
            //           //               // ),
            //           //               padding: const pw.EdgeInsets.fromLTRB(
            //           //                   4, 0, 4, 0),
            //           //               child: pw.Row(
            //           //                 mainAxisAlignment:
            //           //                     pw.MainAxisAlignment.center,
            //           //                 crossAxisAlignment:
            //           //                     pw.CrossAxisAlignment.end,
            //           //                 // mainAxisAlignment:
            //           //                 //     pw.MainAxisAlignment.spaceBetween,
            //           //                 children: [
            //           //                   pw.Text(
            //           //                     'ลงชื่อ',
            //           //                     textAlign: pw.TextAlign.right,
            //           //                     style: pw.TextStyle(
            //           //                       fontSize: font_Size,
            //           //                       font: ttf,
            //           //                       fontWeight: pw.FontWeight.bold,
            //           //                       color: Colors_pd,
            //           //                     ),
            //           //                   ),
            //           //                   pw.Expanded(
            //           //                       flex: 2,
            //           //                       child: pw.Container(
            //           //                         // width: 120,
            //           //                         decoration:
            //           //                             const pw.BoxDecoration(
            //           //                           // color: PdfColors.green100,
            //           //                           border: pw.Border(
            //           //                             bottom: pw.BorderSide(
            //           //                                 width: 0.5,
            //           //                                 color: PdfColors.grey600),
            //           //                           ),
            //           //                         ),
            //           //                         padding:
            //           //                             const pw.EdgeInsets.all(8.0),
            //           //                         height: 30,
            //           //                       )),
            //           //                   pw.Text(
            //           //                     'พยาน',
            //           //                     textAlign: pw.TextAlign.left,
            //           //                     style: pw.TextStyle(
            //           //                       fontSize: font_Size,
            //           //                       font: ttf,
            //           //                       fontWeight: pw.FontWeight.bold,
            //           //                       color: Colors_pd,
            //           //                     ),
            //           //                   ),
            //           //                 ],
            //           //               ),
            //           //             ),
            //           //             pw.SizedBox(height: 2 * PdfPageFormat.mm),
            //           //             pw.Text(
            //           //               (Name4_choice == null ||
            //           //                       Name4_choice.toString() == '' ||
            //           //                       Name4_choice.toString() == 'null')
            //           //                   ? '(___________________________) '
            //           //                   : '( ${Name4_choice.toString()} ) ',
            //           //               // '(___________________________) ',
            //           //               textAlign: pw.TextAlign.center,
            //           //               style: pw.TextStyle(
            //           //                 color: Colors_pd,
            //           //                 fontSize: font_Size,
            //           //                 font: ttf,
            //           //                 fontWeight: pw.FontWeight.bold,
            //           //               ),
            //           //             ),
            //           //           ],
            //           //         )),
            //           //   ],
            //           // ),
            //         ])),
          ];
        },
        footer: (context) {
          // -------------------------------------------------------------
          final int firstSection = 2; // ชุดแรกมี 2 หน้า
          final int secondSection =
              (context.pagesCount - firstSection).clamp(0, 1 << 30);

          final String pageLabel = (context.pageNumber <= firstSection)
              ? "${context.pageNumber}/$firstSection"
              : "${context.pageNumber - firstSection}/$secondSection";

          // ✅ รวมเลขหน้ากับข้อความด้านขวา
          String rightText = '';
          if (context.pageNumber == 1) {
            rightText = '$pageLabel... ข้อ 7. ค่าเช่าสาธารณูปโภค...';
          } else if (context.pageNumber == 2) {
            rightText = '';
          } else if (context.pageNumber == 3) {
            rightText = '$pageLabel... 2.12 การชำระเงินประกันการตกแต่ง...';
          } else if (context.pageNumber == 4) {
            rightText = '$pageLabel... ข้อ 4. การแจ้งการประมวลผล...';
          } else {
            rightText = '';
          }

          // -------------------------------------------------------------
          return pw.Column(
            children: [
              // ====== บรรทัดตัวเลขและข้อความ ======
              pw.Container(
                width: PdfPageFormat.a4.width,
                padding: const pw.EdgeInsets.fromLTRB(40, 0, 40, 0),
                child: pw.Stack(
                  alignment: pw.Alignment.center,
                  children: [
                    // 🔹 ตัวเลขอยู่กลาง
                    pw.Align(
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        pageLabel,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: Colors_pd,
                          fontSize: font_Size,
                          font: ttf,
                        ),
                      ),
                    ),

                    // 🔹 ข้อความอยู่ขวา + กล่องเปล่าด้านหลัง
                    pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Row(
                        mainAxisSize:
                            pw.MainAxisSize.min, // ให้ Row กว้างเท่าที่จำเป็น
                        children: [
                          pw.Text(
                            rightText,
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: Colors_pd,
                              fontSize: font_Size,
                              font: ttf,
                            ),
                          ),
                          pw.SizedBox(width: 7),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ====== แถบสีและโลโก้ด้านล่าง ======
              pw.Stack(
                children: [
                  // 🔸 แถบสี 3 ชั้น
                  pw.Container(
                    width: PdfPageFormat.a4.width,
                    height: 55,
                    child: pw.Center(
                      child: pw.Container(
                        width: widths,
                        height: 25,
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          mainAxisSize: pw.MainAxisSize.min,
                          children: [
                            pw.Row(children: [
                              pw.Expanded(
                                child: pw.Container(
                                  color: PdfColors.red,
                                  height: 5,
                                ),
                              )
                            ]),
                            pw.Row(children: [
                              pw.Expanded(
                                child: pw.Container(
                                  color: PdfColors.green900,
                                  height: 8,
                                ),
                              )
                            ]),
                            pw.Row(children: [
                              pw.Expanded(
                                child: pw.Container(
                                  color: PdfColors.red,
                                  height: 5,
                                ),
                              )
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 🔸 โลโก้มุมขวา
                  pw.Positioned(
                    top: 4,
                    right: 50,
                    child: pw.Container(
                      width: 50.0,
                      height: 50.0,
                      child: pw.Image(pw.MemoryImage(imageData)),
                    ),
                  ),

                  // 🔸 ข้อความบริษัท (ซ้ายบน)
                  pw.Positioned(
                    top: 4,
                    left: 40,
                    child: pw.Container(
                      width: PdfPageFormat.a4.width - 150,
                      child: pw.Text(
                        "CHOICE MINI STORE CO., LTD. 7/11 VILLAGE NO.5, THA SALA SUB-DISTRICT, MUEANG CHIANG MAI DISTRICT, CHIANG MAI PROVINCE 50000",
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          color: Colors_pd,
                          fontSize: font_Size - 4,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                        ),
                      ),
                    ),
                  ),

                  // 🔸 ข้อความลิขสิทธิ์ (ขวาล่าง)
                  pw.Positioned(
                    bottom: 4,
                    right: 120,
                    child: pw.Text(
                      "Sub Area Licencee: Chiang Mai, Lamphun, Mae-Hong-Son",
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: Colors_pd,
                        fontSize: font_Size - 4,
                        font: ttf,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // final bytes = await pdf.save();

    // final dir = await getApplicationDocumentsDirectory();
    // final file = File('${dir.path}/name');
    // await file.writeAsBytes(bytes);
    // return file;
    // final List<int> bytes = await pdf.save();
    // final Uint8List data = Uint8List.fromList(bytes);
    // MimeType type = MimeType.PDF;
    // final dir = await FileSaver.instance.saveFile(
    //     "ใบเสนอราคา(ณ วันที่${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day})",
    //     data,
    //     "pdf",
    //     mimeType: type);

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RentalInforman_Agreement(
            doc: pdf,
            context: context,
            ////////////------------------->

            // Get_Value_NameShop_index: Get_Value_NameShop_index,
            // Get_Value_cid: Get_Value_cid,
            // verticalGroupValue: _verticalGroupValue,
            // Form_nameshop: Form_nameshop,
            // Form_typeshop: Form_typeshop,
            // Form_bussshop: Form_bussshop,
            // Form_bussscontact: Form_bussscontact,
            // Form_address: Form_address,
            // Form_tel: Form_tel,
            // Form_email: Form_email,
            // Form_tax: Form_tax,
            // Form_ln: Form_ln,
            // Form_zn: Form_zn,
            // Form_area: Form_area,
            // Form_qty: Form_qty,
            // Form_sdate: Form_sdate,
            // Form_ldate: Form_ldate,
            // Form_period: Form_period,
            // Form_rtname: Form_rtname,
            // quotxSelectModels: quotxSelectModels,
            // TransModels: _TransModels,
            // renTal_name: renTal_name,
            // bill_addr: bill_addr,
            // bill_email: bill_email,
            // bill_tel: bill_tel,
            // bill_tax: bill_tax,
            // bill_name: bill_name,
            // newValuePDFimg: newValuePDFimg,
          ),
        ));
  }
}
