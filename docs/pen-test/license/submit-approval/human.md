# Pen Test (Human) — ส่งอนุมัติ (LicenseSubmitApprovalRequestPage) — `/submit-approval`

> **เอกสารนี้คืออะไร** — manual UI walkthrough สำหรับ menu `/submit-approval` (LicenseSubmitApprovalRequestPage — ส่งคำร้องขออนุมัติ + multi-round view)
>
> **Automated test** → [`ai.md`](./ai.md)
>
> **Cross-links**:
> - Master index → [`../../README.md`](../../README.md)
> - ก่อนหน้าใน flow: [`../fact-check/`](../fact-check/) (ตรวจข้อเท็จจริง)
> - ขั้นถัดไป: [`../approve/`](../approve/) (อนุมัติ)

---

## ภาพรวมระบบ

### ฟีเจอร์ที่ทดสอบ
LicenseSubmitApprovalRequestPage — หน้าส่งคำร้องขออนุมัติ + ดู rounds timeline (multi-round approval):

```
LicenseSubmitApprovalRequestPage (list + search + filter + zone)
   └── LicenseSubmitApprovalDetailPage
        ├── Step 1: ส่งคำร้องขออนุมัติ (submit form)
        └── Step 2: rounds timeline + steps + reviewers
```

| Action | คำอธิบาย |
|---|---|
| ส่งคำร้องขออนุมัติ | ส่ง request เข้าสู่ approval workflow |
| ดู rounds timeline | ดูสถานะแต่ละ round ของการอนุมัติ |
| ดู steps ภายใน round | ดู steps ที่ reviewer แต่ละคนต้อง approve/reject |

### API ที่ใช้ (v2 หลัก + v1 fallback — verified ✅)
**v2 list/detail**:
- `GET /v2/admin/requests/tasks/approvals` — list คำขออนุมัติ
- `GET /v2/admin/approvals/{requestUuid}` — detail approval
- `GET /v2/admin/approvals/me` — approver list (me)

**v2 rounds + steps**:
- `POST /v2/admin/approvals/{requestUuid}/rounds` — create round
- `POST /v2/admin/approvals/{requestUuid}/steps/{stepUuid}/approve` — approve step
- `POST /v2/admin/approvals/{requestUuid}/steps/{stepUuid}/reject` — reject step

**v1 fallback** (legacy approval list):
- `GET /v1/admin/approvals` — fallback list

> **Note**: endpoint path ด้านบนเป็น preliminary — ตรวจสอบจาก `lib/.../license_submit_approval_request_page/services/license_submit_approval_service.dart` อีกครั้งเพื่อยืนยัน path จริง

### ฟีเจอร์ที่ตัดออก (ถ้ามี)
> TODO: ระบุถ้ามี

### Baseline
- commit: `6d1a298` (HEAD) "docs(pen-test): relocate existing area-config pentest into new pen-test folder"

---

## สิ่งที่ต้องเตรียม

- ✅ `fvm flutter pub get` เรียบร้อย
- ✅ Login เข้าสู่ระบบ (สิทธิ์ submitter/approver)
- ✅ Backend v1 + v2 ขึ้นอยู่
- ✅ Browser DevTools Network tab เปิด (filter `admin/requests/tasks/approvals|admin/approvals`)
- ✅ commit ปัจจุบัน `6d1a298` หรือใหม่กว่า

---

## วิธีรัน

```bash
fvm flutter run -d chrome
```

หลังแอปเปิด:
1. Login → เปิดเมนู **ใบอนุญาต › ส่งอนุมัติ**
2. URL ควรเป็น `/submit-approval`
3. DevTools Network tab → filter `admin/requests/tasks/approvals`

---

## 0. Pre-flight

- [ ] Hot reload สำเร็จ — ไม่มี compile error
- [ ] หน้า `/submit-approval` เปิดได้ ไม่มี red error
- [ ] Header แสดง "ส่งคำร้องขออนุมัติ" + ปุ่ม action ที่เกี่ยวข้อง
- [ ] Network tab: `GET /v2/admin/requests/tasks/approvals` → status `200`
- [ ] ถ้ามีข้อมูล: list/table แสดง row อย่างน้อย 1 row

---

## 1. List + Search + Filter

### 1.1 Initial load
- [ ] เปิดหน้า `/submit-approval` → list โหลดทันที
- [ ] Pagination indicator ("1 / N") ปรากฏ
- [ ] ถ้า 0 row → แสดง empty state

### 1.2 Search
- [ ] พิมพ์คำค้น (ชื่อผู้เช่า / เลขคำขอ / เลขบัตร) ใน search box → debounce
- [ ] List filter ตามคำค้น
- [ ] Network tab: `GET /v2/admin/requests/tasks/approvals?q=...` → 200
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

## 2. Submit for Approval (Detail Step 1)

### 2.1 เปิด detail
- [ ] กด row → detail page เปิด → step 1 active
- [ ] Network: `GET /v2/admin/approvals/{requestUuid}` → 200
- [ ] แสดงข้อมูลคำขอ (tenant info, request info, documents summary)

### 2.2 Submit form
- [ ] รายการ reviewer ที่ต้อง approve (pre-configured)
- [ ] ปุ่ม **ส่งคำร้องขออนุมัติ**
- [ ] Confirm dialog "ยืนยันการส่งคำร้อง" แสดง
- [ ] Validation: ถ้าไม่ครบ → block + highlight

### 2.3 Submit action
- [ ] กด **ยืนยัน** → POST `/v2/admin/approvals/{requestUuid}/rounds` → 200
- [ ] Snackbar success
- [ ] List refresh → row เปลี่ยนสถานะ (เช่น "รออนุมัติ")

---

## 3. Multi-Round Detail View (Detail Step 2)

### 3.1 เปิด step 2
- [ ] กด "ถัดไป" → step 2 active
- [ ] แสดง rounds timeline (ทุก round ที่ submit ไปแล้ว)

### 3.2 Rounds timeline
- [ ] แต่ละ round: ลำดับ, วันที่ส่ง, สถานะ (กำลังดำเนินการ/อนุมัติ/ปฏิเสธ)
- [ ] Expand round → แสดง steps ภายใน
- [ ] แต่ละ step: reviewer, role, สถานะ, วันที่ approve/reject

### 3.3 Steps view
- [ ] แสดง list ของ reviewer แต่ละ step
- [ ] Badge: อนุมัติ ✅ / ปฏิเสธ ❌ / รอดำเนินการ ⏳
- [ ] Comment/เหตุผล ของแต่ละ step (ถ้ามี)

### 3.4 Current round indicator
- [ ] Round ปัจจุบัน highlight (active)
- [ ] Previous rounds collapsed/greyed
- [ ] Next round pending (ถ้ามี round ถัดไป)

---

## 4. Edge cases

- [ ] Network down → snackbar error + state ไม่ crash
- [ ] Token expired → redirect login
- [ ] Submit form ไม่ครบ → submit block + highlight field
- [ ] Rounds timeline ว่าง (0 round) → empty state
- [ ] เปิด detail + ปิด + เปิด detail อีก → state reset
- [ ] Pagination overflow → redirect หรือ disable Next

---

## 5. Backend verification

**คาดหวัง**: v2 list/detail/rounds + v1 fallback (mixed v1+v2 แต่ไม่มี PHP)

- [ ] ไม่มี `.php` ใน URL ใดๆ ตลอดการทดสอบ
- [ ] ทุก response: status `200`/`201`/`204`
- [ ] ทุก request มี `Authorization: Bearer <token>`
- [ ] Endpoint paths ตรงกับ API table ด้านบน (verify กับ service files)

### Endpoint ที่ใช้บ่อย
- [ ] `GET /v2/admin/requests/tasks/approvals` (list)
- [ ] `GET /v2/admin/approvals/{requestUuid}` (detail)
- [ ] `POST /v2/admin/approvals/{requestUuid}/rounds` (submit)
- [ ] `POST /v2/admin/approvals/{requestUuid}/steps/{stepUuid}/approve` (approve)
- [ ] `POST /v2/admin/approvals/{requestUuid}/steps/{stepUuid}/reject` (reject)

---

## 6. Provider scope regression (ถ้าเคยเจอ)

> TODO: ระบุ bug ที่เคยเจอ (เช่น "Could not find Provider<LicenseSubmitApprovalViewModel>") ถ้ามี

---

## เกณฑ์ Pass / Fail

### Pass
- ✅ ทุก checkbox ใน section 0-4 ผ่าน
- ✅ Network tab ไม่มี `.php`
- ✅ Backend verification section 5 ทุกข้อ ✅
- ✅ Submit for approval → status เปลี่ยน
- ✅ Rounds timeline แสดงครบทุก round + steps

### Fail
- ❌ Red error บนหน้าจอ
- ❌ Submit for approval fail / state ไม่ persist
- ❌ Rounds timeline ไม่แสดง steps
- ❌ Snackbar ข้อความผิด
- ❌ PHP endpoint ที่ไม่อยู่ใน list → unexpected, ต้อง flag

---

## ปัญหาที่เคยเจอและแก้แล้ว

> TODO: เพิ่มเมื่อเจอ bug

---

**จบเอกสาร** — หลัง menu นี้ stable และไม่มี `.php` ค้าง → flip สถานะใน [`../../README.md`](../../README.md) เป็น v2 ✅
