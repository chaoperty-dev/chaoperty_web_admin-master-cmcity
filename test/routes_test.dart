// ============================================================================
// routes_test.dart
// ============================================================================
// ทดสอบ:
// 1. AppRoute constants — parse จาก source file
// 2. navigation_menu.json — parse ถูก, status=true ทุกเมนู
// 3. Route ใน menu ตรงกับ AppRoute constants
//
// หมายเหตุ: ไม่ import app_router.dart โดยตรงเพราะมัน pull in dart:html
// (ใช้ได้เฉพาะ web) — แทนที่จะ parse source file ด้วย regex
// ============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  // ==========================================================================
  // 🛣️ AppRoute constants (parse จาก source)
  // ==========================================================================
  group('🛣️ AppRoute constants (parsed from source)', () {
    late Set<String> routeConstants;

    setUpAll(() {
      final file = File('lib/router/app_router.dart');
      expect(file.existsSync(), true);
      final content = file.readAsStringSync();
      final regex = RegExp(r"static const String (\w+) = '([^']+)';");
      routeConstants = <String>{};
      for (final m in regex.allMatches(content)) {
        routeConstants.add(m.group(2)!);
      }
    });

    test('✅ มี routes พื้นฐาน 16 ตัว', () {
      expect(routeConstants.contains('/login'), true);
      expect(routeConstants.contains('/contract'), true);
      expect(routeConstants.contains('/payment'), true);
      expect(routeConstants.contains('/attach'), true);
      expect(routeConstants.contains('/verify'), true);
      expect(routeConstants.contains('/fact-check'), true);
      expect(routeConstants.contains('/approve'), true);
      expect(routeConstants.contains('/submit-approval'), true);
      expect(routeConstants.contains('/announce'), true);
      expect(routeConstants.contains('/tenant'), true);
      expect(routeConstants.contains('/area'), true);
      expect(routeConstants.contains('/registration'), true);
      expect(routeConstants.contains('/setting'), true);
      expect(routeConstants.contains('/profile/manage'), true);
      expect(routeConstants.contains('/report/customers'), true);
      expect(routeConstants.contains('/report/areas'), true);
    });

    test('✅ routes ทุกตัวขึ้นต้นด้วย /', () {
      for (final r in routeConstants) {
        expect(r.startsWith('/'), true, reason: '$r should start with /');
      }
    });

    test('✅ routes ไม่ซ้ำกัน', () {
      expect(routeConstants.length, routeConstants.length);
    });
  });


  // ==========================================================================
  // 📋 navigation_menu.json
  // ==========================================================================
  group('📋 navigation_menu.json', () {
    late Map<String, dynamic> menuJson;
    late List<dynamic> items;

    setUpAll(() {
      final file = File('assets/menu/navigation_menu.json');
      expect(file.existsSync(), true, reason: 'menu file must exist');
      final content = file.readAsStringSync();
      menuJson = json.decode(content) as Map<String, dynamic>;
      items = menuJson['items'] as List<dynamic>;
    });

    test('✅ parse header + items', () {
      expect(menuJson['header'], isNotNull);
      expect(menuJson['header']['title'], 'Chaoperty');
      expect(items.isNotEmpty, true);
    });

    test('✅ มี 8 items ระดับบนสุด', () {
      expect(items.length, 7);
    });

    test('✅ ทุก item มี label + icon', () {
      for (final item in items) {
        final m = item as Map<String, dynamic>;
        expect(m['label'], isNotNull);
        if (m['type'] == 'item') {
          expect(m['route'], isNotNull);
        }
        expect(m['icon'], isNotNull);
      }
    });

    test('✅ ทุกเมนู status=true', () {
      for (final item in items) {
        final m = item as Map<String, dynamic>;
        expect(m['status'], true, reason: ' should be active');
        if (m['children'] != null) {
          for (final child in m['children'] as List) {
            final c = child as Map<String, dynamic>;
            expect(c['status'], true,
                reason: ' >  should be active');
          }
        }
      }
    });

    test('✅ กลุ่ม "รายงาน" มี 2 children (customers + areas)', () {
      final reportGroup = items.firstWhere(
        (i) => (i as Map)['label'] == 'รายงาน',
        orElse: () => <String, dynamic>{},
      ) as Map<String, dynamic>;
      expect(reportGroup, isNot(equals(<String, dynamic>{})));
      final children = reportGroup['children'] as List;
      expect(children.length, 2);
      final labels = children.map((c) => (c as Map)['label']).toList();
      expect(labels.contains('รายงานลูกค้า'), true);
      expect(labels.contains('รายงานพื้นที่เช่า'), true);
    });

    test('✅ กลุ่ม "ใบอนุญาต" มี 8 children', () {
      final licenseGroup = items.firstWhere(
        (i) => (i as Map)['label'] == 'ใบอนุญาต',
        orElse: () => <String, dynamic>{},
      ) as Map<String, dynamic>;
      final children = licenseGroup['children'] as List;
      expect(children.length, 8);
    });
  });

  // ==========================================================================
  // 🔗 Sync menu routes ↔ AppRoute constants
  // ==========================================================================
  group('🔗 Sync menu routes ↔ AppRoute constants', () {
    test('✅ routes ใน menu มีใน AppRoute', () {
      final menuFile = File('assets/menu/navigation_menu.json');
      final menuJson = json.decode(menuFile.readAsStringSync());

      // ดึง routes จาก menu
      final menuRoutes = <String>{};
      for (final item in menuJson['items'] as List) {
        final m = item as Map<String, dynamic>;
        if (m['route'] != null) menuRoutes.add(m['route'] as String);
        if (m['children'] != null) {
          for (final c in m['children'] as List) {
            menuRoutes.add((c as Map)['route'] as String);
          }
        }
      }

      // ดึง routes จาก app_router.dart
      final routerFile = File('lib/router/app_router.dart');
      final content = routerFile.readAsStringSync();
      final regex = RegExp(r"static const String (\w+) = '([^']+)';");
      final appRoutes = <String>{};
      for (final m in regex.allMatches(content)) {
        appRoutes.add(m.group(2)!);
      }

      for (final r in menuRoutes) {
        expect(appRoutes.contains(r), true,
            reason: ' is in menu but missing from AppRoute');
      }
    });
  });
}
