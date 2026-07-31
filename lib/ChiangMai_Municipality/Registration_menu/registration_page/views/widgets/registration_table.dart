// ============================================================================
// registration_table.dart
// ============================================================================
// ตารางแสดงรายการ "ทะเบียนลูกค้า"
// - Card-based header + alternating rows + hover state
// - ปุ่ม "เรียกดู" เป็น pill button
// - Empty / loading state
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../unity/FormatPhone.dart';
import '../../../../../Model/GetCustomer_Model.dart';
import '../theme/registration_theme.dart';
import '../../viewmodels/registration_view_model.dart';

class RegistrationTable extends StatelessWidget {
  const RegistrationTable({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistrationViewModel>();

    final paged = vm.paged;

    if (vm.isLoading && paged.isEmpty) {
      return const _LoadingState();
    }
    if (paged.isEmpty) {
      return _EmptyState(
        hasFilter: vm.searchQuery.isNotEmpty,
        onClear: vm.refresh,
      );
    }

    return Container(
      decoration: LaDecor.card(),
      child: Column(
        children: [
          _headerRow(),
          const Divider(height: 1, color: LaColors.border),
          // Subtle skeleton ตอน refetch
          if (vm.isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: LaColors.surfaceMuted,
              valueColor: AlwaysStoppedAnimation<Color>(LaColors.primary),
            ),
          // Scroll view ภายในการ์ด — ป้องกัน overflow เมื่อมี rows เกิน viewport
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (int i = 0; i < paged.length; i++)
                    _dataRow(context, vm, paged[i], i),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // Header
  // ========================================================================
  Widget _headerRow() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: LaSpace.md, vertical: LaSpace.md),
      decoration: const BoxDecoration(
        color: LaColors.surfaceMuted,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(LaRadius.lg),
          topRight: Radius.circular(LaRadius.lg),
        ),
      ),
      child: const Row(
        children: [
          _HeaderCell(label: '', flex: 0, width: 110),
          _HeaderCell(label: 'รหัสลูกค้า', flex: 2),
          _HeaderCell(label: 'ชื่อลูกค้า', flex: 3),
          _HeaderCell(label: 'ประเภท', flex: 2),
          _HeaderCell(label: 'เบอร์โทร', flex: 2),
          _HeaderCell(label: 'อีเมล', flex: 2),
          _HeaderCell(label: 'ที่อยู่', flex: 3),
          _HeaderCell(label: 'โซน', flex: 2),
        ],
      ),
    );
  }

  // ========================================================================
  // Data row
  // ========================================================================
  Widget _dataRow(
    BuildContext context,
    RegistrationViewModel vm,
    CustomerModel model,
    int index,
  ) {
    return _HoverableRow(
      index: index,
      onTap: () => vm.onViewCustomer(model),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Action
          SizedBox(
            width: 110,
            child: Center(
              child: _ViewButton(onTap: () => vm.onViewCustomer(model)),
            ),
          ),
          _Cell(value: model.custno ?? '-', flex: 2, isMono: true),
          _Cell(value: model.cname ?? model.scname ?? '-', flex: 3),
          _Cell(value: model.type ?? '-', flex: 2),
          _Cell(
              value: formatPhoneNumber(model.tel ?? ''), flex: 2, isMono: true),
          _Cell(value: model.email ?? '-', flex: 2),
          _Cell(value: _shortAddr(model), flex: 3),
          _Cell(value: model.zn ?? '-', flex: 2),
        ],
      ),
    );
  }

  String _shortAddr(CustomerModel model) {
    final a1 = model.addr1 ?? '';
    final a2 = model.addr2 ?? '';
    final combined = '$a1 $a2'.trim();
    if (combined.isEmpty) return '-';
    if (combined.length <= 32) return combined;
    return '${combined.substring(0, 32)}…';
  }
}

// ============================================================================
// Internal widgets
// ============================================================================

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  final double? width;
  const _HeaderCell({required this.label, this.flex = 1, this.width});

  @override
  Widget build(BuildContext context) {
    final child = Text(
      label,
      style: LaText.tableHeader,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    if (width != null) {
      return SizedBox(width: width, child: Center(child: child));
    }
    return Expanded(flex: flex, child: child);
  }
}

class _Cell extends StatelessWidget {
  final String value;
  final int flex;
  final bool isMono;
  final bool muted;
  const _Cell({
    required this.value,
    this.flex = 1,
    this.isMono = false,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: AutoSizeText(
          value.isEmpty ? '-' : value,
          minFontSize: 11,
          maxFontSize: 14,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: LaText.tableCell.copyWith(
            color: muted ? LaColors.textSecondary : LaColors.textPrimary,
            fontFamily: isMono ? 'monospace' : LaText.fontRegular,
            fontFamilyFallback: const [LaText.fontRegular],
          ),
        ),
      ),
    );
  }
}

class _ViewButton extends StatefulWidget {
  final VoidCallback onTap;
  const _ViewButton({required this.onTap});

  @override
  State<_ViewButton> createState() => _ViewButtonState();
}

class _ViewButtonState extends State<_ViewButton> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: LaColors.primaryLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LaRadius.pill),
        side: BorderSide(color: LaColors.primaryDark, width: 1),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(LaRadius.pill),
        hoverColor: LaColors.primary.withOpacity(.12),
        highlightColor: LaColors.primary.withOpacity(.18),
        splashColor: LaColors.primary.withOpacity(.20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.visibility_rounded,
                size: 14,
                color: LaColors.primaryDark,
              ),
              const SizedBox(width: 4),
              Text(
                'เรียกดู',
                style: TextStyle(
                  color: LaColors.primaryDark,
                  fontFamily: LaText.fontBold,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoverableRow extends StatelessWidget {
  final int index;
  final Widget child;
  final VoidCallback onTap;
  const _HoverableRow({
    required this.index,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final base = index.isEven ? Colors.white : LaColors.surfaceMuted;
    final hoverColor = index.isEven
        ? LaColors.primary.withOpacity(.05)
        : LaColors.primary.withOpacity(.08);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        hoverColor: hoverColor,
        child: Container(
          decoration: BoxDecoration(
            color: base,
            border: Border(
              top: BorderSide(
                color: LaColors.border.withOpacity(.5),
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: LaSpace.md, vertical: LaSpace.md),
          child: child,
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
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.xxl),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: LaColors.primary),
            SizedBox(height: LaSpace.md),
            Text('กำลังโหลดข้อมูลลูกค้า...', style: LaText.bodyMuted),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilter;
  final VoidCallback onClear;
  const _EmptyState({required this.hasFilter, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.xxl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: LaColors.primary.withOpacity(.10),
                borderRadius: BorderRadius.circular(LaRadius.lg),
              ),
              child: Icon(
                hasFilter
                    ? Icons.search_off_rounded
                    : Icons.people_outline_rounded,
                size: 36,
                color: LaColors.primary,
              ),
            ),
            const SizedBox(height: LaSpace.md),
            Text(
              hasFilter ? 'ไม่พบข้อมูลที่ค้นหา' : 'ยังไม่มีข้อมูลลูกค้า',
              style: LaText.h2,
            ),
            const SizedBox(height: LaSpace.sm),
            Text(
              hasFilter
                  ? 'ลองเปลี่ยนคำค้นหรือ filter ใหม่อีกครั้ง'
                  : 'เมื่อมีการลงทะเบียนลูกค้า รายการจะแสดงที่นี่',
              style: LaText.bodyMuted,
              textAlign: TextAlign.center,
            ),
            if (hasFilter) ...[
              const SizedBox(height: LaSpace.md),
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('ล้าง filter'),
                style: TextButton.styleFrom(foregroundColor: LaColors.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
