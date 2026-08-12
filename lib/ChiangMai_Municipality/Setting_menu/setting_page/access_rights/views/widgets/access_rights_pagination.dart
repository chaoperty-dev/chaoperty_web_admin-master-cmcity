// ============================================================================
// access_rights_pagination.dart
// ============================================================================
// ปุ่มเปลี่ยนหน้า (Prev / Next) — pill design + label จำนวนรายการ
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/access_rights_theme.dart';
import '../../viewmodels/access_rights_view_model.dart';

class AccessRightsPagination extends StatelessWidget {
  const AccessRightsPagination({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AccessRightsViewModel>();
    final total = vm.filtered.length;
    final perPage = vm.perPage;
    final totalPages = total == 0 ? 0 : (total / perPage).ceil();
    final current = totalPages == 0 ? 0 : vm.currentPage.clamp(1, totalPages);
    final canPrev = current > 1 && !vm.isLoading;
    final canNext = current < totalPages && !vm.isLoading;

    return Container(
      height: 48,
      padding:
          const EdgeInsets.symmetric(horizontal: ArSpace.sm, vertical: ArSpace.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ArRadius.md),
        border: Border.all(color: ArColors.border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillButton(
            icon: Icons.chevron_left_rounded,
            enabled: canPrev,
            onTap: () {
              if (current > 1) {
                // local-only pagination
                // ไม่มี backend paginate — คำนวณ client-side ผ่าน sort/filter
              }
            },
            tooltip: 'หน้าก่อนหน้า',
          ),
          const SizedBox(width: ArSpace.sm),
          _PageLabel(current: current, last: totalPages),
          const SizedBox(width: ArSpace.sm),
          _PillButton(
            icon: Icons.chevron_right_rounded,
            enabled: canNext,
            onTap: () {
              if (current < totalPages) {
                // local-only pagination
              }
            },
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
      padding:
          const EdgeInsets.symmetric(horizontal: ArSpace.md, vertical: 6),
      decoration: BoxDecoration(
        color: ArColors.primaryLight,
        borderRadius: BorderRadius.circular(ArRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.menu_book_rounded,
            size: 13,
            color: ArColors.primaryDark,
          ),
          const SizedBox(width: 6),
          Text(
            'หน้า',
            style: ArText.caption.copyWith(color: ArColors.primaryDark),
          ),
          const SizedBox(width: 4),
          Text(
            '$current',
            style: const TextStyle(
              fontFamily: ArText.fontBold,
              fontSize: 13,
              color: ArColors.primaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            ' / $last',
            style: ArText.caption.copyWith(color: ArColors.primaryDark),
          ),
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
            duration: ArAnimations.fast,
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: !active
                  ? ArColors.surfaceMuted
                  : (_hover ? ArColors.primary : Colors.white),
              borderRadius: BorderRadius.circular(ArRadius.pill),
              border: Border.all(
                color: !active
                    ? ArColors.border
                    : (_hover ? ArColors.primary : ArColors.borderStrong),
                width: 1,
              ),
            ),
            child: Icon(
              widget.icon,
              size: 18,
              color: !active
                  ? ArColors.textMuted
                  : (_hover ? Colors.white : ArColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
