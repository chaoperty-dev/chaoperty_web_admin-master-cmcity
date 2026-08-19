// ============================================================================
// license_fact_check_table.dart
// ============================================================================
// ตารางแสดงรายการ "ตรวจสอบข้อเท็จจริง" — ดีไซน์ใหม่
// - Card-based header + alternating rows + hover state
// - Status pill ใช้สีตามคำสถานะ
// - ปุ่ม "เรียกดู" เป็น pill button
// - Empty / loading state สวยงาม
//
// v2 (2026-08): ใช้ข้อมูลจาก /api/v2/admin/requests/tasks/inspections
//   - "รายการ" → module.name_th (item.moduleNameTh)
//   - เพิ่มคอลัม "ผ่านตรวจ" (item.inspectionPassed) ก่อน "สถานะ"
//   - คอมเมนต์ "เบอร์โทร" ออก
//   - ใช้ FactCheckItem ของตัวเอง (ไม่ใช้ ReviewModel)
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:provider/provider.dart';

import '../../../../unity/Enum.dart';
import '../../../../unity/FormatDate.dart';
// import '../../../../unity/FormatPhone.dart'; // คอมเมนต์ปิดเบอร์โทร
import '../../models/fact_check_item.dart';
import '../theme/license_fact_check_theme.dart';
import '../../viewmodels/license_fact_check_view_model.dart';

/// Breakpoint: < 900px = โทรศัพท์/แท็บเล็ต → ใช้ card layout
const double kLicenseMenuMobileBreakpoint = 900;

bool _isLicenseListMobile(BuildContext context) =>
    MediaQuery.of(context).size.width < kLicenseMenuMobileBreakpoint;

class LicensefactcheckTable extends StatelessWidget {
  const LicensefactcheckTable({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicensefactcheckViewModel>();

    if (vm.isLoading && vm.requests.isEmpty) {
      return const _LoadingState();
    }
    if (vm.requests.isEmpty) {
      return _EmptyState(
        hasFilter: vm.searchQuery.isNotEmpty ||
            (vm.selectedZoneSub != null && vm.selectedZoneSub != 'ทั้งหมด') ||
            (vm.selectedZone != null && vm.selectedZone != 'ทั้งหมด'),
        onClear: vm.refresh,
      );
    }

    // ─── Mobile (card layout) ───
    if (_isLicenseListMobile(context)) {
      return Column(
        children: [
          if (vm.isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: LaColors.surfaceMuted,
              valueColor: AlwaysStoppedAnimation<Color>(LaColors.primary),
            ),
          for (int i = 0; i < vm.requests.length; i++) ...[
            _FactCheckCard(
              index: i,
              item: vm.requests[i],
              onTap: () => vm.onViewRequest(vm.requests[i]),
            ),
            if (i < vm.requests.length - 1) const SizedBox(height: LaSpace.sm),
          ],
        ],
      );
    }

    return Container(
      decoration: LaDecor.card(),
      child: Column(
        children: [
          _headerRow(),
          const Divider(height: 1, color: LaColors.border),
          if (vm.isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: LaColors.surfaceMuted,
              valueColor: AlwaysStoppedAnimation<Color>(LaColors.primary),
            ),
          for (int i = 0; i < vm.requests.length; i++)
            _dataRow(context, vm, vm.requests[i], i),
        ],
      ),
    );
  }

  // ========================================================================
  // Header (v2 order: เรียกดู, รายการ, บริเวณ, โซนพื้นที่, รหัสพื้นที่, ชื่อผู้ติดต่อ,
  //                   วันที่ส่งคำร้อง, ผ่านตรวจ, สถานะ, รหัสรายการ)
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
          _HeaderCell(label: 'รายการ', flex: 2),
          _HeaderCell(label: 'บริเวณ', flex: 2),
          _HeaderCell(label: 'โซนพื้นที่', flex: 2),
          _HeaderCell(label: 'รหัสพื้นที่', flex: 2),
          _HeaderCell(label: 'ชื่อผู้ติดต่อ', flex: 3),
          // _HeaderCell(label: 'เบอร์โทร', flex: 2), // คอมเมนต์ปิดเบอร์โทร
          _HeaderCell(label: 'วันที่ส่งคำร้อง', flex: 2),
          _HeaderCell(label: 'ผ่านตรวจ', flex: 2),
          _HeaderCell(label: 'สถานะ', flex: 2),
          _HeaderCell(label: 'รหัสรายการ', flex: 2),
        ],
      ),
    );
  }

  // ========================================================================
  // Data row
  // ========================================================================
  Widget _dataRow(
    BuildContext context,
    LicensefactcheckViewModel vm,
    FactCheckItem item,
    int index,
  ) {
    final palette = StatusPalette.of(item.statusLabel);
    return _HoverableRow(
      index: index,
      onTap: () => vm.onViewRequest(item),
      child: Row(
        children: [
          // Action
          SizedBox(
            width: 110,
            child:
                Center(child: _ViewButton(onTap: () => vm.onViewRequest(item))),
          ),
          // รายการ — module.name_th (v2)
          _Cell(
              value: item.moduleNameTh.isEmpty ? '-' : item.moduleNameTh,
              flex: 2),
          // บริเวณ — details.subzone
          _Cell(value: item.subzone, flex: 2),
          // โซนพื้นที่ — details.zn
          _Cell(value: item.zn, flex: 2),
          // รหัสพื้นที่ — details.ln
          _Cell(value: item.ln, flex: 2, isMono: true),
          // ชื่อผู้ติดต่อ — customer.cname (อาจว่าง)
          _Cell(
              value: _maskName(item.customerName),
              tooltip: item.customerName,
              flex: 3),
          // _Cell(
          //     value: _maskPhone(item.customerTel),
          //     tooltip: item.customerTel,
          //     flex: 2,
          //     isMono: true), // คอมเมนต์ปิดเบอร์โทร
          // วันที่ส่งคำร้อง — submitted_at (fallback created_at)
          _Cell(
              value: formatFactCheckDate(
                  item.submittedAt ?? item.createdAt),
              flex: 2,
              isMono: true),
          // ผ่านตรวจ (v2 ใหม่) — ก่อนหน้าสถานะ
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: _InspectionPassedBadge(passed: item.inspectionPassed),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _StatusPill(
                label: item.statusLabel,
                palette: palette,
              ),
            ),
          ),
          _CopyUuidCell(
            fullValue: item.uuid,
            display: _shortUuid(item.uuid),
            flex: 2,
          ),
        ],
      ),
    );
  }

  String _shortUuid(String uuid) {
    if (uuid.isEmpty) return '-';
    if (uuid.length <= 12) return uuid;
    return '${uuid.substring(0, 8)}…';
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

  /// Mask เบอร์โทร — ซ่อน 3 ตัวท้าย
  // (คอมเมนต์ปิดเบอร์โทร — เก็บไว้ใช้ในอนาคต)
  // String _maskPhone(String raw) {
  //   if (raw.isEmpty || raw == '-') return '-';
  //   final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  //   if (digits.length <= 3) return raw;
  //   final maskedDigits = digits.substring(0, digits.length - 3) + '***';
  //   if (digits.length == 10) {
  //     return '${maskedDigits.substring(0, 3)}-${maskedDigits.substring(3, 6)}-${maskedDigits.substring(6)}';
  //   }
  //   if (digits.length == 9) {
  //     return '${maskedDigits.substring(0, 2)}-${maskedDigits.substring(2, 5)}-${maskedDigits.substring(5)}';
  //   }
  //   return maskedDigits;
  // }
}

// ============================================================================
// Internal widgets
// ============================================================================

/// Badge: แสดงผล "ผ่านตรวจ" (inspection_passed) — ใช้ก่อน status pill
/// passed == true → ✓ สีเขียว
/// passed == false → ⏳ สีส้ม
class _InspectionPassedBadge extends StatelessWidget {
  final bool passed;
  const _InspectionPassedBadge({required this.passed});

  @override
  Widget build(BuildContext context) {
    final Color fg;
    final IconData icon;
    final String label;
    if (passed) {
      fg = const Color(0xFF15803D); // green-700
      icon = Icons.check_circle_rounded;
      label = 'ผ่าน';
    } else {
      fg = const Color(0xFFB45309); // amber-700
      icon = Icons.pending_actions_rounded;
      label = 'รอ';
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Tooltip(
        message: passed ? 'ตรวจสอบข้อเท็จจริงผ่านแล้ว' : 'ยังไม่ผ่านการตรวจสอบ',
        waitDuration: const Duration(milliseconds: 250),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
            Text(
              label,
              style: LaText.tableCell.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card layout — ใช้บน mobile/tablet (< 900px)
class _FactCheckCard extends StatelessWidget {
  final int index;
  final FactCheckItem item;
  final VoidCallback onTap;
  const _FactCheckCard({
    required this.index,
    required this.item,
    required this.onTap,
  });

  String _shortUuid(String uuid) {
    if (uuid.isEmpty) return '-';
    if (uuid.length <= 12) return uuid;
    return '${uuid.substring(0, 8)}…';
  }

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

  // String _maskPhone(String raw) {...} // คอมเมนต์ปิดเบอร์โทร

  @override
  Widget build(BuildContext context) {
    final palette = StatusPalette.of(item.statusLabel);
    final moduleLabel = item.moduleNameTh.isEmpty ? '-' : item.moduleNameTh;
    final name = _maskName(item.customerName);
    final submitted =
        formatFactCheckDate(item.submittedAt ?? item.createdAt);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LaRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(LaSpace.md),
          decoration: LaDecor.card(),
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
                      color: LaColors.primaryLight,
                      borderRadius: BorderRadius.circular(LaRadius.pill),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: LaText.tableCell.copyWith(
                        color: LaColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: LaSpace.sm),
                  Expanded(
                    child: Text(
                      moduleLabel,
                      style: LaText.tableCell.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: LaSpace.sm),
                  _StatusPill(
                    label: item.statusLabel,
                    palette: palette,
                  ),
                ],
              ),
              const Divider(height: LaSpace.lg, color: LaColors.border),
              _CardRow(label: 'ชื่อผู้ติดต่อ', value: name),
              // _CardRow(label: 'เบอร์โทร', value: phone, isMono: true), // ปิดเบอร์โทร
              if (item.subzone.isNotEmpty)
                  _CardRow(label: 'บริเวณ', value: item.subzone),
              if (item.zn.isNotEmpty)
                  _CardRow(label: 'โซนพื้นที่', value: item.zn),
              _CardRow(
                  label: 'รหัสพื้นที่', value: item.ln, isMono: true),
              _CardRow(
                  label: 'วันที่ส่งคำร้อง', value: submitted, isMono: true),
              _CardRow(
                label: 'ผ่านตรวจ',
                value: item.inspectionPassed ? 'ผ่าน' : 'รอ',
              ),
              _CardRow(
                label: 'รหัสรายการ',
                value: _shortUuid(item.uuid),
                isMono: true,
                muted: true,
              ),
              const SizedBox(height: LaSpace.sm),
              Align(
                alignment: Alignment.centerRight,
                child: _ViewButton(onTap: onTap),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMono;
  final bool muted;
  final String? uuidCopy;
  const _CardRow({
    required this.label,
    required this.value,
    this.isMono = false,
    this.muted = false,
    this.uuidCopy,
  });

  @override
  Widget build(BuildContext context) {
    Widget valueText = Text(
      value.isEmpty ? '-' : value,
      style: LaText.tableCell.copyWith(
        color: muted ? LaColors.textSecondary : LaColors.textPrimary,
        fontFamily: isMono ? 'monospace' : LaText.fontRegular,
        fontFamilyFallback: const [LaText.fontRegular],
        fontSize: 12,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    final canCopy = uuidCopy != null && uuidCopy!.isNotEmpty;
    if (canCopy) {
      valueText = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: valueText),
          const SizedBox(width: 4),
          const Icon(Icons.content_copy_rounded,
              size: 11, color: LaColors.textMuted),
        ],
      );
    }

    Widget valueChild = Expanded(child: valueText);

    if (canCopy) {
      valueChild = Expanded(
        child: Tooltip(
          message: 'คลิกเพื่อคัดลอก: $uuidCopy',
          waitDuration: const Duration(milliseconds: 300),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: uuidCopy!));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle_outline_rounded,
                            size: 18, color: Colors.white),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'คัดลอกรหัสรายการแล้ว',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: valueText,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: LaText.bodyMuted.copyWith(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          valueChild,
        ],
      ),
    );
  }
}

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
  final String? tooltip;
  const _Cell({
    required this.value,
    this.flex = 1,
    this.isMono = false,
    this.muted = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Tooltip(
          message: tooltip ?? value,
          waitDuration: const Duration(milliseconds: 300),
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
      ),
    );
  }
}

/// Copyable UUID cell
class _CopyUuidCell extends StatelessWidget {
  final String fullValue;
  final String display;
  final int flex;
  const _CopyUuidCell({
    required this.fullValue,
    required this.display,
    this.flex = 2,
  });

  Future<void> _copy(BuildContext context) async {
    if (fullValue.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: fullValue));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded,
                size: 18, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'คัดลอกรหัสรายการแล้ว',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Tooltip(
          message: fullValue.isEmpty ? '-' : 'คลิกเพื่อคัดลอก: $fullValue',
          waitDuration: const Duration(milliseconds: 300),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
              onTap: fullValue.isEmpty ? null : () => _copy(context),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: AutoSizeText(
                        display.isEmpty ? '-' : display,
                        minFontSize: 11,
                        maxFontSize: 14,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LaText.tableCell.copyWith(
                          color: LaColors.textSecondary,
                          fontFamily: 'monospace',
                          fontFamilyFallback: const [LaText.fontRegular],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.content_copy_rounded,
                      size: 12,
                      color: LaColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final StatusPalette palette;
  const _StatusPill({required this.label, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: LaDecor.pill(palette.bg, palette.fg),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: palette.fg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: AutoSizeText(
                label.isEmpty ? '-' : label,
                minFontSize: 10,
                maxFontSize: 12,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: LaText.fontBold,
                  fontSize: 11,
                  color: palette.fg,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoverableRow extends StatefulWidget {
  final int index;
  final Widget child;
  final VoidCallback onTap;
  const _HoverableRow({
    required this.index,
    required this.child,
    required this.onTap,
  });

  @override
  State<_HoverableRow> createState() => _HoverableRowState();
}

class _HoverableRowState extends State<_HoverableRow> {
  bool _hover = false;

  @override
  void didUpdateWidget(_HoverableRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _hover = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.index.isEven ? Colors.white : LaColors.surfaceMuted;
    final hoverColor = widget.index.isEven
        ? LaColors.primary.withOpacity(.05)
        : LaColors.primary.withOpacity(.08);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (hover) {
          if (hover != _hover) {
            setState(() => _hover = hover);
          }
        },
        hoverColor: hoverColor,
        splashColor: LaColors.primary.withOpacity(.12),
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: LrAnimations.fast,
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
              horizontal: LaSpace.md, vertical: LaSpace.md),
          decoration: BoxDecoration(
            color: _hover ? null : base,
            border: const Border(
              bottom: BorderSide(color: LaColors.border, width: 1),
            ),
          ),
          child: widget.child,
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
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: LrAnimations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _hover ? LaColors.primary : LaColors.surfaceMuted,
            borderRadius: BorderRadius.circular(LaRadius.pill),
            border: Border.all(
              color: _hover ? LaColors.primary : LaColors.border,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.visibility_outlined,
                size: 13,
                color: _hover ? Colors.white : LaColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                'เรียกดู',
                style: TextStyle(
                  fontFamily: LaText.fontBold,
                  fontSize: 11,
                  color: _hover ? Colors.white : LaColors.textSecondary,
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: LaColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_outlined,
              size: 36,
              color: LaColors.primaryDark,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hasFilter ? 'ไม่พบรายการที่ตรงกัน' : 'ยังไม่มีคำขอ',
            style: LaText.h2,
          ),
          const SizedBox(height: 6),
          Text(
            hasFilter
                ? 'ลองปรับตัวกรองหรือคำค้นหาใหม่อีกครั้ง'
                : 'กดปุ่ม "สร้างคำขอ" เพื่อเริ่มต้นคำขอต่อสัญญาใหม่',
            style: LaText.bodyMuted,
            textAlign: TextAlign.center,
          ),
          if (hasFilter) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('รีเฟรช'),
              style: OutlinedButton.styleFrom(
                foregroundColor: LaColors.primary,
                side: BorderSide(color: LaColors.primary.withOpacity(.4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(LaRadius.pill),
                ),
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
      padding: const EdgeInsets.symmetric(vertical: 60),
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(LaColors.primary),
            ),
          ),
          SizedBox(height: 12),
          Text('กำลังโหลดข้อมูล...', style: LaText.bodyMuted),
        ],
      ),
    );
  }
}