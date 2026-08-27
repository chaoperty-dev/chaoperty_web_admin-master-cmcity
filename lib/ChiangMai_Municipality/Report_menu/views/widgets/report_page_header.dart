// ============================================================================
// setting_page_header.dart
// ============================================================================
// Header ของหน้า SettingPage hub — ใช้ style เดียวกับ LicensefactcheckHeader
// (slate-900/slate-800 gradient + icon badge + eyebrow + title + subtitle)
// ============================================================================

import 'package:flutter/material.dart';

import '../../../Setting_menu/setting_page/views/theme/setting_page_theme.dart';

class ReportPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;

  const ReportPageHeader({
    super.key,
    this.icon = Icons.settings_rounded,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            SetColors.headerBg,
            SetColors.headerAccent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(SetRadius.lg),
        boxShadow: [
          BoxShadow(
            color: SetColors.primary.withOpacity(.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: SetColors.primary.withOpacity(.18),
              borderRadius: BorderRadius.circular(SetRadius.md),
              border: Border.all(
                color: SetColors.primaryAccent.withOpacity(.35),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: SetColors.primaryAccent,
              size: 22,
            ),
          ),
          const SizedBox(width: SetSpace.md),
          // Title block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SETTING',
                  style: SetText.label.copyWith(
                    color: SetColors.primaryAccent.withOpacity(.9),
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: SetText.h1.copyWith(
                    color: SetColors.textInverse,
                    fontSize: 20,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: SetText.caption.copyWith(
                      color: Colors.white.withOpacity(.65),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
