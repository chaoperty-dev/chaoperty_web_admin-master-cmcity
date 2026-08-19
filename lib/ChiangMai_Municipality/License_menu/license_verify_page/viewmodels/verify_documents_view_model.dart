// ============================================================================
// verify_documents_view_model.dart
// ============================================================================
// ViewModel — state ของหน้า "แนบเอกสาร" (Step 1)
//
// เก็บ:
//   - รายการเอกสารที่ต้องแนบ (List<LicenseverifyDocument>)
//   - สถานะโหลด/อัปโหลด
//   - เรียก service เพื่อ fetch / upload / delete
//
// ไม่ผูกกับ global state ของ Make_contract_CMM
// ใช้ model ของตัวเอง (LicenseverifyDocument / LicenseverifyAttachment)
// ============================================================================

import 'package:flutter/foundation.dart';

import '../models/license_verify_document.dart';
import '../services/verify_documents_service.dart';

/// คอลัมน์ที่ใช้แสดงในตาราง — อ้างอิง data_title_doc
///
/// - `title`   : key สำหรับจับคู่ logic ใน `_buildCell` (ห้ามเปลี่ยน)
/// - `header`  : label สั้นที่โชว์บน column header (ปรับให้เหมาะกับหน้าจอแคบ)
const List<Map<String, String>> kVerifyDocDisplayFields = [
  {'ser': '1', 'title': 'ชื่อเอกสาร', 'header': 'ชื่อเอกสาร', 'data': 'title'},
  {'ser': '2', 'title': 'วันที่ทำรายการ', 'header': 'วันทำรายการ', 'data': 'datex'},
  {'ser': '3', 'title': 'ไฟล์เอกสาร', 'header': 'ไฟล์', 'data': 'file'},
  {'ser': '4', 'title': 'สถานะ', 'header': 'สถานะ', 'data': 'status'},
  {'ser': '5', 'title': 'วันที่ตรวจสอบ', 'header': 'วันตรวจ', 'data': 'verify'},
];

class VerifyDocumentsViewModel extends ChangeNotifier {
  VerifyDocumentsViewModel({
    required this.requestUuid,
    VerifyDocumentsService? service,
  }) : _service = service ?? VerifyDocumentsService();

  final String? requestUuid;
  final VerifyDocumentsService _service;

  // ---------- State ----------
  List<LicenseverifyDocument> _documents = [];
  bool _isLoading = false;
  bool _isUploading = false;
  String? _errorMessage;

  /// มุมมองการแสดงผล: 'list' (แถวแนวนอน) หรือ 'grid' (สูงสุด 4 คอลัมน์)
  String _viewMode = 'list';

  List<LicenseverifyDocument> get documents => List.unmodifiable(_documents);
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;
  bool get hasRequest => (requestUuid ?? '').isNotEmpty;
  String get viewMode => _viewMode;
  bool get isListView => _viewMode == 'list';
  bool get isGridView => _viewMode == 'grid';

  /// สลับมุมมอง (list ↔ grid)
  void toggleViewMode() {
    _viewMode = _viewMode == 'list' ? 'grid' : 'list';
    notifyListeners();
  }

  void setViewMode(String mode) {
    if (_viewMode != mode) {
      _viewMode = mode;
      notifyListeners();
    }
  }

  // ---------- Actions ----------
  /// โหลดรายการเอกสารจาก API
  Future<void> load() async {
    if (!hasRequest) {
      _documents = [];
      notifyListeners();
      return;
    }
    _setLoading(true);
    try {
      final list = await _service.fetchDocuments(requestUuid!);
      _documents = list;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'โหลดรายการเอกสารไม่สำเร็จ';
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh (pull) — alias สำหรับปุ่มรีเฟรช
  Future<void> refresh() => load();

  /// อัปโหลดไฟล์ที่เลือกแล้ว แล้วแทนที่ attachment ของ docId
  Future<bool> uploadFor({
    required int documentId,
    required PickedFile picked,
  }) async {
    if (!hasRequest) return false;
    _setUploading(true);
    try {
      final result = await _service.uploadAttachment(
        requestUuid: requestUuid!,
        documentId: documentId,
        bytes: picked.bytes,
        filename: picked.name,
        file: picked.file,
      );

      if (!result.ok) {
        _errorMessage = 'อัปโหลดไม่สำเร็จ (HTTP ${result.statusCode})';
        return false;
      }

      // อัปเดต attachments ใน state ทันที (ไม่ต้อง reload ทั้งหมด)
      final data = result.body?['data'];
      if (data is Map<String, dynamic>) {
        final updated = LicenseverifyAttachment.fromJson(data);
        _replaceAttachment(documentId, updated);
      } else {
        // ถ้า body ไม่มี data → reload
        await load();
      }
      _errorMessage = null;
      return true;
    } catch (_) {
      _errorMessage = 'เกิดข้อผิดพลาดระหว่างอัปโหลด';
      return false;
    } finally {
      _setUploading(false);
    }
  }

  /// ลบไฟล์แนบ
  Future<bool> deleteAttachment({
    required int documentId,
    required String attachmentUuid,
  }) async {
    if (!hasRequest) return false;
    _setLoading(true);
    try {
      final ok = await _service.deleteAttachment(
        requestUuid: requestUuid!,
        attachmentUuid: attachmentUuid,
      );
      if (ok) {
        _clearAttachment(documentId);
        _errorMessage = null;
      } else {
        _errorMessage = 'ลบไฟล์ไม่สำเร็จ';
      }
      return ok;
    } catch (_) {
      _errorMessage = 'เกิดข้อผิดพลาดระหว่างลบไฟล์';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ---------- Internals ----------
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setUploading(bool v) {
    _isUploading = v;
    notifyListeners();
  }

  void _replaceAttachment(int documentId, LicenseverifyAttachment updated) {
    final idx = _documents.indexWhere((d) => d.id == documentId);
    if (idx == -1) return;
    _documents[idx].attachments = [updated];
    notifyListeners();
  }

  void _clearAttachment(int documentId) {
    final idx = _documents.indexWhere((d) => d.id == documentId);
    if (idx == -1) return;
    _documents[idx].attachments = [];
    notifyListeners();
  }

  // ---------- Review / Verify ----------
  /// อนุมัติเอกสาร (อัปเดตสถานะ attachment เป็น approved)
  Future<bool> approveDocument({
    required int documentId,
    String? comment,
  }) async {
    if (!hasRequest) return false;
    final att = _findAttachment(documentId);
    if (att == null) return false;
    // ignore: avoid_print
    print(
        '🔵 [VerifyDocumentsViewModel] approveDocument docId=$documentId attachmentUuid=${att.uuid}');
    final ok = await _service.updateAttachmentReviewStatus(
      requestUuid: requestUuid!,
      attachmentUuid: att.uuid?.toString() ?? '',
      status: 'approved',
      description: comment ?? 'อนุมัติ',
    );
    if (ok) {
      _updateAttachmentStatus(documentId, 'approved');
    }
    // ignore: avoid_print
    print('🔵 [VerifyDocumentsViewModel] approveDocument result=$ok');
    return ok;
  }

  /// ปฏิเสธเอกสาร (อัปเดตสถานะ attachment เป็น rejected) — ต้องมี description
  Future<bool> rejectDocument({
    required int documentId,
    required String description,
  }) async {
    if (!hasRequest) return false;
    if (description.trim().isEmpty) return false;
    final att = _findAttachment(documentId);
    if (att == null) return false;
    // ignore: avoid_print
    print(
        '🔴 [VerifyDocumentsViewModel] rejectDocument docId=$documentId attachmentUuid=${att.uuid} description="$description"');
    final ok = await _service.updateAttachmentReviewStatus(
      requestUuid: requestUuid!,
      attachmentUuid: att.uuid?.toString() ?? '',
      status: 'rejected',
      description: description.trim(),
    );
    if (ok) {
      _updateAttachmentStatus(documentId, 'rejected');
    }
    // ignore: avoid_print
    print('🔴 [VerifyDocumentsViewModel] rejectDocument result=$ok');
    return ok;
  }

  /// ขอให้ผู้ใช้ปรับปรุงเอกสาร (status = needs_update) — ต้องมี description
  Future<bool> requestUpdateDocument({
    required int documentId,
    required String description,
  }) async {
    if (!hasRequest) return false;
    if (description.trim().isEmpty) return false;
    final att = _findAttachment(documentId);
    if (att == null) return false;
    // ignore: avoid_print
    print(
        '🟡 [VerifyDocumentsViewModel] requestUpdateDocument docId=$documentId attachmentUuid=${att.uuid} description="$description"');
    final ok = await _service.updateAttachmentReviewStatus(
      requestUuid: requestUuid!,
      attachmentUuid: att.uuid?.toString() ?? '',
      status: 'needs_update',
      description: description.trim(),
    );
    if (ok) {
      _updateAttachmentStatus(documentId, 'needs_update');
    }
    // ignore: avoid_print
    print('🟡 [VerifyDocumentsViewModel] requestUpdateDocument result=$ok');
    return ok;
  }

  LicenseverifyAttachment? _findAttachment(int documentId) {
    final idx = _documents.indexWhere((d) => d.id == documentId);
    if (idx == -1) return null;
    final attachments = _documents[idx].attachments;
    if (attachments.isEmpty) return null;
    return attachments.first;
  }

  void _updateAttachmentStatus(int documentId, String status) {
    final idx = _documents.indexWhere((d) => d.id == documentId);
    if (idx == -1) return;
    if (_documents[idx].attachments.isNotEmpty) {
      String label;
      switch (status) {
        case 'approved':
          label = 'อนุมัติ';
          break;
        case 'rejected':
          label = 'ปฏิเสธ';
          break;
        case 'needs_update':
          label = 'ขอปรับปรุง';
          break;
        default:
          label = status;
      }
      final updated = LicenseverifyAttachment(
        uuid: _documents[idx].attachments.first.uuid,
        fileType: _documents[idx].attachments.first.fileType,
        fileName: _documents[idx].attachments.first.fileName,
        filePath: _documents[idx].attachments.first.filePath,
        reviewAt: _documents[idx].attachments.first.reviewAt,
        uploadedAt: _documents[idx].attachments.first.uploadedAt,
        status: status,
        status_label: label,
      );
      _documents[idx].attachments = [updated];
    }
    notifyListeners();
  }
}



