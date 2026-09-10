import 'dart:math';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ChaoArea/ChaoAreaRenew_Screen.dart';
import '../../Man_PDF/Preview_PDF/Preview_RentalInforma.dart';
import '../../Model/GetC_Quot_Select_Model.dart';
import '../../PeopleChao/Rental_Information.dart';
import '../../Style/LaoBaht.dart';
import '../../Style/ThaiBaht.dart';
import '../../Style/loadAndCacheImage.dart';

///////-------------------------------------------> ( ใบเสนอราคา/สัญญาเช่าพื้นที่ )
class Pdfgen_RentalInformaLao {
  static void exportPDF_RentalInformaLao(
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
      Form_cdate,
      quotxSelectModels,
      _TransModels,
      renTal_name,
      bill_addr,
      bill_email,
      bill_tel,
      bill_tax,
      bill_name,
      newValuePDFimg,
      Form_addmin) async {
    final pdf = pw.Document();
    // Load fonts with Lao as primary font
    final laoFontData = await rootBundle.load("fonts/NotoSansLao.ttf");
    final thaiFontData = await rootBundle.load("fonts/THSarabunNew.ttf");

    final laoFont = pw.Font.ttf(laoFontData);
    final thaiFont = pw.Font.ttf(thaiFontData);

    // Variables
    var Colors_pd = PdfColors.black;
    double font_Size = 8.0;
    final ttf = laoFont; // Use Lao font as primary

    // Helper function to create text with font fallback
    pw.Text textWithFallback(
      String text, {
      double? fontSize,
      PdfColor? color,
      pw.TextAlign? textAlign,
      double? laoFontSize,
      double? thaiFontSize,
    }) {
      final bool hasThai = text.contains(RegExp(r'[ก-๙]'));
      return pw.Text(
        text,
        textAlign: textAlign,
        style: pw.TextStyle(
          font: laoFont,
          fontFallback: [thaiFont],
          fontSize:
              hasThai ? (thaiFontSize ?? 10.0) : (laoFontSize ?? font_Size),
          color: color ?? Colors_pd,
        ),
      );
    }

    DateTime date = DateTime.now();
    var formatter = new DateFormat.MMMMd('th_TH');
    String thaiDate = formatter.format(date);
    var nFormat = NumberFormat("#,##0.00", "en_US");
    final iconImage =
        (await rootBundle.load('images/LOGO.png')).buffer.asUint8List();
    List netImage = [];
    Uint8List? resizedLogo = await getResizedLogo();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    // for (int i = 0; i < newValuePDFimg.length; i++) {
    //   netImage.add(await networkImage('${newValuePDFimg[i]}'));
    // }
    ///////////////////////------------------------------------------------->
    // // Your date string

    // String dateString = '${Form_cdate}';

    // // Parse the date string into a DateTime object
    // DateTime date_thai = DateTime.parse(dateString);
    // List<String> dateParts = dateString.split('-');

    // // The first part (index 0) will be the year
    // String year = dateParts[0];
    // // Define a Thai date format

    // var thaiDateFormat = new DateFormat.MMMMd('th_TH');
    // // Format the date in Thai date format
    // String thai_Date = thaiDateFormat.format(date_thai);
    ///////////////////////------------------------------------------------->

    ///////////////////////------------------------------------------------->
    // final tableHeaders = [
    //   'งวด',
    //   'รายการ',
    //   'วันที่',
    //   'ยอด/งวด',
    //   'ยอด',
    // ];
    quotxSelectModels = quotxSelectModels
      ..sort((QuotxSelectModel a, QuotxSelectModel b) {
        // เรียงตาม exptser ก่อน (น้อยไปมาก)
        final exptserA = int.tryParse(a.exptser ?? '0') ?? 0;
        final exptserB = int.tryParse(b.exptser ?? '0') ?? 0;
        if (exptserA != exptserB) return exptserA.compareTo(exptserB);

        // ถ้า exptser เท่ากัน ให้เรียงตามอักษร (ลบอักขระที่ไม่ใช่ตัวอักษรออก)
        final nameA = (a.expname ?? '').replaceAll(RegExp(r'[^ก-๙a-zA-Z]'), '');
        final nameB = (b.expname ?? '').replaceAll(RegExp(r'[^ก-๙a-zA-Z]'), '');
        return nameA.compareTo(nameB);
      });
    // ===== นับจำนวนแถวที่จะแสดงในหน้า 1 =====
    int totalRowsPage1 = 0;
    for (int index = 0; index < quotxSelectModels.length; index++) {
      final model = quotxSelectModels[index];
      final bool hasAmtTy = model.amt_ty != null && model.amt_ty!.isNotEmpty;
      if (!hasAmtTy) {
        totalRowsPage1 += 1;
      } else {
        final List<String> rawAmtList = model.amt_ty!.split(',');
        double? current;
        int groupCount = 0;
        for (final v in rawAmtList) {
          final val = double.tryParse(v) ?? 0;
          if (current == null || val == current) {
            if (current == null) current = val;
          } else {
            groupCount++;
            current = val;
          }
        }
        if (current != null) groupCount++;
        totalRowsPage1 += groupCount;
      }
      if (totalRowsPage1 >= 9) break;
    }

    // ===== หาตำแหน่งที่ตัดหน้า =====
    int pageBreakAtIndex = 0;
    int rowsCount = 0;
    for (int index = 0; index < quotxSelectModels.length; index++) {
      final model = quotxSelectModels[index];
      final bool hasAmtTy = model.amt_ty != null && model.amt_ty!.isNotEmpty;
      int modelRows = 0;
      if (!hasAmtTy) {
        modelRows = 1;
      } else {
        final List<String> rawAmtList = model.amt_ty!.split(',');
        double? current;
        int groupCount = 0;
        for (final v in rawAmtList) {
          final val = double.tryParse(v) ?? 0;
          if (current == null || val == current) {
            if (current == null) current = val;
          } else {
            groupCount++;
            current = val;
          }
        }
        if (current != null) groupCount++;
        modelRows = groupCount;
      }
      if (rowsCount + modelRows > 9) {
        pageBreakAtIndex = index;
        break;
      }
      rowsCount += modelRows;
      pageBreakAtIndex = index + 1;
    }

    double total_ = 0.0;
    // final tableData = [
    for (int index = 0; index < quotxSelectModels.length; index++) {
      // ถ้า amt_ty ไม่ว่างและ totals มีค่า ให้ใช้ totals
      if (quotxSelectModels[index].amt_ty != null &&
          quotxSelectModels[index].amt_ty.toString().isNotEmpty) {
        total_ += double.tryParse(
                quotxSelectModels[index].totals?.toString() ?? "0.00") ??
            0.00;
      } else {
        total_ += (int.tryParse(quotxSelectModels[index].term ?? "0") ?? 0) *
            (double.tryParse(quotxSelectModels[index].total ?? "0.00") ?? 0.00);
      }
    }
    int rowNo = 1;

    double total_1 = 0.00;

    for (int index = 0; index < quotxSelectModels.length; index++) {
      final model = quotxSelectModels[index];
      final bool hasAmtTy = model.amt_ty != null && model.amt_ty!.isNotEmpty;

      if (hasAmtTy) {
        // ถ้ามี amt_ty ให้หาค่า unique และบวกเฉพาะค่าที่ไม่ซ้ำ
        final List<String> rawAmtList = model.amt_ty!.split(',');
        Set<double> uniqueValues = {};

        for (final v in rawAmtList) {
          final val = double.tryParse(v) ?? 0;
          uniqueValues.add(val);
        }

        // บวกค่า unique ทั้งหมด
        for (final uniqueVal in uniqueValues) {
          total_1 += uniqueVal;
        }
      } else {
        // ถ้าไม่มี amt_ty ใช้สูตรเดิม
        total_1 += double.tryParse(model.total?.toString() ?? "0.0") ?? 0.0;
      }
    }

    //     [
    //       '${quotxSelectModels[index].unit} / ${quotxSelectModels[index].term} (งวด)',
    //       '${quotxSelectModels[index].expname}',
    //       '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${quotxSelectModels[index].sdate!} 00:00:00'))} - ${DateFormat('dd-MM-yyyy').format(DateTime.parse('${quotxSelectModels[index].ldate!} 00:00:00'))}',
    //       '${nFormat.format(double.parse(quotxSelectModels[index].total!))}',
    //       '${nFormat.format(int.parse(quotxSelectModels[index].term!) * double.parse(quotxSelectModels[index].total!))}',
    //     ],
    // ];
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
                              fontSize: font_Size,
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
                //     : pw.Image(
                //         (netImage[0]),
                //         height: 72,
                //         width: 70,
                //       ),
                pw.SizedBox(width: 4 * PdfPageFormat.mm),
                pw.Container(
                  // width: 250,
                  child: pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${bill_name.toString().trim()}',
                        maxLines: 2,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          // fontWeight: pw.FontWeight.bold,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.Text(
                        'ທີ່ຢູ່: $bill_addr',
                        maxLines: 3,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          color: Colors_pd,
                          font: ttf,
                        ),
                      ),
                      pw.Text(
                        (bill_tax == null ||
                                bill_tax.toString() == '' ||
                                bill_tax.toString() == 'null')
                            ? 'ເລກປະຈຳຕົວຜູ້ເສຍພາສີ: 0'
                            : 'ເລກປະຈຳຕົວຜູ້ເສຍພາສີ: $bill_tax',
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
                        (bill_tel == null ||
                                bill_tel.toString() == '' ||
                                bill_tel.toString() == 'null')
                            ? 'ໂທລະສັບ: '
                            : 'ໂທລະສັບ: $bill_tel',
                        textAlign: pw.TextAlign.right,
                        maxLines: 1,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),
                      pw.Text(
                        (bill_email == null ||
                                bill_email.toString() == '' ||
                                bill_email.toString() == 'null')
                            ? 'ອີເມວ: '
                            : 'ອີເມວ: $bill_email',
                        maxLines: 1,
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                          fontSize: font_Size,
                          font: ttf,
                          color: Colors_pd,
                        ),
                      ),

                      pw.Text(
                        (Form_cdate.toString() == '0000-00-00' ||
                                Form_cdate == null)
                            ? 'ວັນທີ່: ${Form_sdate}'
                            : 'ວັນທີ່: ${Form_cdate}',
                        //pdf_AC_his_statusbill.dart 'ณ วันที่:  ${thai_Date} ${int.parse(year) + 543}',
                        //'ณ วันที่:  $thaiDate ${DateTime.now().year + 543}',
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
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Divider(),
            pw.SizedBox(height: 4 * PdfPageFormat.mm),
          ]);
        },
        build: (context) {
          return [
            // pw.Row(
            //   children: [
            //     pw.Image(
            //       pw.MemoryImage(iconImage),
            //       height: 72,
            //       width: 72,
            //     ),
            //     pw.SizedBox(width: 1 * PdfPageFormat.mm),
            //     pw.Column(
            //       mainAxisSize: pw.MainAxisSize.min,
            //       crossAxisAlignment: pw.CrossAxisAlignment.start,
            //       children: [
            //         pw.Text(
            //           'บริษัทดีเซนทริค จำกัด(Dzentric co., ltd.)',
            //           style: pw.TextStyle(
            //             fontSize: 14.0,
            //             fontWeight: pw.FontWeight.bold,
            //             font: ttf,
            //           ),
            //         ),
            //         pw.Text(
            //           '1-8 ถ.รัตนโกสินทร์ ต.ศรีภูมิ อ.เมือง จ.เชียงใหม่ 50200',
            //           style: pw.TextStyle(
            //             fontSize: 10.0,
            //             color: PdfColors.grey700,
            //             font: ttf,
            //           ),
            //         ),
            //       ],
            //     ),
            //     pw.Spacer(),
            //     pw.Container(
            //       width: 180,
            //       child: pw.Column(
            //         mainAxisSize: pw.MainAxisSize.min,
            //         crossAxisAlignment: pw.CrossAxisAlignment.end,
            //         children: [
            //           pw.Text(
            //             'ข้อมูลพื้นที่',
            //             textAlign: pw.TextAlign.center,
            //             style: pw.TextStyle(
            //                 fontSize: 11.0,
            //                 fontWeight: pw.FontWeight.bold,
            //                 font: ttf,
            //                 color: PdfColors.black),
            //           ),
            //           pw.SizedBox(height: 2 * PdfPageFormat.mm),
            //           pw.Text(
            //             'รหัสพื้นที่ {NumberArea_}',
            //             textAlign: pw.TextAlign.right,
            //             style: pw.TextStyle(
            //                 fontSize: 10.0, font: ttf, color: PdfColors.black),
            //           ),
            //           pw.Text(
            //             'ณ วันที่: ${DateTime.now().day.toString()}/${DateTime.now().month.toString()}/${DateTime.now().year.toString()}',
            //             textAlign: pw.TextAlign.right,
            //             style: pw.TextStyle(
            //                 fontSize: 10.0, font: ttf, color: PdfColors.black),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ],
            // ),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'ໃບສະເໜີລາຄາ',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontSize: font_Size,
                    font: ttf,
                    fontWeight: pw.FontWeight.bold,
                    color: Colors_pd,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 4 * PdfPageFormat.mm),
            pw.Align(
              alignment: pw.Alignment.center,
              child: pw.Container(
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.Text(
                          'ຂໍ້ມູນຜູ້ເຊົ່າ',
                          textAlign: pw.TextAlign.left,
                          style: pw.TextStyle(
                            fontSize: font_Size,
                            font: ttf,
                            fontWeight: pw.FontWeight.bold,
                            color: Colors_pd,
                          ),
                        ),
                      ],
                    ),
                    // pw.SizedBox(height: 4 * PdfPageFormat.mm),
                    // pw.Row(children: [
                    //   pw.Expanded(
                    //     flex: 1,
                    //     child: pw.Container(
                    //       decoration: pw.BoxDecoration(
                    //           color: PdfColors.green100,
                    //           border: pw.Border(
                    //               bottom: pw.BorderSide(
                    //             color: PdfColors.green900,
                    //             width: 1.0, // Underline thickness
                    //           ))),
                    //       padding: const pw.EdgeInsets.all(8.0),
                    //       child: pw.Text(
                    //         'ข้อมูลผู้เช่า',
                    //         textAlign: pw.TextAlign.center,
                    //         style: pw.TextStyle(
                    //             fontSize: font_Size,
                    //             fontWeight: pw.FontWeight.bold,
                    //             font: ttf,
                    //             color: PdfColors.green900),
                    //       ),
                    //     ),
                    //   )
                    // ]),
                    pw.SizedBox(height: 4 * PdfPageFormat.mm),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            'ປະເພດຮ້ານຄ້າ:',
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              fontWeight: pw.FontWeight.bold,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border(
                                    bottom: pw.BorderSide(
                              color: PdfColors.grey200, //grey200
                              width: 2.0, // Underline thickness
                            ))),
                            // child: pw.Text(
                            //   (_verticalGroupValue.toString().isNotEmpty)
                            //       ? '$_verticalGroupValue'
                            //       : ' - ',
                            //   textAlign: pw.TextAlign.center,
                            //   style: pw.TextStyle(
                            //     fontSize: font_Size,
                            //     // fontWeight: pw.FontWeight.bold,
                            //     font: ttf,
                            //     color: Colors_pd,
                            //   ),
                            // ),
                            child: textWithFallback(
                              (_verticalGroupValue.toString().isNotEmpty)
                                  ? '$_verticalGroupValue'
                                  : ' - ',
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            Get_Value_NameShop_index.toString() == '1'
                                ? 'ເລກທີ່ສັນຍາ : '
                                : 'ເລກທີ່ໃບສະເໜີລາຄາ : ',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              fontWeight: pw.FontWeight.bold,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border(
                                    bottom: pw.BorderSide(
                              color: PdfColors.grey200,
                              width: 2.0, // Underline thickness
                            ))),
                            // child: pw.Text(
                            //   (Get_Value_cid.toString().isNotEmpty)
                            //       ? '$Get_Value_cid'
                            //       : ' - ',
                            //   textAlign: pw.TextAlign.center,
                            //   style: pw.TextStyle(
                            //     fontSize: font_Size,
                            //     // fontWeight: pw.FontWeight.bold,
                            //     font: ttf,
                            //     color: Colors_pd,
                            //   ),
                            // ),
                            child: textWithFallback(
                              (Get_Value_cid.toString().isNotEmpty)
                                  ? '$Get_Value_cid'
                                  : ' - ',
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 2 * PdfPageFormat.mm),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            'ຊື່ຮ້ານ : ',
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              fontWeight: pw.FontWeight.bold,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border(
                                    bottom: pw.BorderSide(
                              color: PdfColors.grey200,
                              width: 2.0, // Underline thickness
                            ))),
                            child: textWithFallback(
                              (Form_nameshop.toString().isNotEmpty)
                                  ? '$Form_nameshop'
                                  : ' - ',
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            'ປະເພດຮ້ານຄ້າ:',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              fontWeight: pw.FontWeight.bold,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border(
                                    bottom: pw.BorderSide(
                              color: PdfColors.grey200,
                              width: 2.0, // Underline thickness
                            ))),
                            // child: pw.Text(
                            //   (Form_typeshop.toString().isNotEmpty)
                            //       ? '$Form_typeshop'
                            //       : ' - ',
                            //   textAlign: pw.TextAlign.center,
                            //   style: pw.TextStyle(
                            //     fontSize: font_Size,
                            //     // fontWeight: pw.FontWeight.bold,
                            //     font: ttf,
                            //     color: Colors_pd,
                            //   ),
                            // ),
                            child: textWithFallback(
                              (Form_typeshop.toString().isNotEmpty)
                                  ? '$Form_typeshop'
                                  : ' - ',
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 2 * PdfPageFormat.mm),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            'ຊື່ຜູ້ເຊົ່າ/ບໍລິສັດ : ',
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              fontWeight: pw.FontWeight.bold,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border(
                                    bottom: pw.BorderSide(
                              color: PdfColors.grey200,
                              width: 2.0, // Underline thickness
                            ))),
                            // child: pw.Text(
                            //   (Form_bussshop.toString().isNotEmpty)
                            //       ? '$Form_bussshop'
                            //       : ' - ',
                            //   textAlign: pw.TextAlign.center,
                            //   style: pw.TextStyle(
                            //     fontSize: font_Size,
                            //     // fontWeight: pw.FontWeight.bold,
                            //     font: ttf,
                            //     color: Colors_pd,
                            //   ),
                            // ),
                            child: textWithFallback(
                              (Form_bussshop.toString().isNotEmpty)
                                  ? '$Form_bussshop'
                                  : ' - ',
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            'ຊື່ຜູ້ຕິດຕໍ່ :',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              fontWeight: pw.FontWeight.bold,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border(
                                    bottom: pw.BorderSide(
                              color: PdfColors.grey200,
                              width: 2.0, // Underline thickness
                            ))),
                            // child: pw.Text(
                            //   (Form_bussscontact.toString().isNotEmpty)
                            //       ? '$Form_bussscontact'
                            //       : ' - ',
                            //   textAlign: pw.TextAlign.center,
                            //   style: pw.TextStyle(
                            //     fontSize: font_Size,
                            //     // fontWeight: pw.FontWeight.bold,
                            //     font: ttf,
                            //     color: Colors_pd,
                            //   ),
                            // ),
                            child: textWithFallback(
                              (Form_bussscontact.toString().isNotEmpty)
                                  ? '$Form_bussscontact'
                                  : ' - ',
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 2 * PdfPageFormat.mm),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            'ທີ່ຢູ່ : ',
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              fontWeight: pw.FontWeight.bold,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 6,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border(
                                    bottom: pw.BorderSide(
                              color: PdfColors.grey200,
                              width: 2.0, // Underline thickness
                            ))),
                            // child: pw.Text(
                            //   (Form_address.toString().isNotEmpty)
                            //       ? '$Form_address'
                            //       : ' - ',
                            //   textAlign: pw.TextAlign.center,
                            //   style: pw.TextStyle(
                            //     fontSize: font_Size,
                            //     // fontWeight: pw.FontWeight.bold,
                            //     font: ttf,
                            //     color: Colors_pd,
                            //   ),
                            // ),
                            child: textWithFallback(
                              (Form_address.toString().isNotEmpty)
                                  ? '$Form_address'
                                  : ' - ',
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 2 * PdfPageFormat.mm),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            'ID/TAX ID : ',
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              fontWeight: pw.FontWeight.bold,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 6,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border(
                                    bottom: pw.BorderSide(
                              color: PdfColors.grey200,
                              width: 2.0, // Underline thickness
                            ))),
                            // decoration: pw.BoxDecoration(
                            //     border: pw.Border(
                            //         bottom: pw.BorderSide(
                            //   color: Colors_pd,
                            //   width: 1.0, // Underline thickness
                            // ))),
                            // child: pw.Text(
                            //   (Form_tax.toString().isNotEmpty)
                            //       ? '$Form_tax'
                            //       : ' - ',
                            //   textAlign: pw.TextAlign.center,
                            //   style: pw.TextStyle(
                            //     fontSize: font_Size,
                            //     // fontWeight: pw.FontWeight.bold,
                            //     font: ttf,
                            //     color: Colors_pd,
                            //   ),
                            // ),
                            child: textWithFallback(
                              (Form_tax.toString().isNotEmpty)
                                  ? '$Form_tax'
                                  : ' - ',
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 2 * PdfPageFormat.mm),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            'ເບີໂທ : ',
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              fontWeight: pw.FontWeight.bold,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border(
                                    bottom: pw.BorderSide(
                              color: PdfColors.grey200,
                              width: 2.0, // Underline thickness
                            ))),
                            // child: pw.Text(
                            //   (Form_tel.toString().isNotEmpty)
                            //       ? '$Form_tel'
                            //       : ' - ',
                            //   textAlign: pw.TextAlign.center,
                            //   style: pw.TextStyle(
                            //     fontSize: font_Size,
                            //     // fontWeight: pw.FontWeight.bold,
                            //     font: ttf,
                            //     color: Colors_pd,
                            //   ),
                            // ),
                            child: textWithFallback(
                              (Form_tel.toString().isNotEmpty)
                                  ? '$Form_tel'
                                  : ' - ',
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            'ອີເມວ :',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              fontWeight: pw.FontWeight.bold,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(
                            decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                    bottom: pw.BorderSide(
                              color: PdfColors.grey200,
                              width: 2.0, // Underline thickness
                            ))),
                            // child: pw.Text(
                            //   (Form_email.toString().isNotEmpty)
                            //       ? '$Form_email'
                            //       : ' - ',
                            //   textAlign: pw.TextAlign.center,
                            //   style: pw.TextStyle(
                            //     fontSize: font_Size,
                            //     // fontWeight: pw.FontWeight.bold,
                            //     font: ttf,
                            //     color: Colors_pd,
                            //   ),
                            // ),
                            child: textWithFallback(
                              (Form_email.toString().isNotEmpty)
                                  ? '$Form_email'
                                  : ' - ',
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // pw.SizedBox(height: 2 * PdfPageFormat.mm),
                    // pw.Divider(
                    //   height: 1.0,
                    //   color: PdfColors.green900,
                    // ),
                    // pw.SizedBox(height: 4 * PdfPageFormat.mm),
                    // pw.Row(children: [
                    //   pw.Expanded(
                    //     flex: 1,
                    //     child: pw.Container(
                    //       decoration: pw.BoxDecoration(
                    //           color: PdfColors.green100,
                    //           border: pw.Border(
                    //               bottom: pw.BorderSide(
                    //             color: PdfColors.green900,
                    //             width: 1.0, // Underline thickness
                    //           ))),
                    //       padding: const pw.EdgeInsets.all(8.0),
                    //       child: pw.Text(
                    //         'พื้นที่เช่า ',
                    //         textAlign: pw.TextAlign.center,
                    //         style: pw.TextStyle(
                    //             fontSize: 10.0,
                    //             fontWeight: pw.FontWeight.bold,
                    //             font: ttf,
                    //             color: PdfColors.green900),
                    //       ),
                    //     ),
                    //   )
                    // ]),
                    pw.SizedBox(height: 2 * PdfPageFormat.mm),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            'ລະຫັດພື້ນທີ່ເຊົ່າ : ',
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              fontWeight: pw.FontWeight.bold,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border(
                                    bottom: pw.BorderSide(
                              color: PdfColors.grey200,
                              width: 2.0, // Underline thickness
                            ))),
                            // child: pw.Text(
                            //   (Form_ln.toString().isNotEmpty)
                            //       ? '$Form_ln'
                            //       : ' - ',
                            //   textAlign: pw.TextAlign.center,
                            //   style: pw.TextStyle(
                            //     fontSize: font_Size,
                            //     // fontWeight: pw.FontWeight.bold,
                            //     font: ttf,
                            //     color: Colors_pd,
                            //   ),
                            // ),
                            child: textWithFallback(
                              (Form_ln.toString().isNotEmpty)
                                  ? '$Form_ln'
                                  : ' - ',
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            'ໂຊນພື້ນທີ່ເຊົ່າ :',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              fontWeight: pw.FontWeight.bold,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border(
                                    bottom: pw.BorderSide(
                              color: PdfColors.grey200,
                              width: 2.0, // Underline thickness
                            ))),
                            // child: pw.Text(
                            //   (Form_zn.toString().isNotEmpty)
                            //       ? '$Form_zn'
                            //       : ' - ',
                            //   textAlign: pw.TextAlign.center,
                            //   style: pw.TextStyle(
                            //     fontSize: font_Size,
                            //     // fontWeight: pw.FontWeight.bold,
                            //     font: ttf,
                            //     color: Colors_pd,
                            //   ),
                            // ),
                            child: textWithFallback(
                              (Form_zn.toString().isNotEmpty)
                                  ? '$Form_zn'
                                  : ' - ',
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 2 * PdfPageFormat.mm),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            'ລວມພື້ນທີ່ເຊົ່າ: ',
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              fontWeight: pw.FontWeight.bold,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border(
                                    bottom: pw.BorderSide(
                              color: PdfColors.grey200,
                              width: 2.0, // Underline thickness
                            ))),
                            // child: pw.Text(
                            //   (Form_area.toString().isNotEmpty)
                            //       ? '$Form_area (ตร.ม.)'
                            //       : ' - (ตร.ม.)',
                            //   textAlign: pw.TextAlign.center,
                            //   style: pw.TextStyle(
                            //     fontSize: font_Size,
                            //     // fontWeight: pw.FontWeight.bold,
                            //     font: ttf,
                            //     color: Colors_pd,
                            //   ),
                            // ),
                            child: textWithFallback(
                              (Form_area.toString().isNotEmpty)
                                  ? '$Form_area (ตร.ม.)'
                                  : ' - (ตร.ม.)',
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            'ຈຳນວນພື້ນທີ່:',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              fontWeight: pw.FontWeight.bold,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border(
                                    bottom: pw.BorderSide(
                              color: PdfColors.grey200,
                              width: 2.0, // Underline thickness
                            ))),
                            // child: pw.Text(
                            //   (Form_qty.toString().isNotEmpty)
                            //       ? '$Form_qty '
                            //       : ' - ',
                            //   textAlign: pw.TextAlign.center,
                            //   style: pw.TextStyle(
                            //     fontSize: font_Size,
                            //     // fontWeight: pw.FontWeight.bold,
                            //     font: ttf,
                            //     color: Colors_pd,
                            //   ),
                            // ),
                            child: textWithFallback(
                              (Form_qty.toString().isNotEmpty)
                                  ? '$Form_qty '
                                  : ' - ',
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // pw.SizedBox(height: 4 * PdfPageFormat.mm),
                    // pw.Row(children: [
                    //   pw.Expanded(
                    //     flex: 1,
                    //     child: pw.Container(
                    //       decoration: pw.BoxDecoration(
                    //           color: PdfColors.green100,
                    //           border: pw.Border(
                    //               bottom: pw.BorderSide(
                    //             color: PdfColors.green900,
                    //             width: 1.0, // Underline thickness
                    //           ))),
                    //       padding: const pw.EdgeInsets.all(8.0),
                    //       child: pw.Text(
                    //         'ข้อมูลสัญญา/เสนอราคา',
                    //         textAlign: pw.TextAlign.center,
                    //         style: pw.TextStyle(
                    //             fontSize: 10.0,
                    //             fontWeight: pw.FontWeight.bold,
                    //             font: ttf,
                    //             color: PdfColors.green900),
                    //       ),
                    //     ),
                    //   )
                    // ]),
                    pw.SizedBox(height: 2 * PdfPageFormat.mm),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            'ວັນທີ່ເລີ່ມສັນຍາ/ເສນີລາຄາ : ',
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              fontWeight: pw.FontWeight.bold,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border(
                                    bottom: pw.BorderSide(
                              color: PdfColors.grey200,
                              width: 2.0, // Underline thickness
                            ))),
                            // child: pw.Text(
                            //   (Form_sdate.toString().isNotEmpty)
                            //       ? '$Form_sdate'
                            //       : ' - ',
                            //   textAlign: pw.TextAlign.center,
                            //   style: pw.TextStyle(
                            //     fontSize: font_Size,
                            //     // fontWeight: pw.FontWeight.bold,
                            //     font: ttf,
                            //     color: Colors_pd,
                            //   ),
                            // ),
                            child: textWithFallback(
                              (Form_sdate.toString().isNotEmpty)
                                  ? '$Form_sdate'
                                  : ' - ',
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            'ວັນທີ່ສິ້ນສຸດສັນຍາ/ເສນີລາຄາ :',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              fontWeight: pw.FontWeight.bold,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border(
                                    bottom: pw.BorderSide(
                              color: PdfColors.grey200,
                              width: 2.0, // Underline thickness
                            ))),
                            // child: pw.Text(
                            //   (Form_ldate.toString().isNotEmpty)
                            //       ? '$Form_ldate'
                            //       : ' - ',
                            //   textAlign: pw.TextAlign.center,
                            //   style: pw.TextStyle(
                            //     fontSize: font_Size,
                            //     // fontWeight: pw.FontWeight.bold,
                            //     font: ttf,
                            //     color: Colors_pd,
                            //   ),
                            // ),
                            child: textWithFallback(
                              (Form_ldate.toString().isNotEmpty)
                                  ? '$Form_ldate'
                                  : ' - ',
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 2 * PdfPageFormat.mm),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            'ປະເພດການເຊົ່າ :',
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              fontWeight: pw.FontWeight.bold,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 3,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border(
                                    bottom: pw.BorderSide(
                              color: PdfColors.grey200,
                              width: 2.0, // Underline thickness
                            ))),
                            // child: pw.Text(
                            //   (Form_rtname.toString().isNotEmpty)
                            //       ? '$Form_rtname'
                            //       : ' - ',
                            //   textAlign: pw.TextAlign.center,
                            //   style: pw.TextStyle(
                            //     fontSize: font_Size,
                            //     // fontWeight: pw.FontWeight.bold,
                            //     font: ttf,
                            //     color: Colors_pd,
                            //   ),
                            // ),
                            child: textWithFallback(
                              (Form_rtname.toString().isNotEmpty)
                                  ? '$Form_rtname'
                                  : ' - ',
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            'ລະຍະເວລາການເຊົ່າ :',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontSize: font_Size,
                              fontWeight: pw.FontWeight.bold,
                              font: ttf,
                              color: Colors_pd,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 3,
                          child: pw.Container(
                            decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                    bottom: pw.BorderSide(
                              color: PdfColors.grey200,
                              width: 2.0, // Underline thickness
                            ))),
                            // child: pw.Text(
                            //   (Form_period.toString().isNotEmpty)
                            //       ? '$Form_period'
                            //       : ' - ',
                            //   textAlign: pw.TextAlign.center,
                            //   style: pw.TextStyle(
                            //     fontSize: font_Size,
                            //     // fontWeight: pw.FontWeight.bold,
                            //     font: ttf,
                            //     color: Colors_pd,
                            //   ),
                            // ),
                            child: textWithFallback(
                              (Form_period.toString().isNotEmpty)
                                  ? '$Form_period'
                                  : ' - ',
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.Row(children: [
                      pw.Expanded(
                        flex: 1,
                        child: pw.Container(
                          height: 10,
                          decoration: pw.BoxDecoration(
                              // color: PdfColors.green100,
                              border: pw.Border(
                                  bottom: pw.BorderSide(
                            color: PdfColors.black,
                            width: 1.0, // Underline thickness
                          ))),
                          padding: const pw.EdgeInsets.all(8.0),
                        ),
                      )
                    ]),
                    pw.SizedBox(height: 4 * PdfPageFormat.mm),
                    // รายละเอียดค่าบริการ
                    pw.Center(
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          // pw.SizedBox(height: 5 * PdfPageFormat.mm),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.Text(
                                'ລາຍລະອຽດຄ່າບໍລິການ',
                                textAlign: pw.TextAlign.left,
                                style: pw.TextStyle(
                                  fontSize: font_Size,
                                  font: ttf,
                                  fontWeight: pw.FontWeight.bold,
                                  color: Colors_pd,
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 3 * PdfPageFormat.mm),
                          pw.Container(
                            height: 25,
                            decoration: const pw.BoxDecoration(
                              // color: PdfColors.green100,
                              border: pw.Border(
                                bottom: pw.BorderSide(color: PdfColors.black),
                              ),
                            ),
                            child: pw.Row(
                              children: [
                                pw.Container(
                                  width: 30,
                                  child: pw.Center(
                                    child: textWithFallback(
                                      'ລຳດັບ',
                                    ),
                                  ),
                                ),
                                pw.Expanded(
                                  flex: 2,
                                  child: pw.Container(
                                    // decoration: const pw.BoxDecoration(
                                    //   color: PdfColors.grey100,
                                    //   border: const pw.Border(
                                    //     bottom: pw.BorderSide(color: PdfColors.grey300),
                                    //   ),
                                    // ),
                                    child: pw.Center(
                                      child: pw.Text(
                                        'ລາຍການ',
                                        textAlign: pw.TextAlign.left,
                                        style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: Colors_pd,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                pw.Expanded(
                                  flex: 2,
                                  child: pw.Container(
                                    child: pw.Center(
                                      child: pw.Text(
                                        'ວັນທີ່',
                                        textAlign: pw.TextAlign.left,
                                        style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: Colors_pd,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                pw.Expanded(
                                  flex: 2,
                                  child: pw.Container(
                                    // decoration: const pw.BoxDecoration(
                                    //   color: PdfColors.grey100,
                                    //   border: const pw.Border(
                                    //     bottom: pw.BorderSide(color: PdfColors.grey300),
                                    //   ),
                                    // ),
                                    child: pw.Center(
                                      child: pw.Text(
                                        'ຄວາມສຸດ / ຈຳນວນງວດ',
                                        textAlign: pw.TextAlign.left,
                                        style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: Colors_pd,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                pw.Expanded(
                                  flex: 1,
                                  child: pw.Container(
                                    // decoration: const pw.BoxDecoration(
                                    //   color: PdfColors.white,
                                    //   border: const pw.Border(
                                    //     bottom: pw.BorderSide(color: PdfColors.grey300),
                                    //   ),
                                    // ),
                                    child: pw.Center(
                                      child: pw.Text(
                                        'ຫົວໜຽນລະ',
                                        textAlign: pw.TextAlign.left,
                                        style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: Colors_pd,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                pw.Expanded(
                                  flex: 1,
                                  child: pw.Container(
                                    // decoration: const pw.BoxDecoration(
                                    //   color: PdfColors.white,
                                    //   border: const pw.Border(
                                    //     bottom: pw.BorderSide(color: PdfColors.grey300),
                                    //   ),
                                    // ),
                                    child: pw.Center(
                                      child: pw.Text(
                                        'ຍອດ/ງວດ',
                                        textAlign: pw.TextAlign.left,
                                        style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: Colors_pd,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                pw.Expanded(
                                  flex: 1,
                                  child: pw.Container(
                                    // decoration: const pw.BoxDecoration(
                                    //   color: PdfColors.grey100,
                                    //   border: const pw.Border(
                                    //     bottom: pw.BorderSide(color: PdfColors.grey300),
                                    //   ),
                                    // ),
                                    child: pw.Center(
                                      child: pw.Text(
                                        'ຍອດລວມ',
                                        textAlign: pw.TextAlign.left,
                                        style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: Colors_pd,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.Container(
                            height: 1,
                          ),
                          // for (int index = 0;
                          //     index < quotxSelectModels.length;
                          //     index++)
                          for (int index = 0;
                              index < pageBreakAtIndex;
                              index++) ...[
                            () {
                              final model = quotxSelectModels[index];

                              final bool hasAmtTy = model.amt_ty != null &&
                                  model.amt_ty!.isNotEmpty;

                              final List<String> rawAmtList =
                                  hasAmtTy ? model.amt_ty!.split(',') : [];

                              // ===== group amt_ty (รวมยอด + นับงวด) =====
                              final List<double> groupedAmt = [];
                              final List<int> groupedCount = [];

                              if (hasAmtTy) {
                                double? current;
                                double sum = 0;
                                int count = 0;

                                for (final v in rawAmtList) {
                                  final val = double.tryParse(v) ?? 0;

                                  if (current == null) {
                                    current = val;
                                    sum = val;
                                    count = 1;
                                  } else if (val == current) {
                                    sum += val;
                                    count++;
                                  } else {
                                    groupedAmt.add(sum);
                                    groupedCount.add(count);
                                    current = val;
                                    sum = val;
                                    count = 1;
                                  }
                                }

                                if (current != null) {
                                  groupedAmt.add(sum);
                                  groupedCount.add(count);
                                }
                              }

                              // ===== ไม่มี amt_ty → 1 แถว =====
                              if (!hasAmtTy) {
                                final currentRowNo = rowNo;
                                rowNo++;
                                return pw.Row(
                                  children: [
                                    // pw.Expanded(
                                    //   flex: 1,
                                    //   child: pw.Container(
                                    //     height: 25,
                                    //     decoration: const pw.BoxDecoration(
                                    //       color: PdfColors.white,
                                    //       border: pw.Border(
                                    //         bottom: pw.BorderSide(
                                    //             color: PdfColors.grey300),
                                    //       ),
                                    //     ),
                                    //     child: pw.Center(
                                    //       child: textWithFallback(
                                    //         '$currentRowNo',
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                    pw.Container(
                                      width: 30,
                                      height: 25,
                                      decoration: const pw.BoxDecoration(
                                        color: PdfColors.white,
                                        border: pw.Border(
                                          bottom: pw.BorderSide(
                                              color: PdfColors.grey300),
                                        ),
                                      ),
                                      child: pw.Center(
                                        child: textWithFallback(
                                          '$currentRowNo',
                                        ),
                                      ),
                                    ),
                                    pw.Expanded(
                                      flex: 2,
                                      child: pw.Container(
                                        height: 25,
                                        decoration: const pw.BoxDecoration(
                                          color: PdfColors.grey100,
                                          border: pw.Border(
                                            bottom: pw.BorderSide(
                                                color: PdfColors.grey300),
                                          ),
                                        ),
                                        child: pw.Center(
                                          child: textWithFallback(
                                            '${model.expname}',
                                          ),
                                        ),
                                      ),
                                    ),
                                    pw.Expanded(
                                      flex: 2,
                                      child: pw.Container(
                                        height: 25,
                                        decoration: const pw.BoxDecoration(
                                          color: PdfColors.white,
                                          border: pw.Border(
                                            bottom: pw.BorderSide(
                                                color: PdfColors.grey300),
                                          ),
                                        ),
                                        child: pw.Center(
                                          child: textWithFallback(
                                            (model.sdate == null ||
                                                    model.ldate == null)
                                                ? '00-00-0000'
                                                : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${model.sdate} 00:00:00'))}'
                                                    ' - ${DateFormat('dd-MM-yyyy').format(DateTime.parse('${model.ldate} 00:00:00'))}',
                                          ),
                                        ),
                                      ),
                                    ),
                                    pw.Expanded(
                                      flex: 2,
                                      child: pw.Container(
                                        height: 25,
                                        decoration: const pw.BoxDecoration(
                                          color: PdfColors.grey100,
                                          border: pw.Border(
                                            bottom: pw.BorderSide(
                                                color: PdfColors.grey300),
                                          ),
                                        ),
                                        child: pw.Center(
                                          child: textWithFallback(
                                            '${model.unit} / ${model.term} (งวด)',
                                          ),
                                        ),
                                      ),
                                    ),
                                    pw.Expanded(
                                      flex: 1,
                                      child: pw.Container(
                                        height: 25,
                                        decoration: const pw.BoxDecoration(
                                          color: PdfColors.white,
                                          border: pw.Border(
                                            bottom: pw.BorderSide(
                                                color: PdfColors.grey300),
                                          ),
                                        ),
                                        child: pw.Center(
                                          child: textWithFallback(
                                            model.qty == null
                                                ? '0.00'
                                                : nFormat.format(
                                                    double.parse(model.qty)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    pw.Expanded(
                                      flex: 1,
                                      child: pw.Container(
                                        height: 25,
                                        decoration: const pw.BoxDecoration(
                                          color: PdfColors.grey100,
                                          border: pw.Border(
                                            bottom: pw.BorderSide(
                                                color: PdfColors.grey300),
                                          ),
                                        ),
                                        child: pw.Center(
                                          child: textWithFallback(
                                            model.total == null
                                                ? '0.00'
                                                : nFormat.format(
                                                    double.parse(model.total)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    pw.Expanded(
                                      flex: 1,
                                      child: pw.Container(
                                        height: 25,
                                        decoration: const pw.BoxDecoration(
                                          color: PdfColors.white,
                                          border: pw.Border(
                                            bottom: pw.BorderSide(
                                                color: PdfColors.grey300),
                                          ),
                                        ),
                                        child: pw.Align(
                                          alignment: pw.Alignment.centerRight,
                                          child: textWithFallback(
                                            model.total == null ||
                                                    model.term == null
                                                ? '0.00'
                                                : nFormat.format(int.parse(
                                                        model.term) *
                                                    double.parse(model.total)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }

                              // ===== มี amt_ty → group + ช่วงงวด =====
                              int termStart = 1;
                              DateTime currentStartDate =
                                  DateTime.parse('${model.sdate} 00:00:00');

                              return pw.Column(
                                children: List.generate(groupedAmt.length, (i) {
                                  final double amt = groupedAmt[i];
                                  final int count = groupedCount[i];
                                  final int termEnd = termStart + count - 1;

                                  final String termText = termStart == termEnd
                                      ? '$termStart'
                                      : '$termStart-$termEnd';

                                  termStart = termEnd + 1;

                                  // ===== คำนวณวันที่เริ่มต้นและสิ้นสุดตามประเภทของหน่วย =====
                                  DateTime dateStart = currentStartDate;
                                  DateTime dateEnd = dateStart;

                                  final unitserValue =
                                      int.tryParse(model.unitser ?? '0') ?? 0;
                                  final bool isLastGroup =
                                      (i == groupedAmt.length - 1);

                                  if (isLastGroup) {
                                    // ถ้าเป็นกลุ่มสุดท้าย ให้ใช้ ldate ของโมเดล
                                    dateEnd = DateTime.parse(
                                        '${model.ldate} 00:00:00');
                                  } else {
                                    if (unitserValue == 1) {
                                      // รายปี - บวกปี
                                      dateEnd = DateTime(dateStart.year + count,
                                              dateStart.month, dateStart.day)
                                          .subtract(Duration(days: 1));
                                    } else if (unitserValue == 2) {
                                      // รายเดือน - บวกเดือน
                                      int newMonth = dateStart.month + count;
                                      int newYear = dateStart.year;
                                      while (newMonth > 12) {
                                        newMonth -= 12;
                                        newYear++;
                                      }
                                      dateEnd = DateTime(
                                              newYear, newMonth, dateStart.day)
                                          .subtract(Duration(days: 1));
                                    } else if (unitserValue == 3) {
                                      // สัปดาห์ - บวก 7 วัน * count
                                      dateEnd = dateStart
                                          .add(Duration(days: 7 * count - 1));
                                    } else if (unitserValue == 4) {
                                      // รายวัน - บวกวัน
                                      dateEnd = dateStart
                                          .add(Duration(days: count - 1));
                                    }
                                  }

                                  // ตั้งค่า currentStartDate สำหรับรอบถัดไป
                                  currentStartDate =
                                      dateEnd.add(Duration(days: 1));

                                  // ===== ตัวนับลำดับจริง =====
                                  final currentRowNo = rowNo;
                                  rowNo++;

                                  return pw.Row(
                                    children: [
                                      // ===== ลำดับ =====
                                      // pw.Expanded(
                                      //   flex: 1,
                                      //   child: pw.Container(
                                      //     height: 25,
                                      //     decoration: const pw.BoxDecoration(
                                      //       color: PdfColors.white,
                                      //       border: pw.Border(
                                      //         bottom: pw.BorderSide(
                                      //             color: PdfColors.grey300),
                                      //       ),
                                      //     ),
                                      //     child: pw.Center(
                                      //       child: textWithFallback(
                                      //         '$currentRowNo',
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                      pw.Container(
                                        height: 25,
                                        decoration: const pw.BoxDecoration(
                                          color: PdfColors.white,
                                          border: pw.Border(
                                            bottom: pw.BorderSide(
                                                color: PdfColors.grey300),
                                          ),
                                        ),
                                        child: pw.Center(
                                          child: textWithFallback(
                                            '$currentRowNo',
                                          ),
                                        ),
                                      ),

                                      // ===== รายการ =====
                                      pw.Expanded(
                                        flex: 2,
                                        child: pw.Container(
                                          height: 25,
                                          decoration: const pw.BoxDecoration(
                                            color: PdfColors.grey100,
                                            border: pw.Border(
                                              bottom: pw.BorderSide(
                                                  color: PdfColors.grey300),
                                            ),
                                          ),
                                          child: pw.Center(
                                            child: textWithFallback(
                                              '${model.expname}',
                                            ),
                                          ),
                                        ),
                                      ),

                                      // ===== วันที่ =====
                                      pw.Expanded(
                                        flex: 2,
                                        child: pw.Container(
                                          height: 25,
                                          decoration: const pw.BoxDecoration(
                                            color: PdfColors.white,
                                            border: pw.Border(
                                              bottom: pw.BorderSide(
                                                  color: PdfColors.grey300),
                                            ),
                                          ),
                                          child: pw.Center(
                                            child: textWithFallback(
                                              '${DateFormat('dd-MM-yyyy').format(dateStart)}'
                                              ' - ${DateFormat('dd-MM-yyyy').format(dateEnd)}',
                                            ),
                                          ),
                                        ),
                                      ),

                                      // ===== งวด =====
                                      pw.Expanded(
                                        flex: 2,
                                        child: pw.Container(
                                          height: 25,
                                          decoration: const pw.BoxDecoration(
                                            color: PdfColors.grey100,
                                            border: pw.Border(
                                              bottom: pw.BorderSide(
                                                  color: PdfColors.grey300),
                                            ),
                                          ),
                                          child: pw.Center(
                                            child: textWithFallback(
                                              '${model.unit} / $termText (ງວດ)',
                                            ),
                                          ),
                                        ),
                                      ),

                                      // ===== หน่วย =====
                                      pw.Expanded(
                                        flex: 1,
                                        child: pw.Container(
                                          height: 25,
                                          decoration: const pw.BoxDecoration(
                                            color: PdfColors.white,
                                            border: pw.Border(
                                              bottom: pw.BorderSide(
                                                  color: PdfColors.grey300),
                                            ),
                                          ),
                                          child: pw.Center(
                                            child: textWithFallback(
                                              nFormat.format(double.parse(
                                                  model.qty ?? '0')),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // ===== อัตราพิเศษ =====
                                      pw.Expanded(
                                        flex: 1,
                                        child: pw.Container(
                                          height: 25,
                                          decoration: const pw.BoxDecoration(
                                            color: PdfColors.grey100,
                                            border: pw.Border(
                                              bottom: pw.BorderSide(
                                                  color: PdfColors.grey300),
                                            ),
                                          ),
                                          child: pw.Center(
                                            child: textWithFallback(
                                              nFormat.format(amt / count),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // ===== ยอดรวม =====
                                      pw.Expanded(
                                        flex: 1,
                                        child: pw.Container(
                                          height: 25,
                                          decoration: const pw.BoxDecoration(
                                            color: PdfColors.white,
                                            border: pw.Border(
                                              bottom: pw.BorderSide(
                                                  color: PdfColors.grey300),
                                            ),
                                          ),
                                          child: pw.Align(
                                            alignment: pw.Alignment.centerRight,
                                            child: textWithFallback(
                                              nFormat.format(amt),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              );
                            }(),
                          ],

                          (quotxSelectModels.length < 10)
                              ? pw.Container(
                                  height: 25,
                                  decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                      top:
                                          pw.BorderSide(color: PdfColors.black),
                                    ),
                                  ),
                                  alignment: pw.Alignment.centerRight,
                                  child: pw.Center(
                                    child: pw.Row(
                                      children: [
                                        // pw.SizedBox(
                                        //     width: 2 * PdfPageFormat.mm),
                                        pw.Expanded(
                                          flex: 4,
                                          child: pw.Text(
                                            (total_1 == null)
                                                ? '-'
                                                : 'ຕົວອັກສອນ (~${convertToLaoBaht(total_1)}~)',
                                            style: pw.TextStyle(
                                              fontSize: font_Size,
                                              fontWeight: pw.FontWeight.bold,
                                              font: ttf,
                                              fontStyle: pw.FontStyle.italic,
                                              color: Colors_pd,
                                            ),
                                          ),
                                        ),
                                        pw.SizedBox(width: 30),
                                        pw.Expanded(
                                          flex: 2,
                                          child: pw.Text(
                                            'ຍອດລວມສຸດທິ',
                                            textAlign: pw.TextAlign.center,
                                            style: pw.TextStyle(
                                              fontSize: font_Size,
                                              fontWeight: pw.FontWeight.bold,
                                              font: ttf,
                                              fontStyle: pw.FontStyle.italic,
                                              color: Colors_pd,
                                            ),
                                          ),
                                        ),
                                        pw.Expanded(
                                          flex: 3,
                                          child: pw.Column(
                                            mainAxisAlignment:
                                                pw.MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                pw.CrossAxisAlignment.start,
                                            children: [
                                              pw.Row(
                                                children: [
                                                  pw.Expanded(
                                                      flex: 1,
                                                      child: pw.SizedBox()),
                                                  pw.Expanded(
                                                    flex: 1,
                                                    child: pw.Text(
                                                      (total_1 == null)
                                                          ? '0.00'
                                                          : '${nFormat.format(total_1)}',
                                                      textAlign:
                                                          pw.TextAlign.center,
                                                      style: pw.TextStyle(
                                                        fontWeight:
                                                            pw.FontWeight.bold,
                                                        font: ttf,
                                                        fontSize: font_Size,
                                                        color: Colors_pd,
                                                      ),
                                                    ),
                                                  ),
                                                  pw.Expanded(
                                                    flex: 1,
                                                    child: pw.Text(
                                                      (total_ == null)
                                                          ? '0.00'
                                                          : '${nFormat.format(total_)}',
                                                      textAlign:
                                                          pw.TextAlign.right,
                                                      style: pw.TextStyle(
                                                        fontWeight:
                                                            pw.FontWeight.bold,
                                                        font: ttf,
                                                        fontSize: font_Size,
                                                        color: Colors_pd,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : pw.SizedBox(), // ถ้า >= 9 รายการจะไม่แสดงอะไร

                          // pw.Container(
                          //     height: 25,
                          //     decoration: const pw.BoxDecoration(
                          //       // color: PdfColors.green100,
                          //       border: pw.Border(
                          //           // top: pw.BorderSide(color: PdfColors.black),
                          //           ),
                          //     ),
                          //     alignment: pw.Alignment.centerRight,
                          //     child: pw.Center(
                          //       child: pw.Row(
                          //         children: [
                          //           // pw.SizedBox(width: 2 * PdfPageFormat.mm),
                          //           pw.Expanded(
                          //             flex: 10,
                          //             child: pw.Text(
                          //               //"${nFormat2.format(double.parse(Total.toString()))}";
                          //               (total_1 == null)
                          //                   ? '-'
                          //                   : 'ตัวอักษร (~${convertToThaiBaht(total_1)}~)',
                          //               textAlign: pw.TextAlign.right,
                          //               style: pw.TextStyle(
                          //                 fontSize: font_Size,
                          //                 fontWeight: pw.FontWeight.bold,
                          //                 font: ttf,
                          //                 fontStyle: pw.FontStyle.italic,
                          //                 // decoration:
                          //                 //     pw.TextDecoration.lineThrough,
                          //                 color: Colors_pd,
                          //               ),
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //     )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ===== หน้า 2 (ถ้ามีรายการเกิน pageBreakAtIndex) =====
            if (pageBreakAtIndex < quotxSelectModels.length)
              pw.Align(
                alignment: pw.Alignment.topLeft,
                child: pw.Container(
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.SizedBox(height: 2 * PdfPageFormat.mm),
                      // รายละเอียดค่าบริการ (ต่อ)
                      pw.Center(
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'ລາຍລະອຽດຄ່າບໍລິການ (ຕໍ່)',
                                  textAlign: pw.TextAlign.left,
                                  style: pw.TextStyle(
                                    fontSize: font_Size,
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                    color: Colors_pd,
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 3 * PdfPageFormat.mm),
                            pw.Container(
                              height: 25,
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  bottom: pw.BorderSide(color: PdfColors.black),
                                ),
                              ),
                              child: pw.Row(
                                children: [
                                  pw.Container(
                                    width: 30,
                                    height: 25,
                                    decoration: const pw.BoxDecoration(
                                      color: PdfColors.white,
                                      border: pw.Border(
                                        bottom: pw.BorderSide(
                                            color: PdfColors.grey300),
                                      ),
                                    ),
                                    child: pw.Center(
                                      child: textWithFallback(
                                        'ລຳດັບ',
                                      ),
                                    ),
                                  ),
                                  pw.Expanded(
                                    flex: 2,
                                    child: pw.Center(
                                      child: pw.Text(
                                        'ລາຍການ',
                                        textAlign: pw.TextAlign.left,
                                        style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: Colors_pd,
                                        ),
                                      ),
                                    ),
                                  ),
                                  pw.Expanded(
                                    flex: 2,
                                    child: pw.Center(
                                      child: pw.Text(
                                        'ວັນທີ່',
                                        textAlign: pw.TextAlign.left,
                                        style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: Colors_pd,
                                        ),
                                      ),
                                    ),
                                  ),
                                  pw.Expanded(
                                    flex: 2,
                                    child: pw.Center(
                                      child: pw.Text(
                                        'ຄວາມສຸດ / ຈຳນວນງວດ',
                                        textAlign: pw.TextAlign.left,
                                        style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: Colors_pd,
                                        ),
                                      ),
                                    ),
                                  ),
                                  pw.Expanded(
                                    flex: 1,
                                    child: pw.Center(
                                      child: pw.Text(
                                        'ຫົວໜຽນລະ',
                                        textAlign: pw.TextAlign.left,
                                        style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: Colors_pd,
                                        ),
                                      ),
                                    ),
                                  ),
                                  pw.Expanded(
                                    flex: 1,
                                    child: pw.Center(
                                      child: pw.Text(
                                        'ຍອດ/ງວດ',
                                        textAlign: pw.TextAlign.left,
                                        style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: Colors_pd,
                                        ),
                                      ),
                                    ),
                                  ),
                                  pw.Expanded(
                                    flex: 1,
                                    child: pw.Center(
                                      child: pw.Text(
                                        'ຍອດລວມ',
                                        textAlign: pw.TextAlign.left,
                                        style: pw.TextStyle(
                                          fontSize: font_Size,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: Colors_pd,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.Container(
                              height: 1,
                            ),
                            for (int index = pageBreakAtIndex;
                                index < quotxSelectModels.length;
                                index++) ...[
                              () {
                                final model = quotxSelectModels[index];

                                final bool hasAmtTy = model.amt_ty != null &&
                                    model.amt_ty!.isNotEmpty;

                                final List<String> rawAmtList =
                                    hasAmtTy ? model.amt_ty!.split(',') : [];

                                final List<double> groupedAmt = [];
                                final List<int> groupedCount = [];

                                if (hasAmtTy) {
                                  double? current;
                                  double sum = 0;
                                  int count = 0;

                                  for (final v in rawAmtList) {
                                    final val = double.tryParse(v) ?? 0;

                                    if (current == null) {
                                      current = val;
                                      sum = val;
                                      count = 1;
                                    } else if (val == current) {
                                      sum += val;
                                      count++;
                                    } else {
                                      groupedAmt.add(sum);
                                      groupedCount.add(count);
                                      current = val;
                                      sum = val;
                                      count = 1;
                                    }
                                  }

                                  if (current != null) {
                                    groupedAmt.add(sum);
                                    groupedCount.add(count);
                                  }
                                }

                                if (!hasAmtTy) {
                                  final currentRowNo = rowNo;
                                  rowNo++;
                                  return pw.Row(
                                    children: [
                                      // pw.Expanded(
                                      //   flex: 1,
                                      //   child: pw.Container(
                                      //     height: 25,
                                      //     decoration: const pw.BoxDecoration(
                                      //       color: PdfColors.white,
                                      //       border: pw.Border(
                                      //         bottom: pw.BorderSide(
                                      //             color: PdfColors.grey300),
                                      //       ),
                                      //     ),
                                      //     child: pw.Center(
                                      //       child: textWithFallback(
                                      //         '$currentRowNo',
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                      pw.Container(
                                        height: 25,
                                        width: 30,
                                        decoration: const pw.BoxDecoration(
                                          color: PdfColors.white,
                                          border: pw.Border(
                                            bottom: pw.BorderSide(
                                                color: PdfColors.grey300),
                                          ),
                                        ),
                                        child: pw.Center(
                                          child: textWithFallback(
                                            '$currentRowNo',
                                          ),
                                        ),
                                      ),
                                      pw.Expanded(
                                        flex: 2,
                                        child: pw.Container(
                                          height: 25,
                                          decoration: const pw.BoxDecoration(
                                            color: PdfColors.grey100,
                                            border: pw.Border(
                                              bottom: pw.BorderSide(
                                                  color: PdfColors.grey300),
                                            ),
                                          ),
                                          child: pw.Center(
                                            child: textWithFallback(
                                              '${model.expname}',
                                            ),
                                          ),
                                        ),
                                      ),
                                      pw.Expanded(
                                        flex: 2,
                                        child: pw.Container(
                                          height: 25,
                                          decoration: const pw.BoxDecoration(
                                            color: PdfColors.white,
                                            border: pw.Border(
                                              bottom: pw.BorderSide(
                                                  color: PdfColors.grey300),
                                            ),
                                          ),
                                          child: pw.Center(
                                            child: textWithFallback(
                                              (model.sdate == null ||
                                                      model.ldate == null)
                                                  ? '00-00-0000'
                                                  : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${model.sdate} 00:00:00'))}'
                                                      ' - ${DateFormat('dd-MM-yyyy').format(DateTime.parse('${model.ldate} 00:00:00'))}',
                                            ),
                                          ),
                                        ),
                                      ),
                                      pw.Expanded(
                                        flex: 2,
                                        child: pw.Container(
                                          height: 25,
                                          decoration: const pw.BoxDecoration(
                                            color: PdfColors.grey100,
                                            border: pw.Border(
                                              bottom: pw.BorderSide(
                                                  color: PdfColors.grey300),
                                            ),
                                          ),
                                          child: pw.Center(
                                            child: textWithFallback(
                                              '${model.unit} / ${model.term} (ງວດ)',
                                            ),
                                          ),
                                        ),
                                      ),
                                      pw.Expanded(
                                        flex: 1,
                                        child: pw.Container(
                                          height: 25,
                                          decoration: const pw.BoxDecoration(
                                            color: PdfColors.white,
                                            border: pw.Border(
                                              bottom: pw.BorderSide(
                                                  color: PdfColors.grey300),
                                            ),
                                          ),
                                          child: pw.Center(
                                            child: textWithFallback(
                                              model.qty == null
                                                  ? '0.00'
                                                  : nFormat.format(
                                                      double.parse(model.qty)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      pw.Expanded(
                                        flex: 1,
                                        child: pw.Container(
                                          height: 25,
                                          decoration: const pw.BoxDecoration(
                                            color: PdfColors.grey100,
                                            border: pw.Border(
                                              bottom: pw.BorderSide(
                                                  color: PdfColors.grey300),
                                            ),
                                          ),
                                          child: pw.Center(
                                            child: textWithFallback(
                                              model.total == null
                                                  ? '0.00'
                                                  : nFormat.format(double.parse(
                                                      model.total)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      pw.Expanded(
                                        flex: 1,
                                        child: pw.Container(
                                          height: 25,
                                          decoration: const pw.BoxDecoration(
                                            color: PdfColors.white,
                                            border: pw.Border(
                                              bottom: pw.BorderSide(
                                                  color: PdfColors.grey300),
                                            ),
                                          ),
                                          child: pw.Align(
                                            alignment: pw.Alignment.centerRight,
                                            child: textWithFallback(
                                              model.total == null ||
                                                      model.term == null
                                                  ? '0.00'
                                                  : nFormat.format(
                                                      int.parse(model.term) *
                                                          double.parse(
                                                              model.total)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                int termStart = 1;
                                DateTime currentStartDate =
                                    DateTime.parse('${model.sdate} 00:00:00');

                                return pw.Column(
                                  children:
                                      List.generate(groupedAmt.length, (i) {
                                    final double amt = groupedAmt[i];
                                    final int count = groupedCount[i];
                                    final int termEnd = termStart + count - 1;

                                    final String termText = termStart == termEnd
                                        ? '$termStart'
                                        : '$termStart-$termEnd';

                                    termStart = termEnd + 1;

                                    DateTime dateStart = currentStartDate;
                                    DateTime dateEnd = dateStart;

                                    final unitserValue =
                                        int.tryParse(model.unitser ?? '0') ?? 0;
                                    final bool isLastGroup =
                                        (i == groupedAmt.length - 1);

                                    if (isLastGroup) {
                                      dateEnd = DateTime.parse(
                                          '${model.ldate} 00:00:00');
                                    } else {
                                      if (unitserValue == 1) {
                                        dateEnd = DateTime(
                                                dateStart.year + count,
                                                dateStart.month,
                                                dateStart.day)
                                            .subtract(Duration(days: 1));
                                      } else if (unitserValue == 2) {
                                        int newMonth = dateStart.month + count;
                                        int newYear = dateStart.year;
                                        while (newMonth > 12) {
                                          newMonth -= 12;
                                          newYear++;
                                        }
                                        dateEnd = DateTime(newYear, newMonth,
                                                dateStart.day)
                                            .subtract(Duration(days: 1));
                                      } else if (unitserValue == 3) {
                                        dateEnd = dateStart
                                            .add(Duration(days: 7 * count - 1));
                                      } else if (unitserValue == 4) {
                                        dateEnd = dateStart
                                            .add(Duration(days: count - 1));
                                      }
                                    }

                                    currentStartDate =
                                        dateEnd.add(Duration(days: 1));

                                    final currentRowNo = rowNo;
                                    rowNo++;

                                    return pw.Row(
                                      children: [
                                        pw.Expanded(
                                          flex: 1,
                                          child: pw.Container(
                                            height: 25,
                                            width: 30,
                                            decoration: const pw.BoxDecoration(
                                              color: PdfColors.white,
                                              border: pw.Border(
                                                bottom: pw.BorderSide(
                                                    color: PdfColors.grey300),
                                              ),
                                            ),
                                            child: pw.Center(
                                              child: textWithFallback(
                                                '$currentRowNo',
                                              ),
                                            ),
                                          ),
                                        ),
                                        pw.Expanded(
                                          flex: 2,
                                          child: pw.Container(
                                            height: 25,
                                            decoration: const pw.BoxDecoration(
                                              color: PdfColors.grey100,
                                              border: pw.Border(
                                                bottom: pw.BorderSide(
                                                    color: PdfColors.grey300),
                                              ),
                                            ),
                                            child: pw.Center(
                                              child: textWithFallback(
                                                '${model.unit} / $termText (ງວດ)',
                                              ),
                                            ),
                                          ),
                                        ),
                                        pw.Expanded(
                                          flex: 2,
                                          child: pw.Container(
                                            height: 25,
                                            decoration: const pw.BoxDecoration(
                                              color: PdfColors.white,
                                              border: pw.Border(
                                                bottom: pw.BorderSide(
                                                    color: PdfColors.grey300),
                                              ),
                                            ),
                                            child: pw.Center(
                                              child: textWithFallback(
                                                '${model.expname}',
                                              ),
                                            ),
                                          ),
                                        ),
                                        pw.Expanded(
                                          flex: 2,
                                          child: pw.Container(
                                            height: 25,
                                            decoration: const pw.BoxDecoration(
                                              color: PdfColors.grey100,
                                              border: pw.Border(
                                                bottom: pw.BorderSide(
                                                    color: PdfColors.grey300),
                                              ),
                                            ),
                                            child: pw.Center(
                                              child: textWithFallback(
                                                '${DateFormat('dd-MM-yyyy').format(dateStart)}'
                                                ' - ${DateFormat('dd-MM-yyyy').format(dateEnd)}',
                                              ),
                                            ),
                                          ),
                                        ),
                                        pw.Expanded(
                                          flex: 1,
                                          child: pw.Container(
                                            height: 25,
                                            decoration: const pw.BoxDecoration(
                                              color: PdfColors.white,
                                              border: pw.Border(
                                                bottom: pw.BorderSide(
                                                    color: PdfColors.grey300),
                                              ),
                                            ),
                                            child: pw.Center(
                                              child: textWithFallback(
                                                nFormat.format(double.parse(
                                                    model.qty ?? '0')),
                                              ),
                                            ),
                                          ),
                                        ),
                                        pw.Expanded(
                                          flex: 1,
                                          child: pw.Container(
                                            height: 25,
                                            decoration: const pw.BoxDecoration(
                                              color: PdfColors.grey100,
                                              border: pw.Border(
                                                bottom: pw.BorderSide(
                                                    color: PdfColors.grey300),
                                              ),
                                            ),
                                            child: pw.Center(
                                              child: textWithFallback(
                                                nFormat.format(amt / count),
                                              ),
                                            ),
                                          ),
                                        ),
                                        pw.Expanded(
                                          flex: 1,
                                          child: pw.Container(
                                            height: 25,
                                            decoration: const pw.BoxDecoration(
                                              color: PdfColors.white,
                                              border: pw.Border(
                                                bottom: pw.BorderSide(
                                                    color: PdfColors.grey300),
                                              ),
                                            ),
                                            child: pw.Align(
                                              alignment:
                                                  pw.Alignment.centerRight,
                                              child: textWithFallback(
                                                nFormat.format(amt),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                );
                              }(),
                            ],
                            pw.Container(
                              height: 25,
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  top: pw.BorderSide(color: PdfColors.black),
                                ),
                              ),
                              alignment: pw.Alignment.centerRight,
                              child: pw.Center(
                                child: pw.Row(
                                  children: [
                                    // pw.SizedBox(width: 2 * PdfPageFormat.mm),
                                    pw.Expanded(
                                      flex: 4,
                                      child: pw.Text(
                                        (total_1 == null)
                                            ? '-'
                                            : 'ຕົວອັກສອນ (~${convertToLaoBaht(total_1)}~)',
                                        style: pw.TextStyle(
                                          fontSize: font_Size,
                                          fontWeight: pw.FontWeight.bold,
                                          font: ttf,
                                          fontStyle: pw.FontStyle.italic,
                                          color: Colors_pd,
                                        ),
                                      ),
                                    ),
                                    pw.SizedBox(width: 30),
                                    pw.Expanded(
                                      flex: 2,
                                      child: pw.Text(
                                        'ຍອດລວມສຸດທິ',
                                        textAlign: pw.TextAlign.center,
                                        style: pw.TextStyle(
                                          fontSize: font_Size,
                                          fontWeight: pw.FontWeight.bold,
                                          font: ttf,
                                          fontStyle: pw.FontStyle.italic,
                                          color: Colors_pd,
                                        ),
                                      ),
                                    ),
                                    pw.Expanded(
                                      flex: 3,
                                      child: pw.Column(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Row(
                                            children: [
                                              pw.Expanded(
                                                  flex: 1,
                                                  child: pw.SizedBox()),
                                              pw.Expanded(
                                                flex: 1,
                                                child: pw.Text(
                                                  (total_1 == null)
                                                      ? '0.00'
                                                      : '${nFormat.format(total_1)}',
                                                  textAlign:
                                                      pw.TextAlign.center,
                                                  style: pw.TextStyle(
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    font: ttf,
                                                    fontSize: font_Size,
                                                    color: Colors_pd,
                                                  ),
                                                ),
                                              ),
                                              pw.Expanded(
                                                flex: 1,
                                                child: pw.Text(
                                                  (total_ == null)
                                                      ? '0.00'
                                                      : '${nFormat.format(total_)}',
                                                  textAlign: pw.TextAlign.right,
                                                  style: pw.TextStyle(
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    font: ttf,
                                                    fontSize: font_Size,
                                                    color: Colors_pd,
                                                  ),
                                                ),
                                              ),
                                            ],
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
                    ],
                  ),
                ),
              ),
          ];
        },
        footer: (context) {
          return
              // (context.pageNumber != context.pagesCount)
              //     ? pw.Align(
              //         alignment: pw.Alignment.bottomRight,
              //         child: pw.Text(
              //           'หน้า ${context.pageNumber} / ${context.pagesCount} ',
              //           textAlign: pw.TextAlign.left,
              //           style: pw.TextStyle(
              //             fontSize: 10,
              //             font: ttf,
              //             color: Colors_pd,
              //             // fontWeight: pw.FontWeight.bold
              //           ),
              //         ),
              //       )
              //     :
              pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              // if (context.pageNumber == context.pagesCount)
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey, width: 1),
                  ),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(height: 2 * PdfPageFormat.mm),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 1,
                            child: pw.Text(
                              'ລງຊື່ຜູ້ເຊົ່າ',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: font_Size,
                                fontWeight: pw.FontWeight.bold,
                                font: ttf,
                                color: Colors_pd,
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 1,
                            child: pw.Text(
                              'ລງຊື່ຜູ້ໃຫ້ເຊົ່າ',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: font_Size,
                                fontWeight: pw.FontWeight.bold,
                                font: ttf,
                                color: Colors_pd,
                              ),
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 2 * PdfPageFormat.mm),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 1,
                            child: pw.Text(
                              '.............................................',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: font_Size,
                                font: ttf,
                                color: Colors_pd,
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 1,
                            child: pw.Text(
                              '.............................................',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: font_Size,
                                font: ttf,
                                color: Colors_pd,
                              ),
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 2 * PdfPageFormat.mm),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 1,
                            // child: pw.Text(
                            //   (ren.toString() != '106')
                            //       ? '( $Form_bussshop )'
                            //       : '( $Form_addmin )',
                            //   textAlign: pw.TextAlign.center,
                            //   style: pw.TextStyle(
                            //     fontSize: font_Size,
                            //     font: ttf,
                            //     color: Colors_pd,
                            //   ),
                            // ),
                            child: textWithFallback(
                              (ren.toString() != '106')
                                  ? '( $Form_bussshop )'
                                  : '( $Form_addmin )',
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Expanded(
                            flex: 1,
                            // child: pw.Text(
                            //   (ren.toString() != '106')
                            //       ? '( ${bill_name.toString().trim()} )'
                            //       : '( $Form_bussshop )',
                            //   textAlign: pw.TextAlign.center,
                            //   style: pw.TextStyle(
                            //     fontSize: font_Size,
                            //     font: ttf,
                            //     color: Colors_pd,
                            //   ),
                            // ),
                            child: textWithFallback(
                              (ren.toString() != '106')
                                  ? '( ${bill_name.toString().trim()} )'
                                  : '( $Form_bussshop )',
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 2 * PdfPageFormat.mm),
                      pw.Row(
                        children: [
                          pw.SizedBox(width: 2 * PdfPageFormat.mm),
                          pw.Text(
                            'ໝາຍເຫດ : ${'.....' * 50}',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                                fontSize: font_Size,
                                font: ttf,
                                color: Colors_pd,
                                fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 1 * PdfPageFormat.mm),
                      // pw.Row(
                      //   mainAxisAlignment: pw.MainAxisAlignment.center,
                      //   children: [
                      //     pw.Text(
                      //       '.....' * 50,
                      //       textAlign: pw.TextAlign.left,
                      //       maxLines: 1,
                      //       style: pw.TextStyle(
                      //         fontSize: font_Size,
                      //         font: ttf,
                      //         color: Colors_pd,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      pw.SizedBox(height: 3 * PdfPageFormat.mm),
                    ],
                  )),
              pw.SizedBox(height: 3 * PdfPageFormat.mm),
              pw.Align(
                alignment: pw.Alignment.bottomRight,
                child: pw.Text(
                  'ໜ້າ ${context.pageNumber} / ${context.pagesCount} ',
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
    );

    // final bytes = await pdf.save();

    // final dir = await getApplicationDocumentsDirectory();
    // final file = File('${dir.path}/name');
    // await file.writeAsBytes(bytes);
    // return file;
    //----------------------------------------->
    // final List<int> bytes = await pdf.save();
    // final Uint8List data = Uint8List.fromList(bytes);
    // MimeType type = MimeType.PDF;
    // final dir = await FileSaver.instance.saveFile(
    //     // "ใบเสนอราคา(ณ วันที่${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day})",
    //     "ใบเสนอราคา $Get_Value_cid",
    //     data,
    //     "pdf",
    //     mimeType: type);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewScreenRentalInforma(
              doc: pdf, Get_Value_cid: Get_Value_cid),
        ));
  }
}
