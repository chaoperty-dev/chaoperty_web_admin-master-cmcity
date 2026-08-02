// ============================================================================
// personal_information_signature_section.dart
// ============================================================================
// Section แสดง preview ลายเซ็น (placeholder ถ้ายังไม่มี)
// ============================================================================

import 'package:flutter/material.dart';
import '../../models/personal_information_models.dart';
import '../theme/personal_information_theme.dart';

class PersonalInformationSignatureSection extends StatelessWidget {
  final AdminProfile profile;
  const PersonalInformationSignatureSection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final hasSignature = profile.hasSignature;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ลายเซ็น', style: PiText.h3),
        const SizedBox(height: PiSpace.md),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: PiSpace.isMobile(context) ? double.infinity : 360,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(PiRadius.md),
              border: Border.all(
                color: hasSignature ? PiColors.border : const Color(0xFFFCD34D),
                width: hasSignature ? 1 : 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: hasSignature
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(PiRadius.md - 1),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Image.memory(
                        profile.signatureBytes!,
                        height: 240,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image_outlined,
                          size: 36,
                          color: PiColors.textMuted,
                        ),
                      ),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.draw_rounded,
                        size: 36,
                        color: PiColors.textMuted,
                      ),
                      const SizedBox(height: PiSpace.sm),
                      Text(
                        'ยังไม่มีลายเซ็น',
                        style: PiText.bodyMuted,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'กดปุ่ม "แก้ไขลายเซ็น" เพื่อเพิ่ม',
                        style: PiText.caption,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
