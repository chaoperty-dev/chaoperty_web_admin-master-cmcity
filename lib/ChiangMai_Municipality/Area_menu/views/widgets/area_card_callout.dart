// ============================================================================
// area_card_callout.dart
// ============================================================================
// Callout bubble — แสดงเหนือ block "พื้นที่เช่า" เมื่อกด
// - มี label (ชื่อ zone/subzone + lock) + ปุ่มลูกศรขวา `>`
// - ลูกศรด้านล่างชี้ block (flip ด้านบนถ้าที่บนไม่พอ)
// - กด bubble / ปุ่ม > → เปิด action menu 7 ตัว (เดิม)
// - กด backdrop → ปิด
// ============================================================================

import 'package:flutter/material.dart';

import 'area_license_action_menu.dart';

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
    anchorKey: anchorKey,
    model: model,
  );
}

Future<void> showAreaCardCallout({
  required BuildContext context,
  required Rect anchorRect,
  required GlobalKey anchorKey,
  required Map<String, dynamic> model,
}) async {
  const double bubbleW = 280;
  const double bubbleH = 72;
  const double gap = 8;

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

  final overlayState = Overlay.of(context, rootOverlay: false);
  late OverlayEntry entry;
  bool isOpen = true;

  void close() {
    if (!isOpen) return;
    isOpen = false;
    entry.remove();
  }

  final routeKey = model['key']?.toString() ??
      '${model['subzone'] ?? ''}|${model['zone'] ?? ''}|${model['lock'] ?? ''}';

  entry = OverlayEntry(
    builder: (ctx) => _CalloutOverlay(
      left: left,
      top: top,
      bubbleW: bubbleW,
      arrowX: arrowX,
      flipDown: flipDown,
      model: model,
      onClose: close,
      onOpenMenu: () {
        close();
        if (ctx.mounted) {
          showAreaLicenseActionMenuAt(
            context: ctx,
            anchorKey: anchorKey,
            routeData: routeKey,
          );
        }
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
  final Map<String, dynamic> model;
  final VoidCallback onClose;
  final VoidCallback onOpenMenu;

  const _CalloutOverlay({
    required this.left,
    required this.top,
    required this.bubbleW,
    required this.arrowX,
    required this.flipDown,
    required this.model,
    required this.onClose,
    required this.onOpenMenu,
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
              model: widget.model,
              onTap: widget.onOpenMenu,
            ),
          ),
        ),
      ],
    );
  }
}

class _CalloutBubble extends StatelessWidget {
  final double width;
  final double arrowX;
  final bool flipDown;
  final Map<String, dynamic> model;
  final VoidCallback onTap;

  const _CalloutBubble({
    required this.width,
    required this.arrowX,
    required this.flipDown,
    required this.model,
    required this.onTap,
  });

  String _titleText() {
    final lease = (model['lock'] ?? '').toString();
    final zone = (model['zone'] ?? '').toString();
    if (lease.isEmpty && zone.isEmpty) return 'พื้นที่เช่า';
    if (lease.isEmpty) return zone;
    return lease;
  }

  String _subtitleText() {
    final sub = (model['subzone'] ?? '').toString();
    final zone = (model['zone'] ?? '').toString();
    if (sub.isNotEmpty && zone.isNotEmpty) return '$sub · $zone';
    if (zone.isNotEmpty) return zone;
    if (sub.isNotEmpty) return sub;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    const double arrowSize = 10;
    final title = _titleText();
    final subtitle = _subtitleText();
    return SizedBox(
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: const Color(0xFFFFFFFF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Color(0xFFE4E4E7), width: 1),
            ),
            elevation: 6,
            shadowColor: Colors.black.withValues(alpha: .15),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'เช่าอู่: $title',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              '($subtitle...)',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF4F4F5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
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