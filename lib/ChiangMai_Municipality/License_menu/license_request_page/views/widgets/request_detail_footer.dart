// ============================================================================
// request_detail_footer.dart
// ============================================================================
// Footer bar — ปุ่ม "ย้อนกลับ" + "ถัดไป" / "บันทึก"
// (ใช้ Lr* tokens ของ request_page)
// ============================================================================

import 'package:flutter/material.dart';

import '../theme/license_request_theme.dart';

class RequestDetailFooter extends StatelessWidget {
  final bool readOnly;
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onNext;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final String? nextLabel;
  final String? saveLabel;

  const RequestDetailFooter({
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
          horizontal: LrSpace.lg, vertical: LrSpace.md),
      decoration: const BoxDecoration(
        color: LrColors.surfaceMuted,
        border: Border(top: BorderSide(color: LrColors.border, width: 1)),
      ),
      child: Row(
        children: [
          Icon(
            isLast ? Icons.task_alt_rounded : Icons.edit_note_rounded,
            size: 14,
            color: LrColors.textMuted,
          ),
          const SizedBox(width: 6),
          Text(
            readOnly
                ? 'โหมดดูอย่างเดียว'
                : isLast
                    ? 'พร้อมบันทึก'
                    : 'กรอกข้อมูลให้ครบถ้วนก่อนกดถัดไป',
            style: LrText.caption,
          ),
          const Spacer(),
          _CancelButton(
            label: currentStep > 1 ? 'ย้อนกลับ' : 'ยกเลิก',
            icon: currentStep > 1
                ? Icons.arrow_back_rounded
                : Icons.close_rounded,
            onTap: onCancel,
          ),
          const SizedBox(width: LrSpace.sm),
          // ✅ ปุ่มบันทึก: ตอมเม้นปิดไว้ชั่วคราว (ยังไม่พร้อมใช้งาน)
          // - Step 1 → แสดงปุ่ม "ถัดไป"
          // - Step 2 (last) → ไม่แสดงปุ่ม "บันทึก" (เฉพาะปุ่ม "ยกเลิก" แสดงอย่างเดียว)
          if (!readOnly && !isLast)
            _NextButton(label: nextLabel ?? 'ถัดไป', onTap: onNext),
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
            color: _hover ? LrColors.statusRejectedBg : Colors.white,
            borderRadius: BorderRadius.circular(LrRadius.md),
            border: Border.all(
              color: _hover ? LrColors.statusRejectedFg : LrColors.borderStrong,
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
                    _hover ? LrColors.statusRejectedFg : LrColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: _hover
                      ? LrColors.statusRejectedFg
                      : LrColors.textSecondary,
                  fontFamily: LrText.fontBold,
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
                ? LrColors.primary.withOpacity(.12)
                : LrColors.primaryLight,
            borderRadius: BorderRadius.circular(LrRadius.md),
            border: Border.all(
              color: _hover ? LrColors.primary : LrColors.primaryDark,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  color: LrColors.primaryDark,
                  fontFamily: LrText.fontBold,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.arrow_forward_rounded,
                  size: 16, color: LrColors.primaryDark),
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _hover
                  ? [LrColors.primaryDark, LrColors.primary]
                  : [LrColors.primary, LrColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(LrRadius.md),
            boxShadow: [
              BoxShadow(
                color: LrColors.primary.withOpacity(_hover ? .35 : .25),
                blurRadius: _hover ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded,
                  size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: LrText.fontBold,
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
