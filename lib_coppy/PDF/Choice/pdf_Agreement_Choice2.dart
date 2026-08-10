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
import '../../Style/loadAndCacheImage.dart';

class Expense {
  final String nameExp;
  final String dueDate;
  final String sday;
  final String max_duedate;
  final String pvatExp;
  final String whtExp;
  final String nwhtExp;
  final String totalExp;

  Expense(
      {required this.nameExp,
      required this.dueDate,
      required this.sday,
      required this.max_duedate,
      required this.pvatExp,
      required this.whtExp,
      required this.nwhtExp,
      required this.totalExp});

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      nameExp: json['name_exp'],
      dueDate: json['duedate'],
      sday: json['sday'],
      max_duedate: json['max_duedate'],
      pvatExp: json['pvat_exp'],
      whtExp: json['wht_exp'],
      nwhtExp: json['nwht_exp'],
      totalExp: json['total_exp'],
    );
  }
}

class Pdfgen_Agreement_Choice2 {
//////////---------------------------------------------------->( **** เอกสารสัญญาห้องเช่า  Choice)

  static void exportPDF_Agreement_Choice2(
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
    String thaiDate = DateFormat('d เดือน MMM yyyy', 'th').format(date);
    var nFormat = NumberFormat("#,##0.00", "en_US");
    var nFormat2 = NumberFormat("###0.00", "en_US");
    final iconImage =
        (await rootBundle.load('images/LOGO.png')).buffer.asUint8List();
    final ByteData image = await rootBundle.load('images/image7-11.png');
    final ByteData BG_PDF = await rootBundle.load('images/Choice_BG_PDF.png');

    Uint8List imageData = (image).buffer.asUint8List();
    Uint8List imageBG = (BG_PDF).buffer.asUint8List();

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
    String? base64Image_1 = preferences.getString('base64Image1');
    Uint8List? resizedLogo = await getResizedLogo();
    // String? base64Image_2 = preferences.getString('base64Image2');
    // String? base64Image_3 = preferences.getString('base64Image3');
    // String? base64Image_4 = preferences.getString('base64Image4');
    String base64Image_new1 = (base64Image_1 == null) ? '' : base64Image_1;
    // String base64Image_new2 = (base64Image_2 == null) ? '' : base64Image_2;
    // String base64Image_new3 = (base64Image_3 == null) ? '' : base64Image_3;
    // String base64Image_new4 = (base64Image_4 == null) ? '' : base64Image_4;
    // Uint8List data1 = base64Decode(base64Image_new1);
    // Uint8List data2 = base64Decode(base64Image_new2);
    // Uint8List data3 = base64Decode(base64Image_new3);
    // Uint8List data4 = base64Decode(base64Image_new4);
    // for (int i = 0; i < newValuePDFimg.length; i++) {
    //   netImage.add(await networkImage('${newValuePDFimg[i]}'));
    // }
    ////////////--------------------->
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
    // for (int i = 0; i < newValuePDFimg.length; i++) {
    //   signature_Image1.add(await networkImage('${newValuePDFimg[i]}'));
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
    ///////////////////////------------------------------------------------->

    String Howday = (Form_rtname.toString() == 'รายวัน')
        ? 'วัน'
        : (Form_rtname.toString() == 'รายเดือน')
            ? 'เดือน'
            : (Form_rtname.toString() == 'รายปี')
                ? 'ปี'
                : '$Form_rtname';
    double widths = await MediaQuery.of(context).size.width;
    int pange = 1;

//     List<double> data2 = [0.00, 0.00, 0.00];
//     String Rent_List = (quotxSelectModels
//                 .where((e) =>
//                     e.expser.toString() == '1' &&
//                     // e.unitser.toString() == '1' &&
//                     e.amt_ty.toString() != '')
//                 .length ==
//             0)
//         ? '0.00, 0.00, 0.00'
//         : quotxSelectModels
//             .where((e) =>
//                 e.expser.toString() == '1' &&
//                 // e.unitser.toString() == '1' &&
//                 e.amt_ty.toString() != '')
//             .map((e) => e.amt_ty)
//             .toString();

//     // Step 1: Remove parentheses
//     Rent_List = Rent_List.replaceAll('(', '').replaceAll(')', '');

//     // Step 2: Split the string by commas
//     List<String> rentStringList = Rent_List.split(',');

//     // Step 3: Convert the list of strings to a list of doubles
//     List<double> rentList =
//         (rentStringList.map((e) => double.parse(e)).toList() == 0)
//             ? data2
//             : rentStringList.map((e) => double.parse(e)).toList();

// ///////////////////////------------------------------------------------->
    final String textdata =
        '${quotxSelectModels.where((model) => model.expser.toString() == '1' && model.unitser.toString() == '2').map((model) => model.exp_array).join(', ')}';

    // List<dynamic> jsonResponse = json.decode(textdata);
    List<Expense> expenses = [];
    // List<Expense> expenses =
    //     jsonResponse.map((data) => Expense.fromJson(data)).toList();
    if (textdata.isNotEmpty) {
      try {
        List<dynamic> jsonResponse = json.decode(textdata);
        List<Expense> expensesx =
            jsonResponse.map((data) => Expense.fromJson(data)).toList();
        expenses = expensesx;
      } catch (e) {
        // print('Error decoding JSON: $e');
        // Handle error (e.g., set expenses to an empty list or log the error)
        List<Expense> expensesx = [];
        expenses = expensesx;
      }
    } else {
      // Handle the case where textdata is empty
      List<Expense> expensesx = [];
      expenses = expensesx;
    }
    // late List<List<Expense>> expensess;

    // expensess = List.generate(20, (_) => []);
    // int index_1 = 0;
    // int index_2 = 0;
    // for (var expense in expenses) {
    //   expensess[index_1].add(expense);
    //   if (expensess[index_1].length == 12) {
    //     index_1++;
    //   }
    // }
    // for (int index = 0; index < expensess.length; index++) {
    //   if (expensess[index].length != 0) {
    //     for (int index2 = 0; index2 < expensess[index].length; index2++) {
    //       print(
    //           '${index} S : ${expensess[index][index2].dueDate} : ${expensess[index][index2].totalExp}');
    //     }
    //   }
    // }
// ///////////////////////------------------------------------------------->
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
                            child: pw.Text(
                              '$bill_name ',
                              maxLines: 1,
                              style: pw.TextStyle(
                                fontSize: 10,
                                font: ttf,
                                color: Colors_pd,
                              ),
                            ),
                          ),
                  ),
                  // (netImage.isEmpty)
                  //     ? pw.Container(
                  //         height: 72,
                  //         width: 70,
                  //         color: PdfColors.grey200,
                  //         child: pw.Center(
                  //           child: pw.Text(
                  //             '$renTal_name ',
                  //             maxLines: 1,
                  //             style: pw.TextStyle(
                  //               fontSize: 10,
                  //               font: ttf,
                  //               color: Colors_pd,
                  //             ),
                  //           ),
                  //         ))

                  //     // pw.Image(
                  //     //     pw.MemoryImage(iconImage),
                  //     //     height: 72,
                  //     //     width: 70,
                  //     //   )
                  //     : pw.Image(
                  //         (netImage[0]),
                  //         height: 72,
                  //         width: 70,
                  //       ),
                  pw.SizedBox(width: 1 * PdfPageFormat.mm),
                  pw.Container(
                    width: 350,
                    child: pw.Column(
                      mainAxisSize: pw.MainAxisSize.min,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '${bill_name.toString().trim()}',
                          maxLines: 2,
                          style: pw.TextStyle(
                            fontSize: font_Size,
                            color: PdfColors.black,
                            fontWeight: pw.FontWeight.bold,
                            font: ttf,
                          ),
                        ),
                        pw.Text(
                          '${bill_addr.toString().trim()}',
                          maxLines: 3,
                          style: pw.TextStyle(
                            fontSize: font_Size,
                            color: Colors_pd,
                            font: ttf,
                          ),
                        ),
                        pw.Text(
                          'เลขประจำตัวผู้เสียภาษี : $bill_tax',
                          maxLines: 2,
                          style: pw.TextStyle(
                            fontSize: font_Size,
                            font: ttf,
                            color: Colors_pd,
                          ),
                        ),
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
                          borderRadius: pw.BorderRadius.only(
                              topLeft: pw.Radius.circular(10),
                              topRight: pw.Radius.circular(10),
                              bottomLeft: pw.Radius.circular(10),
                              bottomRight: pw.Radius.circular(10)),
                          border: pw.Border.all(color: Colors_pd3, width: 1),
                        ),
                        padding: pw.EdgeInsets.all(5),
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
                      ? pw.Text(
                          'สัญญาเช่า',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            color: Colors_pd,
                            fontSize: font_Size,
                            fontWeight: pw.FontWeight.bold,
                            font: ttf,
                          ),
                        )
                      // : pw.Text(
                      //     '${context.pageNumber} / ${context.pagesCount}',

                      //     textAlign: pw.TextAlign.center,
                      //     style: pw.TextStyle(
                      //       color: Colors_pd,
                      //       fontSize: font_Size,
                      //       fontWeight: pw.FontWeight.bold,
                      //       font: ttf,
                      //     ),
                      //   ),
                      : pw.Container(
                          height: font_Size + 5,
                        ),
                ],
              ),
              pw.Container(
                width: PdfPageFormat.a4.width,
                padding: pw.EdgeInsets.fromLTRB(50, 0, 50, 0),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    if (context.pageNumber.toString() == '1')
                      pw.Text(
                        'สาขา $Form_zn',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          color: Colors_pd,
                          fontSize: font_Size,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                        ),
                      ),
                    pw.Spacer(),
                    pw.Text(
                      'สัญญาเลขที่  $Get_Value_cid',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        color: Colors_pd,
                        fontSize: font_Size,
                        fontWeight: pw.FontWeight.bold,
                        font: ttf,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 2 * PdfPageFormat.mm),
              pw.Container(
                width: PdfPageFormat.a4.width,
                padding: pw.EdgeInsets.fromLTRB(50, 0, 50, 0),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Spacer(),
                    pw.Text(
                      (Form_wnote.toString() == '' || Form_wnote == null)
                          ? 'อ้างอิงสัญญาเดิมเลขที่________________'
                          : 'อ้างอิงสัญญาเดิมเลขที่ ${Form_wnote}',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        color: Colors_pd,
                        fontSize: font_Size,
                        fontWeight: pw.FontWeight.bold,
                        font: ttf,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 2 * PdfPageFormat.mm),
            ],
          );
        },
        build: (context) {
          return [
            pw.Container(
                decoration: pw.BoxDecoration(
                  image: pw.DecorationImage(
                    image: pw.MemoryImage(imageBG),
                    fit: pw.BoxFit.fill,
                  ),
                ),
                width: PdfPageFormat.a4.width,
                padding: pw.EdgeInsets.fromLTRB(50, 0, 50, 0),
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
                                // pw.Text(
                                //   (Form_wnote.toString() == '' ||
                                //           Form_wnote == null)
                                //       ? 'อ้างอิงสัญญาเดิมเลขที่________________'
                                //       : 'อ้างอิงสัญญาเดิมเลขที่ ${Form_wnote}',
                                //   // (Get_Value_cid.toString() ==
                                //   //         Form_renew_cid.toString())
                                //   //     ? 'อ้างอิงสัญญาเดิมเลขที่________________'
                                //   //     : 'อ้างอิงสัญญาเดิมเลขที่ ${Form_renew_cid}',
                                //   // 'ทำที่ $renTal_name ',
                                //   textAlign: pw.TextAlign.right,
                                //   style: pw.TextStyle(
                                //     fontSize: font_Size,
                                //     font: ttf,
                                //     color: Colors_pd,
                                //   ),
                                // ),
                                pw.Text(
                                  'ทำที่ บริษัท ชอยส์ มินิสโตร์ จำกัด',
                                  // 'ทำที่ $renTal_name ',
                                  textAlign: pw.TextAlign.right,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    color: Colors_pd,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(
                            (Datex_text.text == '0000-00-00' ||
                                    Datex_text.text == '' ||
                                    Datex_text.text == null)
                                ? 'วันที่ 00-00-0000'
                                : 'วันที่ ${DateFormat('dd MMM', 'TH').format(DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('${Datex_text.text} 00:00:00')}"))} ${DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('${Datex_text.text} 00:00:00')}").year + 543}',
                            //  'วันที่ ${thaiDate}',
                            // 'วันที่ ${DateFormat('dd MMM', 'th').format(DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_sdate 00:00:00')}"))} ${DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_sdate 00:00:00')}").year + 543}',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              color: Colors_pd,
                              fontSize: font_Size,
                              fontWeight: pw.FontWeight.bold,
                              font: ttf,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 2 * PdfPageFormat.mm),
                      pw.Text(
                        'ข้อ 1. รายละเอียดคู่สัญญา',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          color: Colors_pd,
                          fontSize: font_Size,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                        ),
                      ),
                      pw.Text(
                        ' ' * 12 +
                            'สัญญาฉบับนี้ทำขึ้นระหว่าง   บริษัท ชอยส์ มินิสโตร์  จำกัด   โดย นางฤทัยรัตน์ วิสิทธิ์ และนายวธัญญู ตันตรานนท์  กรรมการผู้มีอำนาจลงนาม  สำนักงานใหญ่ตั้งอยู่เลขที่  7/11 หมู่ที่5 ตำบลท่าศาลา อำเภอเมืองเชียงใหม่ จังหวัดเชียงใหม่ ซึ่งต่อไปใน',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          color: Colors_pd,
                          fontSize: font_Size,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Row(
                        children: [
                          pw.Text(
                            'สัญญานี้จะเรียกว่า “ผู้ให้เช่า” ฝ่ายหนึ่ง กับ ',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                          pw.Expanded(
                              flex: 2,
                              child: pw.Container(
                                decoration: pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                  color: Colors_pd,
                                  width: 0.3, // Underline thickness
                                ))),
                                child: pw.Text(
                                  "$Form_bussshop",
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
                            'โดย',
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
                                decoration: pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                  color: Colors_pd,
                                  width: 0.3, // Underline thickness
                                ))),
                                child: pw.Text(
                                  (_verticalGroupValue.toString() ==
                                          'องค์กร/นิติบุคคล')
                                      ? " $Form_bussscontact "
                                      : " - ",
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
                            'ผู้มีอำนาจลงนาม ',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Row(
                        children: [
                          pw.Text(
                            'เลขประจำตัวประชาชน/ทะเบียนนิติบุคคล เลขที่ ',
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
                                decoration: pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                  color: Colors_pd,
                                  width: 0.3, // Underline thickness
                                ))),
                                child: pw.Text(
                                  "$Form_tax",
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    color: Colors_pd,
                                    fontSize: font_Size - 0.2,
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
                          pw.Text(
                            'ที่อยู่/สำนักงานใหญ่ ตั้งอยู่',
                            // 'อยู่บ้านเลขที่/สำนักงานตั้งอยู่เลขที่',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontSize: font_Size - 0.3,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                          pw.Expanded(
                              flex: 2,
                              child: pw.Container(
                                decoration: pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                  color: Colors_pd,
                                  width: 0.3, // Underline thickness
                                ))),
                                child: pw.Text(
                                  "$Form_address",
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
                            'โทรศัพท์ ',
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
                                decoration: pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                  color: Colors_pd,
                                  width: 0.3, // Underline thickness
                                ))),
                                child: pw.Text(
                                  "$Form_tel",
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    color: Colors_pd,
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                  ),
                                ),
                              )),
                          // pw.Text(
                          //   'ซึ่งต่อไปในสัญญานี้จะเรียกว่า “ผู้เช่า” ',
                          //   textAlign: pw.TextAlign.left,
                          //   style: pw.TextStyle(
                          //     color: Colors_pd,
                          //     fontSize: font_Size,
                          //     fontWeight: pw.FontWeight.bold,
                          //     font: ttf,
                          //   ),
                          // ),
                        ],
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        'ซึ่งต่อไปในสัญญานี้จะเรียกว่า “ผู้เช่า” อีกฝ่ายหนึ่ง คู่สัญญาได้ตกลงกันมีข้อความดังต่อไปนี้',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          color: Colors_pd,
                          fontSize: font_Size,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        'ข้อ 2. รายละเอียดสถานที่ให้เช่า',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          color: Colors_pd,
                          fontSize: font_Size,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Row(
                        children: [
                          pw.Text(
                            ' ' * 12 +
                                'ผู้ให้เช่าตกลงให้เช่าและผู้เช่าตกลงเช่าล็อคเลขที่',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                          pw.Container(
                            width: 120,
                            decoration: pw.BoxDecoration(
                                border: pw.Border(
                                    bottom: pw.BorderSide(
                              color: Colors_pd,
                              width: 0.3, // Underline thickness
                            ))),
                            child: pw.Text(
                              "$Form_ln",
                              maxLines: 1,
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
                            'ขนาดพื้นที่เช่า',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                          pw.Container(
                            width: 50,
                            decoration: pw.BoxDecoration(
                                border: pw.Border(
                                    bottom: pw.BorderSide(
                              color: Colors_pd,
                              width: 0.3, // Underline thickness
                            ))),
                            child: pw.Text(
                              "$Form_area ",
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
                            ' ตร.ม.จำนวน',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                          pw.Container(
                            width: 30,
                            decoration: pw.BoxDecoration(
                                border: pw.Border(
                                    bottom: pw.BorderSide(
                              color: Colors_pd,
                              width: 0.3, // Underline thickness
                            ))),
                            child: pw.Text(
                              " $Form_qty ",
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
                            'ห้อง',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ],
                      ),
                      // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      // pw.Row(
                      //   children: [
                      //     pw.Text(
                      //       'ขนาดพื้นที่เช่า',
                      //       textAlign: pw.TextAlign.left,
                      //       style: pw.TextStyle(
                      //         fontSize: font_Size,
                      //         font: ttf,
                      //         color: Colors_pd,
                      //       ),
                      //     ),
                      //     pw.Container(
                      //       width: 100,
                      //       decoration: pw.BoxDecoration(
                      //           border: pw.Border(
                      //               bottom: pw.BorderSide(
                      //         color: Colors_pd,
                      //         width: 0.3, // Underline thickness
                      //       ))),
                      //       child: pw.Text(
                      //         "$Form_area ",
                      //         textAlign: pw.TextAlign.center,
                      //         style: pw.TextStyle(
                      //           color: Colors_pd,
                      //           fontSize: font_Size,
                      //           fontWeight: pw.FontWeight.bold,
                      //           font: ttf,
                      //         ),
                      //       ),
                      //     ),
                      //     pw.Text(
                      //       ' ตร.ม. จำนวน',
                      //       textAlign: pw.TextAlign.left,
                      //       style: pw.TextStyle(
                      //         fontSize: font_Size,
                      //         font: ttf,
                      //         color: Colors_pd,
                      //       ),
                      //     ),
                      //     pw.Container(
                      //       width: 100,
                      //       decoration: pw.BoxDecoration(
                      //           border: pw.Border(
                      //               bottom: pw.BorderSide(
                      //         color: Colors_pd,
                      //         width: 0.3, // Underline thickness
                      //       ))),
                      //       child: pw.Text(
                      //         " $Form_qty ",
                      //         textAlign: pw.TextAlign.center,
                      //         style: pw.TextStyle(
                      //           color: Colors_pd,
                      //           fontSize: font_Size,
                      //           fontWeight: pw.FontWeight.bold,
                      //           font: ttf,
                      //         ),
                      //       ),
                      //     ),
                      //     pw.Text(
                      //       'ห้อง',
                      //       textAlign: pw.TextAlign.left,
                      //       style: pw.TextStyle(
                      //         fontSize: font_Size,
                      //         font: ttf,
                      //         color: Colors_pd,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // pw.Text(
                      //   ' ' * 12 +
                      //       'ผู้ให้เช่าตกลงให้เช่าและผู้เช่าตกลงเช่าอาคารเลขที่  209/1 หมู่ที่ 1 ตำบลริมเหนือ อำเภอแม่ริม จังหวัดเชียงใหม่ ขนาดพื้นที่เช่า   24.00    ตร.ม. จำนวน  1   ห้อง  ',
                      //   textAlign: pw.TextAlign.left,
                      //   style: pw.TextStyle(
                      //     color: Colors_pd,
                      //     fontSize: font_Size,
                      //     fontWeight: pw.FontWeight.bold,
                      //     font: ttf,
                      //   ),
                      // ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        'ข้อ 3. วัตถุประสงค์ของการให้เช่า',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          color: Colors_pd,
                          fontSize: font_Size,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Row(
                        children: [
                          pw.Text(
                            ' ' * 12 +
                                'ผู้เช่าตกลงเช่าทรัพย์สินที่เช่าเพื่อดำเนินกิจการร้าน',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                          pw.Expanded(
                              flex: 2,
                              child: pw.Container(
                                decoration: pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                  color: Colors_pd,
                                  width: 0.3, // Underline thickness
                                ))),
                                child: pw.Text(
                                  (Form_typeshop == null ||
                                          Form_typeshop.toString() == 'null')
                                      ? "$Form_typeshop"
                                      : "$Form_typeshop",
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
                            'เท่านั้น การเปลี่ยนแปลงวัตถุประสงค์ ',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                          textAlign: pw.TextAlign.justify,
                          maxLines: 3,
                          style: pw.TextStyle(
                            fontSize: font_Size,
                            font: ttf,
                            color: Colors_pd,
                          ),
                          'ประเภทการค้าชนิดหรือลักษณะของกิจการตลอดจนชื่อในทางการค้าของผู้เช่า    จะต้องได้รับความยินยอมเป็นลายลักษณ์อักษรจากผู้ให้เช่าก่อนและผู้เช่า\nต้องไม่นำทรัพย์สินของผู้ให้เช่าไปประกอบกิจการอันนำมาซึ่งความเสียหาย   และเป็นที่ต้องห้ามของกฎหมาย ตลอดจนห้ามนำทรัพย์สินที่เช่าไปให้ผู้อื่นเช่า\nช่วงเป็นเด็ดขาด'),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        'ข้อ 4. ระยะเวลาการเช่าและวันส่งมอบทรัพย์สินที่เช่า',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          color: Colors_pd,
                          fontSize: font_Size,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Row(
                        children: [
                          pw.Text(
                            ' ' * 12 +
                                'คู่สัญญาตกลงรับเช่าทรัพย์สิน ตามข้อ 2. สัญญาเริ่มตั้งแต่วันที่',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                          pw.Expanded(
                              flex: 2,
                              child: pw.Container(
                                decoration: pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                  color: Colors_pd,
                                  width: 0.3, // Underline thickness
                                ))),
                                child: pw.Text(
                                  (Form_sdate == '0000-00-00' ||
                                          Form_sdate == '' ||
                                          Form_sdate == null)
                                      ? '-'
                                      : '${DateFormat('dd MMM', 'th').format(DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_sdate 00:00:00')}"))} ${DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_sdate 00:00:00')}").year + 543}',
                                  // "$Form_sdate",
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
                            'ถึงวันที่ ',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                          pw.Expanded(
                              flex: 2,
                              child: pw.Container(
                                decoration: pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                  color: Colors_pd,
                                  width: 0.3, // Underline thickness
                                ))),
                                child: pw.Text(
                                  (Form_ldate == '0000-00-00' ||
                                          Form_ldate == '' ||
                                          Form_ldate == null)
                                      ? '-'
                                      : '${DateFormat('dd MMM', 'th').format(DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_ldate 00:00:00')}"))} ${DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_ldate 00:00:00')}").year + 543}',
                                  //   "$Form_ldate",
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
                          pw.Text(
                            'ระยะเวลาการเช่า',
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
                                decoration: pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                  color: Colors_pd,
                                  width: 0.3, // Underline thickness
                                ))),
                                child: pw.Text(
                                  "$FormPeriod_choice",
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
                            (Form_rtname.toString() == 'รายวัน')
                                ? 'วัน และผู้ให้เช่าตกลงส่งมอบทรัพย์สินที่เช่าให้แก่ผู้เช่าครอบครองในวันที่ '
                                : (Form_rtname.toString() == 'รายเดือน')
                                    ? 'เดือน และผู้ให้เช่าตกลงส่งมอบทรัพย์สินที่เช่าให้แก่ผู้เช่าครอบครองในวันที่ '
                                    : (Form_rtname.toString() == 'รายปี')
                                        ? 'ปี และผู้ให้เช่าตกลงส่งมอบทรัพย์สินที่เช่าให้แก่ผู้เช่าครอบครองในวันที่ '
                                        : '$Form_rtname และผู้ให้เช่าตกลงส่งมอบทรัพย์สินที่เช่าให้แก่ผู้เช่าครอบครองในวันที่ ',
                            // 'เดือนและผู้ให้เช่าตกลงส่งมอบทรัพย์สินที่เช่าให้แก่ผู้เช่าครอบครองในวันที่',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                          pw.Expanded(
                              flex: 2,
                              child: pw.Container(
                                decoration: pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                  color: Colors_pd,
                                  width: 0.3, // Underline thickness
                                ))),
                                child: pw.Text(
                                  (DatexChoice_Sub2_3text == null)
                                      ? '-'
                                      : '${DateFormat('dd MMM', 'th').format(DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$DatexChoice_Sub2_3text 00:00:00')}"))} ${DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$DatexChoice_Sub2_3text 00:00:00')}").year + 543}',
                                  // : '${DateFormat('dd MMM', 'th').format(DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$DatexChoice_Sub2_3text 00:00:00')}"))} ${DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$DatexChoice_Sub2_3text 00:00:00')}").year + 543}',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    color: Colors_pd,
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                  ),
                                ),
                              )),
                          // pw.Text(
                          //   'โดยระหว่างวันที่',
                          //   textAlign: pw.TextAlign.left,
                          //   style: pw.TextStyle(
                          //     fontSize: font_Size,
                          //     font: ttf,
                          //     color: Colors_pd,
                          //   ),
                          // ),
                        ],
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        'หากกรณีผู้เช่าเปิดดำเนินกิจการก่อนวันที่สัญญาเริ่มต้น ผู้เช่าจะต้องชำระค่าเช่าตามจริง',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      // pw.Row(children: [
                      //   pw.Container(
                      //     width: 60,
                      //     decoration: pw.BoxDecoration(
                      //         border: pw.Border(
                      //             bottom: pw.BorderSide(
                      //       color: Colors_pd,
                      //       width: 0.3, // Underline thickness
                      //     ))),
                      //     child: pw.Text(
                      //       " - ",
                      //       textAlign: pw.TextAlign.center,
                      //       style: pw.TextStyle(
                      //         color: Colors_pd,
                      //         fontSize: font_Size,
                      //         fontWeight: pw.FontWeight.bold,
                      //         font: ttf,
                      //       ),
                      //     ),
                      //   ),
                      //   pw.Text(
                      //     'ผู้เช่าไม่ต้องชำระค่าเช่าให้แก่ผู้ให้เช่า หากกรณีผู้เช่าเปิดดำเนินกิจการก่อนวันที่สัญญาเริ่มต้น ผู้เช่าจะต้องชำระค่าเช่าตามจริง',
                      //     textAlign: pw.TextAlign.left,
                      //     style: pw.TextStyle(
                      //       fontSize: font_Size,
                      //       font: ttf,
                      //       color: Colors_pd,
                      //     ),
                      //   ),
                      // ]),

                      pw.SizedBox(height: 5 * PdfPageFormat.mm),
                      pw.Text(
                        'ข้อ 5. อัตราค่าเช่า',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          color: Colors_pd,
                          fontSize: font_Size,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 12 +
                            'ผู้เช่าตกลงชำระค่าเช่าเป็นรายเดือน ให้แก่ผู้ให้เช่า ในอัตราค่าเช่าดังนี้',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          color: Colors_pd,
                          fontSize: font_Size,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      if (expenses.length == 0) //zn 19783
                        pw.SizedBox(
                            child: pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                              pw.Row(
                                children: [
                                  pw.Text(
                                    ' ' * 12 + 'อัตราค่าเช่าตั้งแต่วันที่',
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
                                          (Form_sdate == '0000-00-00' ||
                                                  Form_sdate == '' ||
                                                  Form_sdate == null)
                                              ? '-'
                                              : '${DateFormat('dd MMM', 'th').format(DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_sdate 00:00:00')}"))} ${DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_sdate 00:00:00')}").year + 543}',
                                          // "$Form_sdate",
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
                                          (Form_ldate == '0000-00-00' ||
                                                  Form_ldate == '' ||
                                                  Form_ldate == null)
                                              ? '-'
                                              : '${DateFormat('dd MMM', 'th').format(DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_ldate 00:00:00')}"))} ${DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_ldate 00:00:00')}").year + 543}',
                                          //   "$Form_ldate",
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
                                  pw.Text(
                                    ' ' * 12 + 'ชำระค่าเช่าเดือนละ',
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
                                          (quotxSelectModels
                                                      .where((e) =>
                                                          e.expser.toString() ==
                                                              '1' &&
                                                          e.unitser
                                                                  .toString() ==
                                                              '2')
                                                      .length ==
                                                  0)
                                              ? ' 0.00'
                                              : ' ${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '1' && e.unitser.toString() == '2').map((e) => e.pvat != null ? double.parse(e.pvat.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ' +
                                                  '(~${convertToThaiBaht(quotxSelectModels.where((e) => e.expser.toString() == '1' && e.unitser.toString() == '2').map((e) => e.pvat != null ? double.parse(e.pvat.toString()) : 0.00).fold(0.00, (a, b) => a + b))}~)',
                                          textAlign: pw.TextAlign.left,
                                          style: pw.TextStyle(
                                            color: Colors_pd,
                                            fontSize: font_Size,
                                            fontWeight: pw.FontWeight.bold,
                                            font: ttf,
                                          ),
                                        ),
                                      )),
                                  pw.Text(
                                    (quotxSelectModels
                                                .where((e) =>
                                                    e.expser.toString() == '1')
                                                .length ==
                                            0)
                                        ? 'หักภาษี ณ ที่จ่าย '
                                        : (quotxSelectModels
                                                    .where((e) =>
                                                        e.expser.toString() ==
                                                        '1')
                                                    .map((e) => e.nwht != null
                                                        ? double.parse(
                                                            e.nwht.toString())
                                                        : 0.00)
                                                    .fold(0.00,
                                                        (a, b) => a + b) ==
                                                0)
                                            ? 'หักภาษี ณ ที่จ่าย '
                                            : 'หักภาษี ณ ที่จ่าย ' +
                                                '( ${quotxSelectModels.where((e) => e.expser.toString() == '1' && e.unitser.toString() != '4').map((e) => e.nwht != null ? double.parse(e.nwht.toString()) : 0.00).fold(0.00, (a, b) => a + b)} ) % ',
                                    textAlign: pw.TextAlign.left,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      color: Colors_pd,
                                    ),
                                  ),
                                  pw.Expanded(
                                    flex: 2,
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                          border: pw.Border(
                                              bottom: pw.BorderSide(
                                        color: Colors_pd,
                                        width:
                                            0.3, // Underline thickness 10096-10-2024
                                      ))),
                                      child: pw.Text(
                                        (quotxSelectModels
                                                    .where((e) =>
                                                        e.expser.toString() ==
                                                        '1')
                                                    .length ==
                                                0)
                                            ? '0.00'
                                            : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '1' && e.cfid.toString() != '1').map((e) => e.wht != null ? double.parse(e.wht.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ',
                                        textAlign: pw.TextAlign.center,
                                        style: pw.TextStyle(
                                          color: Colors_pd,
                                          fontSize: font_Size,
                                          fontWeight: pw.FontWeight.bold,
                                          font: ttf,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              pw.SizedBox(height: 1 * PdfPageFormat.mm),
                              pw.Row(
                                children: [
                                  pw.Text(
                                    ' ' * 12 + 'รวมเป็นเงินทั้งสิ้น',
                                    textAlign: pw.TextAlign.left,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      color: Colors_pd,
                                    ),
                                  ),
                                  pw.Expanded(
                                    flex: 2,
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                          border: pw.Border(
                                              bottom: pw.BorderSide(
                                        color: Colors_pd,
                                        width: 0.3, // Underline thickness
                                      ))),
                                      child: pw.Text(
                                        (quotxSelectModels
                                                    .where((e) =>
                                                        e.expser.toString() ==
                                                            '1' &&
                                                        e.unitser.toString() ==
                                                            '2')
                                                    .length ==
                                                0)
                                            ? ' 0.00'
                                            : ' ${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '1' && e.unitser.toString() == '2').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ' +
                                                '(~${convertToThaiBaht(quotxSelectModels.where((e) => e.expser.toString() == '1' && e.unitser.toString() == '2').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b))}~)',
                                        textAlign: pw.TextAlign.center,
                                        style: pw.TextStyle(
                                          color: Colors_pd,
                                          fontSize: font_Size,
                                          fontWeight: pw.FontWeight.bold,
                                          font: ttf,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              pw.SizedBox(height: 2 * PdfPageFormat.mm),
                            ])),
                      for (int index = 0; index < expenses.length; index++)
                        if (expenses[index].totalExp.toString() != '0.00')
                          pw.SizedBox(
                              child: pw.Column(
                                  mainAxisAlignment: pw.MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                // pw.Row(
                                //   children: [
                                //     pw.Text(
                                //       ' ' * 12 + 'อัตราค่าเช่าตั้งแต่วันที่',
                                //       textAlign: pw.TextAlign.left,
                                //       style: pw.TextStyle(
                                //         fontSize: font_Size,
                                //         font: ttf,
                                //         color: Colors_pd,
                                //       ),
                                //     ),
                                //     pw.Expanded(
                                //         flex: 1,
                                //         child: pw.Container(
                                //           height: 14,
                                //           decoration: pw.BoxDecoration(
                                //               border: pw.Border(
                                //                   bottom: pw.BorderSide(
                                //             color: Colors_pd,
                                //             width: 0.3, // Underline thickness
                                //           ))),
                                //           child: pw.Text(
                                //             (index == 0)
                                //                 ? (Form_sdate == '0000-00-00' ||
                                //                         Form_sdate == '' ||
                                //                         Form_sdate == null)
                                //                     ? '-'
                                //                     : '${DateFormat('dd MMM', 'th').format(DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_sdate 00:00:00')}"))} ${DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_sdate 00:00:00')}").year + 543}'
                                //                 : (DateTime.parse(
                                //                                 '${expenses[index].max_duedate} 00:00:00')
                                //                             .month
                                //                             .toString() !=
                                //                         '1')
                                //                     ? '1 ม.ค. ${DateTime.parse('${expenses[index].dueDate} 00:00:00').year + 543}'
                                //                     : (DateTime.parse(
                                //                                     '${expenses[index].dueDate} 00:00:00')
                                //                                 .day
                                //                                 .toString() !=
                                //                             '1')
                                //                         ? '1 ม.ค. ${DateTime.parse('${expenses[index].dueDate} 00:00:00').year + 543}'
                                //                         : '${DateFormat('dd MMM', 'TH').format(DateTime.parse("${DateFormat("yyyy-MM-dd HH:mm:ss").parse('${expenses[index].max_duedate} 00:00:00')}"))} ${DateTime.parse('${expenses[index].max_duedate} 00:00:00').year + 543}',
                                //             // (expenses[index].dueDate == null ||
                                //             //         expenses[index]
                                //             //                 .dueDate
                                //             //                 .toString() ==
                                //             //             '')
                                //             //     ? '-'
                                //             //     : '${DateFormat('dd MMM', 'TH').format(DateTime.parse("${DateFormat("yyyy-MM-dd HH:mm:ss").parse('${expenses[index].dueDate} 00:00:00')}"))} ${DateTime.parse('${expenses[index].dueDate} 00:00:00').year + 543}',
                                //             // '${expenses[index].dueDate}',
                                //             textAlign: pw.TextAlign.center,
                                //             style: pw.TextStyle(
                                //               color: Colors_pd,
                                //               fontSize: font_Size,
                                //               fontWeight: pw.FontWeight.bold,
                                //               font: ttf,
                                //             ),
                                //           ),
                                //         )),
                                //     pw.Text(
                                //       'ถึงวันที่',
                                //       textAlign: pw.TextAlign.left,
                                //       style: pw.TextStyle(
                                //         fontSize: font_Size,
                                //         font: ttf,
                                //         color: Colors_pd,
                                //       ),
                                //     ),
                                //     pw.Expanded(
                                //         flex: 1,
                                //         child: pw.Container(
                                //           height: 14,
                                //           decoration: pw.BoxDecoration(
                                //               border: pw.Border(
                                //                   bottom: pw.BorderSide(
                                //             color: Colors_pd,
                                //             width: 0.3, // Underline thickness
                                //           ))),
                                //           child: pw.Text(
                                //             (expenses.length == (index + 1))
                                //                 ? (Form_ldate == '0000-00-00' ||
                                //                         Form_ldate == '' ||
                                //                         Form_ldate == null)
                                //                     ? '-'
                                //                     : '${DateFormat('dd MMM', 'th').format(DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_ldate 00:00:00')}"))} ${DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_ldate 00:00:00')}").year + 543}'
                                //                 : (int.parse(DateTime.parse(
                                //                                     '${expenses[index + 1].max_duedate} 00:00:00')
                                //                                 .year
                                //                                 .toString()) >
                                //                             int.parse(DateTime.parse(
                                //                                     '${expenses[index].max_duedate} 00:00:00')
                                //                                 .year
                                //                                 .toString()) &&
                                //                         expenses.length !=
                                //                             (index + 1))
                                //                     ? '31 ธ.ค. ${DateTime.parse('${expenses[index].max_duedate} 00:00:00').year + 543}'
                                //                     : (expenses[index]
                                //                                     .max_duedate ==
                                //                                 null ||
                                //                             expenses[index]
                                //                                     .max_duedate
                                //                                     .toString() ==
                                //                                 '')
                                //                         ? '-'
                                //                         : '${DateFormat('dd MMM', 'TH').format(DateTime.parse("${DateFormat("yyyy-MM-dd HH:mm:ss").parse('${expenses[index].max_duedate} 00:00:00')}"))} ${DateTime.parse('${expenses[index].max_duedate} 00:00:00').year + 543}',
                                //             // '${expenses[index].max_duedate}',
                                //             textAlign: pw.TextAlign.center,
                                //             style: pw.TextStyle(
                                //               color: Colors_pd,
                                //               fontSize: font_Size,
                                //               fontWeight: pw.FontWeight.bold,
                                //               font: ttf,
                                //             ),
                                //           ),
                                //         )),
                                //   ],
                                // ),
                                pw.Row(
                                  children: [
                                    pw.Text(
                                      ' ' * 12 + 'อัตราค่าเช่าตั้งแต่วันที่',
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
                                            (expenses[index].dueDate == null ||
                                                    expenses[index]
                                                            .dueDate
                                                            .toString() ==
                                                        '')
                                                ? '-'
                                                : '${expenses[index].sday} ${DateFormat('MMM', 'TH').format(DateTime.parse("${DateFormat("yyyy-MM-dd HH:mm:ss").parse('${expenses[index].dueDate} 00:00:00')}"))} ${DateTime.parse('${expenses[index].dueDate} 00:00:00').year + 543}',
                                            // (expenses[index].dueDate == null ||
                                            //         expenses[index]
                                            //                 .dueDate
                                            //                 .toString() ==
                                            //             '')
                                            //     ? '-'
                                            //     : '${DateFormat('dd MMM', 'TH').format(DateTime.parse("${DateFormat("yyyy-MM-dd HH:mm:ss").parse('${expenses[index].dueDate} 00:00:00')}"))} ${DateTime.parse('${expenses[index].dueDate} 00:00:00').year + 543}',
                                            // '${expenses[index].dueDate}',
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
                                            (expenses[index].max_duedate ==
                                                        null ||
                                                    expenses[index]
                                                            .max_duedate
                                                            .toString() ==
                                                        '')
                                                ? '-'
                                                : (index + 1 == expenses.length)
                                                    ? (Form_ldate ==
                                                                '0000-00-00' ||
                                                            Form_ldate == '' ||
                                                            Form_ldate == null)
                                                        ? '-'
                                                        : '${DateFormat('dd MMM', 'th').format(DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_ldate 00:00:00')}"))} ${DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_ldate 00:00:00')}").year + 543}'
                                                    : '${expenses[index].sday} ${DateFormat('MMM', 'TH').format(DateTime.parse("${DateFormat("yyyy-MM-dd HH:mm:ss").parse('${expenses[index].max_duedate} 00:00:00')}"))} ${DateTime.parse('${expenses[index].max_duedate} 00:00:00').year + 543}',
                                            // '${expenses[index].max_duedate}',
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
                                    pw.Text(
                                      ' ' * 12 + 'ชำระค่าเช่าเดือนละ',
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
                                            (expenses[index].totalExp == null ||
                                                    expenses[index]
                                                            .totalExp
                                                            .toString() ==
                                                        '')
                                                ? ' 0.00 บาท (~${convertToThaiBaht(0.00)}~)'
                                                : " ${nFormat.format(double.parse(expenses[index].totalExp.toString()))} บาท (~${convertToThaiBaht(double.parse(expenses[index].totalExp.toString()))}~) ",
                                            textAlign: pw.TextAlign.left,
                                            style: pw.TextStyle(
                                              color: Colors_pd,
                                              fontSize: font_Size,
                                              fontWeight: pw.FontWeight.bold,
                                              font: ttf,
                                            ),
                                          ),
                                        )),
                                    pw.Text(
                                      (quotxSelectModels
                                                  .where((e) =>
                                                      e.expser.toString() ==
                                                      '1')
                                                  .length ==
                                              0)
                                          ? 'หักภาษี ณ ที่จ่าย '
                                          : 'หักภาษี ณ ที่จ่าย ' +
                                              '( ${quotxSelectModels.where((e) => e.expser.toString() == '1').map((e) => e.nwht != null ? double.parse(e.nwht.toString()) : 0.00).fold(0.00, (a, b) => a + b)} ) % ',
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                        fontSize: font_Size,
                                        font: ttf,
                                        color: Colors_pd,
                                      ),
                                    ),
                                    pw.Expanded(
                                      flex: 2,
                                      child: pw.Container(
                                        decoration: pw.BoxDecoration(
                                            border: pw.Border(
                                                bottom: pw.BorderSide(
                                          color: Colors_pd,
                                          width:
                                              0.3, // Underline thickness 10096-10-2024
                                        ))),
                                        child: pw.Text(
                                          (quotxSelectModels
                                                      .where((e) =>
                                                          e.expser.toString() ==
                                                          '1')
                                                      .length ==
                                                  0)
                                              ? '0.00'
                                              : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '1' && e.cfid.toString() != '1').map((e) => e.wht != null ? double.parse(e.wht.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ',
                                          textAlign: pw.TextAlign.center,
                                          style: pw.TextStyle(
                                            color: Colors_pd,
                                            fontSize: font_Size,
                                            fontWeight: pw.FontWeight.bold,
                                            font: ttf,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                pw.SizedBox(height: 1 * PdfPageFormat.mm),
                                pw.Row(
                                  children: [
                                    pw.Text(
                                      ' ' * 12 + 'รวมเป็นเงินทั้งสิ้น',
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                        fontSize: font_Size,
                                        font: ttf,
                                        color: Colors_pd,
                                      ),
                                    ),
                                    pw.Expanded(
                                      flex: 2,
                                      child: pw.Container(
                                        decoration: pw.BoxDecoration(
                                            border: pw.Border(
                                                bottom: pw.BorderSide(
                                          color: Colors_pd,
                                          width: 0.3, // Underline thickness
                                        ))),
                                        child: pw.Text(
                                          (expenses[index].totalExp == null ||
                                                  expenses[index]
                                                          .totalExp
                                                          .toString() ==
                                                      '')
                                              ? ' 0.00 บาท (~${convertToThaiBaht(0.00)}~)'
                                              : " ${nFormat.format(double.parse(expenses[index].totalExp.toString()))} บาท (~${convertToThaiBaht(double.parse(expenses[index].totalExp.toString()))}~) ",
                                          textAlign: pw.TextAlign.center,
                                          style: pw.TextStyle(
                                            color: Colors_pd,
                                            fontSize: font_Size,
                                            fontWeight: pw.FontWeight.bold,
                                            font: ttf,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                pw.SizedBox(height: 1 * PdfPageFormat.mm),
                              ])),

                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 12 +
                            'อนึ่ง การชำระค่าเช่ารายเดือน ผู้เช่าต้องชำระค่าเช่าล่วงหน้าตั้งแต่วันที่ 25  ถึงวันสุดท้ายของแต่ละเดือน โดยถือเป็นค่าเช่ารายเดือนของเดือนถัด\nไป หากผู้เช่าไม่ทำการชำระภายในเวลาที่กำหนด ผู้ให้เช่ามีสิทธิคิดค่าปรับวันละรายเดือนของเดือนถัดไป หากผู้เช่าไม่ทำการชำระภายในเวลาที่กำหนดผู้ให้',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.Row(children: [
                        pw.Text(
                          'เช่ามีสิทธิคิดค่าปรับวันละ',
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
                                (quotxSelectModels
                                            .where((e) =>
                                                e.expser.toString() == '17')
                                            .length ==
                                        0)
                                    ? '0.00 บาท (~${convertToThaiBaht(0.00)}~)'
                                    : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '17').map((e) => e.amt != null ? double.parse(e.amt.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ' +
                                        '(~${convertToThaiBaht((quotxSelectModels.where((e) => e.expser.toString() == '17').map((e) => e.amt != null ? double.parse(e.amt.toString()) : 0.00).fold(0.00, (a, b) => a + b)))}~)',
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
                          'นับตั้งแต่วันที่เลยกำหนดชำระ และหากผู้เช่ายังไม่ชำระค่าเช่าและค่าปรับ',
                          textAlign: pw.TextAlign.left,
                          style: pw.TextStyle(
                            fontSize: font_Size,
                            font: ttf,
                            color: Colors_pd,
                          ),
                        ),
                      ]),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        'ภายในวันที่ 5 ของเดือนถัดไป ผู้ให้เช่ามีสิทธิบอกเลิกสัญญาได้ทันที ',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      (expenses.length == 0)
                          ? pw.SizedBox(height: 2 * PdfPageFormat.mm)
                          : (expenses.length == 3)
                              ? pw.SizedBox(height: 15 * PdfPageFormat.mm)
                              : (expenses.length == 2 || expenses.length == 1)
                                  ? pw.SizedBox(height: 25 * PdfPageFormat.mm)
                                  : pw.SizedBox(height: 5 * PdfPageFormat.mm),
                      // pw.Text(
                      //   'ข้อ 5. อัตราค่าเช่า',
                      //   textAlign: pw.TextAlign.left,
                      //   style: pw.TextStyle(
                      //     color: Colors_pd,
                      //     fontSize: font_Size,
                      //     fontWeight: pw.FontWeight.bold,
                      //     font: ttf,
                      //   ),
                      // ),
                      // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      // pw.Row(
                      //   children: [
                      //     pw.Text(
                      //       ' ' * 12 +
                      //           'ผู้เช่าตกลงจะชำระค่าเช่าเป็นรายเดือน เดือนละ',
                      //       textAlign: pw.TextAlign.left,
                      //       style: pw.TextStyle(
                      //         fontSize: font_Size,
                      //         font: ttf,
                      //         color: Colors_pd,
                      //       ),
                      //     ),
                      //     pw.Expanded(
                      //       flex: 2,
                      //       child: pw.Container(
                      //         decoration: pw.BoxDecoration(
                      //             border: pw.Border(
                      //                 bottom: pw.BorderSide(
                      //           color: Colors_pd,
                      //           width: 0.3, // Underline thickness
                      //         ))),
                      //         child: pw.Text(
                      //           (quotxSelectModels
                      //                       .where((e) =>
                      //                           e.expser.toString() == '1')
                      //                       .length ==
                      //                   0)
                      //               ? '0.00'
                      //               : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '1').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ',
                      //           // +
                      //           //     '(~${convertToThaiBaht(quotxSelectModels.where((e) => e.expser.toString() == '1').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b))}~)',
                      //           // " -  บาท ( - )",
                      //           textAlign: pw.TextAlign.center,
                      //           style: pw.TextStyle(
                      //             color: Colors_pd,
                      //             fontSize: font_Size,
                      //             fontWeight: pw.FontWeight.bold,
                      //             font: ttf,
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //     pw.Text(
                      //       'ให้แก่ผู้ให้เช่า โดยชำระผ่านทางบัญชี',
                      //       textAlign: pw.TextAlign.left,
                      //       style: pw.TextStyle(
                      //         fontSize: font_Size,
                      //         font: ttf,
                      //         color: Colors_pd,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      // pw.Text(
                      //   'ธนาคารกรุงเทพ จำกัด (มหาชน) สาขาท่าแพ ประเภทออมทรัพย์ เลขที่บัญชี 251-4-93765-1 ชื่อบัญชี “บริษัท ชอยส์ มินิสโตร์ จำกัด”',
                      //   textAlign: pw.TextAlign.left,
                      //   style: pw.TextStyle(
                      //     fontSize: font_Size,
                      //     font: ttf,
                      //     color: Colors_pd,
                      //   ),
                      // ),
                      // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      // pw.Text(
                      //   ' ' * 12 +
                      //       'อนึ่ง การชำระค่าเช่ารายเดือน ผู้เช่าต้องชำระค่าเช่าล่วงหน้าภายในวันสุดท้ายของเดือนปฏิทินก่อนหน้า โดยถือเป็นค่าเช่ารายเดือนของเดือนถัด',
                      //   textAlign: pw.TextAlign.left,
                      //   maxLines: 1,
                      //   style: pw.TextStyle(
                      //     fontSize: font_Size,
                      //     font: ttf,
                      //     color: Colors_pd,
                      //   ),
                      // ),
                      // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      // pw.Row(
                      //   children: [
                      //     pw.Text(
                      //       'ไปหากผู้เช่าไม่ทำการชำระภายในเวลาที่กำหนด ผู้ให้เช่ามีสิทธิคิดค่าปรับวันละ',
                      //       textAlign: pw.TextAlign.left,
                      //       style: pw.TextStyle(
                      //         fontSize: font_Size,
                      //         font: ttf,
                      //         color: Colors_pd,
                      //       ),
                      //     ),
                      //     pw.Expanded(
                      //         flex: 1,
                      //         child: pw.Container(
                      //           // height: 13,
                      //           decoration: pw.BoxDecoration(
                      //               border: pw.Border(
                      //                   bottom: pw.BorderSide(
                      //             color: Colors_pd,
                      //             width: 0.3, // Underline thickness
                      //           ))),
                      //           child: pw.Text(
                      //             (quotxSelectModels
                      //                         .where((e) =>
                      //                             e.expser.toString() == '17')
                      //                         .length ==
                      //                     0)
                      //                 ? '0.00 (~${convertToThaiBaht(0.00)}~)'
                      //                 : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '17').map((e) => e.amt != null ? double.parse(e.amt.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ',
                      //             // "  -   บาท (    -    ) ",
                      //             textAlign: pw.TextAlign.center,
                      //             style: pw.TextStyle(
                      //               color: Colors_pd,
                      //               fontSize: font_Size,
                      //               fontWeight: pw.FontWeight.bold,
                      //               font: ttf,
                      //             ),
                      //           ),
                      //         )),
                      //   ],
                      // ),
                      // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      // pw.Row(
                      //   children: [
                      //     pw.Expanded(
                      //         child: pw.Container(
                      //       // height: 13,
                      //       decoration: pw.BoxDecoration(
                      //           border: pw.Border(
                      //               bottom: pw.BorderSide(
                      //         color: Colors_pd,
                      //         width: 0.3, // Underline thickness
                      //       ))),
                      //       child: pw.Text(
                      //         (quotxSelectModels
                      //                     .where((e) =>
                      //                         e.expser.toString() == '17')
                      //                     .length ==
                      //                 0)
                      //             ? '( - )'
                      //             : '(~${convertToThaiBaht(quotxSelectModels.where((e) => e.expser.toString() == '17').map((e) => e.amt != null ? double.parse(e.amt.toString()) : 0.00).fold(0.00, (a, b) => a + b))}~)',
                      //         textAlign: pw.TextAlign.center,
                      //         style: pw.TextStyle(
                      //           fontSize: font_Size,
                      //           font: ttf,
                      //           color: Colors_pd,
                      //         ),
                      //       ),
                      //     )),
                      //     pw.Text(
                      //       (quotxSelectModels
                      //                   .where(
                      //                       (e) => e.expser.toString() == '17')
                      //                   .length ==
                      //               0)
                      //           ? ' นับตั้งแต่วันที่เลยกำหนดชำระ และหากผู้เช่ายังไม่ชำระค่าเช่าและค่าปรับภายในวันที่'
                      //           : ' นับตั้งแต่วันที่เลยกำหนดชำระ และหากผู้เช่ายังไม่ชำระค่าเช่าและค่าปรับภายในวันที่',
                      //       textAlign: pw.TextAlign.left,
                      //       style: pw.TextStyle(
                      //         fontSize: font_Size,
                      //         font: ttf,
                      //         color: Colors_pd,
                      //       ),
                      //     ),
                      //     pw.Container(
                      //       width: 30,
                      //       // height: 13,
                      //       decoration: pw.BoxDecoration(
                      //           border: pw.Border(
                      //               bottom: pw.BorderSide(
                      //         color: Colors_pd,
                      //         width: 0.3, // Underline thickness
                      //       ))),
                      //       child: pw.Text(
                      //         "5",
                      //         textAlign: pw.TextAlign.center,
                      //         style: pw.TextStyle(
                      //           color: Colors_pd,
                      //           fontSize: font_Size,
                      //           fontWeight: pw.FontWeight.bold,
                      //           font: ttf,
                      //         ),
                      //       ),
                      //     ),
                      //     // pw.Text(
                      //     //   'ของเดือนถัดไป',
                      //     //   textAlign: pw.TextAlign.left,
                      //     //   style: pw.TextStyle(
                      //     //     fontSize: font_Size,
                      //     //     font: ttf,
                      //     //     color: Colors_pd,
                      //     //   ),
                      //     // ),
                      //   ],
                      // ),

                      // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      // pw.Text(
                      //   'ของเดือนถัดไป ผู้ให้เช่ามีสิทธิบอกเลิกสัญญาได้ทันที ',
                      //   textAlign: pw.TextAlign.left,
                      //   style: pw.TextStyle(
                      //     fontSize: font_Size,
                      //     font: ttf,
                      //     color: Colors_pd,
                      //   ),
                      // ),
                      // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        'ข้อ 6. เงินประกัน',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          color: Colors_pd,
                          fontSize: font_Size,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 12 + '6.1 ประกันการเช่า',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          color: Colors_pd,
                          fontSize: font_Size,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Row(
                        children: [
                          pw.Text(
                            ' ' * 12 +
                                'ผู้เช่าจะต้องวางเงินประกันการเช่าแก่ผู้ให้เช่า  เป็นจำนวนเงิน',
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
                                // height: 13,
                                decoration: pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                  color: Colors_pd,
                                  width: 0.3, // Underline thickness
                                ))),
                                child: pw.Text(
                                  (quotxSelectModels
                                              .where((e) =>
                                                  e.expser.toString() == '2')
                                              .length ==
                                          0)
                                      ? '0.00 บาท (~${convertToThaiBaht(0.00)}~)'
                                      : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '2').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ' +
                                          '(~${convertToThaiBaht(double.parse('${quotxSelectModels.where((e) => e.expser.toString() == '2').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b)}'))}~)',
                                  // (Form_PakanAll_Total == null ||
                                  //         Form_PakanAll_Total.toString() == '')
                                  //     ? '0.00 (~${convertToThaiBaht(0.00)}~)'
                                  //     : '${nFormat.format(double.parse('${Form_PakanAll_Total}'))} บาท ' +
                                  //         '(~${convertToThaiBaht(double.parse('${Form_PakanAll_Total}'))}~)',
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
                      pw.SizedBox(height: 2 * PdfPageFormat.mm),
                      pw.Row(
                        children: [
                          pw.Text(
                            'โดยเงินจำนวนดังกล่าวเป็นเงินมาจากประกันการเช่าจากสัญญาเดิม สัญญาเลขที่',
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
                              // width: 60,
                              // height: 13,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border(
                                      bottom: pw.BorderSide(
                                color: Colors_pd,
                                width: 0.3, // Underline thickness
                              ))),
                              child: pw.Text(
                                (Get_Value_cid.toString() ==
                                        Form_renew_cid.toString())
                                    ? ' - '
                                    : '${Form_renew_cid}',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  color: Colors_pd,
                                  fontSize: font_Size,
                                  fontWeight: pw.FontWeight.bold,
                                  font: ttf,
                                ),
                              ),
                            ),
                          ),
                          pw.Text(
                            'จำนวน ',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Row(
                        children: [
                          pw.Expanded(
                              flex: 1,
                              child: pw.Container(
                                // height: 13,
                                decoration: pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                  color: Colors_pd,
                                  width: 0.3, // Underline thickness
                                ))),
                                child: pw.Text(
                                  (Get_Value_cid.toString() ==
                                          Form_renew_cid.toString())
                                      ? '0.00 บาท (~${convertToThaiBaht(0.00)}~)'
                                      : (Form_PakanAll_Total == null ||
                                              Form_PakanAll_Total.toString() ==
                                                  '')
                                          ? '0.00 บาท (~${convertToThaiBaht(0.00)}~)'
                                          : '${nFormat.format(double.parse('${Form_PakanAll_Total}'))} บาท ' +
                                              '(~${convertToThaiBaht(double.parse('${Form_PakanAll_Total}'))}~)',
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
                            'และผู้เช่าทำการวางเงินประกันการเช่าเพิ่มอีก',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Row(
                        children: [
                          pw.Text(
                            'จำนวน',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                          pw.Expanded(
                              flex: 2,
                              child: pw.Container(
                                // height: 13,
                                decoration: pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                  color: Colors_pd,
                                  width: 0.3, // Underline thickness
                                ))),
                                child: pw.Text(
                                  (quotxSelectModels
                                              .where((e) =>
                                                  e.expser.toString() == '2')
                                              .length ==
                                          0)
                                      ? '0.00 บาท (~${convertToThaiBaht(0.00)}~)'
                                      : '0.00 บาท (~${convertToThaiBaht(0.00)}~)',
                                  // : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '2').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ' +
                                  // '(~${convertToThaiBaht(quotxSelectModels.where((e) => e.expser.toString() == '2').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b))}~)',
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
                            'โดยมีกำหนดชำระภายในวันที่ ',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                          pw.Container(
                            width: 100,
                            decoration: pw.BoxDecoration(
                                border: pw.Border(
                                    bottom: pw.BorderSide(
                              color: Colors_pd,
                              width: 0.3, // Underline thickness
                            ))),
                            child: pw.Text(
                              (quotxSelectModels
                                          .where(
                                              (e) => e.expser.toString() == '2')
                                          .length ==
                                      0)
                                  ? ''
                                  : '${quotxSelectModels.where((model) => model.expser.toString() == '2').map(
                                        (model) => (model.pdate == null)
                                            ? ''
                                            : '${DateFormat('dd MMM', 'th').format(DateTime.parse("${DateFormat("yyyy-MM-dd HH:mm:ss").parse('${model.pdate} 00:00:00')}"))} ${DateTime.parse('${model.pdate} 00:00:00').year + 543}',
                                        // : '${model.pdate}',
                                      ).join('')}',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                color: Colors_pd,
                                fontSize: font_Size,
                                fontWeight: pw.FontWeight.bold,
                                font: ttf,
                              ),
                            ),
                          ),
                        ],
                      ),

                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        'เพื่อเป็นการประกันการชำระค่าเช่า และประกันการปฏิบัติตามสัญญานี้ รวมถึงค่าเสียหายใด ๆ  ที่ผู้เช่าต้องรับผิดตามสัญญานี้ โดยหากมีการต่อสัญญาแล้ว\nผู้ให้เช่าปรับอัตราค่าเช่าเพิ่มขึ้น ผู้เช่าจะต้องวางเงินประกันเพิ่มตามการปรับอัตราค่าเช่า  ',
                        textAlign: pw.TextAlign.left,
                        maxLines: 2,
                        style: pw.TextStyle(
                          color: Colors_pd,
                          fontSize: font_Size,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 12 +
                            'อนึ่ง เมื่อสัญญานี้สิ้นสุดลงผู้เช่าได้ส่งมอบสถานที่เช่าคืนให้แก่ผู้ให้เช่าและผู้ให้เช่าได้ตรวจรับมอบสถานที่เช่าเรียบร้อยแล้วไม่ปรากฏความเสียหาย\nใดๆผู้ให้เช่าจะคืนเงินประกันการเช่าดังกล่าวโดยไม่มีดอกเบี้ยให้แก่ผู้เช่าภายในระยะเวลา 45 วัน',
                        textAlign: pw.TextAlign.left,
                        maxLines: 2,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 12 +
                            'กรณีที่ผู้เช่ามีหนี้สินที่ค้างชำระต่อผู้ให้เช่า ผู้ให้เช่ามีสิทธิหักเงินประกันนี้ได้   และหากยังมีเงินเหลืออยู่ผู้ให้เช่าจะคืนให้แก่ผู้เช่าแต่หากหักหนี้สินที่\nค้างชำระจากเงินประกันแล้วยังไม่คุ้มกับเงินที่ผู้เช่าค้างชำระ ผู้ให้เช่ามีสิทธิเรียกร้องจากผู้เช่าจนครบ',
                        textAlign: pw.TextAlign.left,
                        maxLines: 2,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 12 + '6.2 ประกันตกแต่ง',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          color: Colors_pd,
                          fontSize: font_Size,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 12 +
                            'ขณะที่ผู้เช่าทำการตกแต่งอาคารที่เช่า ไม่ว่าจะเป็นภายนอกอาคาร  หรือภายในอาคารก็ตาม ผู้เช่าจะต้องวางเงินประกันการตกแต่งให้แก่ผู้ให้เช่า',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.Row(
                        children: [
                          pw.Text(
                            'เป็นจำนวน',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                          pw.Expanded(
                              flex: 2,
                              child: pw.Container(
                                // height: 13,
                                decoration: pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                  color: Colors_pd,
                                  width: 0.3, // Underline thickness
                                ))),
                                child: pw.Text(
                                  (quotxSelectModels
                                              .where((e) =>
                                                  e.expser.toString() == '38')
                                              .length ==
                                          0)
                                      ? '0.00 บาท (~${convertToThaiBaht(0.00)}~)'
                                      : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '38').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ' +
                                          '(~${convertToThaiBaht(quotxSelectModels.where((e) => e.expser.toString() == '38').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b))}~)',
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
                            'โดยมีกำหนดชำระ',
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
                                // height: 13,
                                decoration: pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                  color: Colors_pd,
                                  width: 0.3, // Underline thickness
                                ))),
                                child: pw.Text(
                                  (quotxSelectModels
                                              .where((e) =>
                                                  e.expser.toString() == '38')
                                              .length ==
                                          0)
                                      ? '-'
                                      : '${quotxSelectModels.where((model) => model.expser.toString() == '38').map((model) => model.pdate).join(', ')}',
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
                            'กรณีเกิดความเสียหายใดๆอันเกิด',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        'จากการตกแต่งที่ผู้เช่าต้องรับผิดตามสัญญานี้หรือหากความเสียหายยังไม่เพียงพอ ผู้ให้เช่ามีสิทธิเรียกค่าเสียหายเพิ่มเติม   จนกว่าจะได้รับชำระจนครบถ้วน\nเมื่อผู้เช่าทำการตกแต่งอาคารที่เช่าเสร็จสิ้นแล้วผู้ให้เช่าจะคืนเงินประกันการตกแต่งภายใน  45 วัน   นับตั้งแต่ตัวแทนของผู้ให้เช่าได้ทำการตรวจสอบความ\nเสียหายเรียบร้อยและไม่ปรากฏความเสียหายใด ๆ อันเกิดจากการตกแต่งอาคารที่เช่า',
                        textAlign: pw.TextAlign.left,
                        maxLines: 3,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 12 + '6.3 ประกันวินาศภัย ',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 12 +
                            'ผู้เช่าจะต้องจัดทำประกันภัยประเภท “การเสี่ยงภัยทรัพย์สิน (All Risk Insurance)” ในโครงสร้างอาคารของทรัพย์สินที่เช่า และประกันภัยความ\nรับผิดตามกฎหมายต่อบุคคลภายนอก กับบริษัทประกันภัยที่ผู้ให้เช่าจัดหาให้ หรือบริษัทประกันภัยที่ผู้เช่าจัดหามาเองโดยผู้เช่าเป็นผู้รับภาระเรื่องค่าใช้จ่าย\nและดำเนินการให้กรมธรรม์ดังกล่าวมีผลคุ้มครองตั้งแต่วันที่ผู้เช่ารับมอบทรัพย์สินที่เช่า  จนถึงตลอดระยะเวลาการเช่า   และระบุให้ผู้ให้เช่าเป็นผู้รับผลประ\nโยชน์ตลอดอายุสัญญาเช่า  ทั้งนี้  ผู้เช่าจะต้องส่งมอบสำเนากรมธรรม์ประกันภัยที่จัดทำหรือกรมธรรม์ประกันภัยต่ออายุให้กับผู้ให้เช่าด้วยเมื่อได้รับการร้อง\nขอจากผู้ให้เช่า',
                        textAlign: pw.TextAlign.left,
                        maxLines: 5,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        'ข้อ 7. ค่าเช่าสาธารณูปโภคและการชำระ',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 12 +
                            'ผู้เช่าตกลงชำระค่าสาธารณูปโภคตลอดอายุสัญญาให้แก่ผู้ให้เช่า ตามรายการใบแจ้งหนี้ของทางผู้ให้เช่า ดังนี้  ',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 12 + '7.1 อัตราค่าไฟฟ้า ',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),

                      pw.Row(
                        children: [
                          pw.Text(
                            ' ' * 12 +
                                '- ค่าธรรมเนียมในการขอใช้มิเตอร์ไฟฟ้าครั้งแรก จำนวน',
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
                                // height: 13,
                                decoration: pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                  color: Colors_pd,
                                  width: 0.3, // Underline thickness
                                ))),
                                child: pw.Text(
                                  (quotxSelectModels
                                              .where((e) =>
                                                  e.expser.toString() == '20')
                                              .length ==
                                          0)
                                      ? '0.00 บาท (~${convertToThaiBaht(0.00)}~)'
                                      : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '20').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ' +
                                          '(~${convertToThaiBaht(double.parse('${quotxSelectModels.where((e) => e.expser.toString() == '20').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b)}'))}~)',
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
                          pw.Text(
                            ' ' * 12 + '- ค่าไฟฟ้า หน่วยละ',
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
                                // height: 13,
                                decoration: pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                  color: Colors_pd,
                                  width: 0.3, // Underline thickness
                                ))),
                                child: pw.Text(
                                  (quotxSelectModels
                                              .where((e) =>
                                                  e.expser.toString() == '6' &&
                                                  e.unitser.toString() == '6')
                                              .length ==
                                          0)
                                      ? '0.00 บาท (~${convertToThaiBaht(0.00)}~)'
                                      : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '6' && e.unitser.toString() == '6').map((e) => e.qty != null ? double.parse(e.qty.toString()) : 0.00).first)} บาท ' +
                                          '(~${convertToThaiBaht(quotxSelectModels.where((e) => e.expser.toString() == '6' && e.unitser.toString() == '6').map((e) => e.qty != null ? double.parse(e.qty.toString()) : 0.00).first)}~)',
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
                            'พร้อมภาษีมูลค่าเพิ่ม',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),

                      pw.Row(
                        children: [
                          pw.Text(
                            ' ' * 12 +
                                '- ค่าไฟฟ้า “แบบเหมาจ่าย” ในอัตราเดือนละ',
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
                                // height: 13,
                                decoration: pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                  color: Colors_pd,
                                  width: 0.3, // Underline thickness
                                ))),
                                child: pw.Text(
                                  (quotxSelectModels
                                              .where((e) =>
                                                  e.expser.toString() == '6' &&
                                                  e.unitser.toString() == '7')
                                              .length ==
                                          0)
                                      ? '0.00 บาท (~${convertToThaiBaht(0.00)}~)'
                                      : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '6' && e.unitser.toString() == '7').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ' +
                                          '(~${convertToThaiBaht(double.parse('${quotxSelectModels.where((e) => e.expser.toString() == '7' && e.unitser.toString() == '6').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b)}'))}~)',
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
                            'พร้อมภาษีมูลค่าเพิ่ม',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 12 + '7.2 อัตราค่าน้ำประปา',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),

                      pw.Row(
                        children: [
                          pw.Text(
                            ' ' * 12 +
                                '- ค่าธรรมเนียมในการขอใช้มิเตอร์น้ำประปาครั้งแรก จำนวน',
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
                                // height: 13,
                                decoration: pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                  color: Colors_pd,
                                  width: 0.3, // Underline thickness
                                ))),
                                child: pw.Text(
                                  (quotxSelectModels
                                              .where((e) =>
                                                  e.expser.toString() == '21')
                                              .length ==
                                          0)
                                      ? '0.00 บาท (~${convertToThaiBaht(0.00)}~)'
                                      : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '21').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ' +
                                          '(~${convertToThaiBaht(double.parse('${quotxSelectModels.where((e) => e.expser.toString() == '21').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b)}'))}~)',
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
                          pw.Text(
                            ' ' * 12 + '- ค่าน้ำประปา หน่วยละ',
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
                                // height: 13,
                                decoration: pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                  color: Colors_pd,
                                  width: 0.3, // Underline thickness
                                ))),
                                child: pw.Text(
                                  (quotxSelectModels
                                              .where((e) =>
                                                  e.expser.toString() == '7' &&
                                                  e.unitser.toString() == '6')
                                              .length ==
                                          0)
                                      ? '0.00 บาท (~${convertToThaiBaht(0.00)}~)'
                                      : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '7' && e.unitser.toString() == '6').map((e) => e.qty != null ? double.parse(e.qty.toString()) : 0.00).first)} บาท ' +
                                          '(~${convertToThaiBaht(quotxSelectModels.where((e) => e.expser.toString() == '7' && e.unitser.toString() == '6').map((e) => e.qty != null ? double.parse(e.qty.toString()) : 0.00).first)}~)',
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
                            'พร้อมภาษีมูลค่าเพิ่ม',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Row(
                        children: [
                          pw.Text(
                            ' ' * 12 +
                                '- ค่าน้ำประปา “แบบเหมาจ่าย” ในอัตราเดือนละ',
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
                                // height: 13,
                                decoration: pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                  color: Colors_pd,
                                  width: 0.3, // Underline thickness
                                ))),
                                child: pw.Text(
                                  (quotxSelectModels
                                              .where((e) =>
                                                  e.expser.toString() == '7' &&
                                                  e.unitser.toString() == '7')
                                              .length ==
                                          0)
                                      ? '0.00 บาท (~${convertToThaiBaht(0.00)}~)'
                                      : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '7' && e.unitser.toString() == '7').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ' +
                                          '(~${convertToThaiBaht(double.parse('${quotxSelectModels.where((e) => e.expser.toString() == '7' && e.unitser.toString() == '7').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b)}'))}~)',
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
                            'พร้อมภาษีมูลค่าเพิ่ม',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ],
                      ),

                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 12 +
                            'กรณีที่ผู้เช่าชำระค่าไฟฟ้าและค่าประปาแก่การไฟฟ้าและการประปาส่วนภูมิภาค  ผู้เช่าต้องชำระค่าไฟฟ้าและค่าประปาที่ใช้ในสถานที่เช่าตลอด\nอายุสัญญา ตามรายการใบแจ้งค่าไฟฟ้าของการไฟฟ้าส่วนภูมิภาค  และใบแจ้งค่าประปาของการประปาส่วนภูมิภาค  โดยผู้เช่าช่วงจะต้องทำการส่งสำเนา\nรายการใบแจ้งค่าไฟฟ้าและประปา พร้อมหลักฐานการชำระเงินมาให้ผู้ให้เช่าช่วงทุกๆ เดือน        ',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 5 * PdfPageFormat.mm),
                      pw.Text(
                        'ข้อ 8. ค่าบริการพื้นที่ส่วนกลาง ',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 12 +
                            'ผู้ให้เช่าตกลงให้บริการ และผู้เช่าตกลงรับบริการต่างๆ ดังต่อไปนี้',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 12 +
                            '8.1 การจัดให้มีระบบไฟฟ้า แสงสว่างบริเวณภายนอกสถานที่เช่าภายในบริเวณโครงการ',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 12 +
                            '8.2 การจัดให้มีระบบน้ำประปาบริเวณภายนอกสถานที่เช่าภายในบริเวณโครงการ',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 12 + '8.3 การจัดให้มีบริการที่จอดรถ',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 12 +
                            '8.4 การจัดให้มีแม่บ้านและบริการบำรุงรักษาความสะอาดบริเวณภายนอกสถานที่เช่า',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 12 +
                            '8.5 จัดให้มีบริการบำรุงรักษาและซ่อมแซมห้องสุขาของโครงการเพื่อประโยชน์ของสถานที่เช่า',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 12 +
                            '8.6 จัดให้มีการตกแต่ง ซ่อมแซม และบริการอื่นๆ ที่จำเป็นในบริเวณภายนอกสถานที่เช่าที่ผู้ให้เช่าเห็นว่าเหมาะสม',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 12 +
                            'ผู้เช่าตกลงชำระค่าบริการพื้นที่ส่วนกลางรายเดือนพร้อมภาษีมูลค่าเพิ่ม ตามอัตราที่ผู้ให้เช่ากำหนด ดังนี้',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      for (int index8 = 0; index8 < 3; index8++)
                        pw.Column(children: [
                          pw.Row(
                            children: [
                              pw.Text(
                                ' ' * 12 + 'ตั้งแต่วันที่',
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
                                    // height: 13,
                                    decoration: pw.BoxDecoration(
                                        border: pw.Border(
                                            bottom: pw.BorderSide(
                                      color: Colors_pd,
                                      width: 0.3, // Underline thickness
                                    ))),
                                    child: pw.Text(
                                      '-',
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
                                    // height: 13,
                                    decoration: pw.BoxDecoration(
                                        border: pw.Border(
                                            bottom: pw.BorderSide(
                                      color: Colors_pd,
                                      width: 0.3, // Underline thickness
                                    ))),
                                    child: pw.Text(
                                      '-',
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
                              pw.Text(
                                ' ' * 12 + 'ในอัตราเดือนละ',
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
                                    // height: 13,
                                    decoration: pw.BoxDecoration(
                                        border: pw.Border(
                                            bottom: pw.BorderSide(
                                      color: Colors_pd,
                                      width: 0.3, // Underline thickness
                                    ))),
                                    child: pw.Text(
                                      (quotxSelectModels
                                                  .where((e) =>
                                                      e.expser.toString() ==
                                                          '39' &&
                                                      e.unitser.toString() ==
                                                          '2')
                                                  .length ==
                                              0)
                                          ? '0.00 บาท'
                                          : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '39' && e.unitser.toString() == '2').map((e) => e.amt != null ? double.parse(e.amt.toString()) : 0.00).reduce((a, b) => a + b))} บาท ',
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
                                'บาท/ตารางเมตร/เดือนเป็นจำนวนเงินเดือนละ',
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
                                    // height: 13,
                                    decoration: pw.BoxDecoration(
                                        border: pw.Border(
                                            bottom: pw.BorderSide(
                                      color: Colors_pd,
                                      width: 0.3, // Underline thickness
                                    ))),
                                    child: pw.Text(
                                      (quotxSelectModels
                                                  .where((e) =>
                                                      e.expser.toString() ==
                                                          '39' &&
                                                      e.unitser.toString() ==
                                                          '2')
                                                  .length ==
                                              0)
                                          ? '0.00 บาท'
                                          : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '39' && e.unitser.toString() == '2').map((e) => e.amt != null ? double.parse(e.amt.toString()) : 0.00).reduce((a, b) => a + b))} บาท ',
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
                        ]),

                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        'ข้อ 9. ภาษีที่ดินสิ่งปลูกสร้าง และภาษีอื่น ๆ',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 12 +
                            'ผู้เช่าตกลงรับภาระในภาษีที่ดินและสิ่งปลูกสร้าง   และภาษีอื่นใดที่เกี่ยวข้องกับทรัพย์สินที่เช่าหรือเกิดจากการประกอบกิจการของผู้เช่า\nซึ่งจะต้องชำระตามอัตราที่กฎหมายกำหนดในแต่ละปี ตั้งแต่วันที่เริ่มสัญญาตลอดจนสิ้นอายุสัญญานี้',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),

                      pw.Row(
                        children: [
                          pw.Text(
                            'โดยผู้เช่าจะชำระค่าภาษีแต่ละปีภายในเวลาที่ผู้ให้เช่ากำหนด เป็นรายเดือน เดือนละ',
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
                                // height: 13,
                                decoration: pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                  color: Colors_pd,
                                  width: 0.3, // Underline thickness
                                ))),
                                child: pw.Text(
                                  (quotxSelectModels
                                              .where((e) =>
                                                  e.expser.toString() == '22' &&
                                                  e.unitser.toString() == '2')
                                              .length ==
                                          0)
                                      ? '0.00 บาท (~${convertToThaiBaht(0.00)}~)'
                                      : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '22' && e.unitser.toString() == '2').map((e) => e.amt != null ? double.parse(e.amt.toString()) : 0.00).reduce((a, b) => a + b))} บาท ' +
                                          "(~${convertToThaiBaht(quotxSelectModels.where((e) => e.expser.toString() == '22' && e.unitser.toString() == '2').map((e) => e.amt != null ? double.parse(e.amt.toString()) : 0.00).reduce((a, b) => a + b))}~)",
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
                          pw.Text(
                            '/รายปี ปีละ',
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
                                // height: 13,
                                decoration: pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                  color: Colors_pd,
                                  width: 0.3, // Underline thickness
                                ))),
                                child: pw.Text(
                                  (quotxSelectModels
                                              .where((e) =>
                                                  e.expser.toString() == '22' &&
                                                  e.unitser.toString() == '1')
                                              .length ==
                                          0)
                                      ? '0.00 บาท (~${convertToThaiBaht(0.00)}~)'
                                      : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '22' && e.unitser.toString() == '1').map((e) => e.amt != null ? double.parse(e.amt.toString()) : 0.00).reduce((a, b) => a + b))} บาท '
                                          "(~${convertToThaiBaht(quotxSelectModels.where((e) => e.expser.toString() == '22' && e.unitser.toString() == '1').map((e) => e.amt != null ? double.parse(e.amt.toString()) : 0.00).reduce((a, b) => a + b))}~)",
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    color: Colors_pd,
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                  ),
                                ),
                              )),
                          // pw.Text(
                          //   'โดยชำระเงินผ่านช่องทางที่ผู้ให้เช่ากำหนด',
                          //   textAlign: pw.TextAlign.left,
                          //   style: pw.TextStyle(
                          //     fontSize: font_Size,
                          //     font: ttf,
                          //     color: Colors_pd,
                          //   ),
                          // ),
                        ],
                      ),
                      pw.SizedBox(height: 2 * PdfPageFormat.mm),
                      pw.Text(
                        'หากผู้เช่ามิได้ชำระค่าภาษีใดๆ ตามที่ตกลงไว้ในวรรคแรก หรือได้ชำระแล้ว แต่ขาดเงินไปจำวนเท่าใดและผู้เช่าได้ชำระค่าภาษีนั้นให้แล้ว  ผู้เช่าจะต้องชดใช้\nค่าภาษีที่ผู้ให้เช่าได้ชำระให้ทั้งหมดให้ผู้เช่าช่วง ภายในเวลาที่ผู้ให้เช่ากำหนด',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        'ข้อ 10. การต่ออายุสัญญา',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),

                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 12 +
                            '10.1 ผู้ให้เช่ามีสิทธิกำหนดอัตราค่าเช่าใหม่เพิ่มขึ้นทุก ๆ ปี  ปีละไม่เกิน  20%',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 12 +
                            '10.2 หากครบกำหนดอายุสัญญาเช่านี้แล้ว ผู้เช่ามีความประสงค์จะต่ออายุสัญญา   ผู้เช่าต้องแจ้งความจำนงเป็นลายลักษณ์อักษรให้ผู้ให้เช่าทราบ',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.Text(
                        'ล่วงหน้าไม่น้อยกว่า 90 วัน ก่อนสิ้นสุดอายุสัญญาเช่านี้ ผู้ให้เช่าจะพิจารณาให้ผู้เช่าเช่าต่อไปหรือไม่ก็ได้    หากให้เช่าต่อผู้เช่าจะต้องทำสัญญาฉบับใหม่กับ\nผู้ให้เช่าทุกคราวที่มีการต่อสัญญาก่อนสัญญานี้จะสิ้นสุดลง  หากผู้เช่าไม่แจ้งความจำนงว่าจะขอเช่าต่อหรือผู้เช่าไม่ทำสัญญาฉบับใหม่     กับผู้ให้เช่าก่อนที่\nสัญญานี้จะสิ้นสุดลงให้ถือว่าไม่มีการเช่าต่อภายหลังครบกำหนดอายุสัญญานี้กันอีกต่อไป ',
                        textAlign: pw.TextAlign.left,
                        maxLines: 4,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 5 * PdfPageFormat.mm),
                      pw.Text(
                        'ข้อ 11. ข้อรับรองและสัญญาของผู้เช่า',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Container(
                        padding: pw.EdgeInsets.fromLTRB(35, 0, 0, 0),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Text(
                              '11.1 ผู้เช่าจะต้องดูแลรักษาทรัพย์สินที่เช่าเสมือนวิญญูชนจะพึงดูแลรักษาทรัพย์ของตนและผู้เช่า จะต้องเป็นผู้เสียค่าใช้จ่ายในการบำรุงรักษา\nและซ่อมแซมอาคารที่เช่าเอง',
                              textAlign: pw.TextAlign.justify,
                              style: pw.TextStyle(
                                fontSize: font_Size,
                                font: ttf,
                                color: Colors_pd,
                              ),
                            ),
                            pw.SizedBox(height: 1 * PdfPageFormat.mm),
                            pw.Text(
                              '11.2 ผู้เช่าจะต้องไม่นำวัตถุไวไฟหรือวัตถุอันตรายอื่นใดมาเก็บรักษาไว้ในอาคารที่เช่า  พร้อมจัดเตรียมถังดับเพลิงให้เหมาะสม หากเกิดความเสียหายอันสืบเนื่องจากความผิดของผู้เช่าเอง ต้องชดใช้ค่าเสียหายทั้งหมดที่เกิดขึ้น',
                              textAlign: pw.TextAlign.justify,
                              style: pw.TextStyle(
                                fontSize: font_Size,
                                font: ttf,
                                color: Colors_pd,
                              ),
                            ),
                            pw.SizedBox(height: 1 * PdfPageFormat.mm),
                            pw.Text(
                              '11.3 ผู้เช่าจะต้องไม่กระทำการใดๆ ให้เป็นที่รบกวนหรือก่อให้เกิดความรำคาญแก่เจ้าของอาคารข้างเคียง',
                              textAlign: pw.TextAlign.justify,
                              style: pw.TextStyle(
                                fontSize: font_Size,
                                font: ttf,
                                color: Colors_pd,
                              ),
                            ),
                            pw.SizedBox(height: 1 * PdfPageFormat.mm),
                            pw.Text(
                              '11.4 ผู้เช่าจะไม่ตกแต่ง ดัดแปลง ต่อเติม ภายในและภายนอกอาคารสถานที่เช่าดังกล่าวโดยปราศจากการอนุมัติจากผู้ให้เช่าก่อนเท่านั้นหากผู้\nเช่าไม่ปฏิบัติดังกล่าว ทั้งนี้ผู้เช่าจะต้องรับผิดชดใช้ค่าใช้จ่ายที่เกิดขึ้นทั้งหมด ',
                              textAlign: pw.TextAlign.justify,
                              style: pw.TextStyle(
                                fontSize: font_Size,
                                font: ttf,
                                color: Colors_pd,
                              ),
                            ),
                            pw.SizedBox(height: 1 * PdfPageFormat.mm),
                            pw.Text(
                              '11.5 ผู้เช่าต้องรับผิดชอบและชดใช้ค่าใช้จ่ายทั้งปวงอันเกี่ยวกับอุบัติเหตุ หรือความเสียหายใด ๆ ต่อบุคคล ทรัพย์สินซึ่งเกิดในหรือจากสถานที่\nเช่าหรือการดำเนินงานในสถานที่เช่าของผู้เช่า นับตั้งแต่วันที่ผู้เช่าเข้าครอบครองพื้นที่',
                              textAlign: pw.TextAlign.justify,
                              style: pw.TextStyle(
                                fontSize: font_Size,
                                font: ttf,
                                color: Colors_pd,
                              ),
                            ),
                            pw.SizedBox(height: 1 * PdfPageFormat.mm),
                            pw.Text(
                              '11.6 การติดตั้งป้ายชื่อร้าน  ป้ายโฆษณา ภาษีป้าย  หรือสิ่งใด ๆ  ก็ตามของผู้เช่าที่แสดงต่อสาธารณชน  อันเกิดจากการประกอบกิจการของผู้\nเช่าต้องได้รับความยินยอมจากผู้ให้เช่าเสียก่อนหากฝ่าฝืนผู้ให้เช่ามีสิทธิที่จะถอดถอนป้ายที่มิได้รับอนุญาตนั้น ออกโดยมิต้องรับผิดชอบต่อความ\nเสียหายและสูญหายใดๆที่เกิดขึ้นแก่ผู้เช่า',
                              textAlign: pw.TextAlign.justify,
                              style: pw.TextStyle(
                                fontSize: font_Size,
                                font: ttf,
                                color: Colors_pd,
                              ),
                            ),
                            pw.SizedBox(height: 1 * PdfPageFormat.mm),
                            pw.Text(
                              '11.7 ผู้ให้เช่าหรือตัวแทนมีสิทธิเข้าไป  และตรวจตราในสถานที่เช่าได้ตลอดผู้เช่าลูกจ้างและบริวารของผู้เช่า  จะต้องอำนวยความะดวกให้แก่ผู้\nให้เช่าหรือตัวแทนเสมอ',
                              textAlign: pw.TextAlign.justify,
                              style: pw.TextStyle(
                                fontSize: font_Size,
                                font: ttf,
                                color: Colors_pd,
                              ),
                            ),
                            // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                            // pw.Text(
                            //   '11.8 ผู้เช่าจะต้องเป็นผู้ชำระค่าไฟฟ้า และค่าน้ำประปาที่ใช้ในสถานที่เช่าตลอดอายุสัญญานี้',
                            //   textAlign: pw.TextAlign.justify,
                            //   style: pw.TextStyle(
                            //     fontSize: font_Size,
                            //     font: ttf,
                            //     color: Colors_pd,
                            //   ),
                            // ),
                            // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                            // pw.Row(children: [
                            //   pw.Text(
                            //     ' ' * 5 +
                            //         'กรณีผู้เช่าชำระค่าไฟฟ้าและค่าน้ำประปาแก่ผู้ให้เช่า ผู้เช่าจะต้องชำระในอัตราที่ผู้ให้เช่ากำหนด ค่าไฟฟ้าหน่วยละ',
                            //     textAlign: pw.TextAlign.justify,
                            //     style: pw.TextStyle(
                            //       fontSize: font_Size,
                            //       font: ttf,
                            //       color: Colors_pd,
                            //     ),
                            //   ),
                            //   pw.Expanded(
                            //     flex: 1,
                            //     child: pw.Container(
                            //       // width: 100,
                            //       // height: 13,
                            //       decoration: pw.BoxDecoration(
                            //           border: pw.Border(
                            //               bottom: pw.BorderSide(
                            //         color: Colors_pd,
                            //         width: 0.3, // Underline thickness
                            //       ))),
                            //       child: pw.Text(
                            //         (quotxSelectModels
                            //                     .where((e) =>
                            //                         e.expser.toString() == '6')
                            //                     .length ==
                            //                 0)
                            //             ? '0.00 บาท'
                            //             : " ${quotxSelectModels.where((model) => model.expser == '6').map((model) => model.qty).join(', ')} บาท",
                            //         textAlign: pw.TextAlign.center,
                            //         style: pw.TextStyle(
                            //           color: Colors_pd,
                            //           fontSize: font_Size,
                            //           fontWeight: pw.FontWeight.bold,
                            //           font: ttf,
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ]),
                            // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                            // pw.Row(children: [
                            //   pw.Text(
                            //     'ค่าประปาหน่วยละ',
                            //     textAlign: pw.TextAlign.justify,
                            //     style: pw.TextStyle(
                            //       fontSize: font_Size,
                            //       font: ttf,
                            //       color: Colors_pd,
                            //     ),
                            //   ),
                            //   pw.Container(
                            //     width: 50,
                            //     // height: 13,
                            //     decoration: pw.BoxDecoration(
                            //         border: pw.Border(
                            //             bottom: pw.BorderSide(
                            //       color: Colors_pd,
                            //       width: 0.3, // Underline thickness
                            //     ))),
                            //     child: pw.Text(
                            //       (quotxSelectModels
                            //                   .where((e) =>
                            //                       e.expser.toString() == '7')
                            //                   .length ==
                            //               0)
                            //           ? '0.00 บาท'
                            //           : " ${quotxSelectModels.where((model) => model.expser == '7').map((model) => model.qty).join(', ')} บาท",
                            //       textAlign: pw.TextAlign.center,
                            //       style: pw.TextStyle(
                            //         color: Colors_pd,
                            //         fontSize: font_Size,
                            //         fontWeight: pw.FontWeight.bold,
                            //         font: ttf,
                            //       ),
                            //     ),
                            //   ),
                            //   pw.Text(
                            //     'พร้อมภาษีมูลค่าเพิ่มตามรายการใบแจ้งหนี้ของผู้ให้เช่าทุกเดือนโดยชำระเงินผ่านช่องทางที่ผู้ให้เช่าช่วงกำหนด',
                            //     textAlign: pw.TextAlign.justify,
                            //     style: pw.TextStyle(
                            //       fontSize: font_Size,
                            //       font: ttf,
                            //       color: Colors_pd,
                            //     ),
                            //   ),
                            // ]),
                            // pw.SizedBox(height: 1 * PdfPageFormat.mm),

                            // pw.Text(
                            //   'กรณีที่ผู้เช่าช่วงชำระค่าไฟฟ้าและค่าประปาแก่การไฟฟ้าและการประปาส่วนภูมิภาคและผู้เช่าช่วงต้องทำการส่งสำเนารายการใบแจ้งหนี้ค่าไฟฟ้า\nและค่าประปา พร้อมหลักฐานการชำระเงินมาให้แก่ผู้ให้เช่าช่วงทุกเดือน',
                            //   textAlign: pw.TextAlign.left,
                            //   style: pw.TextStyle(
                            //     fontSize: font_Size,
                            //     font: ttf,
                            //     color: Colors_pd,
                            //   ),
                            // ),

                            pw.SizedBox(height: 1 * PdfPageFormat.mm),
                            pw.Text(
                              '11.8  ผู้เช่าจะต้องไม่ประกอบกิจการในลักษณะเดียวกัน  หรือคล้ายคลึงกันกับกิจการของผู้ให้เช่าในการประกอบการค้า  ประเภทมินิมาร์ท,คอน\nวีเนี่ยนสโตร์   หรือซุปเปอร์มาร์เก็ต   รวมตลอดทั้งกิจการที่ผู้ให้เช่าเห็นว่ามีลักษณะในทำนองเดียวกัน กับธุรกิจการค้าของผู้ให้เช่าเป็นอันขาด',
                              textAlign: pw.TextAlign.justify,
                              style: pw.TextStyle(
                                fontSize: font_Size,
                                font: ttf,
                                color: Colors_pd,
                              ),
                            ),
                          ],
                        ),
                      ),

                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        'ข้อ 12. กรณีบอกเลิกหรือสิ้นสุดสัญญา ',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Container(
                          padding: pw.EdgeInsets.fromLTRB(35, 0, 0, 0),
                          child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.Text(
                                  '12.1 หากการประกอบธุรกิจการค้าของผู้เช่าไม่เป็นไปตามเป้าหมาย   และผู้เช่าต้องการบอกเลิกสัญญาเช่าก่อนครบกำหนด ตามสัญญาจะต้อง\nบอกกล่าวแก่ผู้ให้เช่าไม่น้อยกว่า   90  วัน   โดยผู้ให้เช่ามีสิทธิเรียกค่าเสียหาย อันเกิดแต่การบอกเลิกสัญญาดังกล่าว และริบเงินประกันการเช่า\nทั้งหมด',
                                  textAlign: pw.TextAlign.left,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    color: Colors_pd,
                                  ),
                                ),
                                pw.SizedBox(height: 1 * PdfPageFormat.mm),
                                pw.Text(
                                  '12.2 หากผู้เช่าผิดสัญญาเช่าข้อหนึ่งข้อใด  หรือถูกยึดทรัพย์บังคับคดี  หรือถูกฟ้องให้เป็นบุคคลล้มละลาย  ผู้ให้เช่า มีสิทธิเลิกสัญญาเช่าได้ทันที\nโดยไม่ต้องบอกกล่าวก่อนล่วงหน้า',
                                  textAlign: pw.TextAlign.left,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    color: Colors_pd,
                                  ),
                                ),
                                pw.SizedBox(height: 1 * PdfPageFormat.mm),
                              ])),
                      pw.Container(
                          padding: pw.EdgeInsets.fromLTRB(35, 0, 0, 0),
                          child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                // pw.Text(
                                //   '10.1 หากการประกอบธุรกิจการค้าของผู้เช่าไม่เป็นไปตามเป้าหมาย   และผู้เช่าต้องการบอกเลิกสัญญาเช่าก่อนครบกำหนด ตามสัญญาจะต้อง\nบอกกล่าวแก่ผู้ให้เช่าไม่น้อยกว่า   90  วัน   โดยผู้ให้เช่ามีสิทธิเรียกค่าเสียหาย อันเกิดแต่การบอกเลิกสัญญาดังกล่าว และริบเงินประกันการเช่า\nทั้งหมด',
                                //   textAlign: pw.TextAlign.left,
                                //   style: pw.TextStyle(
                                //     fontSize: font_Size,
                                //     font: ttf,
                                //     color: Colors_pd,
                                //   ),
                                // ),
                                // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                                // pw.Text(
                                //   '10.2 หากผู้เช่าผิดสัญญาเช่าข้อหนึ่งข้อใด  หรือถูกยึดทรัพย์บังคับคดี  หรือถูกฟ้องให้เป็นบุคคลล้มละลาย  ผู้ให้เช่า มีสิทธิเลิกสัญญาเช่าได้ทันที\nโดยไม่ต้องบอกกล่าวก่อนล่วงหน้า',
                                //   textAlign: pw.TextAlign.left,
                                //   style: pw.TextStyle(
                                //     fontSize: font_Size,
                                //     font: ttf,
                                //     color: Colors_pd,
                                //   ),
                                // ),
                                // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                                pw.Text(
                                  '12.3 ห้ามมิให้ผู้เช่านำทรัพย์สินที่เช่าหรือแบ่งสถานที่เช่าให้บุคคลอื่นเช่าช่วงต่อรวมทั้งเปลี่ยนแปลงประเภทกิจการค้าต่างจากเดิมโดยปราศจาก\nการอนุมัติจากผู้ให้เช่าก่อน ผู้ให้เช่ามีสิทธิบอกเลิกสัญญาได้ทันที',
                                  textAlign: pw.TextAlign.left,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    color: Colors_pd,
                                  ),
                                ),
                                pw.SizedBox(height: 1 * PdfPageFormat.mm),
                                pw.Text(
                                  '12.4 ผู้เช่าจะไม่ใช้พื้นที่เกินกว่าที่ระบุไว้ในสัญญาเช่านี้  หากฝ่าฝืนและผู้ให้เช่าตรวจพบว่าใช้พื้นที่เกินจากสัญญา  ผู้ให้เช่ามีสิทธิบอกเลิกสัญญา\nหรือปรับได้',
                                  textAlign: pw.TextAlign.left,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    color: Colors_pd,
                                  ),
                                ),
                                pw.SizedBox(height: 1 * PdfPageFormat.mm),
                                pw.Text(
                                  '12.5 หากผู้เช่าไม่เริ่มประกอบกิจการค้าในสถานที่เช่าภายในกำหนดเวลาวันเริ่มสัญญาเช่านี้ให้ถือว่าผู้เช่าผิดสัญญาและผู้ให้เช่ามีสิทธิบอกเลิก\nสัญญา และยึดเงินประกันการเช่านี้ได้',
                                  textAlign: pw.TextAlign.left,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    color: Colors_pd,
                                  ),
                                ),
                              ])),
                      pw.Container(
                          padding: pw.EdgeInsets.fromLTRB(35, 0, 0, 0),
                          child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.SizedBox(height: 1 * PdfPageFormat.mm),
                                pw.Text(
                                  '12.6 เมื่อสัญญาเช่านี้สิ้นสุดลงไม่ว่าจะเนื่องจากสาเหตุประการใดก็ตามรวมทั้งเนื่องจากการครบอายุของสัญญาเช่าถ้าผู้ให้เช่าประสงค์ให้ผู้เช่ารื้อ\nถอนบรรดาสิ่งแก้ไขเปลี่ยนแปลงเพิ่มเติมออกไปผู้เช่าจะต้องรื้อถอนปรับปรุงพื้นที่เพื่อส่งมอบพื้นที่เช่าและอุปกรณ์ทั้งหมดให้คืนสู่สภาพเดิมด้วย\nค่าใช้จ่ายของผู้เช่าเองหากผู้เช่าไม่รื้อถอนปรับปรุงผู้ให้เช่ามีสิทธิเข้าไปรื้อถอนปรับปรุงสถานที่เช่าได้เองโดยผู้เช่าเป็นผู้รับผิดชอบค่าใช้จ่ายให้แก่\nผู้ให้เช่า',
                                  textAlign: pw.TextAlign.left,
                                  maxLines: 5,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    color: Colors_pd,
                                  ),
                                ),
                                pw.SizedBox(height: 1 * PdfPageFormat.mm),
                                pw.Text(
                                  '12.7 ผู้เช่าต้องขนย้ายทรัพย์สินและบริวารออกไปจากสถานที่เช่าให้เสร็จเรียบร้อยภายใน 15 วันนับแต่วันที่สัญญาเช่าสิ้นสุดลงกรณีที่ผู้เช่าต้อง\nรื้อถอนปรับปรุงพื้นที่สถานที่เช่าให้กลับคืนสู่สภาพเดิมผู้เช่าต้องดำเนินการให้แล้วเสร็จภายใน 30 วัน นับแต่วันที่สัญญาเช่าสิ้นสุดลงและหากพ้น\nกำหนดระยะเวลาตามที่กล่าวมาข้างต้น แล้วผู้เช่ายังไม่ขนย้ายทรัพย์สิน บริวาร และ/หรือ รื้อถอนปรับปรุงพื้นที่ สถานที่เช่าให้กลับคืนสู่สภาพ',
                                  textAlign: pw.TextAlign.left,
                                  maxLines: 4,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    color: Colors_pd,
                                  ),
                                ),
                                pw.SizedBox(height: 1 * PdfPageFormat.mm),
                                pw.Row(
                                  children: [
                                    pw.Text(
                                      'เดิมให้แล้วเสร็จตามสัญญาผู้เช่าตกลงชำระค่าปรับในอัตราวันละ',
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
                                          // height: 13,
                                          decoration: pw.BoxDecoration(
                                              border: pw.Border(
                                                  bottom: pw.BorderSide(
                                            color: Colors_pd,
                                            width: 0.3, // Underline thickness
                                          ))),
                                          child: pw.Text(
                                            // (quotxSelectModels.length == 0)
                                            //     ? '0.00 (~${convertToThaiBaht(0.00)}~)'
                                            //     : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '17').map((e) => e.amt != null ? double.parse(e.amt.toString()) : 0.00).reduce((a, b) => a + b))} บาท ',
                                            " 1,000.00 บาท ( หนึ่งพันบาทถ้วน ) ",
                                            textAlign: pw.TextAlign.center,
                                            style: pw.TextStyle(
                                              color: Colors_pd,
                                              fontSize: font_Size,
                                              fontWeight: pw.FontWeight.bold,
                                              font: ttf,
                                            ),
                                          ),
                                        )),
                                    // pw.Text(
                                    //   'โดยหากผู้เช่ายังคงปล่อยทิ้งทรัพย์สินไว้ในพื้นที่เช่าให้ทรัพย์สินนั้นตกเป็น',
                                    //   textAlign: pw.TextAlign.left,
                                    //   style: pw.TextStyle(
                                    //     fontSize: font_Size,
                                    //     font: ttf,
                                    //     color: Colors_pd,
                                    //   ),
                                    // ),
                                  ],
                                ),
                                pw.SizedBox(height: 1 * PdfPageFormat.mm),
                                pw.Text(
                                  'โดยหากผู้เช่ายังคงปล่อยทิ้งทรัพย์สินไว้ในพื้นที่เช่าให้ทรัพย์สินนั้นตกเป็นกรรมสิทธิ์ของผู้ให้เช่าทันที โดยให้ผู้ให้เช่า มีสิทธิ จำหน่าย จ่าย โอน\nหรือจัดการทรัพย์สินยึดเงินประกันตลอดจนเรียกร้องค่าใช้จ่ายอันเกิดแต่การจัดการทรัพย์สินของผู้เช่าและ/หรือรื้อถอนปรับปรุงพื้นที่สถานที่เช่าให้กลับคืนสู่สภาพเดิมจากผู้เช่าโดยผู้เช่าไม่มีสิทธิเรียกร้องทรัพย์สิน หรือเรียกร้องค่าเสียหายใด ๆ ทั้งสิ้นจากผู้ให้เช่า',
                                  textAlign: pw.TextAlign.left,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    color: Colors_pd,
                                  ),
                                ),
                                pw.SizedBox(height: 1 * PdfPageFormat.mm),
                                pw.Text(
                                  '12.8 หากผู้ให้เช่าช่วงมีความจำเป็นต้องใช้ประโยชน์ในสถานที่เช่าช่วงผู้ให้เช่าช่วงสามารถใช้สิทธิบอกเลิกสัญญาเช่าก่อนครบกำหนดสัญญานี้ได้\nโดยจะแจ้งให้ผู้เช่าทราบล่วงหน้าไม่น้อยกว่า 1 เดือน',
                                  textAlign: pw.TextAlign.left,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    color: Colors_pd,
                                  ),
                                ),
                              ])),

                      // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      // pw.Text(
                      //   'ข้อ 13. การแจ้งการประมวลผลข้อมูลส่วนบุคคล   ',
                      //   textAlign: pw.TextAlign.left,
                      //   style: pw.TextStyle(
                      //     fontSize: font_Size,
                      //     font: ttf,
                      //     color: Colors_pd,
                      //   ),
                      // ),
                      // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      // pw.Container(
                      //     padding: pw.EdgeInsets.fromLTRB(35, 0, 0, 0),
                      //     child: pw.Column(
                      //         crossAxisAlignment: pw.CrossAxisAlignment.start,
                      //         mainAxisAlignment: pw.MainAxisAlignment.start,
                      //         children: [
                      //           // pw.Text(
                      //           //   '12.1 การเก็บ และใช้ข้อมูลส่วนบุคคล',
                      //           //   textAlign: pw.TextAlign.left,
                      //           //   style: pw.TextStyle(
                      //           //     fontSize: font_Size,
                      //           //     font: ttf,
                      //           //     color: Colors_pd,
                      //           //   ),
                      //           // ),
                      //           // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      //           pw.Text(
                      //             '13.1 การเก็บ และใช้ข้อมูลส่วนบุคคล ผู้ให้เช่าได้เก็บรวบรวมและหรือใช้ข้อมูลส่วนบุคคลของผู้เช่าได้แก่ สำเนาบัตรประจำตัวประชาชน,สำเนา\nทะเบียนบ้าน,สำเนาบัญชีธนาคารเอกสารสำคัญใดๆที่มีข้อมูลส่วนบุคคล (“ข้อมูลส่วนบุคคล”) เป็นระยะเวลาทั้งหมด 10 ปี (สิบปี) นับจากวันที่\nสัญญาฉบับนี้สิ้นสุดลงโดยมีวัตถุประสงค์เพื่อตรวจสอบความเป็นตัวตนของผู้เช่าเป็นหลักฐานในการก่อตั้งสิทธิเรียกร้องและเพื่อใช้ตามวัตถุประ\nสงค์ตามสัญญาฉบับนี้เรียกร้องและเพื่อใช้ตามวัตถุประสงค์ตามสัญญาฉบับนี้เท่านั้นโดยไม่นำข้อมูลส่วนบุคคลดังกล่าวไปใช้เพื่อวัตถุประสงค์อื่น\nใดนอกจากสัญญาฉบับนี้แต่อย่างใด',
                      //             textAlign: pw.TextAlign.left,
                      //             style: pw.TextStyle(
                      //               fontSize: font_Size,
                      //               font: ttf,
                      //               color: Colors_pd,
                      //             ),
                      //           ),
                      //         ])),
                      // pw.Container(
                      //     padding: pw.EdgeInsets.fromLTRB(35, 0, 0, 0),
                      //     child: pw.Column(
                      //         crossAxisAlignment: pw.CrossAxisAlignment.start,
                      //         mainAxisAlignment: pw.MainAxisAlignment.start,
                      //         children: [
                      //           pw.Text(
                      //             'ทั้งนี้ หากผู้เช่าไม่ส่งมอบข้อมูลส่วนบุคคลดังกล่าวแก่ผู้ให้เช่า จะทำให้การจัดทำสัญญาฉบับนี้ไม่สมบูรณ์อันเป็นฐานการประมวลผลเพื่อเป็น\nการจำเป็นเพื่อการปฏิบัติตามสัญญาและเป็นการจำเป็นเพื่อประโยชน์โดยชอบด้วยกฎหมาย ตามมาตรา24(3),(5)ของพระราชบัญญัติคุ้มครอง\nข้อมูลส่วนบุคคล พ.ศ. 2562',
                      //             textAlign: pw.TextAlign.left,
                      //             style: pw.TextStyle(
                      //               fontSize: font_Size,
                      //               font: ttf,
                      //               color: Colors_pd,
                      //             ),
                      //           ),
                      //           pw.Text(
                      //             'ทั้งนี้ผู้เช่าในฐานะเจ้าของข้อมูลส่วนบุคคลรับทราบว่าตนเองมีสิทธิดังนี้ (1) สิทธิในการเข้าถึงและรับสำเนาข้อมูลส่วนบุคคลที่ผู้ให้เช่าได้ทำการ\nเก็บรวบรวมและหรือใช้ได้ตลอดจนสิทธิในการคัดค้านการประมวลผลข้อมูลส่วนบุคคล (2) เมื่อพ้นระยะเวลาทั้งหมด 10 ปี (สิบปี) นับจากวัน\nที่สัญญาฉบับนี้สิ้นสุดลงผู้ให้เช่าจะทำการลบหรือทำลายข้อมูลส่วนบุคคล (3)สิทธิในการขอให้ผู้ให้เช่าระงับการใช้ข้อมูลส่วนบุคคล หากผู้ให้เช่า\nได้ใช้ข้อมูลส่วนบุคคลไม่เป็นไป ตามวัตถุประสงค์ตามวรรคแรกข้างต้น (4) สิทธิในการขอแก้ไขข้อมูลส่วนบุคคลให้ถูกต้องเป็นปัจจุบันสมบูรณ์\nและไม่ก่อให้เกิดความเข้าใจผิด(5) สิทธิในการร้องเรียนผู้ให้เช่า การใช้สิทธิข้างต้นจะต้องจัดทำเป็นลายลักษณ์อักษรและแจ้งต่อผู้ให้เช่าภายใน\nระยะเวลาอันสมควร และไม่เกินระยะเวลาที่กฎหมายกำหนดโดยผู้ให้เช่าจะปฏิบัติตามข้อกำหนดทางกฎหมายที่เกี่ยวข้องกับสิทธิของเจ้าของ\nข้อมูลส่วนบุคคลและผู้ให้เช่าขอสงวนสิทธิ์ในการคิดค่าบริการใดๆที่เกี่ยวข้องและจำเป็นต่อการใช้สิทธิดังกล่าว',
                      //             textAlign: pw.TextAlign.left,
                      //             style: pw.TextStyle(
                      //               fontSize: font_Size,
                      //               font: ttf,
                      //               color: Colors_pd,
                      //             ),
                      //           ),
                      //         ])),

                      // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      // pw.Container(
                      //     padding: pw.EdgeInsets.fromLTRB(35, 0, 0, 0),
                      //     child: pw.Column(
                      //         crossAxisAlignment: pw.CrossAxisAlignment.start,
                      //         mainAxisAlignment: pw.MainAxisAlignment.start,
                      //         children: [
                      //           pw.Text(
                      //             '13.2 การเปิดเผยข้อมูลส่วนบุคคล',
                      //             textAlign: pw.TextAlign.left,
                      //             style: pw.TextStyle(
                      //               fontSize: font_Size,
                      //               font: ttf,
                      //               color: Colors_pd,
                      //             ),
                      //           ),
                      //           pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      //           pw.Text(
                      //             'เพื่อประโยชน์ของผู้เช่าตามวัตถุประสงค์ในสัญญาเช่า ผู้ให้บริการอาจเปิดเผยข้อมูลของผู้เช่าให้กับหน่วยงานอื่นของผู้ให้เช่ารวมถึงบริษัทในเครือ\nและบริษัทย่อยเพื่อวัตถุประสงค์ในการปฏิบัติตามภาระผูกพันตามสัญญาประโยชน์ที่ชอบด้วยกฎหมายการปฏิบัติตามกฎหมายและวัตถุประสงค์\nอื่นๆภายใต้กฎหมายไทยผู้เช่ารับทราบว่าหากมีเหตุร้องเรียนเกี่ยวกับข้อมูลส่วนบุคคลสามารถติดต่อประสานงานมายังเจ้าหน้าที่คุ้มครองข้อมูลส่วนบุคคลได้ในช่องทางดังนี้',
                      //             textAlign: pw.TextAlign.left,
                      //             style: pw.TextStyle(
                      //               fontSize: font_Size,
                      //               font: ttf,
                      //               color: Colors_pd,
                      //             ),
                      //           ),
                      //         ])),

                      // pw.SizedBox(height: 5 * PdfPageFormat.mm),
                      // pw.Text(
                      //   ' ' * 12 +
                      //       'เจ้าหน้าที่คุ้มครองข้อมูลส่วนบุคคล (Data Protection Officer: DPO) / ผู้ควบคุมข้อมูลส่วนบุคคล (Data Controller)',
                      //   textAlign: pw.TextAlign.left,
                      //   style: pw.TextStyle(
                      //     fontSize: font_Size,
                      //     font: ttf,
                      //     color: Colors_pd,
                      //   ),
                      // ),
                      // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      // pw.Text(
                      //   ' ' * 12 + 'บริษัท ชอยส์ มินิสโตร์ จำกัด ',
                      //   textAlign: pw.TextAlign.left,
                      //   style: pw.TextStyle(
                      //     fontSize: font_Size,
                      //     font: ttf,
                      //     color: Colors_pd,
                      //   ),
                      // ),
                      // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      // pw.Text(
                      //   ' ' * 12 +
                      //       'เลขที่ 7/11 หมู่ที่ 5 ตำบลท่าศาลา อำเภอเมืองเชียงใหม่ จังหวัดเชียงใหม่ 50000',
                      //   textAlign: pw.TextAlign.left,
                      //   style: pw.TextStyle(
                      //     fontSize: font_Size,
                      //     font: ttf,
                      //     color: Colors_pd,
                      //   ),
                      // ),
                      // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      // pw.Text(
                      //   ' ' * 12 + 'Email Address : privacy@choice.co.th',
                      //   textAlign: pw.TextAlign.left,
                      //   style: pw.TextStyle(
                      //     fontSize: font_Size,
                      //     font: ttf,
                      //     color: Colors_pd,
                      //   ),
                      // ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        'ข้อ 13. การบอกกล่าว',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 12 +
                            'การบอกกล่าวตามสัญญานี้ หากฝ่ายหนึ่งฝ่ายใดได้ทำเป็นหนังสือและจัดส่งทางไปรษณีย์ลงทะเบียนไปยังคู่สัญญาอีกฝ่ายหนึ่ง ตามที่อยู่ที่ระบุไว้\nข้างต้นในสัญญานี้ให้ถือว่าเป็นการบอกกล่าวที่ชอบด้วยกฎหมาย และคู่สัญญาอีกฝ่ายหนึ่งได้รับทราบแล้ว',
                        textAlign: pw.TextAlign.left,
                        maxLines: 2,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 5 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 12 +
                            'สัญญานี้ทำขึ้นเป็น 2 ฉบับ มีข้อความถูกต้องตรงกันทุกประการ ทั้งสองฝ่ายต่างได้อ่านและเข้าใจข้อความทั้งหมดในสัญญาดีโดยตลอดเห็นว่าถูก\nต้องตามเจตนาและความประสงค์ทุกประการแล้ว จึงได้ลงลายมือชื่อไว้เป็นหลักฐานต่อหน้าพยานและต่างเก็บรักษาไว้ฝ่ายละ 1 ฉบับ',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      // pw.SizedBox(height: 5 * PdfPageFormat.mm),
                      // pw.Text(
                      //   ' ' * 12 +
                      //       'ต้องตามเจตนาและความประสงค์ทุกประการแล้ว จึงได้ลงลายมือชื่อไว้เป็นหลักฐานต่อหน้าพยานและต่างเก็บรักษาไว้ฝ่ายละ 1 ฉบับ',
                      //   textAlign: pw.TextAlign.left,
                      //   style: pw.TextStyle(
                      //     fontSize: font_Size,
                      //     font: ttf,
                      //     color: Colors_pd,
                      //   ),
                      // ),
                      pw.SizedBox(height: 5 * PdfPageFormat.mm),
                      pw.Row(children: [
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
                                      // pw.Expanded(
                                      //   flex: 2,
                                      //   child:
                                      //       // pw.Container(
                                      //       //   // width: 120,
                                      //       //   decoration:
                                      //       //       const pw.BoxDecoration(
                                      //       //     // color: PdfColors.green100,
                                      //       //     border: pw.Border(
                                      //       //       bottom: pw.BorderSide(
                                      //       //           width: 0.5,
                                      //       //           color:
                                      //       //               PdfColors.grey600),
                                      //       //     ),
                                      //       //   ),
                                      //       //   padding:
                                      //       //       const pw.EdgeInsets.all(
                                      //       //           8.0),
                                      //       //   height: 30,
                                      //       // )
                                      //       (imageBytes_manager.isEmpty)
                                      //           ? pw.Container(
                                      //               // width: 120,
                                      //               decoration:
                                      //                   const pw.BoxDecoration(
                                      //                 // color: PdfColors.green100,
                                      //                 border: pw.Border(
                                      //                   bottom: pw.BorderSide(
                                      //                       width: 0.5,
                                      //                       color: PdfColors
                                      //                           .grey600),
                                      //                 ),
                                      //               ),
                                      //               padding:
                                      //                   const pw.EdgeInsets.all(
                                      //                       8.0),
                                      //               height: 30,
                                      //             )
                                      //           : pw.Container(
                                      //               // width: 120,
                                      //               decoration:
                                      //                   const pw.BoxDecoration(
                                      //                 // color: PdfColors.green100,
                                      //                 border: pw.Border(
                                      //                   bottom: pw.BorderSide(
                                      //                       width: 0.5,
                                      //                       color: PdfColors
                                      //                           .grey600),
                                      //                 ),
                                      //               ),
                                      //               padding:
                                      //                   const pw.EdgeInsets.all(
                                      //                       8.0),
                                      //               child: pw.Center(
                                      //                 child: pw.Image(
                                      //                   pw.MemoryImage(
                                      //                       imageBytes_manager),
                                      //                   height: 20,
                                      //                   width: 100,
                                      //                 ),
                                      //               ),
                                      //             ),
                                      // ),
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
                      ]),
                    ])),
          ];
        },
        footer: (context) {
          return pw.Column(
            children: [
              pw.Container(
                  width: PdfPageFormat.a4.width,
                  padding: pw.EdgeInsets.fromLTRB(40, 0, 40, 0),
                  child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        // pw.Text(
                        //   (context.pageNumber.toString() == '1')
                        //       ? "${context.pageNumber} / ${context.pagesCount}...อนึ่ง การชำระค่าเช่ารายเดือน..."
                        //       : (context.pageNumber.toString() == '2')
                        //           ? "${context.pageNumber} / ${context.pagesCount}...ข้อ 8. การต่ออายุสัญญา..."
                        //           : (context.pageNumber.toString() == '3')
                        //               ? "${context.pageNumber} / ${context.pagesCount}... ข้อ 10. กรณีบอกเลิกหรือสิ้นสุดสัญญา....."
                        //               : (context.pageNumber.toString() == '4')
                        //                   ? "${context.pageNumber} / ${context.pagesCount}...ข้อ 12. การแจ้งการประมวลผลข้อมูลส่วนบุคคล ....."
                        //                   : "${context.pageNumber} / ${context.pagesCount}",
                        //   textAlign: pw.TextAlign.center,
                        //   style: pw.TextStyle(
                        //     fontWeight: pw.FontWeight.bold,
                        //     color: Colors_pd,
                        //     fontSize: font_Size - 2,
                        //     font: ttf,
                        //   ),
                        // ),
                        pw.Stack(
                          children: [
                            // กลางหน้ากระดาษ
                            pw.Container(
                              width: double.infinity,
                              child: pw.Align(
                                alignment: pw.Alignment.center,
                                child: pw.Text(
                                  "${context.pageNumber} / ${context.pagesCount}",
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: Colors_pd,
                                    fontSize: font_Size - 2,
                                    font: ttf,
                                  ),
                                ),
                              ),
                            ),
                            // ชิดขวา
                            pw.Container(
                              width: double.infinity,
                              child: pw.Align(
                                alignment: pw.Alignment.centerRight,
                                child: pw.Text(
                                  _getPageSuffix(context.pageNumber),
                                  textAlign: pw.TextAlign.right,
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: Colors_pd,
                                    fontSize: font_Size - 2,
                                    font: ttf,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ])),
              pw.Stack(
                children: [
                  pw.Container(
                      width: PdfPageFormat.a4.width,
                      height: 55,
                      child: pw.Center(
                        child: pw.Container(
                            width: widths,
                            height: 25,
                            child: pw.Column(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                mainAxisSize: pw.MainAxisSize.min,
                                children: [
                                  pw.Row(children: [
                                    pw.Expanded(
                                        child: pw.Container(
                                      color: PdfColors.red,
                                      height: 5,
                                    ))
                                  ]),
                                  pw.Row(children: [
                                    pw.Expanded(
                                        child: pw.Container(
                                      color: PdfColors.green900,
                                      height: 8,
                                    ))
                                  ]),
                                  pw.Row(children: [
                                    pw.Expanded(
                                        child: pw.Container(
                                      color: PdfColors.red,
                                      height: 5,
                                    ))
                                  ]),
                                ])),
                      )),
                  pw.Positioned(
                      top: 4,
                      right: 50,
                      child: pw.Container(
                          width: 50.0,
                          height: 50.0,
                          child: pw.Image(pw.MemoryImage(imageData)))),
                  pw.Positioned(
                    top: 4,
                    left: 40,
                    child: pw.Text(
                      "CHOICE MINI STORE CO., LTD. 7/11 VILLAGE NO.5, THA SALA SUB-DISTRICT, MUEANG CHIANG MAI DISTRICT, CHIANG MAI PROVINANCE 50000",
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        color: Colors_pd,
                        fontSize: font_Size - 4,
                        fontWeight: pw.FontWeight.bold,
                        font: ttf,
                      ),
                    ),
                  ),
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
            ///
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

// -------------------------------> (คำท้ายเอกสารหน้าถัดไป)
String _getPageSuffix(int page) {
  switch (page) {
    case 1:
      return '...โดยเงินจำนวนดังกล่าวเป็นเงิน...';
    case 2:
      return '...ข้อ 8. ค่าบริการพื้นที่ส่วนกลาง...';
    case 3:
      return '...11.1 ผู้เช่าจะต้องดูแลรักษา....';
    case 4:
      return '...12.6 เมื่อสัญญาเช่านี้สิ้นสุด....';
    // case 5:
    //   return '...บริษัท ชอยส์ มินิสโตร์ จํากัด....';
    default:
      return '';
  }
}
