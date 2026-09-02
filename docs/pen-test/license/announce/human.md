# Pen Test (Human) — ประกาศคำขอใบอนุญาต — `/announce`

> ✅ **v2 API** — เมนูนี้ใช้ v2 ทั้งหมด
>
> **Automated test** → [`ai.md`](./ai.md)
>
> **Cross-link**: [`../contract/`](../contract/) (ลูกค้าที่ถูกประกาศจะถูกใช้เป็นตัวเลือกใน contract)

---

## ภาพรวมระบบ

### ฟีเจอร์ที่ทดสอบ
LicenseAnnouncePage — หน้าจัดการประกาศคำขอใบอนุญาต (admin เป็นคนสร้างประกาศ เพื่อให้ลูกค้ามาเลือกทำคำขอ):

```
LicenseAnnouncePage (list + search + zone filter)
   ├── Add announcement → LicenseAnnounceAddPage → form submit
   ├── Row tap → LicenseAnnounceDetailPage (read-only)
   └── Edit → LicenseAnnounceEditPage → PATCH → list refresh
```

| Action | คำอธิบาย |
|---|---|
| List + Search | ดูประกาศทั้งหมด + ค้นหา |
| Add | สร้างประกาศใหม่ (admin) |
| Edit | แก้ไขประกาศ |
| Delete | ลบประกาศ |
| Detail | ดูรายละเอียดประกาศ |

### API ที่ใช้ (v2 ทั้งหมด — verified ✅)
- `GET /admin/announcements` — list + filter
- `GET /admin/announcements/{id}` — detail
- `POST /admin/announcements` — create
- `PUT /admin/announcements/{id}` — update
- `DELETE /admin/announcements/{id}` — delete

> **Note**: endpoint path ด้านบนเป็น preliminary — ตรวจสอบจาก `lib/ChiangMai_Municipality/License_menu/license_announce_page/services/license_announce_service.dart` อีกครั้งเพื่อยืนยัน path จริง

### ฟีเจอร์ที่ตัดออก (ถ้ามี)
> TODO: ระบุจาก Explore agent findings (ถ้ามี)

### Baseline
- commit: `6d1a298` (HEAD) "docs(pen-test): relocate existing area-config pentest into new pen-test folder"

---

## สิ่งที่ต้องเตรียม

- ✅ `fvm flutter pub get` เรียบร้อย
- ✅ Login เข้าสู่ระบบ (admin role)
- ✅ Backend v2 ขึ้นอยู่
- ✅ Browser DevTools Network tab เปิด (filter `admin/announcements`)
- ✅ commit ปัจจุบัน `6d1a298` หรือใหม่กว่า

---

## วิธีรัน

```bash
fvm flutter run -d chrome
```

หลังแอปเปิด:
1. Login → เปิดเมนู **ใบอนุญาต › ประกาศ** (ไอคอน campaign)
2. URL ควรเป็น `/announce`
3. DevTools Network tab → filter `admin/announcements`

---

## 0. Pre-flight

- [ ] Hot reload สำเร็จ — ไม่มี compile error
- [ ] หน้า `/announce` เปิดได้ ไม่มี red error
- [ ] Header แสดง "ประกาศคำขอใบอนุญาต" + ปุ่ม "เพิ่มประกาศ"
- [ ] Network tab: `GET /admin/announcements` → status `200`
- [ ] ถ้ามีข้อมูล: list/table แสดง row อย่างน้อย 1 row

---

## 1. List + Search

### 1.1 Initial load
- [ ] เปิดหน้า `/announce` → list โหลดทันที
- [ ] Pagination indicator ("1 / N") ปรากฏ
- [ ] ถ้า 0 row → แสดง empty state

### 1.2 Search
- [ ] พิมพ์คำค้น (เช่น "คำขอ A") ใน search box → debounce
- [ ] List filter ตามคำค้น
- [ ] Network tab: `GET /admin/announcements?q=...` → 200
- [ ] Clear search → list กลับมาเต็ม

### 1.3 Zone filter
- [ ] Filter dropdown (โซน) ทำงาน
- [ ] List filter ตาม dropdown ที่เลือก

### 1.4 Sort
- [ ] Sort by date / status (ถ้ามี)
- [ ] Arrow indicator แสดงทิศทาง sort

### 1.5 Pagination
- [ ] กด **Next** → page 2 โหลด → indicator "2 / N"
- [ ] กด **Prev** → กลับ page 1
- [ ] กด page number ตรงๆ → jump

---

## 2. Add announcement (form)

### 2.1 เปิดฟอร์ม
- [ ] กดปุ่ม **เพิ่มประกาศ** → form page เปิด
- [ ] Fields ว่าง (ไม่ prefill)
- [ ] Validation: required fields

### 2.2 กรอกฟอร์ม
- [ ] หัวข้อประกาศ (title)
- [ ] รายละเอียด (description)
- [ ] วันที่เริ่ม / วันที่สิ้นสุด
- [ ] โซนที่เกี่ยวข้อง
- [ ] สถานะ (active / draft)

### 2.3 Submit
- [ ] กด **บันทึก** → POST `/admin/announcements`
- [ ] Response 200/201 → snackbar success
- [ ] Redirect กลับหน้า list
- [ ] Row ใหม่ปรากฏใน list

---

## 3. Edit

### 3.1 เปิดฟอร์ม
- [ ] เลือก row → กดปุ่ม **แก้ไข**
- [ ] Edit page เปิด + form prefill จาก row
- [ ] Step 1 form แสดงข้อมูลเดิมครบ

### 3.2 แก้ไข + Submit
- [ ] แก้ field → กด **บันทึก** → PUT `/admin/announcements/{id}`
- [ ] Response 200 → snackbar success
- [ ] List refresh → row อัปเดต

---

## 4. Delete

### 4.1 Confirm dialog
- [ ] เลือก row → กดปุ่ม **ลบ**
- [ ] Dialog "ยืนยันการลบ" ปรากฏ
- [ ] กด ยกเลิก → dialog ปิด
- [ ] กด ยืนยัน → DELETE `/admin/announcements/{id}`

### 4.2 Result
- [ ] Snackbar success
- [ ] Row หายจาก list
- [ ] List refresh อัตโนมัติ

---

## 5. Detail

### 5.1 เปิด detail
- [ ] กด row → detail page เปิด
- [ ] แสดงข้อมูลครบ: หัวข้อ, รายละเอียด, วันที่, โซน, สถานะ

### 5.2 Footer actions
- [ ] ปุ่ม **แก้ไข** → ไป edit page
- [ ] ปุ่ม **ลบ** → confirm dialog

---

## 6. Edge cases

- [ ] Network down → snackbar error + state ไม่ crash
- [ ] Token expired → redirect login
- [ ] เปิด detail + ปิด + เปิด detail อีก → state reset
- [ ] Pagination overflow → redirect หรือ disable Next
- [ ] Form submit 2 ครั้งซ้อน → block ปุ่ม หรือ disable ขณะ pending
- [ ] Network 504 / 500 → snackbar error message

---

## 7. Backend verification

**คาดหวัง**: ทุก request ใช้ v2 (`/admin/...`)

- [ ] ไม่มี `.php` ใน URL ใดๆ ตลอดการทดสอบ
- [ ] ทุก response: status `200`/`201`/`204`
- [ ] ทุก request มี `Authorization: Bearer <token>`
- [ ] Endpoint paths ตรงกับ API table ด้านบน (verify กับ `license_announce_service.dart`)

### Endpoint ที่ใช้บ่อย
- [ ] `GET /admin/announcements` (list)
- [ ] `GET /admin/announcements/{id}` (detail)
- [ ] `POST /admin/announcements` (create)
- [ ] `PUT /admin/announcements/{id}` (update)
- [ ] `DELETE /admin/announcements/{id}` (delete)

---

## 8. Regression (ถ้าเคยเจอ)

> TODO: เพิ่มเมื่อเจอ bug

---

## เกณฑ์ Pass / Fail

### Pass
- ✅ AI Test ผ่าน (ถ้ามี)
- ✅ Human Test ทุก checkbox ผ่าน
- ✅ Network tab: ไม่มี `.php`
- ✅ Backend verification section 7 ทุกข้อ ✅

### Fail
- ❌ Red error บนหน้าจอ
- ❌ Snackbar ข้อความผิด
- ❌ List ไม่ refresh หลัง create/edit/delete

---

## ปัญหาที่เคยเจอและแก้แล้ว

> TODO: เพิ่มเมื่อเจอ bug

---

**จบเอกสาร**