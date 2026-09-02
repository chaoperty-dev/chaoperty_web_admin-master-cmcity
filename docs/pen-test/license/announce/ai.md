# Pen Test (AI) — ประกาศคำขอใบอนุญาต — `/announce`

> ✅ **v2 API** — เมนูนี้ใช้ v2 ทั้งหมด (ใช้ `domain_v1` แล้วตัด `/v1` ออก เพื่อเรียก `/api/v2/...`)
>
> **Human test** → [`human.md`](./human.md)
>
> **สถานะใน README หลัก** → [v2 marker](../../README.md#สรุปสถานะ--15-menu-routes)

---

## ภาพรวม

- **Status**: ❌ **No automated tests yet** (TBD)
- **API version**: v2 ✅
- **Primary folder**: `lib/ChiangMai_Municipality/License_menu/license_announce_page/` (19 dart files)
- **Files of interest**:
  - `models/license_announce_config.dart`, `models/license_announce_event.dart`, `models/license_announce_item.dart`
  - `services/license_announce_service.dart`
  - `viewmodels/license_announce_view_model.dart`, `viewmodels/license_announce_detail_step1_view_model.dart`
  - `views/license_announce_page.dart`, `views/license_announce_detail_page.dart`, `views/license_announce_add_page.dart`, `views/license_announce_edit_page.dart`
  - `views/widgets/license_announce_*.dart` (8 widget files — header, search, table, zone_filter, pagination, detail header/footer/step1)

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
fvm flutter test test/license_announce_models_test.dart test/license_announce_view_model_test.dart
```

---

## Testable scenarios (TBD — ต้องเขียน)

### Model Factories
- [ ] `LicenseAnnounceItem` from JSON / payload parsing
- [ ] `LicenseAnnounceConfig` defaults + constants
- [ ] `LicenseAnnounceEvent` variants (loaded / error / success)

### ViewModel CRUD
- [ ] `LicenseAnnounceViewModel` — list load, pagination, search filter, zone filter
- [ ] `LicenseAnnounceDetailStep1ViewModel` — detail load + multi-step state
- [ ] Add flow state transitions (form fields → submit)
- [ ] Edit flow state transitions (load → patch → submit)
- [ ] Delete flow state transitions (confirm → DELETE → list refresh)
- [ ] Events: success/error snackbar emissions

### Widget tests (pumpWidget + Provider)
- [ ] `LicenseAnnouncePage` empty state + populated state
- [ ] `LicenseAnnounceTable` row rendering
- [ ] `LicenseAnnouncePagination` "1 / N" indicator
- [ ] `LicenseAnnounceSearchBar` debounce + clear
- [ ] `LicenseAnnounceZoneFilter` dropdown change → list refresh
- [ ] Detail page tabs / sections
- [ ] Add / Edit form validation

---

## Pattern template — ใช้เป็น guide ตอนเขียน

อ้างอิง [`../../../test/area_view_model_test.dart`](../../../test/area_view_model_test.dart):

```dart
class FakeLicenseAnnounceService extends LicenseAnnounceService {
  // seed methods + in-memory store
  // @override fetchList, fetchDetail, create, update, delete
}

LicenseAnnounceViewModel _makeVM(FakeLicenseAnnounceService svc) =>
    LicenseAnnounceViewModel(config: ..., service: svc);

void main() {
  group('LicenseAnnounceViewModel', () {
    late FakeLicenseAnnounceService svc;
    late LicenseAnnounceViewModel vm;

    setUp(() async {
      svc = FakeLicenseAnnounceService()..seedItem(...);
      vm = _makeVM(svc);
      await Future<void>.delayed(Duration.zero);  // bootstrap
    });

    test('list load returns seeded announcements', () {
      expect(vm.items.length, ...);
    });
    // ... more tests
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

1. เขียน `test/license_announce_models_test.dart` (model factories)
2. เขียน `test/license_announce_view_model_test.dart` (CRUD + events)
3. รัน `fvm flutter test test/license_announce_*` จน pass
4. Manual test ตาม [`human.md`](./human.md) section 1-7
5. Update `human.md` หัวข้อ Backend verification เมื่อ test stable