import 'dart:convert';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../Style/Translate.dart';
import '../../../Style/colors.dart';
import '../../Model/ReviewUuid_Model.dart';
import '../../unity/API_admin_signature.dart';
import '../../unity/API_requests_reviews.dart';
import '../../unity/API_requests_reviewsflow.dart';
import '../../unity/SecurePrefs_helper.dart';
import '../../unity/show_dialog_cmm.dart';
import 'unitypdf_cmm.dart';

// ─── Top-level: runs in isolate (no platform channels) ────────────────────────
Future<Uint8List> _computeChecklistPdf(Map<String, dynamic> args) async {
  final fontBytes = args['font'] as Uint8List;
  final checkBytes = args['check'] as Uint8List;
  final squareBytes = args['square'] as Uint8List;
  final sigBytes = args['sig'] as Uint8List?;
  final items = (args['items'] as List).cast<Map<String, dynamic>>();
  final zn = args['zn'] as String;
  final ln = args['ln'] as String;
  final fullName = args['fullName'] as String;
  final position = args['position'] as String;

  final ttf = pw.Font.ttf(ByteData.view(fontBytes.buffer));
  final check = pw.MemoryImage(checkBytes);
  final square = pw.MemoryImage(squareBytes);
  final sig = sigBytes != null ? pw.MemoryImage(sigBytes) : null;

  pw.Widget _t(String v, {double sz = 14, bool b = false}) => pw.Text(
        v,
        style: pw.TextStyle(
          font: ttf,
          fontSize: sz,
          fontWeight: b ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      );

  List<pw.Widget> _section(String title) => [
        pw.SizedBox(height: 0),
        pw.Align(alignment: pw.Alignment.bottomRight, child: _t('[$title]', sz: 15, b: true)),
        pw.SizedBox(height: 2),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Expanded(
              flex: 2,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Align(alignment: pw.Alignment.centerLeft, child: _t('สำหรับเจ้าหน้าที่', sz: 15, b: true)),
                  pw.Align(alignment: pw.Alignment.centerLeft, child: _t('ได้รับเอกสารประกอบคำขอต่ออายุใบอนุญาต', sz: 15, b: true)),
                  pw.Align(alignment: pw.Alignment.centerLeft, child: _t('พื้นที่ผ่อนผันบริเวณ : $zn', sz: 15, b: true)),
                ],
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                decoration: pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.circular(3),
                  border: pw.Border.all(color: PdfColors.black, width: 1),
                ),
                padding: const pw.EdgeInsets.all(4.0),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Align(alignment: pw.Alignment.center, child: _t('ตรวจเอกสาร', sz: 15, b: true)),
                    pw.Row(children: [
                      pw.Expanded(child: pw.Align(alignment: pw.Alignment.centerLeft, child: _t('โซน : $zn', sz: 15, b: true))),
                      pw.Expanded(child: pw.Align(alignment: pw.Alignment.centerLeft, child: _t('พื้นที่ : $ln', sz: 15, b: true))),
                    ]),
                    pw.Row(children: [
                      pw.Expanded(child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Image(check, width: 15, height: 15),
                          pw.SizedBox(width: 2),
                          pw.Align(alignment: pw.Alignment.centerLeft, child: _t('ผ่าน', sz: 15, b: true)),
                        ],
                      )),
                      pw.Expanded(child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Image(square, width: 15, height: 15),
                          pw.SizedBox(width: 2),
                          pw.Align(alignment: pw.Alignment.centerLeft, child: _t('ไม่ผ่าน', sz: 15, b: true)),
                        ],
                      )),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: _t('ทำที่ สำนักงานเทศบาลนครเชียงใหม่', sz: 14, b: true),
        ),
        for (int i = 0; i < items.length; i += 2)
          pw.Padding(
            padding: const pw.EdgeInsets.all(4.0),
            child: pw.Row(children: [
              pw.Expanded(child: pw.Row(children: [
                pw.Image((items[i]['hasFile'] as bool) ? check : square, width: 15, height: 15),
                pw.SizedBox(width: 2),
                _t(items[i]['nameTh'] as String),
              ])),
              if (i + 1 < items.length)
                pw.Expanded(child: pw.Row(children: [
                  pw.Image((items[i + 1]['hasFile'] as bool) ? check : square, width: 15, height: 15),
                  pw.SizedBox(width: 2),
                  _t(items[i + 1]['nameTh'] as String),
                ]))
              else
                pw.Expanded(child: pw.Container()),
            ]),
          ),
        pw.SizedBox(height: 10),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Column(children: [
            if (sig != null)
              pw.SizedBox(
                width: 80, height: 40,
                child: pw.Container(
                  width: 120, height: 60,
                  child: pw.FittedBox(fit: pw.BoxFit.contain, child: pw.Image(sig)),
                ),
              ),
            _t('(ลงชื่อ) $fullName', sz: 11),
            _t(position, sz: 11),
          ]),
        ),
        pw.SizedBox(height: 10),
      ];

  final doc = pw.Document();
  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4.copyWith(
      marginBottom: 18.0, marginLeft: 18.0,
      marginRight: 18.0, marginTop: 18.0,
    ),
    build: (_) => [..._section('ต้นฉบับ'), pw.Divider(), ..._section('สำเนา')],
  ));
  return doc.save();
}
// ──────────────────────────────────────────────────────────────────────────────

class PreviewPdfgenchecklist_CMM2 extends StatefulWidget {
  final renTal_name;
  final title;

  final id;
  final uuid;
  final Request_Uuid;
  final code;
  final file_path;
  final file_type;
  final file_typeOpen;
  final uploaded_At;
  final commentReviewer;
  final statusReviewer;
  final List<RequiredDocument> docs;
  final zn;
  final ln;
  final bool viewver;

  PreviewPdfgenchecklist_CMM2({
    Key? key,
    this.renTal_name,
    this.title,
    this.id,
    this.uuid,
    this.Request_Uuid,
    this.code,
    this.file_path,
    this.file_type,
    this.file_typeOpen,
    this.uploaded_At,
    this.commentReviewer,
    this.statusReviewer,
    required this.docs,
    this.zn,
    this.ln,
    required this.viewver,
  }) : super(key: key);

  @override
  State<PreviewPdfgenchecklist_CMM2> createState() =>
      _PreviewPdfgenchecklist_CMM2State();
}

class _PreviewPdfgenchecklist_CMM2State
    extends State<PreviewPdfgenchecklist_CMM2> {
  dynamic ResponseReviews;
  dynamic widget_Signature;

  Uint8List? Signature_user;

  /// ไฟล์จากเซิร์ฟเวอร์ (กรณี widget.uuid != null/empty)
  Uint8List? _pdfBytes;

  /// ไฟล์ที่สร้างฝั่งไคลเอนต์ (กรณี widget.uuid == null/empty) และ cache
  Uint8List? _cachedChecklistBytes;

  bool _isLoading = true;
  String? _error;

  /// เก็บ Document ไว้ถ้าจำเป็นสำหรับการอัปโหลด (ไม่ต้องใช้ใน PdfPreview.build)
  final dynamic pdf = pw.Document();

  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final PdfViewerController _pdfViewerController = PdfViewerController();
  double _currentZoomLevel = 1.0;

  String fullNameAdmin = '',
      positionAdmin = '',
      proFileUuid = '',
      sigNatureUuid = '';
  Uint8List? signaturesUrl;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });
    if (widget.uuid != null && widget.uuid != '') {
      await Future.wait([StoredAuthData(), loadPdfBytes()]);
    } else {
      await StoredAuthData();
      await _generateChecklistPdf();
      setState(() {
        _isLoading = false;
      });
    }

    // auto-stamp + auto-open dialog ครั้งแรก
    if (mounted &&
        signaturesUrl != null &&
        widget.viewver == false &&
        (widget.uuid == null || widget.uuid == '')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          Signature_user = signaturesUrl;
        });
        Cancel_showDialog(context);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool bool_type() {
    return widget.file_typeOpen == 'ReviewsFile' &&
        widget.statusReviewer == 'pending';
  }

  Future<void> StoredAuthData() async {
    final response = await read_AdminSignature();
    if (response == null || response.statusCode != 200) return;
    final result = json.decode(response.body);
    final data = result['data'] as Map<String, dynamic>? ?? {};
    final profileUuid = data['profile_uuid']?.toString();
    final profile = data['profile']?.toString();
    final signatureUuid = data['signature_uuid']?.toString();
    final positionName = data['position_name']?.toString();

    Uint8List? sigBytes;
    if (signatureUuid != null && signatureUuid.isNotEmpty) {
      final sigResp = await img_signatureUuid(signatureUuid: signatureUuid);
      if (sigResp != null && sigResp.statusCode == 200) {
        sigBytes = sigResp.bodyBytes;
      }
    }

    if (!mounted) return;
    setState(() {
      signaturesUrl = sigBytes;
      proFileUuid = profileUuid ?? '';
      sigNatureUuid = signatureUuid ?? '';
      fullNameAdmin = profile ?? '';
      positionAdmin = positionName ?? '';
    });
  }

  Future<void> loadPdfBytes() async {
    // ถ้าไม่มี uuid -> ไม่ต้องโหลดไฟล์จาก server
    if (widget.uuid == null || widget.uuid == '') {
      return;
    }
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

  Future<void> _generateChecklistPdf() async {
    try {
      // Pre-load assets on main thread (platform channel)
      final fontB = await fontRawBytes();
      final checkB = await checkImageBytes();
      final squareB = await squareImageBytes();

      final items = widget.docs
          .where((d) => d.document.nameTh.toUpperCase() != 'SAMPLE')
          .map((d) => <String, Object?>{
                'nameTh': d.document.nameTh ?? '',
                'hasFile': d.attachment?.fileName?.isNotEmpty ?? false,
              })
          .toList();

      // Run save() in isolate — keeps main thread free (spinner stays alive)
      final bytes = await compute(_computeChecklistPdf, {
        'font': fontB,
        'check': checkB,
        'square': squareB,
        'sig': signaturesUrl ?? Signature_user,
        'items': items,
        'zn': widget.zn?.toString() ?? '',
        'ln': widget.ln?.toString() ?? '',
        'fullName': fullNameAdmin,
        'position': positionAdmin,
      });

      if (mounted) setState(() => _cachedChecklistBytes = bytes);
    } catch (e) {
      if (mounted) setState(() => _error = 'สร้าง PDF ไม่สำเร็จ: $e');
    }
  }

  Future<void> _printPDF() async {
    final bytes = _pdfBytes ?? _cachedChecklistBytes;
    if (bytes == null) return;
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => bytes);
  }

  Future<void> _savePDF() async {
    final bytes = _pdfBytes ?? _cachedChecklistBytes;
    if (bytes == null) return;
    await Printing.sharePdf(bytes: bytes, filename: 'downloaded_document.pdf');
  }

  dynamic signatureWidget;
  bool _submitting = false;
  String? ResponseMessageCheckList;

  List<pw.Widget> buildChecklistSection(
    pw.Font ttf,
    pw.ImageProvider check,
    pw.ImageProvider square,
    String title,
  ) {
    final data_check = widget.docs
        .where((doc) => doc.document.nameTh.toUpperCase() != 'SAMPLE')
        .toList();
    return [
      pw.SizedBox(height: 0),
      pw.Align(
        alignment: pw.Alignment.bottomRight,
        child: pw.Text('[$title]',
            style: pw.TextStyle(
                font: ttf, fontSize: 15, fontWeight: pw.FontWeight.bold)),
      ),
      pw.SizedBox(height: 2),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text('สำหรับเจ้าหน้าที่',
                      style: pw.TextStyle(
                          font: ttf,
                          fontSize: 15,
                          fontWeight: pw.FontWeight.bold)),
                ),
                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text('ได้รับเอกสารประกอบคำขอต่ออายุใบอนุญาต',
                      style: pw.TextStyle(
                          font: ttf,
                          fontSize: 15,
                          fontWeight: pw.FontWeight.bold)),
                ),
                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text('พื้นที่ผ่อนผันบริเวณ : ${widget.zn}',
                      style: pw.TextStyle(
                          font: ttf,
                          fontSize: 15,
                          fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
          ),
          pw.Expanded(
            flex: 1,
            child: pw.Container(
              decoration: pw.BoxDecoration(
                borderRadius: pw.BorderRadius.circular(3),
                border: pw.Border.all(color: PdfColors.black, width: 1),
              ),
              padding: const pw.EdgeInsets.all(4.0),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Align(
                    alignment: pw.Alignment.center,
                    child: pw.Text('ตรวจเอกสาร',
                        style: pw.TextStyle(
                            font: ttf,
                            fontSize: 15,
                            fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Align(
                          alignment: pw.Alignment.centerLeft,
                          child: pw.Text('โซน : ${widget.zn}',
                              style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 15,
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Align(
                          alignment: pw.Alignment.centerLeft,
                          child: pw.Text('พื้นที่ : ${widget.ln}',
                              style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 15,
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Image(check, width: 15, height: 15),
                            pw.SizedBox(width: 2),
                            pw.Align(
                              alignment: pw.Alignment.centerLeft,
                              child: pw.Text('ผ่าน',
                                  style: pw.TextStyle(
                                      font: ttf,
                                      fontSize: 15,
                                      fontWeight: pw.FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Image(square, width: 15, height: 15),
                            pw.SizedBox(width: 2),
                            pw.Align(
                              alignment: pw.Alignment.centerLeft,
                              child: pw.Text('ไม่ผ่าน',
                                  style: pw.TextStyle(
                                      font: ttf,
                                      fontSize: 15,
                                      fontWeight: pw.FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 10),
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('ทำที่ สำนักงานเทศบาลนครเชียงใหม่',
            style: pw.TextStyle(
                font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
      ),
      for (int i = 0; i < data_check.length; i += 2)
        pw.Padding(
          padding: const pw.EdgeInsets.all(4.0),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Row(
                  children: [
                    pw.Image(
                      (data_check[i].attachment?.fileName?.isNotEmpty ?? false)
                          ? check
                          : square,
                      width: 15,
                      height: 15,
                    ),
                    pw.SizedBox(width: 2),
                    Textx(
                      value: data_check[i].document.nameTh ?? '',
                      font: ttf,
                    ),
                  ],
                ),
              ),
              if (i + 1 < data_check.length)
                pw.Expanded(
                  child: pw.Row(
                    children: [
                      pw.Image(
                        (data_check[i + 1].attachment?.fileName?.isNotEmpty ??
                                false)
                            ? check
                            : square,
                        width: 15,
                        height: 15,
                      ),
                      pw.SizedBox(width: 2),
                      Textx(
                        value: data_check[i + 1].document.nameTh ?? '',
                        font: ttf,
                      ),
                    ],
                  ),
                )
              else
                pw.Expanded(child: pw.Container()),
            ],
          ),
        ),
      pw.SizedBox(height: 10),
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Column(children: [
          pw.SizedBox(
            width: 80,
            height: 40,
            child: (Signature_user == null)
                ? null
                : pw.Container(
                    width: 120,
                    height: 60,
                    child: pw.FittedBox(
                      fit: pw.BoxFit.contain,
                      child: pw.Image(pw.MemoryImage(Signature_user!)),
                    ),
                  ),
          ),
          if (widget_Signature != null) widget_Signature,
          Textx_mini(value: '(ลงชื่อ) $fullNameAdmin', font: ttf),
          Textx_mini(value: '$positionAdmin', font: ttf),
        ]),
      ),
      pw.SizedBox(height: 10),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final List<RequiredDocument> data_check = widget.docs
        .where((doc) => doc.document.nameTh.toUpperCase() != 'SAMPLE')
        .toList();
    final widthx = MediaQuery.of(context).size.width > 600 ? 5 : 3;
    final heightx = MediaQuery.of(context).size.height > 600 ? 4 : 2;

    Future<void> _notSuccessFully() async {
      Dialog_error(context, 'ไม่สามารถทำรายการนี้ได้');
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppBarColors.hexColor,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context, {
                'message': ResponseMessageCheckList,
              });
            },
            icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : StatefulBuilder(builder: (context, setState) {
                    return Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              if (_pdfBytes != null ||
                                  _cachedChecklistBytes != null)
                                SfPdfViewer.memory(
                                  _pdfBytes ?? _cachedChecklistBytes!,
                                  key: _pdfViewerKey,
                                  controller: _pdfViewerController,
                                  enableDocumentLinkAnnotation: false,
                                  canShowScrollHead: false,
                                  canShowScrollStatus: false,
                                  pageLayoutMode: PdfPageLayoutMode.continuous,
                                  enableDoubleTapZooming: true,
                                  onZoomLevelChanged: (details) {
                                    _currentZoomLevel = details.newZoomLevel;
                                  },
                                )
                              else
                                const Center(
                                    child: Text('กำลังเตรียมเอกสาร...')),

                              // 🔽 ลายน้ำแบบบาง ด้วย CustomPaint
                              IgnorePointer(
                                child: CustomPaint(
                                  size: Size.infinite,
                                  painter: _WatermarkPainter('Chaoperty'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.print),
                                    onPressed: (_pdfBytes == null &&
                                            _cachedChecklistBytes == null)
                                        ? _notSuccessFully
                                        : _printPDF,
                                    tooltip: 'Print PDF',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.save_alt),
                                    onPressed: (_pdfBytes == null &&
                                            _cachedChecklistBytes == null)
                                        ? _notSuccessFully
                                        : _savePDF,
                                    tooltip: 'Save PDF',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.zoom_in),
                                    onPressed: () {
                                      _currentZoomLevel += 0.25;
                                      if (_currentZoomLevel > 3.0) {
                                        _currentZoomLevel = 3.0;
                                      }
                                      _pdfViewerController.zoomLevel =
                                          _currentZoomLevel;
                                    },
                                    tooltip: 'Zoom In',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.zoom_out),
                                    onPressed: () {
                                      _currentZoomLevel -= 0.25;
                                      if (_currentZoomLevel < 1.0) {
                                        _currentZoomLevel = 1.0;
                                      }
                                      _pdfViewerController.zoomLevel =
                                          _currentZoomLevel;
                                    },
                                    tooltip: 'Zoom Out',
                                  ),
                                ],
                              ),
                              if ((widget.uuid == null || widget.uuid == '') &&
                                  widget.viewver == false)
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Translate.TranslateAndSet_TextAutoSize(
                                      '*โปรดตรวจสอบความถูกต้องของเอกสารก่อนกดยืนยัน',
                                      CustomerScreen_Color.Colors_Text2_,
                                      TextAlign.center,
                                      null,
                                      Font_.Fonts_T,
                                      10,
                                      14,
                                      1),
                                ),
                              if ((widget.uuid == null || widget.uuid == '') &&
                                  widget.viewver == false)
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: SizedBox(
                                    width: 160,
                                    child: Center(
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                            Colors.grey.shade400,
                                          ),
                                        ),
                                        onPressed: () async {
                                          Cancel_showDialog(context);
                                        },
                                        child: Translate
                                            .TranslateAndSet_TextAutoSize(
                                                'ลงชื่อ/ประทับลายเซ็น',
                                                CustomerScreen_Color
                                                    .Colors_Text2_,
                                                TextAlign.center,
                                                null,
                                                Font_.Fonts_T,
                                                10,
                                                14,
                                                1),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }));
  }

  Future<void> Cancel_showDialog(BuildContext context) async {
    TextEditingController reasonController =
        TextEditingController(text: 'เอกสารนี้ถูกต้องผ่านเกณฑ์แล้ว');
    final _formKey = GlobalKey<FormState>();
    Offset _pos = Offset.zero;
    bool _posSet = false;

    await showDialog(
      context: context,
      barrierColor: Colors.black26,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            final size = MediaQuery.of(ctx).size;
            if (!_posSet) {
              _pos = Offset(size.width - 450, 16);
              _posSet = true;
            }
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.zero,
              elevation: 0,
              child: SizedBox.expand(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        behavior: HitTestBehavior.translucent,
                      ),
                    ),
                    Positioned(
                      left: _pos.dx.clamp(0.0, size.width - 440),
                      top: _pos.dy.clamp(0.0, size.height - 300),
                      child: GestureDetector(
                        onPanUpdate: (d) =>
                            setStateDialog(() => _pos += d.delta),
                        child: Material(
                          elevation: 12,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 420,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // header + drag hint
                                Row(
                                  children: [
                                    const Icon(Icons.drag_indicator,
                                        color: Colors.grey, size: 20),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Text(
                                        'เอกสารผ่านเกณฑ์ ท่านต้องการลงชื่อประทับลายเซ็นเอกสารหรือไม่',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 18),
                                      onPressed: () => Navigator.pop(ctx),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // reasonController
                                TextFormField(
                                  controller: reasonController,
                                  maxLines: 1,
                                  decoration: const InputDecoration(
                                    hintText: 'รายละเอียด...',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // signature box
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 130,
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(4.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: (Signature_user == null)
                                              ? const Center(
                                                  child: Text('ยังไม่มีลายเซ็น',
                                                      style: TextStyle(
                                                          color: Colors.grey)))
                                              : Image.memory(Signature_user!,
                                                  fit: BoxFit.contain),
                                        ),
                                      ),
                                      Container(
                                        decoration: const BoxDecoration(
                                          color: AppbackgroundColor.Abg_Colors,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            TextButton(
                                              onPressed: () async {
                                                await font1();
                                                setState(() {
                                                  Signature_user = signaturesUrl;
                                                });
                                                setStateDialog(() {});
                                                if (widget.uuid == null ||
                                                    widget.uuid == '') {
                                                  _generateChecklistPdf();
                                                }
                                              },
                                              child: const Text('ประทับลายเซ็น',
                                                  style: TextStyle(
                                                      color: Colors.blueGrey)),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  widget_Signature = null;
                                                  Signature_user = null;
                                                });
                                                setStateDialog(() {});
                                                if (widget.uuid == null ||
                                                    widget.uuid == '') {
                                                  _generateChecklistPdf();
                                                }
                                              },
                                              child: const Text('ยกเลิกลายเซ็น',
                                                  style: TextStyle(
                                                      color: Colors.blueGrey)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // name + position
                                for (int index = 0; index < 2; index++)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 8.0),
                                    child: TextFormField(
                                      readOnly: true,
                                      initialValue: (index == 0)
                                          ? '$fullNameAdmin'
                                          : '$positionAdmin',
                                      decoration: InputDecoration(
                                        labelText: (index == 0)
                                            ? 'ชื่อผู้ตรวจสอบเอกสาร'
                                            : 'ชื่อตำแหน่ง',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: const OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                // action row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('ยกเลิก'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: (Signature_user == null)
                                          ? () => Dialog_error(ctx,
                                              'กรุณาลงชื่อประทับลายเซ็นก่อน')
                                          : () async {
                                              Navigator.of(ctx,
                                                      rootNavigator: true)
                                                  .pop();
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback(
                                                      (_) async {
                                                await Approved_showDialog(
                                                    Navigator.of(context,
                                                            rootNavigator: true)
                                                        .context,
                                                    bypass: true);
                                              });
                                            },
                                      child: const Text('ยืนยัน'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> Approved_showDialog(BuildContext context,
      {required bool bypass}) async {
    int selectedOption = 2;
    TextEditingController reasonController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    setState(() {
      reasonController.text = 'เอกสารนี้ถูกต้องผ่านเกณฑ์แล้ว';
    });
    if (bypass == true) {
      if (_submitting) return;
      setState(() => _submitting = true);

      try {
        final bytes = _pdfBytes ?? _cachedChecklistBytes;
        if (bytes == null) {
          await Dialog_error(context, 'ไม่พบไฟล์สำหรับอัพโหลด');
          if (mounted) setState(() => _submitting = false);
          return;
        }

        final resp = await Post_ReviewsCheckListCommit(
          requestUuid: widget.Request_Uuid.toString(),
          profileUuid: proFileUuid.toString(),
          signatureUuid: sigNatureUuid.toString(),
          staTus: 'approved',
          documentId: widget.id.toString(),
          file: bytes,
        );

        if (resp == null) {
          await Dialog_error(context, 'ไม่พบการตอบกลับจากเซิร์ฟเวอร์');
          return;
        }

        final body = json.decode(resp.body);
        final message = body['message']?.toString() ?? 'No message';

        if (resp.statusCode == 201 || resp.statusCode == 409) {
          setState(() => ResponseMessageCheckList = message);
          if (!mounted) return;
          // Navigator.of(context).pop(); // ปิด dialog
          Navigator.of(context).pop({
            'status': true,
            'message': message,
          });
        } else {
          if (!mounted) return;
          // Navigator.of(context).pop(); // ปิด dialog
          await Dialog_error(context, message);
        }
      } catch (e, st) {
        // debugPrint('❌ $e\n$st');
        if (mounted) {
          // Navigator.of(context).pop(); // ปิด dialog
          await Dialog_error(context, 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง');
        }
      } finally {
        if (mounted) setState(() => _submitting = false);
      }
    } else {
      await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(fontSize: 16, color: Colors.black),
                    children: [
                      TextSpan(
                          text: 'เอกสารผ่านเกณฑ์',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: 'ถูกต้องครบถ้วน '),
                      TextSpan(text: '[อัพโหลดเอกสาร]'),
                    ],
                  ),
                ),

                // const Text('เอกสารผ่านเกณฑ์ ถูกต้องครบถ้วน',
                //     textAlign: TextAlign.center),
                content: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<int>(
                        value: 2,
                        groupValue: selectedOption,
                        onChanged: (value) {
                          setStateDialog(() {
                            selectedOption = value!;
                            reasonController.clear();
                          });
                        },
                        title:
                            const Text('เอกสารผ่านเกณฑ์ (โปรดระบุรายละเอียด)'),
                      ),
                      if (selectedOption == 2)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextFormField(
                            controller: reasonController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              hintText: 'รายละเอียด...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ยกเลิก'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_submitting) return;
                      setState(() => _submitting = true);

                      try {
                        final bytes = _pdfBytes ?? _cachedChecklistBytes;
                        if (bytes == null) {
                          await Dialog_error(context, 'ไม่พบไฟล์สำหรับอัพโหลด');
                          if (mounted) setState(() => _submitting = false);
                          return;
                        }

                        final resp = await Post_ReviewsCheckListCommit(
                          requestUuid: widget.Request_Uuid.toString(),
                          profileUuid: proFileUuid.toString(),
                          signatureUuid: sigNatureUuid.toString(),
                          staTus: 'approved',
                          documentId: widget.id.toString(),
                          file: bytes,
                        );

                        if (resp == null) {
                          await Dialog_error(
                              context, 'ไม่พบการตอบกลับจากเซิร์ฟเวอร์');
                          return;
                        }

                        final body = json.decode(resp.body);
                        final message =
                            body['message']?.toString() ?? 'No message';

                        if (resp.statusCode == 201 || resp.statusCode == 409) {
                          setState(() => ResponseMessageCheckList = message);
                          if (!mounted) return;
                          Navigator.of(context).pop(); // ปิด dialog
                          Navigator.of(context).pop({
                            'status': true,
                            'message': message,
                          });
                        } else {
                          if (!mounted) return;
                          Navigator.of(context).pop(); // ปิด dialog
                          await Dialog_error(context, message);
                        }
                      } catch (e, st) {
                        // debugPrint('❌ $e\n$st');
                        if (mounted) {
                          Navigator.of(context).pop(); // ปิด dialog
                          await Dialog_error(
                              context, 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง');
                        }
                      } finally {
                        if (mounted) setState(() => _submitting = false);
                      }
                    },
                    child: const Text('ยืนยัน'),
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }
}

/// Painter สำหรับวาดลายน้ำแบบเบา เร็ว และไม่กระพริบ
class _WatermarkPainter extends CustomPainter {
  final String text;
  _WatermarkPainter(this.text);

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    const double angle = -0.4; // ประมาณ -22°
    canvas.save();
    canvas.rotate(angle);

    final style = const TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.bold,
      // ใช้ opacity ต่ำ ๆ เพื่อลดการรบกวนสายตา
      color: Color.fromRGBO(0, 0, 0, 0.08),
    );

    // ช่องไฟให้พอดี ๆ
    for (double y = -size.height; y < size.height * 2; y += 180) {
      for (double x = -size.width; x < size.width * 2; x += 260) {
        textPainter.text = TextSpan(text: text, style: style);
        textPainter.layout();
        textPainter.paint(canvas, Offset(x, y));
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
