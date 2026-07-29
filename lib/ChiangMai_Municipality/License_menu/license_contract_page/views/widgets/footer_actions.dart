// ============================================================================
// footer_actions.dart
// ============================================================================
// Footer bar — ปุ่ม "ยกเลิก" + "บันทึก" (gradient save)
// ============================================================================

import 'package:flutter/material.dart';

import '../theme/license_contract_theme.dart';

class FooterActions extends StatelessWidget {
  final bool readOnly;
  final int currentPage;
  final int totalPages;
  final VoidCallback? onNext;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  const FooterActions({
    super.key,
    required this.readOnly,
    this.currentPage = 1,
    this.totalPages = 2,
    this.onNext,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentPage >= totalPages;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: LcSpace.lg, vertical: LcSpace.md),
      decoration: const BoxDecoration(
        color: LcColors.surfaceMuted,
        border: Border(
          top: BorderSide(color: LcColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Hint text
          Icon(
            isLast ? Icons.task_alt_rounded : Icons.edit_note_rounded,
            size: 14,
            color: LcColors.textMuted,
          ),
          const SizedBox(width: 6),
          Text(
            readOnly
                ? 'โหมดดูอย่างเดียว'
                : isLast
                    ? 'พร้อมบันทึก'
                    : 'กรอกข้อมูลให้ครบถ้วนก่อนกดถัดไป',
            style: LcText.caption,
          ),
          const Spacer(),
          // Cancel (กดที่หน้า 2 → กลับหน้า 1 / หน้า 1 → ปิด)
          _CancelButton(
            label: currentPage > 1 ? 'ย้อนกลับ' : 'ยกเลิก',
            icon: currentPage > 1
                ? Icons.arrow_back_rounded
                : Icons.close_rounded,
            onTap: onCancel,
          ),
          const SizedBox(width: LcSpace.sm),
          // ปุ่มหลัก: ถัดไป (Step 1) หรือ บันทึก (Step 2)
          if (!readOnly)
            isLast
                ? _SaveButton(onTap: onSave)
                : _NextButton(onTap: onNext ?? () {}),
        ],
      ),
    );
  }
}

class _CancelButton extends StatefulWidget {
  final VoidCallback onTap;
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
          duration: LcAnimations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _hover ? LcColors.dangerLight : Colors.white,
            borderRadius: BorderRadius.circular(LcRadius.md),
            border: Border.all(
              color: _hover ? LcColors.danger : LcColors.borderStrong,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: _hover ? LcColors.danger : LcColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: _hover ? LcColors.danger : LcColors.textSecondary,
                  fontFamily: LcText.fontBold,
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
  final VoidCallback onTap;
  const _NextButton({required this.onTap});

  @override
  State<_NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<_NextButton> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: _down ? 0.97 : (_hover ? 1.02 : 1.0),
        duration: LcAnimations.fast,
        curve: Curves.easeOut,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _down = true),
          onTapCancel: () => setState(() => _down = false),
          onTapUp: (_) => setState(() => _down = false),
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _hover ? LcColors.primaryLight : Colors.white,
              borderRadius: BorderRadius.circular(LcRadius.md),
              border: Border.all(
                color: _hover ? LcColors.primary : LcColors.borderStrong,
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ถัดไป',
                  style: TextStyle(
                    color: _hover ? LcColors.primaryDark : LcColors.primary,
                    fontFamily: LcText.fontBold,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: _hover ? LcColors.primaryDark : LcColors.primary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SaveButton({required this.onTap});

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: _down ? 0.97 : (_hover ? 1.02 : 1.0),
        duration: LcAnimations.fast,
        curve: Curves.easeOut,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _down = true),
          onTapCancel: () => setState(() => _down = false),
          onTapUp: (_) => setState(() => _down = false),
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [LcColors.primaryAccent, LcColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(LcRadius.md),
              boxShadow: [
                BoxShadow(
                  color: LcColors.primary.withOpacity(.45),
                  blurRadius: _hover ? 14 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.22),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'บันทึก',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: LcText.fontBold,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
