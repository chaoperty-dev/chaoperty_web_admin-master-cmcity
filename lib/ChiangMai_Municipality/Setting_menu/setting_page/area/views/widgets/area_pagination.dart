// ============================================================================
// area_pagination.dart
// ============================================================================
// Pagination pill ยืดหุบจากด้านข้าง
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/area_theme.dart';
import '../../viewmodels/area_view_model.dart';

class AreaPagination extends StatefulWidget {
  const AreaPagination({super.key});

  @override
  State<AreaPagination> createState() => _AreaPaginationState();
}

class _AreaPaginationState extends State<AreaPagination> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AreaViewModel>();
    final canPrev = vm.currentPage > 1 && !vm.isLoading;
    final canNext = vm.currentPage < vm.totalPages && !vm.isLoading;

    return LayoutBuilder(
      builder: (context, c) {
        final isMobile = c.maxWidth < 520;
        if (!isMobile) {
          return _buildFull(label: '${vm.currentPage} / ${vm.totalPages}');
        }
        return _buildCollapsible(
          label: '${vm.currentPage} / ${vm.totalPages}',
          canPrev: canPrev,
          canNext: canNext,
        );
      },
    );
  }

  Widget _buildFull({required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AeaRadius.md),
        border: Border.all(color: AeaColors.border, width: 1),
      ),
      child: _RowContent(
        label: label,
        onPrev: null,
        onNext: null,
        canPrev: true,
        canNext: true,
      ),
    );
  }

  Widget _buildCollapsible({
    required String label,
    required bool canPrev,
    required bool canNext,
  }) {
    final vm = context.read<AreaViewModel>();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AeaRadius.md),
        border: Border.all(color: AeaColors.border, width: 1),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(AeaRadius.md),
          onTap: () => setState(() => _expanded = !_expanded),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: _expanded
                ? _RowContent(
                    label: label,
                    onPrev: () {
                      vm.previousPage();
                      setState(() => _expanded = false);
                    },
                    onNext: () {
                      vm.nextPage();
                      setState(() => _expanded = false);
                    },
                    canPrev: canPrev,
                    canNext: canNext,
                  )
                : SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AeaColors.textSecondary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _RowContent extends StatelessWidget {
  final String label;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final bool canPrev;
  final bool canNext;
  const _RowContent({
    required this.label,
    required this.onPrev,
    required this.onNext,
    required this.canPrev,
    required this.canNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PillBtn(
          icon: Icons.chevron_left_rounded,
          enabled: canPrev,
          onTap: onPrev,
          tooltip: 'หน้าก่อนหน้า',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: AeaText.fontBold,
              fontSize: 13,
              color: AeaColors.primaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _PillBtn(
          icon: Icons.chevron_right_rounded,
          enabled: canNext,
          onTap: onNext,
          tooltip: 'หน้าถัดไป',
        ),
      ],
    );
  }
}

class _PillBtn extends StatefulWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;
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
    final active = widget.enabled && widget.onTap != null;
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
          onTap: widget.onTap,
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
