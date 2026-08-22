// ============================================================================
// payment_history_view.dart
// ============================================================================
// View — ประวัติ + Activity log ของ Payment (Step 3 / sub-page)
//
// ใช้ 2 endpoint:
//   - GET /v2/payments/{uuid}/history   → รายการเปลี่ยนสถานะ
//   - GET /v2/payments/{uuid}/activity  → activity log (event + actor)
//
// มีปุ่ม "แนบ Statement" เพื่อเปิด BankStatementUploadDialog
// (อัปโหลด Statement .xlsx/xls/csv + รูปสลิป)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/license_payment_attachment.dart';
import '../../models/license_payment_detail_model.dart';
import '../../viewmodels/license_payment_detail_view_model.dart';
import '../theme/license_payment_theme.dart';
import 'receipt_entry_stepper_dialog.dart';

/// เปิดเป็น Bottom Sheet → คืน PaymentAttachment? (อัปโหลดสำเร็จ) / null
Future<PaymentAttachment?> showPaymentHistorySheet({
  required BuildContext context,
  required String paymentUuid,
  PaymentDetail? payment,
}) {
  return showModalBottomSheet<PaymentAttachment>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    // อยู่ใน nearest Navigator เพื่อให้ inherit Provider scope ของหน้า detail
    useRootNavigator: false,
    builder: (_) => PaymentHistoryView(
      paymentUuid: paymentUuid,
      payment: payment,
    ),
  );
}

class PaymentHistoryView extends StatefulWidget {
  final String paymentUuid;
  final PaymentDetail? payment;
  const PaymentHistoryView({
    super.key,
    required this.paymentUuid,
    this.payment,
  });

  @override
  State<PaymentHistoryView> createState() => _PaymentHistoryViewState();
}

class _PaymentHistoryViewState extends State<PaymentHistoryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LicensePaymentDetailViewModel>().loadHistoryAndActivity(
            uuidOverride: widget.paymentUuid,
          );
    });
  }

  Future<void> _refresh() async {
    await context.read<LicensePaymentDetailViewModel>().loadHistoryAndActivity(
          uuidOverride: widget.paymentUuid,
        );
  }

  Future<void> _openUpload() async {
    final p = widget.payment;
    if (p == null || p.uuid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ไม่พบข้อมูล payment สำหรับแนบไฟล์'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final result = await showReceiptEntryStepperDialog(
      context: context,
      payment: p,
      defaultAmount: p.amount,
      initialStep: 3,
    );
    if (!mounted) return;
    if (result != null) {
      await context
          .read<LicensePaymentDetailViewModel>()
          .loadHistoryAndActivity(uuidOverride: widget.paymentUuid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: LaColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(LaRadius.lg)),
        ),
        child: Column(
          children: [
            _grabber(),
            _header(),
            const Divider(height: 1),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.all(LaSpace.lg),
                  children: [
                    _summaryCard(),
                    const SizedBox(height: LaSpace.md),
                    _historySection(),
                    const SizedBox(height: LaSpace.md),
                    _activitySection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────── sub-widgets ────────────────

  Widget _grabber() => Container(
        margin: const EdgeInsets.only(top: 8, bottom: 4),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: LaColors.borderStrong,
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _header() => Padding(
        padding: const EdgeInsets.fromLTRB(
            LaSpace.lg, LaSpace.sm, LaSpace.lg, LaSpace.md),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: LaColors.primaryLight,
                borderRadius: BorderRadius.circular(LaRadius.sm),
              ),
              child: const Icon(Icons.history_rounded,
                  size: 20, color: LaColors.primaryDark),
            ),
            const SizedBox(width: LaSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ประวัติการรับชำระ', style: LaText.h2),
                  Text(
                    'uuid: ${_short(widget.paymentUuid)}',
                    style: LaText.caption
                        .copyWith(fontFamily: 'monospace', color: LaColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'ปิด',
              icon: const Icon(Icons.close_rounded, size: 18),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );

  Widget _summaryCard() {
    final p = widget.payment;
    return Container(
      padding: const EdgeInsets.all(LaSpace.md),
      decoration: LaDecor.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (p != null) ...[
            Row(
              children: [
                Expanded(
                  child: _kv('เลขที่ใบเสร็จ', p.paymentNo.isEmpty ? '-' : p.paymentNo),
                ),
                _kv('สถานะ', p.statusLabel, isStatus: true, statusText: p.status),
              ],
            ),
            const SizedBox(height: LaSpace.sm),
            Row(
              children: [
                Expanded(
                  child: _kv('จำนวนเงิน', formatMoney(p.amount)),
                ),
                Expanded(
                  child: _kv('ผู้ชำระ', p.payerName.isEmpty ? '-' : p.payerName),
                ),
              ],
            ),
          ] else
            Text('ไม่พบข้อมูล payment detail', style: LaText.bodyMuted),
          const SizedBox(height: LaSpace.md),
          FilledButton.icon(
            onPressed: _openUpload,
            icon: const Icon(Icons.receipt_long_rounded, size: 16),
            label: const Text('บันทึกการรับชำระ'),
            style: FilledButton.styleFrom(
              backgroundColor: LaColors.primaryDark,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _historySection() {
    return Consumer<LicensePaymentDetailViewModel>(
      builder: (_, vm, __) => _TimelineSection(
        title: 'ประวัติการเปลี่ยนสถานะ',
        icon: Icons.swap_horiz_rounded,
        loading: vm.isHistoryLoading,
        error: vm.historyError,
        isEmpty: vm.history?.isEmpty ?? true,
        emptyMessage: 'ยังไม่มีประวัติการเปลี่ยนสถานะ',
        items: vm.history?.items ?? const [],
        itemBuilder: (it) => _HistoryRow(
          item: it as PaymentHistoryItem,
        ),
        onRetry: () => vm.loadHistory(uuidOverride: widget.paymentUuid),
      ),
    );
  }

  Widget _activitySection() {
    return Consumer<LicensePaymentDetailViewModel>(
      builder: (_, vm, __) => _TimelineSection(
        title: 'Activity Log',
        icon: Icons.bolt_rounded,
        loading: vm.isActivityLoading,
        error: vm.activityError,
        isEmpty: vm.activity?.isEmpty ?? true,
        emptyMessage: 'ยังไม่มี activity log',
        items: vm.activity?.items ?? const [],
        itemBuilder: (it) => _ActivityRow(
          item: it as PaymentActivityItem,
        ),
        onRetry: () => vm.loadActivity(uuidOverride: widget.paymentUuid),
      ),
    );
  }

  static String _short(String uuid) =>
      uuid.length <= 12 ? uuid : '${uuid.substring(0, 8)}…';

  static Widget _kv(String label, String value,
      {bool isStatus = false, String? statusText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: LaText.caption.copyWith(color: LaColors.textMuted)),
        const SizedBox(height: 2),
        if (isStatus && statusText != null)
          _StatusPill(status: statusText)
        else
          Text(value.isEmpty ? '-' : value, style: LaText.body),
      ],
    );
  }
}

// ============================================================================
// _TimelineSection — generic list section with loading/error/empty state
// ============================================================================

class _TimelineSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool loading;
  final String? error;
  final bool isEmpty;
  final String emptyMessage;
  final List items;
  final Widget Function(dynamic) itemBuilder;
  final VoidCallback onRetry;

  const _TimelineSection({
    required this.title,
    required this.icon,
    required this.loading,
    required this.error,
    required this.isEmpty,
    required this.emptyMessage,
    required this.items,
    required this.itemBuilder,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: LaColors.primaryDark),
              const SizedBox(width: 6),
              Text(title,
                  style: LaText.body.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              if (loading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: LaSpace.sm),
          if (error != null)
            _ErrorRow(message: error!, onRetry: onRetry)
          else if (loading && items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(emptyMessage, style: LaText.bodyMuted),
            )
          else
            Column(children: items.map(itemBuilder).toList()),
        ],
      ),
    );
  }
}

class _ErrorRow extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorRow({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LaSpace.sm),
      decoration: BoxDecoration(
        color: LaColors.statusRejectedBg.withOpacity(.4),
        borderRadius: BorderRadius.circular(LaRadius.sm),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 14, color: LaColors.statusRejectedFg),
          const SizedBox(width: 6),
          Expanded(
            child: Text(message,
                style: LaText.caption
                    .copyWith(color: LaColors.statusRejectedFg)),
          ),
          TextButton(onPressed: onRetry, child: const Text('ลองใหม่')),
        ],
      ),
    );
  }
}

// ============================================================================
// _HistoryRow — แถวประวัติ (timeline style)
// ============================================================================

class _HistoryRow extends StatelessWidget {
  final PaymentHistoryItem item;
  const _HistoryRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return _TimelineRow(
      leading: const Icon(Icons.swap_horiz_rounded,
          size: 14, color: LaColors.statusInfoFg),
      leadingBg: LaColors.statusInfoBg,
      title: item.status ?? item.action ?? 'เปลี่ยนสถานะ',
      subtitle: item.note?.isNotEmpty == true ? item.note : null,
      actor: item.actorName,
      time: item.createdAt,
      uuid: item.uuid,
    );
  }
}

// ============================================================================
// _ActivityRow — แถว activity
// ============================================================================

class _ActivityRow extends StatelessWidget {
  final PaymentActivityItem item;
  const _ActivityRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return _TimelineRow(
      leading: const Icon(Icons.bolt_rounded,
          size: 14, color: LaColors.statusApprovedFg),
      leadingBg: LaColors.statusApprovedBg,
      title: item.action?.isNotEmpty == true ? item.action! : 'Activity',
      subtitle: item.description?.isNotEmpty == true ? item.description : null,
      actor: item.actorName,
      time: item.createdAt,
      uuid: item.uuid,
    );
  }
}

// ============================================================================
// _TimelineRow — generic row layout
// ============================================================================

class _TimelineRow extends StatelessWidget {
  final Widget leading;
  final Color leadingBg;
  final String title;
  final String? subtitle;
  final String? actor;
  final String? time;
  final String uuid;

  const _TimelineRow({
    required this.leading,
    required this.leadingBg,
    required this.title,
    required this.subtitle,
    required this.actor,
    required this.time,
    required this.uuid,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: leadingBg,
              borderRadius: BorderRadius.circular(LaRadius.pill),
            ),
            child: leading,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: LaText.body
                            .copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (time != null && time!.isNotEmpty)
                      Text(
                        _shortTime(time!),
                        style: LaText.caption
                            .copyWith(color: LaColors.textMuted),
                      ),
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: LaText.caption),
                ],
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (actor != null && actor!.isNotEmpty) ...[
                      const Icon(Icons.person_outline_rounded,
                          size: 11, color: LaColors.textMuted),
                      const SizedBox(width: 2),
                      Text(actor!,
                          style: LaText.caption
                              .copyWith(color: LaColors.textMuted)),
                      const SizedBox(width: 8),
                    ],
                    if (uuid.isNotEmpty)
                      Text(
                        uuid.length > 10 ? '${uuid.substring(0, 8)}…' : uuid,
                        style: LaText.caption.copyWith(
                          fontFamily: 'monospace',
                          color: LaColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _shortTime(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw);
      final d = dt.toLocal();
      String two(int n) => n.toString().padLeft(2, '0');
      return '${d.day}/${d.month}/${d.year} ${two(d.hour)}:${two(d.minute)}';
    } catch (_) {
      return raw;
    }
  }
}

// ============================================================================
// _StatusPill — small status pill
// ============================================================================

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    Color bg = LaColors.statusNeutralBg;
    Color fg = LaColors.statusNeutralFg;
    if (s == 'paid' || s == 'completed') {
      bg = LaColors.statusApprovedBg;
      fg = LaColors.statusApprovedFg;
    } else if (s == 'draft' || s == 'pending') {
      bg = LaColors.statusPendingBg;
      fg = LaColors.statusPendingFg;
    } else if (s == 'rejected' || s == 'cancelled') {
      bg = LaColors.statusRejectedBg;
      fg = LaColors.statusRejectedFg;
    } else if (s.contains('payment') || s.contains('review')) {
      bg = LaColors.statusInfoBg;
      fg = LaColors.statusInfoFg;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(LaRadius.pill),
      ),
      child: Text(
        status,
        style: LaText.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
