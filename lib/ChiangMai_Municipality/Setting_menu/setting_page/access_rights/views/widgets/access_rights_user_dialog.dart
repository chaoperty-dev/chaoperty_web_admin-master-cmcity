// ============================================================================
// access_rights_user_dialog.dart
// ============================================================================
// Dialog เพิ่ม/แก้ผู้ใช้ + Dialog จัดการลายเซ็น
// - ใช้ร่วมกับ AccessRightsViewModel (ส่งผ่าน constructor เพื่อแก้ปัญหา Provider scope)
// - Form validation เบื้องต้น (required, email format)
// - Signature pad จาก syncfusion_flutter_signaturepad
// ============================================================================

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

import '../theme/access_rights_theme.dart';
import '../../models/access_rights_position.dart';
import '../../models/access_rights_role.dart';
import '../../models/access_rights_user.dart';
import '../../viewmodels/access_rights_view_model.dart';

/// โหมดของ dialog
enum ArUserDialogMode { create, edit }

class AccessRightsUserDialog extends StatefulWidget {
  final ArUserDialogMode mode;
  final AccessRightsUser? initial;
  final AccessRightsViewModel viewModel;

  const AccessRightsUserDialog({
    super.key,
    required this.mode,
    this.initial,
    required this.viewModel,
  });

  @override
  State<AccessRightsUserDialog> createState() => _AccessRightsUserDialogState();
}

class _AccessRightsUserDialogState extends State<AccessRightsUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _prefix = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _citizenId = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _prepostion = TextEditingController();

  final GlobalKey<SfSignaturePadState> _signatureKey = GlobalKey();

  int? _positionId;
  final Set<int> _selectedRoleIds = <int>{};
  bool _submitting = false;
  bool _hasDrawn = false;

  @override
  void initState() {
    super.initState();
    if (widget.mode == ArUserDialogMode.edit && widget.initial != null) {
      final u = widget.initial!;
      _prefix.text = u.prefix;
      _firstName.text = u.firstName;
      _lastName.text = u.lastName;
      _phone.text = u.phone;
      _email.text = u.email;
      _citizenId.text = u.citizenId;
      _username.text = u.username;
      _prepostion.text = u.prepostion;
      _positionId = u.positionId;
      _selectedRoleIds.addAll(u.roles.map((r) => r.id));
    }
  }

  @override
  void dispose() {
    _prefix.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _email.dispose();
    _citizenId.dispose();
    _username.dispose();
    _password.dispose();
    _prepostion.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_positionId == null) {
      _showMessage('กรุณาเลือกลำดับการลงลายมือชื่อ');
      return;
    }
    final vm = widget.viewModel;
    // ตัดสิทธิ์ที่ไม่ได้ mapping กับตำแหน่งปัจจุบันออกก่อนส่ง (กัน prefill โหมดแก้ไข)
    final allowed = _allowedRoleIds(vm);
    if (allowed != null) {
      _selectedRoleIds.removeWhere((id) => !allowed.contains(id));
    }
    if (_selectedRoleIds.isEmpty) {
      _showMessage('กรุณาเลือกสิทธิ์อย่างน้อย 1 รายการ');
      return;
    }

    setState(() => _submitting = true);
    try {
      Uint8List signatureBytes = Uint8List(0);
      if (widget.mode == ArUserDialogMode.create) {
        try {
          signatureBytes = await _exportSignature() ?? Uint8List(0);
        } catch (_) {
          signatureBytes = Uint8List(0);
        }
        if (signatureBytes.isEmpty) {
          _showMessage('กรุณาวาดลายเซ็นก่อนบันทึก');
          return;
        }
      }

      final ok = widget.mode == ArUserDialogMode.create
          ? await vm.createUser(
              fileData: signatureBytes,
              username: _username.text.trim(),
              email: _email.text.trim(),
              password: _password.text,
              prefix: _prefix.text.trim(),
              firstName: _firstName.text.trim(),
              lastName: _lastName.text.trim(),
              citizenId: _citizenId.text.trim(),
              phone: _phone.text.trim(),
              prepostion: _prepostion.text.trim(),
              positionId: _positionId!,
              roleIds: _selectedRoleIds.toList(),
            )
          : await vm.updateUser(
              userUuid: widget.initial!.uuid,
              username: _username.text.trim(),
              email: _email.text.trim(),
              password: _password.text,
              prefix: _prefix.text.trim(),
              firstName: _firstName.text.trim(),
              lastName: _lastName.text.trim(),
              citizenId: _citizenId.text.trim(),
              phone: _phone.text.trim(),
              prepostion: _prepostion.text.trim(),
              positionId: _positionId!,
              roleIds: _selectedRoleIds.toList(),
            );
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pop(true);
      } else {
        _showMessage('บันทึกไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');
      }
    } catch (e) {
      if (mounted) _showMessage('เกิดข้อผิดพลาด: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<Uint8List?> _exportSignature() async {
    final state = _signatureKey.currentState;
    if (state == null) return null;
    final image = await state.toImage();
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ArColors.statusRejectedFg,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    final title = widget.mode == ArUserDialogMode.create
        ? 'เพิ่มผู้ใช้'
        : 'แก้ไขผู้ใช้';
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: ArColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ArRadius.lg),
      ),
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 760,
          maxHeight: screenHeight * 0.92,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Header (ตรึงบน) ───
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  ArSpace.lg, ArSpace.md, ArSpace.md, ArSpace.md),
              child: _dialogHeader(title),
            ),
            const Divider(height: 1, color: ArColors.border),

            // ─── Body (scroll) ───
            Flexible(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(ArSpace.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _sectionLabel('ข้อมูลส่วนตัว', Icons.person_outline_rounded),
                      const SizedBox(height: ArSpace.sm),
                      _formGrid(),
                      const SizedBox(height: ArSpace.lg),
                      _sectionLabel(
                          'ข้อมูลการเข้าสู่ระบบ', Icons.login_rounded),
                      const SizedBox(height: ArSpace.sm),
                      _accountGrid(),
                      const SizedBox(height: ArSpace.lg),
                      _sectionLabel('ลำดับการลงลายมือชื่อ',
                          Icons.format_list_numbered_rounded),
                      const SizedBox(height: ArSpace.sm),
                      _positionDropdown(vm.positions),
                      const SizedBox(height: ArSpace.lg),
                      _sectionLabel(
                          'สิทธิการเข้าถึง *', Icons.verified_user_outlined),
                      const SizedBox(height: ArSpace.sm),
                      _roleCheckList(vm.roles, vm),
                      const SizedBox(height: ArSpace.lg),
                      _sectionLabel('ลายมือชื่อ', Icons.draw_rounded),
                      const SizedBox(height: ArSpace.sm),
                      if (widget.mode == ArUserDialogMode.create)
                        _signaturePad()
                      else
                        _signatureHint(),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Footer (ตรึงล่าง) ───
            const Divider(height: 1, color: ArColors.border),
            Padding(
              padding: const EdgeInsets.all(ArSpace.md),
              child: _actionRow(),
            ),
          ],
        ),
      ),
    );
  }

  /// หัวข้อ section — icon box + label
  Widget _sectionLabel(String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ArColors.primary.withOpacity(.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: ArColors.primary),
        ),
        const SizedBox(width: 8),
        Text(text, style: ArText.h2.copyWith(fontSize: 14)),
      ],
    );
  }

  Widget _dialogHeader(String title) {
    final isCreate = widget.mode == ArUserDialogMode.create;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: ArColors.primary.withOpacity(.12),
            borderRadius: BorderRadius.circular(ArRadius.md),
            border: Border.all(color: ArColors.primary.withOpacity(.28)),
          ),
          child: Icon(
            isCreate ? Icons.person_add_rounded : Icons.edit_rounded,
            color: ArColors.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: ArSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: ArText.h1),
              Text(
                isCreate
                    ? 'กรอกข้อมูลผู้ใช้และกำหนดสิทธิ์การเข้าถึง'
                    : 'แก้ไขข้อมูลผู้ใช้และสิทธิ์การเข้าถึง',
                style: ArText.bodyMuted.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
        _CloseButton(onTap: () => Navigator.of(context).pop(false)),
      ],
    );
  }

  InputDecoration _inputDeco(String label) {
    OutlineInputBorder border([Color? color, double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color ?? ArColors.border, width: w),
        );
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: ArColors.textSecondary),
      filled: true,
      fillColor: ArColors.surfaceMuted.withOpacity(.35),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: border(),
      enabledBorder: border(),
      focusedBorder: border(ArColors.primary, 1.4),
      errorBorder: border(ArColors.statusRejectedFg),
      focusedErrorBorder: border(ArColors.statusRejectedFg, 1.4),
      isDense: true,
      counterText: '',
    );
  }

  Widget _formGrid() {
    Widget field(TextEditingController c, String label,
        {TextInputType? type,
        String? Function(String?)? validator,
        int? maxLen,
        bool digits = false,
        bool nameOnly = false}) {
      return TextFormField(
        controller: c,
        keyboardType: type,
        maxLength: maxLen,
        decoration: _inputDeco(label),
        inputFormatters: [
          // ชื่อ/นามสกุล — ได้เฉพาะตัวอักษรไทย+อังกฤษ (ตัดเว้นวรรค/อักขระพิเศษ)
          if (nameOnly)
            FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-Z฀-๿]')),
          if (digits) ...[
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(maxLen ?? 10),
          ],
        ],
        validator: validator ??
            (v) => (v == null || v.trim().isEmpty) ? 'กรุณากรอก$label' : null,
      );
    }

    return Column(
      children: [
        Row(children: [
          Expanded(child: field(_prefix, 'คำนำหน้าชื่อ', nameOnly: true)),
          const SizedBox(width: ArSpace.sm),
          Expanded(child: field(_firstName, 'ชื่อ (ไม่มีเว้นวรรค/อักขระพิเศษ)',
              nameOnly: true, maxLen: 50)),
        ]),
        const SizedBox(height: ArSpace.sm),
        Row(children: [
          Expanded(child: field(_lastName, 'นามสกุล (ไม่มีเว้นวรรค/อักขระพิเศษ)',
              nameOnly: true, maxLen: 50)),
          const SizedBox(width: ArSpace.sm),
          Expanded(
            child: field(
              _phone,
              'เบอร์โทร (0-9)',
              type: TextInputType.phone,
              digits: true,
              maxLen: 10,
              validator: (v) {
                final t = (v ?? '').trim();
                if (t.isEmpty) return 'กรุณากรอกเบอร์โทร';
                if (t.length < 9) return 'เบอร์โทรต้องมี 9-10 หลัก';
                return null;
              },
            ),
          ),
        ]),
      ],
    );
  }

  Widget _accountGrid() {
    Widget field(TextEditingController c, String label,
        {TextInputType? type,
        String? Function(String?)? validator,
        int? maxLen,
        bool digits = false,
        bool noSpace = false,
        bool englishOnly = false}) {
      return TextFormField(
        controller: c,
        keyboardType: type,
        maxLength: maxLen,
        decoration: _inputDeco(label),
        inputFormatters: [
          if (englishOnly)
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._\-]')),
          if (digits) FilteringTextInputFormatter.digitsOnly,
          if (noSpace) FilteringTextInputFormatter.deny(RegExp(r'\s')),
        ],
        validator: validator ??
            (v) => (v == null || v.trim().isEmpty) ? 'กรุณากรอก$label' : null,
      );
    }

    return Column(
      children: [
        Row(children: [
          Expanded(
            child: field(
              _email,
              'อีเมล (ห้ามเว้นวรรค)',
              type: TextInputType.emailAddress,
              noSpace: true,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'กรุณากรอกอีเมล';
                final r = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
                return r.hasMatch(v.trim()) ? null : 'รูปแบบอีเมลไม่ถูกต้อง';
              },
            ),
          ),
          const SizedBox(width: ArSpace.sm),
          Expanded(
            child: field(_citizenId, 'เลขบัตรประชาชน (0-9)',
                type: TextInputType.number, digits: true, maxLen: 13,
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return 'กรุณากรอกเลขบัตรประชาชน';
                  if (t.length != 13) return 'เลขบัตรประชาชนต้องมี 13 หลัก';
                  return null;
                }),
          ),
        ]),
        const SizedBox(height: ArSpace.sm),
        Row(children: [
          Expanded(
            child: field(
              _username,
              'ชื่อผู้ใช้ (username) — a-z, A-Z, 0-9 เท่านั้น',
              englishOnly: true,
              validator: (v) {
                final t = (v ?? '').trim();
                if (t.isEmpty) return 'กรุณากรอกชื่อผู้ใช้';
                final r = RegExp(r'^[a-zA-Z0-9._-]+$');
                if (!r.hasMatch(t)) {
                  return 'ใช้ได้เฉพาะอังกฤษ/ตัวเลข ห้ามเว้นวรรคและตัวอักษรไทย';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: ArSpace.sm),
          Expanded(
            child: TextFormField(
              controller: _password,
              obscureText: true,
              decoration: _inputDeco(widget.mode == ArUserDialogMode.edit
                  ? 'รหัสผ่าน (เว้นว่างไว้ถ้าไม่เปลี่ยน)'
                  : 'รหัสผ่าน (ห้ามเว้นวรรค)'),
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
              validator: (v) {
                if (widget.mode == ArUserDialogMode.create && (v == null || v.isEmpty)) {
                  return 'กรุณากรอกรหัสผ่าน';
                }
                if (v != null && v.isNotEmpty && v.length < 4) {
                  return 'รหัสผ่านต้องยาวอย่างน้อย 4 ตัวอักษร';
                }
                return null;
              },
            ),
          ),
        ]),
        const SizedBox(height: ArSpace.sm),
        field(_prepostion, 'ตำแหน่งเตรียม (prepostion)'),
      ],
    );
  }

  Widget _positionDropdown(List<AccessRightsPosition> positions) {
    if (positions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(ArSpace.md),
        decoration: ArDecor.softCard(),
        child: const Text('ยังไม่มีตำแหน่งในระบบ', style: ArText.bodyMuted),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: ArColors.surfaceMuted.withOpacity(.35),
        border: Border.all(color: ArColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: _positionId,
          hint: const Text('เลือกลำดับการลงลายมือชื่อ'),
          icon: const Icon(Icons.expand_more_rounded, color: ArColors.textSecondary),
          borderRadius: BorderRadius.circular(10),
          items: positions
              .map(
                (p) => DropdownMenuItem<int>(
                  value: p.id,
                  child: Text(
                    '${p.id}. ${p.nameTh}',
                    style: ArText.body.copyWith(fontSize: 13),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() {
            _positionId = v;
            // รีเซ็ตสิทธิ์ที่เลือกทุกครั้งที่เปลี่ยนลำดับ (เหมือนของเดิม)
            _selectedRoleIds.clear();
          }),
        ),
      ),
    );
  }

  /// id ของสิทธิ์ที่ mapping กับตำแหน่งปัจจุบัน (API v2 role-positions)
  /// — เอาเฉพาะ active == true
  /// - ถ้า mapping ว่าง (API fail) → คืน null = ไม่กรอง แสดงทุกสิทธิ์
  Set<int>? _allowedRoleIds(AccessRightsViewModel vm) {
    if (vm.rolePositions.isEmpty) return null;
    return {
      for (final rp in vm.rolePositions)
        if (rp.active && rp.positionId == _positionId) rp.roleId
    };
  }

  Widget _roleCheckList(
      List<AccessRightsRole> roles, AccessRightsViewModel vm) {
    // ยังไม่เลือกลำดับการลงลายมือชื่อ — เตือนก่อน (เหมือนของเดิม)
    if (_positionId == null) {
      return Container(
        padding: const EdgeInsets.all(ArSpace.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: ArColors.statusRejectedFg.withOpacity(.40), width: 1),
          color: ArColors.statusRejectedFg.withOpacity(.05),
        ),
        child: const Text(
          '** กรุณาเลือกลำดับการลงลายมือชื่อก่อน..!!',
          style: TextStyle(color: ArColors.statusRejectedFg, fontSize: 13),
        ),
      );
    }
    if (roles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(ArSpace.md),
        decoration: ArDecor.softCard(),
        child: const Text('ยังไม่มีสิทธิ์ในระบบ', style: ArText.bodyMuted),
      );
    }

    // แสดงเฉพาะสิทธิ์ที่ mapping กับตำแหน่งนี้ (v2 role-positions)
    // mapping ว่าง → แสดงทั้งหมด (fallback)
    final allowed = _allowedRoleIds(vm);
    final visible = allowed == null
        ? roles
        : roles.where((r) => allowed.contains(r.id)).toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final r in visible)
          _RoleChip(
            label: r.nameTh,
            selected: _selectedRoleIds.contains(r.id),
            onTap: () {
              setState(() {
                if (!_selectedRoleIds.add(r.id)) {
                  _selectedRoleIds.remove(r.id);
                }
              });
            },
          ),
      ],
    );
  }

  /// โหมดแก้ไข — ลายเซ็นจัดการผ่าน dialog ลายเซ็นแยก
  Widget _signatureHint() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ArColors.border),
        color: ArColors.surfaceMuted.withOpacity(.25),
      ),
      child: const Center(
        child: Text(
          'จัดการลายเซ็นผ่านปุ่ม "ลายเซ็น" ในตาราง',
          style: TextStyle(color: ArColors.textMuted, fontSize: 13),
        ),
      ),
    );
  }

  Widget _signaturePad() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ArColors.border),
        color: ArColors.surfaceMuted.withOpacity(.25),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Stack(
            children: [
              Listener(
                onPointerDown: (_) {
                  if (!_hasDrawn) setState(() => _hasDrawn = true);
                },
                child: SizedBox(
                  height: 180,
                  child: SfSignaturePad(
                    key: _signatureKey,
                    backgroundColor: Colors.white,
                    strokeColor: Colors.black87,
                    minimumStrokeWidth: 1.2,
                    maximumStrokeWidth: 3.0,
                  ),
                ),
              ),
              // hint (หายเมื่อเริ่มวาด)
              if (!_hasDrawn)
                const IgnorePointer(
                  child: SizedBox(
                    height: 180,
                    child: Center(
                      child: Text(
                        'เซ็นชื่อภายในกรอบนี้',
                        style: TextStyle(
                            color: ArColors.textMuted, fontSize: 13),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                _signatureKey.currentState?.clear();
                setState(() => _hasDrawn = false);
              },
              icon: const Icon(Icons.cleaning_services_rounded,
                  size: 16, color: ArColors.statusRejectedFg),
              label: const Text('ล้างลายเซ็น',
                  style: TextStyle(color: ArColors.statusRejectedFg)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _CancelButton(
          disabled: _submitting,
          onTap: () => Navigator.of(context).pop(false),
        ),
        const SizedBox(width: 12),
        _SaveButton(
          label: widget.mode == ArUserDialogMode.create
              ? 'เพิ่มผู้ใช้'
              : 'บันทึกการแก้ไข',
          loading: _submitting,
          onTap: _onSubmit,
        ),
      ],
    );
  }
}

/// ปุ่มยกเลิก — ขาวขอบเทา ไม่มีสี
class _CancelButton extends StatefulWidget {
  final bool disabled;
  final VoidCallback onTap;
  const _CancelButton({required this.disabled, required this.onTap});
  @override
  State<_CancelButton> createState() => _CancelButtonState();
}

class _CancelButtonState extends State<_CancelButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final enabled = !widget.disabled;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: ArAnimations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          decoration: BoxDecoration(
            color: _hover && enabled
                ? ArColors.surfaceMuted
                : Colors.white,
            borderRadius: BorderRadius.circular(ArRadius.md),
            border: Border.all(
              color: _hover && enabled
                  ? ArColors.textMuted.withOpacity(.5)
                  : ArColors.border,
              width: 1,
            ),
          ),
          child: Text(
            'ยกเลิก',
            style: TextStyle(
              fontSize: 13,
              fontFamily: ArText.fontBold,
              color: _hover && enabled
                  ? ArColors.textPrimary
                  : ArColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// ปุ่มบันทึก/เพิ่ม — เขียว hover เงา + loading spinner
class _SaveButton extends StatefulWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;
  const _SaveButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });
  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  bool _hover = false;
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    final enabled = !widget.loading;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: ArAnimations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          decoration: BoxDecoration(
            color: !enabled
                ? ArColors.primary.withOpacity(.55)
                : (_down
                    ? ArColors.primaryDark
                    : ArColors.primary),
            borderRadius: BorderRadius.circular(ArRadius.md),
            boxShadow: [
              if (_hover && enabled)
                BoxShadow(
                  color: ArColors.primary.withOpacity(.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.loading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              else
                const Icon(Icons.save_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 7),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: ArText.fontBold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chip สิทธิ์ — แสดงเฉพาะชื่อ (เลือก = เขียวทึบ)
class _RoleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: ArAnimations.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? ArColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? ArColors.primary : ArColors.border,
            width: 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: ArColors.primary.withOpacity(.30),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check_rounded,
                  size: 14, color: Colors.white),
              const SizedBox(width: 5),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontFamily: selected ? ArText.fontBold : ArText.fontRegular,
                  color: selected ? Colors.white : ArColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ปุ่มกลมปิด dialog — hover แดง (ใช้ร่วมทั้ง 2 dialog)
class _CloseButton extends StatefulWidget {
  final VoidCallback onTap;
  const _CloseButton({required this.onTap});

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: ArAnimations.fast,
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _hover
                ? ArColors.statusRejectedBg
                : ArColors.surfaceMuted.withOpacity(.6),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.close_rounded,
            size: 20,
            color: _hover
                ? ArColors.statusRejectedFg
                : ArColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Signature dialog (อัปโหลดลายเซ็น)
// ============================================================================
class AccessRightsSignatureDialog extends StatefulWidget {
  final AccessRightsUser user;
  final AccessRightsViewModel viewModel;

  const AccessRightsSignatureDialog({
    super.key,
    required this.user,
    required this.viewModel,
  });

  @override
  State<AccessRightsSignatureDialog> createState() =>
      _AccessRightsSignatureDialogState();
}

class _AccessRightsSignatureDialogState extends State<AccessRightsSignatureDialog> {
  final GlobalKey<SfSignaturePadState> _padKey = GlobalKey();
  bool _submitting = false;
  Uint8List? _existing;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final sigUuid = widget.user.signatureUuid;
    if (sigUuid == null || sigUuid.isEmpty) return;
    try {
      final bytes = await widget.viewModel.loadSignatureImage(sigUuid);
      if (!mounted || bytes == null) return;
      setState(() => _existing = bytes);
    } catch (_) {
      // โหลดลายเซ็นเดิมไม่ได้ — แสดงแค่ pad ว่าง (ไม่ block การใช้งาน)
    }
  }

  Future<void> _onSave() async {
    final state = _padKey.currentState;
    if (state == null) return;
    setState(() => _submitting = true);
    try {
      final image = await state.toImage();
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        _showSnack('ไม่สามารถสร้างภาพลายเซ็นได้');
        return;
      }
      final bytes = byteData.buffer.asUint8List();
      if (bytes.isEmpty) {
        _showSnack('กรุณาวาดลายเซ็นก่อนอัปโหลด');
        return;
      }
      final ok = await widget.viewModel.uploadSignature(
        userUuid: widget.user.uuid,
        fileData: bytes,
      );
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pop(true);
      } else {
        _showSnack('อัปโหลดลายเซ็นไม่สำเร็จ');
      }
    } catch (e) {
      if (mounted) _showSnack('เกิดข้อผิดพลาด: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ArColors.statusRejectedFg,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ArColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ArRadius.lg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(ArSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text('จัดการลายเซ็น', style: ArText.h1)),
                  _CloseButton(onTap: () => Navigator.of(context).pop(false)),
                ],
              ),
              const SizedBox(height: ArSpace.sm),
              Text(
                'ผู้ใช้: ${widget.user.username} (${widget.user.fullName})',
                style: ArText.bodyMuted,
              ),
              const SizedBox(height: ArSpace.md),
              if (_existing != null) ...[
                Text('ลายเซ็นปัจจุบัน',
                    style: ArText.h2.copyWith(fontSize: 14)),
                const SizedBox(height: ArSpace.sm),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: ArColors.border),
                    borderRadius: BorderRadius.circular(ArRadius.sm),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Image.memory(_existing!,
                      height: 120, fit: BoxFit.contain),
                ),
                const SizedBox(height: ArSpace.md),
                Text('วาดลายเซ็นใหม่',
                    style: ArText.h2.copyWith(fontSize: 14)),
                const SizedBox(height: ArSpace.sm),
              ] else
                Text('วาดลายเซ็น',
                    style: ArText.h2.copyWith(fontSize: 14)),
              const SizedBox(height: ArSpace.sm),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(color: ArColors.border),
                  borderRadius: BorderRadius.circular(ArRadius.md),
                ),
                padding: const EdgeInsets.all(8),
                child: SfSignaturePad(
                  key: _padKey,
                  backgroundColor: Colors.white,
                  strokeColor: Colors.black87,
                  minimumStrokeWidth: 1.2,
                  maximumStrokeWidth: 3.0,
                ),
              ),
              const SizedBox(height: ArSpace.sm),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _padKey.currentState?.clear(),
                  icon: const Icon(Icons.cleaning_services_rounded, size: 16),
                  label: const Text('ล้าง'),
                ),
              ),
              const SizedBox(height: ArSpace.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _submitting ? null : () => Navigator.of(context).pop(false),
                    child: const Text('ยกเลิก'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _submitting ? null : _onSave,
                    icon: _submitting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(Icons.upload_rounded, size: 16),
                    label: const Text('อัปโหลด'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ArColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
