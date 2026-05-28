// ignore_for_file: unused_import

import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ChiangMai_Municipality/List_CMM/Register_CMM/AuthService.dart';
import 'ChiangMai_Municipality/List_CMM/Register_CMM/Login_page_cmm.dart';
import 'ChiangMai_Municipality/List_CMM/Register_CMM/SetupPage.dart';
import 'Register/SignIn_License.dart';
import 'Register/SignIn_Screen.dart';
import 'Register/SignIn_admin.dart';
import 'Register/Signup_License.dart';
import 'Setting/Draginto_example.dart';
import 'Setting/test.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb, kReleaseMode;
import 'dart:html' as html;
import 'ChiangMai_Municipality/mobile_upload_grid_cmm.dart';
import 'Style/test_print_name.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

///validator@gmail.com----------------------------------------------------->
///
/// flutter run --enable-software-rendering
/// flutter run -d chrome --web-renderer html --enable-software-rendering
/// flutter run -d chrome  --no-sound-null-safety
/// flutter run -d chrome --web-browser-flag "--disable-web-security" (à¹à¸à¹‰à¸›à¸±à¸à¸«à¸² security  CORS (Cross-Origin Resource Sharing))
/// flutter run -d web-server
///
///----------------------------------------------------->4
///
/// flutter build web --web-renderer html --release
///  flutter build web --release --no-sound-null-safety
/// flutter build web --web-renderer html --release --no-sound-null-safety
///  flutter build web --web-renderer html --release --dart-define=web-browser-flag=--disable-web-security (à¹à¸à¹‰à¸›à¸±à¸à¸«à¸² security  CORS (Cross-Origin Resource Sharing))
///  flutter build web --web-renderer html --release --no-sound-null-safety --dart-define=web-browser-flag=--disable-web-security (à¹à¸à¹‰à¸›à¸±à¸à¸«à¸² security  CORS (Cross-Origin Resource Sharing))
///  flutter build web --release --web-renderer=html --dart-define=web-browser-flag=--disable-web-security
///
//----------------------------------------------------->
//
// flutter build web --web-renderer html --release --dart-define=web-browser-flag=--disable-web-security --no-tree-shake-icons (à¹à¸à¹‰à¸›à¸±à¸à¸«à¸² This application cannot tree shake icons fonts. It has non-constant instances of IconData at the following location)
///
///flutter build web --dart-define=BROWSER_IMAGE_DECODING_ENABLED=false   (à¹à¸à¹‰à¸›à¸±à¸à¸«à¸² Security Capture Screen )
///flutter build web --dart-define=BROWSER_IMAGE_DECODING_ENABLED=false-browser-flag=--disable-web-security  (à¹à¸à¹‰à¸›à¸±à¸à¸«à¸² Security Capture Screen + security  CORS )
///flutter build web --dart-define=BROWSER_IMAGE_DECODING_ENABLED=false-define=web-browser-flag=--disable-web-security --no-tree-shake-icons  (à¹à¸à¹‰à¸›à¸±à¸à¸«à¸² Security Capture Screen + security  CORS + icons )
///
//*/flutter build web --dart-define=BROWSER_IMAGE_DECODING_ENABLED=false-browser-flag=--disable-web-security --no-tree-shake-icons
//*#/flutter build web --web-renderer canvaskit --no-tree-shake-icons --base-href /cmcity/
//*#/flutter build web --web-renderer canvaskit --no-tree-shake-icons --base-href /cmcity_test/

//----------------------------------------------------->
//----(Git Lab)
//1.----> git add .
//2.------> git remote set-url origin https://gitlab.com/traishitech.com/chaoperty.git
//3.-------->git commit -m "commit message"
//4.-----------> git push origin main
//----------------------------------------------------->
//----(Git Hub)
//1.----> git add .
//2.------> git remote set-url origin https://github.com/trairatdzentric/chaoperty_web.git
//2.------> git remote set-url origin https://github.com/TraiShiTech/chaoperty.git
//3.-------->git commit -m "commit message"
//4.-----------> git push origin main
//----------------------------------------------------->
//  git config --global user.email "trairat.dzentric@gmail.com"
//  git config --global user.name "trairatdzentric"
//----------------------------------------------------->
//à¸à¸£à¸¸à¸“à¸²à¸•à¸±à¸”à¸«à¸™à¸µà¹‰à¸£à¸²à¸¢à¸à¸²à¸£à¸§à¸²à¸‡à¸šà¸´à¸¥à¹ƒà¸«à¹‰à¹€à¸ªà¸£à¹‡à¸ˆà¸ªà¸´à¹‰à¸™ à¸à¹ˆà¸­à¸™à¸£à¸­à¸šà¸§à¸²à¸‡à¸šà¸´à¸¥à¹ƒà¸«à¸¡à¹ˆ à¸«à¸²à¸à¸•à¸´à¸”à¸›à¸±à¸à¸«à¸²à¸à¸£à¸¸à¸“à¸²à¸•à¸´à¸”à¸•à¹ˆà¸­ chaoperty
// à¸‚à¸­à¸­à¸ à¸±à¸¢ à¸£à¸°à¸šà¸šà¸ˆà¸°à¸¡à¸µà¸à¸²à¸£à¸­à¸±à¸žà¹€à¸”à¸• à¸“. 12.00 -12.50 à¸™.(08/10/2025)
// à¸­à¸±à¸žà¹€à¸”à¸•à¸£à¸°à¸šà¸šà¹€à¸ªà¸£à¹‡à¸ˆà¸ªà¸´à¹‰à¸™à¹à¸¥à¹‰à¸§(09/12/2024) à¸à¸£à¸¸à¸“à¸²à¸­à¸­à¸à¸ˆà¸²à¸à¸£à¸°à¸šà¸šà¹à¸¥à¸°à¸£à¸µà¹€à¸Ÿà¸£à¸Š...
// à¸­à¸±à¸žà¹€à¸”à¸•à¸£à¸°à¸šà¸šà¹€à¸ªà¸£à¹‡à¸ˆà¸ªà¸´à¹‰à¸™à¹à¸¥à¹‰à¸§ à¸à¸£à¸¸à¸“à¸²à¸­à¸­à¸à¸ˆà¸²à¸à¸£à¸°à¸šà¸šà¹à¸¥à¸°à¸£à¸µà¹€à¸Ÿà¸£à¸Š..
// 1.à¸‚à¸­à¸­à¸ à¸±à¸¢ à¹€à¸à¸´à¸”à¸‚à¹‰à¸­à¸œà¸´à¸”à¸žà¸¥à¸²à¸”à¹€à¸¡à¸™à¸¹ à¸šà¸±à¸à¸Šà¸µ->à¸Šà¸³à¸£à¸°à¸šà¸´à¸¥ à¸à¸£à¸¸à¸“à¸²à¸«à¸¢à¸¸à¸”à¹ƒà¸Šà¹‰à¸Šà¸±à¹ˆà¸§à¸„à¸£à¸²à¸§à¸ˆà¸™à¸à¸§à¹ˆà¸²à¸£à¸°à¸šà¸šà¸ˆà¸°à¸¡à¸µà¸à¸²à¸£à¸­à¸±à¸žà¹€à¸”à¸•(09/04/2567) // 2. à¸‚à¸­à¸­à¸ à¸±à¸¢ à¸£à¸°à¸šà¸šà¸ˆà¸°à¸¡à¸µà¸à¸²à¸£à¸­à¸±à¸žà¹€à¸”à¸• à¸“. 10.40 -10.55 à¸™.(09/04/2567)
// flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080

// void main() {
//   HttpOverrides.global = new MyHttpOverrides();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         // ignore: prefer_const_literals_to_create_immutables
//         localizationsDelegates: [
//           GlobalMaterialLocalizations.delegate,
//           GlobalWidgetsLocalizations.delegate,
//           MonthYearPickerLocalizations.delegate,
//         ],
//         // ignore: prefer_const_literals_to_create_immutables
//         supportedLocales: [
//           const Locale('en', 'US'), // English
//           const Locale('th', 'TH'), // Thai
//           const Locale('lo', 'LA'), // Lao
//         ],
//         locale: const Locale('th'),
//         title: 'Chaoperty',
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//             primarySwatch: Colors.green,
//             scrollbarTheme: ScrollbarThemeData().copyWith(
//               thumbColor: MaterialStateProperty.all(Colors.lightGreen[200]),
//             )),
//         home: SignInScreen()

//         //  const SignInScreen(),
//         // home: SignUPLicense()// SignInLicense(), // SignUnAdmin(),
//         );
//   }
// }
// flutter run -d chrome --web-hostname=localhost --web-port=5000 --dart-define=FLUTTER_WEB_USE_SKIA=true
class SidebarController extends ChangeNotifier {
  static const _key = 'isSidebarOpen';
  bool _isOpen = true;
  bool get isOpen => _isOpen;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isOpen = prefs.getBool(_key) ?? true;
    notifyListeners();
  }

  Future<void> toggle() async {
    _isOpen = !_isOpen;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, _isOpen);
  }

  Future<void> set(bool value) async {
    _isOpen = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, _isOpen);
  }
}

const bool enableAppLogs =
    true; // Set to false to disable all debugPrint logs globally

void main() async {
  setUrlStrategy(const HashUrlStrategy());
  WidgetsFlutterBinding.ensureInitialized();

  final ctrl = SidebarController();
  await ctrl.load(); // Load persisted sidebar state before runApp

  runZonedGuarded(
    () async {
      if (!enableAppLogs) {
        debugPrint = (String? message, {int? wrapWidth}) {};
      }
      String fragment = '';

      if (kIsWeb) {
        // Listen for hash change from QR scan.
        html.window.onHashChange.listen((event) {
          final newHash = html.window.location.hash;
          if (newHash.contains('mobile_upload')) {
            html.window.location.reload();
          }
        });

        // Read URL fragment (#...).
        fragment = html.window.location.hash;
        if (fragment.startsWith('#')) {
          fragment = fragment.substring(1);
        }

        // Restore guest session.
        if (fragment.isEmpty || !fragment.contains('mobile_upload')) {
          final savedUrl = html.window.localStorage['last_mobile_upload_url'];

          if (savedUrl != null && savedUrl.contains('mobile_upload')) {
            fragment =
                savedUrl.startsWith('#') ? savedUrl.substring(1) : savedUrl;
          }
        }
      }

      final isMobileUpload = fragment.contains('mobile_upload');

      Widget initialPage;

      if (isMobileUpload) {
        /// ===============================
        /// Mobile Upload Mode
        /// ===============================
        final queryPart =
            fragment.contains('?') ? fragment.split('?').last : '';

        final queryParams = Uri.splitQueryString(queryPart);

        String requestUuid = queryParams['request_uuid'] ?? '';
        String expiry = queryParams['expiry'] ?? '';
        String token = queryParams['token'] ?? '';

        // Support base64 obfuscation (d).
        if (queryParams.containsKey('d')) {
          try {
            final decoded = utf8.decode(base64Url.decode(queryParams['d']!));
            final data = json.decode(decoded);

            requestUuid = data['request_uuid']?.toString() ?? '';
            expiry = data['expiry']?.toString() ?? '';
            token = data['token']?.toString() ?? '';
          } catch (_) {
            // Silent fallback for production.
          }
        }

        initialPage = MobileUploadGrid_CMM(
          requestUuid: requestUuid,
          expiry: expiry,
          accessToken: token,
        );
      } else {
        /// ===============================
        /// Normal App Flow
        /// ===============================
        final isLoggedIn = await AuthService.tryAutoLogin();
        final isFirstLogin = isLoggedIn && (await AuthService.isFirstLogin());
        // In lib/main.dart
        // initialPage = const TestPrintNamePage();
        initialPage = isLoggedIn
            ? (isFirstLogin ? const SetupPage() : const SetupPage())
            : const LoginPage();

        // initialPage = isLoggedIn
        //     ? (isFirstLogin ? const SetupPage() : const SetupPage())
        //     : const LoginPage();
      }

      /// ===============================
      /// Run App
      /// ===============================

      runApp(
        ChangeNotifierProvider.value(
          value: ctrl,
          child: MyApp(
            initialPage: initialPage,
            blockBack: !isMobileUpload,
          ),
        ),
      );
    },

    /// ===============================
    /// Global Error Handler
    /// ===============================
    (error, stackTrace) {
      if (enableAppLogs) {
        print('ERROR: $error');
        print(stackTrace);
      }
    },

    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        if (enableAppLogs) {
          parent.print(zone, line);
        }
      },
    ),
  );
}
// void main() async {
//   setUrlStrategy(const HashUrlStrategy());
//   WidgetsFlutterBinding.ensureInitialized();

//   final ctrl = SidebarController();
//   await ctrl.load(); // à¹‚à¸«à¸¥à¸”à¸„à¹ˆà¸²à¸à¹ˆà¸­à¸™ runApp

//   runZonedGuarded(
//     () async {
//       // à¸›à¸´à¸” debugPrint à¸—à¸¸à¸à¸­à¸±à¸™
//       debugPrint = (String? message, {int? wrapWidth}) {};

//       String fragment = '';
//       if (kIsWeb) {
//         // Listen for hash changes to force refresh on new QR scans
//         html.window.onHashChange.listen((event) {
//           final newHash = html.window.location.hash;
//           if (newHash.contains('mobile_upload')) {
//             html.window.location.reload();
//           }
//         });

//         // Use location.hash directly as it's more reliable for HashUrlStrategy
//         fragment = html.window.location.hash;
//         if (fragment.startsWith('#')) fragment = fragment.substring(1);

//         // Restore Guest session only if current fragment is empty/invalid
//         if (fragment.isEmpty || !fragment.contains('mobile_upload')) {
//           final savedUrl = html.window.localStorage['last_mobile_upload_url'];
//           if (savedUrl != null && savedUrl.contains('mobile_upload')) {
//             fragment =
//                 savedUrl.startsWith('#') ? savedUrl.substring(1) : savedUrl;
//           }
//         }
//       }

//       final isMobileUpload = fragment.contains('mobile_upload');

//       Widget initialPage;
//       if (isMobileUpload) {
//         final queryPart =
//             fragment.contains('?') ? fragment.split('?').last : '';
//         final queryParams = Uri.splitQueryString(queryPart);

//         String requestUuid = queryParams['request_uuid'] ?? '';
//         String expiry = queryParams['expiry'] ?? '';
//         String token = queryParams['token'] ?? '';

//         // Handle obfuscated data if 'd' parameter is present
//         if (queryParams.containsKey('d')) {
//           try {
//             final decoded = utf8.decode(base64Url.decode(queryParams['d']!));
//             final data = json.decode(decoded);
//             requestUuid = data['request_uuid']?.toString() ?? '';
//             expiry = data['expiry']?.toString() ?? '';
//             token = data['token']?.toString() ?? '';
//           } catch (e) {
//             // Fallback or silent error
//           }
//         }

//         initialPage = MobileUploadGrid_CMM(
//           requestUuid: requestUuid,
//           expiry: expiry,
//           accessToken: token,
//         );
//       } else {
//         final isLoggedIn = await AuthService.tryAutoLogin();
//         final isFirstLogin = isLoggedIn && (await AuthService.isFirstLogin());
//         initialPage = isLoggedIn
//             ? (isFirstLogin ? const SetupPage() : const SetupPage())
//             : const LoginPage();
//       }

//       runApp(
//         ChangeNotifierProvider.value(
//           value: ctrl,
//           child: MyApp(
//             initialPage: initialPage,
//             blockBack: !isMobileUpload, // âœ… à¸¥à¹‡à¸­à¸à¸­à¸´à¸™à¹à¸¥à¹‰à¸§à¸„à¹ˆà¸­à¸¢à¸šà¸¥à¹‡à¸­à¸ back
//           ),
//         ),
//       );
//     },
//     (error, stackTrace) {
//       // à¸•à¸£à¸‡à¸™à¸µà¹‰à¸–à¹‰à¸²à¸­à¸¢à¸²à¸ log error à¹„à¸› server à¸à¹‡à¹ƒà¸ªà¹ˆà¹„à¸”à¹‰
//       // à¹à¸•à¹ˆà¸–à¹‰à¸²à¸­à¸¢à¸²à¸à¹€à¸‡à¸µà¸¢à¸šà¸ªà¸™à¸´à¸—à¸ˆà¸£à¸´à¸‡ à¹† à¸à¹‡à¸›à¸¥à¹ˆà¸­à¸¢à¸§à¹ˆà¸²à¸‡à¹„à¸”à¹‰
//     },
//     zoneSpecification: ZoneSpecification(
//       // à¸›à¸´à¸” print() à¸—à¸¸à¸à¸­à¸±à¸™à¹ƒà¸™à¹à¸­à¸›
//       print: (self, parent, zone, line) {
//         // à¹„à¸¡à¹ˆà¹€à¸£à¸µà¸¢à¸ parent.print = mute
//       },
//     ),
//   );
// }

class MyApp extends StatelessWidget {
  final Widget initialPage;
  final bool blockBack;

  const MyApp({super.key, required this.initialPage, required this.blockBack});

  @override
  Widget build(BuildContext context) {
    final wrapped = blockBack
        ? BackBlocker(child: initialPage) // âœ… à¸à¸±à¸™ pop
        : initialPage;

    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        MonthYearPickerLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('th', 'TH'),
        Locale('lo', 'LA'),
      ],
      locale: const Locale('th'),
      title: 'Chaoperty',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scrollbarTheme: ScrollbarThemeData().copyWith(
          thumbColor: MaterialStateProperty.all(Colors.lightGreen[200]),
        ),
      ),
      home: BackBlocker(child: initialPage),
    );
  }
}

class BackBlocker extends StatefulWidget {
  final Widget child;
  const BackBlocker({super.key, required this.child});

  @override
  State<BackBlocker> createState() => _BackBlockerState();
}

class _BackBlockerState extends State<BackBlocker> {
  @override
  void initState() {
    super.initState();
    // Removed corrupted history pushState
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>
          false, // âŒ à¸à¸±à¸™à¸›à¸¸à¹ˆà¸¡ back à¹ƒà¸™à¹à¸­à¸›
      child: widget.child,
    );
  }
}
