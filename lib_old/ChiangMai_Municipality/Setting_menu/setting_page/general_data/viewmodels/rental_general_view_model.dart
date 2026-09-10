// ============================================================================
// rental_general_view_model.dart
// ============================================================================
// ViewModel สำหรับหน้า "ข้อมูลทั่วไป" — Port จาก SettingScreen.dart State
// ============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/rental_general_models.dart';
import '../services/rental_general_service.dart';

class RentalGeneralViewModel extends ChangeNotifier {
  final RentalGeneralService service;

  RentalGeneralViewModel({required this.service});

  // ───────── State ─────────
  bool _loading = false;
  bool get loading => _loading;

  bool _loadingZones = false;
  bool get loadingZones => _loadingZones;

  RentalGeneralModel _data = RentalGeneralModel.empty();
  RentalGeneralModel get data => _data;

  List<ZoneImageModel> _zones = [];
  List<ZoneImageModel> get zones => List.unmodifiable(_zones);

  String? _error;
  String? get error => _error;

  // ───────── Event stream ─────────
  final StreamController<RentalGeneralEvent> _events =
      StreamController<RentalGeneralEvent>.broadcast();
  Stream<RentalGeneralEvent> get events => _events.stream;

  @override
  void dispose() {
    _events.close();
    super.dispose();
  }

  // ───────── Actions ─────────

  /// โหลดข้อมูลทั้งหมด (rental + areaCount)
  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();
    _events.add(const LoadingRentalGeneral());

    final ev = await service.fetchAll();
    switch (ev) {
      case LoadedRentalGeneral(:final data):
        _data = data;
        _error = null;
      case ErrorRentalGeneral(:final message):
        _error = message;
      case LoadingRentalGeneral():
      case LoadedZoneImages():
      case UpdatedRentalGeneral():
      case UploadedRentalGeneral():
      case DeletedRentalGeneral():
        break;
    }
    _loading = false;
    notifyListeners();
    _events.add(ev);
  }

  /// โหลด zones (สำหรับ Row 8 — รูปภาพโซนพื้นที่)
  Future<void> loadZones() async {
    if (_loadingZones) return;
    _loadingZones = true;
    notifyListeners();

    final ev = await service.fetchZones();
    if (ev is LoadedZoneImages) {
      _zones = ev.zones;
    }
    _loadingZones = false;
    notifyListeners();
    _events.add(ev);
  }

  /// ค้นหา zone ตามชื่อ (filter client-side)
  List<ZoneImageModel> searchZones(String query) {
    if (query.trim().isEmpty) return zones;
    final q = query.toLowerCase();
    return _zones.where((z) => (z.zn ?? '').toLowerCase().contains(q)).toList();
  }

  /// แก้ไข "ชื่อสถานที่"
  Future<bool> updateName(String newName) async {
    final ok = await service.updateName(newName);
    if (ok) {
      _data = _data.copyWith(pn: newName);
      notifyListeners();
      _events.add(const UpdatedRentalGeneral('pn'));
    }
    return ok;
  }

  /// แก้ไข "ระยะเวลาแจ้งใกล้หมดสัญญา"
  Future<bool> updateOpenSetDate(int days) async {
    final ok = await service.updateOpenSetDate(days);
    if (ok) {
      _data = _data.copyWith(openSetDate: days == 0 ? 30 : days);
      notifyListeners();
      _events.add(const UpdatedRentalGeneral('open_set_date'));
    }
    return ok;
  }

  /// Toggle "เปิดแจ้งผ่านไลน์"
  Future<bool> toggleMassOn() async {
    final newVal = _data.massOn == 1 ? 0 : 1;
    final ok = await service.toggleMassOn(newVal);
    if (ok) {
      _data = _data.copyWith(massOn: newVal);
      notifyListeners();
      _events.add(const UpdatedRentalGeneral('mass_on'));
    }
    return ok;
  }

  /// Upload image (logo/contract/zone)
  /// path: 'logo' | 'contract' | 'zone'
  Future<bool> uploadImage({
    required String path,
    required String zoneName,
    String? zoneSer,
    required Uint8List imageBytes,
    required String extension,
  }) async {
    if (_data.dbn == null || _data.dbn!.isEmpty) return false;

    final ren = _data.ser ?? '';
    final ts = DateTime.now().millisecondsSinceEpoch;
    final String fileName;
    switch (path) {
      case 'logo':
        fileName = 'logo${ren}_$ts.$extension';
        break;
      case 'contract':
        fileName = 'Map${ren}_$ts.$extension';
        break;
      case 'zone':
        fileName = 'zone${zoneName}_$ts.$extension';
        break;
      default:
        return false;
    }

    final base64Image = base64Encode(imageBytes);
    final ok1 = await service.uploadImage(
      path: path,
      fileName: fileName,
      extension: extension,
      folder: _data.dbn!,
      base64Image: base64Image,
    );
    if (!ok1) return false;

    final ok2 = await service.refreshImageRecord(
      path: path,
      fileName: fileName,
      ser: zoneSer,
    );
    if (ok2) {
      // reload zones หรือ rental ตาม path
      if (path == 'zone') {
        await loadZones();
      } else {
        await load();
      }
      _events.add(UploadedRentalGeneral(path, zoneName: zoneName));
    }
    return ok2;
  }

  /// Delete image
  Future<bool> deleteImage({
    required String path,
    required String? fileName,
    String? zoneSer,
  }) async {
    if (_data.dbn == null || _data.dbn!.isEmpty) return false;
    final ok = await service.deleteImage(
      path: path,
      fileName: fileName,
      folder: _data.dbn!,
      ser: zoneSer,
    );
    if (ok) {
      if (path == 'zone') {
        await loadZones();
      } else {
        await load();
      }
      _events.add(DeletedRentalGeneral(path));
    }
    return ok;
  }

  /// Helper: เปิด image picker (mobile)
  Future<Uint8List?> pickImageBytes() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return null;
    return picked.readAsBytes();
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}
