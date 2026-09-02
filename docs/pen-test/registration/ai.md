# Pen Test (AI) — ทะเบียน — `/registration`

> **เอกสารนี้คืออะไร** — automated test scope สำหรับ menu `/registration` (ทะเบียนผู้เช่า)
>
> **Human test** → [`human.md`](./human.md)

---

## ภาพรวม

- **Status**: ✅ **Tests exist** — `test/registration_menu_test.dart` (286 lines)
- **API version**: ⚠️ Mixed (v1 + PHP legacy — 3 PHP endpoints)
- **Primary folder**: `lib/ChiangMai_Municipality/Registration_menu/` (router pulls from `registration_page/views/registration_page.dart`)
- **Files of interest**:
  - `registration_page/models/registration_config.dart`, `registration_event.dart`
  - `registration_page/services/registration_service.dart`
  - `registration_page/viewmodels/registration_view_model.dart`, `registration_detail_view_model.dart`
  - `registration_page/views/registration_page.dart`, `widgets/registration_table.dart`, `widgets/registration_pagination.dart`

---

## สิ่งที่ต้องเตรียม

- ✅ ติดตั้ง fvm + Flutter 3.38.3
- ✅ อยู่ที่ root ของโปรเจกต์

---

## วิธีรัน

```bash
fvm flutter test test/registration_menu_test.dart
```

**ผลที่คาดหวัง**:
- exit code `0`
- output ลงท้ายด้วย `All tests passed!`
- จำนวน tests: **14 tests** ใน 4 groups

---

## ขอบเขตที่ครอบคลุม

### 📄 Pagination (4 tests)
- [ ] ✅ คำนวณหน้าจากจำนวนรายการ (perPage = 50) — 120 items → 3 pages
- [ ] ✅ `goToPage(2)` เปลี่ยนหน้าและ slice ถูกต้อง (uuid-50 ขึ้นไป)
- [ ] ✅ `goToPage` clamp เมื่อเกินขอบเขต
- [ ] ✅ `prevPage` / `nextPage` ทำงาน

### 🔍 Search & Filter (4 tests)
- [ ] ✅ ค้นหาตามคำค้น (client-side filter)
- [ ] ✅ `setSearchField` เปลี่ยนฟิลด์ค้นหา
- [ ] ✅ กรองสถานะตาม `st` field
- [ ] ✅ ไม่พบข้อมูล → `paged` ว่าง

### 🧭 Event & Lookup (3 tests)
- [ ] ✅ `onViewTenant` ส่ง `RegistrationNavigateEvent(routeData: uuid)`
- [ ] ✅ `findTenantByKey` หาได้จาก `uuid` และ `custno`
- [ ] ✅ `kSearchFields` มีฟิลด์ครบ

### 🖼️ Widgets (3 tests — pumpWidget + Provider)
- [ ] ✅ `RegistrationTable` แสดงแถวตาม `paged`
- [ ] ✅ `RegistrationTable` แสดง empty state เมื่อไม่มีข้อมูล
- [ ] ✅ `RegistrationPagination` แสดง "หน้า / หน้าสุดท้าย"

**Total: 14 tests, 4 groups**

---

## Test infrastructure

ใช้:
- `FakeRegistrationService extends RegistrationService` — thin stub คืน `List<CustomerReportItem>` ที่ส่งเข้า constructor
- `pumpWidget` + `ChangeNotifierProvider<RegistrationViewModel>.value(value: vm)` — pattern ตาม agent 1's findings
- VM constructed ผ่าน constructor จริง: `RegistrationViewModel(config: ..., service: FakeRegistrationService(items: items))`

ไม่มี shared `test/helpers/` หรือ `test_utils.dart` — test file self-contained

---

## ⚠️ Mixed API — PHP endpoints ที่ต้อง flag

> จาก Explore agent: 3 PHP endpoints ยังค้าง

| Method | Endpoint | ใช้ทำอะไร |
|---|---|---|
| GET | `GC_custo_se.php` | search/lookup ลูกค้า |
| GET | `GC_type.php` | dropdown ประเภทร้าน |
| POST | `registration_add_up.php` | add/update tenant |

> **ผลกระทบต่อ test**: unit test ครอบ VM logic (client-side pagination/search) ไม่ยิง HTTP → PHP endpoints ไม่กระทบ test. แต่ manual test ต้อง flag ใน [`human.md`](./human.md) section 7.

---

## Coverage gaps (TBD เมื่อต้องเขียนเพิ่ม)

- [ ] Add/Edit form (`registration_add_page.dart`, `registration_edit_page.dart`) — Thai-address autocomplete
- [ ] Detail page navigation flow
- [ ] Error handling — network down / token expired
- [ ] `RegistrationDetailViewModel` CRUD
- [ ] Integration test: full flow (list → detail → edit → save → back)

---

## เกณฑ์ Pass / Fail

### Pass
- ✅ exit code `0`
- ✅ output ลงท้ายด้วย `All tests passed!`
- ✅ 14/14 tests pass

### Fail
- ❌ exit code != `0`
- ❌ มี test fail/skipped

**ถ้า AI Test fail → ห้าม merge — fix ก่อน**

---

## ลำดับการทำงาน (ถ้าเขียน test เพิ่ม)

1. เขียน `test/registration_detail_view_model_test.dart` (detail CRUD)
2. เขียน widget test สำหรับ add/edit form
3. เขียน integration test full flow
4. Migrate 3 PHP endpoints → v2 (separate epic)
5. อัปเดต README index — flip สถานะเป็น v2 ✅
