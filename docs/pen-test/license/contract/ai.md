# Pen Test (AI) — คำขอใบอนุญาต — `/contract`

> ⚠️ **MIXED API** — เมนูนี้ผสม v2 + PHP legacy (1 area PHP + 6 billing PHPs + v2 contracts)
>
> **Human test** → [`human.md`](./human.md)
>
> **สถานะใน README หลัก** → [Mixed marker](../../README.md#สรุปสถานะ--15-menu-routes)

---

## ภาพรวม

- **Status**: ❌ **No automated tests yet** (TBD)
- **API version**: ⚠️ **Mixed** — v2 (contracts) + PHP legacy (billing)
- **PHP endpoints**: 7 live
- **Primary folder**: `lib/ChiangMai_Municipality/License_menu/license_contract_page/` (30 dart files)
- **Files of interest**:
  - `models/license_contract_config.dart`, `models/license_contract_event.dart`, `models/license_contract_result.dart`, `models/billing_models.dart`
  - `services/license_contract_service.dart`, `services/billing_service.dart`
  - `viewmodels/license_contract_view_model.dart`, `viewmodels/billing_view_model.dart`
  - `views/license_contract_page.dart`
  - `views/widgets/announcement_card.dart`, `area_info_card.dart`, `billing_table.dart`, `customer_picker_dialog.dart`, `form_contract_section.dart`, `form_person_section.dart`, `form_shop_section.dart`, `footer_actions.dart`, `header_bar.dart`, `next_step_button.dart`
  - `unity/API_announcement.dart`, `unity/API_properties.dart`, `unity/customers_report_service.dart`, `unity/registration_service.dart`, `unity/zone_selection_store.dart`

---

## สิ่งที่ต้องเตรียม

- ✅ ติดตั้ง fvm + Flutter 3.38.3
- ✅ อยู่ที่ root ของโปรเจกต์
- ✅ Backend v2 ขึ้นอยู่ (สำหรับ contracts)
- ✅ **PHP backend** ขึ้นอยู่ (สำหรับ billing — ต้องใช้จนกว่าจะ migrate)

---

## PHP endpoints ที่ต้อง migrate (BLOCKER — billing section)

> จาก Explore agent: มี 7 endpoint ที่ใช้ PHP legacy (1 area + 6 billing)

| Method | Endpoint | ใช้ทำอะไร |
|---|---|---|
| GET | `GC_areaAll.php` | โหลดรายการพื้นที่ (ใช้ใน dropdown) |
| GET | `InC_BillDetail.php` | รายละเอียดบิล |
| GET | `InC_Bill.php` | list บิลในสัญญา |
| GET | `InC_Bill_Receipt.php` | ใบเสร็จรับเงิน |
| POST | `InC_Bill_SubmitSlip.php` | อัปโหลดสลิปชำระเงิน |
| POST | `InC_Bill_DeleteSlip.php` | ลบสลิปชำระเงิน |
| GET | `HistoryBill.php` | ประวัติการเรียกเก็บ |

**Target v2 endpoint** (ยังไม่มี — ต้องขอจาก backend):
- `GET /admin/bills` — list bills in contract
- `GET /admin/bills/{id}` — bill detail
- `GET /admin/bills/{id}/receipt` — receipt PDF
- `POST /admin/bills/{id}/slip` — upload payment slip
- `DELETE /admin/bills/{id}/slip` — remove payment slip
- `GET /admin/contracts/{id}/bills/history` — billing history
- `GET /admin/areas` (replace `GC_areaAll.php`)

---

## วิธีรัน (เมื่อเขียน test แล้ว)

> **ยังไม่มี test files** — section นี้จะ activate เมื่อ test ถูกเขียน

```bash
# คาดว่าจะมี test file ในอนาคต:
fvm flutter test test/license_contract_models_test.dart test/license_contract_view_model_test.dart test/billing_view_model_test.dart
```

---

## Testable scenarios (TBD — ต้องเขียน)

### Model Factories
- [ ] `LicenseContractConfig` defaults + constants
- [ ] `LicenseContractEvent` variants (loaded / submitted / error)
- [ ] `LicenseContractResult` payload parsing
- [ ] `BillingModels` — bill, slip, receipt, history

### ViewModel CRUD
- [ ] `LicenseContractViewModel` — 3-section form state (person/shop/contract)
- [ ] `BillingViewModel` — list bills, submit slip, delete slip
- [ ] Announcement card state (load active announcement)
- [ ] Customer picker dialog state
- [ ] Events: success/error snackbar emissions
- [ ] Form validation per section

### Widget tests (pumpWidget + Provider)
- [ ] `LicenseContractPage` empty state + populated state
- [ ] `FormPersonSection` validation
- [ ] `FormShopSection` validation
- [ ] `FormContractSection` validation
- [ ] `AnnouncementCard` renders selected announcement
- [ ] `CustomerPickerDialog` search + select
- [ ] `BillingTable` row rendering
- [ ] `FooterActions` enable/disable per section validity

---

## Pattern template — ใช้เป็น guide ตอนเขียน

อ้างอิง [`../../../test/area_view_model_test.dart`](../../../test/area_view_model_test.dart):

```dart
class FakeLicenseContractService extends LicenseContractService {
  // seed methods + in-memory store
  // @override fetchAnnouncements, submitContract
}

class FakeBillingService extends BillingService {
  // seed bills + slip history
  // @override fetchBills, submitSlip, deleteSlip
}

void main() {
  group('LicenseContractViewModel', () {
    late FakeLicenseContractService svc;
    late LicenseContractViewModel vm;

    setUp(() async {
      svc = FakeLicenseContractService()..seedAnnouncement(...);
      vm = LicenseContractViewModel(service: svc);
      await Future<void>.delayed(Duration.zero);  // bootstrap
    });

    test('3-section form aggregates validity', () {
      expect(vm.canSubmit, ...);
    });
    // ... more tests
  });

  group('BillingViewModel', () {
    late FakeBillingService billingSvc;
    late BillingViewModel billingVM;

    setUp(() async {
      billingSvc = FakeBillingService()..seedBill(...);
      billingVM = BillingViewModel(service: billingSvc);
      await Future<void>.delayed(Duration.zero);
    });

    test('submit slip updates bill status', () {
      // ...
    });
  });
}
```

---

## Pre-migration checklist (billing section)

> ทำข้อนี้ก่อนเริ่ม migrate PHP billing → v2

- [ ] Verify backend v2 endpoints (7 รายการในตารางด้านบน) มีจริง + contract ตรงกับ PHP response
- [ ] ตรวจ field mapping (snake_case ↔ camelCase, missing fields, slip upload format)
- [ ] ตรวจ pagination contract (per_page, page, total) สำหรับ bill list
- [ ] ตรวจ receipt PDF contract (URL vs base64)
- [ ] อัปเดต `BillingService` ให้ใช้ `domain_v2` แทน PHP root
- [ ] ลบ import / fallback ของ `domain` (legacy PHP root)
- [ ] เขียน unit test ครอบ v2 path ก่อนลบ PHP
- [ ] Manual test ตาม [`human.md`](./human.md) section 4 (Billing) — ทุก checkbox ✅
- [ ] อัปเดต README index — flip billing สถานะเป็น v2 ✅

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

1. **Migrate PHP billing → v2** (blocker 7 endpoints) — backend endpoint + service wrapper
2. ลบ PHP endpoint ออกจาก `BillingService` + `LicenseContractService` (ส่วน area dropdown)
3. เขียน `test/license_contract_models_test.dart`
4. เขียน `test/license_contract_view_model_test.dart` (3-section form)
5. เขียน `test/billing_view_model_test.dart`
6. รัน `fvm flutter test test/license_contract_* test/billing_*` จน pass
7. Manual test ตาม `human.md` section 1-5 + 7-8
8. อัปเดต README index — flip billing สถานะเป็น v2 ✅