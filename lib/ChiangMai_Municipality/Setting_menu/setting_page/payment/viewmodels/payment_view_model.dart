// ============================================================================
// payment_view_model.dart
// ============================================================================
// ViewModel — จัดการ state + business logic ของหน้า "การรับชำระ"
// - เรียก Service โหลด payments / paytypes / banks / banktypes / rentals
// - แจ้ง View ผ่าน Stream<PaymentEvent>
// - mounted-check + Future<void> + single notifyListeners
// ============================================================================

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/payment_bank_model.dart';
import '../models/payment_banktype_model.dart';
import '../models/payment_config.dart';
import '../models/payment_event.dart';
import '../models/payment_paytype_model.dart';
import '../models/payment_payment_model.dart';
import '../models/payment_rental_model.dart';
import '../services/payment_service.dart';

class PaymentViewModel extends ChangeNotifier {
  PaymentViewModel({
    required PaymentConfig config,
    PaymentService? service,
  })  : _config = config,
        _service = service ?? PaymentService() {
    _bootstrap();
  }

  final PaymentConfig _config;
  final PaymentService _service;

  // ---------- Event channel ----------
  final StreamController<PaymentEvent> _eventController =
      StreamController<PaymentEvent>.broadcast();
  Stream<PaymentEvent> get events => _eventController.stream;

  // ---------- Data ----------
  List<PaymentPaymentModel> _payments = [];
  List<PaymentPaymentModel> get payments => _payments;

  List<PaymentPaymentModel> _filtered = [];
  List<PaymentPaymentModel> get filtered => _filtered;

  List<PaymentPayTypeModel> _payTypes = [];
  List<PaymentPayTypeModel> get payTypes => _payTypes;

  List<PaymentBankModel> _banks = [];
  List<PaymentBankModel> get banks => _banks;

  List<PaymentBankTypeModel> _bankTypes = [];
  List<PaymentBankTypeModel> get bankTypes => _bankTypes;

  List<PaymentRentalModel> _rentals = [];
  List<PaymentRentalModel> get rentals => _rentals;

  // ---------- Rental ----------
  String? _rser;
  String? get rser => _rser;
  String? _foder;
  String? get foder => _foder;

  // ---------- UI state ----------
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _sortColumn = 'sw';
  bool _sortAscending = true;
  String get sortColumn => _sortColumn;
  bool get sortAscending => _sortAscending;

  // ---------- Config getters ----------
  String get title => _config.title;
  bool get readOnly => _config.readOnly;

  // ===============================================================
  // Init
  // ===============================================================
  Future<void> _bootstrap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _rser = prefs.getString('renTalSer') ?? '';
    } catch (e) {
      debugPrint('PaymentViewModel._bootstrap prefs error: $e');
    }
    // โหลด rentals + payTypes + bankTypes ก่อน (สำหรับ dialog)
    await Future.wait([
      _loadRentals(),
      _loadPayTypes(),
      _loadBanks(),
      _loadBankTypes(),
    ]);
    // ใช้ foder จาก rental ตัวแรก (ถ้ามี)
    if (_rentals.isNotEmpty) {
      _foder = _rentals.first.foder;
    }
    notifyListeners();
    await _loadPayments();
  }

  // ===============================================================
  // Loaders
  // ===============================================================
  Future<void> _loadPayments() async {
    if ((_rser ?? '').isEmpty) return;
    _isLoading = true;
    notifyListeners();
    final list = await _service.fetchPayments(_rser!);
    _payments = list;
    _applyFilter();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadPayTypes() async {
    if ((_rser ?? '').isEmpty) return;
    final list = await _service.fetchPayTypes(_rser!);
    _payTypes = list;
  }

  Future<void> _loadBanks() async {
    if ((_rser ?? '').isEmpty) return;
    final list = await _service.fetchBanks(_rser!);
    _banks = list;
  }

  Future<void> _loadBankTypes() async {
    if ((_rser ?? '').isEmpty) return;
    final list = await _service.fetchBankTypes(_rser!);
    _bankTypes = list;
  }

  Future<void> _loadRentals() async {
    if ((_rser ?? '').isEmpty) return;
    final list = await _service.fetchRentals(_rser!);
    _rentals = list;
  }

  /// Public refresh
  Future<void> refresh() => _loadPayments();

  // ===============================================================
  // Search
  // ===============================================================
  void setSearch(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void executeSearch() {
    _applyFilter();
    notifyListeners();
  }

  // ===============================================================
  // Sort
  // ===============================================================
  void onSort(String column) {
    if (_sortColumn == column) {
      _sortAscending = !_sortAscending;
    } else {
      _sortColumn = column;
      _sortAscending = true;
    }
    _applyFilter();
    notifyListeners();
  }

  // ===============================================================
  // CRUD: Payment
  // ===============================================================
  Future<bool> addPayment({
    required String ln,
    required String sn,
    required String sname,
    required String sw,
    required String zone,
    required String typeId,
    required String bankId,
    required String bankTypeId,
  }) async {
    if ((_rser ?? '').isEmpty) {
      _emit(const PaymentErrorEvent('ไม่พบ rser'));
      return false;
    }
    final ok = await _service.addPayment(
      rser: _rser!,
      ln: ln,
      sn: sn,
      sname: sname,
      sw: sw,
      zone: zone,
      typeId: typeId,
      bankId: bankId,
      bankTypeId: bankTypeId,
    );
    if (ok) {
      _emit(const PaymentSuccessEvent('เพิ่ม Payment สำเร็จ'));
      await _loadPayments();
    } else {
      _emit(const PaymentErrorEvent('เพิ่ม Payment ล้มเหลว'));
    }
    return ok;
  }

  Future<bool> updatePayment({
    required String ser,
    required String ln,
    required String sn,
    required String sname,
    required String sw,
    required String zone,
    required String typeId,
    required String bankId,
    required String bankTypeId,
  }) async {
    if ((_rser ?? '').isEmpty) {
      _emit(const PaymentErrorEvent('ไม่พบ rser'));
      return false;
    }
    final ok = await _service.updatePayment(
      rser: _rser!,
      ser: ser,
      ln: ln,
      sn: sn,
      sname: sname,
      sw: sw,
      zone: zone,
      typeId: typeId,
      bankId: bankId,
      bankTypeId: bankTypeId,
    );
    if (ok) {
      _emit(const PaymentSuccessEvent('แก้ไข Payment สำเร็จ'));
      await _loadPayments();
    } else {
      _emit(const PaymentErrorEvent('แก้ไข Payment ล้มเหลว'));
    }
    return ok;
  }

  Future<bool> deletePayment(String ser) async {
    if ((_rser ?? '').isEmpty) {
      _emit(const PaymentErrorEvent('ไม่พบ rser'));
      return false;
    }
    final ok = await _service.deletePayment(rser: _rser!, ser: ser);
    if (ok) {
      _emit(const PaymentSuccessEvent('ลบ Payment สำเร็จ'));
      await _loadPayments();
    } else {
      _emit(const PaymentErrorEvent('ลบ Payment ล้มเหลว'));
    }
    return ok;
  }

  // ===============================================================
  // CRUD: PayType
  // ===============================================================
  Future<bool> addPayType({required String tn, String? desc}) async {
    if ((_rser ?? '').isEmpty) {
      _emit(const PaymentErrorEvent('ไม่พบ rser'));
      return false;
    }
    final ok = await _service.addPayType(rser: _rser!, tn: tn, desc: desc);
    if (ok) {
      _emit(const PaymentSuccessEvent('เพิ่ม PayType สำเร็จ'));
      await _loadPayTypes();
      notifyListeners();
    } else {
      _emit(const PaymentErrorEvent('เพิ่ม PayType ล้มเหลว'));
    }
    return ok;
  }

  // ===============================================================
  // CRUD: Bank
  // ===============================================================
  Future<bool> addBank({
    required String bcode,
    required String bname,
    required String btype,
  }) async {
    if ((_rser ?? '').isEmpty) {
      _emit(const PaymentErrorEvent('ไม่พบ rser'));
      return false;
    }
    final ok = await _service.addBank(
      rser: _rser!,
      bcode: bcode,
      bname: bname,
      btype: btype,
    );
    if (ok) {
      _emit(const PaymentSuccessEvent('เพิ่ม Bank สำเร็จ'));
      await _loadBanks();
      notifyListeners();
    } else {
      _emit(const PaymentErrorEvent('เพิ่ม Bank ล้มเหลว'));
    }
    return ok;
  }

  // ===============================================================
  // CRUD: BankType
  // ===============================================================
  Future<bool> addBankType({required String btype}) async {
    if ((_rser ?? '').isEmpty) {
      _emit(const PaymentErrorEvent('ไม่พบ rser'));
      return false;
    }
    final ok = await _service.addBankType(rser: _rser!, btype: btype);
    if (ok) {
      _emit(const PaymentSuccessEvent('เพิ่ม BankType สำเร็จ'));
      await _loadBankTypes();
      notifyListeners();
    } else {
      _emit(const PaymentErrorEvent('เพิ่ม BankType ล้มเหลว'));
    }
    return ok;
  }

  // ===============================================================
  // Slip
  // ===============================================================
  Future<bool> uploadSlip({
    required String ser,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    if ((_rser ?? '').isEmpty) {
      _emit(const PaymentErrorEvent('ไม่พบ rser'));
      return false;
    }
    final ok = await _service.uploadSlip(
      rser: _rser!,
      ser: ser,
      fileBytes: fileBytes,
      fileName: fileName,
    );
    if (ok) {
      _emit(const PaymentSuccessEvent('อัปโหลดสลิปสำเร็จ'));
      await _loadPayments();
    } else {
      _emit(const PaymentErrorEvent('อัปโหลดสลิปล้มเหลว'));
    }
    return ok;
  }

  Future<bool> deleteSlip({
    required String ser,
    required String fileName,
  }) async {
    if ((_rser ?? '').isEmpty) {
      _emit(const PaymentErrorEvent('ไม่พบ rser'));
      return false;
    }
    final ok = await _service.deleteSlip(
      rser: _rser!,
      ser: ser,
      fileName: fileName,
      foder: _foder ?? '',
      pathFoder: 'slip',
    );
    if (ok) {
      _emit(const PaymentSuccessEvent('ลบสลิปสำเร็จ'));
      await _loadPayments();
    } else {
      _emit(const PaymentErrorEvent('ลบสลิปล้มเหลว'));
    }
    return ok;
  }

  // ===============================================================
  // UI actions
  // ===============================================================
  void onAdd() => _emit(const PaymentOpenAddEvent());
  void onEdit(String ser) => _emit(PaymentOpenEditEvent(ser));
  void onSlip(String ser) => _emit(PaymentOpenSlipEvent(ser));
  void onAddPayType() => _emit(const PaymentOpenAddPayTypeEvent());
  void onAddBank() => _emit(const PaymentOpenAddBankEvent());
  void onAddBankType() => _emit(const PaymentOpenAddBankTypeEvent());

  // ===============================================================
  // Helpers
  // ===============================================================
  void _emit(PaymentEvent e) {
    if (_eventController.isClosed) return;
    _eventController.add(e);
  }

  void _applyFilter() {
    final q = _searchQuery.trim().toLowerCase();
    Iterable<PaymentPaymentModel> list = _payments;
    if (q.isNotEmpty) {
      list = list.where((p) {
        return p.ln.toLowerCase().contains(q) ||
            p.sname.toLowerCase().contains(q) ||
            p.sn.toLowerCase().contains(q) ||
            p.bankName.toLowerCase().contains(q) ||
            p.bankCode.toLowerCase().contains(q) ||
            p.typeName.toLowerCase().contains(q);
      });
    }
    final arr = list.toList();
    arr.sort((a, b) {
      final av = _valueForSort(a, _sortColumn);
      final bv = _valueForSort(b, _sortColumn);
      final cmp = av.compareTo(bv);
      return _sortAscending ? cmp : -cmp;
    });
    _filtered = arr;
  }

  String _valueForSort(PaymentPaymentModel p, String col) {
    switch (col) {
      case 'ln':
        return p.ln.toLowerCase();
      case 'sn':
        return p.sn.toLowerCase();
      case 'sname':
        return p.sname.toLowerCase();
      case 'sw':
        return p.sw.padLeft(5, '0');
      case 'bank':
        return p.bankName.toLowerCase();
      case 'type':
        return p.typeName.toLowerCase();
      default:
        return p.sw.padLeft(5, '0');
    }
  }

  // ===============================================================
  // Lifecycle
  // ===============================================================
  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
