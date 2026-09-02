// ============================================================================
// zone_selection_store.dart
// ============================================================================
// Global singleton — เก็บ state ของ filter ที่ผู้ใช้เลือก แยกตาม "โมดูล"
//
// ✅ Persist ข้าม navigation ในขอบเขตของแต่ละโมดูล:
//    - Area/Tenant share: sub-zone + zone + leaseStatus + requestStatus
//    - License (7 pages) share: sub-zone + zone + licenseStatus
//
// ✅ เปลี่ยน sub-zone → auto reset zone เป็น "ทั้งหมด"
// ✅ Singleton pattern — `ZoneSelectionStore.instance`
// ============================================================================

import 'package:flutter/foundation.dart';

class ZoneSelectionStore extends ChangeNotifier {
  ZoneSelectionStore._();
  static final ZoneSelectionStore instance = ZoneSelectionStore._();

  // ════════════════════════════════════════════════════════════════
  // AREA + TENANT module (share scope)
  // ════════════════════════════════════════════════════════════════
  String _areaSubZone = 'ทั้งหมด';
  String _areaZone = 'ทั้งหมด';
  String _areaLeaseStatus = 'ทั้งหมด';
  String _areaRequestStatus = 'ทั้งหมด';

  String get areaSubZone => _areaSubZone;
  String get areaZone => _areaZone;
  String get areaLeaseStatus => _areaLeaseStatus;
  String get areaRequestStatus => _areaRequestStatus;

  // ════════════════════════════════════════════════════════════════
  // LICENSE module (7 pages share scope)
  // ════════════════════════════════════════════════════════════════
  String _licenseSubZone = 'ทั้งหมด';
  String _licenseZone = 'ทั้งหมด';
  /// nullable — null = "ทั้งหมด"
  String? _licenseStatus;

  String get licenseSubZone => _licenseSubZone;
  String get licenseZone => _licenseZone;
  String? get licenseStatus => _licenseStatus;

  // ════════════════════════════════════════════════════════════════
  // Setters — AREA + TENANT
  // ════════════════════════════════════════════════════════════════

  void setAreaSubZone(String? value) {
    final next = _norm(value);
    final subChanged = _areaSubZone != next;
    final zoneNeedsReset = _areaZone != 'ทั้งหมด';
    if (!subChanged && !zoneNeedsReset) return;
    _areaSubZone = next;
    if (zoneNeedsReset) _areaZone = 'ทั้งหมด';
    notifyListeners();
  }

  void setAreaZone(String? value) {
    final next = _norm(value);
    if (_areaZone == next) return;
    _areaZone = next;
    notifyListeners();
  }

  void setAreaLeaseStatus(String? value) {
    final next = _norm(value);
    if (_areaLeaseStatus == next) return;
    _areaLeaseStatus = next;
    notifyListeners();
  }

  void setAreaRequestStatus(String? value) {
    final next = _norm(value);
    if (_areaRequestStatus == next) return;
    _areaRequestStatus = next;
    notifyListeners();
  }

  // ════════════════════════════════════════════════════════════════
  // Setters — LICENSE
  // ════════════════════════════════════════════════════════════════

  void setLicenseSubZone(String? value) {
    final next = _norm(value);
    final subChanged = _licenseSubZone != next;
    final zoneNeedsReset = _licenseZone != 'ทั้งหมด';
    if (!subChanged && !zoneNeedsReset) return;
    _licenseSubZone = next;
    if (zoneNeedsReset) _licenseZone = 'ทั้งหมด';
    notifyListeners();
  }

  void setLicenseZone(String? value) {
    final next = _norm(value);
    if (_licenseZone == next) return;
    _licenseZone = next;
    notifyListeners();
  }

  void setLicenseStatus(String? value) {
    final next = (value == null || value.isEmpty || value == 'ทั้งหมด')
        ? null
        : value;
    if (_licenseStatus == next) return;
    _licenseStatus = next;
    notifyListeners();
  }

  /// Reset ทั้งหมด (logout / refresh hard)
  void reset() {
    final was = _areaSubZone != 'ทั้งหมด' ||
        _areaZone != 'ทั้งหมด' ||
        _areaLeaseStatus != 'ทั้งหมด' ||
        _areaRequestStatus != 'ทั้งหมด' ||
        _licenseSubZone != 'ทั้งหมด' ||
        _licenseZone != 'ทั้งหมด' ||
        _licenseStatus != null;
    _areaSubZone = 'ทั้งหมด';
    _areaZone = 'ทั้งหมด';
    _areaLeaseStatus = 'ทั้งหมด';
    _areaRequestStatus = 'ทั้งหมด';
    _licenseSubZone = 'ทั้งหมด';
    _licenseZone = 'ทั้งหมด';
    _licenseStatus = null;
    if (was) notifyListeners();
  }

  // ════════════════════════════════════════════════════════════════
  // Helper
  // ════════════════════════════════════════════════════════════════
  String _norm(String? v) => (v == null || v.isEmpty) ? 'ทั้งหมด' : v;
}