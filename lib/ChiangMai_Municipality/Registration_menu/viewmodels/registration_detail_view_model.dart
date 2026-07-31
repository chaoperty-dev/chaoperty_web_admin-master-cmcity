// ============================================================================
// registration_detail_view_model.dart
// ============================================================================
// ViewModel — จัดการ state ของหน้า Detail (2-step) ของเมนู "ทะเบียน"
// - Step 1: ข้อมูลลูกค้า
// - Step 2: รายละเอียดที่อยู่ / สัญญา / ผู้ติดต่อ
// ============================================================================

import 'package:flutter/foundation.dart';

import '../../../../Model/GetCustomer_Model.dart';

class RegistrationDetailViewModel extends ChangeNotifier {
  /// Step ปัจจุบัน (1 หรือ 2)
  int _currentDetailStep = 1;
  int get currentDetailStep => _currentDetailStep;

  /// จำนวน Step ทั้งหมด
  int get totalDetailSteps => 2;

  /// Customer ที่กำลังแสดง
  CustomerModel? _customer;
  CustomerModel? get customer => _customer;

  /// โหลด customer เข้ามา
  void loadCustomer(CustomerModel model) {
    _customer = model;
    _currentDetailStep = 1;
    notifyListeners();
  }

  void nextDetailStep() {
    if (_currentDetailStep < totalDetailSteps) {
      _currentDetailStep++;
      notifyListeners();
    }
  }

  void previousDetailStep() {
    if (_currentDetailStep > 1) {
      _currentDetailStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    if (step < 1 || step > totalDetailSteps) return;
    _currentDetailStep = step;
    notifyListeners();
  }
}
