// ============================================================================
// request_detail_step2.dart
// ============================================================================
// Step 2 — ค่ายอดสัญญา (Payment) — read-only view
// - ใช้ ViewModel: LicenseRequestDetailStep2ViewModel (./viewmodels/...)
// - ใช้ Service: LicenseRequestBillingService (./services/...)
// - เรียก API: GET {domain_v1}/admin/requests/{uuid}/prepayment
// - UI สไตล์เดียวกับ BillingTable (license_contract_page)
//   - DD-MM-YYYY date format
//   - Gradient add button
//   - Badge for term
//   - Pill for total (ยอดสุทธิ)
//   - Gradient grand total card
//   - Responsive width (เต็มจอ / ไม่จำกัด 1400)
// ============================================================================

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../services/license_request_billing_service.dart';
import '../../viewmodels/license_request_detail_step2_view_model.dart';
import '../theme/license_request_theme.dart';

// ============================================================================
// Main widget — wrap with ChangeNotifierProvider ใน parent (license_request_detail_page)
// ============================================================================

class RequestDetailStep2 extends StatefulWidget {
  /// UUID ของ Request (มาจาก ReviewModel.newRequest.requestUuid)
  /// ใช้สำหรับ GET /admin/requests/{uuid}/prepayment
  final String? requestUuid;

  const RequestDetailStep2({super.key, this.requestUuid});

  @override
  State<RequestDetailStep2> createState() => _RequestDetailStep2State();
}

class _RequestDetailStep2State extends State<RequestDetailStep2> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<LicenseRequestDetailStep2ViewModel>();
      final uuid = widget.requestUuid?.trim() ?? '';
      if (uuid.isNotEmpty) {
        vm.loadFromUuid(uuid);
      } else {
        vm.disposeState();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseRequestDetailStep2ViewModel>();

    if (vm.isLoading && vm.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(LrSpace.lg),
      child: Column(
        // ✅ stretch: บังคับให้ children ทุกตัวขยายเต็มความกว้างแนวนอน
        // ทำให้ตาราง + Grand Total Card เต็มจอ edge-to-edge
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Toolbar (gradient add + counter) ───
          Row(
            children: [
              _GradientAddButton(onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('โหมดดูอย่างเดียว — ไม่สามารถเพิ่มรายการได้'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }),
              const SizedBox(width: 12),
              _RowCounter(count: vm.items.length),
              const Spacer(),
              if (vm.items.isNotEmpty)
                Text(
                  'รวม ${vm.items.length} รายการ',
                  style: LrText.caption,
                ),
            ],
          ),
          const SizedBox(height: LrSpace.md),

          // ─── Main Table / Empty State ───
          if (vm.items.isEmpty) _EmptyState() else _buildTable(vm.items),
          const SizedBox(height: LrSpace.md),

          // ─── Grand Total Card ───
          if (vm.items.isNotEmpty) _buildGrandTotal(vm.items),
        ],
      ),
    );
  }

  Widget _buildTable(List<BillingItem> items) {
    // ─── Responsive width: รองรับทุกขนาดหน้าจอ ───
    // - Mobile/Small (< 600px):   minWidth = 1100 (scroll แนวนอน)
    // - Tablet (600-1200px):       minWidth = mediaWidth (เต็มจอ)
    // - Desktop (≥ 1200px):        minWidth = mediaWidth - 320 (ลบ sidebar)
    final mediaWidth = MediaQuery.of(context).size.width;
    final tableWidth = (mediaWidth < 600
            ? 1100.0
            : (mediaWidth < 1200 ? mediaWidth : mediaWidth - 320)
                .clamp(1100, 5000))
        .toDouble();

    return Container(
      decoration: LrDecor.card(),
      clipBehavior: Clip.antiAlias,
      // ✅ ใช้ SizedBox(width: double.infinity) บังคับให้ Container ขยายเต็มจอ
      // แล้ว SingleChildScrollView ข้างในจะ scroll แนวนอนเมื่อ content ยาวเกิน
      width: double.infinity,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        }),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: tableWidth),
            child: DataTable(
              columnSpacing: 22,
              headingRowHeight: 46,
              dataRowMinHeight: 56,
              dataRowMaxHeight: 68,
              headingRowColor:
                  MaterialStateColor.resolveWith((_) => LrColors.surfaceMuted),
              headingTextStyle: LrText.tableHeader,
              dataTextStyle: LrText.tableCell,
              dividerThickness: 0.6,
              showBottomBorder: true,
              columns: const [
                DataColumn(label: Text('ประเภทค่าบริการ')),
                DataColumn(label: Text('ความถี่')),
                DataColumn(label: Text('จำนวนงวด'), numeric: true),
                DataColumn(label: Text('วันเริ่มต้น')),
                DataColumn(label: Text('ยอด (บาท)'), numeric: true),
                DataColumn(label: Text('ประเภท VAT')),
                DataColumn(label: Text('VAT'), numeric: true),
                DataColumn(label: Text('ประเภท WHT')),
                DataColumn(label: Text('WHT'), numeric: true),
                DataColumn(label: Text('ยอดสุทธิ'), numeric: true),
                DataColumn(label: Text('')),
              ],
              rows: List<DataRow>.generate(
                items.length,
                (i) => _buildRow(i, items[i]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(int i, BillingItem row) {
    final isAlt = i.isEven;
    return DataRow(
      color: MaterialStateColor.resolveWith(
        (_) => isAlt ? LrColors.cardBg : LrColors.surfaceMuted.withOpacity(.5),
      ),
      cells: [
        // 1. ประเภทค่าบริการ (read-only)
        DataCell(
          Container(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              row.expname.isEmpty ? '-' : row.expname,
              style: LrText.tableCell.copyWith(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        // 2. ความถี่ (read-only)
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: LrColors.surfaceMuted.withOpacity(.5),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: LrColors.border),
            ),
            child: Text(
              row.unit.isEmpty ? '-' : row.unit,
              style: LrText.tableCell.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        // 3. จำนวนงวด (Badge)
        DataCell(
          Center(
              child: _Badge(
                  text: row.term,
                  tone: LrColors.primaryDark,
                  bg: LrColors.primaryLight)),
        ),
        // 4. วันเริ่มต้น (date picker style — read-only)
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: LrColors.surfaceMuted,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: LrColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.event_outlined,
                    size: 14, color: LrColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  row.sdate.isEmpty ? 'เลือกวันที่' : _formatDate(row.sdate),
                  style: LrText.tableCell.copyWith(
                    color: row.sdate.isEmpty
                        ? LrColors.textMuted
                        : LrColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        // 5. ยอด (บาท) (read-only text)
        DataCell(
          SizedBox(
            width: 90,
            child: Text(
              _formatMoney(row.amount),
              textAlign: TextAlign.right,
              style: LrText.tableCell.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        // 6. ประเภท VAT (read-only)
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: LrColors.surfaceMuted.withOpacity(.5),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: LrColors.border),
            ),
            child: Text(
              row.vatRate > 0 ? 'มี' : 'ไม่มี',
              style: LrText.tableCell.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        // 7. VAT value
        DataCell(
          Text(
            row.vatRate.toStringAsFixed(2),
            textAlign: TextAlign.right,
            style: LrText.tableCell,
          ),
        ),
        // 8. ประเภท WHT (read-only)
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: LrColors.surfaceMuted.withOpacity(.5),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: LrColors.border),
            ),
            child: Text(
              row.whtRate > 0 ? 'มี' : 'ไม่มี',
              style: LrText.tableCell.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        // 9. WHT value
        DataCell(
          Text(
            row.whtRate.toStringAsFixed(2),
            textAlign: TextAlign.right,
            style: LrText.tableCell,
          ),
        ),
        // 10. ยอดสุทธิ (pill badge)
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: LrColors.primaryLight,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              _formatMoney(row.net),
              textAlign: TextAlign.right,
              style: LrText.tableCell.copyWith(
                fontWeight: FontWeight.w700,
                color: LrColors.primaryDark,
              ),
            ),
          ),
        ),
        // 11. Action (read-only: just info icon)
        DataCell(
          IconButton(
            tooltip: 'อ่านอย่างเดียว',
            icon: const Icon(Icons.visibility_outlined,
                color: LrColors.textMuted, size: 20),
            onPressed: null,
          ),
        ),
      ],
    );
  }

  Widget _buildGrandTotal(List<BillingItem> items) {
    final total = items.fold(0.0, (sum, e) => sum + e.net);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: LrSpace.lg, vertical: LrSpace.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            LrColors.primaryLight.withOpacity(.6),
            LrColors.primary.withOpacity(.08),
          ],
        ),
        borderRadius: BorderRadius.circular(LrRadius.lg),
        border: Border.all(color: LrColors.primary.withOpacity(.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: LrColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.summarize_rounded,
                    size: 18, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('ยอดรวมทั้งหมด', style: LrText.label),
                  const SizedBox(height: 2),
                  Text(
                    'รวม ${items.length} รายการ',
                    style: LrText.caption,
                  ),
                ],
              ),
            ],
          ),
          Text(
            '${total.toStringAsFixed(2)} บาท',
            style: const TextStyle(
              fontFamily: LrText.fontBold,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: LrColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMoney(double v) => NumberFormat("#,##0.00", "en_US").format(v);

  /// ใช้ format DD-MM-YYYY (มี dash) ให้ตรงกับ BillingTable
  String _formatDate(String raw) {
    if (raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd-MM-yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }
}

// ============================================================================
// Sub widgets (เลียนแบบ billing_table.dart)
// ============================================================================

class _GradientAddButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _GradientAddButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(LrRadius.md),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [LrColors.primary, LrColors.primaryAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(LrRadius.md),
            boxShadow: [
              BoxShadow(
                color: LrColors.primary.withOpacity(.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text(
                  'เพิ่มรายการ',
                  style: TextStyle(
                    fontFamily: LrText.fontBold,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color tone;
  final Color bg;
  const _Badge({required this.text, required this.tone, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: LrText.fontBold,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: tone,
        ),
      ),
    );
  }
}

class _RowCounter extends StatelessWidget {
  final int count;
  const _RowCounter({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: LrColors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: LrColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.list_alt_rounded,
              size: 14, color: LrColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            'จำนวน $count แถว',
            style: LrText.caption.copyWith(
              color: LrColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LrSpace.lg),
      decoration: LrDecor.card(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: LrColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_rounded,
                size: 32, color: LrColors.primary),
          ),
          const SizedBox(height: LrSpace.md),
          const Text('ยังไม่มีรายการค่าบริการ', style: LrText.h2),
          const SizedBox(height: 6),
          const Text('กดปุ่ม "เพิ่มรายการ" เพื่อเริ่มต้น',
              style: LrText.bodyMuted),
        ],
      ),
    );
  }
}
