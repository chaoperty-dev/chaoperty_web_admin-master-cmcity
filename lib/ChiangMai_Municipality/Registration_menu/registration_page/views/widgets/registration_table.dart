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
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
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

    return LayoutBuilder(
      builder: (context, c) {
        final isMobile = c.maxWidth < 700;
        if (isMobile) {
          return SingleChildScrollView(
            child: Column(
              children: [
                if (vm.isLoading)
                  const LinearProgressIndicator(
                    minHeight: 2,
                    backgroundColor: LaColors.surfaceMuted,
                    valueColor: AlwaysStoppedAnimation<Color>(LaColors.primary),
                  ),
                for (int i = 0; i < paged.length; i++) ...[
                  _RegistrationCard(
                    index: i,
                    model: paged[i],
                    maskedName:
                        _maskName(paged[i].cname ?? paged[i].scname ?? '-'),
                    maskedTax: _maskTax(paged[i].tax ?? '-'),
                    maskedPhone:
                        _maskPhone(formatPhoneNumber(paged[i].tel ?? '')),
                    onView: () => vm.onViewCustomer(paged[i]),
                    appOn: vm.appStatusFor(paged[i].uuid?.toString() ?? '') ??
                        false,
                    onToggleApp: () => vm.toggleCustomerAppAccess(
                        paged[i].uuid?.toString() ?? ''),
                    onRegisterLine: () =>
                        vm.registerLine(paged[i].uuid?.toString() ?? ''),
                    onRemoveLine: () =>
                        vm.removeLine(paged[i].uuid?.toString() ?? ''),
                    statusOn: _isOn(paged[i].st),
                    onToggleStatus: () =>
                        vm.toggleAppAccess(paged[i].uuid?.toString() ?? ''),
                  ),
                  if (i < paged.length - 1) const SizedBox(height: LaSpace.sm),
                ],
              ],
            ),
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
      },
    );
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
          _HeaderCell(label: 'สิทธิแอพผู้เช่า', flex: 2),
          _HeaderCell(label: 'ชื่อไลน์', flex: 2),
          _HeaderCell(label: 'สิทธิใช้งานไลน์', flex: 2),
          // _HeaderCell(label: 'สถานะ', flex: 2), // ปิดไว้: เอาสถานะออก
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
          _CopyCell(
            value: model.custno ?? '-',
            copyValue: model.custno ?? '',
            flex: 2,
            isMono: true,
          ),
          _CopyCell(
            value: _maskName(model.cname ?? model.scname ?? '-'),
            copyValue: model.cname ?? model.scname ?? '',
            flex: 3,
          ),
          _CopyCell(
            value: _maskTax(model.tax ?? '-'),
            copyValue: model.tax ?? '',
            flex: 2,
            isMono: true,
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
          _CopyCell(
            value: model.regDisplayname?.isNotEmpty == true
                ? model.regDisplayname!
                : (model.lineid?.isNotEmpty == true ? model.lineid! : '-'),
            copyValue: model.regDisplayname?.isNotEmpty == true
                ? model.regDisplayname!
                : (model.lineid ?? ''),
            flex: 2,
          ),
          // ✅ สิทธิใช้งานไลน์ (toggle)
          _SwitchCell(
            value: vm.lineStatusFor(model.uuid?.toString() ?? '') ?? false,
            flex: 2,
            onTap: () =>
                vm.toggleCustomerLineAccess(model.uuid?.toString() ?? ''),
            onLabel: 'อนุญาต',
            offLabel: 'ไม่อนุญาต',
          ),
          // ✅ สถานะ (toggle จริง — เรียก API) — ปิดไว้: เอาสถานะออก
          // _SwitchCell(
          //   value: _isOn(model.st),
          //   flex: 2,
          //   onTap: () => vm.toggleAppAccess(model.uuid?.toString() ?? ''),
          // ),
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

/// Copyable cell — แสดงข้อความ + ไอคอน content_copy คลิกเพื่อคัดลอก
/// - [value]: ข้อความที่แสดง (อาจ mask แล้ว)
/// - [copyValue]: ข้อความต้นฉบับที่จะคัดลอก (ถ้า�่างจะไม่คัดลอก)
class _CopyCell extends StatelessWidget {
  final String value;
  final String copyValue;
  final int flex;
  final bool isMono;
  const _CopyCell({
    required this.value,
    required this.copyValue,
    this.flex = 1,
    this.isMono = false,
  });

  Future<void> _copy(BuildContext context) async {
    if (copyValue.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: copyValue));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'คัดลอก: $copyValue',
                style: const TextStyle(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
    final display = value.isEmpty ? '-' : value;
    final canCopy = copyValue.isNotEmpty;
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Tooltip(
          message: canCopy ? 'คลิกเ�ื่อคัดลอก: $copyValue' : display,
          waitDuration: const Duration(milliseconds: 300),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
              onTap: canCopy ? () => _copy(context) : null,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: AutoSizeText(
                        display,
                        minFontSize: 11,
                        maxFontSize: 14,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LaText.tableCell.copyWith(
                          color: LaColors.textPrimary,
                          fontFamily: isMono ? 'monospace' : LaText.fontRegular,
                          fontFamilyFallback: const [LaText.fontRegular],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.content_copy_rounded,
                      size: 12,
                      color: canCopy ? LaColors.textMuted : LaColors.border,
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
                    Flexible(
                      child: Text(
                        on ? widget.onLabel : widget.offLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: on
                              ? LaColors.statusApprovedFg
                              : LaColors.statusNeutralFg,
                        ),
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
    final fg = LaColors.statusNeutralFg;
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
              color: _hover ? fg.withOpacity(.15) : LaColors.statusNeutralBg,
              borderRadius: BorderRadius.circular(LaRadius.pill),
              border: Border.all(
                color: _hover ? fg.withOpacity(.55) : fg.withOpacity(.25),
                width: 1,
              ),
              boxShadow: _hover
                  ? [
                      BoxShadow(
                        color: fg.withOpacity(.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: fg,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'ลงทะเบียน',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: fg,
                      fontFamily: LaText.fontBold,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
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

// ============================================================================
// Card layout (mobile / narrow screen)
// ============================================================================
class _RegistrationCard extends StatelessWidget {
  final int index;
  final CustomerModel model;
  final String maskedName;
  final String maskedTax;
  final String maskedPhone;
  final VoidCallback onView;
  final bool appOn;
  final VoidCallback onToggleApp;
  final VoidCallback onRegisterLine;
  final VoidCallback onRemoveLine;
  final bool statusOn;
  final VoidCallback onToggleStatus;
  const _RegistrationCard({
    required this.index,
    required this.model,
    required this.maskedName,
    required this.maskedTax,
    required this.maskedPhone,
    required this.onView,
    required this.appOn,
    required this.onToggleApp,
    required this.onRegisterLine,
    required this.onRemoveLine,
    required this.statusOn,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final hasLine = (model.lineid ?? '').trim().isNotEmpty;
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.md),
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
                  maskedName,
                  style: LaText.tableCell.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if ((model.custno ?? '').isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: LaColors.primaryLight.withOpacity(.4),
                    borderRadius: BorderRadius.circular(LaRadius.pill),
                  ),
                  child: Text(
                    model.custno!,
                    style: LaText.bodyMuted.copyWith(
                      color: LaColors.primaryDark,
                      fontSize: 11,
                      fontFamily: 'monospace',
                      fontFamilyFallback: const [LaText.fontRegular],
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: LaSpace.lg, color: LaColors.border),
          _RegCardRow(label: 'เลขบัตรประชาชน', value: maskedTax, isMono: true),
          _RegCardRow(label: 'เบอร์โทร', value: maskedPhone, isMono: true),
          _RegCardRow(
            label: 'สิทธิแอพผู้เช่า',
            valueWidget: _RegStatusPill(
              on: appOn,
              onLabel: 'อนุญาต',
              offLabel: 'ไม่อนุญาต',
              onTap: onToggleApp,
            ),
          ),
          _RegCardRow(
              label: 'ชื่อไลน์',
              value: model.regDisplayname?.isNotEmpty == true
                  ? model.regDisplayname!
                  : (model.lineid?.isNotEmpty == true ? model.lineid! : '-'),
              isMono: true),
          _RegCardRow(
            label: 'สิทธิใช้งานไลน์',
            valueWidget: hasLine
                ? _LineWithRemove(
                    lineid: model.lineid!,
                    onRemove: onRemoveLine,
                  )
                : _RegisterButton(
                    onTap: () {
                      final url = (model.lineRegisUrl ?? '').trim();
                      if (url.isNotEmpty) {
                        showRegisterLineDialog(
                          context,
                          lineRegisUrl: url,
                          tax: model.tax ?? '',
                        );
                      } else {
                        onRegisterLine();
                      }
                    },
                  ),
          ),
          // ✅ สถานะ — ปิดไว้: เอาสถานะออก
          // _RegCardRow(
          //   label: 'สถานะ',
          //   valueWidget: _RegStatusPill(
          //     on: statusOn,
          //     onLabel: 'เปิดใช้งาน',
          //     offLabel: 'ปิดใช้งาน',
          //     onTap: onToggleStatus,
          //   ),
          // ),
          const SizedBox(height: LaSpace.sm),
          Align(
            alignment: Alignment.centerRight,
            child: _ViewButton(onTap: onView),
          ),
        ],
      ),
    );
  }
}

class _RegCardRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  final bool isMono;
  const _RegCardRow({
    required this.label,
    this.value,
    this.valueWidget,
    this.isMono = false,
  }) : assert(value != null || valueWidget != null,
            'Either value or valueWidget must be provided');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: LaText.bodyMuted.copyWith(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: valueWidget ??
                Text(
                  (value ?? '-').isEmpty ? '-' : value!,
                  style: LaText.tableCell.copyWith(
                    fontSize: 12,
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

class _RegStatusPill extends StatefulWidget {
  final bool on;
  final String onLabel;
  final String offLabel;
  final VoidCallback? onTap;
  const _RegStatusPill({
    required this.on,
    required this.onLabel,
    required this.offLabel,
    this.onTap,
  });

  @override
  State<_RegStatusPill> createState() => _RegStatusPillState();
}

class _RegStatusPillState extends State<_RegStatusPill> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final on = widget.on;
    final clickable = widget.onTap != null;
    return MouseRegion(
      cursor: clickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: on ? LaColors.statusApprovedBg : LaColors.statusNeutralBg,
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
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color:
                      on ? LaColors.statusApprovedFg : LaColors.statusNeutralFg,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  on ? widget.onLabel : widget.offLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: on
                        ? LaColors.statusApprovedFg
                        : LaColors.statusNeutralFg,
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
