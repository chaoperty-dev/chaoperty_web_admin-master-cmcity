// ============================================================================
// registration_pagination.dart
// ============================================================================
// ปุ่มเปลี่ยนหน้า (Prev / Next) — pill แบบยืดหุบจากด้านข้าง
//
// Mobile (default ยุบ):
//   - ยุบ = pill เล็กๆ `[ > ]` มีเฉพาะไอคอนขยาย
//   - กด > → ขยายเป็น `[ < 1 / 38 > ]` ในแนวนอน (inline กับ search bar)
//   - กด < → ยุบกลับ
//
// Desktop:
//   - แสดง pill เต็มตลอด
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/registration_theme.dart';
import '../../viewmodels/registration_view_model.dart';

class RegistrationPagination extends StatefulWidget {
  const RegistrationPagination({super.key});

  @override
  State<RegistrationPagination> createState() => _RegistrationPaginationState();
}

class _RegistrationPaginationState extends State<RegistrationPagination> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistrationViewModel>();
    final canPrev = vm.currentPage > 1 && !vm.isLoading;
    final canNext = vm.currentPage < vm.computedLastPage && !vm.isLoading;
    final last = vm.computedLastPage == 0 ? 1 : vm.computedLastPage;

    final prev = _PillIconButton(
      icon: Icons.chevron_left_rounded,
      enabled: canPrev,
      onTap: () => vm.goToPage(vm.currentPage - 1),
      tooltip: 'หน้าก่อนหน้า',
    );
    final next = _PillIconButton(
      icon: Icons.chevron_right_rounded,
      enabled: canNext,
      onTap: () => vm.goToPage(vm.currentPage + 1),
      tooltip: 'หน้าถัดไป',
    );

    return LayoutBuilder(
      builder: (context, c) {
        final isMobile = c.maxWidth < 520;
        if (!isMobile) {
          // Desktop — pill เต็มเสมอ
          return _FullPaginationPill(
            prev: prev,
            next: next,
            label: '${vm.currentPage} / $last',
          );
        }

        // Mobile — pill ยืด/หุบ
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(LaRadius.md),
            border: Border.all(color: LaColors.border, width: 1),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(LaRadius.md),
              onTap: () => setState(() => _expanded = !_expanded),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: _expanded
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ปุ่ม < — กดแล้วหุบกลับ
                          _PillIconButton(
                            icon: Icons.chevron_left_rounded,
                            enabled: canPrev,
                            onTap: () {
                              vm.goToPage(vm.currentPage - 1);
                              setState(() => _expanded = false);
                            },
                            tooltip: 'หน้าก่อนหน้า',
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              '${vm.currentPage} / $last',
                              style: const TextStyle(
                                fontFamily: LaText.fontBold,
                                fontSize: 13,
                                color: LaColors.primaryDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          _PillIconButton(
                            icon: Icons.chevron_right_rounded,
                            enabled: canNext,
                            onTap: () {
                              vm.goToPage(vm.currentPage + 1);
                              setState(() => _expanded = false);
                            },
                            tooltip: 'หน้าถัดไป',
                          ),
                        ],
                      )
                    : _IconPill(
                        icon: Icons.chevron_right_rounded,
                        onTap: () => setState(() => _expanded = true),
                        tooltip: 'ขยาย pagination',
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Desktop pill — เต็มเสมอ
class _FullPaginationPill extends StatelessWidget {
  final Widget prev;
  final Widget next;
  final String label;

  const _FullPaginationPill({
    required this.prev,
    required this.next,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(color: LaColors.border, width: 1),
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
                fontFamily: LaText.fontBold,
                fontSize: 13,
                color: LaColors.primaryDark,
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

/// Pill เล็ก (mobile collapsed) — มีแค่ ไอคอน
class _IconPill extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _IconPill({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(icon, size: 18, color: LaColors.textSecondary),
      ),
    );
  }
}

class _PillIconButton extends StatefulWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final String tooltip;
  const _PillIconButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.tooltip,
  });

  @override
  State<_PillIconButton> createState() => _PillIconButtonState();
}

class _PillIconButtonState extends State<_PillIconButton> {
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
