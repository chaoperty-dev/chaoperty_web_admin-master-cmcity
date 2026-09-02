# Pen Test (AI) — ตรวจข้อเท็จจริง (LicenseFactCheckPage) — `/fact-check`

> **เอกสารนี้คืออะไร** — automated test scope สำหรับ menu `/fact-check` (LicenseFactCheckPage — ตรวจสอบข้อเท็จจริงภาคสนาม)
>
> **Human test** → [`human.md`](./human.md)
>
> **Cross-links**:
> - Master index → [`../../README.md`](../../README.md)
> - ก่อนหน้าใน flow: [`../verify/`](../verify/) (ตรวจเอกสาร)
> - ขั้นถัดไป: [`../submit-approval/`](../submit-approval/) (ส่งอนุมัติ)

---

## ภาพรวม

- **Status**: ❌ **No automated tests yet** (TBD)
- **Primary folder**: `lib/ChiangMai_Municipality/License_menu/license_fact_check_page/` (25 dart files)
- **API version**: v2 ✅ (v1 endpoints ยังใช้ร่วมอยู่สำหรับ approval flow — ดู `unity/API_requests_reviews.dart`)
- **Files of interest**:
  - `models/license_fact_check_config.dart`, `models/license_fact_check_event.dart`
  - `models/fact_check_item.dart`
  - `services/license_fact_check_service.dart` (list v2 + inspection v1)
  - `viewmodels/license_fact_check_view_model.dart`, `license_fact_check_detail_view_model.dart`
  - `views/license_fact_check_page.dart`, `license_fact_check_detail_page.dart`
  - `views/widgets/fact_check_detail_step1.dart`, `fact_check_detail_step2.dart`
  - `views/widgets/license_fact_check_*.dart` (table, header, search, pagination, zone_filter, detail_header/footer)
  - `unity/API_requests_reviews.dart`, `unity/API_approvals_lastaction.dart`
  - `unity/FormatPhone.dart`, `unity/EncryptText.dart`

---

## สิ่งที่ต้องเตรียม

- ✅ ติดตั้ง fvm + Flutter 3.38.3
- ✅ อยู่ที่ root ของโปรเจกต์
- ✅ Backend v1 + v2 ขึ้นอยู่ (fact-check ใช้ v2 list + v1 inspection)

---

## วิธีรัน (เมื่อเขียน test แล้ว)

> **ยังไม่มี test files** — section นี้จะ activate เมื่อ test ถูกเขียน

```bash
# คาดว่าจะมี test file ในอนาคต:
fvm flutter test test/license_fact_check_models_test.dart test/license_fact_check_view_model_test.dart
```

---

## Testable scenarios (TBD — ต้องเขียน)

### Model Factories
- [ ] `LicenseFactCheckConfig` defaults + constants
- [ ] `LicenseFactCheckEvent` from JSON / payload parsing (success/error snackbar events)
- [ ] `FactCheckItem` — field inspection data (location, time, inspector, findings)

### ViewModel CRUD
- [ ] `LicenseFactCheckViewModel` — list load, pagination, search filter, sort, zone filter
- [ ] `LicenseFactCheckDetailViewModel` — detail load + step1/step2 state transitions
- [ ] Events: success/error snackbar emissions
- [ ] Inspection submit (POST inspection) state transitions

### Widget tests (pumpWidget + Provider)
- [ ] `LicenseFactCheckPage` empty state + populated state
- [ ] `LicenseFactCheckTable` row rendering + status badge
- [ ] `LicenseFactCheckSearchBar` debounce + clear
- [ ] `LicenseFactCheckZoneFilter` dropdown selection
- [ ] `LicenseFactCheckPagination` "1 / N" indicator
- [ ] `FactCheckDetailStep1` (field inspection form)
- [ ] `FactCheckDetailStep2` (verify result)

---

## Pattern template — ใช้เป็น guide ตอนเขียน

อ้างอิง [`../../../test/area_view_model_test.dart`](../../../test/area_view_model_test.dart):

```dart
class FakeLicenseFactCheckService extends LicenseFactCheckService {
  // seed methods + in-memory store
  // @override fetchList (v2), fetchInspection (v1), submitInspection
}

LicenseFactCheckViewModel _makeVM(FakeLicenseFactCheckService svc) =>
    LicenseFactCheckViewModel(config: ..., service: svc);

void main() {
  group('LicenseFactCheckViewModel', () {
    late FakeLicenseFactCheckService svc;
    late LicenseFactCheckViewModel vm;

    setUp(() async {
      svc = FakeLicenseFactCheckService()..seedItem(...);
      vm = _makeVM(svc);
      await Future<void>.delayed(Duration.zero);  // bootstrap
    });

    test('list load returns seeded inspections', () {
      expect(vm.items.length, ...);
    });
    // ... more tests
  });
}
```

---

## API endpoints ที่ใช้บ่อย (อ้างอิงจาก service files)

> ตรวจสอบอีกครั้งจาก `license_fact_check_service.dart` + `unity/API_requests_reviews.dart`

**v2 list**:
- `GET /v2/admin/requests/tasks/inspections` — list งานตรวจข้อเท็จจริง

**v1 inspection** (POST/GET inspection data):
- `POST /admin/requests/{requestUuid}/inspection` — submit inspection
- `GET /admin/requests/{requestUuid}/inspection` — load inspection

**v1 approval flow** (ใช้ใน `unity/API_requests_reviews*.dart`):
- `GET /admin/approvals` — list approvals
- `POST /admin/approvals/{requestUuid}/review` — submit review
- `GET /admin/approvals/lastaction` — last action history

---

## เกณฑ์ Pass / Fail (เมื่อมี test)

### Pass
- ✅ exit code `0`
- ✅ output ลงท้ายด้วย `All tests passed!`
- ✅ ทุก test pass (ไม่มี failed/skipped)

### Fail
- ❌ exit code != `0`
- ❌ มี test fail/skipped

**ถ้า AI Test fail → ห้าม merge — fix ก่อน**

---

## ลำดับการทำงาน

1. เขียน `test/license_fact_check_models_test.dart` (model factories + JSON parsing)
2. เขียน `test/license_fact_check_view_model_test.dart` (list/detail CRUD + events)
3. รัน `fvm flutter test test/license_fact_check_*` จน pass
4. Update `human.md` หัวข้อ Backend verification เมื่อ test stable
