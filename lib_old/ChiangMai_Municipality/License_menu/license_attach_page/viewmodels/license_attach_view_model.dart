// ============================================================================
// license_attach_view_model.dart
// ============================================================================
// ViewModel — จัดการ state + business logic ของหน้า "คำขอต่อสัญญา"
// - เรียก Service โหลดรายการ tab แรก
// - แจ้ง View ผ่าน Stream<LicenseAttachEvent>
// - ไม่ผูกกับ Flutter UI
// ============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../Model/GetZone_Model.dart';
import '../../../../Model/GetSubZone_Model.dart';
import '../../../Model/Review_Model.dart';
import '../models/license_attach_config.dart';
import '../models/license_attach_event.dart';
import '../services/license_attach_service.dart';

class LicenseAttachViewModel extends ChangeNotifier {
  LicenseAttachViewModel({
    required LicenseAttachConfig config,
    LicenseAttachService? service,
  })  : _config = config,
        _service = service ?? LicenseAttachService() {
    _loadInitial();
  }

  final LicenseAttachConfig _config;
  final LicenseAttachService _service;

  // ---------- Event channel ----------
  final StreamController<LicenseAttachEvent> _eventController =
      StreamController<LicenseAttachEvent>.broadcast();
  Stream<LicenseAttachEvent> get events => _eventController.stream;

  // ---------- Data ----------
  List<ReviewModel> _requests = [];
  List<ReviewModel> get requests => _requests;

  // ---------- Pagination ----------
  int _currentPage = 0;
  int _lastPage = 0;
  int _total = 0;
  String? _linksNext;
  String? _linksPrev;

  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get total => _total;
  String? get linksNext => _linksNext;
  String? get linksPrev => _linksPrev;

  // ---------- UI state ----------
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // ---------- Zones ----------
  List<ZoneModel> _zoneModels = [];
  List<SubZoneModel> _subzoneModels = [];
  String? _selectedZoneSub;
  String? _selectedZone;
  String? _selectedZoneSer; // ser ของ zone ที่เลือก

  List<ZoneModel> get zoneModels => _zoneModels;
  List<SubZoneModel> get subzoneModels => _subzoneModels;
  String? get selectedZoneSub => _selectedZoneSub;
  String? get selectedZone => _selectedZone;
  String? get selectedZoneSer => _selectedZoneSer;

  // ---------- Config getters ----------
  String get title => _config.title;
  String? get routeData => _config.routeData;
  bool get readOnly => _config.readOnly;

  // ===============================================================
  // Init
  // ===============================================================
  Future<void> _loadInitial() async {
    if (_config.routeData != null && _config.routeData!.isNotEmpty) {
      _searchQuery = _config.routeData!;
    }
    await Future.wait([
      loadSubZones(),
      loadZones(),
    ]);
    await refresh();
  }

  // ===============================================================
  // Zone filters
  // ===============================================================
  Future<void> loadSubZones() async {
    try {
      _subzoneModels = await _service.fetchSubZones();
      notifyListeners();
    } catch (e) {
      print('loadSubZones error: $e');
    }
  }

  Future<void> loadZones({String? zoneSubSer}) async {
    try {
      _zoneModels = await _service.fetchZones(zoneSubSer: zoneSubSer);
      notifyListeners();
    } catch (e) {
      print('loadZones error: $e');
    }
  }

  /// ผู้ใช้เลือก "หมวดโซนพื้นที่" (sub-zone)
  /// → reset "โซนพื้นที่" เป็น "ทั้งหมด"
  /// → reload zones (filter ตาม sub_zone)
  /// → ดึง API คำขอใหม่ (zn=null = ทั้งหมด)
  Future<void> onSubZoneChanged(String? value) async {
    if (value == null) return;

    // 1) ตั้งค่า sub-zone ที่เลือก
    _selectedZoneSub = value;

    // 2) Reset "โซนพื้นที่" กลับเป็น "ทั้งหมด"
    _selectedZone = 'ทั้งหมด';
    _selectedZoneSer = '0';

    notifyListeners();

    // 3) Reload zones ตาม sub-zone
    final sub = _subzoneModels.firstWhere(
      (s) => s.zn == value,
      orElse: () => SubZoneModel(),
    );
    final subSer = (sub.ser == '0' || sub.ser == null) ? null : sub.ser;
    await loadZones(zoneSubSer: subSer);

    // 4) ดึง API คำขอต่อสัญญาใหม่ (zn=null = ทั้งหมด)
    await refresh();
  }

  /// ผู้ใช้เลือก "โซน" → reload คำขอต่อสัญญา filter ด้วย zn
  Future<void> onZoneChanged(String? value) async {
    if (value == null) return;
    _selectedZone = value;
    // หา ser จาก zn
    final zone = _zoneModels.firstWhere(
      (z) => z.zn == value,
      orElse: () => ZoneModel(),
    );
    _selectedZoneSer = zone.ser;
    notifyListeners();
    // ดึง API คำขอต่อสัญญา filter ด้วย zn
    await refresh();
  }

  // ===============================================================
  // Service calls
  // ===============================================================
  /// Auto-detect search field ตามค่าที่ผู้ใช้พิมพ์
  /// - UUID  → 'uuid'
  /// - ตัวเลข → 'tel' (เบอร์โทร)
  /// - อื่นๆ → 'scname' (ชื่อผู้ติดต่อ)
  String _autoSearchField(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'scname';

    // UUID pattern (8-4-4-4-12 hex)
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    if (uuidRegex.hasMatch(v)) return 'uuid';

    // ตัวเลข 9-10 หลัก → น่าจะเป็นเบอร์โทร
    final phoneRegex = RegExp(r'^[0-9]{8,12}$');
    if (phoneRegex.hasMatch(v.replaceAll(RegExp(r'[\s\-]'), ''))) return 'tel';

    return 'scname';
  }

  Future<void> refresh() async {
    _setLoading(true);
    try {
      final res = await _service.fetchRequests(
        query: _searchQuery,
        searchField: _autoSearchField(_searchQuery),
        // ถ้าเลือก "ทั้งหมด" (ser=0) ให้ส่ง null — ไม่ filter
        zn: (_selectedZone == null ||
                _selectedZone == '0' ||
                _selectedZone == 'ทั้งหมด')
            ? null
            : _selectedZone,
      );
      _requests = res.data;
      _currentPage = res.currentPage;
      _lastPage = res.lastPage;
      _total = res.total;
      _linksNext = res.linksNext;
      _linksPrev = res.linksPrev;
    } catch (e) {
      _emitError('โหลดข้อมูลไม่สำเร็จ: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadPage(String? url) async {
    if (url == null || url.isEmpty) return;
    _setLoading(true);
    try {
      final res = await _service.fetchRequests(
        urlCustom: url,
        query: _searchQuery,
        searchField: _autoSearchField(_searchQuery),
        zn: (_selectedZone == null ||
                _selectedZone == '0' ||
                _selectedZone == 'ทั้งหมด')
            ? null
            : _selectedZone,
      );
      _requests = res.data;
      _currentPage = res.currentPage;
      _lastPage = res.lastPage;
      _total = res.total;
      _linksNext = res.linksNext;
      _linksPrev = res.linksPrev;
    } catch (e) {
      _emitError('โหลดหน้าไม่สำเร็จ: $e');
    } finally {
      _setLoading(false);
    }
  }

  void setSearch(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  Future<void> executeSearch() async {
    await refresh();
  }

  // ===============================================================
  // User actions
  // ===============================================================
  /// ผู้ใช้กดปุ่ม "สร้างคำขอ" → ให้ View เปิด popup

  /// ผู้ใช้กดปุ่ม "เรียกดู" ในแถว → ส่ง event ให้ View เปิด full-page route
  void onViewRequest(ReviewModel model) {
    final uuid = model.newRequest?.requestUuid?.toString() ??
        model.uuid?.toString() ??
        '';
    _eventController.add(
      LicenseAttachNavigateEvent('แนบหลักฐาน', routeData: uuid),
    );
  }

  // ===============================================================
  // Helpers
  // ===============================================================
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _emitError(String msg) {
    _eventController.add(LicenseAttachErrorEvent(msg));
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
