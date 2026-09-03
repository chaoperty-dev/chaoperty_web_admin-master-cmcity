// ============================================================================
// area_zone_filter.dart
// ============================================================================
// ตัวกรอง "หมวดโซน" + "โซน" สำหรับ _AreaTab ใน area_page
// - Copy pattern จาก LicenseApproveZoneFilter (card + icon + label + dropdown2)
// - ถ้า group = "ทั้งหมด" (ser=0) → zone dropdown disabled
// - ถ้า zone = null → ไม่ส่ง zone_ser (ให้ VM filter by group)
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/area_view_model.dart';
import '../theme/area_theme.dart';

class AreaZoneFilter extends StatefulWidget {
  const AreaZoneFilter({super.key});

  @override
  State<AreaZoneFilter> createState() => _AreaZoneFilterState();
}

class _AreaZoneFilterState extends State<AreaZoneFilter> {
  final TextEditingController _groupSearchCtrl = TextEditingController();
  final TextEditingController _zoneSearchCtrl = TextEditingController();
  bool _collapsed = false; // default expanded (พื้นที่เช่า = แท็บแรก ใช้บ่อย)

  @override
  void dispose() {
    _groupSearchCtrl.dispose();
    _zoneSearchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AreaViewModel>();
    final hasFilter =
        (vm.selectedGroupSer != null && vm.selectedGroupSer != '0') ||
            (vm.selectedZoneSer != null);

    return Container(
      padding: const EdgeInsets.all(AeaSpace.md),
      decoration: AeaDecor.card(),
      child: LayoutBuilder(
        builder: (context, c) {
          final body = c.maxWidth < 900
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _groupSection(vm),
                    const SizedBox(height: AeaSpace.md),
                    _zoneSection(vm),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 5, child: _groupSection(vm)),
                    _divider(),
                    Expanded(flex: 5, child: _zoneSection(vm)),
                  ],
                );
          if (c.maxWidth >= 900) return body;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _toggleHeader(hasFilter),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: AeaSpace.sm),
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

  Widget _toggleHeader(bool hasFilter) {
    return InkWell(
      onTap: () => setState(() => _collapsed = !_collapsed),
      borderRadius: BorderRadius.circular(AeaRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AeaSpace.xs),
        child: Row(
          children: [
            const Icon(Icons.tune_rounded,
                size: 16, color: AeaColors.primaryDark),
            const SizedBox(width: AeaSpace.sm),
            Text(
              'ตัวกรองพื้นที่',
              style: AeaText.body.copyWith(
                color: AeaColors.textPrimary,
                fontFamily: AeaText.fontBold,
                fontSize: 13,
              ),
            ),
            if (hasFilter) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AeaColors.primary,
                  borderRadius: BorderRadius.circular(AeaRadius.pill),
                ),
                child: const Text(
                  'ใช้งาน',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontFamily: AeaText.fontBold,
                  ),
                ),
              ),
            ],
            const Spacer(),
            AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              turns: _collapsed ? 0 : 0.5,
              child: const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 20, color: AeaColors.textSecondary),
            ),
          ],
        ),
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
      child: _zoneDropdown(vm),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// _FilterField / _DropdownShell / _SearchInner
// ─────────────────────────────────────────────────────────────────────────

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
          width: 96,
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
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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

// ─────────────────────────────────────────────────────────────────────────
// Dropdowns (extension บน _AreaZoneFilterState)
// ─────────────────────────────────────────────────────────────────────────
extension on _AreaZoneFilterState {
  Widget _groupDropdown(AreaViewModel vm) {
    final groupValues = vm.groups.map((g) => g.ser).toSet();
    final safeValue =
        groupValues.contains(vm.selectedGroupSer) ? vm.selectedGroupSer : null;

    return _DropdownShell(
      enabled: true,
      child: DropdownButton2<String>(
        isExpanded: true,
        iconSize: 18,
        iconEnabledColor: AeaColors.textSecondary,
        buttonHeight: 40,
        dropdownMaxHeight: 320,
        dropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AeaRadius.md),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        searchController: _groupSearchCtrl,
        searchInnerWidget: _SearchInner(_groupSearchCtrl),
        searchInnerWidgetHeight: 56,
        hint: AutoSizeText(
          vm.selectedGroupName ?? 'ทั้งหมด',
          style: AeaText.body.copyWith(
            color: vm.selectedGroupSer == null
                ? AeaColors.textMuted
                : AeaColors.textPrimary,
          ),
          maxFontSize: 14,
          minFontSize: 11,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        value: safeValue,
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
                          color: g.ser == '0'
                              ? AeaColors.textMuted
                              : AeaColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: AutoSizeText(
                          g.zn.isEmpty ? '-' : g.zn,
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
          return item.value
              .toString()
              .toLowerCase()
              .contains(searchValue.toLowerCase());
        },
        onMenuStateChange: (isOpen) {
          if (!isOpen) _groupSearchCtrl.clear();
        },
      ),
    );
  }

  Widget _zoneDropdown(AreaViewModel vm) {
    final enabled = vm.selectedGroupSer != null && vm.selectedGroupSer != '0';
    final zoneValues = vm.zones.map((z) => z.ser).toSet();
    final safeValue =
        zoneValues.contains(vm.selectedZoneSer) ? vm.selectedZoneSer : null;
    return _DropdownShell(
      enabled: enabled,
      child: DropdownButton2<String>(
        isExpanded: true,
        iconSize: 18,
        iconEnabledColor: AeaColors.textSecondary,
        buttonHeight: 40,
        dropdownMaxHeight: 320,
        dropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AeaRadius.md),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        searchController: _zoneSearchCtrl,
        searchInnerWidget: _SearchInner(_zoneSearchCtrl),
        searchInnerWidgetHeight: 56,
        hint: AutoSizeText(
          enabled ? (vm.selectedZoneName ?? 'เลือกโซน') : 'เลือกหมวดก่อน',
          style: AeaText.body.copyWith(
            color: (enabled && vm.selectedZoneName != null)
                ? AeaColors.textPrimary
                : AeaColors.textMuted,
          ),
          maxFontSize: 14,
          minFontSize: 11,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        value: safeValue,
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
                          z.zn.isEmpty ? '-' : z.zn,
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
