// ============================================================================
// personal_information_signature_dialog.dart
// ============================================================================
// Dialog เซ็นลายเซ็น (ReusableSignaturePad) + ปุ่มบันทึก
// ============================================================================

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

import '../../../../unity/ReusableSignaturePad.dart';
import '../theme/personal_information_theme.dart';

class PersonalInformationSignatureDialog extends StatefulWidget {
  final Future<bool> Function(GlobalKey<SfSignaturePadState> key) onSave;

  const PersonalInformationSignatureDialog({
    super.key,
    required this.onSave,
  });

  /// เปิด dialog — คืน true ถ้าบันทึกสำเร็จ
  static Future<bool?> show({
    required BuildContext context,
    required Future<bool> Function(GlobalKey<SfSignaturePadState> key) onSave,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(.55),
      builder: (_) => PersonalInformationSignatureDialog(onSave: onSave),
    );
  }

  @override
  State<PersonalInformationSignatureDialog> createState() =>
      _PersonalInformationSignatureDialogState();
}

class _PersonalInformationSignatureDialogState
    extends State<PersonalInformationSignatureDialog> {
  final GlobalKey<SfSignaturePadState> _signatureKey = GlobalKey();
  bool _saving = false;

  Future<void> _handleSave() async {
    setState(() => _saving = true);
    try {
      final ok = await widget.onSave(_signatureKey);
      if (!mounted) return;
      if (ok) {
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = PiSpace.isMobile(context);
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PiRadius.xl),
      ),
      insetPadding: EdgeInsets.all(isMobile ? PiSpace.sm : PiSpace.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? PiSpace.md : PiSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Title ───
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: PiColors.primaryLight,
                      borderRadius: BorderRadius.circular(PiRadius.sm + 2),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: PiColors.primaryDark,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: PiSpace.md),
                  const Expanded(
                    child: Text('แก้ไขลายเซ็นผู้ใช้', style: PiText.h2),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: PiSpace.sm),
              Text(
                'เซ็นลายเซ็นของคุณในกรอบด้านล่าง แล้วกด "บันทึก"',
                style: PiText.caption,
              ),
              SizedBox(height: isMobile ? PiSpace.md : PiSpace.lg),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ReusableSignaturePad(
                    height: isMobile ? 140 : 180,
                    width: isMobile ? null : 500,
                    signatureKey: _signatureKey,
                    onClear: () => _signatureKey.currentState?.clear(),
                  ),
                ),
              ),
              SizedBox(height: isMobile ? PiSpace.md : PiSpace.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _saving ? null : () => Navigator.pop(context, false),
                    child: const Text('ยกเลิก'),
                  ),
                  const SizedBox(width: PiSpace.sm),
                  FilledButton.icon(
                    onPressed: _saving ? null : _handleSave,
                    icon: _saving
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 16),
                    label: const Text('บันทึก'),
                    style: FilledButton.styleFrom(
                      backgroundColor: PiColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: PiSpace.lg,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(PiRadius.sm + 2),
                      ),
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
