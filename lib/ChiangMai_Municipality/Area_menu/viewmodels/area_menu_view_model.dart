// ============================================================================
// area_menu_view_model.dart
// ============================================================================
// ViewModel — จัดการ state + business logic ของหน้า "คำขอต่อสัญญา"
// ✅ SELF-CONTAINED — ใช้ Map<String, dynamic> เป็น data type
// ============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';

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
    _loadInitial();
  }

  final AreaMenuService _service;

  // ---------- Event channel ----------
  final StreamController<evt.AreaMenuEvent> _eventController =
      StreamController<evt.AreaMenuEvent>.broadcast();
  Stream<evt.AreaMenuEvent> get events => _eventController.stream;

  // ---------- Data ----------
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> get requests {
    if (_selectedRequestStatus == 'ทั้งหมด') return _requests;
    final key = _requestStatusKeyMap[_selectedRequestStatus];
    return _requests.where((r) {
      final st = r['st']?.toString() ?? '';
      final status = r['status']?.toString() ?? '';
      // ✅ match ทั้ง TH label (เช่น "ร่างคำขอ") และ EN key (เช่น "draft")
      return st == _selectedRequestStatus ||
          status == _selectedRequestStatus ||
          (key != null && (st == key || status == key));
    }).toList();
  }

  // ---------- Status filter (เหมือน ChaoArea: typecid) ----------
  static const List<String> _statusLabels = [
    'ทั้งหมด',
    'เช่าอยู่',
    'ใกล้หมดสัญญา',
    'หมดสัญญา',
    'เสนอราคา',
    'เสนอราคา(มัดจำ)',
    'ว่าง',
  ];

  String _selectedStatus = 'ทั้งหมด';
  String get selectedStatus => _selectedStatus;
  List<String> get statusOptions => _statusLabels;

  /// แปลงสถานะที่เลือกเป็น typecid สำหรับยิง API (index + 1)
  String _statusToTypecid(String status) {
    final idx = _statusLabels.indexOf(status);
    return idx <= 0 ? '1' : (idx + 1).toString();
  }

  // ---------- Request status filter (in-memory) ----------
  // TH label → EN key ที่ backend ส่งมาใน properties API request_status
  static const Map<String, String> _requestStatusKeyMap = {
    'ร่างคำขอ': 'draft',
    'ส่งคำขอแล้ว': 'submitted',
    'กำลังดำเนินการ': 'in_progress',
    'เสร็จสิ้น': 'completed',
    'ถูกปฏิเสธ': 'rejected',
    'ต้องแก้ไข': 'needs_update',
    'ส่งเอกสารแล้ว': 'documents_submitted',
    'รอข้อมูลชำระเงิน': 'waiting_payment_info',
    'ชำระเงินแล้ว': 'payment_submitted',
    'คำขอเสร็จสิ้น': 'request_completed',
  };

  static const List<String> _requestStatusLabels = [
    'ทั้งหมด',
    'ร่างคำขอ',
    'ส่งคำขอแล้ว',
    'กำลังดำเนินการ',
    'เสร็จสิ้น',
    'ถูกปฏิเสธ',
    'ต้องแก้ไข',
    'ส่งเอกสารแล้ว',
    'รอข้อมูลชำระเงิน',
    'ชำระเงินแล้ว',
    'คำขอเสร็จสิ้น',
  ];

  String _selectedRequestStatus = 'ทั้งหมด';
  String get selectedRequestStatus => _selectedRequestStatus;
  List<String> get requestStatusOptions => _requestStatusLabels;

  // ---------- Config ----------
  final String _title;
  final String? _routeData;
  final bool _readOnly;
  String get title => _title;
  String? get routeData => _routeData;
  bool get readOnly => _readOnly;

  // ---------- Pagination ----------
  int _currentPage = 0;
  int _lastPage = 0;
  int _total = 0;
  String? _linksNext;
  String? _linksPrev;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get total => requests.length;
  String? get linksNext => _linksNext;
  String? get linksPrev => _linksPrev;

  // ---------- UI state ----------
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // ---------- Zones ----------
  List<Map<String, dynamic>> _subzoneModels = [];
  List<Map<String, dynamic>> _zoneModels = [];
  String? _selectedZoneSub = 'ทั้งหมด'; // ดีฟอล: ทั้งหมด
  String? _selectedZone = 'ทั้งหมด'; // ดีฟอล: ทั้งหมด
  String? _selectedZoneSer = '0'; // ser = '0' (ทั้งหมด)
  String? get selectedZoneSub => _selectedZoneSub;
  String? get selectedZone => _selectedZone;
  String? get selectedZoneSer => _selectedZoneSer;
  List<Map<String, dynamic>> get zoneModels => _zoneModels;
  List<Map<String, dynamic>> get subzoneModels => _subzoneModels;
  String? _selectedZoneSubSer; // ser ของ sub-zone ที่เลือก
  String? get selectedZoneSubSer => _selectedZoneSubSer;

  // ===============================================================
  // Init
  // ===============================================================
  Future<void> _loadInitial() async {
    await Future.wait([
      loadFromProperties(),
      loadSubZones(),
    ]);
  }

  // ===============================================================
  // โหลด sub-zones (หมวดโซน)
  // ===============================================================
  Future<void> loadSubZones() async {
    try {
      _subzoneModels = await _service.fetchSubZones();
      notifyListeners();
    } catch (e) {
      print('loadSubZones error: $e');
    }
  }

  // ===============================================================
  // โหลด zones (โซนพื้นที่) — filter ตาม sub-zone ถ้ามี
  // ===============================================================
  Future<void> loadZones({String? zoneSubSer}) async {
    try {
      _zoneModels = await _service.fetchZones(zoneSubSer: zoneSubSer);
      notifyListeners();
    } catch (e) {
      print('loadZones error: $e');
    }
  }

  // ===============================================================
  // โหลดข้อมูลผ่าน service (ใช้ API เดียวกับ ChaoArea)
  // ===============================================================
  Future<void> loadFromProperties({String? zoneSer}) async {
    _setLoading(true);
    try {
      if (zoneSer != null) _selectedZoneSer = zoneSer;
      final list = await _service.fetchRequestsFromProperties(
        zoneSer: _selectedZoneSer,
        typecid: _statusToTypecid(_selectedStatus),
      );
      _requests = list;
      _currentPage = 1;
      _lastPage = 1;
      _total = list.length;
      _linksNext = null;
      _linksPrev = null;
    } catch (e) {
      _emitError('โหลดข้อมูลไม่สำเร็จ: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() => loadFromProperties();

  /// Pagination stub — ไม่รองรับ pagination (properties API ไม่มี)
  Future<void> loadPage(String? url) async {
    if (url == null || url.isEmpty) return;
    await loadFromProperties();
  }

  /// ผู้ใช้เลือก sub-zone
  Future<void> onSubZoneChanged(String? value) async {
    _selectedZoneSub = value;
    _selectedZone = 'ทั้งหมด';
    _selectedZoneSer = '0';

    // หา ser ของ sub-zone จาก list
    String? subSer;
    if (value != null) {
      final found = _subzoneModels.firstWhere(
        (s) => s['zn']?.toString() == value,
        orElse: () => <String, dynamic>{},
      );
      subSer = found['ser']?.toString();
    }
    _selectedZoneSubSer = subSer;

    notifyListeners();

    // โหลด zones ใหม่ตาม sub-zone ที่เลือก
    await loadZones(zoneSubSer: subSer);

    // โหลด properties ใหม่
    await loadFromProperties(zoneSer: '0');
  }

  /// ผู้ใช้เลือก zone
  Future<void> onZoneChanged(String? value) async {
    _selectedZone = value;

    // หา ser ของ zone จาก list (เพราะ API ใช้ ser ไม่ใช่ zn)
    String? zoneSer;
    if (value == null || value == 'ทั้งหมด' || value == '0') {
      zoneSer = '0';
    } else {
      final found = _zoneModels.firstWhere(
        (z) => z['zn']?.toString() == value,
        orElse: () => <String, dynamic>{},
      );
      zoneSer = found['ser']?.toString() ?? '0';
    }
    _selectedZoneSer = zoneSer;

    notifyListeners();
    await loadFromProperties(zoneSer: zoneSer);
  }

  void setSearch(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  Future<void> executeSearch() async {
    await loadFromProperties();
  }

  /// ผู้ใช้เลือกสถานะ → ยิง API ใหม่ด้วย typecid ตาม ChaoArea
  Future<void> onStatusChanged(String? value) async {
    _selectedStatus = value ?? 'ทั้งหมด';
    notifyListeners();
    await loadFromProperties();
  }

  /// ผู้ใช้เลือกสถานะคำขอ (request_status) → filter in-memory ไม่ยิง API
  void onRequestStatusChanged(String? value) {
    _selectedRequestStatus = value ?? 'ทั้งหมด';
    notifyListeners();
  }

  /// ผู้ใช้กด "เรียกดู" → ส่ง event ให้ View เปิด full-page route
  void onViewRequest(Map<String, dynamic> model) {
    final uuid =
        model['request_uuid']?.toString() ?? model['uuid']?.toString() ?? '';
    _eventController.add(
      evt.AreaMenuNavigateEvent(_title, routeData: uuid),
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

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
