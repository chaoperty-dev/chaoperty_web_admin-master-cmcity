// ============================================================================
// registration_detail_footer.dart
// ============================================================================
// Footer — ปุ่ม ก่อนหน้า / ถัดไป / บันทึก (ใช้ในหน้า Detail 2-step)
// ============================================================================

import 'package:flutter/material.dart';

import '../theme/registration_theme.dart';

class RegistrationDetailFooter extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback onSave;

  const RegistrationDetailFooter({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onPrev,
    required this.onNext,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentStep >= totalSteps;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RgSpace.lg,
        vertical: RgSpace.md,
      ),
      decoration: BoxDecoration(
        color: RgColors.cardBg,
        border: Border(top: BorderSide(color: RgColors.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ─── ก่อนหน้า ───
          OutlinedButton.icon(
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left_rounded, size: 18),
            label: const Text('ก่อนหน้า'),
            style: OutlinedButton.styleFrom(
              foregroundColor: RgColors.textSecondary,
              side: BorderSide(color: RgColors.border, width: 1),
              padding: const EdgeInsets.symmetric(
                  horizontal: RgSpace.lg, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RgRadius.md),
              ),
            ),
          ),
          const Spacer(),

          // ─── ถัดไป / บันทึก ───
          if (!isLast)
            FilledButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right_rounded, size: 18),
              label: const Text('ถัดไป'),
              style: FilledButton.styleFrom(
                backgroundColor: RgColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: RgSpace.xl, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RgRadius.md),
                ),
              ),
            )
          else
            FilledButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('บันทึก'),
              style: FilledButton.styleFrom(
                backgroundColor: RgColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: RgSpace.xl, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RgRadius.md),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
