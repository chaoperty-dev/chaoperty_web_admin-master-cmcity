// ============================================================================
// area_license_action_menu.dart
// ============================================================================
// Popup menu (popover) — เลือกเมนูย่อยของ "ใบอนุญาต" ที่จะไปจาก area card
// แสดง 7 เมนู (ยกเว้น "ประกาศคำขอใบอนุญาต")
// ใช้ showMenu ของ Flutter ผูกตำแหน่งกับการ์ดที่กด (RelativeRect)
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

/// แสดง popup menu ติดกับการ์ดที่กด
/// [position] = global rect ของการ์ด (จาก RenderBox)
/// [routeData] = composite key (เช่น "subzone|zone|lock") ส่งต่อเป็น query param
Future<void> showAreaLicenseActionMenu({
  required BuildContext context,
  required Rect position,
  required String routeData,
}) {
  final overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox?;
  final overlaySize = overlay?.size ?? MediaQuery.of(context).size;
  // ตำแหน่ง popup: ชิดขวาของการ์ด, ขยายลงล่าง — fallback ถ้าชนขอบจอ
  final double left = position.right;
  final double top = position.top;
  final double maxRight = overlaySize.width - 320; // ความกว้างประมาณ popup
  final double adjustedLeft = left > maxRight ? position.left : left;
  final double adjustedTop =
      top + 280 > overlaySize.height ? overlaySize.height - 300 : top;

  final rect = RelativeRect.fromLTRB(
    adjustedLeft,
    adjustedTop,
    overlaySize.width - position.right,
    overlaySize.height - position.bottom,
  );

  // cache GoRouter ก่อน async เพื่อหลีกเลี่ยง use_build_context_synchronously
  final router = GoRouter.of(context);

  return showMenu<_LicenseAction>(
    context: context,
    position: rect,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(LaRadius.md),
      side: BorderSide(color: Colors.grey.shade200),
    ),
    elevation: 12,
    color: Colors.white,
    items: _licenseActions
        .map(
          (a) => PopupMenuItem<_LicenseAction>(
            value: a,
            height: 56,
            padding: EdgeInsets.zero,
            child: _LicenseActionTile(action: a),
          ),
        )
        .toList(),
  ).then((selected) {
    if (selected == null) return;
    final uri = Uri(
      path: selected.route,
      queryParameters: {'routeData': routeData},
    );
    router.go(uri.toString());
  });
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
  // ใช้ context ก่อน await — ไม่ข้าม async gap
  if (!context.mounted) return;
  await showAreaLicenseActionMenu(
    context: context,
    position: globalOffset & size,
    routeData: routeData,
  );
}

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
