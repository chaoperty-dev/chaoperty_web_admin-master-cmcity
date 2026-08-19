// ============================================================================
// license_announce_header.dart
// ============================================================================
// Header ของหน้า "ประกาศ"
// - Eyebrow + Title + subtitle + ปุ่ม "เพิ่มประกาศ"
// - Gradient + glow + count badge + interactive button
// - Responsive: wide / medium / compact (เหมือน Registration header)
// ============================================================================

import 'package:flutter/material.dart';
import '../theme/license_announce_theme.dart';

class LicenseAnnounceHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int? totalCount;
  final VoidCallback? onCreate;

  const LicenseAnnounceHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.totalCount,
    this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final compact = w < 480;
        final medium = !compact && w < 720;
        return Container(
          padding: EdgeInsets.fromLTRB(
            compact ? 14 : 20,
            compact ? 12 : 16,
            compact ? 14 : 20,
            compact ? 12 : 16,
          ),
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
          child: compact
              ? _buildCompactLayout()
              : medium
                  ? _buildMediumLayout()
                  : _buildWideLayout(),
        );
      },
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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
            Icons.campaign_rounded,
            color: LrColors.primaryAccent,
            size: 22,
          ),
        ),
        const SizedBox(width: LrSpace.md),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: _titleBlock(showEyebrow: true),
          ),
        ),
        if (totalCount != null) ...[
          _countBadge(),
          const SizedBox(width: LrSpace.sm),
        ],
        if (onCreate != null)
          _CreateButton(
            onPressed: onCreate!,
            label: 'เพิ่มประกาศ',
            icon: Icons.add_rounded,
          ),
      ],
    );
  }

  Widget _buildMediumLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: LrColors.primary.withOpacity(.18),
            borderRadius: BorderRadius.circular(LrRadius.md),
            border: Border.all(
              color: LrColors.primaryAccent.withOpacity(.35),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.campaign_rounded,
            color: LrColors.primaryAccent,
            size: 20,
          ),
        ),
        const SizedBox(width: LrSpace.sm),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: _titleBlock(showEyebrow: false, titleSize: 18),
          ),
        ),
        if (totalCount != null) ...[
          const SizedBox(width: LrSpace.sm),
          _countBadge(compact: true),
        ],
        if (onCreate != null) ...[
          const SizedBox(width: LrSpace.sm),
          _CreateButton(
            onPressed: onCreate!,
            label: 'เพิ่มประกาศ',
            icon: Icons.add_rounded,
            compact: true,
          ),
        ],
      ],
    );
  }

  Widget _buildCompactLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: LrColors.primary.withOpacity(.18),
                borderRadius: BorderRadius.circular(LrRadius.sm),
                border: Border.all(
                  color: LrColors.primaryAccent.withOpacity(.35),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.campaign_rounded,
                color: LrColors.primaryAccent,
                size: 18,
              ),
            ),
            const SizedBox(width: LrSpace.sm),
            Expanded(child: _titleBlock(showEyebrow: false, titleSize: 17)),
          ],
        ),
        const SizedBox(height: LrSpace.sm),
        Row(
          children: [
            if (totalCount != null) ...[
              Expanded(child: _countBadge()),
              const SizedBox(width: LrSpace.sm),
            ] else
              const Spacer(),
            if (onCreate != null)
              _CreateButton(
                onPressed: onCreate!,
                label: 'เพิ่มประกาศ',
                icon: Icons.add_rounded,
                compact: true,
              ),
          ],
        ),
      ],
    );
  }

  Widget _titleBlock({required bool showEyebrow, double titleSize = 20}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showEyebrow)
          Text(
            'LICENSE ANNOUNCE',
            style: LrText.label.copyWith(
              color: LrColors.primaryAccent.withOpacity(.9),
              letterSpacing: 1.6,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        if (showEyebrow) const SizedBox(height: 4),
        Text(
          title,
          style: LrText.h1.copyWith(
            color: LrColors.textInverse,
            fontSize: titleSize,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _countBadge({bool compact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
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
          Icon(
            Icons.format_list_numbered_rounded,
            color: LrColors.primaryAccent,
            size: compact ? 11 : 14,
          ),
          SizedBox(width: compact ? 3 : 6),
          Text(
            '$totalCount รายการ',
            style: LrText.bodyMuted.copyWith(
              color: Colors.white,
              fontFamily: LrText.fontBold,
              fontSize: compact ? 10 : 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CreateButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final bool compact;
  const _CreateButton({
    required this.onPressed,
    required this.label,
    required this.icon,
    this.compact = false,
  });

  @override
  State<_CreateButton> createState() => _CreateButtonState();
}

class _CreateButtonState extends State<_CreateButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final compact = widget.compact;
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
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 16,
            vertical: compact ? 7 : 10,
          ),
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
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: compact ? 14 : 18,
                height: compact ? 14 : 18,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.22),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: compact ? 11 : 14,
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontFamily: LrText.fontBold,
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}