# Pen Test (AI) — แนบเอกสารคำขอ — `/attach`

> ✅ **v2 API** — เมนูนี้ใช้ v2 ทั้งหมด
>
> **Human test** → [`human.md`](./human.md)
>
> **สถานะใน README หลัก** → [v2 marker](../../README.md#สรุปสถานะ--15-menu-routes)

---

## ภาพรวม

- **Status**: ❌ **No automated tests yet** (TBD)
- **API version**: v2 ✅
- **Primary folder**: `lib/ChiangMai_Municipality/License_menu/license_attach_page/` (45 dart files)
- **Files of interest**:
  - `models/license_attach_config.dart`, `models/license_attach_event.dart`, `models/license_attach_document.dart`, `models/license_attach_checklist_model.dart`, `models/license_attach_result.dart`, `models/attach_request_item.dart`, `models/attach_task_model.dart`
  - `services/license_attach_service.dart`, `services/license_attach_checklist_service.dart`, `services/attach_documents_service.dart`, `services/attach_signature_service.dart`
  - `viewmodels/license_attach_view_model.dart`, `viewmodels/license_attach_detail_view_model.dart`, `viewmodels/attach_documents_view_model.dart`, `viewmodels/attach_signature_view_model.dart`
  - `views/license_attach_page.dart`, `views/license_attach_detail_page.dart`
  - `views/widgets/attach_batch_upload_sheet.dart`, `attach_file_preview_dialog.dart`, `attach_signature_section.dart`, `attach_detail_*.dart`, `license_attach_*.dart`
  - `utils/attachment_utils.dart`
  - `unity/API_approvals_lastaction.dart`, `unity/API_requests_reviews.dart`, `unity/EncryptText.dart`, `unity/SecurePrefs_helper.dart`, `unity/zone_selection_store.dart`

---

## สิ่งที่ต้องเตรียม

- ✅ ติดตั้ง fvm + Flutter 3.38.3
- ✅ อยู่ที่ root ของโปรเจกต์
- ✅ Backend v2 ขึ้นอยู่

---

## วิธีรัน (เมื่อเขียน test แล้ว)

> **ยังไม่มี test files** — section นี้จะ activate เมื่อ test ถูกเขียน

```bash
# คาดว่าจะมี test file ในอนาคต:
fvm flutter test test/license_attach_models_test.dart test/license_attach_view_model_test.dart test/attach_documents_view_model_test.dart test/attach_signature_view_model_test.dart
```

---

## Testable scenarios (TBD — ต้องเขียน)

### Model Factories
- [ ] `LicenseAttachDocument` from JSON / payload parsing
- [ ] `LicenseAttachChecklistModel` — checklist item state
- [ ] `LicenseAttachResult` upload result
- [ ] `AttachRequestItem` / `AttachTaskModel` — request metadata
- [ ] `LicenseAttachConfig` defaults + constants
- [ ] `LicenseAttachEvent` variants (loaded / uploaded / signed / error)

### ViewModel CRUD
- [ ] `LicenseAttachViewModel` — list load, pagination, search filter
- [ ] `LicenseAttachDetailViewModel` — detail load + multi-step state (step1/step2)
- [ ] `AttachDocumentsViewModel` — upload, delete, batch upload state
- [ ] `AttachSignatureViewModel` — signature pad state, submit
- [ ] Checklist progress tracking (per-item)
- [ ] Events: success/error snackbar emissions

### Widget tests (pumpWidget + Provider)
- [ ] `LicenseAttachPage` empty state + populated state
- [ ] `LicenseAttachTable` row rendering
- [ ] `LicenseAttachPagination` "1 / N" indicator
- [ ] `LicenseAttachSearchBar` debounce + clear
- [ ] Detail page step1/step2 navigation
- [ ] `AttachBatchUploadSheet` multi-file picker
- [ ] `AttachSignatureSection` signature pad capture
- [ ] `AttachFilePreviewDialog` image/PDF preview
- [ ] Checklist progress UI

---

## Pattern template — ใช้เป็น guide ตอนเขียน

อ้างอิง [`../../../test/area_view_model_test.dart`](../../../test/area_view_model_test.dart):

```dart
class FakeLicenseAttachService extends LicenseAttachService {
  // seed methods + in-memory store
  // @override fetchList, fetchDetail, uploadDocument, batchUpload, sign, submit
}

class FakeAttachDocumentsService extends AttachDocumentsService {
  // seed documents + batch store
  // @override fetchDocuments, upload, delete, batchUpload
}

class FakeAttachSignatureService extends AttachSignatureService {
  // seed signatures
  // @override submitSignature
}

void main() {
  group('LicenseAttachViewModel', () {
    late FakeLicenseAttachService svc;
    late LicenseAttachViewModel vm;

    setUp(() async {
      svc = FakeLicenseAttachService()..seedItem(...);
      vm = LicenseAttachViewModel(service: svc);
      await Future<void>.delayed(Duration.zero);  // bootstrap
    });

    test('list load returns seeded attach items', () {
      expect(vm.items.length, ...);
    });
    // ... more tests
  });

  group('AttachDocumentsViewModel', () {
    late FakeAttachDocumentsService docSvc;
    late AttachDocumentsViewModel docVM;

    setUp(() async {
      docSvc = FakeAttachDocumentsService()..seedDocument(...);
      docVM = AttachDocumentsViewModel(service: docSvc);
      await Future<void>.delayed(Duration.zero);
    });

    test('batch upload appends documents', () {
      // ...
    });
  });

  group('AttachSignatureViewModel', () {
    late FakeAttachSignatureService sigSvc;
    late AttachSignatureViewModel sigVM;

    setUp(() async {
      sigSvc = FakeAttachSignatureService();
      sigVM = AttachSignatureViewModel(service: sigSvc);
      await Future<void>.delayed(Duration.zero);
    });

    test('submit signature emits success event', () async {
      // ...
    });
  });
}
```

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

1. เขียน `test/license_attach_models_test.dart` (model factories)
2. เขียน `test/license_attach_view_model_test.dart` (CRUD + events)
3. เขียน `test/attach_documents_view_model_test.dart` (upload + batch)
4. เขียน `test/attach_signature_view_model_test.dart` (signature submit)
5. รัน `fvm flutter test test/license_attach_* test/attach_*` จน pass
6. Manual test ตาม [`human.md`](./human.md) section 1-7
7. Update `human.md` หัวข้อ Backend verification เมื่อ test stable