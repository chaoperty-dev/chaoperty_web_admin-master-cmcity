// ============================================================================
// license_approve_bulk_page.dart
// ============================================================================
// Full-page route สำหรับ "อนุมัติรายการทั้งหมด" (Tab 2)
// - เปิดแบบ fullscreen เหมือน LicenseApproveDetailPage (มาจากแถวของ Tab 1)
// - Body: ApproveBulkSignaturePreview ฝังอยู่ + header ย้อนกลับ
// - ไม่มี tab bar / search / pagination — เพราะเป็น full-page ต่างหาก
//
// ใช้งาน:
//   Navigator.push(context, MaterialPageRoute(
//     builder: (_) => const LicenseApproveBulkPage(),
//   ));
// ============================================================================

import 'package:flutter/material.dart';

import 'theme/license_approve_theme.dart';
import 'widgets/approve_bulk_signature_preview.dart';

class LicenseApproveBulkPage extends StatelessWidget {
  const LicenseApproveBulkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LaColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BulkPageHeader(
              title: 'อนุมัติรายการทั้งหมด',
              subtitle: 'ตรวจสอบข้อมูลผู้ลงนามก่อนดำเนินการ',
              onBack: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
            const Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(LaSpace.lg),
                child: ApproveBulkSignaturePreview(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Header สำหรับ full-page — โทนเดียวกับ ApproveDetailHeader (gradient + back)
// แต่เป็นของตัวเอง ไม่ผูกกับ VM (full-page นี้ไม่มี state)
// ─────────────────────────────────────────────────────────────────────
class _BulkPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onBack;

  const _BulkPageHeader({
    required this.title,
    required this.onBack,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [LaColors.headerBg, LaColors.headerAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: LaColors.primary.withOpacity(.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 22,
            ),
            tooltip: 'ย้อนกลับ',
          ),
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: LaColors.primary.withOpacity(.18),
              borderRadius: BorderRadius.circular(LaRadius.md),
              border: Border.all(
                color: LaColors.primaryAccent.withOpacity(.35),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.done_all_rounded,
              color: LaColors.primaryAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: LaSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'LICENSE BULK APPROVAL',
                  style: LaText.label.copyWith(
                    color: LaColors.primaryAccent.withOpacity(.9),
                    letterSpacing: 1.6,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: LaText.h1.copyWith(color: Colors.white, fontSize: 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: LaText.caption.copyWith(
                      color: Colors.white.withOpacity(.65),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}