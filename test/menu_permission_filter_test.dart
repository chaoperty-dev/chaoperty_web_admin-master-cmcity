// ============================================================================
// menu_permission_filter_test.dart
// ============================================================================
// Tests for permission-based menu filtering:
// - NavigationItemModel / NavigationChildModel permission parsing
// - NavigationMenuService.loadFiltered() (uses real asset JSON +
//   mocked SharedPreferences for menuPermission codes)
// - AuthService.getMenuPermissions()
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chaoperty/ChiangMai_Municipality/List_CMM/Register_CMM/AuthService.dart';
import 'package:chaoperty/navigation/models/navigation_menu_model.dart';
import 'package:chaoperty/navigation/services/navigation_menu_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    NavigationMenuService.clearCache();
  });

  // ==========================================================================
  // Model: permission field parsing
  // ==========================================================================
  group('NavigationItemModel.permission', () {
    test('parses permission code from JSON', () {
      final item = NavigationItemModel.fromJson({
        'type': 'item',
        'label': 'Area',
        'route': '/area',
        'permission': 'area_manager',
      });
      expect(item.permission, 'area_manager');
      expect(item.isGroup, isFalse);
    });

    test('permission defaults to null when absent', () {
      final item = NavigationItemModel.fromJson({
        'type': 'item',
        'label': 'Area',
        'route': '/area',
      });
      expect(item.permission, isNull);
    });

    test('child parses own permission, defaults null (inherit group)', () {
      final child = NavigationChildModel.fromJson({
        'label': 'Announce',
        'route': '/announce',
      });
      expect(child.permission, isNull);

      final child2 = NavigationChildModel.fromJson({
        'label': 'Reports',
        'route': '/report/areas',
        'permission': 'reports',
      });
      expect(child2.permission, 'reports');
    });

    test('copyWithChildren keeps fields, replaces children', () {
      final group = NavigationItemModel.fromJson({
        'type': 'group',
        'label': 'License',
        'permission': 'permit',
        'children': [
          {'label': 'A', 'route': '/a'},
          {'label': 'B', 'route': '/b'},
        ],
      });
      final copy = group.copyWithChildren([group.children.first]);
      expect(copy.label, 'License');
      expect(copy.permission, 'permit');
      expect(copy.children.length, 1);
      expect(copy.children.first.label, 'A');
    });
  });

  // ==========================================================================
  // Service: loadFiltered() against the real asset JSON
  // ==========================================================================
  group('NavigationMenuService.loadFiltered', () {
    test('all current role codes -> all 7 top items, 8 permit children',
        () async {
      SharedPreferences.setMockInitialValues({
        'menuPermission': 'area_manager,CURRENT_TENANTS,LICENSE_ISSUANCE_PROCESS,'
            'LICENSE_REQUEST_ANNOUNCEMENT,LICENSE_REQUEST,'
            'REQUEST_DOCUMENT_ATTACHMENT,FEE_PAYMENT,REQUEST_DOCUMENT_REVIEW,'
            'FACT_VERIFICATION,SUBMIT_APPROVAL_REQUEST,APPROVE_REQUEST,'
            'permit,TENANT_REGISTRY,reports,REGISTRY_REPORT,'
            'RENTAL_AREA_REPORT,setting,SYSTEM_MASTER_DATA,'
            'AREA_CONFIGURATION,RENTAL_CONFIGURATION,DOCUMENTS_AND_FORMS,'
            'PAYMENT_RECEIPT_CONFIGURATION,ACCESS_PERMISSION,profile,'
            'management,account_manager',
      });
      final menu = await NavigationMenuService.loadFiltered();

      expect(menu.items.length, 7);
      final labels = menu.items.map((e) => e.label).toList();
      expect(
          labels,
          containsAll([
            'พื้นที่เช่า',
            'ผู้เช่า',
            'ใบอนุญาต',
            'ทะเบียน',
            'รายงาน',
            'ตั้งค่า',
            'จัดการข้อมูลส่วนตัว',
          ]));

      final permit = menu.items.firstWhere((e) => e.label == 'ใบอนุญาต');
      expect(permit.children.length, 8);
      final reports = menu.items.firstWhere((e) => e.label == 'รายงาน');
      expect(reports.children.length, 2);
    });

    test('group perm + 1 child perm + profile -> filtered children', () async {
      // json ใหม่: group ใบอนุญาต ใช้ LICENSE_ISSUANCE_PROCESS
      // และ children ระบุ permission ของตัวเอง (ไม่สืบทอดกลุ่ม)
      SharedPreferences.setMockInitialValues({
        'menuPermission': 'LICENSE_ISSUANCE_PROCESS,FEE_PAYMENT,profile',
      });
      final menu = await NavigationMenuService.loadFiltered();

      expect(menu.items.length, 2);
      expect(menu.items.map((e) => e.label),
          containsAll(['ใบอนุญาต', 'จัดการข้อมูลส่วนตัว']));
      final permit = menu.items.firstWhere((e) => e.label == 'ใบอนุญาต');
      expect(
          permit.children.length, 1); // เฉพาะ child ที่มีสิทธิ์ (FEE_PAYMENT)
      expect(permit.children.first.label, 'ชำระค่าธรรมเนียม');
    });

    test('empty permissions -> menu hidden entirely (secure default)',
        () async {
      SharedPreferences.setMockInitialValues({
        'menuPermission': '',
      });
      final menu = await NavigationMenuService.loadFiltered();
      expect(menu.items, isEmpty);
    });

    test('no menuPermission key (fresh storage) -> menu hidden', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final menu = await NavigationMenuService.loadFiltered();
      expect(menu.items, isEmpty);
    });

    test('unrelated codes -> everything permissioned is hidden', () async {
      SharedPreferences.setMockInitialValues({
        'menuPermission': 'doc_reviewer,some_future_code',
      });
      final menu = await NavigationMenuService.loadFiltered();
      expect(menu.items, isEmpty);
    });
  });

  // ==========================================================================
  // AuthService.getMenuPermissions
  // ==========================================================================
  group('AuthService.getMenuPermissions', () {
    test('splits comma-separated codes, trims empties', () async {
      SharedPreferences.setMockInitialValues({
        'menuPermission': ' permit ,profile,, reports ',
      });
      final codes = await AuthService.getMenuPermissions();
      expect(codes, ['permit', 'profile', 'reports']);
    });

    test('missing key -> empty list', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final codes = await AuthService.getMenuPermissions();
      expect(codes, isEmpty);
    });
  });
}
