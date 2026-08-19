// ============================================================================
// license_approve_detail_step2_view_model.dart
// ============================================================================
// ViewModel — Step 2 (Timeline view) สำหรับ license_approve_page
//
// โหลด approval timeline (current_round + steps) จาก
// GET /v2/admin/approvals/{requestUuid} แล้วแสดงผ่าน step2 widget
//
// หมายเหตุ: ไม่มี logic สำหรับ "บันทึก/ส่งคำร้องขออนุมัติ" — เป็น read-only view
// ============================================================================

import 'package:flutter/foundation.dart';

import '../models/license_approve_detail_extended.dart';
import '../services/license_approve_detail_service.dart';

class LicenseApproveDetailStep2ViewModel extends ChangeNotifier {
  LicenseApproveDetailStep2ViewModel({
    LicenseApproveDetailService? service,
  }) : _service = service ?? LicenseApproveDetailService();

  final LicenseApproveDetailService _service;

  // ─── Loading states ───
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ─── Error ───
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ─── Data ───
  ApprovalDetailResponse? _approvalDetail;
  ApprovalDetailResponse? get approvalDetail => _approvalDetail;

  ApprovalCurrentRound? get currentRound => _approvalDetail?.currentRound;
  List<ApprovalStepV2> get currentSteps =>
      _approvalDetail?.currentRound?.steps ?? const [];
  List<ApprovalHistoryEntry> get history =>
      _approvalDetail?.history ?? const [];

  // ===========================================================================
  // Load timeline from API
  // ===========================================================================

  Future<void> loadTimeline(String requestUuid) async {
    if (requestUuid.isEmpty) {
      _errorMessage = 'ไม่พบ request uuid';
      notifyListeners();
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _approvalDetail = await _service.fetchApprovalDetail(
        requestUuid: requestUuid,
      );
    } catch (e) {
      _errorMessage = e.toString();
      _approvalDetail = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
