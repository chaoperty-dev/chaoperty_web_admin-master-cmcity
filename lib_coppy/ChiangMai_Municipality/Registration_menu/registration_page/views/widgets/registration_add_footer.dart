// ============================================================================
// registration_add_footer.dart
// ============================================================================
// Footer bar — ปุ่ม "ย้อนกลับ / ยกเลิก" + "ถัดไป" / "บันทึก"
// (เหมือน RequestDetailFooter ของ License_menu)
// ============================================================================

import 'package:flutter/material.dart';

import '../theme/registration_theme.dart';

class RegistrationAddFooter extends StatelessWidget {
  final bool readOnly;
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onNext;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final String? nextLabel;
  final String? saveLabel;

  const RegistrationAddFooter({
    super.key,
    this.readOnly = false,
    this.currentStep = 1,
    this.totalSteps = 2,
    this.onNext,
    this.onSave,
    this.onCancel,
    this.nextLabel,
    this.saveLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentStep >= totalSteps;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: LaSpace.lg, vertical: LaSpace.md),
      decoration: const BoxDecoration(
        color: LaColors.surfaceMuted,
        border: Border(top: BorderSide(color: LaColors.border, width: 1)),
      ),
      child: Row(
        children: [
          Icon(
            isLast ? Icons.task_alt_rounded : Icons.edit_note_rounded,
            size: 14,
            color: LaColors.textMuted,
          ),
          const SizedBox(width: 6),
          Text(
            readOnly
                ? 'โหมดดูอย่างเดียว'
                : isLast
                    ? 'พร้อมบันทึก'
                    : 'กรอกข้อมูลให้ครบถ้วนก่อนกดถัดไป',
            style: LaText.caption,
          ),
          const Spacer(),
          _CancelButton(
            label: currentStep > 1 ? 'ย้อนกลับ' : 'ยกเลิก',
            icon: currentStep > 1
                ? Icons.arrow_back_rounded
                : Icons.close_rounded,
            onTap: onCancel,
          ),
          const SizedBox(width: LaSpace.sm),
          if (!readOnly)
            isLast
                ? _SaveButton(label: saveLabel ?? 'บันทึก', onTap: onSave)
                : _NextButton(label: nextLabel ?? 'ถัดไป', onTap: onNext),
        ],
      ),
    );
  }
}

class _CancelButton extends StatefulWidget {
  final VoidCallback? onTap;
  final String label;
  final IconData icon;
  const _CancelButton({
    required this.onTap,
    this.label = 'ยกเลิก',
    this.icon = Icons.close_rounded,
  });

  @override
  State<_CancelButton> createState() => _CancelButtonState();
}

class _CancelButtonState extends State<_CancelButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.label,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(LaRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _hover ? LaColors.statusRejectedBg : Colors.white,
            borderRadius: BorderRadius.circular(LaRadius.md),
            border: Border.all(
              color: _hover ? LaColors.statusRejectedFg : LaColors.borderStrong,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 16,
                color:
                    _hover ? LaColors.statusRejectedFg : LaColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: _hover
                      ? LaColors.statusRejectedFg
                      : LaColors.textSecondary,
                  fontFamily: LaText.fontBold,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextButton extends StatefulWidget {
  final VoidCallback? onTap;
  final String label;
  const _NextButton({required this.onTap, this.label = 'ถัดไป'});

  @override
  State<_NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<_NextButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.label,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(LaRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: _hover
                ? LaColors.primary.withOpacity(.12)
                : LaColors.primaryLight,
            borderRadius: BorderRadius.circular(LaRadius.md),
            border: Border.all(
              color: _hover ? LaColors.primary : LaColors.primaryDark,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  color: LaColors.primaryDark,
                  fontFamily: LaText.fontBold,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_rounded,
                  size: 16, color: LaColors.primaryDark),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatefulWidget {
  final VoidCallback? onTap;
  final String label;
  const _SaveButton({required this.onTap, this.label = 'บันทึก'});

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.label,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(LaRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: _hover
                ? LaColors.primary.withOpacity(.12)
                : LaColors.primaryLight,
            borderRadius: BorderRadius.circular(LaRadius.md),
            border: Border.all(
              color: _hover ? LaColors.primary : LaColors.primaryDark,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  color: LaColors.primaryDark,
                  fontFamily: LaText.fontBold,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.check_rounded,
                  size: 16, color: LaColors.primaryDark),
            ],
          ),
        ),
      ),
    );
  }
}
