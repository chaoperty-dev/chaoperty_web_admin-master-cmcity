// ============================================================================
// area_view_model.dart
// ============================================================================
// ViewModel — จัดการ state + business logic ของหน้า "จัดการ Area"
// - เรียก Service โหลด zones / areas / types / count
// - แจ้ง View ผ่าน Stream<AreaEvent>
// - CRUD ใช้ direct call (ไม่ผ่าน popup event — ใช้ full-page route)
// ============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../INSERT_Log/Insert_log.dart';
import '../models/area_area_model.dart';
import '../models/area_config.dart';
import '../models/area_event.dart';
import '../models/area_type_model.dart';
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

  // ---------- Data ----------
  List<AreaZoneModel> _zones = [];
  List<AreaZoneModel> get zones => _zones;

  List<AreaAreaModel> _areas = [];
  List<AreaAreaModel> get areas => _areas;

  List<AreaAreaModel> _filtered = [];
  List<AreaAreaModel> get filtered => _filtered;

  List<AreaTypeModel> _types = [];
  List<AreaTypeModel> get types => _types;

  int _areaCount = 0;
  int get areaCount => _areaCount;

  // ---------- Selection ----------
  String? _selectedZoneSer;
  String? _selectedZoneName;
  String? get selectedZoneSer => _selectedZoneSer;
  String? get selectedZoneName => _selectedZoneName;

  String? _selectedTypeId;
  String? get selectedTypeId => _selectedTypeId;

  // ---------- Rental / User ----------
  String? _rser;
  String? _serUser;
  String? get rser => _rser;
  String? get serUser => _serUser;

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

  // ---------- Pagination (client-side) ----------
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
    try {
      final prefs = await SharedPreferences.getInstance();
      _rser = prefs.getString('renTalSer') ?? '';
      _serUser = prefs.getString('ser') ?? '';
    } catch (e) {
      debugPrint('AreaViewModel._bootstrap prefs error: $e');
    }
    await Future.wait([
      _loadZones(),
      _loadTypes(),
    ]);
    // เลือก "ทั้งหมด" ถ้ามี
    final all = _zones.where((z) => z.zn == 'ทั้งหมด').firstOrNull;
    if (all != null) {
      _selectedZoneSer = all.ser;
      _selectedZoneName = all.zn;
    } else if (_zones.isNotEmpty) {
      _selectedZoneSer = _zones.first.ser;
      _selectedZoneName = _zones.first.zn;
    }
    notifyListeners();
    await _loadAreasAndCount();
  }

  /// Public refresh — ใช้รีเฟรชข้อมูลจากภายนอก (เช่น EmptyState)
  Future<void> refresh() => _loadAreasAndCount();

  // ===============================================================
  // Loaders
  // ===============================================================
  Future<void> _loadZones() async {
    if ((_rser ?? '').isEmpty) return;
    final list = await _service.fetchZones(_rser!);
    _zones = list;
  }

  Future<void> _loadTypes() async {
    if ((_rser ?? '').isEmpty) return;
    final list = await _service.fetchTypes(_rser!);
    _types = list;
  }

  Future<void> _loadAreasAndCount() async {
    if ((_rser ?? '').isEmpty) return;
    _isLoading = true;
    notifyListeners();
    final results = await Future.wait([
      _service.fetchAreas(rser: _rser!, zoneSer: _selectedZoneSer ?? '0'),
      _service.fetchAreaCount(_rser!),
    ]);
    _areas = results[0] as List<AreaAreaModel>;
    _areaCount = results[1] as int;
    _applyFilter();
    _isLoading = false;
    notifyListeners();
  }

  // ===============================================================
  // Zone selection
  // ===============================================================
  Future<void> onZoneChanged(String? ser, String? name) async {
    _selectedZoneSer = ser;
    _selectedZoneName = name;
    _currentPage = 1;
    notifyListeners();
    await _loadAreasAndCount();
  }

  // ===============================================================
  // Type selection (filter area ตาม type)
  // ===============================================================
  void onTypeChanged(String? typeId) {
    _selectedTypeId = typeId;
    _currentPage = 1;
    _applyFilter();
    notifyListeners();
  }

  // ===============================================================
  // Search
  // ===============================================================
  void setSearch(String value) {
    _searchQuery = value;
    _currentPage = 1;
    notifyListeners();
  }

  void executeSearch() {
    _currentPage = 1;
    _applyFilter();
    notifyListeners();
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
  // CRUD: Zone
  // ===============================================================
  Future<bool> addZone({required String zn}) async {
    if ((_rser ?? '').isEmpty) {
      _emit(const AreaErrorEvent('ไม่พบ rser'));
      return false;
    }
    // เช็คชื่อโซนซ้ำ (logic จาก Advance_AreaSet.dart)
    final exists = await _service.zoneExists(rser: _rser!, zn: zn);
    if (exists) {
      _emit(AreaErrorEvent('มีโซนชื่อ "$zn" อยู่แล้ว'));
      return false;
    }
    final ok = await _service.addZone(rser: _rser!, zn: zn);
    if (ok) {
      _emit(const AreaSuccessEvent('เพิ่มโซนสำเร็จ'));
      // Insert_log (pattern จาก Advance_AreaSet.dart)
      Insert_log.Insert_logs('ตั้งค่า', 'พื้นที่>>เพิ่มโซนพื้นที่($zn)');
      await _loadZones();
      notifyListeners();
    } else {
      _emit(const AreaErrorEvent('เพิ่มโซนล้มเหลว'));
    }
    return ok;
  }

  Future<bool> deleteZone({
    required String zoneSer,
    required String zoneName,
  }) async {
    if ((_rser ?? '').isEmpty) {
      _emit(const AreaErrorEvent('ไม่พบ rser'));
      return false;
    }
    // เช็คว่ามี area ในโซนนี้หรือไม่
    final inUse = _areas.any((a) => a.zone == zoneSer);
    if (inUse) {
      _emit(AreaErrorEvent(
          'ไม่สามารถลบโซน "$zoneName" ได้ เนื่องจากมีข้อมูล Area อยู่'));
      return false;
    }
    final ok = await _service.deleteZone(rser: _rser!, zoneSer: zoneSer);
    if (ok) {
      _emit(AreaSuccessEvent('ลบโซน "$zoneName" สำเร็จ'));
      Insert_log.Insert_logs('ตั้งค่า', 'พื้นที่>>ยืนยันลบโซน $zoneName');
      await _loadZones();
      // ถ้าโซนที่ถูกลบคือโซนที่เลือกอยู่ → กลับไป "ทั้งหมด"
      if (_selectedZoneSer == zoneSer) {
        final all = _zones.where((z) => z.zn == 'ทั้งหมด').firstOrNull;
        if (all != null) {
          _selectedZoneSer = all.ser;
          _selectedZoneName = all.zn;
        }
      }
      notifyListeners();
      await _loadAreasAndCount();
    } else {
      _emit(const AreaErrorEvent('ลบโซนล้มเหลว'));
    }
    return ok;
  }

  // ===============================================================
  // CRUD: Area
  // ===============================================================
  Future<bool> addArea({
    required String ln,
    required String sn,
    required String sname,
    required String sw,
    required String lncode,
    required String area,
    required String rent,
    required String rentMaket,
    required String zone,
    required String typeId,
  }) async {
    if ((_rser ?? '').isEmpty) {
      _emit(const AreaErrorEvent('ไม่พบ rser'));
      return false;
    }
    final ok = await _service.addArea(
      rser: _rser!,
      zone: zone,
      ln: ln,
      sname: sname,
      area: area,
      rent: rent,
      rentMaket: rentMaket,
      sw: sw,
      typeId: typeId,
    );
    if (ok) {
      _emit(const AreaSuccessEvent('เพิ่ม Area สำเร็จ'));
      Insert_log.Insert_logs(
          'ตั้งค่า', 'พื้นที่>>เพิ่มพื้นที่($lncode : $sname)');
      await _loadAreasAndCount();
    } else {
      _emit(const AreaErrorEvent('เพิ่ม Area ล้มเหลว'));
    }
    return ok;
  }

  /// แก้ไข Area — แก้ได้แค่ รหัสพื้นที่, ชื่อพื้นที่, ขนาดพื้นที่, ค่าบริการหลัก
  Future<bool> updateArea({
    required String ser,
    required String ln,
    required String sname,
    required String area,
    required String rent,
    required String zone,
    required String typeId,
    String? lncode,
    String? sw,
    String? rentMaket,
  }) async {
    if ((_rser ?? '').isEmpty) {
      _emit(const AreaErrorEvent('ไม่พบ rser'));
      return false;
    }
    final ok = await _service.updateArea(
      rser: _rser!,
      ser: ser,
      zone: zone,
      ln: ln,
      sname: sname,
      area: area,
      rent: rent,
      rentMaket: rentMaket ?? '0',
      sw: sw ?? '0',
      typeId: typeId,
    );
    if (ok) {
      _emit(const AreaSuccessEvent('แก้ไข Area สำเร็จ'));
      Insert_log.Insert_logs('ตั้งค่า', 'พื้นที่>>แก้ไข($lncode : $sname)');
      await _loadAreasAndCount();
    } else {
      _emit(const AreaErrorEvent('แก้ไข Area ล้มเหลว'));
    }
    return ok;
  }

  Future<bool> deleteArea(AreaAreaModel area) async {
    if ((_rser ?? '').isEmpty) {
      _emit(const AreaErrorEvent('ไม่พบ rser'));
      return false;
    }
    final ok = await _service.deleteArea(rser: _rser!, ser: area.ser);
    if (ok) {
      _emit(const AreaSuccessEvent('ลบ Area สำเร็จ'));
      Insert_log.Insert_logs(
          'ตั้งค่า', 'พื้นที่>>ลบ(${area.lncode} : ${area.ln})');
      await _loadAreasAndCount();
    } else {
      _emit(const AreaErrorEvent('ลบ Area ล้มเหลว'));
    }
    return ok;
  }

  // ===============================================================
  // UI actions — ใช้ navigate ไป full-page route (ไม่ popup)
  // ===============================================================
  void onAddZonePage() {}
  void onAddAreaPage() {}
  void onEditAreaPage(AreaAreaModel area) {}

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
    if (_selectedTypeId != null && _selectedTypeId!.isNotEmpty) {
      list = list.where((a) => a.typeId == _selectedTypeId);
    }
    if (q.isNotEmpty) {
      list = list.where((a) {
        return a.ln.toLowerCase().contains(q) ||
            a.sname.toLowerCase().contains(q) ||
            a.sn.toLowerCase().contains(q) ||
            a.lncode.toLowerCase().contains(q) ||
            a.sw.toLowerCase().contains(q);
      });
    }
    final arr = list.toList();
    // เรียงตาม sw asc
    arr.sort((a, b) => a.sw.padLeft(5, '0').compareTo(b.sw.padLeft(5, '0')));
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
