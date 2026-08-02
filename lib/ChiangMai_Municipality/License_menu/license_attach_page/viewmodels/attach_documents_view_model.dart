// ============================================================================
// attach_documents_view_model.dart
// ============================================================================
// ViewModel — state ของหน้า "แนบเอกสาร" (Step 1)
//
// เก็บ:
//   - รายการเอกสารที่ต้องแนบ (List<DocumentModel>)
//   - สถานะโหลด/อัปโหลด
//   - เรียก service เพื่อ fetch / upload / delete
//
// ไม่ผูกกับ global state ของ Make_contract_CMM
// (คัดลอก "ลอจิก" มาออกแบบใหม่ให้สะอาด)
// ============================================================================

import 'package:flutter/foundation.dart';

import '../../../Model/Document_Model.dart';
import '../services/attach_documents_service.dart';

/// คอลัมน์ที่ใช้แสดงในตาราง — อ้างอิง data_title_doc แบบเดียวกับหน้า Make_contract_CMM
const List<Map<String, String>> kAttachDocDisplayFields = [
  {'ser': '1', 'title': 'ชื่อเอกสาร', 'data': 'title'},
  {'ser': '2', 'title': 'วันที่ทำรายการ', 'data': 'datex'},
  {'ser': '3', 'title': 'ไฟล์เอกสาร', 'data': 'file'},
  {'ser': '4', 'title': 'สถานะ', 'data': 'status'},
  {'ser': '5', 'title': 'วันที่ตรวจสอบ', 'data': 'verify'},
];

class AttachDocumentsViewModel extends ChangeNotifier {
  AttachDocumentsViewModel({
    required this.requestUuid,
    AttachDocumentsService? service,
  }) : _service = service ?? AttachDocumentsService();

  final String? requestUuid;
  final AttachDocumentsService _service;

  // ---------- State ----------
  List<DocumentModel> _documents = [];
  bool _isLoading = false;
  bool _isUploading = false;
  String? _errorMessage;

  /// มุมมองการแสดงผล: 'list' (แถวแนวนอน) หรือ 'grid' (สูงสุด 4 คอลัมน์)
  String _viewMode = 'list';

  List<DocumentModel> get documents => List.unmodifiable(_documents);
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
        final updated = AttachmentsModel.fromJson(data);
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

  void _replaceAttachment(int documentId, AttachmentsModel updated) {
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
}
