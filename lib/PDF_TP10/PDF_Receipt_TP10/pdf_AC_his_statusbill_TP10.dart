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

import '../../CRC_16_Prompay/generate_qrcode.dart';
import '../../Constant/Myconstant.dart';
import '../../PeopleChao/Pays_.dart';
import '../../Style/File_s.dart';
import '../../Style/ThaiBaht.dart';
import '../../Style/loadAndCacheImage.dart';

class Pdfgen_his_statusbill_TP10 {
//////////---------------------------------------------------->(ใบเสร็จรับเงิน/ใบกำกับภาษี)   ใช้  //

  static void exportPDF_statusbill_TP10(
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
      vat_up) async {
    ////
    //// ------------>(ใบเสร็จรับเงินชั่วคราว paySrsscreen_)
    ///////
    final pdf = pw.Document();
    final font = await rootBundle.load("${fonts_pdf}");
    var Colors_pd = PdfColors.black;
    // final font = await rootBundle.load("fonts/Sarabun-Medium.ttf");

    int pageCount = 1; // Initialize the page count
    final ttf = pw.Font.ttf(font);
    double font_Size = 10.0;
    //////--------------------------------------------->
    DateTime date = DateTime.now();
    // var formatter = new DateFormat.MMMMd('th_TH');
    // String thaiDate = formatter.format(date);
    final thaiDate = DateTime.parse(date_Transaction);
    final formatter = DateFormat('d MMMM', 'th_TH');
    final formattedDate = formatter.format(thaiDate);
    //////--------------->พ.ศ.
    DateTime dateTime = DateTime.parse(date_Transaction);
    int newYear = dateTime.year + 543;
    //////--------------------------------------------->
    var nFormat = NumberFormat("#,##0.00", "en_US");
    var nFormat2 = NumberFormat("###0.00", "en_US");
    final iconImage =
        (await rootBundle.load('images/LOGO.png')).buffer.asUint8List();
    List netImage = [];
    List netImage_QR = [];
    Uint8List? resizedLogo = await getResizedLogo();

    ///
    ///
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
    int pagesCount_all = 1;
    int all_list = 90 -
        (int.parse(tableData00.length.toString()) +
            int.parse(tableData01.length.toString()) +
            2);
    pw.Widget Sub() {
      return pw.Column(
        children: [
          pw.Container(
            decoration: const pw.BoxDecoration(
              // color: PdfColors.green100,
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.grey600),
                bottom: pw.BorderSide(color: PdfColors.grey600),
              ),
            ),
            child: pw.Row(
              children: [
                pw.Container(
                  decoration: const pw.BoxDecoration(
                    // color: PdfColors.green100,
                    border: pw.Border(
                      left: pw.BorderSide(color: PdfColors.grey600),
                    ),
                  ),
                  width: 35,
                  height: 60,
                  padding: const pw.EdgeInsets.all(2.0),
                ),
                pw.Expanded(
                  flex: 5,
                  child: pw.Container(
                      decoration: const pw.BoxDecoration(
                          // color: PdfColors.green100,
                          // border: pw.Border(
                          //   left: pw.BorderSide(color: PdfColors.grey600),
                          // ),
                          ),
                      height: 60,
                      padding: const pw.EdgeInsets.all(2.0),
                      child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'ชำระโดย : ',
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
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                      decoration: const pw.BoxDecoration(
                        // color: PdfColors.green100,
                        border: pw.Border(
                          left: pw.BorderSide(color: PdfColors.grey600),
                        ),
                      ),
                      height: 60,
                      padding: const pw.EdgeInsets.all(2.0),
                      child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          // crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text(
                                'มูลค่าสินค้าบริการ / No VAT/Sub Total',
                                textAlign: pw.TextAlign.center,
                                maxLines: 1,
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.black),
                              ),
                            ),
                            pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text(
                                'มูลค่าสินค้าบริการ VAT / Sub Total VAT',
                                textAlign: pw.TextAlign.center,
                                maxLines: 1,
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.black),
                              ),
                            ),
                            pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text(
                                'ภาษีมูลค่าเพิ่ม / VAT',
                                textAlign: pw.TextAlign.center,
                                maxLines: 1,
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.black),
                              ),
                            ),
                            pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text(
                                'ส่วนลด / Discount',
                                textAlign: pw.TextAlign.center,
                                maxLines: 1,
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.black),
                              ),
                            ),
                          ])),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Container(
                      decoration: const pw.BoxDecoration(
                        // color: PdfColors.green100,
                        border: pw.Border(
                          left: pw.BorderSide(color: PdfColors.grey600),
                          right: pw.BorderSide(color: PdfColors.grey600),
                        ),
                      ),
                      height: 60,
                      padding: const pw.EdgeInsets.all(2.0),
                      child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          // crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text(
                                (round_p.toString() == '1')
                                    ? (amt_up == null)
                                        ? '0.00'
                                        : '${nFormat.format(double.parse(amt_up.toString()))}'
                                    : '${nFormat.format(double.parse(sum_pvat.toString()))}',
                                textAlign: pw.TextAlign.center,
                                maxLines: 1,
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.black),
                              ),
                            ),
                            pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text(
                                '${nFormat.format(double.parse(Sum_SubTotal.toString()))}',
                                textAlign: pw.TextAlign.center,
                                maxLines: 1,
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.black),
                              ),
                            ),
                            pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text(
                                (round_p.toString() == '1')
                                    ? (vat_up == null)
                                        ? '0.00'
                                        : '${nFormat.format(double.parse(vat_up.toString()))}'
                                    : '${nFormat.format(double.parse(sum_vat.toString()))}',
                                textAlign: pw.TextAlign.center,
                                maxLines: 1,
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.black),
                              ),
                            ),
                            pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text(
                                '${nFormat.format(double.parse(sum_disamt.toString()))}',
                                textAlign: pw.TextAlign.center,
                                maxLines: 1,
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.black),
                              ),
                            ),
                          ])),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 0 * PdfPageFormat.mm),
          pw.Container(
            decoration: const pw.BoxDecoration(
              // color: PdfColors.green100,
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.grey600),
                bottom: pw.BorderSide(color: PdfColors.grey600),
              ),
            ),
            child: pw.Row(
              children: [
                pw.Container(
                  decoration: const pw.BoxDecoration(
                    // color: PdfColors.green100,
                    border: pw.Border(
                      left: pw.BorderSide(color: PdfColors.grey600),
                    ),
                  ),
                  width: 35,
                  height: 25,
                  padding: const pw.EdgeInsets.all(2.0),
                  child: pw.Align(
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      'ตัวอักษร ',
                      style: pw.TextStyle(
                          fontSize: font_Size,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                          fontStyle: pw.FontStyle.italic,
                          color: PdfColors.grey800),
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 5,
                  child: pw.Container(
                    decoration: const pw.BoxDecoration(
                        // color: PdfColors.green100,
                        // border: pw.Border(
                        //   left: pw.BorderSide(color: PdfColors.grey600),
                        // ),
                        ),
                    height: 25,
                    padding: const pw.EdgeInsets.all(2.0),
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text(
                        /// "${nFormat2.format(double.parse(Total.toString()))}",
                        ///
                        ///       '(~${convertToThaiBaht(double.parse(Total.toString()) - double.parse(dis_sum_Matjum.toString()))}~)',
                        '(~${convertToThaiBaht(double.parse(Total.toString()) + double.parse(sum_fee.toString()))}~)',
                        textAlign: pw.TextAlign.center,
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
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    decoration: const pw.BoxDecoration(
                      // color: PdfColors.green100,
                      border: pw.Border(
                        left: pw.BorderSide(color: PdfColors.grey600),
                      ),
                    ),
                    height: 25,
                    padding: const pw.EdgeInsets.all(2.0),
                    child: pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                        'รวมเงินทั้งสิ้น / Grand Total',
                        textAlign: pw.TextAlign.center,
                        maxLines: 1,
                        style: pw.TextStyle(
                            fontSize: font_Size,
                            fontWeight: pw.FontWeight.bold,
                            font: ttf,
                            color: PdfColors.black),
                      ),
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Container(
                    decoration: const pw.BoxDecoration(
                      // color: PdfColors.green100,
                      border: pw.Border(
                        left: pw.BorderSide(color: PdfColors.grey600),
                        right: pw.BorderSide(color: PdfColors.grey600),
                      ),
                    ),
                    height: 25,
                    padding: const pw.EdgeInsets.all(2.0),
                    child: pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                        '${nFormat.format(double.parse(Total.toString()) + double.parse(sum_fee.toString()))}',
                        textAlign: pw.TextAlign.center,
                        maxLines: 1,
                        style: pw.TextStyle(
                            fontSize: font_Size,
                            fontWeight: pw.FontWeight.bold,
                            font: ttf,
                            color: PdfColors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 5 * PdfPageFormat.mm),
          pw.Align(
            alignment: pw.Alignment.topLeft,
            child: pw.Text(
              'ถ้าชำระเงินด้วยเช็ค ใบเสร็จรับเงินจะสมบูรณ์ต่อเมื่อบริษัทฯ ได้รับเงินตามเช็คธนาคารเรียบร้อยแล้ว',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                fontWeight: pw.FontWeight.bold,
                color: Colors_pd,
              ),
            ),
          ),
          pw.Align(
            alignment: pw.Alignment.topLeft,
            child: pw.Text(
              'If payment is made by cheque, this receipt is not valid until cheque is honored by bank',
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
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginBottom: 4.00,
          marginLeft: 8.00,
          marginRight: 8.00,
          marginTop: 8.00,
        ),
        header: (context) {
          return pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                        child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                          pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Container(
                                  height: 70,
                                  width: 70,
                                  decoration: pw.BoxDecoration(
                                    color: PdfColors.grey200,
                                    border:
                                        pw.Border.all(color: PdfColors.grey300),
                                  ),
                                  child: resizedLogo != null
                                      ? pw.Image(
                                          pw.MemoryImage(resizedLogo),
                                          height: 70,
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
                                //         height: 72,
                                //         width: 70,
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
                                //           height: 72,
                                //           width: 70,
                                //         ),
                                //       ),
                                pw.SizedBox(width: 1 * PdfPageFormat.mm),
                                pw.Container(
                                  width: 280,
                                  child: pw.Column(
                                    mainAxisSize: pw.MainAxisSize.min,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
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
                                                bill_addr.toString() ==
                                                    'null' ||
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
                                        'โทรศัพท์ : $bill_tel',
                                        textAlign: pw.TextAlign.right,
                                        maxLines: 1,
                                        style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          color: Colors_pd,
                                        ),
                                      ),
                                      pw.Text(
                                        'อีเมล : $bill_email',
                                        maxLines: 1,
                                        textAlign: pw.TextAlign.right,
                                        style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          color: Colors_pd,
                                        ),
                                      ),
                                      pw.Text(
                                        (bill_tax.toString() == '' ||
                                                bill_tax == null)
                                            ? 'เลขประจำตัวผู้เสียภาษี : 0'
                                            : 'เลขประจำตัวผู้เสียภาษี : $bill_tax',
                                        // textAlign: pw.TextAlign.justify,
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
                              ]),
                          pw.Container(
                            height: 1,
                          ),
                          pw.Text(
                            (cname.toString() == null ||
                                    cname.toString() == '' ||
                                    cname.toString() == 'null' ||
                                    cname.toString() == '-')
                                ? (sname.toString() == null ||
                                        sname.toString() == '' ||
                                        sname.toString() == 'null' ||
                                        sname.toString() == '-')
                                    ? 'ชื่อ '
                                    : 'ชื่อ $sname'
                                : 'ชื่อ $cname',
                            maxLines: 3,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              color: Colors_pd,
                              font: ttf,
                            ),
                          ),
                          pw.Text(
                            'Account Name',
                            maxLines: 3,
                            style: pw.TextStyle(
                              fontSize: font_Size + 1,
                              color: Colors_pd,
                              font: ttf,
                            ),
                          ),
                          pw.Container(
                            height: 3,
                          ),
                          pw.Text(
                            (tax == null)
                                ? '$all_list เลขประจำตัวผู้เสียภาษี -'
                                : '$all_list เลขประจำตัวผู้เสียภาษี $tax',
                            textAlign: pw.TextAlign.right,
                            maxLines: 1,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                          pw.Text(
                            'Tax ID No.',
                            maxLines: 3,
                            style: pw.TextStyle(
                              fontSize: font_Size + 1,
                              color: Colors_pd,
                              font: ttf,
                            ),
                          ),
                          pw.Container(
                            height: 3,
                          ),
                          pw.Text(
                            (addr.toString() == null ||
                                    addr.toString() == '' ||
                                    addr.toString() == 'null')
                                ? 'ที่อยู่ -'
                                : 'ที่อยู่ $addr',
                            maxLines: 1,
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                          pw.Text(
                            'Address.',
                            maxLines: 3,
                            style: pw.TextStyle(
                              fontSize: font_Size + 1,
                              color: Colors_pd,
                              font: ttf,
                            ),
                          ),
                          pw.Container(
                            height: 3,
                          ),
                        ])),
                    pw.Spacer(),
                    pw.Container(
                      width: 210,
                      child: pw.Column(
                        mainAxisSize: pw.MainAxisSize.min,
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Container(
                            height: 30,
                            // decoration: const pw.BoxDecoration(
                            //   // color: PdfColors.green100,
                            //   border: pw.Border(
                            //     right: pw.BorderSide(color: PdfColors.grey600),
                            //     left: pw.BorderSide(color: PdfColors.grey600),
                            //     top: pw.BorderSide(color: PdfColors.grey600),
                            //     bottom: pw.BorderSide(color: PdfColors.grey600),
                            //   ),
                            // ),
                            padding: const pw.EdgeInsets.all(0.0),
                            child: pw.Column(
                              mainAxisSize: pw.MainAxisSize.min,
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.SizedBox(),
                                pw.Align(
                                  alignment: pw.Alignment.centerRight,
                                  child: (hasNonCashTransaction1)
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
                                              ? (numdoctax.toString() == '')
                                                  ? 'บิลเงินสด [ $TitleType_Default_Receipt_Name ]'
                                                  : 'บิลเงินสด/ใบกำกับภาษี [ $TitleType_Default_Receipt_Name ]'
                                              : (numdoctax.toString() == '')
                                                  ? 'บิลเงินสด'
                                                  : 'บิลเงินสด/ใบกำกับภาษี',
                                          maxLines: 1,
                                          textAlign: pw.TextAlign.right,
                                          style: pw.TextStyle(
                                            fontSize: font_Size + 1,
                                            fontWeight: pw.FontWeight.bold,
                                            font: ttf,
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
                                              ? (numdoctax.toString() == '')
                                                  ? 'ใบเสร็จรับเงิน [ $TitleType_Default_Receipt_Name ]'
                                                  : 'ใบเสร็จรับเงิน/ใบกำกับภาษี [ $TitleType_Default_Receipt_Name ]'
                                              : (numdoctax.toString() == '')
                                                  ? 'ใบเสร็จรับเงิน'
                                                  : 'ใบเสร็จรับเงิน/ใบกำกับภาษี',
                                          maxLines: 1,
                                          textAlign: pw.TextAlign.right,
                                          style: pw.TextStyle(
                                            fontSize: font_Size + 1,
                                            fontWeight: pw.FontWeight.bold,
                                            font: ttf,
                                            color: Colors_pd,
                                          ),
                                        ),
                                ),
                                pw.Align(
                                  alignment: pw.Alignment.centerRight,
                                  child: (hasNonCashTransaction1)
                                      ? pw.Text(
                                          (TitleType_Default_Receipt_Name !=
                                                      null &&
                                                  TitleType_Default_Receipt_Name
                                                          .toString() !=
                                                      'ไม่ระบุ')
                                              ? (numdoctax.toString() == '')
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
                                                              : (TitleType_Default_Receipt_Name
                                                                          .toString() ==
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
                                                              : (TitleType_Default_Receipt_Name
                                                                          .toString() ==
                                                                      'สำเนา')
                                                                  ? 'Cash Sell/Tax Invoice Copy'
                                                                  : 'Cash Sell/Tax Invoice'
                                              : (numdoctax.toString() == '')
                                                  ? 'Cash Sell'
                                                  : 'Cash Sell/Tax Invoice',
                                          textAlign: pw.TextAlign.center,
                                          style: pw.TextStyle(
                                            fontSize: font_Size + 1,
                                            font: ttf,
                                            fontWeight: pw.FontWeight.bold,
                                            color: Colors_pd,
                                          ),
                                        )
                                      : pw.Text(
                                          (TitleType_Default_Receipt_Name !=
                                                  null)
                                              ? (numdoctax.toString() == '')
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
                                                              : (TitleType_Default_Receipt_Name
                                                                          .toString() ==
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
                                                              : (TitleType_Default_Receipt_Name
                                                                          .toString() ==
                                                                      'สำเนา')
                                                                  ? 'Receipt/Tax Invoice Copy'
                                                                  : 'Receipt/Tax Invoice '
                                              : (numdoctax.toString() == '')
                                                  ? 'Receipt'
                                                  : 'Receipt/Tax Invoice',
                                          textAlign: pw.TextAlign.center,
                                          style: pw.TextStyle(
                                            fontSize: font_Size + 1,
                                            font: ttf,
                                            fontWeight: pw.FontWeight.bold,
                                            color: Colors_pd,
                                          ),
                                        ),
                                ),
                                pw.SizedBox(),
                              ],
                            ),
                          ),
                          pw.Container(
                            height: 1,
                          ),
                          pw.Container(
                            child: pw.Row(
                              children: [
                                pw.Container(
                                  width: 105,
                                  height: 35,
                                  decoration: const pw.BoxDecoration(
                                    // color: PdfColors.green100,
                                    border: pw.Border(
                                      // right:
                                      //     pw.BorderSide(color: PdfColors.grey600),
                                      left: pw.BorderSide(
                                          color: PdfColors.grey600),
                                      top: pw.BorderSide(
                                          color: PdfColors.grey600),
                                      bottom: pw.BorderSide(
                                          color: PdfColors.grey600),
                                    ),
                                  ),
                                  padding: const pw.EdgeInsets.all(0.0),
                                  child: pw.Column(
                                    mainAxisSize: pw.MainAxisSize.min,
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.center,
                                    children: [
                                      pw.SizedBox(),
                                      pw.Align(
                                        alignment: pw.Alignment.center,
                                        child: pw.Text(
                                          'วันที่ทำรายการ/TRANSACTION DATE',
                                          maxLines: 1,
                                          textAlign: pw.TextAlign.center,
                                          style: pw.TextStyle(
                                            fontSize: font_Size,
                                            font: ttf,
                                            color: Colors_pd,
                                          ),
                                        ),
                                      ),
                                      pw.Divider(
                                          height: 2, color: PdfColors.grey600),
                                      pw.Align(
                                        alignment: pw.Alignment.center,
                                        child: pw.Text(
                                          (date_Transaction.toString() == '' ||
                                                  date_Transaction.toString() ==
                                                      'null' ||
                                                  date_Transaction == null)
                                              ? '-'
                                              : '${DateFormat('dd/MM').format(DateTime.parse(date_Transaction!))}/${DateTime.parse('${date_Transaction}').year + 543}',
                                          maxLines: 1,
                                          textAlign: pw.TextAlign.center,
                                          style: pw.TextStyle(
                                            fontSize: font_Size,
                                            font: ttf,
                                            color: Colors_pd,
                                          ),
                                        ),
                                      ),
                                      pw.SizedBox(),
                                    ],
                                  ),
                                ),
                                pw.Container(
                                  width: 105,
                                  height: 35,
                                  decoration: const pw.BoxDecoration(
                                    // color: PdfColors.green100,
                                    border: pw.Border(
                                      right: pw.BorderSide(
                                          color: PdfColors.grey600),
                                      left: pw.BorderSide(
                                          color: PdfColors.grey600),
                                      top: pw.BorderSide(
                                          color: PdfColors.grey600),
                                      bottom: pw.BorderSide(
                                          color: PdfColors.grey600),
                                    ),
                                  ),
                                  padding: const pw.EdgeInsets.all(0.0),
                                  child: pw.Column(
                                    mainAxisSize: pw.MainAxisSize.min,
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.center,
                                    children: [
                                      pw.SizedBox(),
                                      pw.Align(
                                        alignment: pw.Alignment.center,
                                        child: pw.Text(
                                          'วันที่รับชำระ/PAYMENT DATE',
                                          maxLines: 1,
                                          textAlign: pw.TextAlign.center,
                                          style: pw.TextStyle(
                                            fontSize: font_Size,
                                            font: ttf,
                                            color: Colors_pd,
                                          ),
                                        ),
                                      ),
                                      pw.Divider(
                                          height: 2, color: PdfColors.grey600),
                                      pw.Align(
                                        alignment: pw.Alignment.center,
                                        child: pw.Text(
                                          (dayfinpay.toString() == '' ||
                                                  dayfinpay.toString() ==
                                                      'null' ||
                                                  dayfinpay == null)
                                              ? '-'
                                              : '${DateFormat('dd/MM').format(DateTime.parse(dayfinpay!))}/${DateTime.parse('${dayfinpay}').year + 543}',
                                          maxLines: 1,
                                          textAlign: pw.TextAlign.center,
                                          style: pw.TextStyle(
                                            fontSize: font_Size,
                                            font: ttf,
                                            color: Colors_pd,
                                          ),
                                        ),
                                      ),
                                      pw.SizedBox(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.Container(
                            height: 5,
                          ),
                          pw.Container(
                            child: pw.Row(
                              children: [
                                pw.Container(
                                  width: 105,
                                  height: 35,
                                  decoration: const pw.BoxDecoration(
                                    // color: PdfColors.green100,
                                    border: pw.Border(
                                      // right:
                                      //     pw.BorderSide(color: PdfColors.grey600),
                                      left: pw.BorderSide(
                                          color: PdfColors.grey600),
                                      top: pw.BorderSide(
                                          color: PdfColors.grey600),
                                      bottom: pw.BorderSide(
                                          color: PdfColors.grey600),
                                    ),
                                  ),
                                  padding: const pw.EdgeInsets.all(0.0),
                                  child: pw.Column(
                                    mainAxisSize: pw.MainAxisSize.min,
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.center,
                                    children: [
                                      pw.SizedBox(),
                                      pw.Align(
                                        alignment: pw.Alignment.center,
                                        child: pw.Text(
                                          'เลขที่ใบเสร็จ/RECEIPT',
                                          maxLines: 1,
                                          textAlign: pw.TextAlign.center,
                                          style: pw.TextStyle(
                                            fontSize: font_Size,
                                            font: ttf,
                                            color: Colors_pd,
                                          ),
                                        ),
                                      ),
                                      pw.Divider(
                                          height: 2, color: PdfColors.grey600),
                                      pw.Align(
                                        alignment: pw.Alignment.center,
                                        child: pw.Text(
                                          (numdoctax.toString() == '')
                                              ? '$numinvoice'
                                              : '$numdoctax',
                                          maxLines: 1,
                                          textAlign: pw.TextAlign.center,
                                          style: pw.TextStyle(
                                            fontSize: font_Size,
                                            font: ttf,
                                            color: Colors_pd,
                                          ),
                                        ),
                                      ),
                                      pw.SizedBox(),
                                    ],
                                  ),
                                ),
                                pw.Container(
                                  width: 105,
                                  height: 35,
                                  decoration: const pw.BoxDecoration(
                                    // color: PdfColors.green100,
                                    border: pw.Border(
                                      right: pw.BorderSide(
                                          color: PdfColors.grey600),
                                      left: pw.BorderSide(
                                          color: PdfColors.grey600),
                                      top: pw.BorderSide(
                                          color: PdfColors.grey600),
                                      bottom: pw.BorderSide(
                                          color: PdfColors.grey600),
                                    ),
                                  ),
                                  padding: const pw.EdgeInsets.all(0.0),
                                  child: pw.Column(
                                    mainAxisSize: pw.MainAxisSize.min,
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.center,
                                    children: [
                                      pw.SizedBox(),
                                      pw.Align(
                                        alignment: pw.Alignment.center,
                                        child: pw.Text(
                                          'อ้างอิงเลขที่/REF NO.',
                                          maxLines: 1,
                                          textAlign: pw.TextAlign.center,
                                          style: pw.TextStyle(
                                            fontSize: font_Size,
                                            font: ttf,
                                            color: Colors_pd,
                                          ),
                                        ),
                                      ),
                                      pw.Divider(
                                          height: 2, color: PdfColors.grey600),
                                      pw.Align(
                                        alignment: pw.Alignment.center,
                                        child: pw.Text(
                                          '-',
                                          maxLines: 1,
                                          textAlign: pw.TextAlign.center,
                                          style: pw.TextStyle(
                                            fontSize: font_Size,
                                            font: ttf,
                                            color: Colors_pd,
                                          ),
                                        ),
                                      ),
                                      pw.SizedBox(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.Container(
                            height: 5,
                          ),
                          pw.Container(
                            height: 35,
                            decoration: const pw.BoxDecoration(
                              // color: PdfColors.green100,
                              border: pw.Border(
                                right: pw.BorderSide(color: PdfColors.grey600),
                                left: pw.BorderSide(color: PdfColors.grey600),
                                top: pw.BorderSide(color: PdfColors.grey600),
                                bottom: pw.BorderSide(color: PdfColors.grey600),
                              ),
                            ),
                            padding: const pw.EdgeInsets.all(0.0),
                            child: pw.Column(
                              mainAxisSize: pw.MainAxisSize.min,
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.SizedBox(),
                                pw.Align(
                                  alignment: pw.Alignment.center,
                                  child: pw.Text(
                                    'ห้องเลขที่/UNIT NO.',
                                    maxLines: 1,
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      color: Colors_pd,
                                    ),
                                  ),
                                ),
                                pw.Divider(height: 2, color: PdfColors.grey600),
                                pw.Align(
                                  alignment: pw.Alignment.center,
                                  child: pw.Text(
                                    '$Ln_s',
                                    maxLines: 1,
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      color: Colors_pd,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(),
                        ],
                      ),
                    ),
                  ],
                ),
                // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                // pw.Divider(),
                pw.SizedBox(height: 2.0 * PdfPageFormat.mm),
              ]);
        },
        build: (context) {
          return [
            pw.Container(
                height: PdfPageFormat.a4.height - 380,
                child: pw.Column(children: [
                  pw.Container(
                    decoration: const pw.BoxDecoration(
                      // color: PdfColors.green100,
                      border: pw.Border(
                        top: pw.BorderSide(color: PdfColors.grey600),
                        bottom: pw.BorderSide(color: PdfColors.grey600),
                      ),
                    ),
                    child: pw.Row(
                      children: [
                        pw.Container(
                            decoration: const pw.BoxDecoration(
                              // color: PdfColors.green100,
                              border: pw.Border(
                                left: pw.BorderSide(color: PdfColors.grey600),
                              ),
                            ),
                            width: 35,
                            height: 32,
                            padding: const pw.EdgeInsets.all(2.0),
                            child: pw.Column(
                                // mainAxisAlignment: pw.MainAxisAlignment.start,
                                // crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Align(
                                    alignment: pw.Alignment.center,
                                    child: pw.Text(
                                      'ลำดับ',
                                      maxLines: 1,
                                      textAlign: pw.TextAlign.center,
                                      style: pw.TextStyle(
                                          fontSize: font_Size,
                                          fontWeight: pw.FontWeight.bold,
                                          font: ttf,
                                          color: PdfColors.black),
                                    ),
                                  ),
                                  pw.Align(
                                    alignment: pw.Alignment.center,
                                    child: pw.Text(
                                      'NO.',
                                      maxLines: 1,
                                      textAlign: pw.TextAlign.center,
                                      style: pw.TextStyle(
                                          fontSize: font_Size,
                                          fontWeight: pw.FontWeight.bold,
                                          font: ttf,
                                          color: PdfColors.black),
                                    ),
                                  ),
                                ])),
                        pw.Expanded(
                          flex: 5,
                          child: pw.Container(
                            decoration: const pw.BoxDecoration(
                              // color: PdfColors.green100,
                              border: pw.Border(
                                left: pw.BorderSide(color: PdfColors.grey600),
                              ),
                            ),
                            height: 32,
                            padding: const pw.EdgeInsets.all(2.0),
                            child: pw.Column(
                                // mainAxisAlignment: pw.MainAxisAlignment.start,
                                // crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Align(
                                    alignment: pw.Alignment.center,
                                    child: pw.Text(
                                      'รายการ',
                                      textAlign: pw.TextAlign.center,
                                      maxLines: 1,
                                      style: pw.TextStyle(
                                          fontSize: font_Size,
                                          fontWeight: pw.FontWeight.bold,
                                          font: ttf,
                                          color: PdfColors.black),
                                    ),
                                  ),
                                  pw.Align(
                                    alignment: pw.Alignment.center,
                                    child: pw.Text(
                                      'ITEMS',
                                      textAlign: pw.TextAlign.center,
                                      maxLines: 1,
                                      style: pw.TextStyle(
                                          fontSize: font_Size,
                                          fontWeight: pw.FontWeight.bold,
                                          font: ttf,
                                          color: PdfColors.black),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                            decoration: const pw.BoxDecoration(
                              // color: PdfColors.green100,
                              border: pw.Border(
                                left: pw.BorderSide(color: PdfColors.grey600),
                              ),
                            ),
                            height: 32,
                            padding: const pw.EdgeInsets.all(2.0),
                            child: pw.Column(
                                // mainAxisAlignment: pw.MainAxisAlignment.start,
                                // crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Align(
                                    alignment: pw.Alignment.center,
                                    child: pw.Text(
                                      'จำนวนเงิน',
                                      textAlign: pw.TextAlign.center,
                                      maxLines: 1,
                                      style: pw.TextStyle(
                                          fontSize: font_Size,
                                          fontWeight: pw.FontWeight.bold,
                                          font: ttf,
                                          color: PdfColors.black),
                                    ),
                                  ),
                                  pw.Align(
                                    alignment: pw.Alignment.center,
                                    child: pw.Text(
                                      'AMOUNT',
                                      textAlign: pw.TextAlign.center,
                                      maxLines: 1,
                                      style: pw.TextStyle(
                                          fontSize: font_Size,
                                          fontWeight: pw.FontWeight.bold,
                                          font: ttf,
                                          color: PdfColors.black),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                              decoration: const pw.BoxDecoration(
                                // color: PdfColors.green100,
                                border: pw.Border(
                                  left: pw.BorderSide(color: PdfColors.grey600),
                                ),
                              ),
                              height: 32,
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Column(
                                  // mainAxisAlignment: pw.MainAxisAlignment.start,
                                  // crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Align(
                                      alignment: pw.Alignment.center,
                                      child: pw.Text(
                                        'ภาษีมูลค่าเพิ่ม',
                                        textAlign: pw.TextAlign.center,
                                        maxLines: 1,
                                        style: pw.TextStyle(
                                            fontSize: font_Size,
                                            fontWeight: pw.FontWeight.bold,
                                            font: ttf,
                                            color: PdfColors.black),
                                      ),
                                    ),
                                    pw.Align(
                                      alignment: pw.Alignment.center,
                                      child: pw.Text(
                                        'VAT',
                                        textAlign: pw.TextAlign.center,
                                        maxLines: 1,
                                        style: pw.TextStyle(
                                            fontSize: font_Size,
                                            fontWeight: pw.FontWeight.bold,
                                            font: ttf,
                                            color: PdfColors.black),
                                      ),
                                    ),
                                  ])),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                              decoration: const pw.BoxDecoration(
                                // color: PdfColors.green100,
                                border: pw.Border(
                                  left: pw.BorderSide(color: PdfColors.grey600),
                                  right:
                                      pw.BorderSide(color: PdfColors.grey600),
                                ),
                              ),
                              height: 32,
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Column(
                                  // mainAxisAlignment: pw.MainAxisAlignment.start,
                                  // crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Align(
                                      alignment: pw.Alignment.center,
                                      child: pw.Text(
                                        'จำนวนเงินรวมทั้งสิ้น',
                                        textAlign: pw.TextAlign.center,
                                        maxLines: 1,
                                        style: pw.TextStyle(
                                            fontSize: font_Size,
                                            fontWeight: pw.FontWeight.bold,
                                            font: ttf,
                                            color: PdfColors.black),
                                      ),
                                    ),
                                    pw.Align(
                                      alignment: pw.Alignment.center,
                                      child: pw.Text(
                                        'TOTAL',
                                        textAlign: pw.TextAlign.center,
                                        maxLines: 1,
                                        style: pw.TextStyle(
                                            fontSize: font_Size,
                                            fontWeight: pw.FontWeight.bold,
                                            font: ttf,
                                            color: PdfColors.black),
                                      ),
                                    ),
                                  ])),
                        ),
                      ],
                    ),
                  ),
                  pw.Container(
                    // height: 800,
                    // color: PdfColors.green100,
                    child: pw.Table(
                      // columnWidths: {
                      //   0: pw.FlexColumnWidth(1),
                      //   1: pw.FlexColumnWidth(2),
                      //   2: pw.FlexColumnWidth(2),
                      // },
                      defaultVerticalAlignment:
                          pw.TableCellVerticalAlignment.middle,
                      border: pw.TableBorder(
                          // bottom:
                          //     pw.BorderSide(color: PdfColors.grey600, width: 1),
                          left:
                              pw.BorderSide(color: PdfColors.grey600, width: 1),
                          right:
                              pw.BorderSide(color: PdfColors.grey600, width: 1),
                          verticalInside: pw.BorderSide(
                              width: 1,
                              color: PdfColors.grey600,
                              style: pw.BorderStyle.solid)),
                      children: [
                        for (int index = 0; index < tableData00.length; index++)
                          pw.TableRow(children: [
                            pw.Container(
                              width: 35,
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Align(
                                alignment: pw.Alignment.topCenter,
                                child: pw.Text(
                                  '${index + 1}',
                                  maxLines: 1,
                                  textAlign: pw.TextAlign.left,
                                  style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      color: PdfColors.grey800),
                                ),
                              ),
                            ),
                            pw.Expanded(
                                flex: 5,
                                child: pw.Container(
                                  padding: const pw.EdgeInsets.all(2.0),
                                  child: pw.Align(
                                    alignment: pw.Alignment.topLeft,
                                    child: pw.Text(
                                      (tableData00[index][0].toString() == '6')
                                          ? '${tableData00[index][2]} [ หน่วยที่ใช้ไป ${tableData00[index][8]}-${tableData00[index][9]} ]'
                                          : '${tableData00[index][2]} ${DateFormat('MMM', 'th').format(DateTime.parse(tableData00[index][1]))} ${DateTime.parse('${tableData00[index][1]}').year + 543}',
                                      // (tableData00[index][0].toString() == '6')
                                      //     ? '${tableData00[index][2]} ${DateFormat('dd/MM').format(DateTime.parse(tableData00[index][1]))}/${DateTime.parse('${tableData00[index][1]}').year + 543} [ หน่วยที่ใช้ไป ${tableData00[index][8]}-${tableData00[index][9]} ]'
                                      //     : '${tableData00[index][2]} ${DateFormat('dd/MM').format(DateTime.parse(tableData00[index][1]))}/${DateTime.parse('${tableData00[index][1]}').year + 543}',
                                      // (tableData00[index][0].toString() == '6')
                                      //     ? '${tableData00[index][2]}(${DateFormat('MMM', 'th_TH').format(DateTime.parse('${tableData00[index][1]}'))} ${DateTime.parse('${tableData00[index][1]}').year + 543} ${DateFormat('dd/MM').format(DateTime.parse(tableData00[index][1]))}/${DateTime.parse('${tableData00[index][1]}').year + 543}) [ หน่วยที่ใช้ไป ${tableData00[index][8]}-${tableData00[index][9]} ]'
                                      //     : '${tableData00[index][2]}(${DateFormat('MMM', 'th_TH').format(DateTime.parse('${tableData00[index][1]}'))} ${DateTime.parse('${tableData00[index][1]}').year + 543} ${DateFormat('dd/MM').format(DateTime.parse(tableData00[index][1]))}/${DateTime.parse('${tableData00[index][1]}').year + 543})',
                                      maxLines: 1,
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          color: PdfColors.grey800),
                                    ),
                                  ),
                                )),
                            pw.Expanded(
                                flex: 1,
                                child: pw.Container(
                                  padding: const pw.EdgeInsets.all(2.0),
                                  child: pw.Align(
                                    alignment: pw.Alignment.topRight,
                                    child: pw.Text(
                                      '${tableData00[index][5]}',
                                      maxLines: 1,
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          color: PdfColors.grey800),
                                    ),
                                  ),
                                )),
                            pw.Expanded(
                                flex: 1,
                                child: pw.Container(
                                  padding: const pw.EdgeInsets.all(2.0),
                                  child: pw.Align(
                                    alignment: pw.Alignment.topRight,
                                    child: pw.Text(
                                      '${tableData00[index][3]}',
                                      maxLines: 1,
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          color: PdfColors.grey800),
                                    ),
                                  ),
                                )),
                            pw.Expanded(
                                flex: 1,
                                child: pw.Container(
                                  padding: const pw.EdgeInsets.all(2.0),
                                  child: pw.Align(
                                      alignment: pw.Alignment.topRight,
                                      child: pw.Text(
                                        '${tableData00[index][13]}',
                                        maxLines: 1,
                                        textAlign: pw.TextAlign.right,
                                        style: pw.TextStyle(
                                            fontSize: font_Size,
                                            font: ttf,
                                            color: PdfColors.grey800),
                                      )
                                      // pw.Column(
                                      //   children: [
                                      //     (tableData00[index][12].toString() ==
                                      //             '0.00')
                                      //         ? pw.Text(
                                      //             '${tableData00[index][13]}',
                                      //             maxLines: 1,
                                      //             textAlign: pw.TextAlign.right,
                                      //             style: pw.TextStyle(
                                      //                 fontSize: font_Size,
                                      //                 font: ttf,
                                      //                 color: PdfColors.grey800),
                                      //           )
                                      //         : pw.Text(
                                      //             '${tableData00[index][13]}',
                                      //             maxLines: 1,
                                      //             textAlign: pw.TextAlign.right,
                                      //             style: pw.TextStyle(
                                      //                 decoration: pw
                                      //                     .TextDecoration
                                      //                     .lineThrough,
                                      //                 fontSize: font_Size,
                                      //                 font: ttf,
                                      //                 color: PdfColors.grey800),
                                      //           ),
                                      //   ],
                                      // ),
                                      ),
                                )),
                          ]),
                        for (int index = 0; index < tableData01.length; index++)
                          pw.TableRow(children: [
                            pw.Container(
                              width: 35,
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Align(
                                alignment: pw.Alignment.topCenter,
                                child: pw.Text(
                                  '${index + 1}',
                                  maxLines: 1,
                                  textAlign: pw.TextAlign.left,
                                  style: pw.TextStyle(
                                      fontSize: font_Size,
                                      font: ttf,
                                      color: PdfColors.grey800),
                                ),
                              ),
                            ),
                            pw.Expanded(
                                flex: 5,
                                child: pw.Container(
                                  padding: const pw.EdgeInsets.all(2.0),
                                  child: pw.Align(
                                    alignment: pw.Alignment.topLeft,
                                    child: pw.Text(
                                      (tableData01[index][0].toString() == '6')
                                          ? '${tableData01[index][2]} [ หน่วยที่ใช้ไป ${tableData01[index][8]}-${tableData01[index][9]} ]'
                                          : '${tableData01[index][2]} ${DateFormat('MMM', 'th').format(DateTime.parse(tableData01[index][1]))} ${DateTime.parse('${tableData01[index][1]}').year + 543}',
                                      // (tableData00[index][0].toString() == '6')
                                      //     ? '${tableData00[index][2]} ${DateFormat('dd/MM').format(DateTime.parse(tableData00[index][1]))}/${DateTime.parse('${tableData00[index][1]}').year + 543} [ หน่วยที่ใช้ไป ${tableData00[index][8]}-${tableData00[index][9]} ]'
                                      //     : '${tableData00[index][2]} ${DateFormat('dd/MM').format(DateTime.parse(tableData00[index][1]))}/${DateTime.parse('${tableData00[index][1]}').year + 543}',
                                      // (tableData00[index][0].toString() == '6')
                                      //     ? '${tableData00[index][2]}(${DateFormat('MMM', 'th_TH').format(DateTime.parse('${tableData00[index][1]}'))} ${DateTime.parse('${tableData00[index][1]}').year + 543} ${DateFormat('dd/MM').format(DateTime.parse(tableData00[index][1]))}/${DateTime.parse('${tableData00[index][1]}').year + 543}) [ หน่วยที่ใช้ไป ${tableData00[index][8]}-${tableData00[index][9]} ]'
                                      //     : '${tableData00[index][2]}(${DateFormat('MMM', 'th_TH').format(DateTime.parse('${tableData00[index][1]}'))} ${DateTime.parse('${tableData00[index][1]}').year + 543} ${DateFormat('dd/MM').format(DateTime.parse(tableData00[index][1]))}/${DateTime.parse('${tableData00[index][1]}').year + 543})',
                                      maxLines: 1,
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          color: PdfColors.grey800),
                                    ),
                                  ),
                                )),
                            pw.Expanded(
                                flex: 1,
                                child: pw.Container(
                                  padding: const pw.EdgeInsets.all(2.0),
                                  child: pw.Align(
                                    alignment: pw.Alignment.topRight,
                                    child: pw.Text(
                                      '0.00',
                                      maxLines: 1,
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          color: PdfColors.grey800),
                                    ),
                                  ),
                                )),
                            pw.Expanded(
                                flex: 1,
                                child: pw.Container(
                                  padding: const pw.EdgeInsets.all(2.0),
                                  child: pw.Align(
                                    alignment: pw.Alignment.topRight,
                                    child: pw.Text(
                                      '0.00',
                                      maxLines: 1,
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          color: PdfColors.grey800),
                                    ),
                                  ),
                                )),
                            pw.Expanded(
                                flex: 1,
                                child: pw.Container(
                                  padding: const pw.EdgeInsets.all(2.0),
                                  child: pw.Align(
                                    alignment: pw.Alignment.topRight,
                                    child: pw.Text(
                                      '${tableData01[index][6]}',
                                      maxLines: 1,
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          color: PdfColors.grey800),
                                    ),
                                  ),
                                )),
                          ]),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Container(
                      decoration: const pw.BoxDecoration(
                        // color: PdfColors.green100,
                        border: pw.Border(
                          // top: pw.BorderSide(color: PdfColors.grey600),
                          bottom: pw.BorderSide(color: PdfColors.grey600),
                        ),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Container(
                            decoration: const pw.BoxDecoration(
                              // color: PdfColors.green100,
                              border: pw.Border(
                                left: pw.BorderSide(color: PdfColors.grey600),
                              ),
                            ),
                            width: 35,
                            // height: 25,
                            padding: const pw.EdgeInsets.all(2.0),
                          ),
                          pw.Expanded(
                            flex: 5,
                            child: pw.Container(
                              decoration: const pw.BoxDecoration(
                                // color: PdfColors.green100,
                                border: pw.Border(
                                  left: pw.BorderSide(color: PdfColors.grey600),
                                ),
                              ),
                              // height: 25,
                              padding: const pw.EdgeInsets.all(2.0),
                            ),
                          ),
                          pw.Expanded(
                            flex: 1,
                            child: pw.Container(
                              decoration: const pw.BoxDecoration(
                                // color: PdfColors.green100,
                                border: pw.Border(
                                  left: pw.BorderSide(color: PdfColors.grey600),
                                ),
                              ),
                              // height: 25,
                              padding: const pw.EdgeInsets.all(2.0),
                            ),
                          ),
                          pw.Expanded(
                            flex: 1,
                            child: pw.Container(
                              decoration: const pw.BoxDecoration(
                                // color: PdfColors.green100,
                                border: pw.Border(
                                  left: pw.BorderSide(color: PdfColors.grey600),
                                ),
                              ),
                              // height: 25,
                              padding: const pw.EdgeInsets.all(2.0),
                            ),
                          ),
                          pw.Expanded(
                            flex: 1,
                            child: pw.Container(
                              decoration: const pw.BoxDecoration(
                                // color: PdfColors.green100,
                                border: pw.Border(
                                  left: pw.BorderSide(color: PdfColors.grey600),
                                  right:
                                      pw.BorderSide(color: PdfColors.grey600),
                                ),
                              ),
                              // height: 25,
                              padding: const pw.EdgeInsets.all(2.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  // for (int index = 0; index < all_list; index++)
                  //   pw.TableRow(children: [
                  //     pw.Container(
                  //       width: 35,
                  //       padding: const pw.EdgeInsets.all(2.0),
                  //       child: pw.Align(
                  //         alignment: pw.Alignment.topCenter,
                  //         child: pw.Text(
                  //           '',
                  //           maxLines: 1,
                  //           textAlign: pw.TextAlign.left,
                  //           style: pw.TextStyle(
                  //               fontSize: font_Size,
                  //               font: ttf,
                  //               color: PdfColors.grey800),
                  //         ),
                  //       ),
                  //     ),
                  //     pw.Expanded(
                  //         flex: 5,
                  //         child: pw.Container(
                  //           padding: const pw.EdgeInsets.all(2.0),
                  //           child: pw.Align(
                  //             alignment: pw.Alignment.topLeft,
                  //             child: pw.Text(
                  //               '',
                  //               maxLines: 1,
                  //               textAlign: pw.TextAlign.left,
                  //               style: pw.TextStyle(
                  //                   fontSize: font_Size,
                  //                   font: ttf,
                  //                   color: PdfColors.grey800),
                  //             ),
                  //           ),
                  //         )),
                  //     pw.Expanded(
                  //         flex: 1,
                  //         child: pw.Container(
                  //           padding: const pw.EdgeInsets.all(2.0),
                  //           child: pw.Align(
                  //             alignment: pw.Alignment.topRight,
                  //             child: pw.Text(
                  //               '',
                  //               maxLines: 1,
                  //               textAlign: pw.TextAlign.right,
                  //               style: pw.TextStyle(
                  //                   fontSize: font_Size,
                  //                   font: ttf,
                  //                   color: PdfColors.grey800),
                  //             ),
                  //           ),
                  //         )),
                  //     pw.Expanded(
                  //         flex: 1,
                  //         child: pw.Container(
                  //           padding: const pw.EdgeInsets.all(2.0),
                  //           child: pw.Align(
                  //             alignment: pw.Alignment.topRight,
                  //             child: pw.Text(
                  //               '',
                  //               maxLines: 1,
                  //               textAlign: pw.TextAlign.right,
                  //               style: pw.TextStyle(
                  //                   fontSize: font_Size,
                  //                   font: ttf,
                  //                   color: PdfColors.grey800),
                  //             ),
                  //           ),
                  //         )),
                  //     pw.Expanded(
                  //         flex: 1,
                  //         child: pw.Container(
                  //           padding: const pw.EdgeInsets.all(2.0),
                  //           child: pw.Align(
                  //             alignment: pw.Alignment.topRight,
                  //             child: pw.Text(
                  //               '',
                  //               maxLines: 1,
                  //               textAlign: pw.TextAlign.right,
                  //               style: pw.TextStyle(
                  //                   fontSize: font_Size,
                  //                   font: ttf,
                  //                   color: PdfColors.grey800),
                  //             ),
                  //           ),
                  //         )),
                  //   ]),
                ]))
          ];
        },
        footer: (context) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            mainAxisSize: pw.MainAxisSize.min,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              Sub(),
              pw.SizedBox(
                height: 15,
              ),
              pw.Container(
                  // decoration: pw.BoxDecoration(
                  //   border: pw.Border.all(color: PdfColors.grey, width: 1),
                  // ),
                  padding: pw.EdgeInsets.fromLTRB(2, 4, 2, 4),
                  child: pw.Row(
                    children: [
                      // pw.Expanded(
                      //     flex: 2,
                      //     child: pw.Column(
                      //         mainAxisAlignment: pw.MainAxisAlignment.start,
                      //         crossAxisAlignment: pw.CrossAxisAlignment.start,
                      //         children: [
                      //           pw.Text(
                      //             'หมายเหตุ : ',
                      //             textAlign: pw.TextAlign.left,
                      //             style: pw.TextStyle(
                      //               fontSize: font_Size,
                      //               font: ttf,
                      //               fontWeight: pw.FontWeight.bold,
                      //               color: Colors_pd,
                      //             ),
                      //           ),
                      //           pw.Text(
                      //             (hasNonCashTransaction)
                      //                 ? '( / ) 1. เงินโอน, QR Code, Mobile Banking '
                      //                 : '(   ) 1. เงินโอน, QR Code, Mobile Banking ',
                      //             textAlign: pw.TextAlign.left,
                      //             style: pw.TextStyle(
                      //               fontSize: font_Size,
                      //               font: ttf,
                      //               fontWeight: pw.FontWeight.bold,
                      //               color: Colors_pd,
                      //             ),
                      //           ),
                      //           pw.Text(
                      //             (hasNonCashTransaction)
                      //                 ? '      บัญชี ${finnancetransModels.where((model) => model.dtype == 'KP' && model.ptser != null && model.ptser != '1').map((model) => model.bank).join(', ')} เลขที่ ${finnancetransModels.where((model) => model.dtype == 'KP' && model.ptser != null && model.ptser != '1').map((model) => model.bno).join(', ')} [ ${finnancetransModels.where((model) => model.dtype == 'KP' && model.ptser != null && model.ptser != '1').map((model) => (model.ptname.toString() == 'Online Payment' ? 'PromptPay QR' : model.ptname == 'เงินโอน' ? 'เลขบัญชี' : model.ptname == 'Beam Checkout' ? 'Beam Checkout' : 'Online Standard QR')).join(', ')} ]'
                      //                 : '      บัญชี...................................เลขที่...................................',
                      //             textAlign: pw.TextAlign.left,
                      //             style: pw.TextStyle(
                      //               fontSize: font_Size,
                      //               font: ttf,
                      //               fontWeight: pw.FontWeight.bold,
                      //               color: Colors_pd,
                      //             ),
                      //           ),
                      //           if (hasNonCashTransaction8)
                      //             pw.Text(
                      //               hasNonCashTransaction7
                      //                   ? '      ( Ref1. ${finnancetransModels.where((model) => model.dtype == 'KP' && model.ptser != null && model.ptser != '1').map((model) => model.inv.replaceAll('-', '')).join(', ')} Ref2. ${DateFormat('ddMM').format(DateTime.parse(dayfinpay!))}${DateTime.parse('${dayfinpay}').year + 543} )'
                      //                   : '      ( Ref1. ${finnancetransModels.where((model) => model.dtype == 'KP' && model.ptser != null && model.ptser != '1').map((model) => model.ref1).join(', ')} Ref2. ${DateFormat('ddMM').format(DateTime.parse(dayfinpay!))}${DateTime.parse('${dayfinpay}').year + 543} )',
                      //               textAlign: pw.TextAlign.left,
                      //               style: pw.TextStyle(
                      //                 fontSize: font_Size,
                      //                 font: ttf,
                      //                 fontWeight: pw.FontWeight.bold,
                      //                 color: Colors_pd,
                      //               ),
                      //             ),
                      //           pw.Row(
                      //             // mainAxisAlignment:
                      //             //     pw.MainAxisAlignment.spaceBetween,
                      //             children: [
                      //               pw.Expanded(
                      //                 flex: 1,
                      //                 child: pw.Text(
                      //                   (hasNonCashTransaction1)
                      //                       ? '( / ) 2. เงินสด'
                      //                       : '(   ) 2. เงินสด',
                      //                   textAlign: pw.TextAlign.left,
                      //                   style: pw.TextStyle(
                      //                     fontSize: font_Size,
                      //                     font: ttf,
                      //                     fontWeight: pw.FontWeight.bold,
                      //                     color: Colors_pd,
                      //                   ),
                      //                 ),
                      //               ),
                      //               pw.Expanded(
                      //                 flex: 3,
                      //                 child: pw.Text(
                      //                   (hasNonCashTransaction ||
                      //                           hasNonCashTransaction1)
                      //                       ? '(   ) 3. อื่นๆ.............................'
                      //                       : '( / ) 3. อื่นๆ ${finnancetransModels.where((model) => model.ptser != '6' || model.ptser != '5' || model.ptser != '2' || model.ptser != '1' && model.dtype == 'KP').map((model) => model.bank).join(', ')}',
                      //                   textAlign: pw.TextAlign.left,
                      //                   style: pw.TextStyle(
                      //                     fontSize: font_Size,
                      //                     font: ttf,
                      //                     fontWeight: pw.FontWeight.bold,
                      //                     color: Colors_pd,
                      //                   ),
                      //                 ),
                      //               ),
                      //             ],
                      //           )
                      //         ])),
                      pw.Expanded(
                          flex: 1,
                          child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              // crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Text(
                                  '........................................................',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                    color: Colors_pd,
                                  ),
                                ),
                                pw.Text(
                                  'ผู้รับเงิน',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                    color: Colors_pd,
                                  ),
                                ),
                                pw.Text(
                                  'Bill Collector By',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                    color: Colors_pd,
                                  ),
                                ),
                              ])),
                      pw.Expanded(
                          flex: 1,
                          child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              // crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Text(
                                  '........................................................',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                    color: Colors_pd,
                                  ),
                                ),
                                pw.Text(
                                  'ผู้มีอำนวจลงนามแทนบริษัท',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                    color: Colors_pd,
                                  ),
                                ),
                                pw.Text(
                                  'Authorized Signature',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                    color: Colors_pd,
                                  ),
                                ),
                              ])),
                      pw.Expanded(
                          flex: 1,
                          child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              // crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Text(
                                  '........................................................',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                    color: Colors_pd,
                                  ),
                                ),
                                pw.Text(
                                  'ผู้รับเอกสาร',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                    color: Colors_pd,
                                  ),
                                ),
                                pw.Text(
                                  'Received By',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                    color: Colors_pd,
                                  ),
                                ),
                              ])),
                    ],
                  )),
              pw.Row(
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
                        'หน้าที่ ${context.pageNumber} / ${context.pagesCount} ',
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
              )
            ],
          );
        },
      ),
    );
    pageCount++;

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
      final List<int> bytes = await pdf.save();
      final Uint8List data = Uint8List.fromList(bytes);
      MimeType type = MimeType.PDF;
      final dir = await FileSaver.instance.saveFile(
          (numdoctax.toString() == '')
              ? 'ใบเสร็จรับเงิน $numinvoice'
              : 'ใบเสร็จรับเงิน/ใบกำกับภาษี $numdoctax',
          data,
          "pdf",
          mimeType: type);
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PreviewPdfgen_Billsplay(
                doc: pdf,
                title: (TitleType_Default_Receipt_Name == null)
                    ? (numdoctax.toString() == '')
                        ? 'ใบเสร็จรับเงิน $numinvoice'
                        : 'ใบเสร็จรับเงิน/ใบกำกับภาษี $numdoctax'
                    : (numdoctax.toString() == '')
                        ? 'ใบเสร็จรับเงิน [ $TitleType_Default_Receipt_Name ]$numinvoice'
                        : 'ใบเสร็จรับเงิน/ใบกำกับภาษี [ $TitleType_Default_Receipt_Name ]$numdoctax'),
          ));
    }
  }
}
