// ============================================================================
// zone_selection_store.dart
// ============================================================================
// Global singleton — เก็บ state ของ filter ที่ผู้ใช้เลือก
//
// ✅ Persist ข้าม navigation:
//    - หมวดโซนพื้นที่ (sub-zone)
//    - โซนพื้นที่ (zone)
//    - สถานะ (status) — รวมทั้ง lease status (หมดสัญญา/เช่าอยู่/ว่าง) และ request status (draft/...)
//
// ✅ ใช้ร่วมกันทุกหน้าที่มี dropdown filter (Area / License / Tenant / etc.)
// ✅ เปลี่ยน sub-zone → auto reset zone เป็น "ทั้งหมด"
// ✅ Singleton pattern — `ZoneSelectionStore.instance`
// ============================================================================

import 'package:flutter/foundation.dart';

class ZoneSelectionStore extends ChangeNotifier {
  ZoneSelectionStore._();
  static final ZoneSelectionStore instance = ZoneSelectionStore._();

  // ─── Sub-zone ───
  String _selectedZoneSub = 'ทั้งหมด';
  String get selectedZoneSub => _selectedZoneSub;

  // ─── Zone ───
  String _selectedZone = 'ทั้งหมด';
  String get selectedZone => _selectedZone;

  // ─── Status (request status — Area menu "สถานะคำขอ") ───
  String _selectedRequestStatus = 'ทั้งหมด';
  String get selectedRequestStatus => _selectedRequestStatus;

  // ─── Status (legacy lease status — "หมดสัญญา/เช่าอยู่/ว่าง") ───
  String _selectedLeaseStatus = 'ทั้งหมด';
  String get selectedLeaseStatus => _selectedLeaseStatus;

  // ─── Status (license status — string enum เช่น 'draft'/'completed'/'rejected') ───
  /// nullable — null = "ทั้งหมด"
  String? _selectedLicenseStatus;
  String? get selectedLicenseStatus => _selectedLicenseStatus;

  bool get isAll =>
      _selectedZoneSub == 'ทั้งหมด' &&
      _selectedZone == 'ทั้งหมด' &&
      _selectedRequestStatus == 'ทั้งหมด' &&
      _selectedLeaseStatus == 'ทั้งหมด' &&
      (_selectedLicenseStatus == null || _selectedLicenseStatus == 'ทั้งหมด');

  /// ser ของ zone ที่เลือก ('0' = ทั้งหมด)
  String get selectedZoneSer => '0';

  // ===============================================================
  // Mutators
  // ===============================================================

  /// ผู้ใช้เลือก "หมวดโซนพื้นที่"
  /// → reset "โซนพื้นที่" กลับเป็น "ทั้งหมด" อัตโนมัติ
  void setSubZone(String? value) {
    final next = (value == null || value.isEmpty) ? 'ทั้งหมด' : value;
    final subChanged = _selectedZoneSub != next;
    final zoneNeedsReset = _selectedZone != 'ทั้งหมด';

    if (!subChanged && !zoneNeedsReset) return;

    _selectedZoneSub = next;
    if (zoneNeedsReset) _selectedZone = 'ทั้งหมด';
    notifyListeners();
  }

  /// ผู้ใช้เลือก "โซนพื้นที่"
  void setZone(String? value) {
    final next = (value == null || value.isEmpty) ? 'ทั้งหมด' : value;
    if (_selectedZone == next) return;
    _selectedZone = next;
    notifyListeners();
  }

  /// ผู้ใช้เลือก "สถานะคำขอ" (Area menu — request_status pill)
  void setRequestStatus(String? value) {
    final next = (value == null || value.isEmpty) ? 'ทั้งหมด' : value;
    if (_selectedRequestStatus == next) return;
    _selectedRequestStatus = next;
    notifyListeners();
  }

  /// ผู้ใช้เลือก "สถานะ" แบบ legacy (หมดสัญญา/เช่าอยู่/ว่าง)
  void setLeaseStatus(String? value) {
    final next = (value == null || value.isEmpty) ? 'ทั้งหมด' : value;
    if (_selectedLeaseStatus == next) return;
    _selectedLeaseStatus = next;
    notifyListeners();
  }

  /// ผู้ใช้เลือก "สถานะ" license (string enum เช่น 'draft'/'completed'/'rejected')
  /// → "ทั้งหมด" / null = ไม่ filter
  void setLicenseStatus(String? value) {
    final next = (value == null || value.isEmpty || value == 'ทั้งหมด')
        ? null
        : value;
    if (_selectedLicenseStatus == next) return;
    _selectedLicenseStatus = next;
    notifyListeners();
  }

  /// Reset ทั้งหมด (logout / refresh hard)
  void reset() {
    final was = !isAll;
    _selectedZoneSub = 'ทั้งหมด';
    _selectedZone = 'ทั้งหมด';
    _selectedRequestStatus = 'ทั้งหมด';
    _selectedLeaseStatus = 'ทั้งหมด';
    _selectedLicenseStatus = null;
    if (was) notifyListeners();
  }
}