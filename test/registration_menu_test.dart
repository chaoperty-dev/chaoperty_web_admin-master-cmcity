// ============================================================================
// registration_menu_test.dart
// ============================================================================
// ชุดทดสอบเมนู "ทะเบียนผู้เช่า" (registration_page)
// - ไม่ยิง HTTP/ApiCache จริง (ใช้ FakeRegistrationService)
// - ครอบคลุม: Pagination, ค้นหา, กรองสถานะ, Event, findTenantByKey,
//   และ Widget test (ตาราง + pagination)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:chaoperty/ChiangMai_Municipality/Registration_menu/registration_page/models/registration_config.dart';
import 'package:chaoperty/ChiangMai_Municipality/Registration_menu/registration_page/services/registration_service.dart';
import 'package:chaoperty/ChiangMai_Municipality/Registration_menu/registration_page/models/registration_event.dart';
import 'package:chaoperty/ChiangMai_Municipality/Registration_menu/registration_page/viewmodels/registration_view_model.dart';
import 'package:chaoperty/ChiangMai_Municipality/Registration_menu/registration_page/views/widgets/registration_pagination.dart';
import 'package:chaoperty/ChiangMai_Municipality/Registration_menu/registration_page/views/widgets/registration_table.dart';
import 'package:chaoperty/ChiangMai_Municipality/Report_menu/customers/services/customers_report_service.dart';

/// Fake service ที่คืนข้อมูลจำลอง (ไม่ยิง network)
class FakeRegistrationService extends RegistrationService {
  FakeRegistrationService({required this.items});
  final List<CustomerReportItem> items;

  @override
  Future<List<CustomerReportItem>> fetchReportCustomers() async => items;
}

List<CustomerReportItem> _buildItems(int count, {List<int>? statuses}) {
  return List<CustomerReportItem>.generate(
    count,
    (i) => CustomerReportItem(
      uuid: 'uuid-$i',
      custno: 'C${1000 + i}',
      cname: 'ลูกค้า $i',
      scname: 'ร้าน $i',
      taxno: '1${i.toString().padLeft(12, '0')}',
      tel: '053-000-${(i + 1).toString().padLeft(3, '0')}',
      st: statuses == null ? 1 : (statuses[i] ?? 1),
    ),
  );
}

RegistrationViewModel _vm(List<CustomerReportItem> items) => RegistrationViewModel(
      config: const RegistrationConfig(title: 'ทะเบียน'),
      service: FakeRegistrationService(items: items),
    );

void main() {
  // ==========================================================================
  // 📄 Pagination
  // ==========================================================================
  group('📄 Pagination', () {
    test('✅ คำนวณหน้าจากจำนวนรายการ (perPage = 50)', () async {
      final vm = _vm(_buildItems(120));
      await vm.refresh();
      expect(vm.total, 120);
      expect(vm.computedLastPage, 3);
      expect(vm.paged.length, 50);
    });

    test('✅ goToPage เปลี่ยนหน้าและตัด slice ถูกต้อง', () async {
      final vm = _vm(_buildItems(120));
      await vm.refresh();

      vm.goToPage(2);
      expect(vm.currentPage, 2);
      expect(vm.paged.length, 50);
      expect(vm.paged.first.uuid, 'uuid-50');

      vm.goToPage(3);
      expect(vm.currentPage, 3);
      expect(vm.paged.length, 20);
      expect(vm.paged.last.uuid, 'uuid-119');
    });

    test('✅ goToPage คลamping เมื่อเกิน范围', () async {
      final vm = _vm(_buildItems(120));
      await vm.refresh();

      vm.goToPage(3); // ไปหน้าสุดท้ายก่อน
      expect(vm.currentPage, 3);
      vm.goToPage(99); // เกิน lastPage → คงที่
      expect(vm.currentPage, 3);
      vm.goToPage(0); // ต่ำกว่า 1 → คงที่
      expect(vm.currentPage, 3);
      vm.goToPage(-5);
      expect(vm.currentPage, 3);
    });

    test('✅ prevPage / nextPage', () async {
      final vm = _vm(_buildItems(120));
      await vm.refresh();

      vm.nextPage();
      expect(vm.currentPage, 2);
      vm.prevPage();
      expect(vm.currentPage, 1);
      vm.prevPage();
      expect(vm.currentPage, 1); // อยู่หน้า 1 แล้ว → คงที่
    });
  });

  // ==========================================================================
  // 🔍 Search / Filter
  // ==========================================================================
  group('🔍 Search & Filter', () {
    test('✅ ค้นหาตามคำค้น (client-side)', () async {
      final vm = _vm(_buildItems(120));
      await vm.refresh();

      // 'ลูกค้า 0' เจอเฉพาะ i=0
      vm.setSearch('ลูกค้า 0');
      expect(vm.total, 1);
      expect(vm.computedLastPage, 1);
      expect(vm.paged.first.uuid, 'uuid-0');

      // ล้างคำค้น → กลับมาครบ
      vm.setSearch('');
      expect(vm.total, 120);
    });

    test('✅ setSearchField เปลี่ยนฟิลด์ค้นหา', () async {
      final vm = _vm(_buildItems(120));
      await vm.refresh();

      vm.setSearchField('custno');
      expect(vm.searchField, 'custno');
      vm.setSearch('C1100'); // เจอเฉพาะ i=100
      expect(vm.total, 1);
      expect(vm.paged.first.custno, 'C1100');
    });

    test('✅ กรองสถานะตาม st', () async {
      // st: [1,0,2,3,1,0,...] สลับ
      final statuses = List<int>.generate(120, (i) => i % 4);
      final vm = _vm(_buildItems(120, statuses: statuses));
      await vm.refresh();

      vm.onStatusChanged('ปัจจุบัน'); // st == 1
      expect(vm.selectedStatus, 'ปัจจุบัน');
      // i%4==1 → 30 รายการ (1,5,9,...,117)
      expect(vm.total, 30);

      vm.onStatusChanged('หมดสัญญา'); // st == 0 || 2
      // i%4==0 (st0) + i%4==2 (st2) → 60 รายการ
      expect(vm.total, 60);

      vm.onStatusChanged('ใกล้หมดสัญญา'); // st == 3
      // i%4==3 → 30 รายการ
      expect(vm.total, 30);

      vm.onStatusChanged('ทั้งหมด');
      expect(vm.total, 120);
    });

    test('✅ ไม่พบข้อมูล → paged ว่าง', () async {
      final vm = _vm(_buildItems(120));
      await vm.refresh();

      vm.setSearch('ไม่มีในระบบ_xyz');
      expect(vm.total, 0);
      expect(vm.computedLastPage, 0);
      expect(vm.paged.isEmpty, isTrue);
    });
  });

  // ==========================================================================
  // 🧭 Navigation Event / lookup
  // ==========================================================================
  group('🧭 Event & Lookup', () {
    test('✅ onViewTenant ส่ง RegistrationNavigateEvent (routeData = uuid)', () async {
      final vm = _vm(_buildItems(10));
      await vm.refresh();

      final item = vm.paged.first;
      final received = <RegistrationEvent>[];
      final sub = vm.events.listen(received.add);

      vm.onViewTenant(item);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(received, hasLength(1));
      final e = received.first;
      expect(e, isA<RegistrationNavigateEvent>());
      expect((e as RegistrationNavigateEvent).routeData, item.uuid);
    });

    test('✅ findTenantByKey หาได้จาก uuid และ custno', () async {
      final vm = _vm(_buildItems(50));
      await vm.refresh();

      expect(vm.findTenantByKey('uuid-7')?.uuid, 'uuid-7');
      expect(vm.findTenantByKey('C1049')?.custno, 'C1049');
      expect(vm.findTenantByKey(''), isNull);
      expect(vm.findTenantByKey('ไม่มี'), isNull);
    });

    test('✅ kSearchFields มีฟิลด์ครบ', () {
      final fields = RegistrationViewModel.kSearchFields;
      final values = fields.map((f) => f['value']).toList();
      expect(values, contains('cname'));
      expect(values, contains('scname'));
      expect(values, contains('custno'));
      expect(values, contains('taxno'));
      expect(values, contains('tel'));
      expect(values, contains('email'));
      expect(values, contains('lineid'));
    });
  });

  // ==========================================================================
  // 🖼️ Widget tests
  // ==========================================================================
  group('🖼️ Widgets', () {
    testWidgets('✅ RegistrationTable แสดงแถวตาม paged', (tester) async {
      final vm = _vm(_buildItems(120));
      await vm.refresh();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<RegistrationViewModel>.value(
            value: vm,
            child: const SizedBox(
              width: 1200,
              child: RegistrationTable(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // custno ของรายการแรก (i=0) = C1000 ต้องแสดง
      expect(find.text('C1000'), findsWidgets);
      // หัวตาราง "ชื่อลูกค้า"
      expect(find.text('ชื่อลูกค้า'), findsWidgets);
    });

    testWidgets('✅ RegistrationTable แสดง empty state เมื่อไม่มีข้อมูล',
        (tester) async {
      final vm = _vm(_buildItems(120));
      await vm.refresh();
      vm.setSearch('ไม่มีในระบบ_xyz');

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<RegistrationViewModel>.value(
            value: vm,
            child: const SizedBox(
              width: 1200,
              child: RegistrationTable(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // ค้นหาแล้วไม่เจอ → ข้อความ "ไม่พบข้อมูลที่ค้นหา"
      expect(find.text('ไม่พบข้อมูลที่ค้นหา'), findsOneWidget);
    });

    testWidgets('✅ RegistrationPagination แสดง "หน้า / หน้าสุดท้าย"',
        (tester) async {
      final vm = _vm(_buildItems(120));
      await vm.refresh();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<RegistrationViewModel>.value(
            value: vm,
            child: const SizedBox(
              width: 1200,
              child: RegistrationPagination(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 / 3'), findsOneWidget);
    });
  });
}
