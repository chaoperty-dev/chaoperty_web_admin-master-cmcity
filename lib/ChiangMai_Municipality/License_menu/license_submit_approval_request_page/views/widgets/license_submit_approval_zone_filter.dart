// ============================================================================
// license_submit_approval_zone_filter.dart
// ============================================================================
// ตัวกรอง "หมวดโซนพื้นที่" + "โซนพื้นที่" + "สถานะ" — ดีไซน์ใหม่
// - ใช้ card + label chip + dropdown ที่ขอบโค้ง
// - search inner widget ปรับให้สวยขึ้น
// - ถ้า "สถานะ" = ทั้งหมด → ไม่ส่ง key ให้ backend
// (copy จาก license_attach_zone_filter.dart เพื่อให้ dropdown ทำงาน)
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../license_request_page/views/theme/license_request_theme.dart';
import '../../viewmodels/license_submit_approval_view_model.dart';

class LicenseSubmitApprovalZoneFilter extends StatefulWidget {
  const LicenseSubmitApprovalZoneFilter({super.key});

  @override
  State<LicenseSubmitApprovalZoneFilter> createState() =>
      _LicenseSubmitApprovalZoneFilterState();
}

class _LicenseSubmitApprovalZoneFilterState extends State<LicenseSubmitApprovalZoneFilter> {
  final TextEditingController _subZoneSearchCtrl = TextEditingController();
  final TextEditingController _zoneSearchCtrl = TextEditingController();
  final TextEditingController _statusSearchCtrl = TextEditingController();
  bool _collapsed = true;

  @override
  void dispose() {
    _subZoneSearchCtrl.dispose();
    _zoneSearchCtrl.dispose();
    _statusSearchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseSubmitApprovalViewModel>();
    return Container(
      padding: const EdgeInsets.all(LrSpace.md),
      decoration: LrDecor.card(),
      child: LayoutBuilder(
        builder: (context, c) {
          final body = c.maxWidth < 1100
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _subZoneSection(vm),
                    const SizedBox(height: LrSpace.md),
                    _zoneSection(vm),
                    const SizedBox(height: LrSpace.md),
                    _statusSection(vm),
                    const SizedBox(height: LrSpace.md),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _sortSection(vm),
                    ),
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
                    _divider(),
                    const SizedBox(width: LrSpace.sm),
                    _sortSection(vm),
                  ],
                );
          if (c.maxWidth >= 1100) return body;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _toggleHeader(vm),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: LrSpace.sm),
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

  Widget _toggleHeader(LicenseSubmitApprovalViewModel vm) {
    final hasFilter = (vm.selectedZoneSub != null &&
            vm.selectedZoneSub != 'ทั้งหมด') ||
        (vm.selectedZone != null && vm.selectedZone != 'ทั้งหมด') ||
        vm.selectedStatus != null ||
        vm.selectedSort != 'created_at' ||
        vm.selectedSortDir != 'desc';
    return InkWell(
      onTap: () => setState(() => _collapsed = !_collapsed),
      borderRadius: BorderRadius.circular(LrRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: LrSpace.xs),
        child: Row(
          children: [
            const Icon(Icons.tune_rounded, size: 16, color: LrColors.primaryDark),
            const SizedBox(width: LrSpace.sm),
            Text(
              'ตัวกรองพื้นที่',
              style: LrText.bodyMuted.copyWith(
                color: LrColors.textPrimary,
                fontFamily: LrText.fontBold,
                fontSize: 13,
              ),
            ),
            if (hasFilter) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: LrColors.primary,
                  borderRadius: BorderRadius.circular(LrRadius.pill),
                ),
                child: const Text(
                  'ใช้งาน',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontFamily: LrText.fontBold,
                  ),
                ),
              ),
            ],
            const Spacer(),
            AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              turns: _collapsed ? 0 : 0.5,
              child: const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 20, color: LrColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: LrSpace.md),
        color: LrColors.border,
      );

  Widget _subZoneSection(LicenseSubmitApprovalViewModel vm) {
    return _FilterField(
      icon: Icons.layers_outlined,
      label: 'หมวดโซนพื้นที่',
      child: _subZoneDropdown(vm),
    );
  }

  Widget _zoneSection(LicenseSubmitApprovalViewModel vm) {
    final enabled = vm.selectedZoneSub != null && !vm.readOnly;
    return _FilterField(
      enabled: enabled,
      icon: Icons.place_outlined,
      label: 'โซนพื้นที่',
      child: _zoneDropdown(vm),
    );
  }

  Widget _statusSection(LicenseSubmitApprovalViewModel vm) {
    return _FilterField(
      icon: Icons.flag_outlined,
      label: 'สถานะ',
      child: _statusDropdown(vm),
    );
  }

  Widget _sortSection(LicenseSubmitApprovalViewModel vm) {
    final isDesc = vm.selectedSortDir == 'desc';
    return InkWell(
      onTap: vm.readOnly ? null : () => _showSortMenu(vm),
      borderRadius: BorderRadius.circular(LrRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: LrColors.surfaceMuted,
          borderRadius: BorderRadius.circular(LrRadius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDesc
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              size: 14,
              color: LrColors.textMuted,
            ),
            const SizedBox(width: 6),
            const Text(
              'เรียง',
              style: TextStyle(fontSize: 13, color: LrColors.textSecondary),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.expand_more_rounded,
              size: 14,
              color: LrColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  void _showSortMenu(LicenseSubmitApprovalViewModel vm) {
    final isDesc = vm.selectedSortDir == 'desc';
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(.05),
      builder: (ctx) => Dialog(
        alignment: Alignment.bottomRight,
        insetPadding: const EdgeInsets.fromLTRB(0, 0, 24, 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LrRadius.md),
        ),
        child: SizedBox(
          width: 280,
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    onTap: () {
                      vm.onSortDirChanged();
                      Navigator.of(ctx).pop();
                    },
                    borderRadius: BorderRadius.circular(LrRadius.sm),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Row(
                        children: [
                          Icon(
                            isDesc
                                ? Icons.arrow_downward_rounded
                                : Icons.arrow_upward_rounded,
                            size: 14,
                            color: LrColors.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AutoSizeText(
                              isDesc ? 'มากไปน้อย' : 'น้อยไปมาก',
                              style: LrText.body.copyWith(
                                color: LrColors.textMuted,
                                fontSize: 13,
                              ),
                              maxFontSize: 13,
                              minFontSize: 11,
                              maxLines: 1,
                            ),
                          ),
                          const Icon(
                            Icons.swap_vert_rounded,
                            size: 14,
                            color: LrColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ...LicenseSubmitApprovalViewModel.sortOptions.map((k) =>
                      InkWell(
                        onTap: () {
                          vm.onSortChanged(k);
                          Navigator.of(ctx).pop();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: k == vm.selectedSort
                                    ? const Icon(
                                        Icons.check_rounded,
                                        size: 14,
                                        color: LrColors.primary,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AutoSizeText(
                                  LicenseSubmitApprovalViewModel
                                          .sortLabels[k] ??
                                      k,
                                  style: LrText.body.copyWith(fontSize: 13),
                                  maxFontSize: 13,
                                  minFontSize: 11,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
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
extension on _LicenseSubmitApprovalZoneFilterState {
  Widget _subZoneDropdown(LicenseSubmitApprovalViewModel vm) {
    // กัน assertion fail: ถ้า value ไม่ตรงกับ item ใดเลย ให้ส่ง null
    final subZoneValues = vm.subzoneModels.map((s) => s.zn ?? '').toSet();
    final safeSubZoneValue =
        subZoneValues.contains(vm.selectedZoneSub) ? vm.selectedZoneSub : null;

    return _DropdownShell(
      enabled: true,
      child: DropdownButton2<String>(
        isExpanded: true,
        iconSize: 18,
        iconEnabledColor: LrColors.textSecondary,
        buttonHeight: 40,
        dropdownMaxHeight: 320,
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        value: safeSubZoneValue,
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

  Widget _zoneDropdown(LicenseSubmitApprovalViewModel vm) {
    final enabled = vm.selectedZoneSub != null && !vm.readOnly;
    // กัน assertion fail: ถ้า value ไม่ตรงกับ item ใดเลย ให้ส่ง null
    final zoneValues = vm.zoneModels.map((z) => z.zn ?? '').toSet();
    final safeZoneValue =
        zoneValues.contains(vm.selectedZone) ? vm.selectedZone : null;
    return _DropdownShell(
      enabled: enabled,
      child: DropdownButton2<String>(
        isExpanded: true,
        iconSize: 18,
        iconEnabledColor: LrColors.textSecondary,
        buttonHeight: 40,
        dropdownMaxHeight: 320,
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        value: safeZoneValue,
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

  Widget _statusDropdown(LicenseSubmitApprovalViewModel vm) {
    final items = <String>['ทั้งหมด', ...LicenseSubmitApprovalViewModel.statusOptions];
    final value = vm.selectedStatus ?? 'ทั้งหมด';
    return _DropdownShell(
      enabled: !vm.readOnly,
      child: DropdownButton2<String>(
        isExpanded: true,
        iconSize: 18,
        iconEnabledColor: LrColors.textSecondary,
        buttonHeight: 40,
        dropdownMaxHeight: 320,
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
        searchController: _statusSearchCtrl,
        searchInnerWidget: _SearchInner(_statusSearchCtrl),
        hint: AutoSizeText(
          vm.selectedStatus == null
              ? 'ทั้งหมด'
              : (LicenseSubmitApprovalViewModel
                      .statusLabels[vm.selectedStatus] ??
                  vm.selectedStatus!),
          style: LrText.body.copyWith(
            color: vm.selectedStatus == null
                ? LrColors.textMuted
                : LrColors.textPrimary,
          ),
          maxFontSize: 14,
          minFontSize: 11,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        value: value,
        items: items
            .map((s) => DropdownMenuItem<String>(
                  value: s,
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: s == 'ทั้งหมด'
                              ? LrColors.textMuted
                              : StatusPalette.of(s).fg,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AutoSizeText(
                              s == 'ทั้งหมด'
                                  ? s
                                  : (LicenseSubmitApprovalViewModel
                                          .statusLabels[s] ??
                                      s),
                              style: LrText.body,
                              maxFontSize: 14,
                              minFontSize: 11,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (s != 'ทั้งหมด')
                              AutoSizeText(
                                s,
                                style: LrText.caption
                                    .copyWith(color: LrColors.textMuted),
                                maxFontSize: 10,
                                minFontSize: 9,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
        onChanged: vm.readOnly ? null : (v) => vm.onStatusChanged(v),
        searchMatchFn: (item, searchValue) {
          return item.value
              .toString()
              .toLowerCase()
              .contains(searchValue.toLowerCase());
        },
        onMenuStateChange: (isOpen) {
          if (!isOpen) _statusSearchCtrl.clear();
        },
      ),
    );
  }

}
