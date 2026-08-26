// ============================================================================
// license_request_detail_step1_view_model.dart
// ============================================================================
// ViewModel — จัดการ state + business logic ของหน้า "ตรวจสอบคำขอ" (Step 1)
// - เรียก Service โหลด ReviewDetail ตาม UUID
// - Map ข้อมูลลง form fields (read-only mode)
// - ไม่ผูกกับ Flutter UI โดยตรง
// ============================================================================

import 'package:flutter/material.dart';

import '../../../Model/Person&Shop_Model.dart';
import '../../../Model/ReviewUuid_Model.dart';
import '../services/license_request_detail_service.dart';

/// ViewModel — ของตัวเอง (ไม่แชร์กับ license_contract_page)
/// ใช้สำหรับ Request Detail Step 1 (read-only mode)
class LicenseRequestDetailStep1ViewModel extends ChangeNotifier {
  LicenseRequestDetailStep1ViewModel({
    LicenseRequestDetailService? service,
  }) : _service = service ?? LicenseRequestDetailService();

  final LicenseRequestDetailService _service;

  // ---------- Form state (own data) ----------
  late List<PersonFieldModel> _dataPerson;
  late List<ShopFieldModel> _dataShop;
  late List<Map<String, dynamic>> _dataCid;
  late List<TextEditingController> _controllersPerson;
  late List<TextEditingController> _controllersShop;
  late List<TextEditingController> _controllersShopSub;

  // ---------- Selections (own data) ----------
  String? _selectedZn;
  String? _selectedSubZone;
  String? _selectedLn;
  String? _selectedScname;

  // ---------- Loading state ----------
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ---------- Raw review data (สำหรับ status) ----------
  String _status = '';
  String get status => _status;

  // ---------- Public getters ----------
  List<PersonFieldModel> get dataPerson => _dataPerson;
  List<ShopFieldModel> get dataShop => _dataShop;
  List<Map<String, dynamic>> get dataCid => _dataCid;
  List<TextEditingController> get controllersPerson => _controllersPerson;
  List<TextEditingController> get controllersShop => _controllersShop;
  List<TextEditingController> get controllersShopSub => _controllersShopSub;

  String? get selectedZn => _selectedZn;
  String? get selectedSubZone => _selectedSubZone;
  String? get selectedLn => _selectedLn;
  String? get selectedScname => _selectedScname;

  // ---------- Init ----------
  LicenseRequestDetailStep1ViewModel init() {
    _dataPerson = data_persons
        .map((p) => PersonFieldModel(
              ser: p.ser,
              title: p.title,
              detail: '',
            ))
        .toList();

    _dataShop = data_shops
        .map((s) => ShopFieldModel(
              ser: s.ser,
              title: s.title,
              detail: '',
              detailsub: s.detailsub
                  .map((sub) => ShopSubField(
                        ser: sub.ser,
                        titlesub: sub.titlesub,
                        detail: '',
                      ))
                  .toList(),
            ))
        .toList();

    _dataCid = [
      {'ser': '1', 'title': 'วันที่เริ่มต้น', 'detail': ''},
      {'ser': '2', 'title': 'วันที่สิ้นสุด', 'detail': ''},
      {'ser': '3', 'title': 'ประเภทสัญญา', 'detail': ''},
      {'ser': '4', 'title': 'ระยะเวลาเช่า (เดือน)', 'detail': ''},
    ];

    _controllersPerson = List.generate(
      _dataPerson.length,
      (i) => TextEditingController(text: _dataPerson[i].detail),
    );
    _controllersShop = List.generate(
      _dataShop.length,
      (i) => TextEditingController(text: _dataShop[i].detail),
    );
    _controllersShopSub = List.generate(
      _dataShop[0].detailsub.length,
      (i) => TextEditingController(text: _dataShop[0].detailsub[i].detail),
    );
    return this;
  }

  // ===============================================================
  // Load data from API
  // ===============================================================
  Future<void> loadFromUuid(String uuid) async {
    _setLoading(true);
    _clearError();
    try {
      final reviewDetail = await _service.fetchReviewDetail(uuid: uuid);
      _applyReviewData(reviewDetail);
    } catch (e) {
      _setError('$e');
    } finally {
      _setLoading(false);
    }
  }

  // ===============================================================
  // Map ReviewDetail → form fields (pattern เดียวกับ
  // request_examiner1_cmm.dart → AddForm_requests_uuid())
  // ===============================================================
  void _applyReviewData(ReviewDetail rd) {
    final client = rd.client;
    final addr = client.json;
    final nr = rd.newRequest;

    // ─── Status (สำหรับ shared VM) ───
    _status = rd.status;

    // ─── Person fields ───
    _setPersonField('ชื่อ-นามสกุล', client.cname);
    _setPersonField('เลขบัตรประจำตัว', client.tax);
    _setPersonField('อายุ', client.age.toString());
    _setPersonField('สัญชาติ', client.national ?? '');
    _setPersonField('บ้านเลขที่', addr.number);
    _setPersonField('หมู่ที่', addr.moo);
    _setPersonField('ตรอก/ซอย', addr.soi ?? '');
    _setPersonField('ถนน', addr.road ?? '');
    _setPersonField('ตำบล/แขวง', addr.tambon);
    _setPersonField('อำเภอ/เขต', addr.amphoe);
    _setPersonField('จังหวัด', addr.province);
    _setPersonField('เบอร์โทร', client.tel);
    _setPersonField('หมายเหตุ', client.addr1);

    // ─── Shop fields ───
    _setShopField('ขนาดพื้นที่เช่า', nr.qty);
    _setShopField('ประเภทสินค้า', client.stype);
    _setShopField('ชื่อร้าน', client.scname);

    // ─── Shop sub fields (dataShop[0].detailsub) ───
    if (_dataShop.isNotEmpty && _dataShop[0].detailsub.length >= 3) {
      _setShopSubField(0, nr.subzone.toString()); // บริเวณ
      _setShopSubField(1, nr.zn); // โซน
      _setShopSubField(2, nr.ln); // ล็อกที่
    }

    // ─── CID fields ───
    _setCidField('1', nr.sdate);
    _setCidField('2', nr.ldate);
    _setCidField('3', nr.type);
    _setCidField('4', nr.leaseTermMonths.toString());

    // ─── Selected values (สำหรับ read-only display) ───
    _selectedSubZone = nr.subzone.toString();
    _selectedZn = nr.zn;
    _selectedLn = nr.ln;
    _selectedScname = client.scname;

    notifyListeners();
  }

  // ===============================================================
  // Helpers
  // ===============================================================
  void _setPersonField(String titleKeyword, String value) {
    final idx = _dataPerson.indexWhere((p) => p.title.contains(titleKeyword));
    if (idx < 0) return;
    _dataPerson[idx].detail = value;
    _controllersPerson[idx].text = value;
  }

  void _setShopField(String titleKeyword, String value) {
    final idx = _dataShop.indexWhere((s) => s.title.contains(titleKeyword));
    if (idx < 0) return;
    _dataShop[idx].detail = value;
    _controllersShop[idx].text = value;
  }

  void _setShopSubField(int index, String value) {
    if (_dataShop.isEmpty) return;
    if (index < 0 || index >= _dataShop[0].detailsub.length) return;
    _dataShop[0].detailsub[index].detail = value;
    if (index < _controllersShopSub.length) {
      _controllersShopSub[index].text = value;
    }
  }

  void _setCidField(String ser, String value) {
    final idx = _dataCid.indexWhere((c) => c['ser'].toString() == ser);
    if (idx < 0) return;
    _dataCid[idx]['detail'] = value;
  }

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

  @override
  void dispose() {
    for (final c in _controllersPerson) {
      c.dispose();
    }
    for (final c in _controllersShop) {
      c.dispose();
    }
    for (final c in _controllersShopSub) {
      c.dispose();
    }
    super.dispose();
  }
}
