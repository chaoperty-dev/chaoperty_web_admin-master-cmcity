// ============================================================================
// registration_detail_header.dart
// ============================================================================
// Header — ใช้ในหน้า Detail (2-step)
// - มีปุ่ม Back / Title / Step indicator
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/registration_theme.dart';
import '../../viewmodels/registration_detail_view_model.dart';

class RegistrationDetailHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;

  const RegistrationDetailHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    // Touch VM so it rebuilds
    context.watch<RegistrationDetailViewModel>();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            RgColors.headerBg,
            RgColors.headerAccent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(RgRadius.lg),
          bottomRight: Radius.circular(RgRadius.lg),
        ),
        boxShadow: [
          BoxShadow(
            color: RgColors.primary.withOpacity(.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // ─── Back button ───
          IconButton(
            tooltip: 'กลับ',
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: RgColors.textInverse,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(.10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RgRadius.sm),
              ),
            ),
          ),
          const SizedBox(width: RgSpace.md),

          // ─── Title + Subtitle ───
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'REGISTRATION',
                  style: RgText.label.copyWith(
                    color: RgColors.primaryAccent.withOpacity(.9),
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: RgText.h1.copyWith(
                    color: RgColors.textInverse,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: RgText.caption.copyWith(
                    color: Colors.white.withOpacity(.65),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // ─── Step indicator ───
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.10),
              borderRadius: BorderRadius.circular(RgRadius.pill),
              border: Border.all(
                color: Colors.white.withOpacity(.20),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.timeline_rounded,
                  color: RgColors.textInverse,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'Step $currentStep/$totalSteps',
                  style: RgText.caption.copyWith(
                    color: Colors.white,
                    fontFamily: RgText.fontBold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
