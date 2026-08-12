// ============================================================================
// license_announce_pagination.dart
// ============================================================================
// ปุ่มเปลี่ยนหน้า (Prev / Next) — pill + label จำนวนหน้า
// ============================================================================

import 'package:flutter/material.dart';
import '../theme/license_announce_theme.dart';

class LicenseAnnouncePagination extends StatelessWidget {
  final int current;
  final int last;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const LicenseAnnouncePagination({
    super.key,
    required this.current,
    required this.last,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final canPrev = current > 1;
    final canNext = current < last;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(
          horizontal: LrSpace.sm, vertical: LrSpace.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LrRadius.md),
        border: Border.all(color: LrColors.border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillButton(
            icon: Icons.chevron_left_rounded,
            enabled: canPrev,
            onTap: onPrev,
            tooltip: 'หน้าก่อนหน้า',
          ),
          const SizedBox(width: LrSpace.sm),
          _PageLabel(current: current, last: last),
          const SizedBox(width: LrSpace.sm),
          _PillButton(
            icon: Icons.chevron_right_rounded,
            enabled: canNext,
            onTap: onNext,
            tooltip: 'หน้าถัดไป',
          ),
        ],
      ),
    );
  }
}

class _PageLabel extends StatelessWidget {
  final int current;
  final int last;
  const _PageLabel({required this.current, required this.last});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: LrSpace.md, vertical: 6),
      decoration: BoxDecoration(
        color: LrColors.primaryLight,
        borderRadius: BorderRadius.circular(LrRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.menu_book_rounded,
            size: 13,
            color: LrColors.primaryDark,
          ),
          const SizedBox(width: 6),
          Text('หน้า',
              style: LrText.caption.copyWith(color: LrColors.primaryDark)),
          const SizedBox(width: 4),
          Text(
            '$current',
            style: const TextStyle(
              fontFamily: LrText.fontBold,
              fontSize: 13,
              color: LrColors.primaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(' / $last',
              style: LrText.caption.copyWith(color: LrColors.primaryDark)),
        ],
      ),
    );
  }
}

class _PillButton extends StatefulWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final String tooltip;
  const _PillButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.tooltip,
  });
  @override
  State<_PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<_PillButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final active = widget.enabled;
    return MouseRegion(
      cursor: active ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (active) setState(() => _hover = true);
      },
      onExit: (_) => setState(() => _hover = false),
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: active ? widget.onTap : null,
          child: AnimatedContainer(
            duration: LrAnimations.fast,
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: !active
                  ? LrColors.surfaceMuted
                  : (_hover ? LrColors.primary : Colors.white),
              borderRadius: BorderRadius.circular(LrRadius.pill),
              border: Border.all(
                color: !active
                    ? LrColors.border
                    : (_hover ? LrColors.primary : LrColors.borderStrong),
                width: 1,
              ),
            ),
            child: Icon(
              widget.icon,
              size: 18,
              color: !active
                  ? LrColors.textMuted
                  : (_hover ? Colors.white : LrColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
