// ============================================================================
// payment_detail_step1.dart
// ============================================================================
// Step 1 — ตรวจสอบรายการรับชำระ
// Layout แบบ 2 คอลัมน์ (icon + label + value) เหมือน fact_check
// Render PaymentDetail ที่โหลดจาก VM (uuid ถูกส่งมาตอนกด เรียกดู จาก list page)
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../unity/FormatPhone.dart';
import '../../models/license_payment_detail_model.dart';
import '../../models/license_prepayment_model.dart' hide formatMoney;
import '../theme/license_payment_theme.dart';
import '../../viewmodels/license_payment_detail_view_model.dart';

class PaymentDetailStep1 extends StatelessWidget {
  const PaymentDetailStep1({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicensePaymentDetailViewModel>();

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
                  gradient: LinearGradient(
                    colors: [
                      LaColors.primaryLight.withOpacity(.35),
                      LaColors.primaryLight.withOpacity(.1),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(LaRadius.md),
                  border: Border.all(color: LaColors.primary.withOpacity(.15)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: LaColors.primaryDark,
                        borderRadius: BorderRadius.circular(LaRadius.sm),
                      ),
                      child: const Icon(Icons.receipt_long_rounded,
                          size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: LaSpace.sm),
                    const Text(
                      'ตรวจสอบรายการรับชำระ',
                      style: LaText.h2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LaSpace.md),

              // ─── Loading / Error / Data ───
              if (vm.isLoading && vm.detail == null)
                const _LoadingBlock()
              else if (vm.errorMessage != null && vm.detail == null)
                _ErrorBlock(message: vm.errorMessage!)
              else if (vm.detail == null)
                _EmptyBlock(uuid: vm.detail?.uuid)
              else
                _PaymentSummaryCard(detail: vm.detail!),

              const SizedBox(height: LaSpace.lg),

              // ─── Prepayment (การจ่ายล่วงหน้า) ───
              if (vm.prepayment != null) ...[
                _PrepaymentCard(
                  prepayment: vm.prepayment!,
                  payments: vm.payments?.data ?? const [],
                  onProceed: vm.proceedToPayment,
                ),
                const SizedBox(height: LaSpace.lg),
              ],

              // ─── สถานะการชำระ (จาก GET .../payments) ───
              if (vm.payments != null) ...[
                _PaymentStatusCard(
                  payments: vm.payments!,
                  details: vm.prepayment?.details ?? const [],
                ),
                const SizedBox(height: LaSpace.lg),
              ],

              // ─── Footer note ───
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
        ),
      ),
    );
  }
}

// ============================================================================
// Summary card — 2 columns (info item pattern)
// ============================================================================

class _PaymentSummaryCard extends StatelessWidget {
  final PaymentDetail detail;
  const _PaymentSummaryCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    final d = detail;
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header row: status + uuid ───
          Row(
            children: [
              _StatusBadge(label: d.statusLabel),
              const Spacer(),
              _PillIcon(
                icon: Icons.tag_rounded,
                text: 'UUID: ${_short(d.uuid)}',
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
                      label: 'เลขที่สัญญา',
                      value: d.paymentNo,
                    ),
                    _InfoItem(
                      icon: Icons.calendar_today_rounded,
                      label: 'วันที่สิ้นสุด',
                      value: _formatDate(d.paidAt),
                    ),
                    _InfoItem(
                      icon: Icons.location_on_rounded,
                      label: 'บริเวณ / โซน',
                      value: d.payType,
                    ),
                    _InfoItem(
                      icon: Icons.numbers_rounded,
                      label: 'รหัสพื้นที่',
                      value: d.methodName,
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
                      value: d.payerName,
                    ),
                    _InfoItem(
                      icon: Icons.phone_rounded,
                      label: 'เบอร์โทร',
                      value: formatPhoneNumber(d.clientTel),
                      mono: true,
                    ),
                    _InfoItem(
                      icon: Icons.confirmation_number_rounded,
                      label: 'เลขประจำตัวผู้เสียภาษี',
                      value: d.clientTax,
                      mono: true,
                    ),
                    _InfoItem(
                      icon: Icons.place_rounded,
                      label: 'ที่อยู่',
                      value: d.clientAddr,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
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

  String _short(String uuid) {
    if (uuid.isEmpty) return '-';
    if (uuid.length <= 12) return uuid;
    return '${uuid.substring(0, 8)}…';
  }
}

// ============================================================================
// Prepayment card — รายการจ่ายล่วงหน้า (from GET .../prepayment)
// ============================================================================

class _PrepaymentCard extends StatelessWidget {
  final PrepaymentData prepayment;
  final List<PaymentDetail> payments;
  final void Function(PrepaymentItem item) onProceed;
  const _PrepaymentCard({
    required this.prepayment,
    this.payments = const [],
    required this.onProceed,
  });

  /// สถานะของแต่ละรายการจ่ายล่วงหน้า (join กับรายการชำระ)
  /// - มี payment ที่ status=paid   → ชำระแล้ว
  /// - มี payment (draft/อื่นๆ)      → รอชำระ
  /// - ไม่มี payment เลย             → ยังไม่ทำรายการ
  String statusOf(PrepaymentItem item) {
    PaymentDetail? matched;
    for (final p in payments) {
      if (p.debtLineUuid == item.uuid) {
        matched = p;
        break;
      }
    }
    if (matched == null) return 'ยังไม่ทำรายการ';
    return matched.statusLabel;
  }

  @override
  Widget build(BuildContext context) {
    final items = prepayment.details;
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ───
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: LaColors.primaryLight,
                  borderRadius: BorderRadius.circular(LaRadius.sm),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    size: 18, color: LaColors.primaryDark),
              ),
              const SizedBox(width: LaSpace.sm),
              Text('รายการจ่ายล่วงหน้า', style: LaText.h2),
              if (items.isNotEmpty) ...[
                const SizedBox(width: LaSpace.sm),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: LaColors.primaryLight,
                    borderRadius: BorderRadius.circular(LaRadius.pill),
                  ),
                  child: Text(
                    '${items.length} รายการ',
                    style: LaText.caption.copyWith(
                      color: LaColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              _PillIcon(
                icon: Icons.tag_rounded,
                text: 'Prepay: ${_short(prepayment.uuid ?? '')}',
                muted: true,
              ),
            ],
          ),
          const SizedBox(height: LaSpace.md),

          if (prepayment.requestUuid != null &&
              prepayment.requestUuid!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: LaSpace.md),
              child: _InfoItem(
                icon: Icons.link_rounded,
                label: 'Request UUID',
                value: prepayment.requestUuid,
                mono: true,
              ),
            ),

          // ─── รายการ (ตารางบนจอกว้าง / การ์ดบนจอแคบ) ───
          if (items.isEmpty)
            Container(
              padding: const EdgeInsets.all(LaSpace.lg),
              decoration: LaDecor.softCard(),
              child: const Center(
                child: Text('ไม่พบรายการจ่ายล่วงหน้า', style: LaText.bodyMuted),
              ),
            )
          else
            _PrepaymentList(
              items: items,
              statusOf: statusOf,
              onProceed: onProceed,
            ),

          const SizedBox(height: LaSpace.md),

          // ─── Grand total ───
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: LaSpace.md, vertical: LaSpace.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  LaColors.primaryLight,
                  LaColors.primaryLight.withOpacity(.5),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(LaRadius.md),
              border: Border.all(color: LaColors.primary.withOpacity(.18)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: LaColors.primaryDark,
                    borderRadius: BorderRadius.circular(LaRadius.sm),
                  ),
                  child: const Icon(Icons.summarize_rounded,
                      size: 18, color: Colors.white),
                ),
                const SizedBox(width: LaSpace.sm),
                Text('รวมทั้งสิ้น', style: LaText.body),
                const Spacer(),
                Text(
                  prepayment.grandTotalDisplay,
                  style: LaText.h2.copyWith(
                    color: LaColors.primaryDark,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _short(String uuid) {
    if (uuid.isEmpty) return '-';
    if (uuid.length <= 12) return uuid;
    return '${uuid.substring(0, 8)}…';
  }
}

/// จุดตัดเปลี่ยนจากตารางเป็นการ์ด (px) — จอแคบกว่านี้ใช้การ์ดแทน
const double _prepayBreakpoint = 700;

class _PrepaymentList extends StatelessWidget {
  final List<PrepaymentItem> items;
  final String Function(PrepaymentItem) statusOf;
  final void Function(PrepaymentItem) onProceed;
  const _PrepaymentList({
    required this.items,
    required this.statusOf,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _prepayBreakpoint) {
          // ─── จอแคบ: แสดงเป็นการ์ดแถวละ 1 รายการ ───
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(height: LaSpace.sm),
                _PrepaymentItemCard(
                  item: items[i],
                  status: statusOf(items[i]),
                  onProceed: onProceed,
                ),
              ],
            ],
          );
        }
        // ─── จอกว้าง: แสดงเป็นตาราง ───
        return _PrepaymentTable(
          items: items,
          statusOf: statusOf,
          onProceed: onProceed,
        );
      },
    );
  }
}

class _PrepaymentTable extends StatelessWidget {
  final List<PrepaymentItem> items;
  final String Function(PrepaymentItem) statusOf;
  final void Function(PrepaymentItem) onProceed;
  const _PrepaymentTable({
    required this.items,
    required this.statusOf,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LaDecor.softCard(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row
          Container(
            color: LaColors.surfaceMuted,
            padding: const EdgeInsets.symmetric(
                horizontal: LaSpace.md, vertical: LaSpace.sm),
            child: Row(
              children: [
                Expanded(
                    flex: 3, child: Text('รายการ', style: LaText.tableHeader)),
                Expanded(
                    flex: 2, child: Text('สถานะ', style: LaText.tableHeader)),
                Expanded(
                    flex: 1, child: Text('หน่วย', style: LaText.tableHeader)),
                Expanded(
                    flex: 1, child: Text('งวด', style: LaText.tableHeader)),
                Expanded(
                    flex: 1, child: Text('จำนวน', style: LaText.tableHeader)),
                Expanded(
                    flex: 2, child: Text('วันที่', style: LaText.tableHeader)),
                Expanded(
                    flex: 2,
                    child: Text('รวม',
                        style: LaText.tableHeader, textAlign: TextAlign.right)),
                const SizedBox(width: 20),
                const SizedBox(width: 150),
              ],
            ),
          ),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: LaColors.border),
            _PrepaymentRow(
              item: items[i],
              status: statusOf(items[i]),
              onProceed: onProceed,
            ),
          ],
        ],
      ),
    );
  }
}

class _PrepaymentRow extends StatelessWidget {
  final PrepaymentItem item;
  final String status;
  final void Function(PrepaymentItem) onProceed;
  const _PrepaymentRow({
    required this.item,
    required this.status,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    final date = (item.sdate ?? '').isNotEmpty || (item.ldate ?? '').isNotEmpty
        ? '${formatPrepayDate(item.sdate)} - ${formatPrepayDate(item.ldate)}'
        : '-';
    final shortUuid =
        item.uuid.length > 8 ? '${item.uuid.substring(0, 8)}…' : item.uuid;
    return InkWell(
      onTap: () => onProceed(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: LaSpace.md, vertical: LaSpace.sm),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: LaColors.primaryLight,
                      borderRadius: BorderRadius.circular(LaRadius.sm),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      size: 16,
                      color: LaColors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: LaSpace.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item.expname, style: LaText.tableCell),
                        if (item.uuid.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              children: [
                                const Text('รหัส ', style: LaText.caption),
                                Text(shortUuid,
                                    style: LaText.caption.copyWith(
                                      fontFamily: 'monospace',
                                      color: LaColors.textMuted,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(flex: 2, child: Text(status, style: LaText.tableCell)),
            Expanded(flex: 1, child: Text(item.unit, style: LaText.tableCell)),
            Expanded(
                flex: 1,
                child: Text(item.term ?? '-', style: LaText.tableCell)),
            Expanded(
                flex: 1, child: Text(item.qty ?? '-', style: LaText.tableCell)),
            Expanded(flex: 2, child: Text(date, style: LaText.tableCell)),
            Expanded(
              flex: 2,
              child: Text(
                item.totalDisplay,
                style: LaText.tableCell.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                  color: LaColors.primaryDark,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 20),
            SizedBox(
              width: 150,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _ActionButton(
                  status: status,
                  onPressed: () => onProceed(item),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrepaymentItemCard extends StatelessWidget {
  final PrepaymentItem item;
  final String status;
  final void Function(PrepaymentItem) onProceed;
  const _PrepaymentItemCard({
    required this.item,
    required this.status,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    final date = (item.sdate ?? '').isNotEmpty || (item.ldate ?? '').isNotEmpty
        ? '${formatPrepayDate(item.sdate)} - ${formatPrepayDate(item.ldate)}'
        : '-';
    final shortUuid =
        item.uuid.length > 8 ? '${item.uuid.substring(0, 8)}…' : item.uuid;
    return InkWell(
      onTap: () => onProceed(item),
      borderRadius: BorderRadius.circular(LaRadius.md),
      child: Container(
        decoration: LaDecor.softCard(),
        padding: const EdgeInsets.all(LaSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: LaColors.primaryLight,
                    borderRadius: BorderRadius.circular(LaRadius.sm),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    size: 16,
                    color: LaColors.primaryDark,
                  ),
                ),
                const SizedBox(width: LaSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.expname, style: LaText.body),
                      if (item.uuid.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            children: [
                              const Text('รหัส ', style: LaText.caption),
                              Text(shortUuid,
                                  style: LaText.caption.copyWith(
                                    fontFamily: 'monospace',
                                    color: LaColors.textMuted,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: LaSpace.sm),
                Text(
                  item.totalDisplay,
                  style: LaText.body.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                    color: LaColors.primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: LaSpace.sm),
            Row(
              children: [
                Expanded(
                  child: _MiniField(label: 'หน่วย', value: item.unit),
                ),
                Expanded(
                  child: _MiniField(label: 'งวด', value: item.term ?? '-'),
                ),
                Expanded(
                  child: _MiniField(label: 'จำนวน', value: item.qty ?? '-'),
                ),
              ],
            ),
            const SizedBox(height: LaSpace.sm),
            Row(
              children: [
                Expanded(child: _MiniField(label: 'วันที่', value: date)),
                const SizedBox(width: LaSpace.sm),
                _ActionButton(
                  status: status,
                  onPressed: () => onProceed(item),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniField extends StatelessWidget {
  final String label;
  final String value;
  const _MiniField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: LaSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: LaText.label),
          const SizedBox(height: 2),
          Text(
            value,
            style: LaText.tableCell,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Payment status card — สถานะรายการชำระ (จาก GET .../payments)
// ============================================================================

class _PaymentStatusCard extends StatelessWidget {
  final RequestPaymentsResponse payments;
  final List<PrepaymentItem> details;
  const _PaymentStatusCard({
    required this.payments,
    this.details = const [],
  });

  @override
  Widget build(BuildContext context) {
    final items = payments.data;
    final paidCount =
        items.where((e) => e.status.toLowerCase() == 'paid').length;

    // ─── join ชื่อรายการ (expname) จาก prepayment detail ───
    // payment.debtLineUuid → prepayment detail.uuid → expname
    final nameByLine = <String, String>{};
    for (final d in details) {
      if (d.uuid.isNotEmpty) nameByLine[d.uuid] = d.expname;
    }

    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ───
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: LaColors.statusInfoBg,
                  borderRadius: BorderRadius.circular(LaRadius.sm),
                ),
                child: const Icon(Icons.receipt_long_rounded,
                    size: 18, color: LaColors.statusInfoFg),
              ),
              const SizedBox(width: LaSpace.sm),
              Text('สถานะการชำระ', style: LaText.h2),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration:
                    LaDecor.pill(LaColors.surfaceMuted, LaColors.textSecondary),
                child: Text(
                  'ชำระแล้ว $paidCount / ${items.length}',
                  style: LaText.caption.copyWith(
                    color: LaColors.textSecondary,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: LaSpace.md),

          if (items.isEmpty)
            Container(
              padding: const EdgeInsets.all(LaSpace.lg),
              decoration: LaDecor.softCard(),
              child: const Center(
                child: Text('ไม่พบรายการชำระ', style: LaText.bodyMuted),
              ),
            )
          else
            ...items.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: LaSpace.sm),
                  child: _PaymentStatusRow(
                    payment: p,
                    itemName: nameByLine[p.debtLineUuid] ?? '',
                  ),
                )),
        ],
      ),
    );
  }
}

class _PaymentStatusRow extends StatelessWidget {
  final PaymentDetail payment;
  final String itemName;
  const _PaymentStatusRow({
    required this.payment,
    this.itemName = '',
  });

  @override
  Widget build(BuildContext context) {
    final p = payment;
    return Container(
      decoration: LaDecor.softCard(),
      padding: const EdgeInsets.all(LaSpace.md),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: LaColors.statusInfoBg,
              borderRadius: BorderRadius.circular(LaRadius.sm),
            ),
            child: const Icon(Icons.payments_outlined,
                size: 18, color: LaColors.statusInfoFg),
          ),
          const SizedBox(width: LaSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  p.paymentNo.isNotEmpty ? p.paymentNo : '-',
                  style: LaText.h2.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${itemName.isNotEmpty ? itemName : '-'}  •  '
                  '${_formatSystem(p.paymentSystem)}  •  ${formatMoney(p.amount)}',
                  style: LaText.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: LaSpace.sm),
          _StatusBadge(label: p.statusLabel),
        ],
      ),
    );
  }

  String _formatSystem(String s) {
    final v = (s).toLowerCase();
    if (v == 'internal') return 'ในระบบ';
    if (v == 'external') return 'ภายนอก';
    return s.isEmpty ? '-' : s;
  }
}

// ============================================================================
// Sub widgets
// ============================================================================

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

class _ActionButton extends StatelessWidget {
  final String status;
  final VoidCallback onPressed;
  const _ActionButton({required this.status, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    final notStarted = s.contains('ยังไม่') || s.isEmpty;

    if (notStarted) {
      // ─── filled primary (ต้องจ่าย) ───
      return InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(LaRadius.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: LaColors.primaryDark,
            borderRadius: BorderRadius.circular(LaRadius.sm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.payments_rounded, size: 14, color: Colors.white),
              SizedBox(width: 4),
              Text(
                'ชำระเงิน',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ─── outlined (ทำรายการต่อ) ───
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(LaRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(LaRadius.sm),
          border: Border.all(color: LaColors.primaryDark, width: 1.4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'ทำรายการต่อ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: LaColors.primaryDark,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.arrow_forward_rounded,
                size: 14, color: LaColors.primaryDark),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  const _StatusBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final s = label.toLowerCase();
    Color fg;
    if (s.contains('อนุมัติ') ||
        s.contains('approved') ||
        s.contains('pass') ||
        s.contains('ชำระแล้ว') ||
        s.contains('เสร็จ')) {
      fg = LaColors.statusApprovedFg;
    } else if (s.contains('ปฏิเสธ') ||
        s.contains('reject') ||
        s.contains('cancel') ||
        s.contains('ยกเลิก')) {
      fg = LaColors.statusRejectedFg;
    } else if (s.contains('รอ') ||
        s.contains('pending') ||
        s.contains('progress') ||
        s.contains('กำลัง')) {
      fg = LaColors.statusPendingFg;
    } else {
      fg = LaColors.statusNeutralFg;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: fg.withOpacity(.1),
        borderRadius: BorderRadius.circular(LaRadius.pill),
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
            label.isEmpty ? '-' : label,
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
          Text('กำลังโหลดรายการรับชำระ...', style: LaText.bodyMuted),
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
          TextButton(
            onPressed: () =>
                context.read<LicensePaymentDetailViewModel>().reload(),
            child: const Text('ลองใหม่'),
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
                ? 'ไม่พบข้อมูลรายการ (uuid: ${uuid!.substring(0, uuid!.length.clamp(0, 8))})'
                : 'ไม่พบข้อมูลรายการ',
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
