// ============================================================================
// license_request_detail_step2_view_model.dart
// ============================================================================
// ViewModel — จัดการ state + business logic ของหน้า "ค่ายอดสัญญา" (Step 2)
// - เรียก Service โหลด BillingItem (prepayment) ตาม Request UUID
// - CRUD เป็น local-only (mock) เพราะ step 2 เดิมไม่ได้เรียก POST/PUT/DELETE
// - ไม่ผูกกับ Flutter UI โดยตรง
// ============================================================================

import 'dart:convert';

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
    // ลบแค่ instance แรกที่ ser ตรงกัน (กัน ser ชนกัน → ลบทีเดียวลบทุกแถว)
    final i = _items.indexWhere((e) => e.ser == ser);
    if (i >= 0) {
      _items.removeAt(i);
      notifyListeners();
    }
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

  /// เพิ่มรายการใหม่จาก JSON (debt_details) ที่ AddBillingTable ส่งกลับมา
  /// - เพิ่มอย่างเดียว (ไม่แตะรายการเดิม) แล้วรวมกับของเดิมที่มีอยู่
  /// - gen ser ใหม่ให้ไม่ชนกับรายการเดิม (ser ใช้อ้างอิงตอนลบ)
  void addItemsFromJson(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return;
    final existing = _items.map((e) => e.ser).toSet();
    var seq = DateTime.now().millisecondsSinceEpoch;
    for (final row in rows) {
      final item = BillingItem.fromDebtJson(row);
      var ser = item.ser;
      if (ser.isEmpty || existing.contains(ser)) {
        ser = (seq++).toString();
      }
      existing.add(ser);
      _items.add(BillingItem(
        uuid: item.uuid,
        ser: ser,
        expname: item.expname,
        sdate: item.sdate,
        ldate: item.ldate,
        unit: item.unit,
        term: item.term,
        amount: item.amount,
        vatRate: item.vatRate,
        whtRate: item.whtRate,
      ));
    }
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

  // ===============================================================
  // Save (POST /admin/requests/{uuid}/prepayment)
  // ===============================================================
  bool _isSaving = false;
  bool get isSaving => _isSaving;

  /// บันทึก/ลบ/แก้ไข รายการ debt_details ผ่าน API
  /// - ส่ง items ปัจจุบัน (รวมการเพิ่ม/ลบ/แก้ไข)
  /// - หลัง save สำเร็จ โหลดข้อมูลใหม่จาก API
  /// - Return error message (null = สำเร็จ)
  Future<String?> submit() async {
    final uuid = _currentUuid;
    if (uuid == null || uuid.isEmpty) {
      return 'ไม่พบ Request UUID';
    }

    _isSaving = true;
    _clearError();
    notifyListeners();

    try {
      final response = await _service.saveBillingItems(
        requestUuid: uuid,
        items: _items,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // โหลดข้อมูลใหม่จาก API เพื่อ sync state
        await loadFromUuid(uuid);
        _isSaving = false;
        notifyListeners();
        return null; // สำเร็จ
      } else {
        String errMsg = 'บันทึกไม่สำเร็จ (${response.statusCode})';
        try {
          final body = json.decode(response.body);
          if (body is Map && body['message'] is String) {
            errMsg = body['message'] as String;
          }
        } catch (_) {}
        _isSaving = false;
        _setError(errMsg);
        return errMsg;
      }
    } catch (e) {
      _isSaving = false;
      final msg = 'บันทึกไม่สำเร็จ: $e';
      _setError(msg);
      return msg;
    }
  }
}
