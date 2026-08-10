// ============================================================================
// registration_add_view_model.dart
// ============================================================================
// ViewModel — จัดการ state ของหน้า "เพิ่มทะเบียนลูกค้า" (2-step)
// ============================================================================

import 'package:flutter/foundation.dart';

class RegistrationAddViewModel extends ChangeNotifier {
  int _currentStep = 1;
  int get currentStep => _currentStep;

  int get totalSteps => 2;

  void nextStep() {
    if (_currentStep < totalSteps) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 1) {
      _currentStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    if (step < 1 || step > totalSteps) return;
    _currentStep = step;
    notifyListeners();
  }
}
