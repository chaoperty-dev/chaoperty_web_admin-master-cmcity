// ============================================================================
// area_license_action_menu.dart
// ============================================================================
// Popup menu (speech-bubble style) — เลือกเมนูย่อยของ "ใบอนุญาต" ที่จะไปจาก area card
// แสดง 7 เมนู (ยกเว้น "ประกาศคำขอใบอนุญาต")
//
// ✅ Bubble shape: มีลูกศร (triangle) ชี้จาก popup ไปยังการ์ดที่กด
//    - ถ้า popup อยู่ขวาการ์ด → ลูกศรชี้ซ้าย (อยู่ขอบซ้ายของ popup)
//    - ถ้า popup อยู่ซ้ายการ์ด → ลูกศรชี้ขวา (อยู่ขอบขวาของ popup)
//
// ใช้ OverlayEntry วางเอง (ไม่ใช่ showMenu) เพื่อ control shape + arrow
// แต่ละเมนู navigate ไป route ที่กำหนด พร้อม routeData = key (subzone|zone|lock)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../router/app_router.dart';
import '../theme/area_menu_theme.dart';

/// รายการเมนู "ใบอนุญาต" ที่ให้เลือก (ยกเว้น "ประกาศคำขอใบอนุญาต")
class _LicenseAction {
  final String label;
  final String hint;
  final IconData icon;
  final String route;
  const _LicenseAction({
    required this.label,
    required this.hint,
    required this.icon,
    required this.route,
  });
}

const _licenseActions = <_LicenseAction>[
  _LicenseAction(
    label: 'คำขอใบอนุญาต',
    hint: 'สร้าง/แก้ไขคำขอ',
    icon: Icons.edit_note_outlined,
    route: AppRoute.contract,
  ),
  _LicenseAction(
    label: 'แนบเอกสารคำขอ',
    hint: 'อัปโหลดเอกสารประกอบ',
    icon: Icons.attach_file_outlined,
    route: AppRoute.attach,
  ),
  _LicenseAction(
    label: 'ชำระค่าธรรมเนียม',
    hint: 'ตรวจสอบ/แจ้งชำระ',
    icon: Icons.payments_outlined,
    route: AppRoute.payment,
  ),
  _LicenseAction(
    label: 'ตรวจสอบเอกสารคำขอ',
    hint: 'ตรวจความครบถ้วนเอกสาร',
    icon: Icons.rule_outlined,
    route: AppRoute.verify,
  ),
  _LicenseAction(
    label: 'ตรวจสอบข้อเท็จจริง',
    hint: 'ตรวจสอบข้อมูลตามจริง',
    icon: Icons.search_outlined,
    route: AppRoute.factCheck,
  ),
  _LicenseAction(
    label: 'ส่งคำร้องขออนุมัติ',
    hint: 'ส่งเข้าขั้นตอนอนุมัติ',
    icon: Icons.send_outlined,
    route: AppRoute.submitApproval,
  ),
  _LicenseAction(
    label: 'อนุมัติคำร้อง',
    hint: 'พิจารณาอนุมัติขั้นสุดท้าย',
    icon: Icons.check_circle_outline,
    route: AppRoute.approve,
  ),
];

/// ฝั่งที่ลูกศรชี้ออกจาก popup (ไปทางการ์ด)
enum _ArrowSide { left, right, none }

const double _menuWidth = 300;
const double _itemHeight = 56;
const double _arrowSize = 12; // ความยาวลูกศร (ด้านที่ยื่นออก)

/// แสดง bubble popup ติดกับการ์ดที่กด พร้อมลูกศรชี้การ์ด
/// [position] = global rect ของการ์ด (จาก RenderBox)
/// [routeData] = composite key (เช่น "subzone|zone|lock") ส่งต่อเป็น query param
Future<void> showAreaLicenseActionMenu({
  required BuildContext context,
  required Rect position,
  required String routeData,
}) async {
  const double menuW = _menuWidth;
  final double menuH = _licenseActions.length * _itemHeight + 16; // padding

  final overlayBox =
      Overlay.of(context).context.findRenderObject() as RenderBox?;
  final overlaySize = overlayBox?.size ?? MediaQuery.of(context).size;
  final double overlayWidth = overlaySize.width;
  final double overlayHeight = overlaySize.height;

  // ─── X: วาง popup ขวาการ์ดก่อน / ถ้าล้น → ซ้ายการ์ด ───
  late double popupLeft;
  _ArrowSide arrowSide;
  if (position.right + menuW + _arrowSize <= overlayWidth) {
    // popup อยู่ขวาการ์ด → ลูกศรชี้ซ้าย (จาก popup ไปการ์ด)
    popupLeft = position.right + _arrowSize;
    arrowSide = _ArrowSide.left;
  } else {
    // popup อยู่ซ้ายการ์ด → ลูกศรชี้ขวา
    popupLeft = position.left - menuW - _arrowSize;
    arrowSide = _ArrowSide.right;
    if (popupLeft < 0) {
      // การ์ดอยู่ซ้ายสุด → clamp ชิดขอบซ้ายจอ + ลูกศรอยู่ขวา
      popupLeft = 0;
      arrowSide = _ArrowSide.right;
    }
  }

  // ─── Y: เริ่มที่ขอบบนการ์ด / ถ้าล้น → ดันขึ้น ───
  late double popupTop;
  if (position.top + menuH <= overlayHeight) {
    popupTop = position.top;
  } else {
    popupTop = overlayHeight - menuH;
    if (popupTop < 0) popupTop = 0;
  }

  // ตำแหน่ง Y ของลูกศร (ชิดการ์ด: ใช้ top ของการ์ด + offset เล็กน้อย)
  final double arrowY = (position.top - popupTop)
      .clamp(16.0, menuH - 16)
      .toDouble();

  // cache GoRouter ก่อน async
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
    builder: (ctx) {
      return Stack(
        children: [
          // backdrop: กดพื้นที่ว่างเพื่อปิด
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: close,
              child: const SizedBox.expand(),
            ),
          ),
          // bubble
          Positioned(
            left: popupLeft,
            top: popupTop,
            child: _BubblePopup(
              arrowSide: arrowSide,
              arrowY: arrowY,
              items: _licenseActions,
              onSelected: (action) {
                close();
                final uri = Uri(
                  path: action.route,
                  queryParameters: {'routeData': routeData},
                );
                router.go(uri.toString());
              },
            ),
          ),
        ],
      );
    },
  );
  overlayState.insert(entry);
}

/// ใช้ GlobalKey เพื่อ resolve RenderBox ของการ์ด → Rect → เรียก showAreaLicenseActionMenu
Future<void> showAreaLicenseActionMenuAt({
  required BuildContext context,
  required GlobalKey anchorKey,
  required String routeData,
}) async {
  final renderObject = anchorKey.currentContext?.findRenderObject();
  if (renderObject is! RenderBox) {
    return;
  }
  final globalOffset = renderObject.localToGlobal(Offset.zero);
  final size = renderObject.size;
  if (!context.mounted) return;
  await showAreaLicenseActionMenu(
    context: context,
    position: globalOffset & size,
    routeData: routeData,
  );
}

/// Fallback (ไม่มี anchor) — popup กลางจอ ใช้สำหรับ table row หรือ event flow ทั่วไป
Future<void> showAreaLicenseActionMenuDefault({
  required BuildContext context,
  required String routeData,
}) async {
  final size = MediaQuery.of(context).size;
  final double popupLeft = (size.width - _menuWidth) / 2;
  const double popupTop = 80;

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
    builder: (ctx) {
      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: close,
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            left: popupLeft,
            top: popupTop,
            child: _BubblePopup(
              arrowSide: _ArrowSide.none,
              arrowY: 0,
              items: _licenseActions,
              onSelected: (action) {
                close();
                final uri = Uri(
                  path: action.route,
                  queryParameters: {'routeData': routeData},
                );
                router.go(uri.toString());
              },
            ),
          ),
        ],
      );
    },
  );
  overlayState.insert(entry);
}

// ============================================================================
// Internal — Bubble Popup (box + arrow pointing to anchor)
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

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Main box ──
        Container(
          width: _menuWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(LaRadius.md),
            border: Border.all(color: Colors.grey.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.10),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey.shade100,
                    indent: 12,
                    endIndent: 12,
                  ),
                InkWell(
                  onTap: () => onSelected(items[i]),
                  borderRadius: i == 0
                      ? const BorderRadius.vertical(top: Radius.circular(LaRadius.md - 1))
                      : i == items.length - 1
                          ? const BorderRadius.vertical(bottom: Radius.circular(LaRadius.md - 1))
                          : BorderRadius.zero,
                  child: SizedBox(
                    height: _itemHeight,
                    child: _LicenseActionTile(action: items[i]),
                  ),
                ),
              ],
            ],
          ),
        ),

        // ── Arrow (ลูกศร) ──
        if (arrowSide == _ArrowSide.left)
          Positioned(
            left: -arrowW,
            top: arrowY - arrowW,
            child: CustomPaint(
              size: const Size(_arrowSize, _arrowSize * 2),
              painter: _ArrowPainter(
                pointingLeft: true,
                color: Colors.white,
                borderColor: Colors.grey.shade200,
              ),
            ),
          )
        else if (arrowSide == _ArrowSide.right)
          Positioned(
            right: -arrowW,
            top: arrowY - arrowW,
            child: CustomPaint(
              size: const Size(_arrowSize, _arrowSize * 2),
              painter: _ArrowPainter(
                pointingLeft: false,
                color: Colors.white,
                borderColor: Colors.grey.shade200,
              ),
            ),
          ),
      ],
    );
  }
}

// ============================================================================
// Internal — Arrow (ลูกศรชี้ออกจาก popup ไปทางการ์ด)
// ============================================================================
class _ArrowPainter extends CustomPainter {
  final bool pointingLeft;
  final Color color;
  final Color borderColor;
  _ArrowPainter({
    required this.pointingLeft,
    required this.color,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();
    if (pointingLeft) {
      // ลูกศรชี้ซ้าย: ยอดแหลมอยู่ซ้าย
      path.moveTo(0, h / 2);
      path.lineTo(w, 0);
      path.lineTo(w, h);
      path.close();
    } else {
      // ลูกศรชี้ขวา: ยอดแหลมอยู่ขวา
      path.moveTo(w, h / 2);
      path.lineTo(0, 0);
      path.lineTo(0, h);
      path.close();
    }

    // fill ก่อน → ขอบทับ
    canvas.drawPath(path, Paint()..color = color);
    // วาดเส้นขอบเฉพาะด้านที่ติด box (ขวาเมื่อ left, ซ้ายเมื่อ right)
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    if (pointingLeft) {
      final edge = Path()
        ..moveTo(w, 0)
        ..lineTo(w, h);
      canvas.drawPath(edge, borderPaint);
    } else {
      final edge = Path()
        ..moveTo(0, 0)
        ..lineTo(0, h);
      canvas.drawPath(edge, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter old) =>
      old.pointingLeft != pointingLeft ||
      old.color != color ||
      old.borderColor != borderColor;
}

// ============================================================================
// Internal — Tile (icon + label + hint) ต่อ 1 item
// ============================================================================
class _LicenseActionTile extends StatelessWidget {
  final _LicenseAction action;
  const _LicenseActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              action.icon,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  action.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  action.hint,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}