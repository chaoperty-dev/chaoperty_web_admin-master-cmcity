# Pen Test (Human) — อนุมัติคำร้อง (LicenseApprovePage) — `/approve`

> ⚠️ **MIXED API** — menu นี้ผสม v1 (legacy approval flow) + v2 (bulk approve + PDF preview) — Network จะเห็น v1/v2/v3 requests ปะปนกัน
>
> **Automated test** → [`ai.md`](./ai.md)
>
> **Cross-links**:
> - Master index → [`../../README.md`](../../README.md)
> - ก่อนหน้าใน flow: [`../submit-approval/`](../submit-approval/) (ส่งอนุมัติ)
> - ใบอนุญาตที่เกี่ยวข้อง: [`../verify/`](../verify/), [`../fact-check/`](../fact-check/)

---

## ภาพรวมระบบ

### ฟีเจอร์ที่ทดสอบ
LicenseApprovePage — หน้าอนุมัติคำร้องขอใบอนุญาต (final approver view):

```
LicenseApprovePage (list + search + filter + zone)
   └── LicenseApproveDetailPage
        ├── Step 1: รายละเอียดคำขอ + multi-PDF preview
        └── Step 2: อนุมัติ/ปฏิเสธ (single หรือ bulk)
             └── Legacy signature fallback (PHP InC_approval_legacy.php)
```

| Action | คำอธิบาย |
|---|---|
| อนุมัติคำร้อง (single) | approve คำขอเดียว |
| อนุมัติคำร้อง (bulk) | approve หลายคำขอพร้อมกัน (≤50/round) |
| ปฏิเสธคำร้อง | reject + เหตุผล |
| ดู multi-PDF | preview PDFs หลายไฟล์พร้อมกัน |
| Legacy signature | fallback สำหรับ signature image (PHP `InC_approval_legacy.php`) |

### API ที่ใช้ (Mixed ⚠️ — ดู note ด้านล่าง)
**v1 endpoints** (legacy approval flow — 4 endpoints):
- `GET /admin/know` — admin signature meta
- `GET /admin/users/signatures/{uuid}/preview` — signature image bytes
- `GET /admin/approvals/{requestUuid}/flow` — flow uuid list (legacy)
- `POST /admin/approvals/{requestUuid}/flow/{flowUuid}/approve` — approve (legacy)

**v2 endpoints**:
- `GET /v2/admin/approvals/me` — list งาน approve ของฉัน
- `GET /v2/admin/approvals/{requestUuid}` — detail approval
- `POST /v2/admin/approvals/{requestUuid}/steps/{stepUuid}/approve` — approve step
- `POST /v2/admin/approvals/{requestUuid}/steps/{stepUuid}/reject` — reject step
- `POST /admin/approvals/bulk/approve` — bulk approve (≤50/round)

**v3 endpoint**:
- `GET /api/preview/{path}/{requestUuid}` — generated PDFs (multi-PDF preview)

**PHP legacy** (1 endpoint — ต้อง migrate ⚠️):
- `POST InC_approval_legacy.php` — legacy signature approval path (ใช้ตอน v2 path ล้มเหลว)

> **Target v2** (หลัง migrate):
> - แทนที่ `InC_approval_legacy.php` ด้วย v2 bulk/approve ที่ handle signature fallback ในตัว

> **Note**: endpoint path ด้านบนเป็น preliminary — ตรวจสอบจาก `lib/.../license_approve_page/services/license_legacy_approval_service.dart` อีกครั้งเพื่อยืนยัน path จริง

### ฟีเจอร์ที่ตัดออก (ถ้ามี)
> TODO: ระบุถ้ามี

### Baseline
- commit: `6d1a298` (HEAD) "docs(pen-test): relocate existing area-config pentest into new pen-test folder"

---

## สิ่งที่ต้องเตรียม

- ✅ `fvm flutter pub get` เรียบร้อย
- ✅ Login เข้าสู่ระบบ (สิทธิ์ final approver)
- ✅ Backend v1 + v2 + v3 ขึ้นอยู่
- ✅ **PHP backend** ขึ้นอยู่ (ยังต้องใช้จนกว่าจะ migrate เสร็จ)
- ✅ DevTools Network tab — filter `admin/approvals|approvals/bulk|InC_approval_legacy`
- ✅ commit `6d1a298`

---

## วิธีรัน

```bash
fvm flutter run -d chrome
```

หลังแอปเปิด:
1. Login → เปิดเมนู **ใบอนุญาต › อนุมัติ**
2. URL ควรเป็น `/approve`
3. DevTools Network tab → filter `admin/approvals`

---

## 0. Pre-flight

- [ ] Hot reload สำเร็จ
- [ ] หน้า `/approve` เปิดได้ ไม่มี red error
- [ ] Network tab: `GET /v2/admin/approvals/me` → status `200` (v2 — expected)
- [ ] ถ้ามีข้อมูล: list แสดง row อย่างน้อย 1 row
- [ ] Pagination indicator ("1 / N") ปรากฏ

---

## 1. List + Search + Filter

### 1.1 Initial load
- [ ] เปิดหน้า `/approve` → list โหลดทันที
- [ ] Pagination indicator ("1 / N") ปรากฏ
- [ ] Empty state ถ้า 0 row

### 1.2 Search
- [ ] พิมพ์คำค้น (ชื่อผู้เช่า / เลขคำขอ / เลขบัตร) → list filter
- [ ] Network: `GET /v2/admin/approvals/me?q=...` → 200 (v2)
- [ ] Clear search → list กลับเต็ม

### 1.3 Zone filter
- [ ] Filter by zone (dropdown) — list filter ตาม zone
- [ ] Zone selection persist ระหว่าง session (ใช้ `zone_selection_store.dart`)

### 1.4 Pagination
- [ ] Next / Prev / page number — goToPage clamp เมื่อเกิน
- [ ] prevPage / nextPage boundary

---

## 2. Detail Page

### 2.1 เปิด detail
- [ ] กด row → detail page เปิด
- [ ] Network: `GET /v2/admin/approvals/{requestUuid}` → 200 (v2)
- [ ] Step 1 active: แสดงข้อมูลคำขอ + documents

### 2.2 Section แต่ละอัน
- [ ] **ข้อมูลคำขอ**: ผู้เช่า, ประเภทใบอนุญาต, วันที่ส่ง
- [ ] **เอกสารแนบ**: list + preview
- [ ] **ประวัติการตรวจ**: verify/fact-check rounds
- [ ] **PDF ที่ generate แล้ว**: preview link

---

## 3. Multi-PDF Preview

### 3.1 เปิด preview
- [ ] กดปุ่ม **ดู PDF** → multi-PDF preview page เปิด
- [ ] Network: `GET /api/preview/{path}/{requestUuid}` → 200 (v3)
- [ ] แสดง PDF หลายไฟล์ (tab หรือ scroll)

### 3.2 Navigation
- [ ] Tab เปลี่ยน PDF → load PDF ใหม่
- [ ] Zoom in/out (ถ้ามี)
- [ ] Download PDF (ถ้ามี)

### 3.3 Error case
- [ ] PDF load fail → snackbar + retry

---

## 4. Bulk Approve (Detail Step 2)

### 4.1 เปิด step 2
- [ ] กด "ถัดไป" → step 2 active
- [ ] เลือก checkbox ของแต่ละ row → counter อัปเดต

### 4.2 Bulk select
- [ ] เลือก row เดียว → counter "1 เลือก"
- [ ] เลือก 50 row → counter "50 เลือก" (สูงสุด)
- [ ] เลือก 51 row → block + message "สูงสุด 50/round"
- [ ] "เลือกทั้งหมด" (select all) → counter = ทั้งหมด

### 4.3 Bulk approve action
- [ ] กด **อนุมัติ (Bulk)** → confirm dialog
- [ ] ยืนยัน → POST `/admin/approvals/bulk/approve` (v2) → 200
- [ ] ตรวจสอบ `≤50/round` validation
- [ ] Response: per-row success/fail list
- [ ] Snackbar: "อนุมัติ X รายการ / ล้มเหลว Y รายการ"

### 4.4 Bulk reject (ถ้ามี)
- [ ] กด **ปฏิเสธ (Bulk)** → text area เหตุผล
- [ ] ยืนยัน → POST `/admin/approvals/bulk/reject` (ถ้ามี v2) หรือ loop per-row

---

## 5. Single Approve / Reject

### 5.1 Approve
- [ ] กด **อนุมัติ** → confirm dialog
- [ ] ยืนยัน → POST `/v2/admin/approvals/{requestUuid}/steps/{stepUuid}/approve` (v2) → 200
- [ ] Snackbar success
- [ ] List refresh → row เปลี่ยนสถานะ (เช่น "อนุมัติแล้ว")

### 5.2 Reject
- [ ] กด **ปฏิเสธ** → text area เหตุผล
- [ ] ยืนยัน → POST `/v2/admin/approvals/{requestUuid}/steps/{stepUuid}/reject` (v2) → 200
- [ ] Snackbar success
- [ ] List refresh → row เปลี่ยนสถานะ

---

## 6. Legacy Signature Fallback

### 6.1 เมื่อไหร่ trigger
- [ ] ถ้า v2 approve ล้มเหลว → fallback path ทำงาน
- [ ] หรือถ้า approver มี signature image ที่ต้องดึงจาก v1 path

### 6.2 Signature preview
- [ ] Network: `GET /admin/users/signatures/{uuid}/preview` (v1) → 200
- [ ] แสดง signature image ก่อน approve
- [ ] `GET /admin/know` (v1) → admin signature meta

### 6.3 Legacy approve action
- [ ] กด **อนุมัติ (Legacy)** → POST `InC_approval_legacy.php` (PHP) → 200
- [ ] ⚠️ PHP request — expected ตอนนี้
- [ ] Snackbar success

---

## 7. Edge cases

- [ ] Network down → snackbar error + state ไม่ crash
- [ ] Token expired → redirect login
- [ ] Bulk select >50 → block + message
- [ ] Multi-PDF preview fail → snackbar + retry
- [ ] Legacy fallback fail → snackbar + retry (หรือใช้ v2 path)
- [ ] เปิด detail + back + เปิด detail อีก → state reset
- [ ] Pagination overflow → redirect หรือ disable Next

---

## 8. Backend verification (CURRENT STATE)

**คาดหวังตอนนี้**: v1 + v2 + v3 + PHP requests (mixed หลาย version)

- [ ] `GET /v2/admin/approvals/me` → 200 (v2 — OK)
- [ ] `GET /v2/admin/approvals/{requestUuid}` → 200 (v2 — OK)
- [ ] `POST /v2/admin/approvals/{requestUuid}/steps/{stepUuid}/approve` → 200 (v2 — OK)
- [ ] `POST /v2/admin/approvals/{requestUuid}/steps/{stepUuid}/reject` → 200 (v2 — OK)
- [ ] `POST /admin/approvals/bulk/approve` → 200 (v2 bulk)
- [ ] `GET /api/preview/{path}/{requestUuid}` → 200 (v3 preview)
- [ ] `GET /admin/know` → 200 (v1 legacy — OK)
- [ ] `GET /admin/users/signatures/{uuid}/preview` → 200 (v1 legacy — OK)
- [ ] `GET /admin/approvals/{requestUuid}/flow` → 200 (v1 legacy — OK)
- [ ] `POST /admin/approvals/{requestUuid}/flow/{flowUuid}/approve` → 200 (v1 legacy — OK)
- [ ] `POST InC_approval_legacy.php` → 200 (PHP — expected จนกว่าจะ migrate)
- [ ] ทุก request มี `Authorization: Bearer <token>`

---

## 9. Backend verification (POST-MIGRATION TARGET)

> ใช้ checklist นี้หลัง migrate PHP `InC_approval_legacy.php` → v2 เสร็จ

- [ ] ❌ **ไม่มี `.php`** ใน URL
- [ ] `POST /v2/admin/approvals/{requestUuid}/approve-legacy` (หรือ path ใหม่) → 200
- [ ] ทุก request ใช้ v2 path
- [ ] Multi-PDF preview ยังใช้ v3 endpoint
- [ ] v1 endpoints สำหรับ legacy approval flow ยังคงอยู่ (จนกว่าจะย้ายทั้งหมด)

---

## 10. Regression (ถ้าเคยเจอ)

### Bug 1: bulk approve counter
- ถ้า counter ไม่อัปเดต → ตรวจ state binding ระหว่าง checkbox ↔ counter

---

## Migration blocking checklist

> ทำ checklist นี้ก่อน mark menu นี้เป็น "v2 ✅" ใน README index

- [ ] Backend มี v2 endpoint ทดแทน `InC_approval_legacy.php` (พร้อม signature handling)
- [ ] `LicenseLegacyApprovalService` ใช้ v2 path แทน PHP path
- [ ] ลบ import/fallback PHP ทุกที่
- [ ] Manual test section 8 → 9 (ทุก checkbox ✅)
- [ ] เขียน unit test ครอบ v2 path (ดู [`ai.md`](./ai.md))
- [ ] อัปเดต README index — flip สถานะเป็น v2 ✅

---

## เกณฑ์ Pass / Fail

### Pass (post-migration)
- ✅ AI Test ผ่าน
- ✅ Human Test ทุก checkbox ผ่าน
- ✅ Network tab: ไม่มี `.php`
- ✅ Backend verification section 9 ทุกข้อ ✅

### Pass (current — pre-migration)
- ⚠️ AI Test ยังไม่มี (TBD)
- ⚠️ Network tab มี v1 + v2 + v3 + PHP (mixed — expected จนกว่าจะ migrate)
- ✅ ฟีเจอร์ทำงานได้ปกติ (functional smoke)
- ✅ Bulk approve ทำงาน (≤50/round)

### Fail
- ❌ Red error บนหน้าจอ
- ❌ Snackbar ข้อความผิด
- ❌ PHP endpoint ใหม่ปรากฏ (ที่ไม่ใช่ `InC_approval_legacy.php`) → unexpected, ต้อง flag
- ❌ Bulk >50 ไม่ถูก block
- ❌ Multi-PDF preview fail ทั้งหมด

---

## ปัญหาที่เคยเจอและแก้แล้ว

> TODO: เพิ่มเมื่อเจอ bug

---

**จบเอกสาร** — หลัง migrate PHP `InC_approval_legacy.php` เสร็จ ลบ section 8 (current state) และเลื่อน section 9 เป็น 8
