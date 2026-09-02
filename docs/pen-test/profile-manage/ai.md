# Pen Test (AI) — จัดการข้อมูลส่วนตัว (PersonalInformation) — `/profile/manage`

> **เอกสารนี้คืออะไร** — automated test scope สำหรับ top-level menu `/profile/manage` (ManagePersonalInformationPage — แก้ไขข้อมูลผู้ใช้ + ลายเซ็น)
>
> **Human test** → [`human.md`](./human.md)
>
> **หมายเหตุ**: top-level `/profile/manage` (admin profile) **คนละ feature** กับ `/registration` (ทะเบียนผู้เช่า) และ `/tenant` (รายชื่อผู้เช่า) — หน้านี้จัดการ user/signature ของ admin ที่ login อยู่

---

## ภาพรวม

- **Status**: ❌ **No automated tests yet** (TBD)
- **Primary folder**: `lib/ChiangMai_Municipality/Personal_information_menu/personal_information_page/` (16 dart files)
- **API version**: v2 ✅ (verified — `domain_v1` defined in `Myconstant.dart` ใช้สำหรับ `/admin/know` + `/admin/users/signatures/.../preview` ซึ่งเป็น v1 admin endpoints ที่ backend ยังไม่ย้าย — verify เพิ่มเติม)
- **Files of interest**:
  - `models/personal_information_models.dart` — `AdminProfile`, `PersonalInformationEvent`
  - `viewmodels/personal_information_view_model.dart` — `PersonalInformationViewModel` (load/save/refresh)
  - `services/personal_information_service.dart` — `loadProfile()`, `saveSignature()`, `exportSignatureBytes()`
  - `views/personal_information_page.dart` — main page + `_HeaderEditButton`
  - `views/widgets/personal_information_*.dart` — avatar / info_grid / signature_section / signature_dialog / app_bar
  - `unity/ReusableSignaturePad.dart` — signature drawing canvas
  - `unity/API_admin_signature.dart` — `read_AdminSignature()`, `img_signatureUuid()`
  - `unity/EncryptText.dart`, `unity/SecurePrefs_helper.dart`

---

## สิ่งที่ต้องเตรียม

- ✅ ติดตั้ง fvm + Flutter 3.38.3
- ✅ อยู่ที่ root ของโปรเจกต์
- ✅ Login admin + token ยังไม่หมดอายุ

---

## วิธีรัน (เมื่อเขียน test แล้ว)

> **ยังไม่มี test files** — section นี้จะ activate เมื่อ test ถูกเขียน

```bash
# คาดว่าจะมี test file ในอนาคต:
fvm flutter test test/personal_information_models_test.dart test/personal_information_view_model_test.dart
```

---

## Testable scenarios (TBD — ต้องเขียน)

### Model Factories
- [ ] `AdminProfile` from JSON — parse `data.profile_uuid`, `data.signature_uuid`, `data.profile`, `data.position_name`
- [ ] `AdminProfile.hasSignature` derived from `signatureBytes != null`
- [ ] `PersonalInformationEvent` sealed family — `PersonalInformationError`, `PersonalInformationSaved`

### ViewModel CRUD
- [ ] `PersonalInformationViewModel.load()` — bootstrap from service → populates `profile` + clears `error`
- [ ] `PersonalInformationViewModel.refresh()` — re-fetch + emit events
- [ ] `PersonalInformationViewModel.saveSignature(key)` — multipart upload → emit `PersonalInformationSaved`
- [ ] State flags: `isLoading`, `isSaving`, `error`
- [ ] Error path: service throws → emit `PersonalInformationError(message)`

### Widget tests (pumpWidget + Provider)
- [ ] `ManagePersonalInformationPage` loading state (CircularProgressIndicator + "กำลังโหลดข้อมูล...")
- [ ] Error state — error block + "ลองอีกครั้ง" button → calls `vm.refresh()`
- [ ] Profile loaded — `_ProfileCard` + 4 `InfoFieldData` rows
- [ ] `_HeaderEditButton` disabled while `isSaving == true` (shows spinner)
- [ ] Signature pad dialog — tap "แก้ไขลายเซ็น" → opens `PersonalInformationSignatureDialog`
- [ ] `PersonalInformationSignatureSection` — show existing signature OR "ยังไม่มีลายเซ็น"

### Reusable Signature Pad
- [ ] `ReusableSignaturePad` — drawing strokes captured as PNG bytes
- [ ] Clear / Undo / Save actions
- [ ] Export bytes shape — `Uint8List` PNG ready for upload

---

## Pattern template — ใช้เป็น guide ตอนเขียน

อ้างอิง [`../../../test/area_view_model_test.dart`](../../../test/area_view_model_test.dart):

```dart
class FakePersonalInformationService extends PersonalInformationService {
  AdminProfile? _seed;
  Uint8List? _signatureBytes;
  bool _throwOnLoad = false;
  bool _throwOnSave = false;

  void seedProfile(AdminProfile p) => _seed = p;
  void seedSignature(Uint8List b) => _signatureBytes = b;
  void throwOnLoad() => _throwOnLoad = true;
  void throwOnSave() => _throwOnSave = true;

  @override
  Future<AdminProfile> loadProfile() async {
    if (_throwOnLoad) throw Exception('boom');
    return _seed ?? const AdminProfile();
  }

  @override
  Future<bool> saveSignature({
    required Uint8List signedData,
    required String userUuid,
  }) async {
    if (_throwOnSave) throw Exception('boom');
    _signatureBytes = signedData;
    return true;
  }
}

void main() {
  group('PersonalInformationViewModel', () {
    late FakePersonalInformationService svc;
    late PersonalInformationViewModel vm;

    setUp(() async {
      svc = FakePersonalInformationService()
        ..seedProfile(AdminProfile(
          userUuid: 'u1',
          profileUuid: 'p1',
          signatureUuid: 's1',
          fullName: 'สมชาย ใจดี',
          positionName: 'นาย',
          email: 'a@b.com',
        ));
      vm = PersonalInformationViewModel(service: svc);
      await vm.load();
    });

    test('load populates profile', () {
      expect(vm.profile?.fullName, 'สมชาย ใจดี');
      expect(vm.isLoading, false);
      expect(vm.error, isNull);
    });

    test('saveSignature emits PersonalInformationSaved', () async {
      final events = <PersonalInformationEvent>[];
      final sub = vm.events.listen(events.add);
      await vm.saveSignature(Uint8List.fromList([1,2,3]));
      await Future<void>.delayed(Duration.zero);
      expect(events.whereType<PersonalInformationSaved>().length, 1);
      await sub.cancel();
    });
  });
}
```

---

## API endpoints ที่ใช้ (v2 target — TODO verify)

> ดูจาก `unity/API_admin_signature.dart` ตอนนี้ใช้ `domain_v1` — verify ว่า backend มี v2 equivalent หรือยัง

| Method | Endpoint | ใช้ทำอะไร | สถานะ |
|---|---|---|---|
| GET | `/admin/know` | โหลด admin profile + signature_uuid | ✅ ใช้ v1 อยู่ |
| GET | `/admin/users/signatures/{uuid}/preview` | ดาวน์โหลดภาพลายเซ็น (PNG bytes) | ✅ ใช้ v1 อยู่ |
| POST | `/admin/users/{uuid}/signatures` | multipart upload ลายเซ็นใหม่ (PNG) | TODO verify v2 path |
| GET | `/admin/profile` | ดึง profile info (alias สำหรับ /admin/know) | TODO |
| PUT | `/admin/profile` | แก้ไข profile info | TODO (ถ้ามี) |
| POST | `/admin/profile/password` | เปลี่ยน password | TODO (ถ้ามี) |

> **TODO**: verify กับ `personal_information_service.dart` และ backend v2 contract — flag ถ้ายังต้องใช้ v1

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

1. Verify endpoint จริงจาก `personal_information_service.dart` (cross-check `API_admin_signature.dart`)
2. ถ้าพบว่าใช้ v1 อยู่ → flag ใน `human.md` section 7 Backend verification
3. เขียน `test/personal_information_models_test.dart` (model factories)
4. เขียน `test/personal_information_view_model_test.dart` (CRUD + events)
5. รัน `fvm flutter test test/personal_information_*` จน pass
6. Update `human.md` หัวข้อ Backend verification เมื่อ test stable
