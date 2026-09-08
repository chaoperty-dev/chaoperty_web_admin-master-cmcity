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

const double kAccessRightsMobileBreakpoint = 700;

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

    return LayoutBuilder(
      builder: (context, c) {
        final isMobile = c.maxWidth < kAccessRightsMobileBreakpoint;
        if (isMobile) {
          return Column(
            children: [
              if (vm.isLoading)
                const LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: ArColors.surfaceMuted,
                  valueColor: AlwaysStoppedAnimation<Color>(ArColors.primary),
                ),
              for (int i = 0; i < rows.length; i++) ...[
                _UserCard(
                  model: rows[i],
                  onEdit: () => vm.onEdit(rows[i].uuid),
                  onSignature: () => vm.onSignature(rows[i].uuid),
                ),
                if (i < rows.length - 1) const SizedBox(height: ArSpace.sm),
              ],
            ],
          );
        }
        if (vm.viewMode == AccessRightsViewMode.card) {
          return _UserCardGrid(rows: rows, vm: vm);
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
      },
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
                    maxLines: 1,
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
              width: 170, child: _ActionHeader()),
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
              child: Row(
                children: [
                  _UserAvatar(model: model),
                  const SizedBox(width: 8),
                  Expanded(child: _Cell(value: model.username)),
                ],
              ),
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
              width: 170,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _MiniButton(
                    icon: Icons.edit_rounded,
                    label: 'แก้ไข',
                    onTap: () => vm.onEdit(model.uuid),
                  ),
                  const SizedBox(width: 8),
                  _MiniButton(
                    icon: Icons.draw_rounded,
                    label: 'ลายเซ็น',
                    onTap: () => vm.onSignature(model.uuid),
                    color: ArColors.statusInfoFg,
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

class _UserAvatar extends StatelessWidget {
  final AccessRightsUser model;
  final double radius;

  const _UserAvatar({required this.model, this.radius = 15});

  String get _initials {
    final source = model.fullName.trim().isNotEmpty
        ? model.fullName.trim()
        : model.username.trim();
    final parts = source.split(RegExp(r'\s+'))..removeWhere((e) => e.isEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasSignature =
        model.signatureUuid != null && model.signatureUuid!.trim().isNotEmpty;
    return Tooltip(
      message: hasSignature
          ? '${model.fullName} — มีลายเซ็นในระบบแล้ว'
          : '${model.fullName} — ยังไม่มีลายเซ็น',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: const Color(0xFF1E40AF),
            child: Text(
              _initials,
              style: TextStyle(
                fontFamily: ArText.fontBold,
                fontSize: radius * .68,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasSignature ? Icons.verified : Icons.warning_amber_rounded,
                size: radius * .85,
                color: hasSignature
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFB45309),
              ),
            ),
          ),
        ],
      ),
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
    final fg = _hover ? Colors.white : c;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: ArAnimations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _hover ? c : c.withOpacity(.08),
            borderRadius: BorderRadius.circular(ArRadius.pill),
            border: Border.all(
              color: _hover ? c : c.withOpacity(.25),
              width: 1,
            ),
            boxShadow: [
              if (_hover)
                BoxShadow(
                  color: c.withOpacity(.28),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 13, color: fg),
              const SizedBox(width: 5),
              Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: ArText.fontBold,
                  fontSize: 11,
                  color: fg,
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

// ============================================================================
// Card grid layout (desktop)
// ============================================================================
class _UserCardGrid extends StatelessWidget {
  final List<AccessRightsUser> rows;
  final AccessRightsViewModel vm;

  const _UserCardGrid({required this.rows, required this.vm});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1180
            ? 3
            : constraints.maxWidth >= 760
                ? 2
                : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: ArSpace.md,
            mainAxisSpacing: ArSpace.md,
            mainAxisExtent: 250,
          ),
          itemCount: rows.length,
          itemBuilder: (_, index) {
            final user = rows[index];
            return _DesktopUserCard(
              model: user,
              onEdit: () => vm.onEdit(user.uuid),
              onSignature: () => vm.onSignature(user.uuid),
            );
          },
        );
      },
    );
  }
}

class _DesktopUserCard extends StatelessWidget {
  final AccessRightsUser model;
  final VoidCallback onEdit;
  final VoidCallback onSignature;

  const _DesktopUserCard({
    required this.model,
    required this.onEdit,
    required this.onSignature,
  });

  @override
  Widget build(BuildContext context) {
    final rolesText = model.roles.isEmpty
        ? '-'
        : model.roles.map((role) => role.nameTh).join(', ');
    final levelText =
        model.roles.isEmpty ? '-' : model.roles.first.level.toString();

    return Container(
      decoration: ArDecor.card(),
      padding: const EdgeInsets.all(ArSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _UserAvatar(model: model, radius: 19),
              const SizedBox(width: ArSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ArText.tableCell.copyWith(
                        fontFamily: ArText.fontBold,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      model.username.isEmpty ? '-' : model.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ArText.caption,
                    ),
                  ],
                ),
              ),
              if (levelText != '-')
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: ArDecor.pill(
                    ArColors.primaryLight,
                    ArColors.primaryDark,
                  ),
                  child: Text(
                    'ลำดับ $levelText',
                    style: ArText.label.copyWith(
                      color: ArColors.primaryDark,
                      letterSpacing: 0,
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: ArSpace.lg, color: ArColors.border),
          _CardInfoLine(
            icon: Icons.email_outlined,
            value: model.email.isEmpty ? '-' : model.email,
          ),
          const SizedBox(height: 6),
          _CardInfoLine(
            icon: Icons.badge_outlined,
            value: model.positionName.isEmpty ? '-' : model.positionName,
          ),
          const SizedBox(height: 6),
          Tooltip(
            message: rolesText,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.admin_panel_settings_outlined,
                    size: 15,
                    color: ArColors.textMuted,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    rolesText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: ArText.tableCell.copyWith(
                      fontSize: 12,
                      color: ArColors.textSecondary,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _MiniButton(
                icon: Icons.edit_rounded,
                label: 'แก้ไข',
                onTap: onEdit,
              ),
              const SizedBox(width: 8),
              _MiniButton(
                icon: Icons.draw_rounded,
                label: 'ลายเซ็น',
                onTap: onSignature,
                color: ArColors.statusInfoFg,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardInfoLine extends StatelessWidget {
  final IconData icon;
  final String value;

  const _CardInfoLine({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: ArColors.textMuted),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ArText.tableCell.copyWith(
              fontSize: 12,
              color: ArColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Card layout (mobile / narrow screen)
// ============================================================================
class _UserCard extends StatelessWidget {
  final AccessRightsUser model;
  final VoidCallback onEdit;
  final VoidCallback onSignature;
  const _UserCard({
    required this.model,
    required this.onEdit,
    required this.onSignature,
  });

  @override
  Widget build(BuildContext context) {
    final rolesText = model.roles.isEmpty
        ? '-'
        : model.roles.map((r) => r.nameTh).join(', ');
    final levelText =
        model.roles.isEmpty ? '-' : model.roles.first.level.toString();

    return Container(
      decoration: ArDecor.card(),
      padding: const EdgeInsets.all(ArSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _UserAvatar(model: model, radius: 16),
              const SizedBox(width: ArSpace.sm),
              Expanded(
                child: Text(
                  model.username.isEmpty ? '-' : model.username,
                  style: ArText.tableCell.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (levelText != '-')
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: ArColors.primaryLight.withOpacity(.4),
                    borderRadius: BorderRadius.circular(ArRadius.pill),
                  ),
                  child: Text(
                    'ลำดับ $levelText',
                    style: ArText.bodyMuted.copyWith(
                      color: ArColors.primaryDark,
                      fontSize: 11,
                      fontFamily: ArText.fontBold,
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: ArSpace.lg, color: ArColors.border),
          _AccessCardRow(label: 'อีเมล', value: model.email, muted: true),
          _AccessCardRow(
            label: 'ตำแหน่ง',
            value: model.positionName.isEmpty ? '-' : model.positionName,
          ),
          _AccessCardRow(label: 'สิทธิ์การเข้าถึง', value: rolesText),
          const SizedBox(height: ArSpace.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _MiniButton(
                icon: Icons.edit_rounded,
                label: 'แก้ไข',
                onTap: onEdit,
              ),
              const SizedBox(width: 6),
              _MiniButton(
                icon: Icons.draw_rounded,
                label: 'ลายเซ็น',
                onTap: onSignature,
                color: ArColors.statusInfoFg,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccessCardRow extends StatelessWidget {
  final String label;
  final String value;
  final bool muted;
  const _AccessCardRow({
    required this.label,
    required this.value,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: ArText.bodyMuted.copyWith(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: ArText.tableCell.copyWith(
                color: muted ? ArColors.textSecondary : ArColors.textPrimary,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
