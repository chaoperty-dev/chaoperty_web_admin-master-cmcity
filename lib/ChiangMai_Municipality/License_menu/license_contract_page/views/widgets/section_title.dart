// ============================================================================
// section_title.dart
// ============================================================================
// Section header (icon badge + title + optional subtitle)
// ใช้สำหรับแบ่งฟอร์มเป็นส่วนๆ เช่น "ข้อมูลผู้เช่า", "ข้อมูลร้านค้า"
// ============================================================================

import 'package:flutter/material.dart';

import '../theme/license_contract_theme.dart';

class SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;

  const SectionTitle({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = iconColor ?? LcColors.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LcSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: accent.withOpacity(.12),
              borderRadius: BorderRadius.circular(LcRadius.sm),
              border: Border.all(
                color: accent.withOpacity(.25),
                width: 1,
              ),
            ),
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(width: LcSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: LcText.h2.copyWith(fontSize: 14),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: LcText.caption),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
