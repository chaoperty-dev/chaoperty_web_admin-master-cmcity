// ============================================================================
// request_detail_section_title.dart
// ============================================================================
// Section header (icon badge + title) — ใช้ในแท็บ "ข้อมูลคำขอ" ของ license_attach_page
// คัดลอกมาจาก license_request_page/views/widgets/request_detail_section_title.dart
// ============================================================================

import 'package:flutter/material.dart';

class RequestDetailSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? iconColor;

  const RequestDetailSectionTitle({
    super.key,
    required this.icon,
    required this.title,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = iconColor ?? const Color(0xFF15803D);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accent.withOpacity(.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}