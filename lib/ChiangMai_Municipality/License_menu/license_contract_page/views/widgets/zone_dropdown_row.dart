// ============================================================================
// zone_dropdown_row.dart
// ============================================================================
// Row 4 dropdowns: โซนพื้นที่เช่า / โซน / รหัสพื้นที่ / ค้นจากทะเบียน
// - ใช้ _FieldDropdown + icon badge pattern เดียวกับ license_request_page
// - **ทุก dropdown มี search box ภายใน** (กดแล้วพิมพ์ค้นหาได้)
// - cascading: เลือก sub-zone → zone → property
// - ปุ่ม "ค้นหาจากทะเบียน" จะ disabled ถ้ายังไม่ได้เลือกโซน
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../Style/colors.dart';
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
      child: Column(
        children: [
          // Row 1: sub-zone + zone
          Row(
            children: [
              Expanded(child: _subZoneField(context, vm)),
              const SizedBox(width: LcSpace.md),
              Expanded(child: _zoneField(context, vm)),
            ],
          ),
          const SizedBox(height: LcSpace.md),
          // Row 2: property + search from registry
          Row(
            children: [
              Expanded(flex: 3, child: _propertyField(context, vm)),
              const SizedBox(width: LcSpace.md),
              Expanded(
                flex: 2,
                child: _searchFromRegistry(enabled: canSearchRegistry),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // Dropdown decoration (รวมไว้ที่เดียวเพื่อ reuse)
  // ──────────────────────────────────────────────────────────────────
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

  // ──────────────────────────────────────────────────────────────────
  // Sub-zone
  // ──────────────────────────────────────────────────────────────────
  Widget _subZoneField(BuildContext context, LicenseContractViewModel vm) {
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
        hint: _hint(vm.selectedSubZone ?? 'เลือกโซนพื้นที่เช่า'),
        value: vm.subZoneOptions.isEmpty ? null : vm.selectedSubZone,
        items: vm.subZoneOptions.isEmpty
            ? [
                const DropdownMenuItem<String>(
                    value: '', child: Text('ไม่มีข้อมูล')),
              ]
            : vm.subZoneOptions
                .map((sub) => DropdownMenuItem<String>(
                      value: sub,
                      child: _DropRow(label: sub),
                    ))
                .toList(),
        onChanged: (vm.subZoneOptions.isEmpty || vm.readOnly)
            ? null
            : (v) {
                if (v == null) return;
                vm.onSubZoneChanged(v);
              },
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

  // ──────────────────────────────────────────────────────────────────
  // Zone
  // ──────────────────────────────────────────────────────────────────
  Widget _zoneField(BuildContext context, LicenseContractViewModel vm) {
    final enabled = !vm.readOnly;
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
        hint: _hint(vm.selectedZn ?? 'เลือกโซน'),
        value: vm.selectedZn,
        items: vm.zoneOptions
            .map((zn) => DropdownMenuItem<String>(
                  value: zn,
                  child: _DropRow(label: zn),
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

  // ──────────────────────────────────────────────────────────────────
  // Property (รหัสพื้นที่)
  // ──────────────────────────────────────────────────────────────────
  Widget _propertyField(BuildContext context, LicenseContractViewModel vm) {
    final enabled = vm.selectedZn != null && !vm.readOnly;
    return _FieldDropdown(
      icon: Icons.numbers_rounded,
      label: 'รหัสพื้นที่',
      enabled: enabled,
      child: DropdownButton2<String>(
        isExpanded: true,
        iconSize: 18,
        iconEnabledColor: LcColors.textSecondary,
        buttonHeight: 40,
        dropdownDecoration: _dropdownDecoration(),
        searchController: _propertySearchCtrl,
        searchInnerWidget: _SearchInner(_propertySearchCtrl),
        hint: AutoSizeText(
          vm.selectedZn == null
              ? 'เลือกโซนก่อน'
              : (vm.selectedLn == null
                  ? 'เลือกรหัสพื้นที่'
                  : vm.selectedLn!.split('|').first),
          style: LcText.input.copyWith(
            color: vm.selectedLn == null
                ? LcColors.textMuted
                : LcColors.textPrimary,
          ),
          maxFontSize: 14,
          minFontSize: 11,
        ),
        value: vm.selectedLn,
        items: vm.filteredAreas.map((area) {
          // ล็อกที่ "มีคนเช่า" → disable
          // ตรวจจาก 2 แหล่ง (ผ่าน vm.isOccupied):
          //   1) area.quantity == '1'  (จาก GC_areaAll.php)
          //   2) area.ser อยู่ใน occupiedAsers (จาก admin/requests/properties)
          final isOccupied = vm.isOccupied(area);
          final lncode = area.lncode ?? '-';
          // ชื่อร้าน: API GC_areaAll ไม่ส่ง sname ของผู้เช่า
          // ต้องดึงจาก PropertiesModel.client.scname หรือ area.cname
          final hasRequest = area.properties.isNotEmpty;
          final firstProp = hasRequest ? area.properties.first : null;
          final firstReq = firstProp?.newRequest;
          final reqStep = firstReq?.requestStep;
          final reqStatus = firstReq?.requestStatus;
          // หาชื่อร้านจากหลายแหล่ง (เรียงตาม priority)
          final sname = (area.cname?.isNotEmpty == true)
              ? area.cname!
              : (firstProp?.client?.scname?.isNotEmpty == true)
                  ? firstProp!.client!.scname!
                  : (area.sname_q?.isNotEmpty == true)
                      ? area.sname_q!
                      : '';

          // ===== 2 บรรทัด =====
          // บรรทัด 1 (หลัก): ล็อก + ชื่อร้าน (ถ้ามี)
          // บรรทัด 2 (รอง): step/status ของ request หรือ "ว่าง"
          String mainLabel;
          String? subLabel;

          if (sname.isNotEmpty) {
            mainLabel = '$lncode • $sname';
          } else {
            mainLabel = lncode;
          }

          if (hasRequest) {
            // มี request → แสดง status (priority 1) หรือ step (priority 2)
            if (reqStatus != null && reqStatus.isNotEmpty) {
              subLabel = reqStatus;
            } else if (reqStep != null && reqStep.isNotEmpty) {
              subLabel = reqStep;
            } else {
              subLabel = 'กำลังดำเนินการ';
            }
          } else if (isOccupied) {
            subLabel = 'มีผู้เช่าแล้ว';
          }

          return DropdownMenuItem<String>(
            value:
                '$lncode|${area.ser ?? ''}|${area.zser ?? ''}|${area.cname ?? ''}',
            enabled: !isOccupied, // ← ปิดล็อกที่มีคนเช่า
            child: _PropertyDropRow(
              mainLabel: mainLabel,
              subLabel: subLabel,
              occupied: isOccupied,
            ),
          );
        }).toList(),
        onChanged: enabled
            ? (v) {
                if (v == null) return;
                vm.onPropertyChanged(v);
              }
            : null,
        searchMatchFn: (item, searchValue) {
          return item.value
              .toString()
              .toLowerCase()
              .contains(searchValue.toLowerCase());
        },
        onMenuStateChange: (isOpen) async {
          if (!isOpen) {
            _propertySearchCtrl.clear();
            return;
          }
          // เมื่อเปิด dropdown → refetch ล็อกทั้งหมด (เหมือน Data_Properties)
          await vm.refreshProperties();
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // Search from registry button
  // ──────────────────────────────────────────────────────────────────
  Widget _searchFromRegistry({required bool enabled}) {
    return _FieldDropdown(
      icon: Icons.search_rounded,
      label: 'ค้นหาจากทะเบียน',
      enabled: enabled,
      child: _RegistryButton(
        enabled: enabled,
        onTap: () => _openCustomerPicker(),
      ),
    );
  }

  /// เปิด CustomerPickerDialog → เมื่อเลือกลูกค้า ให้ auto-fill form
  Future<void> _openCustomerPicker() async {
    final customer = await CustomerPickerDialog.show(context);
    if (customer == null || !mounted) return;

    // Sync กลับ VM — ใช้ helper ที่มีอยู่แล้วใน _autoFillFromProperty
    final vm = context.read<LicenseContractViewModel>();
    vm.applyCustomerFromRegistry(
      custno: customer.custno,
      cname: customer.cname,
      scname: customer.scname,
      tax: customer.tax,
      tel: customer.tel,
      addr1: customer.addr1,
      national: customer.national,
    );
  }

  // ──────────────────────────────────────────────────────────────────
  Widget _hint(String text) => AutoSizeText(
        text,
        style: LcText.input.copyWith(color: LcColors.textMuted),
        maxFontSize: 14,
        minFontSize: 11,
      );
}

// ============================================================================
// Internal widgets
// ============================================================================

/// Field wrapper — icon label + dropdown
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

/// Search box ที่แสดงขณะ dropdown เปิด
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
        cursorColor: LcColors.primary,
        decoration: const InputDecoration(
          isDense: true,
          filled: true,
          fillColor: LcColors.surfaceMuted,
          hintText: 'พิมพ์เพื่อค้นหา...',
          hintStyle: LcText.caption,
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 18,
            color: LcColors.textMuted,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(LcRadius.sm)),
            borderSide: BorderSide(color: LcColors.border, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(LcRadius.sm)),
            borderSide: BorderSide(color: LcColors.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(LcRadius.sm)),
            borderSide: BorderSide(color: LcColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

/// Dropdown item row — มี dot + label
class _DropRow extends StatelessWidget {
  final String label;
  const _DropRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
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
}

/// Dropdown item row สำหรับ "รหัสพื้นที่" — 2 บรรทัด + รองรับสถานะ "มีผู้เช่าแล้ว"
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
    final dotColor = occupied ? LcColors.textMuted : LcColors.primary;
    final mainColor = occupied ? LcColors.textMuted : LcColors.textPrimary;
    final subColor = occupied ? LcColors.textMuted : LcColors.textSecondary;
    return Row(
      children: [
        // dot indicator
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(right: 8, top: 6),
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        // 2-line text (main + sub)
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                mainLabel,
                style: LcText.input.copyWith(
                  color: mainColor,
                  fontWeight: FontWeight.w600,
                ),
                maxFontSize: 14,
                minFontSize: 11,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subLabel != null && subLabel!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: AutoSizeText(
                    subLabel!,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: subColor,
                      fontWeight: FontWeight.w500,
                    ),
                    maxFontSize: 11,
                    minFontSize: 9,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        if (occupied)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: LcColors.surfaceMuted,
              borderRadius: BorderRadius.circular(LcRadius.pill),
              border: Border.all(color: LcColors.border, width: 1),
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
    // ปรับ UI ให้ "พอดี" — เต็มพื้นที่, จัดกลาง, ใช้ icon + text + arrow
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (enabled) setState(() => _hover = true);
      },
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: _down ? 0.97 : (_hover ? 1.02 : 1.0),
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
              border: Border.all(
                color: !enabled
                    ? LcColors.border
                    : (_hover ? LcColors.headerBg : LcColors.headerBg),
                width: 1,
              ),
              boxShadow: !enabled
                  ? []
                  : [
                      BoxShadow(
                        color:
                            LcColors.headerBg.withOpacity(_hover ? .55 : .35),
                        blurRadius: _hover ? 12 : 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 12,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Silence analyzer (Font_/FontWeight_ are kept for parity with old file)
// ignore: unused_element
const _kFontRegular = Font_.Fonts_T;
// ignore: unused_element
const _kFontBold = FontWeight_.Fonts_T;
