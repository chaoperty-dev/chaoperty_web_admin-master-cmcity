// ============================================================================
// license_request_pagination.dart
// ============================================================================
// ปุ่มเปลี่ยนหน้า (Prev / Next) — pill ยืดหุบจากด้านข้าง
// Mobile: ยุบ `[ > ]` (ดีฟอลต์) → กดขยายเป็น `[ < 1/38 > ]`
// Desktop: pill เต็มเสมอ
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/license_request_theme.dart';
import '../../viewmodels/license_request_view_model.dart';

class LicenseRequestPagination extends StatefulWidget {
  const LicenseRequestPagination({super.key});

  @override
  State<LicenseRequestPagination> createState() =>
      _LicenseRequestPaginationState();
}

class _LicenseRequestPaginationState extends State<LicenseRequestPagination> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseRequestViewModel>();
    final canPrev = (vm.linksPrev?.isNotEmpty ?? false) && !vm.isLoading;
    final canNext = (vm.linksNext?.isNotEmpty ?? false) && !vm.isLoading;

    return LayoutBuilder(
      builder: (context, c) {
        final isMobile = c.maxWidth < 520;
        if (!isMobile) {
          return _buildPill(
            label: '${vm.currentPage} / ${vm.lastPage}',
            prev: _PillBtn(
              icon: Icons.chevron_left_rounded,
              enabled: canPrev,
              onTap: () => vm.loadPage(vm.linksPrev),
              tooltip: 'หน้าก่อนหน้า',
            ),
            next: _PillBtn(
              icon: Icons.chevron_right_rounded,
              enabled: canNext,
              onTap: () => vm.loadPage(vm.linksNext),
              tooltip: 'หน้าถัดไป',
            ),
          );
        }
        return _buildCollapsible(
          label: '${vm.currentPage} / ${vm.lastPage}',
          onPrev: () => vm.loadPage(vm.linksPrev),
          onNext: () => vm.loadPage(vm.linksNext),
          canPrev: canPrev,
          canNext: canNext,
        );
      },
    );
  }

  Widget _buildCollapsible({
    required String label,
    required VoidCallback onPrev,
    required VoidCallback onNext,
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
                          onPrev();
                          setState(() => _expanded = false);
                        },
                        tooltip: 'หน้าก่อนหน้า',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          label,
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
                          onNext();
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

  Widget _buildPill({
    required String label,
    required Widget prev,
    required Widget next,
  }) {
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
          prev,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: LrText.fontBold,
                fontSize: 13,
                color: LrColors.primaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          next,
        ],
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
