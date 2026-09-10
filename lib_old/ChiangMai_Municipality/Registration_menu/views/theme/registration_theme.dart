// ============================================================================
// registration_theme.dart
// ============================================================================
// Shared design tokens สำหรับเมนู "ทะเบียน" (Registration)
// - ใช้ Rg* tokens (Registration) เพื่อไม่ชนกับหน้าอื่น
// ============================================================================

import 'package:flutter/material.dart';

class RgColors {
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

  static const Color statusPendingBg = Color(0xFFFEF3C7);
  static const Color statusPendingFg = Color(0xFFB45309);
  static const Color statusApprovedBg = Color(0xFFDCFCE7);
  static const Color statusApprovedFg = Color(0xFF15803D);
  static const Color statusRejectedBg = Color(0xFFFEE2E2);
  static const Color statusRejectedFg = Color(0xFFB91C1C);
  static const Color statusInfoBg = Color(0xFFDBEAFE);
  static const Color statusInfoFg = Color(0xFF1D4ED8);
  static const Color statusNeutralBg = Color(0xFFF1F5F9);
  static const Color statusNeutralFg = Color(0xFF475569);
}

class RgSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
}

class RgRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;
}

class RgText {
  static const String fontBold = 'LINESeed1';
  static const String fontRegular = 'LINESeed2';

  static const TextStyle h1 = TextStyle(
    fontFamily: fontBold,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: RgColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontBold,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: RgColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontRegular,
    fontSize: 14,
    color: RgColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: fontRegular,
    fontSize: 13,
    color: RgColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontBold,
    fontSize: 11,
    color: RgColors.textSecondary,
    letterSpacing: 0.6,
  );

  static const TextStyle tableHeader = TextStyle(
    fontFamily: fontBold,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: RgColors.textSecondary,
    letterSpacing: 0.4,
  );

  static const TextStyle tableCell = TextStyle(
    fontFamily: fontRegular,
    fontSize: 13,
    color: RgColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontRegular,
    fontSize: 12,
    color: RgColors.textMuted,
  );
}

class RgDecor {
  static BoxDecoration card({double radius = RgRadius.lg}) => BoxDecoration(
        color: RgColors.cardBg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: RgColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static BoxDecoration softCard({Color? color}) => BoxDecoration(
        color: color ?? RgColors.surfaceMuted,
        borderRadius: BorderRadius.circular(RgRadius.md),
        border: Border.all(color: RgColors.border, width: 1),
      );

  static BoxDecoration pill(Color bg, Color fg) => BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(RgRadius.pill),
        border: Border.all(color: fg.withOpacity(.18), width: 1),
      );
}

/// 🏷️ Status → (bg, fg) mapper — รองรับทั้งคำไทยและอังกฤษ
class StatusPalette {
  final Color bg;
  final Color fg;
  const StatusPalette(this.bg, this.fg);

  static StatusPalette of(String? status) {
    final s = (status ?? '').toLowerCase().trim();
    if (s.isEmpty) {
      return const StatusPalette(
          RgColors.statusNeutralBg, RgColors.statusNeutralFg);
    }
    if (s.contains('รอ') ||
        s.contains('pending') ||
        s.contains('wait') ||
        s.contains('progress') ||
        s.contains('process') ||
        s.contains('doing') ||
        s.contains('กำลัง') ||
        s.contains('อยู่ระหว่าง') ||
        s.contains('ดำเนินการ')) {
      return const StatusPalette(
          RgColors.statusPendingBg, RgColors.statusPendingFg);
    }
    if (s.contains('อนุมัติ') ||
        s.contains('approved') ||
        s.contains('ตกลง') ||
        s.contains('ผ่าน') ||
        s.contains('success') ||
        s == 'ok' ||
        s.contains('complete') ||
        s.contains('เสร็จ')) {
      return const StatusPalette(
          RgColors.statusApprovedBg, RgColors.statusApprovedFg);
    }
    if (s.contains('ปฏิเสธ') ||
        s.contains('reject') ||
        s.contains('cancel') ||
        s.contains('ยกเลิก') ||
        s.contains('ไม่อนุมัติ') ||
        s.contains('หมดอายุ')) {
      return const StatusPalette(
          RgColors.statusRejectedBg, RgColors.statusRejectedFg);
    }
    return const StatusPalette(
        RgColors.statusNeutralBg, RgColors.statusNeutralFg);
  }
}
