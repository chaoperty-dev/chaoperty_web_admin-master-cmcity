// ============================================================================
// license_request_header.dart
// ============================================================================
// Header ของหน้า "คำขอต่อสัญญา"
// - Eyebrow + Title + subtitle + ปุ่ม "สร้างคำขอ"
// - ใช้ gradient + glow แทนการใช้พื้นหลังเรียบ
// - Responsive: wide / medium / compact (เหมือน Registration header)
// - ใช้ context.select<LicenseRequestViewModel, _HeaderData> 1-arg selector
//   เพื่อ rebuild เฉพาะเมื่อ title / total / onCreate เปลี่ยน
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/license_request_view_model.dart';
import '../theme/license_request_theme.dart';

class LicenseRequestHeader extends StatelessWidget {
  final String? subtitle;

  const LicenseRequestHeader({super.key, this.subtitle});

  @override
  Widget build(BuildContext context) {
    // 1-arg selector: rebuild เฉพาะเมื่อ title/totalCount/onCreate เปลี่ยน
    final selected = context.select<LicenseRequestViewModel, _HeaderData>(
      (vm) => _HeaderData(
        title: vm.title,
        total: vm.total,
        onCreate: vm.onCreateRequest,
      ),
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
              ? _buildCompactLayout(selected, subtitle)
              : medium
                  ? _buildMediumLayout(selected, subtitle)
                  : _buildWideLayout(selected, subtitle),
        );
      },
    );
  }

  Widget _buildWideLayout(_HeaderData data, String? subtitle) {
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
            Icons.assignment_rounded,
            color: LrColors.primaryAccent,
            size: 22,
          ),
        ),
        const SizedBox(width: LrSpace.md),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: _titleBlock(data.title, subtitle, showEyebrow: true),
          ),
        ),
        _countBadge(data.total),
        const SizedBox(width: LrSpace.sm),
        _CreateButton(onPressed: data.onCreate),
      ],
    );
  }

  Widget _buildMediumLayout(_HeaderData data, String? subtitle) {
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
            Icons.assignment_rounded,
            color: LrColors.primaryAccent,
            size: 20,
          ),
        ),
        const SizedBox(width: LrSpace.sm),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: _titleBlock(data.title, subtitle, showEyebrow: false, titleSize: 18),
          ),
        ),
        const SizedBox(width: LrSpace.sm),
        _countBadge(data.total, compact: true),
        const SizedBox(width: LrSpace.sm),
        _CreateButton(onPressed: data.onCreate, compact: true),
      ],
    );
  }

  Widget _buildCompactLayout(_HeaderData data, String? subtitle) {
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
                Icons.assignment_rounded,
                color: LrColors.primaryAccent,
                size: 18,
              ),
            ),
            const SizedBox(width: LrSpace.sm),
            Expanded(child: _titleBlock(data.title, subtitle, showEyebrow: false, titleSize: 17)),
          ],
        ),
        const SizedBox(height: LrSpace.sm),
        Row(
          children: [
            Expanded(child: _countBadge(data.total)),
            const SizedBox(width: LrSpace.sm),
            _CreateButton(onPressed: data.onCreate, compact: true),
          ],
        ),
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
            'LICENSE REQUEST',
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
            subtitle,
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

  Widget _countBadge(int totalCount, {bool compact = false}) {
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
  final bool compact;
  const _CreateButton({required this.onPressed, this.compact = false});

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
                  Icons.add_rounded,
                  color: Colors.white,
                  size: compact ? 11 : 14,
                ),
              ),
              if (!compact) ...[
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
            ],
          ),
        ),
      ),
    );
  }
}

/// ค่า tuple ที่ header ต้อง watch — ใช้กับ context.select 1-arg
class _HeaderData {
  final String title;
  final int total;
  final VoidCallback onCreate;
  const _HeaderData({
    required this.title,
    required this.total,
    required this.onCreate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _HeaderData &&
        other.title == title &&
        other.total == total &&
        other.onCreate == onCreate;
  }

  @override
  int get hashCode => Object.hash(title, total, onCreate);
}
