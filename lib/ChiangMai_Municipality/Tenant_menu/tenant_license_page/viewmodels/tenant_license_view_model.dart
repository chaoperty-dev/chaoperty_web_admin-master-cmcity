// ============================================================================
// tenant_license_view_model.dart
// ============================================================================
// ViewModel — จัดการ state + business logic ของหน้า "ผู้เช่า"
// - เรียก Service โหลดรายการ tab แรก
// - แจ้ง View ผ่าน Stream<TenantLicenseEvent>
// - ไม่ผูกกับ Flutter UI
// ============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../Model/GetTeNant_Model.dart';
import '../../../../Model/GetZone_Model.dart';
import '../../../../Model/GetSubZone_Model.dart';
import '../../../unity/zone_selection_store.dart';
import '../models/tenant_license_config.dart';
import '../models/tenant_license_event.dart';
import '../services/tenant_license_service.dart';

class TenantLicenseViewModel extends ChangeNotifier {
  TenantLicenseViewModel({
    required TenantLicenseConfig config,
    TenantLicenseService? service,
  })  : _config = config,
        _service = service ?? TenantLicenseService() {
    // ✅ sync state จาก global ZoneSelectionStore (คงค่าที่ user เลือกไว้ข้ามหน้า)
    _selectedZoneSub = ZoneSelectionStore.instance.selectedZoneSub == 'ทั้งหมด'
        ? null
        : ZoneSelectionStore.instance.selectedZoneSub;
    _selectedZone = ZoneSelectionStore.instance.selectedZone == 'ทั้งหมด'
        ? null
        : ZoneSelectionStore.instance.selectedZone;
    _selectedZoneSer = '0';
    ZoneSelectionStore.instance.addListener(_onZoneStoreChanged);
    _loadInitial();
  }

  final ZoneSelectionStore _zoneStore = ZoneSelectionStore.instance;

  void _onZoneStoreChanged() {
    final newSub = _zoneStore.selectedZoneSub == 'ทั้งหมด'
        ? null
        : _zoneStore.selectedZoneSub;
    final newZone = _zoneStore.selectedZone == 'ทั้งหมด'
        ? null
        : _zoneStore.selectedZone;
    final newLease = _zoneStore.selectedLeaseStatus;
    final subChanged = _selectedZoneSub != newSub;
    final zoneChanged = _selectedZone != newZone;
    final statusChanged = _selectedStatus != newLease;
    if (!subChanged && !zoneChanged && !statusChanged) return;

    final needRefresh =
        (subChanged || zoneChanged || statusChanged);

    _selectedZoneSub = newSub;
    _selectedZone = newZone;
    _selectedZoneSer = '0';
    _selectedStatus = newLease;

    notifyListeners();

    // resolve sub-ser ใหม่ (sub-zones อาจเปลี่ยน) → reload zones filtered
    String? subSer;
    if (_selectedZoneSub != null) {
      final sub = _subzoneModels.firstWhere(
        (s) => s.zn == _selectedZoneSub,
        orElse: () => SubZoneModel(),
      );
      subSer = (sub.ser == '0' || sub.ser == null) ? null : sub.ser;
      loadZones(zoneSubSer: subSer);
    }
    if (needRefresh) {
      refresh();
    }
  }

  final TenantLicenseConfig _config;
  final TenantLicenseService _service;

  // ---------- Event channel ----------
  final StreamController<TenantLicenseEvent> _eventController =
      StreamController<TenantLicenseEvent>.broadcast();
  Stream<TenantLicenseEvent> get events => _eventController.stream;

  // ---------- Data ----------
  List<TeNantModel> _allTenants = [];
  List<TeNantModel> _filteredTenants = [];
  List<TeNantModel> get tenants => _filteredTenants;

  // ---------- Pagination ----------
  static const int _perPage = 50;
  int _currentPage = 1;
  int _total = 0;

  int get currentPage => _currentPage;
  int get lastPage => (_total / _perPage).ceil();
  int get total => _total;

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
  static const List<String> _statusOptions = [
    'ทั้งหมด',
    'ปัจจุบัน',
    'หมดสัญญา',
    'ใกล้หมดสัญญา',
  ];

  String _selectedStatus = 'ทั้งหมด';
  List<String> get statusOptions => _statusOptions;
  String get selectedStatus => _selectedStatus;

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
    // 1) load sub-zones ก่อน (ต้อง resolve ser ของ selectedSub)
    await loadSubZones();
    // 2) ถ้า store มี selected sub-zone → load zones filter ตาม ser
    String? subSer;
    if (_selectedZoneSub != null && _selectedZoneSub!.isNotEmpty) {
      final sub = _subzoneModels.firstWhere(
        (s) => s.zn == _selectedZoneSub,
        orElse: () => SubZoneModel(),
      );
      subSer = (sub.ser == '0' || sub.ser == null) ? null : sub.ser;
    }
    await loadZones(zoneSubSer: subSer);
    // 3) resolve zone ser ที่เลือกไว้ (จาก zone list ที่ filter แล้ว)
    if (_selectedZone != null && _selectedZone!.isNotEmpty) {
      final zn = _zoneModels.firstWhere(
        (z) => z.zn == _selectedZone,
        orElse: () => ZoneModel(),
      );
      _selectedZoneSer = zn.ser;
    }
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
  /// → ดึง API ผู้เช่าใหม่ (zn=null = ทั้งหมด)
  Future<void> onSubZoneChanged(String? value) async {
    if (value == null) return;
    // ✅ sync เข้า global store (auto-reset zone)
    _zoneStore.setSubZone(value);
    // store listener จะ sync state กลับมา + reload zones + refresh
  }

  /// ผู้ใช้เลือก "โซน" → reload ผู้เช่า filter ด้วย zn
  Future<void> onZoneChanged(String? value) async {
    if (value == null) return;
    // ✅ sync เข้า global store
    _zoneStore.setZone(value);
    // store listener จะ sync + refresh
  }

  // ===============================================================
  // Service calls
  // ===============================================================
  Future<void> refresh() async {
    _setLoading(true);
    try {
      _allTenants = await _service.fetchTenants(
        zone: (_selectedZone == null ||
                _selectedZone == '0' ||
                _selectedZone == 'ทั้งหมด')
            ? null
            : _selectedZone,
        status: _selectedStatus == 'ทั้งหมด' ? null : _selectedStatus,
      );
      _applyFilters();
      _currentPage = 1;
    } catch (e) {
      _emitError('โหลดข้อมูลไม่สำเร็จ: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _applyFilters() {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) {
      _filteredTenants = List<TeNantModel>.from(_allTenants);
    } else {
      _filteredTenants = _allTenants.where((t) {
        final fields = [
          t.lncode,
          t.cid,
          t.docno,
          t.sname,
          t.cname,
          t.zn,
          t.zser,
          t.sdate,
          t.fid,
          t.sdate_q,
          t.ldate_q,
          t.wnote,
        ];
        return fields.any((f) => (f ?? '').toLowerCase().contains(q));
      }).toList();
    }
    _total = _filteredTenants.length;
  }

  void setSearch(String value) {
    _searchQuery = value;
    _applyFilters();
    _currentPage = 1;
    notifyListeners();
  }

  Future<void> executeSearch() async {
    // สำหรับ tenant API ไม่ต้องยิง API ใหม่ทุกครั้ง กรอง local ได้
    _applyFilters();
    _currentPage = 1;
    notifyListeners();
  }

  void onStatusChanged(String? value) {
    if (value == null) return;
    // ✅ sync เข้า global store (lease status)
    _zoneStore.setLeaseStatus(value);
    // store listener จะ sync + refresh
  }

  void loadPage(int page) {
    if (page < 1 || page > lastPage) return;
    _currentPage = page;
    notifyListeners();
  }

  // ===============================================================
  // User actions
  // ===============================================================
  /// ผู้ใช้กดปุ่ม "เรียกดู" ในแถว → นำทางไป PeopleChaoScreen2 ด้วย logic เดียวกับ PeopleChao_Screen
  void onViewRequest(TeNantModel model) {
    final cid = model.docno ?? model.cid ?? '';
    final nameShopIndex = model.quantity ?? '';
    final status = _computePeopleChaoStatus(model);

    _eventController.add(
      TenantLicenseNavigateEvent(
        'PeopleChaoScreen2',
        routeData: cid,
        nameShopIndex: nameShopIndex,
        status: status,
      ),
    );
  }

  /// คำนวณสถานะให้ตรงกับ PeopleChao_Screen.dart
  String _computePeopleChaoStatus(TeNantModel model) {
    final quantity = model.quantity;
    if (quantity == '2') return 'เสนอราคา';
    if (quantity == '3') return 'เสนอราคา(มัดจำ)';

    final ldate = model.ldate_q ?? model.ldate;
    if (ldate == null || ldate.isEmpty || ldate == '0000-00-00') {
      return quantity == '1' ? 'เช่าอยู่' : 'ว่าง';
    }

    try {
      final end = DateTime.parse('$ldate 00:00:00');
      final now = DateTime.now();
      if (now.isAfter(end)) return 'หมดสัญญา';
      // open_set_date ใช้ค่า default 30 วัน เหมือน PeopleChao_Screen fallback
      if (now.isAfter(end.subtract(const Duration(days: 30)))) {
        return 'ใกล้หมดสัญญา';
      }
      return 'เช่าอยู่';
    } catch (_) {
      return quantity == '1' ? 'เช่าอยู่' : 'ว่าง';
    }
  }

  // ===============================================================
  // Helpers
  // ===============================================================
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _emitError(String msg) {
    _eventController.add(TenantLicenseErrorEvent(msg));
  }

  @override
  void dispose() {
    _zoneStore.removeListener(_onZoneStoreChanged);
    _eventController.close();
    super.dispose();
  }
}
