// ============================================================================
// registration_edit_page.dart
// ============================================================================
// "แก้ไขทะเบียนลูกค้า" (Full-page 2-step) — UI/UX เดียวกับ Add Page
// - Step 1: ข้อมูลหลัก (ชื่อร้าน/ประเภท/ผู้ติดต่อ/เบอร์โทร/อีเมล)
// - Step 2: ข้อมูลเพิ่มเติม (TAX/วันเกิด/ที่อยู่)
// - โหลดข้อมูลเดิมจาก uuid, prefill controllers, save แบบ UPDATE
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../Constant/Myconstant.dart';
import '../../../../../Model/GetCustomer_Model.dart';
import '../theme/registration_theme.dart';
import '../../viewmodels/registration_detail_view_model.dart';
import 'registration_add_footer.dart';
import 'registration_add_header.dart';
import 'registration_add_step1.dart';
import 'registration_add_step2.dart';
import 'registration_add_view_model.dart';

class RegistrationEditPage extends StatefulWidget {
  /// uuid ของรายการที่จะแก้ไข
  final String uuid;

  /// Callback หลังบันทึกสำเร็จ
  final FutureOr<void> Function()? onSaveSuccess;

  const RegistrationEditPage({
    super.key,
    required this.uuid,
    this.onSaveSuccess,
  });

  /// Factory สร้าง Page พร้อม Provider
  static Widget create({
    Key? key,
    required String uuid,
    FutureOr<void> Function()? onSaveSuccess,
  }) {
    return ChangeNotifierProvider<RegistrationAddViewModel>(
      create: (_) => RegistrationAddViewModel(),
      child: _RegistrationEditPageBody(
        uuid: uuid,
        onSaveSuccess: onSaveSuccess,
      ),
    );
  }

  @override
  State<RegistrationEditPage> createState() => _RegistrationEditPageState();
}

class _RegistrationEditPageState extends State<RegistrationEditPage> {
  @override
  Widget build(BuildContext context) {
    return RegistrationEditPage.create(
      key: widget.key,
      uuid: widget.uuid,
      onSaveSuccess: widget.onSaveSuccess,
    );
  }
}

/// Body จริง — ต้องอยู่ใต้ Provider เสมอ
class _RegistrationEditPageBody extends StatefulWidget {
  final String uuid;
  final FutureOr<void> Function()? onSaveSuccess;
  const _RegistrationEditPageBody({
    required this.uuid,
    this.onSaveSuccess,
  });

  @override
  State<_RegistrationEditPageBody> createState() =>
      _RegistrationEditPageBodyState();
}

class _RegistrationEditPageBodyState extends State<_RegistrationEditPageBody> {
  final _formKey = GlobalKey<FormState>();
  final _nameshop = TextEditingController();
  final _typeshop = TextEditingController();
  final _bussshop = TextEditingController();
  final _bussscontact = TextEditingController();
  final _tel = TextEditingController();
  final _email = TextEditingController();
  final _tax = TextEditingController();
  final _birth = TextEditingController();
  final _national = TextEditingController();
  final _religion = TextEditingController();

  // ─── Address (แยกช่อง) ───
  final _houseNo = TextEditingController();
  final _moo = TextEditingController();
  final _soi = TextEditingController();
  final _street = TextEditingController();
  final _subDistrict = TextEditingController();
  final _district = TextEditingController();
  final _province = TextEditingController();
  final _zipcode = TextEditingController();
  String _address = '';
  String _address2 = ''; // JSON parts — ส่งไป address_2

  String _selectedType = '';
  bool _saving = false;
  bool _loading = true;
  CustomerModel? _customer;

  bool get _isPersonalType {
    final keys = ['ส่วนตัว/บุคคลธรรมดา', 'บุคคลธรรมดา', 'ส่วนตัว', 'personal'];
    return keys.contains(_selectedType) ||
        _selectedType.trim() == 'ส่วนตัว/บุคคลธรรมดา';
  }

  @override
  void initState() {
    super.initState();
    _loadCustomer();
  }

  Future<void> _loadCustomer() async {
    try {
      // ใช้ service ผ่าน viewmodel ของ detail
      final detailVm = RegistrationDetailViewModel();
      await detailVm.loadCustomer(widget.uuid);
      final c = detailVm.customer;
      if (c == null) {
        _snack('ไม่พบข้อมูล');
        setState(() => _loading = false);
        return;
      }
      _customer = c;
      _prefillControllers(c);
      setState(() => _loading = false);
    } catch (e) {
      _snack('โหลดข้อมูลไม่สำเร็จ');
      setState(() => _loading = false);
    }
  }

  void _prefillControllers(CustomerModel c) {
    _nameshop.text = c.scname ?? '';
    _typeshop.text = c.type ?? '';
    _selectedType = c.type ?? '';
    _bussshop.text = c.cname ?? '';
    _bussscontact.text = c.attn ?? '';
    _tel.text = c.tel ?? '';
    _email.text = c.email ?? '';
    _tax.text = c.tax ?? '';
    _birth.text = c.birth ?? '';
    _national.text =
        (c.national ?? '').trim().isEmpty ? 'ไทย' : (c.national ?? '');
    _religion.text =
        (c.religion ?? '').trim().isEmpty ? 'พุทธ' : (c.religion ?? '');

    // ที่อยู่ — ลองแยกจาก addr1 หรือใช้ค่าเดิม
    final addr = (c.addr1 ?? '').trim();
    if (addr.isNotEmpty) {
      // พยายามแยก field จาก string เช่น "123/45 หมู่ 2 ถ.X ต.Y อ.Z จ.W 50000"
      _parseAddress(addr, c.zip ?? '');
    } else if ((c.addr2 ?? '').trim().isNotEmpty) {
      _parseAddress(c.addr2 ?? '', c.zip ?? '');
    }
    _address = addr.isNotEmpty ? addr : (c.addr2 ?? '');
  }

  /// Parse address string เป็น controllers
  void _parseAddress(String addr, String zip) {
    // ตัวอย่าง: "123/45 หมู่ 2 ถ.นิมมานเหมินท์ ต.สุเทพ อ.เมือง จ.เชียงใหม่ 50000"
    String s = addr;

    // บ้านเลขที่ + หมู่
    final mooMatch = RegExp(r'(?:^|\s)(?:หมู่\s*)?(\d+)(?:\s|$)').firstMatch(s);
    // ถนน
    final streetMatch =
        RegExp(r'ถ\.([^\s]+(?:\s[^\s]+)*?)(?=\sต\.|\sอ\.|\sจ\.|\s\d{5}|$)')
            .firstMatch(s);
    // ตำบล
    final tambonMatch =
        RegExp(r'ต\.([^\s]+(?:\s[^\s]+)*?)(?=\sอ\.|\sจ\.|\s\d{5}|$)')
            .firstMatch(s);
    // อำเภอ
    final amphoeMatch =
        RegExp(r'อ\.([^\s]+(?:\s[^\s]+)*?)(?=\sจ\.|\s\d{5}|$)').firstMatch(s);
    // จังหวัด
    final provinceMatch =
        RegExp(r'จ\.([^\s]+(?:\s[^\s]+)*?)(?=\s\d{5}|$)').firstMatch(s);

    if (streetMatch != null) {
      _street.text = streetMatch.group(1)?.trim() ?? '';
    }
    if (tambonMatch != null) {
      _subDistrict.text = tambonMatch.group(1)?.trim() ?? '';
    }
    if (amphoeMatch != null) {
      _district.text = amphoeMatch.group(1)?.trim() ?? '';
    }
    if (provinceMatch != null) {
      _province.text = provinceMatch.group(1)?.trim() ?? '';
    }
    if (zip.isNotEmpty) {
      _zipcode.text = zip;
    }

    // บ้านเลขที่ (เอา string แรกสุดก่อน หมู่/ถนน)
    final houseMatch = RegExp(r'^([^\s]+)').firstMatch(s);
    if (houseMatch != null) {
      final first = houseMatch.group(1) ?? '';
      // ถ้า first เป็นตัวเลข = บ้านเลขที่
      if (RegExp(r'^[\d/]+$').hasMatch(first)) {
        _houseNo.text = first;
        // หา หมู่
        final mooSearch = RegExp(r'หมู่\s*(\d+)').firstMatch(s);
        if (mooSearch != null) {
          _moo.text = mooSearch.group(1) ?? '';
        }
      }
    }
  }

  @override
  void dispose() {
    _nameshop.dispose();
    _typeshop.dispose();
    _bussshop.dispose();
    _bussscontact.dispose();
    _tel.dispose();
    _email.dispose();
    _tax.dispose();
    _birth.dispose();
    _national.dispose();
    _religion.dispose();
    _houseNo.dispose();
    _moo.dispose();
    _soi.dispose();
    _street.dispose();
    _subDistrict.dispose();
    _district.dispose();
    _province.dispose();
    _zipcode.dispose();
    super.dispose();
  }

  // ─── Navigation between steps ───
  void _onNext() {
    if (_formKey.currentState?.validate() != true) return;
    context.read<RegistrationAddViewModel>().nextStep();
  }

  void _onPrev() {
    context.read<RegistrationAddViewModel>().previousStep();
  }

  Future<void> _onSave() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _saving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final ren = prefs.getString('renTalSer') ?? '0';
      final user = prefs.getString('ser') ?? '';

      final bussscontact =
          _isPersonalType ? _bussshop.text.trim() : _bussscontact.text.trim();

      final endpoint = '${MyConstant().domain}/registration_add_up.php';
      final uri = Uri.parse(endpoint).replace(queryParameters: {
        'isAdd': 'true',
        'isEdit': 'true',
        'ren': ren,
      });

      final body = <String, String>{
        'ciddoc': _customer?.cid ?? '',
        'uuid': _customer?.uuid ?? widget.uuid,
        'ser': _customer?.ser?.toString() ?? widget.uuid,
        'qutser': '',
        'user': user,
        'sumdis': '',
        'sumdisp': '',
        'dateY': '',
        'dateY1': '',
        'time': '',
        'payment1': '',
        'payment2': '',
        'pSer1': '',
        'pSer2': '',
        'sum_whta': '',
        'bill': '',
        'fileNameSlip': '',
        'areaSer': _isPersonalType ? '1' : '2',
        'typeModels': _selectedType,
        'typeshop': _typeshop.text.trim(),
        'nameshop': _nameshop.text.trim(),
        'bussshop': _bussshop.text.trim(),
        'bussscontact': bussscontact,
        'address': _address.trim(),
        'address_2': _address2,
        'tel': _tel.text.trim(),
        'tax': _tax.text.trim(),
        'email': _email.text.trim(),
        'Serbool': '',
        'area_rent_sum': '',
        'comment': '',
        'zser': '',
        'birth': _birth.text.trim(),
        'national': _national.text.trim(),
        'religion': _religion.text.trim(),
        'zip': _zipcode.text.trim(),
      };

      // ─── Debug: print url + body + response ───
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🟡 [RegistrationEditPage._onSave]');
      debugPrint('   URL  = $uri');
      debugPrint('   body (${body.length} keys):');
      body.forEach((k, v) {
        debugPrint('     $k = "$v"');
      });
      debugPrint('   _customer?.ser = ${_customer?.ser}');
      debugPrint('   _customer?.uuid = ${_customer?.uuid}');
      debugPrint('   widget.uuid = ${widget.uuid}');

      final resp =
          await http.post(uri, body: body).timeout(const Duration(seconds: 20));

      debugPrint('   Response status = ${resp.statusCode}');
      debugPrint('   Response body   = ${resp.body}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (!mounted) return;

      if (resp.statusCode != 200) {
        _snack('บันทึกลูกค้าไม่สำเร็จ [HTTP ${resp.statusCode}]');
        return;
      }

      _snack('บันทึกการแก้ไขสำเร็จ', success: true);
      if (widget.onSaveSuccess != null) {
        await widget.onSaveSuccess!();
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      debugPrint('RegistrationEditPage save error: $e');
      _snack('เกิดข้อผิดพลาด');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            success ? LaColors.statusApprovedFg : LaColors.statusRejectedFg,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistrationAddViewModel>();
    final step = vm.currentStep;
    final subtitle =
        step == 1 ? 'ข้อมูลร้านค้าและผู้ติดต่อ' : 'ข้อมูลส่วนบุคคลและที่อยู่';

    if (_loading) {
      return Scaffold(
        backgroundColor: LaColors.surface,
        body: SafeArea(
          child: Column(
            children: [
              RegistrationAddHeader(
                title: 'แก้ไขทะเบียนลูกค้า',
                subtitle: 'กำลังโหลดข้อมูล...',
                currentStep: 1,
                totalSteps: vm.totalSteps,
                onBack: () => Navigator.of(context).pop(),
              ),
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: LaColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RegistrationAddHeader(
              title: 'แก้ไขทะเบียนลูกค้า',
              subtitle: subtitle,
              currentStep: step,
              totalSteps: vm.totalSteps,
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: step == 1
                  ? RegistrationAddStep1(
                      formKey: _formKey,
                      nameshop: _nameshop,
                      typeshop: _typeshop,
                      bussshop: _bussshop,
                      bussscontact: _bussscontact,
                      tel: _tel,
                      email: _email,
                      onTypeChanged: (v) =>
                          setState(() => _selectedType = v ?? ''),
                      isPersonalType: _isPersonalType,
                    )
                  : RegistrationAddStep2(
                      formKey: _formKey,
                      tax: _tax,
                      birth: _birth,
                      national: _national,
                      religion: _religion,
                      houseNo: _houseNo,
                      moo: _moo,
                      soi: _soi,
                      street: _street,
                      subDistrict: _subDistrict,
                      district: _district,
                      province: _province,
                      zipcode: _zipcode,
                      onAddressChanged: (v) => setState(() => _address = v),
                      onAddressPartsChanged: (v) =>
                          setState(() => _address2 = v),
                    ),
            ),
            RegistrationAddFooter(
              currentStep: step,
              totalSteps: vm.totalSteps,
              onCancel: () {
                if (step > 1) {
                  _onPrev();
                } else {
                  Navigator.of(context).pop();
                }
              },
              onNext: step < vm.totalSteps ? _onNext : null,
              onSave: _saving ? () {} : _onSave,
            ),
          ],
        ),
      ),
    );
  }
}
