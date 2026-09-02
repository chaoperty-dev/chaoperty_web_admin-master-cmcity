# Pen Test (Human) — ทะเบียน — `/registration`

> **เอกสารนี้คืออะไร** — manual UI walkthrough สำหรับ menu `/registration` (ทะเบียนผู้เช่า)
>
> **Automated test** → [`ai.md`](./ai.md)

---

## ภาพรวมระบบ

### ฟีเจอร์ที่ทดสอบ
RegistrationPage — รายชื่อผู้เช่า + add/edit/detail + Thai-address autocomplete

```
RegistrationPage (list + search + filter + pagination)
   ├── RegistrationAddPage → เพิ่มผู้เช่า (multi-step form + Thai address)
   ├── RegistrationEditPage → แก้ไข
   └── RegistrationDetailPage → รายละเอียด (person/shop/contract)
```

### API ที่ใช้ (Mixed ⚠️ — ดู note ด้านล่าง)
**v1 endpoints** (verified):
- `GET /admin/c-customers` — list customers

**PHP legacy** (3 endpoints ที่ต้อง migrate):
- `GET GC_custo_se.php` — search/lookup ลูกค้า
- `GET GC_type.php` — dropdown ประเภทร้าน
- `POST registration_add_up.php` — add/update tenant

### ฟีเจอร์ที่ตัดออก (ถ้ามี)
> TODO: ระบุถ้ามี

### Baseline
- commit: `6d1a298` (HEAD)

---

## สิ่งที่ต้องเตรียม

- ✅ `fvm flutter pub get`
- ✅ Login (สิทธิ์ `TENANT_REGISTRY`)
- ✅ Backend v1 + PHP legacy ขึ้นอยู่
- ✅ DevTools Network tab — filter `c-customers|custo|registration_add`
- ✅ commit `6d1a298`

---

## วิธีรัน

```bash
fvm flutter run -d chrome
```

หลังแอปเปิด:
1. Login → เมนู **ทะเบียน** (ไอคอน app_registration)
2. URL ควรเป็น `/registration`

---

## 0. Pre-flight

- [ ] Hot reload สำเร็จ
- [ ] หน้า `/registration` เปิดได้ ไม่มี red error
- [ ] Network tab: `GET /admin/c-customers` → status `200` (v1 — expected)
- [ ] List แสดง row อย่างน้อย 1 row ถ้ามีข้อมูล
- [ ] Pagination indicator ("หน้า 1 / N") ปรากฏ

---

## 1. List + Search + Filter

### 1.1 Initial load
- [ ] เปิดหน้า `/registration` → list โหลดทันที
- [ ] Pagination: perPage = 50 → ถ้า >50 row แสดง "1 / 3"
- [ ] Empty state ถ้า 0 row

### 1.2 Search
- [ ] พิมพ์คำค้น (ชื่อ, taxno, tel — ตาม `kSearchFields`) → list filter client-side
- [ ] `setSearchField` (dropdown เลือก field) → filter เฉพาะ field นั้น
- [ ] Network: `GET /admin/c-customers?q=...` (ถ้ามี server-side filter)
- [ ] Clear search → list กลับเต็ม

### 1.3 Status filter
- [ ] กรองตาม `st` (status: ใช้งาน/ระงับ/...)
- [ ] List filter ตาม status ที่เลือก

### 1.4 Pagination
- [ ] Next / Prev / page number — `goToPage` clamp เมื่อเกิน (verified ใน test)
- [ ] `prevPage` / `nextPage` boundary

---

## 2. Detail page

### 2.1 เปิด detail
- [ ] กด row → `onViewTenant` → emit `RegistrationNavigateEvent(routeData: uuid)` → detail page เปิด
- [ ] Sections: ข้อมูลส่วนตัว / ข้อมูลร้าน / contract / license history
- [ ] ปุ่ม action: แก้ไข / ลบ / พิมพ์

### 2.2 Section แต่ละอัน
- [ ] **ข้อมูลส่วนตัว**: ชื่อ, เลขบัตรประชาชน (13 หลัก + checksum), ที่อยู่ไทย, เบอร์โทร
- [ ] **ข้อมูลร้าน**: ชื่อร้าน, ประเภท (จาก `GC_type.php` dropdown), ทะเบียนการค้า
- [ ] **contract**: สัญญาปัจจุบัน + rent + zone
- [ ] **license history**: รายการ license เก่า

---

## 3. Add tenant

### 3.1 เปิด form
- [ ] กดปุ่ม **เพิ่มผู้เช่า** → `RegistrationAddPage` เปิด
- [ ] Form มี 2 steps (ถ้าเป็น multi-step)

### 3.2 Step 1: ข้อมูลส่วนตัว
- [ ] กรอก ชื่อ-นามสกุล, เลขบัตร, วันเกิด
- [ ] Thai address autocomplete (พิมพ์ "เชียงใหม่" → dropdown ตัวเลือก)
- [ ] Validation: เลขบัตร 13 หลัก, checksum ถูก

### 3.3 Step 2: ข้อมูลร้าน + contract
- [ ] ชื่อร้าน, ประเภท (จาก `GC_type.php`)
- [ ] เลือก zone, rent
- [ ] Step 2 review → กด "บันทึก"

### 3.4 Submit
- [ ] Network: `POST registration_add_up.php` → 200 (PHP — expected)
- [ ] Snackbar success
- [ ] กลับมา list → row ใหม่ปรากฏ

---

## 4. Edit tenant

### 4.1 เปิด form
- [ ] จาก detail → กด "แก้ไข" → `RegistrationEditPage` เปิด
- [ ] Fields prefill ครบ

### 4.2 Save
- [ ] แก้ไข field → "บันทึก"
- [ ] Network: `POST registration_add_up.php` (PUT ถ้า v2) → 200
- [ ] Snackbar success + detail update

---

## 5. Delete tenant (ถ้ามี)

### 5.1 Confirm
- [ ] กด "ลบ" → dialog "ยืนยันการลบ" ถามชื่อ
- [ ] ยกเลิก → row ยังอยู่
- [ ] ยืนยัน → DELETE request → success

---

## 6. Edge cases

- [ ] Network down → snackbar error + state ไม่ crash
- [ ] Token expired → redirect login
- [ ] Thai address autocomplete ไม่เจอ → fallback พิมพ์เอง
- [ ] Pagination overflow → redirect page 1
- [ ] Detail page + back + เปิด detail อีก → state reset

---

## 7. Backend verification (CURRENT STATE)

**คาดหวังตอนนี้**: v1 + PHP requests (mixed)

- [ ] `GET /admin/c-customers` → 200 (v1 — OK)
- [ ] `GET GC_custo_se.php` (search) → 200 (PHP — expected)
- [ ] `GET GC_type.php` (dropdown) → 200 (PHP — expected)
- [ ] `POST registration_add_up.php` → 200 (PHP — expected)
- [ ] ทุก request มี `Authorization: Bearer <token>`

---

## 8. Backend verification (POST-MIGRATION TARGET)

> ทำ checklist นี้หลัง migrate 3 PHP → v2 เสร็จ

- [ ] ❌ **ไม่มี `.php`** ใน URL
- [ ] `GET /admin/customers` (หรือ path ใหม่) → 200
- [ ] `GET /admin/customer-types` → 200
- [ ] `POST /admin/customers` (add) → 201
- [ ] `PUT /admin/customers/{id}` (edit) → 200
- [ ] `DELETE /admin/customers/{id}` → 204

---

## 9. Regression (ถ้าเคยเจอ)

### Bug 1: search field default
- ถ้าพิมพ์คำค้นแต่ไม่ match → ตรวจ `setSearchField` ถูกต้อง

---

## Migration blocking checklist

- [ ] Backend มี v2 endpoints ครบทั้ง 3 (search / types / add-up)
- [ ] `RegistrationService` ใช้ `domain_v2` แทน PHP path
- [ ] Manual test section 7 → 8 (ทุก checkbox ✅)
- [ ] AI test ครอบ v2 path (ดู [`ai.md`](./ai.md) coverage gaps)
- [ ] อัปเดต README index — flip สถานะเป็น v2 ✅

---

## เกณฑ์ Pass / Fail

### Pass (post-migration)
- ✅ AI Test ผ่าน (14/14)
- ✅ Human Test ทุก checkbox ผ่าน
- ✅ Network tab: ไม่มี `.php`
- ✅ Backend verification section 8 ทุกข้อ ✅

### Pass (current — pre-migration)
- ✅ AI Test ผ่าน (14/14)
- ⚠️ Network tab มี 3 PHP endpoints (expected)
- ✅ ฟีเจอร์ทำงานได้ปกติ

### Fail
- ❌ Red error บนหน้าจอ
- ❌ Snackbar ข้อความผิด
- ❌ PHP endpoint ที่ไม่อยู่ใน list (4th `.php` ที่ไม่คาดคิด) → unexpected

---

## ปัญหาที่เคยเจอและแก้แล้ว

> TODO: เพิ่มเมื่อเจอ bug

---

**จบเอกสาร** — หลัง migrate เสร็จ ลบ section 7 + เลื่อน section 8 เป็น 7
