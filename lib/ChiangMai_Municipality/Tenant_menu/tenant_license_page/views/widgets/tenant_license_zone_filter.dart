// ============================================================================
// tenant_license_zone_filter.dart
// ============================================================================
// ตัวกรอง "หมวดโซนพื้นที่" + "โซนพื้นที่" — ดีไซน์ใหม่
// - ใช้ card + label chip + dropdown ที่ขอบโค้ง
// - search inner widget ปรับให้สวยขึ้น
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/tenant_license_theme.dart';
import '../../viewmodels/tenant_license_view_model.dart';

class TenantLicenseZoneFilter extends StatefulWidget {
  const TenantLicenseZoneFilter({super.key});

  @override
  State<TenantLicenseZoneFilter> createState() =>
      _TenantLicenseZoneFilterState();
}

class _TenantLicenseZoneFilterState extends State<TenantLicenseZoneFilter> {
  final TextEditingController _subZoneSearchCtrl = TextEditingController();
  final TextEditingController _zoneSearchCtrl = TextEditingController();
  bool _collapsed = true;

  @override
  void dispose() {
    _subZoneSearchCtrl.dispose();
    _zoneSearchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TenantLicenseViewModel>();
    return Container(
      padding: const EdgeInsets.all(LaSpace.md),
      decoration: LaDecor.card(),
      child: LayoutBuilder(
        builder: (context, c) {
          final body = c.maxWidth < 1100
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _subZoneSection(vm),
                    const SizedBox(height: LaSpace.md),
                    _zoneSection(vm),
                    const SizedBox(height: LaSpace.md),
                    _statusSection(vm),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 4, child: _subZoneSection(vm)),
                    _divider(),
                    Expanded(flex: 4, child: _zoneSection(vm)),
                    _divider(),
                    Expanded(flex: 4, child: _statusSection(vm)),
                  ],
                );
          // จอกว้าง (≥1100) → โชว์ Row ตรงๆ ไม่มี toggle
          if (c.maxWidth >= 1100) return body;
          // จอแคบ (<1100) → toggle + animated
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _toggleHeader(vm),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: LaSpace.sm),
                  child: body,
                ),
                crossFadeState: _collapsed
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 200),
                sizeCurve: Curves.easeInOut,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _toggleHeader(TenantLicenseViewModel vm) {
    final hasFilter = (vm.selectedZoneSub != null &&
            vm.selectedZoneSub != 'ทั้งหมด') ||
        (vm.selectedZone != null && vm.selectedZone != 'ทั้งหมด') ||
        vm.selectedStatus != 'ทั้งหมด';
    return InkWell(
      onTap: () => setState(() => _collapsed = !_collapsed),
      borderRadius: BorderRadius.circular(LaRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: LaSpace.xs),
        child: Row(
          children: [
            const Icon(Icons.tune_rounded,
                size: 16, color: LaColors.primaryDark),
            const SizedBox(width: LaSpace.sm),
            Text(
              'ตัวกรองพื้นที่',
              style: LaText.bodyMuted.copyWith(
                color: LaColors.textPrimary,
                fontFamily: LaText.fontBold,
                fontSize: 13,
              ),
            ),
            if (hasFilter) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: LaColors.primary,
                  borderRadius: BorderRadius.circular(LaRadius.pill),
                ),
                child: const Text(
                  'ใช้งาน',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontFamily: LaText.fontBold,
                  ),
                ),
              ),
            ],
            const Spacer(),
            AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              turns: _collapsed ? 0 : 0.5,
              child: const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 20, color: LaColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: LaSpace.md),
        color: LaColors.border,
      );

  Widget _subZoneSection(TenantLicenseViewModel vm) {
    return _FilterField(
      icon: Icons.layers_outlined,
      label: 'หมวดโซนพื้นที่',
      child: _subZoneDropdown(vm),
    );
  }

  Widget _zoneSection(TenantLicenseViewModel vm) {
    final enabled = vm.selectedZoneSub != null && !vm.readOnly;
    return _FilterField(
      enabled: enabled,
      icon: Icons.place_outlined,
      label: 'โซนพื้นที่',
      child: _zoneDropdown(vm),
    );
  }

  Widget _statusSection(TenantLicenseViewModel vm) {
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
        // Label
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
          color: LaColors.surface,
          borderRadius: BorderRadius.circular(LaRadius.sm),
          border: Border.all(color: LaColors.border, width: 1),
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

/// ─────────────────────────────────────────────────────────────────────────
/// _subZoneDropdown + _zoneDropdown
/// ─────────────────────────────────────────────────────────────────────────
extension on _TenantLicenseZoneFilterState {
  Widget _subZoneDropdown(TenantLicenseViewModel vm) {
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
                              ? LaColors.textMuted
                              : LaColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: AutoSizeText(
                          sub.zn ?? '-',
                          style: LaText.body,
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

  Widget _zoneDropdown(TenantLicenseViewModel vm) {
    final enabled = vm.selectedZoneSub != null && !vm.readOnly;
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
                              ? LaColors.textMuted
                              : LaColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: AutoSizeText(
                          zn.zn ?? '-',
                          style: LaText.body,
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

  Widget _statusDropdown(TenantLicenseViewModel vm) {
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
        hint: AutoSizeText(
          vm.selectedStatus,
          style: LaText.body.copyWith(
            color: LaColors.textPrimary,
          ),
          maxFontSize: 14,
          minFontSize: 11,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        value: vm.selectedStatus,
        items: vm.statusOptions
            .map((status) => DropdownMenuItem<String>(
                  value: status,
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: status == 'ทั้งหมด'
                              ? LaColors.textMuted
                              : LaColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: AutoSizeText(
                          status,
                          style: LaText.body,
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
        onChanged: vm.readOnly ? null : (v) => vm.onStatusChanged(v),
      ),
    );
  }
}
