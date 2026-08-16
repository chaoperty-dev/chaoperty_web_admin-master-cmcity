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
import '../../../../unity/Enum.dart';
import '../../../../unity/FormatDate.dart';
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

  /// Mask นามสกุล 3 ตัวอักษรท้าย (เหมือน Area_menu's _maskName)
  /// เช่น "นางกชกร วิชชุชัยมงคล" → "นางก�กร วิชชุชัยม***"
  static String _maskName(String raw) {
    final name = raw.trim();
    if (name.isEmpty) return '';
    final words =
        name.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '';
    if (words.length == 1) {
      final w = words.first;
      if (w.length <= 3) return '***';
      return '${w.substring(0, w.length - 3)}***';
    }
    final lastIndex = words.length - 1;
    final last = words[lastIndex];
    if (last.length <= 3) {
      words[lastIndex] = '***';
    } else {
      words[lastIndex] = '${last.substring(0, last.length - 3)}***';
    }
    return words.join(' ');
  }

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
          // จอแคบ (<700px) → stack ทุก field เป็นแนวตั้ง
          if (c.maxWidth < 700) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _subZoneField(context, vm),
                const SizedBox(height: LcSpace.md),
                _zoneField(context, vm),
                const SizedBox(height: LcSpace.md),
                _propertyField(context, vm),
                const SizedBox(height: LcSpace.md),
                _searchFromRegistry(enabled: canSearchRegistry),
              ],
            );
          }
          return Column(
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
          );
        },
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        value: vm.selectedLn,
        items: vm.filteredAreas.map((area) {
          // ล็อกที่ "มีคนเช่า" → disable
          // ตรวจจาก 2 แหล่ง (ผ่าน vm.isOccupied):
          //   1) area.quantity == '1'  (จาก GC_areaAll.php)
          //   2) area.ser อยู่ใน occupiedAsers (จาก admin/requests/properties)
          final isOccupied = vm.isOccupied(area);
          final lncode = area.lncode ?? '-';
          final cid = area.cid ?? '';

          // ===== Title: cid · lncode (เหมือน Area_menu's lease_number · ln) =====
          String title;
          if (cid.isNotEmpty && cid != lncode) {
            title = '$cid · $lncode';
          } else {
            title = lncode;
          }

          final hasRequest = area.properties.isNotEmpty;
          final firstProp = hasRequest ? area.properties.first : null;
          final firstReq = firstProp?.newRequest;
          final firstClient = firstProp?.client;
          // ===== Status text (เหมือน Area_menu's _statusText) =====
          // ถ้า ldate น้อยกว่าวันนี้ → "หมดสัญญา"
          final ldateRaw = area.ldate?.toString() ?? '';
          String statusText;
          if (ldateRaw.isNotEmpty) {
            try {
              final ldate = DateTime.parse(ldateRaw);
              final today = DateTime.now();
              final end = DateTime(ldate.year, ldate.month, ldate.day);
              final now = DateTime(today.year, today.month, today.day);
              if (end.isBefore(now)) {
                statusText = 'หมดสัญญา';
              } else if (hasRequest) {
                statusText = (firstReq?.requestStatus?.isNotEmpty == true)
                    ? firstReq!.requestStatus!
                    : (firstReq?.requestStep?.isNotEmpty == true)
                        ? firstReq!.requestStep!
                        : 'กำลังดำเนินการ';
              } else {
                statusText = area.st?.toString() ?? '';
              }
            } catch (_) {
              statusText = hasRequest
                  ? ((firstReq?.requestStatus?.isNotEmpty == true)
                      ? firstReq!.requestStatus!
                      : (firstReq?.requestStep?.isNotEmpty == true)
                          ? firstReq!.requestStep!
                          : 'กำลังดำเนินการ')
                  : (area.st?.toString() ?? '');
            }
          } else if (hasRequest) {
            statusText = (firstReq?.requestStatus?.isNotEmpty == true)
                ? firstReq!.requestStatus!
                : (firstReq?.requestStep?.isNotEmpty == true)
                    ? firstReq!.requestStep!
                    : 'กำลังดำเนินการ';
          } else {
            statusText = area.st?.toString() ?? '';
          }
          // Default = "ว่าง" (เหมือน Area_menu box_card)
          if (statusText.isEmpty) statusText = 'ว่าง';

          // ===== End date (เหมือน Area_menu's _endDateText) =====
          String? endDateText;
          if (ldateRaw.isNotEmpty) {
            try {
              endDateText = formatDate(ldateRaw, type: DateFormatType.dmy);
            } catch (_) {
              endDateText = ldateRaw;
            }
          }

          // ===== Client name (mask นามสกุล 3 �ัว — เหมือน Area_menu's _clientText) =====
          final rawCname = (area.cname?.isNotEmpty == true)
              ? area.cname!
              : (firstClient?.scname?.isNotEmpty == true)
                  ? firstClient!.scname!
                  : '';
          final clientText = _maskName(rawCname);

          return DropdownMenuItem<String>(
            value:
                '$lncode|${area.ser ?? ''}|${area.zser ?? ''}|${area.cname ?? ''}',
            enabled: !isOccupied, // ← ปิดล็อกที่มีคนเช่า
            child: _PropertyDropRow(
              title: title,
              statusText: statusText,
              endDate: endDateText,
              clientName: clientText,
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

  // ──────────────────────────────────────────────────────────────────
  Widget _hint(String text) => AutoSizeText(
        text,
        style: LcText.input.copyWith(color: LcColors.textMuted),
        maxFontSize: 14,
        minFontSize: 11,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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

/// Dropdown item row — แสดงเหมือน Area_menu box_card
/// title (cid · lncode) + status pill (สีจาก StatusPalette) + end date + client name
class _PropertyDropRow extends StatelessWidget {
  final String title;
  final String statusText;
  final String? endDate;
  final String clientName;
  final bool occupied;
  const _PropertyDropRow({
    required this.title,
    required this.statusText,
    this.endDate,
    this.clientName = '',
    this.occupied = false,
  });

  /// Status → (bg, fg) palette (เหมือน Area_menu's StatusPalette)
  ({Color bg, Color fg}) _statusPalette() {
    final s = statusText.toLowerCase().trim();
    if (s == 'ว่าง' || s == 'vacant' || s == 'empty') {
      return (bg: const Color(0xFFE0F2FE), fg: const Color(0xFF0369A1)); // sky
    }
    if (s == 'หมดสัญญา' || s == 'expired' || s == 'expiry') {
      return (bg: const Color(0xFFFEE2E2), fg: const Color(0xFFB91C1C)); // red
    }
    if (s == 'สัญญาปัจจุบัน' || s == 'current' || s == 'active') {
      return (bg: const Color(0xFFDCFCE7), fg: const Color(0xFF15803D)); // green
    }
    if (s == 'ใก้หมดสัญญา' || s.contains('near expiry') || s.contains('near_expiry')) {
      return (bg: const Color(0xFFFEF9C3), fg: const Color(0xFFA16207)); // yellow
    }
    if (s.contains('ปฏเสธ') || s.contains('reject') || s.contains('cancel') || s.contains('ยกเลิก')) {
      return (bg: const Color(0xFFFEE2E2), fg: const Color(0xFFB91C1C)); // red
    }
    if (s.contains('รอ') || s.contains('pending') || s.contains('progress') || s.contains('กำลัง') || s.contains('ดำเนินการ')) {
      return (bg: const Color(0xFFFEF3C7), fg: const Color(0xFFB45309)); // amber
    }
    if (s.contains('อนุมัติ') || s.contains('approved') || s.contains('ผ่าน') || s.contains('เสร็จ') || s.contains('complete')) {
      return (bg: const Color(0xFFDCFCE7), fg: const Color(0xFF15803D)); // green
    }
    if (occupied) {
      return (bg: const Color(0xFFFFEBEE), fg: const Color(0xFFC62828)); // red soft
    }
    return (bg: const Color(0xFFF1F5F9), fg: const Color(0xFF475569)); // slate
  }

  @override
  Widget build(BuildContext context) {
    final palette = _statusPalette();
    final titleColor = occupied ? LcColors.textMuted : LcColors.textPrimary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(right: 8, top: 6),
          decoration: BoxDecoration(
            color: occupied ? LcColors.textMuted : palette.fg,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                title,
                style: LcText.input.copyWith(
                  color: titleColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                maxFontSize: 13,
                minFontSize: 11,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: palette.bg,
                  borderRadius: BorderRadius.circular(LcRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: palette.fg,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    AutoSizeText(
                      statusText,
                      style: TextStyle(
                        fontFamily: LcText.fontBold,
                        fontSize: 10,
                        color: palette.fg,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .2,
                      ),
                      maxFontSize: 11,
                      minFontSize: 9,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (endDate != null && endDate!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_outlined, size: 11, color: LcColors.textSecondary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: AutoSizeText(
                          'สิ้นสุด $endDate',
                          style: const TextStyle(
                            fontFamily: LcText.fontRegular,
                            fontSize: 10,
                            color: LcColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          maxFontSize: 11,
                          minFontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              if (clientName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_outline, size: 11, color: LcColors.textPrimary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: AutoSizeText(
                          clientName,
                          style: const TextStyle(
                            fontFamily: LcText.fontRegular,
                            fontSize: 10,
                            color: LcColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          maxFontSize: 11,
                          minFontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
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
