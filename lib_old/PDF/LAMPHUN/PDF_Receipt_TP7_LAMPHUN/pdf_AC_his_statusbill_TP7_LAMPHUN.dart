import 'package:file_saver/file_saver.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;

import 'package:flutter/material.dart'
    show BuildContext, MaterialPageRoute, Navigator;
import '../../../Constant/Myconstant.dart';

import '../../../Man_PDF/Man_Pay_Receipt_PDF.dart';
import '../../../Man_PDF/Man_Temporary_Receipt_PDF.dart';
import '../../../Man_PDF/Preview_PDF/PreviewPdfgen_Billsplay.dart';

import '../../../Model/trans_re_bill_history_model.dart';
import '../../../PeopleChao/Pays_.dart';
import '../../../Style/File_s.dart';
import '../../../Style/ThaiBaht.dart';
import '../../../Style/colors.dart';
import '../../../Style/loadAndCacheImage.dart';

class Pdfgen_his_statusbill_TP7_LAMPHUN {
//////////---------------------------------------------------->(ใบเสร็จรับเงิน/ใบกำกับภาษี)   ใช้  //

  static void exportPDF_statusbill_TP7_LAMPHun(
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
    // ------------------------------------------------------->
    // แสดง Dialog เลือกขนาดกระดาษก่อน Export
    final String? _selectedMode =
        await ManPay_Receipt_PDF.showPageFormatDialog(context as BuildContext);
    if (_selectedMode == null) return; // ผู้ใช้กด Cancel → หยุดทันที
    // ------------------------------------------------------->
    final pdf = pw.Document();
    final font = await rootBundle.load("${fonts_pdf}");
    var Colors_pd = PdfColors.black;
    // final font = await rootBundle.load("fonts/Sarabun-Medium.ttf");
    const PdfColor PDF_Border_Color = PDFConstants.borderColor;
    int pageCount = 1; // Initialize the page count
    final ttf = pw.Font.ttf(font);

    // ─────────────────────────────────────────────────────
    // โหมดกระดาษจาก Dialog
    // 'pos80' | 'pos58' | 'a3' | 'a4' | 'a5'
    final String pageMode = _selectedMode;
    final bool isPos = pageMode == 'pos80' || pageMode == 'pos58';

    // ── Responsive layout variables ─────────────────────
    // font_Size  : ขนาดตัวอักษรหลัก
    // logoSize   : ขนาด logo สี่เหลี่ยม
    // infoGapMm  : ช่องว่างระหว่าง logo กับ info text
    // ────────────────────────────────────────────────────
    // ── Responsive layout variables ─────────────────────
    final double font_Size = () {
      switch (pageMode) {
        case 'pos58':
          return 5.5;
        case 'pos80':
          return 7.5;
        case 'a3':
          return 11.0;
        case 'a5':
          return 7.0;
        case 'a4':
        default:
          return 10.0;
      }
    }();

    final int _logoPx = () {
      switch (pageMode) {
        case 'a3':
          return 300;
        case 'pos58':
          return 96;
        case 'pos80':
          return 120;
        case 'a5':
          return 150;
        case 'a4':
        default:
          return 180;
      }
    }();
    // ─────────────────────────────────────────────────────

    DateTime date = DateTime.now();
    final thaiDate = DateTime.parse(date_Transaction);
    final formatter = DateFormat('d MMMM', 'th_TH');
    final formattedDate = formatter.format(thaiDate);
    DateTime dateTime = DateTime.parse(date_Transaction);
    int newYear = dateTime.year + 543;

    final thaiDate2 = DateTime.parse(dayfinpay);
    final formatter2 = DateFormat('d MMMM', 'th_TH');
    final formattedDate2 = formatter2.format(thaiDate2);

    var nFormat = NumberFormat("#,##0.00", "en_US");
    var nFormat2 = NumberFormat("###0.00", "en_US");
    Uint8List? resizedLogo = await getResizedLogoForSize(targetPx: _logoPx);

    // ── buildFormat logic ───────────────────────────────────────
    PdfPageFormat buildFormat() {
      const double mLeft = 8;
      const double mRight = 8;
      const double mTop = 8;
      const double mBottom = 4;

      switch (pageMode) {
        case 'pos80':
          return PdfPageFormat(80.0 * PdfPageFormat.mm, double.infinity)
              .copyWith(
            marginLeft: mLeft,
            marginRight: mRight,
            marginTop: mTop,
            marginBottom: mBottom,
          );
        case 'pos58':
          return PdfPageFormat(58.0 * PdfPageFormat.mm, double.infinity)
              .copyWith(
            marginLeft: mLeft,
            marginRight: mRight,
            marginTop: mTop,
            marginBottom: mBottom,
          );
        case 'a3':
          return PdfPageFormat.a3.copyWith(
            marginLeft: mLeft,
            marginRight: mRight,
            marginTop: mTop,
            marginBottom: mBottom,
          );
        case 'a5':
          return PdfPageFormat(14.8 * PdfPageFormat.cm, 21.0 * PdfPageFormat.cm)
              .copyWith(
            marginLeft: mLeft,
            marginRight: mRight,
            marginTop: mTop,
            marginBottom: mBottom,
          );
        case 'a4':
        default:
          return PdfPageFormat.a4.copyWith(
            marginLeft: mLeft,
            marginRight: mRight,
            marginTop: mTop,
            marginBottom: mBottom,
          );
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

    // ── Table header columns ──────────────────────────────────────────
    final headerColumns = [
      {
        'label': 'ลำดับ',
        'flex': 0,
        'align': pw.Alignment.center,
        'width': isPos ? 18.0 : 30.0
      },
      {
        'label': 'รายการชำระ (Description)',
        'flex': 6,
        'align': pw.Alignment.centerLeft
      },
      if (!isPos) ...[
        {'label': 'ก่อนVAT', 'flex': 2, 'align': pw.Alignment.centerRight},
        {'label': 'VAT', 'flex': 1, 'align': pw.Alignment.centerRight},
        {'label': 'WHT', 'flex': 1, 'align': pw.Alignment.centerRight},
      ],
      {
        'label': 'ยอดสุทธิ (Total)',
        'flex': 2,
        'align': pw.Alignment.centerRight
      },
    ];
///////------------------------------->
    double roundMoney(double value) {
      return (value * 100).round() / 100;
    }

    double getTotalByField(String fieldName) {
      return _TransReBillHistoryModels.fold(0.0, (sum, item) {
        double value = 0.0;
        switch (fieldName) {
          case 'amt':
            value = double.tryParse(item.amt.toString()) ?? 0.0;
            break;
          case 'pvat':
            value = double.tryParse(item.pvat.toString()) ?? 0.0;
            break;
          case 'vat':
            value = double.tryParse(item.vat.toString()) ?? 0.0;
            break;
          case 'wht':
            value = double.tryParse(item.wht.toString()) ?? 0.0;
            break;
          case 'total':
            value = double.tryParse(item.total.toString()) ?? 0.0;
            break;
          case 'dis_list':
            value = double.tryParse(item.dis_list.toString()) ?? 0.0;
            break;
          default:
            value = 0.0;
        }
        return sum + value;
      });
    }

    double totalsum = getTotalByField('total');
    double totalPvat = getTotalByField('pvat');
    double totalVat = getTotalByField('vat');
    double totalWht = getTotalByField('wht');
    double totalDis = roundMoney(
        double.tryParse(sum_disamt.toString() ?? '0.00') ??
            0.00); // 'disamt' corresponds to the discount field
    double totalFee =
        roundMoney(double.tryParse(sum_fee.toString() ?? '0.00') ?? 0.00);
    double totalBill =
        (totalPvat + totalVat + totalFee) - (totalWht + totalDis);

    final totalMatjum = roundMoney(
        double.tryParse(dis_sum_Matjum.toString() ?? '0.00') ?? 0.00);
    final totalPakan =
        roundMoney(double.tryParse(dis_sum_Pakan.toString() ?? '0.00') ?? 0.00);

    //--------> รวมค่าเช่าที่ไม่ใช่ KD ทั้งหมด
    final hasNotKd = TransReBillHistory.any(
      (e) => e.exp_dtype.toString() != 'KD',
    );

    final totalqty = "1";

    final totalpri = TransReBillHistory.fold<double>(0, (sum, e) {
      if (e.exp_dtype.toString() != 'KD') {
        if (e.ele_ty.toString() != '0' && e.ele_ty != null) {
          // ele_ty พิเศษ → ไม่บวก
          return sum;
        } else {
          return sum + (double.tryParse(e.pri.toString()) ?? 0);
        }
      }
      return sum; // ถ้าเป็น KD → ไม่รวม
    });

    final totalamt = TransReBillHistory.fold<double>(0, (sum, e) {
      if (e.exp_dtype.toString() != 'KD') {
        if (double.tryParse(e.pvat_original.toString()) != 0) {
          return sum + (double.tryParse(e.pvat_original.toString()) ?? 0);
        } else {
          return sum + (double.tryParse(e.amt.toString()) ?? 0);
        }
      }
      return sum;
    });

    final totalsum_TransReBillHistory =
        TransReBillHistory.fold<double>(0, (sum, e) {
      if (e.exp_dtype.toString() != 'KD') {
        return sum + (double.tryParse(e.total.toString()) ?? 0);
      }
      return sum;
    });

    final kdFirst = TransReBillHistory.firstWhere(
      (e) => e.exp_dtype.toString() != 'KD' && e.date != null,
      orElse: () => TransReBillHistory.first, // ถ้าไม่เจอ KU เลย
    );

    final totallist = (kdFirst != null)
        ? '${DateFormat('MMM', 'th').format(DateTime.parse(kdFirst.duedate!))} ${DateTime.parse(kdFirst.duedate!).year + 543}'
        : '-';

    ///////------------------------------->

    ///////------------------------------->

    // ── Table helper functions ──────────────────────────────────────────
    pw.Widget _cell(
      String text, {
      double? w,
      int flex = 0,
      pw.Alignment align = pw.Alignment.centerLeft,
      int maxLines = 2,
      bool borderBottom = true,
      pw.FontWeight weight = pw.FontWeight.normal,
    }) {
      final child = pw.Container(
        padding: const pw.EdgeInsets.all(2),
        decoration: borderBottom
            ? const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(width: 0.3, color: PdfColors.grey300),
                ),
              )
            : null,
        child: pw.Align(
          alignment: align,
          child: pw.Text(
            text,
            maxLines: maxLines,
            textAlign: align == pw.Alignment.centerRight
                ? pw.TextAlign.right
                : (align == pw.Alignment.center
                    ? pw.TextAlign.center
                    : pw.TextAlign.left),
            style: pw.TextStyle(
              fontSize: font_Size,
              font: ttf,
              fontWeight: weight,
              color: PdfColors.grey800,
            ),
          ),
        ),
      );

      if (w != null) return pw.SizedBox(width: w, child: child);
      if (flex > 0) return pw.Expanded(flex: flex, child: child);
      return child;
    }

    // helper: format nullable number
    String _fmt(dynamic v) {
      if (v == null) return '0.00';
      double val = 0.0;
      if (v is String)
        val = double.tryParse(v) ?? 0.0;
      else if (v is num) val = v.toDouble();
      return nFormat.format(val);
    }

    // helper: row summary
    pw.Widget _sumRow(String label, String value, {bool isBold = true}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 0.5),
        child: pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(label,
                  style: pw.TextStyle(
                      fontSize: font_Size,
                      font: ttf,
                      fontWeight:
                          isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
                      color: PdfColors.grey800)),
            ),
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: font_Size,
                    font: ttf,
                    fontWeight:
                        isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
                    color: PdfColors.grey800)),
          ],
        ),
      );
    }

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
          // decoration: const pw.BoxDecoration(
          //   color: PdfColors.white,
          //   border: pw.Border(
          //     left: pw.BorderSide(color: PdfColors.grey600),
          //     right: pw.BorderSide(color: PdfColors.grey600),
          //   ),
          // ),
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

    pw.Widget Header(int serpang) {
      return pw.Column(children: [
        pw.Row(
          // mainAxisSize: pw.MainAxisSize.min,
          // crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              height: 30,
              width: 40,
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: resizedLogo != null
                  ? pw.Image(
                      pw.MemoryImage(resizedLogo),
                      height: 30,
                      width: 40,
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
            pw.Spacer(),
            (hasNonCashTransaction1)
                ? pw.Text(
                    (numdoctax.toString() == '')
                        ? 'บิลเงินสด(Cash Sell)'
                        : 'บิลเงินสด/ใบกำกับภาษี(Cash Sell/Tax invoice)',
                    textAlign: pw.TextAlign.right,
                    maxLines: 1,
                    style: pw.TextStyle(
                      fontSize: font_Size + 1,
                      fontWeight: pw.FontWeight.bold,
                      font: ttf,
                      color: Colors_pd,
                    ),
                  )
                : pw.Text(
                    (numdoctax.toString() == '')
                        ? 'ใบเสร็จรับเงิน(Receipt)'
                        : 'ใบเสร็จรับเงิน/ใบกำกับภาษี(Receipt/Tax invoice)',
                    textAlign: pw.TextAlign.right,
                    maxLines: 1,
                    style: pw.TextStyle(
                      fontSize: font_Size + 1,
                      fontWeight: pw.FontWeight.bold,
                      font: ttf,
                      color: Colors_pd,
                    ),
                  ),
          ],
        ),
        pw.Row(
          children: [
            pw.Container(
              width: 200,
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                mainAxisSize: pw.MainAxisSize.min,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // (netImage.isEmpty)
                  //     ? pw.Container(
                  //         height: 30,
                  //         width: 40,
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
                  //     : pw.Container(
                  //         height: 30,
                  //         width: 40,
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
                  //           height: 30,
                  //           width: 40,
                  //         ),
                  //       ),
                  pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  pw.Text(
                    '${bill_name.toString().trim()}',
                    maxLines: 1,
                    textAlign: pw.TextAlign.left,
                    style: pw.TextStyle(
                      fontSize: font_Size,
                      color: Colors_pd,
                      fontWeight: pw.FontWeight.bold,
                      font: ttf,
                    ),
                  ),
                  pw.Text(
                    'ที่อยู่ : $bill_addr',
                    maxLines: 1,
                    textAlign: pw.TextAlign.left,
                    style: pw.TextStyle(
                      fontSize: font_Size,
                      color: Colors_pd,
                      font: ttf,
                    ),
                  ),
                  pw.Text(
                    (bill_tax.toString() == '' ||
                            bill_tax == null ||
                            bill_tax.toString() == 'null')
                        ? 'เลขประจำตัวผู้เสียภาษี : 0'
                        : 'เลขประจำตัวผู้เสียภาษี : $bill_tax',
                    textAlign: pw.TextAlign.right,
                    maxLines: 1,
                    style: pw.TextStyle(
                      fontSize: font_Size,
                      font: ttf,
                      color: Colors_pd,
                    ),
                  ),
                  pw.Text(
                    'โทร : $bill_tel',
                    textAlign: pw.TextAlign.right,
                    maxLines: 1,
                    style: pw.TextStyle(
                      fontSize: font_Size,
                      font: ttf,
                      color: Colors_pd,
                    ),
                  ),
                  // pw.Text(
                  //   'ลูกค้า(Customer)',
                  //   textAlign: pw.TextAlign.right,
                  //   maxLines: 1,
                  //   style: pw.TextStyle(
                  //     fontSize: font_Size,
                  //     fontWeight: pw.FontWeight.bold,
                  //     font: ttf,
                  //     color: Colors_pd,
                  //   ),
                  // ),
                  pw.Text(
                    (cname != null &&
                            cname.toString().trim().isNotEmpty &&
                            cname.toString() != 'null' &&
                            cname.toString() != '-')
                        ? 'ลูกค้า(Customer) : $cname'
                        : (sname != null &&
                                sname.toString().trim().isNotEmpty &&
                                sname.toString() != 'null' &&
                                sname.toString() != '-')
                            ? 'ลูกค้า(Customer) : $sname'
                            : 'ลูกค้า(Customer) : -',
                    // 'ลูกค้า(Customer) : ${(sname.toString() == '' || sname == null || sname.toString() == 'null') ? '-' : sname} (${(cname.toString() == '' || cname == null || cname.toString() == 'null') ? '-' : cname})',
                    // (sname.toString() == null ||
                    //         sname.toString() == '' ||
                    //         sname.toString() == 'null')
                    //     ? ' -'
                    //     : '$sname',
                    // textAlign: pw.TextAlign.right,
                    maxLines: 1,
                    textAlign: pw.TextAlign.justify,
                    style: pw.TextStyle(
                      fontSize: font_Size,
                      font: ttf,
                      color: Colors_pd,
                    ),
                  ),
                  pw.Text(
                    (addr.toString() == null ||
                            addr.toString() == '' ||
                            addr.toString() == 'null')
                        ? 'ที่อยู่ : -'
                        : 'ที่อยู่ : $addr',
                    textAlign: pw.TextAlign.justify,
                    maxLines: 1,
                    style: pw.TextStyle(
                      fontSize: font_Size,
                      font: ttf,
                      color: Colors_pd,
                    ),
                  ),
                  pw.Text(
                    (tax == null ||
                            tax.toString() == '' ||
                            tax.toString() == 'null')
                        ? 'เลขประจำตัวผู้เสียภาษี : 0'
                        : 'เลขประจำตัวผู้เสียภาษี : $tax',
                    textAlign: pw.TextAlign.justify,
                    maxLines: 1,
                    style: pw.TextStyle(
                      fontSize: font_Size,
                      font: ttf,
                      color: Colors_pd,
                    ),
                  ),
                  pw.Row(
                    children: [
                      pw.Text(
                        'รูปแบบชำระ : ',
                        textAlign: pw.TextAlign.justify,
                        maxLines: 1,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.Expanded(
                          flex: 4,
                          child: pw.Row(
                            children: [
                              for (var i = 0;
                                  i < finnancetransModels.length;
                                  i++)
                                if (finnancetransModels[i].dtype.toString() !=
                                    'FTA')
                                  (finnancetransModels[i].dtype.toString() ==
                                          'KP')
                                      ? pw.Padding(
                                          padding: pw.EdgeInsets.fromLTRB(
                                              2, 0, 2, 0),
                                          child: pw.Text(
                                            (finnancetransModels[i]
                                                        .type
                                                        .toString() ==
                                                    'CASH')
                                                ? '${i + 1}.เงินสด : ${nFormat.format(double.parse(finnancetransModels[i].amt!.toString()))} บาท'
                                                : '${i + 1}.เงินโอน : ${nFormat.format(double.parse(finnancetransModels[i].amt!.toString()))} บาท',
                                            textAlign: pw.TextAlign.justify,
                                            style: pw.TextStyle(
                                              fontSize: font_Size,
                                              font: ttf,
                                              fontWeight: pw.FontWeight.bold,
                                              color: Colors_pd,
                                            ),
                                          ))
                                      : pw.Padding(
                                          padding: pw.EdgeInsets.fromLTRB(
                                              2, 0, 2, 0),
                                          child: pw.Text(
                                            '${i + 1}.${finnancetransModels[i].remark} : ${nFormat.format(double.parse(finnancetransModels[i].amt!.toString()))} บาท',
                                            textAlign: pw.TextAlign.justify,
                                            style: pw.TextStyle(
                                              fontSize: font_Size,
                                              font: ttf,
                                              fontWeight: pw.FontWeight.bold,
                                              color: Colors_pd,
                                            ),
                                          ),
                                        ),
                            ],
                          )),
                    ],
                  ),
                ],
              ),
            ),
            pw.Spacer(),
            pw.Container(
              width: 180,
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                mainAxisSize: pw.MainAxisSize.min,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  // pw.Text(
                  //   (numdoctax.toString() == '')
                  //       ? 'ใบเสร็จรับเงิน(Receipt)'
                  //       : 'ใบเสร็จรับเงิน/ใบกำกับภาษี(Receipt/Tax invoice)',
                  //   textAlign: pw.TextAlign.right,
                  //   maxLines: 1,
                  //   style: pw.TextStyle(
                  //     fontSize: font_Size,
                  //     fontWeight: pw.FontWeight.bold,
                  //     font: ttf,
                  //     color: Colors_pd,
                  //   ),
                  // ),
                  pw.Text(
                    (serpang == 0)
                        ? ''
                        : (serpang == 1)
                            ? 'ต้นฉบับ (Original)'
                            : (serpang == 2)
                                ? 'คู่ฉบับ (Duplicate)'
                                : (serpang == 3)
                                    ? 'สำเนา (Copy)'
                                    : (serpang == 4)
                                        ? 'สำเนาคู่ฉบับ (Duplicate Copy)'
                                        : '',
                    textAlign: pw.TextAlign.right,
                    maxLines: 1,
                    style: pw.TextStyle(
                      fontSize: font_Size,
                      font: ttf,
                      color: Colors_pd,
                    ),
                  ),
                  pw.Text(
                    (numdoctax.toString() == '')
                        ? 'เลขที่(ID) : $numinvoice '
                        : 'เลขที่(ID) : $numdoctax ',
                    textAlign: pw.TextAlign.right,
                    maxLines: 1,
                    style: pw.TextStyle(
                      fontSize: font_Size,
                      font: ttf,
                      color: Colors_pd,
                    ),
                  ),
                  pw.Text(
                    'วันที่ทำรายการ : $formattedDate ${newYear}',
                    textAlign: pw.TextAlign.right,
                    maxLines: 1,
                    style: pw.TextStyle(
                      fontSize: font_Size,
                      fontWeight: pw.FontWeight.bold,
                      font: ttf,
                      color: Colors_pd,
                    ),
                  ),
                  pw.Text(
                    'โซน(Zone) : $Zone_s / ห้อง( Room) : $Ln_s',
                    textAlign: pw.TextAlign.right,
                    maxLines: 1,
                    style: pw.TextStyle(
                      fontSize: font_Size,
                      fontWeight: pw.FontWeight.bold,
                      font: ttf,
                      color: Colors_pd,
                    ),
                  ),
                  pw.Text(
                    (dayfinpay.toString() == '' ||
                            dayfinpay.toString() == 'null' ||
                            dayfinpay == null)
                        ? 'วันที่ชำระ : -'
                        : 'วันที่ชำระ : $formattedDate2 ${DateTime.parse('${dayfinpay}').year + 543}',
                    // (dayfinpay.toString() == '' ||
                    //         dayfinpay.toString() == 'null' ||
                    //         dayfinpay == null)
                    //     ? 'วันที่ชำระ : '
                    //     : 'วันที่ชำระ : ${DateFormat('dd-MM-yyyy').format(DateTime.parse('${dayfinpay}'))} ',
                    textAlign: pw.TextAlign.justify,
                    style: pw.TextStyle(
                      fontSize: font_Size,
                      font: ttf,
                      color: Colors_pd,
                    ),
                  ),
                  // pw.Text(
                  //   'พนักงาน(Staff) : $fname ',
                  //   textAlign: pw.TextAlign.right,
                  //   maxLines: 1,
                  //   style: pw.TextStyle(
                  //     fontSize: font_Size,
                  //     fontWeight: pw.FontWeight.bold,
                  //     font: ttf,
                  //     color: Colors_pd,
                  //   ),
                  // ),
                  pw.Text(
                    'พนักงาน(Staff) : ${(finnancetransModels.any((e) => e.pay_by == "U")) ? "-" : fname}',
                    textAlign: pw.TextAlign.right,
                    maxLines: 1,
                    style: pw.TextStyle(
                      fontSize: font_Size,
                      fontWeight: pw.FontWeight.bold,
                      font: ttf,
                      color: Colors_pd,
                    ),
                  ),

                  pw.Text(
                    (ref_invoice.length == 0)
                        ? ''
                        : 'อ้างอิงเลขที่ :  ${ref_invoice.toSet().map((model) => model).join(', ')}',
                    textAlign: pw.TextAlign.right,
                    maxLines: 3,
                    style: pw.TextStyle(
                      fontSize: font_Size,
                      fontWeight: pw.FontWeight.bold,
                      font: ttf,
                      color: Colors_pd,
                    ),
                  ),

                  (type_bills.toString().trim() == '' || type_bills == null)
                      ? pw.Text('')
                      : pw.Container(
                          padding: pw.EdgeInsets.fromLTRB(1, 0.3, 1, 0.3),
                          decoration: const pw.BoxDecoration(
                            // color: PdfColors.green100,
                            border: pw.Border(
                              right: pw.BorderSide(color: PdfColors.grey300),
                              left: pw.BorderSide(color: PdfColors.grey300),
                              top: pw.BorderSide(color: PdfColors.grey300),
                              bottom: pw.BorderSide(color: PdfColors.grey300),
                            ),
                          ),
                          child: pw.Text(
                            'ประเภท : ล็อคเสียบ',
                            textAlign: pw.TextAlign.justify,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ),
                  pw.SizedBox(height: 2 * PdfPageFormat.mm),
                ],
              ),
            ),
          ],
        ),
        // pw.SizedBox(height: 1 * PdfPageFormat.mm),
        // pw.Divider(),
        // pw.SizedBox(height: 1 * PdfPageFormat.mm),
      ]);
    }

    // ── Footer helper functions ──────────────────────────────────────────
    pw.Widget _ft(String text,
        {PdfColor color = PdfColors.grey800, bool isBold = false}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.all(0),
        child: pw.Text(
          text,
          textAlign: pw.TextAlign.left,
          maxLines: 2,
          style: pw.TextStyle(
            font: ttf,
            fontSize: font_Size,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color,
          ),
        ),
      );
    }

    pw.Widget _signCol(String title) {
      return pw.Expanded(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
                'ลงชื่อ..................................................................($title)',
                style: pw.TextStyle(
                    font: ttf, fontSize: font_Size, color: PdfColors.grey800)),
            pw.Text(
                '(........................................................)',
                style: pw.TextStyle(
                    font: ttf, fontSize: font_Size, color: PdfColors.grey800)),
            pw.Text(
                'วันที่/Date........................................................',
                style: pw.TextStyle(
                    font: ttf, fontSize: font_Size, color: PdfColors.grey800)),
          ],
        ),
      );
    }

    pw.Widget buildFooterContent() {
      final kpTransfer = finnancetransModels
          .where((m) => m.dtype == 'KP' && m.ptser != null && m.ptser != '1');
      final bankInfo = kpTransfer.map((m) => m.bank).join(', ');
      final bnoInfo = kpTransfer.map((m) => m.bno).join(', ');
      final ptNameInfo = kpTransfer
          .map((m) => (m.ptname.toString() == 'Online Payment'
              ? 'PromptPay QR'
              : m.ptname == 'เงินโอน'
                  ? 'เลขบัญชี'
                  : m.ptname == 'Beam Checkout'
                      ? 'Beam Checkout'
                      : 'Online Standard QR'))
          .join(', ');

      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _ft('หมายเหตุ(Note) : $com_ment'),
          pw.SizedBox(height: 1 * PdfPageFormat.mm),
          _ft('1. โปรดชำระเงินภายในวันที่ 25 ถึง วันที่ 5 ของเดือนถัดไป หากเกิดการชำระเงินล่าช้า ทางโครงการจะขอเก็บค่าปรับเป็นดอกเบี้ย ร้อยละ 15 ต่อปี ของยอดนั้นๆ'),
          if (hasNonCashTransaction)
            _ft('2. การชำระเงิน ท่านสามารถโอนเข้าบัญชี $bankInfo เลขที่บัญชี $bnoInfo [ $ptNameInfo ]'),
          _ft('${hasNonCashTransaction ? "3." : "2."} ขอความกรุณาโอนชำระค่าเช่าให้ตรงกับยอดในใบแจ้งหนี้ เพื่อความถูกต้องในทางบัญชี',
              color: PdfColors.red400),
          pw.SizedBox(height: 3 * PdfPageFormat.mm),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _signCol('ผู้จัดการ'),
              _signCol('ผู้รับเงิน'),
            ],
          ),
        ],
      );
    }

    pw.Widget Body_data(int serpang) {
      return pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(children: [
            Header(serpang),
            pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(color: PDFConstants.borderColor),
                  bottom: pw.BorderSide(color: PDFConstants.borderColor),
                ),
              ),
              child: pw.Row(
                children: headerColumns.map((col) {
                  return _cell(
                    col['label'] as String,
                    flex: col['flex'] as int,
                    align: col['align'] as pw.Alignment,
                    w: col['width'] as double?,
                    weight: pw.FontWeight.bold,
                    borderBottom: false,
                  );
                }).toList(),
              ),
            ),
            if (hasNotKd)
              pw.Row(
                children: [
                  _cell('1',
                      w: isPos ? 18.0 : 30.0, align: pw.Alignment.center),
                  _cell('ค่าเช่า ประจําเดือน $totallist', flex: 6),
                  if (!isPos) ...[
                    _cell(_fmt(totalPvat),
                        flex: 2, align: pw.Alignment.centerRight),
                    _cell(_fmt(totalVat),
                        flex: 1, align: pw.Alignment.centerRight),
                    _cell(_fmt(totalWht),
                        flex: 1, align: pw.Alignment.centerRight),
                  ],
                  _cell(_fmt(totalsum),
                      flex: 2, align: pw.Alignment.centerRight),
                ],
              ),
            pw.Column(
              children: TransReBillHistory.where(
                      (e) => e.exp_dtype.toString() == 'KD')
                  .toList()
                  .asMap()
                  .entries
                  .map((entry) {
                final index = entry.key;
                final item = entry.value;
                final rowIdx = hasNotKd ? index + 2 : index + 1;
                final _expText = (item.unitser.toString() == '6')
                    ? '${item.expname} ${DateFormat('MMM', 'th').format(DateTime.parse(item.date!))} ${DateTime.parse('${item.date}').year + 543} [ หน่วยที่ใช้ไป ${item.ovalue}-${item.nvalue} ]'
                    : '${item.expname} ${DateFormat('MMM', 'th').format(DateTime.parse(item.date!))} ${DateTime.parse('${item.date}').year + 543}';
                return pw.Row(
                  children: [
                    _cell('$rowIdx',
                        w: isPos ? 18.0 : 30.0, align: pw.Alignment.center),
                    _cell(_expText, flex: 6),
                    if (!isPos) ...[
                      _cell(_fmt(item.pvat),
                          flex: 2, align: pw.Alignment.centerRight),
                      _cell(_fmt(item.vat),
                          flex: 1, align: pw.Alignment.centerRight),
                      _cell(_fmt(item.wht),
                          flex: 1, align: pw.Alignment.centerRight),
                    ],
                    _cell(_fmt(item.total),
                        flex: 2, align: pw.Alignment.centerRight),
                  ],
                );
              }).toList(),
            ),
            pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                    top: pw.BorderSide(color: PDFConstants.borderColor)),
              ),
              padding: const pw.EdgeInsets.fromLTRB(0, 1.5, 0, 0),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text('(~${convertToThaiBaht(totalBill)}~)',
                        style: pw.TextStyle(
                            fontSize: font_Size,
                            font: ttf,
                            fontStyle: pw.FontStyle.italic,
                            color: PdfColors.grey800)),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Container(
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                            bottom: pw.BorderSide(color: PdfColors.grey600)),
                      ),
                      child: pw.Column(
                        children: [
                          _sumRow('รวมราคาสินค้า/Sub Total', _fmt(totalBill)),
                          _sumRow('ภาษีมูลค่าเพิ่ม/Vat', '0.00'),
                          _sumRow(
                              'รวมเป็นเงิน',
                              _fmt(roundMoney(
                                  ((totalPvat + totalVat) - totalWht) +
                                      totalFee))),
                          _sumRow('ภาษีหัก ณ ที่จ่าย', _fmt(totalWht)),
                          _sumRow('ส่วนลด/Discount', _fmt(totalDis)),
                          if (dis_sum_Matjum != 0)
                            _sumRow(
                                'เงินมัดจำ(ตัดมัดจำ)', _fmt(dis_sum_Matjum)),
                          if (dis_sum_Pakan != 0)
                            _sumRow('เงินประกัน(ตัดเงินประกัน)',
                                _fmt(dis_sum_Pakan)),
                          pw.Container(
                            decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                    top: pw.BorderSide(
                                        color: PdfColors.grey600))),
                            child: _sumRow('ยอดชำระ', _fmt(totalBill)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
          buildFooterContent(),
        ],
      );
    }

    // ── Document Generation ──────────────────────────────────────────
    pdf.addPage(
      pw.MultiPage(
        pageFormat: buildFormat(),
        footer: (context) {
          if (isPos) return pw.SizedBox.shrink();
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('พิมพ์เมื่อ : $date ($pageMode)',
                  style:
                      pw.TextStyle(fontSize: 7.0, font: ttf, color: Colors_pd)),
              pw.Text('หน้าที่ ${context.pageNumber} / ${context.pagesCount}',
                  style:
                      pw.TextStyle(fontSize: 7.0, font: ttf, color: Colors_pd)),
            ],
          );
        },
        build: (context) {
          if (isPos) return [Body_data(1)];
          if ((pageMode == 'a3' || pageMode == 'a4' || pageMode == 'a5') &&
              TransReBillHistory.length < 6) {
            return [
              pw.Container(
                  height: (buildFormat().height - 20) / 2, child: Body_data(1)),
              pw.Divider(
                  color: PdfColors.grey400, borderStyle: pw.BorderStyle.dashed),
              pw.Container(
                  height: (buildFormat().height - 20) / 2, child: Body_data(2)),
            ];
          }
          return [Body_data(1)];
        },
      ),
    );

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
