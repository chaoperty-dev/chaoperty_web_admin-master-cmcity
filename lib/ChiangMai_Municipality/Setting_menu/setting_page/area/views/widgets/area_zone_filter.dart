// ============================================================================
// area_zone_filter.dart
// ============================================================================
// ตัวกรอง "หมวดโซน" + "โซน" — สไตล์เดียวกับ license_payment
// - ใช้ card + label chip + dropdown ที่ขอบโค้ง
// - ปุ่ม "เพิ่มโซน" inline
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/area_theme.dart';
import '../../viewmodels/area_view_model.dart';

class AreaZoneFilter extends StatefulWidget {
  final VoidCallback? onAddZone;
  final ValueChanged<String?>? onDeleteZone;
  const AreaZoneFilter({
    super.key,
    this.onAddZone,
    this.onDeleteZone,
  });

  @override
  State<AreaZoneFilter> createState() => _AreaZoneFilterState();
}

class _AreaZoneFilterState extends State<AreaZoneFilter> {
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
    final vm = context.watch<AreaViewModel>();
    return Container(
      padding: const EdgeInsets.all(AeaSpace.md),
      decoration: AeaDecor.card(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 5, child: _subZoneSection(vm)),
          _divider(),
          Expanded(flex: 5, child: _zoneSection(vm)),
          if (widget.onAddZone != null) ...[
            const SizedBox(width: AeaSpace.md),
            _ActionButton(
              icon: Icons.add_circle_outline_rounded,
              label: 'เพิ่มโซน',
              color: AeaColors.primary,
              onTap: widget.onAddZone!,
            ),
          ],
          if (widget.onDeleteZone != null) ...[
            const SizedBox(width: AeaSpace.sm),
            _ActionButton(
              icon: Icons.delete_outline_rounded,
              label: 'ลบโซน',
              color: AeaColors.statusRejectedFg,
              onTap: () => widget.onDeleteZone!(vm.selectedZoneSer),
            ),
          ],
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: AeaSpace.md),
        color: AeaColors.border,
      );

  Widget _subZoneSection(AreaViewModel vm) {
    return _FilterField(
      icon: Icons.layers_outlined,
      label: 'หมวดโซนพื้นที่',
      child: _subZoneDropdown(vm),
    );
  }

  Widget _zoneSection(AreaViewModel vm) {
    final enabled =
        vm.selectedZoneSer != null && vm.selectedZoneSer != '0' && !vm.readOnly;
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

extension on _AreaZoneFilterState {
  String? _resolveZoneValue(AreaViewModel vm) {
    final ser = vm.selectedZoneSer;
    if (ser == null || ser.isEmpty || ser == '0') return null;
    // ตรวจสอบว่ามี item ที่ value ตรงกันจริงๆ (ยกเว้น "ทั้งหมด")
    final exists = vm.zones.any(
      (z) => z.ser == ser && z.zn != 'ทั้งหมด',
    );
    return exists ? ser : null;
  }

  Widget _subZoneDropdown(AreaViewModel vm) {
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
        searchController: _subZoneSearchCtrl,
        searchInnerWidget: _SearchInner(_subZoneSearchCtrl),
        hint: AutoSizeText(
          'ทั้งหมด',
          style: AeaText.body.copyWith(color: AeaColors.textPrimary),
          maxFontSize: 14,
          minFontSize: 11,
        ),
        value: null,
        items: const [],
        onChanged: null,
      ),
    );
  }

  Widget _zoneDropdown(AreaViewModel vm) {
    final enabled =
        vm.selectedZoneSer != null && vm.selectedZoneSer != '0' && !vm.readOnly;
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
        hint: AutoSizeText(
          vm.selectedZoneName ?? 'เลือกโซน',
          style: AeaText.body.copyWith(
            color: vm.selectedZoneSer == null || vm.selectedZoneSer == '0'
                ? AeaColors.textMuted
                : AeaColors.textPrimary,
          ),
          maxFontSize: 14,
          minFontSize: 11,
        ),
        value: _resolveZoneValue(vm),
        items: vm.zones
            .where((z) => z.zn != 'ทั้งหมด')
            .map((zn) => DropdownMenuItem<String>(
                  value: zn.ser,
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
                          zn.zn,
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

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AeaAnimations.fast,
          height: 42,
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
              const SizedBox(width: 4),
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
  }
}
