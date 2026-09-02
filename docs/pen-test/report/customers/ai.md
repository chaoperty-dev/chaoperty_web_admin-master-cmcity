# Pen Test (AI) — รายงานลูกค้า (CustomersReport) — `/report/customers`

> ⚠️ **MIXED API** — เมนูนี้ใช้ v2 เป็นหลัก แต่มี **fallback v1** (`/v1/admin/c-customers`) สำหรับ "ทะเบียนผู้เช่า" — verify endpoint contract ก่อน release
>
> **Human test** → [`human.md`](./human.md)
>
> **สถานะใน README หลัก** → [Mixed marker](../../README.md#สรุปสถานะ--15-menu-routes)

---

## ภาพรวม

- **Status**: ✅ **Tests exist** — `test/customers_report_test.dart` (227 lines, 7 groups)
- **Primary folder**: `lib/ChiangMai_Municipality/Report_menu/customers/` (11 dart files)
- **API version**: ⚠️ Mixed (v2 primary + v1 fallback for `/v1/admin/c-customers`)
- **Files of interest**:
  - `services/customers_report_service.dart` — `CustomersReportService`, `CustomerReportItem`, `CustomerReportColumn`, `CustomerReportResult`
  - `services/customers_report_exporter.dart` — `CustomersReportExporter` interface
  - `services/customers_report_exporter_io.dart` — IO (mobile/desktop) export
  - `services/customers_report_exporter_web.dart` — Web export (Blob + download)
  - `viewmodels/customers_report_view_model.dart` — `CustomersReportViewModel` (load/export)
  - `customers_report_page.dart` — main page
  - `views/widgets/customers_report_column_picker.dart` — column checklist + drag/drop reorder
  - `views/widgets/customers_report_password_dialog.dart` — `PasswordValidator`, `PasswordResult` (sealed), `kDefaultPassword`
  - `views/widgets/customers_report_preview.dart` — preview table
  - `views/widgets/customers_report_header.dart` — page header

---

## สิ่งที่ต้องเตรียม

- ✅ ติดตั้ง fvm + Flutter 3.38.3
- ✅ อยู่ที่ root ของโปรเจกต์
- ✅ Login admin + token ยังไม่หมดอายุ

---

## วิธีรัน

```bash
fvm flutter test test/customers_report_test.dart
```

**ผลที่คาดหวัง**:
- exit code `0`
- output ลงท้ายด้วย `All tests passed!`
- จำนวน tests: **20+ tests** ใน 7 groups (PasswordValidator × 4 + CustomerReportItem × 2 + defaultColumns × 3 + PasswordResult × 1 + AES × 3)

---

## ขอบเขตที่ครอบคลุม

### 🔐 PasswordValidator.checkAll() (3 tests)
- [ ] ✅ password ผ่านทุก rule (`Xyz789!@#`)
- [ ] ✅ multiple passwords ผ่านทุก rule (`Xk7#mP9!`, `MyP@ss9`, `Test#2024`)
- [ ] ❌ สั้นเกินไป (5 ตัว) → length rule fail

### 🔐 PasswordValidator.isCommonPassword() (9 tests)
- [ ] ❌ blacklist: `Password1!`, `12345678!Aa`, `ChaoCmcity1!` (case-insensitive)
- [ ] ❌ sequential: `abcdef!Xy1`, `098765!aA1`, `qwerty!A1x`
- [ ] ✅ non-sequential OK (`Xyz!A1B`, `MyV3ry!`)
- [ ] ✅ case-insensitive check (`PASSWORD1!`, `pAsSwOrD1!`)

### 🔐 PasswordValidator.hasExcessiveRepeat() (5 tests)
- [ ] ❌ `aaaa1!B`, `Abc1111!`, `Abc123!!!!` (4 ตัวซ้ำ)
- [ ] ✅ 3 ตัวซ้ำ OK, ไม่ซ้ำ OK

### 🔐 PasswordValidator.validate() (3 tests)
- [ ] ✅ valid password → null
- [ ] ❌ weak password → error message
- [ ] ❌ excessive repeat → error message

### 📦 CustomerReportItem (3 tests)
- [ ] ✅ `fromJsonSafe` parse JSON ปกติ (full payload)
- [ ] ✅ `fromJsonSafe` null JSON → null
- [ ] ✅ `getBy(field)` returns value by field name (uuid, custno, st, unknown)

### 📋 defaultColumns() (3 tests)
- [ ] ✅ มี 21 columns
- [ ] ✅ field ใน defaultColumns ต้องมีใน `getBy()` (no exception)
- [ ] ✅ `addr_1` vs `addr_2` มี label ต่างกัน

### 🔒 PasswordResult sealed classes (1 test)
- [ ] ✅ `PasswordCancel`/`PasswordNoPassword`/`PasswordWithValue` เป็น `PasswordResult`

### 🔓 AES Encryption round-trip (3 tests)
- [ ] ✅ encrypt + decrypt ด้วย correct password (PNG header)
- [ ] ❌ decrypt ด้วย wrong password → `isDataValid == false`
- [ ] ✅ default password (`@ChaoCmcity`) round-trip 50 bytes

**Total: 20+ tests, 7 groups**

---

## Test infrastructure

ใช้:
- `package:protect` — AES encryption library สำหรับ round-trip test
- `dart:typed_data` — `Uint8List` สำหรับ encrypt payload
- ไม่มี shared `test/helpers/` หรือ `test_utils.dart` — test file self-contained
- ไม่ test UI (pumpWidget) — unit test ล้วน (logic + parser + crypto)

---

## ⚠️ Mixed API — endpoints ที่ต้อง flag

> จาก `customers_report_service.dart` — 2 endpoints:

| Method | Endpoint | ใช้ทำอะไร | Version |
|---|---|---|---|
| GET | `/admin/reports/customers/columns` | โหลด columns list | v2 ✅ |
| GET | `/admin/reports/customers` | โหลด customer items | v2 ✅ |
| GET | `/v1/admin/c-customers?page=N&per_page=M` | fallback สำหรับ "ทะเบียนผู้เช่า" (Laravel paginated shape) | v1 ⚠️ |

> **ผลกระทบต่อ test**: unit test ครอบ model + crypto logic (no HTTP) → mixed endpoints ไม่กระทบ test. แต่ manual test ต้อง flag ใน [`human.md`](./human.md) section 7.

---

## Coverage gaps (TBD เมื่อต้องเขียนเพิ่ม)

- [ ] ViewModel test — `CustomersReportViewModel` (load/refresh/export state transitions)
- [ ] Exporter test — `CustomersReportExporter` IO branch (xlsx bytes shape)
- [ ] Exporter test — `CustomersReportExporter` Web branch (Blob + filename)
- [ ] Widget test — `CustomersReportPage` column picker toggle + export button
- [ ] Widget test — `CustomersReportPasswordDialog` 2 modes (default + custom)
- [ ] Error path — service returns 0 items → empty preview
- [ ] Error path — service throws → snackbar

---

## เกณฑ์ Pass / Fail

### Pass
- ✅ exit code `0`
- ✅ output ลงท้ายด้วย `All tests passed!`
- ✅ 20/20 tests pass

### Fail
- ❌ exit code != `0`
- ❌ มี test fail/skipped

**ถ้า AI Test fail → ห้าม merge — fix ก่อน**

---

## ลำดับการทำงาน (ถ้าเขียน test เพิ่ม)

1. เขียน `test/customers_report_view_model_test.dart` (VM CRUD)
2. เขียน widget test สำหรับ column picker + password dialog
3. เขียน exporter test (IO + Web branches)
4. Decide: migrate `/v1/admin/c-customers` → `/admin/c-customers` v2 (separate epic) — flip สถานะเป็น v2 ✅
5. อัปเดต README index — flip สถานะเป็น v2 ✅
