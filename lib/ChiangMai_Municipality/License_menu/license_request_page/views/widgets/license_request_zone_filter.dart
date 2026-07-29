// ============================================================================
// license_request_zone_filter.dart
// ============================================================================
// ตัวกรอง "หมวดโซนพื้นที่" + "โซนพื้นที่" — ดีไซน์ใหม่
// - ใช้ card + label chip + dropdown ที่ขอบโค้ง
// - search inner widget ปรับให้สวยขึ้น
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/license_request_theme.dart';
import '../../viewmodels/license_request_view_model.dart';

class LicenseRequestZoneFilter extends StatefulWidget {
  const LicenseRequestZoneFilter({super.key});

  @override
  State<LicenseRequestZoneFilter> createState() =>
      _LicenseRequestZoneFilterState();
}

class _LicenseRequestZoneFilterState extends State<LicenseRequestZoneFilter> {
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
    final vm = context.watch<LicenseRequestViewModel>();
    return Container(
      padding: const EdgeInsets.all(LrSpace.md),
      decoration: LrDecor.card(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 5, child: _subZoneSection(vm)),
          _divider(),
          Expanded(flex: 5, child: _zoneSection(vm)),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: LrSpace.md),
        color: LrColors.border,
      );

  Widget _subZoneSection(LicenseRequestViewModel vm) {
    return _FilterField(
      icon: Icons.layers_outlined,
      label: 'หมวดโซนพื้นที่',
      child: _subZoneDropdown(vm),
    );
  }

  Widget _zoneSection(LicenseRequestViewModel vm) {
    final enabled = vm.selectedZoneSub != null && !vm.readOnly;
    return _FilterField(
      enabled: enabled,
      icon: Icons.place_outlined,
      label: 'โซนพื้นที่',
      child: _zoneDropdown(vm),
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
    final lblColor = enabled ? LrColors.textSecondary : LrColors.textMuted;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(right: LrSpace.sm),
          decoration: BoxDecoration(
            color: enabled ? LrColors.primaryLight : LrColors.surfaceMuted,
            borderRadius: BorderRadius.circular(LrRadius.sm),
          ),
          child: Icon(icon, size: 16, color: LrColors.primaryDark),
        ),
        // Label
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: LrText.bodyMuted.copyWith(
              color: lblColor,
              fontFamily: LrText.fontBold,
              fontSize: 12,
              letterSpacing: .3,
            ),
          ),
        ),
        const SizedBox(width: LrSpace.sm),
        Expanded(child: child),
      ],
    );
  }
}

/// DropdownBox ที่ห่อหุ้ม dropdown_button2 ด้วยดีไซน์ใหม่
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
          color: LrColors.surface,
          borderRadius: BorderRadius.circular(LrRadius.sm),
          border: Border.all(color: LrColors.border, width: 1),
        ),
        child: DropdownButtonHideUnderline(child: child),
      ),
    );
  }
}

/// Search field ภายใน dropdown — ดีไซน์ใหม่
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
        style: LrText.body.copyWith(fontSize: 14),
        cursorColor: LrColors.primary,
        decoration: const InputDecoration(
          isDense: true,
          filled: true,
          fillColor: LrColors.surfaceMuted,
          hintText: 'พิมพ์เพื่อค้นหา...',
          hintStyle: LrText.caption,
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 18,
            color: LrColors.textMuted,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(LrRadius.sm)),
            borderSide: BorderSide(color: LrColors.border, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(LrRadius.sm)),
            borderSide: BorderSide(color: LrColors.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(LrRadius.sm)),
            borderSide: BorderSide(color: LrColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────
/// _subZoneDropdown + _zoneDropdown
/// ─────────────────────────────────────────────────────────────────────────
extension on _LicenseRequestZoneFilterState {
  Widget _subZoneDropdown(LicenseRequestViewModel vm) {
    return _DropdownShell(
      enabled: true,
      child: DropdownButton2<String>(
        isExpanded: true,
        iconSize: 18,
        iconEnabledColor: LrColors.textSecondary,
        buttonHeight: 40,
        dropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(LrRadius.md),
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
          style: LrText.body.copyWith(
            color: vm.selectedZoneSub == null
                ? LrColors.textMuted
                : LrColors.textPrimary,
          ),
          maxFontSize: 14,
          minFontSize: 11,
        ),
        value: vm.selectedZoneSub,
        items: vm.subzoneModels
            .map((sub) => DropdownMenuItem<String>(
                  value: sub.zn ?? '',
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: sub.zn == 'ทั้งหมด'
                              ? LrColors.textMuted
                              : LrColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: AutoSizeText(
                          sub.zn ?? '-',
                          style: LrText.body,
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

  Widget _zoneDropdown(LicenseRequestViewModel vm) {
    final enabled = vm.selectedZoneSub != null && !vm.readOnly;
    return _DropdownShell(
      enabled: enabled,
      child: DropdownButton2<String>(
        isExpanded: true,
        iconSize: 18,
        iconEnabledColor: LrColors.textSecondary,
        buttonHeight: 40,
        dropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(LrRadius.md),
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
          style: LrText.body.copyWith(
            color: vm.selectedZone == null
                ? LrColors.textMuted
                : LrColors.textPrimary,
          ),
          maxFontSize: 14,
          minFontSize: 11,
        ),
        value: vm.selectedZone,
        items: vm.zoneModels
            .map((zn) => DropdownMenuItem<String>(
                  value: zn.zn ?? '',
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: zn.zn == 'ทั้งหมด'
                              ? LrColors.textMuted
                              : LrColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: AutoSizeText(
                          zn.zn ?? '-',
                          style: LrText.body,
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
}
