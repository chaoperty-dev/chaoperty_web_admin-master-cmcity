// ============================================================================
// area_menu_theme.dart
// ============================================================================
// Shared design tokens (colors / typography / decoration) สำหรับหน้า
// "คำขอต่อสัญญา" — ใช้ซ้ำในทุก widget เพื่อให้ UI สม่ำเสมอ
// ============================================================================

import 'package:flutter/material.dart';

/// 🎨 Brand & Semantic Colors
class LaColors {
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

  // Status (semantic)
  static const Color statusPendingBg = Color(0xFFFEF3C7); // amber-100
  static const Color statusPendingFg = Color(0xFFB45309); // amber-700
  static const Color statusApprovedBg = Color(0xFFDCFCE7); // green-100
  static const Color statusApprovedFg = Color(0xFF15803D); // green-700
  static const Color statusRejectedBg = Color(0xFFFEE2E2); // red-100
  static const Color statusRejectedFg = Color(0xFFB91C1C); // red-700
  static const Color statusInfoBg = Color(0xFFDBEAFE); // blue-100
  static const Color statusInfoFg = Color(0xFF1D4ED8); // blue-700
  static const Color statusNeutralBg = Color(0xFFF1F5F9); // slate-100
  static const Color statusNeutralFg = Color(0xFF475569); // slate-600

  // Area-specific status colors
  static const Color statusVacantBg = Color(0xFFE0F2FE); // sky-100
  static const Color statusVacantFg = Color(0xFF0369A1); // sky-700
  static const Color statusCurrentBg = Color(0xFFDCFCE7); // green-100
  static const Color statusCurrentFg = Color(0xFF15803D); // green-700
  static const Color statusNearExpiryBg = Color(0xFFFEF9C3); // yellow-100
  static const Color statusNearExpiryFg = Color(0xFFA16207); // yellow-700
  static const Color statusExpiredBg = Color(0xFFFEE2E2); // red-100
  static const Color statusExpiredFg = Color(0xFFB91C1C); // red-700
  static const Color statusDraftBg = Color(0xFFF3F4F6); // gray-100
  static const Color statusDraftFg = Color(0xFF4B5563); // gray-600
  static const Color statusReviewBg = Color(0xFFF3E8FF); // purple-100
  static const Color statusReviewFg = Color(0xFF7E22CE); // purple-700
}

/// 📐 Spacing & Radius
class LaSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
}

class LaRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;
}

/// 🔤 Typography tokens
class LaText {
  static const String fontBold = 'LINESeed1';
  static const String fontRegular = 'LINESeed2';

  static const TextStyle h1 = TextStyle(
    fontFamily: fontBold,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: LaColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontBold,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: LaColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontRegular,
    fontSize: 14,
    color: LaColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: fontRegular,
    fontSize: 13,
    color: LaColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontBold,
    fontSize: 11,
    color: LaColors.textSecondary,
    letterSpacing: 0.6,
    height: 1.2,
  );

  static const TextStyle tableHeader = TextStyle(
    fontFamily: fontBold,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: LaColors.textSecondary,
    letterSpacing: 0.4,
  );

  static const TextStyle tableCell = TextStyle(
    fontFamily: fontRegular,
    fontSize: 13,
    color: LaColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontRegular,
    fontSize: 12,
    color: LaColors.textMuted,
  );
}

/// 🧱 Reusable Decorations
class LaDecor {
  static BoxDecoration card({double radius = LaRadius.lg}) => BoxDecoration(
        color: LaColors.cardBg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: LaColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static BoxDecoration softCard({Color? color}) => BoxDecoration(
        color: color ?? LaColors.surfaceMuted,
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(color: LaColors.border, width: 1),
      );

  /// Status pill — รับ (bg, fg) มาจาก statusConfig
  static BoxDecoration pill(Color bg, Color fg) => BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(LaRadius.pill),
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
          LaColors.statusNeutralBg, LaColors.statusNeutralFg);
    }

    // ── Area-specific statuses (exact / strong match first) ───────────────
    if (s == 'ว่าง') {
      return const StatusPalette(
          LaColors.statusVacantBg, LaColors.statusVacantFg);
    }
    if (s == 'สัญญาปัจจุบัน' || s == 'current' || s == 'active') {
      return const StatusPalette(
          LaColors.statusCurrentBg, LaColors.statusCurrentFg);
    }
    if (s == 'เช่าอยู่' || s == 'rented' || s == 'leasing') {
      return const StatusPalette(
          LaColors.statusCurrentBg, LaColors.statusCurrentFg);
    }
    if (s == 'ใกล้หมดสัญญา' || s == 'near expiry' || s == 'near_expiry') {
      return const StatusPalette(
          LaColors.statusNearExpiryBg, LaColors.statusNearExpiryFg);
    }
    if (s == 'หมดสัญญา' || s == 'expired' || s == 'expiry') {
      return const StatusPalette(
          LaColors.statusExpiredBg, LaColors.statusExpiredFg);
    }
    if (s == 'ร่างคำขอ' || s == 'draft') {
      return const StatusPalette(
          LaColors.statusDraftBg, LaColors.statusDraftFg);
    }
    if (s == 'กำลังตรวจสอบ' ||
        s == 'under review' ||
        s == 'under_review' ||
        s == 'review') {
      return const StatusPalette(
          LaColors.statusReviewBg, LaColors.statusReviewFg);
    }
    // ── Area menu — status จาก requests/properties API ───────────────────
    if (s == 'เสนอราคา' || s == 'quote' || s == 'bidding') {
      return const StatusPalette(
          LaColors.statusPendingBg, LaColors.statusPendingFg);
    }
    if (s == 'เสนอราคา(มัดจำ)' ||
        s == 'เสนอราคา(มัดจำ)' ||
        s == 'quote(deposit)' ||
        s == 'deposit') {
      return const StatusPalette(
          LaColors.statusReviewBg, LaColors.statusReviewFg);
    }
    if (s == 'ร่างดำเนิน' || s == 'ว่างดำเนิน') {
      return const StatusPalette(
          LaColors.statusReviewBg, LaColors.statusReviewFg);
    }
    // ── Properties API request_status (EN keys) ──────────────────────────
    if (s == 'submitted' || s == 'request_submitted') {
      return const StatusPalette(
          LaColors.statusInfoBg, LaColors.statusInfoFg);
    }
    if (s == 'needs_update' || s == 'need_update') {
      return const StatusPalette(
          LaColors.statusPendingBg, LaColors.statusPendingFg);
    }
    if (s == 'waiting_payment_info' || s == 'waiting_payment') {
      return const StatusPalette(
          LaColors.statusPendingBg, LaColors.statusPendingFg);
    }
    if (s == 'payment_submitted') {
      return const StatusPalette(
          LaColors.statusInfoBg, LaColors.statusInfoFg);
    }
    if (s == 'documents_submitted') {
      return const StatusPalette(
          LaColors.statusInfoBg, LaColors.statusInfoFg);
    }
    if (s == 'request_completed') {
      return const StatusPalette(
          LaColors.statusApprovedBg, LaColors.statusApprovedFg);
    }

    // ── Generic fallback mapping ──────────────────────────────────────────
    // Pending / รอ / รออนุมัติ / in_progress / กำลังดำเนินการ
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
          LaColors.statusPendingBg, LaColors.statusPendingFg);
    }
    // Approved / อนุมัติ / ตกลง / ผ่าน / เสร็จ
    if (s.contains('อนุมัติ') ||
        s.contains('approved') ||
        s.contains('ตกลง') ||
        s.contains('ผ่าน') ||
        s.contains('success') ||
        s == 'ok' ||
        s.contains('complete') ||
        s.contains('เสร็จ')) {
      return const StatusPalette(
          LaColors.statusApprovedBg, LaColors.statusApprovedFg);
    }
    // Rejected / ปฏิเสธ / ยกเลิก / ไม่อนุมัติ / หมดอายุ
    if (s.contains('ปฏิเสธ') ||
        s.contains('reject') ||
        s.contains('cancel') ||
        s.contains('ยกเลิก') ||
        s.contains('ไม่อนุมัติ') ||
        s.contains('failed') ||
        s.contains('fail') ||
        s.contains('หมดอายุ') ||
        s.contains('expired')) {
      return const StatusPalette(
          LaColors.statusRejectedBg, LaColors.statusRejectedFg);
    }
    // Info / ตรวจสอบ / verify
    if (s.contains('ตรวจ') ||
        s.contains('verify') ||
        s.contains('check') ||
        s.contains('info')) {
      return const StatusPalette(LaColors.statusInfoBg, LaColors.statusInfoFg);
    }
    return const StatusPalette(
        LaColors.statusNeutralBg, LaColors.statusNeutralFg);
  }
}

/// ✨ Subtle hover/ripple helpers
class LrAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
}
