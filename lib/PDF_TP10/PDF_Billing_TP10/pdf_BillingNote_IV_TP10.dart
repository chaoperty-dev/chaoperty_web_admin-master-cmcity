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
import '../../ChaoArea/ChaoAreaRenew_Screen.dart';
import '../../Constant/Myconstant.dart';
import '../../Man_PDF/Preview_PDF/PreviewPdfgen_Bills_INV.dart';
import '../../Model/GetInvoice_history_Model.dart';
import '../../PeopleChao/Bills_.dart';
import '../../Style/File_s.dart';
import '../../Style/ThaiBaht.dart';
import '../../Style/loadAndCacheImage.dart';

class Pdfgen_BillingNoteInvlice_TP10 {
  //////////---------------------------------------------------->(ใบวางบิล แจ้งหนี้)  ใช้  ++
  static void exportPDF_BillingNoteInvlice_TP10(

      ///(ser_BillingNote 1 = วางบิล  /// 2 = ประวัติวางบิล )
      List<InvoiceHistoryModel> _InvoiceHistoryModels,
      foder,
      Cust_no,
      cid_,
      Zone_s,
      Ln_s,
      lncode,
      fname,

      ///(ser_BillingNote 1 = วางบิล  /// 2 = ประวัติวางบิล )

      tableData003,
      context,
      Num_cid,
      Namenew,
      SubTotal,
      Vat,
      Deduct,
      Sum_SubTotal,
      DisC,
      Total,
      renTal_name,
      sname_,
      addr_,
      tel_,
      email_,
      tax_,
      cname_,
      bill_addr,
      bill_email,
      bill_tel,
      bill_tax,
      bill_name,
      newValuePDFimg,
      cFinn,
      date_Transaction,
      paymentName1,
      paymentName2,
      selectedValue_bank_bno,
      TitleType_Default_Receipt_Name,
      payment_Ptser1,
      bank1,
      ptser1,
      ptname1,
      img1,
      Preview_ser,
      End_Bill_Paydate,
      fonts_pdf,
      Con_remark,
      paper,
      paper_run,
      sum_net_amount_pvat,
      sum_net_non_pvat,
      customer_name) async {
    int YearQRthai = await int.parse(DateFormat('yyyy')
            .format(DateTime.parse(End_Bill_Paydate))
            .toString()) +
        543;
    final pdf = pw.Document();
    // final fontData = await rootBundle.load("ThaiFonts/Sarabun-Medium.ttf");
    // var dataint = fontData.buffer
    //     .asUint8List(fontData.offsetInBytes, fontData.lengthInBytes);
    // final PdfFont font = PdfFont.of(pdf, data: dataint);
    // final PdfFont font = PdfFont.of(pdf, data: dataint);
    final font = await rootBundle.load("${fonts_pdf}");
    var Colors_pd = PdfColors.black;
    var nFormat = NumberFormat("#,##0.00", "en_US");
    var nFormat2 = NumberFormat("###0.00", "en_US");
    var nFormat3 = NumberFormat("###-##-##0", "en_US");
    // double percen =
    //     (double.parse('$DisC') / double.parse(' $Sum_SubTotal')) * 100.00;
    final ttf = pw.Font.ttf(font);
    double font_Size = 13.0;
    //////---------------------------------------------> (วางบิล)
    DateTime date = DateTime.now();
    var formatter = new DateFormat.MMMMd('th_TH');
    String thaiDate = formatter.format(date);
    //////--------------------------------------------->(ประวัติวางบิล)

    // var formatter = new DateFormat.MMMMd('th_TH');
    // String thaiDate = formatter.format(date);
    final thaiDate2 = DateTime.parse(date_Transaction);
    final formatter2 = DateFormat('d MMMM', 'th_TH');
    final formattedDate2 = formatter.format(thaiDate2);
    //////--------------->พ.ศ.
    DateTime dateTime2 = DateTime.parse(date_Transaction);
    int newYear2 = dateTime2.year + 543;
    //////--------------------------------------------->
    String total_QR = '${nFormat.format(double.parse('${Total}'))}';
    String newTotal_QR = total_QR.replaceAll(RegExp(r'[^0-9]'), '');
    List netImage_QR = [];
    List netImage = [];
    Uint8List? resizedLogo = await getResizedLogo();
    // for (int i = 0; i < newValuePDFimg.length; i++) {
    //   netImage.add(await networkImage('${newValuePDFimg[i]}'));
    // }
    if (img1 == null || img1.toString() == '') {
      netImage_QR.add(await networkImage(
          '${MyConstant().domain}/Awaitdownload/imagenot.png'));
      // netImage_QR.add(iconImage);
    } else {
      netImage_QR.add(await networkImage(
          '${MyConstant().domain}/files/$foder/payment/${img1}'));
    }
    final tableHeaders = [
      'ลำดับ',
      'รายการ',
      'กำหนดชำระ',
      'จำนวน',
      'หน่วย',
      'ราคาต่อหน่วย',
      'ราคารวม',
      // 'Total',
    ];
    ///////------------------------------->

    double getTotalByField(
      List<InvoiceHistoryModel> invoices,
      String? Function(InvoiceHistoryModel item) getter,
    ) {
      return invoices.fold(0.0, (sum, item) {
        final value = double.tryParse(getter(item) ?? '0.00') ?? 0.00;
        return sum + value;
      });
    }

    ///////----------------->

    final totalAmt = getTotalByField(_InvoiceHistoryModels, (item) => item.amt);
    final totalPvat =
        getTotalByField(_InvoiceHistoryModels, (item) => item.pvat);
    final totalVat = getTotalByField(_InvoiceHistoryModels, (item) => item.vat);
    final totalWht = getTotalByField(_InvoiceHistoryModels, (item) => item.wht);

    final totalDis = _InvoiceHistoryModels.isNotEmpty
        ? double.tryParse(_InvoiceHistoryModels.first.disendbill ?? '0.00') ??
            0.00
        : 0.00;

    final totalprice =
        getTotalByField(_InvoiceHistoryModels, (item) => item.total);

    final totalBill = totalprice - totalDis;
    String totalBill_QR =
        totalBill.toString().replaceAll(RegExp(r'[^0-9]'), '');
// _InvoiceHistoryModels.
    ///////------------------------------->

    String getFormattedText(String? data) {
      final value =
          (data == null) ? 0.00 : double.tryParse(data ?? '0.00') ?? 0.00;
      return nFormat.format(value);
    }

    String getFormattedText1(String? data) {
      final value =
          (data == null) ? 0.0 : double.tryParse(data ?? '0.0') ?? 0.0;
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
            color: PdfColors.white,
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
              maxLines: 5,
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

    String cleanDescr(String descr) {
      // ตัดรูปแบบ " <เดือนย่อไทย> <ปีพ.ศ.>" ออก เช่น " พ.ค. 2568"
      return descr.replaceAll(
          RegExp(
              r'\s*(ม\.ค\.|ก\.พ\.|มี\.ค\.|เม\.ย\.|พ\.ค\.|มิ\.ย\.|ก\.ค\.|ส\.ค\.|ก\.ย\.|ต\.ค\.|พ\.ย\.|ธ\.ค\.)\s+\d{4}'),
          '');
    }

    ///////------------------------------->
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
                  height: 107,
                  padding: const pw.EdgeInsets.all(2.0),
                ),
                pw.Expanded(
                  flex: 5, //5
                  child: pw.Container(
                      decoration: const pw.BoxDecoration(
                          // color: PdfColors.green100,
                          // border: pw.Border(
                          //   left: pw.BorderSide(color: PdfColors.grey600),
                          // ),
                          ),
                      height: 107,
                      padding: const pw.EdgeInsets.all(2.0),
                      child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'หมายเหตุ :',
                              textAlign: pw.TextAlign.left,
                              style: pw.TextStyle(
                                fontSize: font_Size,
                                font: ttf,
                                fontWeight: pw.FontWeight.bold,
                                color: Colors_pd,
                              ),
                            ),
                            pw.Text(
                              (ptser1.toString() == '2' ||
                                      ptser1.toString() == '5' ||
                                      ptser1.toString() == '6' ||
                                      ptser1.toString() == '7')
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
                              (ptser1.toString() == '2' ||
                                      ptser1.toString() == '5' ||
                                      ptser1.toString() == '6' ||
                                      ptser1.toString() == '7')
                                  ? '      บัญชี ${bank1} เลขที่ ${selectedValue_bank_bno} [ ${(ptname1 == 'Online Payment') ? 'PromptPay QR' : (ptname1 == 'เงินโอน') ? 'เลขบัญชี' : (ptname1 == 'Beam Checkout') ? 'Beam Checkout' : 'Online Standard QR'} ]'
                                  : '      บัญชี...................................เลขที่...................................',
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
                                    (ptser1.toString() == '1')
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
                                    (ptser1.toString() == '2' ||
                                            ptser1.toString() == '5' ||
                                            ptser1.toString() == '6' ||
                                            ptser1.toString() == '1' ||
                                            ptser1.toString() == '7')
                                        ? '(   ) 3. อื่นๆ.............................'
                                        : '( / ) 3. อื่นๆ ${ptname1.toString().trim()}',
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
                  flex: 4, //4
                  child: pw.Container(
                      decoration: const pw.BoxDecoration(
                        // color: PdfColors.green100,
                        border: pw.Border(
                          left: pw.BorderSide(color: PdfColors.grey600),
                        ),
                      ),
                      height: 107,
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
                                'มูลค่าสินค้าบริการ / VAT/Sub Total',
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
                                'รวมเป็นเงิน  / Sub Total',
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
                                'ภาษีหัก ณ ที่จ่าย / WHT',
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
                  flex: 2,
                  child: pw.Container(
                      // width: 92.5, // ex flex 2
                      decoration: const pw.BoxDecoration(
                        // color: PdfColors.green100,
                        border: pw.Border(
                          left: pw.BorderSide(color: PdfColors.grey600),
                          right: pw.BorderSide(color: PdfColors.grey600),
                        ),
                      ),
                      height: 107,
                      padding: const pw.EdgeInsets.all(2.0),
                      child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          // crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text(
                                '${nFormat.format(double.parse(sum_net_non_pvat.toString()))}',
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
                                '${nFormat.format(double.parse(sum_net_amount_pvat.toString()))}',
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
                                '${nFormat.format(totalVat)}',
                                // '${nFormat.format(double.parse(Vat.toString()))}',
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
                                '${nFormat.format(double.parse(sum_net_non_pvat.toString()) + double.parse(sum_net_amount_pvat.toString()) + totalVat)}',
                                // '${nFormat.format(double.parse(sum_net_non_pvat.toString()) + double.parse(sum_net_amount_pvat.toString()) + double.parse(Vat.toString()))}',
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
                                '${nFormat.format(totalWht)}',
                                // '${nFormat.format(double.parse(Deduct.toString()))}',
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
                                '${nFormat.format(totalDis)}',
                                // '${nFormat.format(double.parse(DisC.toString()))}',
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
                )
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
                        // '(~${convertToThaiBaht(double.parse(Total.toString()) + double.parse(sum_fee.toString()))}~)',
                        '(~${convertToThaiBaht(totalBill)}~)',
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
                  flex: 4,
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
                  flex: 2,
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
                        // '${nFormat.format(double.parse(Total.toString()) + double.parse(sum_fee.toString()))}',
                        '${nFormat.format(totalBill)}',
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
          pw.SizedBox(height: 2 * PdfPageFormat.mm),
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
                        width: 355,
                        // color: PdfColors.blueGrey,
                        child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Container(
                                      height: 70,
                                      width: 70,
                                      decoration: pw.BoxDecoration(
                                        color: PdfColors.grey200,
                                        border: pw.Border.all(
                                            color: PdfColors.grey300),
                                      ),
                                      child: resizedLogo != null
                                          ? pw.Image(
                                              pw.MemoryImage(resizedLogo),
                                              height: 50, //70
                                              width: 50,
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
                                      // color: PdfColors.red,
                                      width: 300, //280
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
                                            maxLines: 2,
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
                                height: 20,
                              ),
                              pw.Text(
                                'ชื่อ/Name : $customer_name',
                                maxLines: 3,
                                style: pw.TextStyle(
                                  fontSize: font_Size,
                                  color: Colors_pd,
                                  font: ttf,
                                ),
                              ),
                              // pw.Text(
                              //   'Account Name',
                              //   maxLines: 3,
                              //   style: pw.TextStyle(
                              //     fontSize: font_Size + 1,
                              //     color: Colors_pd,
                              //     font: ttf,
                              //   ),
                              // ),
                              pw.Container(
                                height: 3,
                              ),
                              pw.Text(
                                (tax_ == null)
                                    ? 'เลขประจำตัวผู้เสียภาษี/Tax ID No : -'
                                    : 'เลขประจำตัวผู้เสียภาษี/Tax ID No : $tax_',
                                textAlign: pw.TextAlign.right,
                                maxLines: 1,
                                style: pw.TextStyle(
                                  fontSize: font_Size,
                                  font: ttf,
                                  color: Colors_pd,
                                ),
                              ),
                              // pw.Text(
                              //   'Tax ID No.',
                              //   maxLines: 3,
                              //   style: pw.TextStyle(
                              //     fontSize: font_Size + 1,
                              //     color: Colors_pd,
                              //     font: ttf,
                              //   ),
                              // ),
                              pw.Container(
                                height: 3,
                              ),
                              pw.Text(
                                'ที่อยู่/Address : $addr_',
                                softWrap: true,
                                maxLines: 3,
                                // textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    color: Colors_pd),
                              ),

                              // pw.Text(
                              //   (addr_.toString() == null ||
                              //           addr_.toString() == '' ||
                              //           addr_.toString() == 'null')
                              //       ? 'ที่อยู่/Address : -'
                              //       : 'ที่อยู่/Address : $addr_',
                              //   maxLines: 3,
                              //   textAlign: pw.TextAlign.right,
                              //   style: pw.TextStyle(
                              //     fontSize: font_Size,
                              //     font: ttf,
                              //     color: Colors_pd,
                              //   ),
                              // ),
                              // pw.Text(
                              //   (addr_.toString() == null ||
                              //           addr_.toString() == '' ||
                              //           addr_.toString() == 'null')
                              //       ? ''
                              //       : '$addr_',
                              //   maxLines: 1,
                              //   textAlign: pw.TextAlign.right,
                              //   style: pw.TextStyle(
                              //     fontSize: font_Size,
                              //     font: ttf,
                              //     color: Colors_pd,
                              //   ),
                              // ),
                              // pw.Text(
                              //   'Address.',
                              //   maxLines: 3,
                              //   style: pw.TextStyle(
                              //     fontSize: font_Size + 1,
                              //     color: Colors_pd,
                              //     font: ttf,
                              //   ),
                              // ),
                              pw.Container(
                                height: 3,
                              ),
                            ])),
                    pw.Spacer(),
                    pw.Container(
                      width: 225,
                      child: pw.Column(
                        mainAxisSize: pw.MainAxisSize.min,
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Container(
                            height: 40,
                            // decoration: const pw.BoxDecoration(
                            //   // color: PdfColors.green100,
                            //   border: pw.Border(
                            //     right: pw.BorderSide(color: PdfColors.grey600),
                            //     left: pw.BorderSide(color: PdfColors.grey600),
                            //     top: pw.BorderSide(color: PdfColors.grey600),
                            //     bottom: pw.BorderSide(color: PdfColors.grey600),
                            //   ),
                            // ),

                            child: pw.Column(
                              mainAxisSize: pw.MainAxisSize.min,
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.SizedBox(),
                                pw.Align(
                                    alignment: pw.Alignment.centerRight,
                                    child: pw.Text(
                                      (TitleType_Default_Receipt_Name != null &&
                                              TitleType_Default_Receipt_Name
                                                          .toString()
                                                      .trim() !=
                                                  '' &&
                                              TitleType_Default_Receipt_Name
                                                      .toString() !=
                                                  'ไม่ระบุ')
                                          ? 'ใบวางบิลแจ้งหนี้ [ $TitleType_Default_Receipt_Name ]'
                                          : 'ใบวางบิลแจ้งหนี้',
                                      textAlign: pw.TextAlign.center,
                                      style: pw.TextStyle(
                                        fontSize: font_Size + 1,
                                        font: ttf,
                                        fontWeight: pw.FontWeight.bold,
                                        color: Colors_pd,
                                      ),
                                    )),
                                pw.Align(
                                  alignment: pw.Alignment.centerRight,
                                  child: pw.Text(
                                    (TitleType_Default_Receipt_Name != null &&
                                            TitleType_Default_Receipt_Name
                                                        .toString()
                                                    .trim() !=
                                                '' &&
                                            TitleType_Default_Receipt_Name
                                                    .toString() !=
                                                'ไม่ระบุ')
                                        ? (TitleType_Default_Receipt_Name
                                                    .toString() ==
                                                'ต้นฉบับ')
                                            ? 'Invoice Original'
                                            : (TitleType_Default_Receipt_Name
                                                        .toString() ==
                                                    'คู่ฉบับ')
                                                ? 'Invoice Duplicate'
                                                : (TitleType_Default_Receipt_Name
                                                            .toString() ==
                                                        'สำเนาคู่ฉบับ')
                                                    ? 'Invoice Duplicate Copy'
                                                    : 'Invoice Copy'
                                        : 'Invoice',
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
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              mainAxisSize: pw.MainAxisSize.min,
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.Container(
                                  width: 112.5,
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
                                            fontSize: font_Size - 1,
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
                                  width: 112.5,
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
                                          'วันที่ครบกำหนดชำระ/PAYMENT DATE',
                                          maxLines: 1,
                                          textAlign: pw.TextAlign.center,
                                          style: pw.TextStyle(
                                            fontSize: font_Size - 1,
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
                                          (End_Bill_Paydate == null ||
                                                  End_Bill_Paydate.toString() ==
                                                      '')
                                              ? '${End_Bill_Paydate} '
                                              : '${DateFormat('dd/MM').format(DateTime.parse(End_Bill_Paydate!))}/${DateTime.parse('${End_Bill_Paydate}').year + 543}',
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
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Container(
                                  width: 225,
                                  height: 40,
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
                                          'เลขที่ใบวางบิลแจ้งหนี้/INVOICE',
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
                                          (cFinn.toString() == '' ||
                                                  cFinn == null ||
                                                  cFinn.toString() == 'null')
                                              ? '-'
                                              : '$cFinn',
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
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Container(
                                  width: 70,
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
                                          'รหัสพื้นที่/UNIT NO.',
                                          maxLines: 1,
                                          textAlign: pw.TextAlign.center,
                                          style: pw.TextStyle(
                                            fontSize: font_Size - 1,
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
                                          '$lncode',
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
                                  width: 155,
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
                                          'ชื่อพื้นที่/UNIT NAME.',
                                          maxLines: 1,
                                          textAlign: pw.TextAlign.center,
                                          style: pw.TextStyle(
                                            fontSize: font_Size - 1,
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
                                      pw.SizedBox(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // pw.Container(
                          //   height: 35,
                          //   decoration: const pw.BoxDecoration(
                          //     // color: PdfColors.green100,
                          //     border: pw.Border(
                          //       right: pw.BorderSide(color: PdfColors.grey600),
                          //       left: pw.BorderSide(color: PdfColors.grey600),
                          //       top: pw.BorderSide(color: PdfColors.grey600),
                          //       bottom: pw.BorderSide(color: PdfColors.grey600),
                          //     ),
                          //   ),
                          //   padding: const pw.EdgeInsets.all(0.0),
                          //   child: pw.Column(
                          //     mainAxisSize: pw.MainAxisSize.min,
                          //     mainAxisAlignment:
                          //         pw.MainAxisAlignment.spaceBetween,
                          //     crossAxisAlignment: pw.CrossAxisAlignment.center,
                          //     children: [
                          //       pw.SizedBox(),
                          //       pw.Row(
                          //         children: [
                          //           pw.Align(
                          //             alignment: pw.Alignment.center,
                          //             child: pw.Text(
                          //               'ห้องเลขที่/UNIT NO.',
                          //               maxLines: 1,
                          //               textAlign: pw.TextAlign.center,
                          //               style: pw.TextStyle(
                          //                 fontSize: font_Size,
                          //                 font: ttf,
                          //                 color: Colors_pd,
                          //               ),
                          //             ),
                          //           ),
                          //           pw.Align(
                          //             alignment: pw.Alignment.center,
                          //             child: pw.Text(
                          //               'ห้องชื่อ/UNIT NAME.',
                          //               maxLines: 1,
                          //               textAlign: pw.TextAlign.center,
                          //               style: pw.TextStyle(
                          //                 fontSize: font_Size,
                          //                 font: ttf,
                          //                 color: Colors_pd,
                          //               ),
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //       pw.Divider(height: 2, color: PdfColors.grey600),
                          //       pw.Row(
                          //         children: [
                          //           pw.Align(
                          //             alignment: pw.Alignment.center,
                          //             child: pw.Text(
                          //               '$lncode',
                          //               maxLines: 1,
                          //               textAlign: pw.TextAlign.center,
                          //               style: pw.TextStyle(
                          //                 fontSize: font_Size,
                          //                 font: ttf,
                          //                 color: Colors_pd,
                          //               ),
                          //             ),
                          //           ),
                          //           pw.Align(
                          //             alignment: pw.Alignment.center,
                          //             child: pw.Text(
                          //               '$Ln_s',
                          //               maxLines: 1,
                          //               textAlign: pw.TextAlign.center,
                          //               style: pw.TextStyle(
                          //                 fontSize: font_Size,
                          //                 font: ttf,
                          //                 color: Colors_pd,
                          //               ),
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //     ],
                          //   ),
                          // ),
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
                height: PdfPageFormat.a4.height - 460,
                child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
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
                                    left:
                                        pw.BorderSide(color: PdfColors.grey600),
                                  ),
                                ),
                                width: 35,
                                height: 40,
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
                              flex: 8,
                              child: pw.Container(
                                decoration: const pw.BoxDecoration(
                                  // color: PdfColors.green100,
                                  border: pw.Border(
                                    left:
                                        pw.BorderSide(color: PdfColors.grey600),
                                  ),
                                ),
                                height: 40,
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
                              flex: 2,
                              child: pw.Container(
                                decoration: const pw.BoxDecoration(
                                  // color: PdfColors.green100,
                                  border: pw.Border(
                                    left:
                                        pw.BorderSide(color: PdfColors.grey600),
                                  ),
                                ),
                                height: 40,
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
                              flex: 2,
                              child: pw.Container(
                                decoration: const pw.BoxDecoration(
                                  // color: PdfColors.green100,
                                  border: pw.Border(
                                    left:
                                        pw.BorderSide(color: PdfColors.grey600),
                                  ),
                                ),
                                height: 40,
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
                                    ]),
                              ),
                            ),
                            pw.Expanded(
                              flex: 2,
                              child: pw.Container(
                                  decoration: const pw.BoxDecoration(
                                    // color: PdfColors.green100,
                                    border: pw.Border(
                                      left: pw.BorderSide(
                                          color: PdfColors.grey600),
                                      right: pw.BorderSide(
                                          color: PdfColors.grey600),
                                    ),
                                  ),
                                  height: 40,
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
                      // pw.Table(
                      //   border: const pw.TableBorder(
                      //       left: pw.BorderSide(
                      //           color: PdfColors.grey600, width: 1),
                      //       right: pw.BorderSide(
                      //           color: PdfColors.grey600, width: 1),
                      //       verticalInside: pw.BorderSide(
                      //           width: 1,
                      //           color: PdfColors.grey600,
                      //           style: pw.BorderStyle.solid)),
                      //   children: List.generate(_InvoiceHistoryModels.length,
                      //       (index) {
                      //     final invoices = _InvoiceHistoryModels[index];

                      //     return pw.TableRow(children: [
                      //       pw.Container(
                      //         // decoration: const pw.BoxDecoration(
                      //         //   color: PdfColors.white,
                      //         //   border: pw.Border(
                      //         //     left: pw.BorderSide(color: PdfColors.grey600),
                      //         //   ),
                      //         // ),
                      //         width: 35,
                      //         padding: const pw.EdgeInsets.all(2.0),
                      //         child: pw.Align(
                      //           alignment: pw.Alignment.center,
                      //           child: pw.Text(
                      //             '${index + 1}',
                      //             maxLines: 2,
                      //             textAlign: pw.TextAlign.center,
                      //             style: pw.TextStyle(
                      //                 fontSize: font_Size,
                      //                 font: ttf,
                      //                 color: PdfColors.grey800),
                      //           ),
                      //         ),
                      //       ),
                      //       buildCell(
                      //         text: (invoices.unitser.toString() == '6')
                      //             ? '${invoices.descr} [ หน่วยที่ใช้ไป ${invoices.ovalue}-${invoices.nvalue} ]'
                      //             // ? '${invoices.descr} [ หน่วยที่ใช้ไป 12345678-12345678 ]'
                      //             : '${invoices.descr} ${DateFormat('MMM', 'th').format(DateTime.parse(invoices.date!))} ${DateTime.parse('${invoices.date}').year + 543}',
                      //         flex: 5,
                      //         alignment: pw.Alignment.centerLeft,
                      //         textAlign: pw.TextAlign.left,
                      //       ),
                      //       // buildCell(
                      //       //   text: (invoices.ele_ty.toString() != '0' &&
                      //       //           invoices.ele_ty != null)
                      //       //       ? 'อัตราพิเศษ'
                      //       //       : isPositive(invoices.dis_list)
                      //       //           ? (invoices.unitser.toString() == '6')
                      //       //               ? getFormattedText('${invoices.pri}')
                      //       //               // : getFormattedText(
                      //       //               //     '${invoices.pvat_original}')
                      //       //               : '-'
                      //       //           : (invoices.unitser.toString() == '6')
                      //       //               ? getFormattedText('${invoices.pri}')
                      //       //               : getFormattedText(
                      //       //                   '${invoices.pvat}'),
                      //       //   // (invoices.pri.toString() == '0.00')
                      //       //   //     ? getFormattedText('${invoices.amt}')
                      //       //   //     : getFormattedText('${invoices.pvat}'),
                      //       //   flex: 2,
                      //       //   alignment: pw.Alignment.centerRight,
                      //       //   textAlign: pw.TextAlign.right,
                      //       // ),
                      //       // buildCell(
                      //       //   text: (invoices.ele_ty.toString() != '0' &&
                      //       //           invoices.ele_ty != null)
                      //       //       ? 'อัตราพิเศษ'
                      //       //       : (invoices.dtype.toString() == 'KU')
                      //       //           ? getFormattedText('${invoices.pri}')
                      //       //           : '-',
                      //       //   flex: 2,
                      //       //   alignment: pw.Alignment.centerRight,
                      //       //   textAlign: pw.TextAlign.right,
                      //       // ),
                      //       // buildCell(
                      //       //   text: (invoices.dtype.toString() == 'KU')
                      //       //       ? getFormattedText('${invoices.amt}')
                      //       //       : getFormattedText('${invoices.pri}'),// ถ้า pvat_original != 0 ให้แสดง pvat_original
                      //       //   flex: 1,
                      //       //   alignment: pw.Alignment.centerRight,
                      //       //   textAlign: pw.TextAlign.right,
                      //       // ),
                      //       // buildCell(
                      //       //   text: (double.tryParse(
                      //       //               invoices.pvat_original.toString()) !=
                      //       //           0)
                      //       //       ? getFormattedText(
                      //       //           '${invoices.pvat_original}')
                      //       //       : (invoices.dtype.toString() == 'KU')
                      //       //           ? getFormattedText('${invoices.amt}')
                      //       //           : getFormattedText('${invoices.pri}'),
                      //       //   flex: 2,
                      //       //   alignment: pw.Alignment.centerRight,
                      //       //   textAlign: pw.TextAlign.right,
                      //       // ),

                      //       buildCell(
                      //         text: getFormattedText(
                      //             '${invoices.net_amount_pvat}'),
                      //         flex: 2,
                      //         alignment: pw.Alignment.centerRight,
                      //         textAlign: pw.TextAlign.right,
                      //       ),

                      //       buildCell(
                      //         text: getFormattedText('${invoices.vat}'),
                      //         flex: 2,
                      //         alignment: pw.Alignment.centerRight,
                      //         textAlign: pw.TextAlign.right,
                      //       ),
                      //       buildCell(
                      //         text: getFormattedText('${invoices.total}'),
                      //         flex: 2,
                      //         alignment: pw.Alignment.centerRight,
                      //         textAlign: pw.TextAlign.right,
                      //       ),
                      //     ]);
                      //   }),
                      // ),
                      pw.SizedBox(height: 1), // <-- เว้นบรรทัด
                      pw.Column(
                        children: List.generate(_InvoiceHistoryModels.length,
                            (index) {
                          final invoices = _InvoiceHistoryModels[index];

                          return pw.Container(
                            decoration: const pw.BoxDecoration(
                              // color: PdfColors.green100,
                              border: pw.Border(
                                // top: pw.BorderSide(color: PdfColors.grey600),
                                // bottom: pw.BorderSide(color: PdfColors.grey600),
                                left: pw.BorderSide(color: PdfColors.grey600),
                                right: pw.BorderSide(color: PdfColors.grey600),
                              ),
                            ),
                            child: pw.Row(
                              children: [
                                pw.Container(
                                  decoration: const pw.BoxDecoration(
                                    color: PdfColors.white,
                                    border: pw.Border(
                                      left: pw.BorderSide(
                                          color: PdfColors.grey600),
                                      right: pw.BorderSide(
                                          color: PdfColors.grey600),
                                    ),
                                  ),
                                  width: 35,
                                  padding: const pw.EdgeInsets.all(2.0),
                                  child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.start, // จัดด้านบน
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.center,
                                    children: [
                                      pw.Text(
                                        '${index + 1}',
                                        maxLines: 2,
                                        textAlign: pw.TextAlign.center,
                                        style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          color: PdfColors.grey800,
                                        ),
                                      ),
                                      if (invoices.dtype.toString() == 'KU')
                                        pw.SizedBox(
                                            height: 67), // <-- เว้นบรรทัด
                                    ],
                                  ),
                                ),
                                buildCell(
                                  text: (invoices.unitser.toString() == '6' &&
                                          invoices.dtype.toString() == 'KU')
                                      ? '${cleanDescr(invoices.expname ?? "")} ${DateFormat('MMM', 'th').format(DateTime.parse(invoices.date!))} ${DateTime.parse('${invoices.date}').year + 543}\nเลขอ่านครั้งหลัง     ${getFormattedText(invoices.ovalue)}\nเลขอ่านครั้งก่อน     ${getFormattedText(invoices.nvalue)}\nค่ากระแส${cleanDescr(invoices.expname ?? "")}ต่อเดือน = (จำนวนหน่วยที่จดครั้งล่าสุด - จำนวนหน่วยที่จดครั้งก่อน) X \nอัตรา${cleanDescr(invoices.expname ?? "")} = (  ${getFormattedText(invoices.ovalue)} - ${getFormattedText(invoices.nvalue)} = ${getFormattedText(invoices.qty)} ) X ${getFormattedText(invoices.pri)}'
                                      : (invoices.unitser.toString() == '6' &&
                                              invoices.dtype.toString() != 'KU')
                                          ? '${invoices.expname ?? ""} [ หน่วยที่ใช้ไป ${invoices.ovalue}-${invoices.nvalue} ]'
                                          : '${invoices.expname ?? ""} ${DateFormat('MMM', 'th').format(DateTime.parse(invoices.date!))} ${DateTime.parse('${invoices.date}').year + 543}',
                                  flex: 8,
                                  alignment: pw.Alignment.centerLeft,
                                  textAlign: pw.TextAlign.left,
                                ),
                                // buildCell(
                                //   text: getFormattedText(
                                //       invoices.net_amount_pvat),
                                //   flex: 2,
                                //   alignment: pw.Alignment.centerRight,
                                //   textAlign: pw.TextAlign.right,
                                // ),
                                pw.Expanded(
                                  flex: 2, // <-- ให้กินพื้นที่ 2 ส่วน
                                  child: pw.Container(
                                    decoration: const pw.BoxDecoration(
                                      color: PdfColors.white,
                                      border: pw.Border(
                                        left: pw.BorderSide(
                                            color: PdfColors.grey600),
                                        right: pw.BorderSide(
                                            color: PdfColors.grey600),
                                      ),
                                    ),
                                    padding: const pw.EdgeInsets.all(2.0),
                                    child: pw.Column(
                                      mainAxisAlignment: pw
                                          .MainAxisAlignment.start, // จัดด้านบน
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.end,
                                      children: [
                                        pw.Text(
                                          getFormattedText(
                                              invoices.net_amount_pvat),
                                          maxLines: 2,
                                          textAlign: pw.TextAlign.right,
                                          style: pw.TextStyle(
                                            fontSize: font_Size,
                                            font: ttf,
                                            color: PdfColors.grey800,
                                          ),
                                        ),
                                        if (invoices.dtype.toString() == 'KU')
                                          pw.SizedBox(
                                              height:
                                                  67), // <-- เว้นบรรทัดเพิ่ม
                                      ],
                                    ),
                                  ),
                                ),
                                pw.Expanded(
                                  flex: 2, // <-- ให้กินพื้นที่ 2 ส่วน
                                  child: pw.Container(
                                    decoration: const pw.BoxDecoration(
                                      color: PdfColors.white,
                                      border: pw.Border(
                                        left: pw.BorderSide(
                                            color: PdfColors.grey600),
                                        right: pw.BorderSide(
                                            color: PdfColors.grey600),
                                      ),
                                    ),
                                    padding: const pw.EdgeInsets.all(2.0),
                                    child: pw.Column(
                                      mainAxisAlignment: pw
                                          .MainAxisAlignment.start, // จัดด้านบน
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.end,
                                      children: [
                                        pw.Text(
                                          getFormattedText(invoices.vat),
                                          maxLines: 2,
                                          textAlign: pw.TextAlign.right,
                                          style: pw.TextStyle(
                                            fontSize: font_Size,
                                            font: ttf,
                                            color: PdfColors.grey800,
                                          ),
                                        ),
                                        if (invoices.dtype.toString() == 'KU')
                                          pw.SizedBox(
                                              height:
                                                  67), // <-- เว้นบรรทัดเพิ่ม
                                      ],
                                    ),
                                  ),
                                ),
                                pw.Expanded(
                                  flex: 2, // <-- ให้กินพื้นที่ 2 ส่วน
                                  child: pw.Container(
                                    decoration: const pw.BoxDecoration(
                                      color: PdfColors.white,
                                      border: pw.Border(
                                        left: pw.BorderSide(
                                            color: PdfColors.grey600),
                                        right: pw.BorderSide(
                                            color: PdfColors.grey600),
                                      ),
                                    ),
                                    padding: const pw.EdgeInsets.all(2.0),
                                    child: pw.Column(
                                      mainAxisAlignment: pw
                                          .MainAxisAlignment.start, // จัดด้านบน
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.end,
                                      children: [
                                        pw.Text(
                                          getFormattedText(invoices.total),
                                          maxLines: 2,
                                          textAlign: pw.TextAlign.right,
                                          style: pw.TextStyle(
                                            fontSize: font_Size,
                                            font: ttf,
                                            color: PdfColors.grey800,
                                          ),
                                        ),
                                        if (invoices.dtype.toString() == 'KU')
                                          pw.SizedBox(
                                              height:
                                                  67), // <-- เว้นบรรทัดเพิ่ม
                                      ],
                                    ),
                                  ),
                                ),

                                // buildCell(
                                //   text: getFormattedText(invoices.vat),
                                //   flex: 2,
                                //   alignment: pw.Alignment.centerRight,
                                //   textAlign: pw.TextAlign.right,
                                // ),
                                // buildCell(
                                //   text: getFormattedText('${invoices.total}'),
                                //   flex: 2,
                                //   alignment: pw.Alignment.centerRight,
                                //   textAlign: pw.TextAlign.right,
                                // ),
                              ],
                            ),
                          );
                        }),
                      ),

                      // pw.Container(
                      //   // height: 800,
                      //   // color: PdfColors.green100,
                      //   child: pw.Table(

                      //     // columnWidths: {
                      //     //   0: pw.FlexColumnWidth(1),
                      //     //   1: pw.FlexColumnWidth(2),
                      //     //   2: pw.FlexColumnWidth(2),
                      //     // },
                      //     defaultVerticalAlignment:
                      //         pw.TableCellVerticalAlignment.middle,
                      //     border: pw.TableBorder(
                      //         // bottom:
                      //         //     pw.BorderSide(color: PdfColors.grey600, width: 1),
                      //         left: pw.BorderSide(
                      //             color: PdfColors.grey600, width: 1),
                      //         right: pw.BorderSide(
                      //             color: PdfColors.grey600, width: 1),
                      //         verticalInside: pw.BorderSide(
                      //             width: 1,
                      //             color: PdfColors.grey600,
                      //             style: pw.BorderStyle.solid)),
                      //     children: [
                      //       for (int index = 0;
                      //           index < tableData003.length;
                      //           index++)
                      //         pw.TableRow(children: [
                      //           pw.Container(
                      //             width: 35,
                      //             padding: const pw.EdgeInsets.all(2.0),
                      //             child: pw.Column(
                      //                 mainAxisAlignment:
                      //                     pw.MainAxisAlignment.start,
                      //                 crossAxisAlignment:
                      //                     pw.CrossAxisAlignment.center,
                      //                 children: [
                      //                   pw.Align(
                      //                     alignment: pw.Alignment.topCenter,
                      //                     child: pw.Text(
                      //                       '${index + 1}',
                      //                       maxLines: 1,
                      //                       textAlign: pw.TextAlign.left,
                      //                       style: pw.TextStyle(
                      //                           fontSize: font_Size,
                      //                           font: ttf,
                      //                           color: PdfColors.grey800),
                      //                     ),
                      //                   ),
                      //                   (tableData003[index][18].toString() ==
                      //                               '0.00' ||
                      //                           tableData003[index][18]
                      //                                   .toString() ==
                      //                               '0')
                      //                       ? pw.SizedBox()
                      //                       : pw.Align(
                      //                           alignment:
                      //                               pw.Alignment.topCenter,
                      //                           child: pw.SizedBox(
                      //                             height: 10,
                      //                           )),
                      //                 ]),
                      //           ),
                      //           pw.Expanded(
                      //               flex: 5,
                      //               child: pw.Container(
                      //                 padding: const pw.EdgeInsets.all(2.0),
                      //                 child: pw.Column(
                      //                   mainAxisAlignment:
                      //                       pw.MainAxisAlignment.start,
                      //                   crossAxisAlignment:
                      //                       pw.CrossAxisAlignment.start,
                      //                   children: [
                      //                     pw.Align(
                      //                       alignment: pw.Alignment.topLeft,
                      //                       child: pw.Text(
                      //                         (tableData003[index][0]
                      //                                     .toString() ==
                      //                                 '6')
                      //                             ? '${tableData003[index][2]}[ หน่วยที่ใช้ไป ${tableData003[index][8]}-${tableData003[index][9]} ]'
                      //                             : '${tableData003[index][2]} ${DateFormat('MMM', 'th_TH').format(DateTime.parse('${tableData003[index][1]}'))} ${DateTime.parse('${tableData003[index][1]}').year + 543}',
                      //                         maxLines: 1,
                      //                         textAlign: pw.TextAlign.left,
                      //                         style: pw.TextStyle(
                      //                             fontSize: font_Size,
                      //                             font: ttf,
                      //                             color: PdfColors.grey800),
                      //                       ),
                      //                     ),
                      //                     (tableData003[index][18].toString() ==
                      //                                 '0.00' ||
                      //                             tableData003[index][18]
                      //                                     .toString() ==
                      //                                 '0')
                      //                         ? pw.SizedBox()
                      //                         : pw.Align(
                      //                             alignment:
                      //                                 pw.Alignment.topLeft,
                      //                             child: pw.Text(
                      //                               ' - ส่วนลด',
                      //                               maxLines: 1,
                      //                               textAlign:
                      //                                   pw.TextAlign.left,
                      //                               style: pw.TextStyle(
                      //                                   // fontStyle: pw.FontStyle.italic,
                      //                                   fontSize: font_Size,
                      //                                   font: ttf,
                      //                                   color:
                      //                                       PdfColors.grey800),
                      //                             ),
                      //                           ),
                      //                   ],
                      //                 ),
                      //               )),
                      //           pw.Expanded(
                      //               flex: 2,
                      //               child: pw.Container(
                      //                 padding: const pw.EdgeInsets.all(2.0),
                      //                 child: pw.Column(
                      //                   mainAxisAlignment:
                      //                       pw.MainAxisAlignment.start,
                      //                   crossAxisAlignment:
                      //                       pw.CrossAxisAlignment.end,
                      //                   children: [
                      //                     pw.Align(
                      //                       alignment: pw.Alignment.topRight,
                      //                       child: pw.Text(
                      //                         (tableData003[index][14]
                      //                                         .toString() !=
                      //                                     '0' &&
                      //                                 tableData003[index][14] !=
                      //                                     null)
                      //                             ? 'อัตราพิเศษ'
                      //                             : '${tableData003[index][15]}',
                      //                         // (tableData003[index][7].toString() ==
                      //                         //         '0.00')
                      //                         //     ? '${tableData003[index][5]}'
                      //                         //     : '${tableData003[index][7]}',
                      //                         maxLines: 1,
                      //                         textAlign: pw.TextAlign.right,
                      //                         style: pw.TextStyle(
                      //                             decoration: (tableData003[
                      //                                                 index][18]
                      //                                             .toString() ==
                      //                                         '0.00' ||
                      //                                     tableData003[index]
                      //                                                 [18]
                      //                                             .toString() ==
                      //                                         '0')
                      //                                 ? null
                      //                                 : pw.TextDecoration
                      //                                     .lineThrough,
                      //                             fontSize: font_Size,
                      //                             font: ttf,
                      //                             color: PdfColors.grey800),
                      //                       ),
                      //                     ),
                      //                     (tableData003[index][18].toString() ==
                      //                                 '0.00' ||
                      //                             tableData003[index][18]
                      //                                     .toString() ==
                      //                                 '0')
                      //                         ? pw.SizedBox()
                      //                         : pw.Align(
                      //                             alignment:
                      //                                 pw.Alignment.topRight,
                      //                             child: pw.Text(
                      //                               '${tableData003[index][20]}',
                      //                               maxLines: 1,
                      //                               textAlign:
                      //                                   pw.TextAlign.left,
                      //                               style: pw.TextStyle(
                      //                                   // fontStyle: pw.FontStyle.italic,
                      //                                   fontSize: font_Size,
                      //                                   font: ttf,
                      //                                   color:
                      //                                       PdfColors.grey800),
                      //                             ),
                      //                           ),
                      //                   ],
                      //                 ),
                      //               )),
                      //           pw.Expanded(
                      //               flex: 2,
                      //               child: pw.Container(
                      //                 padding: const pw.EdgeInsets.all(2.0),
                      //                 child: pw.Column(
                      //                   mainAxisAlignment:
                      //                       pw.MainAxisAlignment.start,
                      //                   crossAxisAlignment:
                      //                       pw.CrossAxisAlignment.end,
                      //                   children: [
                      //                     pw.Align(
                      //                       alignment: pw.Alignment.topRight,
                      //                       child: pw.Text(
                      //                         '${tableData003[index][3]}',
                      //                         maxLines: 1,
                      //                         textAlign: pw.TextAlign.right,
                      //                         style: pw.TextStyle(
                      //                             decoration: (tableData003[
                      //                                                 index][18]
                      //                                             .toString() ==
                      //                                         '0.00' ||
                      //                                     tableData003[index]
                      //                                                 [18]
                      //                                             .toString() ==
                      //                                         '0')
                      //                                 ? null
                      //                                 : pw.TextDecoration
                      //                                     .lineThrough,
                      //                             fontSize: font_Size,
                      //                             font: ttf,
                      //                             color: PdfColors.grey800),
                      //                       ),
                      //                     ),
                      //                     (tableData003[index][18].toString() ==
                      //                                 '0.00' ||
                      //                             tableData003[index][18]
                      //                                     .toString() ==
                      //                                 '0')
                      //                         ? pw.SizedBox()
                      //                         : pw.Align(
                      //                             alignment:
                      //                                 pw.Alignment.topRight,
                      //                             child: pw.Text(
                      //                               '${tableData003[index][21]}',
                      //                               maxLines: 1,
                      //                               textAlign:
                      //                                   pw.TextAlign.left,
                      //                               style: pw.TextStyle(
                      //                                   // fontStyle: pw.FontStyle.italic,
                      //                                   fontSize: font_Size,
                      //                                   font: ttf,
                      //                                   color:
                      //                                       PdfColors.grey800),
                      //                             ),
                      //                           ),
                      //                   ],
                      //                 ),
                      //               )),
                      //           pw.Expanded(
                      //               flex: 2,
                      //               child: pw.Container(
                      //                 padding: const pw.EdgeInsets.all(2.0),
                      //                 child: pw.Column(
                      //                   mainAxisAlignment:
                      //                       pw.MainAxisAlignment.start,
                      //                   crossAxisAlignment:
                      //                       pw.CrossAxisAlignment.end,
                      //                   children: [
                      //                     pw.Align(
                      //                       alignment: pw.Alignment.topRight,
                      //                       child: pw.Text(
                      //                         '${tableData003[index][23]}',
                      //                         maxLines: 1,
                      //                         textAlign: pw.TextAlign.right,
                      //                         style: pw.TextStyle(
                      //                             decoration: (tableData003[
                      //                                                 index][18]
                      //                                             .toString() ==
                      //                                         '0.00' ||
                      //                                     tableData003[index]
                      //                                                 [18]
                      //                                             .toString() ==
                      //                                         '0')
                      //                                 ? null
                      //                                 : pw.TextDecoration
                      //                                     .lineThrough,
                      //                             fontSize: font_Size,
                      //                             font: ttf,
                      //                             color: PdfColors.grey800),
                      //                       ),
                      //                     ),
                      //                     (tableData003[index][18].toString() ==
                      //                                 '0.00' ||
                      //                             tableData003[index][18]
                      //                                     .toString() ==
                      //                                 '0')
                      //                         ? pw.SizedBox()
                      //                         : pw.Align(
                      //                             alignment:
                      //                                 pw.Alignment.topRight,
                      //                             child: pw.Text(
                      //                               '${tableData003[index][24]}',
                      //                               maxLines: 1,
                      //                               textAlign:
                      //                                   pw.TextAlign.left,
                      //                               style: pw.TextStyle(
                      //                                   // fontStyle: pw.FontStyle.italic,
                      //                                   fontSize: font_Size,
                      //                                   font: ttf,
                      //                                   color:
                      //                                       PdfColors.grey800),
                      //                             ),
                      //                           ),
                      //                   ],
                      //                 ),
                      //               )),
                      //         ]),
                      //     ],
                      //   ),
                      // ),

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
                                    left:
                                        pw.BorderSide(color: PdfColors.grey600),
                                  ),
                                ),
                                width: 35,
                                // height: 25,
                                padding: const pw.EdgeInsets.all(2.0),
                              ),
                              pw.Expanded(
                                flex: 8,
                                child: pw.Container(
                                  decoration: const pw.BoxDecoration(
                                    // color: PdfColors.green100,
                                    border: pw.Border(
                                      left: pw.BorderSide(
                                          color: PdfColors.grey600),
                                    ),
                                  ),
                                  // height: 25,
                                  padding: const pw.EdgeInsets.all(2.0),
                                ),
                              ),
                              pw.Expanded(
                                flex: 2,
                                child: pw.Container(
                                  decoration: const pw.BoxDecoration(
                                    // color: PdfColors.green100,
                                    border: pw.Border(
                                      left: pw.BorderSide(
                                          color: PdfColors.grey600),
                                    ),
                                  ),
                                  // height: 25,
                                  padding: const pw.EdgeInsets.all(2.0),
                                ),
                              ),
                              pw.Expanded(
                                flex: 2,
                                child: pw.Container(
                                  decoration: const pw.BoxDecoration(
                                    // color: PdfColors.green100,
                                    border: pw.Border(
                                      left: pw.BorderSide(
                                          color: PdfColors.grey600),
                                    ),
                                  ),
                                  // height: 25,
                                  padding: const pw.EdgeInsets.all(2.0),
                                ),
                              ),
                              pw.Expanded(
                                flex: 2,
                                child: pw.Container(
                                  decoration: const pw.BoxDecoration(
                                    // color: PdfColors.green100,
                                    border: pw.Border(
                                      left: pw.BorderSide(
                                          color: PdfColors.grey600),
                                      right: pw.BorderSide(
                                          color: PdfColors.grey600),
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
                    ]))
          ];
        },
        footer: (context) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            mainAxisSize: pw.MainAxisSize.min,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                height: 7,
              ),
              Sub(),
              pw.SizedBox(
                height: 7,
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
    // final bytes = await pdf.save();

    // final dir = await getApplicationDocumentsDirectory();
    // final file = File('${dir.path}/name');
    // await file.writeAsBytes(bytes);
    // return file;
    ///////----------------------------------------->
    // final List<int> bytes = await pdf.save();
    // final Uint8List data = Uint8List.fromList(bytes);
    // MimeType type = MimeType.PDF;
    // final dir = await FileSaver.instance.saveFile(
    //     "ใบเสนอราคา(ณ วันที่${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day})",
    //     data,
    //     "pdf",
    //     mimeType: type);
    if (Preview_ser.toString() == 'Folder') {
      final List<int> bytes = await pdf.save(); // Save the PDF as bytes
      final Uint8List data = Uint8List.fromList(bytes); // Convert to Uint8List
      var name_1 = 'ใบวางบิล/ใบแจ้งหนี้${cFinn}';
      // Upload the file
      await uploadFile(data, name_1);
    } else if (Preview_ser.toString() == 'File') {
      final List<int> bytes = await pdf.save();
      final Uint8List data = Uint8List.fromList(bytes);
      MimeType type = MimeType.PDF;
      final dir = await FileSaver.instance
          .saveFile('ใบวางบิล/ใบแจ้งหนี้${cFinn}', data, "pdf", mimeType: type);
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PreviewPdfgen_Bills(
                doc: pdf, nameBills: 'ใบวางบิล/ใบแจ้งหนี้${cFinn}'),
          ));
    }
  }
}
