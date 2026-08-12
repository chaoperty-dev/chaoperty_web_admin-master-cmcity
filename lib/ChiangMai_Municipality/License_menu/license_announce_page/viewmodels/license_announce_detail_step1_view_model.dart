// ============================================================================
// license_announce_detail_step1_view_model.dart
// ============================================================================
// ViewModel สำหรับหน้า Detail (step 1 only — read-only)
// โหลดข้อมูลประกาศจาก API v1: GET /admin/announcement/{uuid}
// ============================================================================

import 'package:flutter/foundation.dart';
import '../models/license_announce_item.dart';
import '../services/license_announce_service.dart';

class LicenseAnnounceDetailStep1ViewModel extends ChangeNotifier {
  LicenseAnnounceDetailStep1ViewModel({LicenseAnnounceService? service})
      : _service = service ?? LicenseAnnounceService();

  final LicenseAnnounceService _service;

  // ----------------- State -----------------
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  LicenseAnnounceItem? _item;
  LicenseAnnounceItem? get item => _item;

  String? _uuid;
  String? get uuid => _uuid;

  // ----------------- Init -----------------
  LicenseAnnounceDetailStep1ViewModel init() {
    return this;
  }

  /// โหลดประกาศจาก UUID — เรียกใช้ตอนเปิดหน้า
  Future<void> loadFromUuid(String uuid) async {
    _uuid = uuid;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final detail = await _service.fetchDetail(uuid);
      if (detail == null) {
        _errorMessage = 'ไม่พบข้อมูลประกาศ (uuid=$uuid)';
        _isLoading = false;
        notifyListeners();
        return;
      }
      _item = detail;
      _isLoading = false;
      notifyListeners();
    } catch (e, st) {
      debugPrint('❌ LicenseAnnounceDetailStep1VM.loadFromUuid error: $e\n$st');
      _errorMessage = 'โหลดข้อมูลล้มเหลว: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ลองใหม่อีกครั้ง (เรียกจากปุ่ม "ลองอีกครั้ง")
  Future<void> retry() async {
    final u = _uuid;
    if (u == null || u.isEmpty) return;
    await loadFromUuid(u);
  }
}
