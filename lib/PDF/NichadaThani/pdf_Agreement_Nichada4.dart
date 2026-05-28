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

class Pdfgen_Agreement_Nichada4 {
//////////---------------------------------------------------->( **** เอกสารสัญญาเช่า  Nichada)

  static void exportPDF_Agreement_Nichada4(
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
                  'สัญญาเช่าอาคารสำนักงานแบ่งให้เช่า',
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
                  'หนังสือสัญญาเช่าฉบับนี้ทำขึ้นระหว่าง',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontSize: font_Size,
                    font: ttf,
                    color: Colors_pd,
                  ),
                ),
                pw.Expanded(
                    flex: 4,
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
              ],
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Row(
              children: [
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
                  'กรรมการผู้จัดการ   ซึ่งต่อไปในสัญญาจะเรียกว่า  “ผู้ให้เช่า”  ฝ่ายหนึ่ง  กับ',
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
                    flex: 1,
                    child: pw.Container(
                      decoration: pw.BoxDecoration(
                          border: pw.Border(
                              bottom: pw.BorderSide(
                        color: Colors_pd,
                        width: 0.1, // Underline thickness
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
                  'สำนักงานตั้งอยู่ที่',
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
                  'โดย',
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
                    flex: 1,
                    child: pw.Container(
                      decoration: pw.BoxDecoration(
                          border: pw.Border(
                              bottom: pw.BorderSide(
                        color: Colors_pd,
                        width: 0.1, // Underline thickness
                      ))),
                      child: pw.Text(
                        (_verticalGroupValue.toString() == 'องค์กร/นิติบุคคล')
                            ? "$Form_bussscontact"
                            : "$Form_bussshop",
                        // "$bill_name",
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
                  'ซึ่งต่อไปนี้ในสัญญาจะเรียกว่า  “ผู้เช่า” อีกฝ่ายหนึ่ง',
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
              'คู่สัญญาทั้งสองฝ่ายตกลงทำสัญญาเช่ากันโดยมีรายละเอียดสัญญาดังต่อไปนี้',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Text(
              'ข้อ 1. ผู้ให้เช่าตกลงให้เช่า และผู้เช่าตกลงเช่าอาคารสำนักงานแบ่งให้เช่า เลขที่ 1028 ถนนเลียบคลองรังสิต ต.ประชาธิปัตย์ อ.ธัญบุรี จ.ปทุมธานี 12130 ',
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
                  'ชั้นที่',
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
                pw.Text(
                  'ห้องเลขที่',
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
                  'พื้นที่',
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
                        "$Form_area ตรม.",
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
                //   'ตรม.',
                //   textAlign: pw.TextAlign.left,
                //   style: pw.TextStyle(
                //     fontSize: font_Size,
                //     font: ttf,
                //     color: Colors_pd,
                //   ),
                // ),
              ],
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Row(children: [
              pw.Text(
                'ซึ่งต่อไปในสัญญาจะเรียก “ทรัพย์สินที่เช่า” เพื่อประโยชน์ในการประกอบกิจการเป็นสำนักงานของ ',
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
                      "$Form_bussscontact",
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        color: Colors_pd,
                        fontSize: (Form_bussscontact.length > 46)
                            ? font_Size - 1
                            : font_Size,
                        fontWeight: pw.FontWeight.bold,
                        font: ttf,
                      ),
                    ),
                  )),
              pw.Text(
                'โดยถูกต้องตามกฎหมาย',
                textAlign: pw.TextAlign.left,
                style: pw.TextStyle(
                  fontSize: font_Size,
                  font: ttf,
                  color: Colors_pd,
                ),
              ),
            ]),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Row(
              children: [
                pw.Text(
                  'ข้อ 2. ผู้ให้เช่าตกลงให้เช่า ทรัพย์สินที่เช่าตามข้อ 1 มีกำหนด ',
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
            pw.Row(
              children: [
                pw.Text(
                  'ข้อ 3. ผู้เช่าตกลงชำระเงินค่าเช่าให้แก่ผู้เช่าเป็นรายเดือน ในอัตราค่าเช่าเดือนละ',
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
                            : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '1').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ' +
                                '(~${convertToThaiBaht(double.parse('${quotxSelectModels.where((e) => e.expser.toString() == '1').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b)}'))}~)',
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
                  'งวดแรกผู้เช่าจะชำระค่าเช่าให้ผู้ให้เช่าภายในวันที่',
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
                  ),
                ),
                pw.Text(
                  'และจะชำระค่าเช่าทุกวันที่ 1-5 ของทุกเดือนจำนวนเงิน',
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
                            : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '1').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ' +
                                '(~${convertToThaiBaht(double.parse('${quotxSelectModels.where((e) => e.expser.toString() == '1').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b)}'))}~)',
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
                  'โดยผู้เช่าต้องชำระค่าเช่าแก่ผู้ให้เช่าโดยตรงเป็นเงินสด ณ ภูมิ',
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
                  'ลำเนาของผู้ให้เช่าหรือโอนเงินเข้าบัญชีผู้ให้เช่า เลขที่ ',
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
                        '${PDF_bnos}',
                        // '748-1-20338-7',
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
                  'ธนาคาร',
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
                        '${PDF_banks}',
                        // 'ธนาคารกรุงศรีอยุธยา',
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
                  'ชื่อบัญชี',
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
                        '${PDF_bnames}',
                        // 'นางสาว พฤณ สิทรัพย์ ',
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
                  'ข้อ 4. ในวันที่ทำสัญญานี้ ผู้เช่าได้วางเงินประกันความเสียหายสำหรับการเช่าไว้เป็นจำนวน ',
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
              ],
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Text(
              'สำหรับค่าเสียหายต่าง ๆ หากผู้เช่าประพฤติผิดสัญญานี้ขึ้น โดยให้สิทธิ์แก่ผู้ให้เช่าที่จะริบเงินประกันนี้ได้ทันทีนอกเหนือจากค่าเสียหายต่าง ๆ ที่ผู้เช่าได้ประพฤติผิดสัญญานั้น ๆ',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Text(
              'ข้อ 5. ผู้ให้เช่าสงวนสิทธิ์ในการเปลี่ยนแปลงค่าเช่า โดยผู้ให้เช่าจะแจ้งให้ผู้เช่าทราบล่วงหน้าก่อนผู้เช่าเข้าอยู่หรือเมื่อมีการต่อสัญญาใหม่โดยอัตราค่าเช่าที่จะปรับเพิ่มขึ้นสำหรับ\nการต่อสัญญาฉบับใหม่ จะไม่เกินกว่าร้อยละ 10 (สิบ)',
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
                  'ทั้งนี้ หากผู้เช่าผิดสัญญาไม่ชำระค่าเช่าภายในวันเวลาที่กำหนดดังกล่าว  ให้ถือว่าสัญญานี้เป็นอันยกเลิกโดยไม่ต้องบอกกล่าวอีก  ผู้เช่ายอมให้ผู้ให้เช่าหรือตัวแทนของ\nผู้ให้เช่าเข้าครอบครองทรัพย์สินที่เช่าได้ทันทีหากผู้เช่าไม่ยอมส่งมอบทรัพย์สินที่เช่า   ผู้เช่าจะต้องชำระค่าเสียหายแก่ผู้ให้เช่าในอัตราวันละ   500  บาท  (ห้าร้อยบาทถ้วน) จน\nกว่าผู้เช่า และบริวารของผู้เช่าจะขนย้ายทรัพย์สิน และออกไปจากทรัพย์สินที่เช่า',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Text(
              'ข้อ 6. ในระหว่างอายุสัญญาเช่านี้ผู้เช่ายินยอมชำระค่าภาษีอากรต่าง ๆ ภาษีป้าย ค่าธรรมเนียมและค่าใช้จ่ายอื่น ๆ  ซึ่งรัฐบาล เทศบาลหรือส่วนราชการอื่นใดเรียกเก็บในทรัพย์\nสินที่เช่า ผู้เช่าจะต้องนำเงินไปชำระให้แก่ผู้ให้เช่า  และ/หรือหน่วยงาน ราชการนั้น ๆ ภายในกำหนด 7 วัน นับตั้งแต่วันที่หน่วยงานราชการนั้น ๆเรียกเก็บ  และผู้เช่าจะต้องนำ\nหลักฐานการชำระเงินดังกล่าวไปมอบให้แก่ผู้ให้เช่าเก็บไว้เป็นหลักฐาน โดยผู้เช่าจะไม่เรียกร้องสิ่งตอบแทนใด ๆ จากผู้ให้เช่าทั้งสิ้นยกเว้นในส่วนของภาษีหัก ณ ที่จ่าย ทางผู้เช่า\nมีสิทธิหัก ณ ที่จ่าย ในอัตราร้อยละ 5 (ห้า)',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Text(
              'ข้อ 7. ห้ามผู้เช่านำทรัพยสินที่เช่าไปให้บุคคลเช่าช่วงหรือโอนสิทธิ์การเช่าให้แก่ผู้อื่นหรือให้บุคคลอื่นเข้าอยู่อาศัยโดยเด็ดขาดเว้นแต่จะได้คำยินยอมเป็นหนังสือจากผู้ให้เช่าก่อน',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Text(
              'ข้อ 8.  ผู้เช่าสัญญาว่า จะดูแล, ซ่อมแซม, และรักษาบรรดาทรัพย์สินที่เช่า ตลอดทั้งทรัพย์สินอื่น ๆ มิให้ทรุดโทรมหรือสกปรกรุงรัง ไม่ทอดทิ้งไม่ทำให้เสียหาย  และไม่ประพฤติ\nหรือกระทำใด ๆ ผิดกฎหมาย  หรือให้เป็นที่รบกวนสิทธิของผู้อื่นที่อยู่ข้างเคียง หรือกระทำสิ่งที่น่าจะเป็นอันตรายแก่ทรัพย์สินที่เช่าหรือแก่บุคคลอื่น  หรือแก่ทรัพย์สินของผู้อยู่\nใกล้เคียง และจะไม่ทำการใด ๆ ให้เป็นการน่ารังเกียจ ทั้งนี้ไม่ว่าด้วยตนเองหรือบริวารของผู้เช่า',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Text(
              'ข้อ 9. ผู้เช่าจะไม่เจาะ ตอก ต่อเติม ตลอดจนไม่ทำการใด ๆ ให้เกิดความเสียหายต่อโครงสร้างอาคารที่เช่า กำแพง ผนังฝ้า สี พื้น อุปกรณ์ตกแต่งภายในอาคารที่เช่า แอร์ อื่น ๆ หากเกิดความเสียหายต่ออาคารที่เช่าหรืออาคารข้างเคียง  ผู้เช่าจะต้องรับผิดชอบต่อความเสียหายที่เกิดขึ้นทั้งหมด  และผู้เช่าจะต้องรับผิดชอบในบรรดาความเสียหายหรือบุบ\nสลายใด ๆ อันเกิดขึ้นแก่ทรัพย์สินที่เช่าเพราะความผิดของผู้เช่าหรือบุคคลที่อยู่กับผู้เช่า หรือ บริวารของผู้เช่า เว้นแต่จะได้รับความยินยอมจากผู้ให้เช่า',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 10 * PdfPageFormat.mm),
            pw.Text(
              'ข้อ 10. หากผู้ให้เช่าประสงค์จะขายทรัพย์สินที่เช่า ก่อนครบกำหนดตามสัญญานี้ ผู้ให้เช่าจะต้องแจ้งให้ผู้เช่าทราบล่วงหน้าไม่น้อยกว่า 2 เดือน และผู้เช่ายินดีที่จะขนย้ายทรัพย์\nสิน และบริวารออกไปจากทรัพย์สินที่เช่า',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Text(
              'ข้อ 11.   ผู้เช่ายอมให้ผู้ให้เช่า  หรือตัวแทนของผู้ให้เช่าเข้าไปตรวจตราทรัพย์สินที่ให้เช่าได้ตลอดเวลาที่เช่า  หรือตลอดเวลาที่ครอบครองทรัพย์สินที่เช่าอยู่นี้  อีกทั้งยอมให้ช่าง\nเข้าไปตีราคาทรัพย์สินที่เสียหายในทรัพย์สินที่เช่าได้',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Text(
              'ข้อ 12. เมื่อผู้เช่าออกไปจากทรัพย์สินที่เช่า บรรดาสิ่งก่อสร้างหรือซ่อมแซมที่ตรึงตราในบริเวณทรัพย์สินที่เช่านี้ห้ามมิให้รื้อถอนหรือทำลายเป็นอันขาด และให้ตกเป็นกรรมสิทธิ์\nของผู้ให้เช่าทั้งสิ้น โดยผู้เช่าจะเรียกร้องค่าทดแทนใด ๆ หรือค่าเสียหายใด ๆ ไม่ได้เลย ยกเว้นสิ่งก่อสร้างที่ผู้เช่าต่อเติมไว้เป็นการเฉพาะ ซึ่งผู้ให้เช่าเห็นว่าไม่สามารถเก็บไว้ได้ ผู้\nเช่าต้องทำการรื้อถอนให้อยู่ในสภาพเดิมทุกประการ',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Text(
              'ข้อ 13. หากทรัพย์สินที่เช่าเกิดอัคคีภัยขึ้นให้สัญญาเช่านี้เป็นอันสิ้นสุดลง  และถ้าผู้เช่าจะประกันอัคคีภัยทรัพย์สิน  หรือสินค้าของตนภายในบริเวณทรัพย์สินที่เช่าจะต้องได้รับ\nอนุญาตจากผู้ให้เช่าเป็นลายลักษณ์อักษรก่อนจึงจะทำประกันได้   หรือหากเกิดอัคคีภัยขึ้นเพราะความผิดของผู้เช่า  หรือบริวารของผู้เช่า ผู้เช่าจะต้องชดใช้บรรดาค่าเสียหายที่\nเกิดมีขึ้นทั้งหมดให้แก่ผู้ให้เช่าทันที',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Text(
              'ข้อ 14. เมื่อสัญญานี้เลิกกันด้วยเหตุใดก็ดีบรรดาภาษีหนี้สินต่าง  ๆ  เช่น ค่าเช่า  ค่าน้ำ ค่าไฟฟ้า  ค่าโทรศัพท์  และอื่น  ๆ ที่ผู้เช่าค้างชำระเนื่องจากการเช่าตามสัญญานี้ ผู้เช่า\nสัญญาว่าจะจัดการชำระให้เสร็จสิ้น  และจะนำหลักฐานการชำระหนี้ดังกล่าวมามอบให้ผู้ให้เช่าภายในกำหนด  7  วัน  นับจากวันที่ได้เลิกสัญญา  ส่วนภาษี  และหนี้สินต่างๆที่\nค้างชำระและปรากฎในภายหลังจากวันเลิกสัญญานี้ผู้เช่าจะต้องจัดการชำระให้เสร็จสิ้นโดยเร็ว และผู้เช่ายินยอมให้ผู้ให้เช่ามีสิทธิยึดหน่วงทรัพย์สิน และเงินประกันการเช่าของ\nผู้เช่าจนกว่าผู้เช่าจะชำระหนี้นั้นๆเสร็จสิ้น',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Text(
              'ข้อ 15. เมื่อสัญญาเช่าครบกำหนดการเช่าหรือสัญญาเช่าเลิกกันไม่ว่ากรณีใด  ๆ  ผู้เช่า  และบริวาร  จะต้องขนย้ายทรัพย์สินออกจากทรัพย์สินที่เช่า และส่งมอบทรัพย์สินที่เช่า\nคืนแก่ผู้ให้เช่าทันที  โดยไม่มีสิทธิ์จะเรียกร้องค่าขนย้ายหรือค่าตอบแทนใด  ๆ จากผู้ให้เช่าทั้งสิ้น หากผู้เช่าไม่ยอมออกไปจากทรัพย์สินที่เช่า  และส่งมอบทรัพย์สินที่เช่าตามกำ\nหนด ผู้เช่ายินยอมชดใช้ค่าเสียหายให้แก่ผู้ให้เช่าคิดเป็นรายวัน วันละ 500 บาท (ห้าร้อยบาทถ้วน) จนกว่าจะขนย้ายทรัพย์สิน และบริวารออกจากทรัพย์สินที่เช่าโดยเรียบร้อย หากก่อนสัญญาเช่าครบกำหนดไม่น้อยกว่า 2 เดือน แล้วผู้เช่าประสงค์เช่าต่อต้องทำสัญญากันใหม่ หรือหากผู้เช่าไม่ประสงค์เช่าต่อต้องแจ้งผู้ให้เช่าทราบล่วงหน้าไม่น้อยกว่า 2 เดือน หากผู้เช่าผิดสัญญา ยินยอมให้ริบเงินประกันตามสัญญาข้อ 4 ได้',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Text(
              'ข้อที่ 16. หากผู้เช่าประสงค์ที่จะเช่าทรัพย์สินที่เช่าเกินกว่า 3 ปี ค่าธรรมเนียมที่ต้องชำระต่อหน่วยงานราชการให้ผู้เช่าเป็นผู้ชำระ',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Text(
              'ข้อที่ 17. หากผู้เช่าประพฤติผิดสัญญาข้อหนึ่งข้อใดก็ดี หรือผู้เช่าเช่าทรัพย์สินที่เช่าไม่ครบกำหนดเวลาตามสัญญาในข้อ 2 หรือไม่แจ้งล่วงหน้าไม่น้อยกว่า 2 เดือน  ตามข้อ 15.\nผู้เช่ายินยอมให้ผู้ให้เช่าริบเงินประกันตามสัญญาข้อ 4  ได้  และผู้เช่ายอมให้ผู้ให้เช่าทรงไว้ซึ่งสิทธิ์ที่จะเข้ายึดครองทรัพย์สินที่เช่าได้โดยฉับพลันและมีสิทธิ์บอกเลิกสัญญาเช่าได้\nทันที โดยผู้เช่ายอมให้ถือว่าสัญญาเช่าเป็นอันระงับไป และผู้เช่าจะเรียกร้องเอาค่าเสียหายหรือค่าตอบแทนใด ๆ จากผู้ให้เช่าไม่ได้ทั้งสิ้น  และผู้เช่ายอมให้ถือว่าสิทธิ์ครอบครอง\nทรัพย์สินที่เช่านั้นตกคืนแก่ผู้ให้เช่าแล้ว ตลอดจนผู้เช่ายินยอมให้ผู้ให้เช่าระงับการใช้น้ำ  ระงับการใช้ไฟฟ้า ระงับสัญญาณโทรศัพท์ อินเตอร์เน็ต   ทำลายเครื่องกีดขวางการเข้า\nห้องที่เช่า ตัดกุญแจของผู้เช่าและใส่กุญแจใหม่ ไม่ให้ผู้เช่าหรือบริวารของผู้เช่าไปในทรัพย์สินที่เช่าได้ ตลอดจนผู้ให้เช่ามีสิทธิ์ยึด และหักเงินประกันการเช่า ตามข้อ 4 เพื่อชำระ\nหนี้ต่างๆที่ผู้เช่ายังคงค้างชำระอยู่ได้ทั้งสิ้น โดยผู้เช่าให้ถือว่าการกระทำดังกล่าวไม่ถือเป็นความผิดทั้งทางแพ่งและทางอาญาแต่ประการใด',
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
                'สัญญานี้ทำขึ้นเป็นสองฉบับ ฉบับละ 2 หน้า 17 ข้อ มีข้อความถูกต้องตรงกันทุกประการ ทั้งสองฝ่ายต่างได้อ่านและทราบข้อความโดยตลอดดีแล้ว เห็นว่าถูกต้องตรงตามเจตนาทุกประการ เพื่อเป็นหลักฐานจึงได้ลงมือชื่อไว้เป็นสำคัญต่อหน้าพยานและเก็บไว้ฝ่ายละฉบับ',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: font_Size,
                  font: ttf,
                  color: Colors_pd,
                ),
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

    // pageCount++;
    // pdf.addPage(pw.MultiPage(
    //   pageFormat: PdfPageFormat.a4.copyWith(
    //     marginBottom: 18.00,
    //     marginLeft: 18.00,
    //     marginRight: 18.00,
    //     marginTop: 18.00,
    //   ),
    //   header: (context) {
    //     return pw.Column(children: [
    //       pw.Row(
    //         children: [
    //           pw.Container(
    //             height: 60,
    //             width: 60,
    //             decoration: pw.BoxDecoration(
    //               color: PdfColors.grey200,
    //               border: pw.Border.all(color: PdfColors.grey300),
    //             ),
    //             child: resizedLogo != null
    //                 ? pw.Image(
    //                     pw.MemoryImage(resizedLogo),
    //                     height: 60,
    //                     width: 60,
    //                   )
    //                 : pw.Center(
    //                     child: pw.Text(
    //                       '$bill_name ',
    //                       maxLines: 1,
    //                       style: pw.TextStyle(
    //                         fontSize: 10,
    //                         font: ttf,
    //                         color: Colors_pd,
    //                       ),
    //                     ),
    //                   ),
    //           ),
    //           // (netImage.isEmpty)
    //           //     ? pw.Container(
    //           //         height: 72,
    //           //         width: 70,
    //           //         color: PdfColors.grey200,
    //           //         child: pw.Center(
    //           //           child: pw.Text(
    //           //             '$renTal_name ',
    //           //             maxLines: 1,
    //           //             style: pw.TextStyle(
    //           //               fontSize: 10,
    //           //               font: ttf,
    //           //               color: Colors_pd,
    //           //             ),
    //           //           ),
    //           //         ))

    //           //     // pw.Image(
    //           //     //     pw.MemoryImage(iconImage),
    //           //     //     height: 72,
    //           //     //     width: 70,
    //           //     //   )
    //           //     : pw.Image(
    //           //         (netImage[0]),
    //           //         height: 72,
    //           //         width: 70,
    //           //       ),
    //           pw.SizedBox(width: 1 * PdfPageFormat.mm),
    //           pw.Container(
    //             width: 280,
    //             child: pw.Column(
    //               mainAxisSize: pw.MainAxisSize.min,
    //               crossAxisAlignment: pw.CrossAxisAlignment.start,
    //               children: [
    //                 pw.Text(
    //                   '${bill_name.toString().trim()}',
    //                   maxLines: 2,
    //                   style: pw.TextStyle(
    //                     fontSize: font_Size,
    //                     color: PdfColors.black,
    //                     fontWeight: pw.FontWeight.bold,
    //                     font: ttf,
    //                   ),
    //                 ),
    //                 pw.Text(
    //                   '${bill_addr.toString().trim()}',
    //                   maxLines: 3,
    //                   style: pw.TextStyle(
    //                     fontSize: font_Size,
    //                     color: Colors_pd,
    //                     font: ttf,
    //                   ),
    //                 ),
    //                 pw.Text(
    //                   'เลขประจำตัวผู้เสียภาษี : $bill_tax',
    //                   maxLines: 2,
    //                   style: pw.TextStyle(
    //                     fontSize: font_Size,
    //                     font: ttf,
    //                     color: Colors_pd,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //           pw.Spacer(),
    //           pw.Container(
    //             width: 180,
    //             child: pw.Column(
    //               mainAxisSize: pw.MainAxisSize.min,
    //               crossAxisAlignment: pw.CrossAxisAlignment.end,
    //               children: [
    //                 if (TitleType_Default_Receipt_Name != null &&
    //                     TitleType_Default_Receipt_Name.toString().trim() != '')
    //                   pw.Text(
    //                     '[ $TitleType_Default_Receipt_Name ]',
    //                     maxLines: 1,
    //                     style: pw.TextStyle(
    //                       fontSize: font_Size,
    //                       font: ttf,
    //                       color: PdfColors.grey400,
    //                     ),
    //                   ),
    //                 // pw.Text(
    //                 //   'ใบเสนอราคา',
    //                 //   style: pw.TextStyle(
    //                 //     fontSize: 12.00,
    //                 //     fontWeight: pw.FontWeight.bold,
    //                 //     font: ttf,
    //                 //   ),
    //                 // ),
    //                 // pw.Text(
    //                 //   'ที่อยู่,\n1/1-8 ถ.รัตนโกสินทร์ ต.ศรีภูมิ อ.เมือง จ.เชียงใหม่ 50200',
    //                 //   textAlign: pw.TextAlign.right,
    //                 //   style: pw.TextStyle(
    //                 //       fontSize: 10.0, font: ttf, color: PdfColors.grey),
    //                 // ),
    //                 pw.Text(
    //                   'โทรศัพท์ : $bill_tel',
    //                   textAlign: pw.TextAlign.right,
    //                   maxLines: 1,
    //                   style: pw.TextStyle(
    //                     fontSize: font_Size,
    //                     font: ttf,
    //                     color: Colors_pd,
    //                   ),
    //                 ),
    //                 pw.Text(
    //                   'อีเมล : $bill_email',
    //                   maxLines: 1,
    //                   textAlign: pw.TextAlign.right,
    //                   style: pw.TextStyle(
    //                     fontSize: font_Size,
    //                     font: ttf,
    //                     color: Colors_pd,
    //                   ),
    //                 ),

    //                 pw.Text(
    //                   'วันที่ทำสัญญา :${Datex_text.text}',
    //                   // 'วันที่ทำสัญญา :____/________/____',
    //                   // '${DateFormat('วันที่ทำสัญญา : d เดือน MMM ปี ', 'th').format(DateTime.now())}${DateTime.now().year + 543}',
    //                   maxLines: 2,
    //                   style: pw.TextStyle(
    //                     fontSize: font_Size,
    //                     font: ttf,
    //                     color: Colors_pd,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ],
    //       ),
    //       pw.Divider(height: 2),
    //       // pw.SizedBox(height: 1 * PdfPageFormat.mm),
    //       pw.SizedBox(height: 2 * PdfPageFormat.mm),
    //     ]);
    //   },
    //   build: (context) {
    //     return [
    //       pw.SizedBox(height: 10 * PdfPageFormat.mm),
    //       pw.Text(
    //         'สัญญานี้ทำขึ้นเป็นสองฉบับ คู่สัญญาทั้งสองฝ่ายได้อ่าน และเข้าใจข้อความอย่างดีแล้วเห็นว่าสัญญาถูกต้องจึงลงลายมือชื่อไว้เป็นสัญญาต่อหน้าพยาน',
    //         textAlign: pw.TextAlign.center,
    //         style: pw.TextStyle(
    //           fontSize: font_Size,
    //           font: ttf,
    //           color: Colors_pd,
    //         ),
    //       ),
    //       pw.SizedBox(height: 20 * PdfPageFormat.mm),
    //       pw.Row(children: [
    //         pw.Expanded(
    //             flex: 1,
    //             child: pw.Column(
    //               crossAxisAlignment: pw.CrossAxisAlignment.center,
    //               children: [
    //                 pw.Text(
    //                   'ลงชื่อ___________________________ผู้ให้เช่า    ',
    //                   textAlign: pw.TextAlign.justify,
    //                   style: pw.TextStyle(
    //                     color: Colors_pd,
    //                     fontSize: font_Size,
    //                     font: ttf,
    //                     fontWeight: pw.FontWeight.bold,
    //                   ),
    //                 ),
    //                 pw.SizedBox(height: 2 * PdfPageFormat.mm),
    //                 pw.Text(
    //                   '( $FormName1_choice ) ',
    //                   textAlign: pw.TextAlign.justify,
    //                   style: pw.TextStyle(
    //                     color: Colors_pd,
    //                     fontSize: font_Size,
    //                     font: ttf,
    //                     fontWeight: pw.FontWeight.bold,
    //                   ),
    //                 ),
    //                 pw.SizedBox(height: 2 * PdfPageFormat.mm),
    //                 pw.Text(
    //                   'วันที่____/________/____',
    //                   textAlign: pw.TextAlign.justify,
    //                   style: pw.TextStyle(
    //                     color: Colors_pd,
    //                     fontSize: font_Size,
    //                     font: ttf,
    //                     fontWeight: pw.FontWeight.bold,
    //                   ),
    //                 ),
    //               ],
    //             )),
    //         pw.SizedBox(width: 5 * PdfPageFormat.mm),
    //         pw.Expanded(
    //             flex: 1,
    //             child: pw.Column(
    //               crossAxisAlignment: pw.CrossAxisAlignment.center,
    //               children: [
    //                 pw.Text(
    //                   'ลงชื่อ___________________________ผู้เช่า    ',
    //                   textAlign: pw.TextAlign.justify,
    //                   style: pw.TextStyle(
    //                     color: Colors_pd,
    //                     fontSize: font_Size,
    //                     font: ttf,
    //                     fontWeight: pw.FontWeight.bold,
    //                   ),
    //                 ),
    //                 pw.SizedBox(height: 2 * PdfPageFormat.mm),
    //                 pw.Text(
    //                   '( $FormName2_choice ) ',
    //                   textAlign: pw.TextAlign.justify,
    //                   style: pw.TextStyle(
    //                     color: Colors_pd,
    //                     fontSize: font_Size,
    //                     font: ttf,
    //                     fontWeight: pw.FontWeight.bold,
    //                   ),
    //                 ),
    //                 pw.SizedBox(height: 2 * PdfPageFormat.mm),
    //                 pw.Text(
    //                   'วันที่____/________/____',
    //                   textAlign: pw.TextAlign.justify,
    //                   style: pw.TextStyle(
    //                     color: Colors_pd,
    //                     fontSize: font_Size,
    //                     font: ttf,
    //                     fontWeight: pw.FontWeight.bold,
    //                   ),
    //                 ),
    //               ],
    //             )),
    //       ]),
    //       pw.SizedBox(height: 10 * PdfPageFormat.mm),
    //       pw.Row(children: [
    //         pw.Expanded(
    //             flex: 1,
    //             child: pw.Column(
    //               crossAxisAlignment: pw.CrossAxisAlignment.center,
    //               children: [
    //                 pw.Text(
    //                   'ลงชื่อ___________________________พยาน    ',
    //                   textAlign: pw.TextAlign.justify,
    //                   style: pw.TextStyle(
    //                     color: Colors_pd,
    //                     fontSize: font_Size,
    //                     font: ttf,
    //                     fontWeight: pw.FontWeight.bold,
    //                   ),
    //                 ),
    //                 pw.SizedBox(height: 2 * PdfPageFormat.mm),
    //                 pw.Text(
    //                   '( $FormName3_choice ) ',
    //                   textAlign: pw.TextAlign.justify,
    //                   style: pw.TextStyle(
    //                     color: Colors_pd,
    //                     fontSize: font_Size,
    //                     font: ttf,
    //                     fontWeight: pw.FontWeight.bold,
    //                   ),
    //                 ),
    //                 pw.SizedBox(height: 2 * PdfPageFormat.mm),
    //                 pw.Text(
    //                   'วันที่____/________/____',
    //                   textAlign: pw.TextAlign.justify,
    //                   style: pw.TextStyle(
    //                     color: Colors_pd,
    //                     fontSize: font_Size,
    //                     font: ttf,
    //                     fontWeight: pw.FontWeight.bold,
    //                   ),
    //                 ),
    //               ],
    //             )),
    //         pw.SizedBox(width: 5 * PdfPageFormat.mm),
    //         pw.Expanded(
    //             flex: 1,
    //             child: pw.Column(
    //               crossAxisAlignment: pw.CrossAxisAlignment.center,
    //               children: [
    //                 pw.Text(
    //                   'ลงชื่อ___________________________พยาน    ',
    //                   textAlign: pw.TextAlign.justify,
    //                   style: pw.TextStyle(
    //                     color: Colors_pd,
    //                     fontSize: font_Size,
    //                     font: ttf,
    //                     fontWeight: pw.FontWeight.bold,
    //                   ),
    //                 ),
    //                 pw.SizedBox(height: 2 * PdfPageFormat.mm),
    //                 pw.Text(
    //                   '( $FormName4_choice ) ',
    //                   textAlign: pw.TextAlign.justify,
    //                   style: pw.TextStyle(
    //                     fontSize: font_Size,
    //                     font: ttf,
    //                     fontWeight: pw.FontWeight.bold,
    //                   ),
    //                 ),
    //                 pw.SizedBox(height: 2 * PdfPageFormat.mm),
    //                 pw.Text(
    //                   'วันที่____/________/____',
    //                   textAlign: pw.TextAlign.justify,
    //                   style: pw.TextStyle(
    //                     color: Colors_pd,
    //                     fontSize: font_Size,
    //                     font: ttf,
    //                     fontWeight: pw.FontWeight.bold,
    //                   ),
    //                 ),
    //               ],
    //             )),
    //       ]),
    //       pw.SizedBox(height: 2 * PdfPageFormat.mm),
    //     ];
    //   },
    //   footer: (context) {
    //     return pw.Column(
    //       mainAxisSize: pw.MainAxisSize.min,
    //       children: [
    //         pw.Align(
    //           alignment: pw.Alignment.bottomRight,
    //           child: pw.Text(
    //             'หน้า ${context.pageNumber} / ${context.pagesCount} ',
    //             textAlign: pw.TextAlign.left,
    //             style: pw.TextStyle(
    //               fontSize: 10,
    //               font: ttf,
    //               color: Colors_pd,
    //               // fontWeight: pw.FontWeight.bold
    //             ),
    //           ),
    //         )
    //       ],
    //     );
    //   },
    // ));
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
