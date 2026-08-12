// ============================================================================
// license_request_detail_step2_view_model.dart
// ============================================================================
// ViewModel — จัดการ state + business logic ของหน้า "ค่ายอดสัญญา" (Step 2)
// - เรียก Service โหลด BillingItem (prepayment) ตาม Request UUID
// - CRUD เป็น local-only (mock) เพราะ step 2 เดิมไม่ได้เรียก POST/PUT/DELETE
// - ไม่ผูกกับ Flutter UI โดยตรง
// ============================================================================

import 'package:flutter/foundation.dart';

import '../services/license_request_billing_service.dart';

/// ViewModel — ของตัวเอง (ไม่แชร์กับ license_contract_page)
/// ใช้สำหรับ Request Detail Step 2 (ค่ายอดสัญญา / การชำระ)
class LicenseRequestDetailStep2ViewModel extends ChangeNotifier {
  LicenseRequestDetailStep2ViewModel({
    LicenseRequestBillingService? service,
  }) : _service = service ?? LicenseRequestBillingService();

  final LicenseRequestBillingService _service;

  // ---------- Data ----------
  List<BillingItem> _items = [];
  List<BillingItem> get items => _items;

  // ---------- Loading state ----------
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ---------- Current user-edited (local-only) ----------
  /// เก็บ UUID ของ request ที่กำลังโหลด (กัน race condition)
  String? _currentUuid;

  // ===============================================================
  // Load data from API
  // ===============================================================
  Future<void> loadFromUuid(String uuid) async {
    // ป้องกัน race condition: ถ้า uuid เปลี่ยนระหว่าง load
    _currentUuid = uuid;
    _setLoading(true);
    _clearError();
    try {
      final result = await _service.fetchBillingItemsSafe(requestUuid: uuid);
      // ถ้า uuid เปลี่ยนระหว่างทาง ให้ข้าม (กัน state เก่าทับ state ใหม่)
      if (_currentUuid != uuid) return;
      _items = result.items;
      _errorMessage = result.error;
    } catch (e) {
      if (_currentUuid != uuid) return;
      _setError('โหลดข้อมูลค่าใช้จ่ายไม่สำเร็จ: $e');
    } finally {
      if (_currentUuid == uuid) {
        _setLoading(false);
      }
    }
  }

  Future<void> refresh() async {
    if (_currentUuid != null) {
      await loadFromUuid(_currentUuid!);
    }
  }

  // ===============================================================
  // CRUD (local-only — mock เหมือน step 1 viewmodel)
  // ===============================================================
  Future<void> _deleteItem(String ser) async {
    _items.removeWhere((e) => e.ser == ser);
    notifyListeners();
  }

  /// ลบ item — เรียกจาก widget หลังจาก confirm dialog
  Future<void> deleteItem(String ser) async {
    await _deleteItem(ser);
  }

  /// แก้ไข item — รับ BillingItem ใหม่ (จาก dialog) แล้ว replace ใน list
  void updateItem(BillingItem updated) {
    final i = _items.indexWhere((e) => e.ser == updated.ser);
    if (i >= 0) {
      _items[i] = updated;
      notifyListeners();
    }
  }

  /// เพิ่ม item ใหม่
  void addItem(BillingItem created) {
    _items.add(created);
    notifyListeners();
  }

  // ===============================================================
  // Helpers
  // ===============================================================
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// รีเซ็ต state — เรียกตอน widget dispose
  void disposeState() {
    _items = [];
    _currentUuid = null;
    _errorMessage = null;
  }
}
