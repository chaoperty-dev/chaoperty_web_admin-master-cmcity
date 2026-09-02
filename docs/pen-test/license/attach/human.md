# Pen Test (Human) — แนบเอกสารคำขอ — `/attach`

> ✅ **v2 API** — เมนูนี้ใช้ v2 ทั้งหมด
>
> **Automated test** → [`ai.md`](./ai.md)
>
> **Cross-link**: [`../contract/`](../contract/) (คำขอที่จะแนบเอกสาร) · [`../verify/`](../verify/) (ส่งต่อตรวจเอกสาร)

---

## ภาพรวมระบบ

### ฟีเจอร์ที่ทดสอบ
LicenseAttachPage — หน้าจัดการเอกสารแนบคำขอใบอนุญาต (อัปโหลด + checklist + batch upload + ลายเซ็น)

```
LicenseAttachPage (list + search + filter)
   └── LicenseAttachDetailPage
       ├── Step 1 — Checklist (รายการเอกสารที่ต้องแนบ + upload)
       ├── Step 2 — Signature pad + ลายเซ็นดิจิทัล
       └── AttachBatchUploadSheet (อัปโหลดหลายไฟล์พร้อมกัน)
```

| Action | คำอธิบาย |
|---|---|
| List + Filter | ดูคำขอทั้งหมด + ค้นหา |
| Upload document | อัปโหลดเอกสารแนบทีละไฟล์ |
| Batch upload | อัปโหลดหลายไฟล์พร้อมกัน |
| Delete document | ลบเอกสารที่อัปโหลดผิด |
| Signature | วาดลายเซ็นดิจิทัล + ส่ง |
| Checklist | ติ๊ม checklist ตามเอกสารที่แนบ |
| Preview | ดูตัวอย่างไฟล์ (image / PDF) |

### API ที่ใช้ (v2 ทั้งหมด — verified ✅)
- `GET /admin/attach/requests` — list
- `GET /admin/attach/requests/{id}` — detail
- `GET /admin/attach/requests/{id}/checklist` — checklist state
- `POST /admin/attach/requests/{id}/documents` — upload document
- `POST /admin/attach/requests/{id}/documents/batch` — batch upload
- `DELETE /admin/attach/requests/{id}/documents/{docId}` — delete
- `POST /admin/attach/requests/{id}/signature` — submit signature
- `GET /admin/attach/requests/{id}/documents/{docId}/preview` — file preview URL

> **Note**: endpoint path ด้านบนเป็น preliminary — ตรวจสอบจาก `lib/ChiangMai_Municipality/License_menu/license_attach_page/services/` อีกครั้งเพื่อยืนยัน path จริง

### ฟีเจอร์ที่ตัดออก (ถ้ามี)
> TODO: ระบุจาก Explore agent findings (ถ้ามี)

### Baseline
- commit: `6d1a298` (HEAD) "docs(pen-test): relocate existing area-config pentest into new pen-test folder"

---

## สิ่งที่ต้องเตรียม

- ✅ `fvm flutter pub get` เรียบร้อย
- ✅ Login เข้าสู่ระบบ
- ✅ Backend v2 ขึ้นอยู่
- ✅ Browser DevTools Network tab เปิด (filter `admin/attach`)
- ✅ ไฟล์ทดสอบ: รูปภาพ (.jpg/.png), PDF (.pdf), เอกสารที่ valid
- ✅ commit ปัจจุบัน `6d1a298` หรือใหม่กว่า

---

## วิธีรัน

```bash
fvm flutter run -d chrome
```

หลังแอปเปิด:
1. Login → เปิดเมนู **ใบอนุญาต › แนบเอกสาร** (ไอคอน attach_file)
2. URL ควรเป็น `/attach`
3. DevTools Network tab → filter `admin/attach`

---

## 0. Pre-flight

- [ ] Hot reload สำเร็จ — ไม่มี compile error
- [ ] หน้า `/attach` เปิดได้ ไม่มี red error
- [ ] Header แสดง "แนบเอกสารคำขอ"
- [ ] Network tab: `GET /admin/attach/requests` → status `200`
- [ ] ถ้ามีข้อมูล: list/table แสดง row อย่างน้อย 1 row

---

## 1. List + Search + Filter

### 1.1 Initial load
- [ ] เปิดหน้า `/attach` → list โหลดทันที
- [ ] Pagination indicator ("1 / N") ปรากฏ
- [ ] ถ้า 0 row → แสดง empty state

### 1.2 Search
- [ ] พิมพ์คำค้น (เช่น "คำขอ A") ใน search box → debounce
- [ ] List filter ตามคำค้น
- [ ] Network tab: `GET /admin/attach/requests?q=...` → 200
- [ ] Clear search → list กลับมาเต็ม

### 1.3 Filter (ถ้ามี)
- [ ] Filter dropdown (status, zone, type) ทำงาน
- [ ] List filter ตาม dropdown ที่เลือก

### 1.4 Pagination
- [ ] กด **Next** → page 2 โหลด → indicator "2 / N"
- [ ] กด **Prev** → กลับ page 1
- [ ] กด page number ตรงๆ → jump

---

## 2. Detail page — Step 1 (Checklist + Upload)

### 2.1 เปิด detail
- [ ] กด row → detail page เปิด
- [ ] Tab/Step 1 แสดง checklist (เช่น "สำเนาบัตรประชาชน", "ทะเบียนบ้าน", "รูปถ่าย")

### 2.2 Upload document
- [ ] กด **อัปโหลด** ใน checklist item → file picker
- [ ] เลือกไฟล์ (image / PDF) → upload → POST `/admin/attach/requests/{id}/documents`
- [ ] Response 200/201 → snackbar success
- [ ] Checklist item เปลี่ยนเป็น ✅ uploaded

### 2.3 Preview document
- [ ] กดชื่อเอกสารที่อัปโหลด → preview dialog
- [ ] Network: `GET /admin/attach/requests/{id}/documents/{docId}/preview` → 200
- [ ] Image/PDF แสดงใน dialog

### 2.4 Delete document
- [ ] กดปุ่ม **ลบ** ใน checklist item
- [ ] Confirm dialog → ยืนยัน
- [ ] DELETE `/admin/attach/requests/{id}/documents/{docId}` → 200
- [ ] Checklist item กลับเป็น ❌ not uploaded

---

## 3. Signature pad (Step 2)

### 3.1 เปิด step 2
- [ ] กด **ถัดไป** → Step 2 แสดง signature pad

### 3.2 วาดลายเซ็น
- [ ] ลากนิ้ว/เมาส์บน pad → ลายเซ็นแสดง
- [ ] กด **ล้าง** → pad ว่าง

### 3.3 Submit
- [ ] กด **บันทึกลายเซ็น** → POST `/admin/attach/requests/{id}/signature`
- [ ] Response 200 → snackbar success
- [ ] Step 2 แสดงสถานะ "signed"

---

## 4. Batch upload

### 4.1 เปิด batch upload sheet
- [ ] กด **อัปโหลดหลายไฟล์** → sheet เปิด (bottom modal)

### 4.2 เลือกหลายไฟล์
- [ ] กด **เลือกไฟล์** → file picker (multi-select)
- [ ] เลือก 3-5 ไฟล์ → list แสดง

### 4.3 Upload batch
- [ ] กด **อัปโหลด** → POST `/admin/attach/requests/{id}/documents/batch`
- [ ] Progress bar แสดง per-file
- [ ] เมื่อเสร็จ → snackbar success + checklist อัปเดต

### 4.4 Error handling
- [ ] ไฟล์ที่ upload fail → แสดง error per-file
- [ ] Retry per-file (ถ้ามี)

---

## 5. Checklist progress

### 5.1 Progress indicator
- [ ] Header แสดง progress (เช่น "5 / 8 รายการ")
- [ ] Progress bar อัปเดตตาม checklist ที่ upload

### 5.2 Required items
- [ ] Required items มี badge "จำเป็น"
- [ ] Submit enable เมื่อ required items ครบ

### 5.3 Optional items
- [ ] Optional items มี badge "ไม่จำเป็น" (ถ้ามี)
- [ ] Submit enable แม้ optional items ยังไม่ครบ

---

## 6. Edge cases

- [ ] Network down → snackbar error + state ไม่ crash
- [ ] Token expired → redirect login
- [ ] Upload ไฟล์ใหญ่ (>10MB) → progress bar + ไม่ crash
- [ ] Upload ไฟล์ผิด type (.exe) → validation error
- [ ] Signature pad → ไม่วาด → submit block + warning
- [ ] Batch upload ขัดจังหวะ (network drop) → partial state ไม่ crash
- [ ] เปิด detail + ปิด + เปิด detail อีก → state reset
- [ ] Pagination overflow → redirect หรือ disable Next

---

## 7. Backend verification

**คาดหวัง**: ทุก request ใช้ v2 (`/admin/...`)

- [ ] ไม่มี `.php` ใน URL ใดๆ ตลอดการทดสอบ
- [ ] ทุก response: status `200`/`201`/`204`
- [ ] ทุก request มี `Authorization: Bearer <token>`
- [ ] Upload ใช้ `multipart/form-data` (verify payload ใน DevTools)
- [ ] Signature ใช้ base64 PNG (verify payload ใน DevTools)
- [ ] Endpoint paths ตรงกับ API table ด้านบน (verify กับ `license_attach_service.dart`)

### Endpoint ที่ใช้บ่อย
- [ ] `GET /admin/attach/requests` (list)
- [ ] `GET /admin/attach/requests/{id}` (detail)
- [ ] `GET /admin/attach/requests/{id}/checklist`
- [ ] `POST /admin/attach/requests/{id}/documents`
- [ ] `POST /admin/attach/requests/{id}/documents/batch`
- [ ] `DELETE /admin/attach/requests/{id}/documents/{docId}`
- [ ] `POST /admin/attach/requests/{id}/signature`
- [ ] `GET /admin/attach/requests/{id}/documents/{docId}/preview`

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
- ❌ Upload fail → ไม่ rollback state
- ❌ Signature pad ไม่ capture → submit fail

---

## ปัญหาที่เคยเจอและแก้แล้ว

> TODO: เพิ่มเมื่อเจอ bug

---

**จบเอกสาร**