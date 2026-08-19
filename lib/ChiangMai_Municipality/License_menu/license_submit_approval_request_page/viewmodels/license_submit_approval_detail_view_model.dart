// ============================================================================
// license_submit_approval_detail_view_model.dart
// ============================================================================
// ViewModel — หน้า Detail (Step 1 + Step 2) รวม:
// 1. Step navigation state (1 / 2)
// 2. Approval detail data (current_round + steps + history)
// 3. Approve / Reject actions
// ============================================================================

import 'package:flutter/foundation.dart';

import '../models/submit_approval_detail_extended.dart';
import '../services/license_submit_approval_detail_service.dart';

class LicenseSubmitApprovalDetailViewModel extends ChangeNotifier {
  LicenseSubmitApprovalDetailViewModel({
    LicenseSubmitApprovalDetailService? service,
  }) : _service = service ?? LicenseSubmitApprovalDetailService();

  final LicenseSubmitApprovalDetailService _service;

  // ─── Step navigation ───
  static const int detailTotalSteps = 2;
  int _currentDetailStep = 1;
  int get currentDetailStep => _currentDetailStep;
  int get totalDetailSteps => detailTotalSteps;

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

  // ─── Approval detail data ───
  ApprovalDetailResponse? _approvalDetail;
  bool _isLoadingDetail = false;
  String? _detailError;
  String? _loadedUuid;

  // ─── Approve / Reject state ───
  String? _actingStepUuid;
  bool _isActing = false;
  String? _actionError;

  ApprovalDetailResponse? get approvalDetail => _approvalDetail;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get detailError => _detailError;

  String? get actingStepUuid => _actingStepUuid;
  bool get isActing => _isActing;
  String? get actionError => _actionError;

  // ─── Convenience getters ───
  ApprovalCurrentRound? get currentRound => _approvalDetail?.currentRound;
  List<ApprovalStepV2> get currentSteps =>
      _approvalDetail?.currentRound?.steps ?? const [];
  List<ApprovalHistoryEntry> get history =>
      _approvalDetail?.history ?? const [];

  /// Step ที่ admin คนนี้ทำได้ (canAct + isCurrent)
  ApprovalStepV2? get myActionableStep => currentSteps.firstWhere(
        (s) => s.canAct && s.isCurrent,
        orElse: () => const ApprovalStepV2(),
      );

  /// true = ยังโหลดไม่เสร็จ
  bool get isLoaded => !_isLoadingDetail && _loadedUuid != null;

  // ─── Actions ───
  Future<void> loadApprovalDetail({required String requestUuid}) async {
    if (requestUuid.isEmpty) return;
    _isLoadingDetail = true;
    _detailError = null;
    _loadedUuid = requestUuid;
    notifyListeners();
    debugPrint(
        '[SubmitApproval] loadApprovalDetail requestUuid=$requestUuid (len=${requestUuid.length})');
    try {
      _approvalDetail =
          await _service.fetchApprovalDetail(requestUuid: requestUuid);
      final steps = _approvalDetail?.currentRound?.steps.length ?? 0;
      debugPrint(
          '[SubmitApproval] loaded uuid=$requestUuid currentRound=${_approvalDetail?.currentRound != null}, steps=$steps, canOpen=${_approvalDetail?.canOpenRound}');
    } catch (e) {
      debugPrint('[SubmitApproval] load ERROR uuid=$requestUuid: $e');
      _detailError = e.toString();
      _approvalDetail = null;
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  /// อนุมัติ step → หลังเสร็จ reload detail อัตโนมัติ
  Future<bool> approveStep({required ApprovalStepV2 step}) async {
    final uuid = _approvalDetail?.requestUuid;
    if (uuid == null || uuid.isEmpty || step.uuid.isEmpty) {
      _actionError = 'ไม่พบ request/step uuid';
      notifyListeners();
      return false;
    }
    _actingStepUuid = step.uuid;
    _isActing = true;
    _actionError = null;
    notifyListeners();
    try {
      await _service.approveStep(
        requestUuid: uuid,
        stepUuid: step.uuid,
        remark: '',
      );
      // reload detail เพื่อให้ state ตรงกันทั้ง 2 step
      await loadApprovalDetail(requestUuid: uuid);
      return true;
    } catch (e) {
      _actionError = e.toString();
      return false;
    } finally {
      _actingStepUuid = null;
      _isActing = false;
      notifyListeners();
    }
  }

  /// ปฏิเสธ step → หลังเสร็จ reload detail อัตโนมัติ
  Future<bool> rejectStep({
    required ApprovalStepV2 step,
    required String remark,
  }) async {
    final uuid = _approvalDetail?.requestUuid;
    if (uuid == null || uuid.isEmpty || step.uuid.isEmpty) {
      _actionError = 'ไม่พบ request/step uuid';
      notifyListeners();
      return false;
    }
    if (remark.trim().isEmpty) {
      _actionError = 'กรุณาระบุเหตุผล';
      notifyListeners();
      return false;
    }
    _actingStepUuid = step.uuid;
    _isActing = true;
    _actionError = null;
    notifyListeners();
    try {
      await _service.rejectStep(
        requestUuid: uuid,
        stepUuid: step.uuid,
        remark: remark,
      );
      await loadApprovalDetail(requestUuid: uuid);
      return true;
    } catch (e) {
      _actionError = e.toString();
      return false;
    } finally {
      _actingStepUuid = null;
      _isActing = false;
      notifyListeners();
    }
  }

  void clearError() {
    _detailError = null;
    _actionError = null;
    notifyListeners();
  }
}
