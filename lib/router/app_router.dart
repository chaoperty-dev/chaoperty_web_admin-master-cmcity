import 'package:chaoperty/ChiangMai_Municipality/Area_menu/views/area_menu_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ChiangMai_Municipality/License_menu/license_announce_page/views/license_announce_page.dart';
import '../ChiangMai_Municipality/License_menu/license_approve_page/views/license_approve_page.dart';
import '../ChiangMai_Municipality/License_menu/license_attach_page/views/license_attach_page.dart';
import '../ChiangMai_Municipality/License_menu/license_fact_check_page/views/license_fact_check_page.dart';
import '../ChiangMai_Municipality/License_menu/license_payment_page/views/license_payment_page.dart';
import '../ChiangMai_Municipality/License_menu/license_request_page/views/license_request_page.dart';
import '../ChiangMai_Municipality/License_menu/license_verify_page/views/license_verify_page.dart';
import '../ChiangMai_Municipality/List_CMM/Register_CMM/Login_page_cmm.dart';
import '../ChiangMai_Municipality/List_CMM/Register_CMM/SetupPage.dart';
import '../ChiangMai_Municipality/Personal_information_menu/personal_information_page/views/personal_information_page.dart';
import '../ChiangMai_Municipality/Registration_menu/registration_page/views/registration_page.dart';
import '../ChiangMai_Municipality/Setting_menu/setting_page/views/setting_page.dart';
import '../ChiangMai_Municipality/Tenant_menu/tenant_license_page/views/tenant_license_page.dart';
import '../navigation/app_shell.dart';
import 'auth_state_notifier.dart';

/// Route name constants — short URL เพื่อให้ copy แล้วเปิดได้เลย
class AppRoute {
  AppRoute._();

  // Pre-shell (Login/Setup) — ไม่มี NavigationRail
  static const String login = '/login';
  static const String setup = '/setup';

  // ใบอนุญาต (Branch 0)
  static const String contract = '/contract';
  static const String payment = '/payment';
  static const String attach = '/attach';
  static const String verify = '/verify';
  static const String factCheck = '/fact-check';
  static const String approve = '/approve';
  static const String announce = '/announce';

  // อื่นๆ
  static const String tenant = '/tenant';
  static const String area = '/area';
  static const String registration = '/registration';
  static const String profileManage = '/profile/manage';
  static const String setting = '/setting';
}

/// Fade transition สำหรับทุกหน้าใน Shell — ทำให้ navigation smooth
/// รับ [locationKey] เพิ่มเติมเพื่อบังคับ rebuild ทุกครั้งที่เปลี่ยนหน้า
CustomTransitionPage<T> _fadePage<T>({
  required LocalKey key,
  required Widget child,
  required String locationKey,
}) {
  return CustomTransitionPage<T>(
    key: ValueKey('page_${locationKey}_${key.toString()}'),
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: child,
      );
    },
  );
}

/// สร้าง GoRouter พร้อม StatefulShellRoute + FadeTransition
GoRouter buildAppRouter({
  required AuthStateNotifier authNotifier,
}) {
  return GoRouter(
    initialLocation: AppRoute.contract,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final loggedIn = authNotifier.isLoggedIn;

      // Pre-shell routes: Login / Setup
      if (loc == AppRoute.login) {
        if (loggedIn) return AppRoute.setup;
        return null;
      }
      if (loc == AppRoute.setup) {
        if (!loggedIn) return AppRoute.login;
        return null;
      }

      // ✅ ทุกหน้าใน shell: ต้อง login ก่อน แล้วค่อยให้ผ่าน SetupPage ก่อนเข้า shell
      if (!loggedIn) return AppRoute.login;

      return null;
    },
    routes: <RouteBase>[
      // ── Pre-shell routes ──
      GoRoute(
        path: AppRoute.login,
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          locationKey: state.matchedLocation,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: AppRoute.setup,
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          locationKey: state.matchedLocation,
          child: const SetupPage(),
        ),
      ),

      // ── Shell route ──
      // ใช้ ShellRoute ธรรมดาแทน StatefulShellRoute.indexedStack
      // เพื่อให้ AppShell ควบคุมเองว่าจะ cache/dispose branch ไหน
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          // ใบอนุญาต (7 sub-routes)
          GoRoute(
            path: AppRoute.contract,
            pageBuilder: (context, state) => _fadePage(
              key: state.pageKey,
              locationKey: state.matchedLocation,
              child: LicenseRequestPage.create(),
            ),
          ),
          GoRoute(
            path: AppRoute.payment,
            pageBuilder: (context, state) => _fadePage(
              key: state.pageKey,
              locationKey: state.matchedLocation,
              child: LicensePaymentPage.create(),
            ),
          ),
          GoRoute(
            path: AppRoute.attach,
            pageBuilder: (context, state) => _fadePage(
              key: state.pageKey,
              locationKey: state.matchedLocation,
              child: LicenseAttachPage.create(),
            ),
          ),
          GoRoute(
            path: AppRoute.verify,
            pageBuilder: (context, state) => _fadePage(
              key: state.pageKey,
              locationKey: state.matchedLocation,
              child: LicenseVerifyPage.create(),
            ),
          ),
          GoRoute(
            path: AppRoute.factCheck,
            pageBuilder: (context, state) => _fadePage(
              key: state.pageKey,
              locationKey: state.matchedLocation,
              child: LicensefactcheckPage.create(),
            ),
          ),
          GoRoute(
            path: AppRoute.approve,
            pageBuilder: (context, state) => _fadePage(
              key: state.pageKey,
              locationKey: state.matchedLocation,
              child: LicenseApprovePage.create(),
            ),
          ),
          GoRoute(
            path: AppRoute.announce,
            pageBuilder: (context, state) => _fadePage(
              key: state.pageKey,
              locationKey: state.matchedLocation,
              child: LicenseAnnouncePage.create(),
            ),
          ),

          // พื้นที่เช่า (อยู่ก่อน ผู้เช่า)
          GoRoute(
            path: AppRoute.area,
            pageBuilder: (context, state) => _fadePage(
              key: state.pageKey,
              locationKey: state.matchedLocation,
              child: AreaMenuPage.create(),
              // ChaoAreaScreen(),
            ),
          ),

          // ผู้เช่า
          GoRoute(
            path: AppRoute.tenant,
            pageBuilder: (context, state) => _fadePage(
              key: state.pageKey,
              locationKey: state.matchedLocation,
              child: TenantLicensePage.create(),
            ),
          ),

          // ทะเบียน
          GoRoute(
            path: AppRoute.registration,
            pageBuilder: (context, state) => _fadePage(
              key: state.pageKey,
              locationKey: state.matchedLocation,
              child: RegistrationPage.create(),
            ),
          ),

          // ตั้งค่า (อยู่ก่อน จัดการข้อมูลส่วนตัว)
          GoRoute(
            path: AppRoute.setting,
            pageBuilder: (context, state) => _fadePage(
              key: state.pageKey,
              locationKey: state.matchedLocation,
              child: const SettingPage(),
            ),
          ),

          // จัดการข้อมูลส่วนตัว
          GoRoute(
            path: AppRoute.profileManage,
            pageBuilder: (context, state) => _fadePage(
              key: state.pageKey,
              locationKey: state.matchedLocation,
              child: ManagePersonalInformationPage.create(),
            ),
          ),
        ],
      ),
    ],
  );
}