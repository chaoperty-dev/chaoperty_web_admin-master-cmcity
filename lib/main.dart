// ignore_for_file: unused_import, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';

import 'ChiangMai_Municipality/List_CMM/Register_CMM/AuthService.dart';
import 'app/root_scaffold_messenger.dart';
import 'router/app_router.dart';
import 'router/auth_state_notifier.dart';

const bool enableAppLogs = true;

/// flutter run -d chrome --web-browser-flag "--disable-web-security"
/// SidebarController — เก็บไว้เพราะไฟล์อื่นๆ เช่น AdminScaffold ใช้
// /flutter build web --dart-define=BROWSER_IMAGE_DECODING_ENABLED=false   (แก้ปัญหา Security Capture Screen )
// /flutter build web --dart-define=BROWSER_IMAGE_DECODING_ENABLED=false-browser-flag=--disable-web-security
// /flutter build web --dart-define=BROWSER_IMAGE_DECODING_ENABLED=false-define=web-browser-flag=--disable-web-security --no-tree-shake-icons
// ** */ flutter build web --dart-define=BROWSER_IMAGE_DECODING_ENABLED=false-browser-flag=--disable-web-security --no-tree-shake-icons --base-href /user_intents/
// flutter build web --dart-define=BROWSER_IMAGE_DECODING_ENABLED=false-browser-flag=--disable-web-security --no-tree-shake-icons --base-href /cmcity_test/
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setUrlStrategy(const HashUrlStrategy());

  // โหลด SidebarController ก่อน build app (เหมือนเดิม)
  final sidebarCtrl = SidebarController();
  await sidebarCtrl.load();

  // สร้าง AuthStateNotifier — polling token ทุก 1 วินาที
  // เพื่อให้ GoRouter refresh เมื่อ login/logout
  final authNotifier = AuthStateNotifier();
  authNotifier.startPolling();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SidebarController>.value(value: sidebarCtrl),
        ChangeNotifierProvider<AuthStateNotifier>.value(value: authNotifier),
      ],
      child: MyApp(authNotifier: authNotifier),
    ),
  );
}

class MyApp extends StatefulWidget {
  final AuthStateNotifier authNotifier;

  const MyApp({super.key, required this.authNotifier});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = buildAppRouter(authNotifier: widget.authNotifier);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
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
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scrollbarTheme: ScrollbarThemeData().copyWith(
          thumbColor: MaterialStateProperty.all(Colors.lightGreen[200]),
        ),
      ),
      routerConfig: _router,
      // ─── กันหน้าจอที่สูงเกินไป ───
      // ถ้า height < 500 → UI หลักแสดงผลไม่พอ (โทรศัพท์แนวนอน, split-screen, foldable ปิด)
      // → แสดงจอ "กรุณาหมุนเป็นแนวตั้ง" แทน
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        if (mq.size.height < 500) {
          return const _RotateDeviceScreen();
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}

/// จอเตือนเมื่อโทรศัพท์อยู่แนวนอน — UI หลักออกแบบมาสำหรับแนวตั้งเท่านั้น
class _RotateDeviceScreen extends StatelessWidget {
  const _RotateDeviceScreen();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: const Color(0xFFF6F8F5),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Phone icon + rotation arrow
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(.15),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.phone_iphone_rounded,
                          size: 48,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E7D32),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.screen_rotation_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'กรุณาหมุนอุปกรณ์เป็นแนวตั้ง',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B5E20),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'แอปนี้รองรับการใช้งานบนโทรศัพท์ในแนวตั้งเท่านั้น\n'
                    'โปรดหมุนหน้าจอกลับเพื่อใช้งานต่อ',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF555555),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
