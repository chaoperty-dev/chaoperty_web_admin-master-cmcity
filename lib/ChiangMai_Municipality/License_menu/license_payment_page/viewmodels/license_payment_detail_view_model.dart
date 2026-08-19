// ============================================================================
// license_payment_detail_view_model.dart
// ============================================================================
// ViewModel — step state + โหลด PaymentDetail ตาม uuid
// - ใช้แยกจาก LicensePaymentViewModel เพื่อให้เปิดเป็น full-page route ได้
//   โดยไม่ผูกกับ list page
// ============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/license_payment_detail_model.dart';
import '../models/license_payment_event.dart';
import '../models/license_prepayment_model.dart';
import '../services/license_payment_detail_service.dart';

class LicensePaymentDetailViewModel extends ChangeNotifier {
  /// Step ของหน้า detail:
  ///   1 = ตรวจสอบรายการ (Step 1)
  ///   2 = บันทึกการรับชำระ (Step 2)
  static const int detailTotalSteps = 2;

  LicensePaymentDetailViewModel({
    String? uuid,
    LicensePaymentDetailService? service,
  })  : _uuid = uuid,
        _service = service ?? LicensePaymentDetailService() {
    if (_uuid != null && _uuid!.isNotEmpty) {
      _loadDetail(_uuid!);
    }
  }

  final String? _uuid;
  final LicensePaymentDetailService _service;

  // ---------- Detail data ----------
  PaymentDetail? _detail;
  PaymentDetail? get detail => _detail;

  // ---------- Prepayment (การจ่ายล่วงหน้า) ----------
  PrepaymentData? _prepayment;
  PrepaymentData? get prepayment => _prepayment;
  bool get isPrepaymentLoading => _isPrepaymentLoading;
  bool _isPrepaymentLoading = false;

  // ---------- Step state ----------
  int _currentDetailStep = 1;
  int get currentDetailStep => _currentDetailStep;
  int get totalDetailSteps => detailTotalSteps;

  // ---------- Loading / error ----------
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ---------- Events ----------
  final StreamController<LicensePaymentEvent> _eventController =
      StreamController<LicensePaymentEvent>.broadcast();
  Stream<LicensePaymentEvent> get events => _eventController.stream;

  // ===============================================================
  // Step navigation
  // ===============================================================
  void nextDetailStep() {
    if (_currentDetailStep < detailTotalSteps) {
      _currentDetailStep += 1;
      notifyListeners();
    }
  }

  void previousDetailStep() {
    if (_currentDetailStep > 1) {
      _currentDetailStep -= 1;
      notifyListeners();
    }
  }

  // ===============================================================
  // Detail loading
  // ===============================================================
  Future<void> _loadDetail(String uuid) async {
    print('[LicensePaymentDetailViewModel] _loadDetail uuid=$uuid');
    _setLoading(true);
    _clearError();
    try {
      final results = await Future.wait<dynamic>([
        _service.fetchPaymentDetail(uuid: uuid),
        _service.fetchPrepayment(uuid: uuid),
      ]);
      _detail = results[0] as PaymentDetail?;
      _prepayment = results[1] as PrepaymentData?;
      print('[LicensePaymentDetailViewModel] loaded detail=${_detail?.uuid} status=${_detail?.status} prepaymentItems=${_prepayment?.details.length}');
    } catch (e) {
      print('[LicensePaymentDetailViewModel][ERROR] $e');
      _setError('โหลดรายการรับชำระไม่สำเร็จ: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ---------- สร้างรายการรับชำระ (Draft) ----------
  Future<PaymentDetail?> createPayment({
    required String debtLineUuid,
    required String payType,
    required double amount,
    String paymentSystem = 'external',
    int? paymentMethodId,
  }) async {
    if (_uuid == null || _uuid!.isEmpty) {
      _setError('ไม่พบ request_uuid สำหรับสร้างรายการรับชำระ');
      return null;
    }
    _isPrepaymentLoading = true;
    notifyListeners();
    try {
      final created = await _service.createPayment(
        requestUuid: _uuid!,
        debtLineUuid: debtLineUuid,
        payType: payType,
        amount: amount,
        paymentSystem: paymentSystem,
        paymentMethodId: paymentMethodId,
      );
      _eventController.add(LicensePaymentCreatedEvent(created));
      return created;
    } catch (e) {
      print('[LicensePaymentDetailViewModel][createPayment ERROR] $e');
      _setError('สร้างรายการรับชำระไม่สำเร็จ: $e');
      return null;
    } finally {
      _isPrepaymentLoading = false;
      notifyListeners();
    }
  }

  /// เรียกใช้จาก UI เมื่อต้องการ reload (pull-to-refresh)
  Future<void> reload() async {
    if (_uuid == null || _uuid!.isEmpty) return;
    await _loadDetail(_uuid!);
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
    _eventController.add(LicensePaymentErrorEvent(msg));
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}