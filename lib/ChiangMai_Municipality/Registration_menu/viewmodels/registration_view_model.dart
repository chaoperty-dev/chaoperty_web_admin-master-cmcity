// ============================================================================
// registration_view_model.dart
// ============================================================================
// ViewModel — จัดการ state + business logic ของหน้า "ทะเบียน"
// - เรียก Service โหลดรายการลูกค้า (จาก GC_custo_se.php เดิมของ Bureau_Registration)
// - filter ผ่าน search field ที่ระบุในแต่ละ column
// - ไม่ผูกกับ Flutter UI
// ============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../Model/GetCustomer_Model.dart';
import '../../../../Model/GetType_Model.dart';
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

  // ---------- Data (master) ----------
  List<CustomerModel> _customers = [];
  List<CustomerModel> get customers => _customers;

  // ---------- Data (filtered) ----------
  List<CustomerModel> _filtered = [];
  List<CustomerModel> get filtered => _filtered;

  // ---------- Pagination ----------
  int _currentPage = 0;
  int _lastPage = 0;
  int _total = 0;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get total => _total;

  // ---------- UI state ----------
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _searchField = 'scname';
  String get searchField => _searchField;

  // ---------- Types ----------
  List<TypeModel> _typeModels = [];
  List<TypeModel> get typeModels => _typeModels;

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
      _searchField = 'uuid';
    }
    await Future.wait([
      loadTypes(),
      refresh(),
    ]);
  }

  // ===============================================================
  // Service calls
  // ===============================================================
  Future<void> refresh() async {
    _setLoading(true);
    try {
      final list = await _service.fetchCustomers();
      _customers = list;
      _total = list.length;
      _applyFilter();
    } catch (e) {
      _emitError('โหลดข้อมูลไม่สำเร็จ: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _applyFilter() {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) {
      _filtered = List.of(_customers);
    } else {
      _filtered = _customers.where((c) {
        final hay = _getField(c, _searchField)?.toLowerCase() ?? '';
        return hay.contains(q);
      }).toList();
    }
    _currentPage = _filtered.isEmpty ? 0 : 1;
    _lastPage = 1;
  }

  String? _getField(CustomerModel c, String field) {
    switch (field) {
      case 'custno':
        return c.custno;
      case 'scname':
        return c.scname;
      case 'cname':
        return c.cname;
      case 'tel':
        return c.tel;
      case 'email':
        return c.email;
      case 'tax':
        return c.tax;
      case 'addr':
        return '${c.addr1 ?? ''} ${c.addr2 ?? ''}';
      case 'uuid':
        return c.uuid;
      default:
        return c.scname;
    }
  }

  /// field ที่แสดงใน dropdown
  static const List<Map<String, String>> kSearchFields = [
    {'value': 'scname', 'label': 'ชื่อย่อ'},
    {'value': 'cname', 'label': 'ชื่อลูกค้า'},
    {'value': 'custno', 'label': 'รหัสลูกค้า'},
    {'value': 'tel', 'label': 'เบอร์โทร'},
    {'value': 'email', 'label': 'อีเมล'},
    {'value': 'tax', 'label': 'เลขประจำตัวผู้เสียภาษี'},
    {'value': 'addr', 'label': 'ที่อยู่'},
    {'value': 'uuid', 'label': 'UUID'},
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

  Future<void> executeSearch() async {
    if (_customers.isEmpty) {
      await refresh();
    } else {
      _setLoading(true);
      try {
        _applyFilter();
      } finally {
        _setLoading(false);
      }
    }
  }

  Future<void> loadTypes() async {
    try {
      _typeModels = await _service.fetchTypes();
      notifyListeners();
    } catch (e) {
      print('loadTypes error: $e');
    }
  }

  // ===============================================================
  // User actions
  // ===============================================================
  /// กด "เรียกดู" ในแถว → ส่ง event ให้ View (เปิด full-page route)
  void onViewCustomer(CustomerModel model) {
    final uuid = model.uuid?.toString() ?? '';
    _eventController.add(
      RegistrationNavigateEvent('ทะเบียนลูกค้า', routeData: uuid),
    );
  }

  /// หา customer จาก uuid (ค้นทั้งใน master + filtered)
  CustomerModel? findCustomerByUuid(String uuid) {
    if (uuid.isEmpty) return null;
    for (final c in _customers) {
      if (c.uuid?.toString() == uuid) return c;
    }
    return null;
  }

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
