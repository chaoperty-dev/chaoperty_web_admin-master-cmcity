import 'package:flutter/material.dart';

import '../../models/tenant_permit_models.dart';
import '../theme/tenant_license_theme.dart';

/// Step 3 — ประวัติการอนุมัติ (read-only)
/// UI structure copied from submit_approval_detail_step2.dart.
class TenantLicenseDetailStep2 extends StatelessWidget {
  final TenantPermitDetail permit;

  const TenantLicenseDetailStep2({super.key, required this.permit});

  @override
  Widget build(BuildContext context) {
    final approvals = [...permit.approvals]
      ..sort((a, b) => _sequence(a).compareTo(_sequence(b)));

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
              if (approvals.isEmpty)
                const _TimelineEmpty()
              else
                _Timeline(approvals: approvals),
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
        horizontal: LaSpace.md,
        vertical: LaSpace.sm,
      ),
      decoration: BoxDecoration(
        color: LaColors.primaryLight.withOpacity(.25),
        borderRadius: BorderRadius.circular(LaRadius.md),
      ),
      child: const Row(
        children: [
          Icon(Icons.timeline_rounded, size: 18, color: LaColors.primaryDark),
          SizedBox(width: 8),
          Text('ประวัติการอนุมัติ', style: LaText.h2),
        ],
      ),
    );
  }

  static int _sequence(Map<String, dynamic> approval) =>
      int.tryParse('${approval['flows_sequence'] ?? 0}') ?? 0;
}

class _Timeline extends StatelessWidget {
  final List<Map<String, dynamic>> approvals;

  const _Timeline({required this.approvals});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < approvals.length; i++) ...[
          _TimelineItem(approval: approvals[i]),
          if (i < approvals.length - 1)
            _TimelineConnector(
              topOrder: _sequence(approvals[i]),
              bottomOrder: _sequence(approvals[i + 1]),
            ),
        ],
      ],
    );
  }

  static int _sequence(Map<String, dynamic> approval) =>
      int.tryParse('${approval['flows_sequence'] ?? 0}') ?? 0;
}

class _TimelineConnector extends StatelessWidget {
  final int topOrder;
  final int bottomOrder;

  const _TimelineConnector({required this.topOrder, required this.bottomOrder});

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
    final centerX = size.width / 2;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(
          Offset(centerX, y), Offset(centerX, y + dashHeight), paint);
      y += dashHeight + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TimelineItem extends StatelessWidget {
  final Map<String, dynamic> approval;

  const _TimelineItem({required this.approval});

  _StyleData _style() {
    final status = (approval['status']?.toString() ?? '').toLowerCase();
    final label = _statusLabel(status);
    if (status == 'approved' || status == 'passed' || status.contains('ผ่าน')) {
      return _StyleData(
        bg: LaColors.statusApprovedBg,
        fg: LaColors.statusApprovedFg,
        icon: Icons.check_rounded,
        label: label,
      );
    }
    if (status == 'rejected' ||
        status == 'failed' ||
        status.contains('ไม่ผ่าน')) {
      return _StyleData(
        bg: LaColors.statusRejectedBg,
        fg: LaColors.statusRejectedFg,
        icon: Icons.close_rounded,
        label: label,
      );
    }
    return _StyleData(
      bg: LaColors.statusPendingBg,
      fg: LaColors.statusPendingFg,
      icon: Icons.hourglass_top_rounded,
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _style();
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(LaRadius.md),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(LaRadius.md),
          border: Border.all(color: LaColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        color: style.fg,
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
                      child: Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: style.bg,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: style.fg.withOpacity(.4), width: 1.5),
                        ),
                        child: Icon(style.icon, color: style.fg, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  LaSpace.sm,
                  LaSpace.md,
                  LaSpace.md,
                  LaSpace.md,
                ),
                child: _Content(approval: approval, style: style),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _statusLabel(String status) {
    if (status == 'approved' || status == 'passed' || status.contains('ผ่าน')) {
      return 'ผ่าน';
    }
    if (status == 'rejected' ||
        status == 'failed' ||
        status.contains('ไม่ผ่าน')) {
      return 'ไม่ผ่าน';
    }
    if (status.isEmpty || status == 'pending' || status.contains('รอ')) {
      return 'รอดำเนินการ';
    }
    return status;
  }
}

class _Content extends StatelessWidget {
  final Map<String, dynamic> approval;
  final _StyleData style;

  const _Content({required this.approval, required this.style});

  @override
  Widget build(BuildContext context) {
    final flow = approval['flow'] is Map
        ? Map<String, dynamic>.from(approval['flow'] as Map)
        : const <String, dynamic>{};
    final position = approval['position'] is Map
        ? Map<String, dynamic>.from(approval['position'] as Map)
        : const <String, dynamic>{};
    final profile = approval['profile'] is Map
        ? Map<String, dynamic>.from(approval['profile'] as Map)
        : const <String, dynamic>{};
    final flowName = _value(flow['name']);
    final positionName = _value(position['name_th'] ?? position['name']);
    final profileName = _value(profile['full_name']);
    final approvedAt = _formatDate(approval['approved_at']);
    final comment = _value(approval['comment']);
    final uuid = _shortUuid(_value(approval['uuid']));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'ขั้นที่ ${_value(approval['flows_sequence'])}',
              style: LaText.h2.copyWith(fontSize: 15),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: style.bg,
                borderRadius: BorderRadius.circular(LaRadius.pill),
              ),
              child: Text(
                style.label,
                style: TextStyle(
                  color: style.fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
            const Spacer(),
            if (approvedAt != '-')
              Text(approvedAt, style: LaText.caption.copyWith(fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.assignment_rounded,
                size: 12, color: LaColors.textMuted),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                flowName,
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
        Row(
          children: [
            const Icon(Icons.badge_outlined,
                size: 12, color: LaColors.textMuted),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '$positionName • $profileName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LaText.caption.copyWith(color: LaColors.textSecondary),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.tag_rounded, size: 12, color: LaColors.textMuted),
            const SizedBox(width: 4),
            Text('#$uuid',
                style: LaText.caption.copyWith(
                  color: LaColors.textMuted,
                  fontFamily: 'monospace',
                )),
          ],
        ),
        if (comment != '-') ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
            decoration: BoxDecoration(
              color: LaColors.surfaceMuted,
              borderRadius: BorderRadius.circular(LaRadius.sm),
              border: Border.all(color: style.fg.withOpacity(.35)),
            ),
            child: Text(
              comment,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: LaText.caption.copyWith(
                color: LaColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }

  static String _value(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty || text == 'null' ? '-' : text;
  }

  static String _formatDate(dynamic value) {
    final text = _value(value);
    if (text == '-') return text;
    try {
      final dt = DateTime.parse(text);
      return '${dt.day.toString().padLeft(2, '0')}-'
          '${dt.month.toString().padLeft(2, '0')}-${dt.year + 543} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return text;
    }
  }

  static String _shortUuid(String uuid) {
    if (uuid == '-') return uuid;
    return uuid.length <= 8 ? uuid : uuid.substring(0, 8);
  }
}

class _StyleData {
  final Color bg;
  final Color fg;
  final IconData icon;
  final String label;

  const _StyleData({
    required this.bg,
    required this.fg,
    required this.icon,
    required this.label,
  });
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
      child: const Column(
        children: [
          Icon(Icons.history_toggle_off_rounded,
              size: 40, color: LaColors.textMuted),
          SizedBox(height: LaSpace.sm),
          Text('ยังไม่มีประวัติการอนุมัติ', style: LaText.bodyMuted),
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
            'แสดงลำดับขั้นตอนการอนุมัติจากข้อมูลใบอนุญาต',
            style: LaText.caption,
          ),
        ),
      ],
    );
  }
}
