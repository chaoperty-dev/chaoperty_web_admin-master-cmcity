// ============================================================================
// area_form_page.dart
// ============================================================================
// Full-page form สำหรับเพิ่ม Area (ไม่ใช้ popup — เปิดเต็มจอแบบ license_payment)
// - Step 1: กรอกข้อมูล (ln, sn, sname, sw, lncode, area, rent, rent_maket, zone, type)
// - Step 2: ตรวจสอบ + บันทึก
// รับ AreaViewModel จาก caller โดยตรง (push ผ่าน MaterialPageRoute ตัด scope)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/area_area_model.dart';
import '../viewmodels/area_detail_step_view_model.dart';
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

  /// Factory — wrap Provider (Step VM) + ส่ง ViewModel เข้าไป
  static Widget create({
    Key? key,
    required AreaViewModel viewModel,
    AreaFormMode mode = AreaFormMode.create,
    AreaAreaModel? initial,
    String? preselectedZoneSer,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AreaDetailStepViewModel>(
          create: (_) => AreaDetailStepViewModel(),
        ),
      ],
      child: AreaFormPage(
        viewModel: viewModel,
        mode: mode,
        initial: initial,
        preselectedZoneSer: preselectedZoneSer,
      ),
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
  final _sn = TextEditingController();
  final _sname = TextEditingController();
  final _sw = TextEditingController();
  final _lncode = TextEditingController();
  final _area = TextEditingController();
  final _rent = TextEditingController();
  final _rentMaket = TextEditingController();

  String? _zone;
  String? _typeId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.mode == AreaFormMode.edit && widget.initial != null) {
      final a = widget.initial!;
      _ln.text = a.ln;
      _sn.text = a.sn;
      _sname.text = a.sname;
      _sw.text = a.sw;
      _lncode.text = a.lncode;
      _area.text = a.area;
      _rent.text = a.rent;
      _rentMaket.text = a.rentMaket;
      _zone = a.zone.isEmpty || a.zone == '0' ? null : a.zone;
      _typeId = a.typeId.isEmpty ? null : a.typeId;
    } else {
      _rent.text = '0';
      _rentMaket.text = '0';
      // ใช้ preselectedZoneSer ถ้ามี
      _zone = widget.preselectedZoneSer;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ถ้า create mode + zones โหลดเสร็จแล้ว → resolve _zone
    if (widget.mode == AreaFormMode.create && (_zone == null || _zone == '0')) {
      final vm = _vm;
      final zoneOptions = vm.zones.where((z) => z.zn != 'ทั้งหมด').toList();
      final pre = widget.preselectedZoneSer;
      String? resolved;
      if (pre != null &&
          pre.isNotEmpty &&
          pre != '0' &&
          zoneOptions.any((z) => z.ser == pre)) {
        resolved = pre;
      } else if (zoneOptions.isNotEmpty && zoneOptions.first.ser != '0') {
        resolved = zoneOptions.first.ser;
      }
      if (resolved != null && resolved != _zone) {
        // synchronous update ผ่าน setState ภายใน frame ถัดไป
        _zone = resolved;
      }
    }
  }

  @override
  void dispose() {
    _ln.dispose();
    _sn.dispose();
    _sname.dispose();
    _sw.dispose();
    _lncode.dispose();
    _area.dispose();
    _rent.dispose();
    _rentMaket.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    // validate step 1
    if (!_formKey.currentState!.validate()) return;
    final vm = _vm;
    // ถ้าไม่มี zone เลย → fallback ไปโซนแรกที่มี หรือ "0"
    final zones = vm.zones.where((z) => z.zn != 'ทั้งหมด').toList();
    final fallbackZone = (_zone != null && _zone!.isNotEmpty && _zone != '0')
        ? _zone!
        : (zones.isNotEmpty ? zones.first.ser : '0');

    setState(() => _submitting = true);
    final ok = widget.mode == AreaFormMode.edit
        ? await vm.updateArea(
            ser: widget.initial!.ser,
            ln: _ln.text.trim(),
            sname: _sname.text.trim(),
            area: _area.text.trim(),
            rent: _rent.text.trim().isEmpty ? '0' : _rent.text.trim(),
            zone: fallbackZone,
            typeId: _typeId ?? '',
            lncode: _lncode.text.trim(),
            sw: _sw.text.trim(),
            rentMaket:
                _rentMaket.text.trim().isEmpty ? '0' : _rentMaket.text.trim(),
          )
        : await vm.addArea(
            ln: _ln.text.trim(),
            sn: _sn.text.trim(),
            sname: _sname.text.trim(),
            sw: _sw.text.trim(),
            lncode: _lncode.text.trim(),
            area: _area.text.trim(),
            rent: _rent.text.trim().isEmpty ? '0' : _rent.text.trim(),
            rentMaket:
                _rentMaket.text.trim().isEmpty ? '0' : _rentMaket.text.trim(),
            zone: fallbackZone,
            typeId: _typeId ?? '',
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
    final stepVm = context.watch<AreaDetailStepViewModel>();
    final step = stepVm.currentDetailStep;
    final total = stepVm.totalDetailSteps;
    final subtitle = step == 1 ? 'กรอกข้อมูล Area' : 'ตรวจสอบข้อมูลก่อนบันทึก';
    final title =
        widget.mode == AreaFormMode.create ? 'เพิ่ม Area' : 'แก้ไข Area';

    return Scaffold(
      backgroundColor: AeaColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(title: title, subtitle: subtitle, step: step),
            Expanded(
              child: step == 1 ? _buildStep1() : _buildStep2(),
            ),
            _buildFooter(stepVm, step, total, title),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({
    required String title,
    required String subtitle,
    required int step,
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
                Row(
                  children: [
                    Text(
                      'AREA',
                      style: AeaText.label.copyWith(
                        color: AeaColors.primaryAccent.withOpacity(.9),
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(width: AeaSpace.sm),
                    _StepBadge(step: step, total: 2),
                  ],
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AeaSpace.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionHeader('ข้อมูลทั่วไป', Icons.info_outline_rounded),
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
                      child:
                          _field(_sname, 'ชื่อ Area (sname)', required: true),
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
                _sectionHeader('ค่าบริการ', Icons.payments_outlined),
                const SizedBox(height: AeaSpace.sm),
                _field(
                  _rent,
                  'ค่าบริการหลัก (ต่องวด)',
                  number: true,
                ),
                const SizedBox(height: AeaSpace.lg),
                const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 14, color: AeaColors.textMuted),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'กรอกข้อมูลให้ครบถ้วนก่อนกด "ถัดไป"',
                        style: AeaText.caption,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AeaSpace.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Container(
            decoration: AeaDecor.card(),
            padding: const EdgeInsets.all(AeaSpace.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AeaColors.primaryLight,
                        borderRadius: BorderRadius.circular(AeaRadius.sm),
                      ),
                      child: const Icon(
                        Icons.preview_rounded,
                        color: AeaColors.primaryDark,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AeaSpace.sm),
                    Text('ตรวจสอบข้อมูล Area', style: AeaText.h2),
                  ],
                ),
                const SizedBox(height: AeaSpace.lg),
                _reviewRow('รหัสพื้นที่ (ln)', _ln.text),
                _reviewRow('รหัสพื้นที่ (ln)', _ln.text),
                _reviewRow('ชื่อ Area', _sname.text),
                _reviewRow('ขนาดพื้นที่ (ตร.ม.)', _area.text),
                _reviewRow('ค่าบริการหลัก (ต่องวด)', _rent.text),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // unused helpers removed — _zoneName/_typeName no longer needed
  // since the form no longer shows โซน/ประเภท dropdowns

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(label,
                style:
                    AeaText.bodyMuted.copyWith(fontFamily: AeaText.fontBold)),
          ),
          const SizedBox(width: AeaSpace.md),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: AeaText.body,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(
    AreaDetailStepViewModel stepVm,
    int step,
    int total,
    String title,
  ) {
    final isLast = step >= total;
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
          Icon(
            isLast ? Icons.task_alt_rounded : Icons.edit_note_rounded,
            size: 14,
            color: AeaColors.textMuted,
          ),
          const SizedBox(width: 6),
          Text(
            isLast ? 'พร้อมบันทึก' : 'กรอกข้อมูลให้ครบถ้วนก่อนกดถัดไป',
            style: AeaText.caption,
          ),
          const Spacer(),
          _FooterButton(
            label: step > 1 ? 'ย้อนกลับ' : 'ยกเลิก',
            icon: step > 1 ? Icons.arrow_back_rounded : Icons.close_rounded,
            onTap: () {
              if (step > 1) {
                stepVm.previousDetailStep();
              } else {
                Navigator.of(context).maybePop();
              }
            },
            isPrimary: false,
          ),
          const SizedBox(width: AeaSpace.sm),
          _FooterButton(
            label: isLast ? 'บันทึก' : 'ถัดไป',
            icon: isLast
                ? Icons.check_circle_rounded
                : Icons.arrow_forward_rounded,
            onTap: _submitting
                ? null
                : () {
                    if (!isLast) {
                      stepVm.nextDetailStep();
                    } else {
                      _onSave();
                    }
                  },
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

class _StepBadge extends StatelessWidget {
  final int step;
  final int total;
  const _StepBadge({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.10),
        borderRadius: BorderRadius.circular(AeaRadius.pill),
        border: Border.all(
          color: Colors.white.withOpacity(.18),
          width: 1,
        ),
      ),
      child: Text(
        'ขั้นตอนที่ $step/$total',
        style: AeaText.caption.copyWith(
          color: Colors.white,
          fontFamily: AeaText.fontBold,
          fontSize: 10,
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
