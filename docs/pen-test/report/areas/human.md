# Pen Test (Human) — รายงานพื้นที่เช่า (AreasReport) — `/report/areas`

> **เอกสารนี้คืออะไร** — manual UI walkthrough สำหรับ top-level menu `/report/areas` (AreasReportPage — ภาพรวมพื้นที่เช่า export xlsx)
>
> **Automated test** → [`ai.md`](./ai.md)
>
> **หมายเหตุ**: เมนูนี้ใช้ `customers_report_password_dialog.dart` ร่วมกับ `/report/customers` — พฤติกรรม password dialog เหมือนกัน ดู [`../customers/human.md`](../customers/human.md) section 2

---

## ภาพรวมระบบ

### ฟีเจอร์ที่ทดสอบ
AreasReportPage — ส่งออกภาพรวมพื้นที่เช่าเป็น xlsx (column picker + password confirm → preview → download)

```
AreasReportPage
   ├── Column picker (checklist + drag/drop reorder — 9 columns)
   ├── กด "ส่งออก" → CustomersReportPasswordDialog (shared widget)
   │     ├── โหมด default (@ChaoCmcity) → PasswordWithValue(default)
   │     └── โหมด custom → PasswordValidator → PasswordWithValue(custom)
   ├── AreasReportPreview (ตาราง preview ตาม columns ที่เลือก)
   │     + Header: total_area / total_leased / total_vacant
   └── ดาวน์โหลด xlsx → AreasReportExporter (IO หรือ Web)
```

| Action | คำอธิบาย |
|---|---|
| โหลด overview | ดึง `/admin/reports/areas/overview` (totals + items) |
| โหลด columns | ดึง `/admin/reports/areas/columns` (หรือ fallback 9 default) |
| เลือก columns | checklist + drag/drop reorder |
| ยืนยัน password | dialog 2 โหมด (default/custom) — shared กับ customers |
| Preview | ตาราง rows + header totals (area/leased/vacant) |
| ดาวน์โหลด | สร้าง xlsx → IO save / Web download (Blob) |

### API ที่ใช้ (v2 ✅)
- `GET /admin/reports/areas/columns` — โหลด columns (9 default: subzone, zone, lock, requester, customer_no, customer_tel, sdate, ldate, status)
- `GET /admin/reports/areas/overview?fields=...` — โหลด overview + totals + items

> **Note**: endpoint path ด้านบนเป็น preliminary — ตรวจสอบจาก `lib/ChiangMai_Municipality/Report_menu/areas/services/areas_report_service.dart` อีกครั้งเพื่อยืนยัน path จริง

### ฟีเจอร์ที่ตัดออก (ถ้ามี)
> - ❌ Server-side filter (zone/date range) — ตอนนี้ดึง overview ทั้งหมด
> - ❌ CSV export — มีแค่ xlsx

### Baseline
- commit: `6d1a298` (HEAD)

---

## สิ่งที่ต้องเตรียม

- ✅ `fvm flutter pub get` เรียบร้อย
- ✅ Login admin
- ✅ Backend v2 ขึ้นอยู่
- ✅ Browser DevTools Network tab เปิด (filter `admin/reports/areas`)
- ✅ commit ปัจจุบัน `6d1a298` หรือใหม่กว่า

---

## วิธีรัน

```bash
fvm flutter run -d chrome
```

หลังแอปเปิด:
1. Login → เมนู **รายงาน** → **รายงานพื้นที่เช่า**
2. URL ควรเป็น `/report/areas`
3. DevTools Network tab → filter `admin/reports/areas`

---

## 0. Pre-flight

- [ ] Hot reload สำเร็จ — ไม่มี compile error
- [ ] หน้า `/report/areas` เปิดได้ ไม่มี red error
- [ ] Network tab: `GET /admin/reports/areas/overview` → status `200`
- [ ] Network tab: `GET /admin/reports/areas/columns` → status `200`
- [ ] Header: total_area / total_leased / total_vacant แสดงตัวเลข
- [ ] Column picker แสดง 9 columns (default หรือจาก API)
- [ ] มีปุ่ม "ส่งออก" / "ดาวน์โหลด"

---

## 1. Column picker

### 1.1 Initial state
- [ ] Columns checklist แสดง 9 columns พร้อม TH labels (หมวดโซน, โซน, ล็อค, ผู้เช่า, เลขที่ลูกค้า, โทรศัพท์, วันเริ่ม, วันสิ้นสุด, สถานะ)
- [ ] Columns ที่เลือกไว้มี checkmark
- [ ] Drag handle (≡) ปรากฏข้างแต่ละ row

### 1.2 Toggle column
- [ ] ติ๊ก/unchecked column → state เปลี่ยน
- [ ] ยกเลิกทุก column → ปุ่ม "ส่งออก" disabled หรือ snackbar warning

### 1.3 Drag & drop reorder
- [ ] ลาก column ขึ้น/ลง → ลำดับเปลี่ยน
- [ ] Drop indicator แสดงตำแหน่งใหม่
- [ ] Preview table reorder ตาม (ถ้า preview เปิดอยู่)

---

## 2. Password dialog (shared widget — ดู customers section 2)

### 2.1 เปิด dialog
- [ ] กดปุ่ม "ส่งออก" → dialog เปิด
- [ ] Dialog มี 2 โหมด: "ใช้รหัสดีฟอลต์" / "ตั้งรหัสเอง"

### 2.2 โหมด default
- [ ] เลือก default → ปุ่ม "ยืนยัน" → `PasswordWithValue('@ChaoCmcity')`
- [ ] Dialog ปิด → preview + export flow ทำงานต่อ

### 2.3 โหมด custom
- [ ] เลือก custom → text field + checklist rules (7 rules)
- [ ] พิมพ์ password → rules tick/untick realtime
- [ ] กด "ยืนยัน" เมื่อทุก rule pass → `PasswordWithValue(custom)`
- [ ] กด "ยืนยัน" เมื่อ rule fail → error message (red text)

> ดู [`../customers/human.md`](../customers/human.md) section 2.4 สำหรับ rules checklist เต็ม

---

## 3. Preview + Totals

### 3.1 แสดง preview
- [ ] หลัง password confirm → preview table เปิด
- [ ] Header ตาราง = columns ที่เลือก + TH labels
- [ ] Rows = areas items ตาม columns
- [ ] Totals row ด้านบน: total_area (พื้นที่ทั้งหมด) / total_leased (เช่าแล้ว) / total_vacant (ว่าง)

### 3.2 Empty state
- [ ] ถ้า API คืน 0 items → preview แสดง "ไม่พบข้อมูล" + totals เป็น 0

---

## 4. ดาวน์โหลด (Export)

### 4.1 IO branch (mobile/desktop)
- [ ] กดปุ่ม "ดาวน์โหลด" → file picker เปิด
- [ ] Save as `.xlsx` (default filename: `areas_YYYYMMDD_HHmmss.xlsx`)
- [ ] เปิดไฟล์ใน Excel/LibreOffice → rows + columns ตรง preview
- [ ] Totals ปรากฏที่ header row ของ sheet
- [ ] Password protection (AES) ตรวจสอบได้ตอนเปิดไฟล์

### 4.2 Web branch
- [ ] กดปุ่ม "ดาวน์โหลด" → browser download
- [ ] ไฟล์ลงใน Downloads folder
- [ ] ขนาดไฟล์ > 0 bytes
- [ ] MIME type: `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`

### 4.3 Export phase indicator
- [ ] ระหว่าง export → ปุ่มแสดง phase label ("กำลังเตรียมข้อมูล..." → "กำลังสร้างไฟล์..." → "เสร็จสิ้น")
- [ ] หลังเสร็จ → snackbar success

---

## 5. Cache

### 5.1 Cache hit
- [ ] เปิดหน้า 2 ครั้ง (ภายใน 5 นาที) → ครั้งที่ 2 ใช้ cache (Network tab ไม่มี request)
- [ ] Console log: "fetchColumns cache hit (Xs)" / "fetchOverview cache hit (Xs)"

### 5.2 Force refresh
- [ ] กดปุ่ม refresh (ถ้ามี) → bypass cache → Network request ใหม่

---

## 6. Selector pattern (UI optimization)

### 6.1 Body rebuild isolation
- [ ] เปิด DevTools → Performance tab
- [ ] Toggle column → rebuild เฉพาะ `_BodyState` ที่เปลี่ยน (header/error banner ไม่ rebuild)
- [ ] Error banner — separate widget, ไม่ rebuild ทั้ง body เมื่อ error เปลี่ยน

---

## 7. Edge cases

- [ ] Network down → error banner + state ไม่ crash
- [ ] Token expired → redirect login
- [ ] Backend returns malformed JSON → defensive parser คืน empty result
- [ ] Columns API ล่ม → fallback 9 default columns
- [ ] Overview API ล่ม → totals = null, items = []
- [ ] ดาวน์โหลดระหว่าง network drop → error snackbar
- [ ] File ใหญ่ (> 100 MB) → export timeout → error

---

## 8. Backend verification

**คาดหวัง**: v2 (`/admin/reports/areas/*`) ทั้งหมด

- [ ] ไม่มี `.php` ใน URL ใดๆ ตลอดการทดสอบ
- [ ] ทุก response: status `200`/`201`/`204`
- [ ] ทุก request มี `Authorization: Bearer <token>`
- [ ] Endpoint paths ตรงกับ API table ด้านบน (verify กับ `areas_report_service.dart`)

### Endpoint ที่ใช้บ่อย
- [ ] `GET /admin/reports/areas/columns`
- [ ] `GET /admin/reports/areas/overview?fields=...`

---

## 9. Provider scope regression (ถ้าเคยเจอ)

> TODO: ระบุ bug ที่เคยเจอ (เช่น "Could not find Provider<AreasReportViewModel>") ถ้ามี

---

## เกณฑ์ Pass / Fail

### Pass
- ✅ AI Test ผ่าน (ถ้ามี tests)
- ✅ Human Test ทุก checkbox ผ่าน
- ✅ Network tab: ไม่มี `.php`
- ✅ Backend verification section 8 ทุกข้อ ✅
- ✅ ดาวน์โหลด xlsx ได้ + ตรง preview + totals ครบ

### Fail
- ❌ Red error บนหน้าจอ
- ❌ Totals ไม่แสดง
- ❌ Column picker ไม่อัปเดต
- ❌ Download ไฟล์ว่าง/เสีย
- ❌ Endpoint ใหม่ที่ไม่อยู่ใน list → unexpected, ต้อง flag

---

## ปัญหาที่เคยเจอและแก้แล้ว

> TODO: เพิ่มเมื่อเจอ bug

---

**Cross-links**:
- [README index](../../README.md)
- [AI test scope](./ai.md)
- [report/customers human](../customers/human.md) (sibling — share password dialog)
- [report/customers ai](../customers/ai.md) (password validator tests cover shared widget)
- [area human](../area/human.md) (similar v2 + read pattern)
