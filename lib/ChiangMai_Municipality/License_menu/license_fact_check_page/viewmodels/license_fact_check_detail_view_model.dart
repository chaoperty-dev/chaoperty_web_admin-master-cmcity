// ============================================================================
// license_fact_check_detail_view_model.dart
// ============================================================================
// ViewModel — step state + โหลดข้อมูลเบื้องต้นของ "คำขอ" ที่กดเข้ามา
// + จัดการ "รอบตรวจ" (inspection rounds) + เริ่มรอบใหม่ + อัปโหลดรูป
// ============================================================================

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../../../Model/Review_Model.dart';
import '../../../unity/API_requests_reviews.dart';
import '../services/license_fact_check_service.dart';
import 'package:flutter/foundation.dart';

class LicensefactcheckDetailViewModel extends ChangeNotifier {
  /// Step ของหน้า detail:
  ///   1 = ตรวจสอบข้อเท็จจริง (Step 1)
  ///   2 = สรุปผลการตรวจสอบ (Step 2)
  static const int detailTotalSteps = 2;

  int _currentDetailStep = 1;
  int get currentDetailStep => _currentDetailStep;
  int get totalDetailSteps => detailTotalSteps;

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

  // ============================================================================
  // Request data (โหลดจาก API)
  // ============================================================================

  String? _requestUuid;
  String? get requestUuid => _requestUuid;

  ReviewModel? _currentRequest;
  ReviewModel? get currentRequest => _currentRequest;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _loadError;
  String? get loadError => _loadError;

  /// โหลดรายละเอียดคำขอจาก uuid (routeData ที่ส่งมาจาก list page)
  Future<void> loadByUuid(String uuid) async {
    if (uuid.isEmpty) {
      _loadError = 'ไม่พบ uuid ของรายการ';
      notifyListeners();
      return;
    }
    _requestUuid = uuid;
    _isLoading = true;
    _loadError = null;
    notifyListeners();

    try {
      final res = await read_GC_Reviews(
        query: uuid,
        fild: [
          {
            'ser': '0',
            'st': '1',
            'title': 'รหัสรายการ',
            'value': 'uuid',
          }
        ],
      );
      final hit = res.data.where((m) => m.uuid == uuid).toList();
      if (hit.isNotEmpty) {
        _currentRequest = hit.first;
        _loadError = null;
      } else if (res.data.isNotEmpty) {
        // fallback: API ส่งกลับมาแบบ fuzzy match
        _currentRequest = res.data.first;
        _loadError = null;
      } else {
        _currentRequest = null;
        _loadError = 'ไม่พบข้อมูลคำขอ (uuid: $uuid)';
      }
    } catch (e) {
      _currentRequest = null;
      _loadError = 'โหลดข้อมูลไม่สำเร็จ: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _requestUuid = null;
    _currentRequest = null;
    _loadError = null;
    _isLoading = false;
    notifyListeners();
  }

  // ============================================================================
  // Inspection rounds
  // ============================================================================

  /// service สำหรับเรียก API (inject ได้ตอน test)
  LicensefactcheckService? _service;
  LicensefactcheckService get _effectiveService =>
      _service ?? LicensefactcheckService();

  void setService(LicensefactcheckService svc) {
    _service = svc;
  }

  /// expose service ให้ widget ภายนอก (เช่น ImageThumb) ใช้โหลด preview
  LicensefactcheckService get service => _service ?? LicensefactcheckService();

  List<InspectionRound> _rounds = [];
  List<InspectionRound> get rounds => List.unmodifiable(_rounds);

  bool _isLoadingRounds = false;
  bool get isLoadingRounds => _isLoadingRounds;

  String? _roundsError;
  String? get roundsError => _roundsError;

  /// กำลังสร้างรอบใหม่ (overlay spinner)
  bool _isStartingInspection = false;
  bool get isStartingInspection => _isStartingInspection;

  /// uuid ของ inspection ที่กำลังอัปโหลดรูป (null = ไม่มี)
  String? _activeInspectionUuid;
  String? get activeInspectionUuid => _activeInspectionUuid;

  /// รูปของแต่ละรอบ: key = round uuid, value = List<InspectionImage>
  final Map<String, List<InspectionImage>> _roundImages = {};
  List<InspectionImage> imagesOf(String? roundUuid) =>
      roundUuid == null ? const [] : (_roundImages[roundUuid] ?? const []);
  bool hasImages(String? roundUuid) =>
      roundUuid != null && (_roundImages[roundUuid]?.isNotEmpty ?? false);

  /// loading flag ต่อรอบ
  final Set<String> _loadingImagesFor = {};
  bool isLoadingImages(String? roundUuid) =>
      roundUuid != null && _loadingImagesFor.contains(roundUuid);

  /// โหลดรายการ "รอบตรวจ" ทั้งหมดของ request นี้
  Future<void> loadRounds() async {
    final uuid = _requestUuid;
    if (uuid == null || uuid.isEmpty) return;
    _isLoadingRounds = true;
    _roundsError = null;
    notifyListeners();
    try {
      _rounds = await _effectiveService.listInspections(uuid);
      // โหลดรูปของแต่ละรอบ (parallel)
      await _loadAllRoundImages();
    } catch (e) {
      _roundsError = 'โหลดรอบตรวจไม่สำเร็จ: $e';
      _rounds = [];
    } finally {
      _isLoadingRounds = false;
      notifyListeners();
    }
  }

  /// โหลดรูปของทุกรอบแบบ parallel
  Future<void> _loadAllRoundImages() async {
    final valid = _rounds
        .where((r) => r.uuid != null && r.uuid!.isNotEmpty)
        .map((r) => r.uuid!)
        .toList();
    await Future.wait(valid.map((uid) => loadRoundImages(uid)));
  }

  /// โหลดรูปของ 1 รอบ (lazy) — ใช้กรณี round ใหม่หรืออัปโหลดเพิ่ม
  Future<void> loadRoundImages(String roundUuid) async {
    if (roundUuid.isEmpty) return;
    _loadingImagesFor.add(roundUuid);
    notifyListeners();
    try {
      final imgs = await _effectiveService.listImages(roundUuid);
      _roundImages[roundUuid] = imgs;
    } catch (e) {
      _roundImages[roundUuid] = const [];
    } finally {
      _loadingImagesFor.remove(roundUuid);
      notifyListeners();
    }
  }

  /// เริ่มรอบตรวจใหม่ → POST /admin/requests/{uuid}/inspection
  /// คืน inspectionUuid ให้ caller ใช้อัปโหลดรูปต่อ
  Future<String?> startNewInspection() async {
    final uuid = _requestUuid;
    if (uuid == null || uuid.isEmpty) {
      _roundsError = 'ไม่พบ uuid ของคำขอ';
      notifyListeners();
      return null;
    }
    _isStartingInspection = true;
    _roundsError = null;
    notifyListeners();
    try {
      final res = await _effectiveService.startInspection(uuid);
      final newUuid = res.inspectionUuid;
      if (newUuid == null || newUuid.isEmpty) {
        _roundsError = 'เริ่มรอบตรวจไม่สำเร็จ (server ไม่คืน inspection uuid)';
        return null;
      }
      _activeInspectionUuid = newUuid;
      // refresh รายการรอบทันที
      await loadRounds();
      return newUuid;
    } catch (e) {
      _roundsError = 'เริ่มรอบตรวจไม่สำเร็จ: $e';
      return null;
    } finally {
      _isStartingInspection = false;
      notifyListeners();
    }
  }

  /// อัปโหลดรูปเข้า inspection uuid — แล้ว refresh รายการรอบ
  Future<bool> uploadImageToActive({
    File? file,
    Uint8List? bytes,
    String? filename,
    String caption = '',
  }) async {
    final uuid = _activeInspectionUuid;
    if (uuid == null || uuid.isEmpty) {
      _roundsError = 'ยังไม่ได้เริ่มรอบตรวจ';
      notifyListeners();
      return false;
    }
    try {
      await _effectiveService.uploadImage(
        uuid,
        file: file,
        bytes: bytes,
        filename: filename,
        caption: caption,
      );
      // refresh image_count + รูปของรอบปัจจุบัน
      await loadRounds();
      await loadRoundImages(uuid);
      return true;
    } catch (e) {
      _roundsError = 'อัปโหลดรูปไม่สำเร็จ: $e';
      notifyListeners();
      return false;
    }
  }

  /// อัปโหลดหลายรูปพร้อมกัน — เลือกจาก file_picker (multi)
  Future<BatchUploadResult?> uploadMultipleToActive({
    List<File>? files,
    List<({Uint8List bytes, String filename})>? bytesList,
    String caption = '',
    void Function(int done, int total)? onProgress,
  }) async {
    final uuid = _activeInspectionUuid;
    if (uuid == null || uuid.isEmpty) {
      _roundsError = 'ยังไม่ได้เริ่มรอบตรวจ';
      notifyListeners();
      return null;
    }
    _roundsError = null;
    notifyListeners();
    final result = await _effectiveService.uploadMultipleImages(
      uuid,
      files: files,
      bytesList: bytesList,
      caption: caption,
      onProgress: onProgress,
    );
    // refresh รายการรอบ + รูปของรอบปัจจุบัน
    await loadRounds();
    await loadRoundImages(uuid);
    if (result.failedCount > 0) {
      _roundsError =
          'สำเร็จ ${result.successCount} / ${result.total} ไฟล์ (ล้มเหลว ${result.failedCount})';
      notifyListeners();
    }
    return result;
  }

  void setActiveInspection(String? uuid) {
    _activeInspectionUuid = uuid;
    notifyListeners();
  }

  void clearRoundsError() {
    _roundsError = null;
    notifyListeners();
  }

  // ============================================================================
  // Inspection actions: transition / recheck
  // ============================================================================

  /// เปลี่ยนสถานะ inspection review → POST /admin/inspection/{uuid}/transition
  /// state: pending | in_review | passed | failed | cancelled
  Future<InspectionActionResult?> transitionRound(
    String reviewUuid, {
    required String state,
    String? comment,
  }) async {
    _roundsError = null;
    notifyListeners();
    try {
      final res = await _effectiveService.transitionInspection(
        reviewUuid,
        state: state,
        comment: comment,
      );
      await loadRounds(); // refresh รายการ + state
      return res;
    } catch (e) {
      _roundsError = 'เปลี่ยนสถานะไม่สำเร็จ: $e';
      notifyListeners();
      return null;
    }
  }

  /// เปิดรอบใหม่ (recheck) → POST /admin/inspection/{uuid}/recheck
  Future<InspectionResult?> recheckRound(
    String reviewUuid, {
    String? comment,
  }) async {
    _roundsError = null;
    notifyListeners();
    try {
      final res = await _effectiveService.recheckInspection(
        reviewUuid,
        comment: comment,
      );
      await loadRounds();
      return res;
    } catch (e) {
      _roundsError = 'เปิดรอบใหม่ไม่สำเร็จ: $e';
      notifyListeners();
      return null;
    }
  }
}
