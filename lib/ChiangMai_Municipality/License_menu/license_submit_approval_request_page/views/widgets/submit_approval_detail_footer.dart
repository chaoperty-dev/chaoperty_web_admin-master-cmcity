// ============================================================================
// submit_approval_detail_footer.dart
// ============================================================================
// Footer bar — ปุ่ม "ย้อนกลับ" + "ถัดไป"
// - Step 2: ไม่มีปุ่มหลัก (ไม่มี save API) — ดู timeline อย่างเดียว
// ============================================================================

import 'package:flutter/material.dart';

import '../theme/license_submit_approval_theme.dart';

class SubmitApprovalDetailFooter extends StatelessWidget {
  final bool readOnly;
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onNext;
  final VoidCallback? onCancel;

  /// Label ของปุ่มถัดไป (Step 1)
  final String? nextLabel;

  const SubmitApprovalDetailFooter({
    super.key,
    this.readOnly = false,
    this.currentStep = 1,
    this.totalSteps = 2,
    this.onNext,
    this.onCancel,
    this.nextLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentStep >= totalSteps;
    final showNext = !readOnly && !isLast;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: LaSpace.lg, vertical: LaSpace.md),
      decoration: const BoxDecoration(
        color: LaColors.surfaceMuted,
        border: Border(
          top: BorderSide(color: LaColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Hint icon + text
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
                    ? 'กด "ย้อนกลับ" เพื่อกลับไปแก้ไข'
                    : 'กรุณาตรวจสอบข้อมูลให้ครบถ้วนก่อน',
            style: LaText.caption,
          ),
          const Spacer(),
          // Cancel (step > 1 → ย้อนกลับ, step 1 → ยกเลิก)
          _CancelButton(
            label: currentStep > 1 ? 'ย้อนกลับ' : 'ยกเลิก',
            icon: currentStep > 1
                ? Icons.arrow_back_rounded
                : Icons.close_rounded,
            onTap: onCancel,
          ),
          if (showNext) ...[
            const SizedBox(width: LaSpace.sm),
            _NextButton(
              label: nextLabel ?? 'ขั้นตอนการอนุมัติ',
              onTap: onNext,
            ),
          ],
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
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

/// ปุ่ม "ถัดไป" — outlined style (รองจากบันทึก)
class _NextButton extends StatefulWidget {
  final VoidCallback? onTap;
  final String label;
  const _NextButton({
    required this.onTap,
    this.label = 'ถัดไป',
  });

  @override
  State<_NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<_NextButton> {
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
              Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: LaColors.primaryDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
