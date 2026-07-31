// ============================================================================
// fact_check_detail_step1.dart
// ============================================================================
// Step 1 — ตรวจสอบข้อเท็จจริง (Empty page — skeleton)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/license_fact_check_theme.dart';
import '../../viewmodels/license_fact_check_detail_view_model.dart';

class FactCheckDetailStep1 extends StatelessWidget {
  const FactCheckDetailStep1({super.key});

  @override
  Widget build(BuildContext context) {
    // Touch VM so it rebuilds when step changes
    context.watch<LicensefactcheckDetailViewModel>();

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
                    Icon(Icons.verified_rounded,
                        size: 18, color: LaColors.primaryDark),
                    SizedBox(width: 8),
                    Text('ตรวจสอบข้อเท็จจริง', style: LaText.h2),
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
                      child: const Icon(Icons.inbox_rounded,
                          size: 36, color: LaColors.primary),
                    ),
                    const SizedBox(height: LaSpace.md),
                    Text('เนื้อหา Step 1 — ตรวจสอบข้อเท็จจริง',
                        style: LaText.h2, textAlign: TextAlign.center),
                    const SizedBox(height: LaSpace.sm),
                    Text(
                      'พื้นที่สำหรับแสดงรายการตรวจสอบและ checklist\n'
                      'รอใส่ UI จริงในภายหลัง',
                      style: LaText.bodyMuted,
                      textAlign: TextAlign.center,
                    ),
                    if (false) ...[
                      // ignore: dead_code
                      const SizedBox(height: LaSpace.lg),
                      // ignore: dead_code
                      const Divider(),
                      // ignore: dead_code
                      const SizedBox(height: LaSpace.md),
                      // ignore: dead_code
                      Text(
                        'placeholder',
                        style: LaText.caption,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: LaSpace.lg),
              const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 14, color: LaColors.textMuted),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text('ตรวจสอบข้อเท็จจริงให้ครบถ้วนก่อนกด "ถัดไป"',
                        style: LaText.caption),
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
