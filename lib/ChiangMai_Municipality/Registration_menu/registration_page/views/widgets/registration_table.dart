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
import 'register_line_dialog.dart';

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
          _HeaderCell(label: 'เลขบัตรประชาชน', flex: 2),
          _HeaderCell(label: 'เบอร์โทร', flex: 2),
          _HeaderCell(label: 'แอพผู้เช่า', flex: 2),
          _HeaderCell(label: 'ไลน์', flex: 3),
          _HeaderCell(label: 'สถานะ', flex: 2),
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
          _Cell(
            value: _maskName(model.cname ?? model.scname ?? '-'),
            tooltip: model.cname ?? model.scname,
            flex: 3,
          ),
          _Cell(
            value: _maskTax(model.tax ?? '-'),
            tooltip: model.tax,
            flex: 2,
          ),
          _Cell(
            value: _maskPhone(formatPhoneNumber(model.tel ?? '')),
            tooltip: formatPhoneNumber(model.tel ?? ''),
            flex: 2,
            isMono: true,
          ),
          // ✅ แอพผู้เช่า (toggle แยก — ใช้ local state จนกว่า API จะมา)
          _SwitchCell(
            value: vm.appStatusFor(model.uuid?.toString() ?? '') ?? false,
            flex: 2,
            onTap: () =>
                vm.toggleCustomerAppAccess(model.uuid?.toString() ?? ''),
            onLabel: 'อนุญาต',
            offLabel: 'ไม่อนุญาต',
          ),
          // ✅ ไลน์ — ถ้าว่าง → ปุ่ม "ลงทะเบียน", ถ้ามี → ชื่อไลน์ + ปุ่ม "ลบ"
          _LineCell(
            lineid: model.lineid,
            lineRegisUrl: model.lineRegisUrl,
            tax: model.tax,
            flex: 3,
            onRegister: () => vm.registerLine(model.uuid?.toString() ?? ''),
            onRemove: () => vm.removeLine(model.uuid?.toString() ?? ''),
          ),
          // ✅ สถานะ (toggle จริง — เรียก API)
          _SwitchCell(
            value: _isOn(model.st),
            flex: 2,
            onTap: () => vm.toggleAppAccess(model.uuid?.toString() ?? ''),
          ),
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

  /// แปลง st (dynamic) → bool
  /// st = 1 → true (เปิด), อื่นๆ → false (ปิด)
  static bool _isOn(dynamic st) {
    if (st == null) return false;
    if (st is bool) return st;
    if (st is num) return st == 1;
    if (st is String) {
      final s = st.trim();
      return s == '1' || s.toLowerCase() == 'true';
    }
    return false;
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

/// Cell ที่แสดงเป็นสวิตเปิด/ปิด (pill + dot)
class _SwitchCell extends StatefulWidget {
  final bool value;
  final int flex;
  final VoidCallback? onTap;
  final String onLabel;
  final String offLabel;
  const _SwitchCell({
    required this.value,
    this.flex = 1,
    this.onTap,
    this.onLabel = 'ใช้งาน',
    this.offLabel = 'ยกเลิก',
  });

  @override
  State<_SwitchCell> createState() => _SwitchCellState();
}

class _SwitchCellState extends State<_SwitchCell> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final on = widget.value;
    final clickable = widget.onTap != null;
    return Expanded(
      flex: widget.flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Align(
          alignment: Alignment.centerLeft,
          child: MouseRegion(
            cursor:
                clickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
            onEnter: (_) {
              if (clickable) setState(() => _hover = true);
            },
            onExit: (_) {
              if (clickable) setState(() => _hover = false);
            },
            child: GestureDetector(
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      on ? LaColors.statusApprovedBg : LaColors.statusNeutralBg,
                  borderRadius: BorderRadius.circular(LaRadius.pill),
                  border: Border.all(
                    color: on
                        ? LaColors.statusApprovedFg.withOpacity(.35)
                        : LaColors.statusNeutralFg.withOpacity(.25),
                    width: 1,
                  ),
                  boxShadow: _hover && clickable
                      ? [
                          BoxShadow(
                            color: (on
                                    ? LaColors.statusApprovedFg
                                    : LaColors.statusNeutralFg)
                                .withOpacity(.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // จุดเล็ก
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: on
                            ? LaColors.statusApprovedFg
                            : LaColors.statusNeutralFg,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      on ? widget.onLabel : widget.offLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: on
                            ? LaColors.statusApprovedFg
                            : LaColors.statusNeutralFg,
                      ),
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

/// Cell "ไลน์" — แสดงชื่อ+ปุ่มลบ ถ้ามีข้อมูล, ปุ่ม "ลงทะเบียน" ถ้าว่าง
class _LineCell extends StatelessWidget {
  final String? lineid;
  final String? lineRegisUrl;
  final String? tax;
  final int flex;
  final VoidCallback onRegister;
  final VoidCallback onRemove;
  const _LineCell({
    required this.lineid,
    required this.lineRegisUrl,
    required this.tax,
    required this.flex,
    required this.onRegister,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasLine = (lineid ?? '').trim().isNotEmpty;
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Align(
          alignment: Alignment.centerLeft,
          child: hasLine
              ? _LineWithRemove(
                  lineid: lineid!,
                  onRemove: onRemove,
                )
              : _RegisterButton(
                  onTap: () {
                    // เปิด QR dialog ทันที (ถ้ามี line_regis_url)
                    final url = (lineRegisUrl ?? '').trim();
                    if (url.isNotEmpty) {
                      showRegisterLineDialog(
                        context,
                        lineRegisUrl: url,
                        tax: tax ?? '',
                      );
                    } else {
                      // fallback — เรียก VM stub
                      onRegister();
                    }
                  },
                ),
        ),
      ),
    );
  }
}

class _RegisterButton extends StatefulWidget {
  final VoidCallback onTap;
  const _RegisterButton({required this.onTap});

  @override
  State<_RegisterButton> createState() => _RegisterButtonState();
}

class _RegisterButtonState extends State<_RegisterButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'ลงทะเบียนไลน์',
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _hover
                  ? LaColors.primary.withOpacity(.12)
                  : LaColors.primaryLight,
              borderRadius: BorderRadius.circular(LaRadius.pill),
              border: Border.all(
                color: _hover ? LaColors.primary : LaColors.primaryDark,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_link_rounded,
                  size: 12,
                  color: LaColors.primaryDark,
                ),
                const SizedBox(width: 4),
                Text(
                  'ลงทะเบียน',
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
      ),
    );
  }
}

class _LineWithRemove extends StatefulWidget {
  final String lineid;
  final VoidCallback onRemove;
  const _LineWithRemove({required this.lineid, required this.onRemove});

  @override
  State<_LineWithRemove> createState() => _LineWithRemoveState();
}

class _LineWithRemoveState extends State<_LineWithRemove> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_rounded,
            size: 14,
            color: const Color(0xFF06C755), // LINE green
          ),
          const SizedBox(width: 4),
          Flexible(
            child: AutoSizeText(
              widget.lineid,
              minFontSize: 11,
              maxFontSize: 14,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LaText.tableCell,
            ),
          ),
          const SizedBox(width: 4),
          Tooltip(
            message: 'ลบไลน์',
            child: InkWell(
              onTap: widget.onRemove,
              borderRadius: BorderRadius.circular(LaRadius.pill),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color:
                      _hover ? LaColors.statusRejectedBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(LaRadius.pill),
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color:
                      _hover ? LaColors.statusRejectedFg : LaColors.textMuted,
                ),
              ),
            ),
          ),
        ],
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
