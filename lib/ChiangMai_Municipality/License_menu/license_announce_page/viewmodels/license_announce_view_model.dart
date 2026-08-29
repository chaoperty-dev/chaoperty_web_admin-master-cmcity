// VM
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../unity/zone_selection_store.dart';
import '../models/license_announce_config.dart';
import '../models/license_announce_event.dart';
import '../models/license_announce_item.dart';
import '../services/license_announce_service.dart';

class LicenseAnnounceViewModel extends ChangeNotifier {
  LicenseAnnounceViewModel(
      {required LicenseAnnounceConfig config, LicenseAnnounceService? service})
      : _config = config,
        _service = service ?? LicenseAnnounceService() {
    // ✅ sync state จาก global store (license scope) — ไม่มี status filter
    _selectedSubZone = ZoneSelectionStore.instance.licenseSubZone == 'ทั้งหมด'
        ? null
        : ZoneSelectionStore.instance.licenseSubZone;
    ZoneSelectionStore.instance.addListener(_onZoneStoreChanged);
    _bootstrap();
  }
  final LicenseAnnounceConfig _config;
  final LicenseAnnounceService _service;
  final ZoneSelectionStore _zoneStore = ZoneSelectionStore.instance;

  void _onZoneStoreChanged() {
    final newSub = _zoneStore.licenseSubZone == 'ทั้งหมด'
        ? null
        : _zoneStore.licenseSubZone;
    final newZoneName = _zoneStore.licenseZone == 'ทั้งหมด'
        ? null
        : _zoneStore.licenseZone;
    final subChanged = _selectedSubZone != newSub;
    // resolve zone ser from store zn
    String? newZoneSer;
    if (newZoneName != null) {
      final match = _zones.firstWhere(
        (z) => z.zn == newZoneName,
        orElse: () => const LicenseAnnounceZone(ser: '', zn: ''),
      );
      newZoneSer = match.ser.isEmpty ? null : match.ser;
    }
    final zoneChanged = _selectedZoneSer != newZoneSer;
    if (!subChanged && !zoneChanged) return;

    _selectedSubZone = newSub;
    _selectedZoneSer = newZoneSer;

    notifyListeners();

    // reload zones ตาม subZone (filter ที่ fetch)
    _loadZones();
    // reapply filter (client-side) หลัง zoneSer เปลี่ยน
    _applyFilter();
  }
  final _eventController = StreamController<LicenseAnnounceEvent>.broadcast();
  Stream<LicenseAnnounceEvent> get events => _eventController.stream;
  List<LicenseAnnounceItem> _items = [];
  List<LicenseAnnounceItem> get items => _items;
  List<LicenseAnnounceItem> _filtered = [];
  List<LicenseAnnounceItem> get filtered => _filtered;
  List<LicenseAnnounceZone> _zones = [];
  List<LicenseAnnounceZone> get zones => _zones;

  // alias ให้ตรงกับชื่อที่ UI (license_request) ใช้
  List<LicenseAnnounceZone> get zoneModels => _zones;
  List<LicenseAnnounceSubZone> _subzoneModels = <LicenseAnnounceSubZone>[];
  List<LicenseAnnounceSubZone> get subzoneModels => _subzoneModels;

  String? _rser;
  String? _selectedZoneSer;
  String? get selectedZoneSer => _selectedZoneSer;
  String? get selectedZone => _selectedZoneSer;

  // หมวดโซนพื้นที่ (placeholder — ใช้ sub_zone จาก GC_zone.php)
  String? _selectedSubZone;
  String? get selectedSubZone => _selectedSubZone;
  String? get selectedZoneSub => _selectedSubZone;
  void onSubZoneChanged(String? value) {
    _zoneStore.setLicenseSubZone(value);
  }

  // ---------- Sort ----------
  /// รายการ key ที่ UI ใช้ (announce ไม่มี API sort → sort ฝั่ง client)
  static const List<String> sortOptions = <String>[
    'created_at',
    'submitted_at',
    'completed_at',
    'status',
  ];

  /// ป้ายภาษาไทย (key → label)
  static const Map<String, String> sortLabels = <String, String>{
    'created_at': 'วันที่สร้าง',
    'submitted_at': 'วันที่ส่งคำขอ',
    'completed_at': 'วันที่เสร็จ',
    'status': 'สถานะ',
  };

  /// key ฝั่ง client → accessor บน LicenseAnnounceItem
  /// created_at  → announceDate (published_at)
  /// submitted_at → sdate (effective_at)
  /// completed_at → edate (expired_at)
  /// status      → computedStatus
  static final Map<String, String Function(LicenseAnnounceItem)>
      _sortAccessors = <String, String Function(LicenseAnnounceItem)>{
    'created_at': (a) => a.announceDate,
    'submitted_at': (a) => a.sdate,
    'completed_at': (a) => a.edate,
    'status': (a) => a.computedStatus,
  };

  String _selectedSort = 'created_at';
  String _selectedSortDir = 'desc';
  String get selectedSort => _selectedSort;
  String get selectedSortDir => _selectedSortDir;

  /// ผู้ใช้เลือก key sort → sort ฝั่ง client
  void onSortChanged(String? value) {
    _selectedSort = (value == null || value.isEmpty) ? 'created_at' : value;
    notifyListeners();
    _applyFilter();
  }

  /// สลับ asc/desc
  void onSortDirChanged() {
    _selectedSortDir = _selectedSortDir == 'asc' ? 'desc' : 'asc';
    notifyListeners();
    _applyFilter();
  }

  // alias readOnly (placeholder — license_announce ไม่มีโหมด read-only)
  bool get readOnly => false;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  String get title => _config.title;

  Future<void> _bootstrap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _rser = prefs.getString('renTalSer') ?? '';
    } catch (e) {
      debugPrint('prefs: $e');
    }
    // 1) load sub-zones first (need ser lookup for zone filter)
    await _loadSubZones();
    // 2) load zones (filtered by selected sub-zone via _selectedSubZone field)
    await _loadZones();
    // 3) resolve selected zone's ser from filtered list
    final storeZone = ZoneSelectionStore.instance.licenseZone;
    if (storeZone != 'ทั้งหมด') {
      final match = _zones.firstWhere(
        (z) => z.zn == storeZone,
        orElse: () => const LicenseAnnounceZone(ser: '', zn: ''),
      );
      if (match.ser.isNotEmpty) {
        _selectedZoneSer = match.ser;
      }
    }
    // 4) load items
    await _loadItems();
  }

  Future<void> _loadZones() async {
    if ((_rser ?? '').isEmpty) return;
    _zones = await _service.fetchZones(_rser!, zoneSubSer: _selectedSubZone);
    notifyListeners();
  }

  Future<void> _loadSubZones() async {
    if ((_rser ?? '').isEmpty) return;
    _subzoneModels = await _service.fetchSubZones(_rser!);
    notifyListeners();
  }

  Future<void> _loadItems() async {
    _isLoading = true;
    notifyListeners();
    // API v1 ไม่รับ zone filter — filter ฝั่ง client
    _items = await _service.fetchActive();
    _applyFilter();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => _loadItems();

  void onZoneChanged(String? ser) {
    if (ser == null) {
      _zoneStore.setLicenseZone(null);
      return;
    }
    // find zn จาก ser เพื่อ sync ไปที่ global store
    final match = _zones.firstWhere(
      (z) => z.ser == ser,
      orElse: () => const LicenseAnnounceZone(ser: '', zn: ''),
    );
    if (match.zn.isEmpty) {
      _zoneStore.setLicenseZone(null);
    } else {
      _zoneStore.setLicenseZone(match.zn);
    }
  }

  void setSearch(String value) {
    _searchQuery = value;
    _applyFilter();
    notifyListeners();
  }

  void executeSearch() {
    _applyFilter();
    notifyListeners();
  }

  void onAdd() => _emit(const LicenseAnnounceOpenAddEvent());
  void onEdit(String uuid) => _emit(LicenseAnnounceOpenEditEvent(uuid));
  void onView(String uuid) => _emit(LicenseAnnounceOpenViewEvent(uuid));
  void onAddZone() => _emit(const LicenseAnnounceOpenAddZoneEvent());

  Future<bool> addAnnouncement({
    required String title,
    required String sdate,
    required String edate,
    required String announceDate,
    String? body,
    String? zone,
    String? cDateStart,
    String? cDateEnd,
    List<int>? zoneIds,
    List<Map<String, dynamic>>? zoneData,
  }) async {
    final rser = _rser ?? '';
    if (rser.isEmpty) {
      _emit(const LicenseAnnounceErrorEvent('ไม่พบ rser'));
      return false;
    }
    final ok = await _service.addAnnouncement(
      rser: rser,
      title: title,
      sdate: sdate,
      edate: edate,
      announceDate: announceDate,
      body: body,
      zone: zone,
      cDateStart: cDateStart,
      cDateEnd: cDateEnd,
      zoneIds: zoneIds,
      zoneData: zoneData,
    );
    if (ok) {
      _emit(const LicenseAnnounceSuccessEvent('เพิ่มประกาศสำเร็จ'));
      await _loadItems();
    } else {
      _emit(const LicenseAnnounceErrorEvent('เพิ่มประกาศล้มเหลว'));
    }
    return ok;
  }

  Future<bool> updateAnnouncement({
    required String ser,
    required String title,
    required String sdate,
    required String edate,
    required String announceDate,
    String? body,
    String? zone,
    String? cDateStart,
    String? cDateEnd,
    List<int>? zoneIds,
    List<Map<String, dynamic>>? zoneData,
  }) async {
    final rser = _rser ?? '';
    if (rser.isEmpty) {
      _emit(const LicenseAnnounceErrorEvent('ไม่พบ rser'));
      return false;
    }
    final ok = await _service.updateAnnouncement(
      rser: rser,
      ser: ser,
      title: title,
      sdate: sdate,
      edate: edate,
      announceDate: announceDate,
      body: body,
      zone: zone,
      cDateStart: cDateStart,
      cDateEnd: cDateEnd,
      zoneIds: zoneIds,
      zoneData: zoneData,
    );
    if (ok) {
      _emit(const LicenseAnnounceSuccessEvent('แก้ไขประกาศสำเร็จ'));
      await _loadItems();
    } else {
      _emit(const LicenseAnnounceErrorEvent('แก้ไขประกาศล้มเหลว'));
    }
    return ok;
  }

  Future<bool> deleteAnnouncement(String uuid) async {
    final rser = _rser ?? '';
    if (rser.isEmpty) {
      _emit(const LicenseAnnounceErrorEvent('ไม่พบ rser'));
      return false;
    }
    final ok = await _service.deleteAnnouncement(rser: rser, ser: uuid);
    if (ok) {
      _emit(const LicenseAnnounceSuccessEvent('ลบประกาศสำเร็จ'));
      await _loadItems();
    } else {
      _emit(const LicenseAnnounceErrorEvent('ลบประกาศล้มเหลว'));
    }
    return ok;
  }

  void _applyFilter() {
    final q = _searchQuery.trim().toLowerCase();
    final selectedZone = _selectedZoneSer;
    Iterable<LicenseAnnounceItem> list = _items;

    // Filter by zone (ฝั่ง client — API v1 ไม่รับ query)
    if (selectedZone != null &&
        selectedZone.isNotEmpty &&
        selectedZone != '0') {
      list = list.where((a) => a.zoneId.toString() == selectedZone);
    }

    // Filter by search query
    if (q.isNotEmpty) {
      list = list.where((a) =>
          a.title.toLowerCase().contains(q) ||
          a.content.toLowerCase().contains(q) ||
          (a.zonePn ?? '').toLowerCase().contains(q));
    }

    final arr = list.toList();
    _sortItems(arr);
    _filtered = arr;
  }

  void _sortItems(List<LicenseAnnounceItem> arr) {
    final accessor = _sortAccessors[_selectedSort];
    if (accessor == null) {
      arr.sort((a, b) => b.announceDate.compareTo(a.announceDate));
      return;
    }
    final desc = _selectedSortDir == 'desc';
    arr.sort((a, b) {
      final av = accessor(a);
      final bv = accessor(b);
      final cmp = av.compareTo(bv);
      return desc ? cmp : -cmp;
    });
  }

  void _emit(LicenseAnnounceEvent e) {
    if (!_eventController.isClosed) _eventController.add(e);
  }

  @override
  void dispose() {
    _zoneStore.removeListener(_onZoneStoreChanged);
    _eventController.close();
    super.dispose();
  }
}
