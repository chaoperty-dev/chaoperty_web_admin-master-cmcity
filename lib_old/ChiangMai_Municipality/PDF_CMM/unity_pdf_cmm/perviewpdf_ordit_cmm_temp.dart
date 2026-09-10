// import 'dart:convert';

// import 'package:chaoperty/ChiangMai_Municipality/unity/show_dialog_cmm.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
// import 'package:http/http.dart' as http;
// import '../../../Constant/Myconstant.dart';
// import '../../../Style/Translate.dart';
// import '../../../Style/colors.dart';
// import '../../Model/ReviewUuid_Model.dart';
// import '../../unity/API_requests_reviews.dart';
// import '../../unity/API_requests_reviewsflow.dart';
// import '../../unity/Enum.dart';
// import '../../unity/FormatDate.dart';

// class PreviewPdf_ordit_CMM extends StatefulWidget {
//   // final pw.Document doc;
//   final renTal_name;
//   final title;
//   final id;
//   final uuid;
//   final Request_Uuid;
//   final code;
//   final file_path;
//   final file_type;
//   final file_typeOpen;
//   final uploaded_At;
//   final commentReviewer;
//   final statusReviewer;
//   // List<RequiredDocument> docs;
//   List<dynamic> docs;
//   List<dynamic> data_title_doc;
//   PreviewPdf_ordit_CMM({
//     Key? key,
//     this.renTal_name,
//     this.title,
//     this.id,
//     this.uuid,
//     this.Request_Uuid,
//     this.code,
//     this.file_path,
//     this.file_type,
//     this.file_typeOpen,
//     this.uploaded_At,
//     this.commentReviewer,
//     this.statusReviewer,
//     required this.docs,
//     required this.data_title_doc,
//   }) : super(key: key);

//   @override
//   State<PreviewPdf_ordit_CMM> createState() => _PreviewPdf_ordit_CMMState();
// }

// class _PreviewPdf_ordit_CMMState extends State<PreviewPdf_ordit_CMM> {
//   static const customSwatch = MaterialColor(
//     0xFF8DB95A,
//     <int, Color>{
//       50: Color(0xFFC2FD7F),
//       100: Color(0xFFB6EE77),
//       200: Color(0xFFB2E875),
//       300: Color(0xFFACDF71),
//       400: Color(0xFFA7DA6E),
//       500: Color(0xFFA1D16A),
//       600: Color(0xFF94BF62),
//       700: Color(0xFF90B961),
//       800: Color(0xFF85AB5A),
//       900: Color(0xFF7A9B54),
//     },
//   );
//   final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
//   final PdfViewerController _pdfController = PdfViewerController();
//   final TextEditingController _searchController = TextEditingController();
//   PdfTextSearchResult _searchResult = PdfTextSearchResult();
//   final PdfViewerController _pdfViewerController = PdfViewerController();
//   double _currentZoomLevel = 1.0;

//   bool bool_type() {
//     return widget.file_typeOpen == 'ReviewsFile' &&
//         widget.statusReviewer == 'pending';
//   }

//   dynamic ResponseReviews, is_open_approved;

//   Uint8List? _pdfBytes;
//   bool _isLoading = true;
//   String? _error;
//   @override
//   void initState() {
//     super.initState();
//     loadPdfBytes();
//   }

//   Future<void> loadPdfBytes() async {
//     final response = await pdfimg_ReviewsFlow(attachmentUuid: widget.uuid);
//     if (response != null && response.statusCode == 200) {
//       setState(() {
//         _pdfBytes = response.bodyBytes;
//         _isLoading = false;
//       });
//     } else {
//       setState(() {
//         _error = 'โหลด PDF ไม่สำเร็จ';
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _printPDF() async {
//     if (_pdfBytes == null) return;

//     await Printing.layoutPdf(
//       onLayout: (PdfPageFormat format) async => _pdfBytes!,
//     );
//   }

//   Future<void> _savePDF() async {
//     if (_pdfBytes == null) return;

//     await Printing.sharePdf(
//       bytes: _pdfBytes!,
//       filename: 'downloaded_document.pdf',
//     );
//   }

//   // Future<void> _printPDF() async {
//   //   final response = await http.get(Uri.parse(pdfUrl));
//   //   if (response.statusCode == 200) {
//   //     await Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
//   //       return response.bodyBytes;
//   //     });
//   //   } else {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('❌ Failed to load PDF')),
//   //     );
//   //   }
//   // }

//   // Future<void> _savePDF() async {
//   //   final response = await http.get(Uri.parse(pdfUrl));
//   //   if (response.statusCode == 200) {
//   //     await Printing.sharePdf(
//   //       bytes: response.bodyBytes,
//   //       filename: 'downloaded_document.pdf',
//   //     );
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     final widthx = MediaQuery.of(context).size.width > 600 ? 5 : 3;
//     final heightx = MediaQuery.of(context).size.height > 600 ? 4 : 2;
//     // final pdf = pw.Document();
//     // final String pdfUrl =
//     //     '${MyConstant().domain_v1}/admin/requests/attachments/${widget.uuid}/preview';
//     // print(pdfUrl);
//     Future<void> _notSuccessFully() async {
//       Dialog_error(context, 'ไม่สามารถทำรายการนี้ได้');
//     }

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         appBar: AppBar(
//           backgroundColor: AppBarColors.hexColor,
//           leading: IconButton(
//             onPressed: () {
//               Navigator.pop(context, {
//                 'message': ResponseReviews,
//                 'isopenapproved': is_open_approved, // ✅ Safe
//               });
//               // Navigator.pop(context,  'message': ResponseReviews, );
//             },
//             // onPressed: () => Navigator.pop(context),
//             icon: const Icon(
//               Icons.arrow_back_outlined,
//               color: Colors.white,
//             ),
//           ),
//           centerTitle: true,
//           title: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Center(
//                       child: Text(
//                         "${widget.title}",
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontFamily: Font_.Fonts_T,
//                         ),
//                       ),
//                     ),
//                   ),
//                   // Text(
//                   //   (widget.uploaded_At == null)
//                   //       ? ''
//                   //       : "Uploaded : ${formatDate(widget.uploaded_At, type: DateFormatType.thaiShort)}",
//                   //   style: TextStyle(
//                   //     fontSize: 12,
//                   //     color: Colors.white.withOpacity(0.5),
//                   //     fontFamily: Font_.Fonts_T,
//                   //   ),
//                   // ),
//                 ],
//               ),
//               Text(
//                 (widget.uuid == null) ? '(error)' : "(${widget.uuid})",
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.white.withOpacity(0.5),
//                   fontFamily: Font_.Fonts_T,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         body: Row(
//           children: [
//             IconButton(
//               icon: const Icon(Icons.navigate_before),
//               onPressed: () {
//                 if (widget.file_type.toString() == 'pdf') {
//                   _pdfViewerController.previousPage();
//                 } else {
//                   // TODO: image mode (ถ้ามีหลายภาพให้เปลี่ยน index)
//                 }
//               },
//             ),
//             Expanded(
//               child: SizedBox(
//                 child: Column(
//                   children: [
//                     Expanded(
//                       // child: SizedBox(),
//                       child: (widget.file_type.toString() != 'pdf')
//                           ? Stack(
//                               children: [
//                                 Container(
//                                   width:
//                                       MediaQuery.of(context).size.width * 0.85,
//                                   height:
//                                       MediaQuery.of(context).size.height * 0.85,
//                                   padding: const EdgeInsets.all(20.0),
//                                   child: ClipRRect(
//                                     borderRadius: const BorderRadius.only(
//                                       topLeft: Radius.circular(8.0),
//                                       topRight: Radius.circular(8.0),
//                                       bottomLeft: Radius.circular(8.0),
//                                       bottomRight: Radius.circular(8.0),
//                                     ),
//                                     child: ClipRRect(
//                                       borderRadius: BorderRadius.circular(8.0),
//                                       child: FittedBox(
//                                         // fit: BoxFit.cover,
//                                         child: Image.memory(
//                                           _pdfBytes!,
//                                           // height: 180,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ), // 🔽 ลายน้ำแบบ Overlay
//                                 IgnorePointer(
//                                   child: LayoutBuilder(
//                                     builder: (context, constraints) {
//                                       final width = constraints.maxWidth;
//                                       final height = constraints.maxHeight;

//                                       List<Widget> watermarks = [];

//                                       for (double y = 0;
//                                           y < height;
//                                           y += height / heightx) {
//                                         for (double x = 0;
//                                             x < width;
//                                             x += width / widthx) {
//                                           watermarks.add(Positioned(
//                                             left: x,
//                                             top: y,
//                                             child: Transform.rotate(
//                                               angle: -0.4, // ประมาณ -22 องศา
//                                               child: Opacity(
//                                                 opacity: 0.08,
//                                                 child: Text(
//                                                   'Chaoperty',
//                                                   style: TextStyle(
//                                                     fontSize: 40,
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.black
//                                                         .withOpacity(0.8),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ));
//                                         }
//                                       }

//                                       return Stack(children: watermarks);
//                                     },
//                                   ),
//                                 ),
//                               ],
//                             )
//                           : Stack(
//                               children: [
//                                 // SfPdfViewer.network(
//                                 //   pdfUrl,
//                                 SfPdfViewer.memory(
//                                   _pdfBytes!,
//                                   key: _pdfViewerKey,
//                                   controller: _pdfViewerController,
//                                   enableDocumentLinkAnnotation: false,
//                                   canShowScrollHead: false,
//                                   canShowScrollStatus: false,
//                                   pageLayoutMode: PdfPageLayoutMode.continuous,
//                                   enableDoubleTapZooming: true,
//                                   onZoomLevelChanged: (details) {
//                                     setState(() {
//                                       _currentZoomLevel = details.newZoomLevel;
//                                     });
//                                   },
//                                 ),
//                                 // 🔽 ลายน้ำแบบ Overlay
//                                 IgnorePointer(
//                                   child: LayoutBuilder(
//                                     builder: (context, constraints) {
//                                       final width = constraints.maxWidth;
//                                       final height = constraints.maxHeight;

//                                       List<Widget> watermarks = [];

//                                       for (double y = 0;
//                                           y < height;
//                                           y += height / heightx) {
//                                         for (double x = 0;
//                                             x < width;
//                                             x += width / widthx) {
//                                           watermarks.add(Positioned(
//                                             left: x,
//                                             top: y,
//                                             child: Transform.rotate(
//                                               angle: -0.4, // ประมาณ -22 องศา
//                                               child: Opacity(
//                                                 opacity: 0.08,
//                                                 child: Text(
//                                                   'Chaoperty',
//                                                   style: TextStyle(
//                                                     fontSize: 40,
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.black
//                                                         .withOpacity(0.8),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ));
//                                         }
//                                       }

//                                       return Stack(children: watermarks);
//                                     },
//                                   ),
//                                 ),
//                               ],
//                             ),
//                     ),
//                     Container(
//                       color: Colors.grey[200],
//                       child: Row(
//                         children: [
//                           Expanded(
//                               child: Row(
//                             children: [
//                               SizedBox(
//                                 width: 20,
//                               ),
//                               IconButton(
//                                 icon: const Icon(Icons.print),
//                                 onPressed: (widget.file_typeOpen.toString() ==
//                                         'SuccessFully')
//                                     ? _printPDF
//                                     : _notSuccessFully,
//                                 tooltip: 'Print PDF',
//                               ),
//                               SizedBox(
//                                 width: 10,
//                               ),
//                               IconButton(
//                                 icon: const Icon(Icons.save_alt),
//                                 onPressed: (widget.file_typeOpen.toString() ==
//                                         'SuccessFully')
//                                     ? _savePDF
//                                     : _notSuccessFully,
//                                 tooltip: 'Save PDF',
//                               ),
//                               SizedBox(
//                                 width: 10,
//                               ),
//                               IconButton(
//                                 icon: Icon(Icons.zoom_in),
//                                 onPressed: () {
//                                   setState(() {
//                                     _currentZoomLevel += 0.25;
//                                     if (_currentZoomLevel > 3.0)
//                                       _currentZoomLevel = 3.0;
//                                     _pdfViewerController.zoomLevel =
//                                         _currentZoomLevel;
//                                   });
//                                 },
//                               ),
//                               SizedBox(
//                                 width: 10,
//                               ),
//                               IconButton(
//                                 icon: Icon(Icons.zoom_out),
//                                 onPressed: () {
//                                   setState(() {
//                                     _currentZoomLevel -= 0.25;
//                                     if (_currentZoomLevel < 1.0)
//                                       _currentZoomLevel = 1.0;
//                                     _pdfViewerController.zoomLevel =
//                                         _currentZoomLevel;
//                                   });
//                                 },
//                               ),
//                               SizedBox(
//                                 width: 10,
//                               ),
//                             ],
//                           )),
//                           if (bool_type())
//                             Padding(
//                               padding: const EdgeInsets.all(4.0),
//                               child: Translate.TranslateAndSet_TextAutoSize(
//                                   '*โปรดตรวจสอบความถูกต้องของเอกสารก่อนกดยืนยัน',
//                                   CustomerScreen_Color.Colors_Text2_,
//                                   TextAlign.center,
//                                   null,
//                                   Font_.Fonts_T,
//                                   10,
//                                   14,
//                                   1),
//                             ),
//                           if (bool_type())
//                             Padding(
//                               padding: const EdgeInsets.all(4.0),
//                               child: Container(
//                                 width: 160,
//                                 child: Center(
//                                   child: ElevatedButton(
//                                     style: ButtonStyle(
//                                       backgroundColor:
//                                           MaterialStateProperty.all<Color>(
//                                         Colors.grey.shade400,
//                                       ),
//                                     ),
//                                     onPressed: () async {
//                                       Cancel_showDialog(context);
//                                     },
//                                     child:
//                                         Translate.TranslateAndSet_TextAutoSize(
//                                             'ไม่ผ่านเกณฑ์/แจ้งการแก้ไข',
//                                             CustomerScreen_Color.Colors_Text2_,
//                                             TextAlign.center,
//                                             null,
//                                             Font_.Fonts_T,
//                                             10,
//                                             14,
//                                             1),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           if (bool_type())
//                             Padding(
//                               padding: const EdgeInsets.all(4.0),
//                               child: Container(
//                                 width: 160,
//                                 child: Center(
//                                   child: ElevatedButton(
//                                     style: ButtonStyle(
//                                       backgroundColor:
//                                           MaterialStateProperty.all<Color>(
//                                         Colors.grey.shade900,
//                                       ),
//                                     ),
//                                     onPressed: () async {
//                                       Approved_showDialog(context);
//                                     },
//                                     child:
//                                         Translate.TranslateAndSet_TextAutoSize(
//                                             'เอกสารฉบับนี้ถูกต้อง',
//                                             CustomerScreen_Color.Colors_Text3_,
//                                             TextAlign.center,
//                                             null,
//                                             Font_.Fonts_T,
//                                             10,
//                                             14,
//                                             1),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             IconButton(
//               icon: const Icon(Icons.navigate_next),
//               onPressed: () {
//                 if (widget.file_type.toString() == 'pdf') {
//                   _pdfViewerController.nextPage();
//                 } else {
//                   // TODO: image mode
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> Cancel_showDialog(BuildContext context) async {
//     int selectedOption = 0;
//     TextEditingController reasonController = TextEditingController();
//     final _formKey = GlobalKey<FormState>();
//     String reason = '';
//     List status_list = ['needs_update', 'rejected', 'approved'];
//     await showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16)),
//               title: RichText(
//                 textAlign: TextAlign.center,
//                 text: const TextSpan(
//                   style: TextStyle(fontSize: 16, color: Colors.black),
//                   children: [
//                     TextSpan(
//                       text: 'เอกสารไม่ผ่านเกณฑ์ ',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     TextSpan(text: 'ท่านต้องการแจ้งให้แก้ไขเอกสารหรือไม่'),
//                   ],
//                 ),
//               ),
//               content: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     RadioListTile<int>(
//                       value: 0,
//                       groupValue: selectedOption,
//                       onChanged: (value) {
//                         setState(() {
//                           selectedOption = value!;
//                           reasonController.clear();
//                           reason = '';
//                         });
//                       },
//                       title: const Text(
//                           'แจ้งผู้ส่งคำร้องให้แก้ไขเอกสาร (โปรดระบุรายละเอียด)'),
//                     ),
//                     if (selectedOption == 0)
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                         child: TextFormField(
//                           controller: reasonController,
//                           maxLines: 2,
//                           onChanged: (val) => setState(() => reason = val),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'กรุณากรอกข้อมูล';
//                             } else if (value.length < 10) {
//                               return 'กรุณากรอกอย่างน้อย 10 ตัวอักษร';
//                             }
//                             return null;
//                           },
//                           decoration: const InputDecoration(
//                             hintText: 'โปรดกรอกรายละเอียด...',
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                       ),
//                     RadioListTile<int>(
//                       value: 1,
//                       groupValue: selectedOption,
//                       onChanged: (value) {
//                         setState(() {
//                           selectedOption = value!;
//                           reasonController.clear();
//                           reason = '';
//                         });
//                       },
//                       title: const Text(
//                         'ไม่, คำร้องขอต่อใบอนุญาตจะไม่สามารถดำเนินการต่อได้หากเอกสารถูกแบบไม่ครบตามกำหนด',
//                       ),
//                     ),
//                     if (selectedOption == 1)
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                         child: TextFormField(
//                           controller: reasonController,
//                           maxLines: 2,
//                           onChanged: (val) => setState(() => reason = val),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'กรุณากรอกข้อมูล';
//                             } else if (value.length < 10) {
//                               return 'กรุณากรอกอย่างน้อย 10 ตัวอักษร';
//                             }
//                             return null;
//                           },
//                           decoration: const InputDecoration(
//                             hintText: 'โปรดกรอกรายละเอียด...',
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('ยกเลิก'),
//                 ),
//                 ElevatedButton(
//                   onPressed: reason.trim().isEmpty
//                       ? null
//                       : () async {
//                           if (_formKey.currentState!.validate()) {
//                             final attachments_Uuid = widget.uuid.toString();
//                             print(widget.uuid);
//                             final response = await Post_ReviewsAttachMents(
//                               staTus: status_list[selectedOption],
//                               requestUuid: widget.Request_Uuid,
//                               attachmentsUuid: attachments_Uuid,
//                               descripTion: reasonController.text.toString(),
//                               // role: ReviewsApprovalRoleType.doc_reviewer
//                             );
//                             if (response!.statusCode == 201 ||
//                                 response!.statusCode == 409) {
//                               ResponseReviews = response.body;
//                               Navigator.pop(
//                                 context,
//                                 reasonController.text,
//                               );
//                               print('✅ Post Reviews Success: ${response.body}');
//                             } else {
//                               print(
//                                   '❌ Post Reviews Failed [${response.statusCode}]: ${response.body}');
//                             }
//                             // Navigator.pop(context, reasonController.text);
//                           }
//                         },
//                   child: const Text('ยืนยัน'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

// //   Future<void> Approved_showDialog(
// //     BuildContext context,
// //   ) async {
// //     int selectedOption = 2;
// //     TextEditingController reasonController = TextEditingController();
// //     final _formKey = GlobalKey<FormState>();
// //     String reason = '';
// //     List status_list = ['needs_update', 'rejected', 'approved'];
// //     await showDialog(
// //       context: context,
// //       builder: (context) {
// //         return StatefulBuilder(
// //           builder: (context, setState) {
// //             return AlertDialog(
// //               shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(16)),
// //               title: RichText(
// //                 textAlign: TextAlign.center,
// //                 text: const TextSpan(
// //                   style: TextStyle(fontSize: 16, color: Colors.black),
// //                   children: [
// //                     TextSpan(
// //                       text: 'เอกสารผ่านเกณฑ์ ',
// //                       style: TextStyle(fontWeight: FontWeight.bold),
// //                     ),
// //                     TextSpan(text: 'ถูกต้องครบถ้วน'),
// //                   ],
// //                 ),
// //               ),
// //               content: Form(
// //                 key: _formKey,
// //                 child: Column(
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     SizedBox(
// //                       height: 30,
// //                     )
// //                     // RadioListTile<int>(
// //                     //   value: 2,
// //                     //   groupValue: selectedOption,
// //                     //   onChanged: (value) {
// //                     //     setState(() {
// //                     //       selectedOption = value!;
// //                     //       reasonController.clear();
// //                     //       reason = '';
// //                     //     });
// //                     //   },
// //                     //   title: const Text('เอกสารผ่านเกณฑ์ (โปรดระบุรายละเอียด)'),
// //                     // ),
// //                     // if (selectedOption == 2)
// //                     //   Padding(
// //                     //     padding: const EdgeInsets.symmetric(horizontal: 8.0),
// //                     //     child: TextFormField(
//                     //       controller: reasonController,
//                     //       maxLines: 2,
//                     //       // onChanged: (val) => setState(() => reason = val),
//                     //       // validator: (value) {
//                     //       //   if (value == null || value.isEmpty) {
//                     //       //     return 'กรุณากรอกข้อมูล';
//                     //       //   } else if (value.length < 10) {
//                     //       //     return 'กรุณากรอกอย่างน้อย 10 ตัวอักษร';
//                     //       //   }
//                     //       //   return null;
//                     //       // },
//                     //       decoration: const InputDecoration(
//                     //         hintText: 'รายละเอียด...',
//                     //         border: OutlineInputBorder(),
//                     //       ),
//                     //     ),
//                     //   ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('ยกเลิก'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () async {
//                     // if (_formKey.currentState!.validate()) {
//                     final attachments_Uuid = widget.uuid.toString();
//                     print(widget.uuid);
//                     final response = await Post_ReviewsAttachMents(
//                       staTus: status_list[selectedOption],
//                       requestUuid: widget.Request_Uuid,
//                       attachmentsUuid: attachments_Uuid,
//                       descripTion: reasonController.text.toString(),
//                       // role: ReviewsApprovalRoleType.doc_reviewer
//                     );
//                     if (response!.statusCode == 200 ||
//                         response!.statusCode == 201 ||
//                         response!.statusCode == 409) {
//                       Navigator.pop(context, reasonController.text);
//                       ResponseReviews = response.body;
//                       final resultxx =
//                           json.decode(ResponseReviews); // แปลงเป็น Map

// // หรือถ้าแน่ใจว่าเป็น bool อยู่แล้ว:
//                       final is_open_approved =
//                           resultxx['data']['is_open_approved'] ?? false;
//                       Navigator.pop(context, {
//                         'message': ResponseReviews,
//                         'isopenapproved': is_open_approved, // ✅ Safe
//                       });
//                       print('✅ Post Reviews Success: ${response.body}');
//                     } else {
//                       // print(
//                       //     '❌ Post Reviews Failed [${response.statusCode}]: ${response.body}');
//                       final jsonResponse =
//                           json.decode(response.body); // import 'dart:convert';
//                       Dialog_error(context, '${jsonResponse['message']}');
//                     }
//                     // Navigator.pop(context, reasonController.text);
//                     // }
//                   },
//                   child: const Text('ยืนยัน'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
// }
