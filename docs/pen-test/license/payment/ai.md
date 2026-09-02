# Pen Test (AI) — ชำระค่าธรรมเนียม — `/payment`

> ⚠️ **MIGRATION PENDING** — เมนูนี้ยังใช้ **PHP legacy** อยู่ทั้งหมด (12 endpoints) — ต้อง migrate เป็น v2 ก่อน release
>
> **Human test** → [`human.md`](./human.md)
>
> **สถานะใน README หลัก** → [PHP marker](../../README.md#สรุปสถานะ--15-menu-routes)

---

## ภาพรวม

- **Status**: ❌ **No automated tests yet** (TBD)
- **API version**: ⚠️ **PHP** (ทั้งหมด 12 endpoints)
- **PHP endpoints**: 12 live (`InC_license_payment_*.php`)
- **Primary folder**: `lib/ChiangMai_Municipality/License_menu/license_payment_page/` (28 dart files)
- **Files of interest**:
  - `models/license_payment_config.dart`, `models/license_payment_event.dart`, `models/license_payment_detail_model.dart`, `models/license_payment_attachment.dart`, `models/license_payment_method.dart`, `models/license_prepayment_model.dart`, `models/payment_task_model.dart`
  - `services/license_payment_service.dart`, `services/license_payment_detail_service.dart`
  - `viewmodels/license_payment_view_model.dart`, `viewmodels/license_payment_detail_view_model.dart`
  - `views/license_payment_page.dart`, `views/license_payment_detail_page.dart`
  - `views/widgets/license_payment_*.dart`, `payment_detail_*.dart`, `payment_history_view.dart`
  - `unity/license_status_labels.dart`, `unity/zone_selection_store.dart`

---

## สิ่งที่ต้องเตรียม

- ✅ ติดตั้ง fvm + Flutter 3.38.3
- ✅ อยู่ที่ root ของโปรเจกต์
- ✅ **PHP backend** ขึ้นอยู่ (ยังต้องใช้จนกว่าจะ migrate)

---

## PHP endpoints ที่ต้อง migrate (BLOCKER)

> จาก Explore agent: มี 12 endpoint ใน `license_payment_service.dart` ที่ใช้ PHP legacy

| # | Method | Endpoint (placeholder) | ใช้ทำอะไร |
|---|---|---|---|
| 1 | GET/POST | `InC_license_payment_list.php` | list รายการชำระเงิน |
| 2 | GET | `InC_license_payment_detail.php` | detail รายการ |
| 3 | POST | `InC_license_payment_submit_slip.php` | อัปโหลดสลิป |
| 4 | POST | `InC_license_payment_delete_slip.php` | ลบสลิป |
| 5 | GET | `InC_license_payment_receipt.php` | ใบเสร็จรับเงิน |
| 6 | GET | `InC_license_payment_history.php` | ประวัติการชำระ |
| 7 | GET | `InC_license_payment_prepayment.php` | prepayments list |
| 8 | POST | `InC_license_payment_prepayment_add.php` | เพิ่ม prepayment |
| 9 | POST | `InC_license_payment_prepayment_delete.php` | ลบ prepayment |
| 10 | GET | `InC_license_payment_methods.php` | วิธีการชำระ (dropdown) |
| 11 | POST | `InC_license_payment_confirm.php` | ยืนยันการรับเงิน (admin) |
| 12 | GET | `InC_license_payment_stepper.php` | state stepper (current step) |

> **Note**: path ด้านบนเป็น placeholder ตาม convention — ตรวจสอบจาก `license_payment_service.dart` อีกครั้งเพื่อยืนยัน path จริง

**Target v2 endpoints** (ยังไม่มี — ต้องขอจาก backend):
- `GET /admin/payments` — list
- `GET /admin/payments/{id}` — detail
- `POST /admin/payments/{id}/slip` — upload slip
- `DELETE /admin/payments/{id}/slip` — delete slip
- `GET /admin/payments/{id}/receipt` — receipt
- `GET /admin/payments/{id}/history` — history
- `GET /admin/payments/{id}/prepayments` — prepayments
- `POST /admin/payments/{id}/prepayments` — add prepayment
- `DELETE /admin/payments/{id}/prepayments/{prepayId}` — delete prepayment
- `GET /admin/payments/methods` — methods dropdown
- `POST /admin/payments/{id}/confirm` — confirm payment
- `GET /admin/payments/{id}/stepper` — state stepper

---

## วิธีรัน (เมื่อเขียน test แล้ว)

> **ยังไม่มี test files** — section นี้จะ activate เมื่อ test ถูกเขียน

```bash
# คาดว่าจะมี test file ในอนาคต:
fvm flutter test test/license_payment_models_test.dart test/license_payment_view_model_test.dart test/license_payment_detail_view_model_test.dart
```

---

## Testable scenarios (TBD — ต้องเขียน)

### Model Factories
- [ ] `LicensePaymentConfig` defaults + constants
- [ ] `LicensePaymentEvent` variants (loaded / submitted / confirmed / error)
- [ ] `LicensePaymentDetailModel` from JSON
- [ ] `LicensePaymentAttachment` (slip metadata)
- [ ] `LicensePaymentMethod` enum + JSON
- [ ] `LicensePrepaymentModel` from JSON
- [ ] `PaymentTaskModel` — task state per item

### ViewModel CRUD
- [ ] `LicensePaymentViewModel` — list load, pagination, search filter, zone filter
- [ ] `LicensePaymentDetailViewModel` — detail load + stepper state
- [ ] Prepayments add/delete state transitions
- [ ] Confirm payment state (admin)
- [ ] Events: success/error snackbar emissions

### Widget tests (pumpWidget + Provider)
- [ ] `LicensePaymentPage` empty state + populated state
- [ ] `LicensePaymentTable` row rendering
- [ ] `LicensePaymentPagination` "1 / N" indicator
- [ ] `LicensePaymentSearchBar` debounce + clear
- [ ] `LicensePaymentZoneFilter` dropdown change → list refresh
- [ ] Detail page stepper (payment steps indicator)
- [ ] `PaymentDetailStep1` (slip upload)
- [ ] `PaymentDetailStep2` (review + confirm)
- [ ] `PaymentHistoryView` (history list)
- [ ] Prepayments widget

---

## Pattern template — ใช้เป็น guide ตอนเขียน

อ้างอิง [`../../../test/area_view_model_test.dart`](../../../test/area_view_model_test.dart):

```dart
class FakeLicensePaymentService extends LicensePaymentService {
  // seed methods + in-memory store
  // @override fetchList, fetchDetail, submitSlip, deleteSlip, confirm
}

class FakeLicensePaymentDetailService extends LicensePaymentDetailService {
  // seed detail + stepper + prepayments + history
}

void main() {
  group('LicensePaymentViewModel', () {
    late FakeLicensePaymentService svc;
    late LicensePaymentViewModel vm;

    setUp(() async {
      svc = FakeLicensePaymentService()..seedItem(...);
      vm = LicensePaymentViewModel(service: svc);
      await Future<void>.delayed(Duration.zero);  // bootstrap
    });

    test('list load returns seeded payments', () {
      expect(vm.items.length, ...);
    });
    // ... more tests
  });

  group('LicensePaymentDetailViewModel', () {
    late FakeLicensePaymentDetailService detailSvc;
    late LicensePaymentDetailViewModel detailVM;

    setUp(() async {
      detailSvc = FakeLicensePaymentDetailService()..seedDetail(...);
      detailVM = LicensePaymentDetailViewModel(service: detailSvc);
      await Future<void>.delayed(Duration.zero);
    });

    test('submit slip moves stepper forward', () {
      // ...
    });
  });
}
```

---

## Pre-migration checklist

> ทำข้อนี้ก่อนเริ่ม migrate PHP → v2

- [ ] Verify backend v2 endpoints (12 รายการในตารางด้านบน) มีจริง + contract ตรงกับ PHP response
- [ ] ตรวจ field mapping (snake_case ↔ camelCase, missing fields, slip upload format)
- [ ] ตรวจ pagination contract (per_page, page, total)
- [ ] ตรวจ search/filter contract (q, zone_ser, etc.)
- [ ] ตรวจ stepper state contract (current_step, total_steps, next_action)
- [ ] ตรวจ prepayment contract (amount, method, date, status)
- [ ] ตรวจ receipt contract (URL vs base64)
- [ ] อัปเดต `LicensePaymentService` + `LicensePaymentDetailService` ให้ใช้ `domain_v2`
- [ ] ลบ import / fallback ของ `domain` (legacy PHP root)
- [ ] เขียน unit test ครอบ v2 path ก่อนลบ PHP
- [ ] Manual test ตาม [`human.md`](./human.md) section 4 → 5 (ทุก checkbox ✅)
- [ ] อัปเดต README index — flip สถานะเป็น v2 ✅

---

## เกณฑ์ Pass / Fail (เมื่อมี test)

### Pass
- ✅ exit code `0`
- ✅ output ลงท้ายด้วย `All tests passed!`
- ✅ ทุก test pass

### Fail
- ❌ exit code != `0`
- ❌ มี test fail/skipped

**ถ้า AI Test fail → ห้าม merge — fix ก่อน**

---

## ลำดับการทำงาน

1. **Migrate PHP → v2** (blocker 12 endpoints) — backend endpoint + service wrapper
2. ลบ PHP endpoint ออกจาก `LicensePaymentService` + `LicensePaymentDetailService`
3. เขียน `test/license_payment_models_test.dart`
4. เขียน `test/license_payment_view_model_test.dart`
5. เขียน `test/license_payment_detail_view_model_test.dart`
6. รัน `fvm flutter test test/license_payment_*` จน pass
7. Manual test ตาม `human.md` section 1-6
8. อัปเดต README index — flip สถานะเป็น v2 ✅