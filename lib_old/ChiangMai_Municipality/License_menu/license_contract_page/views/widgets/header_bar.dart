// ============================================================================
// header_bar.dart
// ============================================================================
// Header bar ของ "หน้าสร้างสัญญา" (Step 1: ผู้เช่า)
// - Gradient slate-900 → slate-800 + glow
// - Back button (icon) แทน close (เพราะเป็น page ไม่ใช่ dialog)
// - Step badge "ขั้นตอนที่ 1 / 3" เพื่อบอก progress
// ============================================================================

import 'package:flutter/material.dart';

import '../theme/license_contract_theme.dart';

class HeaderBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const HeaderBar({
    super.key,
    required this.title,
    this.subtitle,
    this.currentStep = 1,
    this.totalSteps = 3,
    this.onBack,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [LcColors.headerBg, LcColors.headerAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: LcColors.primary.withOpacity(.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back button
          _IconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'ย้อนกลับ',
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: LcSpace.md),
          // Icon badge
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: LcColors.primary.withOpacity(.18),
              borderRadius: BorderRadius.circular(LcRadius.md),
              border: Border.all(
                color: LcColors.primaryAccent.withOpacity(.35),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.description_rounded,
              color: LcColors.primaryAccent,
              size: 22,
            ),
          ),
          const SizedBox(width: LcSpace.md),
          // Title block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      'LICENSE CONTRACT',
                      style: LcText.label.copyWith(
                        color: LcColors.primaryAccent.withOpacity(.9),
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(width: LcSpace.sm),
                    // Step badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.10),
                        borderRadius: BorderRadius.circular(LcRadius.pill),
                        border: Border.all(
                          color: Colors.white.withOpacity(.18),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'ขั้นตอนที่ $currentStep/$totalSteps',
                        style: LcText.caption.copyWith(
                          color: Colors.white,
                          fontFamily: LcText.fontBold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: LcText.h1.copyWith(
                    color: LcColors.textInverse,
                    fontSize: 18,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: LcText.caption.copyWith(
                      color: Colors.white.withOpacity(.65),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}

class _IconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _IconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_IconButton> createState() => _IconButtonState();
}

class _IconButtonState extends State<_IconButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: LcAnimations.fast,
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _hover
                  ? Colors.white.withOpacity(.18)
                  : Colors.white.withOpacity(.08),
              borderRadius: BorderRadius.circular(LcRadius.sm),
              border: Border.all(
                color: Colors.white.withOpacity(.20),
                width: 1,
              ),
            ),
            child: Icon(widget.icon, size: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
