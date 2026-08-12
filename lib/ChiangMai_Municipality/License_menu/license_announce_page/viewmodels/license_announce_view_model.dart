// VM
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/license_announce_config.dart';
import '../models/license_announce_event.dart';
import '../models/license_announce_item.dart';
import '../services/license_announce_service.dart';

class LicenseAnnounceViewModel extends ChangeNotifier {
  LicenseAnnounceViewModel(
      {required LicenseAnnounceConfig config, LicenseAnnounceService? service})
      : _config = config,
        _service = service ?? LicenseAnnounceService() {
    _bootstrap();
  }
  final LicenseAnnounceConfig _config;
  final LicenseAnnounceService _service;
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
    _selectedSubZone = value;
    _selectedZoneSer = null; // reset zone เมื่อ subZone เปลี่ยน
    notifyListeners();
    // reload zones ตาม subZone ใหม่
    _loadZones();
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
    await Future.wait([_loadSubZones(), _loadZones(), _loadItems()]);
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
    _selectedZoneSer = ser;
    notifyListeners();
    _applyFilter();
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
    arr.sort((a, b) => b.announceDate.compareTo(a.announceDate));
    _filtered = arr;
  }

  void _emit(LicenseAnnounceEvent e) {
    if (!_eventController.isClosed) _eventController.add(e);
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
