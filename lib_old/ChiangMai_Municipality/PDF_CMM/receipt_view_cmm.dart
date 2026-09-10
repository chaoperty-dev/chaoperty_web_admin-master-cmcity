import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaoperty/ChiangMai_Municipality/unity/show_dialog_cmm.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;
import '../../../Constant/Myconstant.dart';
import '../../../Style/Translate.dart';
import '../../../Style/colors.dart';

import '../Model/AutoExpTrans_ModelCMM.dart';
import '../Model/ReviewUuid_Model.dart';
import '../unity/API_admin_signature.dart';
import '../unity/API_requests_reviews.dart';
import '../unity/API_requests_reviewsflow.dart';
import '../unity/SecurePrefs_helper.dart';

class PreviewPdfgencreceiptView_CMM extends StatefulWidget {
  // final pw.Document doc;
  // final renTal_name;
  final title;

  // final id;
  final uuid;
  // final Request_Uuid;
  // final code;
  // final file_path;
  // final file_type;
  // final file_typeOpen;
  // final uploaded_At;
  // final commentReviewer;
  // final statusReviewer;
  List<ReviewDetail> reviewDetail;
  // final zn;
  // final ln;
  PreviewPdfgencreceiptView_CMM({
    Key? key,
    // required this.doc,
    // this.renTal_name,
    this.title,
    // this.id,
    this.uuid,
    // this.Request_Uuid,
    // this.code,
    // this.file_path,
    // this.file_type,
    // this.file_typeOpen,
    // this.uploaded_At,
    // this.commentReviewer,
    // this.statusReviewer,
    required this.reviewDetail,
    // this.zn,
    // this.ln
  }) : super(key: key);

  static const customSwatch = MaterialColor(
    0xFF8DB95A,
    <int, Color>{
      50: Color(0xFFC2FD7F),
      100: Color(0xFFB6EE77),
      200: Color(0xFFB2E875),
      300: Color(0xFFACDF71),
      400: Color(0xFFA7DA6E),
      500: Color(0xFFA1D16A),
      600: Color(0xFF94BF62),
      700: Color(0xFF90B961),
      800: Color(0xFF85AB5A),
      900: Color(0xFF7A9B54),
    },
  );

  @override
  State<PreviewPdfgencreceiptView_CMM> createState() =>
      _PreviewPdfgenchecklist_CMMState();
}

class _PreviewPdfgenchecklist_CMMState
    extends State<PreviewPdfgencreceiptView_CMM> {
  dynamic ResponseReviews;
  String? Signature_user;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  final PdfViewerController _pdfController = PdfViewerController();

  final TextEditingController _searchController = TextEditingController();

  PdfTextSearchResult _searchResult = PdfTextSearchResult();

  final PdfViewerController _pdfViewerController = PdfViewerController();

  double _currentZoomLevel = 1.0;
  final ValueNotifier<int> counter = ValueNotifier(0);
  Timer? timer;
  StreamController<int> counterStreamController =
      StreamController<int>.broadcast();
  String? ResponseMessageCheckList;
  dynamic pdf = pw.Document();

  dynamic widget_Signature;
  Uint8List? _pdfBytes;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    StoredAuthData();
    super.initState();
    loadPdfBytes();
    // timer = Timer.periodic(Duration(seconds: 5), (_) {
    //   print(DateTime.now()); // ดูว่าถี่แค่ไหน
    //   counter.value++;
    // });
  }

  @override
  void dispose() {
    timer?.cancel();
    counter.dispose();
    counterStreamController.close(); // ✅ ปิดเมื่อหน้า widget ถูกทำลาย
    super.dispose();
  }

  int _tick = 0;
  void startTimer() {
    timer?.cancel();
    _tick = 0;
    timer = Timer.periodic(Duration(seconds: 3), (_) {
      _tick++;
      counterStreamController.add(_tick); // ส่งค่าที่เปลี่ยนไปจริง
      // print('⏱ Timer tick $_tick at ${DateTime.now()}');
    });
  }

  void stopTimer() {
    timer?.cancel();
    counterStreamController.close(); // ✅ ปิด stream
    // print('Timer stopped');
  }

  String fullNameAdmin = '',
      positionAdmin = '',
      proFileUuid = '',
      sigNatureUuid = '';
  String signaturesUrl = '';
  Future<void> StoredAuthData() async {
    final response = await read_AdminSignature();
    final result = json.decode(response!.body);
    final profileUuid = result['data']['profile_uuid'];
    final profile = result['data']['profile'];
    final signatureUuid = result['data']['signature_uuid'];
    final positionName = result['data']['position_name'];

    final accessToken =
        await SecurePrefs.getDecrypted(SecurePrefsType.authAccessToken);
    final userUuid =
        await SecurePrefs.getDecrypted(SecurePrefsType.authUserUuid);
    final userEmail =
        await SecurePrefs.getDecrypted(SecurePrefsType.authUserEmail);
    final userJson =
        await SecurePrefs.getDecrypted(SecurePrefsType.authUserObject);

    if (userJson != null) {
      final Map<String, dynamic> userMap = jsonDecode(userJson);
      final pretty = const JsonEncoder.withIndent('  ').convert(userMap);
      // print(pretty);
      // โหลดภาพลายเซ็นเป็น bytes
      Uint8List? sigBytes;
      if (signatureUuid != null && signatureUuid.isNotEmpty) {
        final sigResp = await img_signatureUuid(signatureUuid: signatureUuid);
        if (sigResp != null && sigResp.statusCode == 200) {
          sigBytes = sigResp.bodyBytes;
        } else {
          debugPrint('❌ Failed to load signature image');
        }
      }
      setState(() {
        // signaturesUrl = (result['data']['signature_uuid'] != null)
        //     ?     '${MyConstant().domain_v1}/admin/users/signatures/${signatureUuid}/preview'
        //     : '';
        proFileUuid = profileUuid ?? '';
        sigNatureUuid = signatureUuid ?? '';
        fullNameAdmin = profile ?? '';
        positionAdmin = positionName ?? '';
        // fullNameAdmin = userMap['fname'] + ' ' + userMap['lname'] ?? '';
        // positionAdmin = userMap['position'] ?? '';
      });
    } else {
      //   print('(null)');
    }
  }

  Future<void> loadPdfBytes() async {
    final response = await pdfimg_ReviewsFlow(attachmentUuid: widget.uuid);
    if (response != null && response.statusCode == 200) {
      setState(() {
        _pdfBytes = response.bodyBytes;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = 'โหลด PDF ไม่สำเร็จ';
        _isLoading = false;
      });
    }
  }

  Future<void> _printPDF() async {
    if (_pdfBytes == null) return;

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => _pdfBytes!,
    );
  }

  Future<void> _savePDF() async {
    if (_pdfBytes == null) return;

    await Printing.sharePdf(
      bytes: _pdfBytes!,
      filename: 'downloaded_document.pdf',
    );
  }

  //////////----------------------->
  @override
  Widget build(BuildContext context) {
    final widthx = MediaQuery.of(context).size.width > 600 ? 5 : 3;
    final heightx = MediaQuery.of(context).size.height > 600 ? 4 : 2;

    Future<void> _notSuccessFully() async {
      Dialog_error(context, 'ไม่สามารถทำรายการนี้ได้');
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: AppBarColors.hexColor,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context, {
                // 'status': true,
                'message': ResponseMessageCheckList,
                // 'data': {
                //   'id': 1,
                //   'name': '$fullNameAdmin',
                //   'position': '$positionAdmin',
                //   'signature': '$Signature_user'
                // }
              });

              // Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_outlined,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          title: Text(
            "${widget.title}",
            style: const TextStyle(
              color: Colors.white,
              fontFamily: Font_.Fonts_T,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // SfPdfViewer.network(
                  //   pdfUrl,
                  SfPdfViewer.memory(
                    _pdfBytes!,
                    key: _pdfViewerKey,
                    controller: _pdfViewerController,
                    enableDocumentLinkAnnotation: false,
                    canShowScrollHead: false,
                    canShowScrollStatus: false,
                    pageLayoutMode: PdfPageLayoutMode.continuous,
                    enableDoubleTapZooming: true,
                    onZoomLevelChanged: (details) {
                      setState(() {
                        _currentZoomLevel = details.newZoomLevel;
                      });
                    },
                  ),
                  // 🔽 ลายน้ำแบบ Overlay
                  IgnorePointer(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final height = constraints.maxHeight;

                        List<Widget> watermarks = [];

                        for (double y = 0; y < height; y += height / heightx) {
                          for (double x = 0; x < width; x += width / widthx) {
                            watermarks.add(Positioned(
                              left: x,
                              top: y,
                              child: Transform.rotate(
                                angle: -0.4, // ประมาณ -22 องศา
                                child: Opacity(
                                  opacity: 0.08,
                                  child: Text(
                                    'Chaoperty',
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                              ),
                            ));
                          }
                        }

                        return Stack(children: watermarks);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              // width: calculatedWidth,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.indigo[400],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0)),
              ),
              // color: Colors.grey[200],
              child: Row(
                children: [
                  Expanded(
                      child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.print,
                          size: 30,
                        ),
                        onPressed: (widget.uuid == '' || widget.uuid == null)
                            ? _notSuccessFully
                            : _printPDF,
                        // (widget.file_typeOpen.toString() == 'SuccessFully')
                        //     ? _printPDF
                        //     : _notSuccessFully,
                        tooltip: 'Print PDF',
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.save_alt,
                          size: 30,
                        ),
                        onPressed: (widget.uuid == '' || widget.uuid == null)
                            ? _notSuccessFully
                            : _savePDF,
                        // (widget.file_typeOpen.toString() == 'SuccessFully')
                        //     ? _savePDF
                        //     : _notSuccessFully,
                        tooltip: 'Save PDF',
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.zoom_in,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            _currentZoomLevel += 0.25;
                            if (_currentZoomLevel > 3.0)
                              _currentZoomLevel = 3.0;
                            _pdfViewerController.zoomLevel = _currentZoomLevel;
                          });
                        },
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.zoom_out,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            _currentZoomLevel -= 0.25;
                            if (_currentZoomLevel < 1.0)
                              _currentZoomLevel = 1.0;
                            _pdfViewerController.zoomLevel = _currentZoomLevel;
                          });
                        },
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
