// ============================================================================
// registration_view_model.dart
// ============================================================================
// ViewModel — จัดการ state + business logic ของหน้า "ทะเบียน"
// - เรียก Service โหลดรายการลูกค้า (จาก GC_custo_se.php)
// - filter ผ่าน search field
// - ไม่ผูกกับ Flutter UI
// ============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../Model/GetCustomer_Model.dart';
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
  List<CustomerModel> _customers = [];
  List<CustomerModel> _filtered = [];
  List<CustomerModel> get customers => _customers;
  List<CustomerModel> get filtered => _filtered;

  // ---------- Pagination (derived — API ส่ง list ทั้งหมด) ----------
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

  // ---------- Pagination constants ----------
  static const int perPage = 50;

  /// จำนวนหน้า derived จาก filtered list
  int get computedLastPage {
    if (_filtered.isEmpty) return 0;
    return ((_filtered.length - 1) ~/ perPage) + 1;
  }

  /// รายการที่จะแสดงในหน้าปัจจุบัน (slice จาก filtered)
  List<CustomerModel> get paged {
    if (_filtered.isEmpty) return const [];
    // ถ้ายังไม่มี currentPage (เช่น ก่อน refresh เสร็จ) ใช้หน้า 1
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
      _searchField = 'uuid';
    }
    await refresh();
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
    // คำนวณหน้าใหม่ — ถ้า current page เกิน lastPage ให้ clamp ลง
    final last = computedLastPage;
    _lastPage = last;
    if (_currentPage < 1) _currentPage = 1;
    if (_currentPage > last && last > 0) _currentPage = last;
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

  // ===============================================================
  // User actions
  // ===============================================================
  void onViewCustomer(CustomerModel model) {
    // ใช้ ser เป็น key หลัก (API V2 ไม่มี field uuid)
    final key = model.ser?.toString() ?? model.uuid?.toString() ?? '';
    _eventController.add(
      RegistrationNavigateEvent('ทะเบียนลูกค้า', routeData: key),
    );
  }

  CustomerModel? findCustomerByUuid(String key) {
    if (key.isEmpty) return null;
    for (final c in _customers) {
      // match ด้วย ser ก่อน (API V2) → fallback uuid
      if (c.ser?.toString() == key) return c;
      if (c.uuid?.toString() == key) return c;
    }
    return null;
  }

  /// Local override สำหรับ "แอพผู้เช่า" (แยกจาก st ของลูกค้า)
  /// - key = ser (preferred) หรือ uuid (fallback)
  /// - value = st (0/1)
  /// - ใช้เพราะ API ของแอพผู้เช่ายังไม่มี → เก็บ state ในเครื่อง
  final Map<String, int> _appStatusOverrides = {};

  /// อ่าน "แอพผู้เช่า" ของลูกค้า (fallback เป็น null ถ้าไม่มี)
  /// - ใช้ override ก่อน (ถ้ามี) → ไม่งั้นดู model จริง
  bool? appStatusFor(String uuid) {
    if (_appStatusOverrides.containsKey(uuid)) {
      return _isOn(_appStatusOverrides[uuid]);
    }
    return null;
  }

  /// Toggle "แอพผู้เช่า" (toggleCustomerAppStatus)
  /// - ตอนนี้ service ยังเป็น stub (return false)
  /// - optimistic update ใน local map → rollback ถ้า fail
  Future<void> toggleCustomerAppAccess(String uuid) async {
    final idx = _customers.indexWhere((c) => c.uuid?.toString() == uuid);
    if (idx < 0) return;

    final current = _customers[idx];
    final customerSer = current.ser?.toString() ?? '';
    if (customerSer.isEmpty) {
      _emitError('ไม่พบ ser ของลูกค้า');
      return;
    }

    // optimistic — อ่าน state ปัจจุบัน (override ก่อน, ไม่งั้น fallback เป็น 0)
    final currentVal =
        _appStatusOverrides[uuid] ?? (current.st is int ? current.st : 0);
    final nextVal = (currentVal == 1) ? 0 : 1;
    _appStatusOverrides[uuid] = nextVal;
    notifyListeners();

    try {
      final ok = await _service.toggleCustomerAppStatus(customerSer, nextVal);
      if (!ok) {
        // rollback
        _appStatusOverrides[uuid] = currentVal;
        notifyListeners();
        _emitError('อัปเดตสถานะแอพผู้เช่าไม่สำเร็จ (รอ API)');
      }
    } catch (e) {
      _appStatusOverrides[uuid] = currentVal;
      notifyListeners();
      _emitError('อัปเดตสถานะแอพผู้เช่าไม่สำเร็จ: $e');
    }
  }

  /// ===== LINE (ลงทะเบียน / ลบ ไลน์) =====
  /// TODO: รอ API ของฝั่งไลน์ OA (ตอนนี้ยังไม่มี endpoint)
  /// - ตอนนี้ส่ง SnackBar แจ้ง user ว่ายังไม่พร้อม
  Future<void> registerLine(String uuid) async {
    final name = findCustomerByUuid(uuid)?.scname ?? '';
    debugPrint('⚠️ [registerLine] uuid=$uuid, name=$name — API ยังไม่มี');
    _eventController.add(
      RegistrationErrorEvent('ยังไม่รองรับการลงทะเบียนไลน์ (รอ API)'),
    );
  }

  Future<void> removeLine(String uuid) async {
    final c = findCustomerByUuid(uuid);
    final name = c?.scname ?? '';
    final oldLine = c?.lineid ?? '';
    debugPrint(
        '⚠️ [removeLine] uuid=$uuid, name=$name, lineid=$oldLine — API ยังไม่มี');
    _eventController.add(
      RegistrationErrorEvent('ยังไม่รองรับการลบไลน์ (รอ API)'),
    );
  }

  /// สลับ st ของลูกค้า (เปิด/ปิดใช้งาน)
  /// - อัพเดต state ในเครื่องทันที (optimistic)
  /// - ส่ง API ไป update — ถ้า fail ค่อย rollback
  Future<void> toggleAppAccess(String uuid) async {
    final idx = _customers.indexWhere((c) => c.uuid?.toString() == uuid);
    if (idx < 0) return;

    // อ่านค่าปัจจุบัน
    final current = _customers[idx];
    final currentSt = current.st;
    final bool currentOn = _isOn(currentSt);

    // ใช้ ser ของลูกค้า (running number) เป็น key ส่งไป API
    final customerSer = current.ser?.toString() ?? '';
    if (customerSer.isEmpty) {
      _emitError('ไม่พบ ser ของลูกค้า');
      return;
    }

    // optimistic update
    current.st = currentOn ? 0 : 1;
    _applyFilter(); // refresh filter (no-op สำหรับ toggle แต่ safe)
    notifyListeners();

    try {
      final ok = await _service.toggleCustomerStatus(customerSer, current.st);
      if (!ok) {
        // rollback
        current.st = currentSt;
        notifyListeners();
        _emitError('อัปเดตสถานะไม่สำเร็จ');
      } else {
        // ─── สำเร็จ → รีเฟรชข้อมูลจาก API ───
        debugPrint('🔄 [toggleAppAccess] success → กำลัง refresh ข้อมูล...');
        await refresh();
        debugPrint('✅ [toggleAppAccess] refresh เสร็จ');
      }
    } catch (e) {
      // rollback
      current.st = currentSt;
      notifyListeners();
      _emitError('อัปเดตสถานะไม่สำเร็จ: $e');
    }
  }

  static bool _isOn(dynamic st) {
    if (st == null) return false;
    if (st is bool) return st;
    if (st is num) return st == 1;
    if (st is String) {
      final s = st.trim();
      return s == '1' || s.toLowerCase() == 'true';
    }
    return false;
  }

  // ===============================================================
  // Pagination
  // ===============================================================
  /// กด Prev / Next → เปลี่ยนหน้า (client-side)
  void loadPage(String? urlOrMarker) {
    // urlOrMarker รับได้ทั้ง "prev" / "next" (string) หรือ int
    if (urlOrMarker == null) return;
    if (urlOrMarker == 'prev') {
      goToPage(_currentPage - 1);
    } else if (urlOrMarker == 'next') {
      goToPage(_currentPage + 1);
    } else {
      final n = int.tryParse(urlOrMarker);
      if (n != null) goToPage(n);
    }
  }

  void goToPage(int page) {
    final last = computedLastPage;
    if (page < 1) page = 1;
    if (page > last && last > 0) page = last;
    if (page == _currentPage) return;
    _currentPage = page;
    notifyListeners();
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
