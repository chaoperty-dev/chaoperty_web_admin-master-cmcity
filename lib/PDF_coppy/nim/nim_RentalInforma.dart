// import 'package:file_saver/file_saver.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/services.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'dart:math' as math;
// import 'package:intl/intl.dart';
// import 'package:flutter/material.dart';
// import 'package:printing/printing.dart';

// import '../../ChaoArea/ChaoAreaRenew_Screen.dart';
// import '../../Man_PDF/Preview_PDF/Preview_RentalInforma.dart';
// import '../../Model/GetC_Quot_Select_Model.dart';
// import '../../PeopleChao/Rental_Information.dart';
// import '../../Style/ThaiBaht.dart';
// import '../../Style/loadAndCacheImage.dart';

// ///////-------------------------------------------> ( ใบเสนอราคา/สัญญาเช่าพื้นที่ )
// class Pdfgen_RentalInformanim {
//   static void exportPDF_RentalInformanim(
//     context,
//     Get_Value_NameShop_index,
//     Get_Value_cid,
//     _verticalGroupValue,
//     Form_nameshop,
//     Form_typeshop,
//     Form_bussshop,
//     Form_bussscontact,
//     Form_address,
//     Form_tel,
//     Form_email,
//     Form_tax,
//     Form_ln,
//     Form_zn,
//     Form_area,
//     Form_qty,
//     Form_sdate,
//     Form_ldate,
//     Form_period,
//     Form_rtname,
//     Form_cdate,
//     quotxSelectModels,
//     _TransModels,
//     renTal_name,
//     bill_addr,
//     bill_email,
//     bill_tel,
//     bill_tax,
//     bill_name,
//     newValuePDFimg,
//   ) async {
//     final pdf = pw.Document();
//     // final fontData = await rootBundle.load("ThaiFonts/Sarabun-Medium.ttf");
//     // var dataint = fontData.buffer
//     //     .asUint8List(fontData.offsetInBytes, fontData.lengthInBytes);
//     // final PdfFont font = PdfFont.of(pdf, data: dataint);
//     // final font = await rootBundle.load("fonts/Sarabun-Medium.ttf");
//     final font = await rootBundle.load("fonts/THSarabunNew.ttf");
//     var Colors_pd = PdfColors.black;
//     int pageCount = 1; // Initialize the page count
//     final ttf = pw.Font.ttf(font);
//     double font_Size = 10.0; //12
//     DateTime date = DateTime.now();
//     var formatter = new DateFormat.MMMMd('th_TH');
//     String thaiDate = formatter.format(date);
//     var nFormat = NumberFormat("#,##0.00", "en_US");
//     final iconImage =
//         (await rootBundle.load('images/LOGO.png')).buffer.asUint8List();
//     List netImage = [];
//     Uint8List? resizedLogo = await getResizedLogo();

//     ///////////////////////------------------------------------------------->

//     // double total_ = 0.00;
//     // // final tableData = [
//     // for (int index = 0; index < quotxSelectModels.length; index++)
//     //   total_ = total_ +
//     //       (int.parse((quotxSelectModels[index].total == null)
//     //               ? 0.00
//     //               : quotxSelectModels[index].term!) *
//     //           double.parse((quotxSelectModels[index].total == null)
//     //               ? 0.00
//     //               : quotxSelectModels[index].total!));
//     //     [
//     //       '${quotxSelectModels[index].unit} / ${quotxSelectModels[index].term} (งวด)',
//     //       '${quotxSelectModels[index].expname}',
//     //       '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${quotxSelectModels[index].sdate!} 00:00:00'))} - ${DateFormat('dd-MM-yyyy').format(DateTime.parse('${quotxSelectModels[index].ldate!} 00:00:00'))}',
//     //       '${nFormat.format(double.parse(quotxSelectModels[index].total!))}',
//     //       '${nFormat.format(int.parse(quotxSelectModels[index].term!) * double.parse(quotxSelectModels[index].total!))}',
//     //     ],
//     // ];

//     final thinBorder = pw.BorderSide(color: PdfColors.black, width: 0.1);
//     String normalizeThai(String text) {
//       // 🔸 ตัดสระทั้งหมดและวรรณยุกต์
//       return text
//           .replaceAll(RegExp(r'[่-๋็์]'), '') // ตัดวรรณยุกต์
//           .replaceAll(RegExp(r'[ะาิีึืุูเแโใไไำๅั็่้๊๋์]'), '') // ตัดสระ
//           .toLowerCase()
//           .trim();
//     }

//     String convertToThaiYear(String dateStr) {
//       final parts = dateStr.split('-');
//       if (parts.length != 3) return dateStr;
//       final int year = int.tryParse(parts[2]) ?? 0;
//       return '${parts[0]}-${parts[1]}-${year + 543}';
//     }

//     // ✅ ใช้เรียง
//     final List<QuotxSelectModel> filteredList1 = quotxSelectModels
//         .where((item) => (item.dtype ?? '').trim() != "KD")
//         .toList()
//       ..sort((QuotxSelectModel a, QuotxSelectModel b) =>
//           normalizeThai(a.expname ?? '')
//               .compareTo(normalizeThai(b.expname ?? '')));

//     final List<QuotxSelectModel> filteredList2 = quotxSelectModels
//         .where((item) => (item.dtype ?? '').trim() == "KD")
//         .toList()
//       ..sort((QuotxSelectModel a, QuotxSelectModel b) =>
//           normalizeThai(a.expname ?? '')
//               .compareTo(normalizeThai(b.expname ?? '')));

//     final total_all = nFormat.format(
//       (filteredList1.fold<double>(
//             0.00,
//             (double sum, dynamic item) =>
//                 sum + (item.total != null ? double.parse(item.total!) : 0.00),
//           )) +
//           (filteredList2.fold<double>(
//             0.00,
//             (double sum, dynamic item) =>
//                 sum + (item.total != null ? double.parse(item.total!) : 0.00),
//           )),
//     );

//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4.copyWith(
//           marginBottom: 30.00,
//           marginLeft: 30.00,
//           marginRight: 30.00,
//           marginTop: 30.00,
//         ),
//         header: (context) {
//           return pw.Column(children: [
//             pw.Row(
//               children: [
//                 pw.Container(
//                   height: 45,
//                   width: 90,
//                   decoration: pw.BoxDecoration(
//                     color: PdfColors.grey200,
//                     border: pw.Border.all(color: PdfColors.grey300),
//                   ),
//                   child: resizedLogo != null
//                       ? pw.Image(
//                           pw.MemoryImage(resizedLogo),
//                           height: 45,
//                           width: 90,
//                           fit: pw.BoxFit.fill, // <-- บังคับให้เต็ม
//                         )
//                       : pw.Center(
//                           child: pw.Text(
//                             '$bill_name ',
//                             maxLines: 1,
//                             style: pw.TextStyle(
//                               fontSize: 10,
//                               font: ttf,
//                               color: Colors_pd,
//                             ),
//                           ),
//                         ),
//                 ),
//                 pw.SizedBox(width: 8 * PdfPageFormat.mm),
//                 pw.Container(
//                   child: pw.Column(
//                     mainAxisSize: pw.MainAxisSize.min,
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Text(
//                         '${bill_name.trim()}', //$bill_addr
//                         maxLines: 3,
//                         style: pw.TextStyle(
//                           fontSize: font_Size,
//                           color: Colors_pd,
//                           font: ttf,
//                         ),
//                       ),
//                       pw.SizedBox(height: 1 * PdfPageFormat.mm),
//                       pw.Text(
//                         'เลขที่ ${bill_addr.trim()}', //
//                         maxLines: 3,
//                         style: pw.TextStyle(
//                           fontSize: font_Size,
//                           color: Colors_pd,
//                           font: ttf,
//                         ),
//                       ),
//                       pw.SizedBox(height: 1 * PdfPageFormat.mm),
//                       pw.Row(
//                         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                         crossAxisAlignment: pw.CrossAxisAlignment.start,
//                         children: [
//                           pw.Text(
//                             'โทร หรือ แฟกซ์ : 053/273800 /  โทร : $bill_tel', // fax?
//                             maxLines: 2,
//                             style: pw.TextStyle(
//                               fontSize: font_Size,
//                               // fontWeight: pw.FontWeight.bold,
//                               font: ttf,
//                               color: Colors_pd,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 pw.Spacer(),
//                 pw.Container(
//                   child: pw.Column(
//                     mainAxisSize: pw.MainAxisSize.min,
//                     crossAxisAlignment: pw.CrossAxisAlignment.end,
//                     children: [
//                       pw.SizedBox(height: 12 * PdfPageFormat.mm),
//                       pw.Align(
//                         alignment: pw.Alignment.centerRight,
//                         child: pw.Text(
//                           'วันที่จัดพิมพ์ : ${DateFormat('dd-MM-').format(DateTime.now())}${DateTime.now().year + 543}',
//                           textAlign: pw.TextAlign.right,
//                           style: pw.TextStyle(
//                             fontSize: font_Size,
//                             font: ttf,
//                             color: Colors_pd,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ]);
//         },
//         build: (context) {
//           return [
//             pw.SizedBox(height: 6 * PdfPageFormat.mm),
//             pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.center,
//               children: [
//                 pw.Text(
//                   'ใบเสนอราคา',
//                   textAlign: pw.TextAlign.left,
//                   style: pw.TextStyle(
//                     fontSize: font_Size,
//                     font: ttf,
//                     fontWeight: pw.FontWeight.bold,
//                     color: Colors_pd,
//                   ),
//                 ),
//               ],
//             ),
//             pw.SizedBox(height: 4 * PdfPageFormat.mm),
//             pw.Align(
//               alignment: pw.Alignment.center,
//               child: pw.Container(
//                 child: pw.Column(
//                   mainAxisAlignment: pw.MainAxisAlignment.center,
//                   children: [
//                     pw.Row(
//                       mainAxisAlignment: pw.MainAxisAlignment.start,
//                       children: [
//                         pw.Text(
//                           'ข้อมูลผู้เช่า',
//                           textAlign: pw.TextAlign.left,
//                           style: pw.TextStyle(
//                             fontSize: font_Size,
//                             font: ttf,
//                             fontWeight: pw.FontWeight.bold,
//                             color: Colors_pd,
//                           ),
//                         ),
//                       ],
//                     ),
//                     pw.SizedBox(height: 4 * PdfPageFormat.mm),
//                     pw.Row(
//                       children: [
//                         pw.Expanded(
//                           flex: 1,
//                           child: pw.Text(
//                             'ชื่อร้าน : ',
//                             textAlign: pw.TextAlign.left,
//                             style: pw.TextStyle(
//                               fontSize: font_Size,
//                               fontWeight: pw.FontWeight.bold,
//                               font: ttf,
//                               color: Colors_pd,
//                             ),
//                           ),
//                         ),
//                         pw.Expanded(
//                           flex: 2,
//                           child: pw.Container(
//                             decoration: pw.BoxDecoration(
//                                 border: pw.Border(
//                                     bottom: pw.BorderSide(
//                               color: PdfColors.black,
//                               width: 0.05, // Underline thickness
//                             ))),
//                             child: pw.Text(
//                               '$Form_nameshop',
//                               textAlign: pw.TextAlign.center,
//                               style: pw.TextStyle(
//                                 fontSize: font_Size,
//                                 // fontWeight: pw.FontWeight.bold,
//                                 font: ttf,
//                                 color: Colors_pd,
//                               ),
//                             ),
//                           ),
//                         ),
//                         pw.Expanded(
//                           flex: 1,
//                           // child: pw.Text(
//                           //   Get_Value_NameShop_index.toString() == '1'
//                           //       ? 'เลขที่ใบสัญญา : '
//                           //       : 'เลขที่ใบเสนอราคา : ',
//                           //   textAlign: pw.TextAlign.center,
//                           //   style: pw.TextStyle(
//                           //     fontSize: font_Size,
//                           //     fontWeight: pw.FontWeight.bold,
//                           //     font: ttf,
//                           //     color: Colors_pd,
//                           //   ),
//                           // ),
//                           child: pw.Text(
//                             'เลขที่ใบเสนอราคา : ',
//                             textAlign: pw.TextAlign.center,
//                             style: pw.TextStyle(
//                               fontSize: font_Size,
//                               fontWeight: pw.FontWeight.bold,
//                               font: ttf,
//                               color: Colors_pd,
//                             ),
//                           ),
//                         ),
//                         pw.Expanded(
//                           flex: 2,
//                           child: pw.Container(
//                             decoration: pw.BoxDecoration(
//                                 border: pw.Border(
//                                     bottom: pw.BorderSide(
//                               color: PdfColors.black,
//                               width: 0.05, // Underline thickness
//                             ))),
//                             child: pw.Text(
//                               '$Get_Value_cid',
//                               textAlign: pw.TextAlign.center,
//                               style: pw.TextStyle(
//                                 fontSize: font_Size,
//                                 // fontWeight: pw.FontWeight.bold,
//                                 font: ttf,
//                                 color: Colors_pd,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     pw.SizedBox(height: 2 * PdfPageFormat.mm),
//                     pw.Row(
//                       children: [
//                         pw.Expanded(
//                           flex: 1,
//                           child: pw.Text(
//                             'ชื่อผู้เช่า : ',
//                             textAlign: pw.TextAlign.left,
//                             style: pw.TextStyle(
//                               fontSize: font_Size,
//                               fontWeight: pw.FontWeight.bold,
//                               font: ttf,
//                               color: Colors_pd,
//                             ),
//                           ),
//                         ),
//                         pw.Expanded(
//                           flex: 2,
//                           child: pw.Container(
//                             decoration: pw.BoxDecoration(
//                                 border: pw.Border(
//                                     bottom: pw.BorderSide(
//                               color: PdfColors.black,
//                               width: 0.05, // Underline thickness
//                             ))),
//                             child: pw.Text(
//                               '$Form_bussshop',
//                               textAlign: pw.TextAlign.center,
//                               style: pw.TextStyle(
//                                 fontSize: font_Size,
//                                 // fontWeight: pw.FontWeight.bold,
//                                 font: ttf,
//                                 color: Colors_pd,
//                               ),
//                             ),
//                           ),
//                         ),
//                         pw.Expanded(
//                           flex: 1,
//                           child: pw.Text(
//                             'เบอร์ติดต่อ : ',
//                             textAlign: pw.TextAlign.center,
//                             style: pw.TextStyle(
//                               fontSize: font_Size,
//                               fontWeight: pw.FontWeight.bold,
//                               font: ttf,
//                               color: Colors_pd,
//                             ),
//                           ),
//                         ),
//                         pw.Expanded(
//                           flex: 2,
//                           child: pw.Container(
//                             decoration: pw.BoxDecoration(
//                                 border: pw.Border(
//                                     bottom: pw.BorderSide(
//                               color: PdfColors.black,
//                               width: 0.05, // Underline thickness
//                             ))),
//                             child: pw.Text(
//                               '$Form_tel',
//                               textAlign: pw.TextAlign.center,
//                               style: pw.TextStyle(
//                                 fontSize: font_Size,
//                                 // fontWeight: pw.FontWeight.bold,
//                                 font: ttf,
//                                 color: Colors_pd,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     pw.SizedBox(height: 2 * PdfPageFormat.mm),
//                     pw.Row(
//                       children: [
//                         pw.Expanded(
//                           flex: 1,
//                           child: pw.Text(
//                             'ที่อยู่ : ',
//                             style: pw.TextStyle(
//                               fontSize: font_Size,
//                               fontWeight: pw.FontWeight.bold,
//                               font: ttf,
//                               color: Colors_pd,
//                             ),
//                           ),
//                         ),
//                         pw.Expanded(
//                           flex: 5,
//                           child: pw.Container(
//                             decoration: pw.BoxDecoration(
//                                 border: pw.Border(
//                                     bottom: pw.BorderSide(
//                               color: PdfColors.black,
//                               width: 0.05, // Underline thickness
//                             ))),
//                             child: pw.Text(
//                               '$Form_address',
//                               textAlign: pw.TextAlign.center,
//                               style: pw.TextStyle(
//                                 fontSize: font_Size,
//                                 // fontWeight: pw.FontWeight.bold,
//                                 font: ttf,
//                                 color: Colors_pd,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     pw.SizedBox(height: 2 * PdfPageFormat.mm),
//                     pw.Row(
//                       children: [
//                         pw.Expanded(
//                           flex: 1,
//                           child: pw.Text(
//                             'ID/TAX ID : ',
//                             style: pw.TextStyle(
//                               fontSize: font_Size,
//                               fontWeight: pw.FontWeight.bold,
//                               font: ttf,
//                               color: Colors_pd,
//                             ),
//                           ),
//                         ),
//                         pw.Expanded(
//                           flex: 5,
//                           child: pw.Container(
//                             decoration: pw.BoxDecoration(
//                                 border: pw.Border(
//                                     bottom: pw.BorderSide(
//                               color: PdfColors.black,
//                               width: 0.05, // Underline thickness
//                             ))),
//                             // decoration: pw.BoxDecoration(
//                             //     border: pw.Border(
//                             //         bottom: pw.BorderSide(
//                             //   color: Colors_pd,
//                             //   width: 1.0, // Underline thickness
//                             // ))),
//                             child: pw.Text(
//                               '$Form_tax',
//                               textAlign: pw.TextAlign.center,
//                               style: pw.TextStyle(
//                                 fontSize: font_Size,
//                                 // fontWeight: pw.FontWeight.bold,
//                                 font: ttf,
//                                 color: Colors_pd,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     pw.SizedBox(height: 2 * PdfPageFormat.mm),
//                     pw.Row(
//                       children: [
//                         pw.Expanded(
//                           flex: 1,
//                           child: pw.Text(
//                             'รหัสพื้นที่/รวมพื้นที่ : ',
//                             style: pw.TextStyle(
//                               fontSize: font_Size,
//                               fontWeight: pw.FontWeight.bold,
//                               font: ttf,
//                               color: Colors_pd,
//                             ),
//                           ),
//                         ),
//                         pw.Expanded(
//                           flex: 2,
//                           child: pw.Container(
//                             decoration: pw.BoxDecoration(
//                                 border: pw.Border(
//                                     bottom: pw.BorderSide(
//                               color: PdfColors.black,
//                               width: 0.05, // Underline thickness
//                             ))),
//                             child: pw.Text(
//                               '$Form_ln ($Form_area ตร.ม.)',
//                               textAlign: pw.TextAlign.center,
//                               style: pw.TextStyle(
//                                 fontSize: font_Size,
//                                 // fontWeight: pw.FontWeight.bold,
//                                 font: ttf,
//                                 color: Colors_pd,
//                               ),
//                             ),
//                           ),
//                         ),
//                         pw.Expanded(
//                           flex: 1,
//                           child: pw.Text(
//                             'โซนพื้นที่เช่า :',
//                             textAlign: pw.TextAlign.center,
//                             style: pw.TextStyle(
//                               fontSize: font_Size,
//                               fontWeight: pw.FontWeight.bold,
//                               font: ttf,
//                               color: Colors_pd,
//                             ),
//                           ),
//                         ),
//                         pw.Expanded(
//                           flex: 2,
//                           child: pw.Container(
//                             decoration: pw.BoxDecoration(
//                                 border: pw.Border(
//                                     bottom: pw.BorderSide(
//                               color: PdfColors.black,
//                               width: 0.05, // Underline thickness
//                             ))),
//                             child: pw.Text(
//                               '$Form_zn',
//                               textAlign: pw.TextAlign.center,
//                               style: pw.TextStyle(
//                                 fontSize: font_Size,
//                                 // fontWeight: pw.FontWeight.bold,
//                                 font: ttf,
//                                 color: Colors_pd,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     pw.SizedBox(height: 2 * PdfPageFormat.mm),
//                     pw.Row(
//                       children: [
//                         pw.Expanded(
//                           flex: 1,
//                           child: pw.Text(
//                             'วันที่เริ่มสัญญา : ',
//                             style: pw.TextStyle(
//                               fontSize: font_Size,
//                               fontWeight: pw.FontWeight.bold,
//                               font: ttf,
//                               color: Colors_pd,
//                             ),
//                           ),
//                         ),
//                         pw.Expanded(
//                           flex: 2,
//                           child: pw.Container(
//                             decoration: pw.BoxDecoration(
//                                 border: pw.Border(
//                                     bottom: pw.BorderSide(
//                               color: PdfColors.black,
//                               width: 0.05, // Underline thickness
//                             ))),
//                             child: pw.Text(
//                               convertToThaiYear(Form_sdate),
//                               textAlign: pw.TextAlign.center,
//                               style: pw.TextStyle(
//                                 fontSize: font_Size,
//                                 // fontWeight: pw.FontWeight.bold,
//                                 font: ttf,
//                                 color: Colors_pd,
//                               ),
//                             ),
//                           ),
//                         ),
//                         pw.Expanded(
//                           flex: 1,
//                           child: pw.Text(
//                             'วันที่สิ้นสุดสัญญา :',
//                             textAlign: pw.TextAlign.center,
//                             style: pw.TextStyle(
//                               fontSize: font_Size,
//                               fontWeight: pw.FontWeight.bold,
//                               font: ttf,
//                               color: Colors_pd,
//                             ),
//                           ),
//                         ),
//                         pw.Expanded(
//                           flex: 2,
//                           child: pw.Container(
//                             decoration: pw.BoxDecoration(
//                                 border: pw.Border(
//                                     bottom: pw.BorderSide(
//                               color: PdfColors.black,
//                               width: 0.05, // Underline thickness
//                             ))),
//                             child: pw.Text(
//                               convertToThaiYear(Form_ldate),
//                               textAlign: pw.TextAlign.center,
//                               style: pw.TextStyle(
//                                 fontSize: font_Size,
//                                 // fontWeight: pw.FontWeight.bold,
//                                 font: ttf,
//                                 color: Colors_pd,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     pw.SizedBox(height: 2 * PdfPageFormat.mm),
//                     pw.Row(
//                       children: [
//                         pw.Expanded(
//                           flex: 1,
//                           child: pw.Text(
//                             'ประเภท/ระยะเวลาการเช่า : ',
//                             style: pw.TextStyle(
//                               fontSize: font_Size,
//                               fontWeight: pw.FontWeight.bold,
//                               font: ttf,
//                               color: Colors_pd,
//                             ),
//                           ),
//                         ),
//                         pw.Expanded(
//                           flex: 2,
//                           child: pw.Container(
//                             decoration: pw.BoxDecoration(
//                                 border: pw.Border(
//                                     bottom: pw.BorderSide(
//                               color: PdfColors.black,
//                               width: 0.05, // Underline thickness
//                             ))),
//                             child: pw.Text(
//                               '$Form_rtname ($Form_period เดือน)', // format
//                               textAlign: pw.TextAlign.center,
//                               style: pw.TextStyle(
//                                 fontSize: font_Size,
//                                 // fontWeight: pw.FontWeight.bold,
//                                 font: ttf,
//                                 color: Colors_pd,
//                               ),
//                             ),
//                           ),
//                         ),
//                         pw.Expanded(
//                           flex: 1,
//                           child: pw.Text(
//                             'ราคาต่อหน่วย :',
//                             textAlign: pw.TextAlign.center,
//                             style: pw.TextStyle(
//                               fontSize: font_Size,
//                               fontWeight: pw.FontWeight.bold,
//                               font: ttf,
//                               color: Colors_pd,
//                             ),
//                           ),
//                         ),
//                         pw.Expanded(
//                           flex: 2,
//                           child: pw.Container(
//                             decoration: const pw.BoxDecoration(
//                                 border: pw.Border(
//                                     bottom: pw.BorderSide(
//                               color: PdfColors.black,
//                               width: 0.05, // Underline thickness
//                             ))),
//                             child: pw.Text(
//                               '-',
//                               textAlign: pw.TextAlign.center,
//                               style: pw.TextStyle(
//                                 fontSize: font_Size,
//                                 // fontWeight: pw.FontWeight.bold,
//                                 font: ttf,
//                                 color: Colors_pd,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     pw.Row(children: [
//                       pw.Expanded(
//                         flex: 1,
//                         child: pw.Container(
//                           height: 10,
//                           decoration: pw.BoxDecoration(
//                               // color: PdfColors.green100,
//                               border: pw.Border(
//                                   bottom: pw.BorderSide(
//                             color: PdfColors.grey200,
//                             width: 8.0, // Underline thickness
//                           ))),
//                           padding: const pw.EdgeInsets.all(8.0),
//                         ),
//                       )
//                     ]),
//                     // รายละเอียดค่าบริการ
//                     pw.SizedBox(height: 2 * PdfPageFormat.mm),
//                     pw.Center(
//                       child: pw.Column(
//                         mainAxisAlignment: pw.MainAxisAlignment.center,
//                         children: [
//                           pw.Row(
//                             mainAxisAlignment: pw.MainAxisAlignment.start,
//                             children: [
//                               pw.Text(
//                                 'รายละเอียดค่าบริการ',
//                                 textAlign: pw.TextAlign.left,
//                                 style: pw.TextStyle(
//                                   fontSize: font_Size,
//                                   font: ttf,
//                                   fontWeight: pw.FontWeight.bold,
//                                   color: Colors_pd,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           pw.SizedBox(height: 3 * PdfPageFormat.mm),
//                           pw.Container(
//                             height: 20,
//                             decoration: const pw.BoxDecoration(
//                               color: PdfColors.lightBlue100,
//                             ),
//                             child: pw.Row(
//                               children: [
//                                 pw.Expanded(
//                                   flex: 1,
//                                   child: pw.Container(
//                                     decoration: pw.BoxDecoration(
//                                       border: pw.Border(
//                                         bottom: thinBorder,
//                                         left: thinBorder,
//                                         right: thinBorder,
//                                         top: thinBorder,
//                                       ),
//                                     ),
//                                     child: pw.Center(
//                                       child: pw.Text(
//                                         'ลำดับ',
//                                         textAlign: pw.TextAlign.center,
//                                         style: pw.TextStyle(
//                                           fontSize: font_Size,
//                                           font: ttf,
//                                           fontWeight: pw.FontWeight.bold,
//                                           color: Colors_pd,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 pw.Expanded(
//                                   flex: 7,
//                                   child: pw.Container(
//                                     decoration: pw.BoxDecoration(
//                                       border: pw.Border(
//                                         bottom: thinBorder,
//                                         left: thinBorder,
//                                         right: thinBorder,
//                                         top: thinBorder,
//                                       ),
//                                     ),
//                                     child: pw.Center(
//                                       child: pw.Text(
//                                         'รายการ',
//                                         textAlign: pw.TextAlign.center,
//                                         style: pw.TextStyle(
//                                           fontSize: font_Size,
//                                           font: ttf,
//                                           fontWeight: pw.FontWeight.bold,
//                                           color: Colors_pd,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 pw.Expanded(
//                                   flex: 3,
//                                   child: pw.Container(
//                                     decoration: pw.BoxDecoration(
//                                       border: pw.Border(
//                                         bottom: thinBorder,
//                                         left: thinBorder,
//                                         right: thinBorder,
//                                         top: thinBorder,
//                                       ),
//                                     ),
//                                     child: pw.Center(
//                                       child: pw.Text(
//                                         'ราคา',
//                                         textAlign: pw.TextAlign.center,
//                                         style: pw.TextStyle(
//                                           fontSize: font_Size,
//                                           font: ttf,
//                                           fontWeight: pw.FontWeight.bold,
//                                           color: Colors_pd,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           pw.Container(
//                             height: 20,
//                             decoration: const pw.BoxDecoration(
//                               color: PdfColors.white,
//                             ),
//                             child: pw.Row(
//                               children: [
//                                 pw.Expanded(
//                                   flex: 1,
//                                   child: pw.Container(
//                                     decoration: pw.BoxDecoration(
//                                       border: pw.Border(
//                                         bottom: thinBorder,
//                                         left: thinBorder,
//                                         right: thinBorder,
//                                         top: thinBorder,
//                                       ),
//                                     ),
//                                     child: pw.Center(
//                                       child: pw.Text(
//                                         '1',
//                                         textAlign: pw.TextAlign.center,
//                                         style: pw.TextStyle(
//                                           fontSize: font_Size,
//                                           font: ttf,
//                                           fontWeight: pw.FontWeight.bold,
//                                           color: Colors_pd,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 pw.Expanded(
//                                   flex: 7,
//                                   child: pw.Container(
//                                     height: 20,
//                                     decoration: pw.BoxDecoration(
//                                       color: PdfColors.white,
//                                       border: pw.Border(
//                                         bottom: thinBorder,
//                                         left: thinBorder,
//                                         right: thinBorder,
//                                         top: thinBorder,
//                                       ),
//                                     ),
//                                     child: pw.Align(
//                                       alignment:
//                                           pw.Alignment.centerLeft, // ✅ ชิดซ้าย
//                                       child: pw.Padding(
//                                         padding: pw.EdgeInsets.only(
//                                             left: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//                                         child: pw.Text(
//                                           'ค่าใช้จ่ายในการเช่าและค่าบริการรายเดือน',
//                                           style: pw.TextStyle(
//                                             fontSize: font_Size,
//                                             font: ttf,
//                                             color: Colors_pd,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 pw.Expanded(
//                                   flex: 3,
//                                   child: pw.Container(
//                                     height: 20,
//                                     decoration: pw.BoxDecoration(
//                                       color: PdfColors.white,
//                                       border: pw.Border(
//                                         bottom: thinBorder,
//                                         left: thinBorder,
//                                         right: thinBorder,
//                                         top: thinBorder,
//                                       ),
//                                     ),
//                                     child: pw.Align(
//                                       alignment:
//                                           pw.Alignment.centerRight, // ✅ ชิดซ้าย
//                                       child: pw.Padding(
//                                         padding: pw.EdgeInsets.only(
//                                             right: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//                                         child: pw.Text(
//                                           '',
//                                           style: pw.TextStyle(
//                                             fontSize: font_Size,
//                                             font: ttf,
//                                             color: Colors_pd,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           for (int index = 0;
//                               index < filteredList1.length;
//                               index++)
//                             pw.Row(
//                               children: [
//                                 pw.Expanded(
//                                   flex: 1,
//                                   child: pw.Container(
//                                     height: 20,
//                                     decoration: pw.BoxDecoration(
//                                       color: PdfColors.white,
//                                       border: pw.Border(
//                                         bottom: thinBorder,
//                                         left: thinBorder,
//                                         right: thinBorder,
//                                         top: thinBorder,
//                                       ),
//                                     ),
//                                     child: pw.Align(
//                                       alignment:
//                                           pw.Alignment.centerLeft, // ✅ ชิดซ้าย
//                                       child: pw.Padding(
//                                         padding: pw.EdgeInsets.only(
//                                             left: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//                                         child: pw.Text(
//                                           '',
//                                           style: pw.TextStyle(
//                                             fontSize: font_Size,
//                                             font: ttf,
//                                             color: Colors_pd,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 pw.Expanded(
//                                   flex: 7,
//                                   child: pw.Container(
//                                     height: 20,
//                                     decoration: pw.BoxDecoration(
//                                       color: PdfColors.white,
//                                       border: pw.Border(
//                                         bottom: thinBorder,
//                                         left: thinBorder,
//                                         right: thinBorder,
//                                         top: thinBorder,
//                                       ),
//                                     ),
//                                     child: pw.Align(
//                                       alignment:
//                                           pw.Alignment.centerLeft, // ✅ ชิดซ้าย
//                                       child: pw.Padding(
//                                         padding: pw.EdgeInsets.only(
//                                             left: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//                                         child: pw.Text(
//                                           '1.${index + 1} ${filteredList1[index].expname}',
//                                           style: pw.TextStyle(
//                                             fontSize: font_Size,
//                                             font: ttf,
//                                             color: Colors_pd,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 pw.Expanded(
//                                   flex: 3,
//                                   child: pw.Container(
//                                     height: 20,
//                                     decoration: pw.BoxDecoration(
//                                       color: PdfColors.white,
//                                       border: pw.Border(
//                                         bottom: thinBorder,
//                                         left: thinBorder,
//                                         right: thinBorder,
//                                         top: thinBorder,
//                                       ),
//                                     ),
//                                     child: pw.Align(
//                                       alignment:
//                                           pw.Alignment.centerRight, // ✅ ชิดขวา
//                                       child: pw.Padding(
//                                         padding: pw.EdgeInsets.only(
//                                             right: 4), // ✅ เว้นขอบขวานิดหน่อย
//                                         child: pw.Text(
//                                           // '',
//                                           (filteredList1[index].total == null)
//                                               ? ''
//                                               : '${nFormat.format(double.parse(filteredList1[index].total!))}',
//                                           style: pw.TextStyle(
//                                             fontSize: font_Size,
//                                             font: ttf,
//                                             color: Colors_pd,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           pw.Container(
//                             height: 20,
//                             decoration: const pw.BoxDecoration(
//                               color: PdfColors.grey200,
//                             ),
//                             child: pw.Row(
//                               children: [
//                                 pw.Expanded(
//                                   flex: 1,
//                                   child: pw.Container(
//                                     height: 20,
//                                     decoration: pw.BoxDecoration(
//                                       // color: PdfColors.white,
//                                       border: pw.Border(
//                                         bottom: thinBorder,
//                                         left: thinBorder,
//                                         right: thinBorder,
//                                         top: thinBorder,
//                                       ),
//                                     ),
//                                     child: pw.Align(
//                                       alignment:
//                                           pw.Alignment.centerLeft, // ✅ ชิดซ้าย
//                                       child: pw.Padding(
//                                         padding: pw.EdgeInsets.only(
//                                             left: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//                                         child: pw.Text(
//                                           '',
//                                           style: pw.TextStyle(
//                                             fontSize: font_Size,
//                                             font: ttf,
//                                             color: Colors_pd,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 pw.Expanded(
//                                   flex: 7,
//                                   child: pw.Container(
//                                     height: 20,
//                                     decoration: pw.BoxDecoration(
//                                       // color: PdfColors.white,
//                                       border: pw.Border(
//                                         bottom: thinBorder,
//                                         left: thinBorder,
//                                         right: thinBorder,
//                                         top: thinBorder,
//                                       ),
//                                     ),
//                                     child: pw.Align(
//                                       alignment: pw.Alignment.center, //
//                                       child: pw.Padding(
//                                         padding: pw.EdgeInsets.only(
//                                             left: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//                                         child: pw.Text(
//                                           'รวมค่าใช้จ่ายรายเดือน',
//                                           style: pw.TextStyle(
//                                             fontSize: font_Size,
//                                             font: ttf,
//                                             color: Colors_pd,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 pw.Expanded(
//                                   flex: 3,
//                                   child: pw.Container(
//                                     height: 20,
//                                     decoration: pw.BoxDecoration(
//                                       // color: PdfColors.white,
//                                       border: pw.Border(
//                                         bottom: thinBorder,
//                                         left: thinBorder,
//                                         right: thinBorder,
//                                         top: thinBorder,
//                                       ),
//                                     ),
//                                     child: pw.Align(
//                                       alignment:
//                                           pw.Alignment.centerRight, // ✅ ชิดซ้าย
//                                       child: pw.Padding(
//                                         padding: pw.EdgeInsets.only(
//                                             right: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//                                         child: pw.Text(
//                                           // '',
//                                           nFormat.format(filteredList1.fold<
//                                                   double>(
//                                               0.00,
//                                               (double sum, dynamic item) =>
//                                                   sum +
//                                                   (item.total != null
//                                                       ? double.parse(
//                                                           item.total!)
//                                                       : 0.00))),
//                                           style: pw.TextStyle(
//                                             fontSize: font_Size,
//                                             font: ttf,
//                                             color: Colors_pd,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           pw.Container(
//                             height: 20,
//                             decoration: const pw.BoxDecoration(
//                               color: PdfColors.white,
//                             ),
//                             child: pw.Row(
//                               children: [
//                                 pw.Expanded(
//                                   flex: 1,
//                                   child: pw.Container(
//                                     height: 20,
//                                     decoration: pw.BoxDecoration(
//                                       color: PdfColors.white,
//                                       border: pw.Border(
//                                         bottom: thinBorder,
//                                         left: thinBorder,
//                                         right: thinBorder,
//                                         top: thinBorder,
//                                       ),
//                                     ),
//                                     child: pw.Align(
//                                       alignment:
//                                           pw.Alignment.center, // ✅ ชิดซ้าย
//                                       child: pw.Padding(
//                                         padding: pw.EdgeInsets.only(
//                                             left: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//                                         child: pw.Text(
//                                           '2',
//                                           style: pw.TextStyle(
//                                             fontSize: font_Size,
//                                             font: ttf,
//                                             color: Colors_pd,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 pw.Expanded(
//                                   flex: 7,
//                                   child: pw.Container(
//                                     height: 20,
//                                     decoration: pw.BoxDecoration(
//                                       color: PdfColors.white,
//                                       border: pw.Border(
//                                         bottom: thinBorder,
//                                         left: thinBorder,
//                                         right: thinBorder,
//                                         top: thinBorder,
//                                       ),
//                                     ),
//                                     child: pw.Align(
//                                       alignment: pw.Alignment.centerLeft, //
//                                       child: pw.Padding(
//                                         padding: pw.EdgeInsets.only(
//                                             left: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//                                         child: pw.Text(
//                                           'ค่าใช้จ่ายเงินประกันและรายการอื่นๆ',
//                                           style: pw.TextStyle(
//                                             fontSize: font_Size,
//                                             font: ttf,
//                                             color: Colors_pd,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 pw.Expanded(
//                                   flex: 3,
//                                   child: pw.Container(
//                                     height: 20,
//                                     decoration: pw.BoxDecoration(
//                                       color: PdfColors.white,
//                                       border: pw.Border(
//                                         bottom: thinBorder,
//                                         left: thinBorder,
//                                         right: thinBorder,
//                                         top: thinBorder,
//                                       ),
//                                     ),
//                                     child: pw.Align(
//                                       alignment:
//                                           pw.Alignment.centerRight, // ✅ ชิดซ้าย
//                                       child: pw.Padding(
//                                         padding: pw.EdgeInsets.only(
//                                             right: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//                                         child: pw.Text(
//                                           '',
//                                           style: pw.TextStyle(
//                                             fontSize: font_Size,
//                                             font: ttf,
//                                             color: Colors_pd,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           for (int index2 = 0;
//                               index2 < filteredList2.length;
//                               index2++) // dtype ku,ko
//                             pw.Row(
//                               children: [
//                                 pw.Expanded(
//                                   flex: 1,
//                                   child: pw.Container(
//                                     height: 20,
//                                     decoration: pw.BoxDecoration(
//                                       color: PdfColors.white,
//                                       border: pw.Border(
//                                         bottom: thinBorder,
//                                         left: thinBorder,
//                                         right: thinBorder,
//                                         top: thinBorder,
//                                       ),
//                                     ),
//                                     child: pw.Align(
//                                       alignment:
//                                           pw.Alignment.centerLeft, // ✅ ชิดซ้าย
//                                       child: pw.Padding(
//                                         padding: pw.EdgeInsets.only(
//                                             left: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//                                         child: pw.Text(
//                                           '',
//                                           style: pw.TextStyle(
//                                             fontSize: font_Size,
//                                             font: ttf,
//                                             color: Colors_pd,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 pw.Expanded(
//                                   flex: 7,
//                                   child: pw.Container(
//                                     height: 20,
//                                     decoration: pw.BoxDecoration(
//                                       color: PdfColors.white,
//                                       border: pw.Border(
//                                         bottom: thinBorder,
//                                         left: thinBorder,
//                                         right: thinBorder,
//                                         top: thinBorder,
//                                       ),
//                                     ),
//                                     child: pw.Align(
//                                       alignment:
//                                           pw.Alignment.centerLeft, // ✅ ชิดซ้าย
//                                       child: pw.Padding(
//                                         padding: pw.EdgeInsets.only(
//                                             left: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//                                         child: pw.Text(
//                                           '2.${index2 + 1} ${filteredList2[index2].expname}',
//                                           style: pw.TextStyle(
//                                             fontSize: font_Size,
//                                             font: ttf,
//                                             color: Colors_pd,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 pw.Expanded(
//                                   flex: 3,
//                                   child: pw.Container(
//                                     height: 20,
//                                     decoration: pw.BoxDecoration(
//                                       color: PdfColors.white,
//                                       border: pw.Border(
//                                         bottom: thinBorder,
//                                         left: thinBorder,
//                                         right: thinBorder,
//                                         top: thinBorder,
//                                       ),
//                                     ),
//                                     child: pw.Align(
//                                       alignment:
//                                           pw.Alignment.centerRight, // ✅ ชิดขวา
//                                       child: pw.Padding(
//                                         padding: pw.EdgeInsets.only(
//                                             right: 4), // ✅ เว้นขอบขวานิดหน่อย
//                                         child: pw.Text(
//                                           (filteredList2[index2].total == null)
//                                               ? ''
//                                               : '${nFormat.format(double.parse(filteredList2[index2].total!))}',
//                                           style: pw.TextStyle(
//                                             fontSize: font_Size,
//                                             font: ttf,
//                                             color: Colors_pd,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           pw.Container(
//                             height: 20,
//                             decoration: const pw.BoxDecoration(
//                               color: PdfColors.grey200,
//                             ),
//                             child: pw.Row(
//                               children: [
//                                 pw.Expanded(
//                                   flex: 1,
//                                   child: pw.Container(
//                                     height: 20,
//                                     decoration: pw.BoxDecoration(
//                                       // color: PdfColors.white,
//                                       border: pw.Border(
//                                         bottom: thinBorder,
//                                         left: thinBorder,
//                                         right: thinBorder,
//                                         top: thinBorder,
//                                       ),
//                                     ),
//                                     child: pw.Align(
//                                       alignment:
//                                           pw.Alignment.centerLeft, // ✅ ชิดซ้าย
//                                       child: pw.Padding(
//                                         padding: pw.EdgeInsets.only(
//                                             left: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//                                         child: pw.Text(
//                                           '',
//                                           style: pw.TextStyle(
//                                             fontSize: font_Size,
//                                             font: ttf,
//                                             color: Colors_pd,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 pw.Expanded(
//                                   flex: 7,
//                                   child: pw.Container(
//                                     height: 20,
//                                     decoration: pw.BoxDecoration(
//                                       // color: PdfColors.white,
//                                       border: pw.Border(
//                                         bottom: thinBorder,
//                                         left: thinBorder,
//                                         right: thinBorder,
//                                         top: thinBorder,
//                                       ),
//                                     ),
//                                     child: pw.Align(
//                                       alignment: pw.Alignment.center, //
//                                       child: pw.Padding(
//                                         padding: pw.EdgeInsets.only(
//                                             left: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//                                         child: pw.Text(
//                                           'รวมค่าใช้จ่ายเงินประกันและรายการอื่นๆ',
//                                           style: pw.TextStyle(
//                                             fontSize: font_Size,
//                                             font: ttf,
//                                             color: Colors_pd,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 pw.Expanded(
//                                   flex: 3,
//                                   child: pw.Container(
//                                     height: 20,
//                                     decoration: pw.BoxDecoration(
//                                       // color: PdfColors.white,
//                                       border: pw.Border(
//                                         bottom: thinBorder,
//                                         left: thinBorder,
//                                         right: thinBorder,
//                                         top: thinBorder,
//                                       ),
//                                     ),
//                                     child: pw.Align(
//                                       alignment:
//                                           pw.Alignment.centerRight, // ✅ ชิดซ้าย
//                                       child: pw.Padding(
//                                         padding: pw.EdgeInsets.only(
//                                             right: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//                                         child: pw.Text(
//                                           nFormat.format(filteredList2.fold<
//                                                   double>(
//                                               0.00,
//                                               (double sum, dynamic item) =>
//                                                   sum +
//                                                   (item.total != null
//                                                       ? double.parse(
//                                                           item.total!)
//                                                       : 0.00))),
//                                           style: pw.TextStyle(
//                                             fontSize: font_Size,
//                                             font: ttf,
//                                             color: Colors_pd,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           pw.Container(
//                             height: 20,
//                             decoration: pw.BoxDecoration(
//                               color: PdfColors.grey400,
//                               border: pw.Border(
//                                 bottom: thinBorder,
//                                 left: thinBorder,
//                                 right: thinBorder,
//                                 top: thinBorder,
//                               ),
//                             ),
//                             child: pw.Row(
//                               children: [
//                                 pw.Expanded(
//                                   flex: 1,
//                                   child: pw.Container(
//                                     height: 20,
//                                     child: pw.Align(
//                                       alignment:
//                                           pw.Alignment.centerLeft, // ✅ ชิดซ้าย
//                                       child: pw.Padding(
//                                         padding: pw.EdgeInsets.only(
//                                             left: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//                                         child: pw.Text(
//                                           '',
//                                           style: pw.TextStyle(
//                                             fontSize: font_Size,
//                                             font: ttf,
//                                             color: Colors_pd,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 pw.Expanded(
//                                   flex: 7,
//                                   child: pw.Container(
//                                     height: 20,
//                                     child: pw.Align(
//                                       alignment: pw.Alignment.center, //
//                                       child: pw.Padding(
//                                         padding: pw.EdgeInsets.only(
//                                             left: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//                                         child: pw.Text(
//                                           '(~${convertToThaiBaht((filteredList1.fold<double>(
//                                                 0.0,
//                                                 (double sum, dynamic item) =>
//                                                     sum +
//                                                     (item.total != null
//                                                         ? double.parse(
//                                                             item.total!)
//                                                         : 0.0),
//                                               )) + (filteredList2.fold<double>(
//                                                 0.0,
//                                                 (double sum, dynamic item) =>
//                                                     sum +
//                                                     (item.total != null
//                                                         ? double.parse(
//                                                             item.total!)
//                                                         : 0.0),
//                                               )))}~)',
//                                           style: pw.TextStyle(
//                                             fontSize: font_Size,
//                                             font: ttf,
//                                             color: Colors_pd,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 pw.Expanded(
//                                   flex: 3,
//                                   child: pw.Container(
//                                     height: 20,
//                                     decoration: pw.BoxDecoration(
//                                       // color: PdfColors.white,
//                                       border: pw.Border(
//                                         left: thinBorder,
//                                       ),
//                                     ),
//                                     child: pw.Align(
//                                       alignment:
//                                           pw.Alignment.centerRight, // ✅ ชิดซ้าย
//                                       child: pw.Padding(
//                                         padding: pw.EdgeInsets.only(
//                                             right: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//                                         child: pw.Text(
//                                           total_all,
//                                           style: pw.TextStyle(
//                                             fontSize: font_Size,
//                                             font: ttf,
//                                             color: Colors_pd,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           pw.SizedBox(height: 2 * PdfPageFormat.mm),
//                           pw.Row(
//                             children: [
//                               pw.Expanded(
//                                 flex: 1,
//                                 child: pw.Text(
//                                   'หมายเหตุ : ',
//                                   style: pw.TextStyle(
//                                     fontSize: font_Size,
//                                     fontWeight: pw.FontWeight.bold,
//                                     font: ttf,
//                                     color: Colors_pd,
//                                   ),
//                                 ),
//                               ),
//                               pw.Expanded(
//                                 flex: 9,
//                                 child: pw.Text(
//                                   '1. อัตราค่าไฟฟ้า หน่วยละ 7 บาท/ อัตราค่าน้ำประปา หน่วยละ 35 บาท',
//                                   style: pw.TextStyle(
//                                     fontSize: font_Size,
//                                     fontWeight: pw.FontWeight.bold,
//                                     font: ttf,
//                                     color: Colors_pd,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           pw.Row(
//                             children: [
//                               pw.Expanded(flex: 1, child: pw.SizedBox()),
//                               pw.Expanded(
//                                 flex: 9,
//                                 child: pw.Text(
//                                   '2. ค่าภาษีที่ดินและสิ่งปลูกสร้าง อัตราตารางเมตรละ ........................................... บาท/ปี (ภาระเป็นของผู้เช่า)',
//                                   style: pw.TextStyle(
//                                     fontSize: font_Size,
//                                     fontWeight: pw.FontWeight.bold,
//                                     font: ttf,
//                                     color: Colors_pd,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           pw.Row(
//                             children: [
//                               pw.Expanded(flex: 1, child: pw.SizedBox()),
//                               pw.Expanded(
//                                 flex: 9,
//                                 child: pw.Text(
//                                   '3. ค่าอากรติดสัญญา (ภาระเป็นของผู้เช่า)',
//                                   style: pw.TextStyle(
//                                     fontSize: font_Size,
//                                     fontWeight: pw.FontWeight.bold,
//                                     font: ttf,
//                                     color: Colors_pd,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           pw.Row(
//                             children: [
//                               pw.Expanded(
//                                 flex: 1,
//                                 child: pw.Text(
//                                   'การชำระ : ',
//                                   style: pw.TextStyle(
//                                     fontSize: font_Size,
//                                     fontWeight: pw.FontWeight.bold,
//                                     font: ttf,
//                                     color: Colors_pd,
//                                   ),
//                                 ),
//                               ),
//                               pw.Expanded(
//                                 flex: 9,
//                                 child: pw.Text(
//                                   '4. ชำระจองพื้นที่ภายใน 30 วัน นับจากวันที่ลงนามในใบเสนอราคา จำนวน ............................................ บาท ',
//                                   style: pw.TextStyle(
//                                     fontSize: font_Size,
//                                     fontWeight: pw.FontWeight.bold,
//                                     font: ttf,
//                                     color: Colors_pd,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           pw.Row(
//                             children: [
//                               pw.Expanded(flex: 1, child: pw.SizedBox()),
//                               pw.Expanded(
//                                 flex: 9,
//                                 child: pw.Text(
//                                   'กรุณาโอนเงินเข้าบัญชี ธ.กรุงไทย สาขาสี ่แยกสนามบินเชียงใหม่ ชื่อบัญชี บริษัท นิ่มซิตี้ เดลี่ จำกัด เลขที่บัญชี 771-0-01967-6',
//                                   style: pw.TextStyle(
//                                     fontSize: font_Size,
//                                     fontWeight: pw.FontWeight.bold,
//                                     font: ttf,
//                                     color: Colors_pd,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           pw.Row(
//                             children: [
//                               pw.Expanded(flex: 1, child: pw.SizedBox()),
//                               pw.Expanded(
//                                 flex: 9,
//                                 child: pw.Text(
//                                   '5. อัตราค่าประกันพื้นที่เช่าและค่าประกันค่าบริการส่วนกลาง เท่ากับ 3 เท่าของค่าเช่า (คืนเมื่อสิ้นสุดสัญญาเช่า)',
//                                   style: pw.TextStyle(
//                                     fontSize: font_Size,
//                                     fontWeight: pw.FontWeight.bold,
//                                     font: ttf,
//                                     color: Colors_pd,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           pw.Row(
//                             children: [
//                               pw.Expanded(flex: 1, child: pw.SizedBox()),
//                               pw.Expanded(
//                                 flex: 9,
//                                 child: pw.Text(
//                                   '6. ระยะเวลาตกแต่ง .......................................................... เดือน เริ่มวันที่ .......................................................... ',
//                                   style: pw.TextStyle(
//                                     fontSize: font_Size,
//                                     fontWeight: pw.FontWeight.bold,
//                                     font: ttf,
//                                     color: Colors_pd,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           pw.Row(
//                             children: [
//                               pw.Expanded(flex: 1, child: pw.SizedBox()),
//                               pw.Expanded(
//                                 flex: 9,
//                                 child: pw.Text(
//                                   '7. วันที ่เริ่มค่าเช่า ................................................................................................................................................. ',
//                                   style: pw.TextStyle(
//                                     fontSize: font_Size,
//                                     fontWeight: pw.FontWeight.bold,
//                                     font: ttf,
//                                     color: Colors_pd,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ];
//         },
//         footer: (context) {
//           return pw.Column(
//             mainAxisSize: pw.MainAxisSize.min,
//             children: [
//               pw.Row(
//                 mainAxisSize: pw.MainAxisSize.min,
//                 children: [
//                   // กล่องซ้าย
//                   pw.Container(
//                     padding: const pw.EdgeInsets.all(8.0),
//                     width: 240, // ความกว้างกล่อง
//                     decoration: pw.BoxDecoration(
//                       border: pw.Border.all(color: PdfColors.grey, width: 1),
//                     ),
//                     child: pw.Column(
//                       mainAxisAlignment: pw.MainAxisAlignment.center,
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.SizedBox(height: 5 * PdfPageFormat.mm),
//                         pw.Row(
//                           children: [
//                             pw.Expanded(
//                               child: pw.Text(
//                                 '(..............................................................................................)',
//                                 textAlign: pw.TextAlign.center,
//                                 style: pw.TextStyle(
//                                   fontSize: font_Size,
//                                   fontWeight: pw.FontWeight.bold,
//                                   font: ttf,
//                                   color: Colors_pd,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         pw.SizedBox(height: 1 * PdfPageFormat.mm),
//                         pw.Row(
//                           children: [
//                             pw.Expanded(
//                               child: pw.Text(
//                                 '..................................................................',
//                                 textAlign: pw.TextAlign.center,
//                                 style: pw.TextStyle(
//                                   fontWeight: pw.FontWeight.bold,
//                                   fontSize: font_Size,
//                                   font: ttf,
//                                   color: Colors_pd,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         pw.Row(
//                           children: [
//                             pw.Expanded(
//                               child: pw.Text(
//                                 'ผู้ขอเช่า/จองพื้นที่',
//                                 textAlign: pw.TextAlign.center,
//                                 style: pw.TextStyle(
//                                   fontWeight: pw.FontWeight.bold,
//                                   fontSize: font_Size,
//                                   font: ttf,
//                                   color: Colors_pd,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         pw.Row(
//                           children: [
//                             pw.Expanded(
//                               child: pw.Text(
//                                 'ลงวันที่...................................................',
//                                 textAlign: pw.TextAlign.center,
//                                 style: pw.TextStyle(
//                                   fontWeight: pw.FontWeight.bold,
//                                   fontSize: font_Size,
//                                   font: ttf,
//                                   color: Colors_pd,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),

//                   pw.SizedBox(width: 50), // เว้นระหว่างกล่อง

//                   // กล่องขวา (เหมือนซ้าย)
//                   pw.Container(
//                     padding: const pw.EdgeInsets.all(8.0),
//                     width: 240, // ความกว้างกล่อง
//                     decoration: pw.BoxDecoration(
//                       border: pw.Border.all(color: PdfColors.grey, width: 1),
//                     ),
//                     child: pw.Column(
//                       mainAxisAlignment: pw.MainAxisAlignment.center,
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.SizedBox(height: 5 * PdfPageFormat.mm),
//                         pw.Row(
//                           children: [
//                             pw.Expanded(
//                               child: pw.Text(
//                                 '(..............................................................................................)',
//                                 textAlign: pw.TextAlign.center,
//                                 style: pw.TextStyle(
//                                   fontSize: font_Size,
//                                   fontWeight: pw.FontWeight.bold,
//                                   font: ttf,
//                                   color: Colors_pd,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         pw.SizedBox(height: 1 * PdfPageFormat.mm),
//                         pw.Row(
//                           children: [
//                             pw.Expanded(
//                               child: pw.Text(
//                                 '..................................................................',
//                                 textAlign: pw.TextAlign.center,
//                                 style: pw.TextStyle(
//                                   fontWeight: pw.FontWeight.bold,
//                                   fontSize: font_Size,
//                                   font: ttf,
//                                   color: Colors_pd,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         pw.Row(
//                           children: [
//                             pw.Expanded(
//                               child: pw.Text(
//                                 'ผู้เสนอราคา',
//                                 textAlign: pw.TextAlign.center,
//                                 style: pw.TextStyle(
//                                   fontWeight: pw.FontWeight.bold,
//                                   fontSize: font_Size,
//                                   font: ttf,
//                                   color: Colors_pd,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         pw.Row(
//                           children: [
//                             pw.Expanded(
//                               child: pw.Text(
//                                 'ลงวันที่...................................................',
//                                 textAlign: pw.TextAlign.center,
//                                 style: pw.TextStyle(
//                                   fontWeight: pw.FontWeight.bold,
//                                   fontSize: font_Size,
//                                   font: ttf,
//                                   color: Colors_pd,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               pw.SizedBox(height: 3 * PdfPageFormat.mm),
//               pw.Align(
//                 alignment: pw.Alignment.bottomRight,
//                 child: pw.Text(
//                   'หน้า ${context.pageNumber} / ${context.pagesCount} ',
//                   style: pw.TextStyle(
//                     fontSize: 10,
//                     font: ttf,
//                     color: Colors_pd,
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );

//     // pageCount++;
//     // pdf.addPage(pw.MultiPage(
//     //   pageFormat: PdfPageFormat.a4.copyWith(
//     //     marginBottom: 30.00,
//     //     marginLeft: 30.00,
//     //     marginRight: 30.00,
//     //     marginTop: 30.00,
//     //   ),
//     //   header: (context) {
//     //     return pw.Column(children: [
//     //       pw.Row(
//     //         children: [
//     //           pw.Container(
//     //             height: 45,
//     //             width: 90,
//     //             decoration: pw.BoxDecoration(
//     //               color: PdfColors.grey200,
//     //               border: pw.Border.all(color: PdfColors.grey300),
//     //             ),
//     //             child: resizedLogo != null
//     //                 ? pw.Image(
//     //                     pw.MemoryImage(resizedLogo),
//     //                     height: 45,
//     //                     width: 90,
//     //                     fit: pw.BoxFit.fill, // <-- บังคับให้เต็ม
//     //                   )
//     //                 : pw.Center(
//     //                     child: pw.Text(
//     //                       '$bill_name ',
//     //                       maxLines: 1,
//     //                       style: pw.TextStyle(
//     //                         fontSize: 10,
//     //                         font: ttf,
//     //                         color: Colors_pd,
//     //                       ),
//     //                     ),
//     //                   ),
//     //           ),
//     //           pw.SizedBox(width: 8 * PdfPageFormat.mm),
//     //           pw.Container(
//     //             child: pw.Column(
//     //               mainAxisSize: pw.MainAxisSize.min,
//     //               crossAxisAlignment: pw.CrossAxisAlignment.start,
//     //               children: [
//     //                 pw.Text(
//     //                   'Nim City Daily : 197,199/8-9  Mahidol rd.  Haiya  Muang  Chiangmai  50100', //$bill_addr
//     //                   maxLines: 3,
//     //                   style: pw.TextStyle(
//     //                     fontSize: font_Size,
//     //                     color: Colors_pd,
//     //                     font: ttf,
//     //                   ),
//     //                 ),
//     //                 pw.SizedBox(height: 2 * PdfPageFormat.mm),
//     //                 pw.Row(children: [
//     //                   pw.Text(
//     //                     'Tel & Fax :  053-273800 /',
//     //                     maxLines: 2,
//     //                     style: pw.TextStyle(
//     //                       fontSize: font_Size,
//     //                       // fontWeight: pw.FontWeight.bold,
//     //                       font: ttf,
//     //                       color: Colors_pd,
//     //                     ),
//     //                   ),
//     //                   pw.Text(
//     //                     'Mobile : 081-8813922',
//     //                     maxLines: 2,
//     //                     style: pw.TextStyle(
//     //                       fontSize: font_Size,
//     //                       // fontWeight: pw.FontWeight.bold,
//     //                       font: ttf,
//     //                       color: Colors_pd,
//     //                     ),
//     //                   ),
//     //                 ]),
//     //               ],
//     //             ),
//     //           ),
//     //         ],
//     //       ),
//     //     ]);
//     //   },
//     //   build: (context) {
//     //     return [
//     //       pw.SizedBox(height: 6 * PdfPageFormat.mm),
//     //       pw.Center(
//     //         child: pw.Column(
//     //           mainAxisAlignment: pw.MainAxisAlignment.center,
//     //           children: [
//     //             pw.Row(
//     //               mainAxisAlignment: pw.MainAxisAlignment.start,
//     //               children: [
//     //                 pw.Text(
//     //                   'รายละเอียดค่าบริการ',
//     //                   textAlign: pw.TextAlign.left,
//     //                   style: pw.TextStyle(
//     //                     fontSize: 14,
//     //                     font: ttf,
//     //                     fontWeight: pw.FontWeight.bold,
//     //                     color: Colors_pd,
//     //                   ),
//     //                 ),
//     //               ],
//     //             ),
//     //             pw.SizedBox(height: 3 * PdfPageFormat.mm),
//     //             pw.Container(
//     //               height: 20,
//     //               decoration: const pw.BoxDecoration(
//     //                 color: PdfColors.lightBlue100,
//     //               ),
//     //               child: pw.Row(
//     //                 children: [
//     //                   pw.Expanded(
//     //                     flex: 1,
//     //                     child: pw.Container(
//     //                       decoration: pw.BoxDecoration(
//     //                         border: pw.Border(
//     //                           bottom: thinBorder,
//     //                           left: thinBorder,
//     //                           right: thinBorder,
//     //                           top: thinBorder,
//     //                         ),
//     //                       ),
//     //                       child: pw.Center(
//     //                         child: pw.Text(
//     //                           'ลำดับ',
//     //                           textAlign: pw.TextAlign.center,
//     //                           style: pw.TextStyle(
//     //                             fontSize: font_Size,
//     //                             font: ttf,
//     //                             fontWeight: pw.FontWeight.bold,
//     //                             color: Colors_pd,
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ),
//     //                   ),
//     //                   pw.Expanded(
//     //                     flex: 7,
//     //                     child: pw.Container(
//     //                       decoration: pw.BoxDecoration(
//     //                         border: pw.Border(
//     //                           bottom: thinBorder,
//     //                           left: thinBorder,
//     //                           right: thinBorder,
//     //                           top: thinBorder,
//     //                         ),
//     //                       ),
//     //                       child: pw.Center(
//     //                         child: pw.Text(
//     //                           'รายการ',
//     //                           textAlign: pw.TextAlign.center,
//     //                           style: pw.TextStyle(
//     //                             fontSize: font_Size,
//     //                             font: ttf,
//     //                             fontWeight: pw.FontWeight.bold,
//     //                             color: Colors_pd,
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ),
//     //                   ),
//     //                   pw.Expanded(
//     //                     flex: 3,
//     //                     child: pw.Container(
//     //                       decoration: pw.BoxDecoration(
//     //                         border: pw.Border(
//     //                           bottom: thinBorder,
//     //                           left: thinBorder,
//     //                           right: thinBorder,
//     //                           top: thinBorder,
//     //                         ),
//     //                       ),
//     //                       child: pw.Center(
//     //                         child: pw.Text(
//     //                           'ราคา',
//     //                           textAlign: pw.TextAlign.center,
//     //                           style: pw.TextStyle(
//     //                             fontSize: font_Size,
//     //                             font: ttf,
//     //                             fontWeight: pw.FontWeight.bold,
//     //                             color: Colors_pd,
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ),
//     //                   ),
//     //                 ],
//     //               ),
//     //             ),
//     //             pw.Container(
//     //               height: 20,
//     //               decoration: const pw.BoxDecoration(
//     //                 color: PdfColors.white,
//     //               ),
//     //               child: pw.Row(
//     //                 children: [
//     //                   pw.Expanded(
//     //                     flex: 1,
//     //                     child: pw.Container(
//     //                       decoration: pw.BoxDecoration(
//     //                         border: pw.Border(
//     //                           bottom: thinBorder,
//     //                           left: thinBorder,
//     //                           right: thinBorder,
//     //                           top: thinBorder,
//     //                         ),
//     //                       ),
//     //                       child: pw.Center(
//     //                         child: pw.Text(
//     //                           '1',
//     //                           textAlign: pw.TextAlign.center,
//     //                           style: pw.TextStyle(
//     //                             fontSize: font_Size,
//     //                             font: ttf,
//     //                             fontWeight: pw.FontWeight.bold,
//     //                             color: Colors_pd,
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ),
//     //                   ),
//     //                   pw.Expanded(
//     //                     flex: 7,
//     //                     child: pw.Container(
//     //                       height: 20,
//     //                       decoration: pw.BoxDecoration(
//     //                         color: PdfColors.white,
//     //                         border: pw.Border(
//     //                           bottom: thinBorder,
//     //                           left: thinBorder,
//     //                           right: thinBorder,
//     //                           top: thinBorder,
//     //                         ),
//     //                       ),
//     //                       child: pw.Align(
//     //                         alignment: pw.Alignment.centerLeft, // ✅ ชิดซ้าย
//     //                         child: pw.Padding(
//     //                           padding: pw.EdgeInsets.only(
//     //                               left: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//     //                           child: pw.Text(
//     //                             'ค่าใช้จ่ายในการเช่าและค่าบริการรายเดือน',
//     //                             style: pw.TextStyle(
//     //                               fontSize: font_Size,
//     //                               font: ttf,
//     //                               color: Colors_pd,
//     //                             ),
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ),
//     //                   ),
//     //                   pw.Expanded(
//     //                     flex: 3,
//     //                     child: pw.Container(
//     //                       height: 20,
//     //                       decoration: pw.BoxDecoration(
//     //                         color: PdfColors.white,
//     //                         border: pw.Border(
//     //                           bottom: thinBorder,
//     //                           left: thinBorder,
//     //                           right: thinBorder,
//     //                           top: thinBorder,
//     //                         ),
//     //                       ),
//     //                       child: pw.Align(
//     //                         alignment: pw.Alignment.centerRight, // ✅ ชิดซ้าย
//     //                         child: pw.Padding(
//     //                           padding: pw.EdgeInsets.only(
//     //                               right: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//     //                           child: pw.Text(
//     //                             '',
//     //                             style: pw.TextStyle(
//     //                               fontSize: font_Size,
//     //                               font: ttf,
//     //                               color: Colors_pd,
//     //                             ),
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ),
//     //                   ),
//     //                 ],
//     //               ),
//     //             ),
//     //             for (int index = 0; index < filteredList1.length; index++)
//     //               pw.Row(
//     //                 children: [
//     //                   pw.Expanded(
//     //                     flex: 1,
//     //                     child: pw.Container(
//     //                       height: 20,
//     //                       decoration: pw.BoxDecoration(
//     //                         color: PdfColors.white,
//     //                         border: pw.Border(
//     //                           bottom: thinBorder,
//     //                           left: thinBorder,
//     //                           right: thinBorder,
//     //                           top: thinBorder,
//     //                         ),
//     //                       ),
//     //                       child: pw.Align(
//     //                         alignment: pw.Alignment.centerLeft, // ✅ ชิดซ้าย
//     //                         child: pw.Padding(
//     //                           padding: pw.EdgeInsets.only(
//     //                               left: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//     //                           child: pw.Text(
//     //                             '',
//     //                             style: pw.TextStyle(
//     //                               fontSize: font_Size,
//     //                               font: ttf,
//     //                               color: Colors_pd,
//     //                             ),
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ),
//     //                   ),
//     //                   pw.Expanded(
//     //                     flex: 7,
//     //                     child: pw.Container(
//     //                       height: 20,
//     //                       decoration: pw.BoxDecoration(
//     //                         color: PdfColors.white,
//     //                         border: pw.Border(
//     //                           bottom: thinBorder,
//     //                           left: thinBorder,
//     //                           right: thinBorder,
//     //                           top: thinBorder,
//     //                         ),
//     //                       ),
//     //                       child: pw.Align(
//     //                         alignment: pw.Alignment.centerLeft, // ✅ ชิดซ้าย
//     //                         child: pw.Padding(
//     //                           padding: pw.EdgeInsets.only(
//     //                               left: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//     //                           child: pw.Text(
//     //                             '1.${index + 1} ${filteredList1[index].expname}',
//     //                             style: pw.TextStyle(
//     //                               fontSize: font_Size,
//     //                               font: ttf,
//     //                               color: Colors_pd,
//     //                             ),
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ),
//     //                   ),
//     //                   pw.Expanded(
//     //                     flex: 3,
//     //                     child: pw.Container(
//     //                       height: 20,
//     //                       decoration: pw.BoxDecoration(
//     //                         color: PdfColors.white,
//     //                         border: pw.Border(
//     //                           bottom: thinBorder,
//     //                           left: thinBorder,
//     //                           right: thinBorder,
//     //                           top: thinBorder,
//     //                         ),
//     //                       ),
//     //                       child: pw.Align(
//     //                         alignment: pw.Alignment.centerRight, // ✅ ชิดขวา
//     //                         child: pw.Padding(
//     //                           padding: pw.EdgeInsets.only(
//     //                               right: 4), // ✅ เว้นขอบขวานิดหน่อย
//     //                           child: pw.Text(
//     //                             // '',
//     //                             (filteredList1[index].total == null)
//     //                                 ? ''
//     //                                 : '${nFormat.format(double.parse(filteredList1[index].total!))}',
//     //                             style: pw.TextStyle(
//     //                               fontSize: font_Size,
//     //                               font: ttf,
//     //                               color: Colors_pd,
//     //                             ),
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ),
//     //                   ),
//     //                 ],
//     //               ),
//     //             pw.Container(
//     //               height: 20,
//     //               decoration: const pw.BoxDecoration(
//     //                 color: PdfColors.grey200,
//     //               ),
//     //               child: pw.Row(
//     //                 children: [
//     //                   pw.Expanded(
//     //                     flex: 1,
//     //                     child: pw.Container(
//     //                       height: 20,
//     //                       decoration: pw.BoxDecoration(
//     //                         // color: PdfColors.white,
//     //                         border: pw.Border(
//     //                           bottom: thinBorder,
//     //                           left: thinBorder,
//     //                           right: thinBorder,
//     //                           top: thinBorder,
//     //                         ),
//     //                       ),
//     //                       child: pw.Align(
//     //                         alignment: pw.Alignment.centerLeft, // ✅ ชิดซ้าย
//     //                         child: pw.Padding(
//     //                           padding: pw.EdgeInsets.only(
//     //                               left: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//     //                           child: pw.Text(
//     //                             '',
//     //                             style: pw.TextStyle(
//     //                               fontSize: font_Size,
//     //                               font: ttf,
//     //                               color: Colors_pd,
//     //                             ),
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ),
//     //                   ),
//     //                   pw.Expanded(
//     //                     flex: 7,
//     //                     child: pw.Container(
//     //                       height: 20,
//     //                       decoration: pw.BoxDecoration(
//     //                         // color: PdfColors.white,
//     //                         border: pw.Border(
//     //                           bottom: thinBorder,
//     //                           left: thinBorder,
//     //                           right: thinBorder,
//     //                           top: thinBorder,
//     //                         ),
//     //                       ),
//     //                       child: pw.Align(
//     //                         alignment: pw.Alignment.center, //
//     //                         child: pw.Padding(
//     //                           padding: pw.EdgeInsets.only(
//     //                               left: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//     //                           child: pw.Text(
//     //                             'รวมค่าใช้จ่ายรายเดือน (รวมภาษี)',
//     //                             style: pw.TextStyle(
//     //                               fontSize: font_Size,
//     //                               font: ttf,
//     //                               color: Colors_pd,
//     //                             ),
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ),
//     //                   ),
//     //                   pw.Expanded(
//     //                     flex: 3,
//     //                     child: pw.Container(
//     //                       height: 20,
//     //                       decoration: pw.BoxDecoration(
//     //                         // color: PdfColors.white,
//     //                         border: pw.Border(
//     //                           bottom: thinBorder,
//     //                           left: thinBorder,
//     //                           right: thinBorder,
//     //                           top: thinBorder,
//     //                         ),
//     //                       ),
//     //                       child: pw.Align(
//     //                         alignment: pw.Alignment.centerRight, // ✅ ชิดซ้าย
//     //                         child: pw.Padding(
//     //                           padding: pw.EdgeInsets.only(
//     //                               right: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//     //                           child: pw.Text(
//     //                             // '',
//     //                             nFormat.format(filteredList1.fold<double>(
//     //                                 0.00,
//     //                                 (double sum, dynamic item) =>
//     //                                     sum +
//     //                                     (item.total != null
//     //                                         ? double.parse(item.total!)
//     //                                         : 0.00))),
//     //                             style: pw.TextStyle(
//     //                               fontSize: font_Size,
//     //                               font: ttf,
//     //                               color: Colors_pd,
//     //                             ),
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ),
//     //                   ),
//     //                 ],
//     //               ),
//     //             ),
//     //             pw.Container(
//     //               height: 20,
//     //               decoration: const pw.BoxDecoration(
//     //                 color: PdfColors.white,
//     //               ),
//     //               child: pw.Row(
//     //                 children: [
//     //                   pw.Expanded(
//     //                     flex: 1,
//     //                     child: pw.Container(
//     //                       height: 20,
//     //                       decoration: pw.BoxDecoration(
//     //                         color: PdfColors.white,
//     //                         border: pw.Border(
//     //                           bottom: thinBorder,
//     //                           left: thinBorder,
//     //                           right: thinBorder,
//     //                           top: thinBorder,
//     //                         ),
//     //                       ),
//     //                       child: pw.Align(
//     //                         alignment: pw.Alignment.center, // ✅ ชิดซ้าย
//     //                         child: pw.Padding(
//     //                           padding: pw.EdgeInsets.only(
//     //                               left: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//     //                           child: pw.Text(
//     //                             '2',
//     //                             style: pw.TextStyle(
//     //                               fontSize: font_Size,
//     //                               font: ttf,
//     //                               color: Colors_pd,
//     //                             ),
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ),
//     //                   ),
//     //                   pw.Expanded(
//     //                     flex: 7,
//     //                     child: pw.Container(
//     //                       height: 20,
//     //                       decoration: pw.BoxDecoration(
//     //                         color: PdfColors.white,
//     //                         border: pw.Border(
//     //                           bottom: thinBorder,
//     //                           left: thinBorder,
//     //                           right: thinBorder,
//     //                           top: thinBorder,
//     //                         ),
//     //                       ),
//     //                       child: pw.Align(
//     //                         alignment: pw.Alignment.centerLeft, //
//     //                         child: pw.Padding(
//     //                           padding: pw.EdgeInsets.only(
//     //                               left: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//     //                           child: pw.Text(
//     //                             'ค่าใช้จ่ายเงินประกันและรายการอื่นๆ',
//     //                             style: pw.TextStyle(
//     //                               fontSize: font_Size,
//     //                               font: ttf,
//     //                               color: Colors_pd,
//     //                             ),
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ),
//     //                   ),
//     //                   pw.Expanded(
//     //                     flex: 3,
//     //                     child: pw.Container(
//     //                       height: 20,
//     //                       decoration: pw.BoxDecoration(
//     //                         color: PdfColors.white,
//     //                         border: pw.Border(
//     //                           bottom: thinBorder,
//     //                           left: thinBorder,
//     //                           right: thinBorder,
//     //                           top: thinBorder,
//     //                         ),
//     //                       ),
//     //                       child: pw.Align(
//     //                         alignment: pw.Alignment.centerRight, // ✅ ชิดซ้าย
//     //                         child: pw.Padding(
//     //                           padding: pw.EdgeInsets.only(
//     //                               right: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//     //                           child: pw.Text(
//     //                             '',
//     //                             style: pw.TextStyle(
//     //                               fontSize: font_Size,
//     //                               font: ttf,
//     //                               color: Colors_pd,
//     //                             ),
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ),
//     //                   ),
//     //                 ],
//     //               ),
//     //             ),
//     //             for (int index2 = 0;
//     //                 index2 < filteredList2.length;
//     //                 index2++) // dtype ku,ko
//     //               pw.Row(
//     //                 children: [
//     //                   pw.Expanded(
//     //                     flex: 1,
//     //                     child: pw.Container(
//     //                       height: 20,
//     //                       decoration: pw.BoxDecoration(
//     //                         color: PdfColors.white,
//     //                         border: pw.Border(
//     //                           bottom: thinBorder,
//     //                           left: thinBorder,
//     //                           right: thinBorder,
//     //                           top: thinBorder,
//     //                         ),
//     //                       ),
//     //                       child: pw.Align(
//     //                         alignment: pw.Alignment.centerLeft, // ✅ ชิดซ้าย
//     //                         child: pw.Padding(
//     //                           padding: pw.EdgeInsets.only(
//     //                               left: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//     //                           child: pw.Text(
//     //                             '',
//     //                             style: pw.TextStyle(
//     //                               fontSize: font_Size,
//     //                               font: ttf,
//     //                               color: Colors_pd,
//     //                             ),
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ),
//     //                   ),
//     //                   pw.Expanded(
//     //                     flex: 7,
//     //                     child: pw.Container(
//     //                       height: 20,
//     //                       decoration: pw.BoxDecoration(
//     //                         color: PdfColors.white,
//     //                         border: pw.Border(
//     //                           bottom: thinBorder,
//     //                           left: thinBorder,
//     //                           right: thinBorder,
//     //                           top: thinBorder,
//     //                         ),
//     //                       ),
//     //                       child: pw.Align(
//     //                         alignment: pw.Alignment.centerLeft, // ✅ ชิดซ้าย
//     //                         child: pw.Padding(
//     //                           padding: pw.EdgeInsets.only(
//     //                               left: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//     //                           child: pw.Text(
//     //                             '2.${index2 + 1} ${filteredList2[index2].expname}',
//     //                             style: pw.TextStyle(
//     //                               fontSize: font_Size,
//     //                               font: ttf,
//     //                               color: Colors_pd,
//     //                             ),
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ),
//     //                   ),
//     //                   pw.Expanded(
//     //                     flex: 3,
//     //                     child: pw.Container(
//     //                       height: 20,
//     //                       decoration: pw.BoxDecoration(
//     //                         color: PdfColors.white,
//     //                         border: pw.Border(
//     //                           bottom: thinBorder,
//     //                           left: thinBorder,
//     //                           right: thinBorder,
//     //                           top: thinBorder,
//     //                         ),
//     //                       ),
//     //                       child: pw.Align(
//     //                         alignment: pw.Alignment.centerRight, // ✅ ชิดขวา
//     //                         child: pw.Padding(
//     //                           padding: pw.EdgeInsets.only(
//     //                               right: 4), // ✅ เว้นขอบขวานิดหน่อย
//     //                           child: pw.Text(
//     //                             (filteredList2[index2].total == null)
//     //                                 ? ''
//     //                                 : '${nFormat.format(double.parse(filteredList2[index2].total!))}',
//     //                             style: pw.TextStyle(
//     //                               fontSize: font_Size,
//     //                               font: ttf,
//     //                               color: Colors_pd,
//     //                             ),
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ),
//     //                   ),
//     //                 ],
//     //               ),
//     //             pw.Container(
//     //               height: 20,
//     //               decoration: const pw.BoxDecoration(
//     //                 color: PdfColors.grey200,
//     //               ),
//     //               child: pw.Row(
//     //                 children: [
//     //                   pw.Expanded(
//     //                     flex: 1,
//     //                     child: pw.Container(
//     //                       height: 20,
//     //                       decoration: pw.BoxDecoration(
//     //                         // color: PdfColors.white,
//     //                         border: pw.Border(
//     //                           bottom: thinBorder,
//     //                           left: thinBorder,
//     //                           right: thinBorder,
//     //                           top: thinBorder,
//     //                         ),
//     //                       ),
//     //                       child: pw.Align(
//     //                         alignment: pw.Alignment.centerLeft, // ✅ ชิดซ้าย
//     //                         child: pw.Padding(
//     //                           padding: pw.EdgeInsets.only(
//     //                               left: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//     //                           child: pw.Text(
//     //                             '',
//     //                             style: pw.TextStyle(
//     //                               fontSize: font_Size,
//     //                               font: ttf,
//     //                               color: Colors_pd,
//     //                             ),
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ),
//     //                   ),
//     //                   pw.Expanded(
//     //                     flex: 7,
//     //                     child: pw.Container(
//     //                       height: 20,
//     //                       decoration: pw.BoxDecoration(
//     //                         // color: PdfColors.white,
//     //                         border: pw.Border(
//     //                           bottom: thinBorder,
//     //                           left: thinBorder,
//     //                           right: thinBorder,
//     //                           top: thinBorder,
//     //                         ),
//     //                       ),
//     //                       child: pw.Align(
//     //                         alignment: pw.Alignment.center, //
//     //                         child: pw.Padding(
//     //                           padding: pw.EdgeInsets.only(
//     //                               left: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//     //                           child: pw.Text(
//     //                             'รวมค่าใช้จ่ายเงินประกันและรายการอื่นๆ',
//     //                             style: pw.TextStyle(
//     //                               fontSize: font_Size,
//     //                               font: ttf,
//     //                               color: Colors_pd,
//     //                             ),
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ),
//     //                   ),
//     //                   pw.Expanded(
//     //                     flex: 3,
//     //                     child: pw.Container(
//     //                       height: 20,
//     //                       decoration: pw.BoxDecoration(
//     //                         // color: PdfColors.white,
//     //                         border: pw.Border(
//     //                           bottom: thinBorder,
//     //                           left: thinBorder,
//     //                           right: thinBorder,
//     //                           top: thinBorder,
//     //                         ),
//     //                       ),
//     //                       child: pw.Align(
//     //                         alignment: pw.Alignment.centerRight, // ✅ ชิดซ้าย
//     //                         child: pw.Padding(
//     //                           padding: pw.EdgeInsets.only(
//     //                               right: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//     //                           child: pw.Text(
//     //                             nFormat.format(filteredList2.fold<double>(
//     //                                 0.00,
//     //                                 (double sum, dynamic item) =>
//     //                                     sum +
//     //                                     (item.total != null
//     //                                         ? double.parse(item.total!)
//     //                                         : 0.00))),
//     //                             style: pw.TextStyle(
//     //                               fontSize: font_Size,
//     //                               font: ttf,
//     //                               color: Colors_pd,
//     //                             ),
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ),
//     //                   ),
//     //                 ],
//     //               ),
//     //             ),
//     //             pw.Container(
//     //               height: 20,
//     //               decoration: pw.BoxDecoration(
//     //                 color: PdfColors.grey400,
//     //                 border: pw.Border(
//     //                   bottom: thinBorder,
//     //                   left: thinBorder,
//     //                   right: thinBorder,
//     //                   top: thinBorder,
//     //                 ),
//     //               ),
//     //               child: pw.Row(
//     //                 children: [
//     //                   pw.Expanded(
//     //                     flex: 1,
//     //                     child: pw.Container(
//     //                       height: 20,
//     //                       child: pw.Align(
//     //                         alignment: pw.Alignment.centerLeft, // ✅ ชิดซ้าย
//     //                         child: pw.Padding(
//     //                           padding: pw.EdgeInsets.only(
//     //                               left: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//     //                           child: pw.Text(
//     //                             '',
//     //                             style: pw.TextStyle(
//     //                               fontSize: font_Size,
//     //                               font: ttf,
//     //                               color: Colors_pd,
//     //                             ),
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ),
//     //                   ),
//     //                   pw.Expanded(
//     //                     flex: 7,
//     //                     child: pw.Container(
//     //                       height: 20,
//     //                       child: pw.Align(
//     //                         alignment: pw.Alignment.center, //
//     //                         child: pw.Padding(
//     //                           padding: pw.EdgeInsets.only(
//     //                               left: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//     //                           child: pw.Text(
//     //                             '(~${convertToThaiBaht((filteredList1.fold<double>(
//     //                                   0.0,
//     //                                   (double sum, dynamic item) =>
//     //                                       sum +
//     //                                       (item.total != null
//     //                                           ? double.parse(item.total!)
//     //                                           : 0.0),
//     //                                 )) + (filteredList2.fold<double>(
//     //                                   0.0,
//     //                                   (double sum, dynamic item) =>
//     //                                       sum +
//     //                                       (item.total != null
//     //                                           ? double.parse(item.total!)
//     //                                           : 0.0),
//     //                                 )))}~)',
//     //                             style: pw.TextStyle(
//     //                               fontSize: font_Size,
//     //                               font: ttf,
//     //                               color: Colors_pd,
//     //                             ),
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ),
//     //                   ),
//     //                   pw.Expanded(
//     //                     flex: 3,
//     //                     child: pw.Container(
//     //                       height: 20,
//     //                       decoration: pw.BoxDecoration(
//     //                         // color: PdfColors.white,
//     //                         border: pw.Border(
//     //                           left: thinBorder,
//     //                         ),
//     //                       ),
//     //                       child: pw.Align(
//     //                         alignment: pw.Alignment.centerRight, // ✅ ชิดซ้าย
//     //                         child: pw.Padding(
//     //                           padding: pw.EdgeInsets.only(
//     //                               right: 4), // ✅ เว้นขอบซ้ายนิดหน่อย
//     //                           child: pw.Text(
//     //                             total_all,
//     //                             style: pw.TextStyle(
//     //                               fontSize: font_Size,
//     //                               font: ttf,
//     //                               color: Colors_pd,
//     //                             ),
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ),
//     //                   ),
//     //                 ],
//     //               ),
//     //             ),
//     //             pw.SizedBox(height: 2 * PdfPageFormat.mm),
//     //             pw.Row(
//     //               children: [
//     //                 pw.Expanded(
//     //                   flex: 1,
//     //                   child: pw.Text(
//     //                     'หมายเหตุ : ',
//     //                     style: pw.TextStyle(
//     //                       fontSize: font_Size,
//     //                       fontWeight: pw.FontWeight.bold,
//     //                       font: ttf,
//     //                       color: Colors_pd,
//     //                     ),
//     //                   ),
//     //                 ),
//     //                 pw.Expanded(
//     //                   flex: 9,
//     //                   child: pw.Text(
//     //                     '1. อัตราค่าไฟฟ้า หน่วยละ 7 บาท/ อัตราค่าน้ำประปา หน่วยละ 35 บาท',
//     //                     style: pw.TextStyle(
//     //                       fontSize: font_Size,
//     //                       fontWeight: pw.FontWeight.bold,
//     //                       font: ttf,
//     //                       color: Colors_pd,
//     //                     ),
//     //                   ),
//     //                 ),
//     //               ],
//     //             ),
//     //             pw.Row(
//     //               children: [
//     //                 pw.Expanded(flex: 1, child: pw.SizedBox()),
//     //                 pw.Expanded(
//     //                   flex: 9,
//     //                   child: pw.Text(
//     //                     '2. ค่าภาษีที่ดินและสิ่งปลูกสร้าง อัตราตารางเมตรละ .......... บาท/ปี (ภาระเป็นของผู ้เช่า)',
//     //                     style: pw.TextStyle(
//     //                       fontSize: font_Size,
//     //                       fontWeight: pw.FontWeight.bold,
//     //                       font: ttf,
//     //                       color: Colors_pd,
//     //                     ),
//     //                   ),
//     //                 ),
//     //               ],
//     //             ),
//     //             pw.Row(
//     //               children: [
//     //                 pw.Expanded(flex: 1, child: pw.SizedBox()),
//     //                 pw.Expanded(
//     //                   flex: 9,
//     //                   child: pw.Text(
//     //                     '3. ค่าอากรติดสัญญญา ต้นฉบับรวมชำระค่าอากร .......... บาท (ภาระเป็นของผู ้เช่า)',
//     //                     style: pw.TextStyle(
//     //                       fontSize: font_Size,
//     //                       fontWeight: pw.FontWeight.bold,
//     //                       font: ttf,
//     //                       color: Colors_pd,
//     //                     ),
//     //                   ),
//     //                 ),
//     //               ],
//     //             ),
//     //             pw.Row(
//     //               children: [
//     //                 pw.Expanded(
//     //                   flex: 1,
//     //                   child: pw.Text(
//     //                     'การชำระ : ',
//     //                     style: pw.TextStyle(
//     //                       fontSize: font_Size,
//     //                       fontWeight: pw.FontWeight.bold,
//     //                       font: ttf,
//     //                       color: Colors_pd,
//     //                     ),
//     //                   ),
//     //                 ),
//     //                 pw.Expanded(
//     //                   flex: 9,
//     //                   child: pw.Text(
//     //                     '4. ชำระจองพื้นที่ ........ บาท (เป็นค่าเช่าพื้นที่เดือนแรก) ภายใน 30 วัน นับจากวันที่ลงนามในใบเสนอราคา',
//     //                     style: pw.TextStyle(
//     //                       fontSize: font_Size,
//     //                       fontWeight: pw.FontWeight.bold,
//     //                       font: ttf,
//     //                       color: Colors_pd,
//     //                     ),
//     //                   ),
//     //                 ),
//     //               ],
//     //             ),
//     //             pw.Row(
//     //               children: [
//     //                 pw.Expanded(flex: 1, child: pw.SizedBox()),
//     //                 pw.Expanded(
//     //                   flex: 9,
//     //                   child: pw.Text(
//     //                     'กรุณาโอนเงินเข้าบัญชี ธ.กรุงไทย สาขาสี ่แยกสนามบินเชียงใหม่ ชื่อบัญชี บริษัท นิ่มซิตี้ เดลี่ จำกัด เลขที่บัญชี 771-0-01967-6',
//     //                     style: pw.TextStyle(
//     //                       fontSize: font_Size,
//     //                       fontWeight: pw.FontWeight.bold,
//     //                       font: ttf,
//     //                       color: Colors_pd,
//     //                     ),
//     //                   ),
//     //                 ),
//     //               ],
//     //             ),
//     //             pw.Row(
//     //               children: [
//     //                 pw.Expanded(flex: 1, child: pw.SizedBox()),
//     //                 pw.Expanded(
//     //                   flex: 9,
//     //                   child: pw.Text(
//     //                     '5. อัตราค่าประกันพื้นที่เช่าและค่าประกันค่าบริการส่วนกลาง เท่ากับ 3 เท่าของค่าเช่า (จะคืนเมื่อสิ้นสุดสัญญาเช่า)',
//     //                     style: pw.TextStyle(
//     //                       fontSize: font_Size,
//     //                       fontWeight: pw.FontWeight.bold,
//     //                       font: ttf,
//     //                       color: Colors_pd,
//     //                     ),
//     //                   ),
//     //                 ),
//     //               ],
//     //             ),
//     //             pw.Row(
//     //               children: [
//     //                 pw.Expanded(flex: 1, child: pw.SizedBox()),
//     //                 pw.Expanded(
//     //                   flex: 9,
//     //                   child: pw.Text(
//     //                     '6. ระยะเวลาตกแต่ง .......... เดือน เริ่มวันที่ ..............................',
//     //                     style: pw.TextStyle(
//     //                       fontSize: font_Size,
//     //                       fontWeight: pw.FontWeight.bold,
//     //                       font: ttf,
//     //                       color: Colors_pd,
//     //                     ),
//     //                   ),
//     //                 ),
//     //               ],
//     //             ),
//     //             pw.Row(
//     //               children: [
//     //                 pw.Expanded(flex: 1, child: pw.SizedBox()),
//     //                 pw.Expanded(
//     //                   flex: 9,
//     //                   child: pw.Text(
//     //                     '7. วันที ่เริ่มค่าเช่า ..............................',
//     //                     style: pw.TextStyle(
//     //                       fontSize: font_Size,
//     //                       fontWeight: pw.FontWeight.bold,
//     //                       font: ttf,
//     //                       color: Colors_pd,
//     //                     ),
//     //                   ),
//     //                 ),
//     //               ],
//     //             ),
//     //           ],
//     //         ),
//     //       ),
//     //     ];
//     //   },
//     //   footer: (context) {
//     //     return pw.Column(
//     //       mainAxisSize: pw.MainAxisSize.min,
//     //       children: [
//     //         pw.Row(
//     //           mainAxisSize: pw.MainAxisSize.min,
//     //           children: [
//     //             // กล่องซ้าย
//     //             pw.Container(
//     //               padding: const pw.EdgeInsets.all(8.0),
//     //               width: 240, // ความกว้างกล่อง
//     //               decoration: pw.BoxDecoration(
//     //                 border: pw.Border.all(color: PdfColors.grey, width: 1),
//     //               ),
//     //               child: pw.Column(
//     //                 mainAxisAlignment: pw.MainAxisAlignment.center,
//     //                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//     //                 children: [
//     //                   pw.Row(
//     //                     children: [
//     //                       pw.Expanded(
//     //                         child: pw.Text(
//     //                           '(..............................................................................................)',
//     //                           textAlign: pw.TextAlign.center,
//     //                           style: pw.TextStyle(
//     //                             fontSize: font_Size,
//     //                             fontWeight: pw.FontWeight.bold,
//     //                             font: ttf,
//     //                             color: Colors_pd,
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ],
//     //                   ),
//     //                   pw.SizedBox(height: 1 * PdfPageFormat.mm),
//     //                   pw.Row(
//     //                     children: [
//     //                       pw.Expanded(
//     //                         child: pw.Text(
//     //                           '..................................................................',
//     //                           textAlign: pw.TextAlign.center,
//     //                           style: pw.TextStyle(
//     //                             fontWeight: pw.FontWeight.bold,
//     //                             fontSize: font_Size,
//     //                             font: ttf,
//     //                             color: Colors_pd,
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ],
//     //                   ),
//     //                   pw.Row(
//     //                     children: [
//     //                       pw.Expanded(
//     //                         child: pw.Text(
//     //                           'ผู้ขอเช่า/จองพื้นที่',
//     //                           textAlign: pw.TextAlign.center,
//     //                           style: pw.TextStyle(
//     //                             fontWeight: pw.FontWeight.bold,
//     //                             fontSize: font_Size,
//     //                             font: ttf,
//     //                             color: Colors_pd,
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ],
//     //                   ),
//     //                   pw.Row(
//     //                     children: [
//     //                       pw.Expanded(
//     //                         child: pw.Text(
//     //                           'ลงวันที่...................................................',
//     //                           textAlign: pw.TextAlign.center,
//     //                           style: pw.TextStyle(
//     //                             fontWeight: pw.FontWeight.bold,
//     //                             fontSize: font_Size,
//     //                             font: ttf,
//     //                             color: Colors_pd,
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ],
//     //                   ),
//     //                 ],
//     //               ),
//     //             ),

//     //             pw.SizedBox(width: 50), // เว้นระหว่างกล่อง

//     //             // กล่องขวา (เหมือนซ้าย)
//     //             pw.Container(
//     //               padding: const pw.EdgeInsets.all(8.0),
//     //               width: 240, // ความกว้างกล่อง
//     //               decoration: pw.BoxDecoration(
//     //                 border: pw.Border.all(color: PdfColors.grey, width: 1),
//     //               ),
//     //               child: pw.Column(
//     //                 mainAxisAlignment: pw.MainAxisAlignment.center,
//     //                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//     //                 children: [
//     //                   pw.Row(
//     //                     children: [
//     //                       pw.Expanded(
//     //                         child: pw.Text(
//     //                           '(..............................................................................................)',
//     //                           textAlign: pw.TextAlign.center,
//     //                           style: pw.TextStyle(
//     //                             fontSize: font_Size,
//     //                             fontWeight: pw.FontWeight.bold,
//     //                             font: ttf,
//     //                             color: Colors_pd,
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ],
//     //                   ),
//     //                   pw.SizedBox(height: 1 * PdfPageFormat.mm),
//     //                   pw.Row(
//     //                     children: [
//     //                       pw.Expanded(
//     //                         child: pw.Text(
//     //                           '..................................................................',
//     //                           textAlign: pw.TextAlign.center,
//     //                           style: pw.TextStyle(
//     //                             fontWeight: pw.FontWeight.bold,
//     //                             fontSize: font_Size,
//     //                             font: ttf,
//     //                             color: Colors_pd,
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ],
//     //                   ),
//     //                   pw.Row(
//     //                     children: [
//     //                       pw.Expanded(
//     //                         child: pw.Text(
//     //                           'ผู้เสนอราคา',
//     //                           textAlign: pw.TextAlign.center,
//     //                           style: pw.TextStyle(
//     //                             fontWeight: pw.FontWeight.bold,
//     //                             fontSize: font_Size,
//     //                             font: ttf,
//     //                             color: Colors_pd,
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ],
//     //                   ),
//     //                   pw.Row(
//     //                     children: [
//     //                       pw.Expanded(
//     //                         child: pw.Text(
//     //                           'ลงวันที่...................................................',
//     //                           textAlign: pw.TextAlign.center,
//     //                           style: pw.TextStyle(
//     //                             fontWeight: pw.FontWeight.bold,
//     //                             fontSize: font_Size,
//     //                             font: ttf,
//     //                             color: Colors_pd,
//     //                           ),
//     //                         ),
//     //                       ),
//     //                     ],
//     //                   ),
//     //                 ],
//     //               ),
//     //             ),
//     //           ],
//     //         ),
//     //         pw.SizedBox(height: 3 * PdfPageFormat.mm),
//     //         pw.Align(
//     //           alignment: pw.Alignment.bottomRight,
//     //           child: pw.Text(
//     //             'หน้า ${context.pageNumber} / ${context.pagesCount} ',
//     //             style: pw.TextStyle(
//     //               fontSize: 10,
//     //               font: ttf,
//     //               color: Colors_pd,
//     //             ),
//     //           ),
//     //         ),
//     //       ],
//     //     );
//     //   },
//     // ));
//     // final bytes = await pdf.save();

//     // final dir = await getApplicationDocumentsDirectory();
//     // final file = File('${dir.path}/name');
//     // await file.writeAsBytes(bytes);
//     // return file;
//     //----------------------------------------->
//     // final List<int> bytes = await pdf.save();
//     // final Uint8List data = Uint8List.fromList(bytes);
//     // MimeType type = MimeType.PDF;
//     // final dir = await FileSaver.instance.saveFile(
//     //     "ใบเสนอราคา(ณ วันที่${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day})",
//     //     data,
//     //     "pdf",
//     //     mimeType: type);
//     Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => PreviewScreenRentalInforma(doc: pdf),
//         ));
//   }
// }
