// ============================================================================
// license_submit_approval_table.dart
// ============================================================================
// ตารางแสดงรายการ "คำขอต่อสัญญา" — ดีไซน์ใหม่
// - Card-based header + alternating rows + hover state
// - Status pill ใช้สีตามคำสถานะ
// - ปุ่ม "เรียกดู" เป็น pill button
// - Empty / loading state สวยงาม
//
// v2 (2026-05): ใช้ data จาก /api/v2/admin/requests/tasks/approvals
//   - "รายการ" → module.name_th (d.moduleName)
//   - เพิ่มคอลัม "ขั้นตอนรอ" (d.pendingStepCount) ก่อน "สถานะ"
//   - คอมเมนต์ "เบอร์โทร" ออก (เก็บไว้ใน detail page)
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:provider/provider.dart';

import '../../../../unity/Enum.dart';
import '../../../../unity/FormatDate.dart' as fd;
// import '../../../../unity/FormatPhone.dart'; // คอมเมนต์ปิดเบอร์โทรออก
import '../../models/license_submit_approval_detail_model.dart';
import '../theme/license_submit_approval_theme.dart';
import '../../viewmodels/license_submit_approval_view_model.dart';

/// Breakpoint: < 900px = โทรศัพท์/แท็บเล็ต → ใช้ card layout
const double kLicenseMenuMobileBreakpoint = 900;

bool _isLicenseListMobile(BuildContext context) =>
    MediaQuery.of(context).size.width < kLicenseMenuMobileBreakpoint;

// ============================================================================
// Top-level helpers (ใช้ร่วมระหว่าง row + card)
// ============================================================================

String _shortUuid(String uuid) {
  if (uuid.isEmpty) return '-';
  if (uuid.length <= 12) return uuid;
  return '${uuid.substring(0, 8)}…';
}

/// Mask ชื่อ — ซ่อน 3 ตัวอักษรท้ายของนามสกุล
String _maskName(String raw) {
  final name = raw.trim();
  if (name.isEmpty || name == '-') return '-';
  final words = name.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
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
// (คอมเมนต์ปิดเบอร์โทรในตารางนี้ — เก็บไว้ใช้ในอนาคต)
// String _maskPhone(String raw) {
//   if (raw.isEmpty || raw == '-') return '-';
//   final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
//   if (digits.length <= 3) return raw;
//
//   final maskedDigits = digits.substring(0, digits.length - 3) + '***';
//
//   if (digits.length == 10) {
//     return '${maskedDigits.substring(0, 3)}-${maskedDigits.substring(3, 6)}-${maskedDigits.substring(6)}';
//   }
//   if (digits.length == 9) {
//     return '${maskedDigits.substring(0, 2)}-${maskedDigits.substring(2, 5)}-${maskedDigits.substring(5)}';
//   }
//   return maskedDigits;
// }

class LicenseSubmitApprovalTable extends StatelessWidget {
  const LicenseSubmitApprovalTable({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseSubmitApprovalViewModel>();

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
            _SubmitApprovalCard(
              index: i,
              detail: vm.requests[i],
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
          // Subtle skeleton ตอน refetch
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
  //                   วันที่สิ้นสุด, ขั้นตอนรอ, สถานะ, รหัสรายการ)
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
          // _HeaderCell(label: 'วันที่สิ้นสุด', flex: 2), // คอมเมนต์ปิดวันที่สิ้นสุด
          _HeaderCell(label: 'อนุมัติ', flex: 1),
          _HeaderCell(label: 'ขั้นตอนรอ', flex: 2),
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
    LicenseSubmitApprovalViewModel vm,
    SubmitApprovalDetail payment,
    int index,
  ) {
    final nr = payment.newRequest;
    final palette = StatusPalette.of(payment.statusLabel);
    return _HoverableRow(
      index: index,
      child: Row(
        children: [
          // Action
          SizedBox(
            width: 110,
            child: Center(
                child: _ViewButton(onTap: () => vm.onViewRequest(payment))),
          ),
          // รายการ — ใช้ module.name_th (v2)
          _Cell(
              value: payment.moduleName.isEmpty ? '-' : payment.moduleName,
              flex: 2),
          // บริเวณ — จาก details.subzone (v2) → fallback paymentSystem
          _Cell(value: nr?.subzone ?? '', flex: 2),
          // โซนพื้นที่ — จาก details.zn (v2) → fallback payType
          _Cell(value: nr?.zn ?? '', flex: 2),
          // รหัสพื้นที่ — จาก details.ln (v2) → fallback methodName
          _Cell(value: nr?.ln ?? '', flex: 2, isMono: true),
          _Cell(
              value: _maskName(payment.client?.cname ?? ''),
              tooltip: payment.client?.cname,
              flex: 3),
          // _Cell(
          //     value: _maskPhone(formatPhoneNumber(payment.client?.tel ?? "")),
          //     tooltip: formatPhoneNumber(payment.client?.tel ?? ""),
          //     flex: 2,
          //     isMono: true), // คอมเมนต์ปิดเบอร์โทร
          // _Cell(
          //     value: fd.formatDate(nr?.ldate ?? '', type: DateFormatType.dmy),
          //     flex: 2,
          //     isMono: true), // คอมเมนต์ปิดวันที่สิ้นสุด
          // อนุมัติ — approval_pending (false = อนุมัติแล้ว)
          Expanded(
            flex: 1,
            child: _BoolCheck(value: payment.approvalPending),
          ),
          // ขั้นตอนรอ (v2 ใหม่) — ก่อนหน้าสถานะ
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: _PendingStepBadge(count: payment.pendingStepCount),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _StatusPill(
                label: payment.statusLabel,
                palette: palette,
              ),
            ),
          ),
          _CopyUuidCell(
            fullValue: payment.uuid,
            display: _shortUuid(payment.uuid),
            flex: 2,
          ),
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

/// Copyable UUID cell — short uuid + persistent copy icon
/// Checkbox icon แสดง boolean — true → ติ๊กถูกสีเขียว, false → กล่องว่าง
class _BoolCheck extends StatelessWidget {
  final bool value;
  const _BoolCheck({required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Align(
        alignment: Alignment.center,
        child: Tooltip(
          message: value ? 'ดำเนินการแล้ว' : 'ยังไม่ดำเนินการ',
          waitDuration: const Duration(milliseconds: 200),
          child: Icon(
            value
                ? Icons.check_box_rounded
                : Icons.check_box_outline_blank_rounded,
            size: 18,
            color: value ? const Color(0xFF15803D) : LaColors.textMuted,
          ),
        ),
      ),
    );
  }
}

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
    // กัน assert fail: ต้องมีทั้ง Scaffold + ScaffoldMessenger ancestor
    if (Scaffold.maybeOf(context) == null) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
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

/// แสดงจำนวน "ขั้นตอนรอ" (pending_step_count) — ใช้ก่อน status pill
/// count == 0 → ซ่อน (ไม่มีขั้นตอนค้าง = ผ่านครบ)
/// count > 0 → icon + ตัวเลข สีฟ้า (ไม่มีกรอบ / ไม่มี background)
class _PendingStepBadge extends StatelessWidget {
  final int count;
  const _PendingStepBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return Center(
        child: Text(
          '-',
          style: LaText.tableCell.copyWith(color: LaColors.textMuted),
        ),
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Tooltip(
        message: 'ขั้นตอนที่รอดำเนินการ $count รายการ',
        waitDuration: const Duration(milliseconds: 250),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.hourglass_top_rounded,
              size: 14,
              color: LaColors.primary, // สีฟ้า
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: LaText.tableCell.copyWith(
                color: LaColors.primary, // สีฟ้า
                fontWeight: FontWeight.w700,
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
  final VoidCallback? onTap;
  const _HoverableRow({
    required this.index,
    required this.child,
    this.onTap,
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
        onHover: widget.onTap == null
            ? null
            : (hover) {
                // onHover จาก InkWell จัดการ state ได้แม่นยำกว่า MouseRegion
                if (hover != _hover) {
                  setState(() => _hover = hover);
                }
              },
        hoverColor: widget.onTap == null ? null : hoverColor,
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

// ============================================================================
// Mobile card layout
// ============================================================================

class _SubmitApprovalCard extends StatefulWidget {
  final int index;
  final SubmitApprovalDetail detail;
  final VoidCallback onTap;

  const _SubmitApprovalCard({
    required this.index,
    required this.detail,
    required this.onTap,
  });

  @override
  State<_SubmitApprovalCard> createState() => _SubmitApprovalCardState();
}

class _SubmitApprovalCardState extends State<_SubmitApprovalCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.detail;
    final nr = d.newRequest;
    final palette = StatusPalette.of(d.statusLabel);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (h) {
          if (h != _hover) setState(() => _hover = h);
        },
        borderRadius: BorderRadius.circular(LaRadius.lg),
        child: AnimatedContainer(
          duration: LrAnimations.fast,
          curve: Curves.easeOut,
          decoration: LaDecor.card().copyWith(
            border: Border.all(
              color: _hover ? LaColors.primary : LaColors.border,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _hover
                    ? LaColors.primary.withOpacity(.08)
                    : Colors.black.withOpacity(.04),
                blurRadius: _hover ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(LaSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header row: index circle + title + status pill ───
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: LaColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${widget.index + 1}',
                      style: LaText.tableHeader.copyWith(
                        color: LaColors.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: LaSpace.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // v2: title = module.name_th (d.moduleName)
                        Text(
                          d.moduleName.isEmpty
                              ? (d.paymentNo.isEmpty ? '-' : d.paymentNo)
                              : d.moduleName,
                          style: LaText.h2.copyWith(fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _maskName(d.client?.cname ?? ''),
                          style: LaText.bodyMuted,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: LaSpace.sm),
                  _StatusPill(label: d.statusLabel, palette: palette),
                ],
              ),
              const SizedBox(height: LaSpace.sm),
              const Divider(height: 1, color: LaColors.border),
              const SizedBox(height: LaSpace.sm),
              // ─── Detail rows ───
              _CardRow(
                icon: Icons.place_outlined,
                label: 'บริเวณ',
                value: nr?.subzone ?? '-',
              ),
              _CardRow(
                icon: Icons.layers_outlined,
                label: 'โซนพื้นที่',
                value: nr?.zn ?? '-',
              ),
              _CardRow(
                icon: Icons.tag,
                label: 'รหัสพื้นที่',
                value: nr?.ln ?? '-',
                isMono: true,
              ),
              // _CardRow(
              //   icon: Icons.phone_outlined,
              //   label: 'เบอร์โทร',
              //   value: _maskPhone(formatPhoneNumber(d.client?.tel ?? '')),
              //   isMono: true,
              // ), // คอมเมนต์ปิดเบอร์โทร
              _CardRow(
                icon: Icons.event_outlined,
                label: 'วันที่สิ้นสุด',
                value: fd.formatDate(nr?.ldate ?? '', type: DateFormatType.dmy),
                isMono: true,
              ),
              _CardRow(
                icon: null, // ไม่มี icon (เคยมี hourglass_top_rounded)
                label: 'ขั้นตอนรอ',
                value: d.pendingStepCount > 0
                    ? '${d.pendingStepCount} รายการ'
                    : '-',
                muted: d.pendingStepCount == 0,
              ),
              _CardRow(
                icon: Icons.fingerprint,
                label: 'รหัสรา�การ',
                value: _shortUuid(d.uuid),
                isMono: true,
                muted: true,
                uuidCopy: d.uuid,
              ),
              const SizedBox(height: LaSpace.sm),
              // ─── Action button ───
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.onTap,
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('เรียกดู'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LaColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(LaRadius.pill),
                    ),
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

class _CardRow extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String value;
  final bool isMono;
  final bool muted;
  final String? uuidCopy;

  const _CardRow({
    this.icon,
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
                // กัน assert fail: ต้องมีทั้ง Scaffold + ScaffoldMessenger ancestor
                if (Scaffold.maybeOf(context) == null) return;
                final messenger = ScaffoldMessenger.maybeOf(context);
                if (messenger == null) return;
                messenger.hideCurrentSnackBar();
                messenger.showSnackBar(
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
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: LaColors.textSecondary),
            const SizedBox(width: 6),
          ],
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: LaText.bodyMuted.copyWith(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          valueChild,
        ],
      ),
    );
  }
}
