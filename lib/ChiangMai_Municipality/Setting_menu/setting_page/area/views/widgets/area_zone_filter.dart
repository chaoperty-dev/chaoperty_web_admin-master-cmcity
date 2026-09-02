// ============================================================================
// area_zone_filter.dart
// ============================================================================
// ตัวกรอง "หมวดโซน" + "โซน" — สไตล์ license_payment
// - 2 dropdown (หมวด → โซน)
// - 6 icon-buttons: [+ แก้ ลบ] สำหรับทั้ง group และ zone
// - ปุ่ม disable ด้วย Opacity + IgnorePointer เมื่อ selection ไม่ valid
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/area_zone_model.dart';
import '../theme/area_theme.dart';
import '../../viewmodels/area_view_model.dart';

class AreaZoneFilter extends StatefulWidget {
  final VoidCallback? onAddGroup;
  final VoidCallback? onEditGroup;
  final VoidCallback? onDeleteGroup;

  final VoidCallback? onAddZone;
  final VoidCallback? onEditZone;
  final VoidCallback? onDeleteZone;

  const AreaZoneFilter({
    super.key,
    this.onAddGroup,
    this.onEditGroup,
    this.onDeleteGroup,
    this.onAddZone,
    this.onEditZone,
    this.onDeleteZone,
  });

  @override
  State<AreaZoneFilter> createState() => _AreaZoneFilterState();
}

class _AreaZoneFilterState extends State<AreaZoneFilter> {
  final TextEditingController _groupSearchCtrl = TextEditingController();
  final TextEditingController _zoneSearchCtrl = TextEditingController();

  @override
  void dispose() {
    _groupSearchCtrl.dispose();
    _zoneSearchCtrl.dispose();
    super.dispose();
  }

  bool get _hasGroupSel =>
      widget.onEditGroup != null || widget.onDeleteGroup != null;
  bool get _hasZoneSel =>
      widget.onAddZone != null ||
      widget.onEditZone != null ||
      widget.onDeleteZone != null;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AreaViewModel>();

    // group selection valid for edit/delete (ไม่ใช่ "ทั้งหมด")
    final groupSelValid =
        vm.selectedGroupSer != null && vm.selectedGroupSer != '0';
    final zoneSelValid = vm.selectedZoneSer != null;

    return Container(
      padding: const EdgeInsets.all(AeaSpace.md),
      decoration: AeaDecor.card(),
      child: LayoutBuilder(
        builder: (context, c) {
          if (c.maxWidth < 760) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _groupSection(vm),
                const SizedBox(height: AeaSpace.sm),
                _CrudRow(
                  enabled: _hasGroupSel,
                  onAdd: widget.onAddGroup,
                  onEdit: widget.onEditGroup,
                  onDelete: widget.onDeleteGroup,
                  editEnabled: groupSelValid,
                  deleteEnabled: groupSelValid,
                ),
                const SizedBox(height: AeaSpace.md),
                _zoneSection(vm),
                const SizedBox(height: AeaSpace.sm),
                _CrudRow(
                  enabled: _hasZoneSel,
                  onAdd: widget.onAddZone,
                  onEdit: widget.onEditZone,
                  onDelete: widget.onDeleteZone,
                  addEnabled: groupSelValid,
                  editEnabled: zoneSelValid,
                  deleteEnabled: zoneSelValid,
                ),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 5, child: _groupSection(vm)),
                  _divider(),
                  Expanded(flex: 5, child: _zoneSection(vm)),
                ],
              ),
              const SizedBox(height: AeaSpace.sm),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: _CrudRow(
                      enabled: _hasGroupSel,
                      onAdd: widget.onAddGroup,
                      onEdit: widget.onEditGroup,
                      onDelete: widget.onDeleteGroup,
                      editEnabled: groupSelValid,
                      deleteEnabled: groupSelValid,
                    ),
                  ),
                  const SizedBox(width: AeaSpace.lg),
                  Expanded(
                    flex: 5,
                    child: _CrudRow(
                      enabled: _hasZoneSel,
                      onAdd: widget.onAddZone,
                      onEdit: widget.onEditZone,
                      onDelete: widget.onDeleteZone,
                      addEnabled: groupSelValid,
                      editEnabled: zoneSelValid,
                      deleteEnabled: zoneSelValid,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: AeaSpace.md),
        color: AeaColors.border,
      );

  Widget _groupSection(AreaViewModel vm) {
    return _FilterField(
      icon: Icons.layers_outlined,
      label: 'หมวดโซนพื้นที่',
      child: _groupDropdown(vm),
    );
  }

  Widget _zoneSection(AreaViewModel vm) {
    final enabled = vm.selectedGroupSer != null && vm.selectedGroupSer != '0';
    return _FilterField(
      enabled: enabled,
      icon: Icons.place_outlined,
      label: 'โซนพื้นที่',
      child: _zoneDropdown(vm, enabled: enabled),
    );
  }

  Widget _groupDropdown(AreaViewModel vm) {
    return _DropdownShell(
      enabled: true,
      child: DropdownButton2<String>(
        isExpanded: true,
        iconSize: 18,
        iconEnabledColor: AeaColors.textSecondary,
        buttonHeight: 40,
        dropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AeaRadius.md),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        searchController: _groupSearchCtrl,
        searchInnerWidget: _SearchInner(_groupSearchCtrl),
        searchInnerWidgetHeight: 56,
        hint: AutoSizeText(
          vm.selectedGroupName ?? 'เลือกหมวด',
          style: AeaText.body.copyWith(color: AeaColors.textPrimary),
          maxFontSize: 14,
          minFontSize: 11,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        value: vm.selectedGroupSer,
        items: vm.groups
            .map((g) => DropdownMenuItem<String>(
                  value: g.ser,
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: AeaColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: AutoSizeText(
                          g.zn,
                          style: AeaText.body,
                          maxFontSize: 14,
                          minFontSize: 11,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
        onChanged: (v) {
          final name = vm.groups
              .where((g) => g.ser == v)
              .map((g) => g.zn)
              .firstOrNull;
          vm.onGroupChanged(v, name);
        },
        searchMatchFn: (item, searchValue) {
          final z = vm.groups.firstWhere(
            (g) => g.ser == item.value,
            orElse: () => const AreaZoneModel(ser: '', rser: '', zn: ''),
          );
          return z.zn.toLowerCase().contains(searchValue.toLowerCase());
        },
        onMenuStateChange: (isOpen) {
          if (!isOpen) _groupSearchCtrl.clear();
        },
      ),
    );
  }

  Widget _zoneDropdown(AreaViewModel vm, {required bool enabled}) {
    final current = vm.selectedZoneSer;
    final exists = current != null &&
        vm.zones.any((z) => z.ser == current && z.ser != '0');
    final value = exists ? current : null;
    return _DropdownShell(
      enabled: enabled,
      child: DropdownButton2<String>(
        isExpanded: true,
        iconSize: 18,
        iconEnabledColor: AeaColors.textSecondary,
        buttonHeight: 40,
        dropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AeaRadius.md),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        searchController: _zoneSearchCtrl,
        searchInnerWidget: _SearchInner(_zoneSearchCtrl),
        searchInnerWidgetHeight: 56,
        hint: AutoSizeText(
          vm.selectedZoneName ?? 'เลือกโซน',
          style: AeaText.body.copyWith(
            color: enabled ? AeaColors.textPrimary : AeaColors.textMuted,
          ),
          maxFontSize: 14,
          minFontSize: 11,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        value: value,
        items: vm.zones
            .where((z) => z.ser != '0')
            .map((z) => DropdownMenuItem<String>(
                  value: z.ser,
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: AeaColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: AutoSizeText(
                          z.zn,
                          style: AeaText.body,
                          maxFontSize: 14,
                          minFontSize: 11,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
        onChanged: enabled
            ? (v) {
                final name = vm.zones
                    .where((z) => z.ser == v)
                    .map((z) => z.zn)
                    .firstOrNull;
                vm.onZoneChanged(v, name);
              }
            : null,
        searchMatchFn: (item, searchValue) {
          final z = vm.zones.firstWhere(
            (z) => z.ser == item.value,
            orElse: () => const AreaZoneModel(ser: '', rser: '', zn: ''),
          );
          return z.zn.toLowerCase().contains(searchValue.toLowerCase());
        },
        onMenuStateChange: (isOpen) {
          if (!isOpen) _zoneSearchCtrl.clear();
        },
      ),
    );
  }
}

// ============================================================================
// CRUD row — [+ เพิ่ม] [✏ แก้ไข] [🗑 ลบ]
// ============================================================================
class _CrudRow extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onAdd;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool addEnabled;
  final bool editEnabled;
  final bool deleteEnabled;

  const _CrudRow({
    required this.enabled,
    this.onAdd,
    this.onEdit,
    this.onDelete,
    this.addEnabled = true,
    this.editEnabled = true,
    this.deleteEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();
    return Wrap(
      spacing: AeaSpace.sm,
      runSpacing: AeaSpace.sm,
      children: [
        if (onAdd != null)
          _CrudIconBtn(
            icon: Icons.add_rounded,
            label: 'เพิ่ม',
            color: AeaColors.primary,
            onTap: onAdd,
            disabled: !addEnabled,
          ),
        if (onEdit != null)
          _CrudIconBtn(
            icon: Icons.edit_outlined,
            label: 'แก้ไข',
            color: AeaColors.primaryDark,
            onTap: onEdit,
            disabled: !editEnabled,
          ),
        if (onDelete != null)
          _CrudIconBtn(
            icon: Icons.delete_outline_rounded,
            label: 'ลบ',
            color: AeaColors.statusRejectedFg,
            onTap: onDelete,
            disabled: !deleteEnabled,
          ),
      ],
    );
  }
}

class _CrudIconBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool disabled;
  const _CrudIconBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.disabled = false,
  });
  @override
  State<_CrudIconBtn> createState() => _CrudIconBtnState();
}

class _CrudIconBtnState extends State<_CrudIconBtn> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final clickable = widget.onTap != null && !widget.disabled;
    final body = MouseRegion(
      cursor: clickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = clickable && _hover || clickable),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AeaAnimations.fast,
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _hover ? widget.color : Colors.white,
            borderRadius: BorderRadius.circular(AeaRadius.md),
            border: Border.all(color: widget.color, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon,
                  size: 14, color: _hover ? Colors.white : widget.color),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: AeaText.fontBold,
                  fontSize: 12,
                  color: _hover ? Colors.white : widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return IgnorePointer(
      ignoring: widget.disabled,
      child: Opacity(opacity: widget.disabled ? 0.4 : 1.0, child: body),
    );
  }
}

// ============================================================================
// Reusable shell widgets
// ============================================================================
class _FilterField extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;
  final bool enabled;
  const _FilterField({
    required this.icon,
    required this.label,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final lblColor = enabled ? AeaColors.textSecondary : AeaColors.textMuted;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(right: AeaSpace.sm),
          decoration: BoxDecoration(
            color: enabled ? AeaColors.primaryLight : AeaColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AeaRadius.sm),
          ),
          child: Icon(icon, size: 16, color: AeaColors.primaryDark),
        ),
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: AeaText.bodyMuted.copyWith(
              color: lblColor,
              fontFamily: AeaText.fontBold,
              fontSize: 12,
              letterSpacing: .3,
            ),
          ),
        ),
        const SizedBox(width: AeaSpace.sm),
        Expanded(child: child),
      ],
    );
  }
}

class _DropdownShell extends StatelessWidget {
  final Widget child;
  final bool enabled;
  const _DropdownShell({required this.child, this.enabled = true});
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : .55,
      child: Container(
        constraints: const BoxConstraints(minHeight: 42),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AeaColors.surface,
          borderRadius: BorderRadius.circular(AeaRadius.sm),
          border: Border.all(color: AeaColors.border, width: 1),
        ),
        child: DropdownButtonHideUnderline(child: child),
      ),
    );
  }
}

class _SearchInner extends StatelessWidget {
  final TextEditingController ctrl;
  const _SearchInner(this.ctrl);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
      child: TextFormField(
        controller: ctrl,
        autofocus: true,
        style: AeaText.body.copyWith(fontSize: 14),
        cursorColor: AeaColors.primary,
        decoration: const InputDecoration(
          isDense: true,
          filled: true,
          fillColor: AeaColors.surfaceMuted,
          hintText: 'พิมพ์เพื่อค้นหา...',
          hintStyle: AeaText.caption,
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 18,
            color: AeaColors.textMuted,
          ),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(AeaRadius.sm)),
            borderSide: BorderSide(color: AeaColors.border, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(AeaRadius.sm)),
            borderSide: BorderSide(color: AeaColors.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(AeaRadius.sm)),
            borderSide: BorderSide(color: AeaColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}