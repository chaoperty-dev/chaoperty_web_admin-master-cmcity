// ============================================================================
// license_attach_table.dart
// ============================================================================
// ตารางแสดงรายการ "คำขอต่อสัญญา" — ดีไซน์ใหม่
// - Card-based header + alternating rows + hover state
// - Status pill ใช้สีตามคำสถานะ
// - ปุ่ม "เรียกดู" เป็น pill button
// - Empty / loading state สวยงาม
// - รหัสรายการ column: คลิกเพื่อ copy UUID
//
// Data shape: AttachRequestItem (v2 /admin/requests)
// Column swap: เลขที่สัญญา = module, รหัสพื้นที่ = lease ln
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:provider/provider.dart';

import '../../../../unity/Enum.dart';
import '../../../../unity/FormatDate.dart';
import '../../../../unity/FormatPhone.dart';
import '../../models/attach_request_item.dart';
import '../theme/license_attach_theme.dart';
import '../../viewmodels/license_attach_view_model.dart';

/// Breakpoint: < 900px = โทรศัพท์/แท็บเล็ต → ใช้ card layout
const double kAttachMobileBreakpoint = 900;

bool _isAttachListMobile(BuildContext context) =>
    MediaQuery.of(context).size.width < kAttachMobileBreakpoint;

class LicenseAttachTable extends StatelessWidget {
  const LicenseAttachTable({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseAttachViewModel>();

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
    if (_isAttachListMobile(context)) {
      return Column(
        children: [
          if (vm.isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: LaColors.surfaceMuted,
              valueColor: AlwaysStoppedAnimation<Color>(LaColors.primary),
            ),
          for (int i = 0; i < vm.requests.length; i++) ...[
            _AttachCard(
              index: i,
              task: vm.requests[i],
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
          // Subtle skeleton �อน refetch
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
          _HeaderCell(label: 'รายการ', flex: 2),
          _HeaderCell(label: 'บริเวณ', flex: 2),
          _HeaderCell(label: 'โซนพื้นที่', flex: 2),
          _HeaderCell(label: 'รหัสพื้นที่', flex: 2),
          _HeaderCell(label: 'ชื่อผู้ติดต่อ', flex: 3),
          _HeaderCell(label: 'เบอร์โทร', flex: 2),
          _HeaderCell(label: 'วันที่สิ้นสุด', flex: 2),
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
    LicenseAttachViewModel vm,
    AttachRequestItem task,
    int index,
  ) {
    final moduleLabel =
        task.moduleNameTh.isNotEmpty ? task.moduleNameTh : task.moduleCode;
    final palette = StatusPalette.of(task.statusLabel);
    return _HoverableRow(
      index: index,
      onTap: () => vm.onViewRequest(task),
      child: Row(
        children: [
          // Action
          SizedBox(
            width: 110,
            child:
                Center(child: _ViewButton(onTap: () => vm.onViewRequest(task))),
          ),
          // เลขที่สัญญา (swap → module label)
          _Cell(value: moduleLabel, flex: 2, isMono: true),
          _Cell(value: task.subzone, flex: 2),
          _Cell(value: task.zn, flex: 2),
          // รหัสพื้นที่ (swap → lease ln)
          _Cell(
              value: task.ln.isEmpty ? '-' : task.ln,
              flex: 2,
              isMono: true),
          _Cell(value: _maskName(task.customerName), flex: 3),
          _Cell(
              value: _maskPhone(formatPhoneNumber(task.customerTel)),
              flex: 2,
              isMono: true),
          _Cell(
              value: formatDate(task.submittedAt, type: DateFormatType.dmy),
              flex: 2,
              isMono: true),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _StatusPill(
                label: task.statusLabel,
                palette: palette,
              ),
            ),
          ),
          _CopyUuidCell(
            fullValue: task.uuid,
            display: _shortUuid(task.uuid),
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
}

// ============================================================================
// Internal widgets
// ============================================================================

/// Card layout — ใช้บน mobile/tablet (< 900px)
class _AttachCard extends StatelessWidget {
  final int index;
  final AttachRequestItem task;
  final VoidCallback onTap;
  const _AttachCard({
    required this.index,
    required this.task,
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

  @override
  Widget build(BuildContext context) {
    final moduleLabel =
        task.moduleNameTh.isNotEmpty ? task.moduleNameTh : task.moduleCode;
    final palette = StatusPalette.of(task.statusLabel);
    final name = _maskName(task.customerName);
    final phone = _maskPhone(formatPhoneNumber(task.customerTel));
    final endDate =
        formatDate(task.submittedAt, type: DateFormatType.dmy);

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
              // ─── Row 1: เลขที่สัญญา + status pill ───
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
                        fontFamily: 'monospace',
                        fontFamilyFallback: const [LaText.fontRegular],
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: LaSpace.sm),
                  _StatusPill(
                    label: task.statusLabel,
                    palette: palette,
                  ),
                ],
              ),
              const Divider(height: LaSpace.lg, color: LaColors.border),
              // ─── Row 2: รายละเอียด (label/value grid) ───
              _CardRow(label: 'ชื่อผู้ติดต่อ', value: name),
              _CardRow(label: 'เบอร์โทร', value: phone, isMono: true),
              if (task.subzone.isNotEmpty)
                _CardRow(label: 'บริเวณ', value: task.subzone),
              if (task.zn.isNotEmpty)
                _CardRow(label: 'โซนพื้นที่', value: task.zn),
              _CardRow(
                label: 'รหัสพื้นที่',
                value: task.ln.isEmpty ? '-' : task.ln,
                isMono: true,
              ),
              _CardRow(label: 'วันที่สิ้นสุด', value: endDate, isMono: true),
              _CardRow(
                label: 'รหัสรายการ',
                value: _shortUuid(task.uuid),
                isMono: true,
                muted: true,
                uuidCopy: task.uuid,
              ),
              const SizedBox(height: LaSpace.sm),
              // ─── Row 3: ปุ่ม ───
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

  Future<void> _doCopy(BuildContext context, String text) async {
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
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
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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
              onTap: () => _doCopy(context, uuidCopy!),
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

/// Copyable UUID cell — short uuid + persistent copy icon
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
    // Reset hover เมื่อ data เปลี่ยน (เช่น refresh table)
    // — ป้องกัน hover state ค้างจาก row เก่าที่ถูก rebuild
    if (oldWidget.index != widget.index) {
      _hover = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.index.isEven ? Colors.white : LaColors.surfaceMuted;
    // ใช้ hover ที่ subtle กว่าเดิม เพื่อไม่ให้ดูแปลกตา
    final hoverColor = widget.index.isEven
        ? LaColors.primary.withOpacity(.05)
        : LaColors.primary.withOpacity(.08);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (hover) {
          // onHover จาก InkWell จัดการ state ได้แม่นยำกว่า MouseRegion
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
                : 'กดปุ่ม "สร้างคำขอ" เ�ื่อเริ่มต้นคำขอต่อสัญญาใหม่',
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
