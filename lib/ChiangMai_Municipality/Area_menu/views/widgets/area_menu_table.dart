// ============================================================================
// area_menu_table.dart
// ============================================================================
// ตารางแสดงรายการ "คำขอต่อสัญญา" — copy รูปแบบจาก tenant_license_table.dart
// - Card-based header + alternating rows + InkWell hover
// - Status pill ใช้สีตาม StatusPalette (จาก Enum.dart)
// - "เรียกดู" pill button มี hover state
// - Empty / loading state วยงาม
// ✅ SELF-CONTAINED — รับ Map<String, dynamic> เป็น data type
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../unity/Enum.dart';
import '../../../unity/FormatDate.dart';
import '../theme/area_menu_theme.dart';
import '../../viewmodels/area_menu_view_model.dart';

class AreaMenuTable extends StatelessWidget {
  const AreaMenuTable({super.key});

  // Map status label — derive จาก item (API areas/overview)
  // - ldate < วันนี้ && requester != null → "หมดสัญญา"
  // - requester != null → "เช่าอยู่"
  // - requester == null → "ว่าง"
  String _statusLabel(Map<String, dynamic> m) {
    final requester = m['requester']?.toString() ?? '';
    final hasRequester = requester.isNotEmpty;
    final ldateRaw = m['ldate']?.toString() ?? '';

    if (hasRequester && ldateRaw.isNotEmpty) {
      try {
        final ldate = DateTime.parse(ldateRaw);
        final today = DateTime.now();
        final end = DateTime(ldate.year, ldate.month, ldate.day);
        final now = DateTime(today.year, today.month, today.day);
        if (end.isBefore(now)) return 'หมดสัญญา';
      } catch (_) {}
    }

    if (hasRequester) return 'เช่าอยู่';
    return 'ว่าง';
  }

  /// Format รหัสล็อค — เก็บ helper ไว้ (ใช้ผ่าน model['lock'] ตรง ๆ ใน _dataRow)
  /// ignore: unused_element
  String _formatLocationCode(Map<String, dynamic> m) {
    final lock = m['lock']?.toString() ?? '';
    return lock.isEmpty ? '-' : lock;
  }

  /// Mask ชื่อผู้ติดต่อ — ชื่อต้นแสดงเต็ม นามสกุลซ่อน 3 ตัวอักษรท้าย
  /// เช่น "นางกชกร วิชชุชัยมงคล" → "นางกชกร วิชชุชัยม***"
  String _maskName(String? raw) {
    final name = raw?.toString().trim() ?? '';
    if (name.isEmpty) return '-';
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

  String _formatEndDate(String raw) {
    if (raw.isEmpty) return '-';
    try {
      return formatDate(raw, type: DateFormatType.dmy);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AreaMenuViewModel>();

    if (vm.isLoading && vm.requests.isEmpty) {
      return const _LoadingState();
    }
    if (vm.requests.isEmpty) {
      return _EmptyState(
        hasFilter: vm.searchQuery.isNotEmpty ||
            (vm.selectedZoneSub.isNotEmpty &&
                vm.selectedZoneSub != 'ทั้งหมด') ||
            (vm.selectedZone.isNotEmpty &&
                vm.selectedZone != 'ทั้งหมด') ||
            vm.selectedStatus != 'ทั้งหมด' ||
            vm.selectedRequestStatus != 'ทั้งหมด',
        onClear: vm.refresh,
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
          _HeaderCell(label: 'ล็อค', flex: 2),
          _HeaderCell(label: 'โซน', flex: 2),
          _HeaderCell(label: 'หมวด', flex: 2),
          _HeaderCell(label: 'รหัสลูกค้า', flex: 2),
          _HeaderCell(label: 'ชื่อผู้ติดต่อ', flex: 3),
          _HeaderCell(label: 'วันที่สิ้นสุด', flex: 2),
          _HeaderCell(label: 'สถานะ', flex: 2),
        ],
      ),
    );
  }

  Widget _dataRow(
    BuildContext context,
    AreaMenuViewModel vm,
    Map<String, dynamic> model,
    int index,
  ) {
    final status = _statusLabel(model);
    final palette = StatusPalette.of(status);
    return _HoverableRow(
      index: index,
      onTap: () => vm.onViewRequest(model),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Center(
                child: _ViewButton(onTap: () => vm.onViewRequest(model))),
          ),
          _Cell(value: (model['lock'] ?? '-').toString(), flex: 2, isMono: true),
          _Cell(value: (model['zone'] ?? '-').toString(), flex: 2),
          _Cell(value: (model['subzone'] ?? '-').toString(), flex: 2),
          _Cell(value: (model['customer_no'] ?? '-').toString(), flex: 2, isMono: true),
          _Cell(
            value: _maskName(model['requester']),
            tooltip: model['requester']?.toString(),
            flex: 3,
          ),
          _Cell(
              value: _formatEndDate((model['ldate'] ?? '').toString()),
              flex: 2,
              isMono: true),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _StatusPill(
                label: status,
                palette: palette,
              ),
            ),
          ),
        ],
      ),
    );
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

class _StatusPill extends StatelessWidget {
  final String label;
  final StatusPalette palette;
  const _StatusPill({required this.label, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
            const SizedBox(width: 5),
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
    // Reset hover เมื่อ data เลี่ยน — ป้องกัน hover state ค้างจาก row เก่า
    if (oldWidget.index != widget.index) {
      _hover = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.index.isEven ? Colors.white : LaColors.surfaceMuted;
    // ✅ สลับสี row + hover (ใช้ InkWell — แม่นยำกว่า MouseRegion)
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
              label: const Text('รีเรช'),
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
