// ============================================================================
// setting_menu_card.dart
// ============================================================================
// การ์ดเมนู 1 ใบ — ใช้ SetDecor.card() (เหมือน LaDecor.card())
// icon badge ซ้าย + title + subtitle + chevron ขวา (visual hint)
// ============================================================================

import 'package:flutter/material.dart';

import '../../../Setting_menu/setting_page/views/theme/setting_page_theme.dart';


class ReportMenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const ReportMenuCard({
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
        hoverColor: SetColors.primary.withOpacity(.04),
        child: Container(
          decoration: SetDecor.card(),
          padding: const EdgeInsets.all(SetSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // icon box + chevron row
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withOpacity(.12),
                      borderRadius: BorderRadius.circular(SetRadius.md),
                      border: Border.all(
                        color: color.withOpacity(.25),
                        width: 1,
                      ),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: SetColors.textMuted,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: SetSpace.md),
              Text(title, style: SetText.h2),
              const SizedBox(height: SetSpace.xs),
              Text(
                subtitle,
                style: SetText.bodyMuted,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
