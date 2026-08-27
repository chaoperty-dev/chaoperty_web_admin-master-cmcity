// ============================================================================
// areas_report_column_picker.dart
// ============================================================================
// Checklist + Drag & Drop reorder (pattern เดียวกับ customers)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/areas_report_view_model.dart';
import '../../services/areas_report_service.dart';
import '../../../customers/views/theme/customers_report_theme.dart';

class AreasReportColumnPicker extends StatelessWidget {
  const AreasReportColumnPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AreasReportViewModel>();
    final cols = vm.columns;

    if (cols.isEmpty) {
      return Container(
        decoration: CrDecor.card(),
        padding: const EdgeInsets.symmetric(vertical: 60),
        alignment: Alignment.center,
        child: Text(
          vm.errorMessage ?? 'ไม่พบรายการ column',
          style: CrText.bodyMuted,
        ),
      );
    }

    return Container(
      decoration: CrDecor.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                CrSpace.lg, CrSpace.md, CrSpace.md, CrSpace.sm),
            child: Row(
              children: [
                Icon(Icons.checklist_rounded,
                    size: 18, color: CrColors.primary),
                const SizedBox(width: 8),
                Text(
                  'เลือก Column ที่ต้องการ Export',
                  style: CrText.h2.copyWith(color: CrColors.textPrimary),
                ),
                const Spacer(),
                Text(
                  '${vm.selectedCount} / ${cols.length}',
                  style: CrText.bodyMuted.copyWith(
                    color: CrColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 12),
                _MiniBtn(label: 'เลือกทั้งหมด', onTap: vm.selectAllColumns),
                const SizedBox(width: 6),
                _MiniBtn(label: 'ยกเลิก', onTap: vm.deselectAllColumns),
              ],
            ),
          ),
          const Divider(height: 1, color: CrColors.border),
          Padding(
            padding: const EdgeInsets.all(CrSpace.md),
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: cols.length,
              onReorder: vm.reorderColumns,
              itemBuilder: (context, index) {
                final col = cols[index];
                return _AreasColumnTile(
                  key: ValueKey('area_col_${col.field}'),
                  index: index,
                  column: col,
                  selected: vm.isSelected(col.field),
                  onToggle: () => vm.toggleColumn(col.field),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================
/// _AreasColumnTile — tile พร้อม drag handle + checkbox
/// ============================================================
class _AreasColumnTile extends StatefulWidget {
  final int index;
  final AreasReportColumn column;
  final bool selected;
  final VoidCallback onToggle;
  const _AreasColumnTile({
    super.key,
    required this.index,
    required this.column,
    required this.selected,
    required this.onToggle,
  });

  @override
  State<_AreasColumnTile> createState() => _AreasColumnTileState();
}

class _AreasColumnTileState extends State<_AreasColumnTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: CrSpace.sm),
      child: GestureDetector(
        onTap: widget.onToggle,
        child: AnimatedContainer(
          duration: CrAnimations.fast,
          padding: const EdgeInsets.symmetric(
              horizontal: CrSpace.md, vertical: CrSpace.sm + 2),
          decoration: BoxDecoration(
            color: widget.selected
                ? CrColors.primaryLight
                : (_hover ? CrColors.surfaceMuted : Colors.white),
            borderRadius: BorderRadius.circular(CrRadius.sm),
            border: Border.all(
              color: widget.selected ? CrColors.primary : CrColors.border,
              width: widget.selected ? 1.4 : 1,
            ),
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                      color: CrColors.primary.withOpacity(.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              ReorderableDragStartListener(
                index: widget.index,
                child: MouseRegion(
                  cursor: SystemMouseCursors.grab,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.drag_indicator_rounded,
                      size: 18,
                      color: CrColors.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: widget.selected
                      ? CrColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: widget.selected
                        ? CrColors.primary
                        : CrColors.borderStrong,
                    width: 1.4,
                  ),
                ),
                child: widget.selected
                    ? const Icon(Icons.check,
                        size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.column.label,
                      style: CrText.body.copyWith(
                        fontSize: 14,
                        fontWeight: widget.selected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: widget.selected
                            ? CrColors.primaryDark
                            : CrColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.column.field,
                      style: CrText.caption.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: CrColors.textMuted,
                        letterSpacing: .3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _MiniBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(CrRadius.pill),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: CrColors.surfaceMuted,
          borderRadius: BorderRadius.circular(CrRadius.pill),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: CrText.fontBold,
            fontSize: 11,
            color: CrColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
