// ============================================================================
// license_approve_table.dart
// ============================================================================
// ตารางแสดงรายการ "คำขอต่อสัญญา" — ดีไซน์ใหม่
// - Card-based header + alternating rows + hover state
// - Status pill ใช้สีตามคำสถานะ
// - ปุ่ม "เรียกดู" เป็น pill button
// - Empty / loading state สวยงาม
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:provider/provider.dart';

import '../../../../unity/Enum.dart';
import '../../../../unity/FormatDate.dart';
// ─── ปิดคอลัมเบอร์โทรไว้ก่อน — import หยุดใช้ ───
// import '../../../../unity/FormatPhone.dart';
import '../../../../Model/Review_Model.dart';
import '../theme/license_approve_theme.dart';
import '../../viewmodels/license_approve_view_model.dart';

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
/// ─── ปิดคอลัมเบอร์โทรไว้ก่อน — หยุดใช้ชั่วคราว ───
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

class LicenseApproveTable extends StatelessWidget {
  const LicenseApproveTable({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseApproveViewModel>();

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
            _ApproveCard(
              index: i,
              model: vm.requests[i],
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
          // ─── ปิดคอลัมเบอร์โทรไว้ก่อน ───
          // _HeaderCell(label: 'เบอร์โทร', flex: 2),
          _HeaderCell(label: 'วันที่สิ้นสุด', flex: 2),
          _HeaderCell(label: 'ขั้นตอน', flex: 2),
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
    LicenseApproveViewModel vm,
    ReviewModel model,
    int index,
  ) {
    final nr = model.newRequest;
    final palette = StatusPalette.of(model.statusLabel ?? model.status);
    // ─── รายการ: ใช้ module.name_th ตรงๆ (v2: module.name_th)
    final listName = (model.module?.nameTh?.isNotEmpty == true
            ? model.module!.nameTh
            : null) ??
        (nr?.leaseNumber?.isNotEmpty == true ? nr!.leaseNumber : null) ??
        '-';
    // ─── ขั้นตอน: ใช้ step_name (v2: step.step_name)
    final stepLabel =
        (model.stepName?.isNotEmpty == true ? model.stepName : null) ?? '-';
    // ─── วันที่สิ้นสุด: v2 ไม่มี ldate → fallback ไป created_at
    final endDateRaw = (nr?.ldate?.isNotEmpty == true
            ? nr!.ldate
            : null) ??
        (model.createdAt?.isNotEmpty == true ? model.createdAt : null) ??
        '';
    // ─── UUID หลัก: v2 step_uuid → v1 uuid (model.uuid รวมไว้แล้ว)
    // ถ้าว่างจริงๆ fallback ไป request_uuid (v2) เพื่อให้ copy ได้
    final displayUuid = (model.uuid?.isNotEmpty == true
            ? model.uuid
            : model.requestUuid) ??
        '';
    return _HoverableRow(
      index: index,
      onTap: () => vm.onViewRequest(model),
      child: Row(
        children: [
          // Action
          SizedBox(
            width: 110,
            child: Center(
                child: _ViewButton(onTap: () => vm.onViewRequest(model))),
          ),
          _Cell(value: listName, tooltip: listName, flex: 2),
          _Cell(value: nr?.subzone ?? '', flex: 2),
          _Cell(value: nr?.zn ?? '', flex: 2),
          _Cell(value: nr?.ln ?? '', flex: 2, isMono: true),
          _Cell(
              value: _maskName(model.client?.cname ?? ''),
              tooltip: model.client?.cname,
              flex: 3),
          // ─── ปิดคอลัมเบอร์โทรไว้ก่อน ───
          // _Cell(
          //     value: _maskPhone(formatPhoneNumber(model.client?.tel ?? "")),
          //     tooltip: formatPhoneNumber(model.client?.tel ?? ""),
          //     flex: 2,
          //     isMono: true),
          _Cell(
              value: formatDate(endDateRaw, type: DateFormatType.dmy),
              flex: 2,
              isMono: true),
          _Cell(value: stepLabel, tooltip: stepLabel, flex: 2),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _StatusPill(
                label: model.statusLabel ?? model.status ?? '-',
                palette: palette,
              ),
            ),
          ),
          _CopyUuidCell(
            fullValue: displayUuid,
            display: _shortUuid(displayUuid),
            flex: 2,
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

class _ApproveCard extends StatefulWidget {
  final int index;
  final ReviewModel model;
  final VoidCallback onTap;

  const _ApproveCard({
    required this.index,
    required this.model,
    required this.onTap,
  });

  @override
  State<_ApproveCard> createState() => _ApproveCardState();
}

class _ApproveCardState extends State<_ApproveCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.model;
    final nr = m.newRequest;
    final palette = StatusPalette.of(m.statusLabel ?? m.status ?? '');
    // รายการ: ใช้ module.name_th ตรงๆ
    final listName = (m.module?.nameTh?.isNotEmpty == true
            ? m.module!.nameTh
            : null) ??
        (nr?.leaseNumber?.isNotEmpty == true ? nr!.leaseNumber : null) ??
        '-';
    // ขั้นตอน: ใช้ step_name
    final stepLabel =
        (m.stepName?.isNotEmpty == true ? m.stepName : null) ?? '-';
    // วันที่สิ้นสุด: fallback ldate → createdAt
    final endDateRaw = (nr?.ldate?.isNotEmpty == true
            ? nr!.ldate
            : null) ??
        (m.createdAt?.isNotEmpty == true ? m.createdAt : null) ??
        '';
    final displayUuid = (m.uuid?.isNotEmpty == true ? m.uuid : m.requestUuid) ??
        '';
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
                        Text(
                          listName,
                          style: LaText.h2.copyWith(fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _maskName(m.client?.cname ?? ''),
                          style: LaText.bodyMuted,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: LaSpace.sm),
                  _StatusPill(
                    label: m.statusLabel ?? m.status ?? '-',
                    palette: palette,
                  ),
                ],
              ),
              const SizedBox(height: LaSpace.md),
              const Divider(height: 1, color: LaColors.border),
              const SizedBox(height: LaSpace.md),
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
              // ─── ปิดคอลัมเบอร์โทรไว้ก่อน ───
              // _CardRow(
              //   icon: Icons.phone_outlined,
              //   label: 'เบอร์โทร',
              //   value: _maskPhone(formatPhoneNumber(m.client?.tel ?? '')),
              //   isMono: true,
              // ),
              _CardRow(
                icon: Icons.event_outlined,
                label: 'วันที่สิ้นสุด',
                value: formatDate(endDateRaw, type: DateFormatType.dmy),
                isMono: true,
              ),
              _CardRow(
                icon: Icons.checklist_rounded,
                label: 'ขั้นตอน',
                value: stepLabel,
              ),
              _CardRow(
                icon: Icons.fingerprint,
                label: 'รหัสรายการ',
                value: _shortUuid(displayUuid),
                isMono: true,
                muted: true,
              ),
              const SizedBox(height: LaSpace.md),
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
  final IconData icon;
  final String label;
  final String value;
  final bool isMono;
  final bool muted;

  const _CardRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isMono = false,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: LaColors.textSecondary),
          const SizedBox(width: 6),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: LaText.bodyMuted.copyWith(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: LaText.tableCell.copyWith(
                color: muted ? LaColors.textSecondary : LaColors.textPrimary,
                fontFamily: isMono ? 'monospace' : LaText.fontRegular,
                fontFamilyFallback: const [LaText.fontRegular],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
