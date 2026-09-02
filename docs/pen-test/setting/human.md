# Pen Test (Human) — ตั้งค่า (hub) — `/setting`

> **เอกสารนี้คืออะไร** — hub walkthrough สำหรับ `/setting` page (launcher 4 sub-menus)
>
> **Sub-menu pentests**:
> - [area-config/human.md](area-config/human.md) — ตั้งค่าพื้นที่เช่า
> - access-rights/human.md — สิทธิ์การเข้าถึง (TBD)
> - payment-config/human.md — ตั้งค่าการชำระเงิน (TBD)
> - general-data/human.md — ข้อมูลทั่วไป (TBD — PHP legacy)
>
> **Automated test** → [`ai.md`](./ai.md)

---

## ภาพรวมระบบ

### ฟีเจอร์ที่ทดสอบ
SettingPage — hub page แสดง 4 menu cards และ push sub-page เมื่อกด

```
SettingPage (hub)
   ├── เปิด sub-menu: ตั้งค่าพื้นที่เช่า  → AreaConfigPage (group/zone/lock CRUD)
   ├── เปิด sub-menu: สิทธิ์การเข้าถึง      → AccessRightsPage (position/role/user CRUD)
   ├── เปิด sub-menu: ตั้งค่าการชำระเงิน   → PaymentConfigPage (payment/paytype/bank CRUD)
   └── เปิด sub-menu: ข้อมูลทั่วไป         → GeneralDataPage (rental general CRUD — PHP ⚠️)
```

### Hub API
- **ไม่มี API call ตรงๆ** — hub เป็น launcher ล้วน (Navigator.push)
- API calls อยู่ที่ sub-menu (ดู pentest folder แต่ละอัน)

### Baseline
- commit: `6d1a298` (HEAD)

---

## สิ่งที่ต้องเตรียม

- ✅ `fvm flutter pub get`
- ✅ Login (สิทธิ์ `setting`)
- ✅ commit `6d1a298`

---

## วิธีรัน

```bash
fvm flutter run -d chrome
```

หลังแอปเปิด:
1. Login → เมนู **ตั้งค่า** (ไอคอน settings)
2. URL ควรเป็น `/setting`
3. ควรเห็น **4 menu cards** (responsive grid)

---

## 0. Pre-flight

- [ ] Hot reload สำเร็จ
- [ ] หน้า `/setting` เปิดได้ ไม่มี red error
- [ ] Header แสดง "ตั้งค่า"
- [ ] 4 menu cards แสดงครบ:
  - [ ] สิทธิ์การเข้าถึง (Access Rights)
  - [ ] ตั้งค่าพื้นที่เช่า (Area Config)
  - [ ] ตั้งค่าการชำระเงิน (Payment Config)
  - [ ] ข้อมูลทั่วไป (General Data)
- [ ] **Network tab**: ไม่มี request ใดๆ ตอน hub โหลด (hub เป็น static)

---

## 1. Permission gating (ถ้ามี)

- [ ] ถ้า user ไม่มีสิทธิ์ → card นั้น disabled (สีเทา 0.4 opacity + กดไม่ติด)
- [ ] ถ้ามีสิทธิ์ครบ → กดได้ทุก card

---

## 2. Tap card → navigate

### 2.1 ตั้งค่าพื้นที่เช่า
- [ ] กด card "ตั้งค่าพื้นที่เช่า" → page push
- [ ] URL/state เปลี่ยน → sub-page แสดง group/zone/lock UI
- [ ] **ทำ Human Test ที่ [area-config/human.md](area-config/human.md)**

### 2.2 สิทธิ์การเข้าถึง
- [ ] กด card "สิทธิ์การเข้าถึง" → page push
- [ ] Position / User / Role UI แสดง
- [ ] **(TBD)** ดู [access-rights/](../../../../lib/ChiangMai_Municipality/Setting_menu/setting_page/access_rights/) folder

### 2.3 ตั้งค่าการชำระเงิน
- [ ] กด card "ตั้งค่าการชำระเงิน" → page push
- [ ] Payment / PayType / Bank UI แสดง
- [ ] **(TBD)** ดู [payment/](../../../../lib/ChiangMai_Municipality/Setting_menu/setting_page/payment/) folder

### 2.4 ข้อมูลทั่วไป
- [ ] กด card "ข้อมูลทั่วไป" → page push
- [ ] Rental general UI แสดง
- [ ] ⚠️ Network tab คาดว่าจะเห็น `.php` requests (ยัง migrate ไม่เสร็จ)
- [ ] **(TBD)** ดู [general_data/](../../../../lib/ChiangMai_Municipality/Setting_menu/setting_page/general_data/) folder

---

## 3. Back navigation

- [ ] กด back (browser back / in-app) → กลับมา hub
- [ ] Hub state คงอยู่ (selected card highlight ถ้ามี)
- [ ] กด card อื่น → push ใหม่
- [ ] ปิด + เปิด hub ใหม่ → ไม่มี state ค้าง

---

## 4. Edge cases

- [ ] **Network down** ตอน hub โหลด → hub render ปกติ (ไม่ต้องใช้ network)
- [ ] **Token expired** ตอนเปิด sub-menu → redirect login
- [ ] **Permission ถูกเพิกถอน** ระหว่างใช้งาน sub-menu → ปิด sub-menu กลับ hub → card disabled

---

## 5. Backend verification

**คาดหวัง**: Hub เองไม่มี API call

- [ ] Network tab ตอน hub โหลด: **ไม่มี request** (verify ก่อน tap card)
- [ ] Sub-menu แต่ละอัน → ดู pentest folder ของ sub-menu นั้น

---

## 6. Regression (ถ้าเคยเจอ)

> TODO: เพิ่มเมื่อเจอ bug

---

## ดูเพิ่ม

- [area-config/human.md](area-config/human.md) — ตัวอย่าง sub-menu pentest ที่ใช้เป็น template
- [Root README](../README.md) — master index

---

## Migration blocking checklist (general-data)

> ทำ checklist นี้ก่อน general-data จะ pass post-migration

- [ ] Backend มี v2 endpoints ครบทั้ง 12 (rental_general_*)
- [ ] `RentalGeneralService` ใช้ `domain_v2` แทน PHP path
- [ ] Manual test section 2.4 (แต่ละ endpoint) ผ่าน
- [ ] AI test ครอบ v2 path (ถ้าเขียน)
- [ ] อัปเดต README index — flip สถานะ general-data เป็น v2 ✅

---

## เกณฑ์ Pass / Fail (Hub)

### Pass
- ✅ 4 cards แสดงครบ
- ✅ Permission gating ทำงาน
- ✅ Tap card → navigate ถูก sub-menu
- ✅ Back navigation ทำงาน
- ✅ Hub ไม่มี network call

### Pass (per sub-menu)
- ✅ Sub-menu pentest folder: human + AI test pass (ดู [area-config/](area-config/) เป็น template)

### Fail
- ❌ Red error บน hub
- ❌ Card ไม่ navigate
- ❌ Hub ยิง network request (unexpected — flag)
- ❌ Back navigation crash

---

**จบเอกสาร** — ถ้า sub-menu ใหม่ถูกเพิ่มใน hub ให้สร้าง folder ใหม่ + update ตารางใน `ai.md`
