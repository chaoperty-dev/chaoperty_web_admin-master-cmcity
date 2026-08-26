// ============================================================================
// license_request_detail_view_model.dart
// ============================================================================
// ViewModel — เฉพาะ step state ของหน้า detail
// ============================================================================

import 'package:flutter/foundation.dart';

import '../services/license_request_detail_service.dart';

class LicenseRequestDetailViewModel extends ChangeNotifier {
  /// Step ของหน้า detail:
  ///   1 = ตรวจสอบคำขอ (Step 1)
  ///   2 = บันทึกการดำเนินการ (Step 2)
  static const int detailTotalSteps = 2;

  LicenseRequestDetailViewModel({
    LicenseRequestDetailService? service,
  }) : _service = service ?? LicenseRequestDetailService();

  final LicenseRequestDetailService _service;

  int _currentDetailStep = 1;
  int get currentDetailStep => _currentDetailStep;
  int get totalDetailSteps => detailTotalSteps;

  // ---------- Cancel request state ----------
  bool _isCancelling = false;
  bool get isCancelling => _isCancelling;
  String? _cancelError;
  String? get cancelError => _cancelError;

  // ---------- Request status (synced from Step1 / cancel API) ----------
  String _status = '';
  String get status => _status;

  /// badge ใน step1 — เฉพาะสถานะที่ "ปฏิเสธ" (เปลี่ยนปุ่มยกเลิกเป็น status badge)
  bool get isRejected {
    final s = _status.toLowerCase().trim();
    return s == 'rejected' || s == 'cancelled' || s == 'canceled';
  }

  /// ล็อก step2 (ห้าม add/delete) — 4 statuses: rejected/cancelled/completed/in_progress
  bool get isLocked {
    final s = _status.toLowerCase().trim();
    return s == 'rejected' ||
        s == 'cancelled' ||
        s == 'canceled' ||
        s == 'completed' ||
        s == 'request_completed' ||
        s == 'in_progress';
  }

  /// sync status จาก API หลังโหลดรายละเอียด (เรียกจาก Step1 หลัง fetchReviewDetail)
  void setStatus(String? raw) {
    final next = (raw ?? '').trim();
    if (_status == next) return;
    _status = next;
    notifyListeners();
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

  /// ยกเลิกคำขอ — คืน true ถ้าสำเร็จ
  Future<bool> cancelRequest({
    required String uuid,
    String? comment,
  }) async {
    if (uuid.isEmpty) return false;
    _isCancelling = true;
    _cancelError = null;
    notifyListeners();
    try {
      final ok = await _service.cancelRequest(uuid: uuid, comment: comment);
      return ok;
    } catch (e) {
      _cancelError = '$e';
      return false;
    } finally {
      _isCancelling = false;
      notifyListeners();
    }
  }
}
