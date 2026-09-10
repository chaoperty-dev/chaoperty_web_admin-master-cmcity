// ============================================================================
// registration_pagination.dart
// ============================================================================
// ปุ่มเปลี่ยนหน้า (Prev / Next) — ดีไซน์ pill + label จำนวนรายการ
// (client-side pagination — slice จาก filtered list ใน VM)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/registration_theme.dart';
import '../../viewmodels/registration_view_model.dart';

class RegistrationPagination extends StatelessWidget {
  const RegistrationPagination({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistrationViewModel>();
    final canPrev = vm.currentPage > 1 && !vm.isLoading;
    final canNext = vm.currentPage < vm.computedLastPage && !vm.isLoading;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(
          horizontal: LaSpace.sm, vertical: LaSpace.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(color: LaColors.border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillButton(
            icon: Icons.chevron_left_rounded,
            enabled: canPrev,
            onTap: () => vm.goToPage(vm.currentPage - 1),
            tooltip: 'หน้าก่อนหน้า',
          ),
          const SizedBox(width: LaSpace.sm),
          _PageLabel(current: vm.currentPage, last: vm.computedLastPage),
          const SizedBox(width: LaSpace.sm),
          _PillButton(
            icon: Icons.chevron_right_rounded,
            enabled: canNext,
            onTap: () => vm.goToPage(vm.currentPage + 1),
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
      padding: const EdgeInsets.symmetric(horizontal: LaSpace.md, vertical: 6),
      decoration: BoxDecoration(
        color: LaColors.primaryLight,
        borderRadius: BorderRadius.circular(LaRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.menu_book_rounded,
            size: 13,
            color: LaColors.primaryDark,
          ),
          const SizedBox(width: 6),
          Text(
            'หน้า',
            style: LaText.caption.copyWith(color: LaColors.primaryDark),
          ),
          const SizedBox(width: 4),
          Text(
            '$current',
            style: const TextStyle(
              fontFamily: LaText.fontBold,
              fontSize: 13,
              color: LaColors.primaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            ' / $last',
            style: LaText.caption.copyWith(color: LaColors.primaryDark),
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
                  ? LaColors.surfaceMuted
                  : (_hover ? LaColors.primary : Colors.white),
              borderRadius: BorderRadius.circular(LaRadius.pill),
              border: Border.all(
                color: !active
                    ? LaColors.border
                    : (_hover ? LaColors.primary : LaColors.borderStrong),
                width: 1,
              ),
            ),
            child: Icon(
              widget.icon,
              size: 18,
              color: !active
                  ? LaColors.textMuted
                  : (_hover ? Colors.white : LaColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
