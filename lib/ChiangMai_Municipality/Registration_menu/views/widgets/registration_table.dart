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

import '../../../unity/FormatPhone.dart';
import '../../../../Model/GetCustomer_Model.dart';
import '../theme/registration_theme.dart';
import '../../viewmodels/registration_view_model.dart';

class RegistrationTable extends StatelessWidget {
  const RegistrationTable({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistrationViewModel>();

    if (vm.isLoading && vm.filtered.isEmpty) {
      return const _LoadingState();
    }
    if (vm.filtered.isEmpty) {
      return _EmptyState(
        hasFilter: vm.searchQuery.isNotEmpty,
        onClear: vm.refresh,
      );
    }

    return Container(
      decoration: RgDecor.card(),
      child: Column(
        children: [
          IntrinsicHeight(child: _headerRow()),
          const Divider(height: 1, color: RgColors.border),
          if (vm.isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: RgColors.surfaceMuted,
              valueColor: AlwaysStoppedAnimation<Color>(RgColors.primary),
            ),
          for (int i = 0; i < vm.filtered.length; i++)
            IntrinsicHeight(child: _dataRow(context, vm, vm.filtered[i], i)),
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
          horizontal: RgSpace.md, vertical: RgSpace.md),
      decoration: const BoxDecoration(
        color: RgColors.surfaceMuted,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(RgRadius.lg),
          topRight: Radius.circular(RgRadius.lg),
        ),
      ),
      child: const Row(
        children: [
          _HeaderCell(label: '', flex: 0, width: 110),
          _HeaderCell(label: 'รหัสลูกค้า', flex: 2),
          _HeaderCell(label: 'ชื่อลูกค้า', flex: 3),
          _HeaderCell(label: 'เลขบัตรประชาชน', flex: 2),
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
        children: [
          // Action
          SizedBox(
            width: 110,
            child: Center(
              child: _ViewButton(onTap: () => vm.onViewCustomer(model)),
            ),
          ),
          _Cell(value: model.custno ?? '-', flex: 2, isMono: true),
          _Cell(value: _maskName(model.cname ?? model.scname ?? '-'), flex: 3),
          _Cell(value: _maskTax(model.tax ?? '-'), flex: 2),
          _Cell(
              value: _maskPhone(formatPhoneNumber(model.tel ?? '')),
              flex: 2,
              isMono: true),
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

  /// Mask ชื่อ — ซ่อน 3 ตัวอักษรท้ายของนามสกุล
  String _maskName(String raw) {
    final name = raw.trim();
    if (name.isEmpty || name == '-') return '-';
    final words =
        name.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '-';

    if (words.length == 1) {
      final w = words.first;
      if (w.length <= 3) return '***';
      return '${w.substring(0, w.length - 3)}***';
    }

    final lastIndex = words.length - 1;
    final last = words[lastIndex];
    if (last.length <= 3) {
      words[lastIndex] = '***';
    } else {
      words[lastIndex] = '${last.substring(0, last.length - 3)}***';
    }
    return words.join(' ');
  }

  /// Mask เบอร์โทร — ซ่อน 3 ตัวท้าย คงรูปแบบ xxx-xxx-xxxx
  String _maskPhone(String raw) {
    if (raw.isEmpty || raw == '-') return '-';
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length <= 3) return raw;

    final maskedDigits = digits.substring(0, digits.length - 3) + '***';

    if (digits.length == 10) {
      return '${maskedDigits.substring(0, 3)}-${maskedDigits.substring(3, 6)}-${maskedDigits.substring(6)}';
    }
    if (digits.length == 9) {
      return '${maskedDigits.substring(0, 2)}-${maskedDigits.substring(2, 5)}-${maskedDigits.substring(5)}';
    }
    return maskedDigits;
  }

  /// Mask เลขบัตรประชาชน — ซ่อน 3 ตัวท้าย รูปแบบ x-xxxx-xxxxx-xxx-x
  String _maskTax(String raw) {
    if (raw.isEmpty || raw == '-') return '-';
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 13) {
      // ไม่ใช่เลขบัตร 13 หลัก → ซ่อน 3 ตัวท้ายแทน
      if (digits.length <= 3) return raw;
      return digits.substring(0, digits.length - 3) + '***';
    }

    final visible = digits.substring(0, 10);
    final masked = digits.substring(10).replaceAll(RegExp(r'[0-9]'), 'X');
    return '${visible.substring(0, 1)}-${visible.substring(1, 5)}-${visible.substring(5, 10)}-${masked.substring(0, 2)}-${masked.substring(2, 3)}';
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
      style: RgText.tableHeader,
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
          style: RgText.tableCell.copyWith(
            color: muted ? RgColors.textSecondary : RgColors.textPrimary,
            fontFamily: isMono ? 'monospace' : RgText.fontRegular,
            fontFamilyFallback: const [RgText.fontRegular],
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
      color: RgColors.primaryLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RgRadius.pill),
        side: BorderSide(color: RgColors.primaryDark, width: 1),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(RgRadius.pill),
        hoverColor: RgColors.primary.withOpacity(.12),
        highlightColor: RgColors.primary.withOpacity(.18),
        splashColor: RgColors.primary.withOpacity(.20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.visibility_rounded,
                size: 14,
                color: RgColors.primaryDark,
              ),
              const SizedBox(width: 4),
              Text(
                'เรียกดู',
                style: TextStyle(
                  color: RgColors.primaryDark,
                  fontFamily: RgText.fontBold,
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
    final base = index.isEven ? Colors.white : RgColors.surfaceMuted;
    final hoverColor = index.isEven
        ? RgColors.primary.withOpacity(.05)
        : RgColors.primary.withOpacity(.08);

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
                color: RgColors.border.withOpacity(.5),
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: RgSpace.md, vertical: RgSpace.md),
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
      decoration: RgDecor.card(),
      padding: const EdgeInsets.all(RgSpace.xxl),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: RgColors.primary),
            SizedBox(height: RgSpace.md),
            Text('กำลังโหลดข้อมูลลูกค้า...', style: RgText.bodyMuted),
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
      decoration: RgDecor.card(),
      padding: const EdgeInsets.all(RgSpace.xxl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: RgColors.primary.withOpacity(.10),
                borderRadius: BorderRadius.circular(RgRadius.lg),
              ),
              child: Icon(
                hasFilter
                    ? Icons.search_off_rounded
                    : Icons.people_outline_rounded,
                size: 36,
                color: RgColors.primary,
              ),
            ),
            const SizedBox(height: RgSpace.md),
            Text(
              hasFilter ? 'ไม่พบข้อมูลที่ค้นหา' : 'ยังไม่มีข้อมูลลูกค้า',
              style: RgText.h2,
            ),
            const SizedBox(height: RgSpace.sm),
            Text(
              hasFilter
                  ? 'ลองเปลี่ยนคำค้นหรือ filter ใหม่อีกครั้ง'
                  : 'เมื่อมีการลงทะเบียนลูกค้า รายการจะแสดงที่นี่',
              style: RgText.bodyMuted,
              textAlign: TextAlign.center,
            ),
            if (hasFilter) ...[
              const SizedBox(height: RgSpace.md),
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('ล้าง filter'),
                style: TextButton.styleFrom(foregroundColor: RgColors.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
