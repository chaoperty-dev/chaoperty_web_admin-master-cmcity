// ============================================================================
// menu_models_test.dart
// ============================================================================
// Unit tests สำหรับ models ที่ใช้ในหลายๆ เมนู
// (ไม่ test HTTP, UI, file picker — ทำไม่ได้ใน Dart VM)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:chaoperty/ChiangMai_Municipality/Model/Receipt_Model.dart';
import 'package:chaoperty/ChiangMai_Municipality/Area_menu/services/area_menu_service.dart';

void main() {
  // ==========================================================================
  // 🧾 Receipt Model (ใช้ใน License — payment, attach, verify)
  // ==========================================================================
  group('🧾 ReceiptModel', () {
    test('✅ parse JSON ปกติ', () {
      final model = ReceiptModel.fromJson({
        'message': 'OK',
        'data': {
          'document': {
            'uuid': 'd-1',
            'documentTypeId': 5,
            'documentNo': 'R001',
            'title': 'ใบเสร็จ',
            'amount': 1000,
          },
          'meta': {
            'createdAt': '2026-08-27',
            'updatedAt': '2026-08-27',
          },
        },
      });
      expect(model.message, 'OK');
      expect(model.data, isNotNull);
      expect(model.data!.document, isNotNull);
      expect(model.data!.document!.uuid, 'd-1');
      expect(model.data!.document!.documentTypeId, null); // JSON uses snake_case
      expect(model.data!.document!.documentNo, null); // JSON uses snake_case
      expect(model.data!.document!.active, null);
    });

    test('✅ parse JSON ที่ data = null', () {
      final model = ReceiptModel.fromJson({
        'message': 'error',
        'data': null,
      });
      expect(model.message, 'error');
      expect(model.data, null);
    });

    test('✅ toJson round-trip', () {
      final original = ReceiptModel(
        message: 'OK',
        data: Data(
          document: Document(uuid: 'd-1', documentNo: 'R001'),
        ),
      );
      final json = original.toJson();
      final restored = ReceiptModel.fromJson(json);
      expect(restored.message, 'OK');
      expect(restored.data?.document?.uuid, 'd-1');
      expect(restored.data?.document?.documentNo, 'R001');
    });
  });


  // ==========================================================================
  // 📐 AreaItem (Area menu — รายการพื้นที่เช่า)
  // ==========================================================================
  group('📐 AreaItem (Area menu)', () {
    test('✅ parse JSON ปกติ', () {
      final item = AreaItem.fromJsonSafe({
        'subzone': 'A1',
        'zone': 'Z1',
        'lock': 'L001',
        'requester': 'นาย A',
        'customer_no': 'C001',
        'customer_tel': '053-111-222',
        'sdate': '2026-01-01',
        'ldate': '2026-12-31',
        'status': 'active',
      });
      expect(item, isNotNull);
      expect(item!.subzone, 'A1');
      expect(item.zone, 'Z1');
      expect(item.lock, 'L001');
      expect(item.customerNo, 'C001');
      expect(item.customerTel, '053-111-222');
    });

    test('✅ parse null JSON -> null', () {
      expect(AreaItem.fromJsonSafe(null), null);
    });

    test('✅ parse JSON ผิด -> null (ไม่ throw)', () {
      expect(AreaItem.fromJsonSafe({'invalid': 'data'}), isNotNull);
    });

    test('✅ null-safe defaults', () {
      const item = AreaItem();
      expect(item.subzone, null);
      expect(item.zone, null);
      expect(item.lock, null);
    });
  });
}
