// ============================================================================
// personal_information_view_model.dart
// ============================================================================
// ViewModel — state ของหน้า "จัดการข้อมูลส่วนตัว"
// โหลด profile, บันทึกลายเซ็น, expose events ผ่าน Stream
// ============================================================================

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart' show GlobalKey;
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

import '../../../unity/Enum.dart';
import '../models/personal_information_models.dart';
import '../services/personal_information_service.dart';

class PersonalInformationViewModel extends ChangeNotifier {
  PersonalInformationViewModel({PersonalInformationService? service})
      : _service = service ?? PersonalInformationService();

  final PersonalInformationService _service;

  // ============================================================================
  // State
  // ============================================================================

  AdminProfile? _profile;
  AdminProfile? get profile => _profile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _error;
  String? get error => _error;

  // Event stream (snackbar / navigation)
  final _eventCtrl = StreamController<PersonalInformationEvent>.broadcast();
  Stream<PersonalInformationEvent> get events => _eventCtrl.stream;

  @override
  void dispose() {
    _eventCtrl.close();
    super.dispose();
  }

  // ============================================================================
  // Actions
  // ============================================================================

  /// โหลด profile (เรียกตอน initState)
  Future<void> load() async {
    _setLoading(true);
    try {
      final p = await _service.loadProfile();
      _profile = p;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _eventCtrl.add(PersonalInformationError(_error!));
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh (สำหรับปุ่ม "รีเฟรช")
  Future<void> refresh() => load();

  /// บันทึกลายเซ็นใหม่
  /// - ดึง bytes จาก signature pad
  /// - upload
  /// - reload profile ใหม่
  Future<bool> saveSignature(
      GlobalKey<SfSignaturePadState> signatureKey) async {
    final p = _profile;
    if (p == null) {
      _eventCtrl.add(const PersonalInformationError('ยังโหลดข้อมูลไม่เสร็จ'));
      return false;
    }
    if (p.userUuid.isEmpty) {
      _eventCtrl.add(const PersonalInformationError('ไม่พบ UUID ของผู้ใช้'));
      return false;
    }

    _setSaving(true);
    try {
      final Uint8List? bytes = await _service.exportSignatureBytes(
        SignatureActionType.upload_admin,
        signatureKey,
      );

      if (bytes == null) {
        _eventCtrl.add(
          const PersonalInformationError('ไม่สามารถแปลงลายเซ็นเป็นไฟล์ได้'),
        );
        return false;
      }

      final ok = await _service.saveSignature(
        signedData: bytes,
        userUuid: p.userUuid,
      );

      if (ok) {
        _eventCtrl.add(const PersonalInformationSaved());
        await load(); // reload เพื่อดึง signature ใหม่
        return true;
      }

      _eventCtrl.add(const PersonalInformationError('แก้ไขลายเซ็นล้มเหลว'));
      return false;
    } catch (e) {
      _eventCtrl.add(PersonalInformationError(e.toString()));
      return false;
    } finally {
      _setSaving(false);
    }
  }

  // ============================================================================
  // Internal
  // ============================================================================

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setSaving(bool v) {
    _isSaving = v;
    notifyListeners();
  }
}
