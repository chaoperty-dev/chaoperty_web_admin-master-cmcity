// ============================================================================
// payment_table.dart
// ============================================================================
// ตารางแสดงรายการ Payment
// - Card-based header + alternating rows + hover state
// - Sort + ปุ่ม "แก้ไข" / "ลบ" / "สลิป" ในแต่ละ row
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/payment_theme.dart';
import '../../models/payment_payment_model.dart';
import '../../viewmodels/payment_view_model.dart';

const double kPaymentMobileBreakpoint = 700;

class PaymentTable extends StatelessWidget {
  const PaymentTable({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PaymentViewModel>();
    final rows = vm.filtered;

    if (vm.isLoading && rows.isEmpty) {
      return const _LoadingState();
    }
    if (rows.isEmpty) {
      return _EmptyState(
        hasFilter: vm.searchQuery.isNotEmpty,
        onRefresh: () => vm.refresh(),
      );
    }

    return LayoutBuilder(
      builder: (context, c) {
        final isMobile = c.maxWidth < kPaymentMobileBreakpoint;
        if (isMobile) {
          return Column(
            children: [
              if (vm.isLoading)
                const LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: PayColors.surfaceMuted,
                  valueColor: AlwaysStoppedAnimation<Color>(PayColors.primary),
                ),
              for (int i = 0; i < rows.length; i++) ...[
                _PaymentCard(
                  index: i,
                  model: rows[i],
                  onEdit: () => vm.onEdit(rows[i].ser),
                  onSlip: () => vm.onSlip(rows[i].ser),
                  onDelete: () => _confirmDelete(context, vm, rows[i]),
                ),
                if (i < rows.length - 1) const SizedBox(height: PaySpace.sm),
              ],
            ],
          );
        }
        return Container(
          decoration: PayDecor.card(),
          child: Column(
            children: [
              _headerRow(vm),
              const Divider(height: 1, color: PayColors.border),
              if (vm.isLoading)
                const LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: PayColors.surfaceMuted,
                  valueColor: AlwaysStoppedAnimation<Color>(PayColors.primary),
                ),
              for (int i = 0; i < rows.length; i++)
                _dataRow(context, vm, rows[i], i),
            ],
          ),
        );
      },
    );
  }

  Widget _headerRow(PaymentViewModel vm) {
    Widget cell(String label, String columnId, {int flex = 2}) {
      final sorted = vm.sortColumn == columnId;
      return Expanded(
        flex: flex,
        child: InkWell(
          onTap: () => vm.onSort(columnId),
          borderRadius: BorderRadius.circular(PayRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (sorted)
                  Icon(
                    vm.sortAscending
                        ? Icons.arrow_drop_up_rounded
                        : Icons.arrow_drop_down_rounded,
                    color: PayColors.primary,
                    size: 18,
                  ),
                Flexible(
                  child: Text(
                    label,
                    style: PayText.tableHeader,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: PaySpace.md, vertical: PaySpace.md),
      decoration: const BoxDecoration(
        color: PayColors.surfaceMuted,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(PayRadius.lg),
          topRight: Radius.circular(PayRadius.lg),
        ),
      ),
      child: Row(
        children: [
          cell('ลำดับ', 'sw', flex: 1),
          cell('รหัส', 'ln', flex: 2),
          cell('ชื่อย่อ', 'sn', flex: 2),
          cell('ชื่อบัญชี', 'sname', flex: 3),
          cell('ประเภท', 'type', flex: 2),
          cell('ธนาคาร', 'bank', flex: 2),
          const SizedBox(width: 200, child: _ActionHeader()),
        ],
      ),
    );
  }

  Widget _dataRow(
    BuildContext context,
    PaymentViewModel vm,
    PaymentPaymentModel m,
    int index,
  ) {
    return _HoverableRow(
      index: index,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: PaySpace.md, vertical: PaySpace.md),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: _Cell(value: m.sw, center: true, mono: true),
            ),
            Expanded(
              flex: 2,
              child: _Cell(value: m.ln, mono: true),
            ),
            Expanded(
              flex: 2,
              child: _Cell(value: m.sn),
            ),
            Expanded(
              flex: 3,
              child: _Cell(value: m.sname),
            ),
            Expanded(
              flex: 2,
              child: _Cell(
                value: m.typeName.isEmpty ? '-' : m.typeName,
                muted: m.typeName.isEmpty,
              ),
            ),
            Expanded(
              flex: 2,
              child: _Cell(
                value: m.bankName.isEmpty
                    ? '-'
                    : (m.bankCode.isEmpty ? m.bankName : '${m.bankName} (${m.bankCode})'),
                muted: m.bankName.isEmpty,
              ),
            ),
            SizedBox(
              width: 200,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: _MiniButton(
                      icon: Icons.edit_rounded,
                      label: 'แก้ไข',
                      onTap: () => vm.onEdit(m.ser),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _MiniButton(
                      icon: Icons.image_outlined,
                      label: 'สลิป',
                      onTap: () => vm.onSlip(m.ser),
                      color: PayColors.statusInfoFg,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _MiniButton(
                      icon: Icons.delete_rounded,
                      label: 'ลบ',
                      onTap: () => _confirmDelete(context, vm, m),
                      color: PayColors.statusRejectedFg,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    PaymentViewModel vm,
    PaymentPaymentModel m,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ยืนยันการลบ Payment'),
        content: Text('ต้องการลบ "${m.sname}" (รหัส ${m.ln}) หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await vm.deletePayment(m.ser);
    }
  }
}

class _ActionHeader extends StatelessWidget {
  const _ActionHeader();
  @override
  Widget build(BuildContext context) {
    return const Text(
      'จัดการ',
      textAlign: TextAlign.center,
      style: PayText.tableHeader,
    );
  }
}

class _Cell extends StatelessWidget {
  final String value;
  final bool muted;
  final bool center;
  final bool mono;
  final int maxLines;
  const _Cell({
    required this.value,
    this.muted = false,
    this.center = false,
    this.mono = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final style = PayText.tableCell.copyWith(
      color: muted ? PayColors.textSecondary : PayColors.textPrimary,
      fontFamily: mono ? PayText.fontBold : PayText.fontRegular,
    );
    return Tooltip(
      message: value,
      child: Text(
        value,
        textAlign: center ? TextAlign.center : TextAlign.start,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
    );
  }
}

class _HoverableRow extends StatefulWidget {
  final int index;
  final Widget child;
  const _HoverableRow({required this.index, required this.child});
  @override
  State<_HoverableRow> createState() => _HoverableRowState();
}

class _HoverableRowState extends State<_HoverableRow> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final isAlt = widget.index.isOdd;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        decoration: BoxDecoration(
          color: _hover
              ? PayColors.primaryLight.withOpacity(.4)
              : (isAlt ? PayColors.surfaceMuted : Colors.white),
        ),
        child: widget.child,
      ),
    );
  }
}

class _MiniButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _MiniButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  @override
  State<_MiniButton> createState() => _MiniButtonState();
}

class _MiniButtonState extends State<_MiniButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final c = widget.color ?? PayColors.primary;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: PayAnimations.fast,
          height: 30,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: _hover ? c : Colors.white,
            borderRadius: BorderRadius.circular(PayRadius.sm),
            border: Border.all(color: c, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 12, color: _hover ? Colors.white : c),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: PayText.fontBold,
                    fontSize: 11,
                    color: _hover ? Colors.white : c,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: PayDecor.card(),
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(PayColors.primary)),
          SizedBox(height: 12),
          Text('กำลังโหลดข้อมูล Payment...', style: PayText.bodyMuted),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilter;
  final VoidCallback onRefresh;
  const _EmptyState({required this.hasFilter, required this.onRefresh});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: PayDecor.card(),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_outlined,
              size: 48, color: PayColors.textMuted),
          const SizedBox(height: 8),
          Text(
            hasFilter
                ? 'ไม่พบ Payment ที่ตรงกับเงื่อนไข'
                : 'ยังไม่มี Payment ในระบบ',
            style: PayText.bodyMuted,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('รีเฟรช'),
            style: OutlinedButton.styleFrom(
              foregroundColor: PayColors.primary,
              side: const BorderSide(color: PayColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Card layout (mobile / narrow screen)
// ============================================================================
class _PaymentCard extends StatelessWidget {
  final int index;
  final PaymentPaymentModel model;
  final VoidCallback onEdit;
  final VoidCallback onSlip;
  final Future<void> Function() onDelete;
  const _PaymentCard({
    required this.index,
    required this.model,
    required this.onEdit,
    required this.onSlip,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bankValue = model.bankName.isEmpty
        ? '-'
        : (model.bankCode.isEmpty
            ? model.bankName
            : '${model.bankName} (${model.bankCode})');

    return Container(
      decoration: PayDecor.card(),
      padding: const EdgeInsets.all(PaySpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: PayColors.primaryLight,
                  borderRadius: BorderRadius.circular(PayRadius.pill),
                ),
                child: Text(
                  '${model.sw}',
                  style: PayText.tableCell.copyWith(
                    color: PayColors.primaryDark,
                    fontWeight: FontWeight.w700,
                    fontFamily: PayText.fontBold,
                  ),
                ),
              ),
              const SizedBox(width: PaySpace.sm),
              Expanded(
                child: Text(
                  model.sname.isEmpty ? '-' : model.sname,
                  style: PayText.tableCell.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (model.ln.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: PayColors.primaryLight.withOpacity(.4),
                    borderRadius: BorderRadius.circular(PayRadius.pill),
                  ),
                  child: Text(
                    model.ln,
                    style: PayText.bodyMuted.copyWith(
                      color: PayColors.primaryDark,
                      fontSize: 11,
                      fontFamily: PayText.fontBold,
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: PaySpace.lg, color: PayColors.border),
          _PayCardRow(label: 'ชื่อย่อ', value: model.sn),
          _PayCardRow(
            label: 'ประเภท',
            value: model.typeName.isEmpty ? '-' : model.typeName,
            muted: model.typeName.isEmpty,
          ),
          _PayCardRow(label: 'ธนาคาร', value: bankValue, muted: model.bankName.isEmpty),
          const SizedBox(height: PaySpace.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _MiniButton(
                icon: Icons.edit_rounded,
                label: 'แก้ไข',
                onTap: onEdit,
              ),
              const SizedBox(width: 6),
              _MiniButton(
                icon: Icons.image_outlined,
                label: 'สลิป',
                onTap: onSlip,
                color: PayColors.statusInfoFg,
              ),
              const SizedBox(width: 6),
              _MiniButton(
                icon: Icons.delete_rounded,
                label: 'ลบ',
                onTap: () async => await onDelete(),
                color: PayColors.statusRejectedFg,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PayCardRow extends StatelessWidget {
  final String label;
  final String value;
  final bool muted;
  const _PayCardRow({
    required this.label,
    required this.value,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: PayText.bodyMuted.copyWith(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: PayText.tableCell.copyWith(
                color: muted ? PayColors.textSecondary : PayColors.textPrimary,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
