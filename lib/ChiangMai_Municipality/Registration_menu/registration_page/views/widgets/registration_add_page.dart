// ============================================================================
// registration_add_page.dart
// ============================================================================
// "เพิ่มทะเบียนลูกค้า" (Full-page 2-step)
// - Step 1: ข้อมูลหลัก (ชื่อร้าน/ประเภท/ผู้ติดต่อ/เบอร์โทร/อีเมล)
// - Step 2: ข้อมูลเพิ่มเติม (TAX/วันเกิด/ที่อยู่)
// - ปิดได้ด้วย Navigator.pop
// ============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../Constant/Myconstant.dart';
import '../theme/registration_theme.dart';
import 'registration_add_footer.dart';
import 'registration_add_header.dart';
import 'registration_add_step1.dart';
import 'registration_add_step2.dart';
import 'registration_add_view_model.dart';

class RegistrationAddPage extends StatefulWidget {
  final FutureOr<void> Function(String)? onSaveSuccess;

  const RegistrationAddPage({super.key, this.onSaveSuccess});

  /// Factory สร้าง Page พร้อม Provider (ใช้ใน Navigator.push)
  static Widget create({
    Key? key,
    FutureOr<void> Function(String)? onSaveSuccess,
  }) {
    return ChangeNotifierProvider<RegistrationAddViewModel>(
      create: (_) => RegistrationAddViewModel(),
      child: _RegistrationAddPageBody(onSaveSuccess: onSaveSuccess),
    );
  }

  @override
  State<RegistrationAddPage> createState() => _RegistrationAddPageState();
}

class _RegistrationAddPageState extends State<RegistrationAddPage> {
  @override
  Widget build(BuildContext context) {
    return RegistrationAddPage.create(
      key: widget.key,
      onSaveSuccess: widget.onSaveSuccess,
    );
  }
}

/// Body จริง — ต้องอยู่ใต้ Provider เสมอ
class _RegistrationAddPageBody extends StatefulWidget {
  final FutureOr<void> Function(String)? onSaveSuccess;
  const _RegistrationAddPageBody({this.onSaveSuccess});

  @override
  State<_RegistrationAddPageBody> createState() =>
      _RegistrationAddPageBodyState();
}

class _RegistrationAddPageBodyState extends State<_RegistrationAddPageBody> {
  // ─── Controllers (ใช้ร่วมกันระหว่าง 2 steps) ───
  final _formKey = GlobalKey<FormState>();
  final _nameshop = TextEditingController();
  final _typeshop = TextEditingController();
  final _bussshop = TextEditingController();
  final _bussscontact = TextEditingController();
  final _tel = TextEditingController();
  final _email = TextEditingController();
  final _tax = TextEditingController();
  final _birth = TextEditingController();

  // ─── Address (แยกช่อง) ───
  final _houseNo = TextEditingController();
  final _moo = TextEditingController();
  final _street = TextEditingController();
  final _subDistrict = TextEditingController();
  final _district = TextEditingController();
  final _province = TextEditingController();
  final _zipcode = TextEditingController();
  String _address = ''; // join แล้ว — ส่งไป API

  String _selectedType = '';
  bool _saving = false;

  bool get _isPersonalType {
    final keys = ['ส่วนตัว/บุคคลธรรมดา', 'บุคคลธรรมดา', 'ส่วนตัว', 'personal'];
    return keys.contains(_selectedType) ||
        _selectedType.trim() == 'ส่วนตัว/บุคคลธรรมดา';
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
    _houseNo.dispose();
    _moo.dispose();
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

      final endpoint = '${MyConstant().domain}/InC_CustoAdd_Bureau.php';
      final uri = Uri.parse(endpoint).replace(queryParameters: {
        'isAdd': 'true',
        'ren': ren,
      });

      final body = <String, String>{
        'ciddoc': '',
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
        'tel': _tel.text.trim(),
        'tax': _tax.text.trim(),
        'email': _email.text.trim(),
        'Serbool': '',
        'area_rent_sum': '',
        'comment': '',
        'zser': '',
        'birth': _birth.text.trim(),
        'national': 'ไทย',
        'religion': 'พุทธ',
      };

      final resp =
          await http.post(uri, body: body).timeout(const Duration(seconds: 20));

      if (!mounted) return;

      if (resp.statusCode != 200) {
        _snack('บันทึกลูกค้าไม่สำเร็จ [HTTP ${resp.statusCode}]');
        return;
      }

      final savedName = _nameshop.text.trim();
      _snack('บันทึกลูกค้าสำเร็จ', success: true);
      if (widget.onSaveSuccess != null) {
        await widget.onSaveSuccess!(savedName);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      debugPrint('RegistrationAddPage save error: $e');
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

    return Scaffold(
      backgroundColor: LaColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RegistrationAddHeader(
              title: 'เพิ่มทะเบียนลูกค้า',
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
                      tax: _tax,
                      birth: _birth,
                      houseNo: _houseNo,
                      moo: _moo,
                      street: _street,
                      subDistrict: _subDistrict,
                      district: _district,
                      province: _province,
                      zipcode: _zipcode,
                      onAddressChanged: (v) => setState(() => _address = v),
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
