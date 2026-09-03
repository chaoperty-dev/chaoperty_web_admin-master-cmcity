// ============================================================================
// area_group_form_page.dart
// ============================================================================
// Full-page form — เพิ่ม/แก้ไข "หมวดโซน" (group) ผ่าน v2 API
// Single-step: กรอกข้อมูล + กดบันทึก
// ============================================================================

import 'package:flutter/material.dart';

import '../models/area_zone_model.dart';
import '../viewmodels/area_view_model.dart';
import 'theme/area_theme.dart';

enum AreaGroupFormMode { create, edit }

class AreaGroupFormPage extends StatefulWidget {
  final AreaViewModel viewModel;
  final AreaGroupFormMode mode;
  final AreaZoneModel? initial;

  const AreaGroupFormPage({
    super.key,
    required this.viewModel,
    required this.mode,
    this.initial,
  });

  static Widget create({
    Key? key,
    required AreaViewModel viewModel,
    AreaZoneModel? initial,
  }) {
    return AreaGroupFormPage(
      viewModel: viewModel,
      mode: initial == null ? AreaGroupFormMode.create : AreaGroupFormMode.edit,
      initial: initial,
    );
  }

  @override
  State<AreaGroupFormPage> createState() => _AreaGroupFormPageState();
}

class _AreaGroupFormPageState extends State<AreaGroupFormPage> {
  final _zn = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;

  AreaViewModel get _vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    if (init != null) {
      _zn.text = init.zn;
    }
  }

  @override
  void dispose() {
    _zn.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    // ✅ backend API จัดการจำนวนเอง — ไม่ส่ง qty
    final ok = widget.mode == AreaGroupFormMode.edit
        ? await _vm.updateGroup(
            ser: widget.initial!.ser,
            zn: _zn.text.trim(),
          )
        : await _vm.addGroup(zn: _zn.text.trim());
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.mode == AreaGroupFormMode.edit;
    final title = isEdit ? 'แก้ไขหมวดโซน' : 'เพิ่มหมวดโซน';

    return Scaffold(
      backgroundColor: AeaColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(title: title),
            Expanded(child: _buildForm()),
            _Footer(
              submitting: _submitting,
              onSave: _onSave,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AeaSpace.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Form(
                  key: _formKey,
                  child: Container(
                    decoration: AeaDecor.card(),
                    padding: const EdgeInsets.all(AeaSpace.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionHeader(
                          icon: Icons.layers_outlined,
                          label: 'ข้อมูลหมวดโซน',
                        ),
                        const SizedBox(height: AeaSpace.lg),
                        const _Label('ชื่อหมวดโซน', required: true),
                        TextFormField(
                          controller: _zn,
                          style: AeaText.body,
                          decoration: _inputDeco(
                            hint: 'เช่น "อาคาร A", "ถนนสุเทพ"',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'กรุณากรอกชื่อหมวดโซน';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AeaSpace.sm),
                        const Text(
                          'ตั้งชื่อหมวดให้จำง่าย — ควรตั้งตามชื่ออาคาร ถนน หรือโซนที่ตั้ง',
                          style: AeaText.caption,
                        ),
                        if (widget.initial != null) ...[
                          const SizedBox(height: AeaSpace.lg),
                          Container(
                            padding: const EdgeInsets.all(AeaSpace.md),
                            decoration: BoxDecoration(
                              color: AeaColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(AeaRadius.sm),
                              border: Border.all(color: AeaColors.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.history_rounded,
                                    size: 16, color: AeaColors.textSecondary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'อัปเดตล่าสุด: ${_formatDateTime(widget.initial!.dataUpdate)}',
                                    style: AeaText.caption,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---- helpers --------------------------------------------------------------

/// Format data_update ("2026-09-02 15:09:39" or "2026-09-02") → "02/09/2569 15:09"
String _formatDateTime(String raw) {
  if (raw.isEmpty) return '-';
  // Try to parse as DateTime — accept both date+time and date-only
  DateTime? dt = DateTime.tryParse(raw);
  if (dt == null) {
    // Try date-only fallback (e.g. "2026-01-13")
    final parts = raw.split(' ');
    dt = DateTime.tryParse(parts.first);
  }
  if (dt == null) return raw;
  // Convert to Buddhist year (พ.ศ. = ค.ศ. + 543)
  final buddhistYear = dt.year + 543;
  final dd = dt.day.toString().padLeft(2, '0');
  final mm = dt.month.toString().padLeft(2, '0');
  final hh = dt.hour.toString().padLeft(2, '0');
  final min = dt.minute.toString().padLeft(2, '0');
  if (dt.hour == 0 && dt.minute == 0 && dt.second == 0) {
    return '$dd/$mm/$buddhistYear';
  }
  return '$dd/$mm/$buddhistYear $hh:$min';
}

InputDecoration _inputDeco({required String hint}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: AeaText.bodyMuted.copyWith(color: AeaColors.textMuted),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AeaRadius.sm),
    ),
    isDense: true,
  );
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionHeader({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
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
          Text(label, style: AeaText.h2),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final bool required;
  const _Label(this.text, {this.required = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text.rich(
        TextSpan(
          text: text,
          style: AeaText.bodyMuted,
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: AeaColors.statusRejectedFg),
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  const _Header({required this.title});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AeaColors.headerBg, AeaColors.headerAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          _IconBtn(
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
              ),
            ),
            child: const Icon(
              Icons.layers_outlined,
              color: AeaColors.primaryAccent,
              size: 22,
            ),
          ),
          const SizedBox(width: AeaSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GROUP',
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final bool submitting;
  final VoidCallback onSave;

  const _Footer({
    required this.submitting,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AeaSpace.lg, vertical: AeaSpace.md),
      decoration: const BoxDecoration(
        color: AeaColors.surfaceMuted,
        border: Border(top: BorderSide(color: AeaColors.border, width: 1)),
      ),
      child: Row(
        children: [
          const Spacer(),
          _FooterBtn(
            label: 'ยกเลิก',
            icon: Icons.close_rounded,
            primary: false,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: AeaSpace.sm),
          _FooterBtn(
            label: 'บันทึก',
            icon: Icons.check_circle_rounded,
            primary: true,
            loading: submitting,
            onTap: submitting ? null : onSave,
          ),
        ],
      ),
    );
  }
}

class _FooterBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool primary;
  final bool loading;
  final VoidCallback? onTap;
  const _FooterBtn({
    required this.label,
    required this.icon,
    required this.primary,
    this.loading = false,
    required this.onTap,
  });
  @override
  State<_FooterBtn> createState() => _FooterBtnState();
}

class _FooterBtnState extends State<_FooterBtn> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final active = widget.onTap != null && !widget.loading;
    if (widget.primary) {
      return MouseRegion(
        cursor: active ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
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
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _hover ? AeaColors.statusRejectedBg : Colors.white,
            borderRadius: BorderRadius.circular(AeaRadius.md),
            border: Border.all(
              color: _hover
                  ? AeaColors.statusRejectedFg
                  : AeaColors.borderStrong,
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

class _IconBtn extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _IconBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });
  @override
  State<_IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<_IconBtn> {
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
              border: Border.all(color: Colors.white.withOpacity(.20)),
            ),
            child: Icon(widget.icon, size: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}