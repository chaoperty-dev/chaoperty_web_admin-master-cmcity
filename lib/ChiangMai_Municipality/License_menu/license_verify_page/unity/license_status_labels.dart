// ============================================================================
// LicenseStatusLabels.dart
// ============================================================================
// Central mapper สำหรับ status ของคำขอ/ใบอนุญาต (License menu)
// — ใช้ร่วมกันทุกเมนู (request / approve / attach / verify / payment / ...)
// — เปลี่ยนที่เดียว ลด drift ระหว่าง table ↔ dropdown ↔ detail
//
// API:
//   LicenseStatusLabels.th(rawKey)            → Thai label (fallback = raw)
//   LicenseStatusLabels.options               → List<String> status keys
//   LicenseStatusLabels.isEmpty / isNotEmpty  → helper
// ============================================================================

import 'package:flutter/material.dart';

/// Central mapper สำหรับ license status
class LicenseStatusLabels {
  /// Thai label สำหรับ status (key = raw API key, lower-case)
  ///
  /// หากไม่พบ key → คืน raw status เดิมกลับมา (per requirement:
  /// "ถ้าไม่พบเคสให้เทินตามAPI เลย ไม่ต้องแปล")
  static const Map<String, String> _map = <String, String>{
    // draft / ยังไม่ส่ง
    'draft': 'ฉบับร่าง',

    // submitted เอกสาร
    'documents_submitted': 'ส่งเอกสารแล้ว',

    // รอข้อมูลการชำระ
    'waiting_payment_info': 'รอข้อมูลชำระเงิน',

    // ชำระเงินแล้ว (รอยืนยัน)
    'payment_submitted': 'ชำระเงินแล้ว',

    // คำขอทั่วไป
    'request_submitted': 'ส่งคำขอแล้ว',
    'needs_update': 'ต้องแก้ไข',
    'under_review': 'กำลังพิจารณา',
    'in_progress': 'กำลังดำเนินการ',

    // เสร็จสิ้น
    'request_completed': 'คำขอเสร็จสิ้น',
    'completed': 'เสร็จสิ้น',
    'approved': 'เสร็จสิ้น',
    'paid': 'ชำระแล้ว',

    // ยกเลิก / ปฏิเสธ
    'cancelled': 'ยกเลิก',
    'canceled': 'ยกเลิก',
    'rejected': 'ถูกปฏิเสธ',

    // pending ทั่วไป
    'pending': 'รอดำเนินการ',
  };

  /// รายการ status keys ทั้งหมด (สำหรับ filter dropdown)
  /// ลำดับ: draft → ... → rejected
  static const List<String> options = <String>[
    'draft',
    'documents_submitted',
    'waiting_payment_info',
    'payment_submitted',
    'request_submitted',
    'needs_update',
    'under_review',
    'in_progress',
    'request_completed',
    'completed',
    'rejected',
  ];

  /// คืน Thai label — ถ้าไม่รู้จัก → คืน raw status (ตาม API)
  static String th(String? raw) {
    final s = (raw ?? '').trim();
    if (s.isEmpty) return '-';
    final k = s.toLowerCase();
    return _map[k] ?? s;
  }

  /// helper: เช็คว่า status ว่าง/ไม่มีค่า
  static bool get isEmptyKey => false; // sentinel — ไม่ได้ใช้

  // ───────── StatusPalette (central color mapping) ─────────
  /// คืนสี pill ตาม raw status
  ///
  /// ใช้ raw key เป็นหลัก (ไม่ substring match ภาษาไทย เพราะ TH wording เปลี่ยนบ่อย)
  static StatusPalette paletteOf(String? raw) {
    final s = (raw ?? '').toLowerCase().trim();
    if (s.isEmpty) {
      return const StatusPalette(_neutralBg, _neutralFg);
    }
    // pending / รอ / draft
    if (s == 'draft' ||
        s == 'pending' ||
        s == 'waiting_payment_info' ||
        s == 'in_progress' ||
        s == 'under_review' ||
        s == 'needs_update' ||
        s == 'request_submitted') {
      return const StatusPalette(_pendingBg, _pendingFg);
    }
    // info / ส่งเอกสาร / ส่งชำระ
    if (s == 'documents_submitted' || s == 'payment_submitted') {
      return const StatusPalette(_infoBg, _infoFg);
    }
    // approved / completed
    if (s == 'completed' ||
        s == 'request_completed' ||
        s == 'approved' ||
        s == 'paid') {
      return const StatusPalette(_approvedBg, _approvedFg);
    }
    // rejected / cancelled
    if (s == 'rejected' || s == 'cancelled' || s == 'canceled') {
      return const StatusPalette(_rejectedBg, _rejectedFg);
    }
    return const StatusPalette(_neutralBg, _neutralFg);
  }

  // palette colors (เหมือน StatusPalette ใน license_payment_theme.dart)
  static const Color _pendingBg = Color(0xFFFEF3C7); // amber-100
  static const Color _pendingFg = Color(0xFF92400E); // amber-800
  static const Color _approvedBg = Color(0xFFDCFCE7); // green-100
  static const Color _approvedFg = Color(0xFF166534); // green-800
  static const Color _rejectedBg = Color(0xFFFEE2E2); // red-100
  static const Color _rejectedFg = Color(0xFF991B1B); // red-800
  static const Color _infoBg = Color(0xFFDBEAFE); // blue-100
  static const Color _infoFg = Color(0xFF1E40AF); // blue-800
  static const Color _neutralBg = Color(0xFFF1F5F9); // slate-100
  static const Color _neutralFg = Color(0xFF475569); // slate-600
}

/// Status palette (bg + fg) — ใช้ทั้ง theme files อื่นๆ ผ่าน alias
class StatusPalette {
  final Color bg;
  final Color fg;
  const StatusPalette(this.bg, this.fg);
}