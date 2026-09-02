# Pen Test (Human) — ตรวจเอกสารคำขอ (LicenseVerifyPage) — `/verify`

> **เอกสารนี้คืออะไร** — manual UI walkthrough สำหรับ menu `/verify` (LicenseVerifyPage — ตรวจสอบเอกสารคำขอใบอนุญาต + signature pad)
>
> **Automated test** → [`ai.md`](./ai.md)
>
> **Cross-links**:
> - Master index → [`../../README.md`](../../README.md)
> - ก่อนหน้าใน flow: [`../attach/`](../attach/) (แนบเอกสาร)
> - ขั้นถัดไป: [`../fact-check/`](../fact-check/) (ตรวจข้อเท็จจริง)

---

## ภาพรวมระบบ

### ฟีเจอร์ที่ทดสอบ
LicenseVerifyPage — หน้าตรวจสอบเอกสารคำขอใบอนุญาต (inspector/reviewer view):

```
LicenseVerifyPage (list + search + filter + zone)
   └── LicenseVerifyDetailPage
        ├── Step 1: รายการเอกสาร (checklist + preview)
        └── Step 2: ผลการตรวจ + signature pad (approve/reject)
```

| Action | คำอธิบาย |
|---|---|
| ตรวจเอกสาร | ตรวจ uploaded documents ตาม checklist |
| ลงลายเซ็น | signature pad ของ reviewer ก่อนยืนยัน |
| อนุมัติเอกสาร | approve document → step submit |
| ปฏิเสธเอกสาร | reject document + เหตุผล |

### API ที่ใช้ (v2 list + v1 approval flow — verified ✅)
**v2 list/tasks**:
- `GET /v2/admin/requests/tasks/inspections` — list งานตรวจเอกสาร
- `GET /v2/admin/requests/tasks/attachments` — list attachments

**v1 approval flow** (legacy — ใช้ร่วมกับ fact-check/submit-approval/approve):
- `GET /admin/approvals` — list approvals
- `GET /admin/approvals/{requestUuid}/flow` — flow uuid list
- `POST /admin/approvals/{requestUuid}/review` — submit review
- `POST /admin/approvals/{requestUuid}/flow/{flowUuid}/approve` — approve flow

**v1 request/checklist**:
- `GET /admin/requests/{uuid}` — request detail
- `GET /admin/requests/{uuid}/checklist` — saved checklist
- `GET /admin/requests/{uuid}/checklist/preview` — checklist preview
- `POST /admin/requests/{uuid}/checklist` — submit checklist
- `GET /admin/requests/{requestUuid}/attachments` — attachments list
- `GET /admin/requests/attachments/{attachmentUuid}/preview` — preview attachment

> **Note**: endpoint path ด้านบนเป็น preliminary — ตรวจสอบจาก `lib/.../license_verify_page/services/license_verify_service.dart` อีกครั้งเพื่อยืนยัน path จริง

### ฟีเจอร์ที่ตัดออก (ถ้ามี)
> TODO: ระบุถ้ามี

### Baseline
- commit: `6d1a298` (HEAD) "docs(pen-test): relocate existing area-config pentest into new pen-test folder"

---

## สิ่งที่ต้องเตรียม

- ✅ `fvm flutter pub get` เรียบร้อย
- ✅ Login เข้าสู่ระบบ (สิทธิ์ reviewer/inspector)
- ✅ Backend v1 + v2 ขึ้นอยู่
- ✅ Browser DevTools Network tab เปิด (filter `admin/requests|admin/approvals`)
- ✅ commit ปัจจุบัน `6d1a298` หรือใหม่กว่า

---

## วิธีรัน

```bash
fvm flutter run -d chrome
```

หลังแอปเปิด:
1. Login → เปิดเมนู **ใบอนุญาต › ตรวจเอกสาร**
2. URL ควรเป็น `/verify`
3. DevTools Network tab → filter `admin/requests/tasks/inspections`

---

## 0. Pre-flight

- [ ] Hot reload สำเร็จ — ไม่มี compile error
- [ ] หน้า `/verify` เปิดได้ ไม่มี red error
- [ ] Header แสดง "ตรวจเอกสารคำขอ" + ปุ่ม action ที่เกี่ยวข้อง
- [ ] Network tab: `GET /v2/admin/requests/tasks/inspections` → status `200`
- [ ] ถ้ามีข้อมูล: list/table แสดง row อย่างน้อย 1 row

---

## 1. List + Search + Filter

### 1.1 Initial load
- [ ] เปิดหน้า `/verify` → list โหลดทันที
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

## 2. Document Checklist (Detail Step 1)

### 2.1 เปิด detail
- [ ] กด row → detail page เปิด → step 1 active
- [ ] Network: `GET /admin/requests/{uuid}/checklist` → 200
- [ ] แสดงรายการเอกสารที่ต้องตรวจ (checklist items)

### 2.2 รายการเอกสารแต่ละรายการ
- [ ] แต่ละ item: ชื่อเอกสาร, ประเภท, badge (รอตรวจ/ผ่าน/ไม่ผ่าน)
- [ ] กด item → preview dialog เปิด (`VerifyFilePreviewDialog`)
- [ ] Network: `GET /admin/requests/attachments/{attachmentUuid}/preview` → 200
- [ ] ปิด preview → กลับมา detail

### 2.3 ตรวจเอกสาร (per-item)
- [ ] แต่ละ item มีปุ่ม **ผ่าน** / **ไม่ผ่าน** / **N/A**
- [ ] กด **ผ่าน** → badge เปลี่ยนเป็นสีเขียว
- [ ] กด **ไม่ผ่าน** → เปิด comment box กรอกเหตุผล
- [ ] กด **N/A** → badge "ไม่เกี่ยวข้อง"

### 2.4 บันทึก checklist draft
- [ ] กด "บันทึกร่าง" → POST `/admin/requests/{uuid}/checklist` → 200
- [ ] Snackbar success
- [ ] ออกจาก detail + กลับเข้า → state persist

---

## 3. Signature Pad (Detail Step 2)

### 3.1 เปิด step 2
- [ ] กด "ถัดไป" → step 2 active
- [ ] แสดงสรุป checklist (จำนวนผ่าน/ไม่ผ่าน/N-A)

### 3.2 วาดลายเซ็น
- [ ] Signature pad ปรากฏ (canvas)
- [ ] ลากนิ้ว/เมาส์ → เส้นลายเซ็นแสดง
- [ ] ปุ่ม **ล้าง** → canvas ว่าง
- [ ] ปุ่ม **บันทึกลายเซ็น** → upload base64

### 3.3 Verify actions (per document)
- [ ] ปุ่ม **อนุมัติเอกสาร** (approve) ต่อ document
- [ ] ปุ่ม **ปฏิเสธ** (reject) + เหตุผล ต่อ document
- [ ] Confirm dialog → ยืนยัน → action success

### 3.4 Submit verify result
- [ ] กด "ยืนยันการตรวจ" → POST `/admin/approvals/{requestUuid}/review` → 200
- [ ] Snackbar success
- [ ] List refresh → row เปลี่ยนสถานะ (เช่น "ตรวจแล้ว")

---

## 4. Edge cases

- [ ] Network down → snackbar error + state ไม่ crash
- [ ] Token expired → redirect login
- [ ] Signature pad ไม่ได้วาด → submit block + message "กรุณาลงลายเซ็น"
- [ ] Checklist ไม่ครบ → submit block + highlight item ที่ขาด
- [ ] เปิด detail + ปิด + เปิด detail อีก → state reset
- [ ] Pagination overflow → redirect หรือ disable Next
- [ ] Attachment preview fail (PDF corrupt) → snackbar + skip ได้

---

## 5. Backend verification

**คาดหวัง**: v2 list + v1 approval/checklist flow (mixed v1+v2 แต่ไม่มี PHP)

- [ ] ไม่มี `.php` ใน URL ใดๆ ตลอดการทดสอบ
- [ ] ทุก response: status `200`/`201`/`204`
- [ ] ทุก request มี `Authorization: Bearer <token>`
- [ ] Endpoint paths ตรงกับ API table ด้านบน (verify กับ service files)

### Endpoint ที่ใช้บ่อย
- [ ] `GET /v2/admin/requests/tasks/inspections` (list)
- [ ] `GET /v2/admin/requests/tasks/attachments` (attachments)
- [ ] `GET /admin/requests/{uuid}` (detail)
- [ ] `GET /admin/requests/{uuid}/checklist` (saved checklist)
- [ ] `GET /admin/requests/{uuid}/checklist/preview` (preview)
- [ ] `POST /admin/requests/{uuid}/checklist` (submit)
- [ ] `POST /admin/approvals/{requestUuid}/review` (submit review)
- [ ] `POST /admin/approvals/{requestUuid}/flow/{flowUuid}/approve` (approve flow)

---

## 6. Provider scope regression (ถ้าเคยเจอ)

> TODO: ระบุ bug ที่เคยเจอ (เช่น "Could not find Provider<LicenseVerifyViewModel>") ถ้ามี

---

## เกณฑ์ Pass / Fail

### Pass
- ✅ ทุก checkbox ใน section 0-4 ผ่าน
- ✅ Network tab ไม่มี `.php`
- ✅ Backend verification section 5 ทุกข้อ ✅
- ✅ Signature pad ใช้งานได้ (draw + clear + upload)
- ✅ Checklist submit → status เปลี่ยน

### Fail
- ❌ Red error บนหน้าจอ
- ❌ Signature pad ไม่ตอบสนอง (draw ไม่ออก)
- ❌ Checklist submit fail / state ไม่ persist
- ❌ Snackbar ข้อความผิด
- ❌ PHP endpoint ที่ไม่อยู่ใน list → unexpected, ต้อง flag

---

## ปัญหาที่เคยเจอและแก้แล้ว

> TODO: เพิ่มเมื่อเจอ bug

---

**จบเอกสาร** — หลัง menu นี้ stable และไม่มี `.php` ค้าง → flip สถานะใน [`../../README.md`](../../README.md) เป็น v2 ✅
