# Pen Test (Human) — ชำระค่าธรรมเนียม — `/payment`

> ⚠️ **MIGRATION PENDING** — เมนูนี้ยังใช้ **PHP legacy** อยู่ทั้งหมด — Network จะเห็น `.php` request (expected ตอนนี้)
>
> **Automated test** → [`ai.md`](./ai.md)
>
> **Cross-link**: [`../attach/`](../attach/) (ส่งต่อหลังแนบเอกสาร) · [`../approve/`](../approve/) (ส่งต่ออนุมัติ)

---

## ภาพรวมระบบ

### ฟีเจอร์ที่ทดสอบ
LicensePaymentPage — หน้าติดตามการชำระค่าธรรมเนียมใบอนุญาต (list + detail + slip upload + prepayments + history + stepper)

```
LicensePaymentPage (list + search + zone filter)
   └── LicensePaymentDetailPage
       ├── Stepper (current step indicator)
       ├── Step 1 — Slip upload + review
       ├── Step 2 — Confirm + receipt
       ├── Prepayments (รายการชำระล่วงหน้า)
       └── PaymentHistoryView (ประวัติการชำระ)
```

| Action | คำอธิบาย |
|---|---|
| List + Filter | ดูรายการชำระทั้งหมด + ค้นหา |
| Payment Detail | ดูรายละเอียด + stepper |
| Slip Upload | อัปโหลดสลิปการโอน |
| Slip Delete | ลบสลิปที่อัปโหลดผิด |
| Prepayment | เพิ่ม/ลบ รายการชำระล่วงหน้า |
| Receipt | ดูใบเสร็จรับเงิน |
| Confirm | ยืนยันการรับเงิน (admin) |
| History | ดูประวัติการชำระ |

### API ที่ใช้ (ตอนนี้ PHP ทั้งหมด — ต้อง migrate ⚠️)
12 endpoints ใน `license_payment_service.dart`:
- `GET/POST InC_license_payment_list.php`
- `GET InC_license_payment_detail.php`
- `POST InC_license_payment_submit_slip.php`, `InC_license_payment_delete_slip.php`
- `GET InC_license_payment_receipt.php`, `InC_license_payment_history.php`
- `GET InC_license_payment_prepayment.php`
- `POST InC_license_payment_prepayment_add.php`, `InC_license_payment_prepayment_delete.php`
- `GET InC_license_payment_methods.php`
- `POST InC_license_payment_confirm.php`
- `GET InC_license_payment_stepper.php`

> **Target v2** (หลัง migrate):
> - `GET/POST /admin/payments` — list
> - `GET /admin/payments/{id}` — detail
> - `POST /admin/payments/{id}/slip`, `DELETE /admin/payments/{id}/slip`
> - `GET /admin/payments/{id}/receipt`, `GET /admin/payments/{id}/history`
> - `GET /admin/payments/{id}/prepayments`, `POST /admin/payments/{id}/prepayments`, `DELETE /admin/payments/{id}/prepayments/{prepayId}`
> - `GET /admin/payments/methods`
> - `POST /admin/payments/{id}/confirm`
> - `GET /admin/payments/{id}/stepper`

> **Note**: endpoint path ด้านบนเป็น preliminary — ตรวจสอบจาก `license_payment_service.dart` อีกครั้งเพื่อยืนยัน path จริง

### Baseline
- commit: `6d1a298` (HEAD) "docs(pen-test): relocate existing area-config pentest into new pen-test folder"

---

## สิ่งที่ต้องเตรียม

- ✅ `fvm flutter pub get`
- ✅ Login
- ✅ **PHP backend** ขึ้นอยู่ (ยังต้องใช้จนกว่าจะ migrate)
- ✅ DevTools Network tab — filter `InC_license_payment`
- ✅ ไฟล์ทดสอบ: สลิปการโอน (.jpg/.png)
- ✅ commit `6d1a298`

---

## วิธีรัน

```bash
fvm flutter run -d chrome
```

หลังแอปเปิด:
1. Login → เมนู **ใบอนุญาต › ชำระค่าธรรมเนียม** (ไอคอน payment)
2. URL ควรเป็น `/payment`
3. DevTools Network tab → filter `InC_license_payment` (คาดว่าจะเห็น `.php` จำนวนมาก)

---

## 0. Pre-flight

- [ ] Hot reload สำเร็จ
- [ ] หน้า `/payment` เปิดได้ ไม่มี red error
- [ ] Network tab: `GET InC_license_payment_list.php` → status `200` (PHP — expected)
- [ ] ถ้ามีข้อมูล: list แสดง row อย่างน้อย 1 row

---

## 1. List + Search + Filter

### 1.1 Initial load
- [ ] เปิดหน้า `/payment` → list โหลดทันที
- [ ] Pagination indicator ("1 / N") ปรากฏ
- [ ] Empty state ถ้า 0 row

### 1.2 Search
- [ ] พิมพ์คำค้น (เช่น "คำขอ A") → list filter
- [ ] Network: `GET InC_license_payment_list.php?q=...` → 200
- [ ] Clear search → list กลับเต็ม

### 1.3 Zone filter
- [ ] Filter dropdown (zone) ทำงาน
- [ ] List filter ตาม dropdown ที่เลือก

### 1.4 Pagination
- [ ] Next / Prev / page number ทำงาน

---

## 2. Payment Detail

### 2.1 เปิด detail
- [ ] กด row → detail page เปิด
- [ ] Network: `GET InC_license_payment_detail.php` → 200 (PHP — expected)
- [ ] แสดงข้อมูลครบ: ยอด, วิธีชำระ, สถานะ, วันที่

### 2.2 Stepper
- [ ] Network: `GET InC_license_payment_stepper.php` → 200 (PHP — expected)
- [ ] Stepper แสดง current step + total steps
- [ ] Step แต่ละขั้น (pending / active / done) แสดง icon ถูกต้อง

---

## 3. Slip upload

### 3.1 Step 1 — อัปโหลดสลิป
- [ ] ใน step 1 กด **อัปโหลดสลิป** → file picker
- [ ] เลือกไฟล์ (image/PDF) → upload
- [ ] Network: `POST InC_license_payment_submit_slip.php` → 200 (PHP — expected)
- [ ] Snackbar success → stepper เลื่อนไป step 2

### 3.2 ดูตัวอย่างสลิป
- [ ] กดที่ thumbnail สลิป → preview dialog
- [ ] Network: `GET InC_license_payment_detail.php` (slip URL field) → 200

### 3.3 ลบสลิป
- [ ] กด **ลบสลิป** → confirm → POST `InC_license_payment_delete_slip.php`
- [ ] Stepper กลับไป step 1

---

## 4. Prepayments (การชำระล่วงหน้า)

### 4.1 List prepayments
- [ ] Network: `GET InC_license_payment_prepayment.php` → 200 (PHP — expected)
- [ ] List prepayments แสดง (ถ้ามี)

### 4.2 เพิ่ม prepayment
- [ ] กด **เพิ่มการชำระล่วงหน้า** → dialog เปิด
- [ ] กรอก: จำนวนเงิน, วิธีชำระ, วันที่
- [ ] กด บันทึก → POST `InC_license_payment_prepayment_add.php` → 200
- [ ] List อัปเดต + stepper state update

### 4.3 ลบ prepayment
- [ ] กด **ลบ** → confirm → POST `InC_license_payment_prepayment_delete.php`
- [ ] List อัปเดต

---

## 5. Confirm + Receipt

### 5.1 ยืนยันการรับเงิน (admin)
- [ ] ใน step 2 กด **ยืนยันการรับเงิน** → confirm dialog
- [ ] กด ยืนยัน → POST `InC_license_payment_confirm.php` → 200 (PHP — expected)
- [ ] Snackbar success
- [ ] สถานะเปลี่ยนเป็น "ชำระแล้ว"

### 5.2 ดูใบเสร็จ
- [ ] กด **ดูใบเสร็จ** → GET `InC_license_payment_receipt.php` → 200
- [ ] Receipt แสดง (PDF/HTML)

### 5.3 วิธีการชำระ
- [ ] Network: `GET InC_license_payment_methods.php` → 200 (PHP — expected)
- [ ] Dropdown methods แสดง options (โอน, เงินสด, เช็ค)

---

## 6. History

### 6.1 เปิด history
- [ ] กด **ประวัติ** → GET `InC_license_payment_history.php` → 200 (PHP — expected)
- [ ] List ประวัติการชำระแสดง (วันที่, จำนวน, สถานะ)

### 6.2 History filter
- [ ] Filter by date range (ถ้ามี)
- [ ] Filter by status (paid / pending / failed)

---

## 7. Edge cases

- [ ] Network down → snackbar error + state ไม่ crash
- [ ] Token expired → redirect login
- [ ] Detail page + back + เปิด detail อีก → state reset
- [ ] Upload สลิปไฟล์ใหญ่ (>10MB) → progress bar + ไม่ crash
- [ ] Upload สลิปผิด type → validation error
- [ ] Confirm payment 2 ครั้งซ้อน → block ปุ่ม หรือ disable
- [ ] Pagination overflow → redirect หรือ disable Next

---

## 8. Backend verification (CURRENT STATE)

**คาดหวังตอนนี้**: ⚠️ PHP requests (เพราะยัง migrate ไม่เสร็จ — ห้าม fail test เพราะเรื่องนี้)

- [ ] `GET InC_license_payment_list.php` → 200 (PHP — expected)
- [ ] `GET InC_license_payment_detail.php` → 200 (PHP — expected)
- [ ] `POST InC_license_payment_submit_slip.php` → 200 (PHP — expected)
- [ ] `POST InC_license_payment_delete_slip.php` → 200 (PHP — expected)
- [ ] `GET InC_license_payment_receipt.php` → 200 (PHP — expected)
- [ ] `GET InC_license_payment_history.php` → 200 (PHP — expected)
- [ ] `GET InC_license_payment_prepayment.php` → 200 (PHP — expected)
- [ ] `POST InC_license_payment_prepayment_add.php` → 200 (PHP — expected)
- [ ] `POST InC_license_payment_prepayment_delete.php` → 200 (PHP — expected)
- [ ] `GET InC_license_payment_methods.php` → 200 (PHP — expected)
- [ ] `POST InC_license_payment_confirm.php` → 200 (PHP — expected)
- [ ] `GET InC_license_payment_stepper.php` → 200 (PHP — expected)
- [ ] ทุก response: status `200`/`204`
- [ ] ทุก request มี `Authorization: Bearer <token>`

---

## 9. Backend verification (POST-MIGRATION TARGET)

> ใช้ checklist นี้หลัง migrate PHP → v2 เสร็จ

- [ ] ❌ **ไม่มี `.php`** ใน URL (ทั้ง 12 endpoints)
- [ ] `GET /admin/payments` → 200
- [ ] `GET /admin/payments/{id}` → 200
- [ ] `POST /admin/payments/{id}/slip` → 200
- [ ] `DELETE /admin/payments/{id}/slip` → 200
- [ ] `GET /admin/payments/{id}/receipt` → 200
- [ ] `GET /admin/payments/{id}/history` → 200
- [ ] `GET /admin/payments/{id}/prepayments` → 200
- [ ] `POST /admin/payments/{id}/prepayments` → 200
- [ ] `DELETE /admin/payments/{id}/prepayments/{prepayId}` → 200
- [ ] `GET /admin/payments/methods` → 200
- [ ] `POST /admin/payments/{id}/confirm` → 200
- [ ] `GET /admin/payments/{id}/stepper` → 200
- [ ] ทุก mutation ใช้ v2

---

## 10. Regression (ถ้าเคยเจอ)

> TODO: เพิ่มเมื่อเจอ bug

---

## Migration blocking checklist

> ทำ checklist นี้ก่อน mark menu นี้เป็น "v2 ✅" ใน README index

- [ ] Backend มี v2 endpoints (12 รายการในตาราง Pre-migration)
- [ ] `LicensePaymentService` ใช้ `domain_v2` แทน `domain` (legacy PHP root)
- [ ] `LicensePaymentDetailService` ใช้ `domain_v2`
- [ ] ลบ import/fallback ทุกที่
- [ ] Manual test section 4 → 5 ทุก checkbox ✅ (PHP)
- [ ] Manual test section 8 → 9 ทุก checkbox ✅ (post-migration)
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

**จบเอกสาร** — หลัง migrate เสร็จ ลบ section 8 (current state) และเลื่อน section 9 เป็น 8