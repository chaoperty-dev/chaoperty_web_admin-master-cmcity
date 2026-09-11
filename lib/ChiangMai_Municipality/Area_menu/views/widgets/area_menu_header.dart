// ============================================================================
// area_menu_header.dart
// ============================================================================
// Header ของหน้า "พื้นที่ผ่อนผัน"
// - Eyebrow + Title + subtitle + stats panel (จาก API areas/overview)
// - Responsive: จอกว้าง = title ซ้าย / stats ชิดขวา, จอแคบ = stats อยู่ใต้
//   title (เลื่อนแนวนอนได้ ไม่ overflow)
// ============================================================================

import 'package:flutter/material.dart';

import '../theme/area_menu_theme.dart';

class AreaMenuHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int? totalCount;

  // สถิติจาก API — total_area / total_leased / total_vacant / duplicate_leases
  final int? totalArea;
  final int? totalLeased;
  final int? totalVacant;
  final int? duplicateLeases;
  const AreaMenuHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.totalCount,
    this.totalArea,
    this.totalLeased,
    this.totalVacant,
    this.duplicateLeases,
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
      child: LayoutBuilder(
        builder: (context, c) {
          final hasStats = totalArea != null ||
              totalLeased != null ||
              totalVacant != null ||
              duplicateLeases != null;
          final statsPanel = hasStats ? _buildStatsPanel() : null;
          final titleBlock = _buildTitleBlock();

          // จอแคบ (<720) → stack: title บน + stats ใต้ (ชิดขวา)
          if (c.maxWidth < 720) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _iconBadge(),
                    const SizedBox(width: LaSpace.md),
                    Expanded(child: titleBlock),
                  ],
                ),
                if (statsPanel != null) ...[
                  const SizedBox(height: LaSpace.md),
                  // จอแคบ (มือถือ/แท็บเล็ต) → panel เต็มความกว้าง
                  // segment กระจายเท่ากัน
                  _buildStatsPanel(fullWidth: true),
                ],
              ],
            );
          }

          // จอกว้าง → title ซ้าย (Expanded) + stats ชิดขวา
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _iconBadge(),
              const SizedBox(width: LaSpace.md),
              Expanded(child: titleBlock),
              if (statsPanel != null) statsPanel,
            ],
          );
        },
      ),
    );
  }

  Widget _iconBadge() {
    return Container(
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
        Icons.area_chart_rounded,
        color: LaColors.primaryAccent,
        size: 22,
      ),
    );
  }

  Widget _buildTitleBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'AREA OVERVIEW',
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

  /// panel stats — segment คั่น divider
  /// [fullWidth] = จอแคบ: เต็มความกว้าง segment กระจายเท่ากัน
  Widget _buildStatsPanel({bool fullWidth = false}) {
    final segments = <Widget>[
      if (totalArea != null)
        _statSegment(
          icon: Icons.grid_view_rounded,
          value: totalArea!,
          label: 'พื้นที่ทั้งหมด',
          valueColor: Colors.white,
        ),
      if (totalLeased != null)
        _statSegment(
          icon: Icons.event_available_rounded,
          value: totalLeased!,
          label: 'ไม่ว่าง',
          valueColor: LaColors.primaryAccent,
        ),
      if (totalVacant != null)
        _statSegment(
          icon: Icons.event_busy_rounded,
          value: totalVacant!,
          label: 'ว่าง',
          valueColor: Colors.white.withOpacity(.85),
        ),
      if (duplicateLeases != null && duplicateLeases! > 0)
        _statSegment(
          icon: Icons.copy_all_rounded,
          value: duplicateLeases!,
          label: 'สัญญาซ้ำ',
          valueColor: const Color(0xFFFFB74D),
        ),
    ];

    Widget row;
    if (fullWidth) {
      // เต็มความกว้าง — segment แบ่งพื้นที่เท่ากัน
      row = Row(
        children: [
          for (int i = 0; i < segments.length; i++) ...[
            if (i > 0) _divider(),
            Expanded(child: Center(child: segments[i])),
          ],
        ],
      );
    } else {
      row = Row(mainAxisSize: MainAxisSize.min, children: [
        for (int i = 0; i < segments.length; i++) ...[
          if (i > 0) _divider(),
          segments[i],
        ],
      ]);
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: LaSpace.sm, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(
          color: Colors.white.withOpacity(.12),
          width: 1,
        ),
      ),
      child: row,
    );
  }

  /// segment ตัวเลข + label — ตัวเลขใหญ่บน, label เล็กใต้
  Widget _statSegment({
    required IconData icon,
    required int value,
    required String label,
    required Color valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LaSpace.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: LaColors.primaryAccent.withOpacity(.9), size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$value',
                style: LaText.h1.copyWith(
                  color: valueColor,
                  fontSize: 16,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: LaText.caption.copyWith(
                  color: Colors.white.withOpacity(.6),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 28,
        color: Colors.white.withOpacity(.12),
      );
}