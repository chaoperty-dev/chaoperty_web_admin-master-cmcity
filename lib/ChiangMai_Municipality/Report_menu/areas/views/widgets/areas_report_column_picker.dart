// ============================================================================
// areas_report_column_picker.dart
// ============================================================================
// เลือก columns ที่จะ export — รูปแบบ Dropdown (Multi-select)
// - ✅ กดปุ่ม dropdown แล้วติ๊กได้หลายคอลัมน์
// - ✅ ลากเรียงลำดับ (ReorderableListView) ภายใน panel
// - ✅ เลือกทั้งหมด / ล้าง
//
// ✅ ใช้ Selector — rebuild เฉพาะตอน columns / selectedCount / errorMessage เปลี่ยน
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
        if (data.columns.isEmpty) {
          return Container(
            decoration: CrDecor.card(),
            padding: const EdgeInsets.symmetric(vertical: 40),
            alignment: Alignment.center,
            child: Text(
              data.errorMessage ?? 'ไม่พบรายการ column',
              style: CrText.bodyMuted,
            ),
          );
        }
        return _ColumnDropdown(
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
/// _ColumnDropdown — ปุ่ม trigger แบบ dropdown
/// ============================================================
class _ColumnDropdown extends StatelessWidget {
  final _PickerData data;
  final VoidCallback onSelectAll;
  final VoidCallback onDeselectAll;
  final void Function(int, int) onReorder;
  final bool Function(String) isSelected;
  final void Function(String) onToggle;

  const _ColumnDropdown({
    required this.data,
    required this.onSelectAll,
    required this.onDeselectAll,
    required this.onReorder,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final total = data.columns.length;
    return MenuAnchor(
      builder: (context, controller, child) => InkWell(
        onTap: () {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        },
        borderRadius: BorderRadius.circular(CrRadius.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(CrRadius.sm),
            border: Border.all(color: CrColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.checklist_rounded,
                  size: 18, color: CrColors.primary),
              const SizedBox(width: 8),
              Text(
                'เลือกคอลัมน์',
                style: CrText.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: CrColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${data.selectedCount}/$total',
                style: CrText.bodyMuted.copyWith(
                  color: CrColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.arrow_drop_down, color: CrColors.textMuted),
            ],
          ),
        ),
      ),
      menuChildren: [
        _DropdownPanel(
          data: data,
          onSelectAll: onSelectAll,
          onDeselectAll: onDeselectAll,
          onReorder: onReorder,
          isSelected: isSelected,
          onToggle: onToggle,
        ),
      ],
    );
  }
}

/// ============================================================
/// _DropdownPanel — panel ที่โผล่จาก dropdown
///   มี header (นับ + เลือกทั้งหมด/ล้าง) + รายการติ๊ก + ลากเรียง
/// ============================================================
class _DropdownPanel extends StatelessWidget {
  final _PickerData data;
  final VoidCallback onSelectAll;
  final VoidCallback onDeselectAll;
  final void Function(int, int) onReorder;
  final bool Function(String) isSelected;
  final void Function(String) onToggle;

  const _DropdownPanel({
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
    return Container(
      width: 320,
      constraints: const BoxConstraints(maxHeight: 440),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CrRadius.md),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 8),
            child: Row(
              children: [
                Text(
                  'คอลัมน์ (${data.selectedCount}/${cols.length})',
                  style: CrText.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: CrColors.textPrimary,
                  ),
                ),
                const Spacer(),
                _MiniBtn(label: 'ทั้งหมด', onTap: onSelectAll),
                const SizedBox(width: 6),
                _MiniBtn(label: 'ล้าง', onTap: onDeselectAll),
              ],
            ),
          ),
          const Divider(height: 1, color: CrColors.border),
          // รายการ (ติ๊ก + ลากเรียง)
          SingleChildScrollView(
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: cols.length,
              onReorder: onReorder,
              itemBuilder: (context, index) {
                final col = cols[index];
                return _DropdownTile(
                  key: ValueKey('dd_area_${col.field}'),
                  index: index,
                  column: col,
                  selected: isSelected(col.field),
                  onToggle: () => onToggle(col.field),
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
/// _DropdownTile — drag handle ซ้าย + checkbox + label
/// ============================================================
class _DropdownTile extends StatelessWidget {
  final int index;
  final AreasReportColumn column;
  final bool selected;
  final VoidCallback onToggle;

  const _DropdownTile({
    super.key,
    required this.index,
    required this.column,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      color: selected ? CrColors.primaryLight : Colors.white,
      child: Row(
        children: [
          // ✅ Drag handle
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Icon(Icons.drag_indicator_rounded,
                  size: 18, color: CrColors.textMuted),
            ),
          ),
          // ✅ Checkbox (ติ๊กเท่านั้น — ไม่ trigger drag)
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 18,
              height: 18,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected ? CrColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: selected ? CrColors.primary : CrColors.borderStrong,
                  width: 1.4,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    column.label,
                    style: CrText.body.copyWith(
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
          ),
        ],
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
