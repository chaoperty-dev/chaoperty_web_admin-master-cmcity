# Pen Test (AI) — ตรวจเอกสารคำขอ (LicenseVerifyPage) — `/verify`

> **เอกสารนี้คืออะไร** — automated test scope สำหรับ menu `/verify` (LicenseVerifyPage — ตรวจสอบเอกสารคำขอใบอนุญาต พร้อม signature pad)
>
> **Human test** → [`human.md`](./human.md)
>
> **Cross-links**:
> - Master index → [`../../README.md`](../../README.md)
> - ก่อนหน้าใน flow: [`../attach/`](../attach/) (แนบเอกสาร)
> - ขั้นถัดไป: [`../fact-check/`](../fact-check/) (ตรวจข้อเท็จจริง)

---

## ภาพรวม

- **Status**: ❌ **No automated tests yet** (TBD)
- **Primary folder**: `lib/ChiangMai_Municipality/License_menu/license_verify_page/` (35 dart files)
- **API version**: v2 ✅ (v1 endpoints ยังใช้ร่วมอยู่สำหรับ legacy approval flow — ดู `unity/API_requests_reviews.dart`)
- **Files of interest**:
  - `models/license_verify_config.dart`, `models/license_verify_event.dart`
  - `models/license_verify_checklist_model.dart`, `models/license_verify_document.dart`
  - `models/license_verify_result.dart`, `models/verify_attachment_item.dart`
  - `models/verify_task_model.dart`
  - `services/license_verify_service.dart` (list + tasks)
  - `services/license_verify_checklist_service.dart` (checklist preview/submit)
  - `services/verify_documents_service.dart` (attachments preview/CRUD)
  - `services/verify_signature_service.dart` (ลายเซ็น reviewer)
  - `viewmodels/license_verify_view_model.dart`, `license_verify_detail_view_model.dart`
  - `viewmodels/verify_documents_view_model.dart`, `verify_signature_view_model.dart`
  - `views/license_verify_page.dart`, `license_verify_detail_page.dart`
  - `views/widgets/verify_*.dart` (14 widget files — table, header, search, pagination, zone_filter, detail_step1/2, signature_section, file_preview_dialog)
  - `unity/API_requests_reviews.dart`, `unity/API_requests_reviewsflow.dart`, `unity/API_approvals_lastaction.dart`

---

## สิ่งที่ต้องเตรียม

- ✅ ติดตั้ง fvm + Flutter 3.38.3
- ✅ อยู่ที่ root ของโปรเจกต์
- ✅ Backend v1 + v2 ขึ้นอยู่ (verify ใช้ v2 list + v1 approval flow)

---

## วิธีรัน (เมื่อเขียน test แล้ว)

> **ยังไม่มี test files** — section นี้จะ activate เมื่อ test ถูกเขียน

```bash
# คาดว่าจะมี test file ในอนาคต:
fvm flutter test test/license_verify_models_test.dart test/license_verify_view_model_test.dart
```

---

## Testable scenarios (TBD — ต้องเขียน)

### Model Factories
- [ ] `LicenseVerifyConfig` defaults + constants (perPage, zone options)
- [ ] `LicenseVerifyEvent` from JSON / payload parsing (success/error snackbar events)
- [ ] `LicenseVerifyChecklistModel` — checklist item with pass/fail/N-A status
- [ ] `LicenseVerifyDocument` — uploaded document model
- [ ] `LicenseVerifyResult` — final verify result enum
- [ ] `VerifyTaskModel` — task ที่ต้องตรวจ
- [ ] `VerifyAttachmentItem` — attachment metadata

### ViewModel CRUD
- [ ] `LicenseVerifyViewModel` — list load, pagination, search filter, sort, zone filter
- [ ] `LicenseVerifyDetailViewModel` — detail load + step1/step2 state transitions
- [ ] `VerifyDocumentsViewModel` — attachment CRUD + preview
- [ ] `VerifySignatureViewModel` — signature pad state + upload
- [ ] Events: success/error snackbar emissions

### Widget tests (pumpWidget + Provider)
- [ ] `LicenseVerifyPage` empty state + populated state
- [ ] `VerifyTable` row rendering + checklist badge
- [ ] `VerifySearchBar` debounce + clear
- [ ] `VerifyZoneFilter` dropdown selection
- [ ] `VerifyPagination` "1 / N" indicator
- [ ] `VerifyDetailStep1` / `VerifyDetailStep2` form transitions
- [ ] `VerifySignatureSection` — pad drawing → base64
- [ ] `VerifyFilePreviewDialog` — open attachment

---

## Pattern template — ใช้เป็น guide ตอนเขียน

อ้างอิง [`../../../test/area_view_model_test.dart`](../../../test/area_view_model_test.dart):

```dart
class FakeLicenseVerifyService extends LicenseVerifyService {
  // seed methods + in-memory store
  // @override fetchList, fetchDetail, fetchChecklist, submitChecklist
}

LicenseVerifyViewModel _makeVM(FakeLicenseVerifyService svc) =>
    LicenseVerifyViewModel(config: ..., service: svc);

void main() {
  group('LicenseVerifyViewModel', () {
    late FakeLicenseVerifyService svc;
    late LicenseVerifyViewModel vm;

    setUp(() async {
      svc = FakeLicenseVerifyService()..seedItem(...);
      vm = _makeVM(svc);
      await Future<void>.delayed(Duration.zero);  // bootstrap
    });

    test('list load returns seeded verify tasks', () {
      expect(vm.items.length, ...);
    });
    // ... more tests
  });
}
```

---

## API endpoints ที่ใช้บ่อย (อ้างอิงจาก service files)

> ตรวจสอบอีกครั้งจาก `license_verify_service.dart` + `license_verify_checklist_service.dart` + `verify_documents_service.dart`

**v2 list/tasks**:
- `GET /v2/admin/requests/tasks/inspections` — list งานตรวจเอกสาร
- `GET /v2/admin/requests/tasks/attachments` — list attachments

**v1 approval flow** (ใช้ใน `unity/API_requests_reviews*.dart`):
- `GET /admin/approvals` — list approvals
- `GET /admin/approvals/{requestUuid}/flow` — flow uuid list
- `POST /admin/approvals/{requestUuid}/review` — submit review
- `POST /admin/approvals/{requestUuid}/flow/{flowUuid}/approve` — approve flow

**v1 request/checklist**:
- `GET /admin/requests/{uuid}` — request detail
- `GET /admin/requests/{uuid}/checklist` — saved checklist
- `GET /admin/requests/{uuid}/checklist/preview` — checklist preview
- `POST /admin/requests/{uuid}/checklist` — submit checklist
- `GET /admin/requests/{requestUuid}/attachments` — attachments list
- `GET /admin/requests/attachments/{attachmentUuid}/preview` — preview attachment

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

1. เขียน `test/license_verify_models_test.dart` (model factories + JSON parsing)
2. เขียน `test/license_verify_view_model_test.dart` (list/detail/checklist CRUD + events)
3. เขียน `test/license_verify_signature_view_model_test.dart` (signature pad)
4. รัน `fvm flutter test test/license_verify_*` จน pass
5. Update `human.md` หัวข้อ Backend verification เมื่อ test stable
