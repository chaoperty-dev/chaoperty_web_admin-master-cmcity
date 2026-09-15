// ============================================================================
// zone_dropdown_row.dart
// ============================================================================
// Row 4 dropdowns: โซนพื้นที่เช่า / โซน / รหัสพื้นที่ / ค้นจากทะเบียน
// - ใช้ _FieldDropdown + icon badge pattern เดียวกับ license_request_page
// - ทุก dropdown มี search box ภายใน
// - cascading: เลือก sub-zone → zone → property
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/license_contract_theme.dart';
import '../../viewmodels/license_contract_view_model.dart';
import 'customer_picker_dialog.dart';

class ZoneDropdownRow extends StatefulWidget {
  const ZoneDropdownRow({super.key});

  @override
  State<ZoneDropdownRow> createState() => _ZoneDropdownRowState();
}

class _ZoneDropdownRowState extends State<ZoneDropdownRow> {
  final TextEditingController _subZoneSearchCtrl = TextEditingController();
  final TextEditingController _zoneSearchCtrl = TextEditingController();
  final TextEditingController _propertySearchCtrl = TextEditingController();

  @override
  void dispose() {
    _subZoneSearchCtrl.dispose();
    _zoneSearchCtrl.dispose();
    _propertySearchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseContractViewModel>();
    final canSearchRegistry = vm.selectedZn != null && !vm.readOnly;
    return Container(
      padding: const EdgeInsets.all(LcSpace.md),
      decoration: LcDecor.card(),
      child: LayoutBuilder(
        builder: (context, c) {
          if (c.maxWidth < 700) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _subZoneField(vm),
                const SizedBox(height: LcSpace.md),
                _zoneField(vm),
                const SizedBox(height: LcSpace.md),
                _propertyField(vm),
                const SizedBox(height: LcSpace.md),
                _searchFromRegistry(enabled: canSearchRegistry),
              ],
            );
          }
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _subZoneField(vm)),
                  const SizedBox(width: LcSpace.md),
                  Expanded(child: _zoneField(vm)),
                ],
              ),
              const SizedBox(height: LcSpace.md),
              Row(
                children: [
                  Expanded(flex: 3, child: _propertyField(vm)),
                  const SizedBox(width: LcSpace.md),
                  Expanded(
                    flex: 2,
                    child: _searchFromRegistry(enabled: canSearchRegistry),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  BoxDecoration _dropdownDecoration() => BoxDecoration(
        borderRadius: BorderRadius.circular(LcRadius.md),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      );

  Widget _subZoneField(LicenseContractViewModel vm) {
    return _FieldDropdown(
      icon: Icons.layers_outlined,
      label: 'โซนพื้นที่เช่า',
      enabled: !vm.readOnly,
      child: DropdownButton2<String>(
        isExpanded: true,
        iconSize: 18,
        iconEnabledColor: LcColors.textSecondary,
        buttonHeight: 40,
        dropdownDecoration: _dropdownDecoration(),
        searchController: _subZoneSearchCtrl,
        searchInnerWidget: _SearchInner(_subZoneSearchCtrl),
        searchInnerWidgetHeight: 56,
        dropdownMaxHeight: 320,
        hint: _hint(vm.selectedSubZone ?? 'เลือกโซนพื้นที่เช่า'),
        value: vm.subZoneOptions.isEmpty ? null : vm.selectedSubZone,
        items: vm.subZoneOptions.isEmpty
            ? [
                const DropdownMenuItem<String>(
                  value: '',
                  child: Text('ไม่มีข้อมูล'),
                ),
              ]
            : vm.subZoneOptions
                .map((sub) => DropdownMenuItem<String>(
                      value: sub,
                      child: _DropRow(label: sub),
                    ))
                .toList(),
        onChanged: vm.readOnly ? null : vm.onSubZoneChanged,
        searchMatchFn: (item, value) =>
            item.value.toString().toLowerCase().contains(value.toLowerCase()),
        onMenuStateChange: (isOpen) {
          if (!isOpen) _subZoneSearchCtrl.clear();
        },
      ),
    );
  }

  Widget _zoneField(LicenseContractViewModel vm) {
    final enabled = vm.selectedSubZone != null && !vm.readOnly;
    return _FieldDropdown(
      icon: Icons.place_outlined,
      label: 'โซน',
      enabled: enabled,
      child: DropdownButton2<String>(
        isExpanded: true,
        iconSize: 18,
        iconEnabledColor: LcColors.textSecondary,
        buttonHeight: 40,
        dropdownDecoration: _dropdownDecoration(),
        searchController: _zoneSearchCtrl,
        searchInnerWidget: _SearchInner(_zoneSearchCtrl),
        searchInnerWidgetHeight: 56,
        dropdownMaxHeight: 320,
        hint: _hint(vm.selectedZn ?? 'เลือกโซน'),
        value: vm.selectedZn,
        items: vm.zoneOptions
            .map((zone) => DropdownMenuItem<String>(
                  value: zone,
                  child: _DropRow(label: zone),
                ))
            .toList(),
        onChanged: enabled ? vm.onZoneChanged : null,
        searchMatchFn: (item, value) =>
            item.value.toString().toLowerCase().contains(value.toLowerCase()),
        onMenuStateChange: (isOpen) {
          if (!isOpen) _zoneSearchCtrl.clear();
        },
      ),
    );
  }

  Widget _propertyField(LicenseContractViewModel vm) {
    return _PropertyDropdown(
      vm: vm,
      searchController: _propertySearchCtrl,
    );
  }

  Widget _searchFromRegistry({required bool enabled}) {
    return _FieldDropdown(
      icon: Icons.search_rounded,
      label: 'ค้นหาจากทะเบียน',
      enabled: enabled,
      child: _RegistryButton(
        enabled: enabled,
        onTap: _openCustomerPicker,
      ),
    );
  }

  Future<void> _openCustomerPicker() async {
    final customer = await CustomerPickerDialog.show(context);
    if (customer == null || !mounted) return;
    context.read<LicenseContractViewModel>().applyCustomerFromRegistry(
          custno: customer.custno,
          uuid: customer.uuid,
          cname: customer.cname,
          scname: customer.scname,
          stype: customer.stype,
          tax: customer.tax,
          tel: customer.tel,
          addr1: customer.addr1,
          national: customer.national,
        );
  }

  Widget _hint(String text) => AutoSizeText(
        text,
        style: LcText.input.copyWith(color: LcColors.textMuted),
        maxFontSize: 14,
        minFontSize: 11,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
}

class _PropertyDropdown extends StatefulWidget {
  final LicenseContractViewModel vm;
  final TextEditingController searchController;

  const _PropertyDropdown({
    required this.vm,
    required this.searchController,
  });

  @override
  State<_PropertyDropdown> createState() => _PropertyDropdownState();
}

class _PropertyDropdownState extends State<_PropertyDropdown> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _targetKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  OverlayEntry? _overlay;
  double _width = 0;

  LicenseContractViewModel get vm => widget.vm;
  bool get _enabled => vm.selectedZn != null && !vm.readOnly;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    widget.searchController.addListener(_refreshOverlay);
    vm.addListener(_refreshOverlay);
  }

  @override
  void didUpdateWidget(covariant _PropertyDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vm != vm) {
      oldWidget.vm.removeListener(_refreshOverlay);
      vm.addListener(_refreshOverlay);
    }
  }

  void _refreshOverlay() => _overlay?.markNeedsBuild();

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter <= 40) {
      vm.loadMoreAreas();
    }
  }

  Future<void> _open() async {
    if (!_enabled || _overlay != null) return;
    final box = _targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    _width = box.size.width;
    await vm.refreshProperties();
    if (!mounted) return;
    _overlay = OverlayEntry(builder: _buildOverlay);
    Overlay.of(context).insert(_overlay!);
  }

  void _close() {
    _overlay?.remove();
    _overlay = null;
    widget.searchController.clear();
  }

  Widget _buildOverlay(BuildContext overlayContext) { 
    final query = widget.searchController.text.toLowerCase();
    final areas = vm.filteredAreas.where((area) {
      final lock = area.lncode?.toLowerCase() ?? '';
      final requester = area.cname?.toLowerCase() ?? '';
      return lock.contains(query) || requester.contains(query);
    }).toList();
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _close,
          ),
        ),
        CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 48),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: _width,
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(LcRadius.md),
                border: Border.all(color: LcColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SearchInner(widget.searchController),
                  Flexible(
                    child: vm.isAreasLoading && areas.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : areas.isEmpty
                            ? const Center(child: Text('ไม่พบรหัสพื้นที่'))
                            : ListView.builder(
                                controller: _scrollController,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                itemCount: areas.length +
                                    (vm.isAreasLoading && areas.isNotEmpty
                                        ? 1
                                        : 0),
                                itemBuilder: (context, index) {
                                  if (index == areas.length) {
                                    return const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Center(
                                        child: SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  final area = areas[index];
                                  final occupied = vm.isOccupied(area);
                                  final lock = area.lncode ?? '-';
                                  final requester = area.cname ?? '';
                                  final request = area.properties.isNotEmpty
                                      ? area.properties.first.newRequest
                                      : null;
                                  final status = area.properties.isEmpty
                                      ? 'ว่าง'
                                      : ((request?.requestStatus?.isNotEmpty ??
                                              false)
                                          ? request!.requestStatus!
                                          : 'กำลังดำเนินการ');
                                  return InkWell(
                                    onTap: occupied
                                        ? null
                                        : () {
                                            vm.onPropertyChanged(
                                              '$lock|${area.ser ?? ''}|${area.zser ?? ''}|$requester',
                                            );
                                            _close();
                                          },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 7,
                                      ),
                                      child: _PropertyDropRow(
                                        mainLabel: requester.isEmpty
                                            ? lock
                                            : '$lock • $requester',
                                        subLabel: status,
                                        occupied: occupied,
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _close();
    vm.removeListener(_refreshOverlay);
    widget.searchController.removeListener(_refreshOverlay);
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = vm.selectedLn?.split('|').first ??
        (vm.selectedZn == null ? 'เลือกโซนก่อน' : 'เลือกรหัสพื้นที่');
    return _FieldDropdown(
      icon: Icons.numbers_rounded,
      label: 'รหัสพื้นที่',
      enabled: _enabled,
      child: CompositedTransformTarget(
        key: _targetKey,
        link: _layerLink,
        child: InkWell(
          onTap: _enabled ? _open : null,
          child: SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                  child: AutoSizeText(
                    text,
                    style: LcText.input.copyWith(
                      color: vm.selectedLn == null
                          ? LcColors.textMuted
                          : LcColors.textPrimary,
                    ),
                    maxFontSize: 14,
                    minFontSize: 11,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down,
                    size: 18, color: LcColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldDropdown extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;
  final bool enabled;

  const _FieldDropdown({
    required this.icon,
    required this.label,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : .55,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 4),
            child: Row(
              children: [
                Icon(icon, size: 14, color: LcColors.primaryDark),
                const SizedBox(width: 4),
                Text(label, style: LcText.label.copyWith(fontSize: 11)),
              ],
            ),
          ),
          Container(
            constraints: const BoxConstraints(minHeight: 42),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: LcColors.surfaceMuted.withOpacity(.6),
              borderRadius: BorderRadius.circular(LcRadius.sm),
              border: Border.all(color: LcColors.border, width: 1),
            ),
            child: DropdownButtonHideUnderline(child: child),
          ),
        ],
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
        style: LcText.input.copyWith(fontSize: 14),
        decoration: const InputDecoration(
          isDense: true,
          filled: true,
          fillColor: LcColors.surfaceMuted,
          hintText: 'พิมพ์เพื่อค้นหา...',
          prefixIcon: Icon(Icons.search_rounded, size: 18),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _DropRow extends StatelessWidget {
  final String label;
  const _DropRow({required this.label});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(
              color: LcColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: AutoSizeText(
              label,
              style: LcText.input,
              maxFontSize: 14,
              minFontSize: 11,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
}

class _PropertyDropRow extends StatelessWidget {
  final String mainLabel;
  final String? subLabel;
  final bool occupied;
  const _PropertyDropRow({
    required this.mainLabel,
    this.subLabel,
    this.occupied = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = occupied ? LcColors.textMuted : LcColors.textPrimary;
    final statusColor = subLabel == 'ว่าง'
        ? const Color(0xFF2E7D32)
        : occupied
            ? const Color(0xFFC62828)
            : LcColors.textSecondary;
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: occupied ? LcColors.textMuted : LcColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                mainLabel,
                style: LcText.input.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                maxFontSize: 14,
                minFontSize: 11,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subLabel != null)
                Text(
                  subLabel!,
                  style: TextStyle(
                    fontSize: 10,
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
        if (occupied)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: LcColors.surfaceMuted,
              borderRadius: BorderRadius.circular(LcRadius.pill),
              border: Border.all(color: LcColors.border),
            ),
            child: const Text(
              'ไม่ว่าง',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: LcColors.textMuted,
              ),
            ),
          ),
      ],
    );
  }
}

class _RegistryButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool enabled;
  const _RegistryButton({required this.onTap, this.enabled = true});

  @override
  State<_RegistryButton> createState() => _RegistryButtonState();
}

class _RegistryButtonState extends State<_RegistryButton> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (enabled) setState(() => _hover = true);
      },
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: _down ? 0.97 : (_hover ? 1.02 : 1),
        duration: LcAnimations.fast,
        curve: Curves.easeOut,
        child: GestureDetector(
          onTap: enabled ? widget.onTap : null,
          onTapDown: (_) {
            if (enabled) setState(() => _down = true);
          },
          onTapCancel: () => setState(() => _down = false),
          onTapUp: (_) => setState(() => _down = false),
          child: AnimatedContainer(
            duration: LcAnimations.fast,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: !enabled
                  ? LcColors.surfaceMuted.withOpacity(.3)
                  : (_hover ? LcColors.headerAccent : LcColors.headerBg),
              borderRadius: BorderRadius.circular(LcRadius.sm),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 14,
                  color: !enabled ? LcColors.textMuted : Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  'ค้นหาจากทะเบียน',
                  style: LcText.caption.copyWith(
                    color: !enabled ? LcColors.textMuted : Colors.white,
                    fontFamily: LcText.fontBold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_rounded,
                    size: 12, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
