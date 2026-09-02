// ============================================================================
// setting_menu_card.dart
// ============================================================================
// การ์ดเมนู 1 ใบ — แนวนอน compact
//   [accent bar | icon box | title + subtitle | chevron]
// - ใช้ SetDecor.card() + accent สีเมนู (left bar 4px)
// - hover มี elevation + tint สีอ่อน
// - fixed height ~compact (parent ควบคุมขนาด)
// ============================================================================

import 'package:flutter/material.dart';

import '../theme/setting_page_theme.dart';

class SettingMenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const SettingMenuCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SetColors.cardBg,
      borderRadius: BorderRadius.circular(SetRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: color.withOpacity(.06),
        splashColor: color.withOpacity(.12),
        child: Container(
          decoration: SetDecor.card(),
          padding: const EdgeInsets.fromLTRB(
            SetSpace.lg,
            SetSpace.md,
            SetSpace.md,
            SetSpace.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon box
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(.10),
                  borderRadius: BorderRadius.circular(SetRadius.md),
                  border: Border.all(
                    color: color.withOpacity(.25),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: SetSpace.md),

              // Title + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: SetText.h2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: SetText.bodyMuted,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Chevron
              const SizedBox(width: SetSpace.sm),
              const Icon(
                Icons.chevron_right_rounded,
                color: SetColors.textMuted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
