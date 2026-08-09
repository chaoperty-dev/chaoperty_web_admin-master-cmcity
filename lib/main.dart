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
import 'router/app_router.dart';
import 'router/auth_state_notifier.dart';

const bool enableAppLogs = true;

/// SidebarController — เก็บไว้เพราะไฟล์อื่นๆ เช่น AdminScaffold ใช้
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
      theme: ThemeData(
        primarySwatch: Colors.green,
        scrollbarTheme: ScrollbarThemeData().copyWith(
          thumbColor: MaterialStateProperty.all(Colors.lightGreen[200]),
        ),
      ),
      routerConfig: _router,
    );
  }
}
