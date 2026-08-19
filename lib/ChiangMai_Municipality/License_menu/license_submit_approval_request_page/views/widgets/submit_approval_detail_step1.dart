// ============================================================================
// submit_approval_detail_step1.dart
// ============================================================================
// Step 1 — ตรวจสอบรายส่งคำร้องขออนุมัติ
// - แสดง "ข้อมูลเบื้องต้น" ของคำร้อง (uuid / สถานะ / lease / zone / ลูกค้า)
// - โหลดผ่าน LicenseSubmitApprovalDetailService.fetchSubmitApprovalDetail(uuid)
// - UI structure พอร์ตมาจาก FactCheckDetailStep1 (เฉพาะส่วน "ข้อมูลเบื้องต้น"
//   — ไม่รวม "รอบตรวจ / Inspection Rounds")
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../unity/FormatPhone.dart';
import '../theme/license_submit_approval_theme.dart';
import '../../viewmodels/license_submit_approval_detail_view_model.dart';
import '../../models/license_submit_approval_detail_model.dart';
import '../../services/license_submit_approval_detail_service.dart';
import 'submit_approval_rounds_section.dart';

class SubmitApprovalDetailStep1 extends StatefulWidget {
  final String? requestUuid;
  const SubmitApprovalDetailStep1({super.key, this.requestUuid});

  @override
  State<SubmitApprovalDetailStep1> createState() =>
      _SubmitApprovalDetailStep1State();
}

class _SubmitApprovalDetailStep1State extends State<SubmitApprovalDetailStep1> {
  final _service = LicenseSubmitApprovalDetailService();

  SubmitApprovalDetail? _detail;
  bool _isLoading = false;
  String? _loadError;
  String? _loadedUuid;

  @override
  void initState() {
    super.initState();
    _loadIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadIfNeeded();
  }

  Future<void> _loadIfNeeded() async {
    final uuid = widget.requestUuid;
    if (uuid == null || uuid.isEmpty) return;
    if (_loadedUuid == uuid && _detail != null) return;

    setState(() {
      _isLoading = true;
      _loadError = null;
      _loadedUuid = uuid;
    });

    try {
      final detail = await _service.fetchSubmitApprovalDetail(uuid: uuid);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Touch VM so it rebuilds when step changes
    context.watch<LicenseSubmitApprovalDetailViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(LaSpace.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Header band ───
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: LaSpace.md, vertical: LaSpace.sm),
                decoration: BoxDecoration(
                  color: LaColors.primaryLight.withOpacity(.25),
                  borderRadius: BorderRadius.circular(LaRadius.md),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.send_rounded,
                        size: 18, color: LaColors.primaryDark),
                    SizedBox(width: 8),
                    Text('ตรวจสอบรายส่งคำร้องขออนุมัติ', style: LaText.h2),
                  ],
                ),
              ),
              const SizedBox(height: LaSpace.md),

              // ─── Loading / Error / Data ───
              if (_isLoading)
                const _LoadingBlock()
              else if (_loadError != null)
                _ErrorBlock(message: _loadError!)
              else if (_detail == null || _detail!.uuid.isEmpty)
                _EmptyBlock(uuid: widget.requestUuid)
              else
                _RequestSummaryCard(model: _detail!),

              const SizedBox(height: LaSpace.lg),

              // ─── Rounds section (UI placeholder) ───
              SubmitApprovalRoundsSection(requestUuid: widget.requestUuid),

              const SizedBox(height: LaSpace.lg),

              // ─── Footer info ───
              const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 14, color: LaColors.textMuted),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'ตรวจสอบรายการให้ครบถ้วนก่อนกด "ถัดไป"',
                      style: LaText.caption,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Sub widgets — พอร์ตมาจาก fact_check_detail_step1.dart
// ============================================================================

class _RequestSummaryCard extends StatelessWidget {
  final SubmitApprovalDetail model;
  const _RequestSummaryCard({required this.model});

  @override
  Widget build(BuildContext context) {
    final nr = model.newRequest;
    final client = model.client;

    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header row: status + uuid ───
          Row(
            children: [
              _StatusBadge(label: model.statusLabel),
              const Spacer(),
              _PillIcon(
                icon: Icons.tag_rounded,
                text: 'UUID: ${_short(model.uuid)}',
                muted: true,
              ),
            ],
          ),
          const SizedBox(height: LaSpace.lg),

          // ─── Grid 2 columns ───
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoColumn(
                  title: 'ข้อมูลคำขอ',
                  items: [
                    _InfoItem(
                      icon: Icons.receipt_long_rounded,
                      label: 'เลขที่คำร้อง',
                      value: nr?.leaseNumber,
                    ),
                    _InfoItem(
                      icon: Icons.calendar_today_rounded,
                      label: 'วันที่ส่งคำร้อง',
                      value: _formatDate(nr?.ldate),
                    ),
                    _InfoItem(
                      icon: Icons.location_on_rounded,
                      label: 'ประเภท / โซน',
                      value: _joinZones(nr),
                    ),
                    _InfoItem(
                      icon: Icons.numbers_rounded,
                      label: 'วิธีการส่งคำร้อง',
                      value: nr?.ln,
                      mono: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: LaSpace.lg),
              Expanded(
                child: _InfoColumn(
                  title: 'ข้อมูลลูกค้า',
                  items: [
                    _InfoItem(
                      icon: Icons.person_rounded,
                      label: 'ชื่อผู้ติดต่อ',
                      value: client?.cname,
                    ),
                    _InfoItem(
                      icon: Icons.phone_rounded,
                      label: 'เบอร์โทร',
                      value: formatPhoneNumber(client?.tel ?? ''),
                      mono: true,
                    ),
                    _InfoItem(
                      icon: Icons.badge_rounded,
                      label: 'เลขประจำตัวผู้เสียภาษี',
                      value: client?.tax,
                      mono: true,
                    ),
                    _InfoItem(
                      icon: Icons.location_on_outlined,
                      label: 'ที่อยู่',
                      value: client?.addr1,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ─── Footer note ───
          const SizedBox(height: LaSpace.lg),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: LaSpace.md, vertical: LaSpace.sm),
            decoration: BoxDecoration(
              color: LaColors.surfaceMuted,
              borderRadius: BorderRadius.circular(LaRadius.sm),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 14, color: LaColors.textMuted),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'ข้อมูลด้านบนเป็น "ภาพรวมคำขอ" '
                    'สำหรับตรวจสอบเบื้องต้น — รายละเอียดเพิ่มเติมจะแสดงใน Step ถัดไป',
                    style: LaText.caption,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _short(String? uuid) {
    if (uuid == null || uuid.isEmpty) return '-';
    if (uuid.length <= 12) return uuid;
    return '${uuid.substring(0, 8)}…';
  }

  String? _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }

  String? _joinZones(NewRequest? nr) {
    if (nr == null) return null;
    final parts = <String>[
      if (nr.subzone.isNotEmpty && nr.subzone != '-') nr.subzone,
      if (nr.zn.isNotEmpty && nr.zn != '-') nr.zn,
    ];
    if (parts.isEmpty) return null;
    return parts.join(' / ');
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  const _StatusBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final s = label.toLowerCase();
    Color bg, fg;
    if (s.contains('อนุมัติ') || s.contains('approved') || s.contains('pass')) {
      bg = LaColors.statusApprovedBg;
      fg = LaColors.statusApprovedFg;
    } else if (s.contains('ปฏิเสธ') ||
        s.contains('reject') ||
        s.contains('cancel') ||
        s.contains('ยกเลิก')) {
      bg = LaColors.statusRejectedBg;
      fg = LaColors.statusRejectedFg;
    } else if (s.contains('รอ') ||
        s.contains('pending') ||
        s.contains('progress')) {
      bg = LaColors.statusPendingBg;
      fg = LaColors.statusPendingFg;
    } else {
      bg = LaColors.statusNeutralBg;
      fg = LaColors.statusNeutralFg;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(LaRadius.pill),
        border: Border.all(color: fg.withOpacity(.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          AutoSizeText(
            label,
            minFontSize: 11,
            maxFontSize: 12,
            maxLines: 1,
            style: TextStyle(
              fontFamily: LaText.fontBold,
              fontWeight: FontWeight.w700,
              color: fg,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillIcon extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool muted;
  const _PillIcon({required this.icon, required this.text, this.muted = false});

  @override
  Widget build(BuildContext context) {
    final fg = muted ? LaColors.textSecondary : LaColors.textPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: LaColors.surfaceMuted,
        borderRadius: BorderRadius.circular(LaRadius.pill),
        border: Border.all(color: LaColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 6),
          AutoSizeText(
            text,
            minFontSize: 11,
            maxFontSize: 12,
            maxLines: 1,
            style: LaText.caption.copyWith(
              color: fg,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String title;
  final List<_InfoItem> items;
  const _InfoColumn({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: LaText.label.copyWith(
            color: LaColors.primaryDark,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: LaSpace.sm),
        for (final item in items) ...[
          item,
          const SizedBox(height: LaSpace.sm),
        ],
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool mono;
  const _InfoItem({
    required this.icon,
    required this.label,
    this.value,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    final v = (value ?? '').trim();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: LaColors.primary.withOpacity(.08),
            borderRadius: BorderRadius.circular(LaRadius.sm),
          ),
          child: Icon(icon, size: 16, color: LaColors.primaryDark),
        ),
        const SizedBox(width: LaSpace.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: LaText.caption),
              const SizedBox(height: 2),
              AutoSizeText(
                v.isEmpty ? '-' : v,
                minFontSize: 12,
                maxFontSize: 14,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: mono ? 'monospace' : LaText.fontRegular,
                  fontSize: 13,
                  color: v.isEmpty ? LaColors.textMuted : LaColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.symmetric(vertical: LaSpace.xxl),
      child: const Column(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          SizedBox(height: LaSpace.md),
          Text('กำลังโหลดข้อมูลคำร้อง...', style: LaText.bodyMuted),
        ],
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  final String message;
  const _ErrorBlock({required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.lg),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: LaColors.statusRejectedFg),
          const SizedBox(width: LaSpace.sm),
          Expanded(
            child: Text(
              message,
              style: LaText.body.copyWith(color: LaColors.statusRejectedFg),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  final String? uuid;
  const _EmptyBlock({this.uuid});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.xxl),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: LaColors.primary.withOpacity(.10),
              borderRadius: BorderRadius.circular(LaRadius.lg),
            ),
            child: const Icon(Icons.inbox_rounded,
                size: 36, color: LaColors.primary),
          ),
          const SizedBox(height: LaSpace.md),
          Text(
            uuid != null && uuid!.isNotEmpty
                ? 'ไม่พบข้อมูลคำร้อง (uuid: ${uuid!.substring(0, uuid!.length.clamp(0, 8))})'
                : 'ไม่พบข้อมูลคำร้อง',
            style: LaText.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: LaSpace.sm),
          const Text(
            'ตรวจสอบว่า uuid ถูกต้อง หรือกด "ย้อนกลับ" เพื่อเลือกรายการใหม่',
            style: LaText.bodyMuted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
