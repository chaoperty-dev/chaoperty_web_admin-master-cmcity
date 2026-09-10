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
  final _national = TextEditingController(text: 'ไทย');
  final _religion = TextEditingController(text: 'พุทธ');

  // ─── Address (แยกช่อง) ───
  final _houseNo = TextEditingController();
  final _moo = TextEditingController();
  final _soi = TextEditingController();
  final _street = TextEditingController();
  final _subDistrict = TextEditingController();
  final _district = TextEditingController();
  final _province = TextEditingController();
  final _zipcode = TextEditingController();
  String _address = ''; // join แล้ว — ส่งไป API
  String _address2 = ''; // JSON parts — ส่งไป address_2

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
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🟢 [RegistrationAddPage] _onSave() STARTED');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // ─── 1. Validate ───
    final formState = _formKey.currentState;
    debugPrint('📋 [1] Form state = $formState');
    debugPrint('📋 [1] Form key context = ${_formKey.currentContext}');
    debugPrint('📋 [1] Form key mounted = ${_formKey.currentContext?.mounted}');

    // ─── 1a. Manual check ทุก field (ก่อน Form.validate) ───
    debugPrint('📋 [1a] Manual field checks:');
    debugPrint('     nameshop      = "${_nameshop.text.trim()}" (required)');
    debugPrint('     typeshop      = "${_typeshop.text.trim()}"');
    debugPrint('     bussshop      = "${_bussshop.text.trim()}"');
    debugPrint(
        '     bussscontact  = "${_bussscontact.text.trim()}" ${_isPersonalType ? "(businessLabel)" : ""}');
    debugPrint('     tel           = "${_tel.text.trim()}"');
    debugPrint('     email         = "${_email.text.trim()}"');
    debugPrint(
        '     tax           = "${_tax.text.trim()}" (required, len=${_tax.text.trim().length})');
    debugPrint('     birth         = "${_birth.text.trim()}"');
    debugPrint('     national      = "${_national.text.trim()}"');
    debugPrint('     religion      = "${_religion.text.trim()}"');
    debugPrint('     houseNo       = "${_houseNo.text.trim()}"');
    debugPrint('     moo           = "${_moo.text.trim()}"');
    debugPrint('     soi           = "${_soi.text.trim()}"');
    debugPrint('     street        = "${_street.text.trim()}"');
    debugPrint('     subDistrict   = "${_subDistrict.text.trim()}"');
    debugPrint('     district      = "${_district.text.trim()}"');
    debugPrint('     province      = "${_province.text.trim()}"');
    debugPrint('     zipcode       = "${_zipcode.text.trim()}"');
    debugPrint('     _address      = "${_address.trim()}"');
    debugPrint('     _address2     = "$_address2"');
    debugPrint('     _selectedType = "${_selectedType}"');
    debugPrint('     _isPersonalType = $_isPersonalType');

    // ─── 1b. Manual required validation (fallback) ───
    final errors = <String>[];
    if (_nameshop.text.trim().isEmpty) errors.add('nameshop (required)');
    if (_tax.text.trim().isEmpty) {
      errors.add('tax (required)');
    } else if (_tax.text.trim().length < 13) {
      errors.add(
          'tax (ต้องกรอกอย่างน้อย 13 หลัก, ตอนนี้ ${_tax.text.trim().length})');
    }
    if (errors.isNotEmpty) {
      debugPrint('❌ [1b] Manual required check FAILED:');
      for (final e in errors) {
        debugPrint('     - $e');
      }
    } else {
      debugPrint('✅ [1b] Manual required check PASSED');
    }

    final formValid = formState?.validate() ?? false;
    debugPrint('📋 [1c] Form.validate() result = $formValid');
    if (!formValid) {
      debugPrint(
          '❌ [1] Validation FAILED — _onSave returns early (nothing happens!)');
      debugPrint('   → ตรวจดูว่าช่องไหน required ยังไม่ได้กรอก');
      if (errors.isNotEmpty) {
        debugPrint('   → The fields likely failed:');
        for (final e in errors) {
          debugPrint('     - $e');
        }
      }
      return;
    }

    setState(() => _saving = true);
    try {
      // ─── 2. Read SharedPreferences ───
      final prefs = await SharedPreferences.getInstance();
      final ren = prefs.getString('renTalSer') ?? '0';
      final user = prefs.getString('ser') ?? '';
      debugPrint('🔑 [2] SharedPreferences: ren="$ren", user="$user"');

      final bussscontact =
          _isPersonalType ? _bussshop.text.trim() : _bussscontact.text.trim();

      // ─── 3. Build URL ───
      // ใช้ registration_add_up.php ตัวเดียว (รองรับทั้ง INSERT + UPDATE)
      // - isEdit=false → INSERT (เพิ่ม)
      // - isEdit=true  + มี ser → UPDATE (แก้ไข)
      final endpoint = '${MyConstant().domain}/registration_add_up.php';
      final uri = Uri.parse(endpoint).replace(queryParameters: {
        'isAdd': 'true',
        'isEdit': 'false',
        'ren': ren,
      });
      debugPrint('🌐 [3] URL (full)  = ${uri.toString()}');
      debugPrint('🌐 [3] URL (host)  = ${uri.host}');
      debugPrint('🌐 [3] URL (path)  = ${uri.path}');
      debugPrint('🌐 [3] URL (query) = ${uri.query}');
      debugPrint('🌐 [3] Domain     = ${MyConstant().domain}');

      // ─── 4. Build body ───
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

      debugPrint('📦 [4] Body (${body.length} keys):');
      body.forEach((k, v) {
        debugPrint('     $k = "$v"');
      });

      // ─── 5. POST ───
      debugPrint('🚀 [5] POST → start...');
      debugPrint(
          '🚀 [5] uri.scheme=${uri.scheme} host=${uri.host} port=${uri.port}');
      debugPrint('🚀 [5] uri.encoded=${uri.toString()}');
      http.Response resp;
      try {
        final stopwatch = Stopwatch()..start();
        resp = await http
            .post(uri, body: body)
            .timeout(const Duration(seconds: 20));
        stopwatch.stop();
        debugPrint(
          '🚀 [5] POST → done in ${stopwatch.elapsedMilliseconds} ms',
        );
      } catch (e, st) {
        debugPrint('❌ [5] POST THREW EXCEPTION: $e');
        debugPrint('❌ [5] stacktrace: $st');
        rethrow;
      }

      // ─── 6. Response ───
      debugPrint('📨 [6] Response status   = ${resp.statusCode}');
      debugPrint('📨 [6] Response reasonPhrase = ${resp.reasonPhrase}');
      debugPrint('📨 [6] Response headers  = ${resp.headers}');
      debugPrint('📨 [6] Response body     = ${resp.body}');
      debugPrint('📨 [6] Response body len = ${resp.body.length}');
      // เดา content-type จาก header (เผื่อ server ตอบ HTML)
      final ct = resp.headers['content-type'] ?? '';
      debugPrint('📨 [6] Response content-type = $ct');

      // ─── 7. Parse JSON ───
      Map<String, dynamic>? firstRow;
      String? newSer;
      String? newUuid;
      try {
        final parsed = jsonDecode(resp.body);
        debugPrint('✅ [7] JSON decoded type = ${parsed.runtimeType}');
        if (parsed is List && parsed.isNotEmpty) {
          firstRow = parsed.first as Map<String, dynamic>;
          newSer = firstRow['ser']?.toString();
          newUuid = firstRow['uuid']?.toString();
          debugPrint('✅ [7] Parsed JSON: ser=$newSer, uuid=$newUuid');
        } else if (parsed is Map<String, dynamic>) {
          debugPrint(
            '⚠️ [7] Response is a Map (not a List). Keys=${parsed.keys.toList()}',
          );
        } else {
          debugPrint('⚠️ [7] Response body is not a non-empty List');
        }
      } catch (e) {
        debugPrint('⚠️ [7] JSON parse failed: $e');
        debugPrint(
            '⚠️ [7] raw body prefix = ${resp.body.substring(0, resp.body.length.clamp(0, 200))}');
      }

      if (!mounted) {
        debugPrint('⚠️ [6] Widget unmounted — skip UI update');
        return;
      }

      // ─── เก็บ messenger ก่อน await เพื่อไม่ให้ pop ช้า ───
      final messenger = ScaffoldMessenger.of(context);

      if (resp.statusCode != 200) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('บันทึกลูกค้าไม่สำเร็จ [HTTP ${resp.statusCode}]'),
            backgroundColor: LaColors.statusRejectedFg,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }

      final savedName = _nameshop.text.trim();
      debugPrint('✅ [8] SAVE SUCCESS — showing SnackBar to user');

      // ─── แสดง SnackBar สำเร็จ (4 วินาที ให้ user เห็นชัด) ───
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'บันทึกลูกค้า "$savedName" สำเร็จ',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: LaColors.statusApprovedFg,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );

      // ─── Callback refresh ตาราง ───
      if (widget.onSaveSuccess != null) {
        try {
          await widget.onSaveSuccess!(savedName);
          debugPrint('✅ [9] onSaveSuccess callback executed');
        } catch (e) {
          debugPrint('⚠️ [9] onSaveSuccess callback error: $e');
        }
      }

      // ─── รอให้ user เห็น SnackBar ก่อน pop ───
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e, st) {
      debugPrint('❌ [Exception] RegistrationAddPage save error: $e');
      debugPrint('❌ [Exception] StackTrace:\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: LaColors.statusRejectedFg,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔴 [RegistrationAddPage] _onSave() FINISHED');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
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
