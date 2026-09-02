# Pen Test (Human) — รายงานลูกค้า (CustomersReport) — `/report/customers`

> ⚠️ **MIXED API** — เมนูนี้ใช้ v2 เป็นหลัก (`/admin/reports/customers`) + v1 fallback (`/v1/admin/c-customers`) — Network จะเห็นทั้งสอง version
>
> **Automated test** → [`ai.md`](./ai.md)

---

## ภาพรวมระบบ

### ฟีเจอร์ที่ทดสอบ
CustomersReportPage — ส่งออกทะเบียนลูกค้าเป็น Excel/CSV (column picker + password confirm → preview → download)

```
CustomersReportPage
   ├── Column picker (checklist + drag/drop reorder)
   ├── กด "ส่งออก" → CustomersReportPasswordDialog
   │     ├── โหมด default (@ChaoCmcity) → PasswordWithValue(default)
   │     └── โหมด custom → PasswordValidator → PasswordWithValue(custom)
   ├── CustomersReportPreview (ตาราง preview ตาม columns ที่เลือก)
   └── ดาวน์โหลด xlsx → CustomersReportExporter (IO หรือ Web)
```

| Action | คำอธิบาย |
|---|---|
| โหลด columns | ดึง `/admin/reports/customers/columns` (หรือ fallback 21 default) |
| เลือก columns | checklist + drag/drop reorder |
| ยืนยัน password | dialog 2 โหมด (default/custom) + password validator |
| Preview | ตารางแสดง rows ตาม columns |
| ดาวน์โหลด | สร้าง xlsx → IO save / Web download (Blob) |

### API ที่ใช้ (v2 primary + v1 fallback)
- `GET /admin/reports/customers/columns` — v2 ✅ โหลด columns
- `GET /admin/reports/customers` — v2 ✅ โหลด items
- `GET /v1/admin/c-customers?page=N&per_page=M` — v1 ⚠️ fallback สำหรับ "ทะเบียนผู้เช่า"

### Baseline
- commit: `6d1a298` (HEAD)

---

## สิ่งที่ต้องเตรียม

- ✅ `fvm flutter pub get` เรียบร้อย
- ✅ Login admin
- ✅ Backend v2 + v1 ขึ้นอยู่ (ทั้งคู่)
- ✅ DevTools Network tab — filter `admin/reports/customers` + `c-customers`
- ✅ commit `6d1a298`

---

## วิธีรัน

```bash
fvm flutter run -d chrome
```

หลังแอปเปิด:
1. Login → เมนู **รายงาน** → **รายงานลูกค้า**
2. URL ควรเป็น `/report/customers`

---

## 0. Pre-flight

- [ ] Hot reload สำเร็จ
- [ ] หน้า `/report/customers` เปิดได้ ไม่มี red error
- [ ] Network tab: `GET /admin/reports/customers/columns` → 200 (v2 — expected)
- [ ] Network tab: `GET /admin/reports/customers` → 200 (v2 — expected)
- [ ] Column picker แสดง 21 columns (default หรือจาก API)
- [ ] มีปุ่ม "ส่งออก" / "ดาวน์โหลด"

---

## 1. Column picker

### 1.1 Initial state
- [ ] Columns checklist แสดงครบ 21 columns พร้อม TH labels
- [ ] Columns ที่เลือกไว้มี checkmark
- [ ] Drag handle (≡) ปรากฏข้างแต่ละ row

### 1.2 Toggle column
- [ ] ติ๊ก/ unchecked column → state เปลี่ยน
- [ ] ยกเลิกทุก column → ปุ่ม "ส่งออก" disabled หรือ snackbar warning

### 1.3 Drag & drop reorder
- [ ] ลาก column ขึ้น/ลง → ลำดับเปลี่ยน
- [ ] Drop indicator แสดงตำแหน่งใหม่
- [ ] Preview table reorder ตาม (ถ้า preview เปิดอยู่)

---

## 2. Password dialog

### 2.1 เปิด dialog
- [ ] กดปุ่ม "ส่งออก" → dialog เปิด
- [ ] Dialog มี 2 โหมด: "ใช้รหัสดีฟอลต์" / "ตั้งรหัสเอง"

### 2.2 โหมด default
- [ ] เลือก default → ปุ่ม "ยืนยัน" → `PasswordWithValue('@ChaoCmcity')`
- [ ] Dialog ปิด → preview แสดง

### 2.3 โหมด custom
- [ ] เลือก custom → text field + checklist rules
- [ ] พิมพ์ password → rules tick/untick realtime
- [ ] กด "ยืนยัน" เมื่อทุก rule pass → `PasswordWithValue(custom)`
- [ ] กด "ยืนยัน" เมื่อ rule fail → error message (red text)
- [ ] กด "ยกเลิก" → `PasswordCancel` → dialog ปิด

### 2.4 Password validator rules (visual checklist)
- [ ] อย่างน้อย 6 ตัวอักษร
- [ ] ตัวพิมพ์เล็ก (a-z)
- [ ] ตัวพิมพ์ใหญ่ (A-Z)
- [ ] ตัวเลข (0-9)
- [ ] อักษรพิเศษ (!@#$%^&*)
- [ ] ไม่ใช่รหัสที่ใช้บ่อย (blacklist + sequential)
- [ ] ไม่มีตัวอักษรซ้ำเกิน 3 ตัว

---

## 3. Preview

### 3.1 แสดง preview
- [ ] หลัง password confirm → preview table เปิด
- [ ] Headers = columns ที่เลือก + TH labels
- [ ] Rows = customer items ตาม columns
- [ ] รองรับ horizontal scroll ถ้า columns เยอะ

### 3.2 Empty state
- [ ] ถ้า API คืน 0 items → preview แสดง "ไม่พบข้อมูล"

---

## 4. ดาวน์โหลด (Export)

### 4.1 IO branch (mobile/desktop)
- [ ] กดปุ่ม "ดาวน์โหลด" → file picker เปิด
- [ ] Save as `.xlsx` (default filename: `customers_YYYYMMDD_HHmmss.xlsx`)
- [ ] เปิดไฟล์ใน Excel/LibreOffice → rows + columns ตรง preview
- [ ] Password protection (AES) ตรวจสอบได้ตอนเปิดไฟล์

### 4.2 Web branch
- [ ] กดปุ่ม "ดาวน์โหลด" → browser download
- [ ] ไฟล์ลงใน Downloads folder
- [ ] ขนาดไฟล์ > 0 bytes
- [ ] MIME type: `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`

---

## 5. Cache

### 5.1 Cache hit
- [ ] เปิดหน้า 2 ครั้ง (ภายใน 5 นาที) → ครั้งที่ 2 ใช้ cache (Network tab ไม่มี request)
- [ ] Console log: "fetchColumns cache hit (Xs)" / "fetchItems cache hit (Xs)"

### 5.2 Force refresh
- [ ] กดปุ่ม refresh (ถ้ามี) → bypass cache → Network request ใหม่

---

## 6. Edge cases

- [ ] Network down → snackbar error + state ไม่ crash
- [ ] Token expired → redirect login
- [ ] Backend returns malformed JSON → defensive parser คืน 0 items
- [ ] Columns API ล่ม → fallback 21 default columns
- [ ] ดาวน์โหลดระหว่าง network drop → error snackbar
- [ ] File ใหญ่ (> 100 MB) → export timeout → error

---

## 7. Backend verification (CURRENT STATE — MIXED)

**คาดหวังตอนนี้**: ⚠️ Mixed — v2 สำหรับ `/admin/reports/customers/*`, v1 สำหรับ `/v1/admin/c-customers` (ห้าม fail test เพราะเรื่องนี้)

- [ ] `GET /admin/reports/customers/columns` → 200 (v2 — expected)
- [ ] `GET /admin/reports/customers` → 200 (v2 — expected)
- [ ] `GET /v1/admin/c-customers?page=N&per_page=M` → 200 (v1 — expected, ใช้สำหรับทะเบียนผู้เช่า)
- [ ] ทุก response: status `200`/`204`
- [ ] ทุก request มี `Authorization: Bearer <token>`

### Backend verification (POST-MIGRATION TARGET)

> ใช้ checklist นี้หลัง migrate v1 → v2 เสร็จ

- [ ] `GET /admin/c-customers?page=N&per_page=M` → 200 (v2 — แทนที่ v1)
- [ ] ❌ **ไม่มี `/v1/admin/c-customers`** ใน URL
- [ ] ทุก mutation (ถ้ามี) ใช้ v2

---

## 8. Regression (ถ้าเคยเจอ)

> TODO: เพิ่มเมื่อเจอ bug

---

## Migration blocking checklist

> ทำ checklist นี้ก่อน mark menu นี้เป็น "v2 ✅" ใน README index

- [ ] Backend มี `GET /admin/c-customers` (Laravel paginated shape compatible)
- [ ] `CustomersReportService.fetchCCustomersPage()` เปลี่ยนจาก `domain_v1` → `domain_v2`
- [ ] Response contract เหมือนเดิม (data[], meta.current_page, meta.last_page, meta.total)
- [ ] Manual test section 4 → 5 (ทุก checkbox ✅)
- [ ] ลบ v1 fallback + import path
- [ ] อัปเดต README index — flip สถานะเป็น v2 ✅

---

## เกณฑ์ Pass / Fail

### Pass (current — mixed)
- ✅ AI Test ผ่าน (20+ tests)
- ✅ Human Test ทุก checkbox ผ่าน
- ✅ Network tab: เห็นทั้ง v2 (`/admin/reports/customers`) และ v1 (`/v1/admin/c-customers`)
- ✅ ฟีเจอร์ทำงานครบ (column picker → password → preview → download)
- ✅ ไฟล์ xlsx เปิดได้ + ตรง preview

### Pass (post-migration target)
- ✅ AI Test ผ่าน
- ✅ Human Test ทุก checkbox ผ่าน
- ✅ Network tab: ไม่มี `/v1/admin/c-customers`
- ✅ Backend verification section "POST-MIGRATION TARGET" ทุกข้อ ✅

### Fail
- ❌ Red error บนหน้าจอ
- ❌ Column picker ไม่อัปเดต
- ❌ Password validator ไม่ block weak password
- ❌ Download ไฟล์ว่าง/เสีย
- ❌ Endpoint ใหม่ที่ไม่อยู่ใน list → unexpected, ต้อง flag

---

## ปัญหาที่เคยเจอและแก้แล้ว

> TODO: เพิ่มเมื่อเจอ bug

---

**Cross-links**:
- [README index](../../README.md)
- [AI test scope](./ai.md)
- [report/areas human](../areas/human.md) (sibling — ใช้ password dialog ร่วมกัน)
- [report/areas ai](../areas/ai.md)

**จบเอกสาร** — หลัง migrate v1 fallback เสร็จ ลบ section 7 (current mixed) และเลื่อน POST-MIGRATION เป็น 7
