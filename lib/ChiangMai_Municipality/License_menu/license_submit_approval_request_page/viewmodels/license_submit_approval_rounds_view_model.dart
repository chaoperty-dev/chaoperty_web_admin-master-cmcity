// ============================================================================
// license_submit_approval_rounds_view_model.dart
// ============================================================================
// ViewModel — เฉพาะ "การเปิดรอบตรวจ" (startRound + canOpenRound flag)
// ไม่รวม approval detail / step actions — หน้าที่นั้นอยู่ที่ DetailVM แล้ว
// ============================================================================

import 'package:flutter/foundation.dart';

import '../models/submit_approval_detail_extended.dart';
import '../models/submit_approval_rounds_models.dart';
import '../services/license_submit_approval_detail_service.dart';

class LicenseSubmitApprovalRoundsViewModel extends ChangeNotifier {
  LicenseSubmitApprovalRoundsViewModel({
    LicenseSubmitApprovalDetailService? service,
  }) : _service = service ?? LicenseSubmitApprovalDetailService();

  final LicenseSubmitApprovalDetailService _service;

  bool _isStartingRound = false;
  bool? _canOpenRound;
  String? _roundError;

  /// Round uuid ล่าสุดที่เพิ่งเปิด
  ApprovalRound? _lastRound;
  String? _checkedUuid;

  /// ประวัติ rounds (โหลดจาก detail endpoint)
  List<ApprovalHistoryEntry> _history = const [];
  bool _isLoadingHistory = false;

  bool get isStartingRound => _isStartingRound;
  bool? get canOpenRound => _canOpenRound;
  String? get roundError => _roundError;
  ApprovalRound? get lastRound => _lastRound;
  List<ApprovalHistoryEntry> get history => _history;
  bool get isLoadingHistory => _isLoadingHistory;

  /// เรียกหลัง loadApprovalDetail เสร็จ → อ่าน can_open_round จาก response
  void syncCanOpenRound(String uuid, bool canOpen) {
    // update ทุกครั้ง (can_open_round อาจเปลี่ยน: true → false หลังเปิดรอบ)
    _checkedUuid = uuid;
    if (_canOpenRound != canOpen) {
      _canOpenRound = canOpen;
      notifyListeners();
    }
  }

  /// Reset state เมื่อ uuid เปลี่ยน
  void resetForUuid(String uuid) {
    if (_checkedUuid != uuid) {
      _canOpenRound = null;
      _lastRound = null;
      _history = const [];
      _checkedUuid = uuid;
    }
  }

  /// โหลดประวัติ rounds (GET /v2/admin/approvals/{uuid}) — เรียกใน step1
  Future<void> loadHistory(String requestUuid) async {
    if (requestUuid.isEmpty) return;
    if (_isLoadingHistory) return;
    _isLoadingHistory = true;
    notifyListeners();
    try {
      final detail =
          await _service.fetchApprovalDetail(requestUuid: requestUuid);
      _history = detail.history;
    } catch (_) {
      // ไม่ทำให้หน้า crash — ปล่อย history เดิม
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  /// POST /v2/admin/approvals/{uuid}/rounds
  Future<ApprovalRound?> startRound({required String requestUuid}) async {
    if (requestUuid.isEmpty) {
      _roundError = 'ไม่พบ request uuid';
      notifyListeners();
      return null;
    }
    _isStartingRound = true;
    _roundError = null;
    notifyListeners();
    try {
      final round = await _service.startRound(requestUuid: requestUuid);
      _lastRound = round;
      _canOpenRound = false; // เปิดแล้ว → ปิดไม่ให้เปิดอีก
      // refresh history หลังเปิดรอบใหม่
      // ignore: discarded_futures
      loadHistory(requestUuid);
      return round;
    } catch (e) {
      _roundError = e.toString();
      return null;
    } finally {
      _isStartingRound = false;
      notifyListeners();
    }
  }

  void clearError() {
    _roundError = null;
    notifyListeners();
  }
}
