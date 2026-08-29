// ============================================================================
// area_license_action_menu.dart
// ============================================================================
// Modal bottom sheet — เลือกเมนูย่อยของ "ใบอนุญาต" ที่จะไปจาก area card
// แสดง 7 เมนู (ยกเว้น "ประกาศคำขอใบอนุญาต")
// แต่ละเมนู navigate ไป route ที่กำหนด พร้อม routeData = key (subzone|zone|lock)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../router/app_router.dart';

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

/// แสดง bottom sheet เลือกเมนูย่อย "ใบอนุญาต"
/// [routeData] = composite key (เช่น "subzone|zone|lock") ส่งต่อเป็น query param
Future<void> showAreaLicenseActionMenu(
  BuildContext context, {
  required String routeData,
}) {
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _AreaLicenseActionSheet(
      routeData: routeData,
      actions: _licenseActions,
    ),
  );
}

class _AreaLicenseActionSheet extends StatelessWidget {
  final String routeData;
  final List<_LicenseAction> actions;
  const _AreaLicenseActionSheet({
    required this.routeData,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.78,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Header ───
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.description_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'ไปเมนูไหนในใบอนุญาต?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'เลือกขั้นตอนที่ต้องการทำต่อสำหรับพื้นที่นี้',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // ─── Action list ───
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: actions.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 64),
                itemBuilder: (context, i) {
                  final a = actions[i];
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      final uri = Uri(
                        path: a.route,
                        queryParameters: {'routeData': routeData},
                      );
                      GoRouter.of(context).go(uri.toString());
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              a.icon,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.label,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  a.hint,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
