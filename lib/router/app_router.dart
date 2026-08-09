import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ChiangMai_Municipality/License_menu/license_announce_page.dart';
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
  static const String registration = '/registration';
  static const String profileManage = '/profile/manage';
}

/// Fade transition สำหรับทุกหน้าใน Shell — ทำให้ navigation smooth
CustomTransitionPage<T> _fadePage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
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
      if (loc == AppRoute.login || loc == AppRoute.setup) {
        if (loggedIn) return AppRoute.contract;
        return null;
      }

      if (!loggedIn) return AppRoute.login;

      return null;
    },
    routes: <RouteBase>[
      // ── Pre-shell routes ──
      GoRoute(
        path: AppRoute.login,
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: AppRoute.setup,
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const SetupPage(),
        ),
      ),

      // ── Shell route ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          // Branch 0: ใบอนุญาต (7 sub-routes + fade transition)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.contract,
                pageBuilder: (context, state) => _fadePage(
                  key: state.pageKey,
                  child: LicenseRequestPage.create(),
                ),
              ),
              GoRoute(
                path: AppRoute.payment,
                pageBuilder: (context, state) => _fadePage(
                  key: state.pageKey,
                  child: LicensePaymentPage.create(),
                ),
              ),
              GoRoute(
                path: AppRoute.attach,
                pageBuilder: (context, state) => _fadePage(
                  key: state.pageKey,
                  child: LicenseAttachPage.create(),
                ),
              ),
              GoRoute(
                path: AppRoute.verify,
                pageBuilder: (context, state) => _fadePage(
                  key: state.pageKey,
                  child: LicenseverifyPage.create(),
                ),
              ),
              GoRoute(
                path: AppRoute.factCheck,
                pageBuilder: (context, state) => _fadePage(
                  key: state.pageKey,
                  child: LicensefactcheckPage.create(),
                ),
              ),
              GoRoute(
                path: AppRoute.approve,
                pageBuilder: (context, state) => _fadePage(
                  key: state.pageKey,
                  child: LicenseApprovePage.create(),
                ),
              ),
              GoRoute(
                path: AppRoute.announce,
                pageBuilder: (context, state) => _fadePage(
                  key: state.pageKey,
                  child: const LicenseAnnouncePage(),
                ),
              ),
            ],
          ),

          // Branch 1: ผู้เช่า
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.tenant,
                pageBuilder: (context, state) => _fadePage(
                  key: state.pageKey,
                  child: TenantLicensePage.create(),
                ),
              ),
            ],
          ),

          // Branch 2: ทะเบียน
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.registration,
                pageBuilder: (context, state) => _fadePage(
                  key: state.pageKey,
                  child: RegistrationPage.create(),
                ),
              ),
            ],
          ),

          // Branch 3: จัดการข้อมูลส่วนตัว
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.profileManage,
                pageBuilder: (context, state) => _fadePage(
                  key: state.pageKey,
                  child: ManagePersonalInformationPage.create(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
