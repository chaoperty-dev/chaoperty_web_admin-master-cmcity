# Pen Test (Human) — จัดการข้อมูลส่วนตัว (PersonalInformation) — `/profile/manage`

> **เอกสารนี้คืออะไร** — manual UI walkthrough สำหรับ top-level menu `/profile/manage` (ManagePersonalInformationPage)
>
> **Automated test** → [`ai.md`](./ai.md)
>
> **หมายเหตุ**: หน้านี้จัดการ **user/signature ของ admin ที่ login อยู่** — ไม่ใช่ทะเบียนผู้เช่า (ดู [`../registration/`](../registration/) หรือ [`../tenant/`](../tenant/))

---

## ภาพรวมระบบ

### ฟีเจอร์ที่ทดสอบ
ManagePersonalInformationPage — หน้าจัดการ profile admin (read-only + edit signature):

```
ManagePersonalInformationPage (read-only info grid + signature section)
   ├── แก้ไขลายเซ็น → PersonalInformationSignatureDialog → ReusableSignaturePad → save
   └── ลองอีกครั้ง (error state) → vm.refresh()
```

| Action | คำอธิบาย |
|---|---|
| โหลด profile | ดึงข้อมูล admin (UUID, profile, position, email) |
| แสดงลายเซ็นปัจจุบัน | ดึงภาพ PNG จาก signatureUuid |
| แก้ไขลายเซ็น | เปิด dialog → วาดลายเซ็นใหม่ → save (multipart upload) |

### API ที่ใช้ (v2 ✅ โดยรวม — verify `/admin/know`)
- `GET /admin/know` — โหลด admin profile + signature_uuid (verify ใช้ v2 หรือ v1)
- `GET /admin/users/signatures/{uuid}/preview` — ดึงภาพลายเซ็น
- `POST /admin/users/{uuid}/signatures` — multipart upload ลายเซ็นใหม่

> **Note**: endpoint path ด้านบนเป็น preliminary — ตรวจสอบจาก `lib/ChiangMai_Municipality/Personal_information_menu/personal_information_page/unity/API_admin_signature.dart` และ `services/personal_information_service.dart` อีกครั้งเพื่อยืนยัน path จริงและ version

### ฟีเจอร์ที่ตัดออก (ถ้ามี)
> - ❌ Change password — หน้านี้ไม่มี (ถ้ามี → flag)
> - ❌ Edit profile name/position — ตอนนี้ read-only

### Baseline
- commit: `6d1a298` (HEAD) "docs(pen-test): relocate existing area-config pentest into new pen-test folder"

---

## สิ่งที่ต้องเตรียม

- ✅ `fvm flutter pub get` เรียบร้อย
- ✅ Login admin เข้าสู่ระบบ
- ✅ Backend v2 ขึ้นอยู่
- ✅ Browser DevTools Network tab เปิด (filter `admin/users`, `admin/know`)
- ✅ commit ปัจจุบัน `6d1a298` หรือใหม่กว่า
- ✅ มี signature pad (touch screen หรือ mouse) สำหรับทดสอบวาดลายเซ็น

---

## วิธีรัน

```bash
fvm flutter run -d chrome
```

หลังแอปเปิด:
1. Login → เปิดเมนู **จัดการข้อมูลส่วนตัว** (ไอคอน person/account)
2. URL ควรเป็น `/profile/manage`
3. DevTools Network tab → filter `admin/users` หรือ `admin/know`

---

## 0. Pre-flight

- [ ] Hot reload สำเร็จ — ไม่มี compile error
- [ ] หน้า `/profile/manage` เปิดได้ ไม่มี red error
- [ ] Header แสดง "ข้อมูลผู้ใช้" + ปุ่ม "แก้ไขลายเซ็น" ที่มุมขวา
- [ ] Network tab: `GET /admin/know` → status `200`
- [ ] Loading state (CircularProgressIndicator + "กำลังโหลดข้อมูล...") ปรากฏชั่วขณะ
- [ ] Info grid แสดง 4 fields: User UUID, Profile UUID, Signature UUID, ลายเซ็นปัจจุบัน

---

## 1. Profile info (read-only)

### 1.1 Initial load
- [ ] เปิดหน้า → loading indicator หายไปหลัง fetch เสร็จ
- [ ] Avatar แสดง (placeholder/initials ถ้าไม่มีรูป)
- [ ] User UUID แสดง (masked: `xxx***`)
- [ ] Profile UUID แสดง (masked: `xxx***`)
- [ ] Signature UUID แสดง (masked: `xxx***`) หรือ "-" ถ้ายังไม่มี
- [ ] "ลายเซ็นปัจจุบัน" แสดง "พร้อมใช้งาน" (เขียว) หรือ "ยังไม่มีลายเซ็น" (เหลือง)

### 1.2 Email
- [ ] Email จาก secure storage แสดงในส่วน info grid (ถ้ามี)

---

## 2. ลายเซ็น — ดูภาพปัจจุบัน

### 2.1 มีลายเซ็นอยู่แล้ว
- [ ] Signature section แสดงภาพลายเซ็น (PNG) ที่ดึงจาก `/admin/users/signatures/{uuid}/preview` → 200
- [ ] ภาพคมชัด ไม่เบลอ
- [ ] ขนาดภาพไม่เล็ก/ใหญ่เกินไป (responsive)

### 2.2 ยังไม่มีลายเซ็น
- [ ] Signature section แสดง placeholder ("ยังไม่มีลายเซ็น" + icon)
- [ ] ไม่มี error/red box

---

## 3. แก้ไขลายเซ็น (Upload ใหม่)

### 3.1 เปิด dialog
- [ ] กดปุ่ม "แก้ไขลายเซ็น" ที่ header
- [ ] Dialog เปิดพร้อม `ReusableSignaturePad` (พื้นที่วาด)
- [ ] มีปุ่ม Clear / Undo / Save / Cancel

### 3.2 วาดลายเซ็น
- [ ] ใช้ mouse/touch วาดลายเซ็นบน pad
- [ ] Stroke ติดตาม mouse ทันที (smooth)
- [ ] Clear ลบ stroke ทั้งหมด
- [ ] Undo ย้อน stroke ทีละชั้น

### 3.3 Save
- [ ] กด "บันทึก" → dialog ปิด
- [ ] ปุ่ม "แก้ไขลายเซ็น" แสดง spinner + "กำลังบันทึก..."
- [ ] Network: `POST /admin/users/{uuid}/signatures` (multipart) → 200
- [ ] Snackbar "บันทึกลายเซ็นสำเร็จ" ปรากฏ (เขียว)
- [ ] Signature section รีเฟรช → แสดงภาพใหม่

### 3.4 Cancel
- [ ] กด "ยกเลิก" → dialog ปิด
- [ ] ลายเซ็นเดิมไม่เปลี่ยน

---

## 4. Error handling

### 4.1 Load fail
- [ ] ปิด backend → refresh หน้า
- [ ] Error block ปรากฏ ("เกิดข้อผิดพลาด: ..." + icon แดง)
- [ ] กด "ลองอีกครั้ง" → reload

### 4.2 Save fail
- [ ] วาดลายเซ็น → save ขณะ backend down
- [ ] Snackbar "เกิดข้อผิดพลาด" ปรากฏ (error theme)
- [ ] Signature section ไม่เปลี่ยน (เก็บของเดิม)

### 4.3 Network timeout
- [ ] ช้ามาก → request timeout → error snackbar
- [ ] State ไม่ crash

### 4.4 Token expired
- [ ] Token หมดอายุขณะอยู่หน้านี้ → redirect login
- [ ] กลับมาหน้าเดิมหลัง login ใหม่

---

## 5. Responsive

### 5.1 Desktop (> 1024px)
- [ ] Layout 2 column (avatar + info grid ซ้าย, signature section ขวา)
- [ ] ปุ่ม "แก้ไขลายเซ็น" + label เต็ม

### 5.2 Mobile (< 768px)
- [ ] Layout 1 column (stacked)
- [ ] ปุ่ม "แก้ไขลายเซ็น" + icon อย่างเดียว (ไม่มี label)
- [ ] Info grid stack vertical

---

## 6. Edge cases

- [ ] เปิด dialog → ปิด → เปิดอีก → state reset (stroke ใหม่)
- [ ] เปิด dialog → กด back button → dialog ปิด (treat as cancel)
- [ ] Upload file ใหญ่มาก (> 5 MB) → handle gracefully (timeout/snackbar)
- [ ] Signature UUID ว่าง → ไม่ fetch preview, แสดง "ยังไม่มีลายเซ็น"
- [ ] User UUID ว่าง (edge case) → save error "ไม่พบ UUID ของผู้ใช้"

---

## 7. Backend verification

**คาดหวัง**: v2 (`/admin/...`) เป็นหลัก — flag ถ้าเห็น v1 path

- [ ] ไม่มี `.php` ใน URL ใดๆ ตลอดการทดสอบ
- [ ] ทุก response: status `200`/`201`/`204`
- [ ] ทุก request มี `Authorization: Bearer <token>`
- [ ] Endpoint paths ตรงกับ API table ด้านบน (verify กับ `API_admin_signature.dart`)

### Endpoint ที่ใช้บ่อย
- [ ] `GET /admin/know` (profile meta)
- [ ] `GET /admin/users/signatures/{uuid}/preview`
- [ ] `POST /admin/users/{uuid}/signatures` (multipart upload)

### ⚠️ ถ้าเจอ v1 path
> ถ้า Network tab แสดง `/v1/admin/know` หรือ `domain_v1` แทน v2 → flag ใน `ai.md` API endpoints table + update `human.md` section นี้

---

## 8. Provider scope regression (ถ้าเคยเจอ)

> TODO: ระบุ bug ที่เคยเจอ (เช่น "Could not find Provider<PersonalInformationViewModel>") ถ้ามี

---

## เกณฑ์ Pass / Fail

### Pass
- ✅ AI Test ผ่าน (ถ้ามี tests)
- ✅ Human Test ทุก checkbox ผ่าน
- ✅ Network tab: ไม่มี `.php`
- ✅ Backend verification section 7 ทุกข้อ ✅
- ✅ แก้ไขลายเซ็นได้จริง + ภาพอัปเดต
- ✅ Error handling ทำงานครบ

### Fail
- ❌ Red error บนหน้าจอ
- ❌ ภาพลายเซ็นไม่อัปเดตหลัง save
- ❌ Snackbar ข้อความผิด
- ❌ ไม่สามารถวาด/บันทึกลายเซ็นได้

---

## ปัญหาที่เคยเจอและแก้แล้ว

> TODO: เพิ่มเมื่อเจอ bug

---

**Cross-links**:
- [README index](../README.md)
- [area human](../area/human.md) (similar read-only/edit pattern)
- [registration human](../registration/human.md) (different feature — tenant registry)
