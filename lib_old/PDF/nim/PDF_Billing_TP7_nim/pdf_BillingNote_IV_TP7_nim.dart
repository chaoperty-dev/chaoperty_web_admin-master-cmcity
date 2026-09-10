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

import '../../../CRC_16_Prompay/generate_qrcode.dart';
import '../../../ChaoArea/ChaoAreaRenew_Screen.dart';
import '../../../Constant/Myconstant.dart';
import '../../../Man_PDF/Preview_PDF/PreviewPdfgen_Bills_INV.dart';
import '../../../Model/GetInvoice_history_Model.dart';
import '../../../PeopleChao/Bills_.dart';
import '../../../Style/File_s.dart';
import '../../../Style/ThaiBaht.dart';
import '../../../Style/colors.dart';
import '../../../Style/loadAndCacheImage.dart';

class Pdfgen_BillingNoteInvlice_TP7_nim {
  //////////---------------------------------------------------->(ใบวางบิล แจ้งหนี้ nim)
  static void exportPDF_BillingNoteInvlice_TP7_nim(
      List<InvoiceHistoryModel> _InvoiceHistoryModels,
      foder,
      Cust_no,
      cid_,
      Zone_s,
      Ln_s,
      fname,

      ///(ser_BillingNote 1 = วางบิล  /// 2 = ประวัติวางบิล )
      // ser_BillingNote,
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
      payment_Ptser1,
      bank1,
      img1,
      btype1,
      ptser1,
      ptname1,
      Preview_ser,
      End_Bill_Paydate,
      fonts_pdf,
      Con_remark,
      customer_name) async {
    ///---------------------> พ.ศ. สำหรับ QR Code (Thai Year for QR)
    int YearQRthai = int.parse(
          DateFormat('yyyy').format(DateTime.parse(End_Bill_Paydate)),
        ) +
        543;

    ///---------------------> เริ่มต้นเอกสาร PDF (Create PDF document)
    final pdf = pw.Document();

    ///---------------------> โหลดฟอนต์ (Load custom font)
    final font = await rootBundle.load("${fonts_pdf}");
    final ttf = pw.Font.ttf(font);

    ///---------------------> ตั้งค่าทั่วไป (Style & Formatter)
    var Colors_pd = PdfColors.black;
    var nFormat = NumberFormat("#,##0.00", "en_US");

    double font_Size = 11.0;

    ///---------------------> วันที่ปัจจุบัน (Current Date for Billing)
    DateTime date = DateTime.now();
    var formatter = DateFormat.MMMMd('th_TH');

    ///---------------------> วันที่ธุรกรรม (Transaction Date)
    final thaiDate2 = DateTime.parse(date_Transaction);
    final formattedDate2 = formatter.format(thaiDate2);

    ///---------------------> พ.ศ. จากวันที่ธุรกรรม (Thai Year from Transaction Date)
    DateTime dateTime2 = DateTime.parse(date_Transaction);
    int newYear2 = dateTime2.year + 543;

    ///---------------------> โหลดภาพ QR (Load QR Image List)
    List netImage_QR = [];

    ///---------------------> โหลดโลโก้และปรับขนาด (Resize Logo)
    Uint8List? resizedLogo = await getResizedLogo();

    ///---------------------> Load QR image (โหลดรูป QR หรือรูปแทน)
    if (img1 == null || img1.toString().isEmpty) {
      netImage_QR.add(
        await networkImage(
          '${MyConstant().domain}/Awaitdownload/imagenot.png',
        ),
      );
    } else {
      netImage_QR.add(
        await networkImage(
          '${MyConstant().domain}/files/$foder/payment/$img1',
        ),
      );
    }

    ///---------------------> Table header columns (หัวคอลัมน์ของตาราง)

    final headerColumns = [
      {'label': 'รายการ', 'flex': 8, 'align': pw.Alignment.center},
      {'label': 'หน่วย', 'flex': 2, 'align': pw.Alignment.center},
      {'label': 'จำนวน', 'flex': 2, 'align': pw.Alignment.center},
      {'label': 'ราคา/หน่วย', 'flex': 2, 'align': pw.Alignment.center},
      {'label': 'จำนวนเงิน', 'flex': 2, 'align': pw.Alignment.center},
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

    const PdfColor PDF_Border_Color = PDFConstants.borderColor;
    ///////----------------->
    // ฟังก์ชันปัดเศษทศนิยม 2 ตำแหน่ง
    double roundMoney(double value) {
      return (value * 100).round() / 100;
    }

    final totalAmt =
        roundMoney(getTotalByField(_InvoiceHistoryModels, (item) => item.amt));
    final totalPvat =
        roundMoney(getTotalByField(_InvoiceHistoryModels, (item) => item.pvat));
    final totalVat =
        roundMoney(getTotalByField(_InvoiceHistoryModels, (item) => item.vat));
    final totalWht =
        roundMoney(getTotalByField(_InvoiceHistoryModels, (item) => item.wht));
    final totalDis = _InvoiceHistoryModels.isNotEmpty
        ? roundMoney(
            double.tryParse(_InvoiceHistoryModels.first.disendbill ?? '0.00') ??
                0.00)
        : 0.00;

    final totalprice = roundMoney(
        getTotalByField(_InvoiceHistoryModels, (item) => item.total));

    final totalBill = roundMoney(totalprice - totalDis);
    String totalBill_QR =
        '${nFormat.format(totalBill).replaceAll(RegExp(r'[^0-9]'), '')}';

// _InvoiceHistoryModels.
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
                    1 *
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

    ///////------------------------------->

    pw.Widget Header(int serpang) {
      return pw.Column(children: [
        if (serpang != 1) pw.SizedBox(height: 15.00),
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
                        margin: pw.EdgeInsets.only(top: 2.0),
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
                            color: PdfColors.black,
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
                      pw.SizedBox(width: 7 * PdfPageFormat.mm),
                      pw.Container(
                        margin: pw.EdgeInsets.only(top: 2.0),
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
                            color: PdfColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.Text(
                    '${' ' * 26}เลขประจําตัวผู้เสียภาษีอากร ${bill_tax.trim()}',
                    maxLines: 3,
                    style: pw.TextStyle(
                      fontSize: font_Size,
                      color: PdfColors.black,
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
                    (serpang == 1) ? '(สำหรับลูกค้า)' : '(สำเนาส่วนที่ 1)',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontSize: font_Size - 2,
                      font: ttf,
                      color: PdfColors.grey800,
                    ),
                  ),
                  pw.Text(
                    'วันที่พิมพ์ ${DateFormat('dd/MM/').format(DateTime.now())}${DateTime.now().year + 543} ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontSize: font_Size - 2,
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
                'ใบแจ้งหนี้/INVOICE',
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
                (cFinn == null ||
                        cFinn.toString().isEmpty ||
                        cFinn.toString() == 'null')
                    ? 'ใบแจ้งหนี้เลขที่ # -'
                    : 'ใบแจ้งหนี้เลขที่ # ${cFinn}',
                style: pw.TextStyle(
                    fontSize: font_Size,
                    fontWeight: pw.FontWeight.bold,
                    font: ttf,
                    color: PdfColors.black),
              ),
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'ชื่อลูกค้า : $customer_name',
                  style: pw.TextStyle(
                    fontSize: font_Size,
                    fontWeight: pw.FontWeight.bold,
                    font: ttf,
                    color: PdfColors.black,
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
                    color: PdfColors.black,
                  ),
                ),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    (addr_ == null ||
                            addr_.toString().isEmpty ||
                            addr_.toString() == 'null')
                        ? 'ที่อยู่/Address : -'
                        : 'ที่อยู่/Address : ${addr_}',
                    style: pw.TextStyle(
                      fontSize: font_Size,
                      fontWeight: pw.FontWeight.bold,
                      font: ttf,
                      color: PdfColors.black,
                    ),
                  ),
                ),
                pw.Text(
                  'ทรัพย์สิน ?????????????????????????',
                  style: pw.TextStyle(
                    fontSize: font_Size,
                    fontWeight: pw.FontWeight.bold,
                    font: ttf,
                    color: PdfColors.black,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
          ],
        )
      ]);
    }

    pw.Widget footer_data_sub(int i) {
      return pw.Expanded(
          child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // pw.SizedBox(height: 5 * PdfPageFormat.mm),
          pw.Padding(
            padding: pw.EdgeInsets.all(0),
            child: pw.Text(
              'กำหนดการชําระเงินภายในวันที่ ${formatter.format(DateTime.parse(End_Bill_Paydate))} ${DateTime.parse(End_Bill_Paydate).year + 543}',
              textAlign: pw.TextAlign.left,
              maxLines: 1,
              style: pw.TextStyle(
                  font: ttf, fontSize: font_Size, color: Colors_pd),
            ),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(0),
            child: pw.Text(
              'กรุณาโอนเข้าบัญชี ${bank1} สาขานิ่มซิตี้เดลี่ ชื่อบัญชี บริษัทนิ่มซิตี้เดลี่ จำกัด เลขที่ บัญชี ${selectedValue_bank_bno} ',
              textAlign: pw.TextAlign.left,
              maxLines: 1,
              style: pw.TextStyle(
                  font: ttf, fontSize: font_Size, color: Colors_pd),
            ),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(0),
            child: pw.Text(
              'โดยหลังจากทีท่านโอนเงินแล้ว กรุณา แฟกซ์ เปอินสลิป มาที่ 053-273800', // Fax?
              textAlign: pw.TextAlign.left,
              maxLines: 1,
              style: pw.TextStyle(
                  font: ttf, fontSize: font_Size, color: Colors_pd),
            ),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(0),
            child: pw.Text(
              'หรือ e-mail มาที่ $bill_email',
              textAlign: pw.TextAlign.left,
              maxLines: 1,
              style: pw.TextStyle(
                  font: ttf, fontSize: font_Size, color: Colors_pd),
            ),
          ),
        ],
      ));
    }

    pw.Widget footer_data(int serpang) {
      return pw.Align(
        alignment: pw.Alignment.bottomCenter,
        child: pw.Container(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(children: [
                pw.Expanded(flex: 3, child: footer_data_sub(serpang)),
                // pw.SizedBox(width: 10 * PdfPageFormat.mm),
                pw.Expanded(
                  flex: 1,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      // pw.SizedBox(height: 5 * PdfPageFormat.mm),
                      pw.Text(
                        '..................................................................',
                        textAlign: pw.TextAlign.left,
                        maxLines: 1,
                        style: pw.TextStyle(
                          // fontWeight: pw.FontWeight.bold,
                          font: ttf,
                          fontSize: font_Size,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.Text(
                        '$fname',
                        textAlign: pw.TextAlign.left,
                        maxLines: 1,
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: font_Size,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.Text(
                        'ผู้จัดทำ',
                        textAlign: pw.TextAlign.left,
                        maxLines: 1,
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: font_Size,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.Text(
                        '${DateFormat('dd/MM/').format(DateTime.now())}${DateTime.now().year + 543} ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                        textAlign: pw.TextAlign.left,
                        maxLines: 1,
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: font_Size,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
              if (serpang == 1)
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
                    children: _InvoiceHistoryModels.toList()
                        .asMap()
                        .entries
                        .map((entry) {
                      final invoices = entry.value;
                      final index = entry.key;
                      return pw.Container(
                        child: pw.Row(
                          children: [
                            // ✅ ใช้โค้ด buildCell เหมือนเดิม
                            buildCell(
                              child: cellWithBottomSpace(
                                invoices.unitser,
                                (invoices.unitser.toString() == '6')
                                    // ? '${invoices.descr} [  ${invoices.ovalue}-${invoices.nvalue} ]' // miter before/after
                                    ? '${invoices.expname} ประจำเดือน ${DateFormat('MMMM', 'th').format(DateTime.parse(invoices.date!))} ${DateTime.parse('${invoices.date}').year + 543} [ มิเตอร์ก่อน-หลัง ${invoices.ovalue}-${invoices.nvalue} ]' // miter before/after
                                    : '${invoices.expname} ประจำเดือน ${DateFormat('MMMM', 'th').format(DateTime.parse(invoices.date!))} ${DateTime.parse('${invoices.date}').year + 543}',
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
                                invoices.unitser,
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
                                invoices.unitser,
                                getFormattedText(invoices.qty),
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
                                invoices.unitser,
                                (invoices.ele_ty.toString() != '0' &&
                                        invoices.ele_ty != null)
                                    ? 'อัตราพิเศษ'
                                    : getFormattedText('${invoices.pri}'),
                                ttf,
                                font_Size,
                              ),
                              flex: 2,
                              alignment: pw.Alignment.centerRight,
                              topBorder: index == 0,
                            ),
                            // buildCell(
                            //   text: (double.tryParse(
                            //               invoices.pvat_original.toString()) !=
                            //           0)
                            //       ? getFormattedText(
                            //           '${invoices.pvat_original}')
                            //       : (invoices.dtype.toString() == 'KU')
                            //           ? getFormattedText('${invoices.amt}')
                            //           : getFormattedText('${invoices.pri}'),
                            //   flex: 2,
                            //   alignment: pw.Alignment.centerRight,
                            //   textAlign: pw.TextAlign.right,
                            //   topBorder: index == 0,
                            // ),
                            // 🔹 total
                            buildCell(
                              child: cellWithTopSpace(
                                invoices.unitser,
                                getFormattedText(
                                    '${invoices.pvat}'), //${TransReBill.total}
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

                  pw.Container(
                    height: () {
                      final c = _InvoiceHistoryModels.length;

                      // ถ้าเป็น unitser == 6 → ลดระดับความสูงลง 1 ขั้น
                      bool isUnit6 = _InvoiceHistoryModels.any(
                          (e) => e.unitser.toString() == '6');

                      if (c < 2) {
                        return isUnit6
                            ? 20.0 * PdfPageFormat.mm
                            : 30.0 * PdfPageFormat.mm;
                      }
                      if (c < 3) {
                        return isUnit6
                            ? 14.0 * PdfPageFormat.mm
                            : 24.0 * PdfPageFormat.mm;
                      }
                      if (c < 4) {
                        return isUnit6
                            ? 8.0 * PdfPageFormat.mm
                            : 18.0 * PdfPageFormat.mm;
                      }
                      if (c < 5) {
                        return isUnit6
                            ? 2.0 * PdfPageFormat.mm
                            : 12.0 * PdfPageFormat.mm;
                      }
                      if (c < 6) {
                        return isUnit6
                            ? 0.0 * PdfPageFormat.mm
                            : 6.0 * PdfPageFormat.mm;
                      }

                      return 0.0;
                    }(),
                    decoration: const pw.BoxDecoration(
                      // color: PdfColors.green100,
                      border: pw.Border(
                        // top: pw.BorderSide(color: PdfColors.grey600),
                        bottom: pw.BorderSide(color: PdfColors.black),
                      ),
                    ),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 8,
                          child: pw.Container(
                            decoration: const pw.BoxDecoration(
                              // color: PdfColors.green100,
                              border: pw.Border(
                                left: pw.BorderSide(color: PdfColors.black),
                                right: pw.BorderSide(color: PdfColors.black),
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
                                left: pw.BorderSide(color: PdfColors.black),
                                right: pw.BorderSide(color: PdfColors.black),
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
                                left: pw.BorderSide(color: PdfColors.black),
                                right: pw.BorderSide(color: PdfColors.black),
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
                                left: pw.BorderSide(color: PdfColors.black),
                                right: pw.BorderSide(color: PdfColors.black),
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
                                left: pw.BorderSide(color: PdfColors.black),
                                right: pw.BorderSide(color: PdfColors.black),
                              ),
                            ),
                            // height: 25,
                            padding: const pw.EdgeInsets.all(2.0),
                          ),
                        ),
                      ],
                    ),
                  ),

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
                                      bottom: pw.BorderSide(
                                        color: PdfColors.black,
                                      ),
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
                                                color: PdfColors.black,
                                              ),
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
            // if (tableData003.length < 11)
            footer_data(serpang)
          ],
        ),
      );
    }

    // if (tableData003.length < 11)

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
                height: PdfPageFormat.a4.height / 2.2,
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
                height: PdfPageFormat.a4.height / 2.2,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(),
                ),
                child: pw.Column(
                  children: [
                    Header(2),
                    pw.Expanded(child: Body_data(2)),
                  ],
                )),
          ];
        },
      ),
    );
    // print(PdfPageFormat.a4.height);

    // if (tableData003.length > 10) {
    //   pdf.addPage(
    //     pw.MultiPage(
    //         pageFormat: PdfPageFormat.a4.copyWith(
    //           marginBottom: 30.00,
    //           marginLeft: 30.00,
    //           marginRight: 30.00,
    //           marginTop: 30.00,
    //         ),
    //         header: (context) {
    //           return Header(1);
    //         },
    //         build: (context) {
    //           return [Body_data(1)];
    //         },
    //         footer: (tableData003.length < 10)
    //             ? null
    //             : (context) {
    //                 return footer_data(1);
    //               }),
    //   );
    // }
    // if (tableData003.length > 10) {
    //   pdf.addPage(
    //     pw.MultiPage(
    //         pageFormat: PdfPageFormat.a4.copyWith(
    //           marginBottom: 30.00,
    //           marginLeft: 30.00,
    //           marginRight: 30.00,
    //           marginTop: 30.00,
    //         ),
    //         header: (context) {
    //           return Header(2);
    //         },
    //         build: (context) {
    //           return [Body_data(2)];
    //         },
    //         footer: (tableData003.length < 10)
    //             ? null
    //             : (context) {
    //                 return footer_data(2);
    //               }),
    //   );
    // }

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
