// import 'dart:async';
// import 'dart:convert';
// import 'dart:html';

// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:chaoperty/ChiangMai_Municipality/unity/show_dialog_cmm.dart';
// import 'package:file_saver/file_saver.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
// import 'package:http/http.dart' as http;
// import '../../../Constant/Myconstant.dart';
// import '../../../Style/Translate.dart';
// import '../../../Style/colors.dart';
// import '../../Model/ReviewUuid_Model.dart';
// import '../../unity/API_admin_signature.dart';
// import '../../unity/API_requests_reviews.dart';
// import '../../unity/API_requests_reviewsflow.dart';
// import '../../unity/Enum.dart';
// import '../../unity/FormatDate.dart';
// import '../../unity/SecurePrefs_helper.dart';
// import 'unitypdf_cmm.dart';

// class PreviewPdfgenchecklist_CMM extends StatefulWidget {
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
//   List<RequiredDocument> docs;
//   final zn;
//   final ln;
//   PreviewPdfgenchecklist_CMM(
//       {Key? key,
//       // required this.doc,
//       this.renTal_name,
//       this.title,
//       this.id,
//       this.uuid,
//       this.Request_Uuid,
//       this.code,
//       this.file_path,
//       this.file_type,
//       this.file_typeOpen,
//       this.uploaded_At,
//       this.commentReviewer,
//       this.statusReviewer,
//       required this.docs,
//       this.zn,
//       this.ln})
//       : super(key: key);

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

//   @override
//   State<PreviewPdfgenchecklist_CMM> createState() =>
//       _PreviewPdfgenchecklist_CMMState();
// }

// class _PreviewPdfgenchecklist_CMMState
//     extends State<PreviewPdfgenchecklist_CMM> {
//   dynamic ResponseReviews;
//   Uint8List? Signature_user;
//   // String? Signature_user;
//   final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

//   final PdfViewerController _pdfController = PdfViewerController();

//   final TextEditingController _searchController = TextEditingController();

//   PdfTextSearchResult _searchResult = PdfTextSearchResult();

//   final PdfViewerController _pdfViewerController = PdfViewerController();

//   double _currentZoomLevel = 1.0;
//   final ValueNotifier<int> counter = ValueNotifier(0);
//   Timer? timer;
//   StreamController<int> counterStreamController =
//       StreamController<int>.broadcast();
//   String? ResponseMessageCheckList;
//   dynamic pdf = pw.Document();

//   dynamic widget_Signature;
//   Uint8List? _pdfBytes;
//   bool _isLoading = true;
//   String? _error;

//   @override
//   void initState() {
//     StoredAuthData();
//     super.initState();
//     loadPdfBytes();
//     // timer = Timer.periodic(Duration(seconds: 5), (_) {
//     //   print(DateTime.now()); // ดูว่าถี่แค่ไหน
//     //   counter.value++;
//     // });
//   }

//   @override
//   void dispose() {
//     timer?.cancel();
//     counter.dispose();
//     // counterStreamController.close(); // ✅ ปิดเมื่อหน้า widget ถูกทำลาย
//     super.dispose();
//   }

//   int _tick = 0;
//   void startTimer() {
//     timer?.cancel();
//     _tick = 0;
//     timer = Timer.periodic(Duration(seconds: 3), (_) {
//       _tick++;
//       counterStreamController.add(_tick); // ส่งค่าที่เปลี่ยนไปจริง
//       print('⏱ Timer tick $_tick at ${DateTime.now()}');
//     });
//   }

//   void stopTimer() {
//     timer?.cancel();
//     counterStreamController.close(); // ✅ ปิด stream
//     print('Timer stopped');
//   }

//   bool bool_type() {
//     return widget.file_typeOpen == 'ReviewsFile' &&
//         widget.statusReviewer == 'pending';
//   }

//   String fullNameAdmin = '',
//       positionAdmin = '',
//       proFileUuid = '',
//       sigNatureUuid = '';
//   Uint8List? signaturesUrl;
//   // String signaturesUrl = '';
//   Future<void> StoredAuthData() async {
//     final response = await read_AdminSignature();
//     final result = json.decode(response!.body);
//     final profileUuid = result['data']['profile_uuid'];
//     final profile = result['data']['profile'];
//     final signatureUuid = result['data']['signature_uuid'];
//     final positionName = result['data']['position_name'];

//     final accessToken =
//         await SecurePrefs.getDecrypted(SecurePrefsType.authAccessToken);
//     final userUuid =
//         await SecurePrefs.getDecrypted(SecurePrefsType.authUserUuid);
//     final userEmail =
//         await SecurePrefs.getDecrypted(SecurePrefsType.authUserEmail);
//     final userJson =
//         await SecurePrefs.getDecrypted(SecurePrefsType.authUserObject);

//     if (userJson != null) {
//       final Map<String, dynamic> userMap = jsonDecode(userJson);
//       final pretty = const JsonEncoder.withIndent('  ').convert(userMap);
//       // print(pretty);
//       // โหลดภาพลายเซ็นเป็น bytes
//       Uint8List? sigBytes;
//       if (signatureUuid != null && signatureUuid.isNotEmpty) {
//         final sigResp = await img_signatureUuid(signatureUuid: signatureUuid);
//         if (sigResp != null && sigResp.statusCode == 200) {
//           sigBytes = sigResp.bodyBytes;
//         } else {
//           debugPrint('❌ Failed to load signature image');
//         }
//       }
//       setState(() {
//         signaturesUrl = sigBytes;
//         // signaturesUrl = (result['data']['signature_uuid'] != null)
//         //     ?     '${MyConstant().domain_v1}/admin/users/signatures/${signatureUuid}/preview'
//         //     : '';
//         proFileUuid = profileUuid ?? '';
//         sigNatureUuid = signatureUuid ?? '';
//         fullNameAdmin = profile ?? '';
//         positionAdmin = positionName ?? '';
//         // fullNameAdmin = userMap['fname'] + ' ' + userMap['lname'] ?? '';
//         // positionAdmin = userMap['position'] ?? '';
//       });
//     } else {
//       print('(null)');
//     }
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

//   dynamic signatureWidget;
//   bool _submitting = false;
//   //////////----------------------->
//   @override
//   Widget build(BuildContext context) {
//     // final String pdfUrl =
//     //     '${MyConstant().domain_v1}/admin/requests/attachments/${widget.uuid}/preview';
//     List<RequiredDocument> data_check = widget.docs;
//     final widthx = MediaQuery.of(context).size.width > 600 ? 5 : 3;
//     final heightx = MediaQuery.of(context).size.height > 600 ? 4 : 2;
//     // Future<void> _printPDF() async {
//     //   final response = await http.get(Uri.parse(pdfUrl));
//     //   if (response.statusCode == 200) {
//     //     await Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
//     //       return response.bodyBytes;
//     //     });
//     //   } else {
//     //     ScaffoldMessenger.of(context).showSnackBar(
//     //       SnackBar(content: Text('❌ Failed to load PDF')),
//     //     );
//     //   }
//     // }

//     // Future<void> _savePDF() async {
//     //   final response = await http.get(Uri.parse(pdfUrl));
//     //   if (response.statusCode == 200) {
//     //     await Printing.sharePdf(
//     //       bytes: response.bodyBytes,
//     //       filename: 'downloaded_document.pdf',
//     //     );
//     //   }
//     // }

//     Future<void> _notSuccessFully() async {
//       Dialog_error(context, 'ไม่สามารถทำรายการนี้ได้');
//     }

//     if (Signature_user != null && Signature_user != '') {
//       // Step 1: Download image from URL
//       // final response = await http.get(Uri.parse(Signature_user));

//       // final signatureImage = pw.MemoryImage(response.bodyBytes);

//       // Step 3: Use in PDF
//       final sigProvider = (Signature_user == null)
//           ? null
//           : pw.MemoryImage(Signature_user!); // ✅ ห่อด้วย MemoryImage

//       signatureWidget = (sigProvider == null)
//           ? pw.SizedBox() // ไม่มีลายเซ็น → วางกล่องเปล่า
//           : pw.Container(
//               width: 120, // กำหนดกรอบลายเซ็น
//               height: 60,
//               decoration: pw.BoxDecoration(
//                 borderRadius: pw.BorderRadius.circular(8),
//               ),
//               child: pw.ClipRRect(
//                 horizontalRadius: 8,
//                 verticalRadius: 8,
//                 child: pw.FittedBox(
//                   fit: pw.BoxFit.contain,
//                   child: pw.Image(sigProvider), // ✅ ใช้ provider
//                 ),
//               ),
//             );
//     }
//     List<pw.Widget> buildChecklistSection(
//       pw.Font ttf,
//       pw.ImageProvider check,
//       pw.ImageProvider square,
//       String title,
//     ) {
//       return [
//         pw.SizedBox(
//           height: 0,
//         ),
//         pw.Align(
//           alignment: pw.Alignment.bottomRight,
//           child: pw.Text('[$title]',
//               style: pw.TextStyle(
//                   font: ttf, fontSize: 15, fontWeight: pw.FontWeight.bold)),
//         ),
//         pw.SizedBox(
//           height: 2,
//         ),
//         pw.Row(
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
//                     alignment: pw.Alignment.centerLeft,
//                     child: pw.Text('สำหรับเจ้าหน้าที่',
//                         style: pw.TextStyle(
//                             font: ttf,
//                             fontSize: 15,
//                             fontWeight: pw.FontWeight.bold)),
//                   ),
//                   pw.Align(
//                     alignment: pw.Alignment.centerLeft,
//                     child: pw.Text('ได้รับเอกสารประกอบคำขอต่ออายุใบอนุญาต',
//                         style: pw.TextStyle(
//                             font: ttf,
//                             fontSize: 15,
//                             fontWeight: pw.FontWeight.bold)),
//                   ),
//                   pw.Align(
//                     alignment: pw.Alignment.centerLeft,
//                     child: pw.Text('พื้นที่ผ่อนผันบริเวณ : ${widget.zn}',
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
//               child: pw.Container(
//                 decoration: pw.BoxDecoration(
//                   // color: AppbackgroundColor.TiTile_Colors.withOpacity(0.8),
//                   borderRadius: pw.BorderRadius.only(
//                       topLeft: pw.Radius.circular(3),
//                       topRight: pw.Radius.circular(3),
//                       bottomLeft: pw.Radius.circular(3),
//                       bottomRight: pw.Radius.circular(3)),
//                   border: pw.Border.all(color: PdfColors.black, width: 1),
//                 ),
//                 padding: pw.EdgeInsets.all(4.0),
//                 child: pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.center,
//                   mainAxisAlignment: pw.MainAxisAlignment.center,
//                   children: [
//                     pw.Align(
//                       alignment: pw.Alignment.center,
//                       child: pw.Text('ตรวจเอกสาร',
//                           style: pw.TextStyle(
//                               font: ttf,
//                               fontSize: 15,
//                               fontWeight: pw.FontWeight.bold)),
//                     ),
//                     pw.Row(
//                       children: [
//                         pw.Expanded(
//                           flex: 1,
//                           child: pw.Align(
//                             alignment: pw.Alignment.centerLeft,
//                             child: pw.Text('โซน : ${widget.zn}',
//                                 style: pw.TextStyle(
//                                     font: ttf,
//                                     fontSize: 15,
//                                     fontWeight: pw.FontWeight.bold)),
//                           ),
//                         ),
//                         pw.Expanded(
//                           flex: 1,
//                           child: pw.Align(
//                             alignment: pw.Alignment.centerLeft,
//                             child: pw.Text('พื้นที่ : ${widget.ln}',
//                                 style: pw.TextStyle(
//                                     font: ttf,
//                                     fontSize: 15,
//                                     fontWeight: pw.FontWeight.bold)),
//                           ),
//                         ),
//                       ],
//                     ),
//                     pw.Row(
//                       children: [
//                         pw.Expanded(
//                             flex: 1,
//                             child: pw.Row(
//                               crossAxisAlignment: pw.CrossAxisAlignment.center,
//                               children: [
//                                 pw.Image(
//                                   check,
//                                   width: 15,
//                                   height: 15,
//                                 ),
//                                 pw.Align(
//                                   alignment: pw.Alignment.centerLeft,
//                                   child: pw.Text('ผ่าน',
//                                       style: pw.TextStyle(
//                                           font: ttf,
//                                           fontSize: 15,
//                                           fontWeight: pw.FontWeight.bold)),
//                                 ),
//                               ],
//                             )),
//                         pw.Expanded(
//                             flex: 1,
//                             child: pw.Row(
//                               crossAxisAlignment: pw.CrossAxisAlignment.center,
//                               children: [
//                                 pw.Image(
//                                   square,
//                                   width: 15,
//                                   height: 15,
//                                 ),
//                                 pw.Align(
//                                   alignment: pw.Alignment.centerLeft,
//                                   child: pw.Text('ไม่ผ่าน',
//                                       style: pw.TextStyle(
//                                           font: ttf,
//                                           fontSize: 15,
//                                           fontWeight: pw.FontWeight.bold)),
//                                 ),
//                               ],
//                             )),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//         // pw.Text(title,
//         //     style: pw.TextStyle(
//         //         font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
//         pw.SizedBox(height: 10),
//         pw.Align(
//           alignment: pw.Alignment.centerRight,
//           child: pw.Text('ทำที่ สำนักงานเทศบาลนครเชียงใหม่',
//               style: pw.TextStyle(
//                   font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
//         ),
//         for (int i = 0; i < data_check.length; i += 2)
//           pw.Padding(
//             padding: pw.EdgeInsets.all(4.0),
//             child: pw.Row(
//               children: [
//                 pw.Expanded(
//                   child: pw.Row(
//                     children: [
//                       pw.Image(
//                         (data_check[i].attachment?.fileName?.isNotEmpty ??
//                                 false)
//                             ? check
//                             : square,
//                         width: 15,
//                         height: 15,
//                       ),
//                       pw.SizedBox(width: 2),
//                       Textx(
//                         value: data_check[i].document.nameTh ?? '',
//                         font: ttf,
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (i + 1 < data_check.length)
//                   pw.Expanded(
//                     child: pw.Row(
//                       children: [
//                         pw.Image(
//                           (data_check[i + 1].attachment?.fileName?.isNotEmpty ??
//                                   false)
//                               ? check
//                               : square,
//                           width: 15,
//                           height: 15,
//                         ),
//                         pw.SizedBox(width: 2),
//                         Textx(
//                           value: data_check[i + 1].document.nameTh ?? '',
//                           font: ttf,
//                         ),
//                       ],
//                     ),
//                   )
//                 else
//                   pw.Expanded(child: pw.Container()),
//               ],
//             ),
//           ),
//         pw.SizedBox(height: 20),
//         pw.Align(
//           alignment: pw.Alignment.centerRight,
//           child: pw.Column(children: [
//             pw.SizedBox(
//               width: 80,
//               height: 40,
//               child: (Signature_user == null || Signature_user == '')
//                   ? null
//                   : signatureWidget,
//             ),
//             if (widget_Signature != null) widget_Signature,
//             Textx_mini(value: '(ลงชื่อ) $fullNameAdmin', font: ttf),
//             Textx_mini(value: '$positionAdmin', font: ttf),
//           ]),
//         ),
//         pw.SizedBox(height: 20),
//       ];
//     }

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         appBar: AppBar(
//           backgroundColor: AppBarColors.hexColor,
//           leading: IconButton(
//             onPressed: () {
//               Navigator.pop(context, {
//                 // 'status': true,
//                 'message': ResponseMessageCheckList,
//                 // 'data': {
//                 //   'id': 1,
//                 //   'name': '$fullNameAdmin',
//                 //   'position': '$positionAdmin',
//                 //   'signature': '$Signature_user'
//                 // }
//               });

//               // Navigator.pop(context);
//             },
//             icon: const Icon(
//               Icons.arrow_back_outlined,
//               color: Colors.white,
//             ),
//           ),
//           centerTitle: true,
//           title: Text(
//             "${widget.title}",
//             style: const TextStyle(
//               color: Colors.white,
//               fontFamily: Font_.Fonts_T,
//             ),
//           ),
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: (widget.uuid == '' || widget.uuid == null)
//                   ? Stack(children: [
//                       // StreamBuilder<int>(
//                       //   stream: counterStreamController.stream,
//                       //   builder: (context, snapshot) {
//                       //     return
//                       PdfPreview(
//                         key: _pdfViewerKey,
//                         // build: (format) => widget.doc.save(),
//                         build: (PdfPageFormat format) async {
//                           final pdfx = pw.Document(); // ✅ ต้องประกาศที่นี่

//                           final ttf = await font1();

//                           final imageCheck =
//                               await rootBundle.load('images/check1.png');
//                           final imageSquare =
//                               await rootBundle.load('images/square3.png');

//                           final check =
//                               pw.MemoryImage(imageCheck.buffer.asUint8List());
//                           final square =
//                               pw.MemoryImage(imageSquare.buffer.asUint8List());

//                           pdfx.addPage(
//                             pw.MultiPage(
//                               pageFormat: PdfPageFormat.a4.copyWith(
//                                 marginBottom: 18.00,
//                                 marginLeft: 18.00,
//                                 marginRight: 18.00,
//                                 marginTop: 18.00,
//                               ),
//                               build: (context) => [
//                                 ...buildChecklistSection(
//                                     ttf, check, square, 'ต้นฉบับ'),
//                                 pw.Divider(),
//                                 ...buildChecklistSection(
//                                     ttf, check, square, 'สำเนา'),
//                               ],
//                             ),
//                           );
//                           setState(() {
//                             pdf = pdfx;
//                           });
//                           return pdfx.save();
//                         },

//                         allowSharing: false,
//                         allowPrinting: false, canDebug: false,
//                         canChangeOrientation: false,
//                         canChangePageFormat: false,
//                         maxPageWidth: MediaQuery.of(context).size.width * 0.6,
//                         // scrollViewDecoration:,
//                         initialPageFormat: PdfPageFormat.a4,
//                         pdfFileName: "${widget.title}.pdf",
//                         //   )
//                         //   ;
//                         // },
//                       ), // 🔽 ลายน้ำแบบ Overlay
//                       IgnorePointer(
//                         child: LayoutBuilder(
//                           builder: (context, constraints) {
//                             final width = constraints.maxWidth;
//                             final height = constraints.maxHeight;

//                             List<Widget> watermarks = [];

//                             for (double y = 0;
//                                 y < height;
//                                 y += height / heightx) {
//                               for (double x = 0;
//                                   x < width;
//                                   x += width / widthx) {
//                                 watermarks.add(Positioned(
//                                   left: x,
//                                   top: y,
//                                   child: Transform.rotate(
//                                     angle: -0.4, // ประมาณ -22 องศา
//                                     child: Opacity(
//                                       opacity: 0.08,
//                                       child: Text(
//                                         'Chaoperty',
//                                         style: TextStyle(
//                                           fontSize: 40,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.black.withOpacity(0.8),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ));
//                               }
//                             }

//                             return Stack(children: watermarks);
//                           },
//                         ),
//                       ),
//                     ])
//                   : Stack(
//                       children: [
//                         // SfPdfViewer.network(
//                         //   pdfUrl,
//                         SfPdfViewer.memory(
//                           _pdfBytes!,
//                           key: _pdfViewerKey,
//                           controller: _pdfViewerController,
//                           enableDocumentLinkAnnotation: false,
//                           canShowScrollHead: false,
//                           canShowScrollStatus: false,
//                           pageLayoutMode: PdfPageLayoutMode.continuous,
//                           enableDoubleTapZooming: true,
//                           onZoomLevelChanged: (details) {
//                             setState(() {
//                               _currentZoomLevel = details.newZoomLevel;
//                             });
//                           },
//                         ),
//                         // 🔽 ลายน้ำแบบ Overlay
//                         IgnorePointer(
//                           child: LayoutBuilder(
//                             builder: (context, constraints) {
//                               final width = constraints.maxWidth;
//                               final height = constraints.maxHeight;

//                               List<Widget> watermarks = [];

//                               for (double y = 0;
//                                   y < height;
//                                   y += height / heightx) {
//                                 for (double x = 0;
//                                     x < width;
//                                     x += width / widthx) {
//                                   watermarks.add(Positioned(
//                                     left: x,
//                                     top: y,
//                                     child: Transform.rotate(
//                                       angle: -0.4, // ประมาณ -22 องศา
//                                       child: Opacity(
//                                         opacity: 0.08,
//                                         child: Text(
//                                           'Chaoperty',
//                                           style: TextStyle(
//                                             fontSize: 40,
//                                             fontWeight: FontWeight.bold,
//                                             color:
//                                                 Colors.black.withOpacity(0.8),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ));
//                                 }
//                               }

//                               return Stack(children: watermarks);
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//             ),
//             Container(
//               color: Colors.grey[200],
//               child: Row(
//                 children: [
//                   Expanded(
//                       child: Row(
//                     children: [
//                       SizedBox(
//                         width: 20,
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.print),
//                         onPressed: (widget.uuid == '' || widget.uuid == null)
//                             ? _notSuccessFully
//                             : _printPDF,
//                         // (widget.file_typeOpen.toString() == 'SuccessFully')
//                         //     ? _printPDF
//                         //     : _notSuccessFully,
//                         tooltip: 'Print PDF',
//                       ),
//                       SizedBox(
//                         width: 10,
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.save_alt),
//                         onPressed: (widget.uuid == '' || widget.uuid == null)
//                             ? _notSuccessFully
//                             : _savePDF,
//                         // (widget.file_typeOpen.toString() == 'SuccessFully')
//                         //     ? _savePDF
//                         //     : _notSuccessFully,
//                         tooltip: 'Save PDF',
//                       ),
//                       SizedBox(
//                         width: 10,
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.zoom_in),
//                         onPressed: () {
//                           setState(() {
//                             _currentZoomLevel += 0.25;
//                             if (_currentZoomLevel > 3.0)
//                               _currentZoomLevel = 3.0;
//                             _pdfViewerController.zoomLevel = _currentZoomLevel;
//                           });
//                         },
//                       ),
//                       SizedBox(
//                         width: 10,
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.zoom_out),
//                         onPressed: () {
//                           setState(() {
//                             _currentZoomLevel -= 0.25;
//                             if (_currentZoomLevel < 1.0)
//                               _currentZoomLevel = 1.0;
//                             _pdfViewerController.zoomLevel = _currentZoomLevel;
//                           });
//                         },
//                       ),
//                       SizedBox(
//                         width: 10,
//                       ),
//                     ],
//                   )),
//                   if (widget.uuid == '' || widget.uuid == null)
//                     Padding(
//                       padding: const EdgeInsets.all(4.0),
//                       child: Translate.TranslateAndSet_TextAutoSize(
//                           '*โปรดตรวจสอบความถูกต้องของเอกสารก่อนกดยืนยัน',
//                           CustomerScreen_Color.Colors_Text2_,
//                           TextAlign.center,
//                           null,
//                           Font_.Fonts_T,
//                           10,
//                           14,
//                           1),
//                     ),
//                   if (widget.uuid == '' || widget.uuid == null)
//                     Padding(
//                       padding: const EdgeInsets.all(4.0),
//                       child: Container(
//                         width: 160,
//                         child: Center(
//                           child: ElevatedButton(
//                             style: ButtonStyle(
//                               backgroundColor: MaterialStateProperty.all<Color>(
//                                 Colors.grey.shade400,
//                               ),
//                             ),
//                             onPressed: () async {
//                               startTimer();
//                               Cancel_showDialog(context);
//                             },
//                             child: Translate.TranslateAndSet_TextAutoSize(
//                                 'ลงชื่อ/ประทับลายเซ็น',
//                                 CustomerScreen_Color.Colors_Text2_,
//                                 TextAlign.center,
//                                 null,
//                                 Font_.Fonts_T,
//                                 10,
//                                 14,
//                                 1),
//                           ),
//                         ),
//                       ),
//                     ),
//                   if (widget.uuid == '' || widget.uuid == null)
//                     Padding(
//                       padding: const EdgeInsets.all(4.0),
//                       child: Container(
//                         width: 160,
//                         child: Center(
//                           child: ElevatedButton(
//                             style: ButtonStyle(
//                               backgroundColor: MaterialStateProperty.all<Color>(
//                                 Colors.grey.shade900,
//                               ),
//                             ),
//                             onPressed: () async {
//                               Approved_showDialog(context);
//                             },
//                             child: Translate.TranslateAndSet_TextAutoSize(
//                                 'อัพโหลดเอกสารฉบับนี้',
//                                 CustomerScreen_Color.Colors_Text3_,
//                                 TextAlign.center,
//                                 null,
//                                 Font_.Fonts_T,
//                                 10,
//                                 14,
//                                 1),
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
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
//                       text: 'เอกสารผ่านเกณฑ์ ',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     TextSpan(
//                         text: 'ท่านต้องการลงชื่อประทับลายเซ็นเอกสารหรือไม่'),
//                   ],
//                 ),
//               ),
//               content: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     SizedBox(
//                       width: 400,
//                       height: 450,
//                       child: Column(
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.only(
//                                     topLeft: Radius.circular(10),
//                                     topRight: Radius.circular(10),
//                                     bottomLeft: Radius.circular(10),
//                                     bottomRight: Radius.circular(10)),
//                                 border:
//                                     Border.all(color: Colors.grey, width: 1),
//                               ),
//                               child: Column(
//                                 children: [
//                                   Container(
//                                     height: 150,
//                                     width: 200,
//                                     padding: const EdgeInsets.all(2.0),
//                                     child: ClipRRect(
//                                       borderRadius: const BorderRadius.only(
//                                         topLeft: Radius.circular(8.0),
//                                         topRight: Radius.circular(8.0),
//                                         bottomLeft: Radius.circular(8.0),
//                                         bottomRight: Radius.circular(8.0),
//                                       ),
//                                       child: (Signature_user == null)
//                                           ? const SizedBox()
//                                           : FittedBox(
//                                               fit: BoxFit.cover,
//                                               child: Image.memory(
//                                                 Signature_user!,
//                                                 height: 180,
//                                               ),
//                                             ),
//                                       //                         (Signature_user == null ||
//                                       //     Signature_user == '')
//                                       // ? null
//                                       // : ClipRRect(
//                                       //     borderRadius:
//                                       //         BorderRadius.circular(8.0),
//                                       //     child: FittedBox(
//                                       //       fit: BoxFit.cover,
//                                       //       child: Image.network(
//                                       //         '$Signature_user',
//                                       //         height: 180,
//                                       //       ),
//                                       //     ),
//                                       //   ),
//                                     ),
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.only(
//                                           topLeft: Radius.circular(0),
//                                           topRight: Radius.circular(0),
//                                           bottomLeft: Radius.circular(0),
//                                           bottomRight: Radius.circular(0)),
//                                     ),
//                                   ),
//                                   Container(
//                                     decoration: const BoxDecoration(
//                                       color: AppbackgroundColor.Abg_Colors,
//                                       borderRadius: BorderRadius.only(
//                                           topLeft: Radius.circular(0),
//                                           topRight: Radius.circular(0),
//                                           bottomLeft: Radius.circular(10),
//                                           bottomRight: Radius.circular(10)),
//                                       // border: Border.all(color: Colors.grey, width: 1),
//                                     ),
//                                     child: Row(
//                                       children: <Widget>[
//                                         TextButton(
//                                           child: AutoSizeText(
//                                             minFontSize: 12,
//                                             maxFontSize: 16,
//                                             maxLines: 1,
//                                             'ประทับลายเซ็น',
//                                             textAlign: TextAlign.left,
//                                             overflow: TextOverflow.ellipsis,
//                                             style: TextStyle(
//                                                 color: Colors.blueGrey,
//                                                 fontFamily: Font_.Fonts_T),
//                                           ),
//                                           onPressed: () async {
//                                             final ttf = await font1();
//                                             setState(() {
//                                               Signature_user = signaturesUrl;
//                                               // 'https://i0.wp.com/www.iurban.in.th/wp-content/uploads/2010/06/signature2.jpg?w=770&ssl=1';
//                                             });
//                                             dynamic widget_Signaturex =
//                                                 await Signature_PDF(
//                                               value: '',
//                                               font: ttf,
//                                               height: 50,
//                                               width: 150,
//                                               imageBytes: Signature_user,
//                                               // signatureImageUrl:
//                                               //     Signature_user, // ✅ ใช้ URL ที่สมบูรณ์
//                                             );
//                                             setState(() {
//                                               _pdfViewerKey.currentState;
//                                             });
//                                           },
//                                           // onPressed: () async {
//                                           //   final ttf = await font1();
//                                           //   setState(() {
//                                           //     Signature_user = signaturesUrl;
//                                           //     // 'https://i0.wp.com/www.iurban.in.th/wp-content/uploads/2010/06/signature2.jpg?w=770&ssl=1';
//                                           //   });

//                                           //   // dynamic widget_Signaturex =
//                                           //   //     await Signature_PDF(
//                                           //   //   value: '',
//                                           //   //   font: ttf,
//                                           //   //   height: 50,
//                                           //   //   width: 150,
//                                           //   //   signatureImageUrl:
//                                           //   //       Signature_user, // ✅ ใช้ URL ที่สมบูรณ์
//                                           //   // );
//                                           //   setState(() {
//                                           //     // widget_Signature =
//                                           //     //     widget_Signaturex;
//                                           //     _pdfViewerKey.currentState;
//                                           //   });
//                                           // },
//                                         ),
//                                         TextButton(
//                                           child: Padding(
//                                             padding: const EdgeInsets.all(8.0),
//                                             child: AutoSizeText(
//                                               minFontSize: 12,
//                                               maxFontSize: 16,
//                                               maxLines: 1,
//                                               'ยกเลิกลายเซ็น',
//                                               textAlign: TextAlign.left,
//                                               overflow: TextOverflow.ellipsis,
//                                               style: TextStyle(
//                                                   color: Colors.blueGrey,
//                                                   fontFamily: Font_.Fonts_T),
//                                             ),
//                                           ),
//                                           onPressed: () async {
//                                             setState(() {
//                                               widget_Signature = null;
//                                               Signature_user = null;
//                                               _pdfViewerKey.currentState;
//                                             });
//                                           },
//                                         ),
//                                       ],
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceEvenly,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           for (int index = 0; index < 2; index++)
//                             SizedBox(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: AutoSizeText(
//                                       minFontSize: 12,
//                                       maxFontSize: 16,
//                                       maxLines: 1,
//                                       (index == 0)
//                                           ? 'ชื่อผู้ตรวจสอบเอกสาร'
//                                           : 'ชื่อตำแหน่ง',
//                                       textAlign: TextAlign.left,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: TextStyle(
//                                           color: PeopleChaoScreen_Color
//                                               .Colors_Text2_,
//                                           fontFamily: Font_.Fonts_T),
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.all(2.0),
//                                     child: TextFormField(
//                                       readOnly: true,
//                                       keyboardType: TextInputType.number,
//                                       // controller: Formbecause_,
//                                       initialValue: (index == 0)
//                                           ? '$fullNameAdmin'
//                                           : '$positionAdmin',
//                                       validator: (value) {
//                                         if (value == null || value.isEmpty) {
//                                           return 'ใส่ข้อมูลให้ครบถ้วน ';
//                                         }
//                                         // if (int.parse(value.toString()) < 13) {
//                                         //   return '< 13';
//                                         // }
//                                         return null;
//                                       },
//                                       onChanged: (value) {
//                                         // setState(() {
//                                         //   Formbecause_.text =
//                                         //       value.toString();
//                                         // });
//                                       },
//                                       maxLines: 1,
//                                       cursorColor: Colors.green,
//                                       decoration: InputDecoration(
//                                           fillColor:
//                                               Colors.white.withOpacity(0.3),
//                                           filled: true,
//                                           // prefixIcon: const Icon(Icons.water,
//                                           //     color: Colors.blue),
//                                           // suffixIcon: Icon(Icons.clear, color: Colors.black),
//                                           focusedBorder:
//                                               const OutlineInputBorder(
//                                             borderRadius: BorderRadius.all(
//                                                 Radius.circular(8)),
//                                             borderSide: BorderSide(
//                                               width: 1,
//                                               color: Colors.black,
//                                             ),
//                                           ),
//                                           enabledBorder:
//                                               const OutlineInputBorder(
//                                             borderRadius: BorderRadius.all(
//                                                 Radius.circular(8)),
//                                             borderSide: BorderSide(
//                                               width: 1,
//                                               color: Colors.grey,
//                                             ),
//                                           ),
//                                           // labelText: 'คำอธิบาย',
//                                           labelStyle: const TextStyle(
//                                             color: ManageScreen_Color
//                                                 .Colors_Text2_,
//                                             // fontWeight:
//                                             //     FontWeight.bold,
//                                             fontFamily: Font_.Fonts_T,
//                                           )),
//                                       // inputFormatters: <TextInputFormatter>[
//                                       //   // for below version 2 use this
//                                       //   FilteringTextInputFormatter.allow(
//                                       //       RegExp(r'[0-9]')),
//                                       //   // for version 2 and greater youcan also use this
//                                       //   FilteringTextInputFormatter.digitsOnly
//                                       // ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                         ],
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     stopTimer();

//                     Navigator.pop(context);
//                   },
//                   child: const Text('ยกเลิก'),
//                 ),
//                 ElevatedButton(
//                   onPressed: Signature_user == null
//                       ? null
//                       : () async {
//                           stopTimer();

//                           Navigator.pop(context);
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

//   Future<void> Approved_showDialog(
//     BuildContext context,
//   ) async {
//     int selectedOption = 2;
//     TextEditingController reasonController = TextEditingController();
//     final _formKey = GlobalKey<FormState>();
//     String reason = '';
//     List status_list = ['needs_update', 'rejected', 'approved'];
//     setState(() {
//       reasonController.text = 'เอกสารนี้ถูกต้องผ่านเกณฑ์แล้ว';
//     });
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
//                       text: 'เอกสารผ่านเกณฑ์ ',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     TextSpan(text: 'ถูกต้องครบถ้วน'),
//                   ],
//                 ),
//               ),
//               content: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // SizedBox(
//                     //   height: 20,
//                     // )
//                     RadioListTile<int>(
//                       value: 2,
//                       groupValue: selectedOption,
//                       onChanged: (value) {
//                         setState(() {
//                           selectedOption = value!;
//                           reasonController.clear();
//                           reason = '';
//                         });
//                       },
//                       title: const Text('เอกสารผ่านเกณฑ์ (โปรดระบุรายละเอียด)'),
//                     ),
//                     if (selectedOption == 2)
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                         child: TextFormField(
//                           controller: reasonController,
//                           maxLines: 2,
//                           // onChanged: (val) => setState(() => reason = val),
//                           // validator: (value) {
//                           //   if (value == null || value.isEmpty) {
//                           //     return 'กรุณากรอกข้อมูล';
//                           //   } else if (value.length < 10) {
//                           //     return 'กรุณากรอกอย่างน้อย 10 ตัวอักษร';
//                           //   }
//                           //   return null;
//                           // },
//                           decoration: const InputDecoration(
//                             hintText: 'รายละเอียด...',
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
//                   onPressed: () async {
//                     if (_submitting) return;
//                     setState(() => _submitting = true);

//                     try {
//                       final bytes = await pdf.save();
//                       final data = Uint8List.fromList(bytes);

//                       final resp = await Post_ReviewsCheckListCommit(
//                         requestUuid: widget.Request_Uuid.toString(),
//                         profileUuid: proFileUuid.toString(),
//                         signatureUuid: sigNatureUuid.toString(),
//                         staTus: 'approved',
//                         documentId: widget.id.toString(),
//                         file: data,
//                       );

//                       if (resp == null) {
//                         await Dialog_error(context,
//                             'ไม่พบการตอบกลับจากเซิร์ฟเวอร์'); // ปิดเฉพาะ dialog ภายใน
//                         return; // ไม่ pop หน้าเดิม
//                       }

//                       final body = json.decode(resp.body);
//                       final message =
//                           body['message']?.toString() ?? 'No message';

//                       if (resp.statusCode == 201 || resp.statusCode == 409) {
//                         setState(() => ResponseMessageCheckList = message);

//                         // 1) ปิด dialog success
//                         // await Dialog_success(context, message);

//                         // 2) ปิด "หน้าปัจจุบัน" แค่ครั้งเดียว พร้อมผลลัพธ์
//                         if (!mounted) return;
//                         Navigator.pop(context, ResponseReviews);
//                         Navigator.of(context).pop({
//                           'status': true,
//                           'message': message,
//                         });
//                       } else {
//                         // await Dialog_error(context, message);
//                         if (!mounted) return;
//                         Navigator.pop(context, ResponseReviews);
//                         await Dialog_error(context, message);
//                         // Navigator.of(context).pop({
//                         //   'status': false,
//                         //   'message': message,
//                         // });
//                       }
//                     } catch (e, st) {
//                       Navigator.pop(context, ResponseReviews);
//                       print('❌ $e\n$st');
//                       await Dialog_error(
//                           context, 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง');
//                       // ไม่ pop หน้าปัจจุบันเพิ่ม ถ้าไม่ต้องการ
//                     } finally {
//                       if (mounted) setState(() => _submitting = false);
//                     }
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
