// ============================================================================
// verify_header.dart
// ============================================================================
// Header ของหน้า "ตรวจสอบเอกสารสำคัญอนุญาต"
// - Eyebrow + Title + subtitle (ไม่มีปุ่ม Create)
// - ใช้ gradient + glow แทนการใช้พื้นหลังเรียบ
// - Responsive: wide / medium / compact (เหมือน Registration header)
// - ใช้ context.select<LicenseVerifyViewModel, _VHeaderData> 1-arg selector
//   เพื่อ rebuild เฉพาะเมื่อ title / total เปลี่ยน
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/license_verify_view_model.dart';
import '../theme/license_verify_theme.dart';

class VerifyHeader extends StatelessWidget {
  final String? subtitle;
  const VerifyHeader({super.key, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final selected = context.select<LicenseVerifyViewModel, _VHeaderData>(
      (vm) => _VHeaderData(title: vm.title, total: vm.total),
    );
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
              ? _buildCompactLayout(selected, subtitle)
              : medium
                  ? _buildMediumLayout(selected, subtitle)
                  : _buildWideLayout(selected, subtitle),
        );
      },
    );
  }

  Widget _buildWideLayout(_VHeaderData data, String? subtitle) {
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
            Icons.attach_file_rounded,
            color: LaColors.primaryAccent,
            size: 22,
          ),
        ),
        const SizedBox(width: LaSpace.md),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: _titleBlock(data.title, subtitle, showEyebrow: true),
          ),
        ),
        _countBadge(data.total),
        const SizedBox(width: LaSpace.sm),
      ],
    );
  }

  Widget _buildMediumLayout(_VHeaderData data, String? subtitle) {
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
            Icons.attach_file_rounded,
            color: LaColors.primaryAccent,
            size: 20,
          ),
        ),
        const SizedBox(width: LaSpace.sm),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: _titleBlock(data.title, subtitle, showEyebrow: false, titleSize: 18),
          ),
        ),
        const SizedBox(width: LaSpace.sm),
        _countBadge(data.total, compact: true),
      ],
    );
  }

  Widget _buildCompactLayout(_VHeaderData data, String? subtitle) {
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
                Icons.attach_file_rounded,
                color: LaColors.primaryAccent,
                size: 18,
              ),
            ),
            const SizedBox(width: LaSpace.sm),
            Expanded(child: _titleBlock(data.title, subtitle, showEyebrow: false, titleSize: 17)),
          ],
        ),
        const SizedBox(height: LaSpace.sm),
        _countBadge(data.total),
      ],
    );
  }

  Widget _titleBlock(
    String title,
    String? subtitle, {
    required bool showEyebrow,
    double titleSize = 20,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showEyebrow)
          Text(
            'LICENSE VERIFY',
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
            subtitle,
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

  Widget _countBadge(int totalCount, {bool compact = false}) {
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

/// tuple สำหรับ context.select 1-arg
class _VHeaderData {
  final String title;
  final int total;
  const _VHeaderData({required this.title, required this.total});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _VHeaderData && other.title == title && other.total == total;
  }

  @override
  int get hashCode => Object.hash(title, total);
}
