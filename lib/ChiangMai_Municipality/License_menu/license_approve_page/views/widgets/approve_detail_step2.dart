// ============================================================================
// approve_detail_step2.dart
// ============================================================================
// Step 2 — Timeline ลำดับขั้นตอนการอนุมัติ (current_round.steps)
// Layout พอร์ตมาจาก submit_approval_detail_step2 (timeline vertical)
// - ข้อมูลจาก GET /v2/admin/approvals/{uuid} → current_round.steps
// - แต่ละ step = card พร้อม status pill, position, uuid
// - read-only (ไม่มี logic สำหรับส่งคำร้องขออนุมัติ)
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/license_approve_detail_step2_view_model.dart';
import '../theme/license_approve_theme.dart';
import '../../models/license_approve_detail_extended.dart';

class ApproveDetailStep2 extends StatefulWidget {
  final String? requestUuid;
  const ApproveDetailStep2({super.key, this.requestUuid});

  @override
  State<ApproveDetailStep2> createState() => _ApproveDetailStep2State();
}

class _ApproveDetailStep2State extends State<ApproveDetailStep2> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.requestUuid != null && widget.requestUuid!.isNotEmpty) {
        context
            .read<LicenseApproveDetailStep2ViewModel>()
            .loadTimeline(widget.requestUuid!);
      }
    });
  }

  @override
  void didUpdateWidget(covariant ApproveDetailStep2 old) {
    super.didUpdateWidget(old);
    if (old.requestUuid != widget.requestUuid &&
        widget.requestUuid != null &&
        widget.requestUuid!.isNotEmpty) {
      context
          .read<LicenseApproveDetailStep2ViewModel>()
          .loadTimeline(widget.requestUuid!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseApproveDetailStep2ViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(LaSpace.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(),
              const SizedBox(height: LaSpace.lg),
              _errorBlock(vm),
              if (vm.isLoading)
                const _TimelineLoading()
              else if (vm.currentSteps.isEmpty)
                const _TimelineEmpty()
              else
                _Timeline(steps: vm.currentSteps, round: vm.currentRound),
              const SizedBox(height: LaSpace.lg),
              const _FooterNote(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorBlock(LicenseApproveDetailStep2ViewModel vm) {
    if (vm.errorMessage == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: LaSpace.md),
      child: Container(
        padding: const EdgeInsets.all(LaSpace.sm),
        decoration: BoxDecoration(
          color: LaColors.statusRejectedBg.withOpacity(.5),
          borderRadius: BorderRadius.circular(LaRadius.md),
          border: Border.all(color: LaColors.statusRejectedFg.withOpacity(.25)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: LaColors.statusRejectedFg, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                vm.errorMessage!,
                style: LaText.caption.copyWith(
                  color: LaColors.statusRejectedFg,
                ),
              ),
            ),
            InkWell(
              onTap: vm.clearError,
              child: const Icon(Icons.close_rounded,
                  size: 16, color: LaColors.statusRejectedFg),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: LaSpace.md, vertical: LaSpace.sm),
      decoration: BoxDecoration(
        color: LaColors.primaryLight.withOpacity(.25),
        borderRadius: BorderRadius.circular(LaRadius.md),
      ),
      child: const Row(
        children: [
          Icon(Icons.timeline_rounded, size: 18, color: LaColors.primaryDark),
          SizedBox(width: 8),
          Text('ลำดับขั้นตอนการอนุมัติ', style: LaText.h2),
        ],
      ),
    );
  }
}

class _FooterNote extends StatelessWidget {
  const _FooterNote();
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.info_outline_rounded, size: 14, color: LaColors.textMuted),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            'ไทม์ไลน์แสดงลำดับขั้นตอนการอนุมัติทั้งหมด — ขั้นปัจจุบันอยู่ด้านบน',
            style: LaText.caption,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Timeline
// ============================================================================

class _Timeline extends StatelessWidget {
  final List<ApprovalStepV2> steps;
  final ApprovalCurrentRound? round;
  const _Timeline({required this.steps, this.round});

  @override
  Widget build(BuildContext context) {
    // เรียงตาม step_order asc (1 → N)
    final sorted = [...steps]
      ..sort((a, b) => (a.stepOrder ?? 0).compareTo(b.stepOrder ?? 0));

    return Column(
      children: [
        // ─── Round summary banner ───
        if (round != null) _RoundSummaryBanner(round: round!),
        if (round != null) const SizedBox(height: LaSpace.md),
        for (int i = 0; i < sorted.length; i++) ...[
          _TimelineItem(step: sorted[i]),
          if (i < sorted.length - 1)
            _TimelineConnector(
              topOrder: sorted[i].stepOrder,
              bottomOrder: sorted[i + 1].stepOrder,
              isCurrentAbove: sorted[i].isCurrent,
            ),
        ],
      ],
    );
  }
}

class _RoundSummaryBanner extends StatelessWidget {
  final ApprovalCurrentRound round;
  const _RoundSummaryBanner({required this.round});

  @override
  Widget build(BuildContext context) {
    final totalSteps = round.steps.length;
    final passedSteps = round.steps
        .where((s) =>
            s.status.toLowerCase() == 'passed' ||
            s.status.toLowerCase() == 'approved')
        .length;

    return Container(
      padding: const EdgeInsets.all(LaSpace.md),
      decoration: BoxDecoration(
        color: LaColors.primaryLight.withOpacity(.35),
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(color: LaColors.primaryDark.withOpacity(.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.folder_open_rounded,
              color: LaColors.primaryDark, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'รอบที่ ${round.round ?? '-'} — ${round.state ?? '-'}',
                  style: LaText.h2.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  'เปิดเมื่อ ${_formatDateTime(round.openedAt)} • '
                  '$passedSteps/$totalSteps ขั้น ผ่านแล้ว',
                  style: LaText.caption,
                ),
              ],
            ),
          ),
          if (round.currentStepOrder != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: LaColors.statusPendingBg,
                borderRadius: BorderRadius.circular(LaRadius.pill),
              ),
              child: Text(
                'กำลังทำขั้นที่ ${round.currentStepOrder}',
                style: TextStyle(
                  color: LaColors.statusPendingFg,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }
}

/// Dashed connector ระหว่าง timeline items
class _TimelineConnector extends StatelessWidget {
  final int? topOrder;
  final int? bottomOrder;
  final bool isCurrentAbove;
  const _TimelineConnector({
    this.topOrder,
    this.bottomOrder,
    this.isCurrentAbove = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 3,
            height: 28,
            child: CustomPaint(painter: _DashedLinePainter()),
          ),
          if (topOrder != null && bottomOrder != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: LaColors.surfaceMuted,
                borderRadius: BorderRadius.circular(LaRadius.pill),
                border: Border.all(color: LaColors.border),
              ),
              child: Text(
                'ขั้น $topOrder → $bottomOrder',
                style: LaText.caption.copyWith(
                  color: LaColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = LaColors.borderStrong
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const dashHeight = 4.0;
    const dashGap = 3.0;
    final cx = size.width / 2;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(
        Offset(cx, y),
        Offset(cx, y + dashHeight),
        paint,
      );
      y += dashHeight + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _TimelineItem extends StatelessWidget {
  final ApprovalStepV2 step;
  const _TimelineItem({required this.step});

  _StyleData _style() {
    final s = step.status.toLowerCase();
    final label = step.statusLabel ?? step.status;
    if (s == 'passed' || s == 'approved' || s.contains('ผ่าน')) {
      return _StyleData(
        bg: LaColors.statusApprovedBg,
        fg: LaColors.statusApprovedFg,
        icon: Icons.check_rounded,
        label: label.isEmpty ? 'ผ่าน' : label,
      );
    } else if (s == 'failed' ||
        s == 'rejected' ||
        s.contains('ไม่ผ่าน')) {
      return _StyleData(
        bg: LaColors.statusRejectedBg,
        fg: LaColors.statusRejectedFg,
        icon: Icons.close_rounded,
        label: label.isEmpty ? 'ไม่ผ่าน' : label,
      );
    } else if (s == 'pending' || s.isEmpty || s.contains('รอ')) {
      return _StyleData(
        bg: LaColors.statusPendingBg,
        fg: LaColors.statusPendingFg,
        icon: Icons.hourglass_top_rounded,
        label: label.isEmpty ? 'รอดำเนินการ' : label,
      );
    } else {
      return _StyleData(
        bg: LaColors.statusInfoBg,
        fg: LaColors.statusInfoFg,
        icon: Icons.assignment_rounded,
        label: label.isEmpty ? '-' : label,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final st = _style();
    final isCurrent = step.isCurrent;
    final isPending =
        step.status.toLowerCase() == 'pending' || step.status.isEmpty;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(LaRadius.md),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(LaRadius.md),
          border: Border.all(
            color: isCurrent ? st.fg.withOpacity(.5) : LaColors.border,
            width: isCurrent ? 1.5 : 1,
          ),
          boxShadow: isCurrent
              ? [
                  BoxShadow(
                    color: st.fg.withOpacity(.15),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Left rail ───
            SizedBox(
              width: 48,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 3,
                      decoration: BoxDecoration(
                        color: st.fg,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(LaRadius.md),
                          bottomLeft: Radius.circular(LaRadius.md),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Center(
                      child: _DotWithPulse(
                        bg: st.bg,
                        fg: st.fg,
                        icon: st.icon,
                        animate: isPending && isCurrent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ─── Right content ───
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    LaSpace.sm, LaSpace.md, LaSpace.md, LaSpace.md),
                child: _Content(step: step, st: st),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotWithPulse extends StatefulWidget {
  final Color bg;
  final Color fg;
  final IconData icon;
  final bool animate;
  const _DotWithPulse({
    required this.bg,
    required this.fg,
    required this.icon,
    required this.animate,
  });

  @override
  State<_DotWithPulse> createState() => _DotWithPulseState();
}

class _DotWithPulseState extends State<_DotWithPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.animate)
                Opacity(
                  opacity: (1 - _ctrl.value).clamp(0.0, 1.0) * 0.6,
                  child: Container(
                    width: 28 + (_ctrl.value * 22),
                    height: 28 + (_ctrl.value * 22),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.fg.withOpacity(.5),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.bg,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: widget.fg.withOpacity(.4), width: 1.5),
                  boxShadow: widget.animate
                      ? [
                          BoxShadow(
                            color: widget.fg.withOpacity(.25),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Icon(widget.icon, color: widget.fg, size: 16),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  final ApprovalStepV2 step;
  final _StyleData st;
  const _Content({required this.step, required this.st});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _titleRow(),
        const SizedBox(height: 4),
        _metaRow(),
        if ((step.remark ?? '').isNotEmpty) ...[
          const SizedBox(height: 6),
          _remarkBox(),
        ],
      ],
    );
  }

  Widget _titleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AutoSizeText(
          'ขั้นที่ ${step.stepOrder ?? '-'}',
          minFontSize: 14,
          maxFontSize: 16,
          style: LaText.h2.copyWith(fontSize: 15),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: st.bg,
            borderRadius: BorderRadius.circular(LaRadius.pill),
          ),
          child: Text(
            st.label,
            style: TextStyle(
              color: st.fg,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
        if (step.isCurrent) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: LaColors.primary.withOpacity(.15),
              borderRadius: BorderRadius.circular(LaRadius.pill),
            ),
            child: const Text(
              'ปัจจุบัน',
              style: TextStyle(
                color: LaColors.primaryDark,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
        const Spacer(),
        if ((step.actedAt ?? '').isNotEmpty)
          Text(
            _formatDate(step.actedAt),
            style: LaText.caption.copyWith(
              color: LaColors.textMuted,
              fontSize: 11,
            ),
          ),
      ],
    );
  }

  Widget _metaRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── step_name ───
        Row(
          children: [
            const Icon(Icons.assignment_rounded,
                size: 12, color: LaColors.textMuted),
            const SizedBox(width: 4),
            Expanded(
              child: AutoSizeText(
                step.stepName,
                minFontSize: 11,
                maxFontSize: 13,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: LaColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // ─── position + uuid ───
        Row(
          children: [
            const Icon(Icons.badge_outlined,
                size: 12, color: LaColors.textMuted),
            const SizedBox(width: 4),
            Expanded(
              child: AutoSizeText(
                step.positionName,
                minFontSize: 10,
                maxFontSize: 12,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LaText.caption.copyWith(
                  color: LaColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.tag_rounded, size: 12, color: LaColors.textMuted),
            const SizedBox(width: 4),
            Text(
              '#${_shortUuid(step.uuid)}',
              style: LaText.caption.copyWith(
                color: LaColors.textMuted,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _remarkBox() {
    final isCollecting = _isCollectingRemark();
    final bgColor = isCollecting
        ? LaColors.statusApprovedBg
        : LaColors.surfaceMuted;
    final accentColor =
        isCollecting ? LaColors.statusApprovedFg : st.fg;
    final textColor =
        isCollecting ? LaColors.statusApprovedFg : LaColors.textSecondary;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(LaRadius.sm),
        border: Border.all(color: accentColor.withOpacity(.35), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 28,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: AutoSizeText(
              step.remark!,
              minFontSize: 11,
              maxFontSize: 12,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: LaText.caption.copyWith(
                color: textColor,
                fontStyle: FontStyle.italic,
                fontWeight:
                    isCollecting ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// remark อยู่ในช่วง "เก็บข้อมูล" → highlight กล่องเป็นสีเขียว
  bool _isCollectingRemark() {
    final r = (step.remark ?? '').toLowerCase();
    if (r.isEmpty) return false;
    return r.contains('start collecting') ||
        r.contains('collecting data') ||
        r.contains('เริ่มเก็บ') ||
        r.contains('กำลังเก็บ');
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  String _shortUuid(String uuid) {
    if (uuid.isEmpty) return '-';
    if (uuid.length <= 8) return uuid;
    return uuid.substring(0, 8);
  }
}

class _StyleData {
  final Color bg;
  final Color fg;
  final IconData icon;
  final String label;
  _StyleData({
    required this.bg,
    required this.fg,
    required this.icon,
    required this.label,
  });
}

// ============================================================================
// Loading / Empty
// ============================================================================

class _TimelineLoading extends StatelessWidget {
  const _TimelineLoading();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LaSpace.xxl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: LaSpace.sm),
          Text('กำลังโหลดลำดับขั้นตอน...', style: LaText.bodyMuted),
        ],
      ),
    );
  }
}

class _TimelineEmpty extends StatelessWidget {
  const _TimelineEmpty();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LaRadius.lg),
        border: Border.all(color: LaColors.border),
      ),
      padding: const EdgeInsets.symmetric(vertical: LaSpace.xxl),
      child: Column(
        children: const [
          Icon(Icons.history_toggle_off_rounded,
              size: 40, color: LaColors.textMuted),
          SizedBox(height: LaSpace.sm),
          Text('ยังไม่มีขั้นตอนการอนุมัติ', style: LaText.bodyMuted),
          SizedBox(height: 4),
          Text(
            'กลับไป Step 1 เพื่อเปิดรอบตรวจ',
            style: LaText.caption,
          ),
        ],
      ),
    );
  }
}
