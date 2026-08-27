// ============================================================================
// customers_report_column_picker.dart
// ============================================================================
// Checklist สำหรับเลือก columns ที่จะ export
// - ✅ Drag & Drop reorder (ReorderableListView)
// - ✅ Toggle check / uncheck
// - ✅ Select all / deselect all
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/customers_report_view_model.dart';
import '../../services/customers_report_service.dart';
import '../theme/customers_report_theme.dart';

// (BuildContext alias for type-inferred callbacks below)

class CustomersReportColumnPicker extends StatelessWidget {
  const CustomersReportColumnPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CustomersReportViewModel>();
    final cols = vm.columns;

    if (vm.isLoadingColumns && cols.isEmpty) {
      return Container(
        decoration: CrDecor.card(),
        padding: const EdgeInsets.symmetric(vertical: 60),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            SizedBox(height: 12),
            Text('กำลังโหลดรายการ column...', style: CrText.bodyMuted),
          ],
        ),
      );
    }

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
          // Header bar
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
          // ✅ ReorderableListView - รองรับ drag & drop
          Padding(
            padding: const EdgeInsets.all(CrSpace.md),
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false, // ใช้ custom handle
              itemCount: cols.length,
              onReorder: vm.reorderColumns,
              itemBuilder: (context, index) {
                final col = cols[index];
                return _ColumnTile(
                  key: ValueKey('col_${col.field}'),
                  index: index,
                  column: col,
                  selected: vm.isSelected(col.field),
                  onToggle: () => vm.toggleColumn(col.field),
                  onReorder: vm.reorderColumns,
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
/// _ColumnTile — มี drag handle ซ้าย + checkbox + label
/// ============================================================
class _ColumnTile extends StatefulWidget {
  final int index;
  final CustomerReportColumn column;
  final bool selected;
  final VoidCallback onToggle;
  final void Function(int, int) onReorder;

  const _ColumnTile({
    super.key,
    required this.index,
    required this.column,
    required this.selected,
    required this.onToggle,
    required this.onReorder,
  });

  @override
  State<_ColumnTile> createState() => _ColumnTileState();
}

class _ColumnTileState extends State<_ColumnTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // ✅ เพิ่ม space ด้านล่างเล็กน้อย (ReorderableListView จัด spacing เอง)
      padding: const EdgeInsets.only(bottom: CrSpace.sm),
      child: GestureDetector(
        // ✅ แตะที่ tile (ไม่ใช่ drag handle) เพื่อ toggle
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
              // ✅ Drag handle ซ้าย (จุดจับ 6 จุด)
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
                  color:
                      widget.selected ? CrColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: widget.selected
                        ? CrColors.primary
                        : CrColors.borderStrong,
                    width: 1.4,
                  ),
                ),
                child: widget.selected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
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
                        fontWeight:
                            widget.selected ? FontWeight.w700 : FontWeight.w600,
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
