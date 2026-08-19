// ============================================================================
// license_announce_pagination.dart
// ============================================================================
// ปุ่มเปลี่ยนหน้า (Prev / Next) — pill ยืดหุบจากด้านข้าง
// ============================================================================

import 'package:flutter/material.dart';
import '../theme/license_announce_theme.dart';

class LicenseAnnouncePagination extends StatefulWidget {
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
  State<LicenseAnnouncePagination> createState() =>
      _LicenseAnnouncePaginationState();
}

class _LicenseAnnouncePaginationState extends State<LicenseAnnouncePagination> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final canPrev = widget.current > 1;
    final canNext = widget.current < widget.last;

    return LayoutBuilder(
      builder: (context, c) {
        final isMobile = c.maxWidth < 520;
        if (!isMobile) {
          return _buildFull(canPrev: canPrev, canNext: canNext);
        }
        return _buildCollapsible(canPrev: canPrev, canNext: canNext);
      },
    );
  }

  Widget _buildFull({required bool canPrev, required bool canNext}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LrRadius.md),
        border: Border.all(color: LrColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillBtn(
            icon: Icons.chevron_left_rounded,
            enabled: canPrev,
            onTap: widget.onPrev,
            tooltip: 'หน้าก่อนหน้า',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '${widget.current} / ${widget.last}',
              style: const TextStyle(
                fontFamily: LrText.fontBold,
                fontSize: 13,
                color: LrColors.primaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _PillBtn(
            icon: Icons.chevron_right_rounded,
            enabled: canNext,
            onTap: widget.onNext,
            tooltip: 'หน้าถัดไป',
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsible({
    required bool canPrev,
    required bool canNext,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LrRadius.md),
        border: Border.all(color: LrColors.border, width: 1),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(LrRadius.md),
          onTap: () => setState(() => _expanded = !_expanded),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: _expanded
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PillBtn(
                        icon: Icons.chevron_left_rounded,
                        enabled: canPrev,
                        onTap: () {
                          widget.onPrev();
                          setState(() => _expanded = false);
                        },
                        tooltip: 'หน้าก่อนหน้า',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '${widget.current} / ${widget.last}',
                          style: const TextStyle(
                            fontFamily: LrText.fontBold,
                            fontSize: 13,
                            color: LrColors.primaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _PillBtn(
                        icon: Icons.chevron_right_rounded,
                        enabled: canNext,
                        onTap: () {
                          widget.onNext();
                          setState(() => _expanded = false);
                        },
                        tooltip: 'หน้าถัดไป',
                      ),
                    ],
                  )
                : SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: LrColors.textSecondary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _PillBtn extends StatefulWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final String tooltip;
  const _PillBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.tooltip,
  });

  @override
  State<_PillBtn> createState() => _PillBtnState();
}

class _PillBtnState extends State<_PillBtn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.enabled;
    return MouseRegion(
      cursor: active ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (active && mounted) setState(() => _hover = true);
      },
      onExit: (_) {
        if (mounted) setState(() => _hover = false);
      },
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
