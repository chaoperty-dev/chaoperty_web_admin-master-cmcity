// ============================================================================
// submit_approval_rounds_section.dart
// ============================================================================
// "ขั้นตอนการส่งคำร้องขออนุมัติ" — UI เชื่อมต่อ v2 admin/approvals APIs
// - เพิ่มการร้องขออนุมัติ → POST /rounds (RoundsVM)
// - step card    → จาก DetailVM.currentRound.steps (single source)
// - อนุมัติ/ปฏิเสธ → DetailVM.approveStep/rejectStep (auto reload)
// - respect can_open_round → disable "เพิ่มการร้องขออนุมัติ"
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/license_submit_approval_theme.dart';
import '../../models/submit_approval_detail_extended.dart';
import '../../viewmodels/license_submit_approval_detail_view_model.dart';
import '../../viewmodels/license_submit_approval_rounds_view_model.dart';

class SubmitApprovalRoundsSection extends StatefulWidget {
  final String? requestUuid;
  const SubmitApprovalRoundsSection({super.key, this.requestUuid});

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
      _ensureLoad();
    });
  }

  @override
  void didUpdateWidget(covariant SubmitApprovalRoundsSection old) {
    super.didUpdateWidget(old);
    if (old.requestUuid != widget.requestUuid) {
      _ensureLoad();
    }
  }

  void _ensureLoad() {
    final uuid = widget.requestUuid;
    if (uuid == null || uuid.isEmpty) return;
    debugPrint('[SubmitApproval] open detail requestUuid=$uuid (len=${uuid.length})');
    final roundsVm =
        context.read<LicenseSubmitApprovalRoundsViewModel>();
    roundsVm.resetForUuid(uuid);
    context
        .read<LicenseSubmitApprovalDetailViewModel>()
        .loadApprovalDetail(requestUuid: uuid);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RoundsHeader(requestUuid: widget.requestUuid),
          const SizedBox(height: LaSpace.md),
          _ErrorBanner(),
          // ─── Content ───
          Consumer<LicenseSubmitApprovalDetailViewModel>(
            builder: (ctx, vm, _) {
              debugPrint(
                  '[RoundsContent] rebuild currentSteps=${vm.currentSteps.length}, '
                  'hasDetail=${vm.approvalDetail != null}, '
                  'loading=${vm.isLoadingDetail}, '
                  'round=${vm.currentRound?.round}');
              // sync canOpenRound → RoundsVM (1 ครั้งต่อ uuid)
              final uuid = widget.requestUuid;
              if (uuid != null && uuid.isNotEmpty && vm.approvalDetail != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ctx
                      .read<LicenseSubmitApprovalRoundsViewModel>()
                      .syncCanOpenRound(uuid, vm.approvalDetail!.canOpenRound);
                });
              }

              if (vm.isLoadingDetail && vm.currentSteps.isEmpty) {
                return const _RoundsLoading();
              }
              final step = vm.myActionableStep!.uuid.isEmpty
                  ? null
                  : vm.myActionableStep;
              if (step == null) {
                return _RoundsEmpty(
                  requestUuid: widget.requestUuid,
                  isStarting:
                      context.watch<LicenseSubmitApprovalRoundsViewModel>()
                          .isStartingRound,
                  onStart: () => _onStartRound(ctx),
                );
              }
              return _StepRoundCard(
                step: step,
                currentStepOrder: vm.currentRound?.currentStepOrder,
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _onStartRound(BuildContext context) async {
    final uuid = widget.requestUuid;
    if (uuid == null || uuid.isEmpty) return;
    final roundsVm = context.read<LicenseSubmitApprovalRoundsViewModel>();
    final round = await roundsVm.startRound(requestUuid: uuid);
    if (!context.mounted) return;
    if (round != null && round.uuid.isNotEmpty) {
      // reload detail → step ใหม่จะปรากฏ
      await context
          .read<LicenseSubmitApprovalDetailViewModel>()
          .loadApprovalDetail(requestUuid: uuid);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'เปิดการร้องขออนุมัติใหม่สำเร็จ (${round.uuid.substring(0, round.uuid.length.clamp(0, 8))})',
          ),
          backgroundColor: LaColors.statusApprovedFg,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (roundsVm.roundError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(roundsVm.roundError!),
          backgroundColor: LaColors.statusRejectedFg,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// ============================================================================
// Header
// ============================================================================

class _RoundsHeader extends StatelessWidget {
  final String? requestUuid;
  const _RoundsHeader({this.requestUuid});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.folder_open_rounded, color: LaColors.primaryDark),
        const SizedBox(width: LaSpace.sm),
        const Text('ขั้นตอนการส่งคำร้องขออนุมัติ', style: LaText.h2),
        const SizedBox(width: LaSpace.sm),
        Consumer<LicenseSubmitApprovalDetailViewModel>(
          builder: (_, vm, __) {
            final count = vm.currentSteps.length;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: LaColors.primary.withOpacity(.10),
                borderRadius: BorderRadius.circular(LaRadius.pill),
              ),
              child: Text(
                '$count ขั้น',
                style: const TextStyle(
                  color: LaColors.primaryDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            );
          },
        ),
        const Spacer(),
        Consumer2<LicenseSubmitApprovalRoundsViewModel,
            LicenseSubmitApprovalDetailViewModel>(
          builder: (ctx, roundsVm, detailVm, __) {
            final canOpen = roundsVm.canOpenRound ?? false;
            final isStarting = roundsVm.isStartingRound;
            // ─── เหตุผลเมื่อ disable (แสดงเป็น tooltip) ───
            final String? disabledReason = isStarting
                ? 'กำลังเพิ่มการร้องขออนุมัติ กรุณารอสักครู่'
                : null;
            return _StartInspectionButton(
              // กดได้เสมอ (override can_open_round) — confirm dialog จะถามอีกที
              enabled: !isStarting,
              isLoading: isStarting,
              disabledReason: disabledReason,
              onTap: isStarting
                  ? null
                  : () => _handleStartRoundTap(
                        ctx,
                        requestUuid: requestUuid,
                        canOpen: canOpen,
                        roundsVm: roundsVm,
                        detailVm: detailVm,
                      ),
            );
          },
        ),
      ],
    );
  }

  /// จัดการเมื่อกดปุ่ม "เพิ่มการร้องขออนุมัติ":
  /// - canOpen = true  → ถาม "ยังไม่ถึงการตรวจ ยืนยันที่จะเพิ่มใช่หรือไม่?"
  /// - canOpen = false → ถาม "มีการร้องขอค้างอยู่ ยืนยันที่จะเพิ่มใหม่ทับหรือไม่?"
  Future<void> _handleStartRoundTap(
    BuildContext ctx, {
    required String? requestUuid,
    required bool canOpen,
    required LicenseSubmitApprovalRoundsViewModel roundsVm,
    required LicenseSubmitApprovalDetailViewModel detailVm,
  }) async {
    final uuid = requestUuid;
    if (uuid == null || uuid.isEmpty) return;

    // ─── ถาม confirm ทั้งสองกรณี ───
    final current = detailVm.approvalDetail?.currentRound;
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        icon: Icon(
          canOpen
              ? Icons.help_outline_rounded
              : Icons.warning_amber_rounded,
          color: canOpen
              ? LaColors.primary
              : LaColors.statusPendingFg,
          size: 32,
        ),
        title: const Text('ยืนยันการเพิ่มการร้องขออนุมัติ'),
        content: Text(
          canOpen
              ? 'ยังไม่ถึงการตรวจ\n'
                  'ยืนยันที่จะเพิ่มการร้องขออนุมัติใช่หรือไม่?'
              : (current != null
                  ? 'มีการร้องขออนุมัติ #${current.round ?? '-'} '
                      'สถานะ: ${current.state ?? '-'} ค้างอยู่\n\n'
                      'ยืนยันที่จะเพิ่มการร้องขออนุมัติใหม่ทับรอบเดิมใช่หรือไม่?'
                  : 'ยืนยันที่จะเพิ่มการร้องขออนุมัติใหม่ใช่หรือไม่?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dCtx).pop(false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: LaColors.primary,
            ),
            onPressed: () => Navigator.of(dCtx).pop(true),
            child: const Text('เพิ่มการร้องขอ'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (!ctx.mounted) return;

    // ─── เรียก API /rounds ───
    final round = await roundsVm.startRound(requestUuid: uuid);
    if (!ctx.mounted) return;

    if (round != null) {
      // สำเร็จ → reload detail แล้ว snackbar
      await detailVm.loadApprovalDetail(requestUuid: uuid);
      // ─── sync canOpenRound จาก response ใหม่ (ป้องกัน guard เก่า block) ───
      if (!ctx.mounted) return;
      final newDetail = detailVm.approvalDetail;
      if (newDetail != null) {
        roundsVm.syncCanOpenRound(
          uuid,
          newDetail.canOpenRound,
        );
      }
      // ─── snackbar (ใช้ uuid/round fallback) ───
      final short = round.uuid.isNotEmpty
          ? round.uuid.substring(0, round.uuid.length.clamp(0, 8))
          : '#${round.round ?? '-'}';
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(
            'เพิ่มการร้องขออนุมัติใหม่สำเร็จ ($short)',
          ),
          backgroundColor: LaColors.statusApprovedFg,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (roundsVm.roundError != null) {
      // ─── error (เช่น 409 Conflict) → snackbar ───
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(roundsVm.roundError!),
          backgroundColor: LaColors.statusRejectedFg,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}

class _StartInspectionButton extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final VoidCallback? onTap;
  final String? disabledReason;
  const _StartInspectionButton({
    this.enabled = true,
    this.isLoading = false,
    this.onTap,
    this.disabledReason,
  });

  @override
  Widget build(BuildContext context) {
    final bg = enabled ? LaColors.primary : LaColors.border;
    final btn = MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(LaRadius.md),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: LaColors.primary.withOpacity(.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                Icon(
                  enabled
                      ? Icons.add_circle_rounded
                      : Icons.lock_outline_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              const SizedBox(width: 6),
              const Text(
                'เพิ่มการร้องขออนุมัติ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // ─── Tooltip: อธิบายเหตุผลเมื่อ disable ───
    if (!enabled && (disabledReason ?? '').isNotEmpty) {
      return Tooltip(
        message: disabledReason!,
        preferBelow: true,
        waitDuration: const Duration(milliseconds: 150),
        child: btn,
      );
    }
    return btn;
  }
}

// ============================================================================
// Step card
// ============================================================================

class _StepRoundCard extends StatelessWidget {
  final ApprovalStepV2 step;
  final int? currentStepOrder;
  const _StepRoundCard({required this.step, this.currentStepOrder});

  static const _pendingBg = LaColors.statusPendingBg;
  static const _pendingFg = LaColors.statusPendingFg;

  String _short(String uuid) {
    if (uuid.isEmpty) return '-';
    if (uuid.length <= 8) return uuid;
    return uuid.substring(0, 8);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LaRadius.lg),
        border: Border.all(color: _pendingFg.withOpacity(.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _pendingFg.withOpacity(.15),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 3,
            decoration: const BoxDecoration(
              color: _pendingFg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(LaRadius.lg),
                topRight: Radius.circular(LaRadius.lg),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                LaSpace.lg, LaSpace.md, LaSpace.lg, LaSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _pendingBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.hourglass_top_rounded,
                        color: _pendingFg,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: LaSpace.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              AutoSizeText(
                                'ขั้นที่ ${step.stepOrder ?? '-'}',
                                minFontSize: 16,
                                maxFontSize: 20,
                                style: LaText.h2,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _pendingBg,
                                  borderRadius:
                                      BorderRadius.circular(LaRadius.pill),
                                ),
                                child: Text(
                                  step.statusLabel ??
                                      (step.status.isEmpty
                                          ? 'รอดำเนินการ'
                                          : step.status),
                                  style: const TextStyle(
                                    color: _pendingFg,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              if (step.isCurrent) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: LaColors.primary.withOpacity(.15),
                                    borderRadius:
                                        BorderRadius.circular(LaRadius.pill),
                                  ),
                                  child: const Text(
                                    'ขั้นปัจจุบัน',
                                    style: TextStyle(
                                      color: LaColors.primaryDark,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step.stepName.isEmpty
                                ? 'กำลังดำเนินการ'
                                : step.stepName,
                            style: const TextStyle(
                              color: _pendingFg,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: LaSpace.md),
                Row(
                  children: [
                    _Stat(
                      icon: Icons.badge_outlined,
                      text: step.positionName.isEmpty
                          ? '-'
                          : step.positionName,
                    ),
                    const Spacer(),
                    Text(
                      '#${_short(step.uuid)}',
                      style: const TextStyle(
                        color: LaColors.textMuted,
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ─── Toolbar ───
          Container(
            decoration: const BoxDecoration(
              color: LaColors.surfaceMuted,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(LaRadius.lg),
                bottomRight: Radius.circular(LaRadius.lg),
              ),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: LaSpace.lg, vertical: LaSpace.sm),
            child: Consumer<LicenseSubmitApprovalDetailViewModel>(
              builder: (ctx, vm, _) {
                final isActing = vm.isActing &&
                    vm.actingStepUuid == step.uuid;
                return Row(
                  children: [
                    Expanded(
                      child: _ToolbarButton(
                        label: 'อนุมัติ',
                        icon: Icons.check_rounded,
                        fg: Colors.white,
                        bg: LaColors.statusApprovedFg,
                        isLoading: isActing,
                        onTap: isActing
                            ? null
                            : () => _onApprove(ctx, vm, step),
                      ),
                    ),
                    const SizedBox(width: LaSpace.sm),
                    Expanded(
                      child: _ToolbarButton(
                        label: 'ปฏิเสธ',
                        icon: Icons.close_rounded,
                        fg: LaColors.statusRejectedFg,
                        bg: LaColors.statusRejectedBg,
                        isLoading: false,
                        onTap: isActing
                            ? null
                            : () => _onReject(ctx, vm, step),
                      ),
                    ),
                    const SizedBox(width: LaSpace.sm),
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: LaColors.border),
                        borderRadius: BorderRadius.circular(LaRadius.md),
                      ),
                      child: InkWell(
                        onTap: vm.isLoadingDetail
                            ? null
                            : () {
                                final uuid = vm.approvalDetail?.requestUuid ?? '';
                                if (uuid.isNotEmpty) {
                                  vm.loadApprovalDetail(requestUuid: uuid);
                                }
                              },
                        borderRadius: BorderRadius.circular(LaRadius.md),
                        child: Icon(
                          Icons.refresh_rounded,
                          size: 16,
                          color: vm.isLoadingDetail
                              ? LaColors.textMuted
                              : LaColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onApprove(
    BuildContext context,
    LicenseSubmitApprovalDetailViewModel vm,
    ApprovalStepV2 step,
  ) async {
    final remark = await _showRemarkDialog(
      context,
      title: 'อนุมัติ',
      hint: 'หมายเหตุ (ไม่บังคับ)',
      accent: LaColors.statusApprovedFg,
      confirmLabel: 'อนุมัติ',
    );
    if (remark == null) return;
    if (!context.mounted) return;
    // remark = '' ผ่านได้
    await vm.approveStep(step: step);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(vm.actionError ?? 'อนุมัติสำเร็จ'),
        backgroundColor: vm.actionError == null
            ? LaColors.statusApprovedFg
            : LaColors.statusRejectedFg,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _onReject(
    BuildContext context,
    LicenseSubmitApprovalDetailViewModel vm,
    ApprovalStepV2 step,
  ) async {
    final remark = await _showRemarkDialog(
      context,
      title: 'ไม่อนุมัติ',
      hint: 'เหตุผล (จำเป็นต้องระบุ)',
      accent: LaColors.statusRejectedFg,
      confirmLabel: 'ปฏิเสธ',
      requireRemark: true,
    );
    if (remark == null || remark.isEmpty) return;
    if (!context.mounted) return;
    final ok = await vm.rejectStep(step: step, remark: remark);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'ปฏิเสธสำเร็จ' : (vm.actionError ?? 'ปฏิเสธไม่สำเร็จ')),
        backgroundColor: ok
            ? LaColors.statusApprovedFg
            : LaColors.statusRejectedFg,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

Future<String?> _showRemarkDialog(
  BuildContext context, {
  required String title,
  required String hint,
  required Color accent,
  required String confirmLabel,
  bool requireRemark = false,
}) async {
  final ctrl = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: ctrl,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(null),
          child: const Text('ยกเลิก'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: accent),
          onPressed: () {
            final txt = ctrl.text.trim();
            if (requireRemark && txt.isEmpty) return;
            Navigator.of(ctx).pop(txt);
          },
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  ctrl.dispose();
  return result;
}

// ============================================================================
// Loading / Empty / Error
// ============================================================================

class _RoundsLoading extends StatelessWidget {
  const _RoundsLoading();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: LaSpace.xxl),
      alignment: Alignment.center,
      child: const Column(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          SizedBox(height: LaSpace.md),
          Text('กำลังโหลดข้อมูลการร้องขออนุมัติ...', style: LaText.bodyMuted),
        ],
      ),
    );
  }
}

class _RoundsEmpty extends StatelessWidget {
  final String? requestUuid;
  final VoidCallback onStart;
  final bool isStarting;
  const _RoundsEmpty({
    this.requestUuid,
    required this.onStart,
    this.isStarting = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasUuid = requestUuid != null && requestUuid!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: LaSpace.xxl),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: LaColors.primary.withOpacity(.10),
              borderRadius: BorderRadius.circular(LaRadius.lg),
            ),
            child: Icon(
              Icons.folder_off_rounded,
              size: 36,
              color: hasUuid ? LaColors.primary : LaColors.textMuted,
            ),
          ),
          const SizedBox(height: LaSpace.md),
          Text(
            hasUuid ? 'ยังไม่มีการร้องขออนุมัติ' : 'ไม่พบ request uuid',
            style: LaText.h2,
          ),
          const SizedBox(height: LaSpace.sm),
          Text(
            hasUuid
                ? 'กดปุ่ม "เพิ่มการร้องขออนุมัติ" เพื่อเริ่มขั้นตอน'
                : 'ไม่สามารถโหลดข้อมูลได้',
            style: LaText.bodyMuted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<LicenseSubmitApprovalRoundsViewModel,
        LicenseSubmitApprovalDetailViewModel>(
      builder: (_, roundsVm, detailVm, __) {
        final err = roundsVm.roundError ?? detailVm.detailError;
        if (err == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: LaSpace.md),
          child: Container(
            padding: const EdgeInsets.all(LaSpace.sm),
            decoration: BoxDecoration(
              color: LaColors.statusRejectedBg.withOpacity(.5),
              borderRadius: BorderRadius.circular(LaRadius.md),
              border:
                  Border.all(color: LaColors.statusRejectedFg.withOpacity(.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: LaColors.statusRejectedFg, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    err,
                    style: LaText.caption.copyWith(
                      color: LaColors.statusRejectedFg,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    roundsVm.clearError();
                    detailVm.clearError();
                  },
                  child: const Icon(Icons.close_rounded,
                      size: 16, color: LaColors.statusRejectedFg),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// Helpers
// ============================================================================

class _Stat extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Stat({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: LaColors.textSecondary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(text,
                style: LaText.caption, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color fg;
  final Color bg;
  final bool isLoading;
  final VoidCallback? onTap;
  const _ToolbarButton({
    required this.label,
    required this.icon,
    required this.fg,
    required this.bg,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(LaRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LaRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(fg),
                  ),
                )
              else
                Icon(icon, color: fg, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
