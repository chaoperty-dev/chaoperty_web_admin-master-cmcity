# Pen Test (AI) — ผู้เช่า — `/tenant`

> ⚠️ **MIGRATION PENDING** — เมนูนี้ยังใช้ **PHP legacy** อยู่ (`GC_tenantAll_V2.php`) — ต้อง migrate เป็น v2 ก่อน release
>
> **Human test** → [`human.md`](./human.md)
>
> **สถานะใน README หลัก** → [PHP marker](../../README.md#สรุปสถานะ--15-menu-routes)

---

## ภาพรวม

- **Status**: ❌ **No automated tests yet** (TBD)
- **PHP endpoints**: 1 live (`GET GC_tenantAll_V2.php`)
- **Primary folder**: `lib/ChiangMai_Municipality/Tenant_menu/tenant_license_page/` (18 dart files)
- **Files of interest**:
  - `models/tenant_license_config.dart`, `models/tenant_license_event.dart`, `models/tenant_license_detail_models.dart`
  - `services/tenant_license_service.dart`
  - `viewmodels/tenant_license_view_model.dart`, `viewmodels/tenant_license_detail_view_model.dart`
  - `views/tenant_license_page.dart`, `views/tenant_license_detail_page.dart`
  - `views/widgets/tenant_license_*.dart` (10 widget files)

---

## สิ่งที่ต้องเตรียม

- ✅ ติดตั้ง fvm + Flutter 3.38.3
- ✅ อยู่ที่ root ของโปรเจกต์

---

## PHP endpoints ที่ต้อง migrate (BLOCKER)

> จาก Explore agent: มี 1 endpoint ที่ใช้ PHP legacy

| Method | Endpoint | ใช้ทำอะไร |
|---|---|---|
| GET | `GC_tenantAll_V2.php` | โหลดรายชื่อผู้เช่าทั้งหมด |

**Target v2 endpoint** (ยังไม่มี — ต้องขอจาก backend):
- `GET /admin/tenants` — list tenants with pagination/filter

---

## วิธีรัน (เมื่อเขียน test แล้ว)

> **ยังไม่มี test files** — section นี้จะ activate เมื่อ test ถูกเขียน

```bash
# คาดว่าจะมี test file ในอนาคต:
fvm flutter test test/tenant_license_models_test.dart test/tenant_license_view_model_test.dart
```

---

## Testable scenarios (TBD — ต้องเขียน)

### Model Factories
- [ ] `TenantLicenseConfig` defaults
- [ ] `TenantLicenseEvent` from JSON / payload parsing
- [ ] `TenantLicenseDetailModels` — person + shop + license + contract info

### ViewModel CRUD
- [ ] `TenantLicenseViewModel` — list load, pagination, search filter
- [ ] `TenantLicenseDetailViewModel` — detail load + state transitions
- [ ] Events: success/error snackbar emissions

### Widget tests (pumpWidget + Provider)
- [ ] `TenantLicensePage` empty state + populated state
- [ ] `TenantLicenseTable` row rendering
- [ ] `TenantLicensePagination` "1 / N" indicator

---

## Pattern template — ใช้เป็น guide ตอนเขียน

อ้างอิง [`../../../test/area_view_model_test.dart`](../../../test/area_view_model_test.dart):

```dart
class FakeTenantLicenseService extends TenantLicenseService {
  // seed methods + in-memory store
  // @override fetchList, fetchDetail
}

TenantLicenseViewModel _makeVM(FakeTenantLicenseService svc) =>
    TenantLicenseViewModel(config: ..., service: svc);

void main() {
  group('TenantLicenseViewModel', () {
    late FakeTenantLicenseService svc;
    late TenantLicenseViewModel vm;

    setUp(() async {
      svc = FakeTenantLicenseService()..seedTenant(...);
      vm = _makeVM(svc);
      await Future<void>.delayed(Duration.zero);
    });

    test('list load returns seeded tenants', () {
      expect(vm.tenants.length, ...);
    });
    // ... more tests
  });
}
```

---

## Pre-migration checklist

> ทำข้อนี้ก่อนเริ่ม migrate PHP → v2

- [ ] Verify backend v2 endpoint `GET /admin/tenants` มีจริง + contract ตรงกับ PHP response
- [ ] ตรวจ field mapping (snake_case ↔ camelCase, missing fields)
- [ ] ตรวจ pagination contract (per_page, page, total)
- [ ] ตรวจ search/filter contract (q, zone_ser, etc.)
- [ ] อัปเดต `TenantLicenseService.fetchTenants()` ให้ใช้ v2
- [ ] ลบ import / fallback ของ `domain` (legacy PHP root)
- [ ] เขียน unit test ครอบคลุม v2 path ก่อนลบ PHP
- [ ] Manual test ตาม [`human.md`](./human.md) section 7 Backend verification
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

1. **Migrate PHP → v2** (blocker) — backend endpoint + service wrapper
2. ลบ PHP endpoint ออกจาก `TenantLicenseService`
3. เขียน `test/tenant_license_models_test.dart`
4. เขียน `test/tenant_license_view_model_test.dart`
5. รัน `fvm flutter test test/tenant_license_*` จน pass
6. Manual test ตาม `human.md` section 7
7. อัปเดต README index — flip สถานะเป็น v2 ✅
