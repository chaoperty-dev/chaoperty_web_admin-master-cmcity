import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:chaoperty/ChiangMai_Municipality/unity/show_dialog_cmm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:step_progress/step_progress.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart' as px;
import '../../../Constant/Myconstant.dart';
import '../../../Responsive/responsive.dart';
import '../../../Style/Translate.dart';
import '../../../Style/colors.dart';
import '../../Model/Payments_Model.dart';
import '../../Model/Receipt_Model.dart';
import '../../Model/ReviewUuid_Model.dart';
import '../../unity/API_admin_requests.dart';
import '../../unity/API_payment.dart';
import '../../unity/API_requests_reviews.dart';
import '../../unity/API_requests_reviewsflow.dart';
import '../../unity/Enum.dart';
import '../../unity/FormatDate.dart';
import '../../unity/PickThaiDate.dart';
import '_WatermarkPainter.dart';

class PreviewPdf_ordit_CMM extends StatefulWidget {
  // ค่าเริ่มต้นจากภายนอก
  final String? renTal_name;
  final String? title;
  final String? id;
  final String? uuid;
  final String? Request_Uuid;
  final String? code;
  final String? file_path;
  final String? file_type;
  final String? file_typeOpen;
  final String? uploaded_At;
  final String? commentReviewer;
  final String? statusReviewer;

  // เอกสารที่เกี่ยวข้อง
  final List<dynamic> docs;
  final List<dynamic> data_title_doc;
  final List<ReviewDetail> payment;
  final bool viewver;

  const PreviewPdf_ordit_CMM({
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
    required this.data_title_doc,
    required this.payment,
    required this.viewver,
  }) : super(key: key);

  @override
  State<PreviewPdf_ordit_CMM> createState() => _PreviewPdf_ordit_CMMState();
}

class _PreviewPdf_ordit_CMMState extends State<PreviewPdf_ordit_CMM> {
  // Viewer
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final PdfViewerController _pdfViewerController = PdfViewerController();
  final TransformationController _imageZoomController =
      TransformationController();
  double _currentZoomLevel = 1.0;

  // ✅ โหมด Grid (แสดงไฟล์ทั้งหมด)
  bool _isGridMode = false;

  // Thumbnail + checkbox state (สำหรับ Grid)
  final Map<String, Uint8List> _thumbByUuid = {}; // uuid -> thumb bytes
  final Set<String> _thumbLoadingUuids = {}; // กันโหลดซ้ำ
  final Set<String> _checkedUuids = {}; // uuid ที่ถูกเลือก
  bool _checkedInitialized = false;

  // Progress สำหรับการอนุมัติแบบ Batch
  double _approveProgress = 0.0;
  int _approveCurrent = 0;
  int _approveTotal = 0;
  StateSetter? _approveDialogSetState;

  // Search (เผื่อใช้งานต่อ)
  final TextEditingController _searchController = TextEditingController();
  PdfTextSearchResult _searchResult = PdfTextSearchResult();

  // Network bytes
  Uint8List? _pdfBytes;
  bool _isLoading = true;
  String? _error;

  // ผลลัพธ์การรีวิว/อนุมัติ
  dynamic ResponseReviews, is_open_approved;

  // Index ของเอกสารที่กำลังดู
  int? idxDocs;

  // ===== State Variables (ข้อมูลปัจจุบันของเอกสารที่เลือก) =====
  String? currentRenTalName;
  String? currentTitle;
  String? currentId;
  String? currentUuid;
  String? currentRequestUuid;
  String? currentCode;
  String? currentFilePath;
  String? currentFileType;
  String? currentFileTypeOpen;
  String? currentUploadedAt;
  String? currentCommentReviewer;
  String? currentStatusReviewer;

  // bool get isReviewsPending =>
  //     currentFileTypeOpen == 'ReviewsFile' &&
  //     currentStatusReviewer == 'pending';
  // แก้เป็น
  bool get isReviewsPending =>
      currentFileTypeOpen == 'ReviewsFile' &&
      currentStatusReviewer == 'pending' &&
      !_approvedUuids.contains(currentUuid ?? '');
// state overlay ไว้บนสุดของ State (ถ้ายังไม่มี)
  final Set<String> _approvedUuids = {}; // ใส่ uuid ของไฟล์ที่อนุมัติแล้ว
  List<PaymentsModelCMM> _list = [];

////////////////////------------------------->
  int? paymentMethodId_Edit;
  String? paymentMethodCode_Edit;
  int? bankaccountId_Edit;
  String? Pdate_Edit;
////////////////////------------------------->
  @override
  void initState() {
    super.initState();

    // sync ค่าจาก widget มาเป็น state เริ่มต้น
    currentRenTalName = widget.renTal_name;
    currentTitle = widget.title;
    currentId = widget.id;
    currentUuid = widget.uuid;
    currentRequestUuid = widget.Request_Uuid;
    currentCode = widget.code;
    currentFilePath = widget.file_path;
    currentFileType = widget.file_type;
    currentFileTypeOpen = widget.file_typeOpen;
    currentUploadedAt = widget.uploaded_At;
    currentCommentReviewer = widget.commentReviewer;
    currentStatusReviewer = widget.statusReviewer;

    // หา index จาก uuid ที่ส่งมา แล้วโหลดไฟล์
    _initIndexFromUuidThenLoad();
    red_payMent();
  }

  List<PaymentsModelCMM> paymentsmodel = [];
  Future<void> red_payMent() async {
    // print('🔄 เรียกใช้งาน red_payMent  ***');

    // โหลดข้อมูลการชำระเงิน
    final result = await read_GC_payment();
    //  print('📥 โหลดรายการวิธีชำระเงิน: ${result.length} รายการ');

    if (result.isNotEmpty) {
      setState(() {
        paymentsmodel = result;
        _list = result
            .map((payment) => PaymentsModelCMM(
                  id: payment.id,
                  uuid: payment.uuid,
                  code: payment.code,
                  name_th: payment.name_th,
                  meta: payment.meta,
                ))
            .toList();
      });

      for (var payment in _list) {
        //   print('✅ วิธีชำระ: ${payment.name_th}');
      }
    } else {
      //  print('⚠️ ไม่พบข้อมูลวิธีชำระเงิน');
    }
  }

  String? tryGetUuid(dynamic x) {
    try {
      final u = (x as dynamic).uuid;
      if (u != null) return u.toString();
    } catch (_) {}
    if (x is Map) {
      final u = x['uuid'];
      if (u != null) return u.toString();
    }
    return null;
  }

  // helper: ดึง field จาก object หรือ Map
  dynamic _get(dynamic obj, String key) {
    if (obj == null) return null;
    // โมเดลที่มีฟิลด์ชื่อ key
    try {
      final v = (obj as dynamic).__proto__; // ป้องกัน ddc noise
    } catch (_) {}
    try {
      final v = (obj as dynamic).toJson?.call(); // บางโมเดล
      if (v is Map && v.containsKey(key)) return v[key];
    } catch (_) {}
    // เข้าถึง property โดยตรง (ถ้ามี)
    try {
      switch (key) {
        case 'attachment':
          return (obj as dynamic).attachment;
        case 'attachments':
          return (obj as dynamic).attachments;
      }
    } catch (_) {}
    // ถ้าเป็น Map
    if (obj is Map) return obj[key];
    return null;
  }

  // helper: อ่าน uuid จาก object/map/โมเดล
  String? _readUuid(dynamic obj) {
    if (obj == null) return null;
    // โมเดลที่มี property uuid
    try {
      final v = (obj as dynamic).uuid;
      if (v != null) return v.toString();
    } catch (_) {}
    // กรณีเป็น Map
    if (obj is Map) {
      final v = obj['uuid'];
      if (v != null) return v.toString();
    }
    return null;
  }

  Future<void> _initIndexFromUuidThenLoad() async {
    final targetUuid = currentUuid?.toString();
    if (targetUuid == null || targetUuid.isEmpty) {
      // print('ไม่พบค่า UUID สำหรับค้นหาเอกสาร');
      setState(() {
        _isLoading = false;
        _error = 'ไม่พบค่า UUID สำหรับค้นหาเอกสาร';
      });
      return;
    }

    //   print('targetUuid  = $targetUuid');

    bool _matchUuid(dynamic item, String uuid) {
      // 1) กรณีมี field 'attachment' (object เดี่ยว)
      final att = _readUuid(_get(item, 'attachment'));
      if (att == uuid) return true;

      // 2) กรณีมี field 'attachments' (อาจเป็น list หรือ object เดี่ยว)
      final atts = _get(item, 'attachments');
      if (atts is List) {
        for (final x in atts) {
          if (_readUuid(x) == uuid) return true;
        }
      } else {
        // attachments เป็น object เดี่ยว
        if (_readUuid(atts) == uuid) return true;
      }
      return false;
    }

    // เลือก source ให้ยืดหยุ่น: ถ้าเป็นโหมด UPFile ให้หาใน attachments ก่อน
    int i;
    if (widget.file_typeOpen.toString() == 'UPFile') {
      i = widget.docs.indexWhere((d) => _matchUuid(d, targetUuid));
    } else {
      // โหมดปกติ: ใช้ทั้ง attachment และ attachments เผื่อไว้
      i = widget.docs.indexWhere((d) => _matchUuid(d, targetUuid));
    }

    if (i < 0) {
      setState(() {
        idxDocs = null;
        _isLoading = false;
        _error = 'ไม่พบเอกสารที่ uuid = $targetUuid';
      });
      return;
    }

    await selectDocAt(i);
  }

// helper (ถ้าอยากคงไว้ก็ได้)
  String displayFileNameFor(dynamic att, int index) {
    final approved = _approvedUuids.contains(att?.uuid?.toString());
    if (approved) return 'file_approved[$index]';
    return att?.fileName?.toString() ?? '-';
  }

  String? currentDisplayFileName;
  Future<void> selectDocAt(int i) async {
    if (i < 0 || i >= widget.docs.length) return;

    final item = widget.docs[i];
    if (widget.file_typeOpen.toString() == 'UPFile') {
      final matched = findAttachmentByDocId(item.attachments ?? [], item.id);
      final file_Uuid = matched?.uuid ?? '';

      // final title = _readString(item, 'nameTh') ?? _readString(item, 'name_th');
      setState(() {
        currentUuid = file_Uuid.toString();
        currentTitle = item.nameTh;
      });
      // print(item.nameTh);
    }
    // print(item.attachments.uuid);

    // ดึง attachment “ตัวที่ตรงกับ currentUuid” ถ้าเป็นลิสต์
    dynamic att = _pickAttachmentFrom(item, wantUuid: currentUuid);
    // ถ้ายังไม่ได้ ลอง fallback: attachment เดี่ยว
    att ??= _getField(item, 'attachment');

    // ชื่อเอกสาร (จาก 'document' ถ้ามี)
    final doc = _getField(item, 'document');

    // Normalize fields
    final fileName =
        _readString(att, 'fileName') ?? _readString(att, 'file_name');
    final fileType =
        _readString(att, 'fileType') ?? _readString(att, 'file_type');
    final uploadedAt =
        _readString(att, 'uploadedAt') ?? _readString(att, 'uploaded_at');
    final status = _readString(att, 'status');
    final uuid = _readString(att, 'uuid');
    final title = (widget.file_typeOpen.toString() == 'UPFile')
        ? _readString(item, 'nameTh') ?? _readString(item, 'name_th')
        : _readString(doc, 'nameTh') ?? _readString(doc, 'name_th');

    final hasFile = (fileName?.isNotEmpty ?? false);
    final approvedLocal = _approvedUuids.contains(uuid);
    final shown = approvedLocal ? 'file_approved[$i]' : (fileName ?? '-');

    if (!mounted) return;
    setState(() {
      _isGridMode = false; // ✅ เมื่อเลือกไฟล์ ให้กลับมาหน้า Viewer
      idxDocs = i;
      currentUuid = uuid;
      currentTitle = (title ?? '').toString();
      currentFileType = fileType?.toLowerCase(); // เก็บให้เป็น lower
      currentUploadedAt = uploadedAt?.toString();
      currentStatusReviewer = status?.toString();
      currentFileTypeOpen =
          (hasFile || approvedLocal) ? 'ReviewsFile' : 'pending';
      currentDisplayFileName = shown;

      _isLoading = true;
      _error = null;
      _pdfBytes = null;
    });
    Future.delayed(const Duration(milliseconds: 300), () async {
      await _loadPdfBytesFor(currentUuid);
    });
  }

// ===== helpers =====
  dynamic _getField(dynamic obj, String key) {
    if (obj == null) return null;
    // model
    try {
      switch (key) {
        case 'attachment':
          return (obj as dynamic).attachment;
        case 'attachments':
          return (obj as dynamic).attachments;
        case 'document':
          return (obj as dynamic).document;
      }
    } catch (_) {}
    // map
    if (obj is Map) return obj[key];
    return null;
  }

  String? _readString(dynamic obj, String key) {
    if (obj == null) return null;
    // model
    try {
      final v = (obj as dynamic).toJson?.call();
      if (v is Map && v.containsKey(key)) return v[key]?.toString();
    } catch (_) {}
    try {
      final v = (obj as dynamic);
      switch (key) {
        case 'uuid':
          return v.uuid?.toString();
        case 'fileName':
          return v.fileName?.toString();
        case 'file_name':
          return v.file_name?.toString();
        case 'fileType':
          return v.fileType?.toString();
        case 'file_type':
          return v.file_type?.toString();
        case 'uploadedAt':
          return v.uploadedAt?.toString();
        case 'uploaded_at':
          return v.uploaded_at?.toString();
        case 'status':
          return v.status?.toString();
        case 'nameTh':
          return v.nameTh?.toString();
        case 'name_th':
          return v.name_th?.toString();
      }
    } catch (_) {}
    // map
    if (obj is Map) return obj[key]?.toString();
    return null;
  }

  dynamic _pickAttachmentFrom(dynamic item, {String? wantUuid}) {
    if (wantUuid == null || wantUuid.isEmpty) return null;

    // attachments list
    final atts = _getField(item, 'attachments');
    if (atts is List) {
      for (final x in atts) {
        final ux = _readString(x, 'uuid');
        if (ux == wantUuid) return x;
      }
    }

    // ถ้า attachments เป็น object เดี่ยว
    if (atts != null) {
      final ux = _readString(atts, 'uuid');
      if (ux == wantUuid) return atts;
    }

    // attachment เดี่ยว
    final att = _getField(item, 'attachment');
    if (att != null) {
      final ux = _readString(att, 'uuid');
      if (ux == wantUuid) return att;
    }

    // uuid บน item เอง
    final uSelf = _readString(item, 'uuid');
    if (uSelf == wantUuid) return item;

    return null;
  }

  Future<void> _loadPdfBytesFor(String? uuid) async {
    if (uuid == null || uuid.isEmpty) {
      if (!mounted) return;
      setState(() {
        _pdfBytes = null;
        _isLoading = false;
        _error = 'ไม่พบ UUID สำหรับโหลดไฟล์';
      });
      _showNextDialog(context);
      return;
    }

    try {
      final response = await pdfimg_ReviewsFlow(attachmentUuid: uuid);
      if (!mounted) return;

      if (response != null && response.statusCode == 200) {
        setState(() {
          _pdfBytes = response.bodyBytes;
          _isLoading = false;
          _error = null;
        });
        if (widget.viewver == false) {
          Future.delayed(const Duration(milliseconds: 300), () async {
            // Navigator.pop(context);
            // _showNextDialog(context);
            if (isReviewsPending) {
              await _showNeedsUpdateOrRejectedDialog(context);
              // if (idxDocs != 0) await _showNeedsUpdateOrRejectedDialog(context); _pdfBytes
            }

            // if (idxDocs != 0) await _showApprovedDialog();
          });
        }
      } else {
        setState(() {
          _pdfBytes = null;
          _isLoading = false;
          _error = 'โหลด PDF ไม่สำเร็จ';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'เกิดข้อผิดพลาดในการโหลดไฟล์: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _printPDF() async {
    if (_pdfBytes == null) return;
    await Printing.layoutPdf(
      onLayout: (format) async => _pdfBytes!,
    );
  }

  Future<void> _savePDF() async {
    if (_pdfBytes == null) return;
    await Printing.sharePdf(
      bytes: _pdfBytes!,
      filename: 'downloaded_document.pdf',
    );
  }

  Future<void> _notSuccessFully() async {
    Dialog_error(context, 'ไม่สามารถทำรายการนี้ได้');
  }

////////////////////------------------------------>
// ---- helpers (วาง top-level) ----
  bool _idEquals(dynamic a, dynamic b) => a?.toString() == b?.toString();

  PaymentsModelCMM? _findInitialItem(
    List<PaymentsModelCMM> list,
    dynamic targetBankId,
  ) {
    for (final e in list) {
      final bankId =
          (e.meta?.isNotEmpty == true) ? e.meta!.first.bank_id : null;
      if (_idEquals(bankId, targetBankId)) return e;
    }
    return list.isNotEmpty
        ? list.first
        : null; // หรือจะคืน null ก็ได้ตามต้องการ
  }

  String _displayDate(dynamic slipDate, dynamic edited) {
    if (edited != null) {
      if (edited is DateTime) {
        return DateFormat('dd-MM-yyyy').format(edited);
      }
      final s = edited.toString().trim();
      if (s.isNotEmpty) return s;
    }
    if (slipDate == null) return 'เลือกวันที่';
    try {
      return DateFormat('dd-MM-yyyy')
          .format(DateTime.parse(slipDate.toString()));
    } catch (_) {
      final s = slipDate.toString();
      return s.length >= 10 ? s.substring(0, 10) : s;
    }
  }

// -------------------------
  // ✅ Normalize file type helper (รองรับ mime / .pdf)
  String? _normalizeFileType(String? ft) {
    if (ft == null) return null;
    final s = ft.trim().toLowerCase();
    if (s.isEmpty) return null;

    // mime → extension
    if (s.contains('/')) {
      final parts = s.split('/');
      if (parts.length == 2) return parts[1];
    }

    // remove dot prefix
    if (s.startsWith('.')) return s.substring(1);

    if (s == 'jpeg') return 'jpg';
    return s;
  }

  bool _isImageType(String? ft) {
    final t = (ft ?? '').toLowerCase();
    return t == 'png' || t == 'jpg' || t == 'jpeg' || t == 'webp';
  }

  bool _hasFileUuid(String? uuid) => uuid != null && uuid.trim().isNotEmpty;

  bool _isApprovedUuid(String? uuid) =>
      uuid != null && _approvedUuids.contains(uuid);

  Set<String> _eligibleUuidsForCheck() {
    final Set<String> out = {};

    for (final item in widget.docs) {
      dynamic att = _getField(item, 'attachment');
      final atts = _getField(item, 'attachments');
      if (att == null && atts is List && atts.isNotEmpty) att = atts.first;
      if (att == null && atts != null && atts is! List) att = atts;

      final uuid = _readString(att, 'uuid');
      final status = _readString(att, 'status'); // pending/approved/...
      final hasFile = uuid != null && uuid.isNotEmpty;

      // ✅ ติ๊กได้เฉพาะ: มีไฟล์ + pending + ยังไม่ approved local
      final canCheck =
          hasFile && status == 'pending' && !_approvedUuids.contains(uuid);

      if (canCheck) out.add(uuid!);
    }

    return out;
  }

  void _checkAll() {
    final eligible = _eligibleUuidsForCheck();
    setState(() {
      _checkedUuids.addAll(eligible);
    });
  }

  void _uncheckAll() {
    setState(() {
      _checkedUuids.clear();
    });
  }

  void _initCheckedDefaults() {
    if (_checkedInitialized) return;
    _checkedInitialized = true;
  }

  // ==========================
  // ✅ Thumbnail maker (ใช้ API เดิม โหลด bytes แล้วทำ thumb)
  Future<Uint8List?> _makeThumbForFile({
    required String uuid,
    required String? fileType,
  }) async {
    try {
      final resp = await pdfimg_ReviewsFlow(attachmentUuid: uuid);
      if (resp == null || resp.statusCode != 200) return null;

      final bytes = resp.bodyBytes;
      final ft = _normalizeFileType(fileType)?.toLowerCase() ?? '';

      // รูป: ใช้ bytes เป็น thumb ได้เลย
      if (_isImageType(ft)) return bytes;

      // PDF: ทำ thumb หน้าแรก
      if (ft == 'pdf') {
        final doc = await px.PdfDocument.openData(bytes);
        final page = await doc.getPage(1);

        final double w = 220.0;
        final double h = w * page.height / page.width;

        final px.PdfPageImage? img = await page.render(
          width: w,
          height: h,
          format: px.PdfPageImageFormat.jpeg,
          quality: 80,
        );

        await page.close();
        await doc.close();

        if (img == null) return null;
        return img.bytes;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  Widget _placeholderTile(String? ft) {
    final t = (ft ?? '').toLowerCase();
    IconData icon = Icons.insert_drive_file;
    if (t == 'pdf') icon = Icons.picture_as_pdf;
    if (_isImageType(t)) icon = Icons.image;
    return Center(child: Icon(icon, size: 40, color: Colors.black54));
  }

  // ✅ Grid แสดง "ทุกไฟล์"
  Widget _buildAllFilesGrid() {
    _initCheckedDefaults();

    if (widget.docs.isEmpty) {
      return const Center(child: Text('ไม่มีเอกสารในรายการ docs'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double baseItemWidth = 100.0 * _currentZoomLevel;
        int calculatedCount = (constraints.maxWidth / baseItemWidth).floor();
        int gridCount = calculatedCount.clamp(1, 5);

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: widget.docs.length,
          itemBuilder: (context, i) {
            final item = widget.docs[i];

            dynamic att = _getField(item, 'attachment');
            final atts = _getField(item, 'attachments');
            if (att == null && atts is List && atts.isNotEmpty) att = atts.first;
            if (att == null && atts != null && atts is! List) att = atts;

            final uuid = _readString(att, 'uuid');
            final rawType =
                _readString(att, 'fileType') ?? _readString(att, 'file_type');
            final fileType = _normalizeFileType(rawType);

            final doc = _getField(item, 'document');
            final title = _readString(doc, 'nameTh') ??
                _readString(doc, 'name_th') ??
                _readString(item, 'nameTh') ??
                _readString(item, 'name_th') ??
                'ไฟล์';

            final bool hasFile = _hasFileUuid(uuid);
            final thumb = hasFile ? _thumbByUuid[uuid] : null;

            if (hasFile &&
                uuid != null &&
                thumb == null &&
                !_thumbLoadingUuids.contains(uuid)) {
              _thumbLoadingUuids.add(uuid);
              _makeThumbForFile(uuid: uuid, fileType: fileType).then((bytes) {
                if (!mounted) return;
                if (bytes != null) {
                  setState(() {
                    _thumbByUuid[uuid] = bytes;
                  });
                }
              }).whenComplete(() {
                _thumbLoadingUuids.remove(uuid);
              });
            }

            return Card(
              elevation: 2,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: hasFile ? () async => await selectDocAt(i) : null,
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                            ),
                            child: thumb != null
                                ? InteractiveViewer(
                                    minScale: 1.0,
                                    maxScale: 4.0,
                                    child:
                                        Image.memory(thumb, fit: BoxFit.cover),
                                  )
                                : _placeholderTile(fileType),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 6),
                          color: Colors.white,
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
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

  Future<void> _showApproveProgressDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            _approveDialogSetState = setStateDialog;
            return AlertDialog(
              title: const Text('กำลังอนุมัติเอกสาร'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value: _approveProgress,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$_approveCurrent / $_approveTotal รายการ',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_approveProgress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _approveAllChecked() async {
    if (_checkedUuids.isEmpty) {
      Dialog_error(context, 'กรุณาเลือกเอกสารอย่างน้อย 1 รายการ');
      return;
    }

    final eligible = _eligibleUuidsForCheck();
    final targets = _checkedUuids.where((u) => eligible.contains(u)).toList();

    if (targets.isEmpty) {
      Dialog_error(context, 'ไม่มีเอกสารที่อยู่ในสถานะรออนุมัติ (pending)');
      return;
    }

    _approveTotal = targets.length;
    _approveCurrent = 0;
    _approveProgress = 0;

    await _showApproveProgressDialog();

    bool hasError = false;

    for (final uuid in targets) {
      try {
        final response = await Post_ReviewsAttachMents(
          staTus: 'approved',
          requestUuid: currentRequestUuid?.toString() ?? '',
          attachmentsUuid: uuid,
          descripTion: '',
        );

        final ok = response != null &&
            (response.statusCode == 200 ||
                response.statusCode == 201 ||
                response.statusCode == 409);

        if (ok) {
          _approvedUuids.add(uuid);
          _checkedUuids.remove(uuid);

          for (final d in widget.docs) {
            try {
              if (d.attachment?.uuid?.toString() == uuid) {
                d.attachment.status = 'approved';
              }
            } catch (_) {}

            try {
              final atts = d.attachments;
              if (atts is List) {
                for (final a in atts) {
                  try {
                    if (a.uuid?.toString() == uuid) a.status = 'approved';
                  } catch (_) {}
                }
              } else if (atts != null) {
                try {
                  if (atts.uuid?.toString() == uuid) atts.status = 'approved';
                } catch (_) {}
              }
            } catch (_) {}
          }
        } else {
          hasError = true;
        }
      } catch (_) {
        hasError = true;
      }

      _approveCurrent++;
      _approveProgress = _approveCurrent / _approveTotal;
      _approveDialogSetState?.call(() {});
    }

    if (!mounted) return;

    Navigator.of(context).pop();
    _approveDialogSetState = null;

    if (hasError) {
      Dialog_error(context, 'อนุมัติบางรายการไม่สำเร็จ');
    } else {
      Dialog_success(context, 'อนุมัติเอกสารที่เลือกเรียบร้อยแล้ว');
    }

    setState(() {});
  }

////////////////////------------------------------>
  @override
  Widget build(BuildContext context) {
    double calculatedWidth = MediaQuery.of(context).size.width;
    int idxDocsx = idxDocs ?? 0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppBarColors.hexColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, {
              'message': ResponseReviews,
              'isopenapproved': is_open_approved,
            });
          },
          icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
        ),
        centerTitle: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _isGridMode
                  ? "เลือกแล้ว ${_checkedUuids.length} รายการ"
                  : "${currentTitle ?? ''} ${idxDocs != null ? "[${idxDocsx + 1}/${widget.docs.length}]" : ""}",
              style: const TextStyle(
                color: Colors.white,
                fontFamily: Font_.Fonts_T,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              (currentUuid == null) ? '(error)' : "(${currentUuid})",
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.7),
                fontFamily: Font_.Fonts_T,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          // Removed batch action buttons as requested
        ],
      ),
      body: Container(
        width: calculatedWidth,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  // เอกสารถัดไป/ก่อนหน้า (เฉพาะตอน viewer)
                  if (!_isGridMode)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(15),
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(15)),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: IconButton(
                        icon: const Icon(
                          Icons.navigate_before,
                          color: Colors.white,
                        ),
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (idxDocs == null) return;
                                final prev = idxDocs! - 1;
                                if (prev >= 0) await selectDocAt(prev);
                              },
                      ),
                    ),
                  Expanded(
                    child:
                        _isGridMode ? _buildAllFilesGrid() : _buildViewerArea(),
                  ),
                  if (!_isGridMode)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(0),
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(0)),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: IconButton(
                          icon: const Icon(
                            Icons.navigate_next,
                            color: Colors.white,
                          ),
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  if (idxDocs == null) return;
                                  var next = idxDocs! + 1;
                                  if (next < widget.docs.length) {
                                    await selectDocAt(next);
                                  }
                                }),
                    ),
                ],
              ),
            ),
            _buildBottomBar(calculatedWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildViewerArea() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (_pdfBytes == null) {
      return const Center(child: Text('ไม่พบไฟล์สำหรับแสดงผล'));
    }

    final isPdf = currentFileType?.toLowerCase() == 'pdf';

    return Stack(
      children: [
        if (isPdf)
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
              // ไม่ต้อง setState เพื่อเลี่ยงกระพริบ
              _currentZoomLevel = details.newZoomLevel;
            },
          )
        else
          // แสดงเป็นภาพ (กรณี file_type ไม่ใช่ pdf)
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.memory(_pdfBytes!),
              ),
            ),
          ),

        // ลายน้ำแบบเบา เร็ว และไม่กระพริบ
        IgnorePointer(
          child: CustomPaint(
            size: Size.infinite,
            painter: WatermarkPainter('Chaoperty'),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(double calculatedWidth) {
    return Container(
      width: calculatedWidth,
      decoration: BoxDecoration(
        color: Colors.indigo[400],
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Left: Tool icons
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.print, size: 22),
                onPressed: (currentFileTypeOpen == 'SuccessFully')
                    ? _printPDF
                    : _notSuccessFully,
                tooltip: 'Print',
              ),
              IconButton(
                icon: const Icon(Icons.save_alt, size: 22),
                onPressed: (currentFileTypeOpen == 'SuccessFully')
                    ? _savePDF
                    : _notSuccessFully,
                tooltip: 'Save',
              ),
              // Zoom Controls (Beautified Pill)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.zoom_out,
                          size: 22, color: Colors.black),
                      onPressed: () {
                        setState(() {
                          _currentZoomLevel -= 0.25;
                          if (_currentZoomLevel < 1.0) _currentZoomLevel = 1.0;

                          final isPdf =
                              (currentFileType ?? '').toLowerCase() == 'pdf';
                          if (!_isGridMode && isPdf) {
                            _pdfViewerController.zoomLevel = _currentZoomLevel;
                          } else if (!_isGridMode) {
                            _imageZoomController.value = Matrix4.identity()
                              ..scale(_currentZoomLevel);
                          }
                        });
                      },
                      tooltip: 'ซูมออก',
                    ),
                    IconButton(
                      icon: const Icon(Icons.zoom_in,
                          size: 22, color: Colors.black),
                      onPressed: () {
                        setState(() {
                          _currentZoomLevel += 0.25;
                          if (_currentZoomLevel > 5.0) _currentZoomLevel = 5.0;

                          final isPdf =
                              (currentFileType ?? '').toLowerCase() == 'pdf';
                          if (!_isGridMode && isPdf) {
                            if (_currentZoomLevel > 3.0)
                              _currentZoomLevel = 3.0;
                            _pdfViewerController.zoomLevel = _currentZoomLevel;
                          } else if (!_isGridMode) {
                            _imageZoomController.value = Matrix4.identity()
                              ..scale(_currentZoomLevel);
                          }
                        });
                      },
                      tooltip: 'ซูมเข้า',
                    ),
                  ],
                ),
              ),
              // View Mode Toggle (Segmented Pill)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "มุมมอง : ",
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: Font_.Fonts_T,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // PDF View Button
                      Container(
                        decoration: BoxDecoration(
                          color:
                              !_isGridMode ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.picture_as_pdf,
                            size: 20,
                            color: !_isGridMode
                                ? Colors.indigo[600]
                                : Colors.black54,
                          ),
                          onPressed: () {
                            if (_isGridMode) {
                              setState(() {
                                _isGridMode = false;
                              });
                            }
                          },
                          tooltip: 'ดูเอกสาร PDF',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Container(
                          width: 1,
                          height: 20,
                          color: Colors.black.withOpacity(0.2),
                        ),
                      ),
                      // Grid View Button
                      Container(
                        decoration: BoxDecoration(
                          color:
                              _isGridMode ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.grid_view,
                            size: 20,
                            color: _isGridMode
                                ? Colors.indigo[600]
                                : Colors.black54,
                          ),
                          onPressed: () {
                            if (!_isGridMode) {
                              setState(() {
                                _isGridMode = true;
                              });
                            }
                          },
                          tooltip: 'ดูแบบ Grid (ทุกไฟล์)',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Right: Status hints and Review button
          if (isReviewsPending && widget.viewver == false && !_isGridMode)
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Translate.TranslateAndSet_TextAutoSize(
                    '*โปรดตรวจสอบความถูกต้องของเอกสารก่อนกดยืนยัน ',
                    CustomerScreen_Color.Colors_Text2_,
                    TextAlign.center,
                    null,
                    Font_.Fonts_T,
                    12,
                    16,
                    1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: SizedBox(
                    width: 140,
                    height: 38,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.grey.shade900),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        _showNeedsUpdateOrRejectedDialog(context);
                      },
                      child: Translate.TranslateAndSet_TextAutoSize(
                        'ตรวจสอบเอกสาร',
                        CustomerScreen_Color.Colors_Text3_,
                        TextAlign.center,
                        null,
                        Font_.Fonts_T,
                        12,
                        16,
                        1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ============== Dialogs ==============
  Future<void> _showNextDialog(BuildContext context) async {
    final screenSize = MediaQuery.of(context).size;
    const dialogWidth = 400.0;
    const topMargin = 20.0;
    const rightMargin = 20.0;

    // 👉 เริ่มต้นขวาบน
    Offset position = Offset(
      screenSize.width - dialogWidth - rightMargin,
      topMargin,
    );

    int selectedOption = 1; // 0 = needs_update, 1 = rejected
    TextEditingController reasonController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    String reason = '';
    // List status_list = ['needs_update', 'rejected', 'approved'];
    List status_list = ['needs_update', 'approved'];
    bool submitting = false; // << ย้ายออกมาอยู่นอก StatefulBuilder

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Stack(
              children: [
                Positioned(
                  left: position.dx,
                  top: position.dy,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setStateDialog(() {
                        position += details.delta;
                      });
                    },
                    child: Material(
                      color: Colors.transparent,
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 450),
                          child: AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                                children: [
                                  TextSpan(
                                      text:
                                          '${idxDocs != null ? "[${idxDocs! + 1}/${widget.docs.length}]" : ""} ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(text: 'ไม่พบเอกสาร'),
                                ],
                              ),
                            ),
                            content: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: submitting
                                    ? null
                                    : () => Navigator.pop(context),
                                child: const Text('ยกเลิก'),
                              ),
                              ElevatedButton(
                                onPressed: submitting
                                    ? null
                                    : () async {
                                        setStateDialog(() => submitting = true);
                                        try {
                                          final attachments_Uuid =
                                              currentUuid?.toString() ?? '';

                                          // ไปเอกสารถัดไป
                                          final prevIndex = idxDocs;
                                          int? next;
                                          if (prevIndex != null) {
                                            next = prevIndex + 1;
                                            if (next < widget.docs.length) {
                                              await selectDocAt(next);
                                            }
                                          }

                                          if (Navigator.of(context).canPop()) {
                                            Navigator.pop(context);
                                            final isLast = next == null ||
                                                next >= widget.docs.length;
                                            if (isLast) {
                                              Navigator.pop(context, {
                                                'message': ResponseReviews,
                                                'isopenapproved':
                                                    is_open_approved,
                                              });
                                            }
                                          }
                                        } finally {
                                          if (context.mounted) {
                                            setStateDialog(
                                                () => submitting = false);
                                          }
                                        }
                                      },
                                child: submitting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Text('ถัดไป'),
                              ),
                            ],
                          )),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

//////////////////////////-------------------------->
  /// แปลงค่าเป็น 'yyyy-MM-dd' หรือคืน null ถ้าถือว่าไม่มีค่า
  /// รับได้: DateTime, String ('2025-08-20', '2025-08-20 00:00:00', '20/08/2025', '20/8/2568'), อื่น ๆ
  String? _normDate(dynamic v) {
    if (v == null) return null;

    // 1) DateTime ตรง ๆ
    if (v is DateTime) {
      return DateFormat('yyyy-MM-dd').format(v);
    }

    // 2) String หลายรูปแบบ
    if (v is String) {
      final s0 = v.trim();
      if (s0.isEmpty || s0 == 'เลือกวันที่') return null;

      // 2.1 ลอง ISO/มาตรฐานก่อน
      try {
        final dt =
            DateTime.parse(s0); // รองรับ 'yyyy-MM-dd' และ 'yyyy-MM-dd HH:mm:ss'
        return DateFormat('yyyy-MM-dd').format(dt);
      } catch (_) {/* ไปต่อข้างล่าง */}

      // 2.2 รองรับ 'yyyy-MM-dd HH:mm:ss'
      final isoLike = RegExp(r'^(\d{4}-\d{2}-\d{2})\s+\d{2}:\d{2}:\d{2}$');
      final mIso = isoLike.firstMatch(s0);
      if (mIso != null) {
        return mIso.group(1); // ส่วนวันที่ล้วน
      }

      // 2.3 รองรับ DD/MM/YYYY หรือ D/M/YYYY (คริสต์ศักราช)
      final dmy = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$');
      final mDmy = dmy.firstMatch(s0);
      if (mDmy != null) {
        final d = int.parse(mDmy.group(1)!);
        final m = int.parse(mDmy.group(2)!);
        var y = int.parse(mDmy.group(3)!);
        // เผื่อกรณีปีไทย (B.E. ~ 2500+)
        if (y > 2400) y -= 543;
        try {
          return DateFormat('yyyy-MM-dd').format(DateTime(y, m, d));
        } catch (_) {}
      }

      // 2.4 เผื่อรูปแบบอื่น ๆ: ตัดให้เหลือ 10 ตัวแรก ถ้าเป็นสตริงยาว ๆ
      if (s0.length >= 10) {
        final head10 = s0.substring(0, 10);
        // ลอง parse อีกที
        try {
          final dt = DateTime.parse(head10);
          return DateFormat('yyyy-MM-dd').format(dt);
        } catch (_) {
          // ไม่ได้จริง ๆ ก็คืนหัว 10 ตัว (ผู้ใช้จะยังเห็นวันที่)
          return head10;
        }
      }

      // 2.5 สุดท้าย คืนสตริงเดิม (แต่ปกติควรหลีกเลี่ยง)
      return s0;
    }

    // 3) ชนิดอื่น ๆ: แปลงเป็นสตริงแล้วลอง parse
    final s = v.toString();
    return s.isEmpty ? null : _normDate(s);
  }

  bool computeHasChanges(
      List<ReviewDetail> payments, dynamic editBankId, dynamic editPdate) {
    final originalBankId =
        payments.isNotEmpty ? payments.first.payment?.bankAccountId : null;
    final originalSlipDate =
        payments.isNotEmpty ? payments.first.payment?.slipDate : null;
    return !_idEquals(editBankId, originalBankId) ||
        _normDate(editPdate) != _normDate(originalSlipDate);
  }

  Future<void> _showNeedsUpdateOrRejectedDialog(BuildContext context) async {
    final screenSize = MediaQuery.of(context).size;
    const dialogWidth = 400.0;
    const topMargin = 20.0;
    const rightMargin = 20.0;

    // 👉 เริ่มต้นขวาบน
    Offset position = Offset(
      screenSize.width - dialogWidth - rightMargin,
      topMargin,
    );

    int selectedOption = 1; // 0 = needs_update, 1 = rejected
    TextEditingController reasonController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    String reason = '';
    // List status_list = ['needs_update', 'rejected', 'approved'];
    List status_list = ['needs_update', 'approved'];
    bool submitting = false; // << ย้ายออกมาอยู่นอก StatefulBuilder

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final firstPayment = widget.payment.first.payment;
            final uuidPayment = firstPayment.uuid;
            final slipDate = firstPayment
                ?.slipDate; // อย่าใส่ 'เลือกวันที่' ที่นี่ ให้เป็น null/จริง
            final bankAccountId = firstPayment?.bankAccountId;
            final paymentMethodId = firstPayment?.paymentMethodId;
            final amount = firstPayment?.amount;

            final bool hasChanges =
                !_idEquals(bankaccountId_Edit, bankAccountId) ||
                    _normDate(Pdate_Edit) != _normDate(slipDate);

            final bool canSubmit = hasChanges && !submitting;
            return Stack(
              children: [
                Positioned(
                  left: position.dx,
                  top: position.dy,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setStateDialog(() {
                        position += details.delta;
                      });
                    },
                    child: Material(
                      color: Colors.transparent,
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 450),
                          child: AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: (selectedOption == 1)
                                ? RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black),
                                      children: [
                                        TextSpan(
                                            text:
                                                '${idxDocs != null ? "[${idxDocs! + 1}/${widget.docs.length}]" : ""} เอกสารผ่านเกณฑ์ ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        TextSpan(text: 'ถูกต้องครบถ้วน'),
                                      ],
                                    ),
                                  )
                                : RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black),
                                      children: [
                                        TextSpan(
                                          text:
                                              '${idxDocs != null ? "[${idxDocs! + 1}/${widget.docs.length}]" : ""} เอกสารไม่ผ่านเกณฑ์ ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                            text:
                                                'ท่านต้องการแจ้งให้แก้ไขเอกสารหรือไม่'),
                                      ],
                                    ),
                                  ),
                            content: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RadioListTile<int>(
                                    value: 0,
                                    groupValue: selectedOption,
                                    onChanged: (value) {
                                      setStateDialog(() {
                                        selectedOption = value!;
                                        reasonController.clear();
                                        reason = '';
                                      });
                                    },
                                    title: const Text(
                                        'แจ้งผู้ส่งคำร้องให้แก้ไขเอกสาร'),
                                  ),
                                  if (selectedOption == 0)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: TextFormField(
                                        controller: reasonController,
                                        maxLines: 2,
                                        onChanged: (val) =>
                                            setStateDialog(() => reason = val),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'กรุณากรอกข้อมูล';
                                          } else if (value.length < 5) {
                                            return 'กรุณากรอกอย่างน้อย 5 ตัวอักษร';
                                          }
                                          return null;
                                        },
                                        decoration: const InputDecoration(
                                          hintText: 'โปรดกรอกรายละเอียด...',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  RadioListTile<int>(
                                    value: 1,
                                    groupValue: selectedOption,
                                    onChanged: (value) {
                                      setStateDialog(() {
                                        selectedOption = value!;
                                        reasonController.clear();
                                        reason = '';
                                      });
                                    },
                                    title: const Text(
                                      'เอกสารผ่านเกณฑ์, ถูกต้องครบถ้วน',
                                    ),
                                  ),
                                  if ((idxDocs! + 1) == 8 &&
                                      selectedOption == 1)
                                    Card(
                                      elevation: 1.0, // Adds a shadow effect
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10.0), // Rounded corners
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            buildEditPaymentSection(
                                                context,
                                                _list,
                                                widget.payment,
                                                setState),
                                            SizedBox(
                                              height: 15,
                                            ),
                                            ElevatedButton(
                                              onPressed: submitting
                                                  ? null
                                                  : () async {
                                                      // กันกดซ้ำ
                                                      setStateDialog(() =>
                                                          submitting = true);

                                                      try {
                                                        // 1) เตรียมค่า base
                                                        final headers =
                                                            await MyHeaders
                                                                .build(); // มี token อะไรของคุณ
                                                        final uri = Uri.parse(
                                                            '${MyConstant().domain_v1}/admin/approvals/payments');

                                                        // 2) รวม headers ให้ถูก (ต้องบอก JSON ชัดเจน)
                                                        final mergedHeaders =
                                                            <String, String>{
                                                          ...headers,
                                                          'Accept':
                                                              'application/json',
                                                          'Content-Type':
                                                              'application/json',
                                                        };

                                                        // 3) ค่าอ้างอิง (ใช้ค่าที่แก้ ถ้าไม่มีใช้ค่าเดิม)
                                                        final _methodId =
                                                            paymentMethodId_Edit;
                                                        final _bankId = (_methodId ==
                                                                2)
                                                            ? bankaccountId_Edit ??
                                                                0
                                                            : (_methodId == 2)
                                                                ? 0
                                                                : bankaccountId_Edit ??
                                                                    bankAccountId;
                                                        final _slipDate =
                                                            Pdate_Edit ??
                                                                slipDate;
                                                        // print(_methodId);
                                                        // print(_bankId);
                                                        // print(_methodId);

                                                        // 4) ตรวจค่าที่จำเป็นครบไหม
                                                        final bool check =
                                                            _methodId != null &&
                                                                _bankId !=
                                                                    null &&
                                                                _slipDate !=
                                                                    null;
                                                        if (!check) {
                                                          Dialog_error(context,
                                                              'แก้ไขไม่สำเร็จ: กรุณากรอกให้ครบ (ช่องทาง/บัญชี/วันที่)');
                                                          return; // ออกก่อนเลย
                                                        }

                                                        // 5) เตรียม payload (ยืนยัน amount ว่าเป็น double)
                                                        final double amt = double
                                                                .tryParse(amount
                                                                    .toString()) ??
                                                            0.0;
                                                        final payload =
                                                            <String, dynamic>{
                                                          'payment_uuid':
                                                              uuidPayment,
                                                          'method_id':
                                                              _methodId, // int
                                                          'bank_id':
                                                              _bankId, // int
                                                          // "slip_time": "11:29:45",
                                                          'slip_date':
                                                              _slipDate, // 'yyyy-MM-dd'
                                                          'amount':
                                                              amt, // double
                                                          "note":
                                                              "แก้ไข(ช่องทาง/บัญชี/วันที่)"
                                                        };
                                                        // print(uri);
                                                        // print(payload);
                                                        // 6) ยิง API
                                                        final resp = await http
                                                            .post(
                                                              uri,
                                                              headers:
                                                                  mergedHeaders,
                                                              body: jsonEncode(
                                                                  payload),
                                                            )
                                                            .timeout(
                                                                const Duration(
                                                                    seconds:
                                                                        20));

                                                        if (resp.statusCode ==
                                                                200 ||
                                                            resp.statusCode ==
                                                                201) {
                                                          // Dialog_success(context,
                                                          //     'บันทึกการอนุมัติการชำระเงินสำเร็จ');
                                                          // if (Navigator.of(context)
                                                          //     .canPop()) {
                                                          //   Navigator.pop(
                                                          //       context); // ปิด dialog ชั้นนี้พอ
                                                          // }
                                                          Dialog_success(
                                                              context,
                                                              'อัพเดทข้อมูลการชำระเงินเรียบร้อยแล้ว');
                                                        } else {
                                                          // อ่าน error ที่อ่านง่าย
                                                          String msg;
                                                          try {
                                                            final j =
                                                                jsonDecode(
                                                                    resp.body);
                                                            msg = j['message']
                                                                    ?.toString() ??
                                                                (j['error']
                                                                        ?.toString() ??
                                                                    resp.reasonPhrase ??
                                                                    'Unknown error');
                                                          } catch (_) {
                                                            msg = resp
                                                                    .reasonPhrase ??
                                                                'Unknown error';
                                                          }
                                                          Dialog_error(context,
                                                              'บันทึกไม่สำเร็จ (${resp.statusCode})\n$msg');
                                                        }
                                                      } on TimeoutException {
                                                        Dialog_error(context,
                                                            'หมดเวลาเชื่อมต่อ (timeout)');
                                                      } catch (e) {
                                                        Dialog_error(context,
                                                            'เกิดข้อผิดพลาด: $e');
                                                      } finally {
                                                        if (context.mounted) {
                                                          setStateDialog(() =>
                                                              submitting =
                                                                  false);
                                                        }
                                                      }
                                                    },
                                              child:
                                                  const Text('บันทึกการแก้ไข'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors
                                                    .black, // Background color of the button
                                                foregroundColor: Colors.white,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: submitting
                                    ? null
                                    : () => Navigator.pop(context),
                                child: const Text('ยกเลิก'),
                              ),
                              (selectedOption == 1)
                                  ? ElevatedButton(
                                      onPressed: submitting
                                          ? null
                                          : () async {
                                              setStateDialog(
                                                  () => submitting = true);
                                              try {
                                                final attachments_Uuid =
                                                    currentUuid?.toString() ??
                                                        '';
                                                final response =
                                                    await Post_ReviewsAttachMents(
                                                  staTus: 'approved',
                                                  requestUuid:
                                                      currentRequestUuid
                                                              ?.toString() ??
                                                          '',
                                                  attachmentsUuid:
                                                      attachments_Uuid,
                                                  descripTion:
                                                      '', // อนุมัติไม่ต้องมีเหตุผลก็ได้
                                                );

                                                if (response != null &&
                                                    (response.statusCode ==
                                                            200 ||
                                                        response.statusCode ==
                                                            201 ||
                                                        response.statusCode ==
                                                            409)) {
                                                  ResponseReviews =
                                                      response.body;
                                                  final resultxx = json
                                                      .decode(ResponseReviews);
                                                  is_open_approved = resultxx[
                                                              'data']?[
                                                          'is_open_approved'] ??
                                                      false;

                                                  // อัปเดต state หน้าหลักให้ "อนุมัติแล้ว"
                                                  if (mounted) {
                                                    setState(() {
                                                      if (currentUuid != null)
                                                        _approvedUuids
                                                            .add(currentUuid!);
                                                      currentStatusReviewer =
                                                          'approved'; // กันปุ่มกลับมา
                                                      // สะท้อนใน list ถ้าแก้ได้
                                                      final i = idxDocs;
                                                      if (i != null &&
                                                          i >= 0 &&
                                                          i <
                                                              widget.docs
                                                                  .length) {
                                                        try {
                                                          widget
                                                                  .docs[i]
                                                                  .attachment
                                                                  ?.status =
                                                              'approved';
                                                        } catch (_) {}
                                                      }
                                                    });
                                                  }

                                                  // ไปเอกสารถัดไป
                                                  final prevIndex = idxDocs;
                                                  int? next;
                                                  if (prevIndex != null) {
                                                    next = prevIndex + 1;
                                                    if (next <
                                                        widget.docs.length) {
                                                      await selectDocAt(next);
                                                    }
                                                  }

                                                  if (Navigator.of(context)
                                                      .canPop()) {
                                                    Navigator.pop(context);
                                                    final isLast = next ==
                                                            null ||
                                                        next >=
                                                            widget.docs.length;
                                                    if (isLast) {
                                                      Navigator.pop(context, {
                                                        'message':
                                                            ResponseReviews,
                                                        'isopenapproved':
                                                            is_open_approved,
                                                      });
                                                    }
                                                  }
                                                } else if (response != null) {
                                                  final jsonResponse = json
                                                      .decode(response.body);
                                                  Dialog_error(context,
                                                      '${jsonResponse['message']}');
                                                } else {
                                                  Dialog_error(context,
                                                      'ไม่พบการตอบกลับจากเซิร์ฟเวอร์');
                                                }
                                              } finally {
                                                if (context.mounted) {
                                                  setStateDialog(
                                                      () => submitting = false);
                                                }
                                              }
                                            },
                                      child: submitting
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2),
                                            )
                                          : Text('ยืนยัน'),
                                    )
                                  : ElevatedButton(
                                      onPressed: (reason.trim().isEmpty ||
                                              submitting)
                                          ? null
                                          : () async {
                                              if (!_formKey.currentState!
                                                  .validate()) return;

                                              setStateDialog(
                                                  () => submitting = true);
                                              try {
                                                final attachments_Uuid =
                                                    currentUuid?.toString() ??
                                                        '';
                                                final response =
                                                    await Post_ReviewsAttachMents(
                                                  staTus: status_list[
                                                      selectedOption], // needs_update หรือ rejected
                                                  requestUuid:
                                                      currentRequestUuid
                                                              ?.toString() ??
                                                          '',
                                                  attachmentsUuid:
                                                      attachments_Uuid,
                                                  descripTion: reasonController
                                                      .text
                                                      .toString(), // ส่งเหตุผล
                                                );

                                                if (response != null &&
                                                    (response.statusCode ==
                                                            200 ||
                                                        response.statusCode ==
                                                            201 ||
                                                        response.statusCode ==
                                                            409)) {
                                                  ResponseReviews =
                                                      response.body;

                                                  // อัปเดตสถานะเอกสารในหน้า (เป็น needs_update/rejected)
                                                  if (mounted) {
                                                    setState(() {
                                                      currentStatusReviewer =
                                                          status_list[
                                                              selectedOption];
                                                      // ถ้าแก้ object ได้ ให้สะท้อนใน list ด้วย
                                                      final i = idxDocs;
                                                      if (i != null &&
                                                          i >= 0 &&
                                                          i <
                                                              widget.docs
                                                                  .length) {
                                                        try {
                                                          widget
                                                                  .docs[i]
                                                                  .attachment
                                                                  ?.status =
                                                              status_list[
                                                                  selectedOption];
                                                        } catch (_) {}
                                                      }
                                                    });
                                                  }

                                                  // ไปเอกสารถัดไป
                                                  if (idxDocs != null) {
                                                    final next = idxDocs! + 1;
                                                    if (next <
                                                        widget.docs.length) {
                                                      await selectDocAt(next);
                                                    }
                                                    if (Navigator.of(context)
                                                        .canPop()) {
                                                      Navigator.pop(context);
                                                      final isLast =
                                                          next == null ||
                                                              next >=
                                                                  widget.docs
                                                                      .length;
                                                      if (isLast) {
                                                        Navigator.pop(context, {
                                                          'message':
                                                              ResponseReviews,
                                                          'isopenapproved':
                                                              is_open_approved,
                                                        });
                                                      }
                                                    }
                                                  }

                                                  // if (Navigator.of(context)
                                                  //     .canPop()) {
                                                  //   Navigator.pop(context,
                                                  //       reasonController.text);
                                                  // }
                                                } else if (response != null) {
                                                  final jsonResponse = json
                                                      .decode(response.body);
                                                  Dialog_error(context,
                                                      '${jsonResponse['message']}');
                                                } else {
                                                  Dialog_error(context,
                                                      'ไม่พบการตอบกลับจากเซิร์ฟเวอร์');
                                                }
                                              } finally {
                                                if (context.mounted) {
                                                  setStateDialog(
                                                      () => submitting = false);
                                                }
                                              }
                                            },
                                      child: submitting
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2),
                                            )
                                          : const Text('ยืนยัน'),
                                    ),
                            ],
                          )),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildEditPaymentSection(
    BuildContext context,
    List list,
    List<ReviewDetail> payments,
    StateSetter update,
  ) {
    // print('widget.payment');
    // print(widget.payment.first.payment);

    if (payments.isEmpty) {
      return const Text("ไม่มีข้อมูลการชำระเงิน");
    }

    final firstPayment = payments.first.payment;
    final amountReceived = firstPayment?.amountReceived;
    final slipDate = firstPayment?.slipDate ?? 'เลือกวันที่';
    final bankAccountId = firstPayment?.bankAccountId;

    // ถ้ามีค่าที่ผู้ใช้แก้ไว้ (เช่น bankaccountId_Edit / Pdate_Edit) ให้ใช้ค่านั้นก่อน
    final initialItem = _findInitialItem(
      _list,
      bankaccountId_Edit ?? bankAccountId,
    );

    return Container(
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.all(
      //     Radius.circular(6),
      //   ),
      //   border: Border.all(color: Colors.grey, width: 0.7),
      // ),
      child: Column(
        children: [
          const SizedBox(height: 1),
          const Divider(),
          const SizedBox(height: 1),
          // Center(
          //   child: CircleAvatar(
          //     radius: 20,
          //     backgroundColor: Colors.teal,
          //     child: Icon(
          //       Icons.attach_money,
          //       color: Colors.white,
          //       size: 20,
          //     ),
          //   ),
          // ),
          // SizedBox(
          //   height: 2,
          // ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Translate.TranslateAndSetText(
                      'รูปแบบชำระ',
                      PeopleChaoScreen_Color.Colors_Text2_,
                      TextAlign.start,
                      null,
                      Font_.Fonts_T,
                      14,
                      1,
                      // PeopleChaoScreen_Color.Colors_Text2_,
                      // TextAlign.start,
                      // FontWeight.bold,
                      // FontWeight_.Fonts_T,
                      // 14,
                      // 1,
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.payment, size: 18, color: Colors.grey),
                  ],
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                flex: 2,
                child: Container(
                    padding: const EdgeInsets.all(2.0),
                    child: CustomDropdown<PaymentsModelCMM>(
                      overlayHeight: 400,
                      items: _list, // ✅ ใช้ list ที่รับมา
                      initialItem: initialItem, // ✅ ปลอดภัยเมื่อหาไม่เจอ
                      // hintText: 'เลือกรูปแบบชำระ',
                      // initialItem: _list.isNotEmpty
                      //     ? _list
                      //         .where((element) =>
                      //             element.meta!.first.bank_id.toString() ==
                      //             '$bankAccountId')
                      //         .first
                      //     : null, // เริ่มต้นเลือกตัวแรก ถ้ามี
                      onChanged: (PaymentsModelCMM? selectedItem) {
                        update(() {
                          paymentMethodId_Edit = null;
                          paymentMethodCode_Edit = null;
                          bankaccountId_Edit = null;
                        });
                        if (selectedItem != null) {
                          // print('✅ พบข้อมูลช่องทางการชำระเงิน');
                          // print(
                          //     '➡️ UUID Method          : ${selectedItem.uuid}');
                          // print('➡️ Payment Method ID    : ${selectedItem.id}');
                          // print(
                          //     '➡️ Payment Code         : ${selectedItem.code}');

                          final hasMeta =
                              selectedItem.meta?.isNotEmpty ?? false;

                          int bankId = 0;
                          if (selectedItem.id == 2) {
                            update(() {
                              paymentMethodId_Edit = selectedItem.id ?? 0;
                              paymentMethodCode_Edit =
                                  selectedItem.code ?? ''; // ✅ ไม่ใช่ id
                              bankaccountId_Edit = null;
                            });
                          } else if (hasMeta) {
                            final meta = selectedItem.meta!.first;
                            bankId = meta.bank_id ?? 0;

                            // print('➡️ Bank ID              : ${meta.bank_id}');
                            // print(
                            //     '➡️ Bank Name            : ${meta.bank_names}');
                            // print(
                            //     '➡️ Bank Account         : ${meta.bank_account}');
                            update(() {
                              paymentMethodId_Edit = selectedItem.id ?? 0;
                              paymentMethodCode_Edit =
                                  selectedItem.code ?? ''; // ✅ ไม่ใช่ id
                              bankaccountId_Edit = meta?.bank_id;
                            });
                          } else {
                            // print('ℹ️ ไม่มีข้อมูลธนาคาร (meta ว่างหรือไม่มี)');
                          }
                        } else {
                          //  print('❌ selectedItem เป็น null');
                        }

                        //  print('----------------------------------');
                      },
                      // แสดงชื่อธนาคารใน header
                      headerBuilder: (context, item, isExpanded) => ListTile(
                        // title: Text(
                        //     item.meta != null && item.meta!.isNotEmpty
                        //         ? item.meta!.first.bank_names ?? ''
                        //         : item.name_th!),
                        title: Row(
                          children: [
                            CircleAvatar(
                              radius: 11,
                              backgroundImage: item.code! == 'CASH'
                                  ? AssetImage('images/LogoBank/CASH.png')
                                  : (item.meta != null && item.meta!.isNotEmpty
                                      ? AssetImage(
                                          'images/LogoBank/${item.meta!.first.bcode}.png')
                                      : null),
                              backgroundColor:
                                  (item.meta != null && item.meta!.isNotEmpty)
                                      ? Colors.transparent
                                      : (item.code! == 'CASH')
                                          ? Colors.transparent
                                          : Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.meta != null && item.meta!.isNotEmpty
                                    ? item.meta!.first.bank_names ?? ''
                                    : item.name_th!,
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        subtitle: item.meta != null && item.meta!.isNotEmpty
                            ? Text(
                                item.meta!.first.bank_account ?? ''!,
                                style: TextStyle(fontSize: 14),
                              )
                            : null,
                      ),
                      //  Text(
                      //   item.meta!.first.bank_names ?? '',
                      //   style: TextStyle(fontSize: 14),
                      // ),
                      // แสดงชื่อในรายการ dropdown
                      listItemBuilder: (context, item, isSelected, onTap) =>
                          ListTile(
                        title: Row(
                          children: [
                            CircleAvatar(
                              radius: 11,
                              backgroundImage: item.code! == 'CASH'
                                  ? AssetImage('images/LogoBank/CASH.png')
                                  : (item.meta != null && item.meta!.isNotEmpty
                                      ? AssetImage(
                                          'images/LogoBank/${item.meta!.first.bcode}.png')
                                      : null),
                              backgroundColor:
                                  (item.meta != null && item.meta!.isNotEmpty)
                                      ? Colors.transparent
                                      : (item.code! == 'CASH')
                                          ? Colors.transparent
                                          : Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.meta != null && item.meta!.isNotEmpty
                                    ? item.meta!.first.bank_names ?? ''
                                    : item.name_th!!,
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        subtitle: item.meta != null && item.meta!.isNotEmpty
                            ? Text(
                                item.meta!.first.bank_account ?? ''!,
                                style: TextStyle(fontSize: 14),
                              )
                            : null,
                        onTap: onTap,
                      ),
                      // validator: (PaymentsModelCMM? item) =>
                      //     item == null ? 'กรุณาเลือกรูปแบบชำระ' : null,
                      // validateOnChange: true,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 🔷 แถวสอง: จำนวนเงิน
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Translate.TranslateAndSetText(
                      'จำนวนเงิน',
                      PeopleChaoScreen_Color.Colors_Text2_,
                      TextAlign.start,
                      null,
                      Font_.Fonts_T,
                      14,
                      1,
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.payment, size: 18, color: Colors.grey),
                  ],
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                flex: 2,
                child: Form(
                  // key: _formKey_pay,
                  child: Container(
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      readOnly: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      cursorColor: Colors.green,
                      decoration: InputDecoration(
                        hintText: '$amountReceived',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontFamily: Font_.Fonts_T,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        border: InputBorder.none,
                      ),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9 .]')),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Row(
              children: [
                // วันที่ชำระ
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Translate.TranslateAndSetText(
                        'วันที่ชำระ',
                        PeopleChaoScreen_Color.Colors_Text2_,
                        TextAlign.start,
                        null,
                        Font_.Fonts_T,
                        14,
                        1,
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.calendar_month,
                          size: 18, color: Colors.grey),
                    ],
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: () async {
                      final DateTime? newDate = await pickThaiDate(context);
                      if (newDate == null) return;

                      update(() {
                        Pdate_Edit = DateFormat('yyyy-MM-dd').format(newDate);
                      });
                    },
                    child: Container(
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _displayDate(
                            slipDate, Pdate_Edit), // ✅ แสดงค่าที่แก้ ถ้ามี
                        // 'เลือกวันที่',
                        // slipDate == null ? 'เลือกวันที่' : '$slipDate',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade800,
                          fontFamily: Font_.Fonts_T,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }

  Future<void> _showApprovedDialog() async {
    int selectedOption = 1; // approved
    TextEditingController reasonController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    // List status_list = ['needs_update', 'rejected', 'approved'];
    List status_list = ['needs_update', 'approved'];

    bool submitting = false; // << ย้ายออกมานอก StatefulBuilder

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
                text: const TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(
                        text: 'เอกสารผ่านเกณฑ์ ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: 'ถูกต้องครบถ้วน'),
                  ],
                ),
              ),
              content: const SizedBox(height: 30),
              actions: [
                TextButton(
                  onPressed: submitting ? null : () => Navigator.pop(context),
                  child: const Text('ยกเลิก'),
                ),
                ElevatedButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          setStateDialog(() => submitting = true);
                          try {
                            final attachments_Uuid =
                                currentUuid?.toString() ?? '';
                            final response = await Post_ReviewsAttachMents(
                              staTus: 'approved',
                              requestUuid: currentRequestUuid?.toString() ?? '',
                              attachmentsUuid: attachments_Uuid,
                              descripTion: '', // อนุมัติไม่ต้องมีเหตุผลก็ได้
                            );

                            if (response != null &&
                                (response.statusCode == 200 ||
                                    response.statusCode == 201 ||
                                    response.statusCode == 409)) {
                              ResponseReviews = response.body;
                              final resultxx = json.decode(ResponseReviews);
                              is_open_approved = resultxx['data']
                                      ?['is_open_approved'] ??
                                  false;

                              // อัปเดต state หน้าหลักให้ "อนุมัติแล้ว"
                              if (mounted) {
                                setState(() {
                                  if (currentUuid != null)
                                    _approvedUuids.add(currentUuid!);
                                  currentStatusReviewer =
                                      'approved'; // กันปุ่มกลับมา
                                  // สะท้อนใน list ถ้าแก้ได้
                                  final i = idxDocs;
                                  if (i != null &&
                                      i >= 0 &&
                                      i < widget.docs.length) {
                                    try {
                                      widget.docs[i].attachment?.status =
                                          'approved';
                                    } catch (_) {}
                                  }
                                });
                              }

                              // ไปเอกสารถัดไป
                              final prevIndex = idxDocs;
                              int? next;
                              if (prevIndex != null) {
                                next = prevIndex + 1;
                                if (next < widget.docs.length) {
                                  await selectDocAt(next);
                                }
                              }

                              if (Navigator.of(context).canPop()) {
                                Navigator.pop(context);
                                if (next == 9) {
                                  Navigator.pop(context, {
                                    'message': ResponseReviews,
                                    'isopenapproved':
                                        is_open_approved, // ✅ Safe
                                  });
                                }
                              }
                            } else if (response != null) {
                              final jsonResponse = json.decode(response.body);
                              Dialog_error(
                                  context, '${jsonResponse['message']}');
                            } else {
                              Dialog_error(
                                  context, 'ไม่พบการตอบกลับจากเซิร์ฟเวอร์');
                            }
                          } finally {
                            if (context.mounted) {
                              setStateDialog(() => submitting = false);
                            }
                          }
                        },
                  child: submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('ยืนยัน'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
