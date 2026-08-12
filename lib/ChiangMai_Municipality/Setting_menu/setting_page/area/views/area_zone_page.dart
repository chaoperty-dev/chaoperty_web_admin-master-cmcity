// ============================================================================
// area_zone_page.dart
// ============================================================================
// Full-page form สำหรับเพิ่มโซน (ไม่ใช้ popup)
// - Step 1: กรอกชื่อโซน + ตรวจสอบ
// - Step 2: ยืนยัน + บันทึก
// รับ AreaViewModel จาก caller โดยตรง (ไม่พึ่ง Provider context เพราะ push
// แบบ MaterialPageRoute ตัด scope)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/area_detail_step_view_model.dart';
import '../viewmodels/area_view_model.dart';
import 'theme/area_theme.dart';

class AreaZonePage extends StatefulWidget {
  /// ViewModel จาก caller — ต้องส่งมา เพราะหน้านี้ถูก push ออกจาก scope เดิม
  final AreaViewModel viewModel;

  const AreaZonePage({super.key, required this.viewModel});

  /// Factory — wrap Provider (Step VM) + ส่ง ViewModel เข้าไป
  static Widget create({
    Key? key,
    required AreaViewModel viewModel,
  }) {
    return ChangeNotifierProvider<AreaDetailStepViewModel>(
      create: (_) => AreaDetailStepViewModel(),
      child: AreaZonePage(viewModel: viewModel),
    );
  }

  @override
  State<AreaZonePage> createState() => _AreaZonePageState();
}

class _AreaZonePageState extends State<AreaZonePage> {
  final _zn = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;

  AreaViewModel get _vm => widget.viewModel;

  @override
  void dispose() {
    _zn.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final ok = await _vm.addZone(zn: _zn.text.trim());
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) Navigator.of(context).pop(true);
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
    final subtitle = step == 1 ? 'กรอกชื่อโซน' : 'ตรวจสอบก่อนบันทึก';

    return Scaffold(
      backgroundColor: AeaColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(subtitle: subtitle, step: step, total: total),
            Expanded(
              child: step == 1 ? _buildStep1() : _buildStep2(),
            ),
            _buildFooter(stepVm, step, total),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({
    required String subtitle,
    required int step,
    required int total,
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
              Icons.layers_outlined,
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
                      'ZONE',
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
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'เพิ่มโซนพื้นที่',
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
    final vm = _vm;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AeaSpace.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AeaSpace.md, vertical: AeaSpace.sm),
                  decoration: BoxDecoration(
                    color: AeaColors.primaryLight.withOpacity(.25),
                    borderRadius: BorderRadius.circular(AeaRadius.md),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 18, color: AeaColors.primaryDark),
                      SizedBox(width: 8),
                      Text('ข้อมูลโซน', style: AeaText.h2),
                    ],
                  ),
                ),
                const SizedBox(height: AeaSpace.md),
                Container(
                  decoration: AeaDecor.card(),
                  padding: const EdgeInsets.all(AeaSpace.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 6),
                        child: Text('ชื่อโซน', style: AeaText.bodyMuted),
                      ),
                      TextFormField(
                        controller: _zn,
                        style: AeaText.body,
                        decoration: InputDecoration(
                          hintText: 'เช่น "ทั้งหมด", "โซน A"',
                          hintStyle: AeaText.bodyMuted
                              .copyWith(color: AeaColors.textMuted),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AeaRadius.sm),
                          ),
                          isDense: true,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'กรุณากรอกชื่อโซน';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AeaSpace.sm),
                      Text(
                        'โซนที่มีอยู่: ${vm.zones.length} โซน',
                        style: AeaText.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AeaSpace.lg),
                const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 14, color: AeaColors.textMuted),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'กรอกชื่อโซนให้ครบถ้วนก่อนกด "ถัดไป"',
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
                    Text('ตรวจสอบข้อมูลโซน', style: AeaText.h2),
                  ],
                ),
                const SizedBox(height: AeaSpace.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 200,
                        child: Text('ชื่อโซน',
                            style: AeaText.bodyMuted
                                .copyWith(fontFamily: AeaText.fontBold)),
                      ),
                      const SizedBox(width: AeaSpace.md),
                      Expanded(
                        child: Text(
                          _zn.text.trim(),
                          style: AeaText.body,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(
    AreaDetailStepViewModel stepVm,
    int step,
    int total,
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
                      if (!_formKey.currentState!.validate()) return;
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
