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

import '../../../Constant/Myconstant.dart';
import '../../../Man_PDF/Preview_PDF/PreviewPdfgen_Billsplay.dart';
import '../../../Model/trans_re_bill_history_model.dart';
import '../../../Style/File_s.dart';
import '../../../Style/ThaiBaht.dart';
import '../../../Style/colors.dart';
import '../../../Style/loadAndCacheImage.dart';

class Pdfgen_his_statusbill_TP7_nim {
//////////---------------------------------------------------->(ใบเสร็จรับเงิน/ใบกำกับภาษี)   ใช้  //

  static void exportPDF_statusbill_TP7_nim(
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
      Con_remark) async {
    ////
    //// ------------>(ใบเสร็จรับเงินชั่วคราว paySrsscreen_)
    ///////
    final pdf = pw.Document();
    final font = await rootBundle.load("${fonts_pdf}");
    var Colors_pd = PdfColors.black;
    // final font = await rootBundle.load("fonts/Sarabun-Medium.ttf");

    int pageCount = 1; // Initialize the page count
    final ttf = pw.Font.ttf(font);

    double font_Size = 8.0;
    DateTime dateTime2 = DateTime.parse(date_Transaction);
    int newYear2 = dateTime2.year + 543;
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
    final thaiDate2 = DateTime.parse(dayfinpay);
    final formatter2 = DateFormat('d MMMM', 'th_TH');
    final formattedDate2 = formatter.format(thaiDate2);
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

    /// ///---------------------> Table header columns (หัวคอลัมน์ของตาราง)
    final headerColumns = [
      {'label': 'รายการ', 'flex': 8, 'align': pw.Alignment.center},
      {'label': 'หน่วย', 'flex': 2, 'align': pw.Alignment.center},
      {'label': 'จำนวน', 'flex': 2, 'align': pw.Alignment.center},
      {'label': 'ราคา/หน่วย', 'flex': 2, 'align': pw.Alignment.center},
      {'label': 'จำนวนเงิน', 'flex': 2, 'align': pw.Alignment.center},
    ];
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
    const PdfColor PDF_Border_Color = PDFConstants.borderColor;
    ///////----------------->
    // ฟังก์ชันปัดเศษทศนิยม 2 ตำแหน่ง
    double roundMoney(double value) {
      return (value * 100).round() / 100;
    }

    final totalAmt = roundMoney(getTotalByField(
        _TransReBillHistoryModels, (e) => e.amt.toString() ?? '0'));
    final totalPvat = roundMoney(getTotalByField(
        _TransReBillHistoryModels, (e) => e.pvat.toString() ?? '0'));
    final totalVat = roundMoney(getTotalByField(
        _TransReBillHistoryModels, (e) => e.vat.toString() ?? '0'));
    final totalWht = roundMoney(getTotalByField(
        _TransReBillHistoryModels, (e) => e.wht.toString() ?? '0'));
    final totalLine = roundMoney(getTotalByField(
        _TransReBillHistoryModels, (e) => e.total.toString() ?? '0'));
    final totalDis =
        roundMoney(double.tryParse(sum_disamt.toString() ?? '0.00') ?? 0.00);
    final totalFee =
        roundMoney(double.tryParse(sum_fee.toString() ?? '0.00') ?? 0.00);
    final totalMatjum = roundMoney(
        double.tryParse(dis_sum_Matjum.toString() ?? '0.00') ?? 0.00);
    final totalPakan =
        roundMoney(double.tryParse(dis_sum_Pakan.toString() ?? '0.00') ?? 0.00);

    final totalBill = roundMoney(roundMoney((totalLine + totalFee) - totalDis) -
        (totalMatjum + totalPakan));

    ///////------------------------------->

    String getFormattedText(String? data) {
      final value =
          (data == null) ? 0.00 : double.tryParse(data ?? '0.00') ?? 0.00;
      return nFormat.format(value);
    }

    bool isPositive(String? value) {
      return (double.tryParse(value ?? '0.00') ?? 0.00) > 0;
    }

    // pw.Widget buildCell({
    //   required String text,
    //   bool topBorder = false,
    //   int flex = 1,
    //   double padding = 2.0,
    //   pw.Alignment alignment = pw.Alignment.center,
    //   pw.TextAlign textAlign = pw.TextAlign.center,
    // }) {
    //   return pw.Expanded(
    //     flex: flex,
    //     child: pw.Container(
    //       decoration: pw.BoxDecoration(
    //         border: pw.Border(
    //           left: const pw.BorderSide(color: PdfColors.grey800),
    //           right: const pw.BorderSide(color: PdfColors.grey800),
    //           top: topBorder
    //               ? const pw.BorderSide(color: PdfColors.grey800)
    //               : pw.BorderSide.none,
    //         ),
    //       ),
    //       padding: pw.EdgeInsets.all(padding),
    //       child: pw.Align(
    //         alignment: alignment,
    //         child: pw.Text(
    //           text,
    //           maxLines: 2,
    //           textAlign: textAlign,
    //           style: pw.TextStyle(
    //             fontSize: font_Size,
    //             font: ttf,
    //             color: PdfColors.grey800,
    //           ),
    //         ),
    //       ),
    //     ),
    //   );
    // }

    pw.Widget buildCell({
      required pw.Widget child,
      bool topBorder = false,
      int flex = 1,
      double padding = 2.0,
      pw.Alignment alignment = pw.Alignment.center,
    }) {
      return pw.Expanded(
        flex: flex,
        child: pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border(
              left: const pw.BorderSide(color: PdfColors.black),
              right: const pw.BorderSide(color: PdfColors.black),
              top: topBorder
                  ? const pw.BorderSide(color: PdfColors.black)
                  : pw.BorderSide.none,
            ),
          ),
          padding: pw.EdgeInsets.all(padding),
          child: pw.Align(
            alignment: alignment,
            child: child,
          ),
        ),
      );
    }

    pw.Widget cellWithTopSpace(
        String? unitser, String text, pw.Font ttf, double font_Size) {
      if (unitser.toString() == '6') {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
                height: font_Size +
                    0.5 *
                        PdfPageFormat
                            .mm), // ⭐ เว้น 1 บรรทัด ตามความสูงฟอนต์จริง
            pw.Text(
              text,
              style: pw.TextStyle(
                font: ttf,
                fontSize: font_Size,
                color: PdfColors.black,
              ),
            ),
          ],
        );
      }

      // ถ้าไม่ใช่ unitser == 6
      return pw.Text(
        text,
        style: pw.TextStyle(
          font: ttf,
          fontSize: font_Size,
          color: PdfColors.black,
        ),
      );
    }

    pw.Widget cellWithBottomSpace(
        String? unitser, String text, pw.Font ttf, double font_Size) {
      if (unitser.toString() == '6') {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              text,
              style: pw.TextStyle(
                font: ttf,
                fontSize: font_Size,
                color: PdfColors.black,
              ),
            ),
            // pw.SizedBox(height: font_Size), // ⭐ เว้นบรรทัดด้านล่าง 1 บรรทัด
            pw.Text(
              '????????',
              style: pw.TextStyle(
                font: ttf,
                fontSize: font_Size,
                color: PdfColors.black,
              ),
            ),
          ],
        );
      }

      // ถ้าไม่ใช่ unitser == 6
      return pw.Text(
        text,
        style: pw.TextStyle(
          font: ttf,
          fontSize: font_Size,
          color: PdfColors.black,
        ),
      );
    }

    pw.Widget buildPayBox({
      required String label,
      required bool isChecked,
    }) {
      return pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Container(
            width: 8,
            height: 8,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 0.6, color: PdfColors.black),
            ),
            child: isChecked
                ? pw.Center(
                    child: pw.Container(
                      width: 5,
                      height: 5,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.black,
                        borderRadius: pw.BorderRadius.circular(1),
                      ),
                    ),
                  )
                : null,
          ),
          pw.SizedBox(width: 3),
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: font_Size,
              font: ttf,
              color: Colors_pd,
            ),
          ),
        ],
      );
    }

    pw.Widget Header(int serpang) {
      return pw.Column(children: [
        // if (serpang != 1) pw.SizedBox(height: 10.00),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // 🔹 โลโก้ (fixed width)
            pw.Container(
              // alignment: pw.Alignment.center,
              height: 30,
              width: 60,
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: resizedLogo != null
                  ? pw.Image(
                      pw.MemoryImage(resizedLogo),
                      height: 30,
                      width: 60,
                      fit: pw.BoxFit.fill,
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

            pw.SizedBox(width: 5 * PdfPageFormat.mm),

            pw.Expanded(
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      // '${bill_name.trim()}',
                      'บริษัท นิ่มซิตี้เดลี จํากัด',
                      maxLines: 2,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: font_Size,
                        color: Colors_pd,
                        font: ttf,
                      ),
                    ),
                  ),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'สำนักงานใหญ่',
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(width: 2 * PdfPageFormat.mm),
                      pw.Container(
                        // margin: pw.EdgeInsets.only(top: 2.0),
                        width: 8,
                        height: 8,
                        decoration: pw.BoxDecoration(
                          border:
                              pw.Border.all(width: 0.8, color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(width: 2 * PdfPageFormat.mm),
                      pw.Expanded(
                        child: pw.Text(
                          '${bill_addr.trim()} โทร. $bill_tel',
                          maxLines: 3,
                          style: pw.TextStyle(
                            fontSize: font_Size,
                            font: ttf,
                            color: Colors_pd,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'สาขาที่ 1',
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(width: 5.7 * PdfPageFormat.mm),
                      pw.Container(
                        // margin: pw.EdgeInsets.only(top: 2.0),
                        width: 8,
                        height: 8,
                        decoration: pw.BoxDecoration(
                          border:
                              pw.Border.all(width: 0.8, color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(width: 2 * PdfPageFormat.mm),
                      pw.Expanded(
                        child: pw.Text(
                          '13 ถนนรัตนโกสินทร์ ตําบลศรีภูมิ อําเภอเมืองเชียงใหม่ จังหวัดเชียงใหม่ 50200 โทร. 081-9613215',
                          maxLines: 3,
                          style: pw.TextStyle(
                            fontSize: font_Size,
                            font: ttf,
                            color: Colors_pd,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.Text(
                    '${' ' * 29}เลขประจําตัวผู้เสียภาษีอากร ${bill_tax.trim()}',
                    maxLines: 3,
                    style: pw.TextStyle(
                      fontSize: font_Size,
                      color: Colors_pd,
                      font: ttf,
                    ),
                  ),
                ],
              ),
            ),

            pw.Container(
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    (serpang == 1)
                        ? '(สำหรับลูกค้า)'
                        : (serpang == 2)
                            ? '(สำเนาส่วนที่ 1)'
                            : '(สำเนาส่วนที่ 2)',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontSize: font_Size,
                      font: ttf,
                      color: PdfColors.grey800,
                    ),
                  ),
                  pw.Text(
                    'วันที่พิมพ์ ${DateFormat('dd/MM/').format(DateTime.now())}${DateTime.now().year + 543} ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontSize: font_Size,
                      font: ttf,
                      color: PdfColors.grey800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 2 * PdfPageFormat.mm),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Center(
              child: pw.Text(
                'ใบเสร็จรับเงิน',
                style: pw.TextStyle(
                  fontSize: font_Size,
                  fontWeight: pw.FontWeight.bold,
                  font: ttf,
                  color: Colors_pd,
                ),
              ),
            ),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                // (cFinn == null ||
                //         cFinn.toString().isEmpty ||
                //         cFinn.toString() == 'null')
                //     ? 'ใบแจ้งหนี้เลขที่ # -'
                //     : 'ใบแจ้งหนี้เลขที่ # ${cFinn}',
                (numdoctax.toString() == '')
                    ? 'ใบเสร็จเลขที่ # $numinvoice '
                    : 'ใบเสร็จเลขที่ # $numdoctax ',

                style: pw.TextStyle(
                  fontSize: font_Size,
                  fontWeight: pw.FontWeight.bold,
                  font: ttf,
                  color: Colors_pd,
                ),
              ),
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  (cname != null &&
                          cname.toString().trim().isNotEmpty &&
                          cname.toString() != 'null' &&
                          cname.toString() != '-')
                      ? 'ได้รับเงินจาก $cname เลขประจำตัวผู้เสีนภาษี $tax'
                      : (sname != null &&
                              sname.toString().trim().isNotEmpty &&
                              sname.toString() != 'null' &&
                              sname.toString() != '-')
                          ? 'ได้รับเงินจาก $sname เลขประจำตัวผู้เสีนภาษี $tax'
                          : 'ได้รับเงินจาก - เลขประจำตัวผู้เสีนภาษี $tax',
                  style: pw.TextStyle(
                    fontSize: font_Size,
                    fontWeight: pw.FontWeight.bold,
                    font: ttf,
                    color: Colors_pd,
                  ),
                ),
                pw.Text(
                  (date_Transaction == null)
                      ? 'วันที่ -'
                      : 'วันที่ $formattedDate2 พ.ศ.${newYear2}',
                  style: pw.TextStyle(
                    fontSize: font_Size,
                    fontWeight: pw.FontWeight.bold,
                    font: ttf,
                    color: Colors_pd,
                  ),
                ),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                // ----- ฝั่งซ้าย -----
                pw.Expanded(
                  child: pw.Text(
                    (addr.toString() == null ||
                            addr.toString() == '' ||
                            addr.toString() == 'null')
                        ? ' -'
                        : '$addr',
                    style: pw.TextStyle(
                      fontSize: font_Size,
                      fontWeight: pw.FontWeight.bold,
                      font: ttf,
                      color: Colors_pd,
                    ),
                  ),
                ),

                // ----- ฝั่งขวาให้ลูปเหมือนเดิม -----
                for (var i = 0; i < finnancetransModels.length; i++)
                  if (finnancetransModels[i].dtype.toString() != 'FTA')
                    pw.Row(
                      children: [
                        pw.Text(
                          'ชำระโดย ',
                          style: pw.TextStyle(
                            fontSize: font_Size,
                            fontWeight: pw.FontWeight.bold,
                            font: ttf,
                            color: Colors_pd,
                          ),
                        ),
                        pw.SizedBox(width: 4),

                        // ==== กล่อง 1 เงินสด ====
                        buildPayBox(
                          label: ' เงินสด',
                          isChecked: (finnancetransModels[i].dtype == 'KP' &&
                              finnancetransModels[i].type == 'CASH'),
                        ),
                        pw.SizedBox(width: 8),

                        // ==== กล่อง 2 เช็ค ====
                        buildPayBox(
                          label: ' เช็ค',
                          isChecked: (finnancetransModels[i].dtype != 'KP'),
                        ),
                        pw.SizedBox(width: 8),

                        // ==== กล่อง 3 เงินโอน ====
                        buildPayBox(
                          label: ' เงินโอน',
                          isChecked: (finnancetransModels[i].dtype == 'KP' &&
                              finnancetransModels[i].type != 'CASH'),
                        ),
                      ],
                    ),
              ],
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
          ],
        )
      ]);
    }

    pw.Widget footer_data(int serpang) {
      return pw.Align(
        alignment: pw.Alignment.bottomCenter,
        child: pw.Container(
          // decoration: new pw.BoxDecoration(
          //     border: pw.Border(
          //         bottom: pw.BorderSide(
          //             color: PdfColors.grey600,
          //             width: 2.0,
          //             style: pw.BorderStyle.none))),
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // pw.SizedBox(height: 1 * PdfPageFormat.mm),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'ลงนาม..................................................................ผู้รับเงิน',
                          textAlign: pw.TextAlign.left,
                          maxLines: 1,
                          style: pw.TextStyle(
                              // fontWeight: pw.FontWeight.bold,
                              font: ttf,
                              fontSize: font_Size,
                              color: PdfColors.black),
                        ),
                        pw.Text(
                          '$fname',
                          textAlign: pw.TextAlign.left,
                          maxLines: 1,
                          style: pw.TextStyle(
                              // fontWeight: pw.FontWeight.bold,
                              font: ttf,
                              fontSize: font_Size,
                              color: PdfColors.black),
                        ),
                        pw.Text(
                          // 'กรุณาโอนเข้าบัญชี ${bank1} สาขานิ่มซิตี้เดลี่ ชื่อบัญชี บริษัทนิ่มซิตี้เดลี่ จำกัด เลขที่ ${payment_Bno1} ',
                          'โอนเข้า บ.นิ่มซิตี้เดลี่ จำกัด ธ.กรุงไทย สาขานิ่มซิตี้เดลี่ เลขที่ 771-0-01-967-6',
                          textAlign: pw.TextAlign.left,
                          maxLines: 1,
                          style: pw.TextStyle(
                              // fontWeight: pw.FontWeight.bold,
                              font: ttf,
                              fontSize: font_Size,
                              color: PdfColors.black),
                        ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'ลงชื่อ..................................................................เจ้าหน้าที่ผู้รับมอบอำนาจ',
                          textAlign: pw.TextAlign.left,
                          maxLines: 1,
                          style: pw.TextStyle(
                              // fontWeight: pw.FontWeight.bold,
                              font: ttf,
                              fontSize: font_Size,
                              color: PdfColors.black),
                        ),
                        // pw.Text(
                        //   '(........................................................)',
                        //   textAlign: pw.TextAlign.left,
                        //   maxLines: 1,
                        //   style: pw.TextStyle(
                        //       // fontWeight: pw.FontWeight.bold,
                        //       font: ttf,
                        //       fontSize: font_Size,
                        //       color: PdfColors.grey800),
                        // ),
                        // pw.Text(
                        //   'วันที่/Date........................................................',
                        //   textAlign: pw.TextAlign.left,
                        //   maxLines: 1,
                        //   style: pw.TextStyle(
                        //       // fontWeight: pw.FontWeight.bold,
                        //       font: ttf,
                        //       fontSize: font_Size,
                        //       color: PdfColors.grey800),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
              if (serpang == 1 || serpang == 2)
                pw.Padding(
                  padding: pw.EdgeInsets.all(0),
                  child: pw.Text(
                    '---' * 140,
                    maxLines: 1,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                        font: ttf,
                        fontSize: font_Size,
                        color: PdfColors.grey500),
                  ),
                ),
              // if (TransReBillHistory.length > 6)
              // pw.SizedBox(height: 2.2 * PdfPageFormat.mm),
            ],
          ),
        ),
      );
    }

    pw.Widget Body_data(int serpang) {
      return pw.Container(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Align(
              alignment: pw.Alignment.topCenter,
              child: pw.Container(
                  child: pw.Column(
                children: [
                  //////////////---------------------------------->
                  pw.Container(
                    decoration: const pw.BoxDecoration(
                      // color: PdfColors.green100,
                      border: pw.Border(
                        top: pw.BorderSide(color: PdfColors.black),
                        // bottom: pw.BorderSide(color: PdfColors.grey800),
                        left: pw.BorderSide(color: PdfColors.black),
                        // right: pw.BorderSide(color: PdfColors.grey800),
                      ),
                    ),
                    child: pw.Row(
                      children: headerColumns.map((col) {
                        final label = col['label'] as String;
                        final flex = col['flex'] as int;
                        final align = col['align'] as pw.Alignment;
                        final width = col['width'] as double?;

                        final container = pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                              right: pw.BorderSide(color: PdfColors.black),
                              // bottom: pw.BorderSide(color: PdfColors.grey800),
                            ),
                          ),
                          padding: const pw.EdgeInsets.all(2.0),
                          child: pw.Align(
                            alignment: align,
                            child: pw.Text(
                              label,
                              maxLines: 1,
                              textAlign: (align == pw.Alignment.centerRight)
                                  ? pw.TextAlign.right
                                  : pw.TextAlign.left,
                              style: pw.TextStyle(
                                fontSize: font_Size,
                                fontWeight: pw.FontWeight.bold,
                                font: ttf,
                                color: PdfColors.black,
                              ),
                            ),
                          ),
                        );

                        if (width != null && flex == 0) {
                          return pw.Container(
                            width: width,
                            height: 20,
                            // decoration: const pw.BoxDecoration(
                            //   border: pw.Border(
                            //     left: pw.BorderSide(color: PdfColors.grey600),
                            //   ),
                            // ),
                            padding: const pw.EdgeInsets.all(2.0),
                            child: container.child,
                          );
                        }

                        return pw.Expanded(flex: flex, child: container);
                      }).toList(),
                    ),
                  ),

                  pw.Column(
                    children: List.generate(TransReBillHistory.length, (index) {
                      final TransReBill = TransReBillHistory[index];

                      // return pw.Container(
                      //   child: pw.Row(
                      //     children: [
                      //       // ✅ ใช้โค้ด buildCell เหมือนเดิม
                      //       buildCell(
                      //         text: (TransReBill.unitser.toString() == '6')
                      //             ? '${TransReBill.expname} ประจำเดือน ${DateFormat('MMMM', 'th').format(DateTime.parse(TransReBill.date!))} ${DateTime.parse('${TransReBill.date}').year + 543} [ มิเตอร์ก่อน-หลัง ${TransReBill.ovalue}-${TransReBill.nvalue} ]' // miter before/after
                      //             : '${TransReBill.expname} ประจำเดือน ${DateFormat('MMMM', 'th').format(DateTime.parse(TransReBill.date!))} ${DateTime.parse('${TransReBill.date}').year + 543}',
                      //         flex: 8,
                      //         alignment: pw.Alignment.centerLeft,
                      //         textAlign: pw.TextAlign.right,
                      //         topBorder: index == 0,
                      //       ),

                      //       buildCell(
                      //         text: 'เดือน/Month???',
                      //         flex: 2,
                      //         alignment: pw.Alignment.center,
                      //         textAlign: pw.TextAlign.center,
                      //         topBorder: index == 0,
                      //       ),

                      //       buildCell(
                      //         text: '${getFormattedText(TransReBill.qty)}',
                      //         flex: 2,
                      //         alignment: pw.Alignment.centerRight,
                      //         textAlign: pw.TextAlign.right,
                      //         topBorder: index == 0,
                      //       ),
                      //       // ราคา/หน่วย
                      //       buildCell(
                      //         text: (TransReBill.ele_ty.toString() != '0' &&
                      //                 TransReBill.ele_ty != null)
                      //             ? 'อัตราพิเศษ'
                      //             : (TransReBill.dtype.toString() == 'KU')
                      //                 ? getFormattedText('${TransReBill.pri}')
                      //                 : getFormattedText('${TransReBill.pri}'),
                      //         flex: 2,
                      //         alignment: pw.Alignment.centerRight,
                      //         textAlign: pw.TextAlign.right,
                      //         topBorder: index == 0,
                      //       ),
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
                      //       //   topBorder: index == 0,
                      //       // ),
                      //       buildCell(
                      //         text: getFormattedText('${TransReBill.total}'),
                      //         flex: 2,
                      //         alignment: pw.Alignment.centerRight,
                      //         textAlign: pw.TextAlign.right,
                      //         topBorder: index == 0,
                      //       ),
                      //     ],
                      //   ),
                      // );
                      return pw.Container(
                        child: pw.Row(
                          children: [
                            // 🔹 expname
                            buildCell(
                              child: cellWithBottomSpace(
                                TransReBill.unitser,
                                (TransReBill.unitser.toString() == '6')
                                    ? '${TransReBill.expname} ประจำเดือน ${DateFormat('MMMM', 'th').format(DateTime.parse(TransReBill.date!))} ${DateTime.parse('${TransReBill.date}').year + 543} [ มิเตอร์ก่อน-หลัง ${TransReBill.ovalue}-${TransReBill.nvalue} ]'
                                    : '${TransReBill.expname} ประจำเดือน ${DateFormat('MMMM', 'th').format(DateTime.parse(TransReBill.date!))} ${DateTime.parse('${TransReBill.date}').year + 543}',
                                ttf,
                                font_Size,
                              ),
                              flex: 8,
                              alignment: pw.Alignment.centerLeft,
                              topBorder: index == 0,
                            ),

                            // 🔹 Month
                            buildCell(
                              child: cellWithTopSpace(
                                TransReBill.unitser,
                                'เดือน/Month',
                                ttf,
                                font_Size,
                              ),
                              flex: 2,
                              alignment: pw.Alignment.center,
                              topBorder: index == 0,
                            ),

                            // 🔹 qty
                            buildCell(
                              child: cellWithTopSpace(
                                TransReBill.unitser,
                                getFormattedText(TransReBill.qty),
                                ttf,
                                font_Size,
                              ),
                              flex: 2,
                              alignment: pw.Alignment.centerRight,
                              topBorder: index == 0,
                            ),

                            // 🔹 ราคา/หน่วย
                            buildCell(
                              child: cellWithTopSpace(
                                TransReBill.unitser,
                                (TransReBill.ele_ty.toString() != '0' &&
                                        TransReBill.ele_ty != null)
                                    ? 'อัตราพิเศษ'
                                    : getFormattedText('${TransReBill.pri}'),
                                ttf,
                                font_Size,
                              ),
                              flex: 2,
                              alignment: pw.Alignment.centerRight,
                              topBorder: index == 0,
                            ),

                            // 🔹 total
                            buildCell(
                              child: cellWithTopSpace(
                                TransReBill.unitser,
                                getFormattedText(
                                    '${TransReBill.pvat}'), //${TransReBill.total}
                                ttf,
                                font_Size,
                              ),
                              flex: 2,
                              alignment: pw.Alignment.centerRight,
                              topBorder: index == 0,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  // pw.Container(
                  //   height: () {
                  //     final c = TransReBillHistory.length;
                  //     if (c < 2) return 30.0 * PdfPageFormat.mm;
                  //     if (c < 3) return 24.0 * PdfPageFormat.mm;
                  //     if (c < 4) return 18.0 * PdfPageFormat.mm;
                  //     if (c < 5) return 12.0 * PdfPageFormat.mm;
                  //     if (c < 6) return 6.0 * PdfPageFormat.mm;
                  //     return 0.0;
                  //   }(),
                  //   decoration: const pw.BoxDecoration(
                  //     // color: PdfColors.green100,
                  //     border: pw.Border(
                  //       // top: pw.BorderSide(color: PdfColors.grey600),
                  //       bottom: pw.BorderSide(color: PdfColors.grey800),
                  //     ),
                  //   ),
                  //   child: pw.Row(
                  //     children: [
                  //       pw.Expanded(
                  //         flex: 8,
                  //         child: pw.Container(
                  //           decoration: const pw.BoxDecoration(
                  //             // color: PdfColors.green100,
                  //             border: pw.Border(
                  //               left: pw.BorderSide(color: PdfColors.grey800),
                  //               right: pw.BorderSide(color: PdfColors.grey800),
                  //             ),
                  //           ),
                  //           // height: 25,
                  //           padding: const pw.EdgeInsets.all(2.0),
                  //         ),
                  //       ),
                  //       pw.Expanded(
                  //         flex: 2,
                  //         child: pw.Container(
                  //           decoration: const pw.BoxDecoration(
                  //             // color: PdfColors.green100,
                  //             border: pw.Border(
                  //               left: pw.BorderSide(color: PdfColors.grey800),
                  //               right: pw.BorderSide(color: PdfColors.grey800),
                  //             ),
                  //           ),
                  //           // height: 25,
                  //           padding: const pw.EdgeInsets.all(2.0),
                  //         ),
                  //       ),
                  //       pw.Expanded(
                  //         flex: 2,
                  //         child: pw.Container(
                  //           decoration: const pw.BoxDecoration(
                  //             // color: PdfColors.green100,
                  //             border: pw.Border(
                  //               left: pw.BorderSide(color: PdfColors.grey800),
                  //               right: pw.BorderSide(color: PdfColors.grey800),
                  //             ),
                  //           ),
                  //           // height: 25,
                  //           padding: const pw.EdgeInsets.all(2.0),
                  //         ),
                  //       ),
                  //       pw.Expanded(
                  //         flex: 2,
                  //         child: pw.Container(
                  //           decoration: const pw.BoxDecoration(
                  //             // color: PdfColors.green100,
                  //             border: pw.Border(
                  //               left: pw.BorderSide(color: PdfColors.grey800),
                  //               right: pw.BorderSide(color: PdfColors.grey800),
                  //             ),
                  //           ),
                  //           // height: 25,
                  //           padding: const pw.EdgeInsets.all(2.0),
                  //         ),
                  //       ),
                  //       pw.Expanded(
                  //         flex: 2,
                  //         child: pw.Container(
                  //           decoration: const pw.BoxDecoration(
                  //             // color: PdfColors.green100,
                  //             border: pw.Border(
                  //               left: pw.BorderSide(color: PdfColors.grey800),
                  //               right: pw.BorderSide(color: PdfColors.grey800),
                  //             ),
                  //           ),
                  //           // height: 25,
                  //           padding: const pw.EdgeInsets.all(2.0),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  // pw.Divider(color: PdfColors.grey),

                  // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  pw.Container(
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        top: pw.BorderSide(color: PdfColors.black),
                        bottom: pw.BorderSide(color: PdfColors.black),
                        left: pw.BorderSide(color: PdfColors.black),
                        right: pw.BorderSide(color: PdfColors.black),
                      ),
                    ),
                    child: pw.Row(
                      children: [
                        // ----------- ช่องซ้าย (ข้อความ Convert ThaiBaht) -----------
                        pw.Expanded(
                          flex: 10,
                          child: pw.Container(
                            alignment: pw.Alignment.center,
                            padding: const pw.EdgeInsets.symmetric(vertical: 6),
                            child: pw.Text(
                              '(~${convertToThaiBaht(totalBill)}~)',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: font_Size,
                                font: ttf,
                                fontStyle: pw.FontStyle.italic,
                                color: PdfColors.black,
                              ),
                            ),
                          ),
                        ),

                        // ----------- ช่องขวาแบบกรอบ + เส้นหลังข้อความ -----------
                        pw.Expanded(
                          flex: 6,
                          child: pw.Container(
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                left: pw.BorderSide(color: PdfColors.black),
                              ),
                            ),
                            child: pw.Column(
                              children: [
                                // ------------------- แถว 1 -------------------
                                pw.Container(
                                  decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                      bottom:
                                          pw.BorderSide(color: PdfColors.black),
                                    ),
                                  ),
                                  child: pw.Row(
                                    children: [
                                      // ข้อความพร้อมเส้นต่อหลัง
                                      pw.Expanded(
                                        flex: 4,
                                        child: pw.Container(
                                          padding:
                                              const pw.EdgeInsets.symmetric(
                                                  vertical: 2, horizontal: 2),
                                          decoration: const pw.BoxDecoration(
                                            border: pw.Border(
                                              right: pw.BorderSide(
                                                  color: PdfColors.black),
                                            ),
                                          ),
                                          child: pw.Text(
                                            'มูลค่าก่อน VAT',
                                            textAlign: pw.TextAlign.right,
                                            style: pw.TextStyle(
                                              font: ttf,
                                              fontSize: font_Size,
                                              color: PdfColors.black,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // ตัวเลข
                                      pw.Expanded(
                                        flex: 2,
                                        child: pw.Padding(
                                          padding:
                                              const pw.EdgeInsets.symmetric(
                                                  horizontal: 2),
                                          child: pw.Text(
                                            nFormat.format(totalPvat),
                                            textAlign: pw.TextAlign.right,
                                            style: pw.TextStyle(
                                              font: ttf,
                                              fontSize: font_Size,
                                              color: PdfColors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // ------------------- แถว 2 -------------------
                                pw.Container(
                                  decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                      bottom:
                                          pw.BorderSide(color: PdfColors.black),
                                    ),
                                  ),
                                  child: pw.Row(
                                    children: [
                                      pw.Expanded(
                                        flex: 4,
                                        child: pw.Container(
                                          padding:
                                              const pw.EdgeInsets.symmetric(
                                                  vertical: 2, horizontal: 2),
                                          decoration: const pw.BoxDecoration(
                                            border: pw.Border(
                                              right: pw.BorderSide(
                                                  color: PdfColors.black),
                                            ),
                                          ),
                                          child: pw.Text(
                                            'ภาษีมูลค่าเพิ่ม',
                                            textAlign: pw.TextAlign.right,
                                            style: pw.TextStyle(
                                              font: ttf,
                                              fontSize: font_Size,
                                              color: PdfColors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      pw.Expanded(
                                        flex: 2,
                                        child: pw.Padding(
                                          padding:
                                              const pw.EdgeInsets.symmetric(
                                                  horizontal: 2),
                                          child: pw.Text(
                                            nFormat.format(totalVat),
                                            textAlign: pw.TextAlign.right,
                                            style: pw.TextStyle(
                                              font: ttf,
                                              fontSize: font_Size,
                                              color: PdfColors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // ------------------- แถว 3 -------------------
                                pw.Container(
                                  child: pw.Row(
                                    children: [
                                      pw.Expanded(
                                        flex: 4,
                                        child: pw.Container(
                                          padding:
                                              const pw.EdgeInsets.symmetric(
                                                  vertical: 2, horizontal: 2),
                                          decoration: const pw.BoxDecoration(
                                            border: pw.Border(
                                              right: pw.BorderSide(
                                                  color: PdfColors.black),
                                            ),
                                          ),
                                          child: pw.Text(
                                            'รวมเงิน',
                                            textAlign: pw.TextAlign.right,
                                            style: pw.TextStyle(
                                              font: ttf,
                                              fontSize: font_Size,
                                              color: PdfColors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      pw.Expanded(
                                        flex: 2,
                                        child: pw.Padding(
                                          padding:
                                              const pw.EdgeInsets.symmetric(
                                                  horizontal: 2),
                                          child: pw.Text(
                                            nFormat.format(totalBill),
                                            textAlign: pw.TextAlign.right,
                                            style: pw.TextStyle(
                                                font: ttf,
                                                fontSize: font_Size,
                                                color: PdfColors.black),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                ],
              )),
            ),
            footer_data(serpang)
          ],
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginBottom: 30.00,
          marginLeft: 30.00,
          marginRight: 30.00,
          marginTop: 30.00,
        ),
        build: (context) {
          return [
            pw.Container(
                // margin: pw.EdgeInsets.only(top: 2), // ⭐ เว้นเท่ากันทุกกล่อง
                height: (PdfPageFormat.a4.height - 60) / 3,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(),
                ),
                child: pw.Column(
                  children: [
                    Header(1),
                    pw.Expanded(child: Body_data(1)),
                  ],
                )),
            pw.Container(
                // margin: pw.EdgeInsets.only(top: 2), // ⭐ เว้นเท่ากันทุกกล่อง
                height: (PdfPageFormat.a4.height - 60) / 3,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(),
                ),
                child: pw.Column(
                  children: [
                    Header(2),
                    pw.Expanded(child: Body_data(2)),
                  ],
                )),
            pw.Container(
                // margin: pw.EdgeInsets.only(top: 2), // ⭐ เว้นเท่ากันทุกกล่อง
                height: (PdfPageFormat.a4.height - 60) / 3,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(),
                ),
                child: pw.Column(
                  children: [
                    Header(3),
                    pw.Expanded(child: Body_data(3)),
                  ],
                )),
          ];
        },
      ),
    );
    // pdf.addPage(
    //   pw.MultiPage(
    //     pageFormat: PdfPageFormat.a4.copyWith(
    //       marginBottom: 15.0,
    //       marginLeft: 30.0,
    //       marginRight: 30.0,
    //       marginTop: 15.0,
    //     ),
    //     build: (context) {
    //       return [
    //         pw.Container(
    //           height: (PdfPageFormat.a4.height - 30) / 3, // 841.889 - (15+15)
    //           decoration: const pw.BoxDecoration(
    //             border: pw.Border(),
    //           ),
    //           child: pw.Column(
    //             children: [
    //               Header(1),
    //               pw.Expanded(child: Body_data(1)),
    //             ],
    //           ),
    //         ),
    //         pw.Container(
    //           height: (PdfPageFormat.a4.height - 30) / 3,
    //           decoration: const pw.BoxDecoration(
    //             border: pw.Border(),
    //           ),
    //           child: pw.Column(
    //             children: [
    //               Header(2),
    //               pw.Expanded(child: Body_data(2)),
    //             ],
    //           ),
    //         ),
    //         pw.Container(
    //           height: (PdfPageFormat.a4.height - 30) / 3,
    //           decoration: const pw.BoxDecoration(
    //             border: pw.Border(),
    //           ),
    //           child: pw.Column(
    //             children: [
    //               Header(3),
    //               pw.Expanded(child: Body_data(3)),
    //             ],
    //           ),
    //         ),
    //       ];
    //     },
    //   ),
    // );

    print(PdfPageFormat.a4.height);

    // if (TransReBillHistory.length >= 7) {
    //   pdf.addPage(
    //     pw.MultiPage(
    //         pageFormat: PdfPageFormat.a4.copyWith(
    //           marginBottom: 4.00,
    //           marginLeft: 8.00,
    //           marginRight: 8.00,
    //           marginTop: 8.00,
    //         ),
    //         header: (context) {
    //           return Header(1);
    //         },
    //         build: (context) {
    //           return [Body_data(1)];
    //         },
    //         footer: (TransReBillHistory.length < 7)
    //             ? null
    //             : (context) {
    //                 return footer_data(1);
    //               }),
    //   );
    //   pdf.addPage(
    //     pw.MultiPage(
    //         pageFormat: PdfPageFormat.a4.copyWith(
    //           marginBottom: 4.00,
    //           marginLeft: 8.00,
    //           marginRight: 8.00,
    //           marginTop: 8.00,
    //         ),
    //         header: (context) {
    //           return Header(2);
    //         },
    //         build: (context) {
    //           return [Body_data(2)];
    //         },
    //         footer: (TransReBillHistory.length < 7)
    //             ? null
    //             : (context) {
    //                 return footer_data(2);
    //               }),
    //   );
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
      final List<int> bytes = await pdf.save();
      final Uint8List data = Uint8List.fromList(bytes);
      MimeType type = MimeType.PDF;
      final dir = await FileSaver.instance.saveFile(
          (numdoctax.toString() == '')
              ? 'ใบเสร็จรับเงิน $numinvoice'
              : 'ใบเสร็จรับเงิน $numdoctax',
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
                        : 'ใบเสร็จรับเงิน $numdoctax'
                    : (numdoctax.toString() == '')
                        ? 'ใบเสร็จรับเงิน [ $TitleType_Default_Receipt_Name ]$numinvoice'
                        : 'ใบเสร็จรับเงิน [ $TitleType_Default_Receipt_Name ]$numdoctax'),
          ));
    }
  }
}
