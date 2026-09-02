# Pen Test (AI) — ตั้งค่า (hub) — `/setting`

> **เอกสารนี้คืออะไร** — hub pentest สำหรับ `/setting` page (เปิด 4 sub-menus ผ่าน `Navigator.push`)
>
> **Sub-menu pentests**:
> - [area-config/](area-config/) — ตั้งค่าพื้นที่เช่า (group/zone/lock CRUD, v2 ✅, has tests ✅)
> - access-rights/ — ⚠️ TBD
> - payment-config/ — ⚠️ TBD (mixed PHP)
> - general-data/ — ⚠️ TBD (PHP legacy — 12 endpoints)
>
> **Human test** → [`human.md`](./human.md)

---

## ภาพรวม

- **Hub status**: ✅ Hub page exists; sub-menus mixed
- **Hub API version**: N/A (hub ไม่ยิง API — เป็น launcher เท่านั้น)
- **Primary folder**: `lib/ChiangMai_Municipality/Setting_menu/setting_page/`
- **Hub files**:
  - `views/setting_page.dart` (root widget — ไม่มี `.create()` factory)
  - `views/theme/setting_page_theme.dart`
  - `views/widgets/setting_menu_card.dart`, `setting_page_header.dart`

### 4 Sub-menus (launched via Navigator.push)

| Sub-menu | Folder | API version | Tests | Pentest |
|---|---|---|---|---|
| ตั้งค่าพื้นที่เช่า (Area config) | `area/` | v2 ✅ | ✅ (36 tests) | [area-config/](area-config/) |
| สิทธิ์การเข้าถึง (Access Rights) | `access_rights/` | v2 ✅ | ❌ | TBD |
| ตั้งค่าการชำระเงิน (Payment config) | `payment/` | ⚠️ Mixed | ❌ | TBD |
| ข้อมูลทั่วไป (General Data) | `general_data/` | ⚠️ **PHP** (12 endpoints) | ❌ | TBD |

---

## สิ่งที่ต้องเตรียม

- ✅ ติดตั้ง fvm + Flutter 3.38.3

---

## วิธีรัน

> Hub ไม่มี test ของตัวเอง — test อยู่ที่ sub-menu folders

```bash
# ทั้งหมด (ถ้ามี test ใน sub-menu):
fvm flutter test test/area_models_test.dart test/area_view_model_test.dart

# area-config เท่านั้น (มี test อยู่แล้ว 36 tests):
fvm flutter test test/area_models_test.dart test/area_view_model_test.dart
```

---

## Hub scope

> Hub ทำหน้าที่แค่ "เปิด sub-menu" — ไม่มี business logic ของตัวเอง

### Testable scenarios (TBD ถ้าต้องเขียน)
- [ ] `SettingPage` render 4 menu cards
- [ ] Tap card → Navigator.push ไปยัง sub-menu ที่ถูกต้อง
- [ ] Permission gating: ถ้า user ไม่มีสิทธิ์ → card disabled

---

## Sub-menu test coverage

### ✅ area-config — [ดู pentest](area-config/)
- 36 tests pass (17 model + 19 VM)
- `test/area_models_test.dart` + `test/area_view_model_test.dart`
- Pattern: `FakeAreaService extends AreaService` + `await Future<void>.delayed(Duration.zero)` × 2

### ❌ access-rights — TBD
- Pattern: ดู area-config เป็น template
- Files: `access_rights/{models,services,viewmodels,views}/`
- Testable: position, user, role, role_position CRUD

### ❌ payment-config — TBD
- Mixed API — ต้อง flag PHP endpoints
- Files: `payment/{models,services,viewmodels,views}/`
- Testable: payment, paytype, bank, banktype, rental CRUD

### ❌ general-data — TBD
- ⚠️ **PHP legacy** (12 endpoints) — migration blocker
- Files: `general_data/{models,services,viewmodels,views}/`
- Testable: rental_general CRUD

---

## ⚠️ Mixed/PHP endpoints — ต้อง flag

> จาก Explore agent: 12 PHP endpoints ใน `general_data/` ยังค้าง

| Method | Endpoint (sample) | ใช้ทำอะไร |
|---|---|---|
| GET | `rental_general_*.php` (×12) | rental CRUD + dropdowns |

> ดู full list จาก `rental_general_service.dart` + `payment_service.dart` เมื่อเขียน pentest folder นั้น

---

## เกณฑ์ Pass / Fail

### Pass (per sub-menu)
- ✅ Sub-menu's AI test pass
- ✅ Sub-menu's Human test pass
- ✅ Network tab ของ sub-menu: ไม่มี `.php` (ยกเว้น general-data ที่ยัง migrate ไม่เสร็จ)

### Hub Pass
- ✅ Hub render 4 cards
- ✅ Tap card → navigate ถูก
- ✅ Permission gating ทำงาน

---

## ลำดับการทำงาน

1. **area-config** ✅ (done — มี pentest folder + 36 tests)
2. **access-rights** — เขียน pentest folder + test files (TBD)
3. **payment-config** — เขียน pentest folder + flag mixed API (TBD)
4. **general-data** — เขียน pentest folder + migrate PHP → v2 (BLOCKER)
5. อัปเดต README index เมื่อ sub-menu เสร็จ

---

## ดูเพิ่ม

- [area-config pentest](area-config/) — ตัวอย่าง pattern ที่ใช้ reuse
- [Root README](../README.md) — master index
