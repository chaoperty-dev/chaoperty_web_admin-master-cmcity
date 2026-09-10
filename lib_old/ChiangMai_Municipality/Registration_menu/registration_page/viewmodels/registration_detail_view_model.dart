// ============================================================================
// registration_detail_view_model.dart
// ============================================================================
// ViewModel — step state + customer data สำหรับหน้า detail
// - ใช้แยกจาก RegistrationViewModel เพื่อให้เปิดเป็น full-page route ได้
//   โดยไม่ผูกกับ list page
// ============================================================================

import 'package:flutter/foundation.dart';

import '../../../../Model/GetCustomer_Model.dart';
import '../services/registration_service.dart';

class RegistrationDetailViewModel extends ChangeNotifier {
  /// Step ของหน้า detail:
  ///   1 = ข้อมูลร้านค้าและผู้ติดต่อ
  ///   2 = ข้อมูลส่วนบุคคลและที่อยู่
  static const int detailTotalSteps = 2;

  int _currentDetailStep = 1;
  int get currentDetailStep => _currentDetailStep;
  int get totalDetailSteps => detailTotalSteps;

  /// Customer data ที่โหลดมา
  CustomerModel? _customer;
  CustomerModel? get customer => _customer;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  final RegistrationService _service = RegistrationService();

  /// โหลด customer by key (ser เป็นหลัก, fallback uuid)
  /// - API V2 ไม่มี uuid → ใช้ ser แทน
  Future<void> loadCustomer(String key) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final list = await _service.fetchCustomers();
      // match ด้วย ser ก่อน (API V2) → fallback uuid
      final match = list.firstWhere(
        (c) =>
            (c.ser?.toString() ?? '') == key ||
            (c.uuid ?? '').toString() == key,
        orElse: () => CustomerModel(),
      );
      _customer = match;
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
    }
  }

  /// ไป step ถัดไป (ไม่เกิน detailTotalSteps)
  void nextDetailStep() {
    if (_currentDetailStep < detailTotalSteps) {
      _currentDetailStep += 1;
      notifyListeners();
    }
  }

  /// กลับ step ก่อนหน้า (ไม่ต่ำกว่า 1)
  void previousDetailStep() {
    if (_currentDetailStep > 1) {
      _currentDetailStep -= 1;
      notifyListeners();
    }
  }
}
