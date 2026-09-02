# Pen Test (AI) — อนุมัติคำร้อง (LicenseApprovePage) — `/approve`

> ⚠️ **MIXED API** — menu นี้ผสม v1 (legacy approval flow) + v2 (bulk approve + PDF preview) — ต้อง flag ใน human.md section 7
>
> **Human test** → [`human.md`](./human.md)
>
> **สถานะใน README หลัก** → [Mixed marker](../../README.md#สรุปสถานะ--15-menu-routes)
>
> **Cross-links**:
> - Master index → [`../../README.md`](../../README.md)
> - ก่อนหน้าใน flow: [`../submit-approval/`](../submit-approval/) (ส่งอนุมัติ)
> - ใบอนุญาตที่เกี่ยวข้อง: [`../verify/`](../verify/), [`../fact-check/`](../fact-check/)

---

## ภาพรวม

- **Status**: ❌ **No automated tests yet** (TBD)
- **API version**: ⚠️ **Mixed** (4× v1 endpoints + 1× v2 endpoint + 1× v3 preview endpoint)
- **Primary folder**: `lib/ChiangMai_Municipality/License_menu/license_approve_page/` (30 dart files)
- **Files of interest**:
  - `models/license_approve_config.dart`, `models/license_approve_event.dart`
  - `models/license_approve_detail_extended.dart`
  - `services/license_approve_service.dart` (list — v1 + v2 `me`)
  - `services/license_approve_detail_service.dart` (detail v2)
  - `services/license_approve_action_service.dart` (approve/reject steps v2)
  - `services/license_legacy_approval_service.dart` (legacy v1 flow + bulk v2)
  - `services/license_pdf_multi_preview_page.dart` (multi-PDF preview)
  - `services/license_approve_review_detail_service.dart`
  - `viewmodels/license_approve_view_model.dart`, `license_approve_detail_view_model.dart`
  - `viewmodels/license_approve_detail_step2_view_model.dart`
  - `views/license_approve_page.dart`, `license_approve_detail_page.dart`
  - `views/widgets/approve_detail_step1.dart`, `approve_detail_step2.dart`
  - `views/widgets/approve_legacy_signature_section.dart`, `approve_bulk_page_summary.dart`
  - `views/widgets/license_approve_*.dart` (table, header, search, pagination, zone_filter, detail_header/footer)
  - `unity/API_requests_reviews.dart`, `unity/API_admin_signature.dart`, `unity/API_approvals_lastaction.dart`

---

## สิ่งที่ต้องเตรียม

- ✅ ติดตั้ง fvm + Flutter 3.38.3
- ✅ อยู่ที่ root ของโปรเจกต์
- ✅ Backend v1 + v2 + v3 ขึ้นอยู่ (approve ผสม 3 version)

---

## ⚠️ Mixed API — endpoints ที่ต้อง flag

> จาก service files (`license_legacy_approval_service.dart`, `license_approve_service.dart`, etc.):

**v1 endpoints** (legacy approval flow — 4 endpoints):
| Method | Endpoint | ใช้ทำอะไร |
|---|---|---|
| GET | `/admin/know` | admin signature meta |
| GET | `/admin/users/signatures/{uuid}/preview` | signature image bytes |
| GET | `/admin/approvals/{requestUuid}/flow` | flow uuid list (legacy) |
| POST | `/admin/approvals/{requestUuid}/flow/{flowUuid}/approve` | approve (legacy) |

**v2 endpoint** (1 endpoint):
| Method | Endpoint | ใช้ทำอะไร |
|---|---|---|
| POST | `/admin/approvals/bulk/approve` | bulk approve (≤50/round) |

**v3 endpoint** (1 endpoint):
| Method | Endpoint | ใช้ทำอะไร |
|---|---|---|
| GET | `/api/preview/{path}/{requestUuid}` | generated PDFs (multi-PDF preview) |

> **ผลกระทบต่อ test**: unit test ครอบ VM logic (client-side pagination/search) ไม่ยิง HTTP → mixed API ไม่กระทบ test. แต่ manual test ต้อง flag ใน [`human.md`](./human.md) section 7.

---

## v2 endpoints อื่นๆ (ที่ใช้ในระบบ)

**v2 list/detail**:
- `GET /v2/admin/approvals/me` — list งาน approve ของฉัน
- `GET /v2/admin/approvals/{requestUuid}` — detail approval

**v2 steps**:
- `POST /v2/admin/approvals/{requestUuid}/steps/{stepUuid}/approve` — approve step
- `POST /v2/admin/approvals/{requestUuid}/steps/{stepUuid}/reject` — reject step

---

## วิธีรัน (เมื่อเขียน test แล้ว)

> **ยังไม่มี test files** — section นี้จะ activate เมื่อ test ถูกเขียน

```bash
# คาดว่าจะมี test file ในอนาคต:
fvm flutter test test/license_approve_models_test.dart test/license_approve_view_model_test.dart
```

---

## Testable scenarios (TBD — ต้องเขียน)

### Model Factories
- [ ] `LicenseApproveConfig` defaults + constants
- [ ] `LicenseApproveEvent` from JSON / payload parsing (success/error snackbar events)
- [ ] `LicenseApproveDetailExtended` — extended detail payload (legacy + v2 merged)

### ViewModel CRUD
- [ ] `LicenseApproveViewModel` — list load, pagination, search filter, sort, zone filter
- [ ] `LicenseApproveDetailViewModel` — detail load + step1/step2 state transitions
- [ ] `LicenseApproveDetailStep2ViewModel` — bulk action state
- [ ] Bulk approve state transitions (≤50/round validation)
- [ ] Multi-PDF preview state transitions
- [ ] Legacy signature fallback state transitions
- [ ] Events: success/error snackbar emissions

### Widget tests (pumpWidget + Provider)
- [ ] `LicenseApprovePage` empty state + populated state
- [ ] `LicenseApproveTable` row rendering + status badge
- [ ] `LicenseApproveSearchBar` debounce + clear
- [ ] `LicenseApproveZoneFilter` dropdown selection
- [ ] `LicenseApprovePagination` "1 / N" indicator
- [ ] `ApproveDetailStep1` / `ApproveDetailStep2` form transitions
- [ ] `ApproveBulkPageSummary` — selection counter
- [ ] `ApproveLegacySignatureSection` — signature image render

---

## Pattern template — ใช้เป็น guide ตอนเขียน

อ้างอิง [`../../../test/area_view_model_test.dart`](../../../test/area_view_model_test.dart):

```dart
class FakeLicenseApproveService extends LicenseApproveService {
  // seed methods + in-memory store
  // @override fetchList (v2 me), fetchDetail (v2), bulkApprove (v2)
}

LicenseApproveViewModel _makeVM(FakeLicenseApproveService svc) =>
    LicenseApproveViewModel(config: ..., service: svc);

void main() {
  group('LicenseApproveViewModel', () {
    late FakeLicenseApproveService svc;
    late LicenseApproveViewModel vm;

    setUp(() async {
      svc = FakeLicenseApproveService()..seedItem(...);
      vm = _makeVM(svc);
      await Future<void>.delayed(Duration.zero);  // bootstrap
    });

    test('list load returns seeded approvals', () {
      expect(vm.items.length, ...);
    });
    // ... more tests
  });
}
```

---

## Pre-migration checklist (สำหรับ PHP `InC_approval_legacy.php`)

> จาก README migration backlog: `/approve` มี 1 PHP endpoint ที่ใช้ใน legacy signature path

- [ ] Verify backend v2 endpoint ทดแทน PHP `InC_approval_legacy.php` มีจริง + contract ตรงกัน
- [ ] ตรวจ field mapping (snake_case ↔ camelCase, missing fields)
- [ ] อัปเดต `LicenseLegacyApprovalService` ให้ใช้ v2 path หลัง migrate
- [ ] ลบ import / fallback ของ PHP root
- [ ] Manual test section 7 → 8 ทุก checkbox ✅
- [ ] AI test ครอบ v2 path ก่อนลบ PHP
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

1. **Migrate PHP legacy → v2** (blocker) — backend endpoint + service wrapper
2. ลบ PHP endpoint ออกจาก `LicenseLegacyApprovalService`
3. เขียน `test/license_approve_models_test.dart`
4. เขียน `test/license_approve_view_model_test.dart`
5. เขียน `test/license_approve_detail_step2_view_model_test.dart` (bulk action)
6. รัน `fvm flutter test test/license_approve_*` จน pass
7. Manual test ตาม `human.md` section 7
8. อัปเดต README index — flip สถานะเป็น v2 ✅
