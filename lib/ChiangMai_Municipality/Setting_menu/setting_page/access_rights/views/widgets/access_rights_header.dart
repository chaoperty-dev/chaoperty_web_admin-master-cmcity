// ============================================================================
// access_rights_header.dart
// ============================================================================
// Header ของหน้า "สิทธิ์การเข้าถึง"
// - Eyebrow + Title + subtitle + count badge + ปุ่ม "เพิ่มผู้ใช้"
// ============================================================================

import 'package:flutter/material.dart';

import '../theme/access_rights_theme.dart';

class AccessRightsHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int? totalCount;
  final VoidCallback? onCreate;

  const AccessRightsHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.totalCount,
    this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ArColors.headerBg, ArColors.headerAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ArRadius.lg),
        boxShadow: [
          BoxShadow(
            color: ArColors.primary.withOpacity(.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: ArColors.primary.withOpacity(.18),
              borderRadius: BorderRadius.circular(ArRadius.md),
              border: Border.all(
                color: ArColors.primaryAccent.withOpacity(.35),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: ArColors.primaryAccent,
              size: 22,
            ),
          ),
          const SizedBox(width: ArSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ACCESS RIGHTS',
                  style: ArText.label.copyWith(
                    color: ArColors.primaryAccent.withOpacity(.9),
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: ArText.h1.copyWith(
                    color: ArColors.textInverse,
                    fontSize: 20,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: ArText.caption.copyWith(
                      color: Colors.white.withOpacity(.65),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (totalCount != null) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.08),
                borderRadius: BorderRadius.circular(ArRadius.pill),
                border: Border.all(
                  color: Colors.white.withOpacity(.18),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.format_list_numbered_rounded,
                    color: ArColors.primaryAccent,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$totalCount รายการ',
                    style: ArText.bodyMuted.copyWith(
                      color: Colors.white,
                      fontFamily: ArText.fontBold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: ArSpace.sm),
          ],
          if (onCreate != null) _CreateButton(onPressed: onCreate!),
        ],
      ),
    );
  }
}

class _CreateButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _CreateButton({required this.onPressed});

  @override
  State<_CreateButton> createState() => _CreateButtonState();
}

class _CreateButtonState extends State<_CreateButton> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: ArAnimations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _down
                ? ArColors.primaryDark
                : (_hover ? ArColors.primary : ArColors.primaryAccent),
            borderRadius: BorderRadius.circular(ArRadius.md),
            boxShadow: [
              if (_hover)
                BoxShadow(
                  color: ArColors.primary.withOpacity(.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_add_rounded,
                  color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                'เพิ่มผู้ใช้',
                style: ArText.bodyMuted.copyWith(
                  color: Colors.white,
                  fontFamily: ArText.fontBold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
