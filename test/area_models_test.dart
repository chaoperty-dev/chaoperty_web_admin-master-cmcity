// ============================================================================
// area_models_test.dart
// ============================================================================
// Unit tests สำหรับ AreaZoneModel + AreaAreaModel factories
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:chaoperty/ChiangMai_Municipality/Setting_menu/setting_page/area/models/area_area_model.dart';
import 'package:chaoperty/ChiangMai_Municipality/Setting_menu/setting_page/area/models/area_zone_model.dart';

void main() {
  group('AreaZoneModel', () {
    group('fromGroup()', () {
      test('สร้าง row หมวดโซนจาก JSON ครบ', () {
        final m = AreaZoneModel.fromGroup({
          'ser': '5',
          'zn': 'อาคาร A',
          'qty': '3',
          'img': '0',
          'data_update': '2026-09-01',
        });
        expect(m.ser, '5');
        expect(m.rser, '5'); // rser เท่ากับ ser (กรณี group)
        expect(m.zn, 'อาคาร A');
        expect(m.qty, '3');
        expect(m.groupSer, isNull); // group ไม่มี parent
      });

      test('default fields เมื่อ JSON ขาด field', () {
        final m = AreaZoneModel.fromGroup({'ser': '1'});
        expect(m.ser, '1');
        expect(m.zn, '');
        expect(m.qty, '0');
        expect(m.img, '0');
        expect(m.dataUpdate, '');
      });

      test('ser null → "0" fallback', () {
        final m = AreaZoneModel.fromGroup({});
        expect(m.ser, '0');
        expect(m.rser, '0');
      });
    });

    group('fromZone()', () {
      test('สร้าง row โซน — มี groupSer เป็น parent', () {
        final m = AreaZoneModel.fromZone({
          'ser': '10',
          'group_ser': '5',
          'zn': 'โซน 1',
          'qty': '1',
        });
        expect(m.ser, '10');
        expect(m.groupSer, '5'); // zone มี parent
        expect(m.rser, '5'); // rser เก็บ groupSer (compat)
        expect(m.zn, 'โซน 1');
      });

      test('group_ser หายไป → default "0"', () {
        final m = AreaZoneModel.fromZone({'ser': '10', 'zn': 'z'});
        expect(m.groupSer, '0');
      });
    });

    group('fromJson()', () {
      test('มี group_ser → ใช้ fromZone', () {
        final m = AreaZoneModel.fromJson({
          'ser': '10',
          'group_ser': '5',
          'zn': 'z',
        });
        expect(m.groupSer, '5');
      });

      test('ไม่มี group_ser → ใช้ fromGroup', () {
        final m = AreaZoneModel.fromJson({'ser': '5', 'zn': 'g'});
        expect(m.groupSer, isNull);
      });
    });

    group('isAll', () {
      test('ser=0 + zn="ทั้งหมด" → true', () {
        expect(const AreaZoneModel(ser: '0', rser: '0', zn: 'ทั้งหมด').isAll, isTrue);
      });

      test('ser!=0 → false', () {
        expect(
            const AreaZoneModel(ser: '5', rser: '5', zn: 'ทั้งหมด').isAll, isFalse);
      });

      test('zn อื่น → false', () {
        expect(const AreaZoneModel(ser: '0', rser: '0', zn: 'อื่น').isAll, isFalse);
      });
    });
  });

  group('AreaAreaModel', () {
    test('fromJson — full payload', () {
      final m = AreaAreaModel.fromJson({
        'ser': '100',
        'ln': 'LN001',
        'sn': 'S001',
        'sname': 'ตู้ล็อก 1',
        'sw': '1',
        'lncode': 'A-001',
        'area': '15.5',
        'rent': '2500',
        'rent_maket': '100',
        'zone': '5',
        'zn': 'UATV4',
        'type_id': '1',
        'type_name': 'ล็อกเสียบ',
        'rser': '0',
        'cid': 'C001',
        'cname': 'ร้าน A',
        'stype': '1',
        'quantity': '1',
      });
      expect(m.ser, '100');
      expect(m.lncode, 'A-001');
      expect(m.zone, '5');
      expect(m.zn, 'UATV4');
      expect(m.rentMaket, '100'); // snake_case alias
      expect(m.isOccupied, isTrue); // cid มีค่า
    });

    test('isOccupied — false เมื่อ cid ว่าง', () {
      const m = AreaAreaModel(ser: '1', ln: '', sn: '', sname: '', sw: '', zone: '0');
      expect(m.isOccupied, isFalse);
    });

    test('isOccupied — true เมื่อ cid เป็น whitespace (trim ยังเหลืออักขระ)', () {
      const m = AreaAreaModel(
          ser: '1', ln: '', sn: '', sname: '', sw: '', zone: '0', cid: 'x');
      expect(m.isOccupied, isTrue);
    });

    test('isOccupied — false เมื่อ cid เป็น string ว่าง', () {
      const m = AreaAreaModel(
          ser: '1', ln: '', sn: '', sname: '', sw: '', zone: '0', cid: '');
      expect(m.isOccupied, isFalse);
    });

    test('zone alias: zone_ser, zser', () {
      final m1 = AreaAreaModel.fromJson({'ser': '1', 'zone_ser': '7'});
      expect(m1.zone, '7');
      final m2 = AreaAreaModel.fromJson({'ser': '1', 'zser': '8'});
      expect(m2.zone, '8');
    });

    test('default values เมื่อ JSON ขาด field', () {
      final m = AreaAreaModel.fromJson({'ser': '1'});
      expect(m.ln, '');
      expect(m.lncode, '');
      expect(m.area, '');
      expect(m.rent, '0');
      expect(m.rentMaket, '0');
      expect(m.zone, '0');
      expect(m.zn, '');
      expect(m.quantity, '0');
    });

    test('toJson — round-trip', () {
      const original = AreaAreaModel(
        ser: '1',
        ln: 'LN001',
        sn: 'S001',
        sname: 'test',
        sw: '1',
        lncode: 'A-001',
        area: '10',
        rent: '1000',
        zone: '5',
      );
      final j = original.toJson();
      final round = AreaAreaModel.fromJson(j);
      expect(round.ser, original.ser);
      expect(round.lncode, original.lncode);
      expect(round.rent, original.rent);
      expect(round.zone, original.zone);
    });
  });
}
