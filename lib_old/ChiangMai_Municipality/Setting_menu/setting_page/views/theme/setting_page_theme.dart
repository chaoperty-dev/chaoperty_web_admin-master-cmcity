// ============================================================================
// setting_page_theme.dart
// ============================================================================
// Shared design tokens สำหรับหน้า SettingPage hub
// - ใช้ prefix "Set" (Setting menu) เพื่อไม่ชนกับ LaColors / RsColors
// - ใช้ style เดียวกับ License menu (LaColors) เพื่อให้ UI สม่ำเสมอทั้งโปรเจค
// ============================================================================

import 'package:flutter/material.dart';

/// 🎨 Brand & Semantic Colors (อิง LaColors)
class SetColors {
  SetColors._();

  // Primary (emerald)
  static const Color primary = Color(0xFF16A34A);
  static const Color primaryDark = Color(0xFF15803D);
  static const Color primaryLight = Color(0xFFDCFCE7);
  static const Color primaryAccent = Color(0xFF4ADE80);

  // Surfaces
  static const Color surface = Color(0xFFF8FAFC); // slate-50
  static const Color surfaceMuted = Color(0xFFF1F5F9); // slate-100
  static const Color cardBg = Colors.white;
  static const Color headerBg = Color(0xFF0F172A); // slate-900
  static const Color headerAccent = Color(0xFF1E293B); // slate-800

  // Borders
  static const Color border = Color(0xFFE2E8F0); // slate-200
  static const Color borderStrong = Color(0xFFCBD5E1); // slate-300

  // Text
  static const Color textPrimary = Color(0xFF0F172A); // slate-900
  static const Color textSecondary = Color(0xFF475569); // slate-600
  static const Color textMuted = Color(0xFF94A3B8); // slate-400
  static const Color textInverse = Colors.white;

  // Menu accent colors (สีของแต่ละเมนูย่อย)
  static const Color menuRental = Color(0xFF6B7280); // gray-500
  static const Color menuArea = Color(0xFFEC4899); // pink-500
  static const Color menuRentalSettings = Color(0xFF16A34A); // green-600
  static const Color menuDocument = Color(0xFF2563EB); // blue-600
  static const Color menuPayment = Color(0xFFEA580C); // orange-600
  static const Color menuAccessRights = Color(0xFF0F172A); // slate-900
}

/// 📐 Spacing & Radius
class SetSpace {
  SetSpace._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
}

class SetRadius {
  SetRadius._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;
}

/// 🔤 Typography tokens (อิง LaText)
class SetText {
  SetText._();

  static const String fontBold = 'LINESeed1';
  static const String fontRegular = 'LINESeed2';

  static const TextStyle h1 = TextStyle(
    fontFamily: fontBold,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: SetColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontBold,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: SetColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontRegular,
    fontSize: 14,
    color: SetColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: fontRegular,
    fontSize: 13,
    color: SetColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontBold,
    fontSize: 11,
    color: SetColors.textSecondary,
    letterSpacing: 0.6,
    height: 1.2,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontRegular,
    fontSize: 12,
    color: SetColors.textMuted,
  );
}

/// 🧱 Reusable Decorations (อิง LaDecor)
class SetDecor {
  SetDecor._();

  static BoxDecoration card({double radius = SetRadius.lg}) => BoxDecoration(
        color: SetColors.cardBg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: SetColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static BoxDecoration softCard({Color? color}) => BoxDecoration(
        color: color ?? SetColors.surfaceMuted,
        borderRadius: BorderRadius.circular(SetRadius.md),
        border: Border.all(color: SetColors.border, width: 1),
      );
}

class SetResponsive {
  SetResponsive._();

  /// < 500 = mobile (เหมือน pattern เดิม)
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 500;

  static double pageMaxWidth = 1200;
  static EdgeInsets pagePadding(BuildContext context) => EdgeInsets.all(
        isMobile(context) ? SetSpace.md : SetSpace.lg,
      );
}
