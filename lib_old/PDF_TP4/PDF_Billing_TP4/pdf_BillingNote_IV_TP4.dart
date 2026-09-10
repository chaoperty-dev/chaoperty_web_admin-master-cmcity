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

class Pdfgen_BillingNoteInvlice_TP4 {
  //////////---------------------------------------------------->(ใบวางบิล แจ้งหนี้)  ใช้  ++
  static void exportPDF_BillingNoteInvlice_TP4(

      ///(ser_BillingNote 1 = วางบิล  /// 2 = ประวัติวางบิล )
      List<InvoiceHistoryModel> _InvoiceHistoryModels,
      foder,
      Cust_no,
      cid_,
      Zone_s,
      Ln_s,
      fname,
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
      bank1,
      ptser1,
      ptname1,
      img1,
      Preview_ser,
      End_Bill_Paydate,
      TitleType_Default_Receipt_Name,
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
      // {
      //   'label': 'ลำดับ',
      //   'flex': 0,
      //   'align': pw.Alignment.centerLeft,
      //   'width': 25.0
      // },
      // {'label': 'กำหนดชำระ', 'flex': 2, 'align': pw.Alignment.centerLeft},
      // {'label': 'รายการ', 'flex': 4, 'align': pw.Alignment.centerLeft},
      // {'label': 'จำนวน', 'flex': 1, 'align': pw.Alignment.centerRight},
      // {'label': 'หน่วย', 'flex': 1, 'align': pw.Alignment.centerRight},
      // // {'label': 'VAT', 'flex': 1, 'align': pw.Alignment.centerRight},
      // // {'label': 'WHT', 'flex': 1, 'align': pw.Alignment.centerRight},
      // // {'label': 'ก่อนVAT', 'flex': 2, 'align': pw.Alignment.centerRight},
      // {'label': 'ราคา', 'flex': 1, 'align': pw.Alignment.centerRight},
      // {'label': 'ส่วนลด', 'flex': 1, 'align': pw.Alignment.centerRight},
      // {'label': 'ยอดสุทธิ', 'flex': 2, 'align': pw.Alignment.centerRight},
      {
        'label': 'ลำดับ',
        'flex': 0,
        'align': pw.Alignment.center,
        'width': 25.0
      },
      {'label': 'กำหนดชำระ', 'flex': 1, 'align': pw.Alignment.centerLeft},
      {'label': 'รายการ', 'flex': 4, 'align': pw.Alignment.centerLeft},
      {'label': 'จำนวน', 'flex': 1, 'align': pw.Alignment.centerRight},
      {'label': 'หน่วย', 'flex': 1, 'align': pw.Alignment.centerRight},
      {'label': 'ก่อนVAT', 'flex': 1, 'align': pw.Alignment.centerRight},
      {'label': 'VAT', 'flex': 1, 'align': pw.Alignment.centerRight},
      {'label': 'WHT', 'flex': 1, 'align': pw.Alignment.centerRight},
      // {'label': 'VAT', 'flex': 1, 'align': pw.Alignment.centerRight},
      // {'label': 'WHT', 'flex': 1, 'align': pw.Alignment.centerRight},
      // {'label': 'ก่อนVAT', 'flex': 2, 'align': pw.Alignment.centerRight},

      {'label': 'ส่วนลด', 'flex': 1, 'align': pw.Alignment.centerRight},
      {'label': 'ยอดสุทธิ', 'flex': 2, 'align': pw.Alignment.centerRight},
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
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginBottom: 4.00,
          marginLeft: 8.00,
          marginRight: 8.00,
          marginTop: 8.00,
        ),
        header: (context) {
          return pw.Column(children: [
            pw.Row(
              children: [
                pw.Container(
                  height: 60,
                  width: 60,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: resizedLogo != null
                      ? pw.Image(
                          pw.MemoryImage(resizedLogo),
                          height: 60,
                          width: 60,
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
                pw.SizedBox(width: 1 * PdfPageFormat.mm),
                pw.Container(
                  width: 200,
                  child: pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '$bill_name',
                        maxLines: 2,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          color: Colors_pd,
                          fontWeight: pw.FontWeight.bold,
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
                        (bill_tax.toString() == '' ||
                                bill_tax == null ||
                                bill_tax.toString() == 'null')
                            ? 'เลขประจำตัวผู้เสียภาษี : 0'
                            : 'เลขประจำตัวผู้เสียภาษี : $bill_tax',
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
                pw.Spacer(),
                pw.Container(
                  width: 180,
                  child: pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'หน้าที่ ${context.pageNumber} / ${context.pagesCount} ',
                        textAlign: pw.TextAlign.right,
                        maxLines: 1,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.SizedBox(width: 5 * PdfPageFormat.mm),
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
                        (bill_email.toString() == '' ||
                                bill_email == null ||
                                bill_email.toString() == 'null')
                            ? 'อีเมล : '
                            : 'อีเมล : $bill_email',
                        maxLines: 1,
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
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Divider(),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
          ]);
        },
        build: (context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  (TitleType_Default_Receipt_Name != null &&
                          TitleType_Default_Receipt_Name.toString().trim() !=
                              '' &&
                          TitleType_Default_Receipt_Name.toString() !=
                              'ไม่ระบุ')
                      ? 'ใบวางบิล/ใบแจ้งหนี้ [ $TitleType_Default_Receipt_Name ]'
                      : 'ใบวางบิล/ใบแจ้งหนี้',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: font_Size + 2,
                    fontWeight: pw.FontWeight.bold,
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
                  flex: 4,
                  child: pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'ลูกค้า',
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.Text(
                        '$customer_name',
                        textAlign: pw.TextAlign.justify,
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
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      // pw.Text(
                      //   'โทรศัพท์: ${tel_}',
                      //   // 'Tel:   ${tel_.substring(0, 3)}-${tel_.substring(3, 6)}-${tel_.substring(6)} ',
                      //   textAlign: pw.TextAlign.justify,
                      //   style: pw.TextStyle(
                      //       fontSize: 10.0,
                      //       font: ttf,
                      //       color: PdfColors.grey800),
                      // ),
                      pw.Text(
                        (email_.toString() == '' ||
                                email_ == null ||
                                email_.toString() == 'null')
                            ? 'อีเมล : -'
                            : 'อีเมล : ${email_}',
                        textAlign: pw.TextAlign.justify,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.Text(
                        (tax_.toString() == '' ||
                                tax_ == null ||
                                tax_.toString() == 'null')
                            ? 'เลขประจำตัวผู้เสียภาษี : 0'
                            : 'เลขประจำตัวผู้เสียภาษี : ${tax_}',
                        textAlign: pw.TextAlign.justify,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.Text(
                        'โซน(Zone) : $Zone_s / ห้อง( Room) : $Ln_s',
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
                pw.SizedBox(width: 10 * PdfPageFormat.mm),
                pw.Expanded(
                  flex: 4,
                  child: pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'เลขที่อ้างอิง(Reference ID)',
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
                            ? ' '
                            : '${cFinn}',
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                        ),
                      ),
                      pw.Text(
                        'วันที่ทำรายการ(Transation Date)',
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.Text(
                        (date_Transaction == null)
                            ? '-'
                            : '$formattedDate2 ${newYear2}',
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.Text(
                        'วันที่ครบกำหนดชำระ(Due Date)',
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.Text(
                        (End_Bill_Paydate == null)
                            ? '-'
                            : '${formatter.format(DateTime.parse(End_Bill_Paydate))} ${DateTime.parse(End_Bill_Paydate).year + 543}',
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Row(children: [
              pw.Text(
                'รับบิลไว้ตรวจสอบตามรายการข้างล่างนี้ถูกต้องแล้ว  ',
                textAlign: pw.TextAlign.justify,
                style: pw.TextStyle(
                  fontSize: font_Size,
                  font: ttf,
                  fontWeight: pw.FontWeight.bold,
                  color: Colors_pd,
                ),
              ),
            ]),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            //////////////---------------------------------->
            pw.Container(
                decoration: const pw.BoxDecoration(
                  // color: PdfColors.green100,
                  border: pw.Border(
                    top: pw.BorderSide(color: PdfColors.grey600),
                    bottom: pw.BorderSide(color: PdfColors.grey600),
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
                          left: (label == 'ยอดสุทธิ')
                              ? pw.BorderSide.none
                              : const pw.BorderSide(color: PdfColors.grey600),
                          right: const pw.BorderSide(color: PdfColors.grey600),
                        ),
                      ),
                      height: 20,
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
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            left: pw.BorderSide(color: PdfColors.grey600),
                          ),
                        ),
                        padding: const pw.EdgeInsets.all(2.0),
                        child: container.child,
                      );
                    }

                    return pw.Expanded(flex: flex, child: container);
                  }).toList(),
                )),

            pw.Column(
              children: List.generate(_InvoiceHistoryModels.length, (index) {
                final invoices = _InvoiceHistoryModels[index];

                return pw.Container(
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
                          color: PdfColors.white,
                          border: pw.Border(
                            left: pw.BorderSide(color: PdfColors.grey600),
                          ),
                        ),
                        width: 25,
                        padding: const pw.EdgeInsets.all(2.0),
                        child: pw.Align(
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            '${index + 1}',
                            maxLines: 2,
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                                fontSize: font_Size,
                                font: ttf,
                                color: PdfColors.grey800),
                          ),
                        ),
                      ),
                      buildCell(
                        text: (invoices.date == null ||
                                invoices.date.toString() == '')
                            ? '-'
                            : '${DateFormat('dd-MM').format(DateTime.parse(invoices.date.toString()))}-${DateTime.parse(invoices.date.toString()).year + 543}',
                        flex: 1,
                        alignment: pw.Alignment.centerLeft,
                        textAlign: pw.TextAlign.center,
                      ),
                      buildCell(
                        text: (invoices.unitser.toString() == '6')
                            ? '${invoices.descr} [ หน่วยที่ใช้ไป ${invoices.ovalue}-${invoices.nvalue} ]' //descr
                            : '${invoices.descr} ${DateFormat('MMM', 'th').format(DateTime.parse(invoices.date!))} ${DateTime.parse('${invoices.date}').year + 543}',
                        flex: 4,
                        alignment: pw.Alignment.centerLeft,
                        textAlign: pw.TextAlign.left,
                      ),
                      buildCell(
                        text: getFormattedText(invoices.qty),
                        flex: 1,
                        alignment: pw.Alignment.centerRight,
                        textAlign: pw.TextAlign.right,
                      ),
                      buildCell(
                        text: (invoices.ele_ty.toString() != '0' &&
                                invoices.ele_ty != null)
                            ? 'อัตราพิเศษ'
                            : (invoices.dtype.toString() == 'KU')
                                ? getFormattedText('${invoices.pri}')
                                : '-',
                        flex: 1,
                        alignment: pw.Alignment.centerRight,
                        textAlign: pw.TextAlign.right,
                      ),
                      // buildCell(
                      //   text: (invoices.dis_list.toString() == '0.00')
                      //       ? getFormattedText(invoices.pri)
                      //       : getFormattedText(invoices.pvat_original),
                      //   flex: 1,
                      //   alignment: pw.Alignment.centerRight,
                      //   textAlign: pw.TextAlign.right,
                      // ),

                      buildCell(
                        text: getFormattedText('${invoices.pvat}'),
                        flex: 1,
                        alignment: pw.Alignment.centerRight,
                        textAlign: pw.TextAlign.right,
                      ),
                      buildCell(
                        text: getFormattedText(invoices.vat),
                        flex: 1,
                        alignment: pw.Alignment.centerRight,
                        textAlign: pw.TextAlign.right,
                      ),
                      buildCell(
                        text: getFormattedText(invoices.wht),
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
                        flex: 2,
                        alignment: pw.Alignment.centerRight,
                        textAlign: pw.TextAlign.right,
                      ),
                    ],
                  ),
                );
              }),
            ),

            // pw.Divider(color: PdfColors.grey),
            pw.Container(
              padding: const pw.EdgeInsets.fromLTRB(0, 4, 0, 0),
              alignment: pw.Alignment.centerRight,
              child: pw.Row(
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
                  pw.Spacer(flex: 6),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // SubTotal, Vat, Deduct, Sum_SubTotal, DisC, Total
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'รวมราคาสินค้า/Sub Total',
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800),
                              ),
                            ),
                            pw.Text(
                              '${nFormat.format(totalPvat)}',
                              // '${sum_pvat}',
                              // '$SubTotal',
                              style: pw.TextStyle(
                                  fontSize: font_Size,
                                  fontWeight: pw.FontWeight.bold,
                                  font: ttf,
                                  color: PdfColors.grey800),
                            ),
                          ],
                        ),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'ภาษีมูลค่าเพิ่ม/Vat',
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800),
                              ),
                            ),
                            pw.Text(
                              '${nFormat.format(totalVat)}',
                              // '${sum_vat}',
                              // '$Vat',
                              style: pw.TextStyle(
                                  fontSize: font_Size,
                                  fontWeight: pw.FontWeight.bold,
                                  font: ttf,
                                  color: PdfColors.grey800),
                            ),
                          ],
                        ),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'หัก ณ ที่จ่าย',
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800),
                              ),
                            ),
                            pw.Text(
                              '${nFormat.format(totalWht)}',
                              // '${sum_wht}',
                              // '$Deduct',
                              style: pw.TextStyle(
                                  fontSize: font_Size,
                                  fontWeight: pw.FontWeight.bold,
                                  font: ttf,
                                  color: PdfColors.grey800),
                            ),
                          ],
                        ),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'ยอดรวม',
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800),
                              ),
                            ),
                            pw.Text(
                              '${nFormat.format(totalBill)}',
                              // '$Sum_SubTotal',
                              style: pw.TextStyle(
                                  fontSize: font_Size,
                                  fontWeight: pw.FontWeight.bold,
                                  font: ttf,
                                  color: PdfColors.grey800),
                            ),
                          ],
                        ),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'ส่วนลด/Discount',
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800),
                              ),
                            ),
                            pw.Text(
                              '${nFormat.format(totalDis)}',
                              // '${sum_disamt}',
                              // '$DisC',
                              style: pw.TextStyle(
                                  fontSize: font_Size,
                                  fontWeight: pw.FontWeight.bold,
                                  font: ttf,
                                  color: PdfColors.grey800),
                            ),
                          ],
                        ),
                        pw.Divider(color: PdfColors.grey600),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'ยอดชำระ',
                                style: pw.TextStyle(
                                    fontSize: font_Size,
                                    fontWeight: pw.FontWeight.bold,
                                    font: ttf,
                                    color: PdfColors.grey800),
                              ),
                            ),
                            pw.Text(
                              '${nFormat.format(totalBill)}',
                              style: pw.TextStyle(
                                  fontSize: font_Size,
                                  fontWeight: pw.FontWeight.bold,
                                  font: ttf,
                                  color: PdfColors.grey800),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
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
                          //"${nFormat2.format(double.parse(Total.toString()))}";
                          '(~${convertToThaiBaht(totalBill)}~)',
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
                                  '${nFormat.format(totalBill)}',
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
            pw.SizedBox(height: 5 * PdfPageFormat.mm),
          ];
        },
        footer: (context) {
          return pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
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
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
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
                                  (ptser1.toString() == '2' ||
                                          ptser1.toString() == '5' ||
                                          ptser1.toString() == '6')
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
                                          ptser1.toString() == '6')
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
                                                ptser1.toString() == '1')
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
                      pw.Expanded(
                          flex: 1,
                          child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              // crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Text(
                                  'ลงชื่อ :',
                                  textAlign: pw.TextAlign.left,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                    color: Colors_pd,
                                  ),
                                ),
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
                                  '(......................................................)',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                    color: Colors_pd,
                                  ),
                                ),
                                pw.Text(
                                  'วันที่/Date...........................................',
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
                                  'ลงชื่อ : ',
                                  textAlign: pw.TextAlign.left,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                    color: Colors_pd,
                                  ),
                                ),
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
                                  '(......................................................)',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                    color: Colors_pd,
                                  ),
                                ),
                                pw.Text(
                                  'วันที่/Date...........................................',
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
                                if (ptser1.toString() == '6')
                                  pw.Container(
                                    child: pw.BarcodeWidget(
                                        data:
                                            '|$selectedValue_bank_bno\r${cFinn.replaceAll('-', '')}\r${DateFormat('ddMM').format(DateTime.parse(End_Bill_Paydate))}$YearQRthai\r${totalBill_QR}',
                                        barcode: pw.Barcode.qrCode(),
                                        width: 55,
                                        height: 55),
                                  ),
                                if (ptser1.toString() == '5')
                                  pw.BarcodeWidget(
                                      data: generateQRCode(
                                          promptPayID:
                                              "$selectedValue_bank_bno",
                                          amount: double.parse('$totalBill')),
                                      barcode: pw.Barcode.qrCode(),
                                      width: 55,
                                      height: 55),
                                if (img1.toString() != '')
                                  if (ptser1.toString() == '2')
                                    pw.Image(
                                      (netImage_QR[0]),
                                      height: 55,
                                      width: 55,
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
                        'พิมพ์เมื่อ : $date',
                        // textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize: 7.00,
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
                          fontSize: 7.00,
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
