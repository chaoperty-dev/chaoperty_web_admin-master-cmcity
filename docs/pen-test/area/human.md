# Pen Test (Human) — พื้นที่เช่า (AreaMenuPage) — `/area`

> **เอกสารนี้คืออะไร** — manual UI walkthrough สำหรับ top-level menu `/area` (AreaMenuPage)
>
> **Automated test** → [`ai.md`](./ai.md)
>
> **หมายเหตุ**: top-level `/area` คือ dashboard ผู้เช่า (ต่อสัญญา/ประมูล/คืน) — **ไม่ใช่** config พื้นที่ (group/zone/lock) ซึ่งอยู่ใน `/setting` → ดู [`../setting/area-config/`](../../setting/area-config/)

---

## ภาพรวมระบบ

### ฟีเจอร์ที่ทดสอบ
AreaMenuPage — dashboard สำหรับจัดการพื้นที่เช่าของผู้เช่า (user-facing):

```
AreaMenuPage (list + search + filter)
   ├── ต่อสัญญา (Renew) → AreaMenuDetailPage → multi-step form
   ├── ประมูล (Bidding) → AreaMenuDetailPage → bid dialog
   └── คืนพื้นที่ (Return) → AreaMenuDetailPage → return confirmation
```

| Action | คำอธิบาย |
|---|---|
| ต่อสัญญา | ต่ออายุสัญญาเช่าของล็อก/พื้นที่ |
| ประมูล | เข้าร่วมประมูลพื้นที่ว่าง |
| คืนพื้นที่ | ส่งคืนพื้นที่เช่า + ยกเลิกสัญญา |

### API ที่ใช้ (v2 ทั้งหมด — verified ✅)
- `GET /admin/areas/...` — list + filter
- `POST /admin/areas/{id}/renew` — ต่อสัญญา
- `POST /admin/areas/{id}/bid` — ประมูล
- `POST /admin/areas/{id}/return` — คืนพื้นที่
- `GET /admin/areas/{id}` — detail

> **Note**: endpoint path ด้านบนเป็น preliminary — ตรวจสอบจาก `lib/ChiangMai_Municipality/Area_menu/services/area_menu_service.dart` อีกครั้งเพื่อยืนยัน path จริง

### ฟีเจอร์ที่ตัดออก (ถ้ามี)
> TODO: ระบุจาก Explore agent findings (ถ้ามี)

### Baseline
- commit: `6d1a298` (HEAD) "docs(pen-test): relocate existing area-config pentest into new pen-test folder"

---

## สิ่งที่ต้องเตรียม

- ✅ `fvm flutter pub get` เรียบร้อย
- ✅ Login เข้าสู่ระบบ
- ✅ Backend v2 ขึ้นอยู่
- ✅ Browser DevTools Network tab เปิด (filter `admin/areas`)
- ✅ commit ปัจจุบัน `6d1a298` หรือใหม่กว่า

---

## วิธีรัน

```bash
fvm flutter run -d chrome
```

หลังแอปเปิด:
1. Login → เปิดเมนู **พื้นที่เช่า** (ไอคอน map)
2. URL ควรเป็น `/area`
3. DevTools Network tab → filter `admin/areas`

---

## 0. Pre-flight

- [ ] Hot reload สำเร็จ — ไม่มี compile error
- [ ] หน้า `/area` เปิดได้ ไม่มี red error
- [ ] Header แสดง "พื้นที่เช่า" + ปุ่ม action ที่เกี่ยวข้อง
- [ ] Network tab: `GET /admin/areas` (หรือ path ที่ใช้จริง) → status `200`
- [ ] ถ้ามีข้อมูล: list/table/card แสดง row อย่างน้อย 1 row

---

## 1. List + Search + Filter

### 1.1 Initial load
- [ ] เปิดหน้า `/area` → list โหลดทันที
- [ ] Pagination indicator ("1 / N") ปรากฏ
- [ ] ถ้า 0 row → แสดง empty state

### 1.2 Search
- [ ] พิมพ์คำค้น (เช่น "LN001") ใน search box → Enter / debounce
- [ ] List filter ตามคำค้น
- [ ] Network tab: `GET /admin/areas?q=...` → 200
- [ ] Clear search → list กลับมาเต็ม

### 1.3 Filter (ถ้ามี)
- [ ] Filter dropdown (zone, status, type) ทำงาน
- [ ] List filter ตาม dropdown ที่เลือก

### 1.4 Sort
- [ ] Sort by rent / area / expiry date (ถ้ามี)
- [ ] Arrow indicator แสดงทิศทาง sort

### 1.5 Pagination
- [ ] กด **Next** → page 2 โหลด → indicator "2 / N"
- [ ] กด **Prev** → กลับ page 1
- [ ] กด page number ตรงๆ → jump

---

## 2. ต่อสัญญา (Renew)

### 2.1 เปิดฟอร์ม
- [ ] เลือก row ที่ยังไม่หมดอายุ → กดปุ่ม "ต่อสัญญา" (badge/button)
- [ ] Detail page เปิด + step 1 form
- [ ] Fields prefill จาก row ที่เลือก

### 2.2 Step 1 (ข้อมูล)
- [ ] Contract duration (start date / end date)
- [ ] Rent amount (prefill เดิม + แก้ได้)
- [ ] Note / remark
- [ ] Validation: required fields

### 2.3 Step 2 (Review)
- [ ] แสดงสรุปค่าทั้งหมด
- [ ] กด "ยืนยัน" → POST `/admin/areas/{id}/renew`
- [ ] Response 200 → snackbar success
- [ ] List refresh → row อัปเดต (renew date ใหม่)

---

## 3. ประมูล (Bidding)

### 3.1 เปิดฟอร์ม
- [ ] เลือก row ที่มี badge "ว่าง" / "ประมูล"
- [ ] กดปุ่ม "ประมูล" → bid dialog เปิด

### 3.2 กรอก bid
- [ ] Bid amount (ต้อง > minimum)
- [ ] Note
- [ ] กด "ส่งคำเสนอ"
- [ ] POST `/admin/areas/{id}/bid` → 200
- [ ] Snackbar success

### 3.3 Bid history
- [ ] ดู bid history (ถ้ามี — รายการ bid ก่อนหน้า)

---

## 4. คืนพื้นที่ (Return)

### 4.1 Confirm dialog
- [ ] เลือก row ที่มีสัญญา → กดปุ่ม "คืนพื้นที่"
- [ ] Dialog "ยืนยันการคืน" ปรากฏ ถามพื้นที่ + วันที่คืน
- [ ] กด ยกเลิก → dialog ปิด
- [ ] กด ยืนยัน → POST `/admin/areas/{id}/return`

### 4.2 Result
- [ ] Snackbar success
- [ ] Row เปลี่ยนสถานะ (เช่น "คืนแล้ว")
- [ ] List refresh อัตโนมัติ

---

## 5. View mode toggle
> (ถ้ามี)

- [ ] Toggle ระหว่าง table ↔ card view
- [ ] Card view responsive (3 col / 2 col / 1 col)

---

## 6. Edge cases

- [ ] Network down → snackbar error + state ไม่ crash
- [ ] Token expired → redirect login
- [ ] เปิด detail + ปิด + เปิด detail อีก → state reset
- [ ] Pagination overflow → redirect หรือ disable Next

---

## 7. Backend verification

**คาดหวัง**: ทุก request ใช้ v2 (`/admin/...`)

- [ ] ไม่มี `.php` ใน URL ใดๆ ตลอดการทดสอบ
- [ ] ทุก response: status `200`/`201`/`204`
- [ ] ทุก request มี `Authorization: Bearer <token>`
- [ ] Endpoint paths ตรงกับ API table ด้านบน (verify กับ `area_menu_service.dart`)

### Endpoint ที่ใช้บ่อย
- [ ] `GET /admin/areas` (list)
- [ ] `GET /admin/areas/{id}` (detail)
- [ ] `POST /admin/areas/{id}/renew`
- [ ] `POST /admin/areas/{id}/bid`
- [ ] `POST /admin/areas/{id}/return`

---

## 8. Provider scope regression (ถ้าเคยเจอ)

> TODO: ระบุ bug ที่เคยเจอ (เช่น "Could not find Provider<AreaMenuViewModel>") ถ้ามี

---

## เกณฑ์ Pass / Fail

### Pass
- ✅ AI Test ผ่าน (ดู [`ai.md`](./ai.md) — ตอนนี้ยังไม่มี test)
- ✅ Human Test: ทุก checkbox ผ่าน
- ✅ Network tab: ไม่มี `.php`

### Fail
- ❌ Red error บนหน้าจอ
- ❌ Snackbar ข้อความผิด
- ❌ Network request ไม่ตรง expected endpoint
- ❌ Action ไม่ persist (POST สำเร็จ แต่ list ไม่ refresh)

---

## ปัญหาที่เคยเจอและแก้แล้ว

> TODO: เพิ่มเมื่อเจอ bug ระหว่าง test

---

**จบเอกสาร** — ถ้ามี sub-flow ใหม่ (เช่น transfer, terminate) เพิ่ม section ที่นี่
