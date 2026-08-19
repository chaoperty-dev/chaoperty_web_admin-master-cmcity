// ============================================================================
// access_rights_pagination.dart
// ============================================================================
// Pagination pill ยืดหุบจากด้านข้าง (local-only pagination)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/access_rights_theme.dart';
import '../../viewmodels/access_rights_view_model.dart';

class AccessRightsPagination extends StatefulWidget {
  const AccessRightsPagination({super.key});

  @override
  State<AccessRightsPagination> createState() => _AccessRightsPaginationState();
}

class _AccessRightsPaginationState extends State<AccessRightsPagination> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AccessRightsViewModel>();
    final total = vm.filtered.length;
    final perPage = vm.perPage;
    final totalPages = total == 0 ? 0 : (total / perPage).ceil();
    final current = totalPages == 0 ? 0 : vm.currentPage.clamp(1, totalPages);
    final canPrev = current > 1 && !vm.isLoading;
    final canNext = current < totalPages && !vm.isLoading;

    return LayoutBuilder(
      builder: (context, c) {
        final isMobile = c.maxWidth < 520;
        if (!isMobile) {
          return _buildFull(label: '$current / $totalPages');
        }
        return _buildCollapsible(
          label: '$current / $totalPages',
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
        borderRadius: BorderRadius.circular(ArRadius.md),
        border: Border.all(color: ArColors.border, width: 1),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ArRadius.md),
        border: Border.all(color: ArColors.border, width: 1),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(ArRadius.md),
          onTap: () => setState(() => _expanded = !_expanded),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: _expanded
                ? _RowContent(
                    label: label,
                    onPrev: () => setState(() => _expanded = false),
                    onNext: () => setState(() => _expanded = false),
                    canPrev: canPrev,
                    canNext: canNext,
                  )
                : const SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: ArColors.textSecondary,
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
              fontFamily: ArText.fontBold,
              fontSize: 13,
              color: ArColors.primaryDark,
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
