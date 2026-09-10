// ============================================================================
// license_verify_detail_view_model.dart
// ============================================================================
// ViewModel — เฉพาะ step state ของหน้า detail (ไม่โหลด list data)
// - ใช้แยกจาก LicenseverifyViewModel เพื่อให้เปิดเป็น full-page route ได้
//   โดยไม่ผูกกับ list page
// ============================================================================

import 'package:flutter/foundation.dart';

class LicenseverifyDetailViewModel extends ChangeNotifier {
  /// Step ของหน้า detail:
  ///   1 = ตรวจสอบหลักฐาน (Step 1)
  ///   2 = สรุปผล (Step 2)
  static const int detailTotalSteps = 2;

  int _currentDetailStep = 1;
  int get currentDetailStep => _currentDetailStep;
  int get totalDetailSteps => detailTotalSteps;

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
