// ============================================================================
// approve_bulk_launcher.dart
// ============================================================================
// Launcher card สำหรับ Tab 2 — ปุ่มเปิด full-page "อนุมัติรายการทั้งหมด"
// Tab 2 ฝังอยู่ใน TabBarView แบบ shared filter → เนื้อหาหลักอยู่บน full-page
// (LicenseApproveBulkPage) เพื่อไม่ให้ UI รก
// ============================================================================

import 'package:flutter/material.dart';

import '../theme/license_approve_theme.dart';
import '../license_approve_bulk_page.dart';

class ApproveBulkLauncher extends StatelessWidget {
  const ApproveBulkLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          padding: const EdgeInsets.all(LaSpace.xl),
          decoration: LaDecor.card(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildIcon(),
              const SizedBox(height: LaSpace.md),
              const Text(
                'อนุมัติรายการทั้งหมด',
                textAlign: TextAlign.center,
                style: LaText.h2,
              ),
              const SizedBox(height: 6),
              const Text(
                'เปิดหน้าเต็มเพื่อดูข้อมูลผู้ลงนามอนุมัติ '
                'และจัดการรายการ',
                textAlign: TextAlign.center,
                style: LaText.bodyMuted,
              ),
              const SizedBox(height: LaSpace.lg),
              _buildCta(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Center(
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: LaColors.primaryLight,
          shape: BoxShape.circle,
          border: Border.all(
            color: LaColors.primary.withOpacity(.25),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.done_all_rounded,
          size: 36,
          color: LaColors.primaryDark,
        ),
      ),
    );
  }

  Widget _buildCta(BuildContext context) {
    return SizedBox(
      height: 44,
      child: FilledButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const LicenseApproveBulkPage(),
              fullscreenDialog: true,
            ),
          );
        },
        icon: const Icon(Icons.open_in_new_rounded, size: 18),
        label: const Text(
          'เปิดหน้าอนุมัติรายการทั้งหมด',
          style: TextStyle(
            fontFamily: LaText.fontBold,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: LaColors.primaryDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LaRadius.md),
          ),
        ),
      ),
    );
  }
}