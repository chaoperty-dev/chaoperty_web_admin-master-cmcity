// ============================================================================
// license_fact_check_view_model.dart
// ============================================================================
// ViewModel — จัดการ state + business logic ของหน้า "ตรวจสอบข้อเท็จจริง"
//
// v2 (2026-08): ใช้ข้อมูลจาก /api/v2/admin/requests/tasks/inspections
// - แต่ละแถวเป็น FactCheckItem (model เป็นของตัวเอง ไม่แชร์กับหน้าอื่น)
// - เรียก Service.fetchInspections()
// - แจ้ง View ผ่าน Stream<LicensefactcheckEvent>
// - ไม่ผูกกับ Flutter UI
// ============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../Model/GetZone_Model.dart';
import '../../../../Model/GetSubZone_Model.dart';
import '../unity/license_status_labels.dart';
import '../unity/zone_selection_store.dart';
import '../models/fact_check_item.dart';
import '../models/license_fact_check_config.dart';
import '../models/license_fact_check_event.dart';
import '../services/license_fact_check_service.dart';

class LicensefactcheckViewModel extends ChangeNotifier {
  LicensefactcheckViewModel({
    required LicensefactcheckConfig config,
    LicensefactcheckService? service,
  })  : _config = config,
        _service = service ?? LicensefactcheckService() {
    // ✅ sync state จาก global store (license scope)
    _selectedZoneSub = ZoneSelectionStore.instance.licenseSubZone == 'ทั้งหมด'
        ? null
        : ZoneSelectionStore.instance.licenseSubZone;
    _selectedZone = ZoneSelectionStore.instance.licenseZone == 'ทั้งหมด'
        ? null
        : ZoneSelectionStore.instance.licenseZone;
    _selectedZoneSer = '0';
    _selectedStatus = ZoneSelectionStore.instance.licenseStatus;
    ZoneSelectionStore.instance.addListener(_onZoneStoreChanged);
    _loadInitial();
  }

  final LicensefactcheckConfig _config;
  final LicensefactcheckService _service;
  final ZoneSelectionStore _zoneStore = ZoneSelectionStore.instance;

  Future<void> _onZoneStoreChanged() async {
    final newSub = _zoneStore.licenseSubZone == 'ทั้งหมด'
        ? null
        : _zoneStore.licenseSubZone;
    final newZone = _zoneStore.licenseZone == 'ทั้งหมด'
        ? null
        : _zoneStore.licenseZone;
    final newStatus = _zoneStore.licenseStatus;
    final subChanged = _selectedZoneSub != newSub;
    final zoneChanged = _selectedZone != newZone;
    final statusChanged = _selectedStatus != newStatus;
    if (!subChanged && !zoneChanged && !statusChanged) return;

    _selectedZoneSub = newSub;
    _selectedZone = newZone;
    _selectedZoneSer = '0';
    _selectedStatus = newStatus;

    notifyListeners();

    // resolve sub-ser + reload zones filtered
    String? subSer;
    if (_selectedZoneSub != null) {
      final sub = _subzoneModels.firstWhere(
        (s) => s.zn == _selectedZoneSub,
        orElse: () => SubZoneModel(),
      );
      subSer = (sub.ser == '0' || sub.ser == null) ? null : sub.ser;
      await loadZones(zoneSubSer: subSer);
    }
    if (_selectedZone != null && _selectedZone!.isNotEmpty) {
      final zone = _zoneModels.firstWhere(
        (z) => z.zn == _selectedZone,
        orElse: () => ZoneModel(),
      );
      _selectedZoneSer = zone.ser;
    }
    await refresh();
  }

  // ---------- Event channel ----------
  final StreamController<LicensefactcheckEvent> _eventController =
      StreamController<LicensefactcheckEvent>.broadcast();
  Stream<LicensefactcheckEvent> get events => _eventController.stream;

  // ---------- Data ----------
  List<FactCheckItem> _items = [];
  List<FactCheckItem> get items => _items;

  /// Backward-compat alias (UI เก่าเรียก vm.requests)
  List<FactCheckItem> get requests => _items;

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
  String? _selectedZoneSer;

  List<ZoneModel> get zoneModels => _zoneModels;
  List<SubZoneModel> get subzoneModels => _subzoneModels;
  String? get selectedZoneSub => _selectedZoneSub;
  String? get selectedZone => _selectedZone;
  String? get selectedZoneSer => _selectedZoneSer;

  // ---------- Status filter ----------
  /// รายการ status ทั้งหมดที่ filter ได้
  /// (null = "ทั้งหมด" — ไม่ส่ง key ให้ backend)
  static List<String> get statusOptions => LicenseStatusLabels.options;

  /// ป้ายภาษาไทยสำหรับ status (ใช้โชว์ใน dropdown ของ filter)
  static String statusLabel(String key) => LicenseStatusLabels.th(key);

  /// ค่าปัจจุบัน (string = enum, null = ทั้งหมด)
  String? _selectedStatus;
  String? get selectedStatus => _selectedStatus;

  /// ผู้ใช้เลือก "สถานะ" — ถ้าเป็น "ทั้งหมด" หรือ null → ไม่ส่ง key
  Future<void> onStatusChanged(String? value) async {
    _zoneStore.setLicenseStatus(value);
  }

  /// แปลง _selectedStatus เป็น List<String>? สำหรับส่งให้ service
  List<String>? get _statusesFilter {
    final s = _selectedStatus;
    if (s == null) return null;
    return <String>[s];
  }

  // ---------- Sort ----------
  /// รายการ key ที่ backend รองรับ (ตรงกับ API `sort_by` allowed values)
  static const List<String> sortOptions = <String>[
    'created_at',
    'submitted_at',
    'completed_at',
    'status',
    'fee_amount',
    'id',
    'zn',
    'ln',
  ];

  /// ป้ายภาษาไทย (key → label)
  static const Map<String, String> sortLabels = <String, String>{
    'created_at': 'วันที่สร้าง',
    'submitted_at': 'วันที่ส่งคำขอ',
    'completed_at': 'วันที่เสร็จ',
    'status': 'สถานะ',
    'fee_amount': 'ค่าธรรมเนียม',
    'id': 'รหัส',
    'zn': 'โซน',
    'ln': 'lease number',
  };

  String _selectedSort = 'created_at';
  String _selectedSortDir = 'desc';
  String get selectedSort => _selectedSort;
  String get selectedSortDir => _selectedSortDir;

  /// ผู้ใช้เลือก key sort → ส่งให้ backend
  Future<void> onSortChanged(String? value) async {
    _selectedSort = (value == null || value.isEmpty) ? 'created_at' : value;
    notifyListeners();
    await refresh();
  }

  /// สลับ asc/desc
  Future<void> onSortDirChanged() async {
    _selectedSortDir = _selectedSortDir == 'asc' ? 'desc' : 'asc';
    notifyListeners();
    await refresh();
  }

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
    // 1) load sub-zones first (need ser lookup)
    await loadSubZones();
    // 2) resolve selected sub's ser from store
    String? subSer;
    if (_selectedZoneSub != null && _selectedZoneSub!.isNotEmpty) {
      final sub = _subzoneModels.firstWhere(
        (s) => s.zn == _selectedZoneSub,
        orElse: () => SubZoneModel(),
      );
      subSer = (sub.ser == '0' || sub.ser == null) ? null : sub.ser;
    }
    await loadZones(zoneSubSer: subSer);
    // 3) resolve zone ser from filtered list
    if (_selectedZone != null && _selectedZone!.isNotEmpty) {
      final zn = _zoneModels.firstWhere(
        (z) => z.zn == _selectedZone,
        orElse: () => ZoneModel(),
      );
      _selectedZoneSer = zn.ser;
    }
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

  /// ผู้ใช้เลือก "หมวดโซนพื้นที่" (sub-zone) → sync ไปที่ global store
  Future<void> onSubZoneChanged(String? value) async {
    if (value == null) return;
    _zoneStore.setLicenseSubZone(value);
  }

  /// ผู้ใช้เลือก "โซน" → sync ไปที่ global store
  Future<void> onZoneChanged(String? value) async {
    if (value == null) return;
    _zoneStore.setLicenseZone(value);
  }

  // ===============================================================
  // Service calls (v2)
  // ===============================================================
  /// โหลดรายการ fact-check (inspections) — v2 endpoint
  Future<void> refresh() async {
    _setLoading(true);
    try {
      // API ต้องการ zser (serial) ไม่ใช่ชื่อโซน — ส่งเป็น zser
      final zserRaw = _selectedZoneSer;
      final zserFilter =
          (zserRaw == null || zserRaw == '0' || zserRaw.isEmpty)
              ? null
              : zserRaw;
      final res = await _service.fetchInspections(
        query: _searchQuery,
        page: 1,
        zser: zserFilter,
        statuses: _statusesFilter,
        sortBy: _selectedSort,
        sortDir: _selectedSortDir,
      );
      _items = res.items;
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

  /// โหลดหน้าถัดไป/ก่อนหน้า (จาก pagination links)
  Future<void> loadPage(String? url) async {
    if (url == null || url.isEmpty) return;
    _setLoading(true);
    try {
      final zserRaw = _selectedZoneSer;
      final zserFilter =
          (zserRaw == null || zserRaw == '0' || zserRaw.isEmpty)
              ? null
              : zserRaw;
      final res = await _service.fetchInspections(
        urlCustom: url,
        query: _searchQuery,
        zser: zserFilter,
        statuses: _statusesFilter,
        sortBy: _selectedSort,
        sortDir: _selectedSortDir,
      );
      _items = res.items;
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
  /// ผู้ใช้กดปุ่ม "เรียกดู" ในแถว → ส่ง event ให้ View เปิด full-page route
  void onViewRequest(FactCheckItem item) {
    _eventController.add(
      LicensefactcheckNavigateEvent('ตรวจสอบข้อเท็จจริง', routeData: item.uuid),
    );
  }

  /// Backward-compat: alias สำหรับ UI เก่า (dynamic type)
  void onViewRequestDynamic(dynamic model) {
    if (model is FactCheckItem) {
      onViewRequest(model);
    }
  }

  // ===============================================================
  // Helpers
  // ===============================================================
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _emitError(String msg) {
    _eventController.add(LicensefactcheckErrorEvent(msg));
  }

  @override
  void dispose() {
    _zoneStore.removeListener(_onZoneStoreChanged);
    _eventController.close();
    super.dispose();
  }
}
