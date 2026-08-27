// ============================================================================
// customers_report_theme.dart
// ============================================================================
// Design tokens สำหรับหน้า "รายงานลูกค้า"
// ใช้ palette ใกล้เคียงกับ Area_menu เพื่อความสม่ำเสมอ
// ============================================================================

import 'package:flutter/material.dart';

/// 🎨 Colors
class CrColors {
  static const Color primary = Color(0xFF16A34A);
  static const Color primaryDark = Color(0xFF15803D);
  static const Color primaryLight = Color(0xFFDCFCE7);

  static const Color surface = Color(0xFFF8FAFC);
  static const Color surfaceMuted = Color(0xFFF1F5F9);

  static const Color border = Color(0xFFE2E8F0);
  static const Color borderStrong = Color(0xFFCBD5E1);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textInverse = Colors.white;
}

/// 📐 Spacing & Radius
class CrSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
}

class CrRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double pill = 999;
}

/// 🔤 Typography
class CrText {
  static const String fontRegular = 'Sarabun';
  static const String fontBold = 'Sarabun';

  static const TextStyle h1 = TextStyle(
    fontFamily: fontBold,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -.2,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontBold,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontRegular,
    fontSize: 14,
    color: CrColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: fontRegular,
    fontSize: 13,
    color: CrColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontRegular,
    fontSize: 11,
    color: CrColors.textMuted,
    letterSpacing: .2,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontBold,
    fontSize: 11,
    color: CrColors.textSecondary,
    letterSpacing: 1.0,
    fontWeight: FontWeight.w700,
  );
}

/// ✨ Animations
class CrAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
}

/// 🧱 Common decoration helpers
class CrDecor {
  /// Card surface (เอาไว้ห่อ panel ต่าง ๆ)
  static BoxDecoration card() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(CrRadius.md),
      border: Border.all(color: CrColors.border, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Header gradient background (เหมือน Area_menu)
  static BoxDecoration headerGradient() {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(CrRadius.lg),
      boxShadow: [
        BoxShadow(
          color: CrColors.primary.withOpacity(.15),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}

