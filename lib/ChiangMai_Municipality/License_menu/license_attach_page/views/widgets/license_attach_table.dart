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
// Data shape: AttachTask (v2 /admin/requests/tasks/attachments)
// Column swap: เลขที่สัญญา = module, รหัสพื้นที่ = lease ln
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:provider/provider.dart';

import '../../../../unity/Enum.dart';
import '../../../../unity/FormatDate.dart';
import '../../../../unity/FormatPhone.dart';
import '../../models/attach_task_model.dart';
import '../theme/license_attach_theme.dart';
import '../../viewmodels/license_attach_view_model.dart';

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
          _HeaderCell(label: 'เ�ขที่สัญญา', flex: 2),
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
    AttachTask task,
    int index,
  ) {
    final moduleLabel = task.module.nameTh.isNotEmpty
        ? task.module.nameTh
        : task.module.code;
    final palette = StatusPalette.of(task.statusLabel);
    return _HoverableRow(
      index: index,
      onTap: () => vm.onViewRequest(task),
      child: Row(
        children: [
          // Action
          SizedBox(
            width: 110,
            child: Center(
                child: _ViewButton(onTap: () => vm.onViewRequest(task))),
          ),
          // เลขที่สัญญา (swap → module label)
          _Cell(value: moduleLabel, flex: 2, isMono: true),
          _Cell(value: task.details.subzone, flex: 2),
          _Cell(value: task.details.zn, flex: 2),
          // รหัสพื้นที่ (swap → lease ln)
          _Cell(
              value: task.details.ln.isEmpty ? '-' : task.details.ln,
              flex: 2,
              isMono: true),
          _Cell(
              value: _maskName(task.customer.cname),
              flex: 3),
          _Cell(
              value: _maskPhone(formatPhoneNumber(task.customer.tel)),
              flex: 2,
              isMono: true),
          _Cell(
              value: formatDate(task.submittedAt, type: DateFormatType.dmy),
              flex: 2,
              isMono: true),
          Expanded(
            flex: 2,
            child: _StatusPill(
              label: task.statusLabel,
              palette: palette,
            ),
          ),
          Expanded(
            flex: 2,
            child: _CopyUuidCell(
              shortUuid: _shortUuid(task.uuid),
              fullUuid: task.uuid,
            ),
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
class _CopyUuidCell extends StatefulWidget {
  final String shortUuid;
  final String fullUuid;
  const _CopyUuidCell({required this.shortUuid, required this.fullUuid});

  @override
  State<_CopyUuidCell> createState() => _CopyUuidCellState();
}

class _CopyUuidCellState extends State<_CopyUuidCell> {
  bool _hover = false;

  Future<void> _copy() async {
    if (widget.fullUuid.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: widget.fullUuid));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('คัดลอกรหัสรา�การแล้ว'),
        duration: Duration(milliseconds: 1200),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: MouseRegion(
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: GestureDetector(
            onTap: _copy,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: AutoSizeText(
                    widget.shortUuid,
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
                Icon(
                  Icons.content_copy_rounded,
                  size: 12,
                  color: _hover ? LaColors.primary : LaColors.textMuted,
                ),
              ],
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
