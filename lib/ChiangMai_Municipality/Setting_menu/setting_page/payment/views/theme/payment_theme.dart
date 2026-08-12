// ============================================================================
// payment_theme.dart
// ============================================================================
// Shared design tokens สำหรับหน้า "การรับชำระ" (CMM Setting)
// ใช้ namespace Pay* (Payment) เพื่อไม่ปะปน
// ============================================================================

import 'package:flutter/material.dart';

/// 🎨 Brand & Semantic Colors
class PayColors {
  static const Color primary = Color(0xFF16A34A);
  static const Color primaryDark = Color(0xFF15803D);
  static const Color primaryLight = Color(0xFFDCFCE7);
  static const Color primaryAccent = Color(0xFF4ADE80);

  static const Color surface = Color(0xFFF8FAFC);
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  static const Color cardBg = Colors.white;
  static const Color headerBg = Color(0xFF0F172A);
  static const Color headerAccent = Color(0xFF1E293B);

  static const Color border = Color(0xFFE2E8F0);
  static const Color borderStrong = Color(0xFFCBD5E1);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textInverse = Colors.white;

  static const Color statusInfoBg = Color(0xFFDBEAFE);
  static const Color statusInfoFg = Color(0xFF1D4ED8);
  static const Color statusApprovedBg = Color(0xFFDCFCE7);
  static const Color statusApprovedFg = Color(0xFF15803D);
  static const Color statusRejectedBg = Color(0xFFFEE2E2);
  static const Color statusRejectedFg = Color(0xFFB91C1C);
  static const Color statusNeutralBg = Color(0xFFF1F5F9);
  static const Color statusNeutralFg = Color(0xFF475569);
}

/// 📐 Spacing
class PaySpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
}

/// 🟦 Radius
class PayRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;
}

/// 🔤 Typography
class PayText {
  static const String fontBold = 'LINESeed1';
  static const String fontRegular = 'LINESeed2';

  static const TextStyle h1 = TextStyle(
    fontFamily: fontBold,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: PayColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontBold,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: PayColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontRegular,
    fontSize: 14,
    color: PayColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: fontRegular,
    fontSize: 13,
    color: PayColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontBold,
    fontSize: 11,
    color: PayColors.textSecondary,
    letterSpacing: 0.6,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontRegular,
    fontSize: 12,
    color: PayColors.textMuted,
  );

  static const TextStyle tableHeader = TextStyle(
    fontFamily: fontBold,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: PayColors.textSecondary,
    letterSpacing: 0.4,
  );

  static const TextStyle tableCell = TextStyle(
    fontFamily: fontRegular,
    fontSize: 13,
    color: PayColors.textPrimary,
  );
}

/// 🧱 Decorations
class PayDecor {
  static BoxDecoration card({double radius = PayRadius.lg}) => BoxDecoration(
        color: PayColors.cardBg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: PayColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static BoxDecoration softCard({Color? color}) => BoxDecoration(
        color: color ?? PayColors.surfaceMuted,
        borderRadius: BorderRadius.circular(PayRadius.md),
        border: Border.all(color: PayColors.border, width: 1),
      );

  static BoxDecoration pill(Color bg, Color fg) => BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(PayRadius.pill),
        border: Border.all(color: fg.withOpacity(.18), width: 1),
      );
}

/// ✨ Animations
class PayAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
}
