// ============================================================================
// license_approve_detail_view_model.dart
// ============================================================================
// ViewModel — step state ของหน้า detail + โหลดข้อมูลเบื้องต้นของคำขอ
// + โหลด approval detail (current_round.steps) สำหรับ step 1 แสดง
// "ขั้นตอนการส่งคำร้องขออนุมัติ"
// + approve/reject approval step (POST /v2/admin/approvals/.../approve|reject)
// ============================================================================

import 'package:flutter/foundation.dart';

import '../../../Model/Review_Model.dart';
import '../../../unity/API_requests_reviews.dart';
import '../models/license_approve_detail_extended.dart';
import '../services/license_approve_action_service.dart';
import '../services/license_approve_detail_service.dart';

class LicenseApproveDetailViewModel extends ChangeNotifier {
  /// Step ของหน้า detail:
  ///   1 = ตรวจสอบคำขอ (Step 1)
  ///   2 = ลำดับขั้นตอนการอนุมัติ (Step 2 — timeline)
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

  // ============================================================================
  // Request data (โหลดจาก API)
  // ============================================================================

  String? _requestUuid;
  String? get requestUuid => _requestUuid;

  ReviewModel? _currentRequest;
  ReviewModel? get currentRequest => _currentRequest;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _loadError;
  String? get loadError => _loadError;

  // ============================================================================
  // Approval detail (read-only — สำหรับ step 1 แสดง "ขั้นตอนปัจจุบัน")
  // ============================================================================
  ApprovalDetailResponse? _approvalDetail;
  bool _isLoadingApproval = false;
  String? _approvalError;

  ApprovalDetailResponse? get approvalDetail => _approvalDetail;
  bool get isLoadingApproval => _isLoadingApproval;
  String? get approvalError => _approvalError;

  ApprovalCurrentRound? get currentRound => _approvalDetail?.currentRound;
  List<ApprovalStepV2> get currentSteps =>
      _approvalDetail?.currentRound?.steps ?? const [];

  /// Step ปัจจุบันที่ admin ต้องดำเนินการ (isCurrent=true)
  ApprovalStepV2? get currentStep {
    final steps = currentSteps;
    for (final s in steps) {
      if (s.isCurrent) return s;
    }
    return null;
  }

  // ============================================================================
  // Approve / Reject state
  // ============================================================================
  String? _actingStepUuid;
  bool _isActing = false;
  String? _actionError;

  String? get actingStepUuid => _actingStepUuid;
  bool get isActing => _isActing;
  String? get actionError => _actionError;

  void clearActionError() {
    _actionError = null;
    notifyListeners();
  }

  // ============================================================================
  // Load request (Step 1)
  // ============================================================================

  /// โหลดรายละเอียดคำขอจาก uuid (routeData) + approval detail
  Future<void> loadByUuid(String uuid) async {
    if (uuid.isEmpty) {
      _loadError = 'ไม่พบ uuid ของรายการ';
      notifyListeners();
      return;
    }
    _requestUuid = uuid;
    _isLoading = true;
    _loadError = null;
    notifyListeners();

    try {
      final res = await read_GC_Reviews(
        query: uuid,
        fild: [
          {
            'ser': '0',
            'st': '1',
            'title': 'รหัสรายการ',
            'value': 'uuid',
          }
        ],
      );
      final hit = res.data.where((m) => m.uuid == uuid).toList();
      if (hit.isNotEmpty) {
        _currentRequest = hit.first;
        _loadError = null;
      } else if (res.data.isNotEmpty) {
        _currentRequest = res.data.first;
        _loadError = null;
      } else {
        _currentRequest = null;
        _loadError = 'ไม่พบข้อมูลคำขอ (uuid: $uuid)';
      }
    } catch (e) {
      _currentRequest = null;
      _loadError = 'โหลดข้อมูลไม่สำเร็จ: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // โหลด approval detail (read-only) เพื่อแสดง "ขั้นตอนปัจจุบัน" ใน step 1
    await _loadApprovalDetail(uuid);
  }

  Future<void> _loadApprovalDetail(String uuid) async {
    _isLoadingApproval = true;
    _approvalError = null;
    notifyListeners();
    try {
      final svc = LicenseApproveDetailService();
      _approvalDetail = await svc.fetchApprovalDetail(requestUuid: uuid);
    } catch (e) {
      _approvalDetail = null;
      _approvalError = e.toString();
    } finally {
      _isLoadingApproval = false;
      notifyListeners();
    }
  }

  /// Reload approval detail only (ใช้หลัง approve/reject หรือกด refresh)
  Future<void> reloadApprovalDetail() async {
    final uuid = _requestUuid;
    if (uuid == null || uuid.isEmpty) return;
    await _loadApprovalDetail(uuid);
  }

  // ============================================================================
  // Approve / Reject
  // ============================================================================

  final LicenseApproveActionService _actionService =
      LicenseApproveActionService();

  /// อนุมัติ step → หลังเสร็จ reload detail อัตโนมัติ
  Future<bool> approveStep({required ApprovalStepV2 step}) async {
    final uuid = _requestUuid;
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
      await _actionService.approveStep(requestUuid: uuid, stepUuid: step.uuid);
      await reloadApprovalDetail();
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
    final uuid = _requestUuid;
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
      await _actionService.rejectStep(
        requestUuid: uuid,
        stepUuid: step.uuid,
        remark: remark,
      );
      await reloadApprovalDetail();
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

  void clear() {
    _requestUuid = null;
    _currentRequest = null;
    _loadError = null;
    _isLoading = false;
    _approvalDetail = null;
    _approvalError = null;
    _isLoadingApproval = false;
    _isActing = false;
    _actingStepUuid = null;
    _actionError = null;
    notifyListeners();
  }
}
