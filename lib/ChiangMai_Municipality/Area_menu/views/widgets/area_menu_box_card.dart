// ============================================================================
// area_menu_box_card.dart
// ============================================================================
// Box Card widget — แสดงข้อมูล "คำขอต่อสัญญา" ในรูปแบบการ์ด (Grid View)
// ✅ SELF-CONTAINED — รับ Map<String, dynamic> เป็น data type
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/area_menu_theme.dart';
import '../../viewmodels/area_menu_view_model.dart';

class AreaMenuBoxCard extends StatefulWidget {
  final Map<String, dynamic> model;
  const AreaMenuBoxCard({super.key, required this.model});

  @override
  State<AreaMenuBoxCard> createState() => _AreaMenuBoxCardState();
}

class _AreaMenuBoxCardState extends State<AreaMenuBoxCard> {
  bool _hover = false;

  // ---------------------------------------------------------------
  // Theme helpers — ใช้ค่าจาก Map เป็นหลัก
  // ---------------------------------------------------------------
  Color _bg() {
    // สีพื้นหลังตาม status (ใช้สีเทาอ่อนเป็น default)
    return LaColors.surfaceMuted;
  }

  Color _border() {
    return _hover ? LaColors.primary : LaColors.border;
  }

  Color _accent() {
    return LaColors.primary;
  }

  // ---------------------------------------------------------------
  // Display text — ดึงจาก Map โดยตรง
  // ---------------------------------------------------------------
  String get _leaseText {
    final lease = widget.model['lease_number']?.toString();
    final ln = widget.model['ln']?.toString();
    if (lease != null && lease.isNotEmpty && ln != null && ln.isNotEmpty) {
      return '$lease · $ln';
    }
    if (lease != null && lease.isNotEmpty) return lease;
    if (ln != null && ln.isNotEmpty) return ln;
    return '-';
  }

  String get _statusText {
    final v = widget.model['status_label']?.toString() ??
        widget.model['status']?.toString();
    return (v == null || v.isEmpty) ? '-' : v;
  }

  String get _zoneText {
    final zn = widget.model['zn']?.toString() ?? '';
    final sub = widget.model['subzone']?.toString() ?? '';
    if (sub.isNotEmpty && zn.isNotEmpty) return '$sub · $zn';
    return zn.isNotEmpty ? zn : sub;
  }

  String get _endDateText {
    final ldate = widget.model['ldate']?.toString() ?? '';
    if (ldate.isEmpty) return '';
    return ldate; // ส่งตรงๆ ไม่ต้อง format
  }

  String get _clientText {
    final c = widget.model['cname']?.toString() ??
        widget.model['scname']?.toString() ??
        '';
    return c;
  }

  String get _phoneText {
    final tel = widget.model['tel']?.toString() ?? '';
    if (tel.isEmpty) return '';
    return tel;
  }

  // ---------------------------------------------------------------
  // Badge visibility
  // ---------------------------------------------------------------
  bool get _showMaintenanceBadge => widget.model['needs_update'] == true;
  bool get _showRequestBadge =>
      widget.model['has_request'] == true ||
      widget.model['need_review'] == true;
  bool get _showNewAttachment => widget.model['has_new_attachment'] == true;

  @override
  Widget build(BuildContext context) {
    final m = widget.model;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: LrAnimations.fast,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _bg(),
          borderRadius: BorderRadius.circular(LaRadius.md),
          border: Border.all(
            color: _border(),
            width: _hover ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_hover ? .10 : .03),
              blurRadius: _hover ? 14 : 6,
              offset: Offset(0, _hover ? 4 : 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(LaRadius.md),
            onTap: () => context.read<AreaMenuViewModel>().onViewRequest(m),
            child: Stack(
              children: [
                // ── Main content ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    LaSpace.md,
                    LaSpace.sm,
                    LaSpace.md,
                    LaSpace.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // ▸ Header: lease + LN (compact)
                      SizedBox(
                        width: double.infinity,
                        child: AutoSizeText(
                          _leaseText,
                          minFontSize: 10,
                          maxFontSize: 12,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: LaText.caption.copyWith(
                            color: LaColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                            letterSpacing: .15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // ▸ Status pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _accent().withOpacity(.16),
                          borderRadius: BorderRadius.circular(LaRadius.pill),
                          border: Border.all(
                            color: _accent().withOpacity(.35),
                            width: 1,
                          ),
                        ),
                        child: AutoSizeText(
                          _statusText,
                          minFontSize: 10,
                          maxFontSize: 13,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: LaText.fontBold,
                            fontSize: 11,
                            color: _accent(),
                            fontWeight: FontWeight.w700,
                            letterSpacing: .3,
                          ),
                        ),
                      ),
                      // ▸ Divider subtle
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _accent().withOpacity(0),
                              _accent().withOpacity(.18),
                              _accent().withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                      // ▸ End date (with icon)
                      if (_endDateText.isNotEmpty)
                        _FieldRow(
                          icon: Icons.event_outlined,
                          text: _endDateText,
                          prefix: 'สิ้นสุด ',
                          accent: LaColors.textSecondary,
                        ),
                      // ▸ Client name (with icon)
                      if (_clientText.isNotEmpty)
                        _FieldRow(
                          icon: Icons.person_outline,
                          text: _clientText,
                          accent: LaColors.textPrimary,
                          bold: true,
                        ),
                    ],
                  ),
                ),

                // ── Badges ─────────────────────────────────
                if (_showMaintenanceBadge)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: _BadgeIcon(
                      icon: Icons.build_rounded,
                      color: Colors.white,
                      bg: LaColors.statusPendingFg,
                      tooltip: 'ต้องอัปเดต',
                    ),
                  ),
                if (_showRequestBadge)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: _BadgeIcon(
                      icon: Icons.edit_note_rounded,
                      color: Colors.white,
                      bg: _accent(),
                      tooltip: 'มีคำขอ',
                    ),
                  ),
                if (_showNewAttachment)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: _BadgeIcon(
                      icon: Icons.attachment_rounded,
                      color: Colors.white,
                      bg: LaColors.primary,
                      tooltip: 'มีไฟล์แนบใหม่',
                      size: 10,
                      radius: 8,
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

// ============================================================================
// Internal — Field row (icon + text)
// ============================================================================
class _FieldRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? prefix;
  final Color? accent;
  final bool bold;
  const _FieldRow({
    required this.icon,
    required this.text,
    this.prefix,
    this.accent,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = accent ?? LaColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color.withOpacity(.85)),
          const SizedBox(width: 5),
          Flexible(
            child: AutoSizeText(
              prefix != null ? '$prefix$text' : text,
              minFontSize: 9,
              maxFontSize: 12,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: LaText.fontRegular,
                fontSize: 11,
                color: color,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: .1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Internal — small circular badge icon
// ============================================================================
class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  final String tooltip;
  final double size;
  final double radius;
  const _BadgeIcon({
    required this.icon,
    required this.color,
    required this.bg,
    required this.tooltip,
    this.size = 14,
    this.radius = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.18),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(.9), width: 1),
        ),
        child: Icon(icon, size: size, color: color),
      ),
    );
  }
}
