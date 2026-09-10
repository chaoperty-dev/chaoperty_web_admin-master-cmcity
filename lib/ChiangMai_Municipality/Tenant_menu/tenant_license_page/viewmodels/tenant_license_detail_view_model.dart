// ============================================================================
// tenant_license_detail_view_model.dart
// ============================================================================
// ViewModel — โหลดรายละเอียดใบอนุญาต + ควบคุม 2 step
// ============================================================================

import 'package:flutter/foundation.dart';

import '../models/tenant_permit_models.dart';
import '../services/tenant_license_service.dart';

class TenantLicenseDetailViewModel extends ChangeNotifier {
  TenantLicenseDetailViewModel({
    required this.permitUuid,
    TenantLicenseService? service,
  }) : _service = service ?? TenantLicenseService() {
    load();
  }

  static const int detailTotalSteps = 2;
  final String permitUuid;
  final TenantLicenseService _service;
  TenantLicenseService get service => _service;

  TenantPermitDetail? _permit;
  TenantPermitDetail? get permit => _permit;

  List<Map<String, dynamic>> _inspections = [];
  List<Map<String, dynamic>> get inspections => List.unmodifiable(_inspections);

  List<Map<String, dynamic>> _payments = [];
  List<Map<String, dynamic>> get payments => List.unmodifiable(_payments);

  bool _disposed = false;

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _error;
  String? get error => _error;

  int _currentDetailStep = 1;
  int get currentDetailStep => _currentDetailStep;
  int get totalDetailSteps => detailTotalSteps;

  Future<void> load() async {
    if (_isLoading || permitUuid.trim().isEmpty) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _permit = await _service.fetchPermitDetail(permitUuid.trim());
      if (_permit == null) {
        _error = 'ไม่พบข้อมูลใบอนุญาต';
      } else {
        _inspections = await _service.fetchInspections(permitUuid.trim());
        _payments = await _service.fetchPermitPayments(permitUuid.trim());
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() => load();

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
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
}
