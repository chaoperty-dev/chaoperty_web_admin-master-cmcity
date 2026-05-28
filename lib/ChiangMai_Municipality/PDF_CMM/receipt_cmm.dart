import 'dart:io';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import '../../PeopleChao/Pays_.dart';
import '../../Style/ThaiBaht.dart';
import '../Model/AutoExpTrans_ModelCMM.dart';
import '../Model/Receipt_Model.dart';
import '../unity/thai_date_utils.dart';
import 'unity_pdf_cmm/perviewpdf1_cmm.dart';
import 'unity_pdf_cmm/unitypdf_cmm.dart';

Future<dynamic> GeneratePDF_Receipt_CMM({
  required BuildContext context,
  required int type,
  required dynamic DataDetail,
  required List<AutoExpTransModelCMM> expAutoModels,
  required Map<String, dynamic> receiptmodel,
  required Uint8List? Signature_user,
  required dynamic fullNameAdmin,
  required dynamic positionAdmin,
}) async {
  final pdf = pw.Document();

  final ttf = await font1(); // สมมติคืนค่า pw.Font
  // final ttf2 = await font2();

  // โหลดภาพตัวอย่าง (เอาออกได้ถ้าไม่ใช้)
  final image = pw.MemoryImage(
      (await rootBundle.load('images/kindpng.png')).buffer.asUint8List());
  final image2 = pw.MemoryImage(
      (await rootBundle.load('images/pngegg2.png')).buffer.asUint8List());
  final image3 = pw.MemoryImage(
      (await rootBundle.load('images/cmm_logo4.png')).buffer.asUint8List());

  final nFormat = NumberFormat("#,##0.00", "en_US");
  String getFormattedText(String? s) =>
      nFormat.format(double.tryParse(s ?? '') ?? 0.00);

  final totalSum = expAutoModels.fold<double>(
    0.0,
    (sum, e) => sum + (double.tryParse(e.total ?? '0.0') ?? 0.0),
  );
  DateTime? safePdate;
  String slipPdate = receiptmodel['receiptDate'];
  if (slipPdate.isNotEmpty) {
    try {
      safePdate = DateTime.parse(slipPdate);
    } catch (_) {
      //debugPrint('❌ วันที่ไม่ถูกต้อง: $slipPdate');
    }
  }

  if (safePdate != null) {
    final pPdatemonthName = getThaiMonthName(safePdate.month);
    final pPdatethaiYear = (safePdate.year + 543).toString();
    final pPdatethaiDate = safePdate.day.toString();
    slipPdate = '$pPdatethaiDate $pPdatemonthName $pPdatethaiYear';
  } else {
    // debugPrint('⚠️ ไม่สามารถแปลง ldate ได้');
  }
  // ---------- ลายเซ็น (แก้ครบ) ----------
  pw.Widget signatureWidget = pw.SizedBox();
  if (Signature_user != null && Signature_user.isNotEmpty) {
    final sigProvider = pw.MemoryImage(Signature_user);
    signatureWidget = pw.Container(
      width: 120,
      height: 60,
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.ClipRRect(
        horizontalRadius: 8,
        verticalRadius: 8,
        child: pw.FittedBox(
          fit: pw.BoxFit.contain,
          child: pw.Image(sigProvider),
        ),
      ),
    );
    //  print(receiptmodel);
  }

  // ---------- เนื้อหาเอกสาร ----------
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.copyWith(
        marginBottom: 18.00,
        marginLeft: 18.00,
        marginRight: 18.00,
        marginTop: 18.00,
      ),
      // header: (context) {
      //   return pw.Column(
      //     crossAxisAlignment: pw.CrossAxisAlignment.start,
      //     mainAxisAlignment: pw.MainAxisAlignment.start,
      //     children: [
      //       // pw.Container(
      //       //   height: 60,
      //       //   width: 60,
      //       //   decoration: pw.BoxDecoration(
      //       //     border: pw.Border.all(color: PdfColors.grey300),
      //       //   ),
      //       //   // child: pw.Image(imageLogo),
      //       // ),
      //       pw.SizedBox(width: 10),
      //       pw.Text('เรียน  ปลัดเทศบาล',
      //           style: pw.TextStyle(
      //               font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
      //       pw.Text('เรียน  หัวหน้าสำนักปลัดเทศบาล',
      //           style: pw.TextStyle(
      //               font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
      //       pw.Text('เรียน  หัวหน้าฝ่ายปกครอง',
      //           style: pw.TextStyle(
      //               font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
      //     ],
      //   );
      // },
      build: (context) => [
        pw.SizedBox(height: 20),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text(
              'สำนักงานเทศบาลนครเชียงใหม่',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                  font: ttf, fontSize: 18, fontWeight: pw.FontWeight.bold),
            )
            // Textx(
            //   value: 'สำนักงานเทศบาล',
            //   font: ttf,
            // ),
          ],
        ),
        pw.Stack(
          children: [
            pw.Row(
              children: [
                pw.Expanded(
                  flex: 1,
                  child: pw.Container(
                      padding: pw.EdgeInsets.all(2),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.SizedBox(height: 50),
                          pw.Row(children: [
                            Textx(
                              value: 'ใบเสร็จ : ',
                              font: ttf,
                            ),
                            labeledLine(
                              value: '${receiptmodel['receiptDocno']}',
                              flex: 2,
                              font: ttf,
                            ),
                          ]),
                          pw.SizedBox(height: 7),
                          pw.Row(children: [
                            Textx(
                              value: 'ได้รับเงินจาก',
                              font: ttf,
                            ),
                            labeledLine(
                              value: '${receiptmodel['clientsName']}',
                              flex: 2,
                              font: ttf,
                            ),
                          ]),
                          pw.SizedBox(height: 7),
                          pw.Row(children: [
                            Textx(
                              value: 'ชำระค่า',
                              font: ttf,
                            ),
                            labeledLine(
                              value: 'ใบอนุญาตตั้งแผงลอย',
                              flex: 2,
                              font: ttf,
                            ),
                          ]),
                          pw.SizedBox(height: 7),
                          // Textx(
                          //   value: 'พื้นที่ประกอบการ',
                          //   font: ttf,
                          // ),
                          // pw.SizedBox(height: 2),
                          // pw.Row(children: [
                          //   Textx(
                          //     value: 'บริเวณ',
                          //     font: ttf,
                          //   ),
                          //   labeledLine(
                          //     value: '${receiptmodel['subzone'] ?? "-"}',
                          //     flex: 2,
                          //     font: ttf,
                          //   ),
                          // ]),
                          // pw.SizedBox(height: 7),
                          // pw.Row(children: [
                          //   Textx(
                          //     value: 'โซนพื้นที่',
                          //     font: ttf,
                          //   ),
                          //   labeledLine(
                          //     value: '${receiptmodel['zn']}',
                          //     flex: 2,
                          //     font: ttf,
                          //   ),
                          // ]),
                          // pw.SizedBox(height: 7),
                          // pw.Row(children: [
                          //   Textx(
                          //     value: 'รหัสพื้นที่',
                          //     font: ttf,
                          //   ),
                          //   labeledLine(
                          //     value: '${receiptmodel['ln']}',
                          //     flex: 2,
                          //     font: ttf,
                          //   ),
                          // ]),
                          // pw.SizedBox(height: 4),
                          Textx(
                            value: 'ไว้แล้วเป็นเงิน (ตัวอักษร)',
                            font: ttf,
                          ),
                          pw.SizedBox(height: 2),
                          pw.SizedBox(
                            height: 20,
                            child: pw.Row(
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.center,
                                mainAxisAlignment: pw.MainAxisAlignment.center,
                                children: [
                                  pw.Expanded(
                                      flex: 1,
                                      child: pw.Stack(
                                        children: [
                                          // Background image
                                          pw.Positioned.fill(
                                            child: pw.Image(
                                              image,
                                              fit: pw.BoxFit.fill,
                                            ),
                                          ),

                                          // Foreground content with border and background color
                                          pw.Align(
                                            alignment: pw.Alignment.center,
                                            child: pw.Container(
                                              padding:
                                                  const pw.EdgeInsets.all(4),
                                              // decoration: pw.BoxDecoration(
                                              //   color: PdfColors.grey300,
                                              //   border:
                                              //       pw.Border.all(color: PdfColors.grey600),
                                              // ),
                                              child: pw.Text(
                                                (totalSum == null)
                                                    ? '-'
                                                    : '(~${convertToThaiBaht(double.parse(totalSum.toString()))}~)',
                                                // 'ห้าร้อยบาทถ้วน',
                                                style: pw.TextStyle(
                                                    font: ttf, fontSize: 14),
                                              ),
                                            ),
                                          ),
                                          pw.Positioned.fill(
                                            child: pw.Image(
                                              image2,
                                              fit: pw.BoxFit.cover,
                                            ),
                                          ),
                                        ],
                                      ))
                                ]),
                          ),
                          pw.SizedBox(height: 2),
                          pw.SizedBox(
                              child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              pw.SizedBox(
                                width: 80,
                                height: 40,
                                child: (Signature_user == null ||
                                        Signature_user == '')
                                    ? null
                                    : signatureWidget,
                              ),
                              pw.Center(
                                child: Textx(
                                  value: ' ( $fullNameAdmin ) ',
                                  font: ttf,
                                ),
                              ),

                              pw.SizedBox(height: 2),
                              pw.Center(
                                child: Textx(
                                  value: 'ลงชื่อผู้รับเงิน',
                                  font: ttf,
                                ),
                              ),

                              // pw.SizedBox(
                              //   width: 80,
                              //   height: 40,
                              //   // child:
                              //   //     (Signature_user == null || Signature_user == '')
                              //   //         ? null
                              //   //         : signatureWidget,
                              // ),
                              // Textx(
                              //   value: ' ( $fullNameAdmin ) ',
                              //   font: ttf,
                              // ),
                              // pw.SizedBox(height: 2),
                              // Textx(
                              //   value: 'ผู้ตรวจสอบบัญชี ',
                              //   font: ttf,
                              // ),
                              // pw.SizedBox(height: 10),
                              // Textx(
                              //   value: '(ตราประทับเทศบาล)',
                              //   font: ttf,
                              // ),
                            ],
                          )),
                        ],
                      )),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Expanded(child: pw.SizedBox()),
                            Textx(
                              value: 'แผนก : ',
                              font: ttf,
                            ),
                            pw.SizedBox(
                              width: 150,
                              child: labeledLine(
                                value: 'งานรักษาความสงบเรียบร้อย',
                                // 'จัดหาประโยชน์จากทรัพย์สิน',
                                flex: 1,
                                font: ttf,
                              ),
                            ),
                            Textx(
                              value: ' หมวด : ',
                              font: ttf,
                            ),
                            pw.SizedBox(
                              width: 150,
                              child: labeledLine(
                                value: 'ค่าธรรมเนียม',
                                flex: 1,
                                font: ttf,
                              ),
                            )
                          ],
                        ),
                        pw.SizedBox(height: 2),
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Expanded(child: pw.SizedBox()),
                            Textx(
                              value: 'วันที่ : ',
                              font: ttf,
                            ),
                            pw.SizedBox(
                              width: 150,
                              child: labeledLine(
                                value: (receiptmodel['receiptDate'] == null ||
                                        receiptmodel['receiptDate'] == '' ||
                                        slipPdate == null)
                                    ? '-'
                                    : '$slipPdate',
                                //'${DateFormat('dd-MM-yyy').format(DateTime.parse('${receiptmodel['receiptDate']}'))}',
                                // '${receiptmodel['receiptDate']}',
                                flex: 1,
                                font: ttf,
                              ),
                            ),
                            Textx(
                              value: ' รูปแบบชำระ : ',
                              font: ttf,
                            ),
                            pw.SizedBox(
                              width: 150,
                              child: labeledLine(
                                value: '${receiptmodel['methodpay_th'] ?? "-"}',
                                flex: 1,
                                font: ttf,
                              ),
                            )
                            // Textx(
                            //   value: 'วันที่ : ',
                            //   font: ttf,
                            // ),
                            // pw.SizedBox(
                            //   width: 150,
                            //   child: labeledLine(
                            //     value: '${receiptmodel['receiptDate']}',
                            //     flex: 2,
                            //     font: ttf,
                            //   ),
                            // ),
                          ],
                        ),
                        pw.SizedBox(
                          height: 10,
                        ),
                        pw.Table(
                          border: pw.TableBorder(
                            left: const pw.BorderSide(
                                color: PdfColors.grey600),
                            right: const pw.BorderSide(
                                color: PdfColors.grey600),
                            top: const pw.BorderSide(
                                color: PdfColors.grey600),
                            bottom: const pw.BorderSide(
                                color: PdfColors.grey600),
                            verticalInside: const pw.BorderSide(
                                color: PdfColors.grey600),
                          ),
                          columnWidths: {
                            0: pw.FixedColumnWidth(32),
                            1: pw.FlexColumnWidth(1),
                            2: pw.FixedColumnWidth(72),
                            3: pw.FixedColumnWidth(32),
                          },
                          children: [
                            pw.TableRow(
                              children: [
                                pw.Container(
                                  padding: pw.EdgeInsets.all(4),
                                  decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                      bottom: pw.BorderSide(
                                          color: PdfColors.grey600),
                                    ),
                                  ),
                                  child: Textx(value: 'ที่', font: ttf),
                                ),
                                pw.Container(
                                  padding: pw.EdgeInsets.all(4),
                                  decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                      bottom: pw.BorderSide(
                                          color: PdfColors.grey600),
                                    ),
                                  ),
                                  child: Textx(value: 'รายการ', font: ttf),
                                ),
                                pw.Container(
                                  padding: pw.EdgeInsets.all(4),
                                  decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                      bottom: pw.BorderSide(
                                          color: PdfColors.grey600),
                                    ),
                                  ),
                                  child: Textx(value: 'จำนวนเงิน', font: ttf),
                                ),
                                pw.Container(
                                  padding: pw.EdgeInsets.all(4),
                                  decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                      bottom: pw.BorderSide(
                                          color: PdfColors.grey600),
                                    ),
                                  ),
                                  child: Textx(value: 'หน่วย', font: ttf),
                                ),
                              ],
                            ),
                            ...List.generate(expAutoModels.length, (index) {
                              final exp = expAutoModels[index];
                              return pw.TableRow(
                                children: [
                                  pw.Container(
                                    height: 80,
                                    padding: pw.EdgeInsets.all(4),
                                    child: Textx(value: '${index + 1}', font: ttf),
                                  ),
                                  pw.Container(
                                    height: 80,
                                    padding: pw.EdgeInsets.fromLTRB(8, 4, 4, 4),
                                    child: pw.Text(
                                      '${exp.expname} บริเวณ ${receiptmodel['subzone'] ?? "-"} โซนพื้นที่ ${receiptmodel['zn']}',
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                          font: ttf,
                                          fontSize: 14,
                                          fontWeight: pw.FontWeight.bold),
                                    ),
                                  ),
                                  pw.Container(
                                    height: 80,
                                    padding: pw.EdgeInsets.fromLTRB(0, 4, 4, 4),
                                    child: Textxright(
                                        value: getFormattedText('${exp.total}'),
                                        font: ttf),
                                  ),
                                  pw.Container(
                                    height: 80,
                                    padding: pw.EdgeInsets.all(4),
                                    child: Textx(value: 'บาท', font: ttf),
                                  ),
                                ],
                              );
                            }),
                            // spacer-start (kept commented)
                                    // pw.Expanded(
                                    //   child: pw.Container(
                                    //     // padding: pw.EdgeInsets.all(2),
                                    //     child: pw.Row(
                                    //       children: [
                                    //         pw.Container(
                                    //           width: 32,
                                    //           decoration: pw.BoxDecoration(
                                    //             // color: PdfColors.grey300,
                                    //             border: pw.Border(
                                    //               left: pw.BorderSide(
                                    //                   color: PdfColors.grey600),
                                    //               right: pw.BorderSide(
                                    //                   color: PdfColors.grey600),
                                    //               // top: pw.BorderSide(
                                    //               //     color: PdfColors.grey600),
                                    //               // bottom: pw.BorderSide(
                                    //               //     color: PdfColors.grey600),
                                    //             ),
                                    //           ),
                                    //         ),
                                    //         pw.Expanded(
                                    //           child: pw.Container(
                                    //               decoration:
                                    //                   const pw.BoxDecoration(
                                    //                 // color: PdfColors.grey300,
                                    //                 border: pw.Border(
                                    //                   right: pw.BorderSide(
                                    //                       color: PdfColors
                                    //                           .grey600),
                                    //                   // top: pw.BorderSide(
                                    //                   //     color: PdfColors.grey600),
                                    //                   // bottom: pw.BorderSide(
                                    //                   //     color: PdfColors.grey600),
                                    //                 ),
                                    //               ),
                                    //               child: pw.Column(
                                    //                 mainAxisAlignment: pw
                                    //                     .MainAxisAlignment
                                    //                     .start,
                                    //                 crossAxisAlignment: pw
                                    //                     .CrossAxisAlignment
                                    //                     .start,
                                    //                 children: [
                                    //                   pw.Padding(
                                    //                     padding: pw.EdgeInsets
                                    //                         .fromLTRB(
                                    //                             12, 1, 1, 1),
                                    //                     child: Textx(
                                    //                       value:
                                    //                           'พื้นที่ประกอบการ',
                                    //                       font: ttf,
                                    //                       fontSize: 14,
                                    //                     ),
                                    //                   ),

                                    //                   pw.SizedBox(height: 2),
                                    //                   pw.Padding(
                                    //                     padding: pw.EdgeInsets
                                    //                         .fromLTRB(
                                    //                             15, 1, 1, 1),
                                    //                     child: Textx(
                                    //                       value:
                                    //                           'บริเวณ ${receiptmodel['subzone']}',
                                    //                       font: ttf,
                                    //                       fontSize: 14,
                                    //                     ),
                                    //                   ),

                                    //                   // pw.Row(children: [
                                    //                   //   Textx(
                                    //                   //     value: 'บริเวณ',
                                    //                   //     font: ttf,
                                    //                   //   ),
                                    //                   //   labeledLine(
                                    //                   //     value:
                                    //                   //         ' ${receiptmodel['subzone'] ?? "-"}',
                                    //                   //     flex: 2,
                                    //                   //     font: ttf,
                                    //                   //   ),
                                    //                   // ]),
                                    //                   pw.SizedBox(height: 7),
                                    //                   pw.Padding(
                                    //                     padding: pw.EdgeInsets
                                    //                         .fromLTRB(
                                    //                             15, 1, 1, 1),
                                    //                     child: Textx(
                                    //                       value:
                                    //                           'โซนพื้นที่ ${receiptmodel['zn']}',
                                    //                       font: ttf,
                                    //                       fontSize: 14,
                                    //                     ),
                                    //                   ),

                                    //                   // pw.Row(children: [
                                    //                   //   Textx(
                                    //                   //     value: 'โซนพื้นที่',
                                    //                   //     font: ttf,
                                    //                   //   ),
                                    //                   //   labeledLine(
                                    //                   //     value:
                                    //                   //         'โซนพื้นที่${receiptmodel['zn']}',
                                    //                   //     flex: 2,
                                    //                   //     font: ttf,
                                    //                   //   ),
                                    //                   // ]),
                                    //                   pw.SizedBox(height: 7),
                                    //                   pw.Padding(
                                    //                     padding: pw.EdgeInsets
                                    //                         .fromLTRB(
                                    //                             15, 1, 1, 1),
                                    //                     child: Textx(
                                    //                       value:
                                    //                           'รหัสพื้นที่ ${receiptmodel['ln']}',
                                    //                       font: ttf,
                                    //                       fontSize: 14,
                                    //                     ),
                                    //                   ),

                                    //                   // pw.Row(children: [
                                    //                   //   Textx(
                                    //                   //     value: 'รหัสพื้นที่',
                                    //                   //     font: ttf,
                                    //                   //   ),
                                    //                   //   labeledLine(
                                    //                   //     value:
                                    //                   //         '${receiptmodel['ln']}',
                                    //                   //     flex: 2,
                                    //                   //     font: ttf,
                                    //                   //   ),
                                    //                   // ]),
                                    //                   pw.SizedBox(height: 4),
                                    //                 ],
                                    //               )),
                                    //         ),
                                    //         pw.Container(
                                    //           width: 70,
                                    //           decoration: pw.BoxDecoration(
                                    //               // color: PdfColors.grey300,
                                    //               // border: pw.Border(
                                    //               //   right: pw.BorderSide(
                                    //               //       color: PdfColors.grey600),
                                    //               //   // top: pw.BorderSide(
                                    //               //   //     color: PdfColors.grey600),
                                    //               //   // bottom: pw.BorderSide(
                                    //               //   //     color: PdfColors.grey600),
                                    //               // ),
                                    //               ),
                                    //         ),
                                    //         pw.Container(
                                    //           width: 32,
                                    //           decoration: pw.BoxDecoration(
                                    //             // color: PdfColors.grey300,
                                    //             border: pw.Border(
                                    //               left: pw.BorderSide(
                                    //                   color: PdfColors.grey600),
                                    //               right: pw.BorderSide(
                                    //                   color: PdfColors.grey600),
                                    //               // top: pw.BorderSide(
                                    //               //     color: PdfColors.grey600),
                                    //               // bottom: pw.BorderSide(
                                    //               //     color: PdfColors.grey600),
                                    //             ),
                                    //           ),
                                    //         ),
                                    //       ],
                                    //     ),
                                    //   ),
                                    // ),

                            pw.TableRow(
                              children: [
                                pw.Container(
                                  height: 25,
                                  padding: pw.EdgeInsets.all(4),
                                  decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                      top: pw.BorderSide(
                                          color: PdfColors.grey600),
                                    ),
                                  ),
                                ),
                                pw.Container(
                                  height: 25,
                                  padding: pw.EdgeInsets.all(4),
                                  decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                      top: pw.BorderSide(
                                          color: PdfColors.grey600),
                                    ),
                                  ),
                                  child: pw.Align(
                                    alignment: pw.Alignment.centerRight,
                                    child: Textx(value: 'รวมเงิน ', font: ttf),
                                  ),
                                ),
                                pw.Container(
                                  height: 25,
                                  padding: pw.EdgeInsets.fromLTRB(0, 4, 4, 4),
                                  decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                      top: pw.BorderSide(
                                          color: PdfColors.grey600),
                                    ),
                                  ),
                                  child: pw.Align(
                                    alignment: pw.Alignment.centerRight,
                                    child: Textxright(
                                        value:
                                            '${getFormattedText('${totalSum}')}',
                                        font: ttf),
                                  ),
                                ),
                                pw.Container(
                                  height: 25,
                                  padding: pw.EdgeInsets.all(4),
                                  decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                      top: pw.BorderSide(
                                          color: PdfColors.grey600),
                                    ),
                                  ),
                                  child: pw.Align(
                                    alignment: pw.Alignment.center,
                                    child: Textx(value: 'บาท', font: ttf),
                                  ),
                                ),
                              ],
                            ),
                            // pw.Positioned(
                            //   bottom: 30,
                            //   left: 100,
                            //   child: pw.Opacity(
                            //     opacity: 0.2, // 80% โปร่งใส (เห็น 20%)
                            //     child: pw.Container(
                            //       width: 150,
                            //       height: 150,
                            //       child: pw.Image(image3, fit: pw.BoxFit.cover),
                            //     ),
                            //   ),
                            // )

                            // pw.Positioned(
                            //     bottom: 30,
                            //     left: 100,
                            //     child: pw.Container(
                            //       width: 150,
                            //       height: 150,
                            //       child: pw.Image(
                            //         image3,
                            //         // fit: pw.BoxFit.cover,
                            //       ),
                            //     )),
                          ],
                        )
                      ]),
                ),
              ],
            ),
            pw.Positioned(
              bottom: 30,
              left: 120,
              child: pw.Opacity(
                opacity: 0.28, // 63% โปร่งใส (เห็น 28%)
                child: pw.Container(
                  width: 180,
                  height: 180,
                  child: pw.Image(image3, fit: pw.BoxFit.cover),
                ),
              ),
            )
          ],
        ),
      ],
    ),
  );

  // final List<int> bytes = await pdf.save();
  // final Uint8List data = Uint8List.fromList(bytes);
  // MimeType type = MimeType.PDF;
  // final dir = await FileSaver.instance.saveFile(
  //     "ใบพิจารณาคำขอต่อใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ", data, "pdf",
  //     mimeType: type);
  if (type == 0) {
    // final List<int> bytes = await pdf.save();
    // final Uint8List data = Uint8List.fromList(bytes);
    // // final List<int> bytes = await pdf.save();
    // // final Uint8List data = Uint8List.fromList(bytes);

    // return bytes;
    return pdf; // ✅ ส่ง document กลับ
  } else {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewPdfgen1_CMM(
              doc: pdf, title: 'ใบเสร็จรับเงิน(สำนักงานเทศบาล)'),
        ));
  }
}
