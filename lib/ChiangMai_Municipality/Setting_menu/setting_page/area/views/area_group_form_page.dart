// ============================================================================
// area_group_form_page.dart
// ============================================================================
// Full-page form — เพิ่ม/แก้ไข "หมวดโซน" (group) ผ่าน v2 API
// - 2-step wizard (กรอก → ตรวจสอบ → บันทึก)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/area_zone_model.dart';
import '../viewmodels/area_detail_step_view_model.dart';
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
    return ChangeNotifierProvider<AreaDetailStepViewModel>(
      create: (_) => AreaDetailStepViewModel(),
      child: AreaGroupFormPage(
        viewModel: viewModel,
        mode: initial == null ? AreaGroupFormMode.create : AreaGroupFormMode.edit,
        initial: initial,
      ),
    );
  }

  @override
  State<AreaGroupFormPage> createState() => _AreaGroupFormPageState();
}

class _AreaGroupFormPageState extends State<AreaGroupFormPage> {
  final _zn = TextEditingController();
  final _qty = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;

  AreaViewModel get _vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    if (init != null) {
      _zn.text = init.zn;
      _qty.text = init.qty == '0' ? '' : init.qty;
    }
  }

  @override
  void dispose() {
    _zn.dispose();
    _qty.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final qty = int.tryParse(_qty.text.trim()) ?? 0;
    final ok = widget.mode == AreaGroupFormMode.edit
        ? await _vm.updateGroup(
            ser: widget.initial!.ser,
            zn: _zn.text.trim(),
            qty: qty,
          )
        : await _vm.addGroup(zn: _zn.text.trim(), qty: qty);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final stepVm = context.watch<AreaDetailStepViewModel>();
    final step = stepVm.currentDetailStep;
    final total = stepVm.totalDetailSteps;
    final isEdit = widget.mode == AreaGroupFormMode.edit;
    final title = isEdit ? 'แก้ไขหมวดโซน' : 'เพิ่มหมวดโซน';

    return Scaffold(
      backgroundColor: AeaColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(title: title, step: step, total: total),
            Expanded(child: step == 1 ? _buildStep1() : _buildStep2()),
            _Footer(
              stepVm: stepVm,
              step: step,
              total: total,
              submitting: _submitting,
              onSave: _onSave,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
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
                  const SizedBox(height: AeaSpace.lg),
                  const _Label('จำนวนโซน (ไม่บังคับ)'),
                  TextFormField(
                    controller: _qty,
                    style: AeaText.body,
                    keyboardType: TextInputType.number,
                    decoration: _inputDeco(hint: 'เช่น 5'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      if (int.tryParse(v.trim()) == null) {
                        return 'กรุณากรอกตัวเลข';
                      }
                      return null;
                    },
                  ),
                ],
              ),
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
          constraints: const BoxConstraints(maxWidth: 700),
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
                    const Text('ตรวจสอบข้อมูล', style: AeaText.h2),
                  ],
                ),
                const SizedBox(height: AeaSpace.lg),
                _ReviewRow(label: 'ชื่อหมวดโซน', value: _zn.text.trim()),
                _ReviewRow(
                  label: 'จำนวนโซน',
                  value: _qty.text.trim().isEmpty ? '-' : _qty.text.trim(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---- helpers --------------------------------------------------------------

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

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReviewRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              label,
              style: AeaText.bodyMuted.copyWith(fontFamily: AeaText.fontBold),
            ),
          ),
          const SizedBox(width: AeaSpace.md),
          Expanded(child: Text(value, style: AeaText.body)),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final int step;
  final int total;
  const _Header({required this.title, required this.step, required this.total});
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
                Row(
                  children: [
                    Text(
                      'GROUP',
                      style: AeaText.label.copyWith(
                        color: AeaColors.primaryAccent.withOpacity(.9),
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(width: AeaSpace.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.10),
                        borderRadius: BorderRadius.circular(AeaRadius.pill),
                        border: Border.all(color: Colors.white.withOpacity(.18)),
                      ),
                      child: Text(
                        'ขั้นตอนที่ $step/$total',
                        style: AeaText.caption.copyWith(
                          color: Colors.white,
                          fontFamily: AeaText.fontBold,
                          fontSize: 10,
                        ),
                      ),
                    ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final AreaDetailStepViewModel stepVm;
  final int step;
  final int total;
  final bool submitting;
  final VoidCallback onSave;

  const _Footer({
    required this.stepVm,
    required this.step,
    required this.total,
    required this.submitting,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = step >= total;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AeaSpace.lg, vertical: AeaSpace.md),
      decoration: const BoxDecoration(
        color: AeaColors.surfaceMuted,
        border: Border(top: BorderSide(color: AeaColors.border, width: 1)),
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
          _FooterBtn(
            label: step > 1 ? 'ย้อนกลับ' : 'ยกเลิก',
            icon: step > 1 ? Icons.arrow_back_rounded : Icons.close_rounded,
            primary: false,
            onTap: () {
              if (step > 1) {
                stepVm.previousDetailStep();
              } else {
                Navigator.of(context).maybePop();
              }
            },
          ),
          const SizedBox(width: AeaSpace.sm),
          _FooterBtn(
            label: isLast ? 'บันทึก' : 'ถัดไป',
            icon: isLast
                ? Icons.check_circle_rounded
                : Icons.arrow_forward_rounded,
            primary: true,
            loading: submitting,
            onTap: () {
              if (!isLast) {
                stepVm.nextDetailStep();
              } else {
                onSave();
              }
            },
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