# Pen Test (Human) — ตรวจข้อเท็จจริง (LicenseFactCheckPage) — `/fact-check`

> **เอกสารนี้คืออะไร** — manual UI walkthrough สำหรับ menu `/fact-check` (LicenseFactCheckPage — ตรวจสอบข้อเท็จจริงภาคสนาม/inspector)
>
> **Automated test** → [`ai.md`](./ai.md)
>
> **Cross-links**:
> - Master index → [`../../README.md`](../../README.md)
> - ก่อนหน้าใน flow: [`../verify/`](../verify/) (ตรวจเอกสาร)
> - ขั้นถัดไป: [`../submit-approval/`](../submit-approval/) (ส่งอนุมัติ)

---

## ภาพรวมระบบ

### ฟีเจอร์ที่ทดสอบ
LicenseFactCheckPage — หน้าตรวจสอบข้อเท็จจริง (inspector ลงพื้นที่ยืนยันข้อมูล):

```
LicenseFactCheckPage (list + search + filter + zone)
   └── LicenseFactCheckDetailPage
        ├── Step 1: ฟอร์มตรวจข้อเท็จจริง (location, time, findings)
        └── Step 2: ผลการตรวจ (verified / not verified + reason)
```

| Action | คำอธิบาย |
|---|---|
| ตรวจข้อเท็จจริง | ตรวจสอบข้อมูลคำขอด้วยตัวเอง (ลงพื้นที่) |
| ยืนยันข้อเท็จจริง | verified → step submit |
| ไม่ยืนยันข้อเท็จจริง | not verified + เหตุผล |

### API ที่ใช้ (v2 list + v1 inspection — verified ✅)
**v2 list**:
- `GET /v2/admin/requests/tasks/inspections` — list งานตรวจข้อเท็จจริง

**v1 inspection** (POST/GET):
- `POST /admin/requests/{requestUuid}/inspection` — submit inspection
- `GET /admin/requests/{requestUuid}/inspection` — load inspection

**v1 approval flow** (legacy — ใช้ร่วมกับ verify/submit-approval/approve):
- `GET /admin/approvals` — list approvals
- `POST /admin/approvals/{requestUuid}/review` — submit review
- `GET /admin/approvals/lastaction` — last action history

> **Note**: endpoint path ด้านบนเป็น preliminary — ตรวจสอบจาก `lib/.../license_fact_check_page/services/license_fact_check_service.dart` อีกครั้งเพื่อยืนยัน path จริง

### ฟีเจอร์ที่ตัดออก (ถ้ามี)
> TODO: ระบุถ้ามี

### Baseline
- commit: `6d1a298` (HEAD) "docs(pen-test): relocate existing area-config pentest into new pen-test folder"

---

## สิ่งที่ต้องเตรียม

- ✅ `fvm flutter pub get` เรียบร้อย
- ✅ Login เข้าสู่ระบบ (สิทธิ์ inspector)
- ✅ Backend v1 + v2 ขึ้นอยู่
- ✅ Browser DevTools Network tab เปิด (filter `admin/requests/tasks/inspections|admin/requests/.*inspection`)
- ✅ commit ปัจจุบัน `6d1a298` หรือใหม่กว่า

---

## วิธีรัน

```bash
fvm flutter run -d chrome
```

หลังแอปเปิด:
1. Login → เปิดเมนู **ใบอนุญาต › ตรวจข้อเท็จจริง**
2. URL ควรเป็น `/fact-check`
3. DevTools Network tab → filter `admin/requests/tasks/inspections`

---

## 0. Pre-flight

- [ ] Hot reload สำเร็จ — ไม่มี compile error
- [ ] หน้า `/fact-check` เปิดได้ ไม่มี red error
- [ ] Header แสดง "ตรวจข้อเท็จจริง" + ปุ่ม action ที่เกี่ยวข้อง
- [ ] Network tab: `GET /v2/admin/requests/tasks/inspections` → status `200`
- [ ] ถ้ามีข้อมูล: list/table แสดง row อย่างน้อย 1 row

---

## 1. List + Search + Filter

### 1.1 Initial load
- [ ] เปิดหน้า `/fact-check` → list โหลดทันที
- [ ] Pagination indicator ("1 / N") ปรากฏ
- [ ] ถ้า 0 row → แสดง empty state

### 1.2 Search
- [ ] พิมพ์คำค้น (ชื่อผู้เช่า / เลขคำขอ / เลขบัตร) ใน search box → debounce
- [ ] List filter ตามคำค้น
- [ ] Network tab: `GET /v2/admin/requests/tasks/inspections?q=...` → 200
- [ ] Clear search → list กลับมาเต็ม

### 1.3 Zone filter
- [ ] Filter dropdown (zone) ทำงาน
- [ ] List filter ตาม zone ที่เลือก
- [ ] Zone selection persist ระหว่าง session (ใช้ `zone_selection_store.dart`)

### 1.4 Sort
- [ ] Sort by date / status / requester (ถ้ามี)
- [ ] Arrow indicator แสดงทิศทาง sort

### 1.5 Pagination
- [ ] กด **Next** → page 2 โหลด → indicator "2 / N"
- [ ] กด **Prev** → กลับ page 1
- [ ] กด page number ตรงๆ → jump

---

## 2. Fact-Check Form (Detail Step 1)

### 2.1 เปิด detail
- [ ] กด row → detail page เปิด → step 1 active
- [ ] Network: `GET /admin/requests/{requestUuid}/inspection` → 200 (ถ้ามี draft)
- [ ] แสดงฟอร์มตรวจข้อเท็จจริง

### 2.2 Field inspection details
- [ ] **วันที่ตรวจ**: date picker → บันทึกค่า
- [ ] **เวลาตรวจ**: time picker → บันทึกค่า
- [ ] **สถานที่ตรวจ**: text field (prefill จาก request data)
- [ ] **ผู้ตรวจ**: prefill จาก logged-in user (ดู `unity/API_admin_signature.dart` และ `unity/FormatPhone.dart`)
- [ ] **หมายเหตุ/ข้อสังเกต**: multi-line text field

### 2.3 ตรวจรายการข้อเท็จจริง
- [ ] แต่ละรายการ: คำถาม/ข้อเท็จจริง, badge (ตรง/ไม่ตรง/บางส่วน)
- [ ] กด **ตรง** → badge เปลี่ยนเป็นสีเขียว
- [ ] กด **ไม่ตรง** → เปิด comment box กรอกเหตุผล
- [ ] กด **บางส่วน** → comment box + ระบุส่วนที่ตรง/ไม่ตรง

### 2.4 Photo upload (ถ้ามี)
- [ ] ปุ่ม **แนบรูปภาพหลักฐาน** → file picker
- [ ] Upload → preview thumbnail แสดง
- [ ] ลบรูป → thumbnail หาย

### 2.5 Validation
- [ ] Required fields: วันที่/เวลา/สถานที่
- [ ] ถ้าไม่กรอก → submit block + highlight field ที่ขาด

---

## 3. Verify Result (Detail Step 2)

### 3.1 เปิด step 2
- [ ] กด "ถัดไป" → step 2 active
- [ ] แสดงสรุปผลการตรวจ (จำนวนตรง/ไม่ตรง/บางส่วน)

### 3.2 ผลการตรวจ
- [ ] Radio: **ยืนยันข้อเท็จจริง** (verified)
- [ ] Radio: **ไม่ยืนยันข้อเท็จจริง** (not verified) + text area กรอกเหตุผล
- [ ] Validation: ถ้าเลือก "ไม่ยืนยัน" → ต้องกรอกเหตุผล

### 3.3 Submit fact-check
- [ ] กด "ยืนยันการตรวจ" → POST `/admin/requests/{requestUuid}/inspection` → 200
- [ ] Snackbar success
- [ ] List refresh → row เปลี่ยนสถานะ (เช่น "ตรวจแล้ว")

---

## 4. Edge cases

- [ ] Network down → snackbar error + state ไม่ crash
- [ ] Token expired → redirect login
- [ ] ฟอร์มไม่ครบ → submit block + highlight field ที่ขาด
- [ ] Photo upload fail → snackbar error + retry ได้
- [ ] เปิด detail + ปิด + เปิด detail อีก → state reset
- [ ] Pagination overflow → redirect หรือ disable Next

---

## 5. Backend verification

**คาดหวัง**: v2 list + v1 inspection/approval flow (mixed v1+v2 แต่ไม่มี PHP)

- [ ] ไม่มี `.php` ใน URL ใดๆ ตลอดการทดสอบ
- [ ] ทุก response: status `200`/`201`/`204`
- [ ] ทุก request มี `Authorization: Bearer <token>`
- [ ] Endpoint paths ตรงกับ API table ด้านบน (verify กับ service files)

### Endpoint ที่ใช้บ่อย
- [ ] `GET /v2/admin/requests/tasks/inspections` (list)
- [ ] `GET /admin/requests/{requestUuid}/inspection` (load)
- [ ] `POST /admin/requests/{requestUuid}/inspection` (submit)
- [ ] `POST /admin/approvals/{requestUuid}/review` (submit review)

---

## 6. Provider scope regression (ถ้าเคยเจอ)

> TODO: ระบุ bug ที่เคยเจอ (เช่น "Could not find Provider<LicenseFactCheckViewModel>") ถ้ามี

---

## เกณฑ์ Pass / Fail

### Pass
- ✅ ทุก checkbox ใน section 0-4 ผ่าน
- ✅ Network tab ไม่มี `.php`
- ✅ Backend verification section 5 ทุกข้อ ✅
- ✅ ฟอร์ม fact-check ใช้งานได้ครบ (date/time/location/findings)
- ✅ Submit fact-check → status เปลี่ยน

### Fail
- ❌ Red error บนหน้าจอ
- ❌ Photo upload fail (ถ้ามี) → submit block
- ❌ Submit inspection fail / state ไม่ persist
- ❌ Snackbar ข้อความผิด
- ❌ PHP endpoint ที่ไม่อยู่ใน list → unexpected, ต้อง flag

---

## ปัญหาที่เคยเจอและแก้แล้ว

> TODO: เพิ่มเมื่อเจอ bug

---

**จบเอกสาร** — หลัง menu นี้ stable และไม่มี `.php` ค้าง → flip สถานะใน [`../../README.md`](../../README.md) เป็น v2 ✅
