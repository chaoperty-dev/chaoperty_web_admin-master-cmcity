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

import '../../../../Model/GetZone_Model.dart';
import '../../../../Model/GetSubZone_Model.dart';
import '../models/tenant_permit_models.dart';
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
    // ✅ sync state จาก global ZoneSelectionStore (area scope — shared with Area menu)
    _selectedZoneSub = ZoneSelectionStore.instance.areaSubZone == 'ทั้งหมด'
        ? null
        : ZoneSelectionStore.instance.areaSubZone;
    _selectedZone = ZoneSelectionStore.instance.areaZone == 'ทั้งหมด'
        ? null
        : ZoneSelectionStore.instance.areaZone;
    _selectedZoneSer = '0';
    ZoneSelectionStore.instance.addListener(_onZoneStoreChanged);
    _loadInitial();
  }

  final ZoneSelectionStore _zoneStore = ZoneSelectionStore.instance;

  void _onZoneStoreChanged() {
    final newSub = _zoneStore.areaSubZone == 'ทั้งหมด'
        ? null
        : _zoneStore.areaSubZone;
    final newZone = _zoneStore.areaZone == 'ทั้งหมด'
        ? null
        : _zoneStore.areaZone;
    final subChanged = _selectedZoneSub != newSub;
    final zoneChanged = _selectedZone != newZone;
    if (!subChanged && !zoneChanged) return;

    _selectedZoneSub = newSub;
    _selectedZone = newZone;
    _selectedZoneSer = newZone == null
        ? '0'
        : _zoneModels
            .where((z) => z.zn == newZone)
            .map((z) => z.ser ?? '0')
            .firstOrNull ?? '0';
    final needRefresh = subChanged || zoneChanged;

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

  // ---------- Data: permits ----------
  List<TenantPermitListItem> _permits = [];
  List<TenantPermitListItem> get tenants => List.unmodifiable(_permits);

  // ---------- Pagination ----------
  static const int _perPage = 50;
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

  // ---------- Zones ----------
  List<ZoneModel> _zoneModels = [];
  List<SubZoneModel> _subzoneModels = [];
  String? _selectedZoneSub;
  String? _selectedZone;
  String? _selectedZoneSer;

  List<ZoneModel> get zoneModels => _zoneModels;
  List<SubZoneModel> get subzoneModels => _subzoneModels;
  String? get selectedZoneSub => _selectedZoneSub;
  String? get selectedZone => _selectedZone;
  String? get selectedZoneSer => _selectedZoneSer;

  // ---------- Permit status filter ----------
  static const List<String> _statusOptions = [
    'ทั้งหมด',
    'รอดำเนินการ',
    'ออกใบอนุญาตแล้ว',
    'ดำเนินการไม่สำเร็จ',
  ];

  String _selectedStatus = 'ทั้งหมด';
  List<String> get statusOptions => _statusOptions;
  String get selectedStatus => _selectedStatus;

  String statusApiValue(String label) {
    switch (label) {
      case 'รอดำเนินการ':
        return 'pending';
      case 'ออกใบอนุญาตแล้ว':
        return 'issued';
      case 'ดำเนินการไม่สำเร็จ':
        return 'failed';
      default:
        return '';
    }
  }

  String zoneLabel(String zoneId) {
    if (zoneId.isEmpty || zoneId == '0') return '-';
    final zone = _zoneModels.where((item) => item.ser == zoneId).firstOrNull;
    return zone?.zn?.isNotEmpty == true ? zone!.zn! : zoneId;
  }

  String statusLabel(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return 'รอดำเนินการ';
      case 'issued':
        return 'ออกใบอนุญาตแล้ว';
      case 'failed':
        return 'ดำเนินการไม่สำเร็จ';
      default:
        return value.isEmpty ? 'ไม่ระบุ' : value;
    }
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
    // ✅ sync เข้า global store (area scope, auto-reset zone)
    _zoneStore.setAreaSubZone(value);
    // store listener จะ sync state กลับมา + reload zones + refresh
  }

  /// ผู้ใช้เลือก "โซน" → reload ผู้เช่า filter ด้วย zn
  Future<void> onZoneChanged(String? value) async {
    if (value == null) return;
    // ✅ sync เข้า global store (area scope)
    _zoneStore.setAreaZone(value);
    // store listener จะ sync + refresh
  }

  // ===============================================================
  // Service calls
  // ===============================================================
  Future<void> refresh({int? page}) async {
    _setLoading(true);
    try {
      final result = await _service.fetchPermits(
        page: page ?? _currentPage,
        perPage: _perPage,
        status: statusApiValue(_selectedStatus),
        search: _searchQuery,
        zser: _selectedZoneSer ?? '',
      );
      _permits = result.items;
      _currentPage = result.currentPage;
      _lastPage = result.lastPage < 1 ? 1 : result.lastPage;
      _total = result.total;
    } catch (e) {
      _permits = [];
      _total = 0;
      _emitError('โหลดข้อมูลไม่สำเร็จ: $e');
    } finally {
      _setLoading(false);
    }
  }

  void setSearch(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  Future<void> executeSearch() async {
    _currentPage = 1;
    await refresh(page: 1);
  }

  void onStatusChanged(String? value) {
    if (value == null) return;
    _selectedStatus = value;
    _currentPage = 1;
    notifyListeners();
    refresh(page: 1);
  }

  Future<void> loadPage(int page) async {
    if (page < 1 || page > lastPage || page == _currentPage) return;
    await refresh(page: page);
  }

  // ===============================================================
  // User actions
  // ===============================================================
  /// ผู้ใช้กดปุ่ม "เรียกดู" → เปิดรายละเอียดใบอนุญาตด้วย permit UUID
  void onViewRequest(TenantPermitListItem permit) {
    _eventController.add(
      TenantLicenseNavigateEvent(
        'TenantPermitDetail',
        routeData: permit.uuid,
        status: permit.status,
      ),
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
    _eventController.add(TenantLicenseErrorEvent(msg));
  }

  @override
  void dispose() {
    _zoneStore.removeListener(_onZoneStoreChanged);
    _eventController.close();
    super.dispose();
  }
}
