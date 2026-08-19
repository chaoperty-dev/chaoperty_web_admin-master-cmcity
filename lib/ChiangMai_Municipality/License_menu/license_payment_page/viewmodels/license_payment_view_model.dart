// ============================================================================
// license_payment_view_model.dart
// ============================================================================
// ViewModel — จัดการ state + business logic ของหน้า "การรับชำระ" (Payment v2)
// - โหลด PaymentTask list (v2 endpoint) + สร้าง draft + บันทึกการรับชำระ
// - โหลด Zones/SubZones (legacy PHP API)
// - แจ้ง View ผ่าน Stream<LicensePaymentEvent>
// - ไม่ผูกกับ Flutter UI
// ============================================================================

import 'dart:async';

import 'package:chaoperty/Constant/api_cache.dart';
import 'package:flutter/foundation.dart';

import '../../../../Model/GetSubZone_Model.dart';
import '../../../../Model/GetZone_Model.dart';
import '../models/license_payment_detail_model.dart';
import '../models/license_payment_config.dart';
import '../models/license_payment_event.dart';
import '../models/payment_task_model.dart';
import '../services/license_payment_detail_service.dart';
import '../services/license_payment_service.dart';

class LicensePaymentViewModel extends ChangeNotifier {
  LicensePaymentViewModel({
    required LicensePaymentConfig config,
    LicensePaymentService? paymentService,
    LicensePaymentDetailService? detailService,
    ApiCache? cache,
  })  : _config = config,
        _paymentService = paymentService ?? LicensePaymentService(cache: cache),
        _detailService = detailService ?? LicensePaymentDetailService() {
    _loadInitial();
  }

  final LicensePaymentConfig _config;
  final LicensePaymentService _paymentService;
  final LicensePaymentDetailService _detailService;

  // ---------- Event channel ----------
  final StreamController<LicensePaymentEvent> _eventController =
      StreamController<LicensePaymentEvent>.broadcast();
  Stream<LicensePaymentEvent> get events => _eventController.stream;

  // ---------- Data ----------
  List<PaymentTask> _payments = [];
  List<PaymentTask> get payments => _payments;

  // ---------- Zones ----------
  List<ZoneModel> _zoneModels = [];
  List<SubZoneModel> _subzoneModels = [];

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

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ---------- Search ----------
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // ---------- v2 filter state ----------
  String _searchCustomer = '';
  String get searchCustomer => _searchCustomer;

  bool _includeDone = true;
  bool get includeDone => _includeDone;

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

  void setCustomerSearch(String value) {
    _searchCustomer = value;
    notifyListeners();
  }

  void setIncludeDone(bool v) {
    _includeDone = v;
    notifyListeners();
    refresh();
  }

  // ---------- Zone filter state ----------
  String? _selectedZoneSub;
  String? _selectedZone;
  String? _selectedZoneSer;
  String? _selectedZoneSubSer;

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
    // โหลด zones/subzones + payments พร้อมกัน
    await Future.wait([
      _loadZones(),
      _loadSubZones(),
      refresh(),
    ]);
  }

  // ===============================================================
  // Service calls
  // ===============================================================
  /// โหลดรายการ "Payment Tasks" ทั้งหมด — v2 endpoint
  /// v2 รับ `zser` (zone serial) — ส่งเฉพาะเมื่อเลือกโซนจริง (ไม่ใช่ 0/ว่าง)
  Future<void> refresh() async {
    _setLoading(true);
    _clearError();
    try {
      final zserRaw = _selectedZoneSer;
      final zserFilter = (zserRaw == null ||
              zserRaw.isEmpty ||
              zserRaw == '0' ||
              zserRaw == 'ทั้งหมด')
          ? null
          : zserRaw;
      final subzoneserRaw = _selectedZoneSubSer;
      final subzoneserFilter =
          (subzoneserRaw == null || subzoneserRaw.isEmpty)
              ? null
              : subzoneserRaw;
      final res = await _paymentService.listPaymentTasks(
        q: _searchQuery.isNotEmpty ? _searchQuery : null,
        customer: _searchCustomer.isNotEmpty ? _searchCustomer : null,
        statuses: _statusesFilter,
        includeDone: _includeDone,
        perPage: 50,
        zser: zserFilter,
        subzoneser: subzoneserFilter,
      );
      _payments = res.data;
      _currentPage = res.currentPage;
      _lastPage = res.lastPage;
      _total = res.total;
      _linksNext = res.linksNext;
      _linksPrev = res.linksPrev;
    } catch (e) {
      _setError('โหลดข้อมูลไม่สำเร็จ: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// โหลด Zones (สำหรับ dropdown filter)
  Future<void> _loadZones() async {
    try {
      _zoneModels = await _paymentService.fetchZones();
    } catch (e) {
      print('LicensePaymentViewModel._loadZones error: $e');
    }
    notifyListeners();
  }

  /// โหลด SubZones (สำหรับ dropdown filter)
  Future<void> _loadSubZones() async {
    try {
      _subzoneModels = await _paymentService.fetchSubZones();
    } catch (e) {
      print('LicensePaymentViewModel._loadSubZones error: $e');
    }
    notifyListeners();
  }

  /// สร้าง Payment Draft (Internal/External)
  /// Returns the new PaymentDetail on success, or null on failure
  Future<PaymentDetail?> createDraft({
    required String requestUuid,
    required String paymentSystem,
    required String payType,
    int? paymentMethodId,
    double? amount,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final created = await _paymentService.createPaymentDraft(
        requestUuid: requestUuid,
        paymentSystem: paymentSystem,
        payType: payType,
        paymentMethodId: paymentMethodId,
        amount: amount,
      );
      _emitCreated(created);
      await refresh();
      return created;
    } catch (e) {
      _setError('สร้าง Payment draft ไม่สำเร็จ: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// โหลด Payment detail (delegate ไป detail service)
  Future<PaymentDetail?> loadDetail(String uuid) async {
    try {
      return await _detailService.fetchPaymentDetail(uuid: uuid);
    } catch (e) {
      _setError('โหลดรายการ Payment ไม่สำเร็จ: $e');
      return null;
    }
  }

  /// โหลด Payment receipt (delegate ไป detail service)
  Future<PaymentReceipt?> loadReceipt(String uuid) async {
    try {
      return await _detailService.fetchReceipt(uuid: uuid);
    } catch (e) {
      _setError('โหลดใบเสร็จไม่สำเร็จ: $e');
      return null;
    }
  }

  /// บันทึกการรับชำระ (delegate ไป detail service)
  Future<PaymentDetail?> pay({
    required String uuid,
    required double amountReceived,
    String? receiptNo,
    String? bookNo,
    String? bookDate,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final paid = await _detailService.pay(
        uuid: uuid,
        amountReceived: amountReceived,
        receiptNo: receiptNo,
        bookNo: bookNo,
        bookDate: bookDate,
      );
      _emitPaid(paid);
      await refresh();
      return paid;
    } catch (e) {
      _setError('บันทึกการรับชำระไม่สำเร็จ: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ===============================================================
  // Search
  // ===============================================================
  void setSearch(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  Future<void> executeSearch() async {
    await refresh();
  }

  // ===============================================================
  // Zone filter (UI compat)
  // ===============================================================
  Future<void> onSubZoneChanged(String? value) async {
    if (value == null) return;
    _selectedZoneSub = value;
    _selectedZone = 'ทั้งหมด'; // reset zone เมื่อ subzone เปลี่ยน
    _selectedZoneSer = '0';

    // หา ser ของ sub_zone ที่เลือก (ใช้ filter zones)
    final sub = _subzoneModels.firstWhere(
      (s) => s.zn == value,
      orElse: () => SubZoneModel(),
    );
    _selectedZoneSubSer = (sub.ser == '0' || sub.ser == null) ? null : sub.ser;

    notifyListeners();

    // ยิง API payments ใหม่ (zn = null → ทั้งหมด หลัง reset zone)
    await refresh();
  }

  Future<void> onZoneChanged(String? value) async {
    if (value == null) return;
    _selectedZone = value;
    // หา ser ของ zone ที่เลือก
    final match = _zoneModels.firstWhere(
      (z) => z.zn == value,
      orElse: () => ZoneModel(),
    );
    _selectedZoneSer = match.ser;
    notifyListeners();
    // Reload payments filter ด้วย zn
    await refresh();
  }

  /// ดรอปดาวน์ Zones: filter by sub_zone (sub_zone.ser == zone.sub_zone)
  /// หมายเหตุ: ต้องคง default "ทั้งหมด" ไว้เสมอ เพราะ onSubZoneChanged จะ reset
  /// _selectedZone = 'ทั้งหมด' หลังเปลี่ยน subzone — ถ้า filter ทิ้ง dropdown
  /// จะ assertion fail (value ไม่ match item)
  List<ZoneModel> get zoneModels {
    if (_selectedZoneSub == null || _selectedZoneSub == 'ทั้งหมด') {
      return _zoneModels;
    }
    final subSer = _selectedZoneSubSer;
    if (subSer == null || subSer.isEmpty || subSer == '0') {
      return _zoneModels;
    }
    final filtered = _zoneModels.where((z) => z.sub_zone == subSer).toList();
    // คง default "ทั้งหมด" ไว้เป็น option แรกเสมอ
    if (_zoneModels.isNotEmpty && _zoneModels.first.zn == 'ทั้งหมด') {
      return [_zoneModels.first, ...filtered];
    }
    return filtered;
  }

  /// ดรอปดาวน์ SubZones
  List<SubZoneModel> get subzoneModels => _subzoneModels;

  String? get selectedZoneSub => _selectedZoneSub;
  String? get selectedZone => _selectedZone;
  String? get selectedZoneSer => _selectedZoneSer;

  // ===============================================================
  // User actions
  // ===============================================================
  /// ผู้ใช้กดปุ่ม "ดู" ในแถว → เปิด detail page
  void onViewPayment(PaymentTask task) {
    _eventController.add(
      LicensePaymentNavigateDetailEvent(
        paymentUuid: task.uuid,
        title: 'รายละเอียดการรับชำระ',
      ),
    );
  }

  // ===============================================================
  // Backward-compat: methods used by old UI widgets
  // ===============================================================

  /// Backward-compat: list รายการ (alias for payments)
  /// UI เก่าเรียก vm.requests — เลย map เป็น List<dynamic> ให้
  List<dynamic> get requests => _payments;

  /// Backward-compat: alias for onViewPayment (UI เก่า)
  /// ใช้ dynamic เพราะ UI ส่ง PaymentTask หรือ type อื่น
  void onViewRequest(dynamic model) {
    if (model is PaymentTask) {
      onViewPayment(model);
    }
  }

  /// โหลดหน้าถัดไป/ก่อนหน้า จาก Laravel links.next / links.prev
  Future<void> loadPage(String? url) async {
    if (url == null || url.isEmpty) return;
    _setLoading(true);
    _clearError();
    try {
      final zserRaw = _selectedZoneSer;
      final zserFilter = (zserRaw == null ||
              zserRaw.isEmpty ||
              zserRaw == '0' ||
              zserRaw == 'ทั้งหมด')
          ? null
          : zserRaw;
      final subzoneserRaw = _selectedZoneSubSer;
      final subzoneserFilter =
          (subzoneserRaw == null || subzoneserRaw.isEmpty)
              ? null
              : subzoneserRaw;
      final res = await _paymentService.listPaymentTasks(
        urlCustom: url,
        q: _searchQuery.isNotEmpty ? _searchQuery : null,
        customer: _searchCustomer.isNotEmpty ? _searchCustomer : null,
        statuses: _statusesFilter,
        includeDone: _includeDone,
        perPage: 50,
        zser: zserFilter,
        subzoneser: subzoneserFilter,
      );
      _payments = res.data;
      _currentPage = res.currentPage;
      _lastPage = res.lastPage;
      _total = res.total;
      _linksNext = res.linksNext;
      _linksPrev = res.linksPrev;
    } catch (e) {
      _setError('โหลดหน้าถัดไปไม่สำเร็จ: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ===============================================================
  // Helpers
  // ===============================================================
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _emitCreated(PaymentDetail payment) {
    _eventController.add(LicensePaymentCreatedEvent(payment));
  }

  void _emitPaid(PaymentDetail payment) {
    _eventController.add(LicensePaymentPaidEvent(payment));
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
