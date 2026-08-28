// ============================================================================
// areas_report_column_picker.dart
// ============================================================================
// Checklist สำหรับเลือก columns ที่จะ export
// - ✅ Drag & Drop reorder (ReorderableListView)
// - ✅ Toggle check / uncheck
// - ✅ Select all / deselect all
//
// ✅ ใช้ Selector — ไม่ rebuild บ่อย
//   rebuild เฉพาะ columns / selectedCount / errorMessage เปลี่ยน
//   ไม่ rebuild ตอน isExporting / totalArea เปลี่ยน
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/areas_report_view_model.dart';
import '../../services/areas_report_service.dart';
import '../../../customers/views/theme/customers_report_theme.dart';

/// Snapshot ของ VM state ที่ picker ต้อง rebuild เมื่อเปลี่ยน
class _PickerData {
  final List<AreasReportColumn> columns;
  final int selectedCount;
  final String? errorMessage;

  const _PickerData({
    required this.columns,
    required this.selectedCount,
    required this.errorMessage,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _PickerData &&
        other.selectedCount == selectedCount &&
        other.errorMessage == errorMessage &&
        _listEq(other.columns, columns);
  }

  @override
  int get hashCode => Object.hash(
        selectedCount,
        errorMessage,
        identityHashCode(columns),
      );

  static bool _listEq(List<AreasReportColumn> a, List<AreasReportColumn> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].field != b[i].field) return false;
    }
    return true;
  }
}

class AreasReportColumnPicker extends StatelessWidget {
  const AreasReportColumnPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AreasReportViewModel, _PickerData>(
      selector: (_, vm) => _PickerData(
        columns: vm.columns,
        selectedCount: vm.selectedCount,
        errorMessage: vm.errorMessage,
      ),
      shouldRebuild: (a, b) => a != b,
      builder: (context, data, _) {
        // ✅ Read VM (ไม่ subscribe) สำหรับ actions/callbacks
        final vm = context.read<AreasReportViewModel>();
        return _PickerContent(
          data: data,
          onSelectAll: vm.selectAllColumns,
          onDeselectAll: vm.deselectAllColumns,
          onReorder: vm.reorderColumns,
          isSelected: vm.isSelected,
          onToggle: vm.toggleColumn,
        );
      },
    );
  }
}

/// ============================================================
/// _PickerContent — pure stateless, ไม่ผูกกับ Provider โดยตรง
/// ใช้ props ทั้งหมด → rebuild เฉพาะตอน data เปลี่ยน
/// ============================================================
class _PickerContent extends StatelessWidget {
  final _PickerData data;
  final VoidCallback onSelectAll;
  final VoidCallback onDeselectAll;
  final void Function(int, int) onReorder;
  final bool Function(String) isSelected;
  final void Function(String) onToggle;

  const _PickerContent({
    required this.data,
    required this.onSelectAll,
    required this.onDeselectAll,
    required this.onReorder,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cols = data.columns;

    if (cols.isEmpty) {
      return Container(
        decoration: CrDecor.card(),
        padding: const EdgeInsets.symmetric(vertical: 60),
        alignment: Alignment.center,
        child: Text(
          data.errorMessage ?? 'ไม่พบรายการ column',
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
                const Icon(Icons.checklist_rounded,
                    size: 18, color: CrColors.primary),
                const SizedBox(width: 8),
                Text(
                  'เลือก Column ที่ต้องการ Export',
                  style: CrText.h2.copyWith(color: CrColors.textPrimary),
                ),
                const Spacer(),
                Text(
                  '${data.selectedCount} / ${cols.length}',
                  style: CrText.bodyMuted.copyWith(
                    color: CrColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 12),
                _MiniBtn(label: 'เลือกทั้งหมด', onTap: onSelectAll),
                const SizedBox(width: 6),
                _MiniBtn(label: 'ยกเลิก', onTap: onDeselectAll),
              ],
            ),
          ),
          const Divider(height: 1, color: CrColors.border),
          // ✅ ReorderableListView - รองรับ drag & drop
          Padding(
            padding: const EdgeInsets.all(CrSpace.md),
            child: RepaintBoundary(
              child: ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false, // ใช้ custom handle
                itemCount: cols.length,
                onReorder: onReorder,
                itemBuilder: (context, index) {
                  final col = cols[index];
                  return _AreasColumnTile(
                    key: ValueKey('area_col_${col.field}'),
                    index: index,
                    column: col,
                    selected: isSelected(col.field),
                    onToggle: () => onToggle(col.field),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================
/// _AreasColumnTile — tile พร้อม drag handle ซ้าย + checkbox + label
///
/// ✅ StatelessWidget (ไม่ track hover)
/// ✅ ไม่ใช้ AnimatedContainer (decoration static ตาม `selected` เท่านั้น)
/// ✅ ไม่ใช้ MouseRegion (ไม่จำเป็นบน touch)
/// ✅ ห่อด้วย RepaintBoundary — isolate repaints
/// ============================================================
class _AreasColumnTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(bottom: CrSpace.sm),
        child: GestureDetector(
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: CrSpace.md, vertical: CrSpace.sm + 2),
            decoration: BoxDecoration(
              color: selected
                  ? CrColors.primaryLight
                  : Colors.white,
              borderRadius: BorderRadius.circular(CrRadius.sm),
              border: Border.all(
                color: selected ? CrColors.primary : CrColors.border,
                width: selected ? 1.4 : 1,
              ),
              boxShadow: selected
                  ? [
                      const BoxShadow(
                        color: Color(0x140F4C81), // primary @ 8%
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // ✅ Drag handle ซ้าย
                ReorderableDragStartListener(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.drag_indicator_rounded,
                      size: 18,
                      color: CrColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: selected ? CrColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color:
                          selected ? CrColors.primary : CrColors.borderStrong,
                      width: 1.4,
                    ),
                  ),
                  child: selected
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
                        column.label,
                        style: CrText.body.copyWith(
                          fontSize: 14,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w600,
                          color: selected
                              ? CrColors.primaryDark
                              : CrColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        column.field,
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
