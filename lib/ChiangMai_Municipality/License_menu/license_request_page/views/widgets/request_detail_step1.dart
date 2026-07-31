// ============================================================================
// request_detail_step1.dart
// ============================================================================
// Step 1 — ตรวจสอบคำขอ (Empty page — skeleton)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/license_request_theme.dart';
import '../../viewmodels/license_request_detail_view_model.dart';

class RequestDetailStep1 extends StatelessWidget {
  const RequestDetailStep1({super.key});

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
                    Icon(Icons.assignment_rounded,
                        size: 18, color: LrColors.primaryDark),
                    SizedBox(width: 8),
                    Text('ตรวจสอบคำขอ', style: LrText.h2),
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
                      child: const Icon(Icons.inbox_rounded,
                          size: 36, color: LrColors.primary),
                    ),
                    const SizedBox(height: LrSpace.md),
                    Text('เนื้อหา Step 1 — ตรวจสอบคำขอ',
                        style: LrText.h2, textAlign: TextAlign.center),
                    const SizedBox(height: LrSpace.sm),
                    Text(
                      'พื้นที่สำหรับแสดงรายละเอียดคำขอก่อนดำเนินการ\n'
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
                    child: Text('ตรวจสอบคำขอให้ครบถ้วนก่อนกด "ถัดไป"',
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
