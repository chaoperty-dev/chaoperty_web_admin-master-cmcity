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
//   - ใช้ Table widget (FlexColumnWidth) เพื่อให้คอลัมน์ขยายเต็มจอ
//   - Add dialog: ใช้ AddBillingTable (license_request_addbilling_table.dart)
//     → เพิ่มอย่างเดียว, ส่ง JSON กลับมารวมกับรายการเดิม
//   - ไม่มีการแก้ไขรายการ (edit) — มีแค่ เพิ่ม / ลบ
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../services/license_request_billing_service.dart';
import '../../viewmodels/license_request_detail_step2_view_model.dart';
import '../theme/license_request_theme.dart';
import 'license_request_addbilling_table.dart';

// ============================================================================
// Main widget
// ============================================================================

class RequestDetailStep2 extends StatefulWidget {
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Toolbar (gradient add + counter) ───
          Row(
            children: [
              _GradientAddButton(onPressed: () => _onAddRow(context)),
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

  // ─── Handlers ───
  /// เปิด full-page เพิ่มรายการ — กดบันทึกในหน้านั้น = ยิง API รวมรายการใหม่+เดิมทันที
  Future<void> _onAddRow(BuildContext context) async {
    final vm = context.read<LicenseRequestDetailStep2ViewModel>();
    final uuid = widget.requestUuid?.trim() ?? '';
    if (uuid.isEmpty) return;

    final saved = await AddBillingTable.show(
      context,
      requestUuid: uuid,
      existingItems: vm.items,
    );
    if (!context.mounted) return;
    if (saved == true) {
      // รีเฟรชรายการจาก API หลัง save สำเร็จ
      await vm.refresh();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เพิ่มรายการสำเร็จ'),
          backgroundColor: LrColors.statusApprovedFg,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (saved == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('บันทึกไม่สำเร็จ'),
          backgroundColor: LrColors.statusRejectedFg,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onDeleteRow(BuildContext context, BillingItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      // ใช้ context ของ dialog เอง — ถ้าใช้ context ของหน้า
      // Navigator.pop จะไปปิด route ของหน้าแทนที่จะปิด dialog (เด้งออกจากหน้า)
      builder: (dialogContext) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('ต้องการลบ "${item.expname}" หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    if (!context.mounted) return;

    final vm = context.read<LicenseRequestDetailStep2ViewModel>();
    // ลบใน local state ก่อน
    vm.deleteItem(item.ser);
    // ยิง API ทันที (overwrite debt_details ทั้งหมด)
    final err = await vm.submit();
    if (!context.mounted) return;
    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ลบรายการสำเร็จ'),
          backgroundColor: LrColors.statusApprovedFg,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: LrColors.statusRejectedFg,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildTable(List<BillingItem> items) {
    final table = Table(
      border: TableBorder(
        horizontalInside:
            BorderSide(color: LrColors.border.withOpacity(.4), width: 0.6),
      ),
      columnWidths: const {
        0: FlexColumnWidth(2.5), // ประเภทค่าบริการ
        1: FlexColumnWidth(1.2), // ความถี่
        2: FlexColumnWidth(1.0), // จำนวนงวด
        3: FlexColumnWidth(1.8), // วันเริ่มต้น
        4: FlexColumnWidth(1.2), // ยอด (บาท)
        5: FlexColumnWidth(1.0), // ประเภท VAT
        6: FlexColumnWidth(1.0), // VAT
        7: FlexColumnWidth(1.0), // ประเภท WHT
        8: FlexColumnWidth(1.0), // WHT
        9: FlexColumnWidth(1.3), // ยอดสุทธิ
        10: FlexColumnWidth(0.6), // action
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        _buildTableHeaderRow(),
        for (int i = 0; i < items.length; i++)
          _buildTableDataRow(items[i], isAlt: i.isEven),
      ],
    );

    return Container(
      decoration: LrDecor.card(),
      clipBehavior: Clip.antiAlias,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                },
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 1100),
                  child: table,
                ),
              ),
            );
          }
          return table;
        },
      ),
    );
  }

  TableRow _buildTableHeaderRow() {
    Widget headerCell(String text) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        color: LrColors.surfaceMuted,
        child: Text(text, style: LrText.tableHeader),
      );
    }

    return TableRow(
      decoration: const BoxDecoration(color: LrColors.surfaceMuted),
      children: [
        headerCell('ประเภทค่าบริการ'),
        headerCell('ความถี่'),
        headerCell('จำนวนงวด'),
        headerCell('วันเริ่มต้น'),
        headerCell('ยอด (บาท)'),
        headerCell('ประเภท VAT'),
        headerCell('VAT'),
        headerCell('ประเภท WHT'),
        headerCell('WHT'),
        headerCell('ยอดสุทธิ'),
        const SizedBox.shrink(),
      ],
    );
  }

  TableRow _buildTableDataRow(BillingItem row, {required bool isAlt}) {
    final bg = isAlt ? LrColors.cardBg : LrColors.surfaceMuted.withOpacity(.5);

    Widget textCell(String text,
        {TextAlign align = TextAlign.left, bool bold = false, Color? color}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Text(
          text.isEmpty ? '-' : text,
          textAlign: align,
          style: LrText.tableCell.copyWith(
            fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            color: color,
          ),
        ),
      );
    }

    Widget chipCell(String text, {Color? color, Color? bg}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: LrText.tableCell.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      );
    }

    Widget dateCell(String text) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Container(
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
                text.isEmpty ? 'เลือกวันที่' : _formatDate(text),
                style: LrText.tableCell.copyWith(
                  color:
                      text.isEmpty ? LrColors.textMuted : LrColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget selectCell(String text) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: LrColors.surfaceMuted.withOpacity(.5),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: LrColors.border),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: LrText.tableCell.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    Widget pillNet(String text) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: LrColors.primaryLight,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            text,
            textAlign: TextAlign.right,
            style: LrText.tableCell.copyWith(
              fontWeight: FontWeight.w700,
              color: LrColors.primaryDark,
            ),
          ),
        ),
      );
    }

    return TableRow(
      decoration: BoxDecoration(color: bg),
      children: [
        textCell(row.expname, bold: true),
        selectCell(row.unit.isEmpty ? '-' : row.unit),
        chipCell(row.term,
            color: LrColors.primaryDark, bg: LrColors.primaryLight),
        dateCell(row.sdate),
        textCell(_formatMoney(row.amount), align: TextAlign.right, bold: true),
        selectCell(row.vatRate > 0 ? 'มี' : 'ไม่มี'),
        textCell(row.vatRate.toStringAsFixed(2), align: TextAlign.right),
        selectCell(row.whtRate > 0 ? 'มี' : 'ไม่มี'),
        textCell(row.whtRate.toStringAsFixed(2), align: TextAlign.right),
        pillNet(_formatMoney(row.net)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          alignment: Alignment.center,
          child: IconButton(
            tooltip: 'ลบ',
            icon: const Icon(Icons.delete_outline,
                color: LrColors.statusRejectedFg, size: 18),
            onPressed: () => _onDeleteRow(context, row),
          ),
        ),
      ],
    );
  }

  Widget _buildGrandTotal(List<BillingItem> items) {
    final total = items.fold(0.0, (sum, e) => sum + e.net);
    return Container(
      width: double.infinity,
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

  // (Removed instance methods _formatMoney and _formatDate — now top-level)
}

// ============================================================================
// Top-level helper functions (shared between State and Dialogs)
// ============================================================================
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

// ============================================================================
// Sub widgets
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
