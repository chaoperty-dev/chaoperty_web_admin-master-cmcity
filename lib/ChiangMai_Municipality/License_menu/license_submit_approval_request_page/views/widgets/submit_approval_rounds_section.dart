// ============================================================================
// submit_approval_rounds_section.dart
// ============================================================================
// Step 1 main action — "เริ่มส่งการร้องขออนุมัติ"
// - ปุ่มเด่น full-width (primary action)
// - tap -> POST /v2/admin/approvals/{uuid}/rounds (startRound)
// - success -> swap to "already submitted" state (local)
// - no approve/reject buttons here — step 1 is "เพิ่มคำร้อง" only
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/license_submit_approval_theme.dart';
import '../../models/submit_approval_detail_extended.dart';
import '../../viewmodels/license_submit_approval_rounds_view_model.dart';

class SubmitApprovalRoundsSection extends StatefulWidget {
  final String? requestUuid;

  /// สถานะจาก API: true = มีการส่งคำร้องขออนุมัติอยู่แล้ว
  /// ใช้ตัดสินว่าจะแสดงปุ่ม "เริ่มส่ง..." หรือสถานะ "ส่งแล้ว"
  /// เมื่อ widget แรกโหลด (ยังไม่เคยกดปุ่ม)
  final bool hasPendingApproval;

  /// submitted_at จาก API (string nullable) — ถ้ามี timestamp แสดงว่า "เคยส่งแล้ว"
  /// ใช้เป็น primary check เพื่อแยก "ยังไม่เคยส่ง" vs "ส่งแล้ว"
  final String? submittedAt;

  const SubmitApprovalRoundsSection({
    super.key,
    this.requestUuid,
    this.hasPendingApproval = false,
    this.submittedAt,
  });

  @override
  State<SubmitApprovalRoundsSection> createState() =>
      _SubmitApprovalRoundsSectionState();
}

class _SubmitApprovalRoundsSectionState
    extends State<SubmitApprovalRoundsSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureReset();
      _loadHistoryIfNeeded();
    });
  }

  @override
  void didUpdateWidget(covariant SubmitApprovalRoundsSection old) {
    super.didUpdateWidget(old);
    if (old.requestUuid != widget.requestUuid) {
      _ensureReset();
      _loadHistoryIfNeeded();
    }
  }

  void _loadHistoryIfNeeded() {
    final uuid = widget.requestUuid;
    if (uuid == null || uuid.isEmpty) return;
    // ignore: discarded_futures
    context.read<LicenseSubmitApprovalRoundsViewModel>().loadHistory(uuid);
  }

  void _ensureReset() {
    final uuid = widget.requestUuid;
    if (uuid == null || uuid.isEmpty) return;
    context.read<LicenseSubmitApprovalRoundsViewModel>().resetForUuid(uuid);
  }

  @override
  Widget build(BuildContext context) {
    final uuid = widget.requestUuid;
    if (uuid == null || uuid.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.lg),
      child: Consumer<LicenseSubmitApprovalRoundsViewModel>(
        builder: (ctx, roundsVm, _) {
          // สถานะ "ส่งแล้ว" ได้จาก 2 แหล่ง:
          // 1. server-driven: hasPendingApproval (approval_pending=true)
          // 2. local: roundsVm.lastRound (หลังกด startRound สำเร็จ)
          // ⚠️ submitted_at + approval_pending=false → ไม่ถือว่า submitted (อนุญาตให้ submit ใหม่ได้)
          final isSubmitted =
              widget.hasPendingApproval || roundsVm.lastRound != null;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(submitted: isSubmitted),
              const SizedBox(height: LaSpace.sm),
              _Description(
                submitted: isSubmitted,
                hasRound: roundsVm.lastRound != null,
              ),
              const SizedBox(height: LaSpace.md),
              if (roundsVm.roundError != null) ...[
                _ErrorBanner(
                  message: roundsVm.roundError!,
                  onDismiss: roundsVm.clearError,
                ),
                const SizedBox(height: LaSpace.md),
              ],
              if (isSubmitted)
                _SubmittedState(round: roundsVm.lastRound)
              else
                _PrimaryActionButton(
                  isLoading: roundsVm.isStartingRound,
                  onTap: roundsVm.isStartingRound
                      ? null
                      : () => _onSubmit(ctx, roundsVm, uuid),
                ),
              // ─── ประวัติ rounds (โหลดจาก detail endpoint) ───
              if (roundsVm.history.isNotEmpty) ...[
                const SizedBox(height: LaSpace.lg),
                const _HistoryDivider(),
                const SizedBox(height: LaSpace.md),
                _HistorySection(history: roundsVm.history),
              ] else if (roundsVm.isLoadingHistory) ...[
                const SizedBox(height: LaSpace.lg),
                const _HistoryLoading(),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _onSubmit(
    BuildContext context,
    LicenseSubmitApprovalRoundsViewModel roundsVm,
    String uuid,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final round = await roundsVm.startRound(requestUuid: uuid);
    if (round != null && round.uuid.isNotEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'ส่งคำร้องขออนุมัติสำเร็จ (${round.uuid.substring(0, round.uuid.length.clamp(0, 8))})',
          ),
          backgroundColor: LaColors.statusApprovedFg,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    // error displayed automatically via roundError banner
  }
}

// ============================================================================
// Header
// ============================================================================

class _Header extends StatelessWidget {
  final bool submitted;
  const _Header({required this.submitted});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          submitted ? Icons.check_circle_rounded : Icons.send_rounded,
          color: submitted ? LaColors.statusApprovedFg : LaColors.primaryDark,
        ),
        const SizedBox(width: LaSpace.sm),
        Text(
          submitted ? 'สถานะการส่งคำร้อง' : 'ส่งคำร้องขออนุมัติ',
          style: LaText.h2,
        ),
      ],
    );
  }
}

// ============================================================================
// Helper description — คำอธิบายสั้นๆ ใต้หัวเรื่อง
// ============================================================================

class _Description extends StatelessWidget {
  final bool submitted;
  final bool hasRound;
  const _Description({required this.submitted, required this.hasRound});

  @override
  Widget build(BuildContext context) {
    final String text;
    if (!submitted) {
      text = 'กดปุ่มด้านล่างเพื่อส่งคำร้องไปยังเจ้าหน้าที่ '
          'ระบบจะเปิดรอบการอนุมัติ เพื่อตรวจสอบและลงนามก่อนออกใบอนุญาต';
    } else if (hasRound) {
      text = 'รอบการอนุมัติถูกสร้างเรียบร้อยแล้ว — '
          'รอเจ้าหน้าที่ดำเนินการตรวจสอบและลงนามอนุมัติใบอนุญาต';
    } else {
      // server-driven — มี approval_pending=true แต่ยังไม่มี local round
      text = 'มีการส่งคำร้องขออนุมัติแล้ว — '
          'อยู่ระหว่างรอเจ้าหน้าที่ดำเนินการตรวจสอบและลงนามอนุมัติ';
    }
    return Text(
      text,
      style: LaText.bodyMuted,
    );
  }
}

// ============================================================================
// Primary action — ปุ่มเด่น full-width
// ============================================================================

class _PrimaryActionButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onTap;
  const _PrimaryActionButton({
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: LaColors.primary,
          borderRadius: BorderRadius.circular(LaRadius.md),
          boxShadow: [
            BoxShadow(
              color: LaColors.primary.withOpacity(.30),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(LaRadius.md),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        SizedBox(width: 10),
                        AutoSizeText(
                          'เริ่มส่งการร้องขออนุมัติ',
                          maxFontSize: 17,
                          minFontSize: 14,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: LaText.fontBold,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            letterSpacing: .3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Submitted state — แสดงหลังกดสำเร็จ
// ============================================================================

class _SubmittedState extends StatelessWidget {
  final dynamic round; // ApprovalRound? — null when server-driven
  const _SubmittedState({required this.round});

  String _short(String uuid) {
    if (uuid.isEmpty) return '-';
    if (uuid.length <= 8) return uuid;
    return uuid.substring(0, 8);
  }

  @override
  Widget build(BuildContext context) {
    // server-driven — มี approval_pending=true แต่ไม่มี round detail
    final hasRound = round != null;
    final roundNo = hasRound ? round.round?.toString() : null;
    final shortUuid = hasRound ? _short(round.uuid ?? '') : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(LaSpace.lg),
      decoration: BoxDecoration(
        color: LaColors.statusApprovedBg,
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(
          color: LaColors.statusApprovedFg.withOpacity(.30),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: LaColors.statusApprovedFg.withOpacity(.15),
              borderRadius: BorderRadius.circular(LaRadius.md),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: LaColors.statusApprovedFg,
              size: 26,
            ),
          ),
          const SizedBox(width: LaSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const AutoSizeText(
                  'ได้มีการส่งคำร้องขออนุมัติแล้ว',
                  maxFontSize: 16,
                  minFontSize: 14,
                  maxLines: 1,
                  style: TextStyle(
                    color: LaColors.statusApprovedFg,
                    fontFamily: LaText.fontBold,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                if (roundNo != null && shortUuid != null) ...[
                  const SizedBox(height: 4),
                  AutoSizeText(
                    'รอบ #$roundNo • $shortUuid',
                    maxFontSize: 12,
                    minFontSize: 10,
                    maxLines: 1,
                    style: TextStyle(
                      color: LaColors.statusApprovedFg.withOpacity(.75),
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Error banner
// ============================================================================

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;
  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LaSpace.sm),
      decoration: BoxDecoration(
        color: LaColors.statusRejectedBg.withOpacity(.5),
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(
          color: LaColors.statusRejectedFg.withOpacity(.25),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: LaColors.statusRejectedFg,
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: LaText.caption.copyWith(
                color: LaColors.statusRejectedFg,
              ),
            ),
          ),
          InkWell(
            onTap: onDismiss,
            child: const Icon(
              Icons.close_rounded,
              size: 16,
              color: LaColors.statusRejectedFg,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// History section — แสดงประวัติ rounds ที่เคยเปิด
// ============================================================================

class _HistoryDivider extends StatelessWidget {
  const _HistoryDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.history_rounded,
            size: 14, color: LaColors.textSecondary),
        const SizedBox(width: 6),
        Text('ประวัติการส่งคำร้อง (รอบการอนุมัติ)', style: LaText.caption),
      ],
    );
  }
}

class _HistoryLoading extends StatelessWidget {
  const _HistoryLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LaSpace.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text('กำลังโหลดประวัติ...', style: LaText.caption),
        ],
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  final List<ApprovalHistoryEntry> history;
  const _HistorySection({required this.history});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < history.length; i++) ...[
          _HistoryRow(entry: history[i], isFirst: i == 0),
          if (i < history.length - 1)
            const Padding(
              padding: EdgeInsets.only(left: 22),
              child: Divider(height: 1, thickness: 1, color: LaColors.border),
            ),
        ],
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final ApprovalHistoryEntry entry;
  final bool isFirst;
  const _HistoryRow({required this.entry, required this.isFirst});

  @override
  Widget build(BuildContext context) {
    final roundNo = entry.round ?? '-';
    final state = entry.status ?? '';
    final actedBy = entry.actedBy ?? '-';
    final actedAt = entry.actedAt ?? '';
    final remark = entry.remark ?? '';

    // โชว์ state เป็น raw value (เหมือน step 2 _RoundSummaryBanner)
    final stateLabel = state.isEmpty ? '-' : state;

    // state-based color/icon (เหมือน step 2 _TimelineItem)
    Color bg = LaColors.primaryLight.withOpacity(.35);
    Color fg = LaColors.primaryDark;
    IconData icon = Icons.folder_open_rounded;
    final s = state.toLowerCase();
    if (s.contains('approve') ||
        s.contains('pass') ||
        s.contains('ผ่าน') ||
        s.contains('อนุมัติ')) {
      bg = LaColors.statusApprovedBg;
      fg = LaColors.statusApprovedFg;
      icon = Icons.check_circle_rounded;
    } else if (s.contains('ปฏิเสธ') ||
        s.contains('ไม่ผ่าน') ||
        s.contains('reject') ||
        s.contains('cancel') ||
        s.contains('ยกเลิก') ||
        s.contains('ไม่อนุมัติ') ||
        s.contains('failed') ||
        s.contains('fail') ||
        s.contains('หมดอายุ') ||
        s.contains('expired')) {
      bg = LaColors.statusRejectedBg;
      fg = LaColors.statusRejectedFg;
      icon = Icons.cancel_rounded;
    } else if (s.contains('pending') ||
        s.contains('รอ') ||
        s.contains('progress')) {
      bg = LaColors.statusPendingBg;
      fg = LaColors.statusPendingFg;
      icon = Icons.hourglass_top_rounded;
    } else {
      bg = LaColors.statusInfoBg;
      fg = LaColors.statusInfoFg;
      icon = Icons.assignment_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(LaSpace.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(color: fg.withOpacity(.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'รอบที่ $roundNo — $stateLabel',
                  style: LaText.h2.copyWith(fontSize: 14, color: fg),
                ),
                const SizedBox(height: 2),
                Text(
                  'เปิดเมื่อ $actedAt • โดย $actedBy',
                  style: LaText.caption,
                ),
                if (remark.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'หมายเหตุ: $remark',
                      style: LaText.caption.copyWith(
                        color: LaColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
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
