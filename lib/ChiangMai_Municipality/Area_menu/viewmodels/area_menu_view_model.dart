// ============================================================================
// area_menu_view_model.dart
// ============================================================================
// ViewModel — หน้า "พื้นที่เช่า"
// Data Source: GET /api/v2/admin/areas/overview — SERVER-DRIVEN
// - ลอจิกยิง API สำรองมาจาก license_request_view_model:
//   เลือก dropdown → sync ZoneSelectionStore → listener resolve ser →
//   reload รายการโซน (กรอง sub_zone) + ยิง overview หน้า 1 ใหม่ทุกครั้ง
// - sort (sort_by / sort_dir), pagination server-side
// ============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../unity/zone_selection_store.dart';
import '../models/area_menu_event.dart' as evt;
import '../services/area_menu_service.dart';

class AreaMenuViewModel extends ChangeNotifier {
  AreaMenuViewModel({
    String title = 'พื้นที่เช่า',
    String? routeData,
    bool readOnly = false,
    AreaMenuService? service,
  })  : _title = title,
        _routeData = routeData,
        _readOnly = readOnly,
        _service = service ?? AreaMenuService() {
    if (routeData != null && routeData.isNotEmpty) {
      _searchQuery = routeData;
    }
    // sync จาก global store ('ทั้งหมด' → null เหมือน license)
    _selectedZoneSub = ZoneSelectionStore.instance.areaSubZone == 'ทั้งหมด'
        ? null
        : ZoneSelectionStore.instance.areaSubZone;
    _selectedZone = ZoneSelectionStore.instance.areaZone == 'ทั้งหมด'
        ? null
        : ZoneSelectionStore.instance.areaZone;
    _selectedRequestStatus = ZoneSelectionStore.instance.areaRequestStatus;
    _selectedStatus = ZoneSelectionStore.instance.areaLeaseStatus;
    ZoneSelectionStore.instance.addListener(_onZoneStoreChanged);
    _loadInitial();
  }

  final AreaMenuService _service;
  final ZoneSelectionStore _zoneStore = ZoneSelectionStore.instance;

  void _onZoneStoreChanged() {
    final newSub = _zoneStore.areaSubZone == 'ทั้งหมด'
        ? null
        : _zoneStore.areaSubZone;
    final newZone = _zoneStore.areaZone == 'ทั้งหมด'
        ? null
        : _zoneStore.areaZone;
    final newRequestStatus = _zoneStore.areaRequestStatus;
    final newLeaseStatus = _zoneStore.areaLeaseStatus;
    final subChanged = _selectedZoneSub != newSub;
    final zoneChanged = _selectedZone != newZone;
    final reqChanged = _selectedRequestStatus != newRequestStatus;
    final leaseChanged = _selectedStatus != newLeaseStatus;
    if (!subChanged && !zoneChanged && !reqChanged && !leaseChanged) return;

    _selectedZoneSub = newSub;
    _selectedZone = newZone;
    _selectedRequestStatus = newRequestStatus;
    _selectedStatus = newLeaseStatus;

    notifyListeners();

    // resolve sub-ser + reload รายการโซน (กรองตามหมวด) — เหมือน license
    String? subSer;
    if (_selectedZoneSub != null) {
      final sub = _subzoneModels.firstWhere(
        (s) => s['zn']?.toString() == _selectedZoneSub,
        orElse: () => const <String, dynamic>{'ser': '0', 'zn': ''},
      );
      final ser = sub['ser']?.toString();
      subSer = (ser == '0' || ser == null || ser.isEmpty) ? null : ser;
      loadZones(subzoneSer: subSer);
    }
    refresh(); // ✅ ยิง API ทุกครั้งที่เลือกใหม่
  }

  // ---------- Event channel ----------
  final StreamController<evt.AreaMenuEvent> _eventController =
      StreamController<evt.AreaMenuEvent>.broadcast();
  Stream<evt.AreaMenuEvent> get events => _eventController.stream;

  // ---------- Data (หน้าปัจจุบันจาก API) ----------
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> get requests => _items;

  // ---------- Stats (จาก API) ----------
  int? _totalArea;
  int? _totalLeased;
  int? _totalVacant;
  int? _duplicateLeases;
  String? _reportDate;

  int? get totalArea => _totalArea;
  int? get totalLeased => _totalLeased;
  int? get totalVacant => _totalVacant;
  int? get duplicateLeases => _duplicateLeases;
  String? get reportDate => _reportDate;

  // ---------- Sort (เหมือน license) ----------
  /// key ที่ API รับ (sort_by)
  static const List<String> sortOptions = <String>[
    'lock',
    'zone',
    'subzone',
    'status',
  ];

  /// ป้ายภาษาไทย (key → label)
  static const Map<String, String> sortLabels = <String, String>{
    'lock': 'ล็อค',
    'zone': 'โซน',
    'subzone': 'หมวดโซน',
    'status': 'สถานะ',
  };

  String _selectedSort = 'lock';
  String _selectedSortDir = 'asc';
  String get selectedSort => _selectedSort;
  String get selectedSortDir => _selectedSortDir;

  /// ผู้ใช้เลือก key sort → ยิง API ใหม่
  Future<void> onSortChanged(String? value) async {
    _selectedSort = (value == null || value.isEmpty) ? 'lock' : value;
    notifyListeners();
    await refresh();
  }

  /// สลับ asc/desc → ยิง API ใหม่
  Future<void> onSortDirChanged() async {
    _selectedSortDir = _selectedSortDir == 'asc' ? 'desc' : 'asc';
    notifyListeners();
    await refresh();
  }

  // ---------- Status filter (UI เดิม — เก็บ contract ไว้) ----------
  static const List<String> _statusLabels = [
    'ทั้งหมด',
    'เช่าอยู่',
    'หมดสัญญา',
    'ว่าง',
  ];

  String _selectedStatus = 'ทั้งหมด';
  String get selectedStatus => _selectedStatus;
  List<String> get statusOptions => _statusLabels;

  // ---------- Request status filter (server param `status`) ----------
  static const Map<String, String> _requestStatusKeyMap = {
    'ฉบับร่าง': 'draft',
    'ส่งเอกสารแล้ว': 'documents_submitted',
    'รอข้อมูลชำระเงิน': 'waiting_payment_info',
    'ชำระเงินแล้ว': 'payment_submitted',
    'ส่งคำขอแล้ว': 'request_submitted',
    'ต้องแก้ไข': 'needs_update',
    'กำลังพิจารณา': 'under_review',
    'กำลังดำเนินการ': 'in_progress',
    'คำขอเสร็จสิ้น': 'request_completed',
    'เสร็จสิ้น': 'completed',
    'ถูกปฏิเสธ': 'rejected',
  };

  static const List<String> _requestStatusLabels = [
    'ทั้งหมด',
    'ฉบับร่าง',
    'ส่งเอกสารแล้ว',
    'รอข้อมูลชำระเงิน',
    'ชำระเงินแล้ว',
    'ส่งคำขอแล้ว',
    'ต้องแก้ไข',
    'กำลังพิจารณา',
    'กำลังดำเนินการ',
    'คำขอเสร็จสิ้น',
    'เสร็จสิ้น',
    'ถูกปฏิเสธ',
  ];

  String _selectedRequestStatus = 'ทั้งหมด';
  String get selectedRequestStatus => _selectedRequestStatus;
  List<String> get requestStatusOptions => _requestStatusLabels;

  /// UI dropdown item — TH label + EN key
  List<Map<String, String>> get requestStatusItems {
    return _requestStatusLabels.map((th) {
      return {
        'th': th,
        'en': th == 'ทั้งหมด' ? '' : (_requestStatusKeyMap[th] ?? ''),
      };
    }).toList(growable: false);
  }

  // ---------- Zones (Map {ser, zn} — ลอจิกเหมือน license) ----------
  List<Map<String, dynamic>> _subzoneModels = [
    {'ser': '0', 'zn': 'ทั้งหมด'},
  ];
  List<Map<String, dynamic>> _zoneModels = [
    {'ser': '0', 'zn': 'ทั้งหมด'},
  ];
  String? _selectedZoneSub;
  String? _selectedZone;

  List<Map<String, dynamic>> get subzoneModels => _subzoneModels;
  List<Map<String, dynamic>> get zoneModels => _zoneModels;
  String? get selectedZoneSub => _selectedZoneSub;
  String? get selectedZone => _selectedZone;

  /// name → ser ('ทั้งหมด'/ไม่เจอ → null = ไม่ส่ง param)
  String? _resolveSubzoneSer(String? name) {
    if (name == null || name.isEmpty || name == 'ทั้งหมด') return null;
    for (final m in _subzoneModels) {
      if (m['zn']?.toString() == name) {
        final ser = m['ser']?.toString();
        return (ser == null || ser.isEmpty || ser == '0') ? null : ser;
      }
    }
    return null;
  }

  String? _resolveZoneSer(String? name) {
    if (name == null || name.isEmpty || name == 'ทั้งหมด') return null;
    for (final m in _zoneModels) {
      if (m['zn']?.toString() == name) {
        final ser = m['ser']?.toString();
        return (ser == null || ser.isEmpty || ser == '0') ? null : ser;
      }
    }
    return null;
  }

  // ---------- Search ----------
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // ---------- Pagination (server-side) ----------
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalRows = 0;

  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get total => _totalRows;
  bool get canPrev => _currentPage > 1;
  bool get canNext => _currentPage < _lastPage;

  // ---------- Misc ----------
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool get readOnly => _readOnly;
  final bool _readOnly;

  String get title => _title;
  final String _title;
  final String? _routeData;

  // ===============================================================
  // Init — เหมือน license _loadInitial
  // ===============================================================
  Future<void> _loadInitial() async {
    // 1) โหลดหมวดโซนก่อน (resolve ser)
    await loadSubZones();
    // 2) resolve sub-ser + โหลดโซนที่กรองแล้ว
    String? subSer;
    if (_selectedZoneSub != null && _selectedZoneSub!.isNotEmpty) {
      final sub = _subzoneModels.firstWhere(
        (s) => s['zn']?.toString() == _selectedZoneSub,
        orElse: () => const <String, dynamic>{'ser': '0', 'zn': ''},
      );
      final ser = sub['ser']?.toString();
      subSer = (ser == '0' || ser == null || ser.isEmpty) ? null : ser;
    }
    await loadZones(subzoneSer: subSer);
    // 3) ยิง overview
    await loadOverview();
  }

  Future<void> loadSubZones() async {
    try {
      _subzoneModels = await _service.fetchSubZones();
      notifyListeners();
    } catch (e) {
      print('[Area] loadSubZones error: $e');
    }
  }

  Future<void> loadZones({String? subzoneSer}) async {
    try {
      _zoneModels = await _service.fetchZones(subzoneSer: subzoneSer);
      notifyListeners();
    } catch (e) {
      print('[Area] loadZones error: $e');
    }
  }

  /// ยิง API 1 หน้า — filter ทั้งหมดเป็น query params
  Future<void> loadOverview({bool forceRefresh = false, int? page}) async {
    if (_isLoading && !forceRefresh && page == null) return;
    _setLoading(true);
    try {
      final result = await _service.fetchAreasOverview(
        forceRefresh: forceRefresh,
        zoneSer: _resolveZoneSer(_selectedZone),
        subzoneSer: _resolveSubzoneSer(_selectedZoneSub),
        q: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
        status: _requestStatusKeyMap[_selectedRequestStatus],
        sortBy: _selectedSort,
        sortDir: _selectedSortDir,
        page: page ?? _currentPage,
      );
      _items = result.items.map((it) => it.toJson()).toList(growable: false);
      _totalArea = result.totalArea;
      _totalLeased = result.totalLeased;
      _totalVacant = result.totalVacant;
      _duplicateLeases = result.duplicateLeases;
      _reportDate = result.date;
      _currentPage = result.currentPage;
      _lastPage = result.lastPage;
      _totalRows = result.totalRows;
      notifyListeners();
    } catch (e) {
      _emitError('โหลดข้อมูลไม่สำเร็จ: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() => loadOverview(forceRefresh: true, page: 1);

  /// Stub เดิม (backward compat)
  Future<void> loadPage(String? url) async {}

  /// เปลี่ยนหน้า — ยิง API ใหม่
  Future<void> goToPage(int page) async {
    if (page < 1 || page > _lastPage || page == _currentPage) return;
    await loadOverview(page: page);
  }

  Future<void> nextPage() => goToPage(_currentPage + 1);
  Future<void> prevPage() => goToPage(_currentPage - 1);

  // ===============================================================
  // Filter handlers — เหมือน license: sync store → listener ยิง API
  // ===============================================================
  Future<void> onSubZoneChanged(String? value) async {
    if (value == null) return;
    _zoneStore.setAreaSubZone(value);
  }

  Future<void> onZoneChanged(String? value) async {
    if (value == null) return;
    _zoneStore.setAreaZone(value);
  }

  void onStatusChanged(String? value) {
    // lease-status dropdown ถูกลบจาก UI แล้ว — sync store อย่างเดียว
    _selectedStatus = value ?? 'ทั้งหมด';
    _zoneStore.setAreaLeaseStatus(_selectedStatus);
  }

  void onRequestStatusChanged(String? value) {
    final next = value ?? 'ทั้งหมด';
    if (_selectedRequestStatus == next) return;
    _selectedRequestStatus = next;
    _zoneStore.setAreaRequestStatus(next);
    notifyListeners();
    refresh(); // ✅ ยิง API ทุกครั้งที่เลือกใหม่
  }

  void setSearch(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  /// debounce 500ms จาก search bar เรียก — ยิง API หน้า 1
  Future<void> executeSearch() async {
    await loadOverview(page: 1);
  }

  /// ผู้ใช้กด "เรียกดู" → ส่ง composite key
  void onViewRequest(Map<String, dynamic> model) {
    final key = model['key']?.toString() ??
        '${model['subzone'] ?? ''}|${model['zone'] ?? ''}|${model['lock'] ?? ''}';
    _eventController.add(
      evt.AreaMenuNavigateEvent(_title, routeData: key),
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
    _eventController.add(evt.AreaMenuErrorEvent(msg));
  }

  /// คำนวณ status label (TH) จาก item — display เท่านั้น (filter เป็นของ server)
  static String _computeStatusLabel(Map<String, dynamic> r) {
    final requester = r['requester']?.toString() ?? '';
    final hasRequester = requester.isNotEmpty;
    final ldate = r['ldate']?.toString() ?? '';

    if (hasRequester && ldate.isNotEmpty) {
      try {
        final end = DateTime.parse(ldate);
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final endDay = DateTime(end.year, end.month, end.day);
        if (endDay.isBefore(today)) return 'หมดสัญญา';
      } catch (_) {}
    }

    if (hasRequester) return 'เช่าอยู่';
    return 'ว่าง';
  }

  /// Public wrapper สำหรับ widget เรียกใช้
  static String computeStatusLabel(Map<String, dynamic> r) =>
      _computeStatusLabel(r);

  /// ✅ สถานะ pill แสดง "สถานะคำขอ" จาก API (`status` EN key → TH)
  /// null/ว่าง → 'ว่าง' (ยังไม่มีคำขอ)
  static String requestStatusLabel(Map<String, dynamic> r) {
    final key = (r['status']?.toString() ?? '').trim();
    if (key.isEmpty) return 'ว่าง';
    for (final entry in _requestStatusKeyMap.entries) {
      if (entry.value == key) return entry.key;
    }
    return key; // key ใหม่ที่ยังไม่มี label — แสดงดิบ
  }

  @override
  void dispose() {
    _zoneStore.removeListener(_onZoneStoreChanged);
    _eventController.close();
    super.dispose();
  }
}