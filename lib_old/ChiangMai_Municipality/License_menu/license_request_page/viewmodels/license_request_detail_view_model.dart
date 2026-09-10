// ============================================================================
// license_request_detail_view_model.dart
// ============================================================================
// ViewModel — เฉพาะ step state ของหน้า detail
// ============================================================================

import 'package:flutter/foundation.dart';

class LicenseRequestDetailViewModel extends ChangeNotifier {
  /// Step ของหน้า detail:
  ///   1 = ตรวจสอบคำขอ (Step 1)
  ///   2 = บันทึกการดำเนินการ (Step 2)
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
}
