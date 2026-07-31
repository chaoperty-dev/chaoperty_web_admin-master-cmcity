// ============================================================================
// verify_detail_step2.dart
// ============================================================================
// Step 2 — สรุปผลการตรวจสอบหลักฐาน (Empty page — skeleton)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/license_verify_theme.dart';
import '../../viewmodels/license_verify_detail_view_model.dart';

class VerifyDetailStep2 extends StatelessWidget {
  const VerifyDetailStep2({super.key});

  @override
  Widget build(BuildContext context) {
    // Touch VM so it rebuilds when step changes
    context.watch<LicenseverifyDetailViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(LaSpace.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: LaSpace.md, vertical: LaSpace.sm),
                decoration: BoxDecoration(
                  color: LaColors.primaryLight.withOpacity(.25),
                  borderRadius: BorderRadius.circular(LaRadius.md),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 18,
                      color: LaColors.primaryDark,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'สรุปผลการตรวจสอบ',
                      style: LaText.h2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LaSpace.md),
              Container(
                decoration: LaDecor.card(),
                padding: const EdgeInsets.all(LaSpace.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: LaColors.primary.withOpacity(.10),
                        borderRadius: BorderRadius.circular(LaRadius.lg),
                      ),
                      child: const Icon(
                        Icons.assignment_turned_in_rounded,
                        size: 36,
                        color: LaColors.primary,
                      ),
                    ),
                    const SizedBox(height: LaSpace.md),
                    Text(
                      'เนื้อหา Step 2 — สรุปผลการตรวจสอบ',
                      style: LaText.h2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: LaSpace.sm),
                    Text(
                      'พื้นที่สำหรับแสดงสรุปผล, ผลการอนุมัติ/ปฏิเสธ, '
                      'หรือ action buttons\n'
                      'รอใส่ UI จริงในภายหลัง',
                      style: LaText.bodyMuted,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LaSpace.lg),
              const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: LaColors.textMuted,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'เมื่อตรวจสอบเสร็จ กดปุ่ม "บันทึก" ด้านล่าง',
                      style: LaText.caption,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
