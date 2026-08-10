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

class Pdfgen_Agreement_Nichada5 {
//////////---------------------------------------------------->( **** เอกสารสัญญาเช่าห้องพัก  Nichada)

  static void exportPDF_Agreement_Nichada5(
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
      FormName1_choice,
      FormName2_choice,
      FormName3_choice,
      FormName4_choice) async {
    final pdf = pw.Document();

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
    String thaiDate = DateFormat('d เดือน MMM', 'th').format(date);
    var nFormat = NumberFormat("#,##0.00", "en_US");
    var nFormat2 = NumberFormat("###0.00", "en_US");
    final iconImage =
        (await rootBundle.load('images/LOGO.png')).buffer.asUint8List();
    List netImage = [];
    Uint8List? resizedLogo = await getResizedLogo();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int pageCount = 1;
    String? base64Image_1 = preferences.getString('base64Image1');
    String base64Image_new1 = (base64Image_1 == null) ? '' : base64Image_1;
    ///////////////////////------------------------------------------------->
    String? PDF_bnos = preferences.getString('PDF_bno');
    String? PDF_banks = preferences.getString('PDF_bank');
    String? PDF_bnames = preferences.getString('PDF_bname');
///////////////////////------------------------------------------------->
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginBottom: 18.00,
          marginLeft: 18.00,
          marginRight: 18.00,
          marginTop: 18.00,
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
                  width: 280,
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
                pw.Container(
                  width: 180,
                  child: pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      if (TitleType_Default_Receipt_Name != null &&
                          TitleType_Default_Receipt_Name.toString().trim() !=
                              '')
                        pw.Text(
                          '[ $TitleType_Default_Receipt_Name ]',
                          maxLines: 1,
                          style: pw.TextStyle(
                            fontSize: font_Size,
                            font: ttf,
                            color: PdfColors.grey400,
                          ),
                        ),
                      // pw.Text(
                      //   'ใบเสนอราคา',
                      //   style: pw.TextStyle(
                      //     fontSize: 12.00,
                      //     fontWeight: pw.FontWeight.bold,
                      //     font: ttf,
                      //   ),
                      // ),
                      // pw.Text(
                      //   'ที่อยู่,\n1/1-8 ถ.รัตนโกสินทร์ ต.ศรีภูมิ อ.เมือง จ.เชียงใหม่ 50200',
                      //   textAlign: pw.TextAlign.right,
                      //   style: pw.TextStyle(
                      //       fontSize: 10.0, font: ttf, color: PdfColors.grey),
                      // ),
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
                        'วันที่ทำสัญญา :${Datex_text.text}',
                        // 'วันที่ทำสัญญา :____/________/____',
                        // '${DateFormat('วันที่ทำสัญญา : d เดือน MMM ปี ', 'th').format(DateTime.now())}${DateTime.now().year + 543}',
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
              ],
            ),
            pw.Divider(height: 2),
            // pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
          ]);
        },
        build: (context) {
          return [
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'สัญญาเช่า',
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
            pw.Row(children: [
              pw.Expanded(
                child: pw.Text(
                  'เลขที่ $Get_Value_cid',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontSize: font_Size,
                    font: ttf,
                    color: Colors_pd,
                  ),
                ),
              ),
              pw.Text(
                'ทำที่ $bill_name',
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  fontSize: font_Size,
                  font: ttf,
                  color: Colors_pd,
                ),
              ),
            ]),
            pw.Row(children: [
              pw.Expanded(
                child: pw.Text(
                  '',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontSize: font_Size,
                    font: ttf,
                    color: Colors_pd,
                  ),
                ),
              ),
              pw.Text(
                'วันที่ ${Datex_text.text}',
                // 'ทำที่ $renTal_name ',
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  fontSize: font_Size,
                  font: ttf,
                  color: Colors_pd,
                ),
              ),
            ]),
            pw.SizedBox(height: 5 * PdfPageFormat.mm),
            pw.Row(
              children: [
                pw.Text(
                  'สัญญาฉบับนี้ทำขึ้นระหว่าง',
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
                        width: 0.1, // Underline thickness
                      ))),
                      child: pw.Text(
                        "$bill_name",
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
                        width: 0.1, // Underline thickness
                      ))),
                      child: pw.Text(
                        (FormName1_choice == null ||
                                FormName1_choice.toString() == '')
                            ? ' '
                            : "$FormName1_choice",
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
                  'กรรมการผู้มีอำนาจ ',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontSize: font_Size,
                    font: ttf,
                    color: Colors_pd,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Row(
              children: [
                pw.Text(
                  'สำนักงานแห่งใหญ่เลขที่',
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
                        width: 0.1, // Underline thickness
                      ))),
                      child: pw.Text(
                        "$bill_addr",
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
                  'ต่อไปในสัญญานี้เรียกว่า "ผู้ให้เช่า" ฝ่ายหนึ่ง กับ',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontSize: font_Size,
                    font: ttf,
                    color: Colors_pd,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Row(
              children: [
                pw.Expanded(
                    flex: 2,
                    child: pw.Container(
                      decoration: pw.BoxDecoration(
                          border: pw.Border(
                              bottom: pw.BorderSide(
                        color: Colors_pd,
                        width: 0.1, // Underline thickness
                      ))),
                      child: pw.Text(
                        (_verticalGroupValue.toString() == 'องค์กร/นิติบุคคล')
                            ? "$Form_bussshop "
                            : "$Form_bussscontact",
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
                  'ผู้ถือบัตรประจำตัวบัตรประชาชนเลขที่',
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
                        width: 0.1, // Underline thickness
                      ))),
                      child: pw.Text(
                        "$Form_tax",
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
                  'อยู่บ้านเลขที่',
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
                        width: 0.1, // Underline thickness
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
                  'ซึ่งต่อไปนี้',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontSize: font_Size,
                    font: ttf,
                    color: Colors_pd,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Text(
              'เรียกว่า "ผู้เช่า" อีกฝ่ายหนึ่ง คู่สัญญาทั้งสองฝ่ายตกลงทำสัญญาเช่ามีใจความดังต่อไปนี้',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Text(
              'สถานที่เช่า',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Row(
              children: [
                pw.Text(
                  ' ' * 12 +
                      'ข้อ1. ผู้เช่าตกลงเช่าและผู้ให้เช่าตกลงให้เช่า ห้องเลขที่',
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
                        width: 0.1, // Underline thickness
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
                  'ณ เลขที่ 35/2 หมู่3 ถนนสามัคคี ตำบลบางตลาด',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontSize: font_Size,
                    font: ttf,
                    color: Colors_pd,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Row(
              children: [
                pw.Text(
                  'อำเภอปากเกร็ด จังหวัด นนทบุรี 11120 มีกำหนดระยะเวลาเช่า ',
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
                        width: 0.1, // Underline thickness
                      ))),
                      child: pw.Text(
                        "$Form_period",
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
                      ? 'วัน '
                      : (Form_rtname.toString() == 'รายเดือน')
                          ? 'เดือน '
                          : (Form_rtname.toString() == 'รายปี')
                              ? 'ปี '
                              : '$Form_rtname ',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontSize: font_Size,
                    font: ttf,
                    color: Colors_pd,
                  ),
                ),
                pw.Text(
                  'นับตั้งแต่วันที่',
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
                        width: 0.1, // Underline thickness
                      ))),
                      child: pw.Text(
                        "$Form_sdate",
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
                  'ถึง',
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
                        width: 0.1, // Underline thickness
                      ))),
                      child: pw.Text(
                        "$Form_ldate",
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
            pw.Text(
              'เงื่อนไข',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Text(
              'ผู้เช่าและผู้ให้เช่าตกลงกันดังต่อไปนี้',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Row(
              children: [
                pw.Text(
                  ' ' * 12 +
                      'ข้อ2. ผู้เช่าตกลงชำระค่าเช่าและค่าตอบแทนให้แก่ผู้ให้เช่าเป็นรายเดือนในอัตราเดือนละ',
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
                        width: 0.1, // Underline thickness
                      ))),
                      child: pw.Text(
                        (quotxSelectModels
                                    .where((e) => e.expser.toString() == '1')
                                    .length ==
                                0)
                            ? '0.00 บาท (~${convertToThaiBaht(0.00)}~)'
                            : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '1').map((e) => e.amt != null ? double.parse(e.amt.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ' +
                                '(~${convertToThaiBaht(double.parse('${quotxSelectModels.where((e) => e.expser.toString() == '1').map((e) => e.amt != null ? double.parse(e.amt.toString()) : 0.00).fold(0.00, (a, b) => a + b)}'))}~)',
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
                  'ทั้งนี้ผู้เช่าได้ทำการจองห้องเช่าของผู้ให้เช่าภายในเดือน',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontSize: font_Size,
                    font: ttf,
                    color: Colors_pd,
                  ),
                ),
                pw.Container(
                  width: 50,
                  height: 15,
                  decoration: pw.BoxDecoration(
                      border: pw.Border(
                          bottom: pw.BorderSide(
                    color: Colors_pd,
                    width: 0.1, // Underline thickness
                  ))),
                  child: pw.Text(
                    '',
                    // 'xx-xx-xxxx',
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
                  'ผู้ให้เช่าซึ่งให้ส่วนลดพิเศษ เป็นจำนวน',
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
                        width: 0.1, // Underline thickness
                      ))),
                      child: pw.Text(
                        (quotxSelectModels
                                    .where((e) => e.expser.toString() == '1')
                                    .length ==
                                0)
                            ? '0.00 บาท (~${convertToThaiBaht(0.00)}~)'
                            : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '1').map((e) => e.amt != null ? double.parse(e.amt.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ' +
                                '(~${convertToThaiBaht(double.parse('${quotxSelectModels.where((e) => e.expser.toString() == '1').map((e) => e.amt != null ? double.parse(e.amt.toString()) : 0.00).fold(0.00, (a, b) => a + b)}'))}~)',
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
                  '/ ต่อเดือน',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontSize: font_Size,
                    font: ttf,
                    color: Colors_pd,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Text(
              'ตลอดระยะเวลาการเช่าตามสัญญาฉบับนี้',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Row(
              children: [
                pw.Text(
                  ' ' * 12 +
                      'ดังนั้น สุทธิผู้เช่าต้องชำระค่าเช่าและค่าตอบแทนให้แก่ผู้ให้เช่าเป็นรายเดือน ในอัตราเดือนละ',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontSize: font_Size,
                    font: ttf,
                    color: PdfColors.red600,
                  ),
                ),
                pw.Expanded(
                    flex: 1,
                    child: pw.Container(
                      decoration: pw.BoxDecoration(
                          border: pw.Border(
                              bottom: pw.BorderSide(
                        color: Colors_pd,
                        width: 0.1, // Underline thickness
                      ))),
                      child: pw.Text(
                        (quotxSelectModels
                                    .where((e) => e.expser.toString() == '1')
                                    .length ==
                                0)
                            ? '0.00 บาท (~${convertToThaiBaht(0.00)}~)'
                            : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '1').map((e) => e.amt != null ? double.parse(e.amt.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ' +
                                '(~${convertToThaiBaht(double.parse('${quotxSelectModels.where((e) => e.expser.toString() == '1').map((e) => e.amt != null ? double.parse(e.amt.toString()) : 0.00).fold(0.00, (a, b) => a + b)}'))}~)',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          color: PdfColors.red600,
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
                  'โดยเริ่มชำระค่าเช่าของเดือนแรกในวันที่',
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
                      width: 70,
                      decoration: pw.BoxDecoration(
                          border: pw.Border(
                              bottom: pw.BorderSide(
                        color: Colors_pd,
                        width: 0.1, // Underline thickness
                      ))),
                      child: pw.Text(
                        "$Form_sdate",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          color: Colors_pd,
                          fontSize: font_Size - 0.3,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                        ),
                      ),
                    )),
                pw.Text(
                  '(ผู้เช่าตกลงชำระค่าน้ำ ค่าไฟในระยะเวลาตั้งแต่วันที่',
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
                      width: 70,
                      height: 15,
                      decoration: pw.BoxDecoration(
                          border: pw.Border(
                              bottom: pw.BorderSide(
                        color: Colors_pd,
                        width: 0.1, // Underline thickness
                      ))),
                      child: pw.Text(
                        " ",
                        // 'xx-xx-xxxx',
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
                  " - ",
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
                      width: 70,
                      height: 15,
                      decoration: pw.BoxDecoration(
                          border: pw.Border(
                              bottom: pw.BorderSide(
                        color: Colors_pd,
                        width: 0.1, // Underline thickness
                      ))),
                      child: pw.Text(
                        " ",
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
                  'ซึ่งเป็นช่วงระยะเวลาในการต่อ',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontSize: font_Size,
                    font: ttf,
                    color: Colors_pd,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            // pw.Paragraph(
            //   padding: pw.EdgeInsets.fromLTRB(0, 0, 0, 0),
            //   text:
            //       'ผู้เข่าตกลงจะชำระเงินค่าเข่าดังกล่าวล่วงหน้าทุกเดือนโดยกำหมดชำระทุกวันที่ 5 ของเดือนถัดไป จนครบกำหนดระยะยะเวลาตามสัญญาเช่า หากผู้เช่าผิดนัดชำระค่าเช่า ผู้เข่า\nชินขอมชำระก่าเบี้ยปรับ วันละ 300 บาท นับตั้งแต่วันผิดนัล จนถึงวันที่ผู้เช่าชำระค่าเช่าและค่าปรับจนครบถ้วน',
            //   style: pw.TextStyle(
            //     fontSize: font_Size,
            //     font: ttf,
            //     color: Colors_pd,
            //   ),
            // ),
            pw.Text(
              'เติมห้องเช่า)ผู้เช่าตกลงจะชำระเงินค่าเช่าดังกล่าวล่วงหน้าทุกเดือนโดยกำหนดชำระทุกวันที่  5  ของเดือนถัดไป  จนครบกำหนดระยะเวลาตามสัญญาเช่า หากผู้เช่าผิดนัดชำระ\nค่าเช่า ผู้เช่ายินยอมชำระค่าเบี้ยปรับ วันละ 300 บาท นับตั้งแต่วันผิดนัด จนถึงวันที่ผู้เช่าชำระค่าเช่าและค่าปรับจนครบถ้วน',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            // pw.Paragraph(
            //   padding: pw.EdgeInsets.fromLTRB(0, 0, 0, 0),
            //   text:
            //       'ทั้งนี้ ผู้เช่าตกลงเป็นผู้ดำเนินการปรับปรุง ซ่อมแชม ท้องเช่าด้วยตนเอง และตกลงเป็นผู้ออกค่าใช้จ่ายต่างๆด้วยตัวเองทั้งสิ้น พร้อมทั้งผู้เข่ามีหน้าที่ส่งแบบแปลนการปรับปรุง ซ่อมแรม ห้องเช่าให้แก่ผู้ให้เข่าทราบ และเป็นผู้ดำเนินการขออนุญาตก่อสร้างตามกฎหมายด้วยตนเอง',
            //   style: pw.TextStyle(
            //     fontSize: font_Size,
            //     font: ttf,
            //     color: Colors_pd,
            //   ),
            // ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Text(
              ' ' * 12 +
                  'ทั้งนี้ผู้เช่าตกลงเป็นผู้ดำเนินการปรับปรุง ซ่อมแชม  ห้องเช่าด้วยตนเอง  และตกลงเป็นผู้ออกค่าใช้จ่ายต่างๆด้วยตัวเองทั้งสิ้น พร้อมทั้งผู้เช่ามีหน้าที่ส่งแบบแปลนการ\n ปรับปรุง ซ่อมแซม  ห้องเช่าให้แก่ผู้ให้เช่าทราบ และเป็นผู้ดำเนินการขออนุญาตก่อสร้างตามกฎหมายด้วยตนเอง',
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
                  'หากเกิดความเสียหายแก่ห้องเช่า และหรือโครงสร้างอื่นๆ อันเนื่องจากการปรับปรุง ซ่อมแชมห้องเช่าของผู้เช่า ผู้เช่าต้องรับผิดชดใช้ค่าเสียหายให้แก่ผู้ให้เช่า ',
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
                  'ข้อ3. ในการชำระค่าเช่าและหรือเบี้ยปรับผู้เช่าจะต้องชำระโดยวิธีการ โอนผ่านบัญชีธนาคารดังนี้',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 5 * PdfPageFormat.mm),
            pw.Text(
              ' ' * 20 + 'ชื่อบัญชี ${PDF_bnames}',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Text(
              ' ' * 20 + 'ธนาคาร ${PDF_banks}',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Text(
              ' ' * 20 + 'บัญชีเลขที่ ${PDF_bnos}',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 5 * PdfPageFormat.mm),
            pw.Row(
              children: [
                pw.Text(
                  ' ' * 12 +
                      'ข้อ4. ผู้เช่าตกลงวางเงินมัดจำให้แก่ผู้ให้เช่าเป็นเงิน',
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
                        width: 0.1, // Underline thickness
                      ))),
                      child: pw.Text(
                        (quotxSelectModels
                                    .where((e) => e.expser.toString() == '2')
                                    .length ==
                                0)
                            ? '0.00 บาท (~${convertToThaiBaht(0.00)}~)'
                            : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '2').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ' +
                                '(~${convertToThaiBaht(double.parse('${quotxSelectModels.where((e) => e.expser.toString() == '2').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b)}'))}~)',
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
                  'เพื่อประกันความเสียหาย',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontSize: font_Size,
                    font: ttf,
                    color: Colors_pd,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),

            pw.Text(
              ' ' * 12 +
                  'ข้อ5. ในกรณีที่ผู้เช่าผิดนัดชำระค่าเช่าพร้อมเบี้ยปรับเกินหนึ่งเดือน ผู้เช่ายินยอมให้ผู้ให้เช่าริบประกันที่ผู้เช่าวางให้แก่ผู้ให้เช่าในข้อ 4 ได้ทันทีโดยไม่ต้องบอกกล่าวต่อ\nผู้เช่าแต่อย่างใด  ในกรณีนี้ไม่ถือว่าเป็นการเลิกสัญญาแต่อย่างใด  และให้ถือว่าเป็นสิทธิ์ของผู้ให้เช่าฝ่ายเดียวที่จะบอกเลิก หากผู้ให้เช่ามิได้ยกเลิกสัญญานี้ผู้เช่าจะต้องชำระเงิน\nประกันแก่ผู้ให้เช่าใหม่ภายใน 30 วันนับตั้งแต่พ้นกำหนดสองเดือนที่ผู้เช่าไม่ชำระค่าเช่า',
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
                  'ข้อ6. หากผู้เช่าผิดนัดตามข้อ  5  ผู้ให้เช่าได้บอกเลิกสัญญา  ให้สัญญาสิ้นสุดลงทันที่. และผู้เช่าจะต้องขนย้ายทรัพย์สินและบริวารออกจากสถานที่เช่าพร้อมสละสิทธิ์\nการครอบครองสถานที่เช่าภายใน 7  วัน โดยผู้เช่ารับภาระค่าใช้จ่ายทั้งหมดและคืนทรัพย์ที่เช่าในสภาพที่เรียบร้อยดังเดิมในสภาพแรกรับตามภาพถ่ายห้องพักและอุปกรณ์ภาย\nในห้องพัก   เมื่อผู้เช่าย้ายเข้าผู้เช่าตกลงยินยอมให้ผู้เช่าใช้สิทธิ์ที่จะปิดกันประตูหรือทางเข้าออกหรือกระทำด้วยประการใด ๆ ในสถานที่เช่า เพื่อมิให้ผู้ให้ผู้เช่าและบริวารเข้าไป\nไร้ประโยชน์ในสถานที่เช่าหรือทรัพย์สินใด  ๆ ในสถานที่เช่า ทั้งนี้ผู้เช่ายินยอมให้ผู้ให้เช่าเข้าไปขนย้ายทรัพย์สินของผู้เช่าและบริวารที่อยู่ในสถานที่เช่า  ออกไปเก็บรักษาไว้ในที่\nที่ผู้ให้เช่าเห็นว่าสมควรได้ทันที   โดยถือว่าเป็นการกระทำเพื่อประโยชน์ของผู้เช่าและบริวารและผู้เช่ายินยอมเป็นผู้ชำระ   ค่าขนย้ายค่าเก็บรักษาและค่าใช้จ่ายทั้งปวงที่เกิดขึ้น\nในการนั้นเองทั้งสิ้น  โดยผู้ให้เช่าไม่จำเป็นต้องได้รับความยินยอมจากผู้เช่าหรือบุคคอื่นอีกแต่อย่างใจ  ผู้เช่ายินยอมให้ผู้ให้เช่าดำเนินการทั้งปวงดังกล่าวข้างต้นแล้วโดยสมัครใจ\nและไม่เพิกถอนความยินยินยอมนั้นอย่างเด็ดขาดและการกระทำเช่นนั้นมีให้ถือว่าเป็นความผิดทางอาญาหรือทางแพ่งแต่อย่างใด',
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
                  'ข้อ7. เงินประกันการผิดสัญญาตามข้อ  4  ผู้ให้เช่าจะคืนให้ผู้เช่าต่อเมื่อผู้เช่าได้ปฏิบัติตามสัญญานี้ครบถ้วน ไม่ว่าข้อหนึ่งข้อใดและได้ส่งมอบสถานที่เช่าคืนให้แก่ผู้ให้\nเช่าในสภาพเรียบร้อยดังเดิมในสภาพแรกรับเมื่อผู้เช่าย้ายเข้า   โดยผู้ให้เช่าจะทำการคืนเงินประกันการผิดสัญญาตามข้อ 4  ให้แก่ผู้เช่าภายใน 30 วันนับตั้งแต่วันที่ตัวแทนของ\nผู้เช่าไปทำการตรวจสอบสภาพห้องภายหลังสิ้นสุดสัญญา',
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
                  'ข้อ8.เมื่อครบกำหนดระยะเวลาการเช่าตาม ข้อ1. แล้ว หากผู้เช่าประสงค์จะเช่าต่อ ผู้เช่าต้องแจ้งให้ผู้ให้เช่าทราบล่วงหน้าเป็นหนังสือไม่น้อยกว่า 1 เดือน โดยถือเป็น\nสิทธิ์ของผู้ให้เช่าแต่     ฝ่ายเดียว ที่จะยินยอมให้ผู้เช่าเช่าต่อหรือไม่  และหากผู้ให้เช่าประสงค์ให้ผู้เช่าเช่าต่อ ทั้งผู้เช่าและผู้ให้เช่าจะต้องทำสัญญาเช่ากันใหม่เป็นหนังสือและกำ\nหนดอัตราค่าเช่าใหม่',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.Text(
              ' ' * 12 +
                  'เมื่อครบกำหนดระยะเวลาการเช่าตามข้อ  1. แล้วผู้เข่าต้องรีบดำเนินการส่งมอบทรัพย์สินที่เช่าคืนแก่ผู้ให้เช่า  โดยครบถ้วนตามสภาพแรกเข้าในขณะที่สัญญาฉบับนี้\nสิ้นสุดลง หรือเลิกกันโดยฉับพลันทันที หากผู้เช่าและบริวารเพิกเฉยไม่ยอมออกไปจากทรัพย์สินที่เช่าโดยฉับพลันทันทันที จะถือว่าผู้เช่าอยู่ต่อไปโดยละเมิด และจะต้องชดใช้ค่า\nเสียหายให้แก่ผู้ให้เช่าเป็นรายวัน วันละ 550 บาท (ห้าร้อยห้าสิบบาทถ้วน) ตลอดเรื่อยไปจนกว่าผู้เช่าและบริวารจะออกไปจากทรัพย์สินที่เช่า',
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
                  'ข้อ9. ผู้เช่าตกลงจะเป็นผู้ชำระค่าอุปโภค  เช่นแต่ไม่จำกัดถึงค่าน้ำประปา ค่าไฟฟ้า และละค่าอินเตอร์เน็ต เอง และผู้ให้เช่าสัญญาว่าจะไม่ค้างชำระค่าอุปโภคดังกล่าว\nเกินกว่าหนึ่งเดือนนับตั้งแต่วันที่ได้รับแจ้งหนี้ ทั้งนี้หากผู้เช่าไม่ชำระค่าอุปโภค ดังกล่าวตามระยะเวลาที่กำหนดไว้ ผู้ให้เช่ามีสิทธิ์ที่จะระงับการบริการอุปโภคดังกล่าวได้โดยไม่จำ\nเป็นต้องแจ้งให้ผู้เช่าทราบล่วงหน้าแต่อย่างใด',
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
                  'ข้อ10. ผู้เช่าจะไม่กระทำและ/หรือใช้สถานที่เช่าในการใด ๆ อันเป็นความผิดกฎหมายหรือนำสิ่งที่ผิดกฎหมายและหรือวัสดุที่เป็นเชื้อเพลิงมาสู่สถานที่เช่า',
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
                  'ข้อ11. ผู้เข่าตกลงจะรักษาทรัพย์สินที่เช่าด้วยค่าใช้จ่ายของตนเองมิให้ชำรุดทรุดโทรมไปกว่าเดิมจากสภาพทรัพย์ที่รับมอบในวันแรกเข้าพักอาศัย  และไม่ยกการเสื่อม\nโทรมโดยธธรรมชาติของทรัพย์นั้นเป็นข้อโต้แย้งในการผลักภาระต่อความรับผิดชอบต่อผู้ให้เช่า ผู้เช่าจะต้องดำเนินการบำรุงรักษาทรัพย์เช่าต่างๆ เช่นเครื่องปรับอากาศ จะต้อง\nล้างทั้งคอยล์ร้อนและคอยล์เย็น อย่างต่ำทุก 6 เดือน เติมน้ำยาเครื่องปรับอากาศ  ตามระยะตามความเหมาะสม  ผู้เช่าต้องดูแลรักษารับผิดชอบระบบท่อน้ำทิ้งทุกจุด  และห้าม\nมิให้ทิ้งเศษขยะสิ่งปฏิกูล หากผู้ให้เช่าเข้าตรวจและพบว่าท่าน     ละเมิดข้อดังกล่าวมีคำปรับความเสียหายเริ่มต้นที่  3,000  บาท และท่านต้องรับผิดชอบความเสียหายทั้งหมด\nหากเป็นสาหตุให้ระบบบท่อตันซึ่งส่งผลกระทบต่อห้องพักอาศัยอื่นหรืออาคาร เป็นต้น',
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
                  'ภายหลังสัญญาฉบับนี้สิ้นสุดลงและเมื่อทำการย้ายออก  ผู้เช่าต้องชำระค่าทำความสะอาดห้องเป็นเงิน  จำนวน 1,500บาท  (หนึ่งพันห้าร้อยบาทถ้วน)  ให้แก่ผู้ให้เช่า',
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
                  'ข้อ12. ถ้าผู้เช่ามีความประสงค์จะดัดแปลงหรือเพิ่มเติมสิ่งใดในสถานที่เช่า  ผู้เช่าจะต้องได้รับอนุญาตจากผู้ให้เช่าเป็นหนังสือก่อน เมื่อสัญญาเช่าสิ้นสุดลง ผู้เช่าจะส่ง\nมอบอาคารคืนในสภาพที่เรือบร้อยดังเดิมในสภาพแรกรับ  เมื่อผู้เช่าย้ายเข้าโดยจะต้องรื้อถอน สิ่งก่อสร้างหรือสิ่งต่อเติมที่ติดกับตัวอาคารโดยผู้เช่าจะต้องรับภาระค่าใช้จ่ายเอง\nทั้งสิ้น  ทั้งนี้ผู้ให้เช่ามีสิทธิเรียกค่าเสียหายเพิ่มอันเกิดจากความเสียหายใดๆจากการรื้อถอนดังกล่าวจากผู้เช่า',
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
                  'ข้อ13. หากเกิดอัคคีภัยขึ้นในสถานที่เช่าไม่ว่าจะเป็นทั้งหมดหรือบางส่วน และไม่ว่าเป็นเพราะการกระทำหรือความประมาทเลินเล่อของผู้เช่า  และ/หรือบริวารของผู้\nเช่าก็ตาม ผู้เช่ายังคงต้องชำระค่าเช่าให้แก่ผู้ให้เช่า  จนกว่าจะครบกำหนดสัญญาเช่าดั่งที่ระบุในข้อ1. ไม่ว่าผู้เช่าจะพักอาศัยหรือไม่ก็ตาม และทำการซ่อมแซมความเสียหายโดย\nผู้เช่ารับภารับการะค่าใช้จ่ายทั้งหมดและส่งมอบสถานที่เช่าคืนให้แก่ผู้ให้เช่าเป็นที่เรียบร้อยดั่งที่ระบุใน ข้อ11. และข้อ12.',
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
                  'ข้อ14. ถ้าสถานที่เข่าเกิดอัคคีภัยขึ้นไม่ว่าจะเป็นทั้งหมดหรือบางส่วนมิว่าเกิดจากการกระทำหรือความประมาทเลินเล่อของผู้ให้เข่า   หรือไม่ผู้ให้เข้าไม่ต้องรับผิดชอบ\nต่อทรัพย์ของผู้เข่า และผู้เข่าจะเรียกร้องค่าเสียหายและ/หรือค่าใช้จ่ายและ/หรือค่าตอบแทนใด ๆ จากผู้ให้เช่ามิได้',
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
                  'ข้อ15. ผู้เช่ายอมให้ผู้ให้เช่าหรือตัวแทนของผู้ให้เช่าเข้าตรวจตราดูแลสถานที่ที่เช่าได้ในเวลาอันสมควร โดยผู้ให้เช่าบอกกล่าวแก่ผู้เช่าไม่น้อยกว่า 1 วัน',
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
                  'ข้อ16. ผู้ให้เช่าไม่อนุญาตให้ผู้เช่าเช่าช่วงและไม่อนุญาตให้ผู้เช่าพาผู้อื่นที่ไม่ปรากฎชื่อ ในสัญญานี้เข้าพักโดยมิได้รับอนุญาตล่วงหน้าเป็นลายลักษณ์อักษรจากผู้ให้เช่า',
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
                  'ข้อ17. สัญญานี้มีผลบังคับใช้ทันทีเมื่อผู้เช่าและผู้ให้เช่าลงนามในสัญญาฉบับนี้ไม่ว่าผู้เช่าจะเข้าพักอาศัยหรือไม่ก็ตาม',
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
                  'ข้อ18. ถ้าผู้เช่าประพฤติผิดสัญญาไม่ว่าข้อหนึ่งข้อใด  หรือกระทำผิดวัตถุประสงค์ของสัญญานี้ข้อหนึ่งข้อใด  ผู้เช่ายินยอมให้ผู้ให้เช่าทรงไว้ซึ่งสิทธิ์ที่จะบอกเลิกสัญญา\nพร้อมทั้งยึดครองและ  ใส่กุญแจสถานที่เช่าโดยพลัน โดยมิต้องบอกกล่าวล่วงหน้าแต่อย่างใด  และผู้เช่ายินยอมให้ผู้ให้เช่ามีสิทธิที่จะยึดหน่วงทรัพย์สินของผู้เช่าซึ่งนำมาสู่สถาน\nที่เช่าได้ทั้งหมดโดยผู้เช่าจะไม่โต้แย้งใด ๆ ทั้งสิ้น จนกว่าผู้เช่าจะได้ชำระหนี้สินทั้งปวงแก่ผู้ให้ผู้ให้เช่าครบถ้วนแล้ว',
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
                  'หากผู้เช่าประพฤติผิดสัญญาไม่ว่าข้อหนึ่งข้อใดอันเป็นเหตุทำให้ผู้ให้เช่าต้องได้รับความเสียหายอย่างหลีกเลื่องไม่ได้ผู้เช่าต้องรับผิดตามข้อกำหนดในสัญญาฉบับนี้และ\nรับผิดตามกฎหมาย ประกอบกับกับผู้เช่าต้องรับผิดชดใช้ค่าเสียหายแก่ผู้ให้เช่าทั้งหมด ค่าใช้จ่ายในกาดำเนินคดีรวมถึงค่าทนายความด้วยตนเองทั้งสิ้น',
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
                  'ข้อ19. ในการที่ผู้เช่าประพฤติผิดสัญญาความ ข้อ5. และหรือ ข้อ6. และหรือ ข้อ18. ผู้เช่ายินยอมชำระค่าปรับพิเศษเป็นค่าเสียหายจากการเสียโอกาสเปิดเช่าให้ผู้เช่า\nรายอื่น ให้แก่ผู้ให้เช่าเป็นจำนวนเงิน 3,000 บาท นอกเหนือจากการให้ผู้ให้เช่าริบเงินประกันและชำระค่าเช่าค้างชำระรวมค่าปรับรายวันจากผิดนัด',
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
                  ' ข้อ20. การที่ผู้ให้เช่าละเว้นไม่บังคับใช้เงื่อนไขใดในสัญญานี้จะไม่ถือว่าผู้ให้เช่าสละสิทธิ์ในการบังคับใช้เงื่อนไขนั้นซึ่งอันเป็นสาระสำคัญแห่งสัญญานี้แต่อย่าง',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Text(
              'สถานที่ส่งเอกสาร',
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
                  'ทั้งผู้เช่าและผู้ให้เช่าตกลงกันว่าสถานที่ส่งเอกสารมีผลทางกฎหมาย คือที่อยู่ที่ตามบัตรประจำตัวประชาชนดังที่ไห้ไว้ในสัญญาฉบับนี้ และให้ส่งโดยทางไปรษณีย์ลงทะ\nเบียนถือว่าผู้รับได้รับโดยสมบูรณ์ไม่ว่าจะได้รับหรือไม่ก็ตาม หรืออีกช่องทางหนึ่งคือส่งในจดหมายอิเล็กทรอนิค ถือว่าผู้รับได้รับโดยสมบูรณ์ไม่ว่าจะอ่านหรือไม่ก็ตาม ',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 10 * PdfPageFormat.mm),
            pw.Text(
              ' ' * 12 +
                  'สัญญานี้ทำขึ้นเป็นสองฉบับมีข้อความถูกต้องตรงกัน  คู่สัญญาทั้งสองฝ่ายได้อ่านและเจ้าใจข้อความในสัญญานี้โดยตลอดแล้ว  จึงลงลายมือไว้เป็นสำคัญต่อหน้าพยาน',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 10 * PdfPageFormat.mm),
            pw.Row(children: [
              pw.Expanded(
                  flex: 1,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'ลงชื่อ___________________________ผู้ให้เช่า    ',
                        textAlign: pw.TextAlign.justify,
                        style: pw.TextStyle(
                          color: Colors_pd,
                          fontSize: font_Size,
                          font: ttf,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 2 * PdfPageFormat.mm),
                      pw.Text(
                        (FormName1_choice == null ||
                                FormName1_choice.toString() == '')
                            ? '(___________________________) '
                            : '( $FormName1_choice ) ',
                        textAlign: pw.TextAlign.justify,
                        style: pw.TextStyle(
                          color: Colors_pd,
                          fontSize: font_Size,
                          font: ttf,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 2 * PdfPageFormat.mm),
                      pw.Text(
                        'วันที่____/________/____',
                        textAlign: pw.TextAlign.justify,
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
                      pw.Text(
                        'ลงชื่อ___________________________ผู้เช่า    ',
                        textAlign: pw.TextAlign.justify,
                        style: pw.TextStyle(
                          color: Colors_pd,
                          fontSize: font_Size,
                          font: ttf,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 2 * PdfPageFormat.mm),
                      pw.Text(
                        (_verticalGroupValue.toString() == 'องค์กร/นิติบุคคล')
                            ? "( $Form_bussscontact )"
                            : "( $Form_bussshop )",
                        // (FormName2_choice == null ||
                        //         FormName2_choice.toString() == '')
                        //     ? '(___________________________) '
                        //     : '( $FormName2_choice ) ',
                        textAlign: pw.TextAlign.justify,
                        style: pw.TextStyle(
                          color: Colors_pd,
                          fontSize: font_Size,
                          font: ttf,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 2 * PdfPageFormat.mm),
                      pw.Text(
                        'วันที่____/________/____',
                        textAlign: pw.TextAlign.justify,
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
            pw.SizedBox(height: 10 * PdfPageFormat.mm),
            pw.Row(children: [
              pw.Expanded(
                  flex: 1,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'ลงชื่อ___________________________พยาน    ',
                        textAlign: pw.TextAlign.justify,
                        style: pw.TextStyle(
                          color: Colors_pd,
                          fontSize: font_Size,
                          font: ttf,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 2 * PdfPageFormat.mm),
                      pw.Text(
                        (FormName3_choice == null ||
                                FormName3_choice.toString() == '')
                            ? '(___________________________) '
                            : '( $FormName3_choice ) ',
                        textAlign: pw.TextAlign.justify,
                        style: pw.TextStyle(
                          color: Colors_pd,
                          fontSize: font_Size,
                          font: ttf,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 2 * PdfPageFormat.mm),
                      pw.Text(
                        'วันที่____/________/____',
                        textAlign: pw.TextAlign.justify,
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
                      pw.Text(
                        'ลงชื่อ___________________________พยาน    ',
                        textAlign: pw.TextAlign.justify,
                        style: pw.TextStyle(
                          color: Colors_pd,
                          fontSize: font_Size,
                          font: ttf,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 2 * PdfPageFormat.mm),
                      pw.Text(
                        (FormName4_choice == null ||
                                FormName4_choice.toString() == '')
                            ? '(___________________________) '
                            : '( $FormName4_choice ) ',
                        textAlign: pw.TextAlign.justify,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 2 * PdfPageFormat.mm),
                      pw.Text(
                        'วันที่____/________/____',
                        textAlign: pw.TextAlign.justify,
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
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
          ];
        },
        footer: (context) {
          return pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              if (context.pageNumber < 3)
                pw.Row(children: [
                  pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'ลงชื่อ___________________________ผู้ให้เช่า    ',
                            textAlign: pw.TextAlign.justify,
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
                          pw.Text(
                            'ลงชื่อ___________________________ผู้เช่า    ',
                            textAlign: pw.TextAlign.justify,
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
              pw.Align(
                alignment: pw.Alignment.bottomRight,
                child: pw.Text(
                  'หน้า ${context.pageNumber} / ${context.pagesCount} ',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontSize: 10,
                    font: ttf,
                    color: Colors_pd,
                    // fontWeight: pw.FontWeight.bold
                  ),
                ),
              )
            ],
          );
        },
      ),
    ); ///////////////////////------------------------------------------------->

    pageCount++;
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4.copyWith(
        marginBottom: 18.00,
        marginLeft: 18.00,
        marginRight: 18.00,
        marginTop: 18.00,
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
                width: 280,
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
              pw.Container(
                width: 180,
                child: pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    if (TitleType_Default_Receipt_Name != null &&
                        TitleType_Default_Receipt_Name.toString().trim() != '')
                      pw.Text(
                        '[ $TitleType_Default_Receipt_Name ]',
                        maxLines: 1,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: PdfColors.grey400,
                        ),
                      ),
                    // pw.Text(
                    //   'ใบเสนอราคา',
                    //   style: pw.TextStyle(
                    //     fontSize: 12.00,
                    //     fontWeight: pw.FontWeight.bold,
                    //     font: ttf,
                    //   ),
                    // ),
                    // pw.Text(
                    //   'ที่อยู่,\n1/1-8 ถ.รัตนโกสินทร์ ต.ศรีภูมิ อ.เมือง จ.เชียงใหม่ 50200',
                    //   textAlign: pw.TextAlign.right,
                    //   style: pw.TextStyle(
                    //       fontSize: 10.0, font: ttf, color: PdfColors.grey),
                    // ),
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
                      'วันที่ทำสัญญา :${Datex_text.text}',
                      // 'วันที่ทำสัญญา :____/________/____',
                      // '${DateFormat('วันที่ทำสัญญา : d เดือน MMM ปี ', 'th').format(DateTime.now())}${DateTime.now().year + 543}',
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
            ],
          ),
          pw.Divider(height: 2),
          // pw.SizedBox(height: 1 * PdfPageFormat.mm),
          pw.SizedBox(height: 2 * PdfPageFormat.mm),
        ]);
      },
      build: (context) {
        return [
          pw.SizedBox(height: 2 * PdfPageFormat.mm),
          pw.Text(
            'ระเบียบการเช่าห้องพัก',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: font_Size,
              font: ttf,
              color: Colors_pd,
            ),
          ),
          pw.SizedBox(height: 1 * PdfPageFormat.mm),
          pw.Text(
            'ข้อ 1. ผู้เช่าห้องเช่าต้องนำหลักฐานมาแสดงตัวตน  กล่าวคือ  บัตรประจำตัวประชาชน  หรือใบสำคัญสำคัญทะเบียนคนต่างด้างด้าว  พร้อมต้องแจ้งทะเบียนที่อยู่ ให้ชัดเจน',
            textAlign: pw.TextAlign.left,
            style: pw.TextStyle(
              fontSize: font_Size,
              font: ttf,
              color: Colors_pd,
            ),
          ),
          pw.SizedBox(height: 1 * PdfPageFormat.mm),
          pw.Text(
            'ข้อ 2. ผู้เช่าห้องต้องวางเงินประกันความเสียหายในที่ได้ลงลายมือชื่อในสัญญาฉบับนี้ให้ไว้แก่ผู้ให้เช่าหรือตัวแทนของผู้ให้เช่า',
            textAlign: pw.TextAlign.left,
            style: pw.TextStyle(
              fontSize: font_Size,
              font: ttf,
              color: Colors_pd,
            ),
          ),
          pw.SizedBox(height: 1 * PdfPageFormat.mm),
          pw.Text(
            'ข้อ 3. ผู้เช่าจะต้องรักษาห้องเช่า และอุปกรณ์เครื่องใช้ภายในห้องทุกชนิด ที่ผู้ให้เช่าจัดเตรียมไว้ให้สะอาดเรีอบร้อย มั่นคง  ถาวรเสมอ  ถ้ามีสิ่งชำรุดเสียหายผู้เช่ามีหน้าก็ต้อง\nซ่อมแซม และ/หรือชำระค่าสียหายของทรัพย์สินที่เสียหายดังกล่าว',
            textAlign: pw.TextAlign.left,
            style: pw.TextStyle(
              fontSize: font_Size,
              font: ttf,
              color: Colors_pd,
            ),
          ),
          pw.SizedBox(height: 1 * PdfPageFormat.mm),
          pw.Text(
            'ข้อ 4. ผู้ให้เช่า และ/หรือตัวแทนมีสิทธิเข้าตรวจตราห้องเช่าได้ตามเวลาอันสมควร โดยจะแจ้งให้แก่ผู้เช่าทุกครั้ง',
            textAlign: pw.TextAlign.left,
            style: pw.TextStyle(
              fontSize: font_Size,
              font: ttf,
              color: Colors_pd,
            ),
          ),
          pw.SizedBox(height: 1 * PdfPageFormat.mm),
          pw.Text(
            'ข้อ 5. ห้ามเจาะตะปูหรือตอกตะปูหรือเปลี่ยนแปลงแก้ไขเคลื่อนย้ายสิ่งของต่างๆภายในห้องเช่าที่เช่าก่อนได้รับอนุญาตเป็นลายลักษณ์อักษรจากผู้ให้เช่าและ/หรือตัวแทนของ\nผู้ให้เช่า หากผู้เช่าฝืนหรือทำให้เกิดความเสียหายกับผนังของห้องเช่า และ/หรือส่วนใดภายในห้องเช่า ผู้เช่าจะต้องเสียค่าปรับจุดละ 500 บาท (ห้าร้อยบาทถ้วน)  หากติดสติก\nเกอร์, รูปภาพ เป็นคราบกาว ผู้เช่าจะต้องเสียค่าปรับจุดละ 500 บาท (ห้าร้อยบาทถ้วน) หรือตามขนาดของความเสียหาย และห้ามนำเอาสิ่งของภายใน\nห้องไปเป็นประกันอันเด็ดขาด',
            textAlign: pw.TextAlign.left,
            style: pw.TextStyle(
              fontSize: font_Size,
              font: ttf,
              color: Colors_pd,
            ),
          ),
          pw.SizedBox(height: 1 * PdfPageFormat.mm),
          pw.Text(
            'ข้อ 6. ห้ามผู้เช่าและ/หรือบริวารของผู้เช่าทำการสูบบุหรี่ หรือสิ่งเสพติดใดอันก่อให้เกิดกลิ่นเหม็นหรือควันภายในห้องเช่า',
            textAlign: pw.TextAlign.left,
            style: pw.TextStyle(
              fontSize: font_Size,
              font: ttf,
              color: Colors_pd,
            ),
          ),
          pw.SizedBox(height: 1 * PdfPageFormat.mm),
          pw.Text(
            'ข้อ 7. กรณีที่ผู้เช่าห้องลืมกุญแจ และ/หรือคือคีย์การ์ดและต้องการให้เจ้าหน้าที่ของผู้ให้เช่าเปิดประตูให้เจ้าหน้าที่จะเปิดประตูให้เฉพาะผู้เช่าที่มีชื่อในสัญญาเช่าห้องท่านั้นและ\nผู้เช่าต้องแสดงหลักฐานยืนยืนยันตัวตนแก่เจ้าหน้าที่ของผู้ให้เช่า กล่าวคือ บัตรประจำตัวประชาชาชน ใบขับขี่หรือแสดงหลักฐานอื่นๆที่สามารถระบุตัวตนของผู้ให้เช่าได้ พร้อม\nทั้งผู้เช่าจะต้องเสียค่าปรับ 200 บาท (สองร้อยบาทถ้วน) ให้แก่ผู้ให้เช่า',
            textAlign: pw.TextAlign.left,
            style: pw.TextStyle(
              fontSize: font_Size,
              font: ttf,
              color: Colors_pd,
            ),
          ),
          pw.SizedBox(height: 1 * PdfPageFormat.mm),
          pw.Text(
            'ข้อ 8. กรณีที่ผู้เช่าทำกุญแจและ/หรือคีย์การ์ด สูญหาย ผู้เช่าต้องเสียค่าปรับให้แก่ผู้ให้เช่าเป็นเงินจำนวน 250 บาท (สองร้องห้าสิบบาทถ้วน)',
            textAlign: pw.TextAlign.left,
            style: pw.TextStyle(
              fontSize: font_Size,
              font: ttf,
              color: Colors_pd,
            ),
          ),
          pw.SizedBox(height: 1 * PdfPageFormat.mm),
          pw.Text(
            'ข้อ 9. ระเบียบอาจมีการเปลี่ยนแปลงและ/หรือมีการเพิ่มเพิ่มเติมผู้เช่าจะประกาศเป็นลายลักษณ์อักษรพร้อมทั้งแจ้งให้ผู้เช่าทราบและผู้เช่ายินดีปฏิบัติตามข้อกำหนดที่เพิ่มเติม\nอย่างเคร่งครัด',
            textAlign: pw.TextAlign.left,
            style: pw.TextStyle(
              fontSize: font_Size,
              font: ttf,
              color: Colors_pd,
            ),
          ),
          pw.SizedBox(height: 1 * PdfPageFormat.mm),
          pw.Text(
            'ข้อ 10. เมื่อใกล้ครบกำหนดตามระยะเวลาการเช่า ผู้เช่าต้องแจ้งย้ายออกกับผู้ให้เช่าเป็นหนังสือ อย่างน้อย 30 วัน',
            textAlign: pw.TextAlign.left,
            style: pw.TextStyle(
              fontSize: font_Size,
              font: ttf,
              color: Colors_pd,
            ),
          ),
          pw.SizedBox(height: 10 * PdfPageFormat.mm),
          pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Text(
              'ข้าพเจ้าได้อ่านและรับทราบข้อกำหนดในระเบียบการเช่าห้องพักนี้แล้ว ข้าพเจ้าตกลงปฏิบัติตนตามทุกข้อ ทุกประการ จึงได้ลงลายมือชื่อไว้เป็นหลักฐานต่อหน้าพยาน และให้ถือว่ากฎระเบียบดังกล่าวเป็นส่วนหนึ่งของสัญญาเช่านี้ด้วย',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
          ),
          pw.SizedBox(height: 20 * PdfPageFormat.mm),
          pw.Row(children: [
            pw.Expanded(
                flex: 1,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'ลงชื่อ___________________________ผู้ให้เช่า    ',
                      textAlign: pw.TextAlign.justify,
                      style: pw.TextStyle(
                        color: Colors_pd,
                        fontSize: font_Size,
                        font: ttf,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2 * PdfPageFormat.mm),
                    pw.Text(
                      (FormName1_choice == null ||
                              FormName1_choice.toString() == '')
                          ? '(___________________________) '
                          : '( $FormName1_choice ) ',
                      textAlign: pw.TextAlign.justify,
                      style: pw.TextStyle(
                        color: Colors_pd,
                        fontSize: font_Size,
                        font: ttf,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2 * PdfPageFormat.mm),
                    pw.Text(
                      'วันที่____/________/____',
                      textAlign: pw.TextAlign.justify,
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
                    pw.Text(
                      'ลงชื่อ___________________________ผู้เช่า    ',
                      textAlign: pw.TextAlign.justify,
                      style: pw.TextStyle(
                        color: Colors_pd,
                        fontSize: font_Size,
                        font: ttf,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2 * PdfPageFormat.mm),
                    pw.Text(
                      (_verticalGroupValue.toString() == 'องค์กร/นิติบุคคล')
                          ? "( $Form_bussscontact )"
                          : "( $Form_bussshop )",
                      // (FormName2_choice == null ||
                      //         FormName2_choice.toString() == '')
                      //     ? '(___________________________) '
                      //     : '( $FormName2_choice ) ',
                      textAlign: pw.TextAlign.justify,
                      style: pw.TextStyle(
                        color: Colors_pd,
                        fontSize: font_Size,
                        font: ttf,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2 * PdfPageFormat.mm),
                    pw.Text(
                      'วันที่____/________/____',
                      textAlign: pw.TextAlign.justify,
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
          pw.SizedBox(height: 10 * PdfPageFormat.mm),
          pw.Row(children: [
            pw.Expanded(
                flex: 1,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'ลงชื่อ___________________________พยาน    ',
                      textAlign: pw.TextAlign.justify,
                      style: pw.TextStyle(
                        color: Colors_pd,
                        fontSize: font_Size,
                        font: ttf,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2 * PdfPageFormat.mm),
                    pw.Text(
                      (FormName3_choice == null ||
                              FormName3_choice.toString() == '')
                          ? '(___________________________) '
                          : '( $FormName3_choice ) ',
                      textAlign: pw.TextAlign.justify,
                      style: pw.TextStyle(
                        color: Colors_pd,
                        fontSize: font_Size,
                        font: ttf,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2 * PdfPageFormat.mm),
                    pw.Text(
                      'วันที่____/________/____',
                      textAlign: pw.TextAlign.justify,
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
                    pw.Text(
                      'ลงชื่อ___________________________พยาน    ',
                      textAlign: pw.TextAlign.justify,
                      style: pw.TextStyle(
                        color: Colors_pd,
                        fontSize: font_Size,
                        font: ttf,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2 * PdfPageFormat.mm),
                    pw.Text(
                      (FormName4_choice == null ||
                              FormName4_choice.toString() == '')
                          ? '(___________________________) '
                          : '( $FormName4_choice ) ',
                      textAlign: pw.TextAlign.justify,
                      style: pw.TextStyle(
                        fontSize: font_Size,
                        font: ttf,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2 * PdfPageFormat.mm),
                    pw.Text(
                      'วันที่____/________/____',
                      textAlign: pw.TextAlign.justify,
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
          pw.SizedBox(height: 2 * PdfPageFormat.mm),
        ];
      },
      footer: (context) {
        return pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.Align(
              alignment: pw.Alignment.bottomRight,
              child: pw.Text(
                'หน้า ${context.pageNumber} / ${context.pagesCount} ',
                textAlign: pw.TextAlign.left,
                style: pw.TextStyle(
                  fontSize: 10,
                  font: ttf,
                  color: Colors_pd,
                  // fontWeight: pw.FontWeight.bold
                ),
              ),
            )
          ],
        );
      },
    ));
    //////---------------------------------->
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
