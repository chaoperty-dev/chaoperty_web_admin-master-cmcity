// ============================================================================
// license_request_header.dart
// ============================================================================
// Header ของหน้า "คำขอต่อสัญญา"
// - Eyebrow + Title + subtitle + ปุ่ม "สร้างคำขอ"
// - ใช้ gradient + glow แทนการใช้พื้นหลังเรียบ
// ============================================================================

import 'package:flutter/material.dart';

import '../theme/license_request_theme.dart';

class LicenseRequestHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int? totalCount;
  final VoidCallback? onCreate;

  const LicenseRequestHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.totalCount,
    this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            LrColors.headerBg,
            LrColors.headerAccent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(LrRadius.lg),
        boxShadow: [
          BoxShadow(
            color: LrColors.primary.withOpacity(.15),
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
              color: LrColors.primary.withOpacity(.18),
              borderRadius: BorderRadius.circular(LrRadius.md),
              border: Border.all(
                color: LrColors.primaryAccent.withOpacity(.35),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.assignment_rounded,
              color: LrColors.primaryAccent,
              size: 22,
            ),
          ),
          const SizedBox(width: LrSpace.md),
          // Title block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'LICENSE REQUEST',
                  style: LrText.label.copyWith(
                    color: LrColors.primaryAccent.withOpacity(.9),
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: LrText.h1.copyWith(
                    color: LrColors.textInverse,
                    fontSize: 20,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: LrText.caption.copyWith(
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
                borderRadius: BorderRadius.circular(LrRadius.pill),
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
                    color: LrColors.primaryAccent,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$totalCount รายการ',
                    style: LrText.bodyMuted.copyWith(
                      color: Colors.white,
                      fontFamily: LrText.fontBold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: LrSpace.sm),
          ],
          // Create button
          if (onCreate != null) _CreateButton(onPressed: onCreate!),
        ],
      ),
    );
  }
}

class _CreateButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _CreateButton({required this.onPressed});

  @override
  State<_CreateButton> createState() => _CreateButtonState();
}

class _CreateButtonState extends State<_CreateButton> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: _down ? 0.97 : (_hover ? 1.02 : 1.0),
        duration: LrAnimations.fast,
        curve: Curves.easeOut,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _down = true),
          onTapCancel: () => setState(() => _down = false),
          onTapUp: (_) => setState(() => _down = false),
          onTap: widget.onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [LrColors.primaryAccent, LrColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(LrRadius.md),
              boxShadow: [
                BoxShadow(
                  color: LrColors.primary.withOpacity(.45),
                  blurRadius: _hover ? 14 : 8,
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
                  'สร้างคำขอ',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: LrText.fontBold,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
