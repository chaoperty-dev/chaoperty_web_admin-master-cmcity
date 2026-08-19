// ============================================================================
// license_verify_detail_view_model.dart
// ============================================================================
// ViewModel — step state + checklist data ของหน้า detail
// ============================================================================

import 'package:flutter/foundation.dart';

import '../models/license_verify_checklist_model.dart';
import '../services/license_verify_checklist_service.dart';

class LicenseverifyDetailViewModel extends ChangeNotifier {
  /// Step ของหน้า detail:
  ///   1 = เลือกเอกสาร (Step 1)
  ///   2 = สรุปการแนบเอกสาร (Step 2)
  static const int detailTotalSteps = 2;

  LicenseverifyDetailViewModel({this.requestUuid});

  /// UUID ของ request (ส่งต่อมาจาก routeData ของหน้า list)
  final String? requestUuid;

  int _currentDetailStep = 1;
  int get currentDetailStep => _currentDetailStep;
  int get totalDetailSteps => detailTotalSteps;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  LicenseverifyChecklistPreview? _checklist;
  LicenseverifyChecklistPreview? get checklist => _checklist;

  /// รายการเอกสารทั้งหมดที่ต้องแนบ (จาก /admin/requests/{uuid} — รวมอันที่ยังไม่อัพ)
  List<LicenseverifyChecklistAttachment> _allAttachments = [];
  List<LicenseverifyChecklistAttachment> get allAttachments =>
      List.unmodifiable(_allAttachments);

  /// รายการเอกสารที่ merge แล้ว (preview ทับด้วย all-attachments)
  /// ใช้แสดงใน step 2 — ให้เห็นทั้งเอกสารที่แนบแล้วและที่ยังไม่แนบ
  List<LicenseverifyChecklistAttachment> get mergedAttachments {
    final byId = <int, LicenseverifyChecklistAttachment>{};
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
      // เรียก 3 endpoints พร้อมกัน — saved (metadata) + preview (file info) + all-attachments (ทุกรายการ)
      // - saved → ใช้ที่ _checklist ถ้ามี (มี version + checklistNo) — fallback ไป preview
      // - preview → ใช้ทับข้อมูลใน mergedAttachments (มี file info)
      // - all-attachments → เป็น base list (รวมเอกสารที่ยังไม่แนบด้วย)
      final results = await Future.wait([
        LicenseverifyChecklistService.fetchSavedChecklist(requestUuid),
        LicenseverifyChecklistService.fetchAllAttachments(requestUuid),
      ]);
      var preview = results[0] as LicenseverifyChecklistPreview?;
      preview ??= await LicenseverifyChecklistService.fetchByUuid(requestUuid);
      _checklist = preview;
      _allAttachments =
          results[1] as List<LicenseverifyChecklistAttachment>;
      _error = null;
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

  /// true ถ้า UI ควรแสดงปุ่ม "พิมพ์ / PDF" — แสดงเฉพาะเมื่อมีประวัติบันทึกแล้ว
  bool get shouldShowPrintButton {
    final preview = _checklist;
    if (preview == null || !preview.isSaved) return false;
    return true;
  }

  // --------------------------------------------------------------------------
  // Submit checklist (POST)
  // --------------------------------------------------------------------------
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  LicenseverifyChecklistSubmitResult? _submitResult;
  LicenseverifyChecklistSubmitResult? get submitResult => _submitResult;

  Future<LicenseverifyChecklistSubmitResult?> submitChecklist() async {
    if (_isSubmitting) return _submitResult;
    _isSubmitting = true;
    _submitResult = null;
    notifyListeners();

    try {
      final result = await LicenseverifyChecklistService.submitChecklist(
        requestUuid,
      );
      _submitResult = result;
      return result;
    } catch (e) {
      debugPrint('SubmitChecklist error: $e');
      _submitResult = LicenseverifyChecklistSubmitResult(
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

