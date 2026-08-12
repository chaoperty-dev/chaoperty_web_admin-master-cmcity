// ============================================================================
// area_pagination.dart
// ============================================================================
// Pagination pill — สไตล์ license_payment (Prev / Next + page label)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/area_theme.dart';
import '../../viewmodels/area_view_model.dart';

class AreaPagination extends StatelessWidget {
  const AreaPagination({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AreaViewModel>();
    final canPrev = vm.currentPage > 1 && !vm.isLoading;
    final canNext = vm.currentPage < vm.totalPages && !vm.isLoading;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(
          horizontal: AeaSpace.sm, vertical: AeaSpace.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AeaRadius.md),
        border: Border.all(color: AeaColors.border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillButton(
            icon: Icons.chevron_left_rounded,
            enabled: canPrev,
            onTap: vm.previousPage,
            tooltip: 'หน้าก่อนหน้า',
          ),
          const SizedBox(width: AeaSpace.sm),
          _PageLabel(current: vm.currentPage, last: vm.totalPages),
          const SizedBox(width: AeaSpace.sm),
          _PillButton(
            icon: Icons.chevron_right_rounded,
            enabled: canNext,
            onTap: vm.nextPage,
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
      padding: const EdgeInsets.symmetric(horizontal: AeaSpace.md, vertical: 6),
      decoration: BoxDecoration(
        color: AeaColors.primaryLight,
        borderRadius: BorderRadius.circular(AeaRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.menu_book_rounded,
            size: 13,
            color: AeaColors.primaryDark,
          ),
          const SizedBox(width: 6),
          Text(
            'หน้า',
            style: AeaText.caption.copyWith(color: AeaColors.primaryDark),
          ),
          const SizedBox(width: 4),
          Text(
            '$current',
            style: const TextStyle(
              fontFamily: AeaText.fontBold,
              fontSize: 13,
              color: AeaColors.primaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            ' / $last',
            style: AeaText.caption.copyWith(color: AeaColors.primaryDark),
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
            duration: AeaAnimations.fast,
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: !active
                  ? AeaColors.surfaceMuted
                  : (_hover ? AeaColors.primary : Colors.white),
              borderRadius: BorderRadius.circular(AeaRadius.pill),
              border: Border.all(
                color: !active
                    ? AeaColors.border
                    : (_hover ? AeaColors.primary : AeaColors.borderStrong),
                width: 1,
              ),
            ),
            child: Icon(
              widget.icon,
              size: 18,
              color: !active
                  ? AeaColors.textMuted
                  : (_hover ? Colors.white : AeaColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
