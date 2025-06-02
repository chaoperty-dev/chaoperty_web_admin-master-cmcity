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
import '../../Style/loadAndCacheImage.dart';

class Pdfgen_Agreement_Choice3 {
//////////---------------------------------------------------->( **** เอกสารสัญญาบริการ Choice)

  static void exportPDF_Agreement_Choice3(
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
      Form_PakanAll_Total_bill,
      Form_wnote,
      FormPeriod_choice) async {
    ////
    //// ------------>(J Space Sansai)
    ///////
    final pdf = pw.Document();
    // final fontData = await rootBundle.load("ThaiFonts/Sarabun-Medium.ttf"r;
    // var dataint = fontData.buffer
    //     .asUint8List(fontData.offsetInBytes, fontData.lengthInBytes);r
    // final PdfFont font = PdfFont.of(pdf, data: dataint);
    final font = await rootBundle.load("fonts/THSarabunNew.ttf");
    final font2 = await rootBundle.load("fonts/THSarabunNew.ttf");
    var Colors_pd = PdfColors.black;
    var Colors_pd2 = PdfColors.grey800;
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

    Uint8List imageData = (image).buffer.asUint8List();
    Uint8List imageBG = (BG_PDF).buffer.asUint8List();

    // List netImage = [];
    // List signature_Image1 = [];
    // List signature_Image2 = [];
    // List signature_Image3 = [];
    // List signature_Image4 = [];
    List footImage = [];
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int pageCount = 1; // Initialize the page count
    String? Name1_choice = preferences.getString('Name1_choice');
    // String? Name2_choice = preferences.getString('Name2_choice');
    String? Name3_choice = preferences.getString('Name3_choice');
    String? Name4_choice = preferences.getString('Name4_choice');
    String? base64Image_1 = preferences.getString('base64Image1');
    // String? base64Image_2 = preferences.getString('base64Image2');
    // String? base64Image_3 = preferences.getString('base64Image3');
    // String? base64Image_4 = preferences.getString('base64Image4');
    String base64Image_new1 = (base64Image_1 == null) ? '' : base64Image_1;
    Uint8List? resizedLogo = await getResizedLogo();
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
    String Howday = (Form_rtname.toString() == 'รายวัน')
        ? 'วัน'
        : (Form_rtname.toString() == 'รายเดือน')
            ? 'เดือน'
            : (Form_rtname.toString() == 'รายปี')
                ? 'ปี'
                : '$Form_rtname';
    double widths = await MediaQuery.of(context).size.width;
    int pange = 1;
//////////---------------------------->
    bool hasNonCash_water_ele = (quotxSelectModels
                .where((e) =>
                    e.expser.toString() == '20' && e.expser.toString() == '21')
                .length ==
            0)
        ? true
        : quotxSelectModels.any((quotxSelectModels) {
            return quotxSelectModels.expser.toString() == '20' &&
                quotxSelectModels.expser.toString() == '21';
          }); ///// น้ำ-ไฟฟ้า
//////////---------------------------->
    bool hasNonCash_water =
        (quotxSelectModels.where((e) => e.expser.toString() == '21').length ==
                0)
            ? true
            : quotxSelectModels.any((quotxSelectModels) {
                return quotxSelectModels.expser.toString() == '21' &&
                    quotxSelectModels.expser.toString() != '20';
              }); ///// น้ำ
//////////---------------------------->
    bool hasNonCash_ele =
        (quotxSelectModels.where((e) => e.expser.toString() == '20').length ==
                0)
            ? true
            : quotxSelectModels.any((quotxSelectModels) {
                return quotxSelectModels.expser.toString() == '20' &&
                    quotxSelectModels.expser.toString() != '21';
              }); ///// ไฟฟ้า
//////////---------------------------->
    bool hasNonCash_No_water_ele = (quotxSelectModels
                .where((e) =>
                    e.expser.toString() != '21' && e.expser.toString() != '20')
                .length ==
            0)
        ? true
        : quotxSelectModels.any((quotxSelectModels) {
            return quotxSelectModels.expser.toString() != '20' &&
                quotxSelectModels.expser.toString() != '21';
          }); ///// ไม่ น้ำ-ไฟฟ้า

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
                  resizedLogo != null
                      ? pw.SizedBox(
                          child: pw.Center(
                          child: pw.Image(pw.MemoryImage(resizedLogo),
                              height: 60, width: 70, fit: pw.BoxFit.fill),
                        ))
                      : pw.Container(
                          height: 60,
                          width: 70,
                          decoration: pw.BoxDecoration(
                            color: PdfColors.white,
                            border: pw.Border.all(color: PdfColors.grey300),
                          ),
                          child: pw.Center(
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
                  // pw.Container(
                  //   height: 70,
                  //   width: 90,
                  //   decoration: (resizedLogo != null)
                  //       ? null
                  //       : pw.BoxDecoration(
                  //           color: PdfColors.grey200,
                  //           border: pw.Border.all(color: PdfColors.grey300),
                  //         ),
                  //   child: resizedLogo != null
                  //       ? pw.Image(
                  //           pw.MemoryImage(resizedLogo),
                  //           height: 70,
                  //           width: 90,
                  //         )
                  //       : pw.Center(
                  //           child: pw.Text(
                  //             '$bill_name ',
                  //             maxLines: 1,
                  //             style: pw.TextStyle(
                  //               fontSize: 10,
                  //               font: ttf,
                  //               color: Colors_pd,
                  //             ),
                  //           ),
                  //         ),
                  // ),
                  // pw.Container(
                  //   height: 60,
                  //   width: 60,
                  //   decoration: pw.BoxDecoration(
                  //     color: PdfColors.grey200,
                  //     border: pw.Border.all(color: PdfColors.grey300),
                  //   ),
                  //   child: resizedLogo != null
                  //       ? pw.Image(
                  //           pw.MemoryImage(resizedLogo),
                  //           height: 60,
                  //           width: 60,
                  //         )
                  //       : pw.Center(
                  //           child: pw.Text(
                  //             '$bill_name ',
                  //             maxLines: 1,
                  //             style: pw.TextStyle(
                  //               fontSize: 10,
                  //               font: ttf,
                  //               color: Colors_pd,
                  //             ),
                  //           ),
                  //         ),
                  // ),
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
              pw.SizedBox(height: 1 * PdfPageFormat.mm),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  (context.pageNumber.toString() == '1')
                      ? pw.Text(
                          'สัญญาบริการ',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            color: Colors_pd,
                            fontSize: font_Size,
                            fontWeight: pw.FontWeight.bold,
                            font: ttf,
                          ),
                        )
                      : pw.SizedBox(),
                ],
              ),
              pw.Container(
                width: PdfPageFormat.a4.width,
                padding: pw.EdgeInsets.fromLTRB(50, 0, 50, 0),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
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
              pw.SizedBox(height: 1 * PdfPageFormat.mm),
              pw.Container(
                width: PdfPageFormat.a4.width,
                padding: pw.EdgeInsets.fromLTRB(50, 0, 50, 0),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
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
              // pw.Row(
              //   children: [
              //     pw.Spacer(),
              //     pw.Container(
              //       width: 180,
              //       child: pw.Column(
              //         mainAxisSize: pw.MainAxisSize.min,
              //         crossAxisAlignment: pw.CrossAxisAlignment.end,
              //         children: [
              //           pw.Text(
              //             (Form_wnote.toString() == '' || Form_wnote == null)
              //                 ? 'อ้างอิงสัญญาเดิมเลขที่________________'
              //                 : 'อ้างอิงสัญญาเดิมเลขที่ ${Form_wnote}',
              //             // 'ทำที่ $renTal_name ',
              //             textAlign: pw.TextAlign.right,
              //             style: pw.TextStyle(
              //               fontSize: font_Size,
              //               font: ttf,
              //               color: Colors_pd,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
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
                      // pw.Row(
                      //   children: [
                      //     pw.Spacer(),
                      //     pw.Container(
                      //       width: 180,
                      //       child: pw.Column(
                      //         mainAxisSize: pw.MainAxisSize.min,
                      //         crossAxisAlignment: pw.CrossAxisAlignment.end,
                      //         children: [
                      //           pw.Text(
                      //             (Form_wnote.toString() == '' ||
                      //                     Form_wnote == null)
                      //                 ? 'อ้างอิงสัญญาเดิมเลขที่________________'
                      //                 : 'อ้างอิงสัญญาเดิมเลขที่ ${Form_wnote}',
                      //             // 'ทำที่ $renTal_name ',
                      //             textAlign: pw.TextAlign.right,
                      //             style: pw.TextStyle(
                      //               fontSize: font_Size,
                      //               font: ttf,
                      //               color: Colors_pd,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 12 +
                            'สัญญาฉบับนี้ทำขึ้นที่ บริษัท ชอยส์มินิสโตร์ จำกัด เลขประจำตัวนิติบุคคล 0-1055-31085-43-4 สำนักงานใหญ่ตั้งอยู่เลขที่\n 7/11 หมู่ที่ 5 ตำบลท่าศาลา อำเภอเมืองเชียงใหม่ จังหวัดเชียงใหม่ เมื่อวันที่ ${Datex_text.text} ระหว่าง บริษัท ชอยส์ มินิส โตร์ จำกัด โดยนางฤทัยรัตน์ วิสิทธิ์ และนายวธัญญู ตันตรานนท์ กรรมการผู้มีอำนาจ ซึ่งต่อไปในสัญญานี้จะเรียกว่า “ผู้ให้เช่า” ฝ่ายหนึ่ง ',
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
                            'กับ ',
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
                            'ผู้มีอำนาจลงนาม เลขประจำตัวประชาชน/ทะเบียน',
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
                            'นิติบุคคล เลขที่',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                          pw.Container(
                            width: 80,
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
                          ),
                          pw.Text(
                            'ที่อยู่/สำนักงานใหญ่ ตั้งอยู่',
                            // 'บ้าน/สำนักงาน เลขที่',
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
                                    fontSize: font_Size - 0.2,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                  ),
                                ),
                              )),

                          // pw.Text(
                          //   'ซึ่งต่อไปในสัญญานี้จะเรียกว่า “ผู้รับบริการ” อีกฝ่ายหนึ่ง คู่สัญญา',
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
                      // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      // pw.Row(
                      //   children: [
                      //     pw.Text(
                      //       'โทรศัพท์ ',
                      //       textAlign: pw.TextAlign.left,
                      //       style: pw.TextStyle(
                      //         fontSize: font_Size,
                      //         font: ttf,
                      //         color: Colors_pd,
                      //       ),
                      //     ),
                      //     pw.Expanded(
                      //         flex: 2,
                      //         child: pw.Container(
                      //           decoration: pw.BoxDecoration(
                      //               border: pw.Border(
                      //                   bottom: pw.BorderSide(
                      //             color: Colors_pd,
                      //             width: 0.3, // Underline thickness
                      //           ))),
                      //           child: pw.Text(
                      //             "$Form_tel",
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
                      //       'ซึ่งต่อไปในสัญญานี้จะเรียกว่า “ผู้รับบริการ” อีกฝ่ายหนึ่ง คู่สัญญา',
                      //       textAlign: pw.TextAlign.left,
                      //       style: pw.TextStyle(
                      //         color: Colors_pd,
                      //         fontSize: font_Size,
                      //         fontWeight: pw.FontWeight.bold,
                      //         font: ttf,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Row(
                        children: [
                          pw.Text(
                            'โทรศัพท์ ',
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
                              "$Form_tel",
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
                            'ซึ่งต่อไปในสัญญานี้จะเรียกว่า “ผู้รับบริการ” อีกฝ่ายหนึ่ง คู่สัญญา ได้ตกลงกันมีข้อความดังต่อไปนี้',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                              color: Colors_pd,
                              fontSize: font_Size,
                              fontWeight: pw.FontWeight.bold,
                              font: ttf,
                            ),
                          ),
                        ],
                      ),

                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 25 + 'ข้อ 1. ขอบเขตการให้บริการ',
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
                                'ผู้ให้บริการตกลงให้ผู้รับบริการใช้พื้นที่บริเวณหน้าร้านเซเว่น-อีเลฟเว่น ',
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
                                  "$Form_zn",
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
                            'ล็อคที่',
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
                                  "$Form_ln",
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
                            'พื้นที่ บริการ',
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
                                  "$Form_area ตร.ม.",
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
                            'เคาน์เตอร์ความสูงไม่เกิน',
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
                              " 0.8 ม.",
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
                      pw.Row(
                        children: [
                          pw.Text(
                            'จำหน่ายสินค้า/บริการ ',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                          pw.Container(
                            width: 200,
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
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 2 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 25 + 'ข้อ 2. ข้อพึงปฏิบัติตามสัญญาบริการ',
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
                        ' ' * 10 +
                            '2.1 กรณีผู้รับบริการจำหน่ายสินค้าหน้าร้านห้ามมีการเคลื่อนย้ายสถานที่ตั้งและเพิ่มขนาดของชั้นวางสินค้านอกเหนือจากที่ระบุไว้ในสัญญาบริการ',
                        textAlign: pw.TextAlign.left,
                        maxLines: 1,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 10 +
                            '2.2 ผู้รับบริการจะต้องไม่นำพื้นที่บริการให้บุคคลใดที่ไม่ใช่ลูกจ้างหรือบริวาร  เข้ามาใช้พื้นที่บริการแทนผู้รับบริการ',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 10 +
                            '2.3 ผู้รับบริการต้องดูแลทรัพย์สินของผู้รับบริการหากเกิดความเสียหายใดๆ แก่ทรัพย์สินของผู้รับบริการผู้ให้บริการจะไม่รับผิดชอบต่อความเสีย\nหายใดๆที่เกิดขึ้นทั้งสิ้น',
                        textAlign: pw.TextAlign.justify,
                        maxLines: 2,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 10 +
                            '2.4 กรณีผู้รับบริการต้องการนำทรัพย์สินของผู้รับบริการเข้าไปไว้ เพื่อจัดเตรียม หรือตกแต่งพื้นที่บริการ สามารถกระทำได้ตามความเหมาะสมที่\nผู้ให้บริการกำหนดมาตรฐานไว้เท่านั้น และให้รักษาความสะอาดอยู่เสมอ',
                        textAlign: pw.TextAlign.justify,
                        maxLines: 2,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 10 +
                            '2.5 ห้ามผู้รับบริการเข้าไปใช้พื้นที่ภายในร้านเซเว่น-อีเลฟเว่น ยกเว้นเข้าไปใช้บริการตามปกติเท่านั้น และห้ามผู้รับบริการใช้ห้องน้ำของทางร้าน',
                        textAlign: pw.TextAlign.justify,
                        maxLines: 2,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 10 +
                            '2.6 ห้ามผู้รับบริการนำรถยนต์หรือรถจักรยานยนต์   มาจอดไว้บริเวณที่จอดรถร้านเซเว่น-อีเลฟเว่น',
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 10 +
                            '2.7 ผู้รับบริการจะต้องดำเนินกิจการที่ถูกต้องตามกฎหมาย อีกทั้งสินค้าและบริการที่นำมาประกอบกิจการจะต้องไม่เป็นการละเมิดลิขสิทธิ์ สิทธิ\nบัตรเครื่องหมายการค้าตามกฎหมายว่าด้วยทรัพย์สินทางปัญญา หรือกฎหมายอื่นใดก็ตาม',
                        textAlign: pw.TextAlign.justify,
                        maxLines: 2,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 25 + 'ข้อ 3. ระยะเวลาของสัญญาบริการ',
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
                                'คู่สัญญาให้สัญญานี้มีผลบังคับใช้ ตั้งแต่วันที่ ',
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
                                  '${DateFormat('dd MMM', 'th').format(DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_sdate 00:00:00')}"))} ${DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_sdate 00:00:00')}").year + 543}',
                                  //   "$Form_sdate",
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
                              flex: 2,
                              child: pw.Container(
                                decoration: pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                  color: Colors_pd,
                                  width: 0.3, // Underline thickness
                                ))),
                                child: pw.Text(
                                  '${DateFormat('dd MMM', 'th').format(DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_ldate 00:00:00')}"))} ${DateTime.parse("${DateFormat("dd-MM-yyyy HH:mm:ss").parse('$Form_ldate 00:00:00')}").year + 543}',
                                  //  "$Form_ldate",
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
                            'โดยมี กำหนดระยะเวลา ',
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
                              (Form_rtname.toString() == 'รายวัน')
                                  ? '$FormPeriod_choice วัน '
                                  : (Form_rtname.toString() == 'รายเดือน')
                                      ? '$FormPeriod_choice เดือน '
                                      : (Form_rtname.toString() == 'รายปี')
                                          ? '$FormPeriod_choice ปี '
                                          : '$FormPeriod_choice $Form_rtname ',
                              // (Form_rtname.toString() == 'รายวัน')
                              //     ? '$Form_period วัน '
                              //     : (Form_rtname.toString() == 'รายเดือน')
                              //         ? '$Form_period เดือน '
                              //         : (Form_rtname.toString() == 'รายปี')
                              //             ? '$Form_period ปี '
                              //             : '$Form_period $Form_rtname ',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                color: Colors_pd,
                                fontSize: font_Size,
                                fontWeight: pw.FontWeight.bold,
                                font: ttf,
                              ),
                            ),
                          )
                        ],
                      ),
                      pw.SizedBox(height: 2 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 25 + 'ข้อ 4. ค่าบริการและเงินประกัน',
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
                                'คู่สัญญาตกลงราคาค่าบริการใช้พื้นที่หน้าร้าน เดือนละ ',
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
                                            e.expser.toString() == '16' &&
                                            e.cfid.toString() == '0')
                                        .isEmpty)
                                    ? '0.00'
                                    : '${nFormat.format(double.parse(quotxSelectModels.firstWhere((e) => e.expser.toString() == '16' && e.cfid.toString() == '0').pvat ?? '0.00'))} บาท',
                                // (quotxSelectModels
                                //             .where((e) =>
                                //                 e.expser.toString() == '16')
                                //             .length ==
                                //         0)
                                //     ? '0.00'
                                //     : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '16' && e.cfid.toString() != '1').map((e) => e.pvat != null ? double.parse(e.pvat.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ',
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
                            'ภาษีมูลค่าเพิ่ม',
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
                                            e.expser.toString() == '16' &&
                                            e.cfid.toString() == '0')
                                        .isEmpty)
                                    ? '0.00'
                                    : '${nFormat.format(double.parse(quotxSelectModels.firstWhere((e) => e.expser.toString() == '16' && e.cfid.toString() == '0').vat ?? '0.00'))} บาท',
                                // (quotxSelectModels
                                //             .where((e) =>
                                //                 e.expser.toString() == '16')
                                //             .length ==
                                //         0)
                                //     ? '0.00'
                                //     : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '16' && e.cfid.toString() != '1').map((e) => e.vat != null ? double.parse(e.vat.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ',
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
                            (quotxSelectModels
                                    .where((e) =>
                                        e.expser.toString() == '16' &&
                                        e.cfid.toString() == '0')
                                    .isEmpty)
                                ? 'หักภาษี ณ ที่จ่าย '
                                : 'หักภาษี ณ ที่จ่าย ' +
                                    '( ${quotxSelectModels.firstWhere((e) => e.expser.toString() == '16' && e.cfid.toString() == '0').nwht != null ? double.parse(quotxSelectModels.firstWhere((e) => e.expser.toString() == '16' && e.cfid.toString() == '0').nwht.toString()) : 0.00} ) % ',
                            // (quotxSelectModels
                            //             .where(
                            //                 (e) => e.expser.toString() == '16')
                            //             .length ==
                            //         0)
                            //     ? 'หักภาษี ณ ที่จ่าย '
                            //     : 'หักภาษี ณ ที่จ่าย ' +
                            //         '( ${quotxSelectModels.where((e) => e.expser.toString() == '16').map((e) => e.nwht != null ? double.parse(e.nwht.toString()) : 0.00).fold(0.00, (a, b) => a + b)} ) % ',
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
                            flex: 2,
                            child: pw.Container(
                              decoration: pw.BoxDecoration(
                                  border: pw.Border(
                                      bottom: pw.BorderSide(
                                color: Colors_pd,
                                width: 0.3, // Underline thickness 10096-10-2024
                              ))),
                              child: pw.Text(
                                (quotxSelectModels
                                        .where((e) =>
                                            e.expser.toString() == '16' &&
                                            e.cfid.toString() == '0')
                                        .isEmpty)
                                    ? '0.00'
                                    : '${nFormat.format(double.parse(quotxSelectModels.firstWhere((e) => e.expser.toString() == '16' && e.cfid.toString() == '0').wht ?? '0.00'))} บาท',
                                // (quotxSelectModels
                                //             .where((e) =>
                                //                 e.expser.toString() == '16')
                                //             .length ==
                                //         0)
                                //     ? '0.00'
                                //     : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '16' && e.cfid.toString() != '1').map((e) => e.wht != null ? double.parse(e.wht.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ',
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
                            'รวมเป็นเงินทั้งสิ้น',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                          pw.Expanded(
                            flex: 3,
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
                                                e.expser.toString() == '16' &&
                                                e.cfid.toString() == '0')
                                            .length ==
                                        0)
                                    ? '0.00 บาท (~${convertToThaiBaht(0.00)}~)'
                                    : '${nFormat.format(double.parse(quotxSelectModels.firstWhere((e) => e.expser.toString() == '16' && e.cfid.toString() == '0').total ?? '0.00'))} บาท ' +
                                        '(~${convertToThaiBaht(double.parse(quotxSelectModels.firstWhere((e) => e.expser.toString() == '16' && e.cfid.toString() == '0').total ?? '0.00'))}~)',
                                // (quotxSelectModels
                                //             .where((e) =>
                                //                 e.expser.toString() == '16')
                                //             .length ==
                                //         0)
                                //     ? '0.00 บาท (~${convertToThaiBaht(0.00)}~)'
                                //     : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '16' && e.cfid.toString() != '1').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ' +
                                //         '(~${convertToThaiBaht(quotxSelectModels.where((e) => e.expser.toString() == '16' && e.cfid.toString() != '1').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b))}~)',
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
                      pw.Text(
                        'โดยผู้รับบริการจะชำระค่าบริการ ผ่านทางบัญชีธนาคารที่ผู้ให้บริการกำหนด ซึ่งผู้รับบริการตกลงชำระค่าบริการเดือน แรกจำนวน',
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
                          // pw.Text(
                          //   'แรกจำนวน ',
                          //   textAlign: pw.TextAlign.left,
                          //   style: pw.TextStyle(
                          //     fontSize: font_Size,
                          //     font: ttf,
                          //     color: Colors_pd,
                          //   ),
                          // ),
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
                                                e.expser.toString() == '16' &&
                                                e.cfid.toString() == '1')
                                            .length !=
                                        0)
                                    ? "${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '16' && e.cfid.toString() == '1').map((e) => e.first_total != null ? double.parse(e.first_total.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท"
                                    : (quotxSelectModels
                                                .where((e) =>
                                                    e.expser.toString() == '16')
                                                .length ==
                                            0)
                                        ? '0.00 บาท'
                                        : "${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '16' && e.cfid.toString() != '1').map((e) => e.first_total != null ? double.parse(e.first_total.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท",
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
                            'และวางเงินประกันไว้กับผู้ให้บริการ จำนวน ',
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
                                                e.expser.toString() == '25')
                                            .length ==
                                        0)
                                    ? '0.00 (~${convertToThaiBaht(0.00)}~)'
                                    : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '25').map((e) => e.pvat != null ? double.parse(e.pvat.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ',
                                // (Form_PakanAll_pvat == null ||
                                //         Form_PakanAll_pvat.toString() == '')
                                //     ? '0.00 บาท'
                                //     : '${nFormat.format(double.parse('${Form_PakanAll_pvat}'))} บาท',
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
                            'ภาษีมูลค่าเพิ่ม',
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
                                                e.expser.toString() == '25')
                                            .length ==
                                        0)
                                    ? '0.00 (~${convertToThaiBaht(0.00)}~)'
                                    : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '25').map((e) => e.vat != null ? double.parse(e.vat.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ',
                                // (Form_PakanAll_vat == null ||
                                //         Form_PakanAll_vat.toString() == '')
                                //     ? '0.00 บาท'
                                //     : '${nFormat.format(double.parse('${Form_PakanAll_vat}'))} บาท',
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
                            'รวมเป็นเงิน',
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
                                                e.expser.toString() == '25')
                                            .length ==
                                        0)
                                    ? '0.00 (~${convertToThaiBaht(0.00)}~)'
                                    : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '25').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ',
                                // (Form_PakanAll_Total == null ||
                                //         Form_PakanAll_Total.toString() == '')
                                //     ? '0.00 บาท (~${convertToThaiBaht(0.00)}~)'
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
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 2 * PdfPageFormat.mm),
                      pw.Text(
                        'ในบรรดาค่าภาษีการค้า ภาษีป้าย หรือค่าใช้จ่ายอื่นใด ที่เกิดจากการประกอบกิจการของผู้รับบริการ ผู้รับบริการจะต้องเป็นผู้รับภาระทั้งสิ้น',
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
                            'หากผู้รับบริการประสงค์จะใช้ไฟฟ้าหรือน้ำประปา จะต้องชำระค่าธรรมเนียมดังนี้',
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
                          pw.Expanded(
                            flex: 1,
                            child: pw.Text(
                              (quotxSelectModels
                                          .where((e) =>
                                              e.expser.toString() == '19')
                                          .length ==
                                      0)
                                  ? ' ' * 15 +
                                      '[   ] ค่าชุดผ้ากันเปื้อน จำนวน_____บาท'
                                  : ' ' * 15 +
                                      '[ / ] ค่าชุดผ้ากันเปื้อน จำนวน ${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '19').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท',
                              textAlign: pw.TextAlign.left,
                              style: pw.TextStyle(
                                color: Colors_pd,
                                fontSize: font_Size,
                                fontWeight: pw.FontWeight.bold,
                                font: ttf,
                              ),
                            ),
                          ),
                          // pw.Expanded(
                          //   flex: 1,
                          //   child: pw.Text(
                          //     (quotxSelectModels
                          //                 .where((e) =>
                          //                     e.expser.toString() == '20' &&
                          //                     e.expser.toString() == '21')
                          //                 .length ==
                          //             0)
                          //         ? ' ' * 15 +
                          //             '[   ] ค่ามิเตอร์ไฟฟ้าและน้ำประปา จำนวน_____บาท'
                          //         : ' ' * 15 +
                          //             '[ / ] ค่ามิเตอร์ไฟฟ้าและน้ำประปา จำนวน ${(quotxSelectModels.where((e) => e.expser.toString() == '20' || e.expser.toString() == '21').length == 0) ? 0.00 : quotxSelectModels.where((e) => e.expser.toString() == '20' || e.expser.toString() == '21').map((e) => double.parse(e.total.toString())).reduce((a, b) => a + b)} บาท',
                          //     textAlign: pw.TextAlign.left,
                          //     style: pw.TextStyle(
                          //       color: Colors_pd,
                          //       fontSize: font_Size,
                          //       fontWeight: pw.FontWeight.bold,
                          //       font: ttf,
                          //     ),
                          //   ),
                          // ),
                          pw.Expanded(
                            flex: 1,
                            child: pw.Text(
                              (quotxSelectModels
                                          .where((e) =>
                                              e.expser.toString() == '20')
                                          .length ==
                                      0)
                                  ? ' ' * 15 +
                                      '[   ]  ค่ามิเตอร์ไฟฟ้า จำนวน_____บาท'
                                  : ' ' * 15 +
                                      '[ / ]  ค่ามิเตอร์ไฟฟ้า จำนวน ${(quotxSelectModels.where((e) => e.expser.toString() == '20').length == 0) ? 0.00 : quotxSelectModels.where((model) => model.expser == '20').map((model) => model.total).join(', ')} บาท',
                              textAlign: pw.TextAlign.left,
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
                      pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 1,
                            child: pw.Text(
                              (quotxSelectModels
                                          .where((e) =>
                                              e.expser.toString() == '21')
                                          .length ==
                                      0)
                                  ? ' ' * 15 +
                                      '[   ] ค่ามิเตอร์น้ำประปา จำนวน_____บาท'
                                  : ' ' * 15 +
                                      '[ / ] ค่ามิเตอร์น้ำประปา จำนวน ${(quotxSelectModels.where((e) => e.expser.toString() == '21').length == 0) ? 0.00 : quotxSelectModels.where((model) => model.expser == '21').map((model) => model.total).join(', ')} บาท',
                              textAlign: pw.TextAlign.left,
                              style: pw.TextStyle(
                                color: Colors_pd,
                                fontSize: font_Size,
                                fontWeight: pw.FontWeight.bold,
                                font: ttf,
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 1,
                            child: pw.Text(
                              (quotxSelectModels
                                          .where((e) =>
                                              e.expser.toString() == '20' ||
                                              e.expser.toString() == '21')
                                          .length ==
                                      0)
                                  // (hasNonCash_No_water_ele == true)
                                  ? ' ' * 15 +
                                      '[ / ] ไม่ใช้มิเตอร์ไฟฟ้าและน้ำประปา '
                                  : ' ' * 15 +
                                      '[   ] ไม่ใช้มิเตอร์ไฟฟ้าและน้ำประปา ',
                              textAlign: pw.TextAlign.left,
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
                      // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      // pw.Row(
                      //   children: [
                      //     pw.Expanded(
                      //       flex: 1,
                      //       child: pw.Text(
                      //         (quotxSelectModels
                      //                     .where((e) =>
                      //                         e.expser.toString() == '20' ||
                      //                         e.expser.toString() == '21' ||
                      //                         e.expser.toString() == '19')
                      //                     .length ==
                      //                 0)
                      //             ? ' ' * 15 + '[   ] +++'
                      //             : ' ' * 15 +
                      //                 '[ / ] *** จำนวน ${(quotxSelectModels.where((e) => e.expser.toString() == '19' || e.expser.toString() == '20' || e.expser.toString() == '21').length == 0) ? 0.00 : quotxSelectModels.where((e) => e.expser.toString() == '19' || e.expser.toString() == '20' || e.expser.toString() == '21').map((e) => double.parse(e.total.toString())).reduce((a, b) => a + b)} บาท',
                      //         textAlign: pw.TextAlign.left,
                      //         style: pw.TextStyle(
                      //           color: Colors_pd,
                      //           fontSize: font_Size,
                      //           fontWeight: pw.FontWeight.bold,
                      //           font: ttf,
                      //         ),
                      //       ),
                      //     ),
                      //     pw.Expanded(flex: 1, child: pw.SizedBox()),
                      //   ],
                      // ),
                      pw.SizedBox(height: 5 * PdfPageFormat.mm),
                      // pw.Text(
                      //   ' ' * 12 +
                      //       'โดยมีค่าบริการไฟฟ้า หน่วยละ 7 บาท ค่าบริการน้ำประปาหน่วยละ 30 บาท เป็นราคาที่ยังไม่รวมภาษีมูลค่าเพิ่ม',
                      //   textAlign: pw.TextAlign.left,
                      //   style: pw.TextStyle(
                      //     color: Colors_pd,
                      //     fontSize: font_Size,
                      //     fontWeight: pw.FontWeight.bold,
                      //     font: ttf,
                      //   ),
                      // ),
                      pw.Row(
                        children: [
                          pw.Text(
                            ' ' * 12 + 'โดยมีค่าบริการไฟฟ้า หน่วยละ',
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
                                                  e.expser.toString() == '6')
                                              .length ==
                                          0)
                                      ? '0.00 บาท'
                                      : " ${quotxSelectModels.where((model) => model.expser == '6').map((model) => model.qty).join(', ')} บาท",
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
                            'ค่าบริการน้ำประปาหน่วยละ',
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
                                                  e.expser.toString() == '7')
                                              .length ==
                                          0)
                                      ? '0.00 บาท'
                                      : " ${quotxSelectModels.where((model) => model.expser == '7').map((model) => model.qty).join(', ')} บาท",
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
                            'เป็นราคาที่ยังไม่รวมภาษีมูลค่าเพิ่ม',
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
                                'ผู้รับบริการชำระค่าบริการ และค่าธรรมเนียมอื่นๆ รวมมูลค่าเป็นเงินทั้งสิ้น ',
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
                                                  e.expser.toString() == '16' ||
                                                  e.expser.toString() == '19' ||
                                                  e.expser.toString() == '20' ||
                                                  e.expser.toString() == '21' ||
                                                  e.expser.toString() == '25')
                                              .length ==
                                          0)
                                      ? '0.00 (~${convertToThaiBaht(0.00)}~)'
                                      : (quotxSelectModels
                                                  .where((e) =>
                                                      e.expser.toString() ==
                                                          '16' &&
                                                      e.cfid.toString() == '1')
                                                  .length !=
                                              0)
                                          ? "${nFormat.format(quotxSelectModels.where((e) => (e.expser.toString() == '16' && e.cfid.toString() == '1') || e.expser.toString() == '19' || e.expser.toString() == '20' || e.expser.toString() == '21' || e.expser.toString() == '25').map((e) => e.first_total != null ? double.parse(e.first_total.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท"
                                          : (quotxSelectModels
                                                      .where((e) =>
                                                          e.expser.toString() ==
                                                          '16')
                                                      .length ==
                                                  0)
                                              ? '0.00 บาท'
                                              : "${nFormat.format(quotxSelectModels.where((e) => (e.expser.toString() == '16' && e.cfid.toString() != '1') || e.expser.toString() == '19' || e.expser.toString() == '20' || e.expser.toString() == '21' || e.expser.toString() == '25').map((e) => e.first_total != null ? double.parse(e.first_total.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท",
                                  // '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '16' || e.expser.toString() == '19' || e.expser.toString() == '20' || e.expser.toString() == '21' || e.expser.toString() == '25').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ' +
                                  //     '(~${convertToThaiBaht(quotxSelectModels.where((e) => e.expser.toString() == '16' || e.expser.toString() == '19' || e.expser.toString() == '20' || e.expser.toString() == '21' || e.expser.toString() == '25').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b))}~)',

                                  // (Form_PakanAll_Total_bill == null ||
                                  //         Form_PakanAll_Total_bill.toString() ==
                                  //             '')
                                  //     ? '0.00 บาท (~${convertToThaiBaht(0.00)}~)'
                                  //     : '${nFormat.format(double.parse('${Form_PakanAll_Total_bill}'))} บาท ' +
                                  //         '(~${convertToThaiBaht(double.parse('${Form_PakanAll_Total_bill}'))}~)',
                                  // " ${Form_PakanAll_Total_bill}-  บาท (   -   ) ",
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
                          //   ' ' * 12 + 'เลขที่ใบเสร็จเงิน',
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
                      pw.Row(
                        children: [
                          pw.Text(
                            ' ' * 12 + 'เลขที่ใบเสร็จเงินประกัน ',
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
                                  (Form_PakanSdate_Doc == null ||
                                          Form_PakanSdate_Doc.toString() == '')
                                      ? ' - '
                                      : '${Form_PakanSdate_Doc}',
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
                            'ลงวันที่',
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
                                  (Form_PakanSdate == null ||
                                          Form_PakanSdate.toString() == '')
                                      ? ' - '
                                      : '${Form_PakanSdate}',
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
                      pw.Text(
                        ' ' * 12 +
                            'อนึ่ง การชำระค่าบริการ ผู้รับบริการต้องชำระค่าบริการล่วงหน้าตั้งแต่วันที่ 25 ถึงวันสุดท้ายของแต่ละเดือนโดยถือเป็นค่าบริการเดือนถัดไปหาก\nผู้รับบริการไม่ชำระค่าบริการภายในเวลาที่กำหนด ผู้ให้บริการมีสิทธิคิดค่าปรับวันละ 50 บาทนับแต่วันที่เลยกำหนดชำระและหากผู้รับบริการยังไม่ชำระค่า\nบริการและค่าปรับภายในวันที่ 5 ของเดือนถัดไป ผู้ให้บริการมีสิทธิบอกเลิกสัญญาได้ทันที',
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
                        ' ' * 12 +
                            'ข้อ 5. การบอกเลิกหรือสิ้นสุดสัญญา และการคืนเงินประกัน',
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
                            'กรณีผู้รับบริการต้องการบอกเลิกสัญญา ต้องแจ้งให้ผู้ให้บริการทราบล่วงหน้าอย่างน้อย 60 วันหรือหากผู้รับบริการต้องการหยุดกิจการหรือไม่มา\nใช้พื้นที่บริการในวันใด ผู้รับบริการต้องแจ้งให้ผู้จัดการ กับเจ้าหน้าที่เช่าหน้าร้านทราบ และติดป้ายแจ้งหยุดกิจ การไว้ในพื้นที่บริการ หากผู้รับบริการไม่มา\nใช้พื้นที่บริการเกินกว่า 5 วัน โดยไม่แจ้งเหตุแก่ผู้จัดการ กับเจ้าหน้าที่ เช่าหน้าร้าน และติดป้ายหยุดกิจการหรือไม่สามารถติดต่อผู้รับบริการได้ผู้ให้บริการมี\nสิทธิบอกเลิกสัญญา ยึดเงินประกัน และให้ถือว่าผู้รับบริการยินยอมส่งมอบ ทรัพย์สินของผู้รับบริการ ที่ปล่อยทิ้งไว้ในพื้นที่บริการให้เป็นกรรมสิทธิ์ของผู้ให้\nบริการ',
                        textAlign: pw.TextAlign.justify,
                        maxLines: 5,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 12 +
                            'กรณีผู้ให้บริการต้องการบอกเลิกสัญญา ต้องแจ้งผู้รับบริการทราบล่วงหน้าอย่างน้อย 60 วัน และหากผู้ให้บริการมีเหตุจำเป็นต้องปิดกิจการร้าน\nเซเว่น-อีเลฟเว่น สาขาที่ผู้รับบริการใช้พื้นที่บริการ ให้ถือว่าสัญญาบริการสิ้นสุดลงทันที ',
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
                            'กรณีผู้รับบริการผิดสัญญาข้อหนึงข้อใด ผู้ให้บริการมีสิทธิบอกเลิกสัญญาได้ทันทีโดยผู้ให้บริการมีสิทธิยึดเงินประกันและเรียกเรียกร้องค่าสินไหม\nทดแทน เพื่อบรรเทาความเสียหายอันเกิดแต่การผิดสัญญานั้น ',
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
                            'หากมีการเลิกหรือสิ้นสุดสัญญาแล้วแต่กรณี ผู้ให้บริการจะคืนเงินประกันให้ผู้รับบริการภายในวันที่ 25 ของเดือนถัดไป นับจาก เดือน ที่มีการเลิก\nหรือสิ้นสุดสัญญา โดยผู้รับบริการจะต้องขนย้ายทรัพย์สินของผู้รับบริการออกจากพื้นที่บริการ และจัดการพื้นที่ให้กลับคืนสู่ สภาพ เดิมภายใน 5 วัน นับแต่\nวันที่เลิกหรือสิ้นสุดสัญญา ถ้าพ้นกำหนดระยะเวลาดังกล่าวแล้ว ผู้รับบริการยังเพิกเฉยปล่อยทิ้งทรัพย์สิน หรือไม่ จัดการพื้นที่บริการตามที่ตกลง ให้ถือว่าผู้\nรับบริการยินยอมส่งมอบทรัพย์สินของผู้รับบริการที่ปล่อยทิ้งไว้ในพื้นที่บริการให้เป็นกรรมสิทธิ์ของผู้ให้บริการซึ่งผู้ให้บริการมีสิทธิ จำหน่าย จ่าย โอน หรือจัดการทรัพย์สินยึดเงินประกันตลอดจนเรียกร้องค่าใช้จ่ายอันเกิดแต่การจัดการทรัพย์สินดังกล่าวจากผู้รับบริการโดยผู้รับบริการไม่มีสิทธิเรียกคืนทรัพย์\nสินหรือเรียกร้องค่าเสียหายใดๆ ทั้งสิ้นจากผู้ให้บริการ',
                        textAlign: pw.TextAlign.justify,
                        maxLines: 6,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      pw.Text(
                        'ข้อ 6. การบอกกล่าว',
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
                            'การบอกกล่าวตามสัญญานี้ หากผู้ให้บริการได้ทำเป็นหนังสือส่งทางไปรษณีย์ลงทะเบียนไปให้ผู้รับบริการ ตามที่อยู่ซึ่งระบุไว้ข้างต้นตามสัญญานี้ ให้ถือว่าเป็นการบอก\nกล่าวที่ถูกต้องและถือว่าผู้รับบริการได้รับทราบแล้ว หากผู้รับบริการย้าย หรือเปลี่ยนแปลงที่อยู่ ผู้รับบริการ ต้องแจ้งให้ผู้ให้บริการทราบ\nเป็นหนังสือภายใน 7 วัน นับแต่วันที่ย้ายหรือเปลี่ยนแปลงที่อยู่ มิฉะนั้นให้ถือว่าการส่งคำบอกกล่าว ใดๆ ที่ผู้ ให้บริการส่งให้ผู้รับบริการตามที่ระบุไว้ในวรรคแรก เป็นการบอกกล่าวที่ถูกต้อง และให้ถือว่าผู้รับบริการรับทราบแล้ว',
                        textAlign: pw.TextAlign.justify,
                        maxLines: 2,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 2 * PdfPageFormat.mm),
                      pw.Text(
                        ' ' * 12 +
                            'สัญญานี้ทำขึ้นสองฉบับ มีข้อความถูกต้องตรงกัน คู่สัญญาได้อ่านและเข้าใจข้อความในสัญญาโดยละเอียดแล้ว จึงได้ลงลายมือชื่อพร้อมทั้งประทับ\nตรา (ถ้ามี) ไว้เป็นสำคัญต่อหน้าพยาน และคู่สัญญาต่างยึดถือไว้ฝ่ายละฉบับ',
                        textAlign: pw.TextAlign.left,
                        maxLines: 2,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(height: 3 * PdfPageFormat.mm),
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
                                        'ผู้ให้บริการ',
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
                                    fontSize: font_Size,
                                    font: ttf,
                                    // fontWeight: pw.FontWeight.bold,
                                    color: Colors_pd,
                                    // fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                // pw.Row(
                                //     mainAxisAlignment:
                                //         pw.MainAxisAlignment.center,
                                //     children: [
                                //       pw.Text(
                                //         '( นางฤทัยรัตน์ วิสิทธิ์ และ นายวธัญ',
                                //         textAlign: pw.TextAlign.center,
                                //         style: pw.TextStyle(
                                //           color: Colors_pd,
                                //           fontSize: font_Size,
                                //           font: ttf,
                                //           // fontWeight: pw.FontWeight.bold,
                                //         ),
                                //       ),
                                //       pw.Text(
                                //         'ญู',
                                //         textAlign: pw.TextAlign.center,
                                //         style: pw.TextStyle(
                                //           color: Colors_pd2,
                                //           fontSize: font_Size - 5,
                                //           font: ttf2,
                                //           // fontWeight: pw.FontWeight.bold,
                                //         ),
                                //       ),
                                //       pw.Text(
                                //         ' ตันตรานนท์ ) ',
                                //         textAlign: pw.TextAlign.center,
                                //         style: pw.TextStyle(
                                //           color: Colors_pd,
                                //           fontSize: font_Size,
                                //           font: ttf,
                                //           // fontWeight: pw.FontWeight.bold,
                                //         ),
                                //       ),
                                //     ]),
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
                                        'ผู้รับบริการ',
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
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            )),
                      ]),
                      pw.SizedBox(height: 3 * PdfPageFormat.mm),
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
                                    font: ttf,
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
                      // pw.Row(children: [
                      //   pw.Expanded(
                      //       flex: 1,
                      //       child: pw.Column(
                      //         crossAxisAlignment: pw.CrossAxisAlignment.center,
                      //         children: [
                      //           // (signature_Image1.isEmpty)
                      //           //     ? pw.Text(
                      //           //         '',
                      //           //         maxLines: 1,
                      //           //         style: pw.TextStyle(
                      //           //           fontSize: 10,
                      //           //           font: ttf,
                      //           //           color: Colors_pd,
                      //           //         ),
                      //           //       )
                      //           //     : pw.Image(
                      //           //         pw.MemoryImage(signature_Image1),
                      //           //         height: 30,
                      //           //         width: 100,
                      //           //       ),
                      //           pw.Text(
                      //             '(ลงชื่อ)___________________________ผู้ให้บริการ    ',
                      //             textAlign: pw.TextAlign.justify,
                      //             style: pw.TextStyle(
                      //               color: Colors_pd,
                      //               fontSize: font_Size,
                      //               font: ttf,
                      //               fontWeight: pw.FontWeight.bold,
                      //             ),
                      //           ),
                      //           pw.SizedBox(height: 2 * PdfPageFormat.mm),
                      //           pw.Text(
                      //             '( นางฤทัยรัตน์ วิสิทธิ์ และ นายวธัญญู ตันตรานนท์ ) ',
                      //             textAlign: pw.TextAlign.justify,
                      //             style: pw.TextStyle(
                      //               color: Colors_pd,
                      //               fontSize: font_Size,
                      //               font: ttf,
                      //               fontWeight: pw.FontWeight.bold,
                      //             ),
                      //           ),
                      //         ],
                      //       )),
                      //   pw.SizedBox(width: 1 * PdfPageFormat.mm),
                      //   pw.Expanded(
                      //       flex: 1,
                      //       child: pw.Column(
                      //         crossAxisAlignment: pw.CrossAxisAlignment.center,
                      //         children: [
                      //           // (signature_Image2.isEmpty)
                      //           //     ? pw.Text(
                      //           //         '',
                      //           //         maxLines: 1,
                      //           //         style: pw.TextStyle(
                      //           //           fontSize: 10,
                      //           //           font: ttf,
                      //           //           color: Colors_pd,
                      //           //         ),
                      //           //       )
                      //           //     : pw.Image(
                      //           //         pw.MemoryImage(signature_Image2),
                      //           //         height: 30,
                      //           //         width: 100,
                      //           //       ),
                      //           pw.Text(
                      //             '(ลงชื่อ)___________________________ผู้รับบริการ    ',
                      //             textAlign: pw.TextAlign.justify,
                      //             style: pw.TextStyle(
                      //               color: Colors_pd,
                      //               fontSize: font_Size,
                      //               font: ttf,
                      //               fontWeight: pw.FontWeight.bold,
                      //             ),
                      //           ),
                      //           pw.SizedBox(height: 2 * PdfPageFormat.mm),
                      //           pw.Text(
                      //             '( $Form_bussshop ) ',
                      //             textAlign: pw.TextAlign.justify,
                      //             style: pw.TextStyle(
                      //               color: Colors_pd,
                      //               fontSize: font_Size,
                      //               font: ttf,
                      //               fontWeight: pw.FontWeight.bold,
                      //             ),
                      //           ),
                      //         ],
                      //       )),
                      // ]),
                      // pw.SizedBox(height: 15 * PdfPageFormat.mm),
                      // pw.Row(children: [
                      //   pw.Expanded(
                      //       flex: 1,
                      //       child: pw.Column(
                      //         crossAxisAlignment: pw.CrossAxisAlignment.center,
                      //         children: [
                      //           // (signature_Image3.isEmpty)
                      //           //     ? pw.Text(
                      //           //         '',
                      //           //         maxLines: 1,
                      //           //         style: pw.TextStyle(
                      //           //           fontSize: 10,
                      //           //           font: ttf,
                      //           //           color: Colors_pd,
                      //           //         ),
                      //           //       )
                      //           //     : pw.Image(
                      //           //         pw.MemoryImage(signature_Image3),
                      //           //         height: 30,
                      //           //         width: 100,
                      //           //       ),
                      //           pw.Text(
                      //             '(ลงชื่อ)___________________________พยาน    ',
                      //             textAlign: pw.TextAlign.justify,
                      //             style: pw.TextStyle(
                      //               color: Colors_pd,
                      //               fontSize: font_Size,
                      //               font: ttf,
                      //               fontWeight: pw.FontWeight.bold,
                      //             ),
                      //           ),
                      //           pw.SizedBox(height: 2 * PdfPageFormat.mm),
                      //           pw.Text(
                      //             '( นางสาวชนิดา ส่งเจริญ ) ',
                      //             textAlign: pw.TextAlign.center,
                      //             style: pw.TextStyle(
                      //               color: Colors_pd,
                      //               fontSize: font_Size,
                      //               font: ttf,
                      //               fontWeight: pw.FontWeight.bold,
                      //             ),
                      //           ),
                      //         ],
                      //       )),
                      //   pw.SizedBox(width: 1 * PdfPageFormat.mm),
                      //   pw.Expanded(
                      //       flex: 1,
                      //       child: pw.Column(
                      //         crossAxisAlignment: pw.CrossAxisAlignment.center,
                      //         children: [
                      //           // (signature_Image4.isEmpty)
                      //           //     ? pw.Text(
                      //           //         '',
                      //           //         maxLines: 1,
                      //           //         style: pw.TextStyle(
                      //           //           fontSize: 10,
                      //           //           font: ttf,
                      //           //           color: Colors_pd,
                      //           //         ),
                      //           //       )
                      //           //     : pw.Image(
                      //           //         pw.MemoryImage(signature_Image4),
                      //           //         height: 30,
                      //           //         width: 100,
                      //           //       ),
                      //           pw.Text(
                      //             '(ลงชื่อ)___________________________พยาน    ',
                      //             textAlign: pw.TextAlign.justify,
                      //             style: pw.TextStyle(
                      //               color: Colors_pd,
                      //               fontSize: font_Size,
                      //               font: ttf,
                      //               fontWeight: pw.FontWeight.bold,
                      //             ),
                      //           ),
                      //           pw.SizedBox(height: 2 * PdfPageFormat.mm),
                      //           pw.Text(
                      //             '(___________________________) ',
                      //             textAlign: pw.TextAlign.justify,
                      //             style: pw.TextStyle(
                      //               fontSize: font_Size,
                      //               font: ttf,
                      //               fontWeight: pw.FontWeight.bold,
                      //             ),
                      //           ),
                      //         ],
                      //       )),
                      // ]),
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
                        pw.Text(
                          "${context.pageNumber} of ${context.pagesCount}",
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: Colors_pd,
                            fontSize: font_Size - 2,
                            font: ttf,
                          ),
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
            Get_Value_NameShop_index: Get_Value_NameShop_index,
            Get_Value_cid: Get_Value_cid,
            verticalGroupValue: _verticalGroupValue,
            Form_nameshop: Form_nameshop,
            Form_typeshop: Form_typeshop,
            Form_bussshop: Form_bussshop,
            Form_bussscontact: Form_bussscontact,
            Form_address: Form_address,
            Form_tel: Form_tel,
            Form_email: Form_email,
            Form_tax: Form_tax,
            Form_ln: Form_ln,
            Form_zn: Form_zn,
            Form_area: Form_area,
            Form_qty: Form_qty,
            Form_sdate: Form_sdate,
            Form_ldate: Form_ldate,
            Form_period: Form_period,
            Form_rtname: Form_rtname,
            quotxSelectModels: quotxSelectModels,
            TransModels: _TransModels,
            renTal_name: renTal_name,
            bill_addr: bill_addr,
            bill_email: bill_email,
            bill_tel: bill_tel,
            bill_tax: bill_tax,
            bill_name: bill_name,
            newValuePDFimg: newValuePDFimg,
          ),
        ));
  }
}

// SELECT
//  c_contractx.unitser ,
//  c_trans.expser , c_trans.date , c_trans.total AS first_total ,  c_trans.total AS first_total ,c_contractx.*
// FROM c_contractx

// LEFT JOIN  c_trans ON c_trans.no = c_contractx.ser AND MONTH(c_trans.duedate) = MONTH(c_contractx.sdate)  AND c_trans.dtype != '!Z'
// LEFT JOIN  c_invoice ON c_invoice.cid = c_contractx.cid AND MONTH(c_invoice.date) = MONTH(c_contractx.sdate)

// WHERE c_contractx.cid = '10029-11-2024'  AND c_contractx.st = '1'

// GROUP BY c_contractx.ser ;
