// ============================================================================
// personal_information_signature_section.dart
// ============================================================================
// Section แสดง preview ลายเซ็น (placeholder ถ้ายังไม่มี)
// อยู่ตรงกลาง + มีไอคอนลูกตาเปิด/ปิด (blur effect)
// ============================================================================

import 'dart:ui';

import 'package:flutter/material.dart';
import '../../models/personal_information_models.dart';
import '../theme/personal_information_theme.dart';

class PersonalInformationSignatureSection extends StatefulWidget {
  final AdminProfile profile;
  const PersonalInformationSignatureSection({
    super.key,
    required this.profile,
  });

  @override
  State<PersonalInformationSignatureSection> createState() =>
      _PersonalInformationSignatureSectionState();
}

class _PersonalInformationSignatureSectionState
    extends State<PersonalInformationSignatureSection> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final hasSignature = widget.profile.hasSignature;
    final isMobile = PiSpace.isMobile(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Header: หัวข้อ + ไอคอนลูกตา
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('ลายเซ็น', style: PiText.h3),
            const SizedBox(width: PiSpace.sm),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => setState(() => _visible = !_visible),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: PiColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(PiRadius.sm),
                    border: Border.all(color: PiColors.border, width: 1),
                  ),
                  child: Tooltip(
                    message: _visible ? 'ซ่อนลายเซ็น' : 'แสดงลายเซ็น',
                    child: Icon(
                      _visible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: PiColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: PiSpace.md),
        Center(
          child: Stack(
            children: [
              Container(
                width: isMobile ? double.infinity : 360,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(PiRadius.md),
                  border: Border.all(
                    color: hasSignature
                        ? PiColors.border
                        : const Color(0xFFFCD34D),
                    width: hasSignature ? 1 : 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(PiRadius.md - 1),
                  child: hasSignature
                      ? ImageFiltered(
                          imageFilter: _visible
                              ? ImageFilter.blur(sigmaX: 0, sigmaY: 0)
                              : ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Image.memory(
                              widget.profile.signatureBytes!,
                              height: 240,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.broken_image_outlined,
                                size: 36,
                                color: PiColors.textMuted,
                              ),
                            ),
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.draw_rounded,
                              size: 36,
                              color: PiColors.textMuted,
                            ),
                            SizedBox(height: PiSpace.sm),
                            Text(
                              'ยังไม่มีลายเซ็น',
                              style: PiText.bodyMuted,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'กดปุ่ม "แก้ไขลายเซ็น" เพื่อเพิ่ม',
                              style: PiText.caption,
                            ),
                          ],
                        ),
                ),
              ),
              // ป้าย "ซ่อนอยู่" เมื่อ blur
              if (!_visible && hasSignature)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.25),
                        borderRadius: BorderRadius.circular(PiRadius.md - 1),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.55),
                          borderRadius: BorderRadius.circular(PiRadius.pill),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.visibility_off_outlined,
                                size: 14, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'ซ่อนลายเซ็น',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
