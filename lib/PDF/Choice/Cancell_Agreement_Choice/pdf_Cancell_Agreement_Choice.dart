import 'package:chaoperty/Style/ThaiBaht.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:printing/printing.dart';

import '../../../Man_PDF/Preview_PDF/PreviewPdfgen_Billsplay.dart';

class Pdfgen_Cancell_Agreement_Choice {
  static void exportPDF_Cancell_Agreement_Choice(
      context,
      foder,
      renTal_name,
      bill_addr,
      bill_email,
      bill_tel,
      bill_tax,
      bill_name,
      TeNant_nameshop,
      TeNant_typeshop,
      TeNant_bussshop,
      TeNant_bussscontact,
      TeNant_address,
      TeNant_tel,
      TeNant_email,
      TeNant_rental_count,
      TeNant_area,
      TeNant_ln,
      TeNant_sdate,
      TeNant_ldate,
      TeNant_period,
      TeNant_rtname,
      TeNant_docno,
      TeNant_zn,
      TeNant_aser,
      TeNant_qty,
      TeNant_cdate,
      TeNant_tax,
      TeNant_ctype,
      TeNant_custno,
      TeNant_ciddoc,
      TeNant_qutser,
      TeNant_verticalGroupValue,
      TeNant_sname,
      TeNant_room_number,
      newValuePDFimg,
      Formbecause_cancel,
      quotxSelectModels,
      transKonModels,
      TitleType_Default_Receipt_Name,
      cc_date,
      w1_date,
      Form_expserPakan,
      Form_PakanAll_pvat,
      fonts_pdf) async {
    final pdf = pw.Document();
    final font = await rootBundle.load('fonts/THSarabunNew.ttf');
    final fontBold = await rootBundle.load('fonts/SarabunBold.ttf');
    var Colors_pd = PdfColors.black;
    final ttf = pw.Font.ttf(font);
    final ttfBold = pw.Font.ttf(fontBold);
    double font_Size = 13.0;

    final bool isServiceDeposit = (Form_expserPakan?.toString() == '25');
    final numberFormat = NumberFormat('#,##0.00');
    final double pakanAmountValue = double.tryParse((Form_PakanAll_pvat ?? '0')
            .toString()
            .trim()
            .replaceAll(',', '')) ??
        0.00;
    final bool hasDepositAmount = pakanAmountValue > 0;
    final String pakanAmount =
        hasDepositAmount ? numberFormat.format(pakanAmountValue) : '';

    final bool checkDepositRent = hasDepositAmount && !isServiceDeposit;
    final bool checkDepositService = hasDepositAmount && isServiceDeposit;

    final String depositRentAmountText =
        checkDepositRent ? pakanAmount : '0.00';
    final String depositServiceAmountText =
        checkDepositService ? pakanAmount : '0.00';
    final String depositTotalAmountText =
        hasDepositAmount ? pakanAmount : '0.00';
    final String depositThaiBahtText =
        hasDepositAmount ? convertToThaiBaht(pakanAmountValue) : '';

    var licence_name1 = 'สิริกร พรหมปัญญา';

    final logoImage = await rootBundle.load('images/choice_logo2.png');
    final logoData = logoImage.buffer.asUint8List();
    final resizedLogo = logoData; // Defined resizedLogo
    var Colors_pd3 = PdfColors.black; // Defined Colors_pd3
    final iconImage =
        (await rootBundle.load('images/LOGO.png')).buffer.asUint8List();
    final ByteData image = await rootBundle.load('images/image7-11.png');
    final ByteData BG_PDF = await rootBundle.load('images/Choice_BG_PDF.png');
    final ByteData LG_PDF = await rootBundle.load('images/choice_logo2.png');
    Uint8List imageData = (image).buffer.asUint8List();
    Uint8List imageBG = (BG_PDF).buffer.asUint8List();
    Uint8List imageLG = (LG_PDF).buffer.asUint8List();
    DateTime now = DateTime.now();
    String dateNowStr =
        '${now.day} ${DateFormat('MMMM', 'th').format(now)} ${now.year + 543}';

    String ccDateStr = '-';
    if (cc_date != null && cc_date.toString() != '0000-00-00') {
      DateTime ccDate = DateTime.parse(cc_date.toString());
      ccDateStr =
          '${ccDate.day} ${DateFormat('MMMM', 'th').format(ccDate)} ${ccDate.year + 543}';
    }
    double widths = PdfPageFormat.a4.width;

    // Calculate total Term from quotxSelectModels

    // double totalDep = 0;
    // double serviceDep = 0;

    // for(var m in transKonModels){
    //    // Logic to separate rental and service deposit if possible
    //    // Assuming structure based on image
    // }
    pw.Widget Textx({
      required String value,
      required pw.Font font,
      double fontSize = 12.5,
      pw.TextAlign align = pw.TextAlign.left,
      pw.FontWeight fontWeight = pw.FontWeight.bold,
      PdfColor? color,
      pw.TextDecoration? decoration,
    }) {
      return pw.Text(
        value,
        textAlign: align,
        style: pw.TextStyle(
          font: font,
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color ?? PdfColors.black,
          decoration: decoration,
        ),
      );
    }

    pw.Widget labeledLine({
      required String value,
      required pw.Font font,
      double fontSize = 12.5,
      required int flex,
      PdfColor? color,
    }) {
      var Colors_pd = PdfColors.black;

      return pw.Expanded(
          flex: flex,
          child: pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: Colors_pd,
                  width: 0.3,
                ),
              ),
            ),
            // padding: const pw.EdgeInsets.only(bottom: -5, top: -5),
            // margin: const pw.EdgeInsets.only(bottom: 5, top: 5),
            //  padding: const pw.EdgeInsets.only(bottom: -3.5),
            child: Textx(
              value: ' ' * 2 + value + ' ' * 2,
              align: pw.TextAlign.center,
              font: font,
              fontSize: fontSize,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ));
    }

    pw.Widget boxX(bool checked) {
      return pw.Container(
        width: 12,
        height: 12,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.black, width: 1),
        ),
        alignment: pw.Alignment.center,
        child: checked
            ? pw.Text(
                '/',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              )
            : null,
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4.copyWith(
            marginBottom: 4.00,
            marginLeft: 8.00,
            marginRight: 8.00,
            marginTop: 8.00,
          ),
          buildBackground: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Opacity(
              opacity: 0.5,
              child: pw.Image(
                pw.MemoryImage(imageBG),
                fit: pw.BoxFit.cover,
              ),
            ),
          ),
        ),
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // pw.Container(
              //   decoration: pw.BoxDecoration(
              //     border: pw.Border.all(
              //       color: PdfColors.black,
              //       width: 0.5,
              //     ),
              //   ),
              //   padding: pw.EdgeInsets.all(5),
              //   child: pw.Column(
              //     children: [

              //     ]
              //   )
              // ),
              pw.Container(
                width: PdfPageFormat.a4.width + 100,
                color: PdfColors.green900,
                height: 13,
              ),
              pw.SizedBox(height: 1 * PdfPageFormat.mm),
              pw.Row(
                children: [
                  pw.Container(
                    width: 30,
                    height: 10,
                  ),
                  pw.Container(
                    height: 60,
                    width: 70,
                    child: pw.Image(
                      pw.MemoryImage(resizedLogo),
                      height: 60,
                      width: 70,
                    ),
                  ),
                  pw.SizedBox(width: 1 * PdfPageFormat.mm),
                  pw.Container(
                    width: 350,
                    child: pw.Column(
                      mainAxisSize: pw.MainAxisSize.min,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        Textx(
                          value: bill_name.toString().trim(),
                          font: ttf,
                        ), //   maxLines: 2,
                        Textx(
                            value: bill_addr.toString().trim(),
                            font: ttf), //   maxLines: 3,
                        Textx(
                            value: 'เลขประจำตัวผู้เสียภาษี : $bill_tax',
                            font: ttf), //   maxLines: 2,
                      ],
                    ),
                  ),
                  pw.Spacer(),
                  if (TitleType_Default_Receipt_Name != null &&
                      TitleType_Default_Receipt_Name.toString().trim() != '' &&
                      TitleType_Default_Receipt_Name.toString().trim() !=
                          'ไม่ระบุ')
                    pw.Padding(
                      padding: const pw.EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: pw.Container(
                        width: 80,
                        decoration: pw.BoxDecoration(
                          // color: PdfColors.grey400,
                          borderRadius: const pw.BorderRadius.only(
                              topLeft: pw.Radius.circular(10),
                              topRight: pw.Radius.circular(10),
                              bottomLeft: pw.Radius.circular(10),
                              bottomRight: pw.Radius.circular(10)),
                          border: pw.Border.all(color: Colors_pd3, width: 1),
                        ),
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Center(
                          child: Textx(
                            value: '$TitleType_Default_Receipt_Name',
                            // maxLines: 1, // Textx doesn't support maxLines yet, but existing code had it
                            fontSize: 20,
                            font: ttf,
                            color: Colors_pd3,
                          ),
                        ),
                      ),
                    ),
                  if (TitleType_Default_Receipt_Name != null &&
                      TitleType_Default_Receipt_Name.toString().trim() != '' &&
                      TitleType_Default_Receipt_Name.toString().trim() !=
                          'ไม่ระบุ')
                    pw.Spacer(),
                ],
              ),
              pw.Center(
                child: Textx(
                    value: 'แบบฟอร์มยกเลิกสัญญา',
                    font: ttf, //  ttf, // ttfBold,,
                    fontSize: font_Size),
              ),
              pw.SizedBox(height: 10),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                Textx(value: 'วันที่แจ้ง ', font: ttf, fontSize: font_Size),
                pw.Container(
                  width: 100,
                  child: labeledLine(value: dateNowStr, font: ttf, flex: 1),
                ),
                pw.Container(width: 50)
              ]),
              pw.SizedBox(height: 5),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
                Textx(
                    value: 'เรื่อง     ยกเลิกสัญญา   วันที่ยกเลิกสัญญา',
                    font: ttf, // ttfBold,,
                    fontSize: font_Size),
                pw.SizedBox(width: 14),
                pw.Container(
                  width: 100,
                  child: labeledLine(value: ccDateStr, font: ttf, flex: 1),
                ),
              ]),
              // pw.SizedBox(height: 5),
              // pw.Divider(thickness: 2),
            ],
          );
        },
        build: (pw.Context context) => [
          // --- Body ---
          pw.SizedBox(height: 15),
          pw.Row(children: [
            Textx(value: 'ชื่อผู้เช่า    ', font: ttf, fontSize: font_Size),
            labeledLine(
              flex: 1,
              value: '${TeNant_bussscontact ?? "-"}',
              font: ttf, // ttfBold,,
              fontSize: font_Size,
            ),
            Textx(
                value: 'จำหน่ายสินค้า/ธุรกิจ  ',
                font: ttf,
                fontSize: font_Size),
            labeledLine(
              flex: 1,
              value: '${TeNant_typeshop ?? "-"}',
              font: ttf, // ttfBold,,
              fontSize: font_Size,
            ),
            Textx(value: '   เลขที่สัญญา   ', font: ttf, fontSize: font_Size),
            labeledLine(
              flex: 1,
              value: '${TeNant_ciddoc ?? "-"}',
              font: ttf, // ttfBold,,
              fontSize: font_Size,
            ),
          ]),
          pw.SizedBox(height: 5),
          pw.Row(children: [
            Textx(value: 'ประเภทการเช่า    ', font: ttf, fontSize: font_Size),
            boxX(TeNant_typeshop == 'พื้นที่หน้าร้าน'),
            Textx(
                value: ' พื้นที่หน้าร้าน    ', font: ttf, fontSize: font_Size),
            boxX(TeNant_typeshop == 'พื้นที่นอกชายคา'),
            Textx(
                value: ' พื้นที่นอกชายคา    ', font: ttf, fontSize: font_Size),
            boxX(TeNant_typeshop == 'ห้องเช่า'),
            Textx(value: ' ห้องเช่า    ', font: ttf, fontSize: font_Size),
            boxX(TeNant_typeshop == 'เครื่องใช้หยอดเหรียญ'),
            Textx(
                value: ' เครื่องใช้หยอดเหรียญ    ',
                font: ttf,
                fontSize: font_Size),
            boxX(TeNant_typeshop == 'เครื่องชั่งน้ำหนัก'),
            Textx(
                value: ' เครื่องชั่งน้ำหนัก    ',
                font: ttf,
                fontSize: font_Size),
            // boxX(![
            //   'พื้นที่หน้าร้าน',
            //   'พื้นที่นอกชายคา',
            //   'ห้องเช่า',
            //   'เครื่องใช้หยอดเหรียญ',
            //   'เครื่องชั่งน้ำหนัก'
            // ].contains(TeNant_typeshop)),
            boxX(false),
            Textx(value: ' อื่นๆ', font: ttf, fontSize: font_Size),
            Textx(
                value: ' _____________________',
                font: ttf,
                fontSize: font_Size),
            labeledLine(value: '-', font: ttf, flex: 1, color: PdfColors.white),
          ]),
          pw.SizedBox(height: 5),
          pw.Row(children: [
            Textx(
                value: 'สถานที่เช่าร้านเซเว่น-อีเลฟเว่น สาขา   ',
                font: ttf,
                fontSize: font_Size),
            labeledLine(
              flex: 1,
              value: '${TeNant_zn ?? "-"}',
              font: ttf, // ttfBold,,
              fontSize: font_Size,
            ),
          ]),
          pw.SizedBox(height: 5),
          pw.Row(children: [
            pw.SizedBox(width: 50),
            Textx(value: 'ล็อคที่   ', font: ttf, fontSize: font_Size),
            pw.Container(
              width: 100,
              child: labeledLine(
                flex: 1,
                value: '${TeNant_ln ?? "-"}',
                font: ttf, // ttfBold,,
                fontSize: font_Size,
              ),
            ),
            Textx(value: '   เนื้อที่   ', font: ttf, fontSize: font_Size),
            pw.Container(
              width: 100,
              child: labeledLine(
                flex: 1,
                value: '${TeNant_area ?? "-"}',
                font: ttf, // ttfBold,,
                fontSize: font_Size,
              ),
            ),
            Textx(value: '   ตร.ม.', font: ttf, fontSize: font_Size),
          ]),
          pw.SizedBox(height: 5),
          pw.Row(children: [
            pw.SizedBox(width: 50),
            Textx(value: 'อาคารเลขที่   ', font: ttf, fontSize: font_Size),
            labeledLine(
              flex: 1,
              value: '${TeNant_room_number ?? "-"}',
              font: ttf, // ttfBold,,
              fontSize: font_Size,
            ),
          ]),
          pw.SizedBox(height: 10),
          pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            Textx(
                value: 'สาเหตุการยกเลิก    ',
                font: ttf, // ttfBold,,
                fontSize: font_Size),
            labeledLine(
              flex: 1,
              value: '${Formbecause_cancel ?? "-"}',
              font: ttf, // ttfBold,,
              fontSize: font_Size,
            ),
          ]),

          // --- Deposit Details ---
          pw.SizedBox(height: 15),
          pw.Center(
              child: Textx(
                  value: 'รายละเอียดเงินประกัน',
                  font: ttf, // ttfBold,,
                  fontSize: font_Size,
                  decoration: pw.TextDecoration.underline)),
          pw.SizedBox(height: 5),

          pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            pw.Expanded(child: pw.SizedBox()),
            pw.Container(
              width: 320,
              child: pw.Table(
                  border: pw.TableBorder.all(
                      color: PdfColors.black,
                      width: 1,
                      style: pw.BorderStyle.solid),
                  columnWidths: {
                    0: pw.FlexColumnWidth(3),
                    1: pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Center(
                            child: Textx(
                                value: 'รายการ',
                                font: ttf,
                                fontSize: font_Size)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Center(
                            child: Textx(
                                value: 'จำนวนเงิน (ไม่รวมภาษี)',
                                font: ttf,
                                fontSize: font_Size)),
                      ),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(
                          padding:
                              pw.EdgeInsets.only(left: 5, top: 4, bottom: 4),
                          child: pw.Row(children: [
                            // pw.Checkbox(
                            //     height: 12,
                            //     checkColor: PdfColors.grey,
                            //     activeColor: PdfColors.white,
                            //     name: 'd1',
                            //     value: checkDepositRent),
                            boxX(checkDepositRent),
                            Textx(
                                value: ' เงินประกันการเช่า',
                                font: ttf,
                                fontSize: font_Size)
                          ])),
                      pw.Padding(
                          padding: pw.EdgeInsets.only(top: 4, bottom: 4),
                          child: pw.Center(
                              child: Textx(
                                  value: depositRentAmountText,
                                  align: pw.TextAlign.center,
                                  font: ttf,
                                  fontSize: font_Size)))
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(
                          padding:
                              pw.EdgeInsets.only(left: 5, top: 4, bottom: 4),
                          child: pw.Row(children: [
                            // pw.Checkbox(
                            //     height: 12,
                            //     checkColor: PdfColors.grey,
                            //     activeColor: PdfColors.white,
                            //     name: 'd2',
                            //     value: checkDepositService),
                            boxX(checkDepositService),
                            Textx(
                                value: ' เงินประกันการบริการ',
                                font: ttf,
                                fontSize: font_Size)
                          ])),
                      pw.Padding(
                          padding: pw.EdgeInsets.only(top: 4, bottom: 4),
                          child: pw.Center(
                              child: Textx(
                                  value: depositServiceAmountText,
                                  align: pw.TextAlign.center,
                                  font: ttf,
                                  fontSize: font_Size)))
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Center(
                            child: Textx(
                                value: 'รวมเงินประกันทั้งสิ้น',
                                font: ttf,
                                fontSize: font_Size)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Center(
                            child: Textx(
                                value: depositTotalAmountText,
                                align: pw.TextAlign.center,
                                font: ttf,
                                fontSize: font_Size)),
                      ),
                    ]),
                  ]),
            ),
            pw.Expanded(
              child: pw.Padding(
                padding: pw.EdgeInsets.only(left: 8, bottom: 2),
                child: pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: Textx(
                    value: depositThaiBahtText,
                    font: ttf,
                    fontSize: font_Size,
                  ),
                ),
              ),
            ),
          ]),

          // --- Refund Options ---
          pw.SizedBox(height: 15),
          Textx(
              value: 'ขอให้ทางบริษัทฯ คืนเงินประกันการเช่า โดย',
              font: ttf, // ttfBold,,
              fontSize: font_Size),
          pw.SizedBox(height: 5),
          pw.Row(children: [
            // pw.Checkbox(
            //     height: 12,
            //     checkColor: PdfColors.grey,
            //     activeColor: PdfColors.white,
            //     name: 'r1',
            //     value: true),
            boxX(true),
            pw.Expanded(
                child: Textx(
                    value:
                        ' คืนเงินประกันการเช่า (กรณีผู้เช่าไม่มีค่าใช้จ่ายค้างชำระ และทำการแจ้งยกเลิกกล่าวหน้า 60 วัน)',
                    font: ttf,
                    fontSize: font_Size)),
          ]),
          pw.Row(children: [
            // pw.Checkbox(
            //     height: 12,
            //     checkColor: PdfColors.grey,
            //     activeColor: PdfColors.white,
            //     name: 'r2',
            //     value: false),
            boxX(false),
            pw.Expanded(
                child: Textx(
                    value:
                        " เงินประกันหักค่าใช้จ่ายคงค้างชำระต่างๆ ทั้งหมด (ส่วนที่เหลือคืนให้กับผู้เช่า / ผู้เช่าชำระเงินส่วนเพิ่ม กรณีเงินประกัน)",
                    font: ttf,
                    fontSize: font_Size)),
          ]),
          pw.Row(children: [
            // pw.Checkbox(
            //     height: 12,
            //     checkColor: PdfColors.grey,
            //     activeColor: PdfColors.white,
            //     name: 'r3',
            //     value: false),
            boxX(false),
            Textx(
                value: ' ไม่คืนเงินประกัน (กรณีผิดสัญญาเช่า)',
                font: ttf,
                fontSize: font_Size),
          ]),
          pw.Padding(
              padding: pw.EdgeInsets.only(left: 30),
              child: pw.Row(children: [
                // pw.Checkbox(
                //     height: 12,
                //     checkColor: PdfColors.grey,
                //     activeColor: PdfColors.white,
                //     name: 'r3_1',
                //     value: false),
                boxX(false),
                pw.Expanded(
                    child: Textx(
                        value:
                            ' เนื่องจาก ผู้เช่าไม่ได้ทำการแจ้งยกเลิกสัญญาล่วงหน้า 60 วัน (ตามเงื่อนไขสัญญา)',
                        font: ttf,
                        fontSize: font_Size)),
              ])),
          pw.Padding(
              padding: pw.EdgeInsets.only(left: 30),
              child: pw.Row(children: [
                // pw.Checkbox(
                //     checkColor: PdfColors.grey,
                //     activeColor: PdfColors.white,
                //     height: 12,
                //     name: 'r3_2',
                //     value: false),
                boxX(false),
                pw.Expanded(
                    child: Textx(
                        value:
                            ' เนื่องจาก ผู้เช่าชำระค่าเช่าเกินกำหนด (ตามเงื่อนไขสัญญา)',
                        font: ttf,
                        fontSize: font_Size)),
              ])),
          pw.Row(children: [
            // pw.Checkbox(
            //     activeColor: PdfColors.grey, // Color when checked
            //     checkColor: PdfColors.white, // Color of the check icon
            //     height: 12,
            //     name: 'r3_3',
            //     value: false),
            boxX(false),
            Textx(value: ' อื่นๆ ', font: ttf, fontSize: font_Size),
            pw.Container(
              width: 350,
              child: labeledLine(
                flex: 1,
                value: '${Formbecause_cancel ?? "-"}',
                font: ttf, // ttfBold,,
                fontSize: font_Size,
              ),
            )
          ]),

          pw.SizedBox(height: 10),
          Textx(
              value:
                  'หมายเหตุ   1  บริษัทฯ จะทำการคืนเงินประกันการเช่าให้แก่ผู้เช่าภายในระยะเวลา 45 วัน (นับตั้งแต่วันที่ผู้เช่าส่งมอบพื้นที่คืนให้กับบริษัทฯ เป็นที่เรียบร้อยแล้ว)',
              font: ttf,
              fontSize: 12),
          Textx(
              value:
                  '               2  บริษัทฯ จะทำการคืนเงินประกันโดยการโอนเงินผ่านบัญชีธนาคาร โดยมีค่าธรรมเนียมในการโอน (บัญชีธนาคารกรุงเทพ 5 บาท , ธนาคารอื่น 10 บาท )',
              font: ttf,
              fontSize: 12),

          // --- Signature Section ---
          pw.SizedBox(height: 20),
          pw.Table(
              columnWidths: {
                0: pw.FlexColumnWidth(1),
                1: pw.FlexColumnWidth(1),
                2: pw.FlexColumnWidth(1),
              },
              border: pw.TableBorder.all(
                  color: PdfColors.black,
                  width: 0.5,
                  style: pw.BorderStyle.solid),
              children: [
                pw.TableRow(children: [
                  // -- 1. ผู้เช่า --
                  pw.Container(
                      padding:
                          pw.EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                      child: pw.Column(children: [
                        Textx(
                            value: 'ผู้เช่า',
                            font: ttf,
                            fontSize: font_Size,
                            decoration: pw.TextDecoration.underline),
                        pw.SizedBox(height: 30),
                        // pw.Divider(thickness: 0.5, color: PdfColors.black),
                        pw.Row(children: [
                          Textx(
                            value: 'ลงชื่อ ',
                            font: ttf,
                            fontSize: font_Size,
                          ),
                          pw.Expanded(
                            child: labeledLine(
                              value: '-',
                              font: ttf,
                              flex: 1,
                              color: PdfColors.white,
                            ),
                          ),
                        ]),
                        pw.SizedBox(height: 5),
                        pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              Textx(
                                  value: '( ${TeNant_bussscontact ?? "-"} )',
                                  font: ttf,
                                  fontSize: font_Size),
                            ]),
                        Textx(value: 'ผู้เช่า', font: ttf, fontSize: font_Size),
                        Textx(
                            value: '........../........../..........',
                            font: ttf,
                            fontSize: font_Size),
                      ])),

                  // -- 2. เสนอโดย --
                  pw.Container(
                      padding:
                          pw.EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                      child: pw.Column(children: [
                        Textx(
                            value: 'เสนอโดย',
                            font: ttf,
                            fontSize: font_Size,
                            decoration: pw.TextDecoration.underline),
                        pw.SizedBox(height: 30),
                        pw.Row(children: [
                          Textx(
                            value: 'ลงชื่อ ',
                            font: ttf,
                            fontSize: font_Size,
                          ),
                          pw.Expanded(
                            child: labeledLine(
                              value: '-',
                              font: ttf,
                              flex: 1,
                              color: PdfColors.white,
                            ),
                          ),
                        ]),
                        pw.SizedBox(height: 5),
                        pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              Textx(
                                  value: '( ${licence_name1 ?? "-"} )',
                                  font: ttf,
                                  fontSize: font_Size),
                            ]),
                        Textx(
                            value: 'แผนกบริหารพื้นที่เช่า',
                            font: ttf,
                            fontSize: font_Size,
                            fontWeight: pw.FontWeight.normal),
                        Textx(
                            value: '........../........../..........',
                            font: ttf,
                            fontSize: font_Size,
                            fontWeight: pw.FontWeight.normal),
                      ])),

                  // -- 3. อนุมัติโดย --
                  pw.Container(
                      padding:
                          pw.EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                      child: pw.Column(children: [
                        Textx(
                            value: 'อนุมัติโดย',
                            font: ttf,
                            fontSize: font_Size,
                            decoration: pw.TextDecoration.underline),
                        pw.SizedBox(height: 30),
                        pw.Row(children: [
                          Textx(
                            value: 'ลงชื่อ ',
                            font: ttf,
                            fontSize: font_Size,
                          ),
                          pw.Expanded(
                            child: labeledLine(
                              value: '-',
                              font: ttf,
                              flex: 1,
                              color: PdfColors.white,
                            ),
                          ),
                        ]),
                        pw.SizedBox(height: 5),
                        pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              Textx(
                                  value: '( เกศแก้ว สุภา )',
                                  font: ttf,
                                  fontSize: font_Size),
                              // pw.Spacer(),
                            ]),
                        Textx(
                            value: 'ผู้จัดการทั่วไป สายงานพัฒนาธุรกิจ',
                            font: ttf,
                            fontSize: font_Size),
                        Textx(
                            value: '........../........../..........',
                            font: ttf,
                            fontSize: font_Size),
                      ])),
                ]),
              ]),
          // pw.SizedBox(height: 20),
        ],
        footer: (context) {
          // // -------------------------------------------------------------
          // final int firstSection = 2; // ชุดแรกมี 2 หน้า
          // final int secondSection =
          //     (context.pagesCount - firstSection).clamp(0, 1 << 30);

          // final String pageLabel = (context.pageNumber <= firstSection)
          //     ? "${context.pageNumber}/$firstSection"
          //     : "${context.pageNumber - firstSection}/$secondSection";

          // // ✅ รวมเลขหน้ากับข้อความด้านขวา
          // String rightText = '';
          // if (context.pageNumber == 1) {
          //   rightText = '$pageLabel... ข้อ 7. ค่าเช่าสาธารณูปโภค...';
          // } else if (context.pageNumber == 2) {
          //   rightText = '';
          // } else if (context.pageNumber == 3) {
          //   rightText = '$pageLabel... 2.12 การชำระเงินประกัน...';
          // } else if (context.pageNumber == 4) {
          //   rightText = '$pageLabel... 3.8 หากผู้ให้เช่าช่วงมีความ...';
          // } else if (context.pageNumber == 5) {
          //   rightText = '$pageLabel... สัญญานี้ทำขึ้นเป็น 2 ฉบับ...';
          // } else {
          //   rightText = '';
          // }

          // -------------------------------------------------------------
          return pw.Column(
            children: [
              // ====== บรรทัดตัวเลขและข้อความ ======
              // pw.Container(
              //   width: PdfPageFormat.a4.width,
              //   padding: const pw.EdgeInsets.fromLTRB(40, 0, 40, 0),
              //   child: pw.Stack(
              //     alignment: pw.Alignment.center,
              //     children: [
              //       // 🔹 ตัวเลขอยู่กลาง
              //       pw.Align(
              //         alignment: pw.Alignment.center,
              //         child: pw.Text(
              //           pageLabel,
              //           textAlign: pw.TextAlign.center,
              //           style: pw.TextStyle(
              //             fontWeight: pw.FontWeight.bold,
              //             color: Colors_pd,
              //             fontSize: font_Size,
              //             font: ttf,
              //           ),
              //         ),
              //       ),

              //       // 🔹 ข้อความอยู่ขวา + กล่องเปล่าด้านหลัง
              //       pw.Align(
              //         alignment: pw.Alignment.centerRight,
              //         child: pw.Row(
              //           mainAxisSize:
              //               pw.MainAxisSize.min, // ให้ Row กว้างเท่าที่จำเป็น
              //           children: [
              //             pw.Text(
              //               rightText,
              //               textAlign: pw.TextAlign.right,
              //               style: pw.TextStyle(
              //                 fontWeight: pw.FontWeight.bold,
              //                 color: Colors_pd,
              //                 fontSize: font_Size,
              //                 font: ttf,
              //               ),
              //             ),
              //             pw.SizedBox(width: 7),
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              // ====== แถบสีและโลโก้ด้านล่าง ======
              pw.Stack(
                children: [
                  // 🔸 แถบสี 3 ชั้น
                  pw.Container(
                    width: PdfPageFormat.a4.width,
                    height: 55,
                    child: pw.Center(
                      child: pw.Container(
                        width: widths,
                        height: 25,
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          mainAxisSize: pw.MainAxisSize.min,
                          children: [
                            pw.Row(children: [
                              pw.Expanded(
                                child: pw.Container(
                                  color: PdfColors.red,
                                  height: 5,
                                ),
                              )
                            ]),
                            pw.Row(children: [
                              pw.Expanded(
                                child: pw.Container(
                                  color: PdfColors.green900,
                                  height: 8,
                                ),
                              )
                            ]),
                            pw.Row(children: [
                              pw.Expanded(
                                child: pw.Container(
                                  color: PdfColors.red,
                                  height: 5,
                                ),
                              )
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 🔸 โลโก้มุมขวา
                  pw.Positioned(
                    top: 4,
                    right: 50,
                    child: pw.Container(
                      width: 50.0,
                      height: 50.0,
                      child: pw.Image(pw.MemoryImage(imageData)),
                    ),
                  ),

                  // 🔸 ข้อความบริษัท (ซ้ายบน)
                  pw.Positioned(
                    top: 4,
                    left: 40,
                    child: pw.Container(
                      width: PdfPageFormat.a4.width - 150,
                      child: pw.Text(
                        "CHOICE MINI STORE CO., LTD. 7/11 VILLAGE NO.5, THA SALA SUB-DISTRICT, MUEANG CHIANG MAI DISTRICT, CHIANG MAI PROVINCE 50000",
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          color: Colors_pd,
                          fontSize: font_Size - 4,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                        ),
                      ),
                    ),
                  ),

                  // 🔸 ข้อความลิขสิทธิ์ (ขวาล่าง)
                  pw.Positioned(
                    bottom: 4,
                    right: 120,
                    child: pw.Text(
                      "Sub Area Licencee: Chiang Mai, Lamphun, Mae-Hong-Son",
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: Colors_pd,
                        fontSize: font_Size - 4,
                        font: ttf,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewPdfgen_Billsplay(
              doc: pdf, title: 'ใบยกเลิกสัญญาเช่า($TeNant_ciddoc)'),
        ));
    // Printing.layoutPdf(
    //   onLayout: (PdfPageFormat format) async => pdf.save(),
    // );
  }
}
