// ============================================================================
// personal_information_app_bar.dart
// ============================================================================
// Header แบบเดียวกับ LicensefactcheckHeader (หน้าหลัก ไม่ใช่ detail)
// - Rounded card + gradient + glow
// - Icon badge + eyebrow + title + subtitle
// - วางใน body ไม่ใช่ AppBar แบบ fixed
// ============================================================================

import 'package:flutter/material.dart';
import '../theme/personal_information_theme.dart';

class PersonalInformationAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? eyebrow;
  final IconData icon;
  final int? totalCount;
  final Widget? trailing;

  const PersonalInformationAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.eyebrow = 'PERSONAL INFORMATION',
    this.icon = Icons.badge_rounded,
    this.totalCount,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = PiSpace.isMobile(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        isMobile ? PiSpace.md : 20,
        isMobile ? PiSpace.sm : 16,
        isMobile ? PiSpace.md : 20,
        isMobile ? PiSpace.sm : 16,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [PiColors.headerBg, PiColors.headerAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(PiRadius.lg),
        boxShadow: [
          BoxShadow(
            color: PiColors.primary.withOpacity(.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon badge (ซ่อนใน mobile เพื่อประหยัดพื้นที่)
          if (!isMobile) ...[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: PiColors.primary.withOpacity(.18),
                borderRadius: BorderRadius.circular(PiRadius.md),
                border: Border.all(
                  color: PiColors.primaryAccent.withOpacity(.35),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: PiColors.primaryAccent, size: 22),
            ),
            const SizedBox(width: PiSpace.md),
          ],
          // Title block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isMobile)
                  Text(
                    eyebrow!.toUpperCase(),
                    style: PiText.label.copyWith(
                      color: PiColors.primaryAccent.withOpacity(.9),
                      letterSpacing: 1.6,
                    ),
                  ),
                SizedBox(height: isMobile ? 0 : 4),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 20,
                    fontWeight: FontWeight.w700,
                    color: PiColors.textInverse,
                    height: 1.2,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: PiText.caption.copyWith(
                      color: Colors.white.withOpacity(.65),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Count badge (ซ่อนใน mobile)
          if (totalCount != null && !isMobile) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.08),
                borderRadius: BorderRadius.circular(PiRadius.pill),
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
                    color: PiColors.primaryAccent,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$totalCount รายการ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'LINESeed1',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: PiSpace.sm),
          ],
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
