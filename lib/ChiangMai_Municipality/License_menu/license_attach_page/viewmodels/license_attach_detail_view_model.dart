// ============================================================================
// license_attach_detail_view_model.dart
// ============================================================================
// ViewModel — step state + checklist data ของหน้า detail
// ============================================================================

import 'package:flutter/foundation.dart';

import '../models/license_attach_checklist_model.dart';
import '../services/license_attach_checklist_service.dart';

class LicenseAttachDetailViewModel extends ChangeNotifier {
  /// Step ของหน้า detail:
  ///   1 = เลือกเอกสาร (Step 1)
  ///   2 = สรุปการแนบเอกสาร (Step 2)
  static const int detailTotalSteps = 2;

  LicenseAttachDetailViewModel({this.requestUuid});

  /// UUID ของ request (ส่งต่อมาจาก routeData ของหน้า list)
  final String? requestUuid;

  int _currentDetailStep = 1;
  int get currentDetailStep => _currentDetailStep;
  int get totalDetailSteps => detailTotalSteps;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  LicenseAttachChecklistPreview? _checklist;
  LicenseAttachChecklistPreview? get checklist => _checklist;

  /// status ปัจจุบันของ request (เช่น 'draft', 'documents_submitted')
  /// ใช้ตัดสินใจว่าต้องยิง POST /submit ก่อน POST /checklist หรือไม่
  String? _requestStatus;
  String? get requestStatus => _requestStatus;

  /// ล็อก step1 + step2 — ห้ามลบ ห้ามแนบ ห้ามบันทึก
  /// 6 statuses: rejected/cancelled/completed/in_progress (เหมือน license_request)
  bool get isLocked {
    final s = (_requestStatus ?? '').toLowerCase().trim();
    return s == 'rejected' ||
        s == 'cancelled' ||
        s == 'canceled' ||
        s == 'completed' ||
        s == 'request_completed' ||
        s == 'in_progress';
  }

  /// sync status จาก API ภายนอก
  void setRequestStatus(String? raw) {
    final next = raw?.trim();
    if (_requestStatus == next) return;
    _requestStatus = next;
    notifyListeners();
  }

  /// รายการเอกสารทั้งหมดที่ต้องแนบ (จาก /admin/requests/{uuid} — รวมอันที่ยังไม่อัพ)
  List<LicenseAttachChecklistAttachment> _allAttachments = [];
  List<LicenseAttachChecklistAttachment> get allAttachments =>
      List.unmodifiable(_allAttachments);

  /// รายการเอกสารที่ merge แล้ว (ทั้งหมด + upload status จาก preview)
  /// ใช้แสดงใน A4 preview
  List<LicenseAttachChecklistAttachment> get mergedAttachments {
    final byId = <int, LicenseAttachChecklistAttachment>{};
    for (final a in _allAttachments) {
      byId[a.clientDocumentId] = a;
    }
    for (final a in _checklist?.payload.attachments ?? const []) {
      // ถ้ามี attachment จาก preview ให้ใช้ข้อมูลจาก preview (มี file info)
      byId[a.clientDocumentId] = a;
    }
    return byId.values.toList(growable: false);
  }

  final Map<int, String> _remarks = {};
  Map<int, String> get remarks => Map.unmodifiable(_remarks);

  String remarkFor(int clientDocumentId) => _remarks[clientDocumentId] ?? '';

  void updateRemark(int clientDocumentId, String value) {
    if (value.trim().isEmpty) {
      _remarks.remove(clientDocumentId);
    } else {
      _remarks[clientDocumentId] = value.trim();
    }
    notifyListeners();
  }

  Future<void> loadChecklist() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // เรียก 3 endpoints พร้อมกัน — saved checklist + all attachments + request status
      final results = await Future.wait([
        LicenseAttachChecklistService.fetchSavedChecklist(requestUuid),
        LicenseAttachChecklistService.fetchAllAttachments(requestUuid),
        LicenseAttachChecklistService.fetchRequestStatus(requestUuid),
      ]);
      var preview = results[0] as LicenseAttachChecklistPreview?;
      preview ??= await LicenseAttachChecklistService.fetchByUuid(requestUuid);
      _checklist = preview;
      _allAttachments = results[1] as List<LicenseAttachChecklistAttachment>;
      _requestStatus = results[2] as String?;
      _error = null;
      syncEditMode();
    } catch (e) {
      _error = e.toString();
      _checklist = null;
      _allAttachments = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void nextDetailStep() {
    if (_currentDetailStep < detailTotalSteps) {
      _currentDetailStep += 1;
      notifyListeners();
    }
  }

  void previousDetailStep() {
    if (_currentDetailStep > 1) {
      _currentDetailStep -= 1;
      notifyListeners();
    }
  }

  // --------------------------------------------------------------------------
  // Submit checklist (POST)
  // --------------------------------------------------------------------------
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  // --------------------------------------------------------------------------
  // Edit mode (สำหรับ step 2)
  // - ถ้ายังไม่เคยบันทึก (preview.isSaved == false) → อยู่ในโหมดแก้ไขเสมอ
  // - ถ้าเคยบันทึกแล้ว → เริ่มในโหมดดู จนกว่าจะกด "แก้ไข"
  // - หลัง save สำเร็จ (version เพิ่ม) → ออกจากโหมดแก้ไขอัตโนมัติ
  // --------------------------------------------------------------------------
  bool _isEditMode = false;
  bool get isEditMode => _isEditMode;

  /// version ณ ตอนที่กดเข้าโหมดแก้ไข — ถ้าเปลี่ยน = save เสร็จ → ออกจาก edit mode
  int? _versionAtEditEntry;
  bool _editModeInitialized = false;

  /// true ถ้า UI ควรแสดงปุ่ม "บันทึก" — แสดงเมื่อ:
  /// - ยังไม่เคยบันทึก (isSaved == false), หรือ
  /// - อยู่ในโหมดแก้ไข
  bool get shouldShowSaveButton {
    final preview = _checklist;
    if (preview == null) return false;
    if (!preview.isSaved) return true;
    return _isEditMode;
  }

  /// true ถ้า UI ควรแสดงปุ่ม "พิมพ์ / PDF" — แสดงเฉพาะเมื่อมีประวัติบันทึกแล้ว และไม่อยู่ในโหมดแก้ไข
  bool get shouldShowPrintButton {
    final preview = _checklist;
    if (preview == null || !preview.isSaved) return false;
    return !_isEditMode;
  }

  void syncEditMode() {
    final preview = _checklist;
    if (preview == null) return;

    // ครั้งแรกที่มีข้อมูล → ตั้งโหมดเริ่มต้น
    if (!_editModeInitialized) {
      _isEditMode = !preview.isSaved;
      _versionAtEditEntry = preview.version;
      _editModeInitialized = true;
      notifyListeners();
      return;
    }

    // ถ้าอยู่ในโหมดแก้ไข และ version เปลี่ยน (= save เสร็จ + refetch)
    if (_isEditMode &&
        _versionAtEditEntry != null &&
        preview.version != null &&
        preview.version != _versionAtEditEntry) {
      _isEditMode = false;
      _versionAtEditEntry = preview.version;
      notifyListeners();
    }
  }

  void enterEditMode() {
    if (!_isEditMode) {
      _isEditMode = true;
      _versionAtEditEntry = _checklist?.version;
      notifyListeners();
    }
  }

  void exitEditMode() {
    if (_isEditMode) {
      _isEditMode = false;
      _versionAtEditEntry = null;
      notifyListeners();
    }
  }

  LicenseAttachChecklistSubmitResult? _submitResult;
  LicenseAttachChecklistSubmitResult? get submitResult => _submitResult;

  Future<LicenseAttachChecklistSubmitResult?> submitChecklist() async {
    if (_isSubmitting) return _submitResult;
    _isSubmitting = true;
    _submitResult = null;
    notifyListeners();

    try {
      // ถ้า request ยังอยู่ในสถานะ 'draft' → ต้องยิง POST /submit ก่อน
      // เพื่อเปลี่ยนเป็น 'documents_submitted' ก่อนยิง POST /checklist
      if (_requestStatus == 'draft') {
        final submitDraft =
            await LicenseAttachChecklistService.submitRequest(requestUuid);
        if (!submitDraft.success) {
          _submitResult = submitDraft;
          return _submitResult;
        }
        // update status หลัง submit สำเร็จ (response.data.status เช่น documents_submitted)
        if (submitDraft.requestStatus != null) {
          _requestStatus = submitDraft.requestStatus;
        } else {
          _requestStatus = 'documents_submitted';
        }
        notifyListeners();
        // ✅ รอ 1.5s ก่อน API ถัดไป — backend มี queue ต้องเว้นระยะ
        await Future.delayed(const Duration(milliseconds: 1500));
      }

      final result = await LicenseAttachChecklistService.submitChecklist(
        requestUuid,
      );
      _submitResult = result;
      // ✅ ถ้าบันทึกสำเร็จ → รอ 1.5s ให้ backend commit เสร็จ แล้ว refresh list
      if (result.success) {
        await Future.delayed(const Duration(milliseconds: 1500));
        // ✅ refresh แบบ fire-and-forget (ไม่ block pop)
        // version/checked_at ใหม่จะมาทันตอนเปิดหน้านี้ครั้งหน้า
        // ignore: unawaited_futures
        loadChecklist();
      }
      return result;
    } catch (e) {
      debugPrint('SubmitChecklist error: $e');
      _submitResult = LicenseAttachChecklistSubmitResult(
        success: false,
        statusCode: -1,
        message: e.toString(),
      );
      return _submitResult;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
