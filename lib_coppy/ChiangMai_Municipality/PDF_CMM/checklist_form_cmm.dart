// import 'dart:io';
// import 'package:file_saver/file_saver.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show Uint8List, rootBundle;
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;

// import '../../Constant/Myconstant.dart';
// import '../../PeopleChao/Pays_.dart';
// import '../Model/ReviewUuid_Model.dart';
// import '../unity/FormatIDCard.dart';
// import '../unity/FormatPhone.dart';
// import '../unity/thai_date_utils.dart';
// import 'unity_pdf_cmm/perviewpdf1_cmm.dart';
// import 'unity_pdf_cmm/perviewpdfchecklist_cmm.dart';
// import 'unity_pdf_cmm/unitypdf_cmm.dart';

// Future<dynamic> GeneratePDF_ChecklistForm_CMM(
//     BuildContext context, int type, DataDetail) async {
//   final pdf = pw.Document();
//   final ttf = await font1();

//   List data_check = [
//     {
//       "ser": "1",
//       "title": "ใบคำขอต่ออายุใบอนุญาต",
//       "bool": true,
//     },
//     {
//       "ser": "2",
//       "title": "ใบรับรองแพทย์",
//       "bool": true,
//     },
//     {
//       "ser": "3",
//       "title": "รูปถ่าย 2 นิ้ว จำนวน 2 รูป",
//       "bool": true,
//     },
//     {
//       "ser": "4",
//       "title": "ใบอนุญาตจำหน่ายสินค้า",
//       "bool": true,
//     },
//     {
//       "ser": "5",
//       "title": "รูปถ่ายคู่กับสินค้าที่จำหน่าย จำนวน 1 ใบ",
//       "bool": true,
//     },
//     {
//       "ser": "6",
//       "title": "หนังสือมอบอำนาจ",
//       "bool": true,
//     },
//     {
//       "ser": "7",
//       "title": "หลักฐานการเปลี่ยนชื่อสกุล",
//       "bool": true,
//     },
//     {
//       "ser": "8",
//       "title": "ประเภทสินค้า",
//       "bool": true,
//     },
//     {
//       "ser": "9",
//       "title": "อื่น ๆ",
//       "bool": true,
//     },
//   ];
//   pdf.addPage(
//     pw.MultiPage(
//       pageFormat: PdfPageFormat.a4.copyWith(
//         marginBottom: 18.00,
//         marginLeft: 18.00,
//         marginRight: 18.00,
//         marginTop: 18.00,
//       ),
//       header: (context) {
//         return pw.Row(
//           mainAxisAlignment: pw.MainAxisAlignment.start,
//           crossAxisAlignment: pw.CrossAxisAlignment.center,
//           children: [
//             pw.Expanded(
//               flex: 2,
//               child: pw.Column(
//                 mainAxisAlignment: pw.MainAxisAlignment.start,
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   pw.Align(
//                     alignment: pw.Alignment.center,
//                     child: pw.Text('สำหรับเจ้าหน้าที่',
//                         style: pw.TextStyle(
//                             font: ttf,
//                             fontSize: 15,
//                             fontWeight: pw.FontWeight.bold)),
//                   ),
//                   pw.Align(
//                     alignment: pw.Alignment.center,
//                     child: pw.Text('ได้รับเอกสารประกอบคำขอต่ออายุใบอนุญาต',
//                         style: pw.TextStyle(
//                             font: ttf,
//                             fontSize: 15,
//                             fontWeight: pw.FontWeight.bold)),
//                   ),
//                   pw.Align(
//                     alignment: pw.Alignment.center,
//                     child: pw.Text('พื้นที่ผ่อนผันบริเวณ',
//                         style: pw.TextStyle(
//                             font: ttf,
//                             fontSize: 15,
//                             fontWeight: pw.FontWeight.bold)),
//                   ),
//                 ],
//               ),
//             ),
//             pw.Expanded(
//               flex: 1,
//               child: pw.Column(
//                 children: [
//                   pw.Align(
//                     alignment: pw.Alignment.center,
//                     child: pw.Text('ตรวจเอกสาร',
//                         style: pw.TextStyle(
//                             font: ttf,
//                             fontSize: 15,
//                             fontWeight: pw.FontWeight.bold)),
//                   ),
//                   pw.Row(
//                     children: [
//                       pw.Align(
//                         alignment: pw.Alignment.center,
//                         child: pw.Text('ตรวจเอกสาร',
//                             style: pw.TextStyle(
//                                 font: ttf,
//                                 fontSize: 15,
//                                 fontWeight: pw.FontWeight.bold)),
//                       ),
//                       pw.Align(
//                         alignment: pw.Alignment.center,
//                         child: pw.Text('ตรวจเอกสาร',
//                             style: pw.TextStyle(
//                                 font: ttf,
//                                 fontSize: 15,
//                                 fontWeight: pw.FontWeight.bold)),
//                       ),
//                     ],
//                   ),
//                   pw.Row(
//                     children: [
//                       pw.Align(
//                         alignment: pw.Alignment.center,
//                         child: pw.Text('ผ่าน',
//                             style: pw.TextStyle(
//                                 font: ttf,
//                                 fontSize: 15,
//                                 fontWeight: pw.FontWeight.bold)),
//                       ),
//                       pw.Align(
//                         alignment: pw.Alignment.center,
//                         child: pw.Text('ไม่ผ่าน',
//                             style: pw.TextStyle(
//                                 font: ttf,
//                                 fontSize: 15,
//                                 fontWeight: pw.FontWeight.bold)),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//       },
//       build: (context) => [
//         pw.SizedBox(height: 20),
//         pw.Align(
//           alignment: pw.Alignment.centerRight,
//           child: pw.Text('ทำที่ สำนักงานเทศบาลนครเชียงใหม่',
//               style: pw.TextStyle(
//                   font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
//         ),
//         for (int index = 0; index < data_check.length; index++)
//           pw.Row(
//             children: [
//               Textx(
//                 value: ' [ / ] ',
//                 font: ttf,
//               ),
//               Textx(
//                 value: '${data_check[index]['title']}',
//                 font: ttf,
//               ),
//               // labeledLine(
//               //   value: '$addr1',
//               //   flex: 1,
//               //   font: ttf,
//               // ),
//             ],
//           ),
//       ],
//     ),
//   );

//   // final List<int> bytes = await pdf.save();
//   // final Uint8List data = Uint8List.fromList(bytes);
//   // MimeType type = MimeType.PDF;
//   // final dir = await FileSaver.instance.saveFile(
//   //     "ใบคำร้องขอต่อใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ", data, "pdf",
//   //     mimeType: type);
//   // Navigator.push(
//   //     context,
//   //     MaterialPageRoute(
//   //       builder: (context) => PreviewPdfgen_Billsplay(
//   //           doc: pdf,
//   //           title: 'ใบคำร้องขอต่อใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ'),
//   //     ));

//   if (type == 0) {
//     return pdf;
//   } else {
//     Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => PreviewPdfgenchecklist_CMM(
//               doc: pdf,
//               title: 'ใบคำร้องขอต่อใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ'),
//         ));
//   }
// }
