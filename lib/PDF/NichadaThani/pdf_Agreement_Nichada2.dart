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

class Pdfgen_Agreement_Nichada2 {
//////////---------------------------------------------------->( **** เอกสารสัญญาบริการ  Nichada)

  static void exportPDF_Agreement_Nichada2(
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
                  'สัญญาบริการ (คู่กับสัญญาเช่าสถานที่)',
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
                        (_verticalGroupValue.toString() == 'องค์กร/นิติบุคคล')
                            ? "$Form_bussshop "
                            : "$Form_bussscontact",
                        // (_verticalGroupValue.toString() == 'องค์กร/นิติบุคคล')
                        //     ? "$Form_bussscontact"
                        //     : "$Form_bussshop",
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
                        // (_verticalGroupValue.toString() == 'องค์กร/นิติบุคคล')
                        //     ? "$Form_bussshop "
                        //     : "$Form_bussscontact",
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
              'ข้อที่ 1. ขอบเขตของการบริการ',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.Text(
              ' ' * 6 +
                  'ผู้ให้บริการตกลงจะให้บริการและผู้รับบริการตกลงรับบริการความสะดวกต่างๆในอาคาร PAISART ดังนี้ คือ',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.Text(
              ' ' * 12 +
                  '(1)	บริการการทำความสะอาดในสถานที่ที่ใช้ร่วมกันในตัวอาคาร',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.Text(
              ' ' * 12 + '(2)	บริการห้องสุขา และบริการน้ำประปาภายในห้องสุขา',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.Text(
              ' ' * 12 + '(3)	บริการเกี่ยวกับระบบไฟฟ้าภายในตัวอาคาร',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.Text(
              ' ' * 12 +
                  '(4)	บริการเครื่องปรับอากาศ (ไม่รวมการซ่อมบำรุงและดูแลรักษา)',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.Text(
              ' ' * 12 +
                  '(5)	บริการให้ใช้ที่จอดรถในอาคาร จำนวน 1 คัน โดยผู้ให้บริการไม่ต้องรับผิดชอบในความสูญหายหรือเสียหายใด ๆ ทั้งสิ้น',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.Text(
              ' ' * 12 + '(6)	บริการเวรยามรักษาความปลอดภัยในตัวอาคาร',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.Text(
              ' ' * 12 +
                  '(7)	จุดรับสัญญาณโทรศัพท์ อินเตอร์เน็ต เครื่องใช้ไฟฟ้า (ภายในอาคาร)',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Text(
              'ข้อที่ 2. ระยะเวลา และอัตราค่าบริการ',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Row(
              children: [
                pw.Text(
                  ' ' * 6 + 'ระยะเวลาของสัญญาบริการนี้มีกำหนด',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontSize: font_Size,
                    font: ttf,
                    color: Colors_pd,
                  ),
                ),
                pw.Container(
                  width: 30,
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
                ),
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
                pw.Text(
                  'โดยถือว่ามีระยะเวลา เช่นเดียวกับสัญญาเช่าสถานที่ในอาคาร',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontSize: font_Size,
                    font: ttf,
                    color: Colors_pd,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            // pw.Text(
            //   'สถานที่ในอาคารดังที่ได้กล่าวไว้ข้างต้น ผู้รับบริการตกลงชำระค่าบริการเป็นรายเดือน ',
            //   textAlign: pw.TextAlign.left,
            //   style: pw.TextStyle(
            //     fontSize: font_Size,
            //     font: ttf,
            //     color: Colors_pd,
            //   ),
            // ),
            // pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Row(
              children: [
                pw.Text(
                  'ดังที่ได้กล่าวไว้ข้างต้น ผู้รับบริการตกลงชำระค่าบริการเป็นรายเดือนในอัตราเดือนละ',
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
                                    .where((e) => e.expser.toString() == '8')
                                    .length ==
                                0)
                            ? '0.00 บาท (~${convertToThaiBaht(0.00)}~)'
                            : '${nFormat.format(quotxSelectModels.where((e) => e.expser.toString() == '8').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ' +
                                '(~${convertToThaiBaht(double.parse('${quotxSelectModels.where((e) => e.expser.toString() == '8').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b)}'))}~)',
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
                //   'ยังไม่รวมภาษีมูลค่าเพิ่ม ',
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
            pw.Text(
              'ยังไม่รวมภาษีมูลค่าเพิ่ม และจะชำระล่วงหน้าทุกวันที่ 1-5 ของทุกเดือน พร้อมกับค่าเช่าสถานที่ โดยผู้รับบริการต้องชำระค่าบริการให้แก่ผู้ให้บริการโดยตรงเป็นเงินสด ณ ภูมิ',
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
                // pw.Text(
                //   'ชื่อบัญชี',
                //   textAlign: pw.TextAlign.left,
                //   style: pw.TextStyle(
                //     fontSize: font_Size,
                //     font: ttf,
                //     color: Colors_pd,
                //   ),
                // ),
                // pw.Expanded(
                //     flex: 1,
                //     child: pw.Container(
                //       decoration: pw.BoxDecoration(
                //           border: pw.Border(
                //               bottom: pw.BorderSide(
                //         color: Colors_pd,
                //         width: 0.1, // Underline thickness
                //       ))),
                //       child: pw.Text(
                //         'นางสาว พฤณ สิทรัพย์ ',
                //         textAlign: pw.TextAlign.center,
                //         style: pw.TextStyle(
                //           color: Colors_pd,
                //           fontSize: font_Size,
                //           fontWeight: pw.FontWeight.bold,
                //           font: ttf,
                //         ),
                //       ),
                //     )),
              ],
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Row(
              children: [
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
                pw.Expanded(flex: 1, child: pw.Text(''))
              ],
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Text(
              'ข้อที่ 3. กระแสไฟฟ้า, ค่าน้ำประปา, และค่าบริการส่วนกลาง ชำระเป็นรายเดือน',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.Text(
              ' ' * 6 +
                  'การบริการไม่รวมค่ากระแสไฟฟ้า, ค่าน้ำประปา (กรณีติดมิเตอร์เพิ่มเติม), และค่าบริการส่วนกลาง ซึ่งผู้รับบริการ  จะต้องชำระต่างหาก โดยคำนวนจากกระแสไฟฟ้า และ\nน้ำประปาที่ใช้จริงในสถานที่ให้เช่าซึ่งผ่านเครื่องวัดที่จัดไว้  โดยเฉพาะในอัตราของไฟฟ้าส่วนภูมิภาค  บวก 2.50 บาท (สองบาทห้าสิบสตางค์) ต่อหนึ่งหน่วยยูนิต, ค่าน้ำประปา (กรณีติดมิเตอร์เพิ่มเติม) ในอัตราของการประปาส่วนภูมิภาค บวก 1.50 บาท  (หนึ่งบาทห้าสิบสตางค์), และค่าส่วนกลาง ตารางเมตร  ละ 15 บาท (สิบห้าบาทถ้วน)  อัตราค่า\nกระแสไฟฟ้า, และค่าน้ำประปา อาจเปลี่ยนแปลงไปตามส่วนที่มีการขึ้นอัตราค่ากระแสไฟฟ้า และน้ำประปาของการไฟฟ้า และการประปาส่วนภูมิภาค ผู้รับบริการจะต้องชำระ',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.Text(
              'ค่ากระแสไฟฟ้า, ค่าน้ำประปา, และค่าส่วนกลางเป็นรายเดือนภายในระยะเวลา 5 วัน นับจากวันที่ได้รับคำบอกกล่าวเป็นลายลักษณ์อักษรจากผู้ใช้บริการ',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Text(
              'ข้อที่ 4. เงินประกัน',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.Row(
              children: [
                pw.Text(
                  ' ' * 6 +
                      'ในวันที่ทำสัญญานี้ ผู้รับประกันได้มอบเงินประกันจำนวน',
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
                                    .where((e) => e.exptser.toString() == '2')
                                    .length ==
                                0)
                            ? '0.00 บาท (~${convertToThaiBaht(0.00)}~)'
                            : '${nFormat.format(quotxSelectModels.where((e) => e.exptser.toString() == '2').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b))} บาท ' +
                                '(~${convertToThaiBaht(double.parse('${quotxSelectModels.where((e) => e.exptser.toString() == '2').map((e) => e.total != null ? double.parse(e.total.toString()) : 0.00).fold(0.00, (a, b) => a + b)}'))}~)',
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
                  'แก่ผู้ให้บริการ',
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
              'เงินประกันนี้ ผู้ให้บริการจะคืนให้แก่ผู้รับบริการในวันที่ครบกำหนดสัญญาบริการหรือเมื่อสัญญาบริการสิ้นสุดลงโดยมิใช่ความผิดของผู้รับบริการ และผู้รับบริการไม่มีหนี้สินค้าง\nชำระแก่ผู้ให้บริการ ในกรณีผู้รับบริการมีหนี้สินค้างชำระแก่ผู้ให้บริการ  ผู้ให้บริการมีสิทธิ์หักจากเงินประกันได้และหากยังมีเงินเหลืออยู่  ผู้ให้บริการจะคืนให้แก่ผู้รับบริการ แต่\nหากหักจากเงินประกันแล้วยังไม่คุ้มกับเงินที่ผู้รับบริการค้างชำระ ผู้ให้บริการมีสิทธิ์เรียกร้องขอจากผู้รับบริการจนครบ',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 18 * PdfPageFormat.mm),
            pw.Text(
              'ข้อที่ 5. กรณีผิดสัญญา',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: font_Size,
                font: ttf,
                color: Colors_pd,
              ),
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Text(
              ' ' * 6 +
                  'สัญญาให้บริการนี้ถือเป็นส่วนหนึ่งของสัญญาเช่าสถานที่ในอาคารดังที่กล่าวไว้แล้วข้างต้นด้วย   ข้อความใดที่มิได้ระบุไว้ชัดเจนในสัญญาบริการฉบับนี้  ก็ให้นำข้อความใน\nสัญญาเช่าสถานที่ในอาคารมาบังคับแก่คู่สัญญาโดยอนุโลมให้ด้วย   ในกรณีที่ผู้รับบริการประพฤติผิดสัญญาฉบับใดฉบับหนึ่ง   อันเป็นเหตุให้สัญญาสิ้นสุดลงก็ให้สัญญาฉบับนี้\nสิ้นสุดลงพร้อมกัน  และนอกจากทางแก้ที่คู่สัญญาได้มีอยู่ต่อกันแล้วผู้ให้บริการมีสิทธิ์ที่จะงดการให้บริการอย่างใดอย่างหนึ่งหรือทั้งหมดตามที่เห็นสมควรก็ได้  โดยผู้รับบริการ\nจะเรียกร้องค่าทดแทนในความเสียหายใด ๆ ที่เกิดขึ้นเพราะเหตุที่ตนเป็นฝ่ายผิดสัญญาก่อนนั้นไม่ได้ทั้งสิ้น',
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
                'สัญญานี้ทำขึ้นเป็นสองฉบับ คู่สัญญาทั้งสองฝ่ายได้อ่าน และเข้าใจข้อความอย่างดีแล้วเห็นว่าสัญญาถูกต้องจึงลงลายมือชื่อไว้เป็นสัญญาต่อหน้าพยาน',
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
