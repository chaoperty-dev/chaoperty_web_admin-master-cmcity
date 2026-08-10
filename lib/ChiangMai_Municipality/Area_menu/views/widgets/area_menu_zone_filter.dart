// ============================================================================
// area_menu_zone_filter.dart
// ============================================================================
// ตัวกรอง "หมวดโซนพื้นที่" + "โซนพื้นที่"
// ✅ SELF-CONTAINED — ใช้ List<Map<String, dynamic>> จาก viewmodel
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/area_menu_theme.dart';
import '../../viewmodels/area_menu_view_model.dart';

class AreaMenuZoneFilter extends StatefulWidget {
  const AreaMenuZoneFilter({super.key});

  @override
  State<AreaMenuZoneFilter> createState() => _AreaMenuZoneFilterState();
}

class _AreaMenuZoneFilterState extends State<AreaMenuZoneFilter> {
  final TextEditingController _subZoneSearchCtrl = TextEditingController();
  final TextEditingController _zoneSearchCtrl = TextEditingController();

  @override
  void dispose() {
    _subZoneSearchCtrl.dispose();
    _zoneSearchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AreaMenuViewModel>();
    return Container(
      padding: const EdgeInsets.all(LaSpace.md),
      decoration: LaDecor.card(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 4, child: _subZoneSection(vm)),
          _divider(),
          Expanded(flex: 4, child: _zoneSection(vm)),
          _divider(),
          Expanded(flex: 4, child: _statusSection(vm)),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: LaSpace.md),
        color: LaColors.border,
      );

  Widget _subZoneSection(AreaMenuViewModel vm) {
    return _FilterField(
      icon: Icons.layers_outlined,
      label: 'หมวดโซนพื้นที่',
      child: _subZoneDropdown(vm),
    );
  }

  Widget _zoneSection(AreaMenuViewModel vm) {
    // ✅ ให้คลิกได้เมอ — ไม่ต้องเลือก sub-zone ก่อน
    final enabled = !vm.readOnly;
    return _FilterField(
      enabled: enabled,
      icon: Icons.place_outlined,
      label: 'โซนพื้นที่',
      child: _zoneDropdown(vm),
    );
  }

  Widget _statusSection(AreaMenuViewModel vm) {
    return _FilterField(
      icon: Icons.flag_outlined,
      label: 'สถานะ',
      child: _statusDropdown(vm),
    );
  }
}

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
    final lblColor = enabled ? LaColors.textSecondary : LaColors.textMuted;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(right: LaSpace.sm),
          decoration: BoxDecoration(
            color: enabled ? LaColors.primaryLight : LaColors.surfaceMuted,
            borderRadius: BorderRadius.circular(LaRadius.sm),
          ),
          child: Icon(icon, size: 16, color: LaColors.primaryDark),
        ),
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: LaText.bodyMuted.copyWith(
              color: lblColor,
              fontFamily: LaText.fontBold,
              fontSize: 12,
              letterSpacing: .3,
            ),
          ),
        ),
        const SizedBox(width: LaSpace.sm),
        Expanded(child: child),
      ],
    );
  }
}

/// DropdownBox ที่ห่อหุ้ม dropdown_button2
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
          color: LaColors.surface,
          borderRadius: BorderRadius.circular(LaRadius.sm),
          border: Border.all(color: LaColors.border, width: 1),
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
        style: LaText.body.copyWith(fontSize: 14),
        cursorColor: LaColors.primary,
        decoration: const InputDecoration(
          isDense: true,
          filled: true,
          fillColor: LaColors.surfaceMuted,
          hintText: 'พิมพ์เพื่อค้นหา...',
          hintStyle: LaText.caption,
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 18,
            color: LaColors.textMuted,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(LaRadius.sm)),
            borderSide: BorderSide(color: LaColors.border, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(LaRadius.sm)),
            borderSide: BorderSide(color: LaColors.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(LaRadius.sm)),
            borderSide: BorderSide(color: LaColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

extension on _AreaMenuZoneFilterState {
  Widget _subZoneDropdown(AreaMenuViewModel vm) {
    return _DropdownShell(
      enabled: true,
      child: DropdownButton2<String>(
        isExpanded: true,
        iconSize: 18,
        iconEnabledColor: LaColors.textSecondary,
        buttonHeight: 40,
        dropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(LaRadius.md),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        searchController: _subZoneSearchCtrl,
        searchInnerWidget: _SearchInner(_subZoneSearchCtrl),
        hint: AutoSizeText(
          vm.selectedZoneSub ?? 'ทั้งหมด',
          style: LaText.body.copyWith(
            color: vm.selectedZoneSub == null
                ? LaColors.textMuted
                : LaColors.textPrimary,
          ),
          maxFontSize: 14,
          minFontSize: 11,
        ),
        value: vm.selectedZoneSub,
        items: vm.subzoneModels.map<Map<String, dynamic>>((sub) {
          final zn = sub['zn']?.toString() ?? '';
          return {
            'value': zn,
            'label': zn,
            'isAll': zn == 'ทั้งหมด',
          };
        }).map((entry) {
          final v = entry['value'] as String;
          return DropdownMenuItem<String>(
            value: v,
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: (entry['isAll'] as bool)
                        ? LaColors.textMuted
                        : LaColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: AutoSizeText(
                    v.isEmpty ? '-' : v,
                    style: LaText.body,
                    maxFontSize: 14,
                    minFontSize: 11,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: vm.readOnly ? null : (v) => vm.onSubZoneChanged(v),
        searchMatchFn: (item, searchValue) {
          return item.value
              .toString()
              .toLowerCase()
              .contains(searchValue.toLowerCase());
        },
        onMenuStateChange: (isOpen) {
          if (!isOpen) _subZoneSearchCtrl.clear();
        },
      ),
    );
  }

  Widget _zoneDropdown(AreaMenuViewModel vm) {
    // ✅ ให้คลิกได้เสมอ — ไม่ต้องเลือก sub-zone ก่อน
    final enabled = !vm.readOnly;
    return _DropdownShell(
      enabled: enabled,
      child: DropdownButton2<String>(
        isExpanded: true,
        iconSize: 18,
        iconEnabledColor: LaColors.textSecondary,
        buttonHeight: 40,
        dropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(LaRadius.md),
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
        hint: AutoSizeText(
          vm.selectedZone ?? 'เลือกโซน',
          style: LaText.body.copyWith(
            color: vm.selectedZone == null
                ? LaColors.textMuted
                : LaColors.textPrimary,
          ),
          maxFontSize: 14,
          minFontSize: 11,
        ),
        value: vm.selectedZone,
        items: vm.zoneModels.map<Map<String, dynamic>>((zn) {
          final v = zn['zn']?.toString() ?? '';
          return {
            'value': v,
            'isAll': v == 'ทั้งหมด',
          };
        }).map((entry) {
          final v = entry['value'] as String;
          return DropdownMenuItem<String>(
            value: v,
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: (entry['isAll'] as bool)
                        ? LaColors.textMuted
                        : LaColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: AutoSizeText(
                    v.isEmpty ? '-' : v,
                    style: LaText.body,
                    maxFontSize: 14,
                    minFontSize: 11,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: enabled ? (v) => vm.onZoneChanged(v) : null,
        searchMatchFn: (item, searchValue) {
          return item.value
              .toString()
              .toLowerCase()
              .contains(searchValue.toLowerCase());
        },
        onMenuStateChange: (isOpen) {
          if (!isOpen) _zoneSearchCtrl.clear();
        },
      ),
    );
  }

  Widget _statusDropdown(AreaMenuViewModel vm) {
    return _DropdownShell(
      child: DropdownButton2<String>(
        isExpanded: true,
        iconSize: 18,
        iconEnabledColor: LaColors.textSecondary,
        buttonHeight: 40,
        dropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(LaRadius.md),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        hint: AutoSizeText(
          vm.selectedStatus,
          style: LaText.body.copyWith(
            color: LaColors.textPrimary,
          ),
          maxFontSize: 14,
          minFontSize: 11,
        ),
        value: vm.selectedStatus,
        items: vm.statusOptions.map((status) {
          final isAll = status == 'ทั้งหมด';
          final palette = isAll
              ? const StatusPalette(LaColors.textMuted, LaColors.textMuted)
              : StatusPalette.of(status);
          return DropdownMenuItem<String>(
            value: status,
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: palette.fg,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: AutoSizeText(
                    status.isEmpty ? '-' : status,
                    style: LaText.body,
                    maxFontSize: 14,
                    minFontSize: 11,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (v) => vm.onStatusChanged(v),
      ),
    );
  }
} // end extension
