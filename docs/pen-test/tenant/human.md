# Pen Test (Human) — ผู้เช่า — `/tenant`

> ⚠️ **MIGRATION PENDING** — เมนูนี้ยังใช้ **PHP legacy** — Network จะเห็น `.php` request (expected ตอนนี้)
>
> **Automated test** → [`ai.md`](./ai.md)

---

## ภาพรวมระบบ

### ฟีเจอร์ที่ทดสอบ
TenantLicensePage — หน้ารายชื่อผู้เช่า + detail (person/shop/license/contract info)

```
TenantLicensePage (list + search + filter)
   └── TenantLicenseDetailPage → person info / shop info / license history
```

### API ที่ใช้ (ตอนนี้ PHP — ต้อง migrate ⚠️)
- `GET GC_tenantAll_V2.php` — list tenants
- (Detail endpoints อาจยัง PHP อยู่ — ตรวจ `tenant_license_service.dart` อีกครั้ง)

> **Target v2** (หลัง migrate):
> - `GET /admin/tenants` — list
> - `GET /admin/tenants/{id}` — detail

### Baseline
- commit: `6d1a298` (HEAD)

---

## สิ่งที่ต้องเตรียม

- ✅ `fvm flutter pub get`
- ✅ Login
- ✅ **PHP backend** ขึ้นอยู่ (ยังต้องใช้จนกว่าจะ migrate เสร็จ)
- ✅ DevTools Network tab — filter `tenant` (คาดว่าจะเห็น `.php`)
- ✅ commit `6d1a298`

---

## วิธีรัน

```bash
fvm flutter run -d chrome
```

หลังแอปเปิด:
1. Login → เมนู **ผู้เช่า** (ไอคอน people)
2. URL ควรเป็น `/tenant`

---

## 0. Pre-flight

- [ ] Hot reload สำเร็จ
- [ ] หน้า `/tenant` เปิดได้ ไม่มี red error
- [ ] Network tab: `GET GC_tenantAll_V2.php` → status `200` (PHP — expected)
- [ ] ถ้ามีข้อมูล: list แสดง row อย่างน้อย 1 row

---

## 1. List + Search

### 1.1 Initial load
- [ ] เปิดหน้า `/tenant` → list โหลดทันที
- [ ] Pagination indicator ("1 / N") ปรากฏ
- [ ] Empty state ถ้า 0 row

### 1.2 Search
- [ ] พิมพ์คำค้น (เช่น "บริษัท A") → list filter
- [ ] Network: `GET GC_tenantAll_V2.php?q=...` → 200
- [ ] Clear search → list กลับเต็ม

### 1.3 Filter (ถ้ามี)
- [ ] Filter by shop type / status / zone (ถ้ามี)
- [ ] List filter ตาม dropdown

### 1.4 Pagination
- [ ] Next / Prev / page number ทำงาน

---

## 2. Detail page

### 2.1 เปิด detail
- [ ] กด row → detail page เปิด
- [ ] Tabs/sections: ข้อมูลส่วนตัว / ข้อมูลร้าน / ประวัติใบอนุญาต / สัญญา
- [ ] แต่ละ section แสดงข้อมูลครบ

### 2.2 Section แต่ละอัน
- [ ] **ข้อมูลส่วนตัว**: ชื่อ-นามสกุล, เลขบัตร, ที่อยู่, เบอร์โทร
- [ ] **ข้อมูลร้าน**: ชื่อร้าน, ประเภท, ทะเบียนการค้า
- [ ] **ประวัติใบอนุญาต**: list ของ license ที่เคยได้
- [ ] **สัญญา**: contract ปัจจุบัน + ประวัติ

---

## 3. Edge cases

- [ ] Network down → snackbar error + state ไม่ crash
- [ ] Token expired → redirect login
- [ ] Detail page + back + เปิด detail อีก → state reset

---

## 4. Backend verification (CURRENT STATE)

**คาดหวังตอนนี้**: ⚠️ PHP requests (เพราะยัง migrate ไม่เสร็จ — ห้าม fail test เพราะเรื่องนี้)

- [ ] `GET GC_tenantAll_V2.php` → 200 (PHP — expected)
- [ ] ทุก response: status `200`/`204`
- [ ] ทุก request มี `Authorization: Bearer <token>`

---

## 5. Backend verification (POST-MIGRATION TARGET)

> ใช้ checklist นี้หลัง migrate PHP → v2 เสร็จ

- [ ] ❌ **ไม่มี `.php`** ใน URL
- [ ] `GET /admin/tenants` → 200
- [ ] `GET /admin/tenants/{id}` → 200
- [ ] ทุก mutation (ถ้ามี) ใช้ v2

---

## 6. Regression (ถ้าเคยเจอ)

> TODO: เพิ่มเมื่อเจอ bug

---

## Migration blocking checklist

> ทำ checklist นี้ก่อน mark menu นี้เป็น "v2 ✅" ใน README index

- [ ] Backend มี `GET /admin/tenants` (พร้อม pagination/search contract)
- [ ] `TenantLicenseService` ใช้ `domain_v2` แทน `domain` (legacy PHP root)
- [ ] ลบ import/fallback ทุกที่
- [ ] Manual test section 4 → 5 (ทุก checkbox ✅)
- [ ] เขียน unit test ครอบ v2 path (ดู [`ai.md`](./ai.md))
- [ ] อัปเดต README index — flip สถานะเป็น v2 ✅

---

## เกณฑ์ Pass / Fail

### Pass (post-migration)
- ✅ AI Test ผ่าน
- ✅ Human Test ทุก checkbox ผ่าน
- ✅ Network tab: ไม่มี `.php`
- ✅ Backend verification section 5 ทุกข้อ ✅

### Pass (current — pre-migration)
- ⚠️ AI Test ยังไม่มี (TBD)
- ⚠️ Network tab มี `.php` (expected จนกว่าจะ migrate)
- ✅ ฟีเจอร์ทำงานได้ปกติ (functional smoke)

### Fail
- ❌ Red error บนหน้าจอ
- ❌ Snackbar ข้อความผิด
- ❌ PHP endpoint ที่ไม่อยู่ใน list → unexpected, ต้อง flag

---

## ปัญหาที่เคยเจอและแก้แล้ว

> TODO: เพิ่มเมื่อเจอ bug

---

**จบเอกสาร** — หลัง migrate เสร็จ ลบ section 4 (current state) และเลื่อน section 5 เป็น 4
