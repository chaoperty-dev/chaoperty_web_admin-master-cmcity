import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../CRC_16_Prompay/generate_qrcode.dart';
import '../../Constant/Myconstant.dart';
import '../../Man_PDF/Preview_PDF/PreviewPdfgen_Billsplay.dart';
import '../../Model/trans_re_bill_history_model.dart';
import '../../PeopleChao/Pays_.dart';
import '../../Style/File_s.dart';
import '../../Style/ThaiBaht.dart';
import '../../Style/loadAndCacheImage.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class Pdfgen_his_statusbill_TP8_Choice {
//////////---------------------------------------------------->(ใบเสร็จรับเงิน/ใบกำกับภาษี)   ใช้  //

  static void exportPDF_statusbill_TP8_Choice(
      List<TransReBillHistoryModel> TransReBillHistory,
      Cust_no,
      cid_s,
      Zone_s,
      Ln_s,
      fname,
      foder,
      tableData00,
      tableData01,
      context,
      _TransReBillHistoryModels,
      Num_cid,
      Namenew,
      sum_pvat,
      sum_vat,
      sum_wht,
      Sum_SubTotal,
      sum_disp,
      sum_disamt,
      Total,
      renTal_name,
      sname,
      cname,
      addr,
      tax,
      bill_addr,
      bill_email,
      bill_tel,
      bill_tax,
      bill_name,
      newValuePDFimg,
      numinvoice,
      numdoctax,
      ref_invoice,
      finnancetransModels,
      date_Transaction,
      dayfinpay,
      type_bills,
      dis_sum_Matjum,
      TitleType_Default_Receipt_Name,
      dis_sum_Pakan,
      sum_fee,
      com_ment,
      fonts_pdf,
      Preview_ser,
      Con_remark,
      round_p,
      paper,
      paper_run,
      amt_up,
      vat_up,
      sum_addvat,
      sum_Nonvat) async {
    ////
    //// ------------>(ใบเสร็จรับเงิน)
    ///////
    final pdf = pw.Document();
    final font = await rootBundle.load("${fonts_pdf}");
    var Colors_pd = PdfColors.black;
    // final font = await rootBundle.load("fonts/Sarabun-Medium.ttf");

    int pageCount = 1; // Initialize the page count
    final ttf = pw.Font.ttf(font);
    double widths = await MediaQuery.of(context).size.width;
    double font_Size = 10.0;
    //////--------------------------------------------->
    DateTime date = DateTime.now();
    // // var formatter = new DateFormat.MMMMd('th_TH');
    // // String thaiDate = formatter.format(date);
    // final thaiDate = DateTime.parse(date_Transaction);
    // final formatter = DateFormat('d MMMM', 'th_TH');
    // final formattedDate = formatter.format(thaiDate);
    // //////--------------->พ.ศ.
    // DateTime dateTime = DateTime.parse(date_Transaction);
    // int newYear = dateTime.year + 543;
    //////--------------------------------------------->
    var nFormat = NumberFormat("#,##0.00", "en_US");
    var nFormat2 = NumberFormat("###0.00", "en_US");
    final iconImage =
        (await rootBundle.load('images/LOGO.png')).buffer.asUint8List();
    List netImage = [];
    List netImage_QR = [];
    final ByteData image = await rootBundle.load('images/image7-11.png');
    final ByteData BG_PDF = await rootBundle.load('images/Choice_BG_PDF.png');
    final ByteData LG_PDF = await rootBundle.load('images/choice_logo2.png');
    // final ByteData Logo_PDF = await rootBundle.load('images/choice_logo.png');
    Uint8List? resizedLogo = await getResizedLogo();
    Uint8List imageData = (image).buffer.asUint8List();
    Uint8List imageBG = (BG_PDF).buffer.asUint8List();
    Uint8List imageLG = (LG_PDF).buffer.asUint8List();
    var docid = (numdoctax.toString() == '') ? '$numinvoice ' : '$numdoctax ';
    var licence_name1 = 'สิริกร พรหมปัญญา';
    var licence_name2 = 'สิริกร พรหมปัญญา';
    var refid = 'LLJZX20241';

    final imageBytes_manager = await loadAndCacheImage(
        '${MyConstant().domain}/gen_licence_img.php?isAdd=true&ren=106&ref_id=$refid&name_id=$licence_name1&doc_id=$docid&extension=.png');
    // final imageBytes_Payee = await loadAndCacheImage(
    //     '${MyConstant().domain}/gen_licence_img.php?isAdd=true&ren=50&ref_id=$refid&name_id=$licence_name2&doc_id=$docid&extension=.png');

////////////////------------------------------->
    double Total_CASH = double.parse(
      '${finnancetransModels.where((model) => model.ptser == '1' && model.dtype == 'KP').fold<double>(
            0.0,
            (double previousValue, element) =>
                previousValue +
                (element.total != null ? double.parse(element.total!) : 0),
          )}',
    );

    // '${finnancetransModels.where((model) => model.ptser == '1' && model.dtype == 'KP').map((model) => model.total).join(', ')}';
    String total_QR =
        '${nFormat.format(double.parse('${Total}') - Total_CASH)}';
    String newTotal_QR = total_QR.replaceAll(RegExp(r'[^0-9]'), '');
    // for (int i = 0; i < newValuePDFimg.length; i++) {
    //   netImage.add(await networkImage('${newValuePDFimg[i]}'));
    // }
    for (int i = 0; i < finnancetransModels.length; i++) {
      if (finnancetransModels[i].img == null ||
          finnancetransModels[i].img.toString() == '') {
        netImage_QR.add(iconImage);
      } else {
        netImage_QR.add(await networkImage(
            '${MyConstant().domain}/files/$foder/payment/${finnancetransModels[i].img}'));
      }
    }

//////////---------------------------->
    bool hasNonCashTransaction = finnancetransModels.any((transaction) {
      return transaction.type.toString() != 'CASH' &&
          transaction.type != null &&
          transaction.dtype.toString() != 'FTA';
    }); ///// เงินโอน , Online Standard QR , Online Payment
////////////////------------------------------->
    bool hasNonCashTransaction1 = finnancetransModels.any((transaction) {
      return transaction.type.toString() == 'CASH' &&
          transaction.dtype.toString() != 'FTA';
    }); ///// เงินสด
////////////////------------------------------->
    bool hasNonCashTransaction2 = finnancetransModels.any((transaction) {
      return transaction.ptser.toString() == '6' &&
          transaction.dtype.toString() != 'FTA';
    }); //Online Standard QR
////////////////------------------------------->
    bool hasNonCashTransaction3 = finnancetransModels.any((transaction) {
      return transaction.ptser.toString() == '2' &&
          transaction.dtype.toString() != 'FTA';
    }); ///// เงินโอน
////////////////------------------------------->
    bool hasNonCashTransaction4 = finnancetransModels.any((transaction) {
      return transaction.ptser.toString() == '5' &&
          transaction.dtype.toString() != 'FTA';
    }); ///// Online Payment
////////////////------------------------------->
    bool hasNonCashTransaction5 = finnancetransModels.any((transaction) {
      return transaction.dtype.toString() == 'MM';
    }); ///// Online Payment
//////////---------------------------------->
    bool hasNonCashTransaction6 = finnancetransModels.any((transaction) {
      return transaction.dtype.toString() == 'FTA';
    }); ///// Online Payment
//////////---------------------------------->
    bool hasNonCashTransaction7 = finnancetransModels.any((transaction) {
      return transaction.ref1.toString().trim() == '';
    });
    bool hasNonCashTransaction8 = finnancetransModels.any((transaction) {
      return transaction.ptser.toString().trim() == '6';
    });
///// Online Standard QR

//////////---------------------------------->

///////------------------------------->
    double getTotalByField(
      List<TransReBillHistoryModel> trans,
      String? Function(TransReBillHistoryModel item) getter,
    ) {
      return trans.fold(0.0, (sum, item) {
        final value = double.tryParse(getter(item) ?? '0.00') ?? 0.00;
        return sum + value;
      });
    }

///////------------------------------->

    final totalAmt = getTotalByField(
        _TransReBillHistoryModels, (e) => e.amt.toString() ?? '0');
    final totalPvat = getTotalByField(
        _TransReBillHistoryModels, (e) => e.pvat.toString() ?? '0');
    final totalVat = getTotalByField(
        _TransReBillHistoryModels, (e) => e.vat.toString() ?? '0');
    final totalWht = getTotalByField(
        _TransReBillHistoryModels, (e) => e.wht.toString() ?? '0');
    final totalLine = getTotalByField(
        _TransReBillHistoryModels, (e) => e.total.toString() ?? '0');

    final net_amount_pvat = getTotalByField(
        _TransReBillHistoryModels, (e) => e.net_amount_pvat.toString() ?? '0');
    final net_non_pvat = getTotalByField(
        _TransReBillHistoryModels, (e) => e.net_non_pvat.toString() ?? '0');

    final totalDis = double.tryParse(sum_disamt.toString() ?? '0.00') ?? 0.00;
    final totalFee = double.tryParse(sum_fee.toString() ?? '0.00') ?? 0.00;
    final totalMatjum =
        double.tryParse(dis_sum_Matjum.toString() ?? '0.00') ?? 0.00;
    final totalPakan =
        double.tryParse(dis_sum_Pakan.toString() ?? '0.00') ?? 0.00;

    final totalBill =
        ((totalLine + totalFee) - totalDis) - (totalMatjum + totalPakan);

    // คำนวณจำนวนเงินหลังหักส่วนลด
    String afterDiscount = '';
    if (nFormat.format(double.parse(dis_sum_Matjum.toString())) != '0.00') {
      afterDiscount = nFormat.format(double.parse(dis_sum_Matjum.toString()) -
          double.parse(sum_disamt.toString()));
    } else if (nFormat.format(double.parse(dis_sum_Pakan.toString())) !=
        '0.00') {
      afterDiscount = nFormat.format(double.parse(dis_sum_Pakan.toString()) -
          double.parse(sum_disamt.toString()));
    } else {
      afterDiscount = nFormat.format(double.parse(sum_fee.toString()) -
          double.parse(sum_disamt.toString()));
    }
    ///////------------------------------->

    String getFormattedText(String? data) {
      final value =
          (data == null) ? 0.00 : double.tryParse(data ?? '0.00') ?? 0.00;
      return nFormat.format(value);
    }

    bool isPositive(String? value) {
      return (double.tryParse(value ?? '0.00') ?? 0.00) > 0;
    }

    pw.Widget buildCell({
      required String text,
      int flex = 1,
      double padding = 2.0,
      pw.Alignment alignment = pw.Alignment.centerRight,
      pw.TextAlign textAlign = pw.TextAlign.right,
    }) {
      return pw.Expanded(
        flex: flex,
        child: pw.Container(
          decoration: const pw.BoxDecoration(
            // color: PdfColors.white,
            border: pw.Border(
              left: pw.BorderSide(color: PdfColors.grey600),
              right: pw.BorderSide(color: PdfColors.grey600),
            ),
          ),
          padding: pw.EdgeInsets.all(padding),
          child: pw.Align(
            alignment: alignment,
            child: pw.Text(
              text,
              maxLines: 2,
              textAlign: textAlign,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: PdfColors.grey800,
              ),
            ),
          ),
        ),
      );
    }

    final pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4.copyWith(
        marginBottom: 5.00,
        marginLeft: 0.00,
        marginRight: 0.00,
        marginTop: 0.00,
      ),
      buildBackground: (ctx) => pw.FullPage(
        ignoreMargins: true,
        child: pw.Image(pw.MemoryImage(imageBG), fit: pw.BoxFit.cover),
      ),
    );
    pw.Widget Header(context) {
      return pw
          .Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Container(
          width: PdfPageFormat.a4.width + 100,
          color: PdfColors.green900,
          height: 13,
        ),
        pw.SizedBox(height: 1 * PdfPageFormat.mm),

        pw.Container(
            padding: pw.EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: pw.Column(
              children: [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    imageLG != null
                        ? pw.Container(
                            child: pw.Center(
                            child: pw.Image(pw.MemoryImage(imageLG),
                                height: 55, width: 60, fit: pw.BoxFit.fill),
                          ))
                        : pw.Container(
                            height: 55,
                            width: 60,
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
                    // (netImage.isEmpty)
                    //     ? pw.Container(
                    //         height: 60,
                    //         width: 60,
                    //         decoration: const pw.BoxDecoration(
                    //           color: PdfColors.grey200,
                    //           border: pw.Border(
                    //             right: pw.BorderSide(color: PdfColors.grey300),
                    //             left: pw.BorderSide(color: PdfColors.grey300),
                    //             top: pw.BorderSide(color: PdfColors.grey300),
                    //             bottom: pw.BorderSide(color: PdfColors.grey300),
                    //           ),
                    //         ),
                    //         child: pw.Center(
                    //           child: pw.Text(
                    //             '$bill_name ',
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
                    //     : pw.Container(
                    //         height: 60,
                    //         width: 60,
                    //         decoration: const pw.BoxDecoration(
                    //           color: PdfColors.grey200,
                    //           border: pw.Border(
                    //             right: pw.BorderSide(color: PdfColors.grey300),
                    //             left: pw.BorderSide(color: PdfColors.grey300),
                    //             top: pw.BorderSide(color: PdfColors.grey300),
                    //             bottom: pw.BorderSide(color: PdfColors.grey300),
                    //           ),
                    //         ),
                    //         child: pw.Image(
                    //           (netImage[0]),
                    //           // fit: pw.BoxFit.fill,
                    //           height: 60,
                    //           width: 60,
                    //         )),
                    pw.SizedBox(width: 1 * PdfPageFormat.mm),
                    pw.Container(
                      // color: PdfColors.grey200,
                      width: 400,
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        mainAxisSize: pw.MainAxisSize.min,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            '$bill_name',
                            //'$',
                            maxLines: 2,
                            style: pw.TextStyle(
                              color: Colors_pd,
                              fontSize: font_Size,
                              // fontWeight: pw.FontWeight.bold,
                              font: ttf,
                            ),
                          ),
                          pw.Text(
                            (bill_addr == null ||
                                    bill_addr.toString() == 'null' ||
                                    bill_addr.toString() == '')
                                ? 'ที่อยู่ : -'
                                : 'ที่อยู่ : $bill_addr',
                            maxLines: 3,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              color: Colors_pd,
                              font: ttf,
                            ),
                          ),
                          pw.Text(
                            (bill_tax.toString() == '' || bill_tax == null)
                                ? 'หมายเลขประจำตัวผู้เสียภาษี : 0'
                                : 'หมายเลขประจำตัวผู้เสียภาษี : $bill_tax',
                            // textAlign: pw.TextAlign.justify,
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                          pw.Text(
                            'โทรศัพท์ : $bill_tel',
                            textAlign: pw.TextAlign.right,
                            maxLines: 1,
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
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.fromLTRB(0, 0, 10, 0),
                          child: pw.Align(
                            alignment: pw.Alignment.topRight,
                            child: pw.Text(
                              'หน้าที่ ${context.pageNumber} / ${context.pagesCount} ',
                              // textAlign: pw.TextAlign.left,
                              style: pw.TextStyle(
                                fontSize: 10,
                                font: ttf,
                                color: Colors_pd,
                                // fontWeight: pw.FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                        if (TitleType_Default_Receipt_Name != null &&
                            TitleType_Default_Receipt_Name.toString().trim() !=
                                '' &&
                            TitleType_Default_Receipt_Name.toString().trim() !=
                                'ไม่ระบุ')
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
                                border: pw.Border.all(
                                    color: PdfColors.black, width: 1),
                              ),
                              padding: pw.EdgeInsets.all(4),
                              child: pw.Center(
                                child: pw.Text(
                                  '$TitleType_Default_Receipt_Name',
                                  maxLines: 1,
                                  style: pw.TextStyle(
                                    fontSize: 20,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  ],
                ),
                pw.SizedBox(height: 1 * PdfPageFormat.mm + 3),
              ],
            )),

        // pw.SizedBox(height: 1 * PdfPageFormat.mm),
        // pw.Divider(),
        // pw.SizedBox(height: 1 * PdfPageFormat.mm),
      ]);
    }

    pw.Widget headerBlock(double fontSize, pw.Font ttf, PdfColor color) {
      return pw.Container(
          // decoration: pw.BoxDecoration(
          //   image: pw.DecorationImage(
          //     image: pw.MemoryImage(
          //       imageBG,
          //     ),
          //     fit: pw.BoxFit.fill,
          //   ),
          // ),
          // padding: pw.EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: pw.Column(children: [
        pw.Container(
          height: (ref_invoice.length > 5)
              ? 112
              : (ref_invoice.length > 1)
                  ? 100
                  : 85,
          child: pw.Row(
            children: [
              pw.Expanded(
                  flex: 3,
                  child: pw.Container(
                    height: (ref_invoice.length > 30)
                        ? 260
                        : (ref_invoice.length > 25)
                            ? 230
                            : (ref_invoice.length > 20)
                                ? 200
                                : (ref_invoice.length > 10)
                                    ? 130
                                    : (ref_invoice.length > 5)
                                        ? 112
                                        : (ref_invoice.length > 1)
                                            ? 115
                                            : 85,
                    decoration: const pw.BoxDecoration(
                      // color: PdfColors.green100,
                      border: pw.Border(
                        top: pw.BorderSide(color: PdfColors.grey600),
                        right: pw.BorderSide(color: PdfColors.grey600),
                        left: pw.BorderSide(color: PdfColors.grey600),
                        bottom: pw.BorderSide(color: PdfColors.grey600),
                      ),
                    ),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                            flex: 1,
                            child: pw.Container(
                              padding: pw.EdgeInsets.fromLTRB(2, 4, 2, 2),
                              child: pw.Column(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    // (cname.toString() == '' ||
                                    //         cname.toString() == '-' ||
                                    //         cname == null ||
                                    //         cname.toString() ==
                                    //             'null')
                                    //     ? 'นามลูกค้า /Name : ${(sname.toString() == '' || sname == null || sname.toString() == 'null') ? '-' : sname}'
                                    //     :
                                    'นามลูกค้า /Name : ${cname}',
                                    // (sname.toString() == null ||
                                    //         sname.toString() == '' ||
                                    //         sname.toString() == 'null')
                                    //     ? 'นามลูกค้า /Name : -'
                                    //     : 'นามลูกค้า /Name : $sname',
                                    textAlign: pw.TextAlign.left,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                  pw.Text(
                                    (addr.toString() == null ||
                                            addr.toString() == '' ||
                                            addr.toString() == 'null')
                                        ? 'ที่อยู่ /Address : -'
                                        : 'ที่อยู่ /Address  : $addr',
                                    textAlign: pw.TextAlign.left,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                  pw.Text(
                                    (tax == null ||
                                            tax.toString() == '' ||
                                            tax.toString() == 'null')
                                        ? 'เลขที่ผู้เสียภาษี /Tax : 0'
                                        : 'เลขที่ผู้เสียภาษี /Tax : $tax',
                                    textAlign: pw.TextAlign.left,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                  // pw.Text(
                                  //   'เลขสัญญา /No. : $cid_s ',
                                  //   textAlign: pw.TextAlign.left,
                                  //   style: pw.TextStyle(
                                  //     fontSize: font_Size,
                                  //     font: ttf,
                                  //     fontWeight: pw.FontWeight.bold,
                                  //     color: Colors_pd,
                                  //   ),
                                  // ),
                                  // pw.Text(
                                  //   'โซน /Zone : $Zone_s (รหัสพื้นที่ /Area  : $Ln_s)',
                                  //   textAlign: pw.TextAlign.left,
                                  //   style: pw.TextStyle(
                                  //     fontSize: font_Size,
                                  //     font: ttf,
                                  //     fontWeight: pw.FontWeight.bold,
                                  //     color: Colors_pd,
                                  //   ),
                                  // ),
                                  pw.Text(
                                    'หมายเหตุ /Note : $com_ment ',
                                    textAlign: pw.TextAlign.left,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                  (ref_invoice.length > 1)
                                      ? pw.Text(
                                          'อ้างอิงเลขที่/Refer no. : ${ref_invoice.toSet().map((model) => model).join(', ')}',
                                          textAlign: pw.TextAlign.left,
                                          maxLines: 5,
                                          style: pw.TextStyle(
                                            fontSize: (ref_invoice.length > 20)
                                                ? font_Size - 2
                                                : font_Size,
                                            font: ttf,
                                            fontWeight: pw.FontWeight.bold,
                                            color: Colors_pd,
                                          ),
                                        )
                                      : pw.SizedBox(),
                                ],
                              ),
                            )),
                      ],
                    ),
                  )),
              pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    children: [
                      pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                            height: (ref_invoice.length > 5)
                                ? 40
                                : (ref_invoice.length > 1)
                                    ? 20
                                    : 10,
                            decoration: const pw.BoxDecoration(
                              // color: PdfColors.green100,
                              border: pw.Border(
                                right: pw.BorderSide(color: PdfColors.grey600),
                                top: pw.BorderSide(color: PdfColors.grey600),
                                bottom: pw.BorderSide(color: PdfColors.grey600),
                              ),
                            ),
                            child: pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Expanded(
                                  flex: 1,
                                  child: pw.Column(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.center,
                                      children: [
                                        (hasNonCashTransaction1)
                                            ? pw.Text(
                                                (TitleType_Default_Receipt_Name !=
                                                            null &&
                                                        TitleType_Default_Receipt_Name
                                                                    .toString()
                                                                .trim() !=
                                                            '' &&
                                                        TitleType_Default_Receipt_Name
                                                                .toString() !=
                                                            'ไม่ระบุ')
                                                    ? (numdoctax.toString() ==
                                                            '')
                                                        ? 'บิลเงินสด [ $TitleType_Default_Receipt_Name ]'
                                                        : 'บิลเงินสด/ใบกำกับภาษี [ $TitleType_Default_Receipt_Name ]'
                                                    : (numdoctax.toString() ==
                                                            '')
                                                        ? 'บิลเงินสด'
                                                        : 'บิลเงินสด/ใบกำกับภาษี',
                                                textAlign: pw.TextAlign.center,
                                                style: pw.TextStyle(
                                                  fontSize: 14,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: Colors_pd,
                                                ),
                                              )
                                            : pw.Text(
                                                (TitleType_Default_Receipt_Name !=
                                                            null &&
                                                        TitleType_Default_Receipt_Name
                                                                    .toString()
                                                                .trim() !=
                                                            '' &&
                                                        TitleType_Default_Receipt_Name
                                                                .toString() !=
                                                            'ไม่ระบุ')
                                                    ? (numdoctax.toString() ==
                                                            '')
                                                        ? 'ใบเสร็จรับเงิน'
                                                        : 'ใบเสร็จรับเงิน/ใบกำกับภาษี '
                                                    : (numdoctax.toString() ==
                                                            '')
                                                        ? 'ใบเสร็จรับเงิน'
                                                        : 'ใบเสร็จรับเงิน/ใบกำกับภาษี',
                                                textAlign: pw.TextAlign.center,
                                                style: pw.TextStyle(
                                                  fontSize: 14,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: Colors_pd,
                                                ),
                                              ),
                                        (hasNonCashTransaction1)
                                            ? pw.Text(
                                                (TitleType_Default_Receipt_Name !=
                                                            null &&
                                                        TitleType_Default_Receipt_Name.toString()
                                                                .trim() !=
                                                            '' &&
                                                        TitleType_Default_Receipt_Name
                                                                .toString() !=
                                                            'ไม่ระบุ')
                                                    ? (numdoctax.toString() ==
                                                            '')
                                                        ? (TitleType_Default_Receipt_Name
                                                                    .toString() ==
                                                                'ต้นฉบับ')
                                                            ? 'Cash Sell Original'
                                                            : (TitleType_Default_Receipt_Name
                                                                        .toString() ==
                                                                    'คู่ฉบับ')
                                                                ? 'Cash Sell Duplicate'
                                                                : (TitleType_Default_Receipt_Name
                                                                            .toString() ==
                                                                        'สำเนาคู่ฉบับ')
                                                                    ? 'Cash Sell Duplicate Copy'
                                                                    : (TitleType_Default_Receipt_Name.toString() ==
                                                                            'สำเนา')
                                                                        ? 'Cash Sell Copy'
                                                                        : 'Cash Sell'
                                                        : (TitleType_Default_Receipt_Name
                                                                    .toString() ==
                                                                'ต้นฉบับ')
                                                            ? 'Cash Sell/Tax Invoice Original'
                                                            : (TitleType_Default_Receipt_Name
                                                                        .toString() ==
                                                                    'คู่ฉบับ')
                                                                ? 'Cash Sell/Tax Invoice Duplicate'
                                                                : (TitleType_Default_Receipt_Name
                                                                            .toString() ==
                                                                        'สำเนาคู่ฉบับ')
                                                                    ? 'Cash Sell/Tax Invoice Duplicate Copy'
                                                                    : (TitleType_Default_Receipt_Name.toString() ==
                                                                            'สำเนา')
                                                                        ? 'Cash Sell/Tax Invoice Copy'
                                                                        : 'Cash Sell/Tax Invoice'
                                                    : (numdoctax.toString() ==
                                                            '')
                                                        ? 'Cash Sell'
                                                        : 'Cash Sell/Tax Invoice',
                                                textAlign: pw.TextAlign.center,
                                                style: pw.TextStyle(
                                                  fontSize: 14,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: Colors_pd,
                                                ),
                                              )
                                            : pw.Text(
                                                (TitleType_Default_Receipt_Name !=
                                                        null)
                                                    ? (numdoctax.toString() ==
                                                            '')
                                                        ? (TitleType_Default_Receipt_Name
                                                                    .toString() ==
                                                                'ต้นฉบับ')
                                                            ? 'Receipt Original'
                                                            : (TitleType_Default_Receipt_Name
                                                                        .toString() ==
                                                                    'คู่ฉบับ')
                                                                ? 'Receipt Duplicate'
                                                                : (TitleType_Default_Receipt_Name
                                                                            .toString() ==
                                                                        'สำเนาคู่ฉบับ')
                                                                    ? 'Receipt Duplicate Copy'
                                                                    : (TitleType_Default_Receipt_Name.toString() ==
                                                                            'สำเนา')
                                                                        ? 'Receipt Copy'
                                                                        : 'Receipt'
                                                        : (TitleType_Default_Receipt_Name
                                                                    .toString() ==
                                                                'ต้นฉบับ')
                                                            ? 'Receipt/Tax Receipt Original'
                                                            : (TitleType_Default_Receipt_Name
                                                                        .toString() ==
                                                                    'คู่ฉบับ')
                                                                ? 'Receipt/Tax Receipt Duplicate'
                                                                : (TitleType_Default_Receipt_Name
                                                                            .toString() ==
                                                                        'สำเนาคู่ฉบับ')
                                                                    ? 'Receipt/Tax Receipt Duplicate Copy'
                                                                    : (TitleType_Default_Receipt_Name.toString() ==
                                                                            'สำเนา')
                                                                        ? 'Receipt/Tax Receipt Copy'
                                                                        : 'Receipt/Tax Invoice'
                                                    : (numdoctax.toString() ==
                                                            '')
                                                        ? 'Receipt'
                                                        : 'Receipt/Tax Invoice',
                                                textAlign: pw.TextAlign.center,
                                                style: pw.TextStyle(
                                                  fontSize: 14,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: Colors_pd,
                                                ),
                                              ),
                                      ]),
                                ),
                              ],
                            ),
                          )),
                      pw.Row(
                        children: [
                          pw.Expanded(
                              flex: 1,
                              child: pw.Container(
                                height: (ref_invoice.length > 5)
                                    ? 70
                                    : (ref_invoice.length > 1)
                                        ? 50
                                        : 40,
                                decoration: const pw.BoxDecoration(
                                  // color: PdfColors.green100,
                                  border: pw.Border(
                                    right:
                                        pw.BorderSide(color: PdfColors.grey600),
                                    top:
                                        pw.BorderSide(color: PdfColors.grey600),
                                    bottom:
                                        pw.BorderSide(color: PdfColors.grey600),
                                  ),
                                ),
                                child: pw.Row(
                                  // crossAxisAlignment:
                                  //     pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Expanded(
                                      flex: 1,
                                      child: pw.Column(
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.center,
                                          children: [
                                            pw.Text(
                                              'วันที่ทำรายการ',
                                              textAlign: pw.TextAlign.center,
                                              style: pw.TextStyle(
                                                fontSize: font_Size,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: Colors_pd,
                                              ),
                                            ),
                                            pw.Text(
                                              'Date',
                                              textAlign: pw.TextAlign.center,
                                              style: pw.TextStyle(
                                                fontSize: font_Size,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: Colors_pd,
                                              ),
                                            ),
                                            pw.Text(
                                              '${DateFormat('dd/MM').format(DateTime.parse(date_Transaction!))}/${DateTime.parse('${date_Transaction}').year + 543}',
                                              //'$date_Transaction',
                                              textAlign: pw.TextAlign.center,
                                              style: pw.TextStyle(
                                                fontSize: font_Size,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: Colors_pd,
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ],
                                ),
                              )),
                          pw.Expanded(
                              flex: 1,
                              child: pw.Container(
                                height: (ref_invoice.length > 5)
                                    ? 70
                                    : (ref_invoice.length > 1)
                                        ? 50
                                        : 40,
                                decoration: const pw.BoxDecoration(
                                  // color: PdfColors.green100,
                                  border: pw.Border(
                                    right:
                                        pw.BorderSide(color: PdfColors.grey600),
                                    top:
                                        pw.BorderSide(color: PdfColors.grey600),
                                    bottom:
                                        pw.BorderSide(color: PdfColors.grey600),
                                  ),
                                ),
                                child: pw.Row(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Expanded(
                                      flex: 1,
                                      child: pw.Column(
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.center,
                                          children: [
                                            pw.Text(
                                              'เลขที่ใบกำกับ',
                                              textAlign: pw.TextAlign.center,
                                              style: pw.TextStyle(
                                                fontSize: font_Size,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: Colors_pd,
                                              ),
                                            ),
                                            pw.Text(
                                              'Order no.',
                                              textAlign: pw.TextAlign.center,
                                              style: pw.TextStyle(
                                                fontSize: font_Size,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: Colors_pd,
                                              ),
                                            ),
                                            pw.Text(
                                              (numdoctax.toString() == '')
                                                  ? '$numinvoice '
                                                  : '$numdoctax ',
                                              textAlign: pw.TextAlign.center,
                                              style: pw.TextStyle(
                                                fontSize: font_Size,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: Colors_pd,
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ],
                                ),
                              )),
                          (ref_invoice.length == 0 || ref_invoice.length > 1)
                              ? pw.SizedBox()
                              : pw.Expanded(
                                  flex: 1,
                                  child: pw.Container(
                                    height: 40,
                                    decoration: const pw.BoxDecoration(
                                      // color: PdfColors.green100,
                                      border: pw.Border(
                                        right: pw.BorderSide(
                                            color: PdfColors.grey600),
                                        top: pw.BorderSide(
                                            color: PdfColors.grey600),
                                        bottom: pw.BorderSide(
                                            color: PdfColors.grey600),
                                      ),
                                    ),
                                    child: pw.Row(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Expanded(
                                          flex: 1,
                                          child: pw.Column(
                                              mainAxisAlignment:
                                                  pw.MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  pw.CrossAxisAlignment.center,
                                              children: [
                                                pw.Text(
                                                  'อ้างอิงเลขที่',
                                                  textAlign:
                                                      pw.TextAlign.center,
                                                  style: pw.TextStyle(
                                                    fontSize: font_Size,
                                                    font: ttf,
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    color: Colors_pd,
                                                  ),
                                                ),
                                                pw.Text(
                                                  'Refer no.',
                                                  textAlign:
                                                      pw.TextAlign.center,
                                                  style: pw.TextStyle(
                                                    fontSize: font_Size,
                                                    font: ttf,
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    color: Colors_pd,
                                                  ),
                                                ),
                                                pw.Text(
                                                  (ref_invoice[0].toString() ==
                                                          '')
                                                      ? '-'
                                                      : '${ref_invoice[0]}',
                                                  // (ref_invoice == null ||
                                                  //         ref_invoice
                                                  //                 .toString() ==
                                                  //             '')
                                                  //     ? ''
                                                  //     : '${ref_invoice}',
                                                  textAlign:
                                                      pw.TextAlign.center,
                                                  style: pw.TextStyle(
                                                    fontSize: font_Size,
                                                    font: ttf,
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    color: Colors_pd,
                                                  ),
                                                ),
                                              ]),
                                        ),
                                      ],
                                    ),
                                  )),
                        ],
                      )
                    ],
                  )),
            ],
          ),
        ),
        pw.Container(
          height: 35,
          child: pw.Row(
            children: [
              pw.Expanded(
                  flex: 3,
                  child: pw.Container(
                    height: 35,
                    decoration: const pw.BoxDecoration(
                      // color: PdfColors.green100,
                      border: pw.Border(
                        // right: pw.BorderSide(color: PdfColors.grey600),
                        left: pw.BorderSide(color: PdfColors.grey600),
                        bottom: pw.BorderSide(color: PdfColors.grey600),
                      ),
                    ),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(
                              height: 35,
                              decoration: const pw.BoxDecoration(
                                // color: PdfColors.green100,
                                border: pw.Border(
                                  right:
                                      pw.BorderSide(color: PdfColors.grey600),
                                  bottom:
                                      pw.BorderSide(color: PdfColors.grey800),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.center,
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.center,
                                children: [
                                  pw.Text(
                                    'พนักงานผู้ทำสัญญา /Contractor man No.',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                  pw.Text(
                                    (fname == '' || fname == null)
                                        ? '-'
                                        : '$fname',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                              height: 35,
                              decoration: const pw.BoxDecoration(
                                // color: PdfColors.green100,
                                border: pw.Border(
                                  bottom:
                                      pw.BorderSide(color: PdfColors.grey800),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.center,
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.center,
                                children: [
                                  pw.Text(
                                    'ประเภท /Type.',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                  pw.Text(
                                    (type_bills.toString().trim() == '' ||
                                            type_bills == null)
                                        ? 'สัญญา'
                                        : 'ล็อคเสียบ',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                              height: 35,
                              decoration: const pw.BoxDecoration(
                                // color: PdfColors.green100,
                                border: pw.Border(
                                  right:
                                      pw.BorderSide(color: PdfColors.grey600),
                                  left: pw.BorderSide(color: PdfColors.grey600),
                                  bottom:
                                      pw.BorderSide(color: PdfColors.grey600),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.center,
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.center,
                                children: [
                                  pw.Text(
                                    'รหัสลูกค้า /Code',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                  pw.Text(
                                    (Cust_no.toString() == '' ||
                                            Cust_no == null)
                                        ? '-'
                                        : '$Cust_no',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                  )),
              pw.Expanded(
                  flex: 1,
                  child: pw.Container(
                    height: 35,
                    decoration: const pw.BoxDecoration(
                      // color: PdfColors.green100,
                      border: pw.Border(
                        right: pw.BorderSide(color: PdfColors.grey600),
                        // left: pw.BorderSide(color: PdfColors.grey800),
                        bottom: pw.BorderSide(color: PdfColors.grey600),
                      ),
                    ),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                              height: 35,
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.center,
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.center,
                                children: [
                                  pw.Text(
                                    'วันที่รับชำระ /Payment Date',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                  pw.Text(
                                    (dayfinpay.toString() == '' ||
                                            dayfinpay.toString() == 'null' ||
                                            dayfinpay == null)
                                        ? '-'
                                        : '${DateFormat('dd/MM').format(DateTime.parse(dayfinpay!))}/${DateTime.parse('${dayfinpay}').year + 543}',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: Colors_pd,
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        )
      ]));
    }

    pw.Widget tableHeader(double fontSize, pw.Font ttf) {
      // — header ของคอลัมน์ตามเดิม —
      return pw.Container(
        decoration: const pw.BoxDecoration(
          // color: PdfColors.green100,
          border: pw.Border(
            // top: pw.BorderSide(color: PdfColors.grey800),
            bottom: pw.BorderSide(color: PdfColors.grey800),
          ),
        ),
        child: pw.Row(
          children: [
            pw.Container(
              width: 30,
              decoration: const pw.BoxDecoration(
                // color: PdfColors.green100,
                border: pw.Border(
                  left: pw.BorderSide(color: PdfColors.grey600),
                  right: pw.BorderSide(color: PdfColors.grey600),
                  bottom: pw.BorderSide(color: PdfColors.grey600),
                ),
              ),
              height: 30,
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'ลำดับ',
                    maxLines: 1,
                    textAlign: pw.TextAlign.left,
                    style: pw.TextStyle(
                        fontSize: font_Size, font: ttf, color: PdfColors.black),
                  ),
                  pw.Text(
                    'No.',
                    maxLines: 1,
                    textAlign: pw.TextAlign.left,
                    style: pw.TextStyle(
                        fontSize: font_Size, font: ttf, color: PdfColors.black),
                  ),
                ],
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.Container(
                decoration: const pw.BoxDecoration(
                  // color: PdfColors.green100,
                  border: pw.Border(
                    right: pw.BorderSide(color: PdfColors.grey600),
                    // top: pw.BorderSide(color: PdfColors.grey800),
                    bottom: pw.BorderSide(color: PdfColors.grey600),
                  ),
                ),
                height: 30,
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'รหัสสินค้า',
                      maxLines: 1,
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: PdfColors.black),
                    ),
                    pw.Text(
                      'Product Code',
                      maxLines: 1,
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: PdfColors.black),
                    ),
                  ],
                ),
              ),
            ),
            pw.Expanded(
              flex: 4,
              child: pw.Container(
                decoration: const pw.BoxDecoration(
                  // color: PdfColors.green100,
                  border: pw.Border(
                    right: pw.BorderSide(color: PdfColors.grey600),
                    // top: pw.BorderSide(color: PdfColors.grey800),
                    bottom: pw.BorderSide(color: PdfColors.grey600),
                  ),
                ),
                height: 30,
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'รายละเอียด',
                      maxLines: 1,
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: PdfColors.black),
                    ),
                    pw.Text(
                      'Description',
                      maxLines: 1,
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: PdfColors.black),
                    ),
                  ],
                ),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                decoration: const pw.BoxDecoration(
                  // color: PdfColors.green100,
                  border: pw.Border(
                    right: pw.BorderSide(color: PdfColors.grey600),
                    // top: pw.BorderSide(color: PdfColors.grey800),
                    bottom: pw.BorderSide(color: PdfColors.grey600),
                  ),
                ),
                height: 30,
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'จำนวน',
                      maxLines: 1,
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: PdfColors.black),
                    ),
                    pw.Text(
                      'Quantity',
                      maxLines: 1,
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: PdfColors.black),
                    ),
                  ],
                ),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                decoration: const pw.BoxDecoration(
                  // color: PdfColors.green100,
                  border: pw.Border(
                    right: pw.BorderSide(color: PdfColors.grey600),
                    top: pw.BorderSide(color: PdfColors.grey600),
                    bottom: pw.BorderSide(color: PdfColors.grey600),
                  ),
                ),
                height: 30,
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'หน่วยละ',
                      maxLines: 1,
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: PdfColors.black),
                    ),
                    pw.Text(
                      'Unit',
                      maxLines: 1,
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: PdfColors.black),
                    ),
                  ],
                ),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                decoration: const pw.BoxDecoration(
                  // color: PdfColors.green100,
                  border: pw.Border(
                    right: pw.BorderSide(color: PdfColors.grey600),
                    top: pw.BorderSide(color: PdfColors.grey600),
                    bottom: pw.BorderSide(color: PdfColors.grey600),
                  ),
                ),
                height: 30,
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'ราคา',
                      maxLines: 1,
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: PdfColors.black),
                    ),
                    pw.Text(
                      'Price',
                      maxLines: 1,
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: PdfColors.black),
                    ),
                  ],
                ),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                decoration: const pw.BoxDecoration(
                  // color: PdfColors.green100,
                  border: pw.Border(
                    right: pw.BorderSide(color: PdfColors.grey600),
                    top: pw.BorderSide(color: PdfColors.grey600),
                    bottom: pw.BorderSide(color: PdfColors.grey600),
                  ),
                ),
                height: 30,
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'ส่วนลด',
                      maxLines: 1,
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: PdfColors.black),
                    ),
                    pw.Text(
                      'Dis',
                      maxLines: 1,
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: PdfColors.black),
                    ),
                  ],
                ),
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.Container(
                decoration: const pw.BoxDecoration(
                  // color: PdfColors.green100,
                  border: pw.Border(
                    // left: pw.BorderSide(color: PdfColors.grey800),
                    right: pw.BorderSide(color: PdfColors.grey600),
                    top: pw.BorderSide(color: PdfColors.grey600),
                    bottom: pw.BorderSide(color: PdfColors.grey600),
                  ),
                ),
                height: 30,
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'จำนวนเงิน',
                      maxLines: 1,
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: PdfColors.black),
                    ),
                    pw.Text(
                      'Amount',
                      maxLines: 1,
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: PdfColors.black),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    pw.Widget itemRow(
        TransReBillHistory, int index, double fontSize, pw.Font ttf) {
      final TransReBill = TransReBillHistory[index];

      return pw.Row(
        children: [
          pw.Container(
            decoration: const pw.BoxDecoration(
              // color: PdfColors.white,
              border: pw.Border(
                left: pw.BorderSide(color: PdfColors.grey600),
              ),
            ),
            width: 30,
            padding: const pw.EdgeInsets.all(2.0),
            child: pw.Align(
              alignment: pw.Alignment.center,
              child: pw.Text(
                '${index + 1}',
                maxLines: 2,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                    fontSize: font_Size, font: ttf, color: PdfColors.grey800),
              ),
            ),
          ),
          buildCell(
            text: (TransReBill.zn != null)
                ? (TransReBill.zn!.split('_')[0].length <= 4)
                    ? '${TransReBill.refno}/0${TransReBill.zn!.split('_')[0]}'
                    : '${TransReBill.refno}/${TransReBill.zn!.split('_')[0]}'
                : (TransReBill.fine.toString() == '1.00' &&
                        TransReBill.refno.toString().trim() == 'null')
                    ? (TransReBill.zn!.split('_')[0].length <= 4)
                        ? '-/0${TransReBill.zn!.split('_')[0]}'
                        : '-/${TransReBill.zn!.split('_')[0]}'
                    : '${TransReBill.refno}',
            // '${TransReBill.refno}',
            flex: 2,
            alignment: pw.Alignment.centerLeft,
            textAlign: pw.TextAlign.center,
          ),
          buildCell(
            text: (TransReBill.unitser.toString() == '6')
                ? '${TransReBill.expname} [ หน่วยที่ใช้ไป ${TransReBill.ovalue}-${TransReBill.nvalue} ]' //descr
                : '${TransReBill.expname}',
            flex: 4,
            alignment: pw.Alignment.centerLeft,
            textAlign: pw.TextAlign.left,
          ),
          buildCell(
            text: getFormattedText(TransReBill.qty),
            flex: 1,
            alignment: pw.Alignment.centerRight,
            textAlign: pw.TextAlign.right,
          ),
          // buildCell(
          //   text: getFormattedText(TransReBill.pri),
          //   flex: 1,
          //   alignment: pw.Alignment.centerRight,
          //   textAlign: pw.TextAlign.right,
          // ),
          buildCell(
            text: (TransReBill.ele_ty.toString() != '0' &&
                    TransReBill.ele_ty != null)
                ? 'อัตราพิเศษ'
                : (TransReBill.exp_dtype.toString() == 'KU')
                    ? getFormattedText('${TransReBill.pri}')
                    : '-',
            flex: 1,
            alignment: pw.Alignment.centerRight,
            textAlign: pw.TextAlign.right,
          ),
          buildCell(
            text: (double.tryParse(TransReBill.pvat_original.toString()) != 0)
                ? getFormattedText('${TransReBill.pvat_original}')
                : (TransReBill.exp_dtype.toString() == 'KU')
                    ? getFormattedText('${TransReBill.pvat}')
                    : getFormattedText('${TransReBill.pvat}'),
            flex: 1,
            alignment: pw.Alignment.centerRight,
            textAlign: pw.TextAlign.right,
          ),
          buildCell(
            text: getFormattedText('${TransReBill.dis_list}'),
            flex: 1,
            alignment: pw.Alignment.centerRight,
            textAlign: pw.TextAlign.right,
          ),
          buildCell(
            text: nFormat.format(
                (double.tryParse(TransReBill.pvat ?? '0') ?? 0) +
                    (double.tryParse(TransReBill.vat ?? '0') ?? 0)),
            flex: 2,
            alignment: pw.Alignment.centerRight,
            textAlign: pw.TextAlign.right,
          ),
        ],
      );
    }

    pw.Widget tablefool(double fontSize, pw.Font ttf) {
      return pw.Column(
        children: [
          pw.Row(
            children: [
              pw.Container(
                  // width: 130,
                  width: 121.5,
                  height: font_Size * 1.7,
                  padding: const pw.EdgeInsets.all(2.0),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    border: const pw.Border(
                      top: pw.BorderSide(color: PdfColors.grey600),
                    ),
                  )),
              pw.Expanded(
                flex: 1,
                child: pw.Container(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.white,
                    border: const pw.Border(
                      top: pw.BorderSide(color: PdfColors.grey600),
                      left: pw.BorderSide(color: PdfColors.grey600),
                      bottom: pw.BorderSide(color: PdfColors.grey600),
                      // right: pw.BorderSide(color: PdfColors.grey600),
                    ),
                  ),
                  padding: const pw.EdgeInsets.all(2.0),
                  child: pw.Text(
                    'ส่วนลด',
                    style: pw.TextStyle(
                        fontSize: font_Size,
                        fontWeight: pw.FontWeight.bold,
                        font: ttf,
                        color: PdfColors.grey800),
                  ),
                ),
              ),
              pw.Expanded(
                flex: 1,
                child: pw.Container(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.white,
                    border: const pw.Border(
                      // left: pw.BorderSide(color: PdfColors.grey600),
                      top: pw.BorderSide(color: PdfColors.grey600),
                      bottom: pw.BorderSide(color: PdfColors.grey600),
                      right: pw.BorderSide(color: PdfColors.grey600),
                    ),
                  ),
                  padding: const pw.EdgeInsets.all(2.0),
                  child: pw.Text(
                    '${nFormat.format(totalDis)}',
                    // '${nFormat.format(double.parse(sum_net_non_pvat.toString()) + double.parse(sum_net_amount_pvat.toString()) - double.parse(DisC.toString()))}', // 1+2-3
                    // '${nFormat.format(double.parse(DisC.toString()))}', //
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                        fontSize: font_Size,
                        fontWeight: pw.FontWeight.bold,
                        font: ttf,
                        color: PdfColors.grey800),
                  ),
                ),
              ),
            ],
          ),

          pw.Container(
            decoration: const pw.BoxDecoration(
              // color: PdfColors.white,
              border: const pw.Border(
                  // top: pw.BorderSide(color: PdfColors.grey600),
                  // left: pw.BorderSide(color: PdfColors.grey600),
                  ),
            ),
            // padding: const pw.EdgeInsets.fromLTRB(0, 4, 0, 0),
            alignment: pw.Alignment.centerRight,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (Con_remark.toString() != '' && Con_remark != null)
                  pw.Container(
                    padding: const pw.EdgeInsets.all(4.0),
                    child: pw.Text(
                      '# หมายเหตุ : $Con_remark',
                      style: pw.TextStyle(
                          fontSize: font_Size,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                          color: PdfColors.grey800),
                    ),
                  ),
                pw.Container(width: 30),
                pw.Spacer(flex: 7),
                pw.Expanded(
                  flex: 5,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 3,
                            child: pw.Container(
                              decoration: const pw.BoxDecoration(
                                color: PdfColors.white,
                                border: const pw.Border(
                                  top: pw.BorderSide(color: PdfColors.grey600),
                                  left: pw.BorderSide(color: PdfColors.grey600),
                                  bottom:
                                      pw.BorderSide(color: PdfColors.grey600),
                                  right:
                                      pw.BorderSide(color: PdfColors.grey600),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Text(
                                'รวมราคาสินค้า ไม่มี/ยกเว้นภาษี',
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800),
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Container(
                              decoration: const pw.BoxDecoration(
                                color: PdfColors.white,
                                border: const pw.Border(
                                  left: pw.BorderSide(color: PdfColors.grey600),
                                  top: pw.BorderSide(color: PdfColors.grey600),
                                  right:
                                      pw.BorderSide(color: PdfColors.grey600),
                                  bottom:
                                      pw.BorderSide(color: PdfColors.grey600),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Text(
                                // '${nFormat.format(sum_Nonvat == null ? 0.00 : double.parse(sum_Nonvat.toString()))}',
                                // '${roundToTwoDecimals('${double.parse(sum_pvat.toString())}')}',
                                // (round_p.toString() == '1')
                                //     ? (amt_up == null)
                                //         ? '0.00'
                                //         : '${nFormat.format(double.parse(amt_up.toString()))}'
                                //     : '${nFormat.format(double.parse(sum_pvat.toString()))}',
                                '${nFormat.format(net_non_pvat)}',
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800),
                              ),
                            ),
                          ),
                        ],
                      ),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 3,
                            child: pw.Container(
                              decoration: const pw.BoxDecoration(
                                color: PdfColors.white,
                                border: const pw.Border(
                                  top: pw.BorderSide(color: PdfColors.grey600),
                                  left: pw.BorderSide(color: PdfColors.grey600),
                                  bottom:
                                      pw.BorderSide(color: PdfColors.grey600),
                                  right:
                                      pw.BorderSide(color: PdfColors.grey600),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Text(
                                'จำนวนเงินรวมทั้งสิ้น',
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800),
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Container(
                              decoration: const pw.BoxDecoration(
                                color: PdfColors.white,
                                border: const pw.Border(
                                  left: pw.BorderSide(color: PdfColors.grey600),
                                  top: pw.BorderSide(color: PdfColors.grey600),
                                  bottom:
                                      pw.BorderSide(color: PdfColors.grey600),
                                  right:
                                      pw.BorderSide(color: PdfColors.grey600),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Text(
                                // '${nFormat.format(Total == null ? 0.00 : double.parse(Total.toString()))}',
                                // '${nFormat.format(((totalPvat + totalVat) - totalWht) + totalFee)}',
                                // '${nFormat.format(((totalPvat + totalVat) - totalWht) + totalFee)}',
                                '${nFormat.format(totalPvat + totalVat)}',
                                // ('${TransReBill.total}'),

                                // '${nFormat.format((double.parse(Total.toString()) + double.parse(sum_fee.toString())) - (double.parse(dis_sum_Matjum.toString()) + double.parse(dis_sum_Pakan.toString())))}',
                                // (nFormat.format(double.parse(
                                //             dis_sum_Matjum
                                //                 .toString())) !=
                                //         '0.00')
                                //     ? '${nFormat.format(double.parse(dis_sum_Matjum.toString()) - double.parse(sum_addvat_choice.toString()) * 1.07)}' //dis_sum_Matjum
                                //     : (nFormat.format(double.parse(
                                //                 dis_sum_Pakan
                                //                     .toString())) !=
                                //             '0.00')
                                //         ? '${nFormat.format(double.parse(dis_sum_Pakan.toString()) - double.parse(sum_addvat_choice.toString()) * 1.07)}'
                                //         : '${nFormat.format((double.parse(sum_addvat_choice.toString()) - double.parse(sum_disamt.toString())) * 1.07)}',
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800),
                              ),
                            ),
                          ),
                        ],
                      ),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 3,
                            child: pw.Container(
                              decoration: const pw.BoxDecoration(
                                color: PdfColors.white,
                                border: const pw.Border(
                                  top: pw.BorderSide(color: PdfColors.grey600),
                                  left: pw.BorderSide(color: PdfColors.grey600),
                                  bottom:
                                      pw.BorderSide(color: PdfColors.grey600),
                                  right:
                                      pw.BorderSide(color: PdfColors.grey600),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Text(
                                'รวมราคาสินค้าคำนวณภาษีมูลค่าเพิ่ม',
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800),
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Container(
                              decoration: const pw.BoxDecoration(
                                color: PdfColors.white,
                                border: const pw.Border(
                                  left: pw.BorderSide(color: PdfColors.grey600),
                                  top: pw.BorderSide(color: PdfColors.grey600),
                                  right:
                                      pw.BorderSide(color: PdfColors.grey600),
                                  bottom:
                                      pw.BorderSide(color: PdfColors.grey600),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Text(
                                // '${nFormat.format(((double.parse(Total.toString()) * 100 / 107) + double.parse(sum_fee.toString())) - (double.parse(dis_sum_Matjum.toString()) + double.parse(dis_sum_Pakan.toString())))}',

                                // '${nFormat.format(double.parse(Sum_SubTotal.toString()))}',
                                // '${nFormat.format(double.parse(sum_addvat.toString()))}',
                                // (nFormat.format(double.parse(
                                //             sum_addvat.toString())) !=
                                //         '0.00')
                                //     ? '${nFormat.format(((double.parse(Total.toString()) * 100 / 107) + double.parse(sum_fee.toString())) - (double.parse(dis_sum_Matjum.toString()) + double.parse(dis_sum_Pakan.toString())))}'
                                //     : '${nFormat.format(double.parse(sum_addvat.toString()))}',

                                // '${nFormat.format(net_amount_pvat)}',
                                '${nFormat.format(net_amount_pvat)}',

                                ///
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800),
                              ),
                            ),
                          ),
                        ],
                      ),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 3,
                            child: pw.Container(
                              decoration: const pw.BoxDecoration(
                                color: PdfColors.white,
                                border: const pw.Border(
                                  top: pw.BorderSide(color: PdfColors.grey600),
                                  left: pw.BorderSide(color: PdfColors.grey600),
                                  bottom:
                                      pw.BorderSide(color: PdfColors.grey600),
                                  right:
                                      pw.BorderSide(color: PdfColors.grey600),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Text(
                                'ภาษีมูลค่าเพิ่ม 7%/ Vat',
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800),
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Container(
                              decoration: const pw.BoxDecoration(
                                color: PdfColors.white,
                                border: const pw.Border(
                                  left: pw.BorderSide(color: PdfColors.grey600),
                                  top: pw.BorderSide(color: PdfColors.grey600),
                                  right:
                                      pw.BorderSide(color: PdfColors.grey600),
                                  bottom:
                                      pw.BorderSide(color: PdfColors.grey600),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Text(
                                // (round_p.toString() == '1')
                                //     ? (vat_up == null
                                //         ? '0.00'
                                //         : '${nFormat.format(double.parse(vat_up.toString()))}')
                                // : '${nFormat.format(double.parse(sum_vat.toString()))}',

                                ///
                                //  : '${nFormat.format(double.parse(Total.toString()) * 7 / 100)}',
                                // : '${nFormat.format((((double.parse(Total.toString()) * 100 / 107) * 7 / 100) + double.parse(sum_fee.toString())) - (double.parse(dis_sum_Matjum.toString()) + double.parse(dis_sum_Pakan.toString())))}',

                                // : '${nFormat.format((double.parse(roundToTwoDecimals('${double.parse(sum_pvat.toString())}')) * 7) / 100)}', //pvat

                                // // : '${nFormat.format((double.parse(sum_addvat_choice.toString()) * 7) / 100)}',
                                // (nFormat.format(double.parse(
                                //             sum_addvat.toString())) !=
                                //         '0.00')
                                //     ? '${nFormat.format((((double.parse(Total.toString()) * 100 / 107) * 7 / 100) + double.parse(sum_fee.toString())) - (double.parse(dis_sum_Matjum.toString()) + double.parse(dis_sum_Pakan.toString())))}'
                                //     : '${nFormat.format(double.parse(sum_addvat.toString()))}',
                                '${nFormat.format(totalVat)}',
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800),
                              ),
                            ),
                          ),
                        ],
                      ),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 3,
                            child: pw.Container(
                              decoration: const pw.BoxDecoration(
                                color: PdfColors.white,
                                border: const pw.Border(
                                  top: pw.BorderSide(color: PdfColors.grey600),
                                  left: pw.BorderSide(color: PdfColors.grey600),
                                  bottom:
                                      pw.BorderSide(color: PdfColors.grey600),
                                  right:
                                      pw.BorderSide(color: PdfColors.grey600),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Text(
                                'หัก ณ ที่จ่าย / Withholding ',
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800),
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Container(
                              decoration: const pw.BoxDecoration(
                                color: PdfColors.white,
                                border: const pw.Border(
                                  left: pw.BorderSide(color: PdfColors.grey600),
                                  top: pw.BorderSide(color: PdfColors.grey600),
                                  bottom:
                                      pw.BorderSide(color: PdfColors.grey600),
                                  right:
                                      pw.BorderSide(color: PdfColors.grey600),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Text(
                                // '${nFormat.format(double.parse(sum_wht.toString()))}',
                                '${nFormat.format(totalWht)}',
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800),
                              ),
                            ),
                          ),
                        ],
                      ),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 3,
                            child: pw.Container(
                              decoration: const pw.BoxDecoration(
                                color: PdfColors.white,
                                border: const pw.Border(
                                  top: pw.BorderSide(color: PdfColors.grey600),
                                  left: pw.BorderSide(color: PdfColors.grey600),
                                  bottom:
                                      pw.BorderSide(color: PdfColors.grey600),
                                  right:
                                      pw.BorderSide(color: PdfColors.grey600),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Text(
                                'ค่าธรรมเนียม / Fees',
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800),
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Container(
                              decoration: const pw.BoxDecoration(
                                color: PdfColors.white,
                                border: const pw.Border(
                                  left: pw.BorderSide(color: PdfColors.grey600),
                                  top: pw.BorderSide(color: PdfColors.grey600),
                                  bottom:
                                      pw.BorderSide(color: PdfColors.grey600),
                                  right:
                                      pw.BorderSide(color: PdfColors.grey600),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Text(
                                // '${nFormat.format(double.parse(sum_fee.toString()))}',
                                '${nFormat.format(totalFee)}',
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (afterDiscount != '0.00')
                        pw.Row(
                          children: [
                            pw.Expanded(
                              flex: 3,
                              child: pw.Container(
                                decoration: const pw.BoxDecoration(
                                  color: PdfColors.white,
                                  border: const pw.Border(
                                    top:
                                        pw.BorderSide(color: PdfColors.grey600),
                                    left:
                                        pw.BorderSide(color: PdfColors.grey600),
                                    bottom:
                                        pw.BorderSide(color: PdfColors.grey600),
                                    right:
                                        pw.BorderSide(color: PdfColors.grey600),
                                  ),
                                ),
                                padding: const pw.EdgeInsets.all(2.0),
                                child: pw.Text(
                                  'หักเงินมัดจำ',
                                  style: pw.TextStyle(
                                      fontSize: font_Size,
                                      fontWeight: pw.FontWeight.bold,
                                      font: ttf,
                                      color: PdfColors.grey800),
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 2,
                              child: pw.Container(
                                decoration: const pw.BoxDecoration(
                                  color: PdfColors.white,
                                  border: const pw.Border(
                                    left:
                                        pw.BorderSide(color: PdfColors.grey600),
                                    top:
                                        pw.BorderSide(color: PdfColors.grey600),
                                    bottom:
                                        pw.BorderSide(color: PdfColors.grey600),
                                    right:
                                        pw.BorderSide(color: PdfColors.grey600),
                                  ),
                                ),
                                padding: const pw.EdgeInsets.all(2.0),
                                child: pw.Text(
                                  // (nFormat.format(double.parse(
                                  //             dis_sum_Matjum.toString())) !=
                                  //         '0.00')
                                  //     ? '${nFormat.format(double.parse(dis_sum_Matjum.toString()) - double.parse(sum_disamt.toString()))}' //dis_sum_Matjum
                                  //     : (nFormat.format(double.parse(
                                  //                 dis_sum_Pakan.toString())) !=
                                  //             '0.00')
                                  //         ? '${nFormat.format(double.parse(dis_sum_Pakan.toString()) - double.parse(sum_disamt.toString()))}'
                                  //         : '${nFormat.format(double.parse(net_amount_pvat.toString()) - double.parse(sum_disamt.toString()))}',
                                  afterDiscount,
                                  textAlign: pw.TextAlign.right,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 3,
                            child: pw.Container(
                              decoration: const pw.BoxDecoration(
                                color: PdfColors.white,
                                border: const pw.Border(
                                  top: pw.BorderSide(color: PdfColors.grey600),
                                  left: pw.BorderSide(color: PdfColors.grey600),
                                  bottom:
                                      pw.BorderSide(color: PdfColors.grey600),
                                  right:
                                      pw.BorderSide(color: PdfColors.grey600),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Text(
                                'ยอดชำระ / Payment Amount',
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800),
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Container(
                              decoration: const pw.BoxDecoration(
                                color: PdfColors.white,
                                border: const pw.Border(
                                  left: pw.BorderSide(color: PdfColors.grey600),
                                  top: pw.BorderSide(color: PdfColors.grey600),
                                  bottom:
                                      pw.BorderSide(color: PdfColors.grey600),
                                  right:
                                      pw.BorderSide(color: PdfColors.grey600),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Text(
                                '${nFormat.format(totalBill)}',
                                // '${nFormat.format((double.parse(Total.toString()) + double.parse(sum_fee.toString())) - (double.parse(dis_sum_Matjum.toString()) + double.parse(dis_sum_Pakan.toString())))}',
                                // '${nFormat.format(double.parse(Total.toString()) - double.parse(dis_sum_Matjum.toString()) - double.parse(dis_sum_Pakan.toString()))}',
                                // (nFormat.format(double.parse(
                                //             dis_sum_Matjum
                                //                 .toString())) !=
                                //         '0.00')
                                //     ? '${nFormat.format(double.parse(dis_sum_Matjum.toString()) + double.parse(dis_sum_Matjum.toString()) * 1.07)}'
                                //     : (nFormat.format(double.parse(
                                //                 dis_sum_Pakan
                                //                     .toString())) !=
                                //             '0.00')
                                //         ? '${nFormat.format(double.parse(dis_sum_Pakan.toString()) + double.parse(dis_sum_Pakan.toString()) * 1.07)}'
                                //         : '${nFormat.format((double.parse(sum_Nonvat_choice.toString()) + double.parse(sum_addvat_choice.toString()) - double.parse(sum_disamt.toString())) * 1.07)}',
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // pw.SizedBox(height: 2 * PdfPageFormat.mm),
          pw.Container(
              height: 25,
              decoration: const pw.BoxDecoration(
                // color: PdfColors.green100,
                border: pw.Border(
                  top: pw.BorderSide(color: PdfColors.grey600),
                  bottom: pw.BorderSide(color: PdfColors.grey600),
                ),
              ),
              alignment: pw.Alignment.centerRight,
              child: pw.Center(
                child: pw.Row(
                  children: [
                    pw.SizedBox(width: 2 * PdfPageFormat.mm),
                    pw.Text(
                      'ตัวอักษร ',
                      style: pw.TextStyle(
                          fontSize: font_Size,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                          fontStyle: pw.FontStyle.italic,
                          color: PdfColors.grey800),
                    ),
                    pw.Expanded(
                      flex: 4,
                      child: pw.Text(
                        '(~${convertToThaiBaht(totalBill)}~)',

                        /// "${nFormat2.format(double.parse(Total.toString()))}",
                        ///
                        ///       '(~${convertToThaiBaht(double.parse(Total.toString()) - double.parse(dis_sum_Matjum.toString()))}~)',
                        // '(~${convertToThaiBaht(double.parse(Total.toString()) + double.parse(sum_fee.toString()))}~)',
                        // (nFormat.format(double.parse(
                        //             dis_sum_Matjum.toString())) !=
                        //         '0.00')
                        //     ? '(~${convertToThaiBaht(double.parse(dis_sum_Matjum.toString()) + double.parse(dis_sum_Matjum.toString()) * 1.07)}~)'
                        //     : (nFormat.format(double.parse(
                        //                 dis_sum_Pakan.toString())) !=
                        //             '0.00')
                        //         ? '(~${convertToThaiBaht(double.parse(dis_sum_Pakan.toString()) + double.parse(dis_sum_Pakan.toString()) * 1.07)}~)'
                        //         : '(~${convertToThaiBaht((double.parse(sum_Nonvat_choice.toString()) + double.parse(sum_addvat_choice.toString()) - double.parse(sum_disamt.toString())) * 1.07)}~)',
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                          fontStyle: pw.FontStyle.italic,
                          // decoration:
                          //     pw.TextDecoration.lineThrough,
                          color: PdfColors.grey800,
                        ),
                      ),
                    ),
                    // pw.Spacer(flex: 6),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            children: [
                              pw.Expanded(
                                flex: 2,
                                child: pw.Text(
                                  'ยอดรวมสุทธิ',
                                  textAlign: pw.TextAlign.left,
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      font: ttf,
                                      fontSize: font_Size,
                                      color: PdfColors.grey800),
                                ),
                              ),
                              pw.Text(
                                // '${nFormat.format(double.parse(Total.toString()) + double.parse(sum_fee.toString()))}',
                                '${nFormat.format(totalBill)}',
                                // (nFormat.format(double.parse(
                                //             dis_sum_Matjum
                                //                 .toString())) !=
                                //         '0.00')
                                //     ? '${nFormat.format(double.parse(dis_sum_Matjum.toString()) + double.parse(dis_sum_Matjum.toString()) * 1.07)}'
                                //     : (nFormat.format(double.parse(
                                //                 dis_sum_Pakan
                                //                     .toString())) !=
                                //             '0.00')
                                //         ? '${nFormat.format(double.parse(dis_sum_Pakan.toString()) + double.parse(dis_sum_Pakan.toString()) * 1.07)}'
                                //         : '${nFormat.format((double.parse(sum_Nonvat_choice.toString()) + double.parse(sum_addvat_choice.toString()) - double.parse(sum_disamt.toString())) * 1.07)}',
                                // '${Total}',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    fontSize: font_Size,
                                    color: PdfColors.grey800),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      );
    }

    // for (int page = 0;
    //     page < (TransReBillHistory.length / 100).ceil();
    //     page++) { TA68-07-004620
    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme, // ✅ BG อยู่ที่นี่
        maxPages: 50,
        // header: (ctx) => Header(ctx),
        header: (ctx) {
          return pw.Column(
            children: [
              Header(ctx),
              // ✅ ส่วนหัว: ถ้าต้องให้อยู่หน้าเดียว และ “ขนาดไม่เกินหน้า”
              // pw.KeepTogether(headerBlock(font_Size, ttf, Colors_pd)),
              pw.Padding(
                padding: pw.EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: headerBlock(font_Size, ttf, Colors_pd),
              ),

              // // ✅ หัวตาราง
              pw.Padding(
                padding: pw.EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: tableHeader(font_Size, ttf),
              ),
              // ✅ รายการแตกหน้าได้เอง
            ],
          );
        },
        build: (ctx) => [
          pw.Padding(
            padding: pw.EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: pw.ListView.builder(
              itemCount: TransReBillHistory.length,
              itemBuilder: (c, i) => itemRow(
                TransReBillHistory,
                i,
                font_Size,
                ttf,
              ),
            ),
          ),

          // ✅ บล็อคสรุปด้านล่าง แนะนำ KeepTogether (แต่ต้องไม่ใหญ่เกินหน้า)
          pw.Padding(
            padding: pw.EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: tablefool(font_Size, ttf),
          ),
          // pw.KeepTogether(
          //   totalsBlock(
          //       /* ใช้กลุ่ม pw.Row/pw.Container ของคุณด้านล่างนี้ได้เลย แต่เลิก fix height */),
          // ),

          // ช่องว่างเล็ก ๆ ปิดท้ายถ้าจำเป็น
          pw.SizedBox(height: 5 * PdfPageFormat.mm),
        ],
        footer: (context) {
          return pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Padding(
                padding: pw.EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: pw.Stack(children: [
                  pw.Positioned(
                      top: 4,
                      left: 0,
                      child: pw.Container(
                        width: 300,
                        height: 300,
                        decoration: pw.BoxDecoration(
                          image: pw.DecorationImage(
                            image: pw.MemoryImage(
                              imageBG,
                            ),
                            fit: pw.BoxFit.cover,
                          ),
                          // border:
                          //     pw.Border.all(color: PdfColors.grey, width: 1),
                        ),
                      )),
                  pw.Positioned(
                      bottom: 4,
                      right: 0,
                      child: pw.Container(
                        width: 200,
                        height: 30,
                        decoration: pw.BoxDecoration(
                          image: pw.DecorationImage(
                            image: pw.MemoryImage(
                              imageBG,
                            ),
                            fit: pw.BoxFit.cover,
                          ),
                          // border:
                          //     pw.Border.all(color: PdfColors.grey, width: 1),
                        ),
                      )),
                  pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey, width: 1),
                      ),
                      padding: pw.EdgeInsets.fromLTRB(2, 4, 2, 4),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                              flex: 2,
                              child: pw.Column(
                                  mainAxisAlignment: pw.MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      'หมายเหตุ : ',
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                        fontSize: font_Size,
                                        font: ttf,
                                        fontWeight: pw.FontWeight.bold,
                                        color: Colors_pd,
                                      ),
                                    ),
                                    pw.Text(
                                      (hasNonCashTransaction)
                                          ? '( / ) 1. เงินโอน, QR Code, Mobile Banking '
                                          : '(   ) 1. เงินโอน, QR Code, Mobile Banking ',
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                        fontSize: font_Size,
                                        font: ttf,
                                        fontWeight: pw.FontWeight.bold,
                                        color: Colors_pd,
                                      ),
                                    ),
                                    pw.Text(
                                      (hasNonCashTransaction)
                                          ? '      บัญชี ${finnancetransModels.where((model) => model.dtype == 'KP' && model.ptser != null && model.ptser != '1').map((model) => model.bank).join(', ')} เลขที่ ${finnancetransModels.where((model) => model.dtype == 'KP' && model.ptser != null && model.ptser != '1').map((model) => model.bno).join(', ')} [ ${finnancetransModels.where((model) => model.dtype == 'KP' && model.ptser != null && model.ptser != '1').map((model) => (model.ptname.toString() == 'Online Payment' ? 'PromptPay QR' : model.ptname == 'เงินโอน' ? 'เลขบัญชี' : model.ptname == 'Beam Checkout' ? 'Beam Checkout' : model.ptname == 'Online Standard QR' ? 'Online Standard QR' : '${model.ptname}')).join(', ')} ]'
                                          : '      บัญชี...................................เลขที่...................................',
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                        fontSize: font_Size,
                                        font: ttf,
                                        fontWeight: pw.FontWeight.bold,
                                        color: Colors_pd,
                                      ),
                                    ),
                                    if (hasNonCashTransaction8)
                                      pw.Text(
                                        hasNonCashTransaction7
                                            ? '      ( Ref1. ${finnancetransModels.where((model) => model.dtype == 'KP' && model.ptser != null && model.ptser != '1').map((model) => model.inv.replaceAll('-', '')).join(', ')} Ref2. ${DateFormat('ddMM').format(DateTime.parse(dayfinpay!))}${DateTime.parse('${dayfinpay}').year + 543} )'
                                            : '      ( Ref1. ${finnancetransModels.where((model) => model.dtype == 'KP' && model.ptser != null && model.ptser != '1').map((model) => model.ref1).join(', ')} Ref2. ${DateFormat('ddMM').format(DateTime.parse(dayfinpay!))}${DateTime.parse('${dayfinpay}').year + 543} )',
                                        textAlign: pw.TextAlign.left,
                                        style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: Colors_pd,
                                        ),
                                      ),
                                    pw.Row(
                                      // mainAxisAlignment:
                                      //     pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Expanded(
                                          flex: 1,
                                          child: pw.Text(
                                            (hasNonCashTransaction1)
                                                ? '( / ) 2. เงินสด'
                                                : '(   ) 2. เงินสด',
                                            textAlign: pw.TextAlign.left,
                                            style: pw.TextStyle(
                                              fontSize: font_Size,
                                              font: ttf,
                                              fontWeight: pw.FontWeight.bold,
                                              color: Colors_pd,
                                            ),
                                          ),
                                        ),
                                        pw.Expanded(
                                          flex: 3,
                                          child: pw.Text(
                                            (hasNonCashTransaction ||
                                                    hasNonCashTransaction1)
                                                ? '(   ) 3. อื่นๆ.............................'
                                                : '( / ) 3. อื่นๆ ${finnancetransModels.where((model) => model.ptser != '6' || model.ptser != '5' || model.ptser != '2' || model.ptser != '1' && model.dtype == 'KP').map((model) => model.bank).join(', ')}',
                                            textAlign: pw.TextAlign.left,
                                            style: pw.TextStyle(
                                              fontSize: font_Size,
                                              font: ttf,
                                              fontWeight: pw.FontWeight.bold,
                                              color: Colors_pd,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ])),
                          pw.Expanded(
                              flex: 1,
                              child: pw.Column(
                                  mainAxisAlignment: pw.MainAxisAlignment.start,
                                  // crossAxisAlignment: pw.CrossAxisAlignment.center,
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
                                      padding: const pw.EdgeInsets.fromLTRB(
                                          4, 0, 4, 0),
                                      child: pw.Row(
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.end,
                                        // mainAxisAlignment:
                                        //     pw.MainAxisAlignment.spaceBetween,
                                        children: [
                                          pw.Expanded(
                                            flex: 1,
                                            child: pw.Text(
                                              'ลงชื่อ : ',
                                              textAlign: pw.TextAlign.left,
                                              style: pw.TextStyle(
                                                fontSize: font_Size,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: Colors_pd,
                                              ),
                                            ),
                                          ),
                                          pw.Expanded(
                                            flex: 2,
                                            child: (imageBytes_manager.isEmpty)
                                                ? pw.Container(
                                                    // width: 120,
                                                    decoration:
                                                        const pw.BoxDecoration(
                                                      // color: PdfColors.green100,
                                                      border: pw.Border(
                                                        bottom: pw.BorderSide(
                                                            width: 0.5,
                                                            color: PdfColors
                                                                .grey600),
                                                      ),
                                                    ),
                                                    padding:
                                                        const pw.EdgeInsets.all(
                                                            8.0),
                                                    height: 30,
                                                  )
                                                : pw.Container(
                                                    // width: 120,
                                                    decoration:
                                                        const pw.BoxDecoration(
                                                      // color: PdfColors.green100,
                                                      border: pw.Border(
                                                        bottom: pw.BorderSide(
                                                            width: 0.5,
                                                            color: PdfColors
                                                                .grey600),
                                                      ),
                                                    ),
                                                    padding:
                                                        const pw.EdgeInsets.all(
                                                            8.0),
                                                    child: pw.Center(
                                                      child: pw.Image(
                                                        pw.MemoryImage(
                                                            imageBytes_manager),
                                                        height: 20,
                                                        width: 100,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                          pw.Expanded(
                                            flex: 2,
                                            child: pw.Text(
                                              ' เจ้าหน้าที่/พนักงาน',
                                              textAlign: pw.TextAlign.left,
                                              style: pw.TextStyle(
                                                fontSize: font_Size,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: Colors_pd,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    pw.SizedBox(
                                      height: 3,
                                    ),
                                    pw.Container(
                                      width: 200,
                                      // decoration: const pw.BoxDecoration(
                                      //   // color: PdfColors.green100,
                                      //   border: pw.Border(
                                      //     bottom: pw.BorderSide(
                                      //         width: 0.5, color: PdfColors.grey600),
                                      //   ),
                                      // ),
                                      padding: const pw.EdgeInsets.fromLTRB(
                                          4, 0, 4, 0),
                                      child: pw.Row(
                                        // mainAxisAlignment:
                                        //     pw.MainAxisAlignment.spaceBetween,
                                        children: [
                                          pw.Expanded(
                                            flex: 1,
                                            child: pw.Text(
                                              'คุณ : ',
                                              textAlign: pw.TextAlign.left,
                                              style: pw.TextStyle(
                                                fontSize: font_Size,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: Colors_pd,
                                              ),
                                            ),
                                          ),
                                          pw.Expanded(
                                            flex: 2,
                                            child: pw.Align(
                                              alignment: pw.Alignment.center,
                                              child: pw.Text(
                                                '(${licence_name1})',
                                                textAlign: pw.TextAlign.left,
                                                style: pw.TextStyle(
                                                  fontSize: font_Size,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: Colors_pd,
                                                ),
                                              ),
                                            ),
                                          ),
                                          pw.Expanded(
                                            flex: 2,
                                            child: pw.Text(
                                              '',
                                              textAlign: pw.TextAlign.left,
                                              style: pw.TextStyle(
                                                fontSize: font_Size,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: Colors_pd,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ])),
                        ],
                      )),
                ]),
              ),
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
                        color: Colors_pd, fontSize: 8.00,
                        // fontSize: font_Size - 4,
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
                        fontSize: 8.00,
                        // fontSize: font_Size - 4,
                        font: ttf,
                      ),
                    ),
                  ),
                  pw.Positioned(
                    bottom: 4,
                    left: 40,
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.fromLTRB(0, 2, 0, 0),
                          child: pw.Align(
                            alignment: pw.Alignment.bottomLeft,
                            child: pw.Text(
                              'ครั้งที่ : ${paper_run} พิมพ์เมื่อ : $date ',
                              // textAlign: pw.TextAlign.left,
                              style: pw.TextStyle(
                                fontSize: 8.00,
                                font: ttf,
                                color: Colors_pd,
                                // fontWeight: pw.FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.fromLTRB(0, 2, 0, 0),
                          child: pw.Align(
                            alignment: pw.Alignment.bottomRight,
                            child: pw.Text(
                              ' ( หน้าที่ ${context.pageNumber} / ${context.pagesCount} ) ',
                              // textAlign: pw.TextAlign.left,
                              style: pw.TextStyle(
                                fontSize: 8.00,
                                font: ttf,
                                color: Colors_pd,
                                // fontWeight: pw.FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // pdf.addPage(
    //   pw.MultiPage(
    //     maxPages: 50,
    //     pageFormat: PdfPageFormat.a4.copyWith(
    //       marginBottom: 5.00,
    //       marginLeft: 0.00,
    //       marginRight: 0.00,
    //       marginTop: 0.00,
    //     ),
    //     // pageFormat: PdfPageFormat.a4.copyWith(
    //     //   marginBottom: 8.00,
    //     //   marginLeft: 8.00,
    //     //   marginRight: 8.00,
    //     //   marginTop: 8.00,
    //     // ),
    //     header: (context) {
    //       return Header(context);
    //     },
    //     build: (context) {
    //       return [
    //         pw.Container(
    //             decoration: pw.BoxDecoration(
    //               image: pw.DecorationImage(
    //                 image: pw.MemoryImage(
    //                   imageBG,
    //                 ),
    //                 fit: pw.BoxFit.fill,
    //               ),
    //             ),
    //             padding: pw.EdgeInsets.fromLTRB(8, 0, 8, 0),
    //             child: pw.Column(children: [
    //               pw.Container(
    //                 height: (ref_invoice.length > 5)
    //                     ? 112
    //                     : (ref_invoice.length > 1)
    //                         ? 100
    //                         : 85,
    //                 child: pw.Row(
    //                   children: [
    //                     pw.Expanded(
    //                         flex: 3,
    //                         child: pw.Container(
    //                           height: (ref_invoice.length > 30)
    //                               ? 260
    //                               : (ref_invoice.length > 25)
    //                                   ? 230
    //                                   : (ref_invoice.length > 20)
    //                                       ? 200
    //                                       : (ref_invoice.length > 10)
    //                                           ? 130
    //                                           : (ref_invoice.length > 5)
    //                                               ? 112
    //                                               : (ref_invoice.length > 1)
    //                                                   ? 115
    //                                                   : 85,
    //                           decoration: const pw.BoxDecoration(
    //                             // color: PdfColors.green100,
    //                             border: pw.Border(
    //                               top: pw.BorderSide(color: PdfColors.grey600),
    //                               right:
    //                                   pw.BorderSide(color: PdfColors.grey600),
    //                               left: pw.BorderSide(color: PdfColors.grey600),
    //                               bottom:
    //                                   pw.BorderSide(color: PdfColors.grey600),
    //                             ),
    //                           ),
    //                           child: pw.Row(
    //                             crossAxisAlignment: pw.CrossAxisAlignment.start,
    //                             children: [
    //                               pw.Expanded(
    //                                   flex: 1,
    //                                   child: pw.Container(
    //                                     padding:
    //                                         pw.EdgeInsets.fromLTRB(2, 4, 2, 2),
    //                                     child: pw.Column(
    //                                       mainAxisAlignment:
    //                                           pw.MainAxisAlignment.spaceBetween,
    //                                       crossAxisAlignment:
    //                                           pw.CrossAxisAlignment.start,
    //                                       children: [
    //                                         pw.Text(
    //                                           // (cname.toString() == '' ||
    //                                           //         cname.toString() == '-' ||
    //                                           //         cname == null ||
    //                                           //         cname.toString() ==
    //                                           //             'null')
    //                                           //     ? 'นามลูกค้า /Name : ${(sname.toString() == '' || sname == null || sname.toString() == 'null') ? '-' : sname}'
    //                                           //     :
    //                                           'นามลูกค้า /Name : ${cname}',
    //                                           // (sname.toString() == null ||
    //                                           //         sname.toString() == '' ||
    //                                           //         sname.toString() == 'null')
    //                                           //     ? 'นามลูกค้า /Name : -'
    //                                           //     : 'นามลูกค้า /Name : $sname',
    //                                           textAlign: pw.TextAlign.left,
    //                                           style: pw.TextStyle(
    //                                             fontSize: font_Size,
    //                                             font: ttf,
    //                                             fontWeight: pw.FontWeight.bold,
    //                                             color: Colors_pd,
    //                                           ),
    //                                         ),
    //                                         pw.Text(
    //                                           (addr.toString() == null ||
    //                                                   addr.toString() == '' ||
    //                                                   addr.toString() == 'null')
    //                                               ? 'ที่อยู่ /Address : -'
    //                                               : 'ที่อยู่ /Address  : $addr',
    //                                           textAlign: pw.TextAlign.left,
    //                                           style: pw.TextStyle(
    //                                             fontSize: font_Size,
    //                                             font: ttf,
    //                                             fontWeight: pw.FontWeight.bold,
    //                                             color: Colors_pd,
    //                                           ),
    //                                         ),
    //                                         pw.Text(
    //                                           (tax == null ||
    //                                                   tax.toString() == '' ||
    //                                                   tax.toString() == 'null')
    //                                               ? 'เลขที่ผู้เสียภาษี /Tax : 0'
    //                                               : 'เลขที่ผู้เสียภาษี /Tax : $tax',
    //                                           textAlign: pw.TextAlign.left,
    //                                           style: pw.TextStyle(
    //                                             fontSize: font_Size,
    //                                             font: ttf,
    //                                             fontWeight: pw.FontWeight.bold,
    //                                             color: Colors_pd,
    //                                           ),
    //                                         ),
    //                                         // pw.Text(
    //                                         //   'เลขสัญญา /No. : $cid_s ',
    //                                         //   textAlign: pw.TextAlign.left,
    //                                         //   style: pw.TextStyle(
    //                                         //     fontSize: font_Size,
    //                                         //     font: ttf,
    //                                         //     fontWeight: pw.FontWeight.bold,
    //                                         //     color: Colors_pd,
    //                                         //   ),
    //                                         // ),
    //                                         // pw.Text(
    //                                         //   'โซน /Zone : $Zone_s (รหัสพื้นที่ /Area  : $Ln_s)',
    //                                         //   textAlign: pw.TextAlign.left,
    //                                         //   style: pw.TextStyle(
    //                                         //     fontSize: font_Size,
    //                                         //     font: ttf,
    //                                         //     fontWeight: pw.FontWeight.bold,
    //                                         //     color: Colors_pd,
    //                                         //   ),
    //                                         // ),
    //                                         pw.Text(
    //                                           'หมายเหตุ /Note : $com_ment ',
    //                                           textAlign: pw.TextAlign.left,
    //                                           style: pw.TextStyle(
    //                                             fontSize: font_Size,
    //                                             font: ttf,
    //                                             fontWeight: pw.FontWeight.bold,
    //                                             color: Colors_pd,
    //                                           ),
    //                                         ),
    //                                         (ref_invoice.length > 1)
    //                                             ? pw.Text(
    //                                                 'อ้างอิงเลขที่/Refer no. : ${ref_invoice.toSet().map((model) => model).join(', ')}',
    //                                                 textAlign:
    //                                                     pw.TextAlign.left,
    //                                                 maxLines: 5,
    //                                                 style: pw.TextStyle(
    //                                                   fontSize:
    //                                                       (ref_invoice.length >
    //                                                               20)
    //                                                           ? font_Size - 2
    //                                                           : font_Size,
    //                                                   font: ttf,
    //                                                   fontWeight:
    //                                                       pw.FontWeight.bold,
    //                                                   color: Colors_pd,
    //                                                 ),
    //                                               )
    //                                             : pw.SizedBox(),
    //                                       ],
    //                                     ),
    //                                   )),
    //                             ],
    //                           ),
    //                         )),
    //                     pw.Expanded(
    //                         flex: 2,
    //                         child: pw.Column(
    //                           children: [
    //                             pw.Expanded(
    //                                 flex: 1,
    //                                 child: pw.Container(
    //                                   height: (ref_invoice.length > 5)
    //                                       ? 40
    //                                       : (ref_invoice.length > 1)
    //                                           ? 20
    //                                           : 10,
    //                                   decoration: const pw.BoxDecoration(
    //                                     // color: PdfColors.green100,
    //                                     border: pw.Border(
    //                                       right: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       top: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       bottom: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                     ),
    //                                   ),
    //                                   child: pw.Row(
    //                                     crossAxisAlignment:
    //                                         pw.CrossAxisAlignment.center,
    //                                     mainAxisAlignment:
    //                                         pw.MainAxisAlignment.center,
    //                                     children: [
    //                                       pw.Expanded(
    //                                         flex: 1,
    //                                         child: pw.Column(
    //                                             mainAxisAlignment:
    //                                                 pw.MainAxisAlignment.center,
    //                                             crossAxisAlignment: pw
    //                                                 .CrossAxisAlignment.center,
    //                                             children: [
    //                                               (hasNonCashTransaction1)
    //                                                   ? pw.Text(
    //                                                       (TitleType_Default_Receipt_Name !=
    //                                                                   null &&
    //                                                               TitleType_Default_Receipt_Name
    //                                                                           .toString()
    //                                                                       .trim() !=
    //                                                                   '' &&
    //                                                               TitleType_Default_Receipt_Name
    //                                                                       .toString() !=
    //                                                                   'ไม่ระบุ')
    //                                                           ? (numdoctax.toString() ==
    //                                                                   '')
    //                                                               ? 'บิลเงินสด [ $TitleType_Default_Receipt_Name ]'
    //                                                               : 'บิลเงินสด/ใบกำกับภาษี [ $TitleType_Default_Receipt_Name ]'
    //                                                           : (numdoctax.toString() ==
    //                                                                   '')
    //                                                               ? 'บิลเงินสด'
    //                                                               : 'บิลเงินสด/ใบกำกับภาษี',
    //                                                       textAlign: pw
    //                                                           .TextAlign.center,
    //                                                       style: pw.TextStyle(
    //                                                         fontSize: 14,
    //                                                         font: ttf,
    //                                                         fontWeight: pw
    //                                                             .FontWeight
    //                                                             .bold,
    //                                                         color: Colors_pd,
    //                                                       ),
    //                                                     )
    //                                                   : pw.Text(
    //                                                       (TitleType_Default_Receipt_Name !=
    //                                                                   null &&
    //                                                               TitleType_Default_Receipt_Name
    //                                                                           .toString()
    //                                                                       .trim() !=
    //                                                                   '' &&
    //                                                               TitleType_Default_Receipt_Name
    //                                                                       .toString() !=
    //                                                                   'ไม่ระบุ')
    //                                                           ? (numdoctax.toString() ==
    //                                                                   '')
    //                                                               ? 'ใบเสร็จรับเงิน'
    //                                                               : 'ใบเสร็จรับเงิน/ใบกำกับภาษี '
    //                                                           : (numdoctax.toString() ==
    //                                                                   '')
    //                                                               ? 'ใบเสร็จรับเงิน'
    //                                                               : 'ใบเสร็จรับเงิน/ใบกำกับภาษี',
    //                                                       textAlign: pw
    //                                                           .TextAlign.center,
    //                                                       style: pw.TextStyle(
    //                                                         fontSize: 14,
    //                                                         font: ttf,
    //                                                         fontWeight: pw
    //                                                             .FontWeight
    //                                                             .bold,
    //                                                         color: Colors_pd,
    //                                                       ),
    //                                                     ),
    //                                               (hasNonCashTransaction1)
    //                                                   ? pw.Text(
    //                                                       (TitleType_Default_Receipt_Name !=
    //                                                                   null &&
    //                                                               TitleType_Default_Receipt_Name
    //                                                                           .toString()
    //                                                                       .trim() !=
    //                                                                   '' &&
    //                                                               TitleType_Default_Receipt_Name
    //                                                                       .toString() !=
    //                                                                   'ไม่ระบุ')
    //                                                           ? (numdoctax.toString() ==
    //                                                                   '')
    //                                                               ? (TitleType_Default_Receipt_Name
    //                                                                           .toString() ==
    //                                                                       'ต้นฉบับ')
    //                                                                   ? 'Cash Sell Original'
    //                                                                   : (TitleType_Default_Receipt_Name.toString() ==
    //                                                                           'คู่ฉบับ')
    //                                                                       ? 'Cash Sell Duplicate'
    //                                                                       : (TitleType_Default_Receipt_Name.toString() ==
    //                                                                               'สำเนาคู่ฉบับ')
    //                                                                           ? 'Cash Sell Duplicate Copy'
    //                                                                           : (TitleType_Default_Receipt_Name.toString() ==
    //                                                                                   'สำเนา')
    //                                                                               ? 'Cash Sell Copy'
    //                                                                               : 'Cash Sell'
    //                                                               : (TitleType_Default_Receipt_Name
    //                                                                           .toString() ==
    //                                                                       'ต้นฉบับ')
    //                                                                   ? 'Cash Sell/Tax Invoice Original'
    //                                                                   : (TitleType_Default_Receipt_Name.toString() ==
    //                                                                           'คู่ฉบับ')
    //                                                                       ? 'Cash Sell/Tax Invoice Duplicate'
    //                                                                       : (TitleType_Default_Receipt_Name.toString() == 'สำเนาคู่ฉบับ')
    //                                                                           ? 'Cash Sell/Tax Invoice Duplicate Copy'
    //                                                                           : (TitleType_Default_Receipt_Name.toString() == 'สำเนา')
    //                                                                               ? 'Cash Sell/Tax Invoice Copy'
    //                                                                               : 'Cash Sell/Tax Invoice'
    //                                                           : (numdoctax.toString() == '')
    //                                                               ? 'Cash Sell'
    //                                                               : 'Cash Sell/Tax Invoice',
    //                                                       textAlign: pw
    //                                                           .TextAlign.center,
    //                                                       style: pw.TextStyle(
    //                                                         fontSize: 14,
    //                                                         font: ttf,
    //                                                         fontWeight: pw
    //                                                             .FontWeight
    //                                                             .bold,
    //                                                         color: Colors_pd,
    //                                                       ),
    //                                                     )
    //                                                   : pw.Text(
    //                                                       (TitleType_Default_Receipt_Name !=
    //                                                               null)
    //                                                           ? (numdoctax.toString() ==
    //                                                                   '')
    //                                                               ? (TitleType_Default_Receipt_Name
    //                                                                           .toString() ==
    //                                                                       'ต้นฉบับ')
    //                                                                   ? 'Receipt Original'
    //                                                                   : (TitleType_Default_Receipt_Name.toString() ==
    //                                                                           'คู่ฉบับ')
    //                                                                       ? 'Receipt Duplicate'
    //                                                                       : (TitleType_Default_Receipt_Name.toString() ==
    //                                                                               'สำเนาคู่ฉบับ')
    //                                                                           ? 'Receipt Duplicate Copy'
    //                                                                           : (TitleType_Default_Receipt_Name.toString() ==
    //                                                                                   'สำเนา')
    //                                                                               ? 'Receipt Copy'
    //                                                                               : 'Receipt'
    //                                                               : (TitleType_Default_Receipt_Name
    //                                                                           .toString() ==
    //                                                                       'ต้นฉบับ')
    //                                                                   ? 'Receipt/Tax Receipt Original'
    //                                                                   : (TitleType_Default_Receipt_Name.toString() ==
    //                                                                           'คู่ฉบับ')
    //                                                                       ? 'Receipt/Tax Receipt Duplicate'
    //                                                                       : (TitleType_Default_Receipt_Name.toString() == 'สำเนาคู่ฉบับ')
    //                                                                           ? 'Receipt/Tax Receipt Duplicate Copy'
    //                                                                           : (TitleType_Default_Receipt_Name.toString() == 'สำเนา')
    //                                                                               ? 'Receipt/Tax Receipt Copy'
    //                                                                               : 'Receipt/Tax Invoice'
    //                                                           : (numdoctax.toString() == '')
    //                                                               ? 'Receipt'
    //                                                               : 'Receipt/Tax Invoice',
    //                                                       textAlign: pw
    //                                                           .TextAlign.center,
    //                                                       style: pw.TextStyle(
    //                                                         fontSize: 14,
    //                                                         font: ttf,
    //                                                         fontWeight: pw
    //                                                             .FontWeight
    //                                                             .bold,
    //                                                         color: Colors_pd,
    //                                                       ),
    //                                                     ),
    //                                             ]),
    //                                       ),
    //                                     ],
    //                                   ),
    //                                 )),
    //                             pw.Row(
    //                               children: [
    //                                 pw.Expanded(
    //                                     flex: 1,
    //                                     child: pw.Container(
    //                                       height: (ref_invoice.length > 5)
    //                                           ? 70
    //                                           : (ref_invoice.length > 1)
    //                                               ? 50
    //                                               : 40,
    //                                       decoration: const pw.BoxDecoration(
    //                                         // color: PdfColors.green100,
    //                                         border: pw.Border(
    //                                           right: pw.BorderSide(
    //                                               color: PdfColors.grey600),
    //                                           top: pw.BorderSide(
    //                                               color: PdfColors.grey600),
    //                                           bottom: pw.BorderSide(
    //                                               color: PdfColors.grey600),
    //                                         ),
    //                                       ),
    //                                       child: pw.Row(
    //                                         // crossAxisAlignment:
    //                                         //     pw.CrossAxisAlignment.start,
    //                                         children: [
    //                                           pw.Expanded(
    //                                             flex: 1,
    //                                             child: pw.Column(
    //                                                 mainAxisAlignment: pw
    //                                                     .MainAxisAlignment
    //                                                     .center,
    //                                                 crossAxisAlignment: pw
    //                                                     .CrossAxisAlignment
    //                                                     .center,
    //                                                 children: [
    //                                                   pw.Text(
    //                                                     'วันที่ทำรายการ',
    //                                                     textAlign:
    //                                                         pw.TextAlign.center,
    //                                                     style: pw.TextStyle(
    //                                                       fontSize: font_Size,
    //                                                       font: ttf,
    //                                                       fontWeight: pw
    //                                                           .FontWeight.bold,
    //                                                       color: Colors_pd,
    //                                                     ),
    //                                                   ),
    //                                                   pw.Text(
    //                                                     'Date',
    //                                                     textAlign:
    //                                                         pw.TextAlign.center,
    //                                                     style: pw.TextStyle(
    //                                                       fontSize: font_Size,
    //                                                       font: ttf,
    //                                                       fontWeight: pw
    //                                                           .FontWeight.bold,
    //                                                       color: Colors_pd,
    //                                                     ),
    //                                                   ),
    //                                                   pw.Text(
    //                                                     '${DateFormat('dd/MM').format(DateTime.parse(date_Transaction!))}/${DateTime.parse('${date_Transaction}').year + 543}',
    //                                                     //'$date_Transaction',
    //                                                     textAlign:
    //                                                         pw.TextAlign.center,
    //                                                     style: pw.TextStyle(
    //                                                       fontSize: font_Size,
    //                                                       font: ttf,
    //                                                       fontWeight: pw
    //                                                           .FontWeight.bold,
    //                                                       color: Colors_pd,
    //                                                     ),
    //                                                   ),
    //                                                 ]),
    //                                           ),
    //                                         ],
    //                                       ),
    //                                     )),
    //                                 pw.Expanded(
    //                                     flex: 1,
    //                                     child: pw.Container(
    //                                       height: (ref_invoice.length > 5)
    //                                           ? 70
    //                                           : (ref_invoice.length > 1)
    //                                               ? 50
    //                                               : 40,
    //                                       decoration: const pw.BoxDecoration(
    //                                         // color: PdfColors.green100,
    //                                         border: pw.Border(
    //                                           right: pw.BorderSide(
    //                                               color: PdfColors.grey600),
    //                                           top: pw.BorderSide(
    //                                               color: PdfColors.grey600),
    //                                           bottom: pw.BorderSide(
    //                                               color: PdfColors.grey600),
    //                                         ),
    //                                       ),
    //                                       child: pw.Row(
    //                                         crossAxisAlignment:
    //                                             pw.CrossAxisAlignment.start,
    //                                         children: [
    //                                           pw.Expanded(
    //                                             flex: 1,
    //                                             child: pw.Column(
    //                                                 mainAxisAlignment: pw
    //                                                     .MainAxisAlignment
    //                                                     .center,
    //                                                 crossAxisAlignment: pw
    //                                                     .CrossAxisAlignment
    //                                                     .center,
    //                                                 children: [
    //                                                   pw.Text(
    //                                                     'เลขที่ใบกำกับ',
    //                                                     textAlign:
    //                                                         pw.TextAlign.center,
    //                                                     style: pw.TextStyle(
    //                                                       fontSize: font_Size,
    //                                                       font: ttf,
    //                                                       fontWeight: pw
    //                                                           .FontWeight.bold,
    //                                                       color: Colors_pd,
    //                                                     ),
    //                                                   ),
    //                                                   pw.Text(
    //                                                     'Order no.',
    //                                                     textAlign:
    //                                                         pw.TextAlign.center,
    //                                                     style: pw.TextStyle(
    //                                                       fontSize: font_Size,
    //                                                       font: ttf,
    //                                                       fontWeight: pw
    //                                                           .FontWeight.bold,
    //                                                       color: Colors_pd,
    //                                                     ),
    //                                                   ),
    //                                                   pw.Text(
    //                                                     (numdoctax.toString() ==
    //                                                             '')
    //                                                         ? '$numinvoice '
    //                                                         : '$numdoctax ',
    //                                                     textAlign:
    //                                                         pw.TextAlign.center,
    //                                                     style: pw.TextStyle(
    //                                                       fontSize: font_Size,
    //                                                       font: ttf,
    //                                                       fontWeight: pw
    //                                                           .FontWeight.bold,
    //                                                       color: Colors_pd,
    //                                                     ),
    //                                                   ),
    //                                                 ]),
    //                                           ),
    //                                         ],
    //                                       ),
    //                                     )),
    //                                 (ref_invoice.length == 0 ||
    //                                         ref_invoice.length > 1)
    //                                     ? pw.SizedBox()
    //                                     : pw.Expanded(
    //                                         flex: 1,
    //                                         child: pw.Container(
    //                                           height: 40,
    //                                           decoration:
    //                                               const pw.BoxDecoration(
    //                                             // color: PdfColors.green100,
    //                                             border: pw.Border(
    //                                               right: pw.BorderSide(
    //                                                   color: PdfColors.grey600),
    //                                               top: pw.BorderSide(
    //                                                   color: PdfColors.grey600),
    //                                               bottom: pw.BorderSide(
    //                                                   color: PdfColors.grey600),
    //                                             ),
    //                                           ),
    //                                           child: pw.Row(
    //                                             crossAxisAlignment:
    //                                                 pw.CrossAxisAlignment.start,
    //                                             children: [
    //                                               pw.Expanded(
    //                                                 flex: 1,
    //                                                 child: pw.Column(
    //                                                     mainAxisAlignment: pw
    //                                                         .MainAxisAlignment
    //                                                         .center,
    //                                                     crossAxisAlignment: pw
    //                                                         .CrossAxisAlignment
    //                                                         .center,
    //                                                     children: [
    //                                                       pw.Text(
    //                                                         'อ้างอิงเลขที่',
    //                                                         textAlign: pw
    //                                                             .TextAlign
    //                                                             .center,
    //                                                         style: pw.TextStyle(
    //                                                           fontSize:
    //                                                               font_Size,
    //                                                           font: ttf,
    //                                                           fontWeight: pw
    //                                                               .FontWeight
    //                                                               .bold,
    //                                                           color: Colors_pd,
    //                                                         ),
    //                                                       ),
    //                                                       pw.Text(
    //                                                         'Refer no.',
    //                                                         textAlign: pw
    //                                                             .TextAlign
    //                                                             .center,
    //                                                         style: pw.TextStyle(
    //                                                           fontSize:
    //                                                               font_Size,
    //                                                           font: ttf,
    //                                                           fontWeight: pw
    //                                                               .FontWeight
    //                                                               .bold,
    //                                                           color: Colors_pd,
    //                                                         ),
    //                                                       ),
    //                                                       pw.Text(
    //                                                         (ref_invoice[0]
    //                                                                     .toString() ==
    //                                                                 '')
    //                                                             ? '-'
    //                                                             : '${ref_invoice[0]}',
    //                                                         // (ref_invoice == null ||
    //                                                         //         ref_invoice
    //                                                         //                 .toString() ==
    //                                                         //             '')
    //                                                         //     ? ''
    //                                                         //     : '${ref_invoice}',
    //                                                         textAlign: pw
    //                                                             .TextAlign
    //                                                             .center,
    //                                                         style: pw.TextStyle(
    //                                                           fontSize:
    //                                                               font_Size,
    //                                                           font: ttf,
    //                                                           fontWeight: pw
    //                                                               .FontWeight
    //                                                               .bold,
    //                                                           color: Colors_pd,
    //                                                         ),
    //                                                       ),
    //                                                     ]),
    //                                               ),
    //                                             ],
    //                                           ),
    //                                         )),
    //                               ],
    //                             )
    //                           ],
    //                         )),
    //                   ],
    //                 ),
    //               ),
    //               pw.Container(
    //                 height: 35,
    //                 child: pw.Row(
    //                   children: [
    //                     pw.Expanded(
    //                         flex: 3,
    //                         child: pw.Container(
    //                           height: 35,
    //                           decoration: const pw.BoxDecoration(
    //                             // color: PdfColors.green100,
    //                             border: pw.Border(
    //                               // right: pw.BorderSide(color: PdfColors.grey600),
    //                               left: pw.BorderSide(color: PdfColors.grey600),
    //                               bottom:
    //                                   pw.BorderSide(color: PdfColors.grey600),
    //                             ),
    //                           ),
    //                           child: pw.Row(
    //                             crossAxisAlignment: pw.CrossAxisAlignment.start,
    //                             children: [
    //                               pw.Expanded(
    //                                 flex: 2,
    //                                 child: pw.Container(
    //                                     height: 35,
    //                                     decoration: const pw.BoxDecoration(
    //                                       // color: PdfColors.green100,
    //                                       border: pw.Border(
    //                                         right: pw.BorderSide(
    //                                             color: PdfColors.grey600),
    //                                         bottom: pw.BorderSide(
    //                                             color: PdfColors.grey800),
    //                                       ),
    //                                     ),
    //                                     padding: const pw.EdgeInsets.all(2.0),
    //                                     child: pw.Column(
    //                                       mainAxisAlignment:
    //                                           pw.MainAxisAlignment.center,
    //                                       crossAxisAlignment:
    //                                           pw.CrossAxisAlignment.center,
    //                                       children: [
    //                                         pw.Text(
    //                                           'พนักงานขาย /Sales man No.',
    //                                           textAlign: pw.TextAlign.center,
    //                                           style: pw.TextStyle(
    //                                             fontSize: font_Size,
    //                                             font: ttf,
    //                                             fontWeight: pw.FontWeight.bold,
    //                                             color: Colors_pd,
    //                                           ),
    //                                         ),
    //                                         pw.Text(
    //                                           '-',
    //                                           // (fname == null)
    //                                           //     ? '-'
    //                                           //     : '$fname',
    //                                           textAlign: pw.TextAlign.center,
    //                                           style: pw.TextStyle(
    //                                             fontSize: font_Size,
    //                                             font: ttf,
    //                                             fontWeight: pw.FontWeight.bold,
    //                                             color: Colors_pd,
    //                                           ),
    //                                         ),
    //                                       ],
    //                                     )),
    //                               ),
    //                               pw.Expanded(
    //                                 flex: 1,
    //                                 child: pw.Container(
    //                                     height: 35,
    //                                     decoration: const pw.BoxDecoration(
    //                                       // color: PdfColors.green100,
    //                                       border: pw.Border(
    //                                         bottom: pw.BorderSide(
    //                                             color: PdfColors.grey800),
    //                                       ),
    //                                     ),
    //                                     padding: const pw.EdgeInsets.all(2.0),
    //                                     child: pw.Column(
    //                                       mainAxisAlignment:
    //                                           pw.MainAxisAlignment.center,
    //                                       crossAxisAlignment:
    //                                           pw.CrossAxisAlignment.center,
    //                                       children: [
    //                                         pw.Text(
    //                                           'ประเภท /Type.',
    //                                           textAlign: pw.TextAlign.center,
    //                                           style: pw.TextStyle(
    //                                             fontSize: font_Size,
    //                                             font: ttf,
    //                                             fontWeight: pw.FontWeight.bold,
    //                                             color: Colors_pd,
    //                                           ),
    //                                         ),
    //                                         pw.Text(
    //                                           (type_bills.toString().trim() ==
    //                                                       '' ||
    //                                                   type_bills == null)
    //                                               ? 'สัญญา'
    //                                               : 'ล็อคเสียบ',
    //                                           textAlign: pw.TextAlign.center,
    //                                           style: pw.TextStyle(
    //                                             fontSize: font_Size,
    //                                             font: ttf,
    //                                             fontWeight: pw.FontWeight.bold,
    //                                             color: Colors_pd,
    //                                           ),
    //                                         ),
    //                                       ],
    //                                     )),
    //                               ),
    //                               pw.Expanded(
    //                                 flex: 1,
    //                                 child: pw.Container(
    //                                     height: 35,
    //                                     decoration: const pw.BoxDecoration(
    //                                       // color: PdfColors.green100,
    //                                       border: pw.Border(
    //                                         right: pw.BorderSide(
    //                                             color: PdfColors.grey600),
    //                                         left: pw.BorderSide(
    //                                             color: PdfColors.grey600),
    //                                         bottom: pw.BorderSide(
    //                                             color: PdfColors.grey600),
    //                                       ),
    //                                     ),
    //                                     padding: const pw.EdgeInsets.all(2.0),
    //                                     child: pw.Column(
    //                                       mainAxisAlignment:
    //                                           pw.MainAxisAlignment.center,
    //                                       crossAxisAlignment:
    //                                           pw.CrossAxisAlignment.center,
    //                                       children: [
    //                                         pw.Text(
    //                                           'รหัสลูกค้า /Code',
    //                                           textAlign: pw.TextAlign.center,
    //                                           style: pw.TextStyle(
    //                                             fontSize: font_Size,
    //                                             font: ttf,
    //                                             fontWeight: pw.FontWeight.bold,
    //                                             color: Colors_pd,
    //                                           ),
    //                                         ),
    //                                         pw.Text(
    //                                           (Cust_no.toString() == '' ||
    //                                                   Cust_no == null)
    //                                               ? '-'
    //                                               : '$Cust_no',
    //                                           textAlign: pw.TextAlign.center,
    //                                           style: pw.TextStyle(
    //                                             fontSize: font_Size,
    //                                             font: ttf,
    //                                             fontWeight: pw.FontWeight.bold,
    //                                             color: Colors_pd,
    //                                           ),
    //                                         ),
    //                                       ],
    //                                     )),
    //                               ),
    //                             ],
    //                           ),
    //                         )),
    //                     pw.Expanded(
    //                         flex: 1,
    //                         child: pw.Container(
    //                           height: 35,
    //                           decoration: const pw.BoxDecoration(
    //                             // color: PdfColors.green100,
    //                             border: pw.Border(
    //                               right:
    //                                   pw.BorderSide(color: PdfColors.grey600),
    //                               // left: pw.BorderSide(color: PdfColors.grey800),
    //                               bottom:
    //                                   pw.BorderSide(color: PdfColors.grey600),
    //                             ),
    //                           ),
    //                           child: pw.Row(
    //                             crossAxisAlignment: pw.CrossAxisAlignment.start,
    //                             children: [
    //                               pw.Expanded(
    //                                 flex: 1,
    //                                 child: pw.Container(
    //                                     height: 35,
    //                                     padding: const pw.EdgeInsets.all(2.0),
    //                                     child: pw.Column(
    //                                       mainAxisAlignment:
    //                                           pw.MainAxisAlignment.center,
    //                                       crossAxisAlignment:
    //                                           pw.CrossAxisAlignment.center,
    //                                       children: [
    //                                         pw.Text(
    //                                           'วันที่รับชำระ /Payment Date',
    //                                           textAlign: pw.TextAlign.center,
    //                                           style: pw.TextStyle(
    //                                             fontSize: font_Size,
    //                                             font: ttf,
    //                                             fontWeight: pw.FontWeight.bold,
    //                                             color: Colors_pd,
    //                                           ),
    //                                         ),
    //                                         pw.Text(
    //                                           (dayfinpay.toString() == '' ||
    //                                                   dayfinpay.toString() ==
    //                                                       'null' ||
    //                                                   dayfinpay == null)
    //                                               ? '-'
    //                                               : '${DateFormat('dd/MM').format(DateTime.parse(dayfinpay!))}/${DateTime.parse('${dayfinpay}').year + 543}',
    //                                           textAlign: pw.TextAlign.center,
    //                                           style: pw.TextStyle(
    //                                             fontSize: font_Size,
    //                                             font: ttf,
    //                                             fontWeight: pw.FontWeight.bold,
    //                                             color: Colors_pd,
    //                                           ),
    //                                         ),
    //                                       ],
    //                                     )),
    //                               ),
    //                             ],
    //                           ),
    //                         )),
    //                   ],
    //                 ),
    //               ),

    //               pw.Container(
    //                 decoration: const pw.BoxDecoration(
    //                   // color: PdfColors.green100,
    //                   border: pw.Border(
    //                     // top: pw.BorderSide(color: PdfColors.grey800),
    //                     bottom: pw.BorderSide(color: PdfColors.grey800),
    //                   ),
    //                 ),
    //                 child: pw.Row(
    //                   children: [
    //                     pw.Container(
    //                       width: 30,
    //                       decoration: const pw.BoxDecoration(
    //                         // color: PdfColors.green100,
    //                         border: pw.Border(
    //                           left: pw.BorderSide(color: PdfColors.grey600),
    //                           right: pw.BorderSide(color: PdfColors.grey600),
    //                           bottom: pw.BorderSide(color: PdfColors.grey600),
    //                         ),
    //                       ),
    //                       height: 30,
    //                       child: pw.Column(
    //                         mainAxisAlignment: pw.MainAxisAlignment.center,
    //                         crossAxisAlignment: pw.CrossAxisAlignment.center,
    //                         children: [
    //                           pw.Text(
    //                             'ลำดับ',
    //                             maxLines: 1,
    //                             textAlign: pw.TextAlign.left,
    //                             style: pw.TextStyle(
    //                                 fontSize: font_Size,
    //                                 font: ttf,
    //                                 color: PdfColors.black),
    //                           ),
    //                           pw.Text(
    //                             'No.',
    //                             maxLines: 1,
    //                             textAlign: pw.TextAlign.left,
    //                             style: pw.TextStyle(
    //                                 fontSize: font_Size,
    //                                 font: ttf,
    //                                 color: PdfColors.black),
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                     pw.Expanded(
    //                       flex: 2,
    //                       child: pw.Container(
    //                         decoration: const pw.BoxDecoration(
    //                           // color: PdfColors.green100,
    //                           border: pw.Border(
    //                             right: pw.BorderSide(color: PdfColors.grey600),
    //                             // top: pw.BorderSide(color: PdfColors.grey800),
    //                             bottom: pw.BorderSide(color: PdfColors.grey600),
    //                           ),
    //                         ),
    //                         height: 30,
    //                         child: pw.Column(
    //                           mainAxisAlignment: pw.MainAxisAlignment.center,
    //                           crossAxisAlignment: pw.CrossAxisAlignment.center,
    //                           children: [
    //                             pw.Text(
    //                               'รหัสสินค้า',
    //                               maxLines: 1,
    //                               textAlign: pw.TextAlign.left,
    //                               style: pw.TextStyle(
    //                                   fontSize: font_Size,
    //                                   font: ttf,
    //                                   color: PdfColors.black),
    //                             ),
    //                             pw.Text(
    //                               'Product Code',
    //                               maxLines: 1,
    //                               textAlign: pw.TextAlign.left,
    //                               style: pw.TextStyle(
    //                                   fontSize: font_Size,
    //                                   font: ttf,
    //                                   color: PdfColors.black),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ),
    //                     pw.Expanded(
    //                       flex: 4,
    //                       child: pw.Container(
    //                         decoration: const pw.BoxDecoration(
    //                           // color: PdfColors.green100,
    //                           border: pw.Border(
    //                             right: pw.BorderSide(color: PdfColors.grey600),
    //                             // top: pw.BorderSide(color: PdfColors.grey800),
    //                             bottom: pw.BorderSide(color: PdfColors.grey600),
    //                           ),
    //                         ),
    //                         height: 30,
    //                         child: pw.Column(
    //                           mainAxisAlignment: pw.MainAxisAlignment.center,
    //                           crossAxisAlignment: pw.CrossAxisAlignment.center,
    //                           children: [
    //                             pw.Text(
    //                               'รายละเอียด',
    //                               maxLines: 1,
    //                               textAlign: pw.TextAlign.left,
    //                               style: pw.TextStyle(
    //                                   fontSize: font_Size,
    //                                   font: ttf,
    //                                   color: PdfColors.black),
    //                             ),
    //                             pw.Text(
    //                               'Description',
    //                               maxLines: 1,
    //                               textAlign: pw.TextAlign.left,
    //                               style: pw.TextStyle(
    //                                   fontSize: font_Size,
    //                                   font: ttf,
    //                                   color: PdfColors.black),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ),
    //                     pw.Expanded(
    //                       flex: 1,
    //                       child: pw.Container(
    //                         decoration: const pw.BoxDecoration(
    //                           // color: PdfColors.green100,
    //                           border: pw.Border(
    //                             right: pw.BorderSide(color: PdfColors.grey600),
    //                             // top: pw.BorderSide(color: PdfColors.grey800),
    //                             bottom: pw.BorderSide(color: PdfColors.grey600),
    //                           ),
    //                         ),
    //                         height: 30,
    //                         child: pw.Column(
    //                           mainAxisAlignment: pw.MainAxisAlignment.center,
    //                           crossAxisAlignment: pw.CrossAxisAlignment.center,
    //                           children: [
    //                             pw.Text(
    //                               'จำนวน',
    //                               maxLines: 1,
    //                               textAlign: pw.TextAlign.left,
    //                               style: pw.TextStyle(
    //                                   fontSize: font_Size,
    //                                   font: ttf,
    //                                   color: PdfColors.black),
    //                             ),
    //                             pw.Text(
    //                               'Quantity',
    //                               maxLines: 1,
    //                               textAlign: pw.TextAlign.left,
    //                               style: pw.TextStyle(
    //                                   fontSize: font_Size,
    //                                   font: ttf,
    //                                   color: PdfColors.black),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ),
    //                     pw.Expanded(
    //                       flex: 1,
    //                       child: pw.Container(
    //                         decoration: const pw.BoxDecoration(
    //                           // color: PdfColors.green100,
    //                           border: pw.Border(
    //                             right: pw.BorderSide(color: PdfColors.grey600),
    //                             top: pw.BorderSide(color: PdfColors.grey600),
    //                             bottom: pw.BorderSide(color: PdfColors.grey600),
    //                           ),
    //                         ),
    //                         height: 30,
    //                         child: pw.Column(
    //                           mainAxisAlignment: pw.MainAxisAlignment.center,
    //                           crossAxisAlignment: pw.CrossAxisAlignment.center,
    //                           children: [
    //                             pw.Text(
    //                               'หน่วยละ',
    //                               maxLines: 1,
    //                               textAlign: pw.TextAlign.left,
    //                               style: pw.TextStyle(
    //                                   fontSize: font_Size,
    //                                   font: ttf,
    //                                   color: PdfColors.black),
    //                             ),
    //                             pw.Text(
    //                               'Unit',
    //                               maxLines: 1,
    //                               textAlign: pw.TextAlign.left,
    //                               style: pw.TextStyle(
    //                                   fontSize: font_Size,
    //                                   font: ttf,
    //                                   color: PdfColors.black),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ),
    //                     pw.Expanded(
    //                       flex: 1,
    //                       child: pw.Container(
    //                         decoration: const pw.BoxDecoration(
    //                           // color: PdfColors.green100,
    //                           border: pw.Border(
    //                             right: pw.BorderSide(color: PdfColors.grey600),
    //                             top: pw.BorderSide(color: PdfColors.grey600),
    //                             bottom: pw.BorderSide(color: PdfColors.grey600),
    //                           ),
    //                         ),
    //                         height: 30,
    //                         child: pw.Column(
    //                           mainAxisAlignment: pw.MainAxisAlignment.center,
    //                           crossAxisAlignment: pw.CrossAxisAlignment.center,
    //                           children: [
    //                             pw.Text(
    //                               'ราคา',
    //                               maxLines: 1,
    //                               textAlign: pw.TextAlign.left,
    //                               style: pw.TextStyle(
    //                                   fontSize: font_Size,
    //                                   font: ttf,
    //                                   color: PdfColors.black),
    //                             ),
    //                             pw.Text(
    //                               'Price',
    //                               maxLines: 1,
    //                               textAlign: pw.TextAlign.left,
    //                               style: pw.TextStyle(
    //                                   fontSize: font_Size,
    //                                   font: ttf,
    //                                   color: PdfColors.black),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ),
    //                     pw.Expanded(
    //                       flex: 1,
    //                       child: pw.Container(
    //                         decoration: const pw.BoxDecoration(
    //                           // color: PdfColors.green100,
    //                           border: pw.Border(
    //                             right: pw.BorderSide(color: PdfColors.grey600),
    //                             top: pw.BorderSide(color: PdfColors.grey600),
    //                             bottom: pw.BorderSide(color: PdfColors.grey600),
    //                           ),
    //                         ),
    //                         height: 30,
    //                         child: pw.Column(
    //                           mainAxisAlignment: pw.MainAxisAlignment.center,
    //                           crossAxisAlignment: pw.CrossAxisAlignment.center,
    //                           children: [
    //                             pw.Text(
    //                               'ส่วนลด',
    //                               maxLines: 1,
    //                               textAlign: pw.TextAlign.left,
    //                               style: pw.TextStyle(
    //                                   fontSize: font_Size,
    //                                   font: ttf,
    //                                   color: PdfColors.black),
    //                             ),
    //                             pw.Text(
    //                               'Dis',
    //                               maxLines: 1,
    //                               textAlign: pw.TextAlign.left,
    //                               style: pw.TextStyle(
    //                                   fontSize: font_Size,
    //                                   font: ttf,
    //                                   color: PdfColors.black),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ),
    //                     pw.Expanded(
    //                       flex: 2,
    //                       child: pw.Container(
    //                         decoration: const pw.BoxDecoration(
    //                           // color: PdfColors.green100,
    //                           border: pw.Border(
    //                             // left: pw.BorderSide(color: PdfColors.grey800),
    //                             right: pw.BorderSide(color: PdfColors.grey600),
    //                             top: pw.BorderSide(color: PdfColors.grey600),
    //                             bottom: pw.BorderSide(color: PdfColors.grey600),
    //                           ),
    //                         ),
    //                         height: 30,
    //                         child: pw.Column(
    //                           mainAxisAlignment: pw.MainAxisAlignment.center,
    //                           crossAxisAlignment: pw.CrossAxisAlignment.center,
    //                           children: [
    //                             pw.Text(
    //                               'จำนวนเงิน',
    //                               maxLines: 1,
    //                               textAlign: pw.TextAlign.left,
    //                               style: pw.TextStyle(
    //                                   fontSize: font_Size,
    //                                   font: ttf,
    //                                   color: PdfColors.black),
    //                             ),
    //                             pw.Text(
    //                               'Amount',
    //                               maxLines: 1,
    //                               textAlign: pw.TextAlign.left,
    //                               style: pw.TextStyle(
    //                                   fontSize: font_Size,
    //                                   font: ttf,
    //                                   color: PdfColors.black),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //               // ✅ รายการแตกหน้าได้เอง
    //               pw.ListView.builder(
    //                   itemCount: TransReBillHistory.length,
    //                   itemBuilder: (c, index) {
    //                     final TransReBill = TransReBillHistory[index];

    //                     return pw.Row(
    //                       children: [
    //                         pw.Container(
    //                           decoration: const pw.BoxDecoration(
    //                             color: PdfColors.white,
    //                             border: pw.Border(
    //                               left: pw.BorderSide(color: PdfColors.grey600),
    //                             ),
    //                           ),
    //                           width: 30,
    //                           padding: const pw.EdgeInsets.all(2.0),
    //                           child: pw.Align(
    //                             alignment: pw.Alignment.center,
    //                             child: pw.Text(
    //                               '${index + 1}',
    //                               maxLines: 2,
    //                               textAlign: pw.TextAlign.center,
    //                               style: pw.TextStyle(
    //                                   fontSize: font_Size,
    //                                   font: ttf,
    //                                   color: PdfColors.grey800),
    //                             ),
    //                           ),
    //                         ),
    //                         buildCell(
    //                           text: (TransReBill.zn != null)
    //                               ? (TransReBill.zn!.split('_')[0].length <= 4)
    //                                   ? '${TransReBill.refno}/0${TransReBill.zn!.split('_')[0]}'
    //                                   : '${TransReBill.refno}/${TransReBill.zn!.split('_')[0]}'
    //                               : (TransReBill.fine.toString() == '1.00' &&
    //                                       TransReBill.refno.toString().trim() ==
    //                                           'null')
    //                                   ? (TransReBill.zn!.split('_')[0].length <=
    //                                           4)
    //                                       ? '-/0${TransReBill.zn!.split('_')[0]}'
    //                                       : '-/${TransReBill.zn!.split('_')[0]}'
    //                                   : '${TransReBill.refno}',
    //                           // '${TransReBill.refno}',
    //                           flex: 2,
    //                           alignment: pw.Alignment.centerLeft,
    //                           textAlign: pw.TextAlign.center,
    //                         ),
    //                         buildCell(
    //                           text: (TransReBill.unitser.toString() == '6')
    //                               ? '${TransReBill.expname} [ หน่วยที่ใช้ไป ${TransReBill.ovalue}-${TransReBill.nvalue} ]' //descr
    //                               : '${TransReBill.expname}',
    //                           flex: 4,
    //                           alignment: pw.Alignment.centerLeft,
    //                           textAlign: pw.TextAlign.left,
    //                         ),
    //                         buildCell(
    //                           text: getFormattedText(TransReBill.qty),
    //                           flex: 1,
    //                           alignment: pw.Alignment.centerRight,
    //                           textAlign: pw.TextAlign.right,
    //                         ),
    //                         // buildCell(
    //                         //   text: getFormattedText(TransReBill.pri),
    //                         //   flex: 1,
    //                         //   alignment: pw.Alignment.centerRight,
    //                         //   textAlign: pw.TextAlign.right,
    //                         // ),
    //                         buildCell(
    //                           text: (TransReBill.ele_ty.toString() != '0' &&
    //                                   TransReBill.ele_ty != null)
    //                               ? 'อัตราพิเศษ'
    //                               : (TransReBill.dtype.toString() == 'KU')
    //                                   ? getFormattedText('${TransReBill.pri}')
    //                                   : '-',
    //                           flex: 1,
    //                           alignment: pw.Alignment.centerRight,
    //                           textAlign: pw.TextAlign.right,
    //                         ),
    //                         buildCell(
    //                           text: (double.tryParse(TransReBill.pvat_original
    //                                       .toString()) !=
    //                                   0)
    //                               ? getFormattedText(
    //                                   '${TransReBill.pvat_original}')
    //                               : (TransReBill.dtype.toString() == 'KU')
    //                                   ? getFormattedText('${TransReBill.amt}')
    //                                   : getFormattedText('${TransReBill.pri}'),
    //                           flex: 1,
    //                           alignment: pw.Alignment.centerRight,
    //                           textAlign: pw.TextAlign.right,
    //                         ),
    //                         buildCell(
    //                           text: getFormattedText('${TransReBill.dis_list}'),
    //                           flex: 1,
    //                           alignment: pw.Alignment.centerRight,
    //                           textAlign: pw.TextAlign.right,
    //                         ),
    //                         buildCell(
    //                           text: nFormat.format((double.tryParse(
    //                                       TransReBill.pvat ?? '0') ??
    //                                   0) +
    //                               (double.tryParse(TransReBill.vat ?? '0') ??
    //                                   0)),
    //                           flex: 2,
    //                           alignment: pw.Alignment.centerRight,
    //                           textAlign: pw.TextAlign.right,
    //                         ),
    //                       ],
    //                     );
    //                   }),

    //               pw.Row(
    //                 children: [
    //                   pw.Container(
    //                       // width: 130,
    //                       width: 121.5,
    //                       height: font_Size * 1.7,
    //                       padding: const pw.EdgeInsets.all(2.0),
    //                       decoration: pw.BoxDecoration(
    //                         color: PdfColors.white,
    //                         border: const pw.Border(
    //                           top: pw.BorderSide(color: PdfColors.grey600),
    //                         ),
    //                       )),
    //                   pw.Expanded(
    //                     flex: 1,
    //                     child: pw.Container(
    //                       decoration: const pw.BoxDecoration(
    //                         color: PdfColors.white,
    //                         border: const pw.Border(
    //                           top: pw.BorderSide(color: PdfColors.grey600),
    //                           left: pw.BorderSide(color: PdfColors.grey600),
    //                           bottom: pw.BorderSide(color: PdfColors.grey600),
    //                           // right: pw.BorderSide(color: PdfColors.grey600),
    //                         ),
    //                       ),
    //                       padding: const pw.EdgeInsets.all(2.0),
    //                       child: pw.Text(
    //                         'ส่วนลด',
    //                         style: pw.TextStyle(
    //                             fontSize: font_Size,
    //                             fontWeight: pw.FontWeight.bold,
    //                             font: ttf,
    //                             color: PdfColors.grey800),
    //                       ),
    //                     ),
    //                   ),
    //                   pw.Expanded(
    //                     flex: 1,
    //                     child: pw.Container(
    //                       decoration: const pw.BoxDecoration(
    //                         color: PdfColors.white,
    //                         border: const pw.Border(
    //                           // left: pw.BorderSide(color: PdfColors.grey600),
    //                           top: pw.BorderSide(color: PdfColors.grey600),
    //                           bottom: pw.BorderSide(color: PdfColors.grey600),
    //                           right: pw.BorderSide(color: PdfColors.grey600),
    //                         ),
    //                       ),
    //                       padding: const pw.EdgeInsets.all(2.0),
    //                       child: pw.Text(
    //                         '${nFormat.format(totalDis)}',
    //                         // '${nFormat.format(double.parse(sum_net_non_pvat.toString()) + double.parse(sum_net_amount_pvat.toString()) - double.parse(DisC.toString()))}', // 1+2-3
    //                         // '${nFormat.format(double.parse(DisC.toString()))}', //
    //                         textAlign: pw.TextAlign.right,
    //                         style: pw.TextStyle(
    //                             fontSize: font_Size,
    //                             fontWeight: pw.FontWeight.bold,
    //                             font: ttf,
    //                             color: PdfColors.grey800),
    //                       ),
    //                     ),
    //                   ),
    //                 ],
    //               ),

    //               pw.Container(
    //                 decoration: const pw.BoxDecoration(
    //                   // color: PdfColors.white,
    //                   border: const pw.Border(
    //                       // top: pw.BorderSide(color: PdfColors.grey600),
    //                       // left: pw.BorderSide(color: PdfColors.grey600),
    //                       ),
    //                 ),
    //                 // padding: const pw.EdgeInsets.fromLTRB(0, 4, 0, 0),
    //                 alignment: pw.Alignment.centerRight,
    //                 child: pw.Row(
    //                   crossAxisAlignment: pw.CrossAxisAlignment.start,
    //                   children: [
    //                     if (Con_remark.toString() != '' && Con_remark != null)
    //                       pw.Container(
    //                         padding: const pw.EdgeInsets.all(4.0),
    //                         child: pw.Text(
    //                           '# หมายเหตุ : $Con_remark',
    //                           style: pw.TextStyle(
    //                               fontSize: font_Size,
    //                               fontWeight: pw.FontWeight.bold,
    //                               font: ttf,
    //                               color: PdfColors.grey800),
    //                         ),
    //                       ),
    //                     pw.Container(width: 30),
    //                     pw.Spacer(flex: 7),
    //                     pw.Expanded(
    //                       flex: 5,
    //                       child: pw.Column(
    //                         crossAxisAlignment: pw.CrossAxisAlignment.start,
    //                         children: [
    //                           pw.Row(
    //                             children: [
    //                               pw.Expanded(
    //                                 flex: 3,
    //                                 child: pw.Container(
    //                                   decoration: const pw.BoxDecoration(
    //                                     color: PdfColors.white,
    //                                     border: const pw.Border(
    //                                       top: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       left: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       bottom: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       right: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                     ),
    //                                   ),
    //                                   padding: const pw.EdgeInsets.all(2.0),
    //                                   child: pw.Text(
    //                                     'รวมราคาสินค้า ไม่มี/ยกเว้นภาษี',
    //                                     style: pw.TextStyle(
    //                                         fontSize: font_Size,
    //                                         fontWeight: pw.FontWeight.bold,
    //                                         font: ttf,
    //                                         color: PdfColors.grey800),
    //                                   ),
    //                                 ),
    //                               ),
    //                               pw.Expanded(
    //                                 flex: 2,
    //                                 child: pw.Container(
    //                                   decoration: const pw.BoxDecoration(
    //                                     color: PdfColors.white,
    //                                     border: const pw.Border(
    //                                       left: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       top: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       right: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       bottom: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                     ),
    //                                   ),
    //                                   padding: const pw.EdgeInsets.all(2.0),
    //                                   child: pw.Text(
    //                                     // '${nFormat.format(sum_Nonvat == null ? 0.00 : double.parse(sum_Nonvat.toString()))}',
    //                                     // '${roundToTwoDecimals('${double.parse(sum_pvat.toString())}')}',
    //                                     // (round_p.toString() == '1')
    //                                     //     ? (amt_up == null)
    //                                     //         ? '0.00'
    //                                     //         : '${nFormat.format(double.parse(amt_up.toString()))}'
    //                                     //     : '${nFormat.format(double.parse(sum_pvat.toString()))}',
    //                                     '${nFormat.format(net_non_pvat)}',
    //                                     textAlign: pw.TextAlign.right,
    //                                     style: pw.TextStyle(
    //                                         fontSize: font_Size,
    //                                         fontWeight: pw.FontWeight.bold,
    //                                         font: ttf,
    //                                         color: PdfColors.grey800),
    //                                   ),
    //                                 ),
    //                               ),
    //                             ],
    //                           ),
    //                           pw.Row(
    //                             children: [
    //                               pw.Expanded(
    //                                 flex: 3,
    //                                 child: pw.Container(
    //                                   decoration: const pw.BoxDecoration(
    //                                     color: PdfColors.white,
    //                                     border: const pw.Border(
    //                                       top: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       left: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       bottom: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       right: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                     ),
    //                                   ),
    //                                   padding: const pw.EdgeInsets.all(2.0),
    //                                   child: pw.Text(
    //                                     'จำนวนเงินรวมทั้งสิ้น',
    //                                     style: pw.TextStyle(
    //                                         fontSize: font_Size,
    //                                         fontWeight: pw.FontWeight.bold,
    //                                         font: ttf,
    //                                         color: PdfColors.grey800),
    //                                   ),
    //                                 ),
    //                               ),
    //                               pw.Expanded(
    //                                 flex: 2,
    //                                 child: pw.Container(
    //                                   decoration: const pw.BoxDecoration(
    //                                     color: PdfColors.white,
    //                                     border: const pw.Border(
    //                                       left: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       top: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       bottom: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       right: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                     ),
    //                                   ),
    //                                   padding: const pw.EdgeInsets.all(2.0),
    //                                   child: pw.Text(
    //                                     // '${nFormat.format(Total == null ? 0.00 : double.parse(Total.toString()))}',
    //                                     // '${nFormat.format(((totalPvat + totalVat) - totalWht) + totalFee)}',
    //                                     // '${nFormat.format(((totalPvat + totalVat) - totalWht) + totalFee)}',
    //                                     '${nFormat.format(totalPvat + totalVat)}',
    //                                     // ('${TransReBill.total}'),

    //                                     // '${nFormat.format((double.parse(Total.toString()) + double.parse(sum_fee.toString())) - (double.parse(dis_sum_Matjum.toString()) + double.parse(dis_sum_Pakan.toString())))}',
    //                                     // (nFormat.format(double.parse(
    //                                     //             dis_sum_Matjum
    //                                     //                 .toString())) !=
    //                                     //         '0.00')
    //                                     //     ? '${nFormat.format(double.parse(dis_sum_Matjum.toString()) - double.parse(sum_addvat_choice.toString()) * 1.07)}' //dis_sum_Matjum
    //                                     //     : (nFormat.format(double.parse(
    //                                     //                 dis_sum_Pakan
    //                                     //                     .toString())) !=
    //                                     //             '0.00')
    //                                     //         ? '${nFormat.format(double.parse(dis_sum_Pakan.toString()) - double.parse(sum_addvat_choice.toString()) * 1.07)}'
    //                                     //         : '${nFormat.format((double.parse(sum_addvat_choice.toString()) - double.parse(sum_disamt.toString())) * 1.07)}',
    //                                     textAlign: pw.TextAlign.right,
    //                                     style: pw.TextStyle(
    //                                         fontSize: font_Size,
    //                                         fontWeight: pw.FontWeight.bold,
    //                                         font: ttf,
    //                                         color: PdfColors.grey800),
    //                                   ),
    //                                 ),
    //                               ),
    //                             ],
    //                           ),
    //                           pw.Row(
    //                             children: [
    //                               pw.Expanded(
    //                                 flex: 3,
    //                                 child: pw.Container(
    //                                   decoration: const pw.BoxDecoration(
    //                                     color: PdfColors.white,
    //                                     border: const pw.Border(
    //                                       top: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       left: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       bottom: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       right: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                     ),
    //                                   ),
    //                                   padding: const pw.EdgeInsets.all(2.0),
    //                                   child: pw.Text(
    //                                     'รวมราคาสินค้าคำนวณภาษีมูลค่าเพิ่ม',
    //                                     style: pw.TextStyle(
    //                                         fontSize: font_Size,
    //                                         fontWeight: pw.FontWeight.bold,
    //                                         font: ttf,
    //                                         color: PdfColors.grey800),
    //                                   ),
    //                                 ),
    //                               ),
    //                               pw.Expanded(
    //                                 flex: 2,
    //                                 child: pw.Container(
    //                                   decoration: const pw.BoxDecoration(
    //                                     color: PdfColors.white,
    //                                     border: const pw.Border(
    //                                       left: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       top: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       right: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       bottom: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                     ),
    //                                   ),
    //                                   padding: const pw.EdgeInsets.all(2.0),
    //                                   child: pw.Text(
    //                                     // '${nFormat.format(((double.parse(Total.toString()) * 100 / 107) + double.parse(sum_fee.toString())) - (double.parse(dis_sum_Matjum.toString()) + double.parse(dis_sum_Pakan.toString())))}',

    //                                     // '${nFormat.format(double.parse(Sum_SubTotal.toString()))}',
    //                                     // '${nFormat.format(double.parse(sum_addvat.toString()))}',
    //                                     // (nFormat.format(double.parse(
    //                                     //             sum_addvat.toString())) !=
    //                                     //         '0.00')
    //                                     //     ? '${nFormat.format(((double.parse(Total.toString()) * 100 / 107) + double.parse(sum_fee.toString())) - (double.parse(dis_sum_Matjum.toString()) + double.parse(dis_sum_Pakan.toString())))}'
    //                                     //     : '${nFormat.format(double.parse(sum_addvat.toString()))}',

    //                                     // '${nFormat.format(net_amount_pvat)}',
    //                                     '${nFormat.format(net_amount_pvat)}',

    //                                     ///
    //                                     textAlign: pw.TextAlign.right,
    //                                     style: pw.TextStyle(
    //                                         fontSize: font_Size,
    //                                         fontWeight: pw.FontWeight.bold,
    //                                         font: ttf,
    //                                         color: PdfColors.grey800),
    //                                   ),
    //                                 ),
    //                               ),
    //                             ],
    //                           ),

    //                           // pw.Row(
    //                           //   children: [
    //                           //     pw.Expanded(
    //                           //       flex: 1,
    //                           //       child: pw.Container(
    //                           //         decoration: const pw.BoxDecoration(
    //                           //           color: PdfColors.white,
    //                           //           border: const pw.Border(
    //                           //             top: pw.BorderSide(
    //                           //                 color: PdfColors.grey600),
    //                           //             left: pw.BorderSide(
    //                           //                 color: PdfColors.grey600),
    //                           //             bottom: pw.BorderSide(
    //                           //                 color: PdfColors.grey600),
    //                           //             right: pw.BorderSide(
    //                           //                 color: PdfColors.grey600),
    //                           //           ),
    //                           //         ),
    //                           //         padding: const pw.EdgeInsets.all(2.0),
    //                           //         child: pw.Text(
    //                           //           'จำนวนเงินหลังหักส่วนลด',
    //                           //           style: pw.TextStyle(
    //                           //               fontSize: font_Size,
    //                           //               fontWeight: pw.FontWeight.bold,
    //                           //               font: ttf,
    //                           //               color: PdfColors.grey800),
    //                           //         ),
    //                           //       ),
    //                           //     ),
    //                           //     pw.Expanded(
    //                           //       flex: 1,
    //                           //       child: pw.Container(
    //                           //         decoration: const pw.BoxDecoration(
    //                           //           color: PdfColors.white,
    //                           //           border: const pw.Border(
    //                           //             left: pw.BorderSide(
    //                           //                 color: PdfColors.grey600),
    //                           //             top: pw.BorderSide(
    //                           //                 color: PdfColors.grey600),
    //                           //             bottom: pw.BorderSide(
    //                           //                 color: PdfColors.grey600),
    //                           //             right: pw.BorderSide(
    //                           //                 color: PdfColors.grey600),
    //                           //           ),
    //                           //         ),
    //                           //         padding: const pw.EdgeInsets.all(2.0),
    //                           //         child: pw.Text(
    //                           //           (nFormat.format(double.parse(
    //                           //                       dis_sum_Matjum
    //                           //                           .toString())) !=
    //                           //                   '0.00')
    //                           //               ? '${nFormat.format(double.parse(dis_sum_Matjum.toString()) - double.parse(sum_disamt.toString()))}' //dis_sum_Matjum
    //                           //               : (nFormat.format(double.parse(
    //                           //                           dis_sum_Pakan
    //                           //                               .toString())) !=
    //                           //                       '0.00')
    //                           //                   ? '${nFormat.format(double.parse(dis_sum_Pakan.toString()) - double.parse(sum_disamt.toString()))}'
    //                           //                   : '${nFormat.format(double.parse(sum_addvat_choice.toString()) - double.parse(sum_disamt.toString()))}',
    //                           //           textAlign: pw.TextAlign.right,
    //                           //           style: pw.TextStyle(
    //                           //             fontSize: font_Size,
    //                           //             fontWeight: pw.FontWeight.bold,
    //                           //             font: ttf,
    //                           //             color: PdfColors.grey800,
    //                           //           ),
    //                           //         ),
    //                           //       ),
    //                           //     ),
    //                           //   ],
    //                           // ),
    //                           pw.Row(
    //                             children: [
    //                               pw.Expanded(
    //                                 flex: 3,
    //                                 child: pw.Container(
    //                                   decoration: const pw.BoxDecoration(
    //                                     color: PdfColors.white,
    //                                     border: const pw.Border(
    //                                       top: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       left: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       bottom: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       right: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                     ),
    //                                   ),
    //                                   padding: const pw.EdgeInsets.all(2.0),
    //                                   child: pw.Text(
    //                                     'ภาษีมูลค่าเพิ่ม 7%/ Vat',
    //                                     style: pw.TextStyle(
    //                                         fontSize: font_Size,
    //                                         fontWeight: pw.FontWeight.bold,
    //                                         font: ttf,
    //                                         color: PdfColors.grey800),
    //                                   ),
    //                                 ),
    //                               ),
    //                               pw.Expanded(
    //                                 flex: 2,
    //                                 child: pw.Container(
    //                                   decoration: const pw.BoxDecoration(
    //                                     color: PdfColors.white,
    //                                     border: const pw.Border(
    //                                       left: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       top: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       right: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       bottom: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                     ),
    //                                   ),
    //                                   padding: const pw.EdgeInsets.all(2.0),
    //                                   child: pw.Text(
    //                                     // (round_p.toString() == '1')
    //                                     //     ? (vat_up == null
    //                                     //         ? '0.00'
    //                                     //         : '${nFormat.format(double.parse(vat_up.toString()))}')
    //                                     // : '${nFormat.format(double.parse(sum_vat.toString()))}',

    //                                     ///
    //                                     //  : '${nFormat.format(double.parse(Total.toString()) * 7 / 100)}',
    //                                     // : '${nFormat.format((((double.parse(Total.toString()) * 100 / 107) * 7 / 100) + double.parse(sum_fee.toString())) - (double.parse(dis_sum_Matjum.toString()) + double.parse(dis_sum_Pakan.toString())))}',

    //                                     // : '${nFormat.format((double.parse(roundToTwoDecimals('${double.parse(sum_pvat.toString())}')) * 7) / 100)}', //pvat

    //                                     // // : '${nFormat.format((double.parse(sum_addvat_choice.toString()) * 7) / 100)}',
    //                                     // (nFormat.format(double.parse(
    //                                     //             sum_addvat.toString())) !=
    //                                     //         '0.00')
    //                                     //     ? '${nFormat.format((((double.parse(Total.toString()) * 100 / 107) * 7 / 100) + double.parse(sum_fee.toString())) - (double.parse(dis_sum_Matjum.toString()) + double.parse(dis_sum_Pakan.toString())))}'
    //                                     //     : '${nFormat.format(double.parse(sum_addvat.toString()))}',
    //                                     '${nFormat.format(totalVat)}',
    //                                     textAlign: pw.TextAlign.right,
    //                                     style: pw.TextStyle(
    //                                         fontSize: font_Size,
    //                                         fontWeight: pw.FontWeight.bold,
    //                                         font: ttf,
    //                                         color: PdfColors.grey800),
    //                                   ),
    //                                 ),
    //                               ),
    //                             ],
    //                           ),

    //                           pw.Row(
    //                             children: [
    //                               pw.Expanded(
    //                                 flex: 3,
    //                                 child: pw.Container(
    //                                   decoration: const pw.BoxDecoration(
    //                                     color: PdfColors.white,
    //                                     border: const pw.Border(
    //                                       top: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       left: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       bottom: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       right: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                     ),
    //                                   ),
    //                                   padding: const pw.EdgeInsets.all(2.0),
    //                                   child: pw.Text(
    //                                     'หัก ณ ที่จ่าย / Withholding ',
    //                                     style: pw.TextStyle(
    //                                         fontSize: font_Size,
    //                                         fontWeight: pw.FontWeight.bold,
    //                                         font: ttf,
    //                                         color: PdfColors.grey800),
    //                                   ),
    //                                 ),
    //                               ),
    //                               pw.Expanded(
    //                                 flex: 2,
    //                                 child: pw.Container(
    //                                   decoration: const pw.BoxDecoration(
    //                                     color: PdfColors.white,
    //                                     border: const pw.Border(
    //                                       left: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       top: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       bottom: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       right: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                     ),
    //                                   ),
    //                                   padding: const pw.EdgeInsets.all(2.0),
    //                                   child: pw.Text(
    //                                     // '${nFormat.format(double.parse(sum_wht.toString()))}',
    //                                     '${nFormat.format(totalWht)}',
    //                                     textAlign: pw.TextAlign.right,
    //                                     style: pw.TextStyle(
    //                                         fontSize: font_Size,
    //                                         fontWeight: pw.FontWeight.bold,
    //                                         font: ttf,
    //                                         color: PdfColors.grey800),
    //                                   ),
    //                                 ),
    //                               ),
    //                             ],
    //                           ),
    //                           pw.Row(
    //                             children: [
    //                               pw.Expanded(
    //                                 flex: 3,
    //                                 child: pw.Container(
    //                                   decoration: const pw.BoxDecoration(
    //                                     color: PdfColors.white,
    //                                     border: const pw.Border(
    //                                       top: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       left: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       bottom: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       right: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                     ),
    //                                   ),
    //                                   padding: const pw.EdgeInsets.all(2.0),
    //                                   child: pw.Text(
    //                                     'ค่าธรรมเนียม / Fees',
    //                                     style: pw.TextStyle(
    //                                         fontSize: font_Size,
    //                                         fontWeight: pw.FontWeight.bold,
    //                                         font: ttf,
    //                                         color: PdfColors.grey800),
    //                                   ),
    //                                 ),
    //                               ),
    //                               pw.Expanded(
    //                                 flex: 2,
    //                                 child: pw.Container(
    //                                   decoration: const pw.BoxDecoration(
    //                                     color: PdfColors.white,
    //                                     border: const pw.Border(
    //                                       left: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       top: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       bottom: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       right: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                     ),
    //                                   ),
    //                                   padding: const pw.EdgeInsets.all(2.0),
    //                                   child: pw.Text(
    //                                     // '${nFormat.format(double.parse(sum_fee.toString()))}',
    //                                     '${nFormat.format(totalFee)}',
    //                                     textAlign: pw.TextAlign.right,
    //                                     style: pw.TextStyle(
    //                                         fontSize: font_Size,
    //                                         fontWeight: pw.FontWeight.bold,
    //                                         font: ttf,
    //                                         color: PdfColors.grey800),
    //                                   ),
    //                                 ),
    //                               ),
    //                             ],
    //                           ),
    //                           pw.Row(
    //                             children: [
    //                               pw.Expanded(
    //                                 flex: 3,
    //                                 child: pw.Container(
    //                                   decoration: const pw.BoxDecoration(
    //                                     color: PdfColors.white,
    //                                     border: const pw.Border(
    //                                       top: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       left: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       bottom: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       right: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                     ),
    //                                   ),
    //                                   padding: const pw.EdgeInsets.all(2.0),
    //                                   child: pw.Text(
    //                                     'ยอดชำระ / Payment Amount',
    //                                     style: pw.TextStyle(
    //                                         fontSize: font_Size,
    //                                         fontWeight: pw.FontWeight.bold,
    //                                         font: ttf,
    //                                         color: PdfColors.grey800),
    //                                   ),
    //                                 ),
    //                               ),
    //                               pw.Expanded(
    //                                 flex: 2,
    //                                 child: pw.Container(
    //                                   decoration: const pw.BoxDecoration(
    //                                     color: PdfColors.white,
    //                                     border: const pw.Border(
    //                                       left: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       top: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       bottom: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                       right: pw.BorderSide(
    //                                           color: PdfColors.grey600),
    //                                     ),
    //                                   ),
    //                                   padding: const pw.EdgeInsets.all(2.0),
    //                                   child: pw.Text(
    //                                     '${nFormat.format(totalBill)}',
    //                                     // '${nFormat.format((double.parse(Total.toString()) + double.parse(sum_fee.toString())) - (double.parse(dis_sum_Matjum.toString()) + double.parse(dis_sum_Pakan.toString())))}',
    //                                     // '${nFormat.format(double.parse(Total.toString()) - double.parse(dis_sum_Matjum.toString()) - double.parse(dis_sum_Pakan.toString()))}',
    //                                     // (nFormat.format(double.parse(
    //                                     //             dis_sum_Matjum
    //                                     //                 .toString())) !=
    //                                     //         '0.00')
    //                                     //     ? '${nFormat.format(double.parse(dis_sum_Matjum.toString()) + double.parse(dis_sum_Matjum.toString()) * 1.07)}'
    //                                     //     : (nFormat.format(double.parse(
    //                                     //                 dis_sum_Pakan
    //                                     //                     .toString())) !=
    //                                     //             '0.00')
    //                                     //         ? '${nFormat.format(double.parse(dis_sum_Pakan.toString()) + double.parse(dis_sum_Pakan.toString()) * 1.07)}'
    //                                     //         : '${nFormat.format((double.parse(sum_Nonvat_choice.toString()) + double.parse(sum_addvat_choice.toString()) - double.parse(sum_disamt.toString())) * 1.07)}',
    //                                     textAlign: pw.TextAlign.right,
    //                                     style: pw.TextStyle(
    //                                         fontSize: font_Size,
    //                                         fontWeight: pw.FontWeight.bold,
    //                                         font: ttf,
    //                                         color: PdfColors.grey800),
    //                                   ),
    //                                 ),
    //                               ),
    //                             ],
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //               // pw.SizedBox(height: 2 * PdfPageFormat.mm),
    //               pw.Container(
    //                   height: 25,
    //                   decoration: const pw.BoxDecoration(
    //                     // color: PdfColors.green100,
    //                     border: pw.Border(
    //                       top: pw.BorderSide(color: PdfColors.grey600),
    //                       bottom: pw.BorderSide(color: PdfColors.grey600),
    //                     ),
    //                   ),
    //                   alignment: pw.Alignment.centerRight,
    //                   child: pw.Center(
    //                     child: pw.Row(
    //                       children: [
    //                         pw.SizedBox(width: 2 * PdfPageFormat.mm),
    //                         pw.Text(
    //                           'ตัวอักษร ',
    //                           style: pw.TextStyle(
    //                               fontSize: font_Size,
    //                               fontWeight: pw.FontWeight.bold,
    //                               font: ttf,
    //                               fontStyle: pw.FontStyle.italic,
    //                               color: PdfColors.grey800),
    //                         ),
    //                         pw.Expanded(
    //                           flex: 4,
    //                           child: pw.Text(
    //                             '(~${convertToThaiBaht(totalBill)}~)',

    //                             /// "${nFormat2.format(double.parse(Total.toString()))}",
    //                             ///
    //                             ///       '(~${convertToThaiBaht(double.parse(Total.toString()) - double.parse(dis_sum_Matjum.toString()))}~)',
    //                             // '(~${convertToThaiBaht(double.parse(Total.toString()) + double.parse(sum_fee.toString()))}~)',
    //                             // (nFormat.format(double.parse(
    //                             //             dis_sum_Matjum.toString())) !=
    //                             //         '0.00')
    //                             //     ? '(~${convertToThaiBaht(double.parse(dis_sum_Matjum.toString()) + double.parse(dis_sum_Matjum.toString()) * 1.07)}~)'
    //                             //     : (nFormat.format(double.parse(
    //                             //                 dis_sum_Pakan.toString())) !=
    //                             //             '0.00')
    //                             //         ? '(~${convertToThaiBaht(double.parse(dis_sum_Pakan.toString()) + double.parse(dis_sum_Pakan.toString()) * 1.07)}~)'
    //                             //         : '(~${convertToThaiBaht((double.parse(sum_Nonvat_choice.toString()) + double.parse(sum_addvat_choice.toString()) - double.parse(sum_disamt.toString())) * 1.07)}~)',
    //                             style: pw.TextStyle(
    //                               fontSize: font_Size,
    //                               fontWeight: pw.FontWeight.bold,
    //                               font: ttf,
    //                               fontStyle: pw.FontStyle.italic,
    //                               // decoration:
    //                               //     pw.TextDecoration.lineThrough,
    //                               color: PdfColors.grey800,
    //                             ),
    //                           ),
    //                         ),
    //                         // pw.Spacer(flex: 6),
    //                         pw.Expanded(
    //                           flex: 2,
    //                           child: pw.Column(
    //                             mainAxisAlignment: pw.MainAxisAlignment.center,
    //                             crossAxisAlignment: pw.CrossAxisAlignment.start,
    //                             children: [
    //                               pw.Row(
    //                                 children: [
    //                                   pw.Expanded(
    //                                     flex: 2,
    //                                     child: pw.Text(
    //                                       'ยอดรวมสุทธิ',
    //                                       textAlign: pw.TextAlign.left,
    //                                       style: pw.TextStyle(
    //                                           fontWeight: pw.FontWeight.bold,
    //                                           font: ttf,
    //                                           fontSize: font_Size,
    //                                           color: PdfColors.grey800),
    //                                     ),
    //                                   ),
    //                                   pw.Text(
    //                                     // '${nFormat.format(double.parse(Total.toString()) + double.parse(sum_fee.toString()))}',
    //                                     '${nFormat.format(totalBill)}',
    //                                     // (nFormat.format(double.parse(
    //                                     //             dis_sum_Matjum
    //                                     //                 .toString())) !=
    //                                     //         '0.00')
    //                                     //     ? '${nFormat.format(double.parse(dis_sum_Matjum.toString()) + double.parse(dis_sum_Matjum.toString()) * 1.07)}'
    //                                     //     : (nFormat.format(double.parse(
    //                                     //                 dis_sum_Pakan
    //                                     //                     .toString())) !=
    //                                     //             '0.00')
    //                                     //         ? '${nFormat.format(double.parse(dis_sum_Pakan.toString()) + double.parse(dis_sum_Pakan.toString()) * 1.07)}'
    //                                     //         : '${nFormat.format((double.parse(sum_Nonvat_choice.toString()) + double.parse(sum_addvat_choice.toString()) - double.parse(sum_disamt.toString())) * 1.07)}',
    //                                     // '${Total}',
    //                                     style: pw.TextStyle(
    //                                         fontWeight: pw.FontWeight.bold,
    //                                         font: ttf,
    //                                         fontSize: font_Size,
    //                                         color: PdfColors.grey800),
    //                                   ),
    //                                 ],
    //                               ),
    //                             ],
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                   )),
    //               pw.SizedBox(height: 5 * PdfPageFormat.mm),
    //             ])),
    //       ];
    //     },

    //     // for (int index = (page * 15);
    //     //                   index <
    //     //                       (((page * 15) + 15 > tableData00.length)
    //     //                           ? tableData00.length
    //     //                           : (page * 15) + 15);
    //     //                   index++)

    //     footer: (context) {
    //       return pw.Column(
    //         mainAxisSize: pw.MainAxisSize.min,
    //         children: [
    //           pw.Padding(
    //             padding: pw.EdgeInsets.fromLTRB(8, 0, 8, 0),
    //             child: pw.Stack(children: [
    //               pw.Positioned(
    //                   top: 4,
    //                   left: 0,
    //                   child: pw.Container(
    //                     width: 300,
    //                     height: 300,
    //                     decoration: pw.BoxDecoration(
    //                       image: pw.DecorationImage(
    //                         image: pw.MemoryImage(
    //                           imageBG,
    //                         ),
    //                         fit: pw.BoxFit.cover,
    //                       ),
    //                       // border:
    //                       //     pw.Border.all(color: PdfColors.grey, width: 1),
    //                     ),
    //                   )),
    //               pw.Positioned(
    //                   bottom: 4,
    //                   right: 0,
    //                   child: pw.Container(
    //                     width: 200,
    //                     height: 30,
    //                     decoration: pw.BoxDecoration(
    //                       image: pw.DecorationImage(
    //                         image: pw.MemoryImage(
    //                           imageBG,
    //                         ),
    //                         fit: pw.BoxFit.cover,
    //                       ),
    //                       // border:
    //                       //     pw.Border.all(color: PdfColors.grey, width: 1),
    //                     ),
    //                   )),
    //               pw.Container(
    //                   decoration: pw.BoxDecoration(
    //                     border: pw.Border.all(color: PdfColors.grey, width: 1),
    //                   ),
    //                   padding: pw.EdgeInsets.fromLTRB(2, 4, 2, 4),
    //                   child: pw.Row(
    //                     children: [
    //                       pw.Expanded(
    //                           flex: 2,
    //                           child: pw.Column(
    //                               mainAxisAlignment: pw.MainAxisAlignment.start,
    //                               crossAxisAlignment:
    //                                   pw.CrossAxisAlignment.start,
    //                               children: [
    //                                 pw.Text(
    //                                   'หมายเหตุ : ',
    //                                   textAlign: pw.TextAlign.left,
    //                                   style: pw.TextStyle(
    //                                     fontSize: font_Size,
    //                                     font: ttf,
    //                                     fontWeight: pw.FontWeight.bold,
    //                                     color: Colors_pd,
    //                                   ),
    //                                 ),
    //                                 pw.Text(
    //                                   (hasNonCashTransaction)
    //                                       ? '( / ) 1. เงินโอน, QR Code, Mobile Banking '
    //                                       : '(   ) 1. เงินโอน, QR Code, Mobile Banking ',
    //                                   textAlign: pw.TextAlign.left,
    //                                   style: pw.TextStyle(
    //                                     fontSize: font_Size,
    //                                     font: ttf,
    //                                     fontWeight: pw.FontWeight.bold,
    //                                     color: Colors_pd,
    //                                   ),
    //                                 ),
    //                                 pw.Text(
    //                                   (hasNonCashTransaction)
    //                                       ? '      บัญชี ${finnancetransModels.where((model) => model.dtype == 'KP' && model.ptser != null && model.ptser != '1').map((model) => model.bank).join(', ')} เลขที่ ${finnancetransModels.where((model) => model.dtype == 'KP' && model.ptser != null && model.ptser != '1').map((model) => model.bno).join(', ')} [ ${finnancetransModels.where((model) => model.dtype == 'KP' && model.ptser != null && model.ptser != '1').map((model) => (model.ptname.toString() == 'Online Payment' ? 'PromptPay QR' : model.ptname == 'เงินโอน' ? 'เลขบัญชี' : model.ptname == 'Beam Checkout' ? 'Beam Checkout' : model.ptname == 'Online Standard QR' ? 'Online Standard QR' : '${model.ptname}')).join(', ')} ]'
    //                                       : '      บัญชี...................................เลขที่...................................',
    //                                   textAlign: pw.TextAlign.left,
    //                                   style: pw.TextStyle(
    //                                     fontSize: font_Size,
    //                                     font: ttf,
    //                                     fontWeight: pw.FontWeight.bold,
    //                                     color: Colors_pd,
    //                                   ),
    //                                 ),
    //                                 if (hasNonCashTransaction8)
    //                                   pw.Text(
    //                                     hasNonCashTransaction7
    //                                         ? '      ( Ref1. ${finnancetransModels.where((model) => model.dtype == 'KP' && model.ptser != null && model.ptser != '1').map((model) => model.inv.replaceAll('-', '')).join(', ')} Ref2. ${DateFormat('ddMM').format(DateTime.parse(dayfinpay!))}${DateTime.parse('${dayfinpay}').year + 543} )'
    //                                         : '      ( Ref1. ${finnancetransModels.where((model) => model.dtype == 'KP' && model.ptser != null && model.ptser != '1').map((model) => model.ref1).join(', ')} Ref2. ${DateFormat('ddMM').format(DateTime.parse(dayfinpay!))}${DateTime.parse('${dayfinpay}').year + 543} )',
    //                                     textAlign: pw.TextAlign.left,
    //                                     style: pw.TextStyle(
    //                                       fontSize: font_Size,
    //                                       font: ttf,
    //                                       fontWeight: pw.FontWeight.bold,
    //                                       color: Colors_pd,
    //                                     ),
    //                                   ),
    //                                 pw.Row(
    //                                   // mainAxisAlignment:
    //                                   //     pw.MainAxisAlignment.spaceBetween,
    //                                   children: [
    //                                     pw.Expanded(
    //                                       flex: 1,
    //                                       child: pw.Text(
    //                                         (hasNonCashTransaction1)
    //                                             ? '( / ) 2. เงินสด'
    //                                             : '(   ) 2. เงินสด',
    //                                         textAlign: pw.TextAlign.left,
    //                                         style: pw.TextStyle(
    //                                           fontSize: font_Size,
    //                                           font: ttf,
    //                                           fontWeight: pw.FontWeight.bold,
    //                                           color: Colors_pd,
    //                                         ),
    //                                       ),
    //                                     ),
    //                                     pw.Expanded(
    //                                       flex: 3,
    //                                       child: pw.Text(
    //                                         (hasNonCashTransaction ||
    //                                                 hasNonCashTransaction1)
    //                                             ? '(   ) 3. อื่นๆ.............................'
    //                                             : '( / ) 3. อื่นๆ ${finnancetransModels.where((model) => model.ptser != '6' || model.ptser != '5' || model.ptser != '2' || model.ptser != '1' && model.dtype == 'KP').map((model) => model.bank).join(', ')}',
    //                                         textAlign: pw.TextAlign.left,
    //                                         style: pw.TextStyle(
    //                                           fontSize: font_Size,
    //                                           font: ttf,
    //                                           fontWeight: pw.FontWeight.bold,
    //                                           color: Colors_pd,
    //                                         ),
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 )
    //                               ])),
    //                       pw.Expanded(
    //                           flex: 1,
    //                           child: pw.Column(
    //                               mainAxisAlignment: pw.MainAxisAlignment.start,
    //                               // crossAxisAlignment: pw.CrossAxisAlignment.center,
    //                               children: [
    //                                 pw.Container(
    //                                   width: 200,
    //                                   // decoration: const pw.BoxDecoration(
    //                                   //   // color: PdfColors.green100,
    //                                   //   border: pw.Border(
    //                                   //     bottom: pw.BorderSide(
    //                                   //         width: 0.5, color: PdfColors.grey600),
    //                                   //   ),
    //                                   // ),
    //                                   padding: const pw.EdgeInsets.fromLTRB(
    //                                       4, 0, 4, 0),
    //                                   child: pw.Row(
    //                                     crossAxisAlignment:
    //                                         pw.CrossAxisAlignment.end,
    //                                     // mainAxisAlignment:
    //                                     //     pw.MainAxisAlignment.spaceBetween,
    //                                     children: [
    //                                       pw.Expanded(
    //                                         flex: 1,
    //                                         child: pw.Text(
    //                                           'ลงชื่อ : ',
    //                                           textAlign: pw.TextAlign.left,
    //                                           style: pw.TextStyle(
    //                                             fontSize: font_Size,
    //                                             font: ttf,
    //                                             fontWeight: pw.FontWeight.bold,
    //                                             color: Colors_pd,
    //                                           ),
    //                                         ),
    //                                       ),
    //                                       pw.Expanded(
    //                                         flex: 2,
    //                                         child: (imageBytes_manager.isEmpty)
    //                                             ? pw.Container(
    //                                                 // width: 120,
    //                                                 decoration:
    //                                                     const pw.BoxDecoration(
    //                                                   // color: PdfColors.green100,
    //                                                   border: pw.Border(
    //                                                     bottom: pw.BorderSide(
    //                                                         width: 0.5,
    //                                                         color: PdfColors
    //                                                             .grey600),
    //                                                   ),
    //                                                 ),
    //                                                 padding:
    //                                                     const pw.EdgeInsets.all(
    //                                                         8.0),
    //                                                 height: 30,
    //                                               )
    //                                             : pw.Container(
    //                                                 // width: 120,
    //                                                 decoration:
    //                                                     const pw.BoxDecoration(
    //                                                   // color: PdfColors.green100,
    //                                                   border: pw.Border(
    //                                                     bottom: pw.BorderSide(
    //                                                         width: 0.5,
    //                                                         color: PdfColors
    //                                                             .grey600),
    //                                                   ),
    //                                                 ),
    //                                                 padding:
    //                                                     const pw.EdgeInsets.all(
    //                                                         8.0),
    //                                                 child: pw.Center(
    //                                                   child: pw.Image(
    //                                                     pw.MemoryImage(
    //                                                         imageBytes_manager),
    //                                                     height: 20,
    //                                                     width: 100,
    //                                                   ),
    //                                                 ),
    //                                               ),
    //                                       ),
    //                                       pw.Expanded(
    //                                         flex: 2,
    //                                         child: pw.Text(
    //                                           ' เจ้าหน้าที่/พนักงาน',
    //                                           textAlign: pw.TextAlign.left,
    //                                           style: pw.TextStyle(
    //                                             fontSize: font_Size,
    //                                             font: ttf,
    //                                             fontWeight: pw.FontWeight.bold,
    //                                             color: Colors_pd,
    //                                           ),
    //                                         ),
    //                                       ),
    //                                     ],
    //                                   ),
    //                                 ),
    //                                 pw.SizedBox(
    //                                   height: 3,
    //                                 ),
    //                                 pw.Container(
    //                                   width: 200,
    //                                   // decoration: const pw.BoxDecoration(
    //                                   //   // color: PdfColors.green100,
    //                                   //   border: pw.Border(
    //                                   //     bottom: pw.BorderSide(
    //                                   //         width: 0.5, color: PdfColors.grey600),
    //                                   //   ),
    //                                   // ),
    //                                   padding: const pw.EdgeInsets.fromLTRB(
    //                                       4, 0, 4, 0),
    //                                   child: pw.Row(
    //                                     // mainAxisAlignment:
    //                                     //     pw.MainAxisAlignment.spaceBetween,
    //                                     children: [
    //                                       pw.Expanded(
    //                                         flex: 1,
    //                                         child: pw.Text(
    //                                           'คุณ : ',
    //                                           textAlign: pw.TextAlign.left,
    //                                           style: pw.TextStyle(
    //                                             fontSize: font_Size,
    //                                             font: ttf,
    //                                             fontWeight: pw.FontWeight.bold,
    //                                             color: Colors_pd,
    //                                           ),
    //                                         ),
    //                                       ),
    //                                       pw.Expanded(
    //                                         flex: 2,
    //                                         child: pw.Align(
    //                                           alignment: pw.Alignment.center,
    //                                           child: pw.Text(
    //                                             '(${licence_name1})',
    //                                             textAlign: pw.TextAlign.left,
    //                                             style: pw.TextStyle(
    //                                               fontSize: font_Size,
    //                                               font: ttf,
    //                                               fontWeight:
    //                                                   pw.FontWeight.bold,
    //                                               color: Colors_pd,
    //                                             ),
    //                                           ),
    //                                         ),
    //                                       ),
    //                                       pw.Expanded(
    //                                         flex: 2,
    //                                         child: pw.Text(
    //                                           '',
    //                                           textAlign: pw.TextAlign.left,
    //                                           style: pw.TextStyle(
    //                                             fontSize: font_Size,
    //                                             font: ttf,
    //                                             fontWeight: pw.FontWeight.bold,
    //                                             color: Colors_pd,
    //                                           ),
    //                                         ),
    //                                       ),
    //                                     ],
    //                                   ),
    //                                 ),
    //                               ])),
    //                     ],
    //                   )),
    //             ]),
    //           ),
    //           pw.Stack(
    //             children: [
    //               pw.Container(
    //                   width: PdfPageFormat.a4.width,
    //                   height: 55,
    //                   child: pw.Center(
    //                     child: pw.Container(
    //                         width: widths,
    //                         height: 25,
    //                         child: pw.Column(
    //                             mainAxisAlignment:
    //                                 pw.MainAxisAlignment.spaceBetween,
    //                             mainAxisSize: pw.MainAxisSize.min,
    //                             children: [
    //                               pw.Row(children: [
    //                                 pw.Expanded(
    //                                     child: pw.Container(
    //                                   color: PdfColors.red,
    //                                   height: 5,
    //                                 ))
    //                               ]),
    //                               pw.Row(children: [
    //                                 pw.Expanded(
    //                                     child: pw.Container(
    //                                   color: PdfColors.green900,
    //                                   height: 8,
    //                                 ))
    //                               ]),
    //                               pw.Row(children: [
    //                                 pw.Expanded(
    //                                     child: pw.Container(
    //                                   color: PdfColors.red,
    //                                   height: 5,
    //                                 ))
    //                               ]),
    //                             ])),
    //                   )),
    //               pw.Positioned(
    //                   top: 4,
    //                   right: 50,
    //                   child: pw.Container(
    //                       width: 50.0,
    //                       height: 50.0,
    //                       child: pw.Image(pw.MemoryImage(imageData)))),
    //               pw.Positioned(
    //                 top: 4,
    //                 left: 40,
    //                 child: pw.Text(
    //                   "CHOICE MINI STORE CO., LTD. 7/11 VILLAGE NO.5, THA SALA SUB-DISTRICT, MUEANG CHIANG MAI DISTRICT, CHIANG MAI PROVINANCE 50000",
    //                   textAlign: pw.TextAlign.center,
    //                   style: pw.TextStyle(
    //                     color: Colors_pd, fontSize: 8.00,
    //                     // fontSize: font_Size - 4,
    //                     fontWeight: pw.FontWeight.bold,
    //                     font: ttf,
    //                   ),
    //                 ),
    //               ),
    //               pw.Positioned(
    //                 bottom: 4,
    //                 right: 120,
    //                 child: pw.Text(
    //                   "Sub Area Licencee: Chiang Mai, Lamphun, Mae-Hong-Son",
    //                   textAlign: pw.TextAlign.center,
    //                   style: pw.TextStyle(
    //                     fontWeight: pw.FontWeight.bold,
    //                     color: Colors_pd,
    //                     fontSize: 8.00,
    //                     // fontSize: font_Size - 4,
    //                     font: ttf,
    //                   ),
    //                 ),
    //               ),
    //               pw.Positioned(
    //                 bottom: 4,
    //                 left: 40,
    //                 child: pw.Row(
    //                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    //                   children: [
    //                     pw.Padding(
    //                       padding: const pw.EdgeInsets.fromLTRB(0, 2, 0, 0),
    //                       child: pw.Align(
    //                         alignment: pw.Alignment.bottomLeft,
    //                         child: pw.Text(
    //                           'ครั้งที่ : ${paper_run} พิมพ์เมื่อ : $date ',
    //                           // textAlign: pw.TextAlign.left,
    //                           style: pw.TextStyle(
    //                             fontSize: 8.00,
    //                             font: ttf,
    //                             color: Colors_pd,
    //                             // fontWeight: pw.FontWeight.bold
    //                           ),
    //                         ),
    //                       ),
    //                     ),
    //                     pw.Padding(
    //                       padding: const pw.EdgeInsets.fromLTRB(0, 2, 0, 0),
    //                       child: pw.Align(
    //                         alignment: pw.Alignment.bottomRight,
    //                         child: pw.Text(
    //                           ' ( หน้าที่ ${context.pageNumber} / ${context.pagesCount} ) ',
    //                           // textAlign: pw.TextAlign.left,
    //                           style: pw.TextStyle(
    //                             fontSize: 8.00,
    //                             font: ttf,
    //                             color: Colors_pd,
    //                             // fontWeight: pw.FontWeight.bold
    //                           ),
    //                         ),
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ],
    //       );
    //     },
    //   ),
    // );
    // }
    // pageCount++;
    // pdf.addPage(pw.MultiPage(build: (context) {
    //   return [
    //     pw.Center(
    //       child: pw.Column(
    //         mainAxisAlignment: pw.MainAxisAlignment.center,
    //         children: [
    //           pw.Text(
    //             'Sheet $pageCount',
    //             style: pw.TextStyle(fontSize: 20),
    //           ),
    //           pw.Text(
    //             'Page $pageCount',
    //             style: pw.TextStyle(fontSize: 16),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ];
    // }, footer: (context) {
    //   return pw.Align(
    //     alignment: pw.Alignment.bottomRight,
    //     child: pw.Text(
    //       'หน้า ${context.pageNumber} / ${context.pagesCount} ',
    //       textAlign: pw.TextAlign.left,
    //       style: pw.TextStyle(
    //         fontSize: 10,
    //         font: ttf,
    //         color: Colors_pd,
    //         // fontWeight: pw.FontWeight.bold
    //       ),
    //     ),
    //   );
    // }));
    // final bytes = await pdf.save();

    // final dir = await getApplicationDocumentsDirectory();
    // final file = File('${dir.path}/name');
    // await file.writeAsBytes(bytes);
    // return file;
    ///-------------------------------------------------->
    // final List<int> bytes = await pdf.save();
    // final Uint8List data = Uint8List.fromList(bytes);
    // MimeType type = MimeType.PDF;
    // final dir = await FileSaver.instance.saveFile(
    //     "ใบเสร็จรับเงิน(ณ วันที่${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day})",
    //     data,
    //     "pdf",
    //     mimeType: type);
    if (Preview_ser.toString() == 'Folder') {
      final List<int> bytes = await pdf.save(); // Save the PDF as bytes
      final Uint8List data = Uint8List.fromList(bytes); // Convert to Uint8List
      var name_1 = (numdoctax.toString() == '')
          ? 'ใบเสร็จรับเงิน $numinvoice'
          : 'ใบเสร็จรับเงิน/ใบกำกับภาษี $numdoctax';
      // Upload the file
      await uploadFile(data, name_1);
    } else if (Preview_ser.toString() == 'File') {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PreviewPdfgen_Billsplay(
                doc: pdf,
                title: (TitleType_Default_Receipt_Name == null)
                    ? (numdoctax.toString() == '')
                        ? 'ใบเสร็จรับเงิน_$numinvoice'
                        : 'ใบเสร็จรับเงิน/ใบกำกับภาษี_$numdoctax'
                    : (numdoctax.toString() == '')
                        ? 'ใบเสร็จรับเงิน_[$TitleType_Default_Receipt_Name]$numinvoice'
                        : 'ใบเสร็จรับเงิน/ใบกำกับภาษี_[$TitleType_Default_Receipt_Name]$numdoctax'),
          ));
      // final List<int> bytes = await pdf.save();
      // final Uint8List data = Uint8List.fromList(bytes);
      // MimeType type = MimeType.PDF;
      // final dir = await FileSaver.instance.saveFile(
      //     (numdoctax.toString() == '')
      //         ? 'ใบเสร็จรับเงิน $numinvoice'
      //         : 'ใบเสร็จรับเงิน/ใบกำกับภาษี $numdoctax',
      //     data,
      //     "pdf",
      //     mimeType: type);
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PreviewPdfgen_Billsplay(
                doc: pdf,
                title: (TitleType_Default_Receipt_Name == null)
                    ? (numdoctax.toString() == '')
                        ? 'ใบเสร็จรับเงิน_$numinvoice'
                        : 'ใบเสร็จรับเงิน/ใบกำกับภาษี_$numdoctax'
                    : (numdoctax.toString() == '')
                        ? 'ใบเสร็จรับเงิน_[$TitleType_Default_Receipt_Name]$numinvoice'
                        : 'ใบเสร็จรับเงิน/ใบกำกับภาษี_[$TitleType_Default_Receipt_Name]$numdoctax'),
          ));
    }
  }
}
