// ============================================================================
// registration_header.dart
// ============================================================================
// Header ของหน้า "ทะเบียน"
// - Eyebrow + Title + subtitle + ปุ่ม "เพิ่มทะเบียน"
// - ใช้ gradient + glow แทนการใช้พื้นหลังเรียบ
// ============================================================================

import 'package:flutter/material.dart';

import '../theme/registration_theme.dart';

class RegistrationHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int? totalCount;
  final VoidCallback? onAdd;
  const RegistrationHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.totalCount,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            LaColors.headerBg,
            LaColors.headerAccent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(LaRadius.lg),
        boxShadow: [
          BoxShadow(
            color: LaColors.primary.withOpacity(.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: LaColors.primary.withOpacity(.18),
              borderRadius: BorderRadius.circular(LaRadius.md),
              border: Border.all(
                color: LaColors.primaryAccent.withOpacity(.35),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.app_registration_rounded,
              color: LaColors.primaryAccent,
              size: 22,
            ),
          ),
          const SizedBox(width: LaSpace.md),
          // Title block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'REGISTRATION',
                  style: LaText.label.copyWith(
                    color: LaColors.primaryAccent.withOpacity(.9),
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: LaText.h1.copyWith(
                    color: LaColors.textInverse,
                    fontSize: 20,
                  ),
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
          // Count badge
          if (totalCount != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.08),
                borderRadius: BorderRadius.circular(LaRadius.pill),
                border: Border.all(
                  color: Colors.white.withOpacity(.18),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.format_list_numbered_rounded,
                    color: LaColors.primaryAccent,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$totalCount รายการ',
                    style: LaText.bodyMuted.copyWith(
                      color: Colors.white,
                      fontFamily: LaText.fontBold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: LaSpace.sm),
          ],
          // Add button
          if (onAdd != null) _AddButton(onPressed: onAdd!),
        ],
      ),
    );
  }
}

class _AddButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _AddButton({required this.onPressed});

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (mounted) setState(() => _down = true);
      },
      onTapCancel: () {
        if (mounted) setState(() => _down = false);
      },
      onTapUp: (_) {
        if (mounted) setState(() => _down = false);
      },
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1.0,
        duration: LrAnimations.fast,
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [LaColors.primaryAccent, LaColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(LaRadius.md),
            boxShadow: [
              BoxShadow(
                color: LaColors.primary.withOpacity(.45),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.22),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'เพิ่มทะเบียน',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: LaText.fontBold,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
