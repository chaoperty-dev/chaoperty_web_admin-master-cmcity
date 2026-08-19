// ============================================================================
// license_verify_view_model.dart
// ============================================================================
// ViewModel — จัดการ state + business logic ของหน้า "คำขอต่อสัญญา"
// - เรียก Service โหลดรายการ tab แรก
// - แจ้ง View ผ่าน Stream<LicenseVerifyEvent>
// - ไม่ผูกกับ Flutter UI
// ============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../Model/GetZone_Model.dart';
import '../../../../Model/GetSubZone_Model.dart';
import '../models/verify_attachment_item.dart';
import '../models/license_verify_config.dart';
import '../models/license_verify_event.dart';
import '../services/license_verify_service.dart';

class LicenseVerifyViewModel extends ChangeNotifier {
  LicenseVerifyViewModel({
    required LicenseVerifyConfig config,
    LicenseVerifyService? service,
  })  : _config = config,
        _service = service ?? LicenseVerifyService() {
    _loadInitial();
  }

  final LicenseVerifyConfig _config;
  final LicenseVerifyService _service;

  // ---------- Event channel ----------
  final StreamController<LicenseVerifyEvent> _eventController =
      StreamController<LicenseVerifyEvent>.broadcast();
  Stream<LicenseVerifyEvent> get events => _eventController.stream;

  // ---------- Data ----------
  List<VerifyAttachmentItem> _requests = [];
  List<VerifyAttachmentItem> get requests => _requests;

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

  // ---------- Status filter ----------
  /// รายการ status ทั้งหมดที่ filter ได้
  /// (null = "ทั้งหมด" — ไม่ส่ง key ให้ backend)
  static const List<String> statusOptions = <String>[
    'draft',
    'documents_submitted',
    'waiting_payment_info',
    'payment_submitted',
    'request_submitted',
    'needs_update',
    'under_review',
    'in_progress',
    'request_completed',
    'completed',
    'rejected',
  ];

  /// ป้ายภาษาไทยสำหรับ status (ใช้โชว์ใน dropdown ของ filter)
  static const Map<String, String> statusLabels = <String, String>{
    'draft': 'ฉบับร่าง',
    'documents_submitted': 'ส่งเอกสารแล้ว',
    'waiting_payment_info': 'รอข้อมูลชำระเงิน',
    'payment_submitted': 'ชำระเงินแล้ว',
    'request_submitted': 'ส่งคำขอแล้ว',
    'needs_update': 'ต้องแก้ไข',
    'under_review': 'กำลังพิจารณา',
    'in_progress': 'กำลังดำเนินการ',
    'request_completed': 'คำขอเสร็จสิ้น',
    'completed': 'เสร็จสิ้น',
    'rejected': 'ถูกปฏิเสธ',
  };

  /// ค่าปัจจุบัน (string = enum, null = ทั้งหมด)
  String? _selectedStatus;
  String? get selectedStatus => _selectedStatus;

  /// ผู้ใช้เลือก "สถานะ" — ถ้าเป็น "ทั้งหมด" หรือ null → ไม่ส่ง key
  Future<void> onStatusChanged(String? value) async {
    _selectedStatus = (value == null || value.isEmpty || value == 'ทั้งหมด')
        ? null
        : value;
    notifyListeners();
    await refresh();
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
  // Service calls — v2 (tasks/attachments)
  // ===============================================================
  Future<void> refresh() async {
    _setLoading(true);
    try {
      final zserRaw = _selectedZoneSer;
      final zserFilter = (zserRaw == null ||
              zserRaw.isEmpty ||
              zserRaw == '0' ||
              zserRaw == 'ทั้งหมด')
          ? null
          : zserRaw;
      final res = await _service.listTasksAttachments(
        q: _searchQuery.isNotEmpty ? _searchQuery : null,
        includeDone: false,
        perPage: 50,
        zser: zserFilter,
        statuses: _statusesFilter,
        sortBy: _selectedSort,
        sortDir: _selectedSortDir,
      );
      _requests = res.items;
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
      final zserRaw = _selectedZoneSer;
      final zserFilter = (zserRaw == null ||
              zserRaw.isEmpty ||
              zserRaw == '0' ||
              zserRaw == 'ทั้งหมด')
          ? null
          : zserRaw;
      final res = await _service.listTasksAttachments(
        urlCustom: url,
        q: _searchQuery.isNotEmpty ? _searchQuery : null,
        includeDone: false,
        perPage: 50,
        zser: zserFilter,
        statuses: _statusesFilter,
        sortBy: _selectedSort,
        sortDir: _selectedSortDir,
      );
      _requests = res.items;
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
  void onViewRequest(VerifyAttachmentItem task) {
    _eventController.add(
      LicenseVerifyNavigateEvent('ตรวจสอบหลักฐาน', routeData: task.uuid),
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
    _eventController.add(LicenseVerifyErrorEvent(msg));
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
