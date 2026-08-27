// ============================================================================
// registration_view_model.dart
// ============================================================================
// ViewModel — จัดการ state + business logic ของหน้า "ทะเบียนผู้เช่า"
// - ตารางเมนูใช้รายงานลูกค้า (CustomerReportItem) จากรายงานผู้เช่า
// - filter + search + pagination (client-side)
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

  // ---------- Data (master + filtered) ----------
  List<CustomerReportItem> _customers = [];
  List<CustomerReportItem> _filtered = [];
  List<CustomerReportItem> get customers => _customers;
  List<CustomerReportItem> get filtered => _filtered;

  // ---------- Pagination ----------
  int _currentPage = 1;
  int _total = 0;
  int get currentPage => _currentPage;
  int get total => _total;
  int get lastPage {
    if (_total == 0) return 0;
    return ((_total - 1) ~/ perPage) + 1;
  }

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

  /// รายการที่จะแสดงในหน้าปัจจุบัน
  List<CustomerReportItem> get paged {
    if (_filtered.isEmpty) return const [];
    final page = _currentPage < 1 ? 1 : _currentPage;
    final start = (page - 1) * perPage;
    if (start >= _filtered.length) return const [];
    final end = (start + perPage).clamp(0, _filtered.length);
    return _filtered.sublist(start, end);
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
      _searchField = 'custno';
    }
    await refresh();
  }

  // ===============================================================
  // Service calls
  // ===============================================================
  Future<void> refresh() async {
    _setLoading(true);
    try {
      final list = await _service.fetchReportCustomers();
      _customers = list;
      _applyFilter();
    } catch (e) {
      _emitError('โหลดข้อมูลไม่สำเร็จ: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _applyFilter() {
    // 1) ค้นหาตามคำค้น
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) {
      _filtered = List<CustomerReportItem>.from(_customers);
    } else {
      _filtered = _customers.where((t) {
        final fields = [
          t.uuid,
          t.custno,
          t.taxno,
          t.scname,
          t.sname,
          t.cname,
          t.branch,
          t.attn,
          t.addr1,
          t.addr2,
          t.zip,
          t.tel,
          t.tax,
          t.fax,
          t.email,
          t.lineid,
          t.status,
          t.birth,
          t.national,
          t.religion,
        ];
        return fields.any((f) => (f ?? '').toLowerCase().contains(q));
      }).toList();
    }

    // 2) กรองตามสถานะ (client-side ตาม field st)
    if (_selectedStatus != 'ทั้งหมด') {
      _filtered = _filtered.where((t) {
        switch (_selectedStatus) {
          case 'ปัจจุบัน':
            return t.st == 1;
          case 'หมดสัญญา':
            return t.st == 0 || t.st == 2;
          case 'ใกล้หมดสัญญา':
            return t.st == 3;
          default:
            return true;
        }
      }).toList();
    }

    _total = _filtered.length;
    final last = lastPage;
    if (_currentPage < 1) _currentPage = 1;
    if (_currentPage > last && last > 0) _currentPage = last;
  }

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
      case 'tax':
        return t.tax;
      case 'email':
        return t.email;
      case 'lineid':
        return t.lineid;
      default:
        return t.uuid;
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
    _applyFilter();
    notifyListeners();
  }

  void setSearchField(String field) {
    _searchField = field;
    _applyFilter();
    notifyListeners();
  }

  void onStatusChanged(String? value) {
    if (value == null) return;
    _selectedStatus = value;
    _applyFilter();
    notifyListeners();
  }

  Future<void> executeSearch() async {
    _setLoading(true);
    try {
      _applyFilter();
    } finally {
      _setLoading(false);
    }
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
    for (final t in _customers) {
      if (t.uuid?.toString() == key) return t;
      if (t.custno?.toString() == key) return t;
    }
    return null;
  }

  // ---------- Pagination (alias สำหรับ widget) ----------
  int get computedLastPage => lastPage;
  void goToPage(int page) => loadPage(page);

  // ===============================================================
  // Pagination
  // ===============================================================
  void loadPage(int page) {
    if (page < 1 || page > lastPage) return;
    _currentPage = page;
    notifyListeners();
  }

  void nextPage() => loadPage(_currentPage + 1);
  void prevPage() => loadPage(_currentPage - 1);

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
