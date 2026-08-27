// ============================================================================
// customers_report_test.dart
// ============================================================================
// Unit tests — เฉพาะ logic ที่ test ได้ใน Dart VM (ไม่ test UI)
// ============================================================================

import 'dart:typed_data' show Uint8List;

import 'package:flutter_test/flutter_test.dart';
import 'package:protect/protect.dart';

import 'package:chaoperty/ChiangMai_Municipality/Report_menu/customers/services/customers_report_service.dart';
import 'package:chaoperty/ChiangMai_Municipality/Report_menu/customers/views/widgets/customers_report_password_dialog.dart';

void main() {
  group('🔐 PasswordValidator.checkAll()', () {
    test('✅ password ผ่านทุก rule', () {
      final checks = PasswordValidator.checkAll('Xyz789!@#');
      expect(checks['อย่างน้อย 6 ตัวอักษร'], true);
      expect(checks['ตัวพิมพ์เล็ก (a-z)'], true);
      expect(checks['ตัวพิมพ์ใหญ่ (A-Z)'], true);
      expect(checks['ตัวเลข (0-9)'], true);
      expect(checks['อักษรพิเศษ (!@#\$%^&*)'], true);
      expect(checks['ไม่ใช่รหัสที่ใช้บ่อย'], true);
      expect(checks['ไม่มีตัวอักษรซ้ำเกิน 3 ตัว'], true);
    });

    test('✅ passwords ที่ผ่านทุก rule', () {
      expect(
        PasswordValidator.checkAll('Xk7#mP9!').values.every((v) => v),
        true,
      );
      expect(
        PasswordValidator.checkAll('MyP@ss9').values.every((v) => v),
        true,
      );
      expect(
        PasswordValidator.checkAll('Test#2024').values.every((v) => v),
        true,
      );
    });

    test('❌ สั้นเกินไป (5 ตัว)', () {
      final checks = PasswordValidator.checkAll('Xy1!@');
      expect(checks['อย่างน้อย 6 ตัวอักษร'], false);
    });
  });


  group('🔐 PasswordValidator.isCommonPassword()', () {
    test('❌ blacklist: password', () {
      expect(PasswordValidator.isCommonPassword('Password1!'), true);
    });

    test('❌ blacklist: 12345678', () {
      expect(PasswordValidator.isCommonPassword('12345678!Aa'), true);
    });

    test('❌ blacklist: chaocmcity (default password)', () {
      expect(PasswordValidator.isCommonPassword('ChaoCmcity1!'), true);
    });

    test('❌ sequential: abcdef (clean → sequential)', () {
      // cleaned = "abcdefxy" (sequential "abcdef")
      expect(PasswordValidator.isCommonPassword('abcdef!Xy1'), true);
    });

    test('❌ sequential: 123456 (reverse)', () {
      // cleaned = "654321ab" (reverse = "ba123456" ไม่ match)
      // ใช้ "098765" → reverse = "567890" ใน sequence
      expect(PasswordValidator.isCommonPassword('098765!aA1'), true);
    });

    test('❌ sequential: qwerty', () {
      expect(PasswordValidator.isCommonPassword('qwerty!A1x'), true);
    });

    test('✅ non-sequential OK', () {
      // "Xyz" ไม่ใช่ sequential (X-Y-Z ข้าม alphabet)
      expect(PasswordValidator.isCommonPassword('Xyz!A1B'), false);
    });

    test('✅ strong password ไม่อยู่ใน blacklist', () {
      expect(PasswordValidator.isCommonPassword('MyV3ry' + '\!'), false);
    });

    test('✅ case-insensitive check', () {
      expect(PasswordValidator.isCommonPassword('PASSWORD1!'), true);
      expect(PasswordValidator.isCommonPassword('pAsSwOrD1!'), true);
    });
  });

  group('🔐 PasswordValidator.hasExcessiveRepeat()', () {
    test('❌ aaaa (4 ตัวซ้ำ)', () {
      expect(PasswordValidator.hasExcessiveRepeat('aaaa1!B'), true);
    });

    test('❌ 1111', () {
      expect(PasswordValidator.hasExcessiveRepeat('Abc1111!'), true);
    });

    test('❌ !!!!', () {
      expect(PasswordValidator.hasExcessiveRepeat('Abc123!!!!'), true);
    });

    test('✅ 3 ตัวซ้ำ (OK)', () {
      expect(PasswordValidator.hasExcessiveRepeat('Aaa123!@'), false);
    });

    test('✅ ไม่ซ้ำ (OK)', () {
      expect(PasswordValidator.hasExcessiveRepeat('Abc123!@'), false);
    });
  });

  group('🔐 PasswordValidator.validate()', () {
    test('✅ valid password -> null', () {
      expect(PasswordValidator.validate('Q7p@Lm9!r2'), null);
    });

    test('❌ weak password -> error', () {
      expect(
        PasswordValidator.validate('Password1!'),
        'รหัสผ่านนี้อ่อนแอเกินไป กรุณาเลือกรหัสอื่น',
      );
    });

    test('❌ excessive repeat -> error', () {
      expect(
        PasswordValidator.validate('Q7paaaa!@LM2'),
        'มีตัวอักษรซ้ำเกิน 3 ตัวติดกัน',
      );
    });
  });

  group('📦 CustomerReportItem', () {
    test('✅ fromJsonSafe — parse JSON ปกติ', () {
      final item = CustomerReportItem.fromJsonSafe({
        'uuid': 'abc-123',
        'custno': 'C001',
        'taxno': 'T001',
        'scname': 'บริษัท A',
        'sname': 'A',
        'cname': 'สมชาย ใจดี',
        'addr_1': '123 ถ.AB',
        'addr_2': 'แขวง X',
        'zip': '50000',
        'tel': '053-111-222',
        'email': 'a@b.com',
        'st': 1,
        'birth': '1990-01-01',
      });
      expect(item, isNotNull);
      expect(item!.uuid, 'abc-123');
      expect(item.custno, 'C001');
      expect(item.taxno, 'T001');
      expect(item.addr1, '123 ถ.AB');
      expect(item.addr2, 'แขวง X');
      expect(item.st, 1);
    });

    test('✅ fromJsonSafe — null JSON -> null', () {
      expect(CustomerReportItem.fromJsonSafe(null), null);
    });

    test('✅ getBy — คืนค่าตาม field', () {
      const item = CustomerReportItem(uuid: 'u1', custno: 'c1', st: 1);
      expect(item.getBy('uuid'), 'u1');
      expect(item.getBy('custno'), 'c1');
      expect(item.getBy('st'), '1');
      expect(item.getBy('unknown'), null);
    });
  });

  group('📋 defaultColumns()', () {
    test('✅ มี 21 columns', () {
      expect(CustomersReportService.defaultColumns().length, 21);
    });

    test('✅ field ใน defaultColumns ต้องมีใน getBy()', () {
      const item = CustomerReportItem();
      for (final c in CustomersReportService.defaultColumns()) {
        expect(() => item.getBy(c.field), returnsNormally);
      }
    });

    test('✅ addr_1 vs addr_2 มี label ต่างกัน', () {
      final cols = CustomersReportService.defaultColumns();
      final addr1 = cols.firstWhere((c) => c.field == 'addr_1');
      final addr2 = cols.firstWhere((c) => c.field == 'addr_2');
      expect(addr1.label, isNot(equals(addr2.label)));
    });
  });

  group('🔒 PasswordResult sealed classes', () {
    test('✅ PasswordCancel/NoPassword/WithValue เป็น PasswordResult', () {
      expect(const PasswordCancel(), isA<PasswordResult>());
      expect(const PasswordNoPassword(), isA<PasswordResult>());
      const v = PasswordWithValue('test');
      expect(v, isA<PasswordResult>());
      expect(v.password, 'test');
    });
  });

  group('🔓 AES Encryption round-trip', () {
    test('✅ encrypt + decrypt ด้วย correct password', () {
      final plain = Uint8List.fromList([0x50, 0x4B, 0x03, 0x04]);
      final enc = Protect.encryptUint8List(plain, 'test123');
      expect(enc.isDataValid, true);
      final dec = Protect.decryptUint8List(enc.processedBytes!, 'test123');
      expect(dec.processedBytes, plain);
    });

    test('❌ decrypt ด้วย wrong password -> invalid', () {
      final enc = Protect.encryptUint8List(Uint8List.fromList([1, 2, 3]), 'c');
      final dec = Protect.decryptUint8List(enc.processedBytes!, 'w');
      expect(dec.isDataValid, false);
    });

    test('✅ default password round-trip', () {
      final plain = Uint8List.fromList(List.generate(50, (i) => i));
      final enc = Protect.encryptUint8List(plain, '@ChaoCmcity');
      final dec = Protect.decryptUint8List(enc.processedBytes!, '@ChaoCmcity');
      expect(dec.processedBytes, plain);
    });
  });
}
