// ============================================================================
// license_approve_detail_view_model.dart
// ============================================================================
// ViewModel — เฉพาะ step state ของหน้า detail + โหลดข้อมูลเบื้องต้นของคำขอ
// ============================================================================

import 'package:flutter/foundation.dart';

import '../../../Model/Review_Model.dart';
import '../../../unity/API_requests_reviews.dart';

class LicenseApproveDetailViewModel extends ChangeNotifier {
  /// Step ของหน้า detail:
  ///   1 = ตรวจสอบคำขอ (Step 1)
  ///   2 = บันทึกการอนุมัติ (Step 2)
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

  /// โหลดรายละเอียดคำขอจาก uuid (routeData ที่ส่งมาจาก list page)
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
        // fallback: API ส่งกลับมาแบบ fuzzy match
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
  }

  void clear() {
    _requestUuid = null;
    _currentRequest = null;
    _loadError = null;
    _isLoading = false;
    notifyListeners();
  }
}