// preview_pdf_ordit_cmm_grid.dart
//
// ✅ PreviewPdf_ordit_CMM (logic เดิม) + เพิ่มโหมด Grid แสดง "ทุกไฟล์" เป็นการ์ด
// - Viewer: Syncfusion SfPdfViewer (PDF) / Image.memory (รูป)
// - Grid: แสดงรายการไฟล์ทั้งหมด (lazy load thumbnail)
//    * PDF: ทำ thumbnail หน้าแรกด้วย package:pdfx
//    * Image (png/jpg/jpeg/webp): ใช้ bytes เดิมเป็น thumbnail
//    * ไฟล์อื่น: แสดงไอคอนแทน
// - มี Checkbox ในแต่ละไฟล์: default ✅ ติ๊กไว้ให้ทั้งหมด "ยกเว้น" รายการที่ไม่มีไฟล์
//
// IMPORTANT:
// 1) ต้องเพิ่ม dependency: pdfx ใน pubspec.yaml
// 2) ใช้ import แบบ prefix เพื่อกันชื่อชนกัน:  import 'package:pdfx/pdfx.dart' as px;
// 3) โค้ดนี้ยังเรียก API เดิมของคุณ: pdfimg_ReviewsFlow(attachmentUuid: uuid)
//
// NOTE: โค้ดนี้พยายาม "ไม่แตะ logic เดิม" ให้มากที่สุด แล้วแทรกเฉพาะส่วน Grid/thumbnail

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

// ✅ เพิ่ม pdfx สำหรับทำ thumbnail
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

class PreviewPdf_ordit_CMM2 extends StatefulWidget {
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

  const PreviewPdf_ordit_CMM2({
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
  State<PreviewPdf_ordit_CMM2> createState() => _PreviewPdf_ordit_CMM2State();
}

class _PreviewPdf_ordit_CMM2State extends State<PreviewPdf_ordit_CMM2> {
  // Viewer
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final PdfViewerController _pdfViewerController = PdfViewerController();
  final TransformationController _imageZoomController =
      TransformationController();
  double _currentZoomLevel = 1.0;

  // Search (เผื่อใช้งานต่อ)
  final TextEditingController _searchController = TextEditingController();
  PdfTextSearchResult _searchResult = PdfTextSearchResult();

  // Network bytes (PDF หรือรูป)
  Uint8List? _pdfBytes;
  bool _isLoading = true;
  String? _error;

  // ✅ โหมด Grid (แสดงไฟล์ทั้งหมด)
  bool _isGridMode = false;

  // Cache bytes by UUID to avoid re-downloading when switching docs
  final Map<String, Uint8List> _bytesByUuid = {};

  // Thumbnail + checkbox state (สำหรับ Grid)
  final Map<String, Uint8List> _thumbByUuid = {}; // uuid -> thumb bytes
  final Set<String> _thumbLoadingUuids = {}; // กันโหลดซ้ำ
  final Set<String> _checkedUuids = {}; // uuid ที่ถูกเลือก
  bool _checkedInitialized = false;

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

  // state overlay ไว้บนสุดของ State
  final Set<String> _approvedUuids = {}; // ใส่ uuid ของไฟล์ที่อนุมัติแล้ว
  List<PaymentsModelCMM> _list = [];

  bool get isReviewsPending =>
      currentFileTypeOpen == 'ReviewsFile' &&
      currentStatusReviewer == 'pending' &&
      !_approvedUuids.contains(currentUuid ?? '');

  bool _hasFileUuid(String? uuid) => uuid != null && uuid.trim().isNotEmpty;

  bool _isApprovedUuid(String? uuid) =>
      uuid != null && _approvedUuids.contains(uuid);

  ////////////////////------------------------->
  int? paymentMethodId_Edit;
  String? paymentMethodCode_Edit;
  int? bankaccountId_Edit;
  String? Pdate_Edit;
  ////////////////////------------------------->
  double _approveProgress = 0.0;
  int _approveCurrent = 0;
  int _approveTotal = 0;
  StateSetter? _approveDialogSetState;

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

  // -------------------------
  // ✅ init checkbox default: ติ๊กไว้ทุกไฟล์ที่ "มีไฟล์จริง"
  void _initCheckedDefaults() {
    if (_checkedInitialized) return;
    // ✅ User requested: "รอบแรกจะไม่มีการติ๊กให้จะมีปุ่มเลือกทั้งหมดก่อน"
    // Therefore, initially, do NOT check any items automatically.
    _checkedInitialized = true;
  }

  // -------------------------
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

  // ------------------------- “เลือกทั้งหมด”
  void _checkAll() {
    final eligible = _eligibleUuidsForCheck();
    setState(() {
      _checkedUuids.addAll(eligible);
    });
  }

  // ------------------------- “เลิกทั้งหมด”
  void _uncheckAll() {
    setState(() {
      _checkedUuids.clear();
    });
  }

  // -------------------------
  // Payments list
  List<PaymentsModelCMM> paymentsmodel = [];
  Future<void> red_payMent() async {
    final result = await read_GC_payment();
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
    try {
      final v = (obj as dynamic).toJson?.call();
      if (v is Map && v.containsKey(key)) return v[key];
    } catch (_) {}
    try {
      switch (key) {
        case 'attachment':
          return (obj as dynamic).attachment;
        case 'attachments':
          return (obj as dynamic).attachments;
      }
    } catch (_) {}
    if (obj is Map) return obj[key];
    return null;
  }

  // helper: อ่าน uuid จาก object/map/โมเดล
  String? _readUuid(dynamic obj) {
    if (obj == null) return null;
    try {
      final v = (obj as dynamic).uuid;
      if (v != null) return v.toString();
    } catch (_) {}
    if (obj is Map) {
      final v = obj['uuid'];
      if (v != null) return v.toString();
    }
    return null;
  }

  Future<void> _initIndexFromUuidThenLoad() async {
    final targetUuid = currentUuid?.toString();
    if (targetUuid == null || targetUuid.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'ไม่พบค่า UUID สำหรับค้นหาเอกสาร';
      });
      return;
    }

    bool _matchUuid(dynamic item, String uuid) {
      final att = _readUuid(_get(item, 'attachment'));
      if (att == uuid) return true;

      final atts = _get(item, 'attachments');
      if (atts is List) {
        for (final x in atts) {
          if (_readUuid(x) == uuid) return true;
        }
      } else {
        if (_readUuid(atts) == uuid) return true;
      }
      return false;
    }

    int i = widget.docs.indexWhere((d) => _matchUuid(d, targetUuid));

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
      // ❗ logic เดิมของคุณ: findAttachmentByDocId(...)
      final matched = findAttachmentByDocId(item.attachments ?? [], item.id);
      final file_Uuid = matched?.uuid ?? '';

      setState(() {
        currentUuid = file_Uuid.toString();
        currentTitle = item.nameTh;
      });
    }

    dynamic att = _pickAttachmentFrom(item, wantUuid: currentUuid);
    att ??= _getField(item, 'attachment');
    final doc = _getField(item, 'document');

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
      idxDocs = i;
      currentUuid = uuid;
      currentTitle = (title ?? '').toString();
      currentFileType = _normalizeFileType(fileType)?.toLowerCase();
      currentUploadedAt = uploadedAt?.toString();
      currentStatusReviewer = status?.toString();
      currentFileTypeOpen =
          (hasFile || approvedLocal) ? 'ReviewsFile' : 'pending';
      currentDisplayFileName = shown;

      _isLoading = true;
      _error = null;
      _pdfBytes = null;

      // กลับไป viewer เมื่อเลือกจาก grid
      _isGridMode = false;
    });

    _loadPdfBytesFor(currentUuid);
  }

  // ===== helpers =====
  dynamic _getField(dynamic obj, String key) {
    if (obj == null) return null;
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
    if (obj is Map) return obj[key];
    return null;
  }

  String? _readString(dynamic obj, String key) {
    if (obj == null) return null;
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
    if (obj is Map) return obj[key]?.toString();
    return null;
  }

  dynamic _pickAttachmentFrom(dynamic item, {String? wantUuid}) {
    if (wantUuid == null || wantUuid.isEmpty) return null;

    final atts = _getField(item, 'attachments');
    if (atts is List) {
      for (final x in atts) {
        final ux = _readString(x, 'uuid');
        if (ux == wantUuid) return x;
      }
    }

    if (atts != null) {
      final ux = _readString(atts, 'uuid');
      if (ux == wantUuid) return atts;
    }

    final att = _getField(item, 'attachment');
    if (att != null) {
      final ux = _readString(att, 'uuid');
      if (ux == wantUuid) return att;
    }

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

    // Return cached bytes immediately
    if (_bytesByUuid.containsKey(uuid)) {
      if (!mounted) return;
      setState(() {
        _pdfBytes = _bytesByUuid[uuid];
        _isLoading = false;
        _error = null;
      });
      if (widget.viewver == false && isReviewsPending) {
        await _showNeedsUpdateOrRejectedDialog(context);
      }
      return;
    }

    try {
      final response = await pdfimg_ReviewsFlow(attachmentUuid: uuid);
      if (!mounted) return;

      if (response != null && response.statusCode == 200) {
        _bytesByUuid[uuid] = response.bodyBytes; // cache
        setState(() {
          _pdfBytes = response.bodyBytes;
          _isLoading = false;
          _error = null;
        });

        if (widget.viewver == false && isReviewsPending) {
          await _showNeedsUpdateOrRejectedDialog(context);
        }
      } else {
        setState(() {
          _pdfBytes = null;
          _isLoading = false;
          _error = 'โหลดไฟล์ไม่สำเร็จ';
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
    await Printing.layoutPdf(onLayout: (format) async => _pdfBytes!);
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
        return img.bytes; // ถ้าเวอร์ชันคุณเป็น img.data ให้เปลี่ยนเป็น img.data
      }

      // อื่น ๆ ไม่ทำ thumb
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

  // ✅ Grid แสดง "ทุกไฟล์" (ไม่ใช่ทุกหน้าใน PDF)
  Widget _buildAllFilesGrid() {
    _initCheckedDefaults();

    if (widget.docs.isEmpty) {
      return const Center(child: Text('ไม่มีเอกสารในรายการ docs'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate dynamic columns based on screen width and zoom level.
        // Base width assumption for 1 column: ~120px.
        // We divide the available width by this base width scaled by the zoom level.
        double baseItemWidth = 100.0 * _currentZoomLevel;
        int calculatedCount = (constraints.maxWidth / baseItemWidth).floor();

        // STRICT CAP: Maximum 5 columns, Minimum 1 column.
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

            // พยายามอ่าน attachment / attachments ให้เจอ (รองรับทั้ง object และ list)
            dynamic att = _getField(item, 'attachment');
            final atts = _getField(item, 'attachments');
            if (att == null && atts is List && atts.isNotEmpty)
              att = atts.first;
            if (att == null && atts != null && atts is! List) att = atts;

            final uuid = _readString(att, 'uuid');
            final rawType =
                _readString(att, 'fileType') ?? _readString(att, 'file_type');
            final fileType = _normalizeFileType(rawType);

            // title: ดึงจาก document (ถ้ามี) ไม่งั้นดึงจาก item
            final doc = _getField(item, 'document');
            final title = _readString(doc, 'nameTh') ??
                _readString(doc, 'name_th') ??
                _readString(item, 'nameTh') ??
                _readString(item, 'name_th') ??
                'ไฟล์';

            final fileName =
                _readString(att, 'fileName') ?? _readString(att, 'file_name');

            final bool hasFile = _hasFileUuid(uuid);
            final bool isApproved = _isApprovedUuid(uuid);
            // final bool showCheckbox = hasFile && !isApproved;
            final status = _readString(att, 'status'); // ของการ์ดนั้น
            final bool showCheckbox = uuid != null &&
                uuid.isNotEmpty &&
                status == 'pending' &&
                !_approvedUuids.contains(uuid);
            // final bool showCheckbox = uuid != null &&
            //     uuid.isNotEmpty && // ✅ ต้องมีไฟล์จริง
            //     currentFileTypeOpen == 'ReviewsFile' &&
            //     currentStatusReviewer == 'pending' && // ✅ pending เท่านั้น
            //     !_approvedUuids.contains(uuid); // ✅ ยังไม่เคยอนุมัติ

            final thumb = hasFile ? _thumbByUuid[uuid] : null;
            final bool checked = showCheckbox && _checkedUuids.contains(uuid);

            // lazy load thumb
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
              clipBehavior: Clip.antiAlias,
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
                    if (showCheckbox)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Colors.white70,
                            shape: BoxShape.circle,
                          ),
                          child: Theme(
                            data: ThemeData(
                              unselectedWidgetColor: Colors.black54,
                            ),
                            child: Checkbox(
                              value: checked,
                              activeColor: Colors.green.shade600,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              onChanged: (v) {
                                setState(() {
                                  if (v == true) {
                                    _checkedUuids.add(uuid!);
                                  } else {
                                    _checkedUuids.remove(uuid);
                                  }
                                });
                              },
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

  Future<void> _showApproveProgressDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            _approveDialogSetState = setStateDialog; // ✅ เก็บไว้
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

    // ✅ กรองให้เหลือเฉพาะที่ "ติ๊กได้จริง" (กันหลุดเงื่อนไข)
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

          // ✅ เอาออกจากรายการที่เลือกทันที
          _checkedUuids.remove(uuid);

          // ✅ สะท้อนใน docs ทั้ง attachment และ attachments
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

      // ✅ update progress (ทำให้ dialog rebuild)
      _approveCurrent++;
      _approveProgress = _approveCurrent / _approveTotal;

      _approveDialogSetState?.call(() {}); // ✅ สำคัญมาก
    }

    if (!mounted) return;

    // ปิด progress dialog
    Navigator.of(context).pop();
    _approveDialogSetState = null;

    if (hasError) {
      Dialog_error(context, 'อนุมัติบางรายการไม่สำเร็จ');
    } else {
      final nav = Navigator.of(context);
      await Dialog_success(context, 'อนุมัติเอกสารที่เลือกเรียบร้อยแล้ว');
      if (mounted && nav.canPop()) nav.pop();
    }
  }

  // Future<void> _approveAllChecked() async {
  //   if (_checkedUuids.isEmpty) {
  //     Dialog_error(context, 'กรุณาเลือกเอกสารอย่างน้อย 1 รายการ');
  //     return;
  //   }

  //   // ✅ กรองเฉพาะ uuid ที่ "ควรอนุมัติได้จริง"
  //   final eligible = _eligibleUuidsForCheck(); // ฟังก์ชันที่ผมให้ไว้ก่อนหน้า
  //   final targets = _checkedUuids.where((u) => eligible.contains(u)).toList();

  //   if (targets.isEmpty) {
  //     Dialog_error(
  //         context, 'ไม่มีเอกสารที่อยู่ในสถานะรออนุมัติ (pending) ให้อนุมัติ');
  //     return;
  //   }

  //   bool hasError = false;
  //   dynamic lastResponseBody;
  //   bool? lastIsOpenApproved;

  //   // ✅ อัปเดต docs ให้ครบทั้ง attachment / attachments
  //   void markApprovedInDocs(String uuid) {
  //     for (final d in widget.docs) {
  //       // 1) attachment เดี่ยว
  //       try {
  //         if (d.attachment?.uuid?.toString() == uuid) {
  //           d.attachment.status = 'approved';
  //         }
  //       } catch (_) {}

  //       // 2) attachments เป็น list
  //       try {
  //         final atts = d.attachments;
  //         if (atts is List) {
  //           for (final a in atts) {
  //             try {
  //               if (a.uuid?.toString() == uuid) {
  //                 a.status = 'approved';
  //               }
  //             } catch (_) {}
  //           }
  //         } else if (atts != null) {
  //           // 3) attachments เป็น object เดี่ยว
  //           try {
  //             if (atts.uuid?.toString() == uuid) {
  //               atts.status = 'approved';
  //             }
  //           } catch (_) {}
  //         }
  //       } catch (_) {}
  //     }
  //   }

  //   for (final uuid in targets) {
  //     try {
  //       final response = await Post_ReviewsAttachMents(
  //         staTus: 'approved',
  //         requestUuid: currentRequestUuid?.toString() ?? '',
  //         attachmentsUuid: uuid,
  //         descripTion: '',
  //       );

  //       if (response != null &&
  //           (response.statusCode == 200 ||
  //               response.statusCode == 201 ||
  //               response.statusCode == 409)) {
  //         // ✅ เก็บ response ล่าสุด (ถ้าคุณต้องส่งกลับ)
  //         lastResponseBody = response.body;
  //         try {
  //           final j = jsonDecode(response.body);
  //           lastIsOpenApproved = j['data']?['is_open_approved'] == true;
  //         } catch (_) {}

  //         // ✅ mark approved
  //         if (mounted) {
  //           setState(() {
  //             _approvedUuids.add(uuid);
  //             _checkedUuids.remove(uuid); // เอาออกจากรายการที่เลือกทันที
  //           });
  //         }

  //         markApprovedInDocs(uuid);
  //       } else {
  //         hasError = true;
  //       }
  //     } catch (_) {
  //       hasError = true;
  //     }
  //   }

  //   if (!mounted) return;

  //   // ✅ แสดงผลลัพธ์
  //   if (hasError) {
  //     Dialog_error(context, 'อนุมัติบางรายการไม่สำเร็จ');
  //   } else {
  //     Dialog_success(context, 'อนุมัติเอกสารที่เลือกเรียบร้อยแล้ว');
  //   }

  //   // ✅ ถ้าคุณต้องการปิดหน้าแล้วส่งค่ากลับ
  //   Navigator.pop(context, {
  //     'message': lastResponseBody ?? ResponseReviews,
  //     'isopenapproved': lastIsOpenApproved ?? true,
  //   });
  // }

  // ==========================
  // UI
  @override
  Widget build(BuildContext context) {
    final calculatedWidth = MediaQuery.of(context).size.width;
    final idxDocsx = idxDocs ?? 0;
    final selectedCount = _checkedUuids.length;

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
                  ? "เลือกแล้ว $selectedCount รายการ"
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
          if (_isGridMode &&
              widget.viewver == false &&
              _checkedUuids.isNotEmpty) ...[
            // 🔴 เลิกทั้งหมด
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                icon: const Icon(Icons.clear_all, size: 18),
                label: Text(
                  'เลิกทั้งหมด (${_checkedUuids.length})',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                onPressed: _uncheckAll,
              ),
            ),

            // ✅ อนุมัติทั้งหมด
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                icon: const Icon(Icons.done_all, size: 18),
                label: Text(
                  'อนุมัติทั้งหมด (${_checkedUuids.length})',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                onPressed: _approveAllChecked,
              ),
            ),
          ],
          if (_isGridMode &&
              widget.viewver == false &&
              _checkedUuids.isEmpty) ...[
            // 🔵 เลือกทั้งหมด
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                icon: const Icon(Icons.check_box_outlined, size: 18),
                label: const Text(
                  'เลือกทั้งหมด',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                onPressed: _checkAll,
              ),
            ),
          ],
        ],

        // actions: [
        //   if (_isGridMode && widget.viewver == false) ...[
        //     if (_checkedUuids.isNotEmpty)
        //       Padding(
        //         padding: const EdgeInsets.only(right: 8),
        //         child: ElevatedButton.icon(
        //           style: ElevatedButton.styleFrom(
        //             backgroundColor: Colors.red.shade700,
        //             padding: const EdgeInsets.symmetric(horizontal: 10),
        //           ),
        //           icon: const Icon(Icons.clear_all,
        //               size: 18, color: Colors.white),
        //           label: Text(
        //             'เลิกทั้งหมด (${_checkedUuids.length})',
        //             style: const TextStyle(color: Colors.white, fontSize: 12),
        //           ),
        //           onPressed: _uncheckAll,
        //         ),
        //       ),
        //     Padding(
        //       padding: const EdgeInsets.only(right: 8),
        //       child: ElevatedButton.icon(
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: Colors.green.shade700,
        //           padding: const EdgeInsets.symmetric(horizontal: 10),
        //         ),
        //         icon: const Icon(Icons.done_all, size: 18, color: Colors.white),
        //         label: Text(
        //           'อนุมัติทั้งหมด (${_checkedUuids.length})',
        //           style: const TextStyle(color: Colors.white, fontSize: 12),
        //         ),
        //         onPressed: _approveAllChecked,
        //       ),
        //     ),
        //   ],
        // ],
      ),
      body: SizedBox(
        width: calculatedWidth,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  // ✅ ปุ่ม prev/next เฉพาะตอน viewer (grid ไม่ต้องมี)
                  if (!_isGridMode)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: IconButton(
                        icon: const Icon(Icons.navigate_before,
                            color: Colors.white),
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
                          bottomLeft: Radius.circular(15),
                        ),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: IconButton(
                        icon: const Icon(Icons.navigate_next,
                            color: Colors.white),
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (idxDocs == null) return;
                                final next = idxDocs! + 1;
                                if (next < widget.docs.length) {
                                  await selectDocAt(next);
                                }
                              },
                      ),
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
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));
    if (_pdfBytes == null)
      return const Center(child: Text('ไม่พบไฟล์สำหรับแสดงผล'));

    final isPdf = (currentFileType ?? '').toLowerCase() == 'pdf';

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
              _currentZoomLevel = details.newZoomLevel;
            },
          )
        else
          Center(
            child: InteractiveViewer(
              transformationController: _imageZoomController,
              minScale: 0.5,
              maxScale: 4.0,
              onInteractionUpdate: (details) {
                _currentZoomLevel =
                    _imageZoomController.value.getMaxScaleOnAxis();
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.memory(_pdfBytes!),
              ),
            ),
          ),
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
    final isSuccess = currentFileTypeOpen == 'SuccessFully';

    return Container(
      width: calculatedWidth,
      // Removed fixed height to allow Wrap/Column to grow
      decoration: BoxDecoration(
        color: Colors.indigo[400],
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // left controls
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.print, size: 22),
                onPressed: isSuccess ? _printPDF : _notSuccessFully,
                tooltip: 'Print',
              ),
              IconButton(
                icon: const Icon(Icons.save_alt, size: 22),
                onPressed: isSuccess ? _savePDF : _notSuccessFully,
                tooltip: 'Save',
              ),
              // Zoom Controls (Beautified Pill)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Container(
                  // decoration: BoxDecoration(
                  //   color: Colors.black.withOpacity(0.1),
                  //   borderRadius: BorderRadius.circular(30.0),
                  //   border: Border.all(
                  //     color: Colors.black.withOpacity(0.15),
                  //     width: 1,
                  //   ),
                  // ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        icon: const Icon(Icons.zoom_out,
                            size: 22, color: Colors.black),
                        onPressed: () {
                          setState(() {
                            _currentZoomLevel -= 0.25;
                            if (_currentZoomLevel < 1.0)
                              _currentZoomLevel = 1.0;

                            final isPdf =
                                (currentFileType ?? '').toLowerCase() == 'pdf';
                            if (!_isGridMode && isPdf) {
                              _pdfViewerController.zoomLevel =
                                  _currentZoomLevel;
                            } else if (!_isGridMode) {
                              _imageZoomController.value = Matrix4.identity()
                                ..scale(_currentZoomLevel);
                            }
                          });
                        },
                        tooltip: 'ซูมออก',
                      ),
                      Container(
                        width: 1,
                        height: 20,
                        color: Colors.black.withOpacity(0.2),
                      ),
                      IconButton(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        icon: const Icon(Icons.zoom_in,
                            size: 22, color: Colors.black),
                        onPressed: () {
                          setState(() {
                            _currentZoomLevel += 0.25;
                            // ขยายระดับการซูมสำหรับ Grid View ขึ้นเป็์น 5
                            if (_currentZoomLevel > 5.0)
                              _currentZoomLevel = 5.0;

                            final isPdf =
                                (currentFileType ?? '').toLowerCase() == 'pdf';
                            if (!_isGridMode && isPdf) {
                              // ขีดจำกัดของ PDF อยู่ที่ 3.0
                              if (_currentZoomLevel > 3.0)
                                _currentZoomLevel = 3.0;
                              _pdfViewerController.zoomLevel =
                                  _currentZoomLevel;
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
              ),
              // View Mode Toggle (Segmented Pill)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  // decoration: BoxDecoration(
                  //   color: Colors.black.withOpacity(0.1),
                  //   borderRadius: BorderRadius.circular(30.0),
                  //   border: Border.all(
                  //     color: Colors.black.withOpacity(0.15),
                  //     width: 1,
                  //   ),
                  // ),
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

          // right hint + review button (เดิม)

          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.end,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
              if (isReviewsPending && widget.viewver == false && !_isGridMode)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: SizedBox(
                    width: 140, // Slightly reduced to fit better
                    height: 38, // Explicit height
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

  // ============== Dialogs (ของเดิม) ==============
  Future<void> _showNextDialog(BuildContext context) async {
    final screenSize = MediaQuery.of(context).size;
    const dialogWidth = 400.0;
    const topMargin = 20.0;
    const rightMargin = 20.0;

    Offset position = Offset(
      screenSize.width - dialogWidth - rightMargin,
      topMargin,
    );

    bool submitting = false;

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
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black),
                              children: [
                                TextSpan(
                                  text:
                                      '${idxDocs != null ? "[${idxDocs! + 1}/${widget.docs.length}]" : ""} ',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(text: 'ไม่พบเอกสาร'),
                              ],
                            ),
                          ),
                          content: const SizedBox(height: 20),
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
                        ),
                      ),
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
    return list.isNotEmpty ? list.first : null;
  }

  String _displayDate(dynamic slipDate, dynamic edited) {
    if (edited != null) {
      if (edited is DateTime) return DateFormat('dd-MM-yyyy').format(edited);
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

  // ==========================
  // ส่วน Dialog รีวิว (ของเดิม) — คงตามที่คุณให้มา (ตัดบางส่วนออกไม่ได้)
  // ✅ คัดลอกมาจากโค้ดเดิมของคุณทั้งก้อนด้านล่าง
  //
  // NOTE: เนื้อหา dialog ยาวมาก แต่คงไว้ครบเพื่อให้ build ผ่าน
  // ==========================

  /// แปลงค่าเป็น 'yyyy-MM-dd' หรือคืน null ถ้าถือว่าไม่มีค่า
  String? _normDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) {
      return DateFormat('yyyy-MM-dd').format(v);
    }
    if (v is String) {
      final s0 = v.trim();
      if (s0.isEmpty || s0 == 'เลือกวันที่') return null;

      try {
        final dt = DateTime.parse(s0);
        return DateFormat('yyyy-MM-dd').format(dt);
      } catch (_) {}

      final isoLike = RegExp(r'^(\d{4}-\d{2}-\d{2})\s+\d{2}:\d{2}:\d{2}$');
      final mIso = isoLike.firstMatch(s0);
      if (mIso != null) return mIso.group(1);

      final dmy = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$');
      final mDmy = dmy.firstMatch(s0);
      if (mDmy != null) {
        final d = int.parse(mDmy.group(1)!);
        final m = int.parse(mDmy.group(2)!);
        var y = int.parse(mDmy.group(3)!);
        if (y > 2400) y -= 543;
        try {
          return DateFormat('yyyy-MM-dd').format(DateTime(y, m, d));
        } catch (_) {}
      }

      if (s0.length >= 10) {
        final head10 = s0.substring(0, 10);
        try {
          final dt = DateTime.parse(head10);
          return DateFormat('yyyy-MM-dd').format(dt);
        } catch (_) {
          return head10;
        }
      }
      return s0;
    }
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

    Offset position = Offset(
      screenSize.width - dialogWidth - rightMargin,
      topMargin,
    );

    int selectedOption = 1;
    TextEditingController reasonController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    String reason = '';
    List status_list = ['needs_update', 'approved'];
    bool submitting = false;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final firstPayment = widget.payment.first.payment;
            final uuidPayment = firstPayment.uuid;
            final slipDate = firstPayment?.slipDate;
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
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.black),
                                    children: [
                                      TextSpan(
                                        text:
                                            '${idxDocs != null ? "[${idxDocs! + 1}/${widget.docs.length}]" : ""} เอกสารผ่านเกณฑ์ ',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const TextSpan(text: 'ถูกต้องครบถ้วน'),
                                    ],
                                  ),
                                )
                              : RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.black),
                                    children: [
                                      TextSpan(
                                        text:
                                            '${idxDocs != null ? "[${idxDocs! + 1}/${widget.docs.length}]" : ""} เอกสารไม่ผ่านเกณฑ์ ',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const TextSpan(
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
                                      'เอกสารผ่านเกณฑ์, ถูกต้องครบถ้วน'),
                                ),

                                // โค้ดแก้ชำระเงิน (ของเดิม) — เรียก buildEditPaymentSection
                                if ((idxDocs! + 1) == 8 && selectedOption == 1)
                                  Card(
                                    elevation: 1.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
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
                                            setState,
                                          ),
                                          const SizedBox(height: 15),
                                          ElevatedButton(
                                            onPressed: submitting
                                                ? null
                                                : () async {
                                                    setStateDialog(() =>
                                                        submitting = true);

                                                    try {
                                                      final headers =
                                                          await MyHeaders
                                                              .build();
                                                      final uri = Uri.parse(
                                                          '${MyConstant().domain_v1}/admin/approvals/payments');

                                                      final mergedHeaders =
                                                          <String, String>{
                                                        ...headers,
                                                        'Accept':
                                                            'application/json',
                                                        'Content-Type':
                                                            'application/json',
                                                      };

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

                                                      final bool check =
                                                          _methodId != null &&
                                                              _bankId != null &&
                                                              _slipDate != null;
                                                      if (!check) {
                                                        Dialog_error(context,
                                                            'แก้ไขไม่สำเร็จ: กรุณากรอกให้ครบ (ช่องทาง/บัญชี/วันที่)');
                                                        return;
                                                      }

                                                      final double amt =
                                                          double.tryParse(amount
                                                                  .toString()) ??
                                                              0.0;
                                                      final payload =
                                                          <String, dynamic>{
                                                        'payment_uuid':
                                                            uuidPayment,
                                                        'method_id': _methodId,
                                                        'bank_id': _bankId,
                                                        'slip_date': _slipDate,
                                                        'amount': amt,
                                                        'note':
                                                            'แก้ไข(ช่องทาง/บัญชี/วันที่)'
                                                      };

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
                                                                seconds: 20),
                                                          );

                                                      if (resp.statusCode ==
                                                              200 ||
                                                          resp.statusCode ==
                                                              201) {
                                                        Dialog_success(context,
                                                            'อัพเดทข้อมูลการชำระเงินเรียบร้อยแล้ว');
                                                      } else {
                                                        String msg;
                                                        try {
                                                          final j = jsonDecode(
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
                                                            submitting = false);
                                                      }
                                                    }
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.black,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: const Text('บันทึกการแก้ไข'),
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                      ),
                                    ),
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
                            (selectedOption == 1)
                                ? ElevatedButton(
                                    onPressed: submitting
                                        ? null
                                        : () async {
                                            setStateDialog(
                                                () => submitting = true);
                                            try {
                                              final attachments_Uuid =
                                                  currentUuid?.toString() ?? '';
                                              final response =
                                                  await Post_ReviewsAttachMents(
                                                staTus: 'approved',
                                                requestUuid: currentRequestUuid
                                                        ?.toString() ??
                                                    '',
                                                attachmentsUuid:
                                                    attachments_Uuid,
                                                descripTion: '',
                                              );

                                              if (response != null &&
                                                  (response.statusCode == 200 ||
                                                      response.statusCode ==
                                                          201 ||
                                                      response.statusCode ==
                                                          409)) {
                                                ResponseReviews = response.body;
                                                final resultxx = json
                                                    .decode(ResponseReviews);
                                                is_open_approved = resultxx[
                                                            'data']
                                                        ?['is_open_approved'] ??
                                                    false;

                                                if (mounted) {
                                                  setState(() {
                                                    if (currentUuid != null) {
                                                      _approvedUuids
                                                          .add(currentUuid!);
                                                    }
                                                    currentStatusReviewer =
                                                        'approved';
                                                    final i = idxDocs;
                                                    if (i != null &&
                                                        i >= 0 &&
                                                        i <
                                                            widget
                                                                .docs.length) {
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
                                                  final isLast = next == null ||
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
                                                final jsonResponse =
                                                    json.decode(response.body);
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
                                                  currentUuid?.toString() ?? '';
                                              final response =
                                                  await Post_ReviewsAttachMents(
                                                staTus:
                                                    status_list[selectedOption],
                                                requestUuid: currentRequestUuid
                                                        ?.toString() ??
                                                    '',
                                                attachmentsUuid:
                                                    attachments_Uuid,
                                                descripTion:
                                                    reasonController.text,
                                              );

                                              if (response != null &&
                                                  (response.statusCode == 200 ||
                                                      response.statusCode ==
                                                          201 ||
                                                      response.statusCode ==
                                                          409)) {
                                                ResponseReviews = response.body;

                                                if (mounted) {
                                                  setState(() {
                                                    currentStatusReviewer =
                                                        status_list[
                                                            selectedOption];
                                                    final i = idxDocs;
                                                    if (i != null &&
                                                        i >= 0 &&
                                                        i <
                                                            widget
                                                                .docs.length) {
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

                                                if (idxDocs != null) {
                                                  final next = idxDocs! + 1;
                                                  if (next <
                                                      widget.docs.length) {
                                                    await selectDocAt(next);
                                                  }
                                                  if (Navigator.of(context)
                                                      .canPop()) {
                                                    Navigator.pop(context);
                                                    final isLast = next >=
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
                                                }
                                              } else if (response != null) {
                                                final jsonResponse =
                                                    json.decode(response.body);
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
                        ),
                      ),
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

  // ===== buildEditPaymentSection (ของเดิม) =====
  Widget buildEditPaymentSection(
    BuildContext context,
    List list,
    List<ReviewDetail> payments,
    StateSetter update,
  ) {
    if (payments.isEmpty) return const Text("ไม่มีข้อมูลการชำระเงิน");

    final firstPayment = payments.first.payment;
    final amountReceived = firstPayment?.amountReceived;
    final slipDate = firstPayment?.slipDate ?? 'เลือกวันที่';
    final bankAccountId = firstPayment?.bankAccountId;

    final initialItem = _findInitialItem(
      _list,
      bankaccountId_Edit ?? bankAccountId,
    );

    return Container(
      child: Column(
        children: [
          const SizedBox(height: 1),
          const Divider(),
          const SizedBox(height: 1),
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
                    items: _list,
                    initialItem: initialItem,
                    onChanged: (PaymentsModelCMM? selectedItem) {
                      update(() {
                        paymentMethodId_Edit = null;
                        paymentMethodCode_Edit = null;
                        bankaccountId_Edit = null;
                      });
                      if (selectedItem != null) {
                        final hasMeta = selectedItem.meta?.isNotEmpty ?? false;
                        if (selectedItem.id == 2) {
                          update(() {
                            paymentMethodId_Edit = selectedItem.id ?? 0;
                            paymentMethodCode_Edit = selectedItem.code ?? '';
                            bankaccountId_Edit = null;
                          });
                        } else if (hasMeta) {
                          final meta = selectedItem.meta!.first;
                          update(() {
                            paymentMethodId_Edit = selectedItem.id ?? 0;
                            paymentMethodCode_Edit = selectedItem.code ?? '';
                            bankaccountId_Edit = meta.bank_id;
                          });
                        }
                      }
                    },
                    headerBuilder: (context, item, isExpanded) => ListTile(
                      title: Row(
                        children: [
                          CircleAvatar(
                            radius: 11,
                            backgroundImage: item.code == 'CASH'
                                ? const AssetImage('images/LogoBank/CASH.png')
                                : (item.meta != null && item.meta!.isNotEmpty
                                    ? AssetImage(
                                        'images/LogoBank/${item.meta!.first.bcode}.png')
                                    : null),
                            backgroundColor:
                                (item.meta != null && item.meta!.isNotEmpty)
                                    ? Colors.transparent
                                    : (item.code == 'CASH')
                                        ? Colors.transparent
                                        : Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.meta != null && item.meta!.isNotEmpty
                                  ? item.meta!.first.bank_names ?? ''
                                  : (item.name_th ?? ''),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      subtitle: item.meta != null && item.meta!.isNotEmpty
                          ? Text(
                              item.meta!.first.bank_account ?? '',
                              style: const TextStyle(fontSize: 14),
                            )
                          : null,
                    ),
                    listItemBuilder: (context, item, isSelected, onTap) =>
                        ListTile(
                      title: Row(
                        children: [
                          CircleAvatar(
                            radius: 11,
                            backgroundImage: item.code == 'CASH'
                                ? const AssetImage('images/LogoBank/CASH.png')
                                : (item.meta != null && item.meta!.isNotEmpty
                                    ? AssetImage(
                                        'images/LogoBank/${item.meta!.first.bcode}.png')
                                    : null),
                            backgroundColor:
                                (item.meta != null && item.meta!.isNotEmpty)
                                    ? Colors.transparent
                                    : (item.code == 'CASH')
                                        ? Colors.transparent
                                        : Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.meta != null && item.meta!.isNotEmpty
                                  ? item.meta!.first.bank_names ?? ''
                                  : (item.name_th ?? ''),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      subtitle: item.meta != null && item.meta!.isNotEmpty
                          ? Text(
                              item.meta!.first.bank_account ?? '',
                              style: const TextStyle(fontSize: 14),
                            )
                          : null,
                      onTap: onTap,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
                        _displayDate(slipDate, Pdate_Edit),
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
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
