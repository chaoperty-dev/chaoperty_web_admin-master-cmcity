// ============================================================================
// area_table.dart
// ============================================================================
// ตารางแสดงรายการ "Area" — ดีไซน์เดียวกับ verify_table.dart
// - Card-based header + alternating rows + hover state
// - Status pill ใช้สีตามสถานะ (ว่าง / ไม่ว่าง)
// - ปุ่ม "เรียกดู" เป็น pill button (action column fixed width 110)
// - Empty / loading state สวยงาม
// - ใช้ AutoSizeText ป้องกัน text overflow ในคอลัมน์แคบ
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/area_theme.dart';
import '../../models/area_area_model.dart';
import '../../viewmodels/area_view_model.dart';

class AreaTable extends StatelessWidget {
  final void Function(AreaAreaModel area)? onEdit;
  const AreaTable({super.key, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AreaViewModel>();
    final rows = vm.pagedFiltered;

    if (vm.isLoading && rows.isEmpty) {
      return const _LoadingState();
    }
    if (rows.isEmpty) {
      return _EmptyState(
        hasFilter: vm.searchQuery.isNotEmpty,
        onRefresh: vm.refresh,
      );
    }

    return Column(
      children: [
        if (vm.isLoading)
          const LinearProgressIndicator(
            minHeight: 2,
            backgroundColor: AeaColors.surfaceMuted,
            valueColor: AlwaysStoppedAnimation<Color>(AeaColors.primary),
          ),
        // ── สลับมุมมองจาก ViewModel.viewMode ──
        if (vm.viewMode == AreaViewMode.table)
          _AreaListTable(
            rows: rows,
            onEdit: onEdit,
          )
        else
          _AreaGrid(
            rows: rows,
            onEdit: onEdit,
          ),
      ],
    );
  }
}

class _AreaListTable extends StatelessWidget {
  final List<AreaAreaModel> rows;
  final void Function(AreaAreaModel area)? onEdit;
  const _AreaListTable({required this.rows, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AeaDecor.card(),
      child: Column(
        children: [
          _headerRow(),
          const Divider(height: 1, color: AeaColors.border),
          for (int i = 0; i < rows.length; i++)
            _dataRow(context, rows[i], i, onEdit),
        ],
      ),
    );
  }

  // ========================================================================
  // Header — ใช้ flex: x และ width: 110 สำหรับ action (เหมือน verify_table)
  // ========================================================================
  Widget _headerRow() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AeaSpace.md, vertical: AeaSpace.md),
      decoration: const BoxDecoration(
        color: AeaColors.surfaceMuted,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AeaRadius.lg),
          topRight: Radius.circular(AeaRadius.lg),
        ),
      ),
      child: const Row(
        children: [
          _HeaderCell(label: '', flex: 0, width: 110),
          _HeaderCell(label: 'โซนพื้นที่', flex: 2),
          _HeaderCell(label: 'รหัสพื้นที่', flex: 3),
          _HeaderCell(label: 'ชื่อพื้นที่', flex: 2),
          _HeaderCell(label: 'ขนาด(ตร.ม.)', flex: 2),
          _HeaderCell(label: 'ค่าเช่า', flex: 2),
          _HeaderCell(label: 'สถานะ', flex: 2),
        ],
      ),
    );
  }

  // ========================================================================
  // Data row
  // ========================================================================
  Widget _dataRow(
    BuildContext context,
    AreaAreaModel a,
    int index,
    void Function(AreaAreaModel)? onEditCb,
  ) {
    final status = _deriveStatus(a);
    final palette = status.palette;
    return _HoverableRow(
      index: index,
      onTap: () {
        if (onEditCb != null) onEditCb(a);
      },
      child: Row(
        children: [
          // Action — fixed width 110 (เหมือน verify_table)
          SizedBox(
            width: 110,
            child: Center(
              child: _ViewButton(onTap: () {
                if (onEditCb != null) onEditCb(a);
              }),
            ),
          ),
          _Cell(value: a.zn, flex: 2, muted: true),
          _Cell(
              value: a.lncode.isEmpty ? '-' : a.lncode, flex: 2, isMono: true),
          _Cell(
              value: a.ln.isEmpty ? '-' : a.ln,
              tooltip: a.ln.isEmpty ? '-' : a.ln,
              flex: 3),

          _Cell(
              value: '${a.area.isEmpty ? '0.00' : a.area}',
              flex: 2,
              isMono: true),
          _Cell(
              value: '${a.rent.isEmpty ? '0.00' : a.rent}',
              flex: 2,
              isMono: true),
          Expanded(
            flex: 2,
            child: _StatusPillBox(
              label: status.label,
              palette: palette,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Internal widgets — สไตล์ verify_table.dart
// ============================================================================

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  final double? width;
  const _HeaderCell({required this.label, this.flex = 1, this.width});

  @override
  Widget build(BuildContext context) {
    final child = Text(
      label,
      style: AeaText.tableHeader,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    if (width != null) {
      return SizedBox(width: width, child: Center(child: child));
    }
    return Expanded(flex: flex, child: child);
  }
}

class _Cell extends StatelessWidget {
  final String value;
  final int flex;
  final bool isMono;
  final bool muted;
  final String? tooltip;
  const _Cell({
    required this.value,
    this.flex = 1,
    this.isMono = false,
    this.muted = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Tooltip(
          message: tooltip ?? value,
          waitDuration: const Duration(milliseconds: 300),
          child: AutoSizeText(
            value.isEmpty ? '-' : value,
            minFontSize: 11,
            maxFontSize: 14,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AeaText.tableCell.copyWith(
              color: muted ? AeaColors.textSecondary : AeaColors.textPrimary,
              fontFamily: isMono ? 'monospace' : AeaText.fontRegular,
              fontFamilyFallback: const [AeaText.fontRegular],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final ({Color bg, Color fg}) palette;
  const _StatusPill({required this.label, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: AeaDecor.pill(palette.bg, palette.fg),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: palette.fg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: AutoSizeText(
                label.isEmpty ? '-' : label,
                minFontSize: 10,
                maxFontSize: 12,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AeaText.fontBold,
                  fontSize: 11,
                  color: palette.fg,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pill ใน cell ของ table — ใช้ FittedBox กัน pill overflow
class _StatusPillBox extends StatelessWidget {
  final String label;
  final ({Color bg, Color fg}) palette;
  const _StatusPillBox({
    required this.label,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: _StatusPill(label: label, palette: palette),
      ),
    );
  }
}

class _HoverableRow extends StatefulWidget {
  final int index;
  final Widget child;
  final VoidCallback onTap;
  const _HoverableRow({
    required this.index,
    required this.child,
    required this.onTap,
  });

  @override
  State<_HoverableRow> createState() => _HoverableRowState();
}

class _HoverableRowState extends State<_HoverableRow> {
  bool _hover = false;

  @override
  void didUpdateWidget(_HoverableRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _hover = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.index.isEven ? Colors.white : AeaColors.surfaceMuted;
    final hoverColor = widget.index.isEven
        ? AeaColors.primary.withOpacity(.05)
        : AeaColors.primary.withOpacity(.08);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (hover) {
          if (hover != _hover) {
            setState(() => _hover = hover);
          }
        },
        hoverColor: hoverColor,
        splashColor: AeaColors.primary.withOpacity(.12),
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: AeaAnimations.fast,
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
              horizontal: AeaSpace.md, vertical: AeaSpace.md),
          decoration: BoxDecoration(
            color: _hover ? null : base,
            border: const Border(
              bottom: BorderSide(color: AeaColors.border, width: 1),
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _ViewButton extends StatefulWidget {
  final VoidCallback onTap;
  const _ViewButton({required this.onTap});

  @override
  State<_ViewButton> createState() => _ViewButtonState();
}

class _ViewButtonState extends State<_ViewButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AeaAnimations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _hover ? AeaColors.primary : AeaColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AeaRadius.pill),
            border: Border.all(
              color: _hover ? AeaColors.primary : AeaColors.border,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.visibility_outlined,
                size: 13,
                color: _hover ? Colors.white : AeaColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                'เรียกดู',
                style: TextStyle(
                  fontFamily: AeaText.fontBold,
                  fontSize: 11,
                  color: _hover ? Colors.white : AeaColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Card widget (Grid view)
// ============================================================================

class _AreaGrid extends StatelessWidget {
  final List<AreaAreaModel> rows;
  final void Function(AreaAreaModel area)? onEdit;
  const _AreaGrid({required this.rows, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1100
            ? 3
            : constraints.maxWidth >= 720
                ? 2
                : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AeaSpace.md,
            mainAxisSpacing: AeaSpace.md,
            mainAxisExtent: 200,
          ),
          itemCount: rows.length,
          itemBuilder: (_, i) => _AreaCard(
            area: rows[i],
            onEdit: () {
              if (onEdit != null) onEdit!(rows[i]);
            },
          ),
        );
      },
    );
  }
}

class _AreaCard extends StatefulWidget {
  final AreaAreaModel area;
  final VoidCallback onEdit;
  const _AreaCard({required this.area, required this.onEdit});

  @override
  State<_AreaCard> createState() => _AreaCardState();
}

class _AreaCardState extends State<_AreaCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.area;
    final status = _deriveStatus(a);
    final palette = status.palette;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: AeaAnimations.fast,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AeaRadius.lg),
          border: Border.all(
            color: _hover ? AeaColors.primary : AeaColors.border,
            width: _hover ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _hover
                  ? AeaColors.primary.withOpacity(.10)
                  : Colors.black.withOpacity(.03),
              blurRadius: _hover ? 12 : 6,
              offset: Offset(0, _hover ? 4 : 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AeaSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row: lncode + status pill ──
              Row(
                children: [
                  Expanded(
                    child: Text(
                      a.lncode.isEmpty ? a.ln : a.lncode,
                      style: AeaText.h2.copyWith(
                        color: AeaColors.textPrimary,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: palette.bg,
                      borderRadius: BorderRadius.circular(AeaRadius.pill),
                      border: Border.all(
                          color: palette.fg.withOpacity(.18), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: palette.fg,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          status.label,
                          style: TextStyle(
                            fontFamily: AeaText.fontBold,
                            fontSize: 10,
                            color: palette.fg,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AeaSpace.sm),
              // ── Zone chip ──
              if (a.zn.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AeaSpace.sm),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 14,
                        color: AeaColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          a.zn,
                          style: AeaText.caption.copyWith(
                            color: AeaColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              // ── Name ──
              Text(
                a.sname.isEmpty ? a.ln : a.sname,
                style: AeaText.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              // ── Bottom row: area + rent ──
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      icon: Icons.straighten_rounded,
                      label: 'ขนาด',
                      value: '${a.area.isEmpty ? '0.00' : a.area} ตร.ม.',
                    ),
                  ),
                  const SizedBox(width: AeaSpace.sm),
                  Expanded(
                    child: _MiniStat(
                      icon: Icons.payments_outlined,
                      label: 'ค่าเช่า',
                      value: '${a.rent.isEmpty ? '0.00' : a.rent} ฿',
                      valueColor: AeaColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AeaSpace.sm),
              // ── Edit button ──
              SizedBox(
                width: double.infinity,
                child: _EditButton(onTap: widget.onEdit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AeaColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AeaRadius.sm),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AeaColors.textMuted),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AeaText.caption.copyWith(fontSize: 10),
                ),
                Text(
                  value,
                  style: AeaText.bodyMuted.copyWith(
                    fontFamily: AeaText.fontBold,
                    fontSize: 12,
                    color: valueColor ?? AeaColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditButton extends StatefulWidget {
  final VoidCallback onTap;
  const _EditButton({required this.onTap});

  @override
  State<_EditButton> createState() => _EditButtonState();
}

class _EditButtonState extends State<_EditButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AeaAnimations.fast,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: _hover ? AeaColors.primary : AeaColors.primaryLight,
            borderRadius: BorderRadius.circular(AeaRadius.sm),
            border: Border.all(color: AeaColors.primary, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.edit_rounded,
                size: 14,
                color: _hover ? Colors.white : AeaColors.primaryDark,
              ),
              const SizedBox(width: 6),
              Text(
                'เรียกดู',
                style: TextStyle(
                  fontFamily: AeaText.fontBold,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _hover ? Colors.white : AeaColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Status logic (shared with table)
// ============================================================================

AreaStatus _deriveStatus(AreaAreaModel model) {
  return model.isOccupied ? AreaStatus.occupied : AreaStatus.empty;
}

enum AreaStatus { empty, occupied }

extension on AreaStatus {
  String get label {
    switch (this) {
      case AreaStatus.empty:
        return 'ว่าง';
      case AreaStatus.occupied:
        return 'ไม่ว่าง';
    }
  }

  ({Color bg, Color fg}) get palette {
    switch (this) {
      case AreaStatus.empty:
        return (
          bg: AeaColors.statusApprovedBg,
          fg: AeaColors.statusApprovedFg,
        );
      case AreaStatus.occupied:
        return (
          bg: AeaColors.statusRejectedBg,
          fg: AeaColors.statusRejectedFg,
        );
    }
  }
}

// ============================================================================
// Empty / Loading
// ============================================================================

class _EmptyState extends StatelessWidget {
  final bool hasFilter;
  final VoidCallback onRefresh;
  const _EmptyState({required this.hasFilter, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AeaDecor.card(),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AeaColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_outlined,
              size: 36,
              color: AeaColors.primaryDark,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hasFilter ? 'ไม่พบรายการที่ตรงกัน' : 'ยังไม่มี รายการพื้นที่เช่า',
            style: AeaText.h2,
          ),
          const SizedBox(height: 6),
          Text(
            hasFilter
                ? 'ลองปรับตัวกรองหรือคำค้นหาใหม่อีกครั้ง'
                : 'กดปุ่ม "สร้าง พื้นที่เช่า" เพื่อเริ่มต้น',
            style: AeaText.bodyMuted,
            textAlign: TextAlign.center,
          ),
          if (hasFilter) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('รีเฟรช'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AeaColors.primary,
                side: BorderSide(color: AeaColors.primary.withOpacity(.4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AeaRadius.pill),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AeaDecor.card(),
      padding: const EdgeInsets.symmetric(vertical: 60),
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AeaColors.primary),
            ),
          ),
          SizedBox(height: 12),
          Text('กำลังโหลดข้อมูล...', style: AeaText.bodyMuted),
        ],
      ),
    );
  }
}
