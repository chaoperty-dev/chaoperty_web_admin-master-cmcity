// ============================================================================
// customers_report_password_dialog.dart
// ============================================================================
// Dialog ถาม password ก่อน export Excel
// มี 2 โหมด: รหัสดีฟอลต์ @ChaoCmcity / ตั้งรหัสเอง
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/customers_report_theme.dart';

const String kDefaultPassword = '@ChaoCmcity';

sealed class PasswordResult {
  const PasswordResult();
}

class PasswordCancel extends PasswordResult {
  const PasswordCancel();
}

class PasswordNoPassword extends PasswordResult {
  const PasswordNoPassword();
}

class PasswordWithValue extends PasswordResult {
  final String password;
  const PasswordWithValue(this.password);
}

enum PasswordMode { useDefault, custom }

/// ✅ Validation: ตรวจสอบรหัสผ่านตาม policy
class PasswordValidator {
  // ✅ ใช้ double-quote ใน regex เพื่อหลีกเลี่ยงปัญหา single-quote ภายใน
  static final RegExp _lower = RegExp(r"[a-z]");
  static final RegExp _upper = RegExp(r"[A-Z]");
  static final RegExp _digit = RegExp(r"[0-9]");
  static final RegExp _special =
      RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/`~]');

  /// ตรวจทุกเงื่อนไขแบบ real-time
  static Map<String, bool> checkAll(String value) {
    return {
      'อย่างน้อย 6 ตัวอักษร': value.length >= 6,
      'ตัวพิมพ์เล็ก (a-z)': _lower.hasMatch(value),
      'ตัวพิมพ์ใหญ่ (A-Z)': _upper.hasMatch(value),
      'ตัวเลข (0-9)': _digit.hasMatch(value),
      'อักษรพิเศษ (!@#\$%^&*)': _special.hasMatch(value),
    };
  }

  /// คืน error message ถ้าไม่ผ่าน (null = ผ่าน)
  static String? validate(String value) {
    if (value.length < 6) return 'ต้องมีอย่างน้อย 6 ตัวอักษร';
    if (!_lower.hasMatch(value)) return 'ต้องมีตัวพิมพ์เล็ก (a-z)';
    if (!_upper.hasMatch(value)) return 'ต้องมีตัวพิมพ์ใหญ่ (A-Z)';
    if (!_digit.hasMatch(value)) return 'ต้องมีตัวเลข (0-9)';
    if (!_special.hasMatch(value)) {
      return 'ต้องมีอักษรพิเศษ (!@#\$%^&* ฯลฯ)';
    }
    return null;
  }
}

class CustomersReportPasswordDialog extends StatefulWidget {
  const CustomersReportPasswordDialog({super.key});

  static Future<PasswordResult> show(BuildContext context) async {
    final result = await showDialog<PasswordResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const CustomersReportPasswordDialog(),
    );
    return result ?? const PasswordCancel();
  }

  @override
  State<CustomersReportPasswordDialog> createState() =>
      _CustomersReportPasswordDialogState();
}

class _CustomersReportPasswordDialogState
    extends State<CustomersReportPasswordDialog> {
  PasswordMode _mode = PasswordMode.useDefault;
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _passwordCtrl.text = kDefaultPassword;
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String? _validatePassword() {
    if (_mode == PasswordMode.useDefault) return null;
    final pwd = _passwordCtrl.text;
    final error = PasswordValidator.validate(pwd);
    if (error != null) return error;
    if (_passwordCtrl.text != _confirmCtrl.text) {
      return 'รหัสผ่านยืนยันไม่ตรงกัน';
    }
    return null;
  }

  void _submit() {
    final error = _validatePassword();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_mode == PasswordMode.useDefault) {
      Navigator.of(context).pop(const PasswordWithValue(kDefaultPassword));
    } else {
      final pwd = _passwordCtrl.text;
      if (pwd.isEmpty) {
        Navigator.of(context).pop(const PasswordNoPassword());
      } else {
        Navigator.of(context).pop(PasswordWithValue(pwd));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCustom = _mode == PasswordMode.custom;
    final checks = isCustom
        ? PasswordValidator.checkAll(_passwordCtrl.text)
        : <String, bool>{};
    final allPass = isCustom && checks.values.every((v) => v);
    final matchConfirm = _passwordCtrl.text == _confirmCtrl.text;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CrRadius.md),
      ),
      elevation: 8,
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(CrSpace.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(CrRadius.md),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============ Header ============
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: CrColors.primaryLight,
                      borderRadius: BorderRadius.circular(CrRadius.sm),
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: CrColors.primaryDark,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ป้องกันไฟล์ด้วยรหัสผ่าน', style: CrText.h2),
                        const SizedBox(height: 2),
                        Text(
                          'เลือกรหัสดีฟอลต์หรือตั้งรหัสเอง',
                          style: CrText.bodyMuted.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: CrSpace.md),

              // ============ Radio choice ============
              Container(
                decoration: BoxDecoration(
                  color: CrColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(CrRadius.sm),
                ),
                child: Column(
                  children: [
                    RadioListTile<PasswordMode>(
                      value: PasswordMode.useDefault,
                      groupValue: _mode,
                      onChanged: (v) => setState(() => _mode = v!),
                      title: Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 16, color: Color(0xFFFFA000)),
                          const SizedBox(width: 6),
                          const Text('ใช้รหัสดีฟอลต์'),
                        ],
                      ),
                      subtitle: Text(
                        '@ChaoCmcity',
                        style: CrText.caption.copyWith(
                          fontFamily: 'monospace',
                          color: CrColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0),
                      dense: true,
                    ),
                    const Divider(height: 1),
                    RadioListTile<PasswordMode>(
                      value: PasswordMode.custom,
                      groupValue: _mode,
                      onChanged: (v) => setState(() {
                        _mode = v!;
                        _passwordCtrl.clear();
                        _confirmCtrl.clear();
                      }),
                      title: Row(
                        children: [
                          const Icon(Icons.edit_rounded,
                              size: 16, color: CrColors.primaryDark),
                          const SizedBox(width: 6),
                          const Text('ตั้งรหัสผ่านเอง'),
                        ],
                      ),
                      subtitle: const Text(
                        '>= 6 ตัว, ตัวเล็ก+ใหญ่+ตัวเลข+อักษรพิเศษ',
                        style: TextStyle(fontSize: 11),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0),
                      dense: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: CrSpace.md),

              // ============ Password field ============
              TextField(
                controller: _passwordCtrl,
                autofocus: _mode == PasswordMode.custom,
                readOnly: !isCustom,
                obscureText: _obscure,
                onChanged: (_) => setState(() {}),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(64),
                ],
                decoration: InputDecoration(
                  hintText: isCustom ? '••••••' : kDefaultPassword,
                  labelText: 'รหัสผ่าน',
                  prefixIcon: const Icon(Icons.key_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded),
                    onPressed: () =>
                        setState(() => _obscure = !_obscure),
                  ),
                  filled: true,
                  fillColor:
                      isCustom ? CrColors.surfaceMuted : const Color(0xFFEEEEEE),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(CrRadius.sm),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                ),
                onSubmitted: (_) => _submit(),
              ),

              // ============ Confirm field (custom only) ============
              if (isCustom) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _confirmCtrl,
                  obscureText: _obscureConfirm,
                  onChanged: (_) => setState(() {}),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(64),
                  ],
                  decoration: InputDecoration(
                    hintText: '••••••',
                    labelText: 'ยืนยันรหัสผ่าน',
                    prefixIcon: const Icon(Icons.key_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded),
                      onPressed: () => setState(
                          () => _obscureConfirm = !_obscureConfirm),
                    ),
                    filled: true,
                    fillColor: CrColors.surfaceMuted,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(CrRadius.sm),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    errorText: _confirmCtrl.text.isNotEmpty && !matchConfirm
                        ? 'รหัสผ่านไม่ตรงกัน'
                        : null,
                  ),
                ),
              ],

              // ============ Validation checklist (custom only) ============
              if (isCustom) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: allPass
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(CrRadius.sm),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        allPass ? '✓ รหัสผ่านผ่านเงื่อนไขทั้งหมด' : 'เงื่อนไขรหัสผ่าน:',
                        style: CrText.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: allPass
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFB07A00),
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...checks.entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Row(
                              children: [
                                Icon(
                                  e.value
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  size: 14,
                                  color: e.value
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFFB07A00),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    e.key,
                                    style: CrText.caption.copyWith(
                                      color: e.value
                                          ? const Color(0xFF2E7D32)
                                          : const Color(0xFF8B6E00),
                                      fontWeight: e.value
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: CrSpace.md),

              // ============ AES info box ============
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(CrRadius.sm),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined,
                        size: 16, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'ไฟล์จะถูก encrypt ด้วย AES — ผู้รับต้องกรอก password เพื่อเปิด',
                        style: CrText.caption.copyWith(
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: CrSpace.md),

              // ============ Buttons ============
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context)
                        .pop(const PasswordCancel()),
                    style: TextButton.styleFrom(
                      foregroundColor: CrColors.textSecondary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    child: const Text('ยกเลิก'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: const Text('ดาวน์โหลด'),
                    style: FilledButton.styleFrom(
                      backgroundColor: CrColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
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
