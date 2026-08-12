// ============================================================================
// access_rights_table.dart
// ============================================================================
// ตารางแสดงรายการผู้ใช้
// - Card-based header + hover row
// - ปุ่ม "แก้ไข" / "ลายเซ็น" ในแต่ละ row
// - Empty / loading state
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/access_rights_user.dart';
import '../theme/access_rights_theme.dart';
import '../../viewmodels/access_rights_view_model.dart';

class AccessRightsTable extends StatelessWidget {
  const AccessRightsTable({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AccessRightsViewModel>();
    final rows = vm.filtered;

    if (vm.isLoading && rows.isEmpty) {
      return const _LoadingState();
    }
    if (rows.isEmpty) {
      return _EmptyState(hasFilter: vm.searchQuery.isNotEmpty, onRefresh: vm.refresh);
    }

    return Container(
      decoration: ArDecor.card(),
      child: Column(
        children: [
          _headerRow(vm),
          const Divider(height: 1, color: ArColors.border),
          if (vm.isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: ArColors.surfaceMuted,
              valueColor: AlwaysStoppedAnimation<Color>(ArColors.primary),
            ),
          for (int i = 0; i < rows.length; i++)
            _dataRow(context, vm, rows[i], i),
        ],
      ),
    );
  }

  // ========================================================================
  // Header
  // ========================================================================
  Widget _headerRow(AccessRightsViewModel vm) {
    Widget cell(String label, String columnId, {int flex = 2, bool center = false}) {
      final sorted = vm.sortColumn == columnId;
      return Expanded(
        flex: flex,
        child: InkWell(
          onTap: () => vm.onSort(columnId),
          borderRadius: BorderRadius.circular(ArRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment:
                  center ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                if (sorted)
                  Icon(
                    vm.sortAscending
                        ? Icons.arrow_drop_up_rounded
                        : Icons.arrow_drop_down_rounded,
                    color: ArColors.primary,
                    size: 18,
                  ),
                Flexible(
                  child: Text(
                    label,
                    style: ArText.tableHeader,
                    textAlign: center ? TextAlign.center : TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: ArSpace.md, vertical: ArSpace.md),
      decoration: const BoxDecoration(
        color: ArColors.surfaceMuted,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ArRadius.lg),
          topRight: Radius.circular(ArRadius.lg),
        ),
      ),
      child: Row(
        children: [
          cell('ชื่อผู้ใช้', 'username', flex: 2),
          cell('อีเมล', 'email', flex: 3),
          cell('ตำแหน่ง', 'position', flex: 2),
          cell('สิทธิ์การเข้าถึง', 'roles', flex: 3),
          cell('ลำดับเซ็น', 'level', flex: 1, center: true),
          const SizedBox(
              width: 150, child: _ActionHeader()),
        ],
      ),
    );
  }

  // ========================================================================
  // Data row
  // ========================================================================
  Widget _dataRow(
    BuildContext context,
    AccessRightsViewModel vm,
    AccessRightsUser model,
    int index,
  ) {
    return _HoverableRow(
      index: index,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: ArSpace.md, vertical: ArSpace.md),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: _Cell(value: model.username),
            ),
            Expanded(
              flex: 3,
              child: _Cell(value: model.email, muted: true),
            ),
            Expanded(
              flex: 2,
              child: _Cell(value: model.positionName.isEmpty ? '-' : model.positionName),
            ),
            Expanded(
              flex: 3,
              child: _Cell(
                value: model.roles.isEmpty
                    ? '-'
                    : model.roles.map((r) => r.nameTh).join(', '),
                maxLines: 2,
              ),
            ),
            Expanded(
              flex: 1,
              child: _Cell(
                value: model.roles.isEmpty ? '-' : model.roles.first.level.toString(),
                center: true,
                mono: true,
              ),
            ),
            SizedBox(
              width: 150,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: _MiniButton(
                      icon: Icons.edit_rounded,
                      label: 'แก้ไข',
                      onTap: () => vm.onEdit(model.uuid),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _MiniButton(
                      icon: Icons.draw_rounded,
                      label: 'ลายเซ็น',
                      onTap: () => vm.onSignature(model.uuid),
                      color: ArColors.statusInfoFg,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Sub widgets
// ============================================================================

class _ActionHeader extends StatelessWidget {
  const _ActionHeader();
  @override
  Widget build(BuildContext context) {
    return Text(
      'จัดการ',
      textAlign: TextAlign.center,
      style: ArText.tableHeader.copyWith(letterSpacing: .4),
    );
  }
}

class _Cell extends StatelessWidget {
  final String value;
  final bool muted;
  final bool center;
  final bool mono;
  final int maxLines;
  const _Cell({
    required this.value,
    this.muted = false,
    this.center = false,
    this.mono = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final style = ArText.tableCell.copyWith(
      color: muted ? ArColors.textSecondary : ArColors.textPrimary,
      fontFamily: mono ? ArText.fontBold : ArText.fontRegular,
    );
    return Tooltip(
      message: value,
      child: Text(
        value,
        textAlign: center ? TextAlign.center : TextAlign.start,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
    );
  }
}

class _HoverableRow extends StatefulWidget {
  final int index;
  final Widget child;
  const _HoverableRow({required this.index, required this.child});

  @override
  State<_HoverableRow> createState() => _HoverableRowState();
}

class _HoverableRowState extends State<_HoverableRow> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final isAlt = widget.index.isOdd;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        decoration: BoxDecoration(
          color: _hover
              ? ArColors.primaryLight.withOpacity(.4)
              : (isAlt ? ArColors.surfaceMuted : Colors.white),
        ),
        child: widget.child,
      ),
    );
  }
}

class _MiniButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _MiniButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  State<_MiniButton> createState() => _MiniButtonState();
}

class _MiniButtonState extends State<_MiniButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final c = widget.color ?? ArColors.primary;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: ArAnimations.fast,
          height: 30,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: _hover ? c : Colors.white,
            borderRadius: BorderRadius.circular(ArRadius.sm),
            border: Border.all(color: c, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 12, color: _hover ? Colors.white : c),
              const SizedBox(width: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: ArText.fontBold,
                  fontSize: 11,
                  color: _hover ? Colors.white : c,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ArDecor.card(),
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(ArColors.primary)),
          SizedBox(height: 12),
          Text('กำลังโหลดข้อมูลผู้ใช้...',
              style: TextStyle(color: ArColors.textSecondary)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilter;
  final VoidCallback onRefresh;
  const _EmptyState({required this.hasFilter, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ArDecor.card(),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off_rounded,
              size: 48, color: ArColors.textMuted),
          const SizedBox(height: 8),
          Text(
            hasFilter ? 'ไม่พบผู้ใช้ที่ตรงกับคำค้น' : 'ยังไม่มีผู้ใช้ในระบบ',
            style: ArText.bodyMuted,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('รีเฟรช'),
            style: OutlinedButton.styleFrom(
              foregroundColor: ArColors.primary,
              side: const BorderSide(color: ArColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
