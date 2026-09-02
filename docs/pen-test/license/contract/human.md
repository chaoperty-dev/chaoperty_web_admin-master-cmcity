# Pen Test (Human) — คำขอใบอนุญาต — `/contract`

> ⚠️ **MIXED API** — เมนูนี้ผสม v2 (contracts) + PHP legacy (billing)
>
> **Automated test** → [`ai.md`](./ai.md)
>
> **Cross-link**: [`../announce/`](../announce/) (ประกาศที่จะเลือกในฟอร์ม) · [`../attach/`](../attach/) (ส่งต่อเอกสาร) · [`../payment/`](../payment/) (ส่งต่อชำระเงิน)

---

## ภาพรวมระบบ

### ฟีเจอร์ที่ทดสอบ
LicenseContractPage — หน้าฟอร์มคำขอใบอนุญาต 3 ส่วน (บุคคล/ร้านค้า/สัญญา) + announcement card + auto-billing + customer picker

```
LicenseContractPage
   ├── AnnouncementCard (เลือกประกาศจาก /announce)
   ├── FormPersonSection (ข้อมูลผู้ขอ)
   ├── FormShopSection (ข้อมูลร้าน)
   ├── FormContractSection (ข้อมูลสัญญา)
   ├── CustomerPickerDialog (เลือกลูกค้าเดิม ถ้ามี)
   ├── AreaInfoCard (เลือกพื้นที่ — PHP legacy)
   ├── BillingTable (PHP legacy billing)
   └── FooterActions (ส่งคำขอ / บันทึก draft)
```

| Section | คำอธิบาย |
|---|---|
| ประกาศ | เลือก announcement ที่ต้องการยื่นคำขอ |
| ข้อมูลบุคคล | ชื่อ-นามสกุล, เลขบัตร, ที่อยู่, เบอร์โทร |
| ข้อมูลร้าน | ชื่อร้าน, ประเภท, ทะเบียนการค้า |
| ข้อมูลสัญญา | วันที่เริ่ม/สิ้นสุด, ค่าเช่า, เงื่อนไข |
| Billing | บิลที่ generate อัตโนมัติ (PHP) |

### API ที่ใช้ (MIXED)
**v2 (verified ✅)**:
- `POST /admin/contracts` — ส่งคำขอ
- `GET /admin/contracts/{id}` — โหลดคำขอ (ถ้ามี)

**PHP legacy (⚠️ ต้อง flag — 7 endpoints)**:
- `GET GC_areaAll.php` — dropdown พื้นที่
- `GET InC_BillDetail.php`, `InC_Bill.php`, `InC_Bill_Receipt.php` — billing
- `POST InC_Bill_SubmitSlip.php`, `InC_Bill_DeleteSlip.php` — slip upload
- `GET HistoryBill.php` — billing history

> **Note**: endpoint path ด้านบนเป็น preliminary — ตรวจสอบจาก `lib/ChiangMai_Municipality/License_menu/license_contract_page/services/` อีกครั้งเพื่อยืนยัน path จริง

### Baseline
- commit: `6d1a298` (HEAD) "docs(pen-test): relocate existing area-config pentest into new pen-test folder"

---

## สิ่งที่ต้องเตรียม

- ✅ `fvm flutter pub get` เรียบร้อย
- ✅ Login เข้าสู่ระบบ
- ✅ Backend v2 ขึ้นอยู่
- ✅ **PHP backend** ขึ้นอยู่ (ยังต้องใช้สำหรับ billing + area)
- ✅ Browser DevTools Network tab เปิด (filter `contract`, `Bill`, `areaAll`)
- ✅ commit ปัจจุบัน `6d1a298` หรือใหม่กว่า

---

## วิธีรัน

```bash
fvm flutter run -d chrome
```

หลังแอปเปิด:
1. Login → เปิดเมนู **ใบอนุญาต › คำขอ** (ไอคอน description)
2. URL ควรเป็น `/contract`
3. DevTools Network tab → filter `contract`, `Bill`, `areaAll`

---

## 0. Pre-flight

- [ ] Hot reload สำเร็จ — ไม่มี compile error
- [ ] หน้า `/contract` เปิดได้ ไม่มี red error
- [ ] Header แสดง "คำขอใบอนุญาต"
- [ ] Network tab: `GET GC_areaAll.php` → status `200` (PHP — expected)
- [ ] Network tab: `GET /admin/contracts` (ถ้ามี load list) → status `200` (v2 — expected)
- [ ] ถ้ามีข้อมูล: ฟอร์มแสดงครบ 3 ส่วน + announcement card

---

## 1. ฟอร์ม 3 ส่วน

### 1.1 Announcement card
- [ ] Card แสดงประกาศที่ active (จาก `/announce`)
- [ ] กดเปลี่ยนประกาศ → dialog เปิด
- [ ] เลือกประกาศใหม่ → card update
- [ ] Network: `GET /admin/announcements?status=active` → 200

### 1.2 Section 1 — ข้อมูลบุคคล
- [ ] ชื่อ-นามสกุล (required)
- [ ] เลขบัตรประชาชน (required, format validation)
- [ ] ที่อยู่ (required)
- [ ] เบอร์โทร (required, format validation)
- [ ] Validation error แสดงใต้ field
- [ ] ปุ่ม Next → enable เมื่อ section valid

### 1.3 Section 2 — ข้อมูลร้าน
- [ ] ชื่อร้าน (required)
- [ ] ประเภทร้าน (dropdown)
- [ ] ทะเบียนการค้า (required)
- [ ] Validation: required fields
- [ ] Customer picker dialog (เลือกลูกค้าเดิม ถ้ามี) → prefill section 1+2

### 1.4 Section 3 — ข้อมูลสัญญา
- [ ] พื้นที่ (dropdown — โหลดจาก `GC_areaAll.php`)
- [ ] วันที่เริ่มสัญญา (date picker)
- [ ] วันที่สิ้นสุด (date picker)
- [ ] ค่าเช่า (prefill จากพื้นที่ที่เลือก, แก้ได้)
- [ ] เงื่อนไขเพิ่มเติม (note)
- [ ] Validation: required fields + end > start

### 1.5 Footer actions
- [ ] **บันทึก draft** → save state ชั่วคราว
- [ ] **ส่งคำขอ** → enable เมื่อทุก section valid
- [ ] กด **ส่งคำขอ** → POST `/admin/contracts`
- [ ] Response 200/201 → snackbar success
- [ ] Redirect ไปยังหน้า success หรือ detail

---

## 2. Customer picker dialog

### 2.1 เปิด dialog
- [ ] กดปุ่ม **เลือกลูกค้าเดิม** → dialog เปิด
- [ ] Search box ทำงาน (พิมพ์ → filter list)

### 2.2 เลือกลูกค้า
- [ ] เลือก row → section 1+2 prefill จาก customer data
- [ ] Dialog ปิด
- [ ] สามารถแก้ไขข้อมูลที่ prefill ได้

### 2.3 ยกเลิก
- [ ] กด ยกเลิก → dialog ปิด, ฟอร์มไม่เปลี่ยน

---

## 3. Billing section (PHP legacy ⚠️)

> หัวข้อนี้ใช้ PHP endpoints ทั้งหมด — ต้อง flag ใน Backend verification

### 3.1 Initial bill load
- [ ] เมื่อเลือกพื้นที่ + วันที่ → bill generate อัตโนมัติ
- [ ] Network: `GET InC_BillDetail.php` → 200 (PHP — expected)
- [ ] `BillingTable` แสดง bill rows

### 3.2 Bill detail
- [ ] กด row bill → detail dialog/page
- [ ] Network: `GET InC_Bill.php` → 200 (PHP — expected)

### 3.3 Slip upload (ถ้ามี)
- [ ] กด **อัปโหลดสลิป** → file picker
- [ ] เลือกไฟล์ → upload → POST `InC_Bill_SubmitSlip.php`
- [ ] Snackbar success → bill status update

### 3.4 Slip delete
- [ ] กด **ลบสลิป** → confirm → POST `InC_Bill_DeleteSlip.php`
- [ ] Bill status กลับเป็น unpaid

### 3.5 Receipt
- [ ] กด **ดูใบเสร็จ** → GET `InC_Bill_Receipt.php` → 200
- [ ] Receipt แสดง (PDF/HTML)

### 3.6 Billing history
- [ ] กด **ประวัติ** → GET `HistoryBill.php` → 200 (PHP — expected)
- [ ] List ประวัติการเรียกเก็บแสดง

---

## 4. Edge cases

- [ ] Network down → snackbar error + state ไม่ crash
- [ ] Token expired → redirect login
- [ ] Form submit 2 ครั้งซ้อน → block ปุ่ม หรือ disable ขณะ pending
- [ ] Required field ว่าง → submit block + error message
- [ ] End date < start date → validation error
- [ ] PHP backend down → billing section แสดง error (v2 ยังทำงานได้)

---

## 5. Backend verification (CURRENT STATE — MIXED)

**คาดหวังตอนนี้**: ⚠️ PHP requests สำหรับ billing + area, v2 สำหรับ contracts

- [ ] `GET GC_areaAll.php` → 200 (PHP — expected)
- [ ] `GET InC_Bill*.php` → 200 (PHP — expected)
- [ ] `POST InC_Bill_SubmitSlip.php` → 200 (PHP — expected)
- [ ] `POST InC_Bill_DeleteSlip.php` → 200 (PHP — expected)
- [ ] `GET HistoryBill.php` → 200 (PHP — expected)
- [ ] `POST /admin/contracts` → 200/201 (v2 — expected)
- [ ] ทุก response: status `200`/`201`/`204`
- [ ] ทุก request มี `Authorization: Bearer <token>`

---

## 6. Backend verification (POST-MIGRATION TARGET)

> ใช้ checklist นี้หลัง migrate PHP billing → v2 เสร็จ

- [ ] ❌ **ไม่มี `.php`** ใน URL (ทั้ง 7 endpoints)
- [ ] `GET /admin/areas` → 200 (replace `GC_areaAll.php`)
- [ ] `GET /admin/bills` → 200 (replace `InC_Bill.php`)
- [ ] `GET /admin/bills/{id}` → 200 (replace `InC_BillDetail.php`)
- [ ] `GET /admin/bills/{id}/receipt` → 200 (replace `InC_Bill_Receipt.php`)
- [ ] `POST /admin/bills/{id}/slip` → 200 (replace `InC_Bill_SubmitSlip.php`)
- [ ] `DELETE /admin/bills/{id}/slip` → 200 (replace `InC_Bill_DeleteSlip.php`)
- [ ] `GET /admin/contracts/{id}/bills/history` → 200 (replace `HistoryBill.php`)
- [ ] `POST /admin/contracts` → 200/201 (v2 — already)
- [ ] ทุก mutation ใช้ v2

---

## 7. Regression (ถ้าเคยเจอ)

> TODO: เพิ่มเมื่อเจอ bug

---

## Migration blocking checklist

> ทำ checklist นี้ก่อน mark menu นี้เป็น "v2 ✅" ใน README index

- [ ] Backend มี v2 endpoints (7 รายการในตาราง Pre-migration)
- [ ] `BillingService` ใช้ `domain_v2` แทน PHP root
- [ ] `LicenseContractService` (area dropdown) ใช้ `domain_v2`
- [ ] ลบ import/fallback ทุกที่
- [ ] Manual test section 3 (Billing) → 6 ทุก checkbox ✅ (PHP)
- [ ] Manual test section 5 → 6 ทุก checkbox ✅ (post-migration)
- [ ] เขียน unit test ครอบ v2 path (ดู [`ai.md`](./ai.md))
- [ ] อัปเดต README index — flip billing สถานะเป็น v2 ✅

---

## เกณฑ์ Pass / Fail

### Pass (post-migration)
- ✅ AI Test ผ่าน
- ✅ Human Test ทุก checkbox ผ่าน
- ✅ Network tab: ไม่มี `.php`
- ✅ Backend verification section 6 ทุกข้อ ✅

### Pass (current — pre-migration)
- ⚠️ AI Test ยังไม่มี (TBD)
- ⚠️ Network tab มี `.php` สำหรับ billing + area (expected จนกว่าจะ migrate)
- ✅ Contracts POST ใช้ v2 (already migrated)
- ✅ ฟีเจอร์ทำงานได้ปกติ (functional smoke)

### Fail
- ❌ Red error บนหน้าจอ
- ❌ Snackbar ข้อความผิด
- ❌ PHP endpoint ที่ไม่อยู่ใน list → unexpected, ต้อง flag

---

## ปัญหาที่เคยเจอและแก้แล้ว

> TODO: เพิ่มเมื่อเจอ bug

---

**จบเอกสาร** — หลัง migrate billing เสร็จ ลบ section 5 (current state) และเลื่อน section 6 เป็น 5