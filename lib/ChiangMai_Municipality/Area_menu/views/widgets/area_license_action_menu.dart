// ============================================================================
// area_license_action_menu.dart
// ============================================================================
// Popup menu (context-menu vibe) — เลือกเมนูย่อยของ "ใบอนุญาต" ที่จะไปจาก area card
// แสดง 7 เมนู (ยกเว้น "ประกาศคำขอใบอนุญาต")
//
// ดีไซน์เรียบ เหมือนคลิกขวา — ไม่มี header ไม่มีสีหลักเด่น
// ลูกศร (triangle) ชี้จาก popup ไปยังการ์ดที่กด
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../router/app_router.dart';
import '../../../List_CMM/Register_CMM/AuthService.dart';

/// รายการเมนู "ใบอนุญาต" ที่ให้เลือก
class _LicenseAction {
  final String label;
  final IconData icon;
  final String route;
  final String permission;
  const _LicenseAction({
    required this.label,
    required this.icon,
    required this.route,
    required this.permission,
  });
}

const _licenseActions = <_LicenseAction>[
  _LicenseAction(
    label: 'คำขอใบอนุญาต',
    icon: Icons.edit_note_outlined,
    route: AppRoute.contract,
    permission: 'LICENSE_REQUEST',
  ),
  _LicenseAction(
    label: 'แนบเอกสารคำขอ',
    icon: Icons.attach_file_outlined,
    route: AppRoute.attach,
    permission: 'REQUEST_DOCUMENT_ATTACHMENT',
  ),
  _LicenseAction(
    label: 'ชำระค่าธรรมเนียม',
    icon: Icons.payments_outlined,
    route: AppRoute.payment,
    permission: 'FEE_PAYMENT',
  ),
  _LicenseAction(
    label: 'ตรวจสอบเอกสารคำขอ',
    icon: Icons.rule_outlined,
    route: AppRoute.verify,
    permission: 'REQUEST_DOCUMENT_REVIEW',
  ),
  _LicenseAction(
    label: 'ตรวจสอบข้อเท็จจริง',
    icon: Icons.search_outlined,
    route: AppRoute.factCheck,
    permission: 'FACT_VERIFICATION',
  ),
  _LicenseAction(
    label: 'ส่งคำร้องขออนุมัติ',
    icon: Icons.send_outlined,
    route: AppRoute.submitApproval,
    permission: 'SUBMIT_APPROVAL_REQUEST',
  ),
  _LicenseAction(
    label: 'อนุมัติคำร้อง',
    icon: Icons.check_circle_outline,
    route: AppRoute.approve,
    permission: 'APPROVE_REQUEST',
  ),
];

/// ดึงรายการเมนูที่ user มีสิทธิ์ใช้งาน (กรองตาม allowed permissions)
Future<List<_LicenseAction>> _allowedActions() async {
  final allowed = (await AuthService.getMenuPermissions()).toSet();
  if (allowed.isEmpty) return const [];
  return _licenseActions
      .where((a) => allowed.contains(a.permission))
      .toList(growable: false);
}

/// แสดง toast เตือนเมื่อ user ไม่มีสิทธิ์ใช้งานเมนูใบอนุญาตเลย
Future<void> _showNoPermissionToast(BuildContext context) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger.showSnackBar(
    const SnackBar(
      content: Text('คุณไม่มีสิทธิ์เข้าถึงเมนูใบอนุญาต'),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
    ),
  );
}

enum _ArrowSide { left, right, none }

const double _menuWidth = 240;
const double _itemHeight = 38;
const double _arrowSize = 10;

/// แสดง context menu ติดกับการ์ดที่กด พร้อมลูกศรเล็กๆ ชี้การ์ด
Future<void> showAreaLicenseActionMenu({
  required BuildContext context,
  required Rect position,
  required String routeData,
}) async {
  final allowed = await _allowedActions();
  if (!context.mounted) return;
  if (allowed.isEmpty) {
    // ไม่มีสิทธิ์ใช้งานเมนูใบอนุญาตเลย
    await _showNoPermissionToast(context);
    return;
  }

  const double menuW = _menuWidth;
  final double menuH = allowed.length * _itemHeight + 8;

  final overlayBox =
      Overlay.of(context).context.findRenderObject() as RenderBox?;
  final overlaySize = overlayBox?.size ?? MediaQuery.of(context).size;
  final double overlayWidth = overlaySize.width;
  final double overlayHeight = overlaySize.height;

  // ─── X ───
  late double popupLeft;
  _ArrowSide arrowSide;
  if (position.right + menuW + _arrowSize <= overlayWidth) {
    popupLeft = position.right + _arrowSize;
    arrowSide = _ArrowSide.left;
  } else {
    popupLeft = position.left - menuW - _arrowSize;
    arrowSide = _ArrowSide.right;
    if (popupLeft < 0) {
      popupLeft = 0;
      arrowSide = _ArrowSide.right;
    }
  }

  // ─── Y: จัดให้ตรงกลางการ์ด (เหมือน right-click) ───
  final double cardCenterY = position.top + position.height / 2;
  double popupTop = cardCenterY - menuH / 2;
  if (popupTop + menuH > overlayHeight) {
    popupTop = overlayHeight - menuH - 8;
  }
  if (popupTop < 8) popupTop = 8;

  // arrowY ตรงกลาง popup (เพราะ popup จัดกลางการ์ดแล้ว)
  final double arrowY = menuH / 2;

  final router = GoRouter.of(context);
  final overlayState = Overlay.of(context, rootOverlay: false);
  late OverlayEntry entry;
  bool isOpen = true;

  void close() {
    if (!isOpen) return;
    isOpen = false;
    entry.remove();
  }

  entry = OverlayEntry(
    builder: (ctx) => _PopupOverlay(
      popupLeft: popupLeft,
      popupTop: popupTop,
      arrowSide: arrowSide,
      arrowY: arrowY,
      items: allowed,
      onClose: close,
      onSelect: (action) {
        close();
        // ✅ Path-style: /contract/:data (encode เผื่อ key มี '/', '|', อื่นๆ)
        router.go(
          routeData.isEmpty
              ? action.route
              : '${action.route}/${Uri.encodeComponent(routeData)}',
        );
      },
    ),
  );
  overlayState.insert(entry);
}

/// ใช้ GlobalKey เพื่อ resolve RenderBox ของการ์ด
Future<void> showAreaLicenseActionMenuAt({
  required BuildContext context,
  required GlobalKey anchorKey,
  required String routeData,
}) async {
  final renderObject = anchorKey.currentContext?.findRenderObject();
  if (renderObject is! RenderBox) return;
  final globalOffset = renderObject.localToGlobal(Offset.zero);
  final size = renderObject.size;
  if (!context.mounted) return;
  await showAreaLicenseActionMenu(
    context: context,
    position: globalOffset & size,
    routeData: routeData,
  );
}

/// Fallback — popup กลางจอ (ไม่มี anchor)
Future<void> showAreaLicenseActionMenuDefault({
  required BuildContext context,
  required String routeData,
}) async {
  final allowed = await _allowedActions();
  if (!context.mounted) return;
  if (allowed.isEmpty) {
    await _showNoPermissionToast(context);
    return;
  }

  final size = MediaQuery.of(context).size;
  final double popupLeft = (size.width - _menuWidth) / 2;
  final double popupTop = size.height / 2 - 150;

  final router = GoRouter.of(context);
  final overlayState = Overlay.of(context, rootOverlay: false);
  late OverlayEntry entry;
  bool isOpen = true;

  void close() {
    if (!isOpen) return;
    isOpen = false;
    entry.remove();
  }

  entry = OverlayEntry(
    builder: (ctx) => _PopupOverlay(
      popupLeft: popupLeft,
      popupTop: popupTop,
      arrowSide: _ArrowSide.none,
      arrowY: 0,
      items: allowed,
      onClose: close,
      onSelect: (action) {
        close();
        // ✅ Path-style: /contract/:data (encode เผื่อ key มี '/', '|', อื่นๆ)
        router.go(
          routeData.isEmpty
              ? action.route
              : '${action.route}/${Uri.encodeComponent(routeData)}',
        );
      },
    ),
  );
  overlayState.insert(entry);
}

// ============================================================================
// Internal — Overlay layer (backdrop + bubble + fade-in)
// ============================================================================
class _PopupOverlay extends StatefulWidget {
  final double popupLeft;
  final double popupTop;
  final _ArrowSide arrowSide;
  final double arrowY;
  final List<_LicenseAction> items;
  final VoidCallback onClose;
  final ValueChanged<_LicenseAction> onSelect;

  const _PopupOverlay({
    required this.popupLeft,
    required this.popupTop,
    required this.arrowSide,
    required this.arrowY,
    required this.items,
    required this.onClose,
    required this.onSelect,
  });

  @override
  State<_PopupOverlay> createState() => _PopupOverlayState();
}

class _PopupOverlayState extends State<_PopupOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _fade = CurvedAnimation(parent: _ac, curve: Curves.easeOut);
    _ac.forward();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: widget.onClose,
            child: const SizedBox.expand(),
          ),
        ),
        Positioned(
          left: widget.popupLeft,
          top: widget.popupTop,
          child: FadeTransition(
            opacity: _fade,
            child: _BubblePopup(
              arrowSide: widget.arrowSide,
              arrowY: widget.arrowY,
              items: widget.items,
              onSelected: widget.onSelect,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Internal — Bubble Popup (กล่อง + ลูกศร)
// ============================================================================
class _BubblePopup extends StatelessWidget {
  final _ArrowSide arrowSide;
  final double arrowY;
  final List<_LicenseAction> items;
  final ValueChanged<_LicenseAction> onSelected;

  const _BubblePopup({
    required this.arrowSide,
    required this.arrowY,
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final arrowW = arrowSide == _ArrowSide.none ? 0.0 : _arrowSize;
    final boxWidth = _menuWidth + arrowW;

    return SizedBox(
      width: boxWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: arrowSide == _ArrowSide.left
                ? EdgeInsets.only(left: arrowW)
                : arrowSide == _ArrowSide.right
                    ? EdgeInsets.only(right: arrowW)
                    : EdgeInsets.zero,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE4E4E7), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.12),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(.04),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── รายการเมนู (เรียบ เหมือน context menu) ──
                  for (int i = 0; i < items.length; i++)
                    _MenuItem(
                      action: items[i],
                      onTap: () => onSelected(items[i]),
                    ),
                ],
              ),
            ),
          ),
          // ── ลูกศรเล็กๆ ──
          if (arrowSide == _ArrowSide.left)
            Positioned(
              left: 0,
              top: arrowY - _arrowSize,
              child: CustomPaint(
                size: Size(_arrowSize + 0.5, _arrowSize * 2),
                painter: _ArrowPainter(pointingLeft: true),
              ),
            )
          else if (arrowSide == _ArrowSide.right)
            Positioned(
              right: 0,
              top: arrowY - _arrowSize,
              child: CustomPaint(
                size: Size(_arrowSize + 0.5, _arrowSize * 2),
                painter: _ArrowPainter(pointingLeft: false),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// Internal — Menu Item (native context-menu vibe)
// ============================================================================
class _MenuItem extends StatefulWidget {
  final _LicenseAction action;
  final VoidCallback onTap;
  const _MenuItem({required this.action, required this.onTap});

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final base = Colors.grey.shade700;
    final hoverBg = const Color(0xFFF4F4F5);
    final hoverFg = const Color(0xFF111827);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          curve: Curves.linear,
          height: _itemHeight,
          color: _hover ? hoverBg : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(
                widget.action.icon,
                size: 15,
                color: _hover ? hoverFg : base,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.action.label,
                  style: TextStyle(
                    fontSize: 13,
                    color: _hover ? hoverFg : base,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Internal — Arrow Painter (ลูกศรเล็กบาง)
// ============================================================================
class _ArrowPainter extends CustomPainter {
  final bool pointingLeft;
  _ArrowPainter({required this.pointingLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();
    if (pointingLeft) {
      path.moveTo(0, h / 2);
      path.lineTo(w, 1);
      path.lineTo(w, h - 1);
      path.close();
    } else {
      path.moveTo(w, h / 2);
      path.lineTo(0, 1);
      path.lineTo(0, h - 1);
      path.close();
    }

    // shadow ใต้ลูกศร (เบาๆ ให้กลมกลืนกับ box)
    canvas.drawShadow(path, Colors.black.withOpacity(.10), 3, true);

    // fill ขาว
    canvas.drawPath(path, Paint()..color = Colors.white);

    // เส้นขอบเฉพาะด้านที่ติด box
    final stroke = Paint()
      ..color = const Color(0xFFE4E4E7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    if (pointingLeft) {
      final edge = Path()
        ..moveTo(w, 1)
        ..lineTo(w, h - 1);
      canvas.drawPath(edge, stroke);
    } else {
      final edge = Path()
        ..moveTo(0, 1)
        ..lineTo(0, h - 1);
      canvas.drawPath(edge, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter old) =>
      old.pointingLeft != pointingLeft;
}