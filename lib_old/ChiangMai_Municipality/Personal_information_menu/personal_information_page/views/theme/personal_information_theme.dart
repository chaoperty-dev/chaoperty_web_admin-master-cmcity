// ============================================================================
// personal_information_theme.dart
// ============================================================================
// Shared design tokens สำหรับหน้า "จัดการข้อมูลส่วนตัว"
// ใช้ pattern เดียวกับ LicenseFactCheck (LaColors / LaSpace / LaRadius / LaText)
// ============================================================================

import 'package:flutter/material.dart';

class PiColors {
  // Primary (emerald) — ใช้ร่วมกับ license_fact_check
  static const Color primary = Color(0xFF16A34A);
  static const Color primaryDark = Color(0xFF15803D);
  static const Color primaryLight = Color(0xFFDCFCE7);
  static const Color primaryAccent = Color(0xFF4ADE80);

  // Surfaces
  static const Color surface = Color(0xFFF8FAFC);
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  static const Color cardBg = Colors.white;

  // Borders
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderStrong = Color(0xFFCBD5E1);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textInverse = Colors.white;

  // Status (semantic)
  static const Color statusApprovedFg = Color(0xFF15803D);
  static const Color statusApprovedBg = Color(0xFFDCFCE7);
  static const Color statusPendingFg = Color(0xFFB45309);
  static const Color statusRejectedFg = Color(0xFFB91C1C);

  // Header (slate-900 → slate-800)
  static const Color headerBg = Color(0xFF0F172A);
  static const Color headerAccent = Color(0xFF1E293B);
}

class PiSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;

  /// Responsive padding ตามขนาดจอ
  static EdgeInsets pagePadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 500) {
      return const EdgeInsets.all(sm); // mobile
    }
    if (w < 1100) {
      return const EdgeInsets.all(md); // tablet
    }
    return const EdgeInsets.all(lg); // desktop
  }

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 500;
}

class PiRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;
}

class PiText {
  static const TextStyle h1 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: PiColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: PiColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: PiColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: PiColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontSize: 13,
    color: PiColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: PiColors.textMuted,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: PiColors.textSecondary,
    letterSpacing: 0.3,
  );
}

class PiDecor {
  static BoxDecoration card({
    double radius = PiRadius.lg,
    Color borderColor = PiColors.border,
  }) =>
      BoxDecoration(
        color: PiColors.cardBg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration softCard() => BoxDecoration(
        color: PiColors.surfaceMuted,
        borderRadius: BorderRadius.circular(PiRadius.md),
        border: Border.all(color: PiColors.border, width: 1),
      );
}
