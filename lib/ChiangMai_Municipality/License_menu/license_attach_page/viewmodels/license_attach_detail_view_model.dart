// ============================================================================
// license_attach_detail_view_model.dart
// ============================================================================
// ViewModel — step state + checklist data ของหน้า detail
// ============================================================================

import 'package:flutter/foundation.dart';

import '../models/license_attach_checklist_model.dart';
import '../services/license_attach_checklist_service.dart';

class LicenseAttachDetailViewModel extends ChangeNotifier {
  /// Step ของหน้า detail:
  ///   1 = เลือกเอกสาร (Step 1)
  ///   2 = สรุปการแนบเอกสาร (Step 2)
  static const int detailTotalSteps = 2;

  LicenseAttachDetailViewModel({this.requestUuid});

  /// UUID ของ request (ส่งต่อมาจาก routeData ของหน้า list)
  final String? requestUuid;

  int _currentDetailStep = 1;
  int get currentDetailStep => _currentDetailStep;
  int get totalDetailSteps => detailTotalSteps;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  LicenseAttachChecklistPreview? _checklist;
  LicenseAttachChecklistPreview? get checklist => _checklist;

  final Map<int, String> _remarks = {};
  Map<int, String> get remarks => Map.unmodifiable(_remarks);

  String remarkFor(int clientDocumentId) => _remarks[clientDocumentId] ?? '';

  void updateRemark(int clientDocumentId, String value) {
    if (value.trim().isEmpty) {
      _remarks.remove(clientDocumentId);
    } else {
      _remarks[clientDocumentId] = value.trim();
    }
    notifyListeners();
  }

  Future<void> loadChecklist() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _checklist = await LicenseAttachChecklistService.fetchByUuid(requestUuid);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _checklist = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
