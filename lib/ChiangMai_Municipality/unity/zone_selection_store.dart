// ============================================================================
// zone_selection_store.dart
// ============================================================================
// Global singleton — เก็บ state ของ "หมวดโซนพื้นที่" + "โซนพื้นที่" ที่ผู้ใช้เลือก
//
// ✅ ใช้ร่วมกันทุกหน้าที่มี dropdown โซน (Area / License / Tenant / etc.)
// ✅ Persist ข้าม navigation — ไม่ reset เมื่อเปลี่ยนหน้า / ไม่ reset เมื่อ pop route
// ✅ เปลี่ยน sub-zone → auto reset zone เป็น "ทั้งหมด"
// ✅ Singleton pattern — `ZoneSelectionStore.instance`
// ============================================================================

import 'package:flutter/foundation.dart';

class ZoneSelectionStore extends ChangeNotifier {
  ZoneSelectionStore._();
  static final ZoneSelectionStore instance = ZoneSelectionStore._();

  // ─── State ───
  String _selectedZoneSub = 'ทั้งหมด';
  String _selectedZone = 'ทั้งหมด';

  String get selectedZoneSub => _selectedZoneSub;
  String get selectedZone => _selectedZone;

  bool get isAll =>
      _selectedZoneSub == 'ทั้งหมด' && _selectedZone == 'ทั้งหมด';

  /// ser ของ zone ที่เลือก (resolve จาก list ที่ page ส่งมา)
  /// หรือ '0' ถ้าเป็น "ทั้งหมด"
  String get selectedZoneSer => '0';

  /// ผู้ใช้เลือก "หมวดโซนพื้นที่" (sub-zone)
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

  /// Reset ทั้งหมด (ใช้ตอน logout / refresh hard)
  void reset() {
    final was = !isAll;
    _selectedZoneSub = 'ทั้งหมด';
    _selectedZone = 'ทั้งหมด';
    if (was) notifyListeners();
  }
}