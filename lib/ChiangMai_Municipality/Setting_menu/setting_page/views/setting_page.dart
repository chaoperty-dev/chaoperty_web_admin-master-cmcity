// ============================================================================
// setting_page.dart
// ============================================================================
// Setting Page (Hub) — หน้าหลัก 6 เมนูย่อย
// ใช้ style เดียวกับ License menu (header dark slate, emerald accent)
// ใช้ Navigator.push ไปยัง sub-page แต่ละเมนู
// ============================================================================

import 'package:flutter/material.dart';

import 'package:chaoperty/ChiangMai_Municipality/Setting_menu/setting_page/access_rights/views/access_rights_page.dart';
import 'package:chaoperty/ChiangMai_Municipality/Setting_menu/setting_page/area/views/area_page.dart';
import 'package:chaoperty/ChiangMai_Municipality/Setting_menu/setting_page/general_data/views/general_data_page.dart';
import 'package:chaoperty/ChiangMai_Municipality/Setting_menu/setting_page/payment/views/payment_page.dart';

import 'theme/setting_page_theme.dart';
import 'widgets/setting_menu_card.dart';
import 'widgets/setting_page_header.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// Setting Page (Hub) — หน้าหลัก 6 เมนูย่อย
/// ═══════════════════════════════════════════════════════════════════════
class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  /// เปิด general_data sub-page (ข้อมูลทั่วไป)
  ///
  /// ใช้ `GeneralDataPage.create()` เพื่อ wrap ChangeNotifierProvider
  /// (เหมือน LicensefactcheckPage.create()) — ห้าม new GeneralDataPage() ตรงๆ
  static void openGeneralData(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GeneralDataPage.create(),
      ),
    );
  }

  /// เปิดหน้า "ตั้งค่าพื้นที่" (Area)
  static void openArea(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AreaPage.create(),
      ),
    );
  }

  /// เปิดหน้า "การรับชำระ" (Payment)
  static void openPayment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage.create(),
      ),
    );
  }

  /// เปิดหน้า "สิทธิการเข้าถึง" (Access Rights)
  static void openAccessRights(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AccessRightsPage.create(),
      ),
    );
  }

  /// เปิด sub-page (ใช้ placeholder สำหรับเมนูที่ยังไม่ได้ทำ)
  static void openPlaceholder(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PlaceholderPage(title: title, subtitle: subtitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = SetResponsive.isMobile(context);
    final crossAxisCount = isMobile ? 2 : 3;

    // รายการเมนู 6 อัน (ใช้ SetColors.menu* สำหรับสีของแต่ละเมนู)
    final menus = <_MenuItem>[
      _MenuItem(
        title: 'ข้อมูลการเช่า',
        subtitle: 'ตั้งค่าข้อมูลพื้นฐานของระบบ',
        icon: Icons.info_outline_rounded,
        color: SetColors.menuRental,
        route: _MenuRoute.rentalSettings,
      ),
      _MenuItem(
        title: 'ตั้งค่าพื้นที่',
        subtitle: 'จัดการโซน / พื้นที่เช่า',
        icon: Icons.location_on_outlined,
        color: SetColors.menuArea,
        route: _MenuRoute.area,
      ),
      _MenuItem(
        title: 'การเช่า',
        subtitle: 'ตั้งค่าการเช่าและค่าใช้จ่าย',
        icon: Icons.handshake_outlined,
        color: SetColors.menuRentalSettings,
        route: _MenuRoute.rental,
      ),
      _MenuItem(
        title: 'เอกสาร',
        subtitle: 'จัดการเอกสาร / แบบฟอร์ม',
        icon: Icons.description_outlined,
        color: SetColors.menuDocument,
        route: _MenuRoute.document,
      ),
      _MenuItem(
        title: 'การรับชำระ',
        subtitle: 'ตั้งค่าช่องทางการรับเงิน',
        icon: Icons.payments_outlined,
        color: SetColors.menuPayment,
        route: _MenuRoute.payment,
      ),
      _MenuItem(
        title: 'สิทธิการเข้าถึง',
        subtitle: 'จัดการสิทธิ์ผู้ใช้งาน',
        icon: Icons.lock_outline_rounded,
        color: SetColors.menuAccessRights,
        route: _MenuRoute.accessRights,
      ),
    ];

    return Container(
      color: SetColors.surface,
      child: Padding(
        padding: SetResponsive.pagePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SettingPageHeader(
              title: 'ตั้งค่า',
              subtitle: 'จัดการการตั้งค่าระบบทั้งหมดของคุณ',
            ),
            const SizedBox(height: SetSpace.lg),
            Expanded(
              child: GridView.builder(
                itemCount: menus.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: SetSpace.lg,
                  crossAxisSpacing: SetSpace.lg,
                  childAspectRatio: isMobile ? 1.05 : 1.25,
                ),
                itemBuilder: (context, i) {
                  final menu = menus[i];
                  return SettingMenuCard(
                    title: menu.title,
                    subtitle: menu.subtitle,
                    icon: menu.icon,
                    color: menu.color,
                    onTap: () => _onMenuTap(context, menu),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onMenuTap(BuildContext context, _MenuItem menu) {
    switch (menu.route) {
      case _MenuRoute.rentalSettings:
        openGeneralData(context);
        break;
      case _MenuRoute.area:
        openArea(context);
        break;
      case _MenuRoute.rental:
      case _MenuRoute.document:
        openPlaceholder(context, menu.title, 'อยู่ระหว่างพัฒนา');
        break;
      case _MenuRoute.payment:
        openPayment(context);
        break;
      case _MenuRoute.accessRights:
        openAccessRights(context);
        break;
    }
  }
}

// ───────── Internal types ─────────

enum _MenuRoute {
  rentalSettings,
  area,
  rental,
  document,
  payment,
  accessRights,
}

class _MenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final _MenuRoute route;
  _MenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}

/// Placeholder page สำหรับเมนูที่ยังไม่ได้ทำ
class _PlaceholderPage extends StatelessWidget {
  final String title;
  final String subtitle;
  const _PlaceholderPage({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SetColors.surface,
      appBar: AppBar(
        backgroundColor: SetColors.surface,
        foregroundColor: SetColors.textPrimary,
        elevation: 0,
        title: Text(
          title,
          style: SetText.h2.copyWith(fontFamily: SetText.fontBold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 56,
              color: SetColors.textMuted,
            ),
            const SizedBox(height: SetSpace.md),
            Text(subtitle, style: SetText.body),
          ],
        ),
      ),
    );
  }
}
