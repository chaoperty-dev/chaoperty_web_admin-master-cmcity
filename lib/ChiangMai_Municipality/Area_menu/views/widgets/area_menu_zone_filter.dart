// ============================================================================
// area_menu_zone_filter.dart
// ============================================================================
// ตัวกรอง "หมวดโซนพื้นที่" + "โซนพื้นที่" + "สถานะคำขอ" + เรียง
// ✅ coppy UI + ลอจิกยิง API จาก license_request_zone_filter.dart ทั้งหมด
// - โซน disabled จนกว่าจะเลือกหมวดโซน
// - เลือกอะไรก็ได้ → sync store → VM ยิง API ใหม่ทุกครั้ง
// - ถ้า "สถานะคำขอ" = ทั้งหมด → ไม่ส่ง status ให้ backend
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
    final vm = context.watch<AreaMenuViewModel>();
    return Container(
      padding: const EdgeInsets.all(LaSpace.md),
      decoration: LaDecor.card(),
      child: LayoutBuilder(
        builder: (context, c) {
          // จอแคบ (<1100px) → stack dropdown เป็นแนวตั้ง
          final body = c.maxWidth < 1100
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _subZoneSection(vm),
                    const SizedBox(height: LaSpace.md),
                    _zoneSection(vm),
                    const SizedBox(height: LaSpace.md),
                    _requestStatusSection(vm),
                    const SizedBox(height: LaSpace.md),
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
                    Expanded(flex: 4, child: _requestStatusSection(vm)),
                    _divider(),
                    const SizedBox(width: LaSpace.sm),
                    _sortSection(vm),
                  ],
                );
          // desktop: แสดงตลอด (ไม่หุบ)
          if (c.maxWidth >= 1100) return body;
          // mobile: collapsible (default หุบไว้)
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

  Widget _toggleHeader(AreaMenuViewModel vm) {
    final hasFilter = (vm.selectedZoneSub != null &&
            vm.selectedZoneSub != 'ทั้งหมด') ||
        (vm.selectedZone != null && vm.selectedZone != 'ทั้งหมด') ||
        vm.selectedRequestStatus != 'ทั้งหมด' ||
        vm.selectedSort != 'lock' ||
        vm.selectedSortDir != 'asc';
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

  Widget _subZoneSection(AreaMenuViewModel vm) {
    return _FilterField(
      icon: Icons.layers_outlined,
      label: 'หมวดโซนพื้นที่',
      child: _subZoneDropdown(vm),
    );
  }

  Widget _zoneSection(AreaMenuViewModel vm) {
    // เหมือน license — เลือกหมวดโซนก่อนถึงเปิดโซน
    final enabled = vm.selectedZoneSub != null && !vm.readOnly;
    return _FilterField(
      enabled: enabled,
      icon: Icons.place_outlined,
      label: 'โซนพื้นที่',
      child: _zoneDropdown(vm),
    );
  }

  Widget _requestStatusSection(AreaMenuViewModel vm) {
    return _FilterField(
      icon: Icons.flag_outlined,
      label: 'สถานะคำขอ',
      child: _requestStatusDropdown(vm),
    );
  }

  Widget _sortSection(AreaMenuViewModel vm) {
    final isDesc = vm.selectedSortDir == 'desc';
    return InkWell(
      onTap: vm.readOnly ? null : () => _showSortMenu(vm),
      borderRadius: BorderRadius.circular(LaRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: LaColors.surfaceMuted,
          borderRadius: BorderRadius.circular(LaRadius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDesc
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              size: 14,
              color: LaColors.textMuted,
            ),
            const SizedBox(width: 6),
            const Text(
              'เรียง',
              style: TextStyle(fontSize: 13, color: LaColors.textSecondary),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.expand_more_rounded,
              size: 14,
              color: LaColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  void _showSortMenu(AreaMenuViewModel vm) {
    final isDesc = vm.selectedSortDir == 'desc';
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(.05),
      builder: (ctx) => Dialog(
        alignment: Alignment.bottomRight,
        insetPadding: const EdgeInsets.fromLTRB(0, 0, 24, 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LaRadius.md),
        ),
        child: SizedBox(
          width: 280,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    onTap: () {
                      vm.onSortDirChanged();
                      Navigator.of(ctx).pop();
                    },
                    borderRadius: BorderRadius.circular(LaRadius.sm),
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
                            color: LaColors.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AutoSizeText(
                              isDesc ? 'มากไปน้อย' : 'น้อยไปมาก',
                              style: LaText.body.copyWith(
                                color: LaColors.textMuted,
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
                            color: LaColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ...AreaMenuViewModel.sortOptions.map((k) => InkWell(
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
                                        color: LaColors.primary,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AutoSizeText(
                                  AreaMenuViewModel.sortLabels[k] ?? k,
                                  style: LaText.body.copyWith(fontSize: 13),
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

/// Search field ภายใน dropdown
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
/// _subZoneDropdown + _zoneDropdown + _requestStatusDropdown
/// ─────────────────────────────────────────────────────────────────────────
extension on _AreaMenuZoneFilterState {
  Widget _subZoneDropdown(AreaMenuViewModel vm) {
    return _DropdownShell(
      enabled: true,
      child: DropdownButton2<String>(
        isExpanded: true,
        iconSize: 18,
        iconEnabledColor: LaColors.textSecondary,
        buttonHeight: 40,
        dropdownMaxHeight: 320,
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
        searchInnerWidgetHeight: 56,
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
                  value: sub['zn']?.toString() ?? '',
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: sub['zn']?.toString() == 'ทั้งหมด'
                              ? LaColors.textMuted
                              : LaColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: AutoSizeText(
                          sub['zn']?.toString() ?? '-',
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

  Widget _zoneDropdown(AreaMenuViewModel vm) {
    final enabled = vm.selectedZoneSub != null && !vm.readOnly;
    return _DropdownShell(
      enabled: enabled,
      child: DropdownButton2<String>(
        isExpanded: true,
        iconSize: 18,
        iconEnabledColor: LaColors.textSecondary,
        buttonHeight: 40,
        dropdownMaxHeight: 320,
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
        searchInnerWidgetHeight: 56,
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
                  value: zn['zn']?.toString() ?? '',
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: zn['zn']?.toString() == 'ทั้งหมด'
                              ? LaColors.textMuted
                              : LaColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: AutoSizeText(
                          zn['zn']?.toString() ?? '-',
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

  Widget _requestStatusDropdown(AreaMenuViewModel vm) {
    return _DropdownShell(
      enabled: !vm.readOnly,
      child: DropdownButton2<String>(
        isExpanded: true,
        iconSize: 18,
        iconEnabledColor: LaColors.textSecondary,
        buttonHeight: 40,
        dropdownMaxHeight: 320,
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
        searchController: _statusSearchCtrl,
        searchInnerWidget: _SearchInner(_statusSearchCtrl),
        searchInnerWidgetHeight: 56,
        hint: AutoSizeText(
          vm.selectedRequestStatus == 'ทั้งหมด'
              ? 'ทั้งหมด'
              : vm.selectedRequestStatus,
          style: LaText.body.copyWith(
            color: vm.selectedRequestStatus == 'ทั้งหมด'
                ? LaColors.textMuted
                : LaColors.textPrimary,
          ),
          maxFontSize: 14,
          minFontSize: 11,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        value: vm.selectedRequestStatus,
        items: vm.requestStatusItems.map((item) {
          final th = item['th'] ?? '';
          final en = item['en'] ?? '';
          final isAll = th == 'ทั้งหมด';
          final palette = isAll
              ? const StatusPalette(LaColors.textMuted, LaColors.textMuted)
              : StatusPalette.of(th);
          return DropdownMenuItem<String>(
            value: th,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AutoSizeText(
                        th,
                        style: LaText.body,
                        maxFontSize: 14,
                        minFontSize: 11,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (en.isNotEmpty)
                        AutoSizeText(
                          en,
                          style: LaText.caption
                              .copyWith(color: LaColors.textMuted),
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
          );
        }).toList(),
        onChanged: vm.readOnly ? null : (v) => vm.onRequestStatusChanged(v),
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