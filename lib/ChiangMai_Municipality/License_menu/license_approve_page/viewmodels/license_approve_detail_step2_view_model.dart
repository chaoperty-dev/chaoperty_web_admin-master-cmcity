// ============================================================================
// license_approve_detail_step2_view_model.dart
// ============================================================================
// ViewModel — จัดการ state + business logic ของ Step 2
// (บันทึกการอนุมัติ + อัปโหลดหลักฐานการตรวจสอบข้อเท็จจริง)
//
// - โหลด ReviewDetail  + ApproveDocuments จาก API
// - โหลดลายเซ็นผู้อนุมัติ (signature + profile) ตั้งแต่เปิดหน้า
// - map ข้อมูลลง form fields (read-only)
// - อัปโหลดไฟล์หลักฐานของผู้ตรวจสอบ
// - ยืนยันการอนุมัติ / ปฏิเสธ (เรียก API ตรง ไม่ผ่านหน้า Signature Pad)
// - ใช้ LicenseApproveStep2Service จาก services/ ตาม pattern ของ license_approve_service.dart
// ============================================================================

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../Model/Person%26Shop_Model.dart';
import '../../../Model/ReviewUuid_Model.dart';
import '../../../unity/SecurePrefs_helper.dart';
import '../services/license_approve_step2_service.dart';

// ============================================================================
// Local models (สร้างใหม่ ไม่ reuse class เดิม)
// ============================================================================

/// เอกสารหลักฐานที่ผู้ตรวจสอบต้องอัปโหลด
class LaApproveDocument {
  final int id;
  final String nameTh;
  final String code;
  final bool required;

  /// ไฟล์ล่าสุดที่อัปโหลด (single)
  LaApproveAttachment? attachment;

  /// ประวัติไฟล์ทั้งหมดที่เคยอัปโหลด (history)
  final List<LaApproveAttachment> attachments;

  LaApproveDocument({
    required this.id,
    required this.nameTh,
    required this.code,
    required this.required,
    this.attachment,
    List<LaApproveAttachment>? attachments,
  }) : attachments = attachments ?? <LaApproveAttachment>[];

  bool get hasFile => attachment != null;

  factory LaApproveDocument.fromJson(Map<String, dynamic> json) {
    LaApproveAttachment? att;
    if (json['approve_attachment'] != null) {
      att = LaApproveAttachment.fromJson(
          json['approve_attachment'] as Map<String, dynamic>);
    }
    final List<LaApproveAttachment> atts = <LaApproveAttachment>[];
    if (json['approve_attachments'] is List) {
      atts.addAll((json['approve_attachments'] as List)
          .whereType<Map<String, dynamic>>()
          .map(LaApproveAttachment.fromJson));
    }
    return LaApproveDocument(
      id: (json['id'] ?? 0) as int,
      nameTh: (json['name_th'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      required: (json['required'] ?? 0) as int == 1,
      attachment: att,
      attachments: atts,
    );
  }
}

/// ไฟล์แนบของหลักฐาน
class LaApproveAttachment {
  final String uuid;
  final String fileName;
  final String fileType;
  final DateTime? createdAt;
  final String? caption;
  final String? captionVersion;

  const LaApproveAttachment({
    required this.uuid,
    required this.fileName,
    required this.fileType,
    this.createdAt,
    this.caption,
    this.captionVersion,
  });

  bool get isPdf =>
      fileType.toLowerCase() == 'pdf' || fileName.toLowerCase().endsWith('.pdf');

  factory LaApproveAttachment.fromJson(Map<String, dynamic> json) {
    DateTime? dt;
    final raw = json['created_at'];
    if (raw != null && raw.toString().isNotEmpty) {
      try {
        dt = DateTime.parse(raw.toString());
      } catch (_) {
        dt = null;
      }
    }
    return LaApproveAttachment(
      uuid: (json['uuid'] ?? '').toString(),
      fileName: (json['file_name'] ?? '').toString(),
      fileType: (json['file_type'] ?? '').toString(),
      createdAt: dt,
      caption: json['caption']?.toString(),
      captionVersion: json['caption_version']?.toString(),
    );
  }
}

/// เอกสารที่ผู้เช่า/ผู้ค้าส่งมา (read-only)
class LaRequestDocument {
  final int id;
  final String nameTh;
  final String? fileName;
  final String? fileType;
  final DateTime? createdAt;
  final String? attachmentUuid;

  const LaRequestDocument({
    required this.id,
    required this.nameTh,
    this.fileName,
    this.fileType,
    this.createdAt,
    this.attachmentUuid,
  });

  bool get hasFile => attachmentUuid != null && attachmentUuid!.isNotEmpty;

  bool get isPdf =>
      (fileType ?? '').toLowerCase() == 'pdf' ||
      (fileName ?? '').toLowerCase().endsWith('.pdf');

  factory LaRequestDocument.fromJson(Map<String, dynamic> json) {
    DateTime? dt;
    final raw = json['created_at'];
    if (raw != null && raw.toString().isNotEmpty) {
      try {
        dt = DateTime.parse(raw.toString());
      } catch (_) {
        dt = null;
      }
    }
    String? attUuid;
    String? fileName;
    String? fileType;
    if (json['request_attachments'] is Map) {
      final att = json['request_attachments'] as Map<String, dynamic>;
      attUuid = att['uuid']?.toString();
      fileName = att['file_name']?.toString();
      fileType = att['file_type']?.toString();
      final raw2 = att['created_at'];
      if (raw2 != null && raw2.toString().isNotEmpty) {
        try {
          dt = DateTime.parse(raw2.toString());
        } catch (_) {/* keep */}
      }
    }
    return LaRequestDocument(
      id: (json['id'] ?? 0) as int,
      nameTh: (json['name_th'] ?? '').toString(),
      fileName: fileName,
      fileType: fileType,
      createdAt: dt,
      attachmentUuid: attUuid,
    );
  }
}

/// ข้อมูลลายเซ็น + โปรไฟล์ผู้อนุมัติ (โหลดตั้งแต่เปิดหน้า)
class LaApproverSignature {
  final String profileUuid;
  final String signatureUuid;
  final String profileName;
  final String positionName;
  final Uint8List? signatureBytes;

  const LaApproverSignature({
    required this.profileUuid,
    required this.signatureUuid,
    required this.profileName,
    required this.positionName,
    this.signatureBytes,
  });

  bool get isReady =>
      profileUuid.isNotEmpty &&
      signatureUuid.isNotEmpty &&
      signatureBytes != null;
}

// ============================================================================
// Main ViewModel
// ============================================================================

class LicenseApproveDetailStep2ViewModel extends ChangeNotifier {
  LicenseApproveDetailStep2ViewModel({
    LicenseApproveStep2Service? service,
  }) : _service = service ?? LicenseApproveStep2Service();

  final LicenseApproveStep2Service _service;

  // ── Loading states ──
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isApproving = false;
  bool _isRejecting = false;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  bool get isApproving => _isApproving;
  bool get isRejecting => _isRejecting;

  // ── Error ──
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── Data ──
  ReviewDetail? _reviewDetail;
  ReviewDetail? get reviewDetail => _reviewDetail;

  List<LaApproveDocument> _approveDocuments = <LaApproveDocument>[];
  List<LaApproveDocument> get approveDocuments =>
      List.unmodifiable(_approveDocuments);

  List<LaRequestDocument> _requestDocuments = <LaRequestDocument>[];
  List<LaRequestDocument> get requestDocuments =>
      List.unmodifiable(_requestDocuments);

  LaApproverSignature? _approverSignature;
  LaApproverSignature? get approverSignature => _approverSignature;

  // ── Form data (read-only — cloned from global static lists) ──
  late List<PersonFieldModel> _dataPerson;
  late List<ShopFieldModel> _dataShop;
  late List<Map<String, dynamic>> _dataCid;
  late List<TextEditingController> _controllersPerson;
  late List<TextEditingController> _controllersShop;
  late List<TextEditingController> _controllersShopSub;
  late List<TextEditingController> _controllersCid;

  // ── Public getters ──
  List<PersonFieldModel> get dataPerson => _dataPerson;
  List<ShopFieldModel> get dataShop => _dataShop;
  List<Map<String, dynamic>> get dataCid => _dataCid;
  List<TextEditingController> get controllersPerson => _controllersPerson;
  List<TextEditingController> get controllersShop => _controllersShop;
  List<TextEditingController> get controllersShopSub => _controllersShopSub;
  List<TextEditingController> get controllersCid => _controllersCid;

  // ── Currently active doc for upload (UI hint) ──
  int? _activeUploadDocId;
  int? get activeUploadDocId => _activeUploadDocId;

  // ===========================================================================
  // Lifecycle
  // ===========================================================================

  void init() {
    _dataPerson = data_persons
        .map((p) => PersonFieldModel(ser: p.ser, title: p.title, detail: ''))
        .toList();

    _dataShop = data_shops
        .map((s) => ShopFieldModel(
              ser: s.ser,
              title: s.title,
              detail: '',
              detailsub: s.detailsub
                  .map((sub) => ShopSubField(
                        ser: sub.ser,
                        titlesub: sub.titlesub,
                        detail: '',
                      ))
                  .toList(),
            ))
        .toList();

    _dataCid = <Map<String, dynamic>>[
      {'ser': '1', 'title': 'วันที่เริ่มต้น', 'detail': ''},
      {'ser': '2', 'title': 'วันที่สิ้นสุด', 'detail': ''},
      {'ser': '3', 'title': 'ประเภทการเช่า', 'detail': ''},
      {'ser': '4', 'title': 'อายุสัญญา (เดือน/ปี)', 'detail': ''},
    ];

    _controllersPerson = List.generate(
      _dataPerson.length,
      (i) => TextEditingController(text: _dataPerson[i].detail),
    );
    _controllersShop = List.generate(
      _dataShop.length,
      (i) => TextEditingController(text: _dataShop[i].detail),
    );
    _controllersShopSub = List.generate(
      _dataShop[0].detailsub.length,
      (i) => TextEditingController(text: _dataShop[0].detailsub[i].detail),
    );
    _controllersCid = List.generate(
      _dataCid.length,
      (i) => TextEditingController(text: _dataCid[i]['detail'].toString()),
    );
  }

  // ===========================================================================
  // Load data from API
  // ===========================================================================

  /// โหลดข้อมูลทั้งหมดตาม requestUuid (เรียกตอนเปิดหน้า)
  Future<void> loadAll(String? requestUuid) async {
    _setLoading(true);
    _clearError();
    try {
      final Future<ReviewDetail?> f1 = _service.fetchReviewDetail(requestUuid);
      final Future<(List<LaApproveDocument>, List<LaRequestDocument>)> f2 =
          _service.fetchApprovalsCheckUp(requestUuid);
      final Future<LaApproverSignature?> f3 = _service.fetchApproverSignature();

      final detail = await f1;
      final tuple = await f2;
      final approver = await f3;

      _reviewDetail = detail;
      _approveDocuments = tuple.$1;
      _requestDocuments = tuple.$2;
      _approverSignature = approver;

      if (detail != null) {
        _applyReviewData(detail);
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh เฉพาะ approveDocuments (หลังอัปโหลด)
  Future<void> refreshApprovals(String? requestUuid) async {
    try {
      final tuple = await _service.fetchApprovalsCheckUp(requestUuid);
      _approveDocuments = tuple.$1;
      _requestDocuments = tuple.$2;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ===========================================================================
  // Upload examiner file
  // ===========================================================================

  /// คืน true ถ้าสำเร็จ
  Future<bool> uploadExaminerFile({
    required String requestUuid,
    required int docId,
  }) async {
    if (_isUploading) return false;
    _setUploading(true);
    _activeUploadDocId = docId;
    notifyListeners();
    try {
      final resp = await _service.pickAndUploadFile(
        uuid: requestUuid,
        docId: docId,
      );
      if (resp == null) return false;
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        await refreshApprovals(requestUuid);
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setUploading(false);
      _activeUploadDocId = null;
      notifyListeners();
    }
  }

  // ===========================================================================
  // Approve / Reject
  // ===========================================================================

  /// คืนค่า (success: bool, message: String?)
  Future<({bool success, String? message, http.Response? rawResponse})>
      approveNow({
    required String requestUuid,
    String comment = '',
  }) async {
    if (_isApproving) {
      return (success: false, message: 'กำลังดำเนินการอยู่', rawResponse: null);
    }
    if (_approverSignature == null || !_approverSignature!.isReady) {
      return (success: false, message: 'ไม่พบลายเซ็นผู้อนุมัติ', rawResponse: null);
    }
    _setApproving(true);
    try {
      final flowUuid = await _service.fetchFlowUuid(requestUuid);
      if (flowUuid == null || flowUuid.isEmpty) {
        return (
          success: false,
          message: 'ไม่พบ flowUuid สำหรับคำขอนี้',
          rawResponse: null,
        );
      }

      final resp = await _service.approve(
        requestUuid: requestUuid,
        flowUuid: flowUuid,
        profileUuid: _approverSignature!.profileUuid,
        signUuid: _approverSignature!.signatureUuid,
        comment: comment,
      );

      if (resp == null) {
        return (success: false, message: 'ไม่สามารถติดต่อเซิร์ฟเวอร์', rawResponse: null);
      }
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return (success: true, message: null, rawResponse: resp);
      }
      String? msg;
      try {
        final j = json.decode(resp.body);
        if (j is Map && j['message'] != null) msg = j['message'].toString();
      } catch (_) {/* ignore */}
      return (
        success: false,
        message: msg ?? 'อนุมัติไม่สำเร็จ (${resp.statusCode})',
        rawResponse: resp,
      );
    } catch (e) {
      return (success: false, message: e.toString(), rawResponse: null);
    } finally {
      _setApproving(false);
    }
  }

  /// คืนค่า (success: bool, message: String?)
  Future<({bool success, String? message, http.Response? rawResponse})>
      rejectRequest({
    required String requestUuid,
    required String comment,
  }) async {
    if (_isRejecting) {
      return (success: false, message: 'กำลังดำเนินการอยู่', rawResponse: null);
    }
    if (comment.trim().isEmpty) {
      return (success: false, message: 'กรุณาระบุเหตุผล', rawResponse: null);
    }
    if (_approverSignature == null || !_approverSignature!.isReady) {
      return (success: false, message: 'ไม่พบลายเซ็นผู้อนุมัติ', rawResponse: null);
    }
    _setRejecting(true);
    try {
      final flowUuid = await _service.fetchFlowUuid(requestUuid);
      if (flowUuid == null || flowUuid.isEmpty) {
        return (
          success: false,
          message: 'ไม่พบ flowUuid สำหรับคำขอนี้',
          rawResponse: null,
        );
      }

      final resp = await _service.reject(
        requestUuid: requestUuid,
        flowUid: flowUuid,
        profileUuid: _approverSignature!.profileUuid,
        signUuid: _approverSignature!.signatureUuid,
        comMent: comment.trim(),
      );

      if (resp == null) {
        return (success: false, message: 'ไม่สามารถติดต่อเซิร์ฟเวอร์', rawResponse: null);
      }
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return (success: true, message: null, rawResponse: resp);
      }
      String? msg;
      try {
        final j = json.decode(resp.body);
        if (j is Map && j['message'] != null) msg = j['message'].toString();
      } catch (_) {/* ignore */}
      return (
        success: false,
        message: msg ?? 'ปฏิเสธไม่สำเร็จ (${resp.statusCode})',
        rawResponse: resp,
      );
    } catch (e) {
      return (success: false, message: e.toString(), rawResponse: null);
    } finally {
      _setRejecting(false);
    }
  }

  // ===========================================================================
  // Helpers
  // ===========================================================================

  /// จำนวนเอกสารที่อัปโหลดแล้ว
  int get uploadedCount => _approveDocuments.where((d) => d.hasFile).length;

  /// จำนวนเอกสารทั้งหมด
  int get totalDocsCount => _approveDocuments.length;

  /// สามารถอนุมัติได้หรือไม่ (Step 2 ตอนนี้มีแค่ปุ่มอนุมัติ ไม่มี attachments UI)
  bool get canConfirm {
    if (_approverSignature == null || !_approverSignature!.isReady) {
      return false;
    }
    return true;
  }

  /// โหลดภาพ thumbnail ของ approve attachment
  Future<Uint8List?> fetchApproveImage({
    required String requestUuid,
    required String attachmentUuid,
  }) {
    return _service.fetchApproveImage(
      requestUuid: requestUuid,
      attachmentUuid: attachmentUuid,
    );
  }

  /// โหลดภาพ thumbnail ของ requester attachment
  Future<Uint8List?> fetchRequesterImage(String attachmentUuid) {
    return _service.fetchRequesterImage(attachmentUuid);
  }

  /// สร้าง auth headers (ใช้สำหรับเรียก PDF preview)
  Future<Map<String, String>> buildAuthHeaders() async {
    // เรียก MyHeaders.build() จาก helper เดียวกับที่ API อื่นๆ ใช้
    return await _service.buildAuthHeaders();
  }

  /// ดึง UuidRequest จาก SecurePrefs (helper สำหรับ View)
  Future<String?> getStoredRequestUuid() async {
    return await SecurePrefs.getDecrypted(SecurePrefsType.UuidRequest);
  }

  /// ดึง flowUuid จาก SecurePrefs (helper สำหรับ View)
  Future<String?> getStoredFlowUuid() async {
    return await SecurePrefs.getDecrypted(SecurePrefsType.flowUuid);
  }

  // ===========================================================================
  // Private — map ReviewDetail → form fields
  // ===========================================================================

  void _applyReviewData(ReviewDetail rd) {
    final client = rd.client;
    final addr = client.json;
    final nr = rd.newRequest;

    _setPersonFieldBySer('1', client.cname);
    _setPersonFieldBySer('2', client.tax);
    _setPersonFieldBySer('3', client.age.toString());
    _setPersonFieldBySer('4', client.national ?? '');
    _setPersonFieldBySer('5', addr.number);
    _setPersonFieldBySer('6', addr.moo);
    _setPersonFieldBySer('7', addr.soi ?? '');
    _setPersonFieldBySer('8', addr.road ?? '');
    _setPersonFieldBySer('9', addr.tambon);
    _setPersonFieldBySer('10', addr.amphoe);
    _setPersonFieldBySer('11', addr.province);
    _setPersonFieldBySer('12', client.tel);
    _setPersonFieldBySer('13', '');

    if (_dataShop.length >= 4) {
      _dataShop[1].detail = nr.qty.toString();
      _dataShop[2].detail = client.stype;
      _dataShop[3].detail = client.scname;

      _controllersShop[1].text = _dataShop[1].detail;
      _controllersShop[2].text = _dataShop[2].detail;
      _controllersShop[3].text = _dataShop[3].detail;

      if (_dataShop[0].detailsub.length >= 3) {
        _dataShop[0].detailsub[0].detail = nr.subzone.toString();
        _dataShop[0].detailsub[1].detail = nr.zn;
        _dataShop[0].detailsub[2].detail = nr.ln;

        _controllersShopSub[0].text = _dataShop[0].detailsub[0].detail;
        _controllersShopSub[1].text = _dataShop[0].detailsub[1].detail;
        _controllersShopSub[2].text = _dataShop[0].detailsub[2].detail;
      }
    }

    _setCidField('1', nr.sdate);
    _setCidField('2', nr.ldate);
    _setCidField('3', nr.type);
    _setCidField('4', nr.leaseTermMonths.toString());
  }

  void _setPersonFieldBySer(String ser, String value) {
    final idx = _dataPerson.indexWhere((p) => p.ser == ser);
    if (idx < 0) return;
    _dataPerson[idx].detail = value;
    _controllersPerson[idx].text = value;
  }

  void _setCidField(String ser, String value) {
    final idx = _dataCid.indexWhere((c) => c['ser'].toString() == ser);
    if (idx < 0) return;
    _dataCid[idx]['detail'] = value;
    _controllersCid[idx].text = value;
  }

  // ===========================================================================
  // State helpers
  // ===========================================================================

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setUploading(bool v) {
    _isUploading = v;
    notifyListeners();
  }

  void _setApproving(bool v) {
    _isApproving = v;
    notifyListeners();
  }

  void _setRejecting(bool v) {
    _isRejecting = v;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    for (final c in _controllersPerson) {
      c.dispose();
    }
    for (final c in _controllersShop) {
      c.dispose();
    }
    for (final c in _controllersShopSub) {
      c.dispose();
    }
    for (final c in _controllersCid) {
      c.dispose();
    }
    super.dispose();
  }
}
