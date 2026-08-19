// ============================================================================
// license_contract_view_model.dart
// ============================================================================
// ViewModel — จัดการ state + business logic ทั้งหมด
// - เรียก Service (LicenseContractService) โหลดข้อมูล
// - แจ้ง View ผ่าน Stream<LicenseContractEvent> (error / saved)
// - ไม่ผูกกับ Flutter UI โดยตรง (Navigator / SnackBar / BuildContext)
// ============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../Constant/Myconstant.dart';
import '../../../../Model/GetArea_Model.dart';
import '../../../../Model/GetZone_Model.dart';
import '../../../../Model/GetSubZone_Model.dart';
import '../../../Model/AnnouncementZone_Model.dart';
import '../../../Model/Person&Shop_Model.dart';
import '../models/billing_models.dart';
import '../models/license_contract_config.dart';
import '../models/license_contract_event.dart';
import '../models/license_contract_result.dart';
import '../services/license_contract_service.dart';

class LicenseContractViewModel extends ChangeNotifier {
  LicenseContractViewModel({
    required LicenseContractConfig config,
    LicenseContractService? service,
  })  : _config = config,
        _service = service ?? LicenseContractService() {
    _initialize();
  }

  final LicenseContractConfig _config;
  final LicenseContractService _service;

  // ---------- Event channel ----------
  final StreamController<LicenseContractEvent> _eventController =
      StreamController<LicenseContractEvent>.broadcast();
  Stream<LicenseContractEvent> get events => _eventController.stream;

  // ---------- Form state ----------
  late List<PersonFieldModel> _dataPerson;
  late List<ShopFieldModel> _dataShop;
  late List<Map<String, dynamic>> _dataCid;
  late List<TextEditingController> _controllersPerson;
  late List<TextEditingController> _controllersShop;
  late List<TextEditingController> _controllersShopSub;

  // ---------- Selection ----------
  String? _selectedZn;
  String? _selectedSubZone;
  String? _selectedLn;
  String? _selectedZser;
  String? _selectedAser;
  String? _selectedScname;

  // ---------- Client (ลูกค้าที่เลือกจาก CustomerPickerDialog) ----------
  String? _clientUuid;

  // ---------- Billing rows (จาก BillingViewModel ผ่าน onRowsChanged callback) ----------
  final List<LcExpTransModel> _billingRows = [];

  // ---------- Data from service ----------
  List<ZoneModel> _zoneModels = [];
  List<SubZoneModel> _subzoneModels = [];
  List<AreaModel> _zoneAreas = []; // ทุกล็อกทั้งหมด (รวมที่มี/ไม่มีคนเช่า)

  // ---------- Announcement ----------
  AnnouncementZone? _announcementZone;
  String? _announcementMessage;

  // ---------- Public getters ----------
  bool get readOnly => _config.readOnly;
  String get title => _config.title;
  String? get announcementMessage =>
      _announcementMessage ?? _config.announcementMessage;
  String? get announcementUuid => _announcementZone?.uuid;
  String? get computedStatus => _announcementZone?.computedStatus;
  String? get cDateStart => _announcementZone?.cDateStart;
  String? get cDateEnd => _announcementZone?.cDateEnd;

  // ---------- Page (Step) ----------
  int _currentPage = 1; // 1 = form, 2 = placeholder
  int get currentPage => _currentPage;
  int get totalPages => 2;

  void goToPage(int page) {
    if (page < 1 || page > 2) return;
    _currentPage = page;
    notifyListeners();
  }

  void nextPage() {
    if (_currentPage < 2) {
      _currentPage += 1;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      _currentPage -= 1;
      notifyListeners();
    }
  }

  /// ตรวจ form ก่อนไป step 2 (ไม่บันทึก — แค่ validate)
  bool validateForNext() {
    if (_dataPerson[0].detail.trim().isEmpty) {
      _emitError('กรุณากรอกชื่อ-นามสกุล');
      return false;
    }
    if (_selectedZn == null || _selectedZn!.isEmpty) {
      _emitError('กรุณาเลือกโซน');
      return false;
    }
    if (_selectedLn == null || _selectedLn!.isEmpty) {
      _emitError('กรุณาเลือกรหัสพื้นที่');
      return false;
    }
    return true;
  }

  List<PersonFieldModel> get dataPerson => _dataPerson;
  List<ShopFieldModel> get dataShop => _dataShop;
  List<Map<String, dynamic>> get dataCid => _dataCid;
  List<TextEditingController> get controllersPerson => _controllersPerson;
  List<TextEditingController> get controllersShop => _controllersShop;
  List<TextEditingController> get controllersShopSub => _controllersShopSub;

  String? get selectedZn => _selectedZn;
  String? get selectedSubZone => _selectedSubZone;
  String? get selectedLn => _selectedLn;
  String? get selectedZser => _selectedZser;
  String? get selectedAser => _selectedAser;
  String? get selectedScname => _selectedScname;
  String? get clientUuid => _clientUuid;
  List<LcExpTransModel> get billingRows => List.unmodifiable(_billingRows);

  // ─── Billing (สำหรับ BillingTable ใน Step 2) ───
  String get cidSdate {
    if (_dataCid.isNotEmpty) {
      return (_dataCid[0]['detail'] ?? '').toString();
    }
    return '';
  }

  String get cidLdate {
    if (_dataCid.length > 1) {
      return (_dataCid[1]['detail'] ?? '').toString();
    }
    return '';
  }

  String get cidZser => '0';

  List<String> get zoneOptions => _zoneModels
      .map((z) => z.zn ?? '')
      .where((zn) => zn.trim().isNotEmpty)
      .toList();

  List<String> get subZoneOptions => _subzoneModels
      .map((s) => s.zn ?? '')
      .where((zn) => zn.trim().isNotEmpty)
      .toList();

  List<AreaModel> get filteredAreas {
    if (_selectedZn == null) return _zoneAreas;
    final zser = _getZoneSer(_selectedZn);
    return _zoneAreas.where((a) => (a.zser ?? '') == (zser ?? '')).toList();
  }

  bool isOccupied(AreaModel area) {
    if ((area.quantity ?? '').toString() == '1') return true;
    if (area.properties.isNotEmpty) return true;
    return false;
  }

  // ===============================================================
  // Init
  // ===============================================================
  void _initialize() {
    _dataPerson = data_persons
        .map((p) => PersonFieldModel(
              ser: p.ser,
              title: p.title,
              detail: _initialOrDefault(
                _config.initialPersonValues,
                data_persons.indexOf(p),
                p.detail,
              ),
            ))
        .toList();

    _dataShop = data_shops
        .map((s) => ShopFieldModel(
              ser: s.ser,
              title: s.title,
              detail: _initialOrDefault(
                _config.initialShopValues,
                data_shops.indexOf(s),
                s.detail,
              ),
              detailsub: s.detailsub
                  .map((sub) => ShopSubField(
                        ser: sub.ser,
                        titlesub: sub.titlesub,
                        detail: sub.detail,
                      ))
                  .toList(),
            ))
        .toList();

    if (_config.initialCidValues != null &&
        _config.initialCidValues!.isNotEmpty) {
      _dataCid = _config.initialCidValues!
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } else {
      _dataCid = [
        {'ser': '1', 'title': 'วันที่เริ่มต้น', 'detail': ''},
        {'ser': '2', 'title': 'วันที่สิ้นสุด', 'detail': ''},
        {'ser': '3', 'title': 'ประเภทสัญญา', 'detail': '1'},
        {'ser': '4', 'title': 'ระยะเวลาเช่า (เดือน)', 'detail': '12'},
      ];
    }

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
      (i) => TextEditingController(
        text: _config.initialShopSubValues != null &&
                _config.initialShopSubValues!.length > i
            ? _config.initialShopSubValues![i]
            : _dataShop[0].detailsub[i].detail,
      ),
    );

    loadZones();
    loadSubZones();
  }

  String _initialOrDefault(List<String>? source, int index, String? fallback) {
    if (source != null && source.length > index) return source[index];
    return fallback ?? '';
  }

  // ===============================================================
  // Service calls
  // ===============================================================
  Future<void> loadZones({String? subZoneSer}) async {
    final zones = await _service.fetchZones(subZoneSer: subZoneSer);
    _zoneModels = zones;
    notifyListeners();
  }

  Future<void> loadSubZones() async {
    final subs = await _service.fetchSubZones();
    _subzoneModels = subs;
    notifyListeners();
  }

  Future<void> loadAreas(String? zoneSer) async {
    _zoneAreas = await _service.fetchAreas(zoneSer: zoneSer);
    notifyListeners();
  }

  Future<void> refreshProperties() async {
    if (_selectedZn == null) return;
    final zoneSer = _getZoneSer(_selectedZn);
    if (zoneSer == null || zoneSer.isEmpty) {
      await loadAreas(null);
      return;
    }
    await loadAreas(zoneSer);
  }

  // ===============================================================
  // Lookup helpers
  // ===============================================================
  String? _getSubZoneSer(String zn) => _subzoneModels
      .firstWhere((s) => s.zn == zn, orElse: () => SubZoneModel())
      .ser;

  String? _getZoneSer(String? zn) {
    if (zn == null) return null;
    return _zoneModels
        .firstWhere((z) => z.zn == zn, orElse: () => ZoneModel())
        .ser;
  }

  // ===============================================================
  // Selection events (View → VM)
  // ===============================================================
  Future<void> onSubZoneChanged(String? value) async {
    if (value == null) return;
    _selectedSubZone = value;
    _selectedZn = null;
    _selectedLn = null;
    _selectedZser = null;
    _selectedAser = null;
    _selectedScname = null;
    _zoneAreas = [];
    notifyListeners();
    await loadZones(subZoneSer: _getSubZoneSer(value));
  }

  Future<void> onZoneChanged(String? value) async {
    if (value == null) return;
    _selectedZn = value;
    _selectedLn = null;
    _selectedZser = null;
    _selectedAser = null;
    _selectedScname = null;
    _zoneAreas = [];
    notifyListeners();
    final zoneSer = _getZoneSer(value);
    if (zoneSer == '0' || zoneSer == null) {
      await loadAreas(null);
      await _loadAnnouncement(null);
    } else {
      await loadAreas(zoneSer);
      await _loadAnnouncement(zoneSer);
    }
  }

  Future<void> _loadAnnouncement(String? zoneSer) async {
    final result = await _service.fetchAnnouncement(
      zoneSer: zoneSer ?? '',
    );

    _announcementZone = result.zone;
    _announcementMessage = result.message;

    if (_announcementZone != null) {
      final startIdx = _findCidIndex('1');
      final endIdx = _findCidIndex('2');
      if (startIdx >= 0 && _announcementZone!.cDateStart != null) {
        _dataCid[startIdx]['detail'] = _announcementZone!.cDateStart!;
      }
      if (endIdx >= 0 && _announcementZone!.cDateEnd != null) {
        _dataCid[endIdx]['detail'] = _announcementZone!.cDateEnd!;
      }
    }

    notifyListeners();
  }

  void onPropertyChanged(String? value) {
    if (value == null) return;
    final parts = value.split('|');
    _selectedLn = value;
    _selectedAser = parts[1];
    _selectedZser = parts[2];
    _selectedScname = parts[3];
    _autoFillFromArea();
    notifyListeners();
  }

  // ===============================================================
  // Apply customer from registry (CustomerPickerDialog)
  // ===============================================================
  void applyCustomerFromRegistry({
    String? custno,
    String? uuid,
    String? cname,
    String? scname,
    String? stype,
    String? tax,
    String? tel,
    String? addr1,
    String? national,
    String? age,
  }) {
    // เก็บ uuid ของ client ไว้ใช้ตอน submit (POST /admin/requests)
    if (uuid != null && uuid.trim().isNotEmpty) {
      _clientUuid = uuid.trim();
    }

    final nameIdx = _findPersonIndex('ชื่อ-นามสกุล');
    if (nameIdx >= 0 && cname != null) {
      _dataPerson[nameIdx].detail = cname;
      _controllersPerson[nameIdx].text = cname;
    }

    final taxIdx = _findPersonIndex('เลขบัตรประจำตัว');
    if (taxIdx >= 0 && tax != null) {
      _dataPerson[taxIdx].detail = tax;
      _controllersPerson[taxIdx].text = tax;
    }

    if (age != null) {
      final ageIdx = _findPersonIndex('อายุ');
      if (ageIdx >= 0) {
        _dataPerson[ageIdx].detail = age;
        _controllersPerson[ageIdx].text = age;
      }
    }

    if (national != null) {
      final natIdx = _findPersonIndex('สัญชาติ');
      if (natIdx >= 0) {
        _dataPerson[natIdx].detail = national;
        _controllersPerson[natIdx].text = national;
      }
    }

    if (addr1 != null && addr1.isNotEmpty) {
      final houseIdx = _findPersonIndex('บ้านเลขที่');
      if (houseIdx >= 0) {
        _dataPerson[houseIdx].detail = addr1;
        _controllersPerson[houseIdx].text = addr1;
      }
      final noteIdx = _findPersonIndex('หมายเหตุ');
      if (noteIdx >= 0) {
        _dataPerson[noteIdx].detail = addr1;
        _controllersPerson[noteIdx].text = addr1;
      }
    }

    if (tel != null) {
      final telIdx = _findPersonIndex('เบอร์โทร');
      if (telIdx >= 0) {
        _dataPerson[telIdx].detail = tel;
        _controllersPerson[telIdx].text = tel;
      }
    }

    if (scname != null && scname.isNotEmpty) {
      final shopIdx = _findShopIndex('ชื่อร้าน');
      if (shopIdx >= 0) {
        _dataShop[shopIdx].detail = scname;
        _controllersShop[shopIdx].text = scname;
      }
    }

    // ✨ "ประเภทสินค้า" (stype) ใช้ข้อมูลจากทะเบียนลูกค้า (CustomerModel.stype)
    //    ไม่ใช่จาก area.stype — เพราะร้านค้านั้น "ประกอบกิจการ" ตามทะเบียน
    if (stype != null && stype.trim().isNotEmpty) {
      final stypeIdx = _findShopIndex('ประเภทสินค้า');
      if (stypeIdx >= 0) {
        _dataShop[stypeIdx].detail = stype;
        _controllersShop[stypeIdx].text = stype;
      }
    }

    _registryCustno = custno;

    notifyListeners();
  }

  String? _registryCustno;
  String? get registryCustno => _registryCustno;

  // ===============================================================
  // CID (Date picker)
  // ===============================================================
  void updateCidDate(int cidSer, String formattedDate) {
    final index = _dataCid.indexWhere((e) => e['ser'] == cidSer.toString());
    if (index < 0) return;

    if (cidSer.toString() == '1') {
      _dataCid[index]['detail'] = formattedDate;
      notifyListeners();
    } else if (cidSer.toString() == '2') {
      final startDateStr = _dataCid[index - 1]['detail'];
      if (startDateStr == null || startDateStr.toString().isEmpty) {
        _emitError('กรุณาเลือกวันที่เริ่มต้นก่อน');
        return;
      }
      try {
        final startDate = DateTime.parse(startDateStr);
        final selectedDate = DateTime.parse(formattedDate);
        final diff = selectedDate.difference(startDate).inDays;
        if (diff < 365) {
          _emitError('กรุณาเลือกวันที่สิ้นสุดให้มากกว่า 1 ปี');
          return;
        }
        _dataCid[index]['detail'] = formattedDate;
        notifyListeners();
      } catch (e) {
        _emitError('กรุณาเลือกวันที่เริ่มต้นก่อน');
      }
    }
  }

  // ===============================================================
  // Auto-fill from property
  // ===============================================================
  void _autoFillFromArea() {
    if (_selectedLn == null) return;
    final selectedLnOnly = _selectedLn!.split('|').first;
    final area = filteredAreas.firstWhere(
      (a) => (a.lncode ?? '').toString() == selectedLnOnly,
      orElse: () => AreaModel(),
    );

    if (_selectedScname != null && _selectedScname!.isNotEmpty) {
      final shopIndex = _findShopIndex('ชื่อร้าน');
      if (shopIndex >= 0) _controllersShop[shopIndex].text = _selectedScname!;
    }

    // ⛔ "ประเภทสินค้า" ไม่ auto-fill จาก area.stype แล้ว
    //    ใช้จาก CustomerModel.stype (เลือกจากทะเบียนลูกค้า) เท่านั้น
    //    เหตุผล: ร้านค้า "ประกอบกิจการ" ตามที่ลูกทะเบียน ไม่ใช่ตามล็อก

    // ✨ Auto-fill "ขนาดพื้นที่เช่า (ตร.ม.)" — ดึงจาก AreaModel.area
    //    (เช่น "1.00", "2.50") — เหมือน area_info_card ที่แสดงอยู่ด้านบน
    if (area.area != null && area.area!.toString().trim().isNotEmpty) {
      final sizeIndex = _findShopIndex('ขนาดพื้นที่');
      if (sizeIndex >= 0) {
        _controllersShop[sizeIndex].text = area.area!.toString();
      }
    }

    final lnAddr = area.ln ?? '';
    if (lnAddr.isNotEmpty) {
      final personIndex = _findPersonIndex('บ้านเลขที่');
      if (personIndex >= 0) _controllersPerson[personIndex].text = lnAddr;
    }

    if (area.lncode != null && area.lncode!.isNotEmpty) {
      final personIndex = _findPersonIndex('หมายเหตุ');
      if (personIndex >= 0) _controllersPerson[personIndex].text = area.lncode!;
    }

    if (area.sdate != null && area.sdate!.isNotEmpty) {
      final idx = _findCidIndex('1');
      if (idx >= 0) _dataCid[idx]['detail'] = area.sdate!;
    }
    if (area.ldate != null && area.ldate!.isNotEmpty) {
      final idx = _findCidIndex('2');
      if (idx >= 0) _dataCid[idx]['detail'] = area.ldate!;
    }

    // ✨ Auto-fill "บริเวณ / โซน / ล็อกที่" (shop sub-fields) — เหมือน
    //    license_request_detail_step1_view_model._setShopSubField(0..2)
    //    * บริเวณ  = subzone ที่เลือก
    //    * โซน     = zone name ที่เลือก
    //    * ล็อกที่ = lncode ที่เลือก
    if (_dataShop.isNotEmpty && _dataShop[0].detailsub.length >= 3) {
      _setShopSubField(0, _selectedSubZone ?? ''); // บริเวณ
      _setShopSubField(1, _selectedZn ?? ''); // โซน
      _setShopSubField(2, _selectedLn?.split('|').first ?? ''); // ล็อกที่
    }

    for (int i = 0; i < _dataPerson.length; i++) {
      _dataPerson[i].detail = _controllersPerson[i].text;
    }
    for (int i = 0; i < _dataShop.length; i++) {
      _dataShop[i].detail = _controllersShop[i].text;
    }
  }

  /// ตัวช่วยเซ็ตค่าฟิลด์ย่อยของร้านค้า (เช่น บริเวณ/โซน/ล็อกที่) — sync ทั้งใน
  /// model (_dataShop[0].detailsub[i].detail) และ controller (_controllersShopSub[i])
  /// เพื่อให้ UI อัปเดตทันที
  void _setShopSubField(int index, String value) {
    if (_dataShop.isEmpty) return;
    if (index < 0 || index >= _dataShop[0].detailsub.length) return;
    if (index < 0 || index >= _controllersShopSub.length) return;
    _dataShop[0].detailsub[index].detail = value;
    _controllersShopSub[index].text = value;
  }

  int _findPersonIndex(String titleKeyword) =>
      _dataPerson.indexWhere((p) => p.title.contains(titleKeyword));

  int _findShopIndex(String titleKeyword) =>
      _dataShop.indexWhere((s) => s.title.contains(titleKeyword));

  int _findCidIndex(String ser) =>
      _dataCid.indexWhere((c) => c['ser'].toString() == ser);

  // ===============================================================
  // Save
  // ===============================================================

  /// รับรายการ billing rows จาก BillingTable (ผ่าน onRowsChanged callback)
  /// — เก็บไว้ใช้ตอน submit() เพื่อสร้าง debt_details
  void setBillingRows(List<LcExpTransModel> rows) {
    _billingRows
      ..clear()
      ..addAll(rows);
  }

  /// POST /admin/requests (เหมือน new_contract_cmm.dart Step 1 → createRequestUuid)
  Future<void> submit() async {
    // 1) sync controllers → models
    for (int i = 0; i < _dataPerson.length; i++) {
      _dataPerson[i].detail = _controllersPerson[i].text;
    }
    for (int i = 0; i < _dataShop.length; i++) {
      _dataShop[i].detail = _controllersShop[i].text;
    }
    for (int i = 0; i < _dataShop[0].detailsub.length; i++) {
      _dataShop[0].detailsub[i].detail = _controllersShopSub[i].text;
    }

    // 2) validate
    if (_dataPerson[0].detail.trim().isEmpty) {
      _emitError('กรุณากรอกชื่อ-นามสกุล');
      return;
    }
    if (_selectedZn == null || _selectedZn!.isEmpty) {
      _emitError('กรุณาเลือกโซน');
      return;
    }
    if (_selectedLn == null || _selectedLn!.isEmpty) {
      _emitError('กรุณาเลือกรหัสพื้นที่');
      return;
    }
    if (_clientUuid == null || _clientUuid!.isEmpty) {
      _emitError('กรุณาเลือกลูกค้าจากทะเบียน (Step 1)');
      return;
    }
    if (_billingRows.isEmpty) {
      _emitError('กรุณาเพิ่มรายการค่าบริการอย่างน้อย 1 รายการ (Step 2)');
      return;
    }

    // 3) สร้าง requestData (เหมือน new_contract_cmm.dart → createRequestUuid)
    //    หมายเหตุ: ฟิลด์ "บ้านเลขที่" ในฟอร์ม LicenseContract อาจมีที่อยู่เต็ม
    //    → ตัดเฉพาะส่วน "เลขที่บ้าน" (ก่อนเว้นวรรคแรก) เพื่อไม่ให้เกิน 30 ตัวอักษร
    String _safeAddress(String raw, {int max = 30}) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) return '';
      // เอาเฉพาะก่อนเว้นวรรคแรก (เช่น "47/20 ต.ดอนแก้ว..." → "47/20")
      final firstPart = trimmed.split(RegExp(r'\s+')).first;
      return firstPart.length > max ? firstPart.substring(0, max) : firstPart;
    }

    String _person(int idx) => (_controllersPerson.length > idx)
        ? _controllersPerson[idx].text.trim()
        : '';

    final requestData = <String, dynamic>{
      'module_id': _config.moduleId,
      'clients_uuid': _clientUuid,
      'announcement_uuid': announcementUuid ?? '',
      'subzoneser': _getSubZoneSer(_selectedSubZone ?? '') ?? '0',
      'subzone': (_selectedSubZone == null || _selectedSubZone!.isEmpty)
          ? '-'
          : _selectedSubZone!,
      'lease_number': _config.leaseNumber ?? '',
      'zser': _selectedZser ?? '',
      'zn': _selectedZn ?? '',
      'aser': _selectedAser ?? '',
      'ln': _selectedLn?.split('|').first ?? '',
      'sdate': cidSdate,
      'ldate': cidLdate,
      'sertype': '4',
      'type': 'รายปี',
      'qty': '1',
      'json': {
        // ✨ ใช้ _safeAddress() เพื่อตัด "เลขที่บ้าน" ออกจากที่อยู่เต็ม + จำกัด 30 ตัวอักษร
        'number': _safeAddress(_person(4)),
        'moo': _person(5),
        'soi': _person(6),
        'road': _person(7),
        'tambon': _person(8),
        'amphoe': _person(9),
        'province': _person(10),
        'raw': '',
      },
      'debt_details': _billingRows.map((r) => r.toJson()).toList(),
    };

    // 4) POST /admin/requests
    try {
      final url = Uri.parse('${MyConstant().domain_v1}/admin/requests');
      final headers = await MyHeaders.build();
      final bodyStr = jsonEncode(requestData);

      final response = await http.post(
        url,
        headers: headers,
        body: bodyStr,
      );

      if (response.statusCode == 201) {
        final body = json.decode(response.body);
        String? createdUuid;
        if (body is Map && body['data'] is Map) {
          createdUuid = body['data']['uuid']?.toString();
        }
        final saved = LicenseContractResult(
          personValues: _dataPerson.map((e) => e.detail).toList(),
          shopValues: _dataShop.map((e) => e.detail).toList(),
          shopSubValues: _dataShop[0].detailsub.map((e) => e.detail).toList(),
          cidValues: _dataCid,
          zn: _selectedZn,
          ln: _selectedLn?.split('|').first,
          zser: _selectedZser,
          aser: _selectedAser,
          scname: _selectedScname,
          uuid: createdUuid,
        );
        _eventController.add(LicenseContractSavedEvent(saved));
      } else {
        String errMsg = 'บันทึกไม่สำเร็จ (${response.statusCode})';
        try {
          final body = json.decode(response.body);
          if (body is Map && body['message'] != null) {
            errMsg = body['message'].toString();
          }
        } catch (_) {}
        _emitError(errMsg);
      }
    } catch (e) {
      _emitError('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์: $e');
    }
  }

  void _emitError(String message) {
    _eventController.add(LicenseContractErrorEvent(message));
    notifyListeners();
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
    _eventController.close();
    super.dispose();
  }
}
