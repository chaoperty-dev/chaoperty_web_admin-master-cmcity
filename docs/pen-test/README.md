# Pen Test Index — ทุก menu ใน navigation_menu.json

> **เอกสารนี้คืออะไร** — master index ของ pentest checklist สำหรับทุก menu ที่ปรากฏใน `assets/menu/navigation_menu.json` (15 menu routes)
>
> **ใครควรอ่าน** — developer / tester / reviewer ที่ต้องการตรวจสอบว่าแต่ละ menu พร้อม merge/release หรือยัง
>
> **Source of truth** — `assets/menu/navigation_menu.json` (15 menu entries)
>
> **Baseline commit** — `6d1a298` (HEAD) "docs(pen-test): relocate existing area-config pentest into new pen-test folder"

---

## โครงสร้าง folder

```
docs/pen-test/
├── README.md          ← (ไฟล์นี้) master index
├── area/              → /area (AreaMenuPage — ต่อสัญญา/ประมูล/คืน)
├── tenant/            → /tenant (ผู้เช่า)
├── registration/      → /registration (ทะเบียน)
├── profile-manage/    → /profile/manage (จัดการข้อมูลส่วนตัว)
├── setting/           → /setting (hub — เปิด 4 sub-menus ผ่าน Navigator.push)
│   ├── ai.md          (hub overview)
│   ├── human.md       (hub walkthrough)
│   └── area-config/   → sub-menu "ตั้งค่าพื้นที่เช่า" (config area/group/zone)
├── license/           → group: ใบอนุญาต (8 children)
│   ├── announce/          → /announce          (ประกาศคำขอใบอนุญาต)
│   ├── contract/          → /contract          (คำขอใบอนุญาต)
│   ├── attach/            → /attach            (แนบเอกสารคำขอ)
│   ├── payment/           → /payment           (ชำระค่าธรรมเนียม)
│   ├── verify/            → /verify            (ตรวจสอบเอกสารคำขอ)
│   ├── fact-check/        → /fact-check        (ตรวจสอบข้อเท็จจริง)
│   ├── submit-approval/   → /submit-approval   (ส่งคำร้องขออนุมัติ)
│   └── approve/           → /approve           (อนุมัติคำร้อง)
└── report/            → group: รายงาน (2 children)
    ├── customers/     → /report/customers    (รายงานลูกค้า)
    └── areas/         → /report/areas        (รายงานพื้นที่เช่า)
```

แต่ละ leaf folder มี **2 ไฟล์**:
- `ai.md` — automated unit test scope + วิธีรัน
- `human.md` — manual UI walkthrough (0-N sections + edge cases + pass/fail)

---

## สรุปสถานะ — 15 menu routes

| # | Menu | Route | API Version | Tests | Pentest Folder |
|---|---|---|---|---|---|
| 1 | พื้นที่เช่า (AreaMenuPage) | `/area` | v2 ✅ | ❌ | [area/](area/) |
| 2 | ผู้เช่า | `/tenant` | ⚠️ **PHP** | ❌ | [tenant/](tenant/) |
| 3 | ใบอนุญาต › ประกาศ | `/announce` | v2 ✅ | ❌ | [license/announce/](license/announce/) |
| 4 | ใบอนุญาต › คำขอ | `/contract` | ⚠️ Mixed | ❌ | [license/contract/](license/contract/) |
| 5 | ใบอนุญาต › แนบเอกสาร | `/attach` | v2 ✅ | ❌ | [license/attach/](license/attach/) |
| 6 | ใบอนุญาต › ชำระค่าธรรมเนียม | `/payment` | ⚠️ **PHP** | ❌ | [license/payment/](license/payment/) |
| 7 | ใบอนุญาต › ตรวจเอกสาร | `/verify` | v2 ✅ | ❌ | [license/verify/](license/verify/) |
| 8 | ใบอนุญาต › ตรวจข้อเท็จจริง | `/fact-check` | v2 ✅ | ❌ | [license/fact-check/](license/fact-check/) |
| 9 | ใบอนุญาต › ส่งอนุมัติ | `/submit-approval` | v2 ✅ | ❌ | [license/submit-approval/](license/submit-approval/) |
| 10 | ใบอนุญาต › อนุมัติ | `/approve` | ⚠️ Mixed | ❌ | [license/approve/](license/approve/) |
| 11 | ทะเบียน | `/registration` | ⚠️ Mixed | ✅ `registration_menu_test.dart` | [registration/](registration/) |
| 12 | รายงาน › ลูกค้า | `/report/customers` | ⚠️ Mixed | ✅ `customers_report_test.dart` | [report/customers/](report/customers/) |
| 13 | รายงาน › พื้นที่เช่า | `/report/areas` | v2 ✅ | ❌ | [report/areas/](report/areas/) |
| 14 | ตั้งค่า (hub) | `/setting` | ⚠️ Mixed | Partial (area sub) | [setting/](setting/) |
| 14a | └ ตั้งค่าพื้นที่เช่า (sub) | — | v2 ✅ | ✅ area_models/view_model | [setting/area-config/](setting/area-config/) |
| 15 | จัดการข้อมูลส่วนตัว | `/profile/manage` | v2 ✅ | ❌ | [profile-manage/](profile-manage/) |

**Legend**:
- v2 ✅ — ใช้ v2 API ทั้งหมด
- ⚠️ Mixed — ผสม v2 + PHP legacy (ต้อง flag ใน human.md section 7)
- ⚠️ **PHP** — ยังใช้ PHP legacy ล้วน (ต้อง migrate ก่อน release)
- ✅ Tests — มี automated test file ครอบคลุม

**Roll-up**: 4 pure v2 · 7 v2-effective · 5 mixed · 2 pure PHP · **24 distinct PHP endpoints still live**

---

## Migration Backlog — 24 PHP endpoints ที่ยังค้าง

> นี่คือ cleanup list สำหรับ migrate PHP → v2 (ทำเป็นแยก epic ได้)

### /tenant (1 endpoint)
- `GET GC_tenantAll_V2.php`

### /contract (7 endpoints)
- `GET GC_areaAll.php`
- `GET InC_BillDetail.php` (billing)
- `GET InC_Bill.php` (billing)
- `GET InC_Bill_Receipt.php` (billing)
- `POST InC_Bill_SubmitSlip.php` (billing)
- `POST InC_Bill_DeleteSlip.php` (billing)
- `GET HistoryBill.php` (billing history)

### /payment (12 endpoints)
- `POST InC_license_payment_*.php` × 12 (full CRUD list/detail/slip)

### /approve (1 endpoint — for legacy signature path)
- `POST InC_approval_legacy.php` (or similar)

### /registration (3 endpoints)
- `GET GC_custo_se.php`
- `GET GC_type.php`
- `POST registration_add_up.php`

### /setting/general_data (12 endpoints)
- `GET/POST/PUT/DELETE rental_general_*.php` × 12

> **Note**: ตัวเลขและ path ด้านบนอ้างอิงจาก Explore agent `a44f7ab1cba37fb57` (round 1). ตรวจสอบอีกครั้งใน pentest folder ของแต่ละ menu ก่อนทำ migration.

---

## วิธีใช้

### สำหรับคนทดสอบ UI
1. เปิด [human.md](setting/area-config/human.md) ของ menu ที่ต้องการทดสอบ
2. ทำตาม checklist ทีละข้อ (Pre-flight → CRUD sections → Edge cases → Backend verification)
3. ตรวจ Network tab ว่าไม่มี `.php` request (ยกเว้น menus ที่ flagged PHP)
4. ติ๊ก ✅ ใน checkbox — เก็บไว้เป็น regression baseline

### สำหรับคนเขียน unit test
1. ดู [ai.md](setting/area-config/ai.md) — list tests ที่มีอยู่
2. ถ้ายังไม่มี tests → follow pattern จาก [`test/area_view_model_test.dart`](../../test/area_view_model_test.dart)
   - สร้าง `FakeXxxService extends XxxService`
   - ใช้ `await Future<void>.delayed(Duration.zero)` × 2 รอ async bootstrap
   - ใช้ `vm.events.listen(...)` + `await Future<void>.delayed(...)` ก่อน assert event
3. Run: `fvm flutter test test/<menu>_models_test.dart test/<menu>_view_model_test.dart`

### สำหรับคน review PR
1. ดูตาราง "สรุปสถานะ" — flag menu ไหนยังไม่ pass
2. ตรวจ migration backlog — ถ้าเพิ่ม PHP endpoint ต้อง flag
3. ทุก PR ที่แตะ menu → require pentest folder นั้น update

---

## เกณฑ์ Pass / Fail ระดับ menu

### Pass (พร้อม merge)
- ✅ AI Test ผ่าน (ถ้ามี tests)
- ✅ Human Test ทุก checkbox ผ่าน
- ✅ Network tab ไม่มี `.php` (ยกเว้น menus ที่อยู่ใน migration backlog และติ๊ก skip พร้อมเหตุผล)

### Fail (ต้องแก้ก่อน merge)
- ❌ AI Test fail → fix code
- ❌ Red error บนหน้าจอ → fix VM/Provider scope
- ❌ PHP endpoint ใหม่ปรากฏ → update migration backlog + flag
- ❌ Snackbar ข้อความผิด → fix event/message

---

## Known bugs history

ดูในแต่ละ pentest folder → หัวข้อ "ปัญหาที่เคยเจอและแก้แล้ว" (เช่น [setting/area-config/human.md](setting/area-config/human.md) → Provider scope bug)

---

## Legend สำหรับสถานะในตาราง

- ✅ ผ่าน / มีครบ
- ⚠️ ต้องระวัง (mixed/PHP/test partial)
- ❌ ไม่มี

---

**จบเอกสาร** — ถ้ามี menu ใหม่ในอนาคต: เพิ่ม folder ใหม่ + update ตารางใน README นี้
