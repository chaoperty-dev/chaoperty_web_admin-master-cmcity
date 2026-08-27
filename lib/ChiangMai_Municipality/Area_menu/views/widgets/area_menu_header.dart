// ============================================================================
// area_menu_header.dart
// ============================================================================
// Header ของหน้า "อนุมัติคำขอ"
// - Eyebrow + Title + subtitle (ไม่มีปุ่ม Create — ใช้สำหรับหน้าอนุมัติ)
// - ใช้ gradient + glow แทนการใช้พื้นหลังเรียบ
// ============================================================================

import 'package:flutter/material.dart';

import '../theme/area_menu_theme.dart';

class AreaMenuHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int? totalCount;
  const AreaMenuHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            LaColors.headerBg,
            LaColors.headerAccent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(LaRadius.lg),
        boxShadow: [
          BoxShadow(
            color: LaColors.primary.withOpacity(.15),
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
              color: LaColors.primary.withOpacity(.18),
              borderRadius: BorderRadius.circular(LaRadius.md),
              border: Border.all(
                color: LaColors.primaryAccent.withOpacity(.35),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.area_chart_rounded,
              color: LaColors.primaryAccent,
              size: 22,
            ),
          ),
          const SizedBox(width: LaSpace.md),
          // Title block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'AREA OVERVIEW',
                  style: LaText.label.copyWith(
                    color: LaColors.primaryAccent.withOpacity(.9),
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: LaText.h1.copyWith(
                    color: LaColors.textInverse,
                    fontSize: 20,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: LaText.caption.copyWith(
                      color: Colors.white.withOpacity(.65),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // Count badge
          if (totalCount != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.08),
                borderRadius: BorderRadius.circular(LaRadius.pill),
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
                    color: LaColors.primaryAccent,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$totalCount ล็อค',
                    style: LaText.bodyMuted.copyWith(
                      color: Colors.white,
                      fontFamily: LaText.fontBold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: LaSpace.sm),
          ],
        ],
      ),
    );
  }
}
