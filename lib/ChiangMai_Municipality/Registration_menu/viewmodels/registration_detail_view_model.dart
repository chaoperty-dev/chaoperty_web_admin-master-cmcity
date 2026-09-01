// ============================================================================
// registration_detail_view_model.dart
// ============================================================================
// ViewModel — จัดการ state ของหน้า Detail (2-step) ของเมนู "ทะเบียน"
// - Step 1: ข้อมูลลูกค้า
// - Step 2: รายละเอียดที่อยู่ / สัญญา / ผู้ติดต่อ
//
// ✅ โหลด customer จาก GET /v1/admin/c-customers/{uuid} (single item)
//    response shape: { data: { ser, uuid, sname, ... } }
// ============================================================================

import 'package:flutter/foundation.dart';

import '../../../../Model/GetCustomer_Model.dart';
import '../registration_page/services/registration_service.dart';

class RegistrationDetailViewModel extends ChangeNotifier {
  RegistrationDetailViewModel({RegistrationService? service})
      : _service = service ?? RegistrationService();

  final RegistrationService _service;

  /// Step ปัจจุบัน (1 หรือ 2)
  int _currentDetailStep = 1;
  int get currentDetailStep => _currentDetailStep;

  /// จำนวน Step ทั้งหมด
  int get totalDetailSteps => 2;

  /// Customer ที่กำลังแสดง
  CustomerModel? _customer;
  CustomerModel? get customer => _customer;

  /// Loading state สำหรับ async load
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Error ล่าสุด (ถ้ามี)
  String? _error;
  String? get error => _error;

  /// โหลด customer จาก object (in-memory)
  void loadCustomer(CustomerModel model) {
    _customer = model;
    _error = null;
    _currentDetailStep = 1;
    notifyListeners();
  }

  /// ✅ โหลด customer จาก API: GET /v1/admin/c-customers/{uuid}
  /// ตอนนี้ข้อมูลอาจยังเป็น null แต่เรียก endpoint เพื่อ verify
  Future<void> loadCustomerByUuid(String uuid) async {
    if (uuid.trim().isEmpty) {
      _error = 'ไม่พบ UUID';
      notifyListeners();
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _service.fetchCustomerByUuid(uuid);
      if (data != null) {
        _customer = CustomerModel.fromJson(data);
      } else {
        _customer = null;
        _error = 'ไม่พบข้อมูลลูกค้า';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _currentDetailStep = 1;
      notifyListeners();
    }
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
