// ============================================================================
// tenant_license_detail_view_model.dart
// ============================================================================
// ViewModel — เฉพาะ step state ของหน้า detail
// ============================================================================

import 'package:flutter/foundation.dart';

class TenantLicenseDetailViewModel extends ChangeNotifier {
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
