# Pen Test (AI) — ส่งอนุมัติ (LicenseSubmitApprovalRequestPage) — `/submit-approval`

> **เอกสารนี้คืออะไร** — automated test scope สำหรับ menu `/submit-approval` (LicenseSubmitApprovalRequestPage — ส่งคำร้องขออนุมัติ + multi-round approval view)
>
> **Human test** → [`human.md`](./human.md)
>
> **Cross-links**:
> - Master index → [`../../README.md`](../../README.md)
> - ก่อนหน้าใน flow: [`../fact-check/`](../fact-check/) (ตรวจข้อเท็จจริง)
> - ขั้นถัดไป: [`../approve/`](../approve/) (อนุมัติ)

---

## ภาพรวม

- **Status**: ❌ **No automated tests yet** (TBD)
- **Primary folder**: `lib/ChiangMai_Municipality/License_menu/license_submit_approval_request_page/` (25 dart files)
- **API version**: v2 ✅ (v1 endpoints ยังใช้ร่วมอยู่สำหรับ legacy approval list — ดู `license_submit_approval_service.dart`)
- **Files of interest**:
  - `models/license_submit_approval_config.dart`, `models/license_submit_approval_event.dart`
  - `models/license_submit_approval_detail_model.dart`
  - `models/submit_approval_detail_extended.dart`
  - `models/submit_approval_rounds_models.dart`
  - `services/license_submit_approval_service.dart` (list v2 + fallback v1)
  - `services/license_submit_approval_detail_service.dart` (v2 approvals/rounds)
  - `viewmodels/license_submit_approval_view_model.dart`
  - `viewmodels/license_submit_approval_detail_view_model.dart`
  - `viewmodels/license_submit_approval_rounds_view_model.dart`
  - `views/license_submit_approval_page.dart`, `license_submit_approval_detail_page.dart`
  - `views/widgets/submit_approval_*.dart` (detail_step1/2, rounds_section, header/footer, table, search, pagination, zone_filter)
  - `unity/license_status_labels.dart`, `unity/zone_selection_store.dart`

---

## สิ่งที่ต้องเตรียม

- ✅ ติดตั้ง fvm + Flutter 3.38.3
- ✅ อยู่ที่ root ของโปรเจกต์
- ✅ Backend v1 + v2 ขึ้นอยู่ (submit-approval ใช้ v2 list + v2 approval steps + fallback v1)

---

## วิธีรัน (เมื่อเขียน test แล้ว)

> **ยังไม่มี test files** — section นี้จะ activate เมื่อ test ถูกเขียน

```bash
# คาดว่าจะมี test file ในอนาคต:
fvm flutter test test/license_submit_approval_models_test.dart test/license_submit_approval_view_model_test.dart
```

---

## Testable scenarios (TBD — ต้องเขียน)

### Model Factories
- [ ] `LicenseSubmitApprovalConfig` defaults + constants
- [ ] `LicenseSubmitApprovalEvent` from JSON / payload parsing (success/error snackbar events)
- [ ] `LicenseSubmitApprovalDetailModel` — detail with approval_pending flag
- [ ] `SubmitApprovalDetailExtended` — extended detail payload
- [ ] `SubmitApprovalRoundsModels` — rounds + steps + reviewers

### ViewModel CRUD
- [ ] `LicenseSubmitApprovalViewModel` — list load, pagination, search filter, sort, zone filter
- [ ] `LicenseSubmitApprovalDetailViewModel` — detail load + step1/step2 state transitions
- [ ] `LicenseSubmitApprovalRoundsViewModel` — rounds timeline state
- [ ] Submit for approval flow state transitions
- [ ] Events: success/error snackbar emissions

### Widget tests (pumpWidget + Provider)
- [ ] `LicenseSubmitApprovalPage` empty state + populated state
- [ ] `LicenseSubmitApprovalTable` row rendering + status badge
- [ ] `LicenseSubmitApprovalSearchBar` debounce + clear
- [ ] `LicenseSubmitApprovalZoneFilter` dropdown selection
- [ ] `LicenseSubmitApprovalPagination` "1 / N" indicator
- [ ] `SubmitApprovalDetailStep1` / `SubmitApprovalDetailStep2` form transitions
- [ ] `SubmitApprovalRoundsSection` — rounds timeline rendering

---

## Pattern template — ใช้เป็น guide ตอนเขียน

อ้างอิง [`../../../test/area_view_model_test.dart`](../../../test/area_view_model_test.dart):

```dart
class FakeLicenseSubmitApprovalService extends LicenseSubmitApprovalService {
  // seed methods + in-memory store
  // @override fetchList (v2), fetchDetail (v2), submitForApproval
}

LicenseSubmitApprovalViewModel _makeVM(FakeLicenseSubmitApprovalService svc) =>
    LicenseSubmitApprovalViewModel(config: ..., service: svc);

void main() {
  group('LicenseSubmitApprovalViewModel', () {
    late FakeLicenseSubmitApprovalService svc;
    late LicenseSubmitApprovalViewModel vm;

    setUp(() async {
      svc = FakeLicenseSubmitApprovalService()..seedItem(...);
      vm = _makeVM(svc);
      await Future<void>.delayed(Duration.zero);  // bootstrap
    });

    test('list load returns seeded approval requests', () {
      expect(vm.items.length, ...);
    });
    // ... more tests
  });
}
```

---

## API endpoints ที่ใช้บ่อย (อ้างอิงจาก service files)

> ตรวจสอบอีกครั้งจาก `license_submit_approval_service.dart` + `license_submit_approval_detail_service.dart`

**v2 list/detail**:
- `GET /v2/admin/requests/tasks/approvals` — list คำขออนุมัติ (มี `approval_pending` flag)
- `GET /v2/admin/approvals/{requestUuid}` — detail approval
- `GET /v2/admin/approvals/me` — approver list (me)

**v2 rounds + steps**:
- `POST /v2/admin/approvals/{requestUuid}/rounds` — create round
- `POST /v2/admin/approvals/{requestUuid}/steps/{stepUuid}/approve` — approve step
- `POST /v2/admin/approvals/{requestUuid}/steps/{stepUuid}/reject` — reject step

**v1 fallback** (legacy approval list — ใช้ในบางจุด):
- `GET /v1/admin/approvals` — fallback list (ใช้ตอน v2 endpoint ยังไม่พร้อม)

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

1. เขียน `test/license_submit_approval_models_test.dart` (model factories + JSON parsing)
2. เขียน `test/license_submit_approval_view_model_test.dart` (list/detail CRUD + events)
3. เขียน `test/license_submit_approval_rounds_view_model_test.dart` (rounds timeline)
4. รัน `fvm flutter test test/license_submit_approval_*` จน pass
5. Update `human.md` หัวข้อ Backend verification เมื่อ test stable
