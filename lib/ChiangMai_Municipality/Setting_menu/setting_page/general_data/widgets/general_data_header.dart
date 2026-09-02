// ============================================================================
// general_data_header.dart
// ============================================================================
// Header — สไตล์เดียวกับ AreaHeader (dark gradient + icon badge + title block)
// - Gradient slate-900 → slate-800 + glow
// - Back button + Icon badge + Eyebrow + Title + subtitle
// ============================================================================

import 'package:flutter/material.dart';

import 'package:chaoperty/ChiangMai_Municipality/License_menu/license_fact_check_page/views/theme/license_fact_check_theme.dart';

class GeneralDataHeader extends StatelessWidget {
  final VoidCallback onBack;
  final String title;
  final String? subtitle;
  final IconData icon;

  const GeneralDataHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.subtitle,
    this.icon = Icons.info_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    return Container(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 12 : 20,
        isMobile ? 10 : 16,
        isMobile ? 12 : 20,
        isMobile ? 10 : 16,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [LaColors.headerBg, LaColors.headerAccent],
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
          // Back button
          _BackButton(onTap: onBack),
          SizedBox(width: isMobile ? 8 : LaSpace.sm),

          // Icon badge
          Container(
            width: isMobile ? 38 : 44,
            height: isMobile ? 38 : 44,
            decoration: BoxDecoration(
              color: LaColors.primary.withOpacity(.18),
              borderRadius: BorderRadius.circular(LaRadius.md),
              border: Border.all(
                color: LaColors.primaryAccent.withOpacity(.35),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: LaColors.primaryAccent,
              size: isMobile ? 18 : 22,
            ),
          ),
          SizedBox(width: isMobile ? 8 : LaSpace.md),

          // Title block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'RENTAL GENERAL',
                  style: LaText.label.copyWith(
                    color: LaColors.primaryAccent.withOpacity(.9),
                    letterSpacing: 1.6,
                    fontSize: isMobile ? 9 : 10,
                  ),
                ),
                SizedBox(height: isMobile ? 2 : 4),
                Text(
                  title,
                  style: LaText.h1.copyWith(
                    color: LaColors.textInverse,
                    fontSize: isMobile ? 16 : 20,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
        ],
      ),
    );
  }
}

/// Back button — hover-aware (เหมือน AreaHeader)
class _BackButton extends StatefulWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Tooltip(
        message: 'ย้อนกลับ',
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 40,
            height: 40,
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
            child: const Icon(
              Icons.arrow_back_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
