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
    if (_selectedRoleIds.isEmpty) {
      _showMessage('กรุณาเลือกสิทธิ์อย่างน้อย 1 รายการ');
      return;
    }

    Uint8List signatureBytes = Uint8List(0);
    if (widget.mode == ArUserDialogMode.create) {
      signatureBytes = await _exportSignature() ?? Uint8List(0);
      if (signatureBytes.isEmpty) {
        _showMessage('กรุณาวาดลายเซ็นก่อนบันทึก');
        return;
      }
    }

    setState(() => _submitting = true);
    final vm = widget.viewModel;
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
    setState(() => _submitting = false);
    if (ok) Navigator.of(context).pop(true);
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

    return Dialog(
      backgroundColor: ArColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ArRadius.lg),
      ),
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.all(ArSpace.lg),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _dialogHeader(title),
                  const SizedBox(height: ArSpace.md),
                  _formGrid(),
                  const SizedBox(height: ArSpace.lg),
                  Text('ลำดับการลงลายมือชื่อ',
                      style: ArText.h2.copyWith(fontSize: 14)),
                  const SizedBox(height: ArSpace.sm),
                  _positionDropdown(vm.positions),
                  const SizedBox(height: ArSpace.lg),
                  Text('สิทธิการเข้าถึง ( *กรุณากำหนดสิทธิ )',
                      style: ArText.h2.copyWith(fontSize: 14)),
                  const SizedBox(height: ArSpace.sm),
                  _roleCheckList(vm.roles),
                  if (widget.mode == ArUserDialogMode.create) ...[
                    const SizedBox(height: ArSpace.lg),
                    Text('ลายมือชื่อ', style: ArText.h2.copyWith(fontSize: 14)),
                    const SizedBox(height: ArSpace.sm),
                    _signaturePad(),
                  ],
                  const SizedBox(height: ArSpace.lg),
                  _actionRow(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dialogHeader(String title) {
    return Row(
      children: [
        Expanded(child: Text(title, style: ArText.h1)),
        IconButton(
          icon: const Icon(Icons.close_rounded),
          color: ArColors.textMuted,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }

  Widget _formGrid() {
    Widget field(TextEditingController c, String label,
        {TextInputType? type, String? Function(String?)? validator, int? maxLen}) {
      return TextFormField(
        controller: c,
        keyboardType: type,
        maxLength: maxLen,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13, color: ArColors.textSecondary),
          border: const OutlineInputBorder(),
          isDense: true,
          counterText: '',
        ),
        inputFormatters: type == TextInputType.number
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        validator: validator ??
            (v) => (v == null || v.trim().isEmpty) ? 'กรุณากรอก$label' : null,
      );
    }

    return Column(
      children: [
        Row(children: [
          Expanded(child: field(_prefix, 'คำนำหน้า', validator: (_) => null)),
          const SizedBox(width: ArSpace.sm),
          Expanded(child: field(_firstName, 'ชื่อ')),
        ]),
        const SizedBox(height: ArSpace.sm),
        Row(children: [
          Expanded(child: field(_lastName, 'นามสกุล')),
          const SizedBox(width: ArSpace.sm),
          Expanded(child: field(_phone, 'เบอร์โทร', type: TextInputType.phone)),
        ]),
        const SizedBox(height: ArSpace.sm),
        Row(children: [
          Expanded(
            child: field(
              _email,
              'อีเมล',
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'กรุณากรอกอีเมล';
                final r = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
                return r.hasMatch(v.trim()) ? null : 'รูปแบบอีเมลไม่ถูกต้อง';
              },
            ),
          ),
          const SizedBox(width: ArSpace.sm),
          Expanded(child: field(_citizenId, 'เลขบัตรประชาชน', type: TextInputType.number, maxLen: 13)),
        ]),
        const SizedBox(height: ArSpace.sm),
        Row(children: [
          Expanded(child: field(_username, 'ชื่อผู้ใช้ (username)')),
          const SizedBox(width: ArSpace.sm),
          Expanded(
            child: TextFormField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(
                labelText: widget.mode == ArUserDialogMode.edit
                    ? 'รหัสผ่าน (เว้นว่างไว้ถ้าไม่เปลี่ยน)'
                    : 'รหัสผ่าน',
                labelStyle: const TextStyle(fontSize: 13, color: ArColors.textSecondary),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
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
        field(_prepostion, 'ตำแหน่งเตรียม (prepostion)', validator: (_) => null),
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
        border: Border.all(color: ArColors.border),
        borderRadius: BorderRadius.circular(ArRadius.sm),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: _positionId,
          hint: const Text('เลือกลำดับการลงลายมือชื่อ'),
          items: positions
              .map(
                (p) => DropdownMenuItem<int>(
                  value: p.id,
                  child: Text('${p.id}. ${p.nameTh}'),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _positionId = v),
        ),
      ),
    );
  }

  Widget _roleCheckList(List<AccessRightsRole> roles) {
    if (roles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(ArSpace.md),
        decoration: ArDecor.softCard(),
        child: const Text('ยังไม่มีสิทธิ์ในระบบ', style: ArText.bodyMuted),
      );
    }
    return Container(
      decoration: ArDecor.softCard(),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          for (final r in roles)
            CheckboxListTile(
              dense: true,
              value: _selectedRoleIds.contains(r.id),
              onChanged: (v) {
                setState(() {
                  if (v == true) {
                    _selectedRoleIds.add(r.id);
                  } else {
                    _selectedRoleIds.remove(r.id);
                  }
                });
              },
              title: Text(
                '${r.nameTh}  (level ${r.level})',
                style: const TextStyle(fontSize: 13),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
        ],
      ),
    );
  }

  Widget _signaturePad() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(ArRadius.md),
        border: Border.all(color: ArColors.border),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: SfSignaturePad(
              key: _signatureKey,
              backgroundColor: Colors.white,
              strokeColor: Colors.black87,
              minimumStrokeWidth: 1.2,
              maximumStrokeWidth: 3.0,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _signatureKey.currentState?.clear(),
              icon: const Icon(Icons.cleaning_services_rounded, size: 16),
              label: const Text('ล้างลายเซ็น'),
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
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(false),
          child: const Text('ยกเลิก'),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: _submitting ? null : _onSubmit,
          icon: _submitting
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : const Icon(Icons.save_rounded, size: 16),
          label: Text(widget.mode == ArUserDialogMode.create ? 'เพิ่มผู้ใช้' : 'บันทึกการแก้ไข'),
          style: ElevatedButton.styleFrom(
            backgroundColor: ArColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
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
    final bytes = await widget.viewModel.loadSignatureImage(sigUuid);
    if (!mounted || bytes == null) return;
    setState(() => _existing = bytes);
  }

  Future<void> _onSave() async {
    final state = _padKey.currentState;
    if (state == null) return;
    final image = await state.toImage();
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;
    final bytes = byteData.buffer.asUint8List();
    if (bytes.isEmpty) return;
    setState(() => _submitting = true);
    final ok = await widget.viewModel.uploadSignature(
      userUuid: widget.user.uuid,
      fileData: bytes,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) Navigator.of(context).pop(true);
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
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
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
