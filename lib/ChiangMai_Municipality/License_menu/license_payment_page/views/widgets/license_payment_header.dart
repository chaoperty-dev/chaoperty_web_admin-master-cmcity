// ============================================================================
// license_payment_header.dart
// ============================================================================
// Header ของหน้า "การรับชำระ"
// - Eyebrow + Title + subtitle (ไม่มีปุ่ม Create)
// - ใช้ gradient + glow แทนการใช้พื้นหลังเรียบ
// - Responsive: wide / medium / compact (เหมือน Registration header)
// ============================================================================

import 'package:flutter/material.dart';

import '../theme/license_payment_theme.dart';

class LicensePaymentHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int? totalCount;
  const LicensePaymentHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.totalCount,
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
            Icons.payments_rounded,
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
            color: LaColors.primary.withOpacity(.18),
            borderRadius: BorderRadius.circular(LaRadius.md),
            border: Border.all(
              color: LaColors.primaryAccent.withOpacity(.35),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.payments_rounded,
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
                color: LaColors.primary.withOpacity(.18),
                borderRadius: BorderRadius.circular(LaRadius.sm),
                border: Border.all(
                  color: LaColors.primaryAccent.withOpacity(.35),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.payments_rounded,
                color: LaColors.primaryAccent,
                size: 18,
              ),
            ),
            const SizedBox(width: LaSpace.sm),
            Expanded(child: _titleBlock(showEyebrow: false, titleSize: 17)),
          ],
        ),
        if (totalCount != null) ...[
          const SizedBox(height: LaSpace.sm),
          _countBadge(),
        ],
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
            'LICENSE PAYMENT ACCEPTANCE',
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
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
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
            size: compact ? 11 : 14,
          ),
          SizedBox(width: compact ? 3 : 6),
          Text(
            '$totalCount รายการ',
            style: LaText.bodyMuted.copyWith(
              color: Colors.white,
              fontFamily: LaText.fontBold,
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