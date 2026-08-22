// ============================================================================
// payment_detail_step2.dart
// ============================================================================
// Step 2 — ใบเสร็จรับเงิน (A4 layout)
// โหลด GET /v2/payments/{uuid}/receipt แล้ว render เป็นกระดาษ A4
// ============================================================================

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../unity/FormatPhone.dart';
import '../../models/license_payment_detail_model.dart';
import '../../services/license_payment_detail_service.dart';
import '../theme/license_payment_theme.dart';
import '../../viewmodels/license_payment_detail_view_model.dart';

class PaymentDetailStep2 extends StatefulWidget {
  const PaymentDetailStep2({super.key});

  @override
  State<PaymentDetailStep2> createState() => _PaymentDetailStep2State();
}

class _PaymentDetailStep2State extends State<PaymentDetailStep2> {
  bool _didAutoLoad = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicensePaymentDetailViewModel>();

    // ─── ถ้ายังไม่มี receipt uuid ให้ลองหา payment paid อันแรกอัตโนมัติ ───
    final targetUuid = vm.receiptUuid ?? _autoPickPaidUuid(vm);
    if (!_didAutoLoad && !vm.isReceiptLoading && vm.receipt == null) {
      final auto = targetUuid;
      if (auto != null && auto.isNotEmpty) {
        _didAutoLoad = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          vm.loadReceipt(uuid: auto);
        });
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(LaSpace.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StepHeader(targetUuid: targetUuid, vm: vm),
              const SizedBox(height: LaSpace.md),
              _ReceiptBody(uuid: targetUuid),
            ],
          ),
        ),
      ),
    );
  }

  String? _autoPickPaidUuid(LicensePaymentDetailViewModel vm) {
    final list = vm.payments?.data ?? const [];
    for (final p in list) {
      if (p.status.toLowerCase() == 'paid' && p.uuid.isNotEmpty) {
        return p.uuid;
      }
    }
    // fallback: detail.uuid (request-level)
    final detailUuid = vm.detail?.uuid;
    return (detailUuid != null && detailUuid.isNotEmpty) ? detailUuid : null;
  }
}

class _StepHeader extends StatelessWidget {
  final String? targetUuid;
  final LicensePaymentDetailViewModel vm;
  const _StepHeader({required this.targetUuid, required this.vm});

  @override
  Widget build(BuildContext context) {
    final uuid = targetUuid ?? '';
    return Container(
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
          const Text('ใบเสร็จรับเงิน', style: LaText.h2),
          const Spacer(),
          if (uuid.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: LaColors.surfaceMuted,
                borderRadius: BorderRadius.circular(LaRadius.pill),
                border: Border.all(color: LaColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.tag_rounded,
                      size: 13, color: LaColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'Payment: ${_short(uuid)}',
                    style: LaText.caption.copyWith(
                      color: LaColors.textSecondary,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: LaSpace.sm),
          IconButton(
            tooltip: 'รีโหลด',
            icon: const Icon(Icons.refresh_rounded, size: 18),
            onPressed: uuid.isEmpty ? null : () => vm.loadReceipt(uuid: uuid),
          ),
        ],
      ),
    );
  }

  String _short(String uuid) {
    if (uuid.length <= 12) return uuid;
    return '${uuid.substring(0, 8)}…';
  }
}

class _ReceiptBody extends StatelessWidget {
  final String? uuid;
  const _ReceiptBody({required this.uuid});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicensePaymentDetailViewModel>();

    if ((uuid ?? '').isEmpty) {
      return const _EmptyState(
        icon: Icons.help_outline_rounded,
        title: 'ยังไม่ได้เลือกรายการชำระ',
        subtitle: 'กลับไป Step 1 แล้วกดปุ่ม "ดูใบเสร็จ" ในรายการที่ชำระแล้ว',
      );
    }
    if (vm.isReceiptLoading && vm.receipt == null) {
      return const _LoadingState();
    }
    if (vm.receiptError != null && vm.receipt == null) {
      return _ErrorState(
        message: vm.receiptError!,
        onRetry: () => vm.loadReceipt(uuid: uuid),
      );
    }
    final r = vm.receipt;
    if (r == null) {
      return _EmptyState(
        icon: Icons.inbox_rounded,
        title: 'ยังไม่มีใบเสร็จ',
        subtitle: 'รายการนี้อาจยังไม่ถูกบันทึกการรับชำระ',
        actionLabel: 'ลองโหลดใหม่',
        onAction: () => vm.loadReceipt(uuid: uuid),
      );
    }
    return _A4Paper(receipt: r);
  }
}

class _A4Paper extends StatelessWidget {
  final PaymentReceipt receipt;
  const _A4Paper({required this.receipt});

  // ─── A4 ratio = 210 : 297 ───
  static const double _a4Ratio = 210 / 297;

  @override
  Widget build(BuildContext context) {
    final r = receipt;
    return Center(
      child: LayoutBuilder(
        builder: (ctx, c) {
          // กระดาษเต็มความกว้าง (≤ 794 px) บน mobile, จำกัด 794 px บน desktop
          final maxWidth = c.maxWidth < 794 ? c.maxWidth : 794.0;
          final paperWidth = maxWidth.toDouble();
          final paperHeight = paperWidth / _a4Ratio;
          return Container(
            width: paperWidth,
            constraints: BoxConstraints(minHeight: paperHeight),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.08),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            padding: const EdgeInsets.fromLTRB(36, 32, 36, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _a4Header(r),
                const SizedBox(height: 18),
                _a4PaymentMeta(r),
                const Divider(
                    height: 28, thickness: 1, color: Color(0xFFE5E7EB)),
                _a4Vendor(r),
                const SizedBox(height: 12),
                _a4Location(r),
                const Divider(
                    height: 28, thickness: 1, color: Color(0xFFE5E7EB)),
                _a4Items(r),
                const SizedBox(height: 12),
                _a4Totals(r),
                const SizedBox(height: 24),
                _a4Officer(r),
                const SizedBox(height: 18),
                _a4Footer(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ───────────────────── header ─────────────────────
  Widget _a4Header(PaymentReceipt r) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'images/cmm_logo3.png',
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: LaColors.primaryDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.account_balance_rounded,
                  color: Colors.white, size: 28),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ใบเสร็จรับเงิน',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'เทศบาลนครเชียงใหม่',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              r.receipt.receiptNo.isEmpty ? '-' : r.receipt.receiptNo,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _receiptDateLine(r),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _receiptDateLine(PaymentReceipt r) {
    final d = r.receipt.date.isNotEmpty
        ? _fmtDate(r.receipt.date)
        : (r.payment.paidAt ?? '');
    return d.isEmpty ? '' : 'วันที่: $d';
  }

  // ─────────────────── payment meta ───────────────────
  Widget _a4PaymentMeta(PaymentReceipt r) {
    final p = r.payment;
    final m = r.method;
    return Wrap(
      spacing: 18,
      runSpacing: 10,
      children: [
        _a4Field('เลขที่ชำระ', p.paymentNo.isEmpty ? '-' : p.paymentNo),
        _a4Field(
            'สถานะ',
            p.status.isEmpty
                ? '-'
                : p.status.toLowerCase() == 'paid'
                    ? 'ชำระเรียบร้อย'
                    : p.status),
        _a4Field(
            'ประเภท',
            r.receipt.payTypeLabel.isNotEmpty
                ? r.receipt.payTypeLabel
                : r.receipt.payType),
        _a4Field(
            'ช่องทาง',
            m == null
                ? '-'
                : (m.nameTh.isNotEmpty ? '${m.code} (${m.nameTh})' : m.code)),
        _a4Field('วันที่ชำระ',
            (p.paidAt?.isNotEmpty ?? false) ? _fmtDateTime(p.paidAt!) : '-'),
        _a4Field(
            'จำนวน',
            p.amountReceived != null
                ? '${formatMoney(p.amountReceived!)} บาท'
                : '-'),
      ],
    );
  }

  Widget _a4Field(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            )),
      ],
    );
  }

  // ───────────────────── vendor ─────────────────────
  Widget _a4Vendor(PaymentReceipt r) {
    final v = r.vendor;
    if (v == null) return const SizedBox.shrink();
    final addr = [v.addr1, v.addr2, v.zip].where((s) => s.isNotEmpty).join(' ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('ผู้ชำระเงิน'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 18,
          runSpacing: 8,
          children: [
            _a4Field('รหัส', v.custno.isEmpty ? '-' : v.custno),
            _a4Field('ชื่อ-สกุล', v.cname.isEmpty ? v.scname : v.cname),
            _a4Field('เลขประจำตัวผู้เสียภาษี', v.tax.isEmpty ? '-' : v.tax),
            _a4Field('โทร', v.tel.isEmpty ? '-' : formatPhoneNumber(v.tel)),
          ],
        ),
        if (addr.isNotEmpty) ...[
          const SizedBox(height: 8),
          _a4Field('ที่อยู่', addr),
        ],
      ],
    );
  }

  // ─────────────────── location ───────────────────
  Widget _a4Location(PaymentReceipt r) {
    final l = r.location;
    if (l == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('สถานที่'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 18,
          runSpacing: 8,
          children: [
            _a4Field('เขต', l.subzone.isEmpty ? l.zn : l.subzone),
            _a4Field('รหัสพื้นที่', l.ln.isEmpty ? '-' : l.ln),
            _a4Field(
                'เลขที่สัญญา', l.leaseNumber.isEmpty ? '-' : l.leaseNumber),
            _a4Field(
                'ระยะสัญญา',
                (l.sdate.isNotEmpty || l.ldate.isNotEmpty)
                    ? '${_fmtDateShort(l.sdate)} - ${_fmtDateShort(l.ldate)}'
                    : '-'),
          ],
        ),
      ],
    );
  }

  // ─────────────────── items table ───────────────────
  Widget _a4Items(PaymentReceipt r) {
    final fees = r.entries.fee;
    final fines = r.entries.fine;
    if (fees.isEmpty && fines.isEmpty) return const SizedBox.shrink();
    final all = <_ItemRow>[
      ...fees.map((e) => _ItemRow(e, false)),
      ...fines.map((e) => _ItemRow(e, true)),
    ];
    final cols = _detectColumns(all);
    if (cols.isEmpty) return const SizedBox.shrink();
    final rows = <Widget>[];
    rows.add(_itemsHeader(cols));
    for (var i = 0; i < all.length; i++) {
      rows.add(_itemsRow(i, all[i], cols));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('รายการ'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(6),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rows,
          ),
        ),
      ],
    );
  }

  /// ตรวจว่าแต่ละ row มี field ใดบ้างที่ "มีค่า" → คืนเฉพาะคอลัมน์ที่อย่างน้อย 1 แถวมี
  List<_ColDef> _detectColumns(List<_ItemRow> rows) {
    bool hasQty = false;
    bool hasUnit = false;
    bool hasSdate = false;
    bool hasLdate = false;
    bool hasAmt = false;
    for (final r in rows) {
      if (r.item.qty.isNotEmpty) hasQty = true;
      if (r.item.unit.isNotEmpty) hasUnit = true;
      if (r.item.sdate.isNotEmpty) hasSdate = true;
      if (r.item.ldate.isNotEmpty) hasLdate = true;
      if (_amountOf(r.item).isNotEmpty) hasAmt = true;
    }
    return _colDefsFromFlags(
      qty: hasQty,
      unit: hasUnit,
      sdate: hasSdate,
      ldate: hasLdate,
      amount: hasAmt,
    );
  }

  List<_ColDef> _colDefsFromFlags({
    required bool qty,
    required bool unit,
    required bool sdate,
    required bool ldate,
    required bool amount,
  }) {
    // ถ้ามีทั้ง sdate และ ldate → รวมเป็น "ระยะเวลา" คอลัมน์เดียว
    // ถ้ามีแค่ sdate หรือ ldate → แยกคนละคอลัมน์
    final cols = <_ColDef>[];
    if (qty) cols.add(const _ColDef('จำนวน', 64, alignRight: true));
    if (unit) cols.add(const _ColDef('หน่วย', 64));
    if (sdate && ldate) {
      cols.add(const _ColDef('ระยะเวลา', 160));
    } else {
      if (sdate) cols.add(const _ColDef('เริ่ม', 90));
      if (ldate) cols.add(const _ColDef('สิ้นสุด', 90));
    }
    if (amount) {
      cols.add(const _ColDef('จำนวนเงิน', 100, alignRight: true, mono: true));
    }
    return cols;
  }

  Widget _itemsHeader(List<_ColDef> cols) {
    return Container(
      color: const Color(0xFFF3F4F6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          const SizedBox(
              width: 28,
              child: Text('ลำดับ',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF374151)))),
          const Expanded(
              child: Text('รายการ',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF374151)))),
          for (final c in cols)
            SizedBox(
              width: c.width,
              child: Text(
                c.label,
                textAlign: c.alignRight ? TextAlign.right : TextAlign.start,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _itemsRow(int idx, _ItemRow row, List<_ColDef> cols) {
    final it = row.item;
    final period = (it.sdate.isNotEmpty || it.ldate.isNotEmpty)
        ? '${_fmtDateShort(it.sdate)} - ${_fmtDateShort(it.ldate)}'
        : '-';
    final amt = _amountOf(it);
    return Container(
      decoration: BoxDecoration(
        color: idx.isOdd ? const Color(0xFFFAFAFA) : Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          SizedBox(
              width: 28,
              child: Text(row.isFine ? '${idx + 1}*' : '${idx + 1}',
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF374151)))),
          Expanded(
              child: Text(it.name.isEmpty ? '-' : it.name,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827)))),
          for (final c in cols)
            SizedBox(
              width: c.width,
              child: Text(
                _cellValue(c, it, period, amt),
                textAlign: c.alignRight ? TextAlign.right : TextAlign.start,
                style: TextStyle(
                  fontSize: c.mono ? 12 : 11,
                  fontFamily: c.mono ? 'monospace' : null,
                  fontWeight: c.mono ? FontWeight.w700 : FontWeight.w400,
                  color: c.mono
                      ? const Color(0xFF111827)
                      : const Color(0xFF374151),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _cellValue(_ColDef c, ReceiptEntryItem it, String period, String amt) {
    switch (c.label) {
      case 'จำนวน':
        return it.qty.isEmpty ? '-' : it.qty;
      case 'หน่วย':
        return it.unit.isEmpty ? '-' : it.unit;
      case 'ระยะเวลา':
        return period;
      case 'เริ่ม':
        return _fmtDateShort(it.sdate);
      case 'สิ้นสุด':
        return _fmtDateShort(it.ldate);
      case 'จำนวนเงิน':
        return amt.isEmpty ? '-' : amt;
      default:
        return '-';
    }
  }

  String _amountOf(ReceiptEntryItem it) {
    if (it.amount > 0) return formatMoney(it.amount);
    if (it.amountInclVat.isNotEmpty) return it.amountInclVat;
    return it.amt;
  }

  // ───────────────────── totals ─────────────────────
  Widget _a4Totals(PaymentReceipt r) {
    final t = r.entries.totals;
    final fee = t.fee > 0 ? t.fee : r.payment.amount;
    final grand = t.grand > 0 ? t.grand : fee;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        children: [
          _totalsRow('ค่าธรรมเนียม', formatMoney(t.fee > 0 ? t.fee : fee)),
          _totalsRow('ค่าปรับ', formatMoney(t.fine)),
          const Divider(height: 16, thickness: 1, color: Color(0xFFE5E7EB)),
          _totalsRow('รวมทั้งสิ้น', '${formatMoney(grand)} บาท', bold: true),
        ],
      ),
    );
  }

  Widget _totalsRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                  fontSize: bold ? 14 : 12,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                  color: const Color(0xFF111827),
                )),
          ),
          Text(value,
              style: TextStyle(
                fontSize: bold ? 16 : 12,
                fontFamily: 'monospace',
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                color: bold ? LaColors.primaryDark : const Color(0xFF111827),
              )),
        ],
      ),
    );
  }

  // ─────────────────── officer + signature ───────────────────
  Widget _a4Officer(PaymentReceipt r) {
    final o = r.officer;
    if (o == null) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        SizedBox(
          width: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'ลงชื่อ ........................................................',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 6),
              _SignatureImage(signatureUuid: o.signature?.uuid ?? ''),
              const SizedBox(height: 4),
              Text(
                '(${o.fullName})',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              if (o.position?.nameTh.isNotEmpty == true)
                Text(
                  o.position!.nameTh,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              const SizedBox(height: 2),
              Text(
                'ผู้รับเงิน',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _a4Footer() {
    return Center(
      child: Text(
        'เอกสารนี้ออกโดยระบบ — Powered by Chaoperty CMS',
        style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
      ),
    );
  }

  // ─────────────────── section title ───────────────────
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: .4,
        color: LaColors.primaryDark,
      ),
    );
  }

  String _fmtDate(String s) {
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(s));
    } catch (_) {
      return s;
    }
  }

  String _fmtDateShort(String s) {
    try {
      return DateFormat('dd/MM/yy').format(DateTime.parse(s));
    } catch (_) {
      return s;
    }
  }

  String _fmtDateTime(String s) {
    try {
      return DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(s));
    } catch (_) {
      return s;
    }
  }
}

class _SignatureImage extends StatefulWidget {
  final String signatureUuid;
  const _SignatureImage({required this.signatureUuid});

  @override
  State<_SignatureImage> createState() => _SignatureImageState();
}

class _SignatureImageState extends State<_SignatureImage> {
  Uint8List? _bytes;
  bool _loading = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    if (widget.signatureUuid.isNotEmpty) _load();
  }

  @override
  void didUpdateWidget(covariant _SignatureImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.signatureUuid != widget.signatureUuid &&
        widget.signatureUuid.isNotEmpty) {
      _bytes = null;
      _failed = false;
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final b = await LicensePaymentDetailService()
          .previewSignature(signatureUuid: widget.signatureUuid);
      if (!mounted) return;
      setState(() {
        _bytes = b;
        _loading = false;
        _failed = b == null;
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
    const size = Size(160, 64);
    if (_loading) {
      return SizedBox(
        width: size.width,
        height: size.height,
        child: const Center(
          child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 1.6)),
        ),
      );
    }
    if (_bytes != null) {
      return SizedBox(
        width: size.width,
        height: size.height,
        child: Image.memory(_bytes!, fit: BoxFit.contain),
      );
    }
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Center(
        child: Text(
          _failed ? '(ไม่พบลายเซ็น)' : '(ไม่มีลายเซ็น)',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

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
            child: Icon(icon, size: 36, color: LaColors.primary),
          ),
          const SizedBox(height: LaSpace.md),
          Text(title, style: LaText.h2, textAlign: TextAlign.center),
          const SizedBox(height: LaSpace.sm),
          Text(subtitle, style: LaText.bodyMuted, textAlign: TextAlign.center),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: LaSpace.md),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(actionLabel!),
              style: FilledButton.styleFrom(
                backgroundColor: LaColors.primaryDark,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();
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
          Text('กำลังโหลดใบเสร็จ...', style: LaText.bodyMuted),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

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
            child: Text(message,
                style: LaText.body.copyWith(color: LaColors.statusRejectedFg)),
          ),
          TextButton(onPressed: onRetry, child: const Text('ลองใหม่')),
        ],
      ),
    );
  }
}

// ───────────────────── helpers ─────────────────────

/// 1 แถวในตาราง + flag isFine (ค่าปรับ)
class _ItemRow {
  final ReceiptEntryItem item;
  final bool isFine;
  const _ItemRow(this.item, this.isFine);
}

/// Definition ของคอลัมน์ที่จะแสดงในตาราง items
class _ColDef {
  final String label;
  final double width;
  final bool alignRight;
  final bool mono;
  const _ColDef(this.label, this.width,
      {this.alignRight = false, this.mono = false});
}
