// ============================================================================
// fact_check_detail_step2.dart
// ============================================================================
// Step 2 — ประวัติการตรวจ (Timeline view)
// แสดง rounds ทั้งหมดเรียงเป็น vertical timeline (ล่าสุด → เก่าสุด)
// ============================================================================

import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../services/license_fact_check_service.dart';
import '../../viewmodels/license_fact_check_detail_view_model.dart';
import '../theme/license_fact_check_theme.dart';

class FactCheckDetailStep2 extends StatelessWidget {
  const FactCheckDetailStep2({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicensefactcheckDetailViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(LaSpace.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(),
              const SizedBox(height: LaSpace.lg),
              if (vm.isLoadingRounds)
                const _TimelineLoading()
              else if (vm.rounds.isEmpty)
                const _TimelineEmpty()
              else
                _Timeline(rounds: vm.rounds),
              const SizedBox(height: LaSpace.lg),
              const _FooterNote(),
            ],
          ),
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
          Text('ประวัติการตรวจ', style: LaText.h2),
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
            'ไทม์ไลน์แสดงลำดับการตรวจทั้งหมด — รอบล่าสุดอยู่ด้านบน',
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
  final List<InspectionRound> rounds;
  const _Timeline({required this.rounds});

  @override
  Widget build(BuildContext context) {
    final sorted = [...rounds]
      ..sort((a, b) => (b.round ?? 0).compareTo(a.round ?? 0));

    return Column(
      children: [
        for (int i = 0; i < sorted.length; i++) ...[
          _TimelineItem(
            round: sorted[i],
            isFirst: i == 0,
            isLast: i == sorted.length - 1,
          ),
          // ─── Dashed connector + date checkpoint ───
          if (i < sorted.length - 1)
            _TimelineConnector(
              topRound: sorted[i],
              bottomRound: sorted[i + 1],
            ),
        ],
      ],
    );
  }
}

/// Dashed connector ระหว่าง items + checkpoint pill
class _TimelineConnector extends StatelessWidget {
  final InspectionRound topRound;
  final InspectionRound bottomRound;
  const _TimelineConnector({
    required this.topRound,
    required this.bottomRound,
  });

  @override
  Widget build(BuildContext context) {
    final timeDiff = _computeTimeGap(
      topRound.createdAt,
      bottomRound.createdAt,
    );

    return Padding(
      padding: const EdgeInsets.only(left: 22), // align with dot center
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ─── Dashed line ───
          SizedBox(
            width: 3,
            height: 28,
            child: CustomPaint(painter: _DashedLinePainter()),
          ),
          // ─── Date checkpoint pill ───
          if (timeDiff != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: LaColors.surfaceMuted,
                borderRadius: BorderRadius.circular(LaRadius.pill),
                border: Border.all(color: LaColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule_rounded,
                      size: 11, color: LaColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    timeDiff,
                    style: LaText.caption.copyWith(
                      color: LaColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? _computeTimeGap(String? top, String? bottom) {
    if (top == null || top.isEmpty || bottom == null || bottom.isEmpty) {
      return null;
    }
    try {
      final t1 = DateTime.parse(top);
      final t2 = DateTime.parse(bottom);
      final diff = t1.difference(t2);
      if (diff.inDays.abs() >= 1) {
        return '${diff.inDays.abs()} วัน';
      } else if (diff.inHours.abs() >= 1) {
        return '${diff.inHours.abs()} ชม.';
      } else if (diff.inMinutes.abs() >= 1) {
        return '${diff.inMinutes.abs()} นาที';
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }
}

/// Painter เส้นประแนวตั้ง
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
  final InspectionRound round;
  final bool isFirst;
  final bool isLast;
  const _TimelineItem({
    required this.round,
    required this.isFirst,
    required this.isLast,
  });

  _StyleData _style() {
    final s = (round.state ?? '').toLowerCase();
    if (s.contains('passed') || s.contains('ผ่าน')) {
      return _StyleData(
        bg: LaColors.statusApprovedBg,
        fg: LaColors.statusApprovedFg,
        icon: Icons.check_rounded,
        label: round.stateLabel ?? round.state ?? 'ผ่าน',
      );
    } else if (s.contains('failed') || s.contains('ไม่ผ่าน')) {
      return _StyleData(
        bg: LaColors.statusRejectedBg,
        fg: LaColors.statusRejectedFg,
        icon: Icons.close_rounded,
        label: round.stateLabel ?? round.state ?? 'ไม่ผ่าน',
      );
    } else if (s.contains('pending') ||
        s.contains('in_review') ||
        s.contains('progress') ||
        s.contains('รอ') ||
        s.isEmpty) {
      return _StyleData(
        bg: LaColors.statusPendingBg,
        fg: LaColors.statusPendingFg,
        icon: Icons.hourglass_top_rounded,
        label: round.stateLabel ?? round.state ?? 'กำลังดำเนินการ',
      );
    } else {
      return _StyleData(
        bg: LaColors.statusInfoBg,
        fg: LaColors.statusInfoFg,
        icon: Icons.assignment_rounded,
        label: round.stateLabel ?? round.state ?? '-',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final st = _style();
    final vm = context.watch<LicensefactcheckDetailViewModel>();
    final images =
        round.uuid != null ? vm.imagesOf(round.uuid!) : <InspectionImage>[];
    final isPending = _isPending();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(LaRadius.md),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(LaRadius.md),
          border: Border.all(
              color: isPending ? st.fg.withOpacity(.4) : LaColors.border,
              width: isPending ? 1.5 : 1),
          boxShadow: isPending
              ? [
                  BoxShadow(
                    color: st.fg.withOpacity(.12),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Left rail (with accent strip + dot) ───
            SizedBox(
              width: 48,
              child: Stack(
                children: [
                  // Accent strip
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
                  // Dot (with pulse for pending)
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Center(
                      child: _DotWithPulse(
                        bg: st.bg,
                        fg: st.fg,
                        icon: st.icon,
                        animate: isPending,
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
                child: _Content(
                  round: round,
                  st: st,
                  images: images,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isPending() {
    final s = (round.state ?? '').toLowerCase();
    return s.contains('pending') ||
        s.contains('in_review') ||
        s.contains('progress') ||
        s.isEmpty;
  }
}

/// Dot + pulse animation (ใช้สำหรับ pending items)
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
              // ─── Pulse ring (เฉพาะ pending) ───
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
              // ─── Solid dot ───
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.bg,
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: widget.fg.withOpacity(.4), width: 1.5),
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
  final InspectionRound round;
  final _StyleData st;
  final List<InspectionImage> images;
  const _Content({
    required this.round,
    required this.st,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _titleRow(),
        const SizedBox(height: 4),
        _metaRow(),
        if ((round.comment ?? '').isNotEmpty) ...[
          const SizedBox(height: 6),
          _commentBox(),
        ],
        if (images.isNotEmpty) ...[
          const SizedBox(height: 8),
          _thumbRow(),
        ],
      ],
    );
  }

  Widget _titleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AutoSizeText(
          'รอบที่ ${round.round ?? '-'}',
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
        const Spacer(),
        Text(
          _formatDate(round.createdAt),
          style: LaText.caption.copyWith(
            color: LaColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _metaRow() {
    return Row(
      children: [
        const Icon(Icons.photo_library_rounded,
            size: 12, color: LaColors.textMuted),
        const SizedBox(width: 4),
        Text(
          '${images.length} รูป',
          style: LaText.caption.copyWith(color: LaColors.textSecondary),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.tag_rounded, size: 12, color: LaColors.textMuted),
        const SizedBox(width: 4),
        Flexible(
          child: AutoSizeText(
            '#${_shortUuid(round.uuid)}',
            minFontSize: 10,
            maxFontSize: 11,
            maxLines: 1,
            style: LaText.caption.copyWith(
              color: LaColors.textMuted,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  Widget _commentBox() {
    // ห้ามใช้ `Border(left: BorderSide(...))` ร่วมกับ `borderRadius` —
    // Flutter บังคับว่า Border ที่มี borderRadius ต้องมี side เดียวกันทุกด้าน
    //
    // ห้ามใช้ IntrinsicHeight + Row(stretch) ใน SingleChildScrollView —
    // LayoutBuilder ที่อยู่ในนั้นไม่รองรับ intrinsic dimensions
    //
    // ใช้แนวทาง: Container นอกกำหนด padding + borderRadius,
    // BoxDecoration ใช้ Border.all(สีอ่อน) แทน แล้ววาง accent strip ด้านซ้าย
    // โดยใช้ Padding เป็น pseudo-column ความสูงเท่ากัน (auto-fit ด้วย border)
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: BoxDecoration(
        color: LaColors.surfaceMuted,
        borderRadius: BorderRadius.circular(LaRadius.sm),
        border: Border.all(color: st.fg.withOpacity(.35), width: 1),
      ),
      child: Row(
        // ไม่ใช้ stretch — children จัดการ height ของตัวเอง
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accent strip (ซ้าย) — เป็น cell อิสระ ไม่ต้อง stretch
          Container(
            width: 3,
            height: 28, // ✅ กำหนดเอง → ไม่ขึ้นกับ parent
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: st.fg,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content
          Expanded(
            child: AutoSizeText(
              round.comment!,
              minFontSize: 11,
              maxFontSize: 12,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: LaText.caption.copyWith(
                color: LaColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumbRow() {
    final shown = images.length > 6 ? images.sublist(0, 6) : images;
    final more = images.length - shown.length;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final img in shown)
          _TimelineThumb(
            inspectionUuid: round.uuid!,
            imageUuid: img.uuid,
          ),
        if (more > 0)
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: LaColors.surfaceMuted,
              borderRadius: BorderRadius.circular(LaRadius.sm),
              border: Border.all(color: LaColors.border),
            ),
            child: Text(
              '+$more',
              style: LaText.caption.copyWith(
                color: LaColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd MMM yyyy HH:mm').format(dt);
    } catch (_) {
      return raw;
    }
  }

  String _shortUuid(String? uuid) {
    if (uuid == null || uuid.isEmpty) return '-';
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

/// Thumbnail แบบ timeline
class _TimelineThumb extends StatefulWidget {
  final String inspectionUuid;
  final String? imageUuid;
  const _TimelineThumb({
    required this.inspectionUuid,
    required this.imageUuid,
  });

  @override
  State<_TimelineThumb> createState() => _TimelineThumbState();
}

class _TimelineThumbState extends State<_TimelineThumb> {
  Uint8List? _bytes;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.imageUuid == null) {
      setState(() {
        _loading = false;
        _failed = true;
      });
      return;
    }
    try {
      final svc = context.read<LicensefactcheckDetailViewModel>().service;
      final bytes = await svc.previewImage(
        widget.imageUuid!,
        inspectionUuid: widget.inspectionUuid,
      );
      if (!mounted) return;
      setState(() {
        _bytes = bytes;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(LaRadius.sm),
      child: Container(
        width: 56,
        height: 56,
        color: LaColors.surfaceMuted,
        child: _loading
            ? const Center(
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                ),
              )
            : _failed || _bytes == null
                ? const Icon(Icons.broken_image_outlined,
                    size: 18, color: LaColors.textMuted)
                : Image.memory(
                    _bytes!,
                    fit: BoxFit.cover,
                    width: 56,
                    height: 56,
                  ),
      ),
    );
  }
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
          Text('กำลังโหลดประวัติ...', style: LaText.bodyMuted),
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
          Text('ยังไม่มีประวัติการตรวจ', style: LaText.bodyMuted),
          SizedBox(height: 4),
          Text(
            'กลับไป Step 1 เพื่อเริ่มรอบแรก',
            style: LaText.caption,
          ),
        ],
      ),
    );
  }
}
