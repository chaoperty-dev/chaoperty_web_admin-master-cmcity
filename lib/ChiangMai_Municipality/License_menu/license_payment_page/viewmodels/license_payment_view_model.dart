// ============================================================================
// license_payment_view_model.dart
// ============================================================================
// ViewModel — จัดการ state + business logic ของหน้า "การรับชำระ" (Payment v2)
// - เรียก Service โหลด PaymentDetail (list) + createPaymentDraft
// - แจ้ง View ผ่าน Stream<LicensePaymentEvent>
// - ไม่ผูกกับ Flutter UI
// ============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/license_payment_detail_model.dart';
import '../models/license_payment_config.dart';
import '../models/license_payment_event.dart';
import '../services/license_payment_detail_service.dart';
import '../services/license_payment_service.dart';

class LicensePaymentViewModel extends ChangeNotifier {
  LicensePaymentViewModel({
    required LicensePaymentConfig config,
    LicensePaymentService? paymentService,
    LicensePaymentDetailService? detailService,
  })  : _config = config,
        _paymentService = paymentService ?? LicensePaymentService(),
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
  List<PaymentDetail> _payments = [];
  List<PaymentDetail> get payments => _payments;

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
    await refresh();
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
      // ไม่มี pagination จาก listPayments (ยังไม่ได้ implement)
      _currentPage = 1;
      _lastPage = 1;
      _total = results.length;
    } catch (e) {
      _setError('โหลดข้อมูลไม่สำเร็จ: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// สร้าง Payment Draft (Internal)
  /// Returns the new PaymentDetail on success, or null on failure
  Future<PaymentDetail?> createDraft({
    required String requestUuid,
    required String paymentSystem, // 'internal' | 'external'
    required String payType, // 'fee' | 'fine'
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
      // Reload list after create
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
      // Reload list after pay
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
  // Backward-compat: methods used by old UI widgets
  // (UI files reference 'requests', 'onViewRequest',
  //  'selectedZoneSub', 'zoneModels', 'subzoneModels',
  //  'onSubZoneChanged', 'onZoneChanged', 'loadPage')
  // ===============================================================

  /// Backward-compat: list รายการ (empty) — UI จะไม่แสดง row
  /// เพราะ viewmodel ใช้ PaymentDetail แทน ReviewModel
  /// แต่ต้องมี field นี้เพื่อให้ UI เก่า compile ได้
  List<dynamic> get requests => <dynamic>[];

  /// Backward-compat: empty list
  List<dynamic> get zoneModels => <dynamic>[];

  /// Backward-compat: empty list
  List<dynamic> get subzoneModels => <dynamic>[];

  /// Backward-compat: zone filter state (UI ใช้)
  String? get selectedZoneSub => null;
  String? get selectedZone => null;
  String? get selectedZoneSer => null;

  /// Backward-compat: no-op
  void onSubZoneChanged(String? value) {}

  /// Backward-compat: no-op
  void onZoneChanged(String? value) {}

  /// Backward-compat: เปลี่ยนจาก PaymentDetail เป็น dynamic
  /// UI เก่าใช้ model.newRequest.leaseNumber, model.client.cname
  /// แต่ PaymentDetail มี field ไม่ตรงกัน — return dynamic
  /// เพื่อให้ compile ได้
  void onViewRequest(dynamic model) {
    // ไม่ทำ action — UI เก่าใช้ ReviewModel ที่มี field ต่างจาก PaymentDetail
  }

  /// Backward-compat: ไม่มี pagination จาก listPayments
  Future<void> loadPage(String? url) async {
    // ไม่ทำ action — listPayments API ไม่ return pagination links
  }

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
