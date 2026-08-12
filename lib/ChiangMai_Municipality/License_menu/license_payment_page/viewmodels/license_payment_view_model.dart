// ============================================================================
// license_payment_view_model.dart
// ============================================================================
// ViewModel — จัดการ state + business logic ของหน้า "การรับชำระ" (Payment v2)
// - โหลด PaymentDetail list + สร้าง draft + บันทึกการรับชำระ
// - โหลด Zones/SubZones (ใช้ LicenseRequestService เดียวกัน)
// - แจ้ง View ผ่าน Stream<LicensePaymentEvent>
// - ไม่ผูกกับ Flutter UI
// ============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../Model/GetSubZone_Model.dart';
import '../../../../Model/GetZone_Model.dart';
import '../models/license_payment_detail_model.dart';
import '../models/license_payment_config.dart';
import '../models/license_payment_event.dart';
import '../services/license_payment_detail_service.dart';
import '../services/license_payment_service.dart';
import '../../license_request_page/services/license_request_service.dart';

class LicensePaymentViewModel extends ChangeNotifier {
  LicensePaymentViewModel({
    required LicensePaymentConfig config,
    LicensePaymentService? paymentService,
    LicensePaymentDetailService? detailService,
    LicenseRequestService? requestService,
  })  : _config = config,
        _paymentService = paymentService ?? LicensePaymentService(),
        _detailService = detailService ?? LicensePaymentDetailService(),
        _requestService = requestService ?? LicenseRequestService() {
    _loadInitial();
  }

  final LicensePaymentConfig _config;
  final LicensePaymentService _paymentService;
  final LicensePaymentDetailService _detailService;
  final LicenseRequestService _requestService;

  // ---------- Event channel ----------
  final StreamController<LicensePaymentEvent> _eventController =
      StreamController<LicensePaymentEvent>.broadcast();
  Stream<LicensePaymentEvent> get events => _eventController.stream;

  // ---------- Data ----------
  List<PaymentDetail> _payments = [];
  List<PaymentDetail> get payments => _payments;

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
  /// โหลดรายการ "Payment" ทั้งหมด
  Future<void> refresh() async {
    _setLoading(true);
    _clearError();
    try {
      final results = await _paymentService.listPayments(
        paymentUuid: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      _payments = results;
      _currentPage = 1;
      _lastPage = 1;
      _total = results.length;
    } catch (e) {
      _setError('โหลดข้อมูลไม่สำเร็จ: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// โหลด Zones (สำหรับ dropdown filter)
  Future<void> _loadZones() async {
    try {
      _zoneModels = await _requestService.fetchZones();
    } catch (e) {
      // silent — ไม่ block UI
    }
    notifyListeners();
  }

  /// โหลด SubZones (สำหรับ dropdown filter)
  Future<void> _loadSubZones() async {
    try {
      _subzoneModels = await _requestService.fetchSubZones();
    } catch (e) {
      // silent — ไม่ block UI
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
  void onSubZoneChanged(String? value) {
    _selectedZoneSub = value;
    _selectedZone = null; // reset zone เมื่อ subzone เปลี่ยน
    _selectedZoneSer = null;
    notifyListeners();
  }

  void onZoneChanged(String? value) {
    _selectedZone = value;
    // หา ser ของ zone ที่เลือก
    if (value != null) {
      final match = _zoneModels.firstWhere(
        (z) => z.zn == value,
        orElse: () => ZoneModel(),
      );
      _selectedZoneSer = match.ser;
    } else {
      _selectedZoneSer = null;
    }
    notifyListeners();
  }

  /// ดรอปดาวน์ Zones: filter by sub_zone
  List<ZoneModel> get zoneModels {
    if (_selectedZoneSub == null || _selectedZoneSub == 'ทั้งหมด') {
      return _zoneModels;
    }
    return _zoneModels
        .where((z) => z.sub_zone == _selectedZoneSub || z.sub_zone == null)
        .toList();
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
  void onViewPayment(PaymentDetail payment) {
    _eventController.add(
      LicensePaymentNavigateDetailEvent(
        paymentUuid: payment.uuid,
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
  /// ใช้ dynamic เพราะ UI ส่ง PaymentDetail หรือ ReviewModel-like
  void onViewRequest(dynamic model) {
    if (model is PaymentDetail) {
      onViewPayment(model);
    }
  }

  /// Backward-compat: loadPage (no-op — listPayments ไม่มี pagination links)
  Future<void> loadPage(String? url) async {
    // ไม่ทำ action — listPayments API ไม่ return pagination links
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
