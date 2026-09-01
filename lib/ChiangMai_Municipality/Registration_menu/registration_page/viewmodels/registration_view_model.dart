// ============================================================================
// registration_view_model.dart
// ============================================================================
// ViewModel — จัดการ state + business logic ของหน้า "ทะเบียนผู้เช่า"
// - ตารางเมนูใช้รายงานลูกค้า (CustomerReportItem) จาก /v1/admin/c-customers
// - ✅ server-side pagination — fetch 1 page ต่อครั้ง (perPage=50)
// - การแก้ไขทะเบียนยังคงใช้ CustomerModel ผ่าน detail viewmodel
// ============================================================================

import 'dart:async';

import 'package:chaoperty/ChiangMai_Municipality/Report_menu/customers/services/customers_report_service.dart'
    show CustomerReportItem;
import 'package:flutter/foundation.dart';

import '../models/registration_config.dart';
import '../models/registration_event.dart';
import '../services/registration_service.dart';

class RegistrationViewModel extends ChangeNotifier {
  RegistrationViewModel({
    required RegistrationConfig config,
    RegistrationService? service,
  })  : _config = config,
        _service = service ?? RegistrationService() {
    _loadInitial();
  }

  final RegistrationConfig _config;
  final RegistrationService _service;

  // ---------- Event channel ----------
  final StreamController<RegistrationEvent> _eventController =
      StreamController<RegistrationEvent>.broadcast();
  Stream<RegistrationEvent> get events => _eventController.stream;

  // ---------- Data (current page) ----------
  /// รายการที่ fetch มาแล้ว (current page)
  List<CustomerReportItem> _pagedItems = [];
  List<CustomerReportItem> get pagedItems => _pagedItems;
  /// alias (เดิม) — table widget อาจใช้ customers/filtered/paged อยู่
  List<CustomerReportItem> get customers => _pagedItems;
  List<CustomerReportItem> get filtered => _pagedItems;

  // ---------- Pagination (server-driven) ----------
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get total => _total;

  // ---------- UI state ----------
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _searchField = 'cname';
  String get searchField => _searchField;

  // ---------- Status filter ----------
  String _selectedStatus = 'ทั้งหมด';
  String get selectedStatus => _selectedStatus;
  static const List<String> statusOptions = [
    'ทั้งหมด',
    'ปัจจุบัน',
    'หมดสัญญา',
    'ใกล้หมดสัญญา',
  ];

  // ---------- Pagination constants ----------
  static const int perPage = 50;

  /// alias — ให้ widget เก่าที่อ้าง .paged ใช้ได้
  List<CustomerReportItem> get paged => _pagedItems;

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
      _searchField = 'custno';
    }
    await refresh();
  }

  // ===============================================================
  // Service calls
  // ===============================================================
  /// โหลด "หน้าปัจจุบัน" ใหม่ — เรียกหลัง create/update/delete
  Future<void> refresh() async {
    _setLoading(true);
    try {
      final r = await _service.fetchReportCustomersPage(page: _currentPage);
      _pagedItems = r.items;
      _currentPage = r.currentPage ?? _currentPage;
      _lastPage = r.lastPage ?? 1;
      _total = r.total;
    } catch (e) {
      _emitError('โหลดข้อมูลไม่สำเร็จ: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// โหลด "หน้า N" ใหม่จาก server
  Future<void> loadPage(int page) async {
    if (page < 1 || page > _lastPage) return;
    _currentPage = page;
    await refresh();
  }

  void nextPage() {
    if (_currentPage < _lastPage) loadPage(_currentPage + 1);
  }

  void prevPage() {
    if (_currentPage > 1) loadPage(_currentPage - 1);
  }

  void _applyFilter() {
    // ✅ server-driven pagination — filter ทำบนหน้าปัจจุบัน
    // (ถ้าต้อง filter ทั้งหมด ต้องเรียก search API แยก — ตอนนี้ยังเป็น stub)
    _pagedItems = List<CustomerReportItem>.from(_pagedItems);
    _total = _pagedItems.length;
  }

  void _applySearch() {
    // เก็บไว้เป็น stub — search แบบ server ต้องเพิ่ม endpoint แยก
  }

  void _applyStatusFilter() {
    // เก็บไว้เป็น stub — filter แบบ server ต้องเพิ่ม endpoint แยก
  }

  /// legacy filter fields ที่ widget เดิมอาจใช้ — คงไว้ไม่ให้พัง
  String? _getField(CustomerReportItem t, String field) {
    switch (field) {
      case 'uuid':
        return t.uuid;
      case 'custno':
        return t.custno;
      case 'taxno':
        return t.taxno;
      case 'scname':
        return t.scname;
      case 'sname':
        return t.sname;
      case 'cname':
        return t.cname;
      case 'branch':
        return t.branch;
      case 'attn':
        return t.attn;
      case 'tel':
        return t.tel;
      case 'email':
        return t.email;
      case 'tax':
        return t.tax;
      default:
        return null;
    }
  }

  static const List<Map<String, String>> kSearchFields = [
    {'value': 'cname', 'label': 'ชื่อลูกค้า'},
    {'value': 'scname', 'label': 'ชื่อร้าน'},
    {'value': 'custno', 'label': 'เลขที่ลูกค้า'},
    {'value': 'taxno', 'label': 'เลขประจำตัวผู้เสียภาษี'},
    {'value': 'tel', 'label': 'เบอร์โทร'},
    {'value': 'email', 'label': 'อีเมล'},
    {'value': 'lineid', 'label': 'Line ID'},
  ];

  void setSearch(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setSearchField(String field) {
    _searchField = field;
    notifyListeners();
  }

  void onStatusChanged(String? value) {
    if (value == null) return;
    _selectedStatus = value;
    notifyListeners();
  }

  Future<void> executeSearch() async {
    await refresh();
  }

  // ===============================================================
  // User actions
  // ===============================================================
  void onViewTenant(CustomerReportItem model) {
    // ใช้ uuid เป็น key หลัก (รายงานไม่มี ser)
    final key = model.uuid?.toString() ?? model.custno ?? '';
    _eventController.add(
      RegistrationNavigateEvent('ทะเบียนผู้เช่า', routeData: key),
    );
  }

  CustomerReportItem? findTenantByKey(String key) {
    if (key.isEmpty) return null;
    for (final t in _pagedItems) {
      if (t.uuid?.toString() == key) return t;
      if (t.custno?.toString() == key) return t;
    }
    return null;
  }

  // ---------- Pagination (alias สำหรับ widget) ----------
  int get computedLastPage => lastPage;
  void goToPage(int page) => loadPage(page);

  // ===============================================================
  // Helpers
  // ===============================================================
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _emitError(String msg) {
    _eventController.add(RegistrationErrorEvent(msg));
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
