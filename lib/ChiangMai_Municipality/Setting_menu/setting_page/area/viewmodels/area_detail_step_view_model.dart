// ============================================================================
// area_detail_step_view_model.dart
// ============================================================================
// ViewModel — step state สำหรับ full-page add/edit (2-step)
// Step 1 = กรอกข้อมูล
// Step 2 = ตรวจสอบ + บันทึก
// ============================================================================

import 'package:flutter/foundation.dart';

class AreaDetailStepViewModel extends ChangeNotifier {
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
