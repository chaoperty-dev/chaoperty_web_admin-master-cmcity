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
import '../../../Style/loadAndCacheImage.dart';

class Pdfgen_BillingNoteInvlice_TP7_LAMPHUN {
  //////////---------------------------------------------------->(ใบวางบิล แจ้งหนี้)  ใช้  ++
  static void exportPDF_BillingNoteInvlice_TP7_LAMPHUN(
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

    double font_Size = 10.0;

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
      {
        'label': 'ลำดับ(#)',
        'flex': 0,
        'align': pw.Alignment.center,
        'width': 30.0
      },
      // {
      //   'label': 'กำหนดชำระ(Description)',
      //   'flex': 2,
      //   'align': pw.Alignment.centerLeft
      // },
      {
        'label': 'รายการชำระ (Description)',
        'flex': 4,
        'align': pw.Alignment.centerLeft
      },
      // {
      //   'label': 'จำนวน (Quantity)',
      //   'flex': 1,
      //   'align': pw.Alignment.centerRight
      // },
      // {'label': 'หน่วยละ (Unit)', 'flex': 1, 'align': pw.Alignment.centerRight},
      // {'label': 'VAT', 'flex': 1, 'align': pw.Alignment.centerRight},
      // {'label': 'WHT', 'flex': 1, 'align': pw.Alignment.centerRight},
      // {'label': 'ก่อนVAT', 'flex': 2, 'align': pw.Alignment.centerRight},
      {'label': 'ราคา (Price)', 'flex': 1, 'align': pw.Alignment.centerRight},
      {'label': 'ส่วนลด (Dis)', 'flex': 1, 'align': pw.Alignment.centerRight},
      {
        'label': 'ยอดสุทธิ (Total)', //(Price)
        'flex': 1,
        'align': pw.Alignment.centerRight
      },
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
        '${nFormat.format(totalBill).replaceAll(RegExp(r'[^0-9]'), '')}';

    //--------> รวมค่าเช่าที่ไม่ใช่ KD ทั้งหมด
    final hasNotKd = _InvoiceHistoryModels.any(
      (e) => e.dtype.toString() != 'KD',
    );

    final totalqty = "1";

    final totalpri = _InvoiceHistoryModels.fold<double>(0, (sum, e) {
      if (e.dtype.toString() != 'KD') {
        if (e.ele_ty.toString() != '0' && e.ele_ty != null) {
          // ele_ty พิเศษ → ไม่บวก
          return sum;
        } else {
          return sum + (double.tryParse(e.pri.toString()) ?? 0);
        }
      }
      return sum; // ถ้าเป็น KD → ไม่รวม
    });

    final totalamt = _InvoiceHistoryModels.fold<double>(0, (sum, e) {
      if (e.dtype.toString() != 'KD') {
        if (double.tryParse(e.pvat_original.toString()) != 0) {
          return sum + (double.tryParse(e.pvat_original.toString()) ?? 0);
        } else {
          return sum + (double.tryParse(e.amt.toString()) ?? 0);
        }
      }
      return sum;
    });

    final totaldis = _InvoiceHistoryModels.fold<double>(0, (sum, e) {
      if (e.dtype.toString() != 'KD') {
        return sum + (double.tryParse(e.dis_list.toString()) ?? 0);
      }
      return sum;
    });

    final totalsum = _InvoiceHistoryModels.fold<double>(0, (sum, e) {
      if (e.dtype.toString() != 'KD') {
        return sum + (double.tryParse(e.total.toString()) ?? 0);
      }
      return sum;
    });

    final kdFirst = _InvoiceHistoryModels.firstWhere(
      (e) => e.dtype.toString() != 'KD' && e.date != null,
      orElse: () => _InvoiceHistoryModels.first, // ถ้าไม่เจอ KD เลย
    );

    final totallist = (kdFirst != null)
        ? '${DateFormat('MMM', 'th').format(DateTime.parse(kdFirst.billdate!))} ${DateTime.parse(kdFirst.billdate!).year + 543}'
        : '-';

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

    ///////------------------------------->

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
            pw.Text(
              'ใบวางบิล/ใบแจ้งหนี้ (Invoice)',
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
                    'โทร : $bill_tel / อีเมล : $bill_email',
                    textAlign: pw.TextAlign.left,
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
                    'ลูกค้า(Customer) : $customer_name',
                    textAlign: pw.TextAlign.right,
                    maxLines: 1,
                    // textAlign: pw.TextAlign.justify,
                    style: pw.TextStyle(
                      fontSize: font_Size,
                      font: ttf,
                      color: Colors_pd,
                    ),
                  ),
                  pw.Text(
                    (addr_.toString() == '' ||
                            addr_ == null ||
                            addr_.toString() == 'null')
                        ? 'ที่อยู่ : -'
                        : 'ที่อยู่ : ${addr_}',
                    textAlign: pw.TextAlign.justify,
                    maxLines: 1,
                    style: pw.TextStyle(
                      fontSize: font_Size,
                      font: ttf,
                      color: Colors_pd,
                    ),
                  ),
                  pw.Text(
                    'โทร : ${(tel_.toString() == '' || tel_ == null || tel_.toString() == 'null') ? 0 : tel_} / เลขประจำตัวผู้เสียภาษี : ${(tax_.toString() == '' || tax_ == null || tax_.toString() == 'null') ? 0 : tax_}',
                    textAlign: pw.TextAlign.justify,
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
            pw.Container(
              width: 180,
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                mainAxisSize: pw.MainAxisSize.min,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  // pw.Text(
                  //   'ใบวางบิล/ใบแจ้งหนี้ (Invoice)',
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
                    (cFinn.toString() == '' ||
                            cFinn == null ||
                            cFinn.toString() == 'null')
                        ? 'เลขที่(ID) : -'
                        : 'เลขที่(ID) : ${cFinn}',
                    textAlign: pw.TextAlign.right,
                    maxLines: 1,
                    style: pw.TextStyle(
                      fontSize: font_Size,
                      font: ttf,
                      color: Colors_pd,
                    ),
                  ),
                  pw.Text(
                    (date_Transaction == null)
                        ? 'วันที่ทำรายการ : '
                        : 'วันที่ทำรายการ : $formattedDate2 ${newYear2}',
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
                    (End_Bill_Paydate == null)
                        ? 'วันที่ครบกำหนดชำระ : '
                        : 'วันที่ครบกำหนดชำระ : ${formatter.format(DateTime.parse(End_Bill_Paydate))} ${DateTime.parse(End_Bill_Paydate).year + 543}',
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
                    'พนักงาน(Staff) : $fname',
                    textAlign: pw.TextAlign.right,
                    maxLines: 1,
                    style: pw.TextStyle(
                      fontSize: font_Size,
                      fontWeight: pw.FontWeight.bold,
                      font: ttf,
                      color: Colors_pd,
                    ),
                  ),
                  pw.SizedBox(height: 10 * PdfPageFormat.mm),
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

    pw.Widget footer_data_sub(int i) {
      return (btype1.toString() == 'CASH')
          ? pw.Expanded(
              child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 10 * PdfPageFormat.mm),
                pw.Padding(
                  padding: pw.EdgeInsets.all(0),
                  child: pw.Text(
                    'หมายเหตุ(Note)',
                    textAlign: pw.TextAlign.left,
                    maxLines: 1,
                    style: pw.TextStyle(
                        font: ttf,
                        fontSize: font_Size,
                        color: PdfColors.grey800),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(0),
                  child: pw.Text(
                    '1. โปรดชำระเงินไม่เกินวันที่หรือเวลาที่กำหนด',
                    textAlign: pw.TextAlign.left,
                    maxLines: 1,
                    style: pw.TextStyle(
                        font: ttf,
                        fontSize: font_Size,
                        color: PdfColors.grey800),
                  ),
                ),
                // pw.Padding(
                //   padding: pw.EdgeInsets.all(0),
                //   child: pw.Text(
                //     '2. หากเกิดข้อผิดพลาดโปรดเก็บหลักฐานการชำระไว้ เพื่อติดต่อเจ้าหน้าที่',
                //     textAlign: pw.TextAlign.left,
                //     maxLines: 1,
                //     style: pw.TextStyle(
                //         font: ttf,
                //         fontSize: font_Size,
                //         color: PdfColors.red400),
                //   ),
                // ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(0),
                  child: pw.Text(
                    '2. ขอความกรุณาชำระค่าเช่าให้ตรงกับยอดในใบแจ้งหนี้ เพื่อความถูกต้องในทางบัญชี',
                    textAlign: pw.TextAlign.left,
                    maxLines: 1,
                    style: pw.TextStyle(
                        font: ttf,
                        fontSize: font_Size,
                        color: PdfColors.red400),
                  ),
                ),
              ],
            ))
          : pw.Expanded(
              child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 10 * PdfPageFormat.mm),
                pw.Padding(
                  padding: pw.EdgeInsets.all(0),
                  child: pw.Text(
                    'หมายเหตุ(Note)',
                    textAlign: pw.TextAlign.left,
                    maxLines: 1,
                    style: pw.TextStyle(
                        font: ttf,
                        fontSize: font_Size,
                        color: PdfColors.grey800),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(0),
                  child: pw.Text(
                    '1. โปรดชำระเงินไม่เกินวันที่หรือเวลาที่กำหนด',
                    textAlign: pw.TextAlign.left,
                    maxLines: 1,
                    style: pw.TextStyle(
                        font: ttf,
                        fontSize: font_Size,
                        color: PdfColors.grey800),
                  ),
                ),
                // (payment_Ptser1 == '6')
                //     ?
                if (ptser1.toString() == '2' ||
                    ptser1.toString() == '5' ||
                    ptser1.toString() == '6' ||
                    ptser1.toString() == '7')
                  pw.Padding(
                    padding: pw.EdgeInsets.all(0),
                    child: pw.Text(
                      '2. การชำระเงิน ท่านสามารถโอนเข้าบัญชี ${bank1} เลขที่บัญชี ${selectedValue_bank_bno} [ ${(ptname1 == 'Online Payment') ? 'PromptPay QR' : (ptname1 == 'เงินโอน') ? 'เลขบัญชี' : (ptname1 == 'Beam Checkout') ? 'Beam Checkout' : 'Online Standard QR'} ]',
                      //  '2. การชำระเงิน ท่านสามารถโอนเข้าเลขที่บัญชี ${finnancetransModels.where((model) => model.ptser == '6' && model.dtype != 'MM').map((model) => model.bno).join(', ')}',
                      textAlign: pw.TextAlign.left,
                      maxLines: 1,
                      style: pw.TextStyle(
                          font: ttf,
                          fontSize: font_Size,
                          color: PdfColors.grey800),
                    ),
                  ),
                // : pw.Padding(
                //     padding: pw.EdgeInsets.all(0),
                //     child: pw.Text(
                //       (payment_Ptser1 == '2')
                //           ? '2. การชำระเงิน ท่านสามารถโอนเข้าบัญชี ${bank1} เลขที่บัญชี ${selectedValue_bank_bno} '
                //           : '2. การชำระเงิน ท่านสามารถโอนเข้าบัญชี ${bank1}  เลขที่บัญชี ${selectedValue_bank_bno} ($paymentName1)',
                //       textAlign: pw.TextAlign.left,
                //       maxLines: 1,
                //       style: pw.TextStyle(
                //           font: ttf,
                //           fontSize: font_Size,
                //           color: PdfColors.grey800),
                //     ),
                //   ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(0),
                  child: pw.Text(
                    '3. ขอความกรุณาชำระค่าเช่าให้ตรงกับยอดในใบแจ้งหนี้ เพื่อความถูกต้องในทางบัญชี',
                    textAlign: pw.TextAlign.left,
                    maxLines: 1,
                    style: pw.TextStyle(
                        font: ttf,
                        fontSize: font_Size,
                        color: PdfColors.red400),
                  ),
                ),
              ],
            ));
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
              pw.Row(children: [
                // pw.Expanded(child: pw.Container()),
                pw.Expanded(flex: 2, child: footer_data_sub(0)),
                // pw.SizedBox(width: 10 * PdfPageFormat.mm),
                pw.Expanded(
                  flex: 1,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.SizedBox(height: 20 * PdfPageFormat.mm),
                      pw.Text(
                        'ลงชื่อ..................................................................(ผู้วางบิล)',
                        textAlign: pw.TextAlign.left,
                        maxLines: 1,
                        style: pw.TextStyle(
                            // fontWeight: pw.FontWeight.bold,
                            font: ttf,
                            fontSize: font_Size,
                            color: PdfColors.grey800),
                      ),
                      pw.Text(
                        '(........................................................)',
                        textAlign: pw.TextAlign.left,
                        maxLines: 1,
                        style: pw.TextStyle(
                            // fontWeight: pw.FontWeight.bold,
                            font: ttf,
                            fontSize: font_Size,
                            color: PdfColors.grey800),
                      ),
                    ],
                  ),
                ),
                if (ptser1.toString() == '6')
                  pw.Container(
                      child: pw.Column(
                    children: [
                      pw.BarcodeWidget(
                        data:
                            '|$selectedValue_bank_bno\r${cFinn.replaceAll('-', '')}\r${DateFormat('ddMM').format(DateTime.parse(End_Bill_Paydate))}$YearQRthai\r${totalBill_QR}',
                        // '|$selectedValue_bank_bno\r${cFinn.replaceAll('-', '')}\r${DateFormat('ddMM').format(DateTime.parse(End_Bill_Paydate))}$YearQRthai\r${newTotal_QR}',
                        barcode: pw.Barcode.qrCode(),
                        height: 70,
                        width: 70,
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        (End_Bill_Paydate == null ||
                                End_Bill_Paydate.toString() == '')
                            // ? '${totalBill_QR}'
                            // : '${totalBill_QR}',
                            ? 'ชำระไม่เกินวันที่ ${End_Bill_Paydate} '
                            : 'ชำระไม่เกินวันที่ ${DateFormat('dd/MM').format(DateTime.parse(End_Bill_Paydate!))}/${DateTime.parse('${End_Bill_Paydate}').year + 543}',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: font_Size - 1.5,
                          font: ttf,
                          // fontWeight: pw.FontWeight.bold,
                          color: Colors_pd,
                        ),
                      ),
                      // pw.Padding(
                      //   padding: pw.EdgeInsets.all(0),
                      //   child: pw.Text(
                      //     'สแกน (Scan me)',
                      //     textAlign: pw.TextAlign.left,
                      //     maxLines: 1,
                      //     style: pw.TextStyle(
                      //         font: ttf,
                      //         fontSize: font_Size,
                      //         color: PdfColors.grey800),
                      //   ),
                      // ),
                    ],
                  )),
                if (ptser1.toString() == '5')
                  pw.Container(
                      child: pw.Column(
                    children: [
                      pw.BarcodeWidget(
                        data: generateQRCode(
                            promptPayID: "$selectedValue_bank_bno",
                            amount: double.parse('$totalBill')),
                        // amount: double.parse((Total == null || Total == '')
                        //     ? '0'
                        //     : '$Total')),
                        barcode: pw.Barcode.qrCode(),
                        height: 70,
                        width: 70,
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        (End_Bill_Paydate == null ||
                                End_Bill_Paydate.toString() == '')
                            ? ' $totalBill ชำระไม่เกินวันที่ ${End_Bill_Paydate} '
                            : '$totalBill ชำระไม่เกินวันที่ ${DateFormat('dd/MM').format(DateTime.parse(End_Bill_Paydate!))}/${DateTime.parse('${End_Bill_Paydate}').year + 543}',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: font_Size - 1.5,
                          font: ttf,
                          // fontWeight: pw.FontWeight.bold,
                          color: Colors_pd,
                        ),
                      ),
                      // pw.Padding(
                      //   padding: pw.EdgeInsets.all(0),
                      //   child: pw.Text(
                      //     'สแกน (Scan me)',
                      //     textAlign: pw.TextAlign.left,
                      //     maxLines: 1,
                      //     style: pw.TextStyle(
                      //         font: ttf,
                      //         fontSize: font_Size,
                      //         color: PdfColors.grey800),
                      //   ),
                      // ),
                    ],
                  )),
                if (img1.toString() != '')
                  if (ptser1.toString() == '2')
                    pw.Container(
                        child: pw.Column(
                      children: [
                        pw.Image(
                          (netImage_QR[0]),
                          height: 70,
                          width: 70,
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          (End_Bill_Paydate == null ||
                                  End_Bill_Paydate.toString() == '')
                              ? 'ชำระไม่เกินวันที่ ${End_Bill_Paydate} '
                              : 'ชำระไม่เกินวันที่ ${DateFormat('dd/MM').format(DateTime.parse(End_Bill_Paydate!))}/${DateTime.parse('${End_Bill_Paydate}').year + 543}',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: font_Size - 1.5,
                            font: ttf,
                            // fontWeight: pw.FontWeight.bold,
                            color: Colors_pd,
                          ),
                        ),
                        // pw.Padding(
                        //   padding: pw.EdgeInsets.all(0),
                        //   child: pw.Text(
                        //     'สแกน (Scan me)',
                        //     textAlign: pw.TextAlign.left,
                        //     maxLines: 1,
                        //     style: pw.TextStyle(
                        //         font: ttf,
                        //         fontSize: font_Size,
                        //         color: PdfColors.grey800),
                        //   ),
                        // ),
                      ],
                    )),
              ]),
              // pw.Row(
              //   children: (btype1.toString() == 'CASH')
              //       ? [pw.Expanded(child: footer_data_sub(0))]
              //       : (payment_Ptser1.toString() == '6')
              //           ? [
              //               footer_data_sub(0),
              //               pw.Column(children: [
              //                 pw.Container(
              //                   child: pw.BarcodeWidget(
              //                     data:
              //                         '|${selectedValue_bank_bno}\r$cFinn\r${DateFormat('dd-MM-yyyy').format(DateTime.parse('${date_Transaction}'))}\r${newTotal_QR}\r',
              //                     barcode: pw.Barcode.qrCode(),
              //                     height: 35,
              //                     width: 40,
              //                   ),
              //                 ),
              //                 pw.Padding(
              //                   padding: pw.EdgeInsets.all(0),
              //                   child: pw.Text(
              //                     'สแกน (Scan me)',
              //                     textAlign: pw.TextAlign.left,
              //                     maxLines: 1,
              //                     style: pw.TextStyle(
              //                         font: ttf,
              //                         fontSize: font_Size,
              //                         color: PdfColors.grey800),
              //                   ),
              //                 ),
              //               ]),
              //             ]
              //           : [
              //               footer_data_sub(0),
              //               // for (var i = 0; i < finnancetransModels.length; i++)
              //               if (payment_Ptser1.toString() != '1')
              //                 pw.Column(children: [
              //                   pw.Container(
              //                     child: (payment_Ptser1.toString() == '5')
              //                         ? pw.BarcodeWidget(
              //                             data: generateQRCode(
              //                                 promptPayID:
              //                                     "${selectedValue_bank_bno}",
              //                                 amount: double.parse((Total ==
              //                                             null ||
              //                                         Total.toString() == '')
              //                                     ? '0'
              //                                     : '${Total}')),
              //                             barcode: pw.Barcode.qrCode(),
              //                             height: 35,
              //                             width: 40,
              //                           )
              //                         : (netImage_QR.length == 0)
              //                             ? pw.Text('')
              //                             : pw.Image(
              //                                 (netImage_QR[0]),
              //                                 height: 35,
              //                                 width: 40,
              //                               ),
              //                   ),
              //                   pw.Padding(
              //                     padding: pw.EdgeInsets.all(0),
              //                     child: pw.Text(
              //                       'สแกน (Scan me)',
              //                       textAlign: pw.TextAlign.left,
              //                       maxLines: 1,
              //                       style: pw.TextStyle(
              //                           font: ttf,
              //                           fontSize: font_Size,
              //                           color: PdfColors.grey800),
              //                     ),
              //                   ),
              //                 ]),
              //             ],
              // ),

              if (serpang == 1 && tableData003.length < 7)
                pw.Padding(
                  padding: pw.EdgeInsets.all(0),
                  child: pw.Text(
                    '...' * 140,
                    maxLines: 1,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                        font: ttf,
                        fontSize: font_Size,
                        color: PdfColors.grey500),
                  ),
                ),
              if (tableData003.length > 6)
                pw.SizedBox(height: 2.2 * PdfPageFormat.mm),
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
                          top: pw.BorderSide(color: PdfColors.grey800),
                          bottom: pw.BorderSide(color: PdfColors.grey800),
                        ),
                      ),
                      child: pw.Row(
                        children: headerColumns.map((col) {
                          final label = col['label'] as String;
                          final flex = col['flex'] as int;
                          final align = col['align'] as pw.Alignment;
                          final width = col['width'] as double?;

                          final container = pw.Container(
                            // decoration: pw.BoxDecoration(
                            //   border: pw.Border(
                            //     left: (label == 'ยอดสุทธิ')
                            //         ? pw.BorderSide.none
                            //         : const pw.BorderSide(color: PdfColors.grey600),
                            //     right: const pw.BorderSide(color: PdfColors.grey600),
                            //   ),
                            // ),
                            // height: 20,
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
                      )),
                  if (hasNotKd)
                    pw.Row(
                      children: [
                        // ช่องแรก เลขลำดับ
                        pw.Container(
                          width: 30,
                          padding: const pw.EdgeInsets.all(2.0),
                          child: pw.Align(
                            alignment: pw.Alignment.center,
                            child: pw.Text(
                              '1', // ✅ แสดงเลขบรรทัด
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: font_Size,
                                font: ttf,
                                color: PdfColors.grey800,
                              ),
                            ),
                          ),
                        ),

                        // ช่องสอง docno ตัวแรก
                        buildCell(
                          text: 'ค่าเช่า ประจําเดือน ${totallist}',
                          flex: 4,
                          alignment: pw.Alignment.centerLeft,
                          textAlign: pw.TextAlign.left,
                        ),

                        // buildCell(
                        //   text: (_InvoiceHistoryModels.unitser.toString() == '6')
                        //       ? '${_InvoiceHistoryModels.descr} [ หน่วยที่ใช้ไป ${_InvoiceHistoryModels.ovalue}-${_InvoiceHistoryModels.nvalue} ]'
                        //       : '${_InvoiceHistoryModels.descr} ${DateFormat('MMM', 'th').format(DateTime.parse(_InvoiceHistoryModels.date!))} ${DateTime.parse('${_InvoiceHistoryModels.date}').year + 543}',
                        //   flex: 4,
                        //   alignment: pw.Alignment.centerLeft,
                        //   textAlign: pw.TextAlign.left,
                        // ),

                        // // qty รวม
                        // buildCell(
                        //   text: getFormattedText(totalqty.toString()),
                        //   flex: 1,
                        //   alignment: pw.Alignment.centerRight,
                        //   textAlign: pw.TextAlign.right,
                        // ),

                        // buildCell(
                        //   text: (totalpri == 0)
                        //       ? '-' // ถ้ารวมแล้วไม่มีค่า
                        //       : getFormattedText(totalpri.toString()),
                        //   flex: 1,
                        //   alignment: pw.Alignment.centerRight,
                        //   textAlign: pw.TextAlign.right,
                        // ),

                        // amt รวม
                        buildCell(
                          text: getFormattedText(totalsum.toString()),
                          flex: 1,
                          alignment: pw.Alignment.centerRight,
                          textAlign: pw.TextAlign.right,
                        ),

                        // ส่วนลดรวม
                        buildCell(
                          text: getFormattedText(totaldis.toString()),
                          flex: 1,
                          alignment: pw.Alignment.centerRight,
                          textAlign: pw.TextAlign.right,
                        ),

                        // รวมสุทธิรวม
                        buildCell(
                          text: getFormattedText(totalsum.toString()),
                          flex: 1,
                          alignment: pw.Alignment.centerRight,
                          textAlign: pw.TextAlign.right,
                        ),
                      ],
                    ),

                  pw.Column(
                    children: _InvoiceHistoryModels.where((e) =>
                            e.dtype.toString() ==
                            'KD') // ✅ กรองเอาเฉพาะที่ไม่ใช่ KD
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
                      final index = entry.key; // index เริ่มจาก 0
                      final invoices = entry.value;

                      return pw.Container(
                        child: pw.Row(
                          children: [
                            pw.Container(
                              width: 30,
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Align(
                                alignment: pw.Alignment.center,
                                child: pw.Text(
                                  hasNotKd
                                      ? '${index + 2}' // ✅ ให้เริ่มที่เลข 2
                                      : '${index + 1}',
                                  maxLines: 2,
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    color: PdfColors.grey800,
                                  ),
                                ),
                              ),
                            ),

                            // ✅ ใช้โค้ด buildCell เหมือนเดิม
                            buildCell(
                              text: (invoices.unitser.toString() == '6')
                                  ? '${invoices.descr} [ หน่วยที่ใช้ไป ${invoices.ovalue}-${invoices.nvalue} ]'
                                  : '${invoices.descr} ${DateFormat('MMM', 'th').format(DateTime.parse(invoices.date!))} ${DateTime.parse('${invoices.date}').year + 543}',
                              flex: 4,
                              alignment: pw.Alignment.centerLeft,
                              textAlign: pw.TextAlign.left,
                            ),
                            // buildCell(
                            //   text: getFormattedText(invoices.qty),
                            //   flex: 1,
                            //   alignment: pw.Alignment.centerRight,
                            //   textAlign: pw.TextAlign.right,
                            // ),
                            // buildCell(
                            //   text: (invoices.ele_ty.toString() != '0' &&
                            //           invoices.ele_ty != null)
                            //       ? 'อัตราพิเศษ'
                            //       : (invoices.dtype.toString() == 'KU')
                            //           ? getFormattedText('${invoices.pri}')
                            //           : '-',
                            //   flex: 1,
                            //   alignment: pw.Alignment.centerRight,
                            //   textAlign: pw.TextAlign.right,
                            // ),
                            // buildCell(
                            //   text: (double.tryParse(
                            //               invoices.pvat_original.toString()) !=
                            //           0)
                            //       ? getFormattedText(
                            //           '${invoices.pvat_original}')
                            //       : (invoices.dtype.toString() == 'KU')
                            //           ? getFormattedText('${invoices.amt}')
                            //           : getFormattedText('${invoices.pri}'),
                            //   flex: 1,
                            //   alignment: pw.Alignment.centerRight,
                            //   textAlign: pw.TextAlign.right,
                            // ),
                            buildCell(
                              text: getFormattedText('${invoices.total}'),
                              flex: 1,
                              alignment: pw.Alignment.centerRight,
                              textAlign: pw.TextAlign.right,
                            ),
                            buildCell(
                              text: getFormattedText('${invoices.dis_list}'),
                              flex: 1,
                              alignment: pw.Alignment.centerRight,
                              textAlign: pw.TextAlign.right,
                            ),
                            buildCell(
                              text: getFormattedText('${invoices.total}'),
                              flex: 1,
                              alignment: pw.Alignment.centerRight,
                              textAlign: pw.TextAlign.right,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  // pw.Column(
                  //   children:
                  //       List.generate(_InvoiceHistoryModels.length, (index) {
                  //     final invoices = _InvoiceHistoryModels[index];

                  //     return pw.Container(
                  //       // decoration: const pw.BoxDecoration(
                  //       //   // color: PdfColors.green100,
                  //       //   border: pw.Border(
                  //       //     // top: pw.BorderSide(color: PdfColors.grey600),
                  //       //     bottom: pw.BorderSide(color: PdfColors.grey600),
                  //       //   ),
                  //       // ),
                  //       child: pw.Row(
                  //         children: [
                  //           pw.Container(
                  //             // decoration: const pw.BoxDecoration(
                  //             //   color: PdfColors.white,
                  //             //   border: pw.Border(
                  //             //     left: pw.BorderSide(color: PdfColors.grey600),
                  //             //   ),
                  //             // ),
                  //             width: 30, //25
                  //             padding: const pw.EdgeInsets.all(2.0),
                  //             child: pw.Align(
                  //               alignment: pw.Alignment.center,
                  //               child: pw.Text(
                  //                 '${index + 1}',
                  //                 maxLines: 2,
                  //                 textAlign: pw.TextAlign.center,
                  //                 style: pw.TextStyle(
                  //                     fontSize: font_Size,
                  //                     font: ttf,
                  //                     color: PdfColors.grey800),
                  //               ),
                  //             ),
                  //           ),
                  //           // buildCell(
                  //           //   text: (invoices.date == null ||
                  //           //           invoices.date.toString() == '')
                  //           //       ? '-'
                  //           //       : '${DateFormat('dd-MM').format(DateTime.parse(invoices.date.toString()))}-${DateTime.parse(invoices.date.toString()).year + 543}',
                  //           //   flex: 2,
                  //           //   alignment: pw.Alignment.centerLeft,
                  //           //   textAlign: pw.TextAlign.center,
                  //           // ),

                  //           buildCell(
                  //             text: (invoices.unitser.toString() == '6')
                  //                 ? '${invoices.descr} [ หน่วยที่ใช้ไป ${invoices.ovalue}-${invoices.nvalue} ]'
                  //                 : '${invoices.descr} ${DateFormat('MMM', 'th').format(DateTime.parse(invoices.date!))} ${DateTime.parse('${invoices.date}').year + 543}',
                  //             flex: 4,
                  //             alignment: pw.Alignment.centerLeft,
                  //             textAlign: pw.TextAlign.left,
                  //           ),
                  //           buildCell(
                  //             text: getFormattedText(invoices.qty),
                  //             // text: (getFormattedText(invoices.tf) != '0.00')
                  //             //     ? '${getFormattedText(invoices.pri)} '
                  //             //         '(tf ${getFormattedText(((double.tryParse(invoices.amt ?? '0.00') ?? 0.00) - (double.tryParse(invoices.vat ?? '0.00') ?? 0.00) - (double.tryParse(invoices.pvat ?? '0.00') ?? 0.00)).toString())})'
                  //             //     : getFormattedText(invoices.nvat),
                  //             flex: 1,
                  //             alignment: pw.Alignment.centerRight,
                  //             textAlign: pw.TextAlign.right,
                  //           ),

                  //           // buildCell(
                  //           //   text: (invoices.ele_ty.toString() != '0' &&
                  //           //           invoices.ele_ty != null)
                  //           //       ? 'อัตราพิเศษ'
                  //           //       : isPositive(invoices.dis_list)
                  //           //           ? (invoices.unitser.toString() == '6')
                  //           //               ? getFormattedText('${invoices.pri}')
                  //           //               // : getFormattedText(
                  //           //               //     '${invoices.pvat_original}')
                  //           //               : '-'
                  //           //           : (invoices.unitser.toString() == '6')
                  //           //               ? getFormattedText('${invoices.pri}')
                  //           //               : getFormattedText(
                  //           //                   '${invoices.pvat}'),

                  //           //   // (invoices.pri.toString() == '0.00')
                  //           //   //     ? getFormattedText('${invoices.amt}')
                  //           //   //     : getFormattedText('${invoices.pvat}'),
                  //           //   flex: 1,
                  //           //   alignment: pw.Alignment.centerRight,
                  //           //   textAlign: pw.TextAlign.right,
                  //           // ),
                  //           buildCell(
                  //             text: (invoices.ele_ty.toString() != '0' &&
                  //                     invoices.ele_ty != null)
                  //                 ? 'อัตราพิเศษ'
                  //                 : (invoices.dtype.toString() == 'KU')
                  //                     ? getFormattedText('${invoices.pri}')
                  //                     : '-',
                  //             flex: 1,
                  //             alignment: pw.Alignment.centerRight,
                  //             textAlign: pw.TextAlign.right,
                  //           ),

                  //           // buildCell(
                  //           //   text: isPositive(invoices.dis_list)
                  //           //       ? getFormattedText('${invoices.vat_original}')
                  //           //       : getFormattedText('${invoices.vat}'),
                  //           //   flex: 1,
                  //           //   alignment: pw.Alignment.centerRight,
                  //           //   textAlign: pw.TextAlign.right,
                  //           // ),
                  //           // buildCell(
                  //           //   text: isPositive(invoices.dis_list)
                  //           //       ? getFormattedText('${invoices.wht_original}')
                  //           //       : getFormattedText('${invoices.wht}'),
                  //           //   flex: 1,
                  //           //   alignment: pw.Alignment.centerRight,
                  //           //   textAlign: pw.TextAlign.right,
                  //           // ),
                  //           // buildCell(
                  //           //   text: isPositive(invoices.dis_list)
                  //           //       ? getFormattedText('${invoices.pvat_original}')
                  //           //       : getFormattedText('${invoices.pvat}'),
                  //           //   flex: 2,
                  //           //   alignment: pw.Alignment.centerRight,
                  //           //   textAlign: pw.TextAlign.right,
                  //           // ),
                  //           buildCell(
                  //             text: (double.tryParse(
                  //                         invoices.pvat_original.toString()) !=
                  //                     0)
                  //                 ? getFormattedText(
                  //                     '${invoices.pvat_original}')
                  //                 : (invoices.dtype.toString() == 'KU')
                  //                     ? getFormattedText('${invoices.amt}')
                  //                     : getFormattedText('${invoices.pri}'),
                  //             flex: 1,
                  //             alignment: pw.Alignment.centerRight,
                  //             textAlign: pw.TextAlign.right,
                  //           ),

                  //           buildCell(
                  //             text: getFormattedText('${invoices.dis_list}'),
                  //             flex: 1,
                  //             alignment: pw.Alignment.centerRight,
                  //             textAlign: pw.TextAlign.right,
                  //           ),
                  //           buildCell(
                  //             text: getFormattedText('${invoices.total}'),
                  //             flex: 2,
                  //             alignment: pw.Alignment.centerRight,
                  //             textAlign: pw.TextAlign.right,
                  //           ),
                  //         ],
                  //       ),
                  //     );
                  //   }),
                  // ),

                  // pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  pw.Container(
                    // height: 25,
                    decoration: const pw.BoxDecoration(
                      // color: PdfColors.green100,
                      border: pw.Border(
                        top: pw.BorderSide(color: PdfColors.grey600),
                        // bottom: pw.BorderSide(color: PdfColors.grey600),
                      ),
                    ),
                    padding: const pw.EdgeInsets.fromLTRB(0, 1, 0, 0),
                    alignment: pw.Alignment.centerRight,
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          flex: 3,
                          child: pw.Text(
                            '(~${convertToThaiBaht(totalBill)}~)',
                            //"${nFormat2.format(double.parse(Total.toString()))}";
                            // '(~${convertToThaiBaht(double.parse(Total.toString()))}~)',
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              // fontWeight: pw.FontWeight.bold,
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
                          flex: 3,
                          child: pw.Container(
                            decoration: const pw.BoxDecoration(
                              // color: PdfColors.green100,
                              border: pw.Border(
                                // top: pw.BorderSide(color: PdfColors.grey600),
                                bottom: pw.BorderSide(color: PdfColors.grey600),
                              ),
                            ),
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Row(
                                  children: [
                                    pw.Expanded(
                                      flex: 2,
                                      child: pw.Text(
                                        'รวมราคาสินค้า/Sub Total',
                                        textAlign: pw.TextAlign.left,
                                        style: pw.TextStyle(
                                            // fontWeight:
                                            //     pw.FontWeight.bold,
                                            font: ttf,
                                            fontSize: font_Size,
                                            color: PdfColors.grey800),
                                      ),
                                    ),
                                    pw.Text(
                                      // '${nFormat.format(totalPvat)}',
                                      '${nFormat.format(totalBill)}',
                                      // '${nFormat.format(double.parse(SubTotal.toString()))}', //..
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                          // fontWeight: pw.FontWeight.bold,
                                          font: ttf,
                                          fontSize: font_Size,
                                          color: PdfColors.grey800),
                                    ),
                                  ],
                                ),
                                pw.Row(
                                  children: [
                                    pw.Expanded(
                                      flex: 2,
                                      child: pw.Text(
                                        'ภาษีมูลค่าเพิ่ม/VAT',
                                        textAlign: pw.TextAlign.left,
                                        style: pw.TextStyle(
                                            // fontWeight:
                                            //     pw.FontWeight.bold,
                                            font: ttf,
                                            fontSize: font_Size,
                                            color: PdfColors.grey800),
                                      ),
                                    ),
                                    pw.Text(
                                      // '${nFormat.format(totalVat)}',
                                      '0.00',
                                      // '${nFormat.format(double.parse(Vat.toString()))}', //..
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                          // fontWeight: pw.FontWeight.bold,
                                          font: ttf,
                                          fontSize: font_Size,
                                          color: PdfColors.grey800),
                                    ),
                                  ],
                                ),
                                pw.Row(
                                  children: [
                                    pw.Expanded(
                                      flex: 2,
                                      child: pw.Text(
                                        'รวมเป็นเงิน/Price',
                                        textAlign: pw.TextAlign.left,
                                        style: pw.TextStyle(
                                            // fontWeight:
                                            //     pw.FontWeight.bold,
                                            font: ttf,
                                            fontSize: font_Size,
                                            color: PdfColors.grey800),
                                      ),
                                    ),
                                    pw.Text(
                                      '${nFormat.format(totalPvat + totalVat)}',
                                      // '${nFormat.format(double.parse(SubTotal.toString()) + double.parse(Vat.toString()))}', //..
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                          // fontWeight: pw.FontWeight.bold,
                                          font: ttf,
                                          fontSize: font_Size,
                                          color: PdfColors.grey800),
                                    ),
                                  ],
                                ),
                                pw.Row(
                                  children: [
                                    pw.Expanded(
                                      flex: 2,
                                      child: pw.Text(
                                        'ภาษีหัก ณ ที่จ่าย/WHT',
                                        textAlign: pw.TextAlign.left,
                                        style: pw.TextStyle(
                                            // fontWeight:
                                            //     pw.FontWeight.bold,
                                            font: ttf,
                                            fontSize: font_Size,
                                            color: PdfColors.grey800),
                                      ),
                                    ),
                                    pw.Text(
                                      '${nFormat.format(totalWht)}',
                                      // '${nFormat.format(double.parse(Deduct.toString()))}', //.
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                          // fontWeight: pw.FontWeight.bold,
                                          font: ttf,
                                          fontSize: font_Size,
                                          color: PdfColors.grey800),
                                    ),
                                  ],
                                ),
                                pw.Row(
                                  children: [
                                    pw.Expanded(
                                      flex: 2,
                                      child: pw.Text(
                                        'ส่วนลด(Discount)',
                                        textAlign: pw.TextAlign.left,
                                        style: pw.TextStyle(
                                            // fontWeight:
                                            //     pw.FontWeight.bold,
                                            font: ttf,
                                            fontSize: font_Size,
                                            color: PdfColors.grey800),
                                      ),
                                    ),
                                    pw.Text(
                                      '${nFormat.format(totalDis)}',
                                      // '${nFormat.format(double.parse(DisC.toString()))}',
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                          // fontWeight: pw.FontWeight.bold,
                                          font: ttf,
                                          fontSize: font_Size,
                                          color: PdfColors.grey800),
                                    ),
                                  ],
                                ),
                                pw.Row(
                                  children: [
                                    pw.Expanded(
                                      flex: 2,
                                      child: pw.Text(
                                        'จำนวนเงินรวมทั้งสิ้น(Total amount)',
                                        textAlign: pw.TextAlign.left,
                                        style: pw.TextStyle(
                                            // fontWeight:
                                            //     pw.FontWeight.bold,
                                            font: ttf,
                                            fontSize: font_Size,
                                            color: PdfColors.grey800),
                                      ),
                                    ),
                                    pw.Text(
                                      '${nFormat.format(totalBill)}',
                                      // '${nFormat.format(double.parse(Total.toString()))}',
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                          // fontWeight: pw.FontWeight.bold,
                                          font: ttf,
                                          fontSize: font_Size,
                                          color: PdfColors.grey800),
                                    ),
                                  ],
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
            if (tableData003.length < 11) footer_data(serpang)
          ],
        ),
      );
    }

    if (tableData003.length < 11)
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.copyWith(
            marginBottom: 4.00,
            marginLeft: 8.00,
            marginRight: 8.00,
            marginTop: 8.00,
          ),
          build: (context) {
            return [
              pw.Container(
                  height: PdfPageFormat.a4.height / 2.05,
                  decoration: const pw.BoxDecoration(
                    // color: PdfColors.green50,
                    border: pw.Border(
                        // top: pw.BorderSide(color: PdfColors.grey800),
                        // bottom: pw.BorderSide(color: PdfColors.grey800),
                        ),
                  ),
                  child: pw.Column(
                    children: [
                      Header(1),
                      pw.Expanded(child: Body_data(1)),
                    ],
                  )),
              pw.Container(
                  height: PdfPageFormat.a4.height / 2.05,
                  decoration: const pw.BoxDecoration(
                    // color: PdfColors.red50,
                    border: pw.Border(
                        // top: pw.BorderSide(color: PdfColors.grey800),
                        // bottom: pw.BorderSide(color: PdfColors.grey800),
                        ),
                  ),
                  child: pw.Column(
                    children: [
                      Header(2),
                      pw.Expanded(child: Body_data(2)),
                    ],
                  )),
            ];
          },
          // footer: (context) {
          //   return pw.Align(
          //     alignment: pw.Alignment.bottomRight,
          //     child: pw.Text(
          //       'หน้า ${context.pageNumber} / ${context.pagesCount} ',
          //       textAlign: pw.TextAlign.left,
          //       style: pw.TextStyle(
          //         fontSize: 10.0,
          //         font: ttf,
          //         color: Colors_pd,
          //         // fontWeight: pw.FontWeight.bold
          //       ),
          //     ),
          //   );
          // },
        ),
      );

    if (tableData003.length > 10)
      pdf.addPage(
        pw.MultiPage(
            pageFormat: PdfPageFormat.a4.copyWith(
              marginBottom: 4.00,
              marginLeft: 8.00,
              marginRight: 8.00,
              marginTop: 8.00,
            ),
            header: (context) {
              return Header(1);
            },
            build: (context) {
              return [Body_data(1)];
            },
            footer: (tableData003.length < 10)
                ? null
                : (context) {
                    return footer_data(1);
                  }),
      );
    if (tableData003.length > 10)
      pdf.addPage(
        pw.MultiPage(
            pageFormat: PdfPageFormat.a4.copyWith(
              marginBottom: 4.00,
              marginLeft: 8.00,
              marginRight: 8.00,
              marginTop: 8.00,
            ),
            header: (context) {
              return Header(2);
            },
            build: (context) {
              return [Body_data(2)];
            },
            footer: (tableData003.length < 10)
                ? null
                : (context) {
                    return footer_data(2);
                  }),
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
