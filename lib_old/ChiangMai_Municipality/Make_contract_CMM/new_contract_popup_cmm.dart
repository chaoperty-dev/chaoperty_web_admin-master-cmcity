// =============================================================
// new_contract_popup_cmm.dart
// Popup widget แสดง "Step 1 : ผู้เช่า" (คัดลอก Logic และ UI จาก new_contract_cmm.dart)
// ใช้งาน:
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (_) => NewContractStepOnePopup(
//       properties: propertiesList, // optional
//       // optional props:
//       // readOnly: true,
//       // initialPersonValues: [...],
//       // initialShopValues: [...],
//       // initialShopSubValues: [...],
//       // initialCidValues: [...],
//       // announcementMessage: '...',
//       onSave: (data) {
//         // data.personValues, data.shopValues, data.shopSubValues, data.cidValues
//         // data.zn, data.ln, data.zser, data.aser, data.scname
//       },
//     ),
//   );
// =============================================================

import 'dart:convert';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/Person&Shop_Model.dart';
import '../Model/Properties_Model.dart';
import '../unity/Enum.dart';
import '../unity/FormatDate.dart';
import '../../Constant/Myconstant.dart';
import '../../Constant/api_cache.dart';
import '../../Model/GetZone_Model.dart';
import '../../Model/GetSubZone_Model.dart';
import '../unity/API_properties.dart';
import '../../Style/colors.dart';

// ====================================================================
// Data class สำหรับส่งค่ากลับเมื่อกดบันทึก
// ====================================================================
class NewContractStepOneResult {
  final List<String> personValues;
  final List<String> shopValues;
  final List<String> shopSubValues;
  final List<Map<String, dynamic>> cidValues;
  final String? zn; // โซน
  final String? ln; // รหัสพื้นที่
  final String? zser; // zone serial
  final String? aser; // area serial
  final String? scname; // ชื่อร้าน

  NewContractStepOneResult({
    required this.personValues,
    required this.shopValues,
    required this.shopSubValues,
    required this.cidValues,
    this.zn,
    this.ln,
    this.zser,
    this.aser,
    this.scname,
  });
}

// ====================================================================
// Main Popup Widget
// ====================================================================
class NewContractStepOnePopup extends StatefulWidget {
  /// โหมดอ่านอย่างเดียว
  final bool readOnly;

  /// รายการ Properties สำหรับโหลดข้อมูล dropdown (โซน/รหัสพื้นที่)
  final List<PropertiesModel>? properties;

  /// ค่าเริ่มต้นของฟิลด์ผู้เช่า (data_persons)
  final List<String>? initialPersonValues;

  /// ค่าเริ่มต้นของฟิลด์ร้านค้า (data_shops)
  final List<String>? initialShopValues;

  /// ค่าเริ่มต้นของฟิลด์ย่อย (detailsub)
  final List<String>? initialShopSubValues;

  /// ค่าเริ่มต้นของข้อมูลสัญญา (start/end date)
  final List<Map<String, dynamic>>? initialCidValues;

  /// ข้อความประกาศ (ถ้ามี)
  final String? announcementMessage;

  /// ชื่อหัวเรื่อง
  final String title;

  /// Callback เมื่อกดบันทึก
  final ValueChanged<NewContractStepOneResult>? onSave;

  const NewContractStepOnePopup({
    super.key,
    this.readOnly = false,
    this.properties,
    this.initialPersonValues,
    this.initialShopValues,
    this.initialShopSubValues,
    this.initialCidValues,
    this.announcementMessage,
    this.title = 'ผู้เช่า',
    this.onSave,
  });

  // Static helper เปิด popup แบบง่าย
  static Future<NewContractStepOneResult?> show(
    BuildContext context, {
    bool readOnly = false,
    List<PropertiesModel>? properties,
    List<String>? initialPersonValues,
    List<String>? initialShopValues,
    List<String>? initialShopSubValues,
    List<Map<String, dynamic>>? initialCidValues,
    String? announcementMessage,
    String title = 'ผู้เช่า',
  }) async {
    return showDialog<NewContractStepOneResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => NewContractStepOnePopup(
        readOnly: readOnly,
        properties: properties,
        initialPersonValues: initialPersonValues,
        initialShopValues: initialShopValues,
        initialShopSubValues: initialShopSubValues,
        initialCidValues: initialCidValues,
        announcementMessage: announcementMessage,
        title: title,
      ),
    );
  }

  @override
  State<NewContractStepOnePopup> createState() =>
      _NewContractStepOnePopupState();
}

class _NewContractStepOnePopupState extends State<NewContractStepOnePopup> {
  // -------- Form state --------
  late List<PersonFieldModel> data_person;
  late List<ShopFieldModel> data_shop;
  late List<Map<String, dynamic>> data_cid;
  late List<TextEditingController> _controllers_person;
  late List<TextEditingController> _controllers_shop;
  late List<TextEditingController> _controllers_shop_sub;
  final _formKey_person = GlobalKey<FormState>();

  // -------- Dropdown state (โซน / รหัสพื้นที่) --------
  String? _selectedZn; // โซน ที่เลือก
  String? _selectedSubZone; // โซนพื้นที่เช่า (subzone) ที่เลือก
  String? _selectedLn; // รหัสพื้นที่ ที่เลือก (เต็ม value: ln|aser|zser|scname)
  String? _selectedZser; // zone serial
  String? _selectedAser; // area serial
  String? _selectedScname; // ชื่อร้าน

  // -------- Read flag --------
  bool read_Only = false;

  // -------- Zone/Subzone data --------
  List<ZoneModel> zoneModels = [];
  List<SubZoneModel> subzoneModels = [];
  final _apiCache = ApiCache(ttl: const Duration(seconds: 60));

  // -------- Selected serials for cascading --------
  String? _selectedSubZoneSer;
  String? _selectedZoneSer;
  List<PropertiesModel> _zoneProperties = [];

  // -------- Derived lists --------
  /// รายการ โซน ที่ไม่ซ้ำ (จาก ZoneModel)
  List<String> get _zoneOptions {
    return zoneModels
        .map((z) => z.zn ?? '')
        .where((zn) => zn.trim().isNotEmpty)
        .toList();
  }

  /// รายการ โซนพื้นที่เช่า (subzone) ที่ไม่ซ้ำ (จาก SubZoneModel)
  List<String> get _subZoneOptions {
    return subzoneModels
        .map((s) => s.zn ?? '')
        .where((zn) => zn.trim().isNotEmpty)
        .toList();
  }

  /// รายการ รหัสพื้นที่ ที่กรองตามโซนที่เลือก (จาก API)
  List<PropertiesModel> get _filteredProperties {
    if (_selectedZn == null) return _zoneProperties;
    return _zoneProperties
        .where((p) => (p.newRequest?.zn ?? '').toString() == _selectedZn)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    read_Only = widget.readOnly;

    _loadZones();
    _loadSubZones();

    // clone data เพื่อไม่ให้กระทบต้นฉบับ
    data_person = data_persons
        .map((p) => PersonFieldModel(
              ser: p.ser,
              title: p.title,
              detail: widget.initialPersonValues != null &&
                      widget.initialPersonValues!.length >
                          data_persons.indexOf(p)
                  ? widget.initialPersonValues![data_persons.indexOf(p)]
                  : p.detail,
            ))
        .toList();

    data_shop = data_shops
        .map((s) => ShopFieldModel(
              ser: s.ser,
              title: s.title,
              detail: widget.initialShopValues != null &&
                      widget.initialShopValues!.length > data_shops.indexOf(s)
                  ? widget.initialShopValues![data_shops.indexOf(s)]
                  : s.detail,
              detailsub: s.detailsub
                  .map((sub) => ShopSubField(
                        ser: sub.ser,
                        titlesub: sub.titlesub,
                        detail: sub.detail,
                      ))
                  .toList(),
            ))
        .toList();

    // cid (ข้อมูลสัญญา)
    if (widget.initialCidValues != null &&
        widget.initialCidValues!.isNotEmpty) {
      data_cid = widget.initialCidValues!
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } else {
      data_cid = [
        {'ser': '1', 'title': 'วันที่เริ่มต้น', 'detail': ''},
        {'ser': '2', 'title': 'วันที่สิ้นสุด', 'detail': ''},
        {'ser': '3', 'title': 'ประเภทสัญญา', 'detail': '1'},
        {'ser': '4', 'title': 'ระยะเวลาเช่า (เดือน)', 'detail': '12'},
      ];
    }

    // controllers
    _controllers_person = List.generate(
      data_person.length,
      (i) => TextEditingController(text: data_person[i].detail ?? ''),
    );
    _controllers_shop = List.generate(
      data_shop.length,
      (i) => TextEditingController(text: data_shop[i].detail ?? ''),
    );
    _controllers_shop_sub = List.generate(
      data_shop[0].detailsub.length,
      (i) => TextEditingController(
        text: widget.initialShopSubValues != null &&
                widget.initialShopSubValues!.length > i
            ? widget.initialShopSubValues![i]
            : (data_shop[0].detailsub[i].detail ?? ''),
      ),
    );
  }

  @override
  void dispose() {
    for (var c in _controllers_person) {
      c.dispose();
    }
    for (var c in _controllers_shop) {
      c.dispose();
    }
    for (var c in _controllers_shop_sub) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadZones({String? subZoneSer}) async {
    if (zoneModels.isNotEmpty) {
      zoneModels.clear();
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    final cacheKey = 'new_contract_popup_read_GC_zone_${ren}_$subZoneSer';

    void applyZoneData(List result) {
      ZoneModel defaultZone = ZoneModel.fromJson({
        'ser': '0',
        'rser': '0',
        'zn': 'ทั้งหมด',
        'qty': '0',
        'img': '0',
        'data_update': '0',
      });

      setState(() {
        zoneModels.clear();
        zoneModels.add(defaultZone);

        for (var map in result) {
          ZoneModel zoneModel = ZoneModel.fromJson(map);
          if (subZoneSer == null ||
              subZoneSer == '0' ||
              zoneModel.sub_zone == subZoneSer) {
            zoneModels.add(zoneModel);
          }
        }

        zoneModels.sort((a, b) {
          if (a.zn == 'ทั้งหมด') return -1;
          if (b.zn == 'ทั้งหมด') return 1;
          return (a.zn ?? '').compareTo(b.zn ?? '');
        });
      });
    }

    if (_apiCache.isValid(cacheKey)) {
      final cachedData = _apiCache.get(cacheKey);
      if (cachedData != null) {
        applyZoneData(cachedData);
        return;
      }
    }

    String url = '${MyConstant().domain}/GC_zone.php?isAdd=true&ren=$ren';
    print(url);
    try {
      var response = await http.get(Uri.parse(url));
      var result = jsonDecode(response.body);

      if (result != null && result is List) {
        _apiCache.set(cacheKey, result);
        applyZoneData(result);
      }
    } catch (e) {
      print('Error reading zones in popup: $e');
    }
  }

  Future<void> _loadProperties(String zoneSer) async {
    _zoneProperties = [];
    try {
      final props = await read_GC_properties(zoneSer, null, null);
      if (mounted) {
        setState(() {
          _zoneProperties = props;
        });
      }
    } catch (e) {
      print('Error reading properties in popup: $e');
    }
  }

  Future<void> _loadSubZones() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    final cacheKey = 'new_contract_popup_read_GC_Sub_zone_$ren';

    if (_apiCache.isValid(cacheKey)) {
      final cachedData = _apiCache.get(cacheKey);
      if (cachedData != null) {
        setState(() {
          subzoneModels.clear();
          subzoneModels.add(SubZoneModel.fromJson({
            'ser': '0',
            'rser': '0',
            'zn': 'ทั้งหมด',
            'qty': '0',
            'img': '0',
            'data_update': '0',
          }));
          for (var map in cachedData) {
            subzoneModels.add(SubZoneModel.fromJson(map));
          }
        });
        return;
      }
    }

    if (subzoneModels.length != 0) {
      setState(() {
        subzoneModels.clear();
      });
    }

    String url = '${MyConstant().domain}/GC_zone_sub.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);

      Map<String, dynamic> map = {};
      map['ser'] = '0';
      map['rser'] = '0';
      map['zn'] = 'ทั้งหมด';
      map['qty'] = '0';
      map['img'] = '0';
      map['data_update'] = '0';

      SubZoneModel subzoneModelx = SubZoneModel.fromJson(map);

      setState(() {
        subzoneModels.add(subzoneModelx);
      });

      for (var map in result) {
        SubZoneModel subzoneModel = SubZoneModel.fromJson(map);
        setState(() {
          subzoneModels.add(subzoneModel);
        });
      }

      _apiCache.set(cacheKey, result);
    } catch (e) {}
  }

  String? _getSubZoneSer(String zn) {
    return subzoneModels
        .firstWhere((s) => s.zn == zn, orElse: () => SubZoneModel())
        .ser;
  }

  String? _getZoneSer(String zn) {
    return zoneModels
        .firstWhere((z) => z.zn == zn, orElse: () => ZoneModel())
        .ser;
  }

  // ---------- Date picker helper (เลียนแบบ Form_Cid) ----------
  Future<void> _pickDateForCid(Map<String, dynamic> cid) async {
    if (cid['ser'].toString() == '3' || cid['ser'].toString() == '4') return;

    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().add(const Duration(days: -100)),
      lastDate: DateTime.now().add(const Duration(days: 400)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppBarColors.ABar_Colors,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(primary: Colors.black),
            ),
          ),
          child: child!,
        );
      },
    );

    if (newDate == null) return;

    final index = data_cid.indexWhere((e) => e['ser'] == cid['ser']);
    if (index < 0) return;

    if (cid['ser'].toString() == '1') {
      setState(() {
        data_cid[index]['detail'] = DateFormat('yyyy-MM-dd').format(newDate);
      });
    } else if (cid['ser'].toString() == '2') {
      final startDateStr = data_cid[index - 1]['detail'];
      if (startDateStr != null && startDateStr.toString().isNotEmpty) {
        try {
          final startDate = DateTime.parse(startDateStr);
          final difference = newDate.difference(startDate).inDays;
          if (difference < 365) {
            _showAlert('กรุณาเลือกวันที่สิ้นสุดให้มากกว่า 1 ปี');
            return;
          }
          setState(() {
            data_cid[index]['detail'] =
                DateFormat('yyyy-MM-dd').format(newDate);
          });
        } catch (e) {
          _showAlert('กรุณาเลือกวันที่เริ่มต้นก่อน');
        }
      } else {
        _showAlert('กรุณาเลือกวันที่เริ่มต้นก่อน');
      }
    }
  }

  void _showAlert(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ---------- Save ----------
  void _handleSave() {
    // sync controller -> model
    for (int i = 0; i < data_person.length; i++) {
      data_person[i].detail = _controllers_person[i].text;
    }
    for (int i = 0; i < data_shop.length; i++) {
      data_shop[i].detail = _controllers_shop[i].text;
    }
    for (int i = 0; i < data_shop[0].detailsub.length; i++) {
      data_shop[0].detailsub[i].detail = _controllers_shop_sub[i].text;
    }

    // validate เบื้องต้น: ชื่อ-นามสกุล ต้องไม่ว่าง
    if (data_person[0].detail.trim().isEmpty) {
      _showAlert('กรุณากรอกชื่อ-นามสกุล');
      return;
    }

    // ตรวจสอบ โซน / รหัสพื้นที่
    if (_selectedZn == null || _selectedZn!.isEmpty) {
      _showAlert('กรุณาเลือกโซน');
      return;
    }
    if (_selectedLn == null || _selectedLn!.isEmpty) {
      _showAlert('กรุณาเลือกรหัสพื้นที่');
      return;
    }

    final result = NewContractStepOneResult(
      personValues: data_person.map((e) => e.detail ?? '').toList(),
      shopValues: data_shop.map((e) => e.detail ?? '').toList(),
      shopSubValues: data_shop[0].detailsub.map((e) => e.detail ?? '').toList(),
      cidValues: data_cid,
      zn: _selectedZn,
      // _selectedLn เก็บ full value: ln|aser|zser|scname
      // ดึงเฉพาะ ln (part แรก) ออกมา
      ln: _selectedLn?.split('|').first,
      zser: _selectedZser,
      aser: _selectedAser,
      scname: _selectedScname,
    );

    widget.onSave?.call(result);
    Navigator.of(context).pop(result);
  }

  // ===============================================================
  // UI
  // ===============================================================
  @override
  Widget build(BuildContext context) {
    final mediaWidth = MediaQuery.of(context).size.width;
    final useFullWidth = mediaWidth < 1200;

    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: useFullWidth ? 1500 : mediaWidth * 0.85,
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // ---------- Header ----------
            _buildHeader(),
            const Divider(height: 1),

            // ---------- Body ----------
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 1400,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Form(
                          key: _formKey_person,
                          child: Column(
                            children: [
                              // โซน / โซนพื้นที่เช่า// รหัสพื้นที่ (Dropdowns)
                              _buildZoneAndAreaDropdownRow(),
                              const SizedBox(height: 10),

                              // พื้นที่ เช่า (Area Info Card) - แสดงข้อมูลจาก Data_Properties
                              if (_selectedLn != null) _buildAreaInfoCard(),
                              const SizedBox(height: 10),

                              // แถวข้อมูลผู้เช่า + ร้านค้า + สัญญา
                              Container(
                                decoration: BoxDecoration(
                                  color: AppbackgroundColor.Sub_Abg_Colors,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ฝั่งซ้าย: ผู้เช่า + ร้านค้า
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        child: Column(
                                          children: [
                                            _buildSidebarSectionTitle(
                                                Icons.person, 'ข้อมูลผู้เช่า'),
                                            _buildFormPerson(),
                                            const SizedBox(height: 20),
                                            _buildSidebarSectionTitle(
                                                Icons.store, 'ข้อมูลร้านค้า'),
                                            _buildFormShop(),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // ฝั่งขวา: ประกาศ + ข้อมูลสัญญา
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            _buildAnnouncementCard(),
                                            const SizedBox(height: 10),
                                            _buildSidebarSectionTitle(
                                                Icons.receipt_long,
                                                'ข้อมูลสัญญา'),
                                            _buildFormCid(),
                                            const SizedBox(height: 10),
                                            if (!read_Only)
                                              _buildNextStepButton(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ---------- Footer ----------
            const Divider(height: 1),
            _buildFooterActions(),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // Header (Title + Step indicator)
  // ===============================================================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppBarColors.ABar_Colors,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: FontWeight_.Fonts_T,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'ปิด',
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // Footer (บันทึก / ยกเลิก)
  // ===============================================================
  Widget _buildFooterActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.red),
            label: const Text(
              'ยกเลิก',
              style: TextStyle(color: Colors.red, fontFamily: Font_.Fonts_T),
            ),
          ),
          const SizedBox(width: 8),
          if (!read_Only)
            ElevatedButton.icon(
              onPressed: _handleSave,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                'บันทึก',
                style:
                    TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppBarColors.ABar_Colors,
              ),
            ),
        ],
      ),
    );
  }

  // ===============================================================
  // โซน / โซนพื้นที่เช่า / รหัสพื้นที่ (Dropdowns - ใช้ข้อมูลจาก Zone/SubZone API)
  // ===============================================================
  Widget _buildZoneAndAreaDropdownRow() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppbackgroundColor.TiTile_Colors,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ===== โซนพื้นที่เช่า (ก่อน) =====
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AutoSizeText(
              'โซนพื้นที่เช่า : ',
              style: const TextStyle(
                color: PeopleChaoScreen_Color.Colors_Text1_,
                fontWeight: FontWeight.bold,
                fontFamily: FontWeight_.Fonts_T,
              ),
              maxFontSize: 16,
              minFontSize: 10,
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppbackgroundColor.Sub_Abg_Colors,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey, width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  hint: _subZoneOptions.isEmpty
                      ? AutoSizeText(
                          'ไม่มีข้อมูล',
                          style: const TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text2_,
                            fontFamily: Font_.Fonts_T,
                          ),
                          maxFontSize: 14,
                          minFontSize: 10,
                        )
                      : AutoSizeText(
                          'เลือกโซนพื้นที่เช่า',
                          style: const TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text2_,
                            fontFamily: Font_.Fonts_T,
                          ),
                          maxFontSize: 14,
                          minFontSize: 10,
                        ),
                  value: _subZoneOptions.isEmpty ? null : _selectedSubZone,
                  items: _subZoneOptions.isEmpty
                      ? <DropdownMenuItem<String>>[
                          const DropdownMenuItem<String>(
                            value: '',
                            child: Text('ไม่มีข้อมูล'),
                          ),
                        ]
                      : _subZoneOptions
                          .map((sub) => DropdownMenuItem<String>(
                                value: sub,
                                child: AutoSizeText(
                                  sub,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: Font_.Fonts_T,
                                  ),
                                  maxFontSize: 14,
                                  minFontSize: 10,
                                ),
                              ))
                          .toList(),
                  onChanged: (_subZoneOptions.isEmpty || read_Only)
                      ? null
                      : (value) {
                          if (value == null) return;
                          final subZoneSer = _getSubZoneSer(value);
                          setState(() {
                            _selectedSubZone = value;
                            _selectedSubZoneSer = subZoneSer;
                            _selectedZn = null;
                            _selectedZoneSer = null;
                            _selectedLn = null;
                            _selectedZser = null;
                            _selectedAser = null;
                            _selectedScname = null;
                            _zoneProperties = [];
                          });
                          _loadZones(subZoneSer: subZoneSer);
                        },
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // ===== โซน =====
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AutoSizeText(
              'โซน : ',
              style: const TextStyle(
                color: PeopleChaoScreen_Color.Colors_Text1_,
                fontWeight: FontWeight.bold,
                fontFamily: FontWeight_.Fonts_T,
              ),
              maxFontSize: 16,
              minFontSize: 10,
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppbackgroundColor.Sub_Abg_Colors,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey, width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  hint: _selectedZn == null
                      ? AutoSizeText(
                          'เลือกโซน',
                          style: const TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text2_,
                            fontFamily: Font_.Fonts_T,
                          ),
                          maxFontSize: 14,
                          minFontSize: 10,
                        )
                      : AutoSizeText(
                          _selectedZn!,
                          style: const TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text2_,
                            fontFamily: Font_.Fonts_T,
                          ),
                          maxFontSize: 14,
                          minFontSize: 10,
                        ),
                  value: _selectedZn,
                  items: _zoneOptions
                      .map((zn) => DropdownMenuItem<String>(
                            value: zn,
                            child: AutoSizeText(
                              zn,
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: Font_.Fonts_T,
                              ),
                              maxFontSize: 14,
                              minFontSize: 10,
                            ),
                          ))
                      .toList(),
                  onChanged: read_Only
                      ? null
                      : (value) {
                          if (value == null) return;
                          final zoneSer = _getZoneSer(value);
                          setState(() {
                            _selectedZn = value;
                            _selectedZoneSer = zoneSer;
                            _selectedLn = null;
                            _selectedZser = null;
                            _selectedAser = null;
                            _selectedScname = null;
                            _zoneProperties = [];
                          });
                          if (zoneSer != null) {
                            _loadProperties(zoneSer);
                          }
                        },
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // ===== รหัสพื้นที่ =====
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AutoSizeText(
              'รหัสพื้นที่ : ',
              style: const TextStyle(
                color: PeopleChaoScreen_Color.Colors_Text1_,
                fontWeight: FontWeight.bold,
                fontFamily: FontWeight_.Fonts_T,
              ),
              maxFontSize: 16,
              minFontSize: 10,
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppbackgroundColor.Sub_Abg_Colors,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey, width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  hint: _selectedLn == null
                      ? AutoSizeText(
                          _selectedZn == null
                              ? 'เลือกโซนก่อน'
                              : 'เลือกรหัสพื้นที่',
                          style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text2_
                                .withOpacity(0.7),
                            fontFamily: Font_.Fonts_T,
                          ),
                          maxFontSize: 14,
                          minFontSize: 10,
                        )
                      : AutoSizeText(
                          _selectedLn!,
                          style: const TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text2_,
                            fontFamily: Font_.Fonts_T,
                          ),
                          maxFontSize: 14,
                          minFontSize: 10,
                        ),
                  value: _selectedLn,
                  items: _filteredProperties
                      .map((p) => DropdownMenuItem<String>(
                            value:
                                '${p.newRequest?.ln ?? ''}|${p.newRequest?.aser ?? ''}|${p.newRequest?.zser ?? ''}|${p.client?.scname ?? ''}',
                            child: AutoSizeText(
                              p.newRequest?.ln ?? '-',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: Font_.Fonts_T,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (_selectedZn == null || read_Only)
                      ? null
                      : (value) {
                          if (value == null) return;
                          final parts = value.split('|');
                          setState(() {
                            // เก็บ value เต็ม เพื่อให้ dropdown value ตรงกับ items
                            _selectedLn = value;
                            _selectedAser = parts[1];
                            _selectedZser = parts[2];
                            _selectedScname = parts[3];
                            // เมื่อเลือกรหัสพื้นที่แล้ว ให้ดึงข้อมูลอื่นๆ มาใส่ form
                            _autoFillFromProperty();
                          });
                        },
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // ===== ทะเบียนผู้เช่า =====
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AutoSizeText(
              'ค้นจากทะเบียน : ',
              style: const TextStyle(
                color: PeopleChaoScreen_Color.Colors_Text1_,
                fontWeight: FontWeight.bold,
                fontFamily: FontWeight_.Fonts_T,
              ),
              maxFontSize: 16,
              minFontSize: 10,
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppbackgroundColor.Sub_Abg_Colors,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    // Dialog_Customer(context);
                  },
                  child: const Text(
                    'ค้นจากทะเบียน',
                    maxLines: 5,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      // PeopleChaoScreen_Color
                      //     .Colors_Text1_
                      // fontWeight: FontWeight.bold,
                      fontFamily: FontWeight_.Fonts_T,
                      fontWeight: FontWeight.bold,
                      //fontSize: 10.0
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Auto-fill form fields จากข้อมูล Property ที่เลือก
  void _autoFillFromProperty() {
    if (_selectedLn == null) return;
    // _selectedLn เก็บ full value: ln|aser|zser|scname
    // ดึง ln ออกมา (part แรก)
    final selectedLnOnly = _selectedLn!.split('|').first;
    final prop = _filteredProperties.firstWhere(
      (p) => (p.newRequest?.ln ?? '').toString() == selectedLnOnly,
      orElse: () => PropertiesModel(),
    );
    final nr = prop.newRequest;
    if (nr == null) return;

    // ชื่อร้าน → detail ของ data_shop[3]
    if (_selectedScname != null && _selectedScname!.isNotEmpty) {
      final shopIndex = _findShopIndex('ชื่อร้าน');
      if (shopIndex >= 0) {
        _controllers_shop[shopIndex].text = _selectedScname!;
      }
    }

    // บ้านเลขที่ (ln) → detail ของ data_person[4]
    final lnAddr = nr.ln ?? '';
    if (lnAddr.isNotEmpty) {
      final personIndex = _findPersonIndex('บ้านเลขที่');
      if (personIndex >= 0) {
        _controllers_person[personIndex].text = lnAddr;
      }
    }

    // วันที่เริ่มต้น / สิ้นสุด (sdate / ldate)
    if (nr.sdate != null && nr.sdate!.isNotEmpty) {
      final idx = _findCidIndex('1');
      if (idx >= 0) data_cid[idx]['detail'] = nr.sdate;
    }
    if (nr.ldate != null && nr.ldate!.isNotEmpty) {
      final idx = _findCidIndex('2');
      if (idx >= 0) data_cid[idx]['detail'] = nr.ldate;
    }

    // ประเภทสัญญา → cid ser=3
    if (nr.sertype != null) {
      final idx = _findCidIndex('3');
      if (idx >= 0) data_cid[idx]['detail'] = nr.sertype.toString();
    }
    // ระยะเวลาเช่า (เดือน) → cid ser=4
    if (nr.leaseTermMonths != null) {
      final idx = _findCidIndex('4');
      if (idx >= 0) data_cid[idx]['detail'] = nr.leaseTermMonths.toString();
    }

    // comments → หมายเหตุ (data_person[12])
    if (nr.comment != null && nr.comment!.isNotEmpty) {
      final personIndex = _findPersonIndex('หมายเหตุ');
      if (personIndex >= 0) {
        _controllers_person[personIndex].text = nr.comment!;
      }
    }

    // ประเภทสินค้า (qty) → data_shop[2]
    if (nr.qty != null && nr.qty!.isNotEmpty) {
      final shopIndex = _findShopIndex('ประเภทสินค้า');
      if (shopIndex >= 0) {
        _controllers_shop[shopIndex].text = nr.qty!;
      }
    }

    // ✅ sync ไปยัง data_person / data_shop ด้วย เพื่อให้ save result ตรง
    for (int i = 0; i < data_person.length; i++) {
      data_person[i].detail = _controllers_person[i].text;
    }
    for (int i = 0; i < data_shop.length; i++) {
      data_shop[i].detail = _controllers_shop[i].text;
    }

    setState(() {});
  }

  int _findPersonIndex(String titleKeyword) {
    final idx = data_person.indexWhere(
      (p) => (p.title ?? '').contains(titleKeyword),
    );
    return idx;
  }

  int _findShopIndex(String titleKeyword) {
    final idx = data_shop.indexWhere(
      (s) => (s.title ?? '').contains(titleKeyword),
    );
    return idx;
  }

  int _findCidIndex(String ser) {
    final idx = data_cid.indexWhere((c) => c['ser'].toString() == ser);
    return idx;
  }

  // ===============================================================
  // หัวข้อย่อย
  // ===============================================================
  Widget _buildSidebarSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: PeopleChaoScreen_Color.Colors_Text1_),
          const SizedBox(width: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: PeopleChaoScreen_Color.Colors_Text1_,
              fontFamily: FontWeight_.Fonts_T,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // Form : ผู้เช่า (คัดลอกจาก Form_Person)
  // ===============================================================
  Widget _buildFormPerson() {
    return SizedBox(
      child: Column(
        children: [
          for (int index = 0; index < data_person.length; index++)
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: SizedBox(
                height:
                    (index + 1 == data_person.length || index == 0) ? null : 50,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(2.0),
                        child: AutoSizeText(
                          '${data_person[index].title}',
                          minFontSize: 12,
                          maxFontSize: 16,
                          maxLines: 1,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text2_,
                            fontFamily: Font_.Fonts_T,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(2.0),
                        child: TextFormField(
                          textAlign: TextAlign.left,
                          keyboardType: TextInputType.multiline,
                          showCursor: !read_Only,
                          readOnly: read_Only,
                          controller: _controllers_person[index],
                          minLines: (index == 0)
                              ? 1
                              : (index + 1 == data_person.length)
                                  ? 3
                                  : 1,
                          maxLines: (index == 0)
                              ? 2
                              : (index + 1 == data_person.length)
                                  ? 3
                                  : 1,
                          decoration: const InputDecoration(
                            fillColor: Color(0x4DFFFFFF),
                            filled: true,
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(6)),
                              borderSide:
                                  BorderSide(width: 1, color: Colors.black),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(6)),
                              borderSide:
                                  BorderSide(width: 1, color: Colors.grey),
                            ),
                            labelStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              fontFamily: Font_.Fonts_T,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===============================================================
  // Form : ร้านค้า (คัดลอกจาก Form_Shop)
  // ===============================================================
  Widget _buildFormShop() {
    return SizedBox(
      child: Column(
        children: [
          for (int shop = 0; shop < data_shop.length; shop++)
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: SizedBox(
                height: (data_shop[shop].ser.toString() == '1') ? 150 : 50,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(2.0),
                        child: AutoSizeText(
                          minFontSize: 12,
                          maxFontSize: 16,
                          maxLines: 1,
                          '${data_shop[shop].title}*',
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text2_,
                            fontFamily: Font_.Fonts_T,
                          ),
                        ),
                      ),
                    ),
                    if (data_shop[shop].ser.toString() == '1')
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                for (int shop_sub = 0;
                                    shop_sub <
                                        data_shop[shop].detailsub.length - 1;
                                    shop_sub++)
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      padding: const EdgeInsets.all(2.0),
                                      child: TextFormField(
                                        textAlign: TextAlign.left,
                                        keyboardType: TextInputType.number,
                                        showCursor: !read_Only,
                                        readOnly: read_Only,
                                        controller:
                                            _controllers_shop_sub[shop_sub],
                                        maxLines: 1,
                                        decoration: InputDecoration(
                                          fillColor:
                                              Colors.white.withOpacity(0.3),
                                          filled: true,
                                          focusedBorder:
                                              const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(6)),
                                            borderSide: BorderSide(
                                                width: 1, color: Colors.black),
                                          ),
                                          enabledBorder:
                                              const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(6)),
                                            borderSide: BorderSide(
                                                width: 1, color: Colors.grey),
                                          ),
                                          labelText:
                                              '${data_shop[shop].detailsub[shop_sub].titlesub}',
                                          labelStyle: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontFamily: Font_.Fonts_T),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                for (int shop_sub = 2;
                                    shop_sub < data_shop[shop].detailsub.length;
                                    shop_sub++)
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      padding: const EdgeInsets.all(2.0),
                                      child: TextFormField(
                                        textAlign: TextAlign.left,
                                        keyboardType: TextInputType.number,
                                        showCursor: !read_Only,
                                        readOnly: read_Only,
                                        controller:
                                            _controllers_shop_sub[shop_sub],
                                        maxLines: 1,
                                        decoration: InputDecoration(
                                          fillColor:
                                              Colors.white.withOpacity(0.3),
                                          filled: true,
                                          focusedBorder:
                                              const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(6)),
                                            borderSide: BorderSide(
                                                width: 1, color: Colors.black),
                                          ),
                                          enabledBorder:
                                              const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(6)),
                                            borderSide: BorderSide(
                                                width: 1, color: Colors.grey),
                                          ),
                                          labelText:
                                              '${data_shop[shop].detailsub[shop_sub].titlesub}',
                                          labelStyle: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontFamily: Font_.Fonts_T),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      )
                    else
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.all(2.0),
                          child: TextFormField(
                            textAlign: TextAlign.left,
                            keyboardType: TextInputType.number,
                            showCursor: !read_Only,
                            readOnly: read_Only,
                            controller: _controllers_shop[shop],
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis),
                            onFieldSubmitted: (value) async {},
                            decoration: const InputDecoration(
                              fillColor: Color(0x4DFFFFFF),
                              filled: true,
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6)),
                                borderSide:
                                    BorderSide(width: 1, color: Colors.black),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6)),
                                borderSide:
                                    BorderSide(width: 1, color: Colors.grey),
                              ),
                              labelStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===============================================================
  // Form : ข้อมูลสัญญา (คัดลอกจาก Form_Cid)
  // ===============================================================
  Widget _buildFormCid() {
    return SizedBox(
      child: Column(
        children: [
          for (var cid in data_cid)
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: SizedBox(
                height: 50,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(2.0),
                        child: AutoSizeText(
                          minFontSize: 12,
                          maxFontSize: 16,
                          maxLines: 1,
                          '${cid["title"]}*',
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text2_,
                            fontFamily: Font_.Fonts_T,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: (cid['ser'].toString() == '3' ||
                                cid['ser'].toString() == '4')
                            ? null
                            : () => _pickDateForCid(cid),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(6)),
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          padding: const EdgeInsets.all(6.0),
                          child: AutoSizeText(
                            minFontSize: 12,
                            maxFontSize: 16,
                            maxLines: 1,
                            (cid["ser"].toString() == '3' ||
                                    cid["ser"].toString() == '4')
                                ? '${cid["detail"]}'
                                : formatDate('${cid["detail"]}',
                                    type: DateFormatType.dmy),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: PeopleChaoScreen_Color.Colors_Text2_,
                              fontFamily: Font_.Fonts_T,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===============================================================
  // การ์ดประกาศ
  // ===============================================================
  Widget _buildAnnouncementCard() {
    final hasAnnouncement =
        widget.announcementMessage?.trim().isNotEmpty ?? false;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        gradient: hasAnnouncement
            ? LinearGradient(
                colors: [
                  const Color(0xFF2E1D59).withOpacity(0.5),
                  const Color(0xFF7B5CE6).withOpacity(0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  const Color(0xFF1F2937).withOpacity(0.5),
                  const Color(0xFF0F172A).withOpacity(0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasAnnouncement
              ? const Color(0xFF8B5CF6).withOpacity(0.5)
              : const Color(0xFF334155).withOpacity(0.5),
          width: 1.2,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white.withOpacity(.15),
          child: Icon(
            hasAnnouncement ? Icons.campaign : Icons.info_outline,
            color: Colors.white,
            size: 18,
          ),
        ),
        title: const Text(
          'ประกาศ',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            hasAnnouncement
                ? widget.announcementMessage!
                : 'ไม่พบประกาศในขณะนี้',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(.92),
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // ปุ่ม "ถัดไป" (ใน popup ใช้สำหรับบันทึกข้อมูล)
  // ===============================================================
  Widget _buildNextStepButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 200,
          child: ElevatedButton.icon(
            onPressed: _handleSave,
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            label: const Text(
              'ถัดไป',
              style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppBarColors.ABar_Colors,
            ),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // พื้นที่ เช่า (Area Info Card) - แสดงข้อมูลจาก Data_Properties
  // ===============================================================
  Widget _buildAreaInfoCard() {
    if (_selectedLn == null) return const SizedBox.shrink();
    // ดึง ln ออกมา (part แรก) จาก full value
    final selectedLnOnly = _selectedLn!.split('|').first;
    final prop = _filteredProperties.firstWhere(
      (p) => (p.newRequest?.ln ?? '').toString() == selectedLnOnly,
      orElse: () => PropertiesModel(),
    );
    final nr = prop.newRequest;
    if (nr == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.teal.shade50,
            Colors.teal.shade50,
            Colors.green.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.teal.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business, size: 18, color: Colors.teal.shade700),
              const SizedBox(width: 8),
              AutoSizeText(
                'พื้นที่ เช่า (Area Info)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800,
                  fontFamily: FontWeight_.Fonts_T,
                ),
                maxFontSize: 16,
                minFontSize: 12,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // โซน
          _buildInfoRow(
            icon: Icons.map,
            label: 'โซน',
            value: nr.zn ?? '-',
          ),
          // โซนพื้นที่เช่า (sub zone)
          if (nr.subzoneser != null && nr.subzoneser.toString().isNotEmpty)
            _buildInfoRow(
              icon: Icons.layers,
              label: 'โซนพื้นที่เช่า',
              value: nr.subzoneser.toString(),
            ),
          // รหัสพื้นที่
          _buildInfoRow(
            icon: Icons.numbers,
            label: 'รหัสพื้นที่',
            value: nr.ln ?? '-',
          ),
          // ประเภทสินค้า
          if (nr.qty != null && nr.qty!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.category,
              label: 'ประเภทสินค้า',
              value: nr.qty!,
            ),
          // ชื่อร้าน
          if (prop.client?.scname != null && prop.client!.scname!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.store,
              label: 'ชื่อร้าน',
              value: prop.client!.scname!,
            ),
          // วันที่เริ่มสัญญา
          if (nr.sdate != null && nr.sdate!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'วันที่เริ่มสัญญา',
              value: formatDate(nr.sdate!, type: DateFormatType.dmy),
            ),
          // วันที่สิ้นสุดสัญญา
          if (nr.ldate != null && nr.ldate!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.event_busy,
              label: 'วันที่สิ้นสุดสัญญา',
              value: formatDate(nr.ldate!, type: DateFormatType.dmy),
            ),
          // หมายเหตุ
          if (nr.comment != null && nr.comment!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.note,
              label: 'หมายเหตุ',
              value: nr.comment!,
            ),
        ],
      ),
    );
  }

  /// Helper: แสดงข้อมูลแต่ละบรรทัดใน Area Info Card
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.teal.shade600),
          const SizedBox(width: 6),
          SizedBox(
            width: 110,
            child: Text(
              '$label :',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade900,
                fontFamily: Font_.Fonts_T,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontFamily: Font_.Fonts_T,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
