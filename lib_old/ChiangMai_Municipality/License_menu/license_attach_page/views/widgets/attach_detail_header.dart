// ============================================================================
// attach_detail_header.dart
// ============================================================================
// Header bar ของหน้า "แนบหลักฐาน" (Step 1 / Step 2)
// ============================================================================

import 'package:flutter/material.dart';

import '../theme/license_attach_theme.dart';

class AttachDetailHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const AttachDetailHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.currentStep = 1,
    this.totalSteps = 2,
    this.onBack,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [LaColors.headerBg, LaColors.headerAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: LaColors.primary.withOpacity(.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _IconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'กลับไปหน้ารายการ',
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: LaSpace.md),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: LaColors.primary.withOpacity(.18),
              borderRadius: BorderRadius.circular(LaRadius.md),
              border: Border.all(
                color: LaColors.primaryAccent.withOpacity(.35),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.attach_file_rounded,
              color: LaColors.primaryAccent,
              size: 22,
            ),
          ),
          const SizedBox(width: LaSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      'LICENSE ATTACH',
                      style: LaText.label.copyWith(
                        color: LaColors.primaryAccent.withOpacity(.9),
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(width: LaSpace.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.10),
                        borderRadius: BorderRadius.circular(LaRadius.pill),
                        border: Border.all(
                          color: Colors.white.withOpacity(.18),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'ขั้นตอนที่ $currentStep/$totalSteps',
                        style: LaText.caption.copyWith(
                          color: Colors.white,
                          fontFamily: LaText.fontBold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: LaText.h1.copyWith(
                    color: LaColors.textInverse,
                    fontSize: 18,
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
            duration: const Duration(milliseconds: 120),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _hover
                  ? Colors.white.withOpacity(.18)
                  : Colors.white.withOpacity(.08),
              borderRadius: BorderRadius.circular(LaRadius.sm),
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
