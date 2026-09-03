// ============================================================================
// area_form_page.dart
// ============================================================================
// Full-page form — เพิ่ม/แก้ไข "Area" (lock) ผ่าน v2 API
// Single-step: กรอกข้อมูล + กดบันทึก
//
// ✅ v2 signature:
//    add    → {zone_ser, lncode, ln, area, rent}
//    edit   → {rent} (partial)
//
// ✅ Zone dropdown reads from vm.zonesOfGroup (cascading จาก group filter)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/area_area_model.dart';
import '../models/area_zone_model.dart';
import '../viewmodels/area_view_model.dart';
import 'theme/area_theme.dart';

enum AreaFormMode { create, edit }

class AreaFormPage extends StatefulWidget {
  final AreaFormMode mode;
  final AreaAreaModel? initial;
  final String? preselectedZoneSer;

  /// ViewModel จาก caller
  final AreaViewModel viewModel;

  const AreaFormPage({
    super.key,
    required this.viewModel,
    this.mode = AreaFormMode.create,
    this.initial,
    this.preselectedZoneSer,
  });

  /// Factory — ส่ง ViewModel เข้าไป (single-step, ไม่ต้อง wrap Provider)
  static Widget create({
    Key? key,
    required AreaViewModel viewModel,
    AreaFormMode mode = AreaFormMode.create,
    AreaAreaModel? initial,
    String? preselectedZoneSer,
  }) {
    return AreaFormPage(
      viewModel: viewModel,
      mode: mode,
      initial: initial,
      preselectedZoneSer: preselectedZoneSer,
    );
  }

  @override
  State<AreaFormPage> createState() => _AreaFormPageState();
}

class _AreaFormPageState extends State<AreaFormPage> {
  AreaViewModel get _vm => widget.viewModel;

  final _formKey = GlobalKey<FormState>();

  // ─── Field controllers ───
  final _ln = TextEditingController();
  final _lncode = TextEditingController();
  final _area = TextEditingController();
  final _rent = TextEditingController();

  String? _zoneSer;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.mode == AreaFormMode.edit && widget.initial != null) {
      final a = widget.initial!;
      _ln.text = a.ln;
      _lncode.text = a.lncode;
      _area.text = a.area;
      _rent.text = a.rent;
      _zoneSer = a.zone.isEmpty || a.zone == '0' ? null : a.zone;
    } else {
      _rent.text = '0';
      _zoneSer = widget.preselectedZoneSer;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ถ้า create mode + zone ยังไม่ได้เลือก → resolve จาก vm.zonesOfGroup
    if (widget.mode == AreaFormMode.create &&
        (_zoneSer == null || _zoneSer == '0')) {
      final zoneOptions =
          _vm.zones.where((z) => z.ser.isNotEmpty && z.ser != '0').toList();
      final pre = widget.preselectedZoneSer;
      String? resolved;
      if (pre != null &&
          pre.isNotEmpty &&
          pre != '0' &&
          zoneOptions.any((z) => z.ser == pre)) {
        resolved = pre;
      } else if (zoneOptions.isNotEmpty) {
        resolved = zoneOptions.first.ser;
      }
      if (resolved != null && resolved != _zoneSer) {
        setState(() {
          _zoneSer = resolved;
        });
      }
    }
  }

  @override
  void dispose() {
    _ln.dispose();
    _lncode.dispose();
    _area.dispose();
    _rent.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = _vm;

    final zones =
        vm.zones.where((z) => z.ser.isNotEmpty && z.ser != '0').toList();
    final fallbackZone =
        (_zoneSer != null && _zoneSer!.isNotEmpty && _zoneSer != '0')
            ? _zoneSer!
            : (zones.isNotEmpty ? zones.first.ser : '');

    if (fallbackZone.isEmpty) {
      _showSnack('กรุณาเลือกโซนก่อน', AeaColors.statusRejectedFg);
      return;
    }

    setState(() => _submitting = true);
    final ok = widget.mode == AreaFormMode.edit
        ? await vm.updateArea(
            ser: widget.initial!.ser,
            rent: _rent.text.trim().isEmpty ? '0' : _rent.text.trim(),
          )
        : await vm.addArea(
            ln: _ln.text.trim(),
            lncode: _lncode.text.trim(),
            area: _area.text.trim(),
            rent: _rent.text.trim().isEmpty ? '0' : _rent.text.trim(),
            zone: fallbackZone,
          );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      Navigator.of(context).pop(true);
    }
  }

  void _showSnack(String message, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AeaRadius.md),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = 'กรอกข้อมูล Area';
    final title =
        widget.mode == AreaFormMode.create ? 'เพิ่ม Area' : 'แก้ไข Area';

    return Scaffold(
      backgroundColor: AeaColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(title: title, subtitle: subtitle),
            Expanded(child: _buildStep1()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AeaColors.headerBg, AeaColors.headerAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AeaColors.primary.withOpacity(.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _IconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'กลับ',
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: AeaSpace.md),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AeaColors.primary.withOpacity(.18),
              borderRadius: BorderRadius.circular(AeaRadius.md),
              border: Border.all(
                color: AeaColors.primaryAccent.withOpacity(.35),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.map_rounded,
              color: AeaColors.primaryAccent,
              size: 22,
            ),
          ),
          const SizedBox(width: AeaSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'AREA',
                  style: AeaText.label.copyWith(
                    color: AeaColors.primaryAccent.withOpacity(.9),
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: AeaText.h1.copyWith(
                    color: AeaColors.textInverse,
                    fontSize: 18,
                  ),
                ),
                Text(
                  subtitle,
                  style: AeaText.caption.copyWith(
                    color: Colors.white.withOpacity(.65),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AeaSpace.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _sectionHeader(
                          'ข้อมูลทั่วไป', Icons.info_outline_rounded),
                      const SizedBox(height: AeaSpace.sm),
                      Row(
                        children: [
                          Expanded(
                            child: _field(
                              _ln,
                              'รหัสพื้นที่ (ln)',
                              required: true,
                            ),
                          ),
                          const SizedBox(width: AeaSpace.sm),
                          Expanded(
                            child: _field(
                              _lncode,
                              'รหัสพื้นที่ (lncode)',
                              required: widget.mode == AreaFormMode.create,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AeaSpace.sm),
                      _field(
                        _area,
                        'ขนาดพื้นที่ (ตร.ม.)',
                        number: true,
                      ),
                      const SizedBox(height: AeaSpace.md),
                      _sectionHeader('โซน', Icons.place_outlined),
                      const SizedBox(height: AeaSpace.sm),
                      _ZoneDropdown(
                        zones: _vm.zones,
                        value: _zoneSer,
                        enabled: widget.mode == AreaFormMode.create,
                        onChanged: widget.mode == AreaFormMode.create
                            ? (v) => setState(() => _zoneSer = v)
                            : null,
                      ),
                      const SizedBox(height: AeaSpace.md),
                      _sectionHeader('ค่าบริการ', Icons.payments_outlined),
                      const SizedBox(height: AeaSpace.sm),
                      _field(
                        _rent,
                        'ค่าเช่า (บาท/งวด)',
                        number: true,
                        required: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        _buildFooter(),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AeaSpace.lg, vertical: AeaSpace.md),
      decoration: const BoxDecoration(
        color: AeaColors.surfaceMuted,
        border: Border(
          top: BorderSide(color: AeaColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          const Spacer(),
          _FooterButton(
            label: 'ยกเลิก',
            icon: Icons.close_rounded,
            onTap: () => Navigator.of(context).maybePop(),
            isPrimary: false,
          ),
          const SizedBox(width: AeaSpace.sm),
          _FooterButton(
            label: 'บันทึก',
            icon: Icons.check_circle_rounded,
            onTap: _submitting ? null : _onSave,
            isPrimary: true,
            loading: _submitting,
          ),
        ],
      ),
    );
  }

  // ───────── helpers ─────────

  Widget _sectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AeaSpace.md, vertical: AeaSpace.sm),
      decoration: BoxDecoration(
        color: AeaColors.primaryLight.withOpacity(.25),
        borderRadius: BorderRadius.circular(AeaRadius.md),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AeaColors.primaryDark),
          const SizedBox(width: 8),
          Text(title, style: AeaText.h2),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    bool required = false,
    bool number = false,
  }) {
    return TextFormField(
      controller: c,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      inputFormatters: number
          ? <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ]
          : null,
      style: AeaText.body,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AeaRadius.sm),
        ),
        isDense: true,
      ),
      validator: required
          ? (v) {
              if (v == null || v.trim().isEmpty) {
                return 'กรอก$label';
              }
              return null;
            }
          : null,
    );
  }
}

// ============================================================================
// Zone dropdown (read from vm.zonesOfGroup)
// ============================================================================
class _ZoneDropdown extends StatelessWidget {
  final List<AreaZoneModel> zones;
  final String? value;
  final bool enabled;
  final ValueChanged<String?>? onChanged;

  const _ZoneDropdown({
    required this.zones,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = zones
        .where((z) => z.ser.isNotEmpty && z.ser != '0')
        .map((z) => DropdownMenuItem<String>(
              value: z.ser,
              child: Text(
                z.zn.isEmpty ? z.ser : z.zn,
                style: AeaText.body,
                overflow: TextOverflow.ellipsis,
              ),
            ))
        .toList();

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AeaColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AeaRadius.sm),
          border: Border.all(color: AeaColors.border),
        ),
        child: Row(
          children: const [
            Icon(Icons.info_outline_rounded,
                size: 16, color: AeaColors.textMuted),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'ยังไม่มีโซน — กรุณาเลือกหมวดและเพิ่มโซนก่อน',
                style: AeaText.bodyMuted,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : AeaColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AeaRadius.sm),
        border: Border.all(color: AeaColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.any((it) => it.value == value) ? value : null,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AeaColors.textSecondary,
          ),
          items: items,
          onChanged: enabled ? onChanged : null,
        ),
      ),
    );
  }
}

class _IconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _IconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_IconButton> createState() => _IconButtonState();
}

class _IconButtonState extends State<_IconButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _hover
                  ? Colors.white.withOpacity(.18)
                  : Colors.white.withOpacity(.08),
              borderRadius: BorderRadius.circular(AeaRadius.sm),
              border: Border.all(
                color: Colors.white.withOpacity(.20),
                width: 1,
              ),
            ),
            child: Icon(widget.icon, size: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _FooterButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool loading;
  const _FooterButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isPrimary,
    this.loading = false,
  });

  @override
  State<_FooterButton> createState() => _FooterButtonState();
}

class _FooterButtonState extends State<_FooterButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final active = widget.onTap != null && !widget.loading;
    if (widget.isPrimary) {
      return MouseRegion(
        cursor: active ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _hover
                    ? [AeaColors.primaryDark, AeaColors.primary]
                    : [AeaColors.primary, AeaColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(AeaRadius.md),
              boxShadow: [
                BoxShadow(
                  color: AeaColors.primary.withOpacity(_hover ? .35 : .25),
                  blurRadius: _hover ? 12 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.loading)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  Icon(widget.icon, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: AeaText.fontBold,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _hover ? AeaColors.statusRejectedBg : Colors.white,
            borderRadius: BorderRadius.circular(AeaRadius.md),
            border: Border.all(
              color:
                  _hover ? AeaColors.statusRejectedFg : AeaColors.borderStrong,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: _hover
                    ? AeaColors.statusRejectedFg
                    : AeaColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: _hover
                      ? AeaColors.statusRejectedFg
                      : AeaColors.textSecondary,
                  fontFamily: AeaText.fontBold,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
