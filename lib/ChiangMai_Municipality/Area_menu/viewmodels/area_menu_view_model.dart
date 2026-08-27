// ============================================================================
// area_menu_view_model.dart
// ============================================================================
// ViewModel — จัดการ state + business logic ของหน้า "คำขอต่อสัญญา"
// ✅ SELF-CONTAINED — ใช้ Map<String, dynamic> เป็น data type
//
// Data Source: GET /api/v2/admin/reports/areas/overview
// - โหลด API เดียวครั้งเดียว
// - filter ทุกอย่าง in-memory
// - Status & zones derive จาก items โดยตรง
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
  List<Map<String, dynamic>> _allItems = [];

  /// Filtered list (sub-zone + zone + status + request_status + search)
  List<Map<String, dynamic>> get requests {
    Iterable<Map<String, dynamic>> out = _allItems;

    if (_selectedZoneSub != null &&
        _selectedZoneSub != 'ทั้งหมด' &&
        (_selectedZoneSub ?? '').isNotEmpty) {
      out = out
          .where((r) => (r['subzone']?.toString() ?? '') == _selectedZoneSub);
    }

    if (_selectedZone != 'ทั้งหมด') {
      out = out.where((r) => (r['zone']?.toString() ?? '') == _selectedZone);
    }

    if (_selectedStatus != 'ทั้งหมด') {
      out = out.where((r) => _computeStatusLabel(r) == _selectedStatus);
    }

    if (_selectedRequestStatus != 'ทั้งหมด') {
      final key = _requestStatusKeyMap[_selectedRequestStatus];
      out = out.where((r) {
        final status = r['status']?.toString() ?? '';
        return status == _selectedRequestStatus ||
            (key != null && status == key);
      });
    }

    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      out = out.where((r) {
        final lock = r['lock']?.toString().toLowerCase() ?? '';
        final zone = r['zone']?.toString().toLowerCase() ?? '';
        final subzone = r['subzone']?.toString().toLowerCase() ?? '';
        final requester = r['requester']?.toString().toLowerCase() ?? '';
        final custNo = r['customer_no']?.toString().toLowerCase() ?? '';
        final custTel = r['customer_tel']?.toString().toLowerCase() ?? '';
        return lock.contains(q) ||
            zone.contains(q) ||
            subzone.contains(q) ||
            requester.contains(q) ||
            custNo.contains(q) ||
            custTel.contains(q);
      });
    }

    return out.toList();
  }

  // ---------- Stats (จาก API) ----------
  int? get totalArea => _totalArea;
  int? get totalLeased => _totalLeased;
  int? get totalVacant => _totalVacant;
  String? get reportDate => _reportDate;

  int? _totalArea;
  int? _totalLeased;
  int? _totalVacant;
  String? _reportDate;

  // ---------- Status filter (เก็บไว้เผื่อใช้ แต่ UI ลบ dropdown นี้ออกแล้ว) ----------
  static const List<String> _statusLabels = [
    'ทั้งหมด',
    'เช่าอยู่',
    'หมดสัญญา',
    'ว่าง',
  ];

  String _selectedStatus = 'ทั้งหมด';
  String get selectedStatus => _selectedStatus;
  List<String> get statusOptions => _statusLabels;

  // ---------- Request status filter (in-memory) ----------
  // TH label → EN key ที่ API ส่งมาใน status
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

  // ✅ เรียงตามลำดับที่แสดงใน UI (dropdown) — ตามรูปที่คุณส่งมา
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

  /// ✅ สำหรับ UI dropdown item — TH label + EN key
  /// คืน List<Map<String, String>> ที่มี key 'th' และ 'en'
  List<Map<String, String>> get requestStatusItems {
    return _requestStatusLabels.map((th) {
      return {
        'th': th,
        'en': th == 'ทั้งหมด' ? '' : (_requestStatusKeyMap[th] ?? ''),
      };
    }).toList(growable: false);
  }

  // ---------- Sub-zone & Zone (derived from items) ----------
  String? _selectedZoneSub = 'ทั้งหมด';
  String get selectedZoneSub => _selectedZoneSub ?? 'ทั้งหมด';

  String _selectedZone = 'ทั้งหมด';
  String get selectedZone => _selectedZone;

  /// Cache สำหรับ map ชื่อ → ser
  /// ser = index+1 (1-based) — เพราะ API item ไม่มี id โดยตรง
  /// ใช้ rowNumber (sorted) เพื่อให้ UI กับ API ตรงกันในแต่ละ session
  static const int _allIndex = 0; // แทน 'ทั้งหมด'

  /// Extract unique subzones (มี 'ทั้งหมด' นำหน้า)
  /// Filter in-memory ตรงๆ ด้วยชื่อ ไม่ต้อง map เป็น ser
  List<Map<String, dynamic>> get subzoneModels {
    final set = <String>{};
    for (final r in _allItems) {
      final s = r['subzone']?.toString();
      if (s != null && s.isNotEmpty) set.add(s);
    }
    final sorted = set.toList()..sort();
    return [
      {'zn': 'ทั้งหมด'},
      ...sorted.map((s) => {'zn': s}),
    ];
  }

  /// Extract unique zones (กรองตาม sub-zone ที่เลือก)
  List<Map<String, dynamic>> get zoneModels {
    final set = <String>{};
    final selectedSub =
        (_selectedZoneSub == 'ทั้งหมด' || _selectedZoneSub == null)
            ? null
            : _selectedZoneSub;
    for (final r in _allItems) {
      final sub = r['subzone']?.toString();
      final zn = r['zone']?.toString();
      if (selectedSub != null && sub != selectedSub) continue;
      if (zn != null && zn.isNotEmpty) set.add(zn);
    }
    final sorted = set.toList()..sort();
    return [
      {'zn': 'ทั้งหมด'},
      ...sorted.map((z) => {'zn': z}),
    ];
  }

  // ---------- Search ----------
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // ---------- Reference date (optional, ส่งให้ API) ----------
  String? _selectedDate;
  String? get selectedDate => _selectedDate;

  // ---------- Misc ----------
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool get readOnly => _readOnly;
  final bool _readOnly;

  String get title => _title;
  final String _title;
  final String? _routeData;

  // ✅ API ใหม่ไม่มี pagination — เก็บ stub สำหรับ backward compat
  int get currentPage => 1;
  int get lastPage => 1;
  int get total => _allItems.length;
  String? get linksNext => null;
  String? get linksPrev => null;

  // ===============================================================
  // Loaders
  // ===============================================================
  void _loadInitial() {
    loadOverview();
  }

  /// โหลด overview (API เดียวจบ — filter ทำ in-memory)
  Future<void> loadOverview({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;
    _setLoading(true);
    try {
      final result = await _service.fetchAreasOverview(
        forceRefresh: forceRefresh,
        date: _selectedDate,
      );
      _allItems = result.items.map((it) => it.toJson()).toList(growable: false);
      _totalArea = result.totalArea;
      _totalLeased = result.totalLeased;
      _totalVacant = result.totalVacant;
      _reportDate = result.date;
      _validateSelectedZone();
    } catch (e) {
      _emitError('โหลดข้อมูลไม่สำเร็จ: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() => loadOverview(forceRefresh: true);

  /// Stub สำหรับ Pagination widget
  Future<void> loadPage(String? url) async {
    // API ใหม่ไม่รองรับ pagination
  }

  // ===============================================================
  // Filter handlers — เปลี่ยน sub-zone/zone filter in-memory เท่านั้น
  // (API จะถูกเรียกครั้งเดียวตอน loadOverview() ครั้งแรก)
  // ===============================================================
  void onSubZoneChanged(String? value) {
    _selectedZoneSub = value ?? 'ทั้งหมด';
    // เปลี่ยน sub-zone ใหม่ → reset zone เป็น 'ทั้งหมด'
    _selectedZone = 'ทั้งหมด';
    notifyListeners();
  }

  void onZoneChanged(String? value) {
    _selectedZone = value ?? 'ทั้งหมด';
    notifyListeners();
  }

  void onStatusChanged(String? value) {
    _selectedStatus = value ?? 'ทั้งหมด';
    notifyListeners();
  }

  void onRequestStatusChanged(String? value) {
    _selectedRequestStatus = value ?? 'ทั้งหมด';
    notifyListeners();
  }

  void setSearch(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  Future<void> executeSearch() async {
    notifyListeners();
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

  /// Validate selected zone ต้องมีอยู่ใน list (กรณี refresh แล้ว zone หายไป)
  void _validateSelectedZone() {
    final zones =
        zoneModels.map((z) => z['zn']?.toString()).whereType<String>().toSet();
    if (!zones.contains(_selectedZone)) {
      _selectedZone = 'ทั้งหมด';
    }
    final subs = subzoneModels
        .map((z) => z['zn']?.toString())
        .whereType<String>()
        .toSet();
    final cur = _selectedZoneSub ?? 'ทั้งหมด';
    if (!subs.contains(cur)) {
      _selectedZoneSub = 'ทั้งหมด';
    }
  }

  /// คำนวณ status label (TH) จาก item
  /// - ldate < วันนี้ && requester != null → "หมดสัญญา"
  /// - requester != null → "เช่าอยู่"
  /// - requester == null → "ว่าง"
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

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
