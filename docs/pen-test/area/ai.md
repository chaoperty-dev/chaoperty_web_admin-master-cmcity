# Pen Test (AI) — พื้นที่เช่า (AreaMenuPage) — `/area`

> **เอกสารนี้คืออะไร** — automated test scope สำหรับ top-level menu `/area` (AreaMenuPage — ต่อสัญญา/ประมูล/คืน)
>
> **Human test** → [`human.md`](./human.md)
>
> **หมายเหตุ**: top-level `/area` (AreaMenuPage) **คนละ feature** กับ "ตั้งค่าพื้นที่เช่า" ใน setting hub (group/zone/lock config) — ดู [`../setting/area-config/`](../setting/area-config/)

---

## ภาพรวม

- **Status**: ❌ **No automated tests yet** (TBD)
- **Primary folder**: `lib/ChiangMai_Municipality/Area_menu/` (22 dart files)
- **API version**: v2 ✅
- **Files of interest**:
  - `models/area_menu_config.dart`, `models/area_menu_event.dart`
  - `services/area_menu_service.dart`
  - `viewmodels/area_menu_view_model.dart`, `viewmodels/area_menu_detail_view_model.dart`
  - `views/area_menu_page.dart`, `views/area_menu_detail_page.dart`
  - `views/widgets/area_menu_*.dart` (14 widget files — header, search, table, zone_filter, card_grid, etc.)

---

## สิ่งที่ต้องเตรียม

- ✅ ติดตั้ง fvm + Flutter 3.38.3
- ✅ อยู่ที่ root ของโปรเจกต์

---

## วิธีรัน (เมื่อเขียน test แล้ว)

> **ยังไม่มี test files** — section นี้จะ activate เมื่อ test ถูกเขียน

```bash
# คาดว่าจะมี test file ในอนาคต:
fvm flutter test test/area_menu_models_test.dart test/area_menu_view_model_test.dart
```

---

## Testable scenarios (TBD — ต้องเขียน)

### Model Factories
- [ ] `AreaMenuEvent` from JSON / payload parsing
- [ ] `AreaMenuConfig` defaults + constants
- [ ] Area menu item payload: ser, ln, lncode, area, rent, zone, customer info, expiry date

### ViewModel CRUD
- [ ] `AreaMenuViewModel` — list load, pagination, search filter, sort
- [ ] `AreaMenuDetailViewModel` — detail load + multi-step state
- [ ] Events: success/error snackbar emissions
- [ ] Renewal flow state transitions
- [ ] Bidding flow state transitions
- [ ] Return flow state transitions

### Widget tests (pumpWidget + Provider)
- [ ] `AreaMenuPage` empty state + populated state
- [ ] `AreaMenuTable` row rendering
- [ ] `AreaMenuPagination` "1 / 3" indicator
- [ ] Card view (`AreaMenuCardGrid`) toggle

---

## Pattern template — ใช้เป็น guide ตอนเขียน

อ้างอิง [`../../../test/area_view_model_test.dart`](../../../test/area_view_model_test.dart):

```dart
class FakeAreaMenuService extends AreaMenuService {
  // seed methods + in-memory store
  // @override fetchList, fetchDetail, renew, bid, return
}

AreaMenuViewModel _makeVM(FakeAreaMenuService svc) =>
    AreaMenuViewModel(config: ..., service: svc);

void main() {
  group('AreaMenuViewModel', () {
    late FakeAreaMenuService svc;
    late AreaMenuViewModel vm;

    setUp(() async {
      svc = FakeAreaMenuService()..seedItem(...);
      vm = _makeVM(svc);
      await Future<void>.delayed(Duration.zero);  // bootstrap
    });

    test('list load returns seeded items', () {
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

1. เขียน `test/area_menu_models_test.dart` (model factories)
2. เขียน `test/area_menu_view_model_test.dart` (CRUD + events)
3. รัน `fvm flutter test test/area_menu_*` จน pass
4. Update `human.md` หัวข้อ Backend verification เมื่อ test stable
