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
          child: compact
              ? _buildCompactLayout()
              : medium
                  ? _buildMediumLayout()
                  : _buildWideLayout(),
        );
      },
    );
  }

  /// Layout สำหรับจอกว้าง (>=720px): row เดียวทุกอย่างเรียงกัน
  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: _titleBlock(showEyebrow: true),
          ),
        ),
        if (totalCount != null) ...[
          _countBadge(),
          const SizedBox(width: LaSpace.sm),
        ],
        if (onAdd != null) _AddButton(onPressed: onAdd!),
      ],
    );
  }

  /// Layout สำหรับจอกลาง (480-720px): row เดียว แต่ add button icon-only
  Widget _buildMediumLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
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
            size: 20,
          ),
        ),
        const SizedBox(width: LaSpace.sm),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: _titleBlock(showEyebrow: false, titleSize: 18),
          ),
        ),
        if (totalCount != null) ...[
          const SizedBox(width: LaSpace.sm),
          _countBadge(compact: true),
        ],
        if (onAdd != null) ...[
          const SizedBox(width: LaSpace.sm),
          _AddButton(onPressed: onAdd!, compact: true),
        ],
      ],
    );
  }

  /// Layout สำหรับจอแคบ (<520px): icon+title บน, badge+button ล่าง
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
                color: LaColors.primary.withOpacity(.18),
                borderRadius: BorderRadius.circular(LaRadius.sm),
                border: Border.all(
                  color: LaColors.primaryAccent.withOpacity(.35),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.app_registration_rounded,
                color: LaColors.primaryAccent,
                size: 18,
              ),
            ),
            const SizedBox(width: LaSpace.sm),
            Expanded(child: _titleBlock(showEyebrow: false, titleSize: 17)),
          ],
        ),
        const SizedBox(height: LaSpace.sm),
        Row(
          children: [
            if (totalCount != null) ...[
              Expanded(child: _countBadge()),
              const SizedBox(width: LaSpace.sm),
            ] else
              const Spacer(),
            if (onAdd != null)
              _AddButton(onPressed: onAdd!, compact: true),
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
            'REGISTRATION',
            style: LaText.label.copyWith(
              color: LaColors.primaryAccent.withOpacity(.9),
              letterSpacing: 1.6,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        if (showEyebrow) const SizedBox(height: 4),
        Text(
          title,
          style: LaText.h1.copyWith(
            color: LaColors.textInverse,
            fontSize: titleSize,
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
    );
  }

  Widget _countBadge({bool compact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 5,
      ),
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
          Icon(
            Icons.format_list_numbered_rounded,
            color: LaColors.primaryAccent,
            size: compact ? 11 : 12,
          ),
          SizedBox(width: compact ? 3 : 4),
          Text(
            '$totalCount รายการ',
            style: LaText.bodyMuted.copyWith(
              color: Colors.white,
              fontFamily: LaText.fontBold,
              fontSize: compact ? 10 : 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool compact;
  const _AddButton({required this.onPressed, this.compact = false});

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
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
                width: compact ? 14 : 18,
                height: compact ? 14 : 18,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.22),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: compact ? 11 : 14,
                ),
              ),
              if (!compact) ...[
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
            ],
          ),
        ),
      ),
    );
  }
}
