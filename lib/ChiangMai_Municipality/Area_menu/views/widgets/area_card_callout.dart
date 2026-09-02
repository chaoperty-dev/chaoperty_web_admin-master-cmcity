// ============================================================================
// area_card_callout.dart
// ============================================================================
// Callout bubble — แสดง "เมนูใบอนุญาต" เหนือ block "พื้นที่เช่า" เมื่อกด
// - แสดงรายการเมนู (filter ตามสิทธิ์ user เหมือน left-side menu)
// - ลูกศรด้านล่างชี้ block (flip ด้านบนถ้าที่บนไม่พอ)
// - กด item → navigate (path-style พร้อม routeData)
// - กด backdrop → ปิด
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../router/app_router.dart';
import '../../../List_CMM/Register_CMM/AuthService.dart';

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

/// ดึงรายการเมนูที่ user มีสิทธิ์ใช้งาน
Future<List<_LicenseAction>> _allowedActions() async {
  final allowed = (await AuthService.getMenuPermissions()).toSet();
  if (allowed.isEmpty) return const [];
  return _licenseActions
      .where((a) => allowed.contains(a.permission))
      .toList(growable: false);
}

Future<void> showAreaCardCalloutAt({
  required BuildContext context,
  required GlobalKey anchorKey,
  required Map<String, dynamic> model,
}) async {
  final renderObject = anchorKey.currentContext?.findRenderObject();
  if (renderObject is! RenderBox) return;
  final rect = renderObject.localToGlobal(Offset.zero) & renderObject.size;
  if (!context.mounted) return;
  await showAreaCardCallout(
    context: context,
    anchorRect: rect,
    model: model,
  );
}

Future<void> showAreaCardCallout({
  required BuildContext context,
  required Rect anchorRect,
  required Map<String, dynamic> model,
}) async {
  final items = await _allowedActions();
  if (!context.mounted) return;
  if (items.isEmpty) {
    // ไม่มีสิทธิ์ใช้งานเมนูเลย
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      const SnackBar(
        content: Text('คุณไม่มีสิทธิ์เข้าถึงเมนูใบอนุญาต'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

  const double bubbleW = 240;
  const double itemH = 38;
  const double gap = 8;
  final double bubbleH = items.length * itemH + 8;

  final overlayBox =
      Overlay.of(context).context.findRenderObject() as RenderBox?;
  final overlayHeight =
      overlayBox?.size.height ?? MediaQuery.of(context).size.height;
  final overlayWidth =
      overlayBox?.size.width ?? MediaQuery.of(context).size.width;

  // X: จัดกลาง block (clamp)
  double left = anchorRect.left + (anchorRect.width - bubbleW) / 2;
  if (left + bubbleW > overlayWidth - 8) left = overlayWidth - bubbleW - 8;
  if (left < 8) left = 8;

  // Y: bubble เหนือ block → ถ้าไม่พอย้ายใต้ block
  double top = anchorRect.top - bubbleH - gap - 6;
  final bool flipDown = top < 8;
  if (flipDown) top = anchorRect.bottom + gap + 6;
  if (top + bubbleH > overlayHeight - 8) top = overlayHeight - bubbleH - 8;

  // arrow X = กลาง block
  double arrowX = (anchorRect.left + anchorRect.width / 2) - left;
  if (arrowX < 16) arrowX = 16;
  if (arrowX > bubbleW - 16) arrowX = bubbleW - 16;

  final router = GoRouter.of(context);
  final routeData = model['key']?.toString() ??
      '${model['subzone'] ?? ''}|${model['zone'] ?? ''}|${model['lock'] ?? ''}';

  final overlayState = Overlay.of(context, rootOverlay: false);
  late OverlayEntry entry;
  bool isOpen = true;

  void close() {
    if (!isOpen) return;
    isOpen = false;
    entry.remove();
  }

  entry = OverlayEntry(
    builder: (ctx) => _CalloutOverlay(
      left: left,
      top: top,
      bubbleW: bubbleW,
      arrowX: arrowX,
      flipDown: flipDown,
      items: items,
      onClose: close,
      onSelect: (action) {
        close();
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

class _CalloutOverlay extends StatefulWidget {
  final double left;
  final double top;
  final double bubbleW;
  final double arrowX;
  final bool flipDown;
  final List<_LicenseAction> items;
  final VoidCallback onClose;
  final ValueChanged<_LicenseAction> onSelect;

  const _CalloutOverlay({
    required this.left,
    required this.top,
    required this.bubbleW,
    required this.arrowX,
    required this.flipDown,
    required this.items,
    required this.onClose,
    required this.onSelect,
  });

  @override
  State<_CalloutOverlay> createState() => _CalloutOverlayState();
}

class _CalloutOverlayState extends State<_CalloutOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
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
          left: widget.left,
          top: widget.top,
          child: FadeTransition(
            opacity: _fade,
            child: _CalloutBubble(
              width: widget.bubbleW,
              arrowX: widget.arrowX,
              flipDown: widget.flipDown,
              items: widget.items,
              onSelect: widget.onSelect,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Bubble — กล่องเมนู 7 ตัว + ลูกศรชี้ block
// ============================================================================
class _CalloutBubble extends StatelessWidget {
  final double width;
  final double arrowX;
  final bool flipDown;
  final List<_LicenseAction> items;
  final ValueChanged<_LicenseAction> onSelect;

  const _CalloutBubble({
    required this.width,
    required this.arrowX,
    required this.flipDown,
    required this.items,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    const double arrowSize = 10;
    return SizedBox(
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE4E4E7), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .12),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: .04),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < items.length; i++)
                  _CalloutItem(
                    action: items[i],
                    onTap: () => onSelect(items[i]),
                  ),
              ],
            ),
          ),
          Positioned(
            left: arrowX - arrowSize,
            top: flipDown ? -arrowSize : null,
            bottom: flipDown ? null : -arrowSize,
            child: CustomPaint(
              size: const Size(arrowSize * 2, arrowSize),
              painter: _CalloutArrowPainter(pointingDown: !flipDown),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalloutItem extends StatefulWidget {
  final _LicenseAction action;
  final VoidCallback onTap;
  const _CalloutItem({required this.action, required this.onTap});

  @override
  State<_CalloutItem> createState() => _CalloutItemState();
}

class _CalloutItemState extends State<_CalloutItem> {
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
          height: 38,
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

class _CalloutArrowPainter extends CustomPainter {
  final bool pointingDown;
  const _CalloutArrowPainter({required this.pointingDown});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();
    if (pointingDown) {
      path.moveTo(0, 0);
      path.lineTo(w, 0);
      path.lineTo(w / 2, h);
    } else {
      path.moveTo(0, h);
      path.lineTo(w, h);
      path.lineTo(w / 2, 0);
    }
    path.close();
    canvas.drawShadow(path, Colors.black.withValues(alpha: .10), 3, true);
    canvas.drawPath(path, Paint()..color = Colors.white);
    final stroke = Paint()
      ..color = const Color(0xFFE4E4E7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    if (pointingDown) {
      final edge = Path()
        ..moveTo(0, 0)
        ..lineTo(w / 2, h);
      canvas.drawPath(edge, stroke);
      final edge2 = Path()
        ..moveTo(w, 0)
        ..lineTo(w / 2, h);
      canvas.drawPath(edge2, stroke);
    } else {
      final edge = Path()
        ..moveTo(0, h)
        ..lineTo(w / 2, 0);
      canvas.drawPath(edge, stroke);
      final edge2 = Path()
        ..moveTo(w, h)
        ..lineTo(w / 2, 0);
      canvas.drawPath(edge2, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _CalloutArrowPainter old) =>
      old.pointingDown != pointingDown;
}