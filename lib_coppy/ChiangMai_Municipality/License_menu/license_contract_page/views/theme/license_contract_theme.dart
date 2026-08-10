// ============================================================================
// license_contract_theme.dart
// ============================================================================
// Shared design tokens สำหรับ "หน้าสร้างสัญญา" (Step 1: ผู้เช่า)
// ใช้ design system เดียวกับ license_request_page
// ============================================================================

import 'package:flutter/material.dart';

/// 🎨 Brand & Semantic Colors (เหมือนกับ LicenseRequestPage)
class LcColors {
  // Primary (emerald)
  static const Color primary = Color(0xFF16A34A);
  static const Color primaryDark = Color(0xFF15803D);
  static const Color primaryLight = Color(0xFFDCFCE7);
  static const Color primaryAccent = Color(0xFF4ADE80);

  // Surfaces
  static const Color surface = Color(0xFFF8FAFC);
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  static const Color cardBg = Colors.white;
  static const Color headerBg = Color(0xFF0F172A);
  static const Color headerAccent = Color(0xFF1E293B);

  // Borders
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderStrong = Color(0xFFCBD5E1);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textInverse = Colors.white;

  // Semantic (สำหรับ field label / hint)
  static const Color label = Color(0xFF334155);
  static const Color required = Color(0xFFDC2626);

  // Danger
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerLight = Color(0xFFFEE2E2);
}

/// 📐 Spacing & Radius
class LcSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
}

class LcRadius {
  static const double sm = 8;
  static const double md = 10;
  static const double lg = 14;
  static const double xl = 16;
  static const double pill = 999;
}

/// 🔤 Typography tokens
class LcText {
  static const String fontBold = 'LINESeed1';
  static const String fontRegular = 'LINESeed2';

  static const TextStyle h1 = TextStyle(
    fontFamily: fontBold,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: LcColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontBold,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: LcColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontRegular,
    fontSize: 14,
    color: LcColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: fontRegular,
    fontSize: 13,
    color: LcColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontBold,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: LcColors.label,
    height: 1.3,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontRegular,
    fontSize: 12,
    color: LcColors.textMuted,
  );

  static const TextStyle input = TextStyle(
    fontFamily: fontRegular,
    fontSize: 13,
    color: LcColors.textPrimary,
  );

  static const TextStyle tableHeader = TextStyle(
    fontFamily: fontBold,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: LcColors.textSecondary,
    letterSpacing: 0.4,
  );

  static const TextStyle tableCell = TextStyle(
    fontFamily: fontRegular,
    fontSize: 13,
    color: LcColors.textPrimary,
  );
}

/// 🧱 Reusable Decorations
class LcDecor {
  static BoxDecoration card({double radius = LcRadius.lg}) => BoxDecoration(
        color: LcColors.cardBg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: LcColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  /// Input field decoration (ใช้ร่วมกันใน Person / Shop / Contract)
  static InputDecoration inputDecor({
    String? labelText,
    String? hintText,
    bool required = false,
    Widget? suffixIcon,
  }) =>
      InputDecoration(
        isDense: true,
        filled: true,
        fillColor: LcColors.surfaceMuted.withOpacity(.6),
        hintText: hintText,
        hintStyle: LcText.caption,
        labelText: labelText,
        labelStyle: LcText.label.copyWith(fontSize: 11),
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(LcRadius.sm)),
          borderSide: BorderSide(color: LcColors.border, width: 1),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(LcRadius.sm)),
          borderSide: BorderSide(color: LcColors.border, width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(LcRadius.sm)),
          borderSide: BorderSide(color: LcColors.primary, width: 1.6),
        ),
        disabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(LcRadius.sm)),
          borderSide: BorderSide(color: LcColors.border, width: 1),
        ),
      );
}

/// ✨ Animations
class LcAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
}
