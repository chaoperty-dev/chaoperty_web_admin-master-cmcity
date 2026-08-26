// ============================================================================
// license_payment_detail_view_model.dart
// ============================================================================
// ViewModel — step state + โหลด PaymentDetail ตาม uuid
// - ใช้แยกจาก LicensePaymentViewModel เพื่อให้เปิดเป็น full-page route ได้
//   โดยไม่ผูกกับ list page
// ============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/license_payment_attachment.dart';
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
  String? get requestUuid => _uuid;
  final LicensePaymentDetailService _service;

  // ---------- Detail data ----------
  PaymentDetail? _detail;
  PaymentDetail? get detail => _detail;

  // ---------- Prepayment (การจ่ายล่วงหน้า) ----------
  PrepaymentData? _prepayment;
  PrepaymentData? get prepayment => _prepayment;
  bool get isPrepaymentLoading => _isPrepaymentLoading;
  bool _isPrepaymentLoading = false;

  // ---------- รายการชำระ / สถานะ (GET .../payments) ----------
  RequestPaymentsResponse? _payments;
  RequestPaymentsResponse? get payments => _payments;

  // ---------- ประวัติ (GET /v2/payments/{uuid}/history) ----------
  PaymentHistoryListResponse? _history;
  PaymentHistoryListResponse? get history => _history;
  bool _isHistoryLoading = false;
  bool get isHistoryLoading => _isHistoryLoading;
  String? _historyError;
  String? get historyError => _historyError;

  // ---------- Activity log (GET /v2/payments/{uuid}/activity) ----------
  PaymentActivityListResponse? _activity;
  PaymentActivityListResponse? get activity => _activity;
  bool _isActivityLoading = false;
  bool get isActivityLoading => _isActivityLoading;
  String? _activityError;
  String? get activityError => _activityError;

  // ---------- Receipt (GET /v2/payments/{uuid}/receipt) ----------
  PaymentReceipt? _receipt;
  PaymentReceipt? get receipt => _receipt;
  bool _isReceiptLoading = false;
  bool get isReceiptLoading => _isReceiptLoading;
  String? _receiptError;
  String? get receiptError => _receiptError;
  String? _receiptUuid;
  String? get receiptUuid => _receiptUuid;

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
        _service.fetchRequestPayments(uuid: uuid),
      ]);
      _detail = results[0] as PaymentDetail?;
      _prepayment = results[1] as PrepaymentData?;
      _payments = results[2] as RequestPaymentsResponse?;
      print('[LicensePaymentDetailViewModel] loaded detail=${_detail?.uuid} status=${_detail?.status} prepaymentItems=${_prepayment?.details.length} payments=${_payments?.data.length}');
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

  /// หารายการชำระที่ผูกกับ debt_line_uuid นี้ (ถ้ามี)
  PaymentDetail? findPaymentByLine(String debtLineUuid) {
    if (debtLineUuid.isEmpty) return null;
    final list = _payments?.data ?? [];
    for (final p in list) {
      if (p.debtLineUuid == debtLineUuid) return p;
    }
    return null;
  }

  /// กดปุ่มรายการจ่ายล่วงหน้า → สร้าง draft (ถ้ายังไม่มี) แล้วไป Step 2
  ///
  /// ใช้กรณี "มีรายการชำระอยู่แล้ว" (ต้องทำรายการต่อ) — ไม่สร้า�ใหม่
  Future<void> proceedToPayment(PrepaymentItem item) async {
    if (_uuid == null || _uuid!.isEmpty) {
      _setError('ไม่พบ request_uuid �ำหรับสร้างรายการรับ�ำระ');
      return;
    }
    nextDetailStep();
  }

  /// เริ่มรายการใหม่ (ยังไม่ทำรายการ) — สร้าง draft เท่านั้น ไม่ navigate
  ///
  /// คืน PaymentDetail ที่สร้าง (หรือ null ถ้ามีอยู่แล้ว/ล้มเหลว)
  Future<PaymentDetail?> startPayment(
    PrepaymentItem item, {
    String paymentSystem = 'external',
    int? paymentMethodId,
  }) async {
    if (_uuid == null || _uuid!.isEmpty) {
      _setError('ไม่พบ request_uuid �ำหรับสร้างรายการรับชำระ');
      return null;
    }
    if (paymentSystem == 'internal' && paymentMethodId == null) {
      _setError('กรุณาเลือกบัญชี/ช่องทางรับ�ำระ');
      return null;
    }
    final existing = findPaymentByLine(item.uuid);
    if (existing != null) return existing;
    return await createPayment(
      debtLineUuid: item.uuid,
      payType: payTypeOf(item),
      amount: item.totalAmount,
      paymentSystem: paymentSystem,
      paymentMethodId: paymentMethodId,
    );
  }

  /// บันทึกการรับชำระ (POST /v2/payments/{uuid}/pay)
  /// paymentSystem:
  ///   - 'internal' → ส่งเฉพาะ amount_received
  ///   - 'external' → ส่ง amount_received + receipt_no + book_no + book_date
  /// คืน PaymentDetail ที่อัปเดตสถานะแล้ว
  Future<PaymentDetail?> payPayment({
    required String paymentUuid,
    required double amountReceived,
    String paymentSystem = 'external',
    String? receiptNo,
    String? bookNo,
    String? bookDate,
  }) async {
    if (paymentUuid.isEmpty) {
      _setError('ไม่พบ payment uuid');
      return null;
    }
    _isPrepaymentLoading = true;
    notifyListeners();
    try {
      final updated = await _service.pay(
        uuid: paymentUuid,
        amountReceived: amountReceived,
        paymentSystem: paymentSystem,
        receiptNo: receiptNo,
        bookNo: bookNo,
        bookDate: bookDate,
      );
      // reload เพื่ออัปเดต payments / statuses
      await reload();
      _eventController.add(LicensePaymentPaidEvent(updated));
      return updated;
    } catch (e) {
      print('[LicensePaymentDetailViewModel][payPayment ERROR] $e');
      _setError('บันทึกการรับชำระไม่สำเร็จ: $e');
      return null;
    } finally {
      _isPrepaymentLoading = false;
      notifyListeners();
    }
  }

  /// อนุมาน pay_type — server ใช้ etype/dtype เป็นสัญญาณหลัก (fallback = fee)
  /// ตรวจหลายช่องทาง: etype/dtype + expname (กรณี server ไม่ใส่ code)
  /// DEBUG: log ให้เห็นค่าก่อนตัดสินใจ
  /// DEBUG: log ให้เ�็นค่าก่อนตัดสินใจ
  String payTypeOf(PrepaymentItem item) {
    final et = (item.etype ?? '').toLowerCase();
    final dt = (item.dtype ?? '').toLowerCase();
    final name = (item.expname ?? '').toLowerCase();
    // ─── ตรวจ 'fine' หลายช่องทาง ───
    // 1) etype/dtype ตรงๆ: 'fine' / 'ko' / 'f' (short code)
    // 2) expname มีคำว่า 'ค่าปรับ' / 'fine' / 'penal'
    final isFine = et == 'fine' ||
        dt == 'fine' ||
        et == 'ko' ||
        dt == 'ko' ||
        (et.length == 1 && et == 'f') ||
        (dt.length == 1 && dt == 'f') ||
        et.contains('fine') ||
        dt.contains('fine') ||
        name.contains('ค่าปรับ') ||
        name.contains('fine') ||
        name.contains('penal');
    final pick = isFine ? 'fine' : 'fee';
    print('[DEBUG pay_type] expname=|${item.expname}| etype=|${item.etype}| dtype=|${item.dtype}| pick=$pick');
    return pick;
  }

  /// เรียกใช้จาก UI เมื่อต้องการ reload (pull-to-refresh)
  Future<void> reload() async {
    if (_uuid == null || _uuid!.isEmpty) return;
    await _loadDetail(_uuid!);
  }

  // ===============================================================
  // History + Activity
  // ===============================================================

  /// โหลดประวัติ (GET /v2/payments/{uuid}/history)
  /// uuidOverride: ถ้าระบุ จะใช้แทน _uuid (รองรับ paymentUuid ที่ต่างจาก requestUuid)
  Future<void> loadHistory({String? uuidOverride}) async {
    final uuid = (uuidOverride ?? _uuid ?? '').trim();
    if (uuid.isEmpty) return;
    _isHistoryLoading = true;
    _historyError = null;
    notifyListeners();
    try {
      _history = await _service.fetchPaymentHistory(uuid: uuid);
    } catch (e) {
      print('[LicensePaymentDetailViewModel][loadHistory ERROR] $e');
      _historyError = '$e';
    } finally {
      _isHistoryLoading = false;
      notifyListeners();
    }
  }

  /// โหลด activity log (GET /v2/payments/{uuid}/activity)
  Future<void> loadActivity({String? uuidOverride}) async {
    final uuid = (uuidOverride ?? _uuid ?? '').trim();
    if (uuid.isEmpty) return;
    _isActivityLoading = true;
    _activityError = null;
    notifyListeners();
    try {
      _activity = await _service.fetchPaymentActivity(uuid: uuid);
    } catch (e) {
      print('[LicensePaymentDetailViewModel][loadActivity ERROR] $e');
      _activityError = '$e';
    } finally {
      _isActivityLoading = false;
      notifyListeners();
    }
  }

  /// โหลดทั้ง history + activity พร้อมกัน (ใช้ตอนเปิดหน้า history)
  Future<void> loadHistoryAndActivity({String? uuidOverride}) async {
    final uuid = (uuidOverride ?? _uuid ?? '').trim();
    if (uuid.isEmpty) return;
    await Future.wait([
      loadHistory(uuidOverride: uuid),
      loadActivity(uuidOverride: uuid),
    ]);
  }

  /// โหลดใบเสร็จ (GET /v2/payments/{uuid}/receipt)
  /// uuid คือ payment uuid (ไม่ใช่ request uuid)
  /// เก็บ _receiptUuid ไว้ใช้ตอน gotoReceipt / reload
  Future<void> loadReceipt({String? uuid}) async {
    final payUuid = (uuid ?? '').trim();
    if (payUuid.isEmpty) {
      _setError('ไม่พบ payment uuid สำหรับโหลดใบเสร็จ');
      return;
    }
    _receiptUuid = payUuid;
    _isReceiptLoading = true;
    _receiptError = null;
    notifyListeners();
    try {
      _receipt = await _service.fetchReceipt(uuid: payUuid);
    } catch (e) {
      print('[LicensePaymentDetailViewModel][loadReceipt ERROR] $e');
      _receiptError = '$e';
    } finally {
      _isReceiptLoading = false;
      notifyListeners();
    }
  }

  /// กดปุ่ม "ดูใบเสร็จ" → โหลดใบเสร็จ + ไป Step 2
  Future<void> gotoReceipt(String paymentUuid) async {
    if (paymentUuid.trim().isEmpty) return;
    await loadReceipt(uuid: paymentUuid);
    nextDetailStep();
  }

  /// อัปโหลดไฟล์แนบ (รูปสลิป) — POST /v2/payments/{uuid}/attachments
  /// คืน PaymentAttachment? (หรือ null ถ้าล้มเหลว)
  Future<PaymentAttachment?> uploadAttachment({
    required String uuid,
    required String filePath,
  }) async {
    if (uuid.isEmpty) {
      _setError('ไม่พบ payment uuid สำหรับอัปโหลดไฟล์แนบ');
      return null;
    }
    try {
      return await _service.uploadPaymentAttachment(
        uuid: uuid,
        filePath: filePath,
      );
    } catch (e) {
      print('[LicensePaymentDetailViewModel][uploadAttachment ERROR] $e');
      _setError('อัปโหลดไฟล์แนบไม่สำเร็จ: $e');
      return null;
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