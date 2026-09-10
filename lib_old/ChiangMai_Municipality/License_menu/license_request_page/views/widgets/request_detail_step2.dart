// ============================================================================
// request_detail_step2.dart
// ============================================================================
// Step 2 — บันทึกการดำเนินการ (Empty page — skeleton)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/license_request_theme.dart';
import '../../viewmodels/license_request_detail_view_model.dart';

class RequestDetailStep2 extends StatelessWidget {
  const RequestDetailStep2({super.key});

  @override
  Widget build(BuildContext context) {
    // Touch VM so it rebuilds when step changes
    context.watch<LicenseRequestDetailViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(LrSpace.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: LrSpace.md, vertical: LrSpace.sm),
                decoration: BoxDecoration(
                  color: LrColors.primaryLight.withOpacity(.25),
                  borderRadius: BorderRadius.circular(LrRadius.md),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.task_alt_rounded,
                        size: 18, color: LrColors.primaryDark),
                    SizedBox(width: 8),
                    Text('บันทึกการดำเนินการ', style: LrText.h2),
                  ],
                ),
              ),
              const SizedBox(height: LrSpace.md),
              Container(
                decoration: LrDecor.card(),
                padding: const EdgeInsets.all(LrSpace.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: LrColors.primary.withOpacity(.10),
                        borderRadius: BorderRadius.circular(LrRadius.lg),
                      ),
                      child: const Icon(Icons.assignment_turned_in_rounded,
                          size: 36, color: LrColors.primary),
                    ),
                    const SizedBox(height: LrSpace.md),
                    Text('เนื้อหา Step 2 — บันทึกการดำเนินการ',
                        style: LrText.h2, textAlign: TextAlign.center),
                    const SizedBox(height: LrSpace.sm),
                    Text(
                      'พื้นที่สำหรับแสดงผลการดำเนินการและบันทึก\n'
                      'รอใส่ UI จริงในภายหลัง',
                      style: LrText.bodyMuted,
                      textAlign: TextAlign.center,
                    ),
                    if (false) ...[
                      // ignore: dead_code
                      const SizedBox(height: LrSpace.lg),
                      // ignore: dead_code
                      const Divider(),
                      // ignore: dead_code
                      const SizedBox(height: LrSpace.md),
                      // ignore: dead_code
                      Text(
                        'placeholder',
                        style: LrText.caption,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: LrSpace.lg),
              const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 14, color: LrColors.textMuted),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text('เมื่อบันทึกเรียบร้อย กดปุ่ม "บันทึก" ด้านล่าง',
                        style: LrText.caption),
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
