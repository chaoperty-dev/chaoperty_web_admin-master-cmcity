// ============================================================================
// registration_header.dart
// ============================================================================
// Header ของหน้า "ทะเบียน"
// - Eyebrow + Title + subtitle (ไม่มีปุ่ม Create)
// - ใช้ gradient + glow เหมือน License_menu
// ============================================================================

import 'package:flutter/material.dart';

import '../theme/registration_theme.dart';

class RegistrationHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int? totalCount;
  final VoidCallback? onAdd;
  const RegistrationHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.totalCount,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            RgColors.headerBg,
            RgColors.headerAccent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(RgRadius.lg),
        boxShadow: [
          BoxShadow(
            color: RgColors.primary.withOpacity(.15),
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
              color: RgColors.primary.withOpacity(.18),
              borderRadius: BorderRadius.circular(RgRadius.md),
              border: Border.all(
                color: RgColors.primaryAccent.withOpacity(.35),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.app_registration_rounded,
              color: RgColors.primaryAccent,
              size: 22,
            ),
          ),
          const SizedBox(width: RgSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'REGISTRATION',
                  style: RgText.label.copyWith(
                    color: RgColors.primaryAccent.withOpacity(.9),
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: RgText.h1.copyWith(
                    color: RgColors.textInverse,
                    fontSize: 20,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: RgText.caption.copyWith(
                      color: Colors.white.withOpacity(.65),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // ─── Total count badge ───
          if (totalCount != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.10),
                borderRadius: BorderRadius.circular(RgRadius.pill),
                border: Border.all(
                  color: Colors.white.withOpacity(.20),
                  width: 1,
                ),
              ),
              child: Text(
                'ทั้งหมด $totalCount',
                style: RgText.caption.copyWith(
                  color: Colors.white,
                  fontFamily: RgText.fontBold,
                  fontSize: 11,
                ),
              ),
            ),
          // ─── เพิ่มทะเบียน ───
          if (onAdd != null) ...[
            const SizedBox(width: RgSpace.sm),
            Tooltip(
              message: 'เพิ่มทะเบียนลูกค้า',
              child: InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(RgRadius.pill),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: RgColors.primary,
                    borderRadius: BorderRadius.circular(RgRadius.pill),
                    boxShadow: [
                      BoxShadow(
                        color: RgColors.primary.withOpacity(.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_circle_outline_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'เพิ่มทะเบียน',
                        style: RgText.body.copyWith(
                          color: Colors.white,
                          fontFamily: RgText.fontBold,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
