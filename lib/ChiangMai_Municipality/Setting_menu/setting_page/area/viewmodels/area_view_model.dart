// ============================================================================
// area_view_model.dart
// ============================================================================
// ViewModel — จัดการ state + business logic ของหน้า "ตั้งค่าพื้นที่เช่า"
// - โหลด groups / zones-of-group / locks จาก v2 API
// - แจ้ง View ผ่าน Stream<AreaEvent>
// - CRUD ครบทั้ง group / zone / lock (area)
// ============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/area_area_model.dart';
import '../models/area_config.dart';
import '../models/area_event.dart';
import '../models/area_zone_model.dart';
import '../services/area_service.dart';

/// รูปแบบการแสดงผลรายการ Area
enum AreaViewMode { table, card }

class AreaViewModel extends ChangeNotifier {
  AreaViewModel({
    required AreaConfig config,
    AreaService? service,
  })  : _config = config,
        _service = service ?? AreaService() {
    _bootstrap();
  }

  final AreaConfig _config;
  final AreaService _service;

  // ---------- Event channel ----------
  final StreamController<AreaEvent> _eventController =
      StreamController<AreaEvent>.broadcast();
  Stream<AreaEvent> get events => _eventController.stream;

  // ---------- Data: groups (หมวด) ----------
  List<AreaZoneModel> _groups = [];
  List<AreaZoneModel> get groups => _groups;

  String? _selectedGroupSer;
  String? _selectedGroupName;
  String? get selectedGroupSer => _selectedGroupSer;
  String? get selectedGroupName => _selectedGroupName;

  /// หมวดที่เลือกอยู่ (null = ยังโหลดไม่เสร็จ)
  AreaZoneModel? get selectedGroup {
    if (_selectedGroupSer == null) return null;
    return _groups.firstWhere(
      (g) => g.ser == _selectedGroupSer,
      orElse: () => const AreaZoneModel(ser: '', rser: '', zn: ''),
    );
  }

  // ---------- Data: zones (โซนของหมวดที่เลือก) ----------
  List<AreaZoneModel> _zonesOfGroup = [];
  List<AreaZoneModel> get zones => _zonesOfGroup;

  String? _selectedZoneSer;
  String? _selectedZoneName;
  String? get selectedZoneSer => _selectedZoneSer;
  String? get selectedZoneName => _selectedZoneName;

  /// โซนที่เลือกอยู่ (null = ไม่ได้เลือก หรือ "ทั้งหมด")
  AreaZoneModel? get selectedZone {
    if (_selectedZoneSer == null) return null;
    return _zonesOfGroup.firstWhere(
      (z) => z.ser == _selectedZoneSer,
      orElse: () => const AreaZoneModel(ser: '', rser: '', zn: ''),
    );
  }

  // ---------- Data: areas (locks) ----------
  List<AreaAreaModel> _areas = [];
  List<AreaAreaModel> get areas => _areas;

  List<AreaAreaModel> _filtered = [];
  List<AreaAreaModel> get filtered => _filtered;

  int _areaCount = 0;
  int get areaCount => _areaCount;

  // ---------- UI state ----------
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // ---------- View mode (table / card) ----------
  AreaViewMode _viewMode = AreaViewMode.card;
  AreaViewMode get viewMode => _viewMode;
  void setViewMode(AreaViewMode mode) {
    if (_viewMode == mode) return;
    _viewMode = mode;
    notifyListeners();
  }

  // ---------- Pagination (client-side over locks list) ----------
  int _currentPage = 1;
  final int _pageSize = 50;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalPages {
    if (_filtered.isEmpty) return 1;
    final n = (_filtered.length / _pageSize).ceil();
    return n < 1 ? 1 : n;
  }

  // ---------- Config getters ----------
  String get title => _config.title;
  bool get readOnly => _config.readOnly;

  // ===============================================================
  // Init
  // ===============================================================
  Future<void> _bootstrap() async {
    await _loadGroups();
    // default: เลือก "ทั้งหมด" (sentinel ser='0' จะถูก prepend ใน fetchGroups)
    final all = _groups.where((g) => g.ser == '0').firstOrNull;
    if (all != null) {
      _selectedGroupSer = all.ser;
      _selectedGroupName = all.zn;
    } else if (_groups.isNotEmpty) {
      _selectedGroupSer = _groups.first.ser;
      _selectedGroupName = _groups.first.zn;
    }
    notifyListeners();
    await _loadAreas();
  }

  /// Public refresh — ใช้รีเฟรชข้อมูลจากภายนอก (เช่น EmptyState)
  Future<void> refresh() => _loadAreas();

  // ===============================================================
  // Loaders
  // ===============================================================
  Future<void> _loadGroups() async {
    final list = await _service.fetchGroups();
    _groups = list;
  }

  Future<void> _loadZonesOfGroup(String groupSer) async {
    if (groupSer == '0' || groupSer.isEmpty) {
      _zonesOfGroup = [];
    } else {
      _zonesOfGroup = await _service.fetchZonesOfGroup(groupSer);
    }
  }

  Future<void> _loadAreas() async {
    _isLoading = true;
    notifyListeners();
    // zone_ser ส่งเป็น zone จริง ถ้าไม่มีก็ส่ง group ser (filter locks ใน group นั้น)
    // ถ้าเป็น "ทั้งหมด" (group=0) → ไม่ส่ง zone_ser เลย (ทั้งหมด)
    final zoneSer = _selectedZoneSer ??
        ((_selectedGroupSer == '0' || _selectedGroupSer == null)
            ? ''
            : _selectedGroupSer!);
    final result = await _service.fetchLocks(
      perPage: 200,
      zoneSer: zoneSer,
      q: _searchQuery,
    );
    _areas = result.data;
    _areaCount = result.total;
    _applyFilter();
    _isLoading = false;
    notifyListeners();
  }

  // ===============================================================
  // Selection: group / zone
  // ===============================================================
  Future<void> onGroupChanged(String? ser, String? name) async {
    _selectedGroupSer = ser;
    _selectedGroupName = name;
    _selectedZoneSer = null;
    _selectedZoneName = null;
    _currentPage = 1;
    notifyListeners();
    if (ser != null && ser != '0') {
      await _loadZonesOfGroup(ser);
    } else {
      _zonesOfGroup = [];
    }
    notifyListeners();
    await _loadAreas();
  }

  Future<void> onZoneChanged(String? ser, String? name) async {
    _selectedZoneSer = ser;
    _selectedZoneName = name;
    _currentPage = 1;
    notifyListeners();
    await _loadAreas();
  }

  // ===============================================================
  // Search
  // ===============================================================
  void setSearch(String value) {
    _searchQuery = value;
    _currentPage = 1;
    notifyListeners();
  }

  Future<void> executeSearch() async {
    _currentPage = 1;
    await _loadAreas();
  }

  // ===============================================================
  // Pagination
  // ===============================================================
  void nextPage() {
    if (_currentPage < totalPages) {
      _currentPage += 1;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      _currentPage -= 1;
      notifyListeners();
    }
  }

  // ===============================================================
  // CRUD: Group
  // ===============================================================
  Future<bool> addGroup({required String zn, int qty = 0}) async {
    final ok = await _service.addGroup(zn: zn, qty: qty);
    if (ok) {
      _emit(const AreaSuccessEvent('เพิ่มหมวดสำเร็จ'));
      await _loadGroups();
      notifyListeners();
    } else {
      _emit(const AreaErrorEvent('เพิ่มหมวดล้มเหลว'));
    }
    return ok;
  }

  Future<bool> updateGroup({
    required String ser,
    required String zn,
    int? qty,
  }) async {
    final ok = await _service.updateGroup(ser: ser, zn: zn, qty: qty);
    if (ok) {
      _emit(const AreaSuccessEvent('แก้ไขหมวดสำเร็จ'));
      await _loadGroups();
      notifyListeners();
    } else {
      _emit(const AreaErrorEvent('แก้ไขหมวดล้มเหลว'));
    }
    return ok;
  }

  Future<bool> deleteGroup({
    required String ser,
    required String name,
  }) async {
    final ok = await _service.deleteGroup(ser: ser);
    if (ok) {
      _emit(AreaSuccessEvent('ลบหมวด "$name" สำเร็จ'));
      // ถ้าหมวดที่ลบคือที่เลือกอยู่ → กลับไป "ทั้งหมด"
      if (_selectedGroupSer == ser) {
        _selectedGroupSer = '0';
        _selectedGroupName = 'ทั้งหมด';
        _selectedZoneSer = null;
        _selectedZoneName = null;
        _zonesOfGroup = [];
      }
      await _loadGroups();
      notifyListeners();
      await _loadAreas();
    } else {
      _emit(const AreaErrorEvent('ลบหมวดล้มเหลว'));
    }
    return ok;
  }

  // ===============================================================
  // CRUD: Zone
  // ===============================================================
  Future<bool> addZone({
    required String groupSer,
    required String zn,
    int qty = 0,
  }) async {
    // เช็คชื่อโซนซ้ำในกลุ่มเดียวกัน
    final exists = await _service.zoneExists(groupSer: groupSer, zn: zn);
    if (exists) {
      _emit(AreaErrorEvent('มีโซนชื่อ "$zn" อยู่ในหมวดนี้แล้ว'));
      return false;
    }
    final ok = await _service.addZone(groupSer: groupSer, zn: zn, qty: qty);
    if (ok) {
      _emit(const AreaSuccessEvent('เพิ่มโซนสำเร็จ'));
      await _loadZonesOfGroup(groupSer);
      notifyListeners();
    } else {
      _emit(const AreaErrorEvent('เพิ่มโซนล้มเหลว'));
    }
    return ok;
  }

  Future<bool> updateZone({
    required String ser,
    required String zn,
    int? qty,
  }) async {
    final ok = await _service.updateZone(ser: ser, zn: zn, qty: qty);
    if (ok) {
      _emit(const AreaSuccessEvent('แก้ไขโซนสำเร็จ'));
      final gs = _selectedGroupSer;
      if (gs != null && gs != '0') {
        await _loadZonesOfGroup(gs);
      }
      notifyListeners();
    } else {
      _emit(const AreaErrorEvent('แก้ไขโซนล้มเหลว'));
    }
    return ok;
  }

  Future<bool> deleteZone({
    required String ser,
    required String name,
  }) async {
    final ok = await _service.deleteZone(ser: ser);
    if (ok) {
      _emit(AreaSuccessEvent('ลบโซน "$name" สำเร็จ'));
      if (_selectedZoneSer == ser) {
        _selectedZoneSer = null;
        _selectedZoneName = null;
      }
      final gs = _selectedGroupSer;
      if (gs != null && gs != '0') {
        await _loadZonesOfGroup(gs);
      }
      notifyListeners();
      await _loadAreas();
    } else {
      _emit(const AreaErrorEvent('ลบโซนล้มเหลว'));
    }
    return ok;
  }

  // ===============================================================
  // CRUD: Area (Lock)
  // ===============================================================
  Future<bool> addArea({
    required String ln,
    required String lncode,
    required String area,
    required String rent,
    required String zone,
  }) async {
    final ok = await _service.addLock(
      zoneSer: zone,
      lncode: lncode,
      ln: ln,
      area: area,
      rent: rent,
    );
    if (ok) {
      _emit(const AreaSuccessEvent('เพิ่ม Area สำเร็จ'));
      await _loadAreas();
    } else {
      _emit(const AreaErrorEvent('เพิ่ม Area ล้มเหลว'));
    }
    return ok;
  }

  Future<bool> updateArea({
    required String ser,
    required String rent,
    int? st,
  }) async {
    final ok = await _service.updateLock(ser: ser, rent: rent, st: st);
    if (ok) {
      _emit(const AreaSuccessEvent('แก้ไข Area สำเร็จ'));
      await _loadAreas();
    } else {
      _emit(const AreaErrorEvent('แก้ไข Area ล้มเหลว'));
    }
    return ok;
  }

  Future<bool> deleteArea(AreaAreaModel area) async {
    final ok = await _service.deleteLock(ser: area.ser);
    if (ok) {
      _emit(AreaSuccessEvent('ลบ "${area.lncode.isNotEmpty ? area.lncode : area.ln}" สำเร็จ'));
      await _loadAreas();
    } else {
      _emit(const AreaErrorEvent('ลบ Area ล้มเหลว'));
    }
    return ok;
  }

  // ===============================================================
  // Helpers
  // ===============================================================
  void _emit(AreaEvent e) {
    if (_eventController.isClosed) return;
    _eventController.add(e);
  }

  void _applyFilter() {
    final q = _searchQuery.trim().toLowerCase();
    Iterable<AreaAreaModel> list = _areas;
    if (q.isNotEmpty) {
      list = list.where((a) {
        return a.ln.toLowerCase().contains(q) ||
            a.lncode.toLowerCase().contains(q);
      });
    }
    final arr = list.toList();
    arr.sort((a, b) =>
        a.lncode.padLeft(8, '0').compareTo(b.lncode.padLeft(8, '0')));
    _filtered = arr;
  }

  /// Slice สำหรับ client-side pagination
  List<AreaAreaModel> get pagedFiltered {
    final start = (_currentPage - 1) * _pageSize;
    final end = start + _pageSize;
    if (start >= _filtered.length) return const [];
    return _filtered.sublist(
        start, end > _filtered.length ? _filtered.length : end);
  }

  // ===============================================================
  // Lifecycle
  // ===============================================================
  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}