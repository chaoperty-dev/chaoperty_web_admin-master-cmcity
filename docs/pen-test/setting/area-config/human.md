# Pen Test (Human) — หน้า "ตั้งค่าพื้นที่เช่า" (full CRUD v2)

> **เอกสารนี้คืออะไร** — checklist ทดสอบด้วยตัวเองสำหรับฟีเจอร์ **ตั้งค่าพื้นที่เช่า** (Area / Group / Zone) ที่ migrate จาก PHP API เก่าไปใช้ v2 API ทั้งหมด
>
> **ใครรัน** — developer / tester / reviewer ที่เปิดแอปขึ้นมาแล้วกดทีละข้อ
>
> **สำหรับ automated unit test** → ดู [`area-pentest-ai.md`](./area-pentest-ai.md)

---

## ภาพรวมระบบ

### ฟีเจอร์ที่ทดสอบ
หน้า "ตั้งค่าพื้นที่เช่า" มี entity 3 ระดับที่เชื่อมกัน:

```
หมวด (Group)  ──┐
                ├── โซน (Zone)  ──┐
                │                ├── พื้นที่เช่า (Area / Lock)
                ├── โซน (Zone)  ──┘
หมวด (Group)  ──┘
```

ผู้ใช้ต้องทำ CRUD ครบทั้ง 3 ระดับผ่าน UI

### API ที่ใช้ (v2 ทั้งหมด — PHP legacy ถูกลบออกแล้ว)

| Method | Endpoint | ใช้ทำอะไร |
|---|---|---|
| GET | `/admin/areas/groups` | โหลดรายชื่อหมวด + sentinel "ทั้งหมด" |
| POST | `/admin/areas/groups` | เพิ่มหมวดใหม่ |
| PUT | `/admin/areas/groups/{ser}` | แก้ไขชื่อ/จำนวนหมวด |
| DELETE | `/admin/areas/groups/{ser}` | ลบหมวด |
| GET | `/admin/areas/zones?group_ser=...` | โหลดโซนในหมวดที่เลือก |
| POST | `/admin/areas/zones` | เพิ่มโซนใหม่ในหมวด |
| PUT | `/admin/areas/zones/{ser}` | แก้ไขชื่อ/จำนวนโซน |
| DELETE | `/admin/areas/zones/{ser}` | ลบโซน |
| GET | `/admin/areas/locks?per_page=&page=&zone_ser=&st=&q=` | โหลดรายการพื้นที่เช่า (พร้อม filter/search) |
| POST | `/admin/areas/locks` | เพิ่มพื้นที่เช่าใหม่ |
| PUT | `/admin/areas/locks/{ser}` | แก้ไข rent ของพื้นที่ |
| DELETE | `/admin/areas/locks/{ser}` | ลบพื้นที่เช่า |

### ฟีเจอร์ที่ตัดออก (intentional)
- ❌ **Type filter** (ล็อกเสียบ / ล็อกครึ่ง / etc.) — ไม่มี v2 endpoint → ตัดทิ้งทั้งหมด
- ❌ **Area count breakdown** (b_1, b_2, b_3, b_4) — ใช้ `result.total` จาก pagination meta แทน
- ❌ **Sub-zone dropdown** เดิม — เปลี่ยนเป็น Group dropdown (entity ใหม่ที่แยกจาก Zone)
- ❌ **PHP endpoints** (`GC_areatype.php`, `GC_areaCount.php` ฯลฯ) — ลบออกหมด

### Baseline
- commit: `2f91a0f` (HEAD) "test(area): unit tests + manual pen test checklist"

---

## สิ่งที่ต้องเตรียมก่อนเริ่ม

- ✅ รัน `fvm flutter pub get` เรียบร้อย
- ✅ Login เข้าสู่ระบบได้ (มี Bearer token ใน local storage / shared prefs)
- ✅ Backend v2 ขึ้นอยู่และตอบ 200 ที่ `/admin/areas/groups`
- ✅ Browser DevTools เปิด **Network tab** พร้อม (สำหรับตรวจ request)
- ✅ commit ปัจจุบันคือ `2f91a0f` (หรือใหม่กว่าที่มีฟีเจอร์ครบ)
- ✅ **ผ่าน AI Test ก่อน** ([`area-pentest-ai.md`](./area-pentest-ai.md)) — ถ้า AI fail ห้ามทำ Human Test

---

## วิธีรัน

```bash
# เปิดเว็บ (chrome)
fvm flutter run -d chrome

# หรือ iOS Simulator / Android Emulator / device จริง
fvm flutter run -d <device-id>
```

หลังแอปเปิด:
1. Login ด้วย user ที่มีสิทธิ์จัดการ area
2. ไปเมนู **ตั้งค่า** → **ตั้งค่าพื้นที่เช่า**
3. เปิด DevTools Network tab (F12) — filter คำว่า `admin/areas`
4. ทดสอบตาม checklist ด้านล่างทีละข้อ

---

## 0. Pre-flight — ตรวจก่อนเริ่ม

**จุดประสงค์**: ยืนยันว่า build/ระบบพร้อมก่อนลงรายละเอียด

- [ ] Hot reload จาก commit `2f91a0f` สำเร็จ — ไม่มี compile error ในคอนโซล
- [ ] หน้า "ตั้งค่าพื้นที่เช่า" เปิดได้ ไม่มี red error screen
- [ ] **Group dropdown** แสดง "ทั้งหมด" เป็น option แรก + รายชื่อหมวดที่มีอยู่ในระบบ
- [ ] **Zone dropdown** disabled อยู่ (จนกว่าจะเลือก group ที่ไม่ใช่ "ทั้งหมด")
- [ ] Network tab เห็น request แรก: `GET /admin/areas/groups` → status `200`
- [ ] ตารางพื้นที่ (table/card) แสดง row อย่างน้อย 1 row ถ้ามีข้อมูล

---

## 1. Group CRUD (หมวด)

### 1.1 Add Group — เพิ่มหมวดใหม่
**จุดประสงค์**: ทดสอบการสร้างหมวดใหม่ผ่าน UI

- [ ] เลือก "ทั้งหมด" ใน Group dropdown
- [ ] ปุ่ม **✏ แก้ไข** และ **🗑 ลบ** ของหมวด ต้อง **disabled** (สีเทา 0.4 opacity + กดไม่ติด)
- [ ] กดปุ่ม **+ เพิ่ม** ของหมวด → เปิดฟอร์ม 2-step wizard
- [ ] Step 1: กรอก "ชื่อหมวด" = `TestGroup_01` + "จำนวน" = `5` → กด **ถัดไป**
- [ ] Step 2 (Review): แสดงค่าที่กรอกถูกต้อง → กด **บันทึก**
- [ ] Snackbar เขียวแสดง "เพิ่มหมวดสำเร็จ"
- [ ] Group dropdown มี `TestGroup_01` เพิ่มขึ้นมา (Network: `POST /admin/areas/groups` → 200)

### 1.2 Edit Group — แก้ไขชื่อหมวด
**จุดประสงค์**: ทดสอบการแก้ไข + prefill ทำงานถูกต้อง

- [ ] เลือก `TestGroup_01` ใน Group dropdown
- [ ] กดปุ่ม **✏ แก้ไข** ของหมวด → ฟอร์ม "แก้ไขหมวด" เปิดขึ้น
- [ ] Step 1: fields prefill ถูกต้อง ("TestGroup_01", 5)
- [ ] เปลี่ยนชื่อเป็น `TestGroup_01_renamed` → กด **ถัดไป** → **บันทึก**
- [ ] Snackbar "แก้ไขหมวดสำเร็จ" (Network: `PUT /admin/areas/groups/{ser}` → 200)
- [ ] Dropdown แสดง `TestGroup_01_renamed` (แทนชื่อเดิม)

### 1.3 Delete Group — ลบหมวด
**จุดประสงค์**: ทดสอบ confirm dialog + cascade reset

- [ ] เลือก `TestGroup_01_renamed`
- [ ] กดปุ่ม **🗑 ลบ** → dialog "ยืนยันการลบหมวด" ปรากฏ ถามชื่อหมวดชัดเจน
- [ ] กด **ยกเลิก** → dialog ปิด + dropdown ยังมีหมวดอยู่ (Network: ไม่มี DELETE request)
- [ ] กด **🗑 ลบ** อีกครั้ง → กด **ยืนยัน**
- [ ] Snackbar "ลบหมวด \"TestGroup_01_renamed\" สำเร็จ" (Network: `DELETE /admin/areas/groups/{ser}` → 200)
- [ ] Group dropdown กลับเป็น "ทั้งหมด" (auto-reset)
- [ ] Zone dropdown ว่าง + disabled

---

## 2. Zone CRUD (โซน)

### 2.1 Add Zone — เพิ่มโซนใหม่
**จุดประสงค์**: ทดสอบการเพิ่มโซน + bind กับ group

- [ ] เลือก group ที่มีอยู่ (เช่น "อาคาร A") — ไม่ใช่ "ทั้งหมด"
- [ ] Zone dropdown enabled + แสดงรายชื่อโซนในหมวดนั้น
- [ ] กดปุ่ม **+ เพิ่ม** ของโซน → ฟอร์ม "เพิ่มโซน" เปิด + banner แสดง "หมวด: อาคาร A"
- [ ] Step 1: กรอก "ชื่อโซน" = `TestZone_01` → กด **ถัดไป** → **บันทึก**
- [ ] Snackbar "เพิ่มโซนสำเร็จ" (Network: `POST /admin/areas/zones` body มี `group_ser` ของ "อาคาร A")
- [ ] Zone dropdown มี `TestZone_01` เพิ่มขึ้น

### 2.2 Edit Zone — แก้ไขชื่อโซน
- [ ] เลือก `TestZone_01` ใน Zone dropdown
- [ ] กดปุ่ม **✏ แก้ไข** ของโซน → ฟอร์ม prefill "TestZone_01"
- [ ] เปลี่ยนเป็น `TestZone_01_renamed` → บันทึก
- [ ] Snackbar "แก้ไขโซนสำเร็จ" (Network: `PUT /admin/areas/zones/{ser}` → 200)
- [ ] Dropdown แสดงชื่อใหม่

### 2.3 Delete Zone — ลบโซน
- [ ] เลือก `TestZone_01_renamed` → กดปุ่ม **🗑 ลบ** → dialog → กด **ยืนยัน**
- [ ] Snackbar "ลบโซน \"...\" สำเร็จ" (Network: `DELETE /admin/areas/zones/{ser}` → 200)
- [ ] โซนหายจาก dropdown

### 2.4 Duplicate name guard — ป้องกันชื่อซ้ำ
**จุดประสงค์**: ทดสอบ business rule "ห้ามมีชื่อโซนซ้ำในหมวดเดียวกัน"

- [ ] เพิ่มโซน `DupZone` ในหมวด "อาคาร A" → สำเร็จ
- [ ] พยายามเพิ่ม `DupZone` อีกครั้งในหมวดเดียวกัน (เปิดฟอร์ม → กรอกชื่อเดิม → บันทึก)
- [ ] Snackbar แดง "มีโซนชื่อ \"DupZone\" อยู่ในหมวดนี้แล้ว" (Network: `POST` อาจได้ 409 หรือ 422)
- [ ] โซน `DupZone` มีแค่ 1 row (ไม่เพิ่มซ้ำ)
- [ ] ลบ `DupZone` ออกหลังทดสอบ

---

## 3. Area CRUD (พื้นที่เช่า)

### 3.1 Add Area — เพิ่มพื้นที่
**จุดประสงค์**: ทดสอบการสร้างพื้นที่เช่า + 2-step form

- [ ] เลือก group + zone ที่มีอยู่
- [ ] กดปุ่ม **+ สร้างพื้นที่เช่า** (header) → ฟอร์ม "เพิ่ม Area" เปิด
- [ ] Zone dropdown ในฟอร์ม preselected ตามที่เลือกไว้
- [ ] Step 1: กรอก `ln=LN001`, `lncode=A-001`, `area=15.5`, `rent=2500` → กด **ถัดไป**
- [ ] Step 2 (Review): แสดงค่าครบ **โดยไม่มี row ซ้ำ** (เคยมี bug duplicate ln)
- [ ] กด **บันทึก** → Snackbar "เพิ่ม Area สำเร็จ" (Network: `POST /admin/areas/locks` body ครบ 5 fields)
- [ ] Table/card แสดง row ใหม่ (refresh อัตโนมัติ)

### 3.2 Edit Area — แก้ไข rent
**จุดประสงค์**: ทดสอบ prefill + partial update (PUT ส่งแค่ rent)

- [ ] Table mode: กด **✏** ใน row / Card mode: กด **เรียกดู** → ฟอร์ม "แก้ไข Area" เปิด
- [ ] Fields prefill ถูกต้อง (ln, lncode, area, rent)
- [ ] เปลี่ยน rent เป็น `3000` → บันทึก
- [ ] Snackbar "แก้ไข Area สำเร็จ" (Network: `PUT /admin/areas/locks/{ser}` body มีแค่ `{"rent": "3000"}`)
- [ ] Row ใน table แสดง rent = `3000`

### 3.3 Delete Area — ลบพื้นที่
**จุดประสงค์**: ทดสอบปุ่มลบใน row/card (ฟีเจอร์ใหม่ที่เพิ่มเข้ามา)

- [ ] กด **🗑** ใน row (table mode) หรือไอคอนลบในการ์ด → dialog "ยืนยันการลบพื้นที่" ถามชื่อ "LN001"
- [ ] กด **ยกเลิก** → row ยังอยู่
- [ ] กด **🗑** → **ยืนยัน** → Snackbar "ลบ \"LN001\" สำเร็จ" (Network: `DELETE /admin/areas/locks/{ser}` → 200)
- [ ] Row หายไป

### 3.4 Filter cascade (table mode)
**จุดประสงค์**: ตรวจสอบว่า filter state คงอยู่หลังเปิด/ปิดฟอร์ม

- [ ] ตั้ง view mode = **ตาราง**
- [ ] กดเลือก row → กด **✏** → ฟอร์มเปิด → กด **ยกเลิก** หรือ ปิด
- [ ] Row ที่เลือกยังอยู่ + ค่า filter (group/zone/search) ไม่ reset

---

## 4. Search — ค้นหาพื้นที่
**จุดประสงค์**: ทดสอบ search filter + loading indicator

- [ ] พิมพ์ `LN` ใน search box → กด Enter / รอ debounce
- [ ] Table แสดงเฉพาะ row ที่ `ln` หรือ `lncode` มีคำว่า "LN"
- [ ] Clear search → table กลับมาแสดง row ทั้งหมด
- [ ] ระหว่าง search: เห็น **LinearProgressIndicator บางๆ** ด้านบน table (loading state)
- [ ] Network: `GET /admin/areas/locks?q=LN&...` → 200

---

## 5. View mode toggle — สลับตาราง/การ์ด
**จุดประสงค์**: ทดสอบ responsive grid + ปุ่ม action ในการ์ด

- [ ] กด toggle **การ์ด** → table เปลี่ยนเป็น grid (≥1100px → 3 col, ≥700px → 2 col, <700px → 1 col)
- [ ] กด toggle **ตาราง** → table กลับเป็น row view
- [ ] ในการ์ด: ปุ่ม **✏** + **🗑** แสดงเป็น 2 ปุ่มแยกกัน (ไม่ใช่รวมเป็นปุ่มเดียว)
- [ ] ปุ่มในการ์ดกดได้ + ทำงานถูกต้อง

---

## 6. Edge cases — กรณีขอบ
**จุดประสงค์**: ทดสอบ state ผิดปกติ

- [ ] **สลับ group**: เลือก "อาคาร A" → เลือก "อาคาร B" → Zone dropdown reset + โหลด zone ของ "อาคาร B"
- [ ] **เลือก "ทั้งหมด"**: zone dropdown disabled + ปุ่ม ✏/🗑 ของโซน disabled
- [ ] **Network down**: ปิด backend → กด action ใดๆ → snackbar error ขึ้น + state ไม่ crash + ไม่มี red error screen
- [ ] **State persistence**: ปิดหน้า + เปิดใหม่ → ค่า group = "ทั้งหมด", zone = ว่าง, search = ว่าง (reset ทุกครั้ง)

---

## 7. Backend verification — ตรวจ Network requests
**จุดประสงค์**: ยืนยันว่าใช้ v2 API ทั้งหมด (ไม่มี PHP หลงเหลือ)

- [ ] **ทุก mutation** ใช้ endpoint v2 (ไม่มี `.php` ใน URL):
  - [ ] `GET /admin/areas/groups`
  - [ ] `GET /admin/areas/zones?group_ser=...`
  - [ ] `GET /admin/areas/locks?per_page=...&page=...&zone_ser=...&q=...`
  - [ ] `POST /admin/areas/groups` body: `{zn, qty, pri, ren_pri}`
  - [ ] `PUT /admin/areas/groups/{ser}` body: `{zn, qty}`
  - [ ] `DELETE /admin/areas/groups/{ser}` → 200/204
  - [ ] `POST /admin/areas/zones` body: `{group_ser, zn, qty, status}`
  - [ ] `PUT /admin/areas/zones/{ser}` body: `{zn, qty}`
  - [ ] `DELETE /admin/areas/zones/{ser}` → 200/204
  - [ ] `POST /admin/areas/locks` body: `{zone_ser, lncode, ln, area, rent}`
  - [ ] `PUT /admin/areas/locks/{ser}` body: `{rent}` (partial)
  - [ ] `DELETE /admin/areas/locks/{ser}` → 200/204
- [ ] **ทุก response**: status `200` หรือ `204` (ไม่มี 404/500 จาก endpoint เก่า)
- [ ] **Auth header**: ทุก request มี `Authorization: Bearer <token>`
- [ ] **ไม่มี `.php`** ใน URL ใดๆ ตลอดการทดสอบ

---

## 8. Provider scope regression — regression test
**จุดประสงค์**: ป้องกัน bug เก่า "Could not find Provider<AreaViewModel>"

> **ประวัติ**: เคยมี bug นี้เพราะ `MaterialPageRoute.builder` สร้าง subtree ใหม่ที่ไม่ inherit Provider จาก parent — fix โดยใช้ `widget.viewModel` แทน `context.watch<AreaViewModel>()` ใน form page

- [ ] กดปุ่ม **+ สร้างพื้นที่เช่า** → ฟอร์มเปิดได้ ไม่มี red error "Could not find Provider<AreaViewModel>"
- [ ] กดปุ่ม **+ เพิ่ม** ของหมวด → ฟอร์มเปิดได้ ไม่มี red error
- [ ] กดปุ่ม **+ เพิ่ม** ของโซน → ฟอร์มเปิดได้ ไม่มี red error
- [ ] กดปุ่ม **✏** ของ row/การ์ด → ฟอร์ม edit เปิดได้ ไม่มี red error
- [ ] กดปุ่ม **✏** ของหมวด/โซน → ฟอร์ม edit เปิดได้ ไม่มี red error

---

## เกณฑ์ Pass / Fail

### Pass (พร้อม merge/release)
- ✅ AI Test ผ่าน 36/36 (ดู [`area-pentest-ai.md`](./area-pentest-ai.md))
- ✅ Human Test: ทุก checkbox ผ่าน (ยกเว้นข้อที่ skip พร้อมเหตุผล)
- ✅ Network tab: ไม่มี `.php` request
- ✅ ไม่มี red error บนหน้าจอตลอดการทดสอบ

### Fail (ต้องแก้ก่อน merge)
- ❌ AI Test มี test fail/skipped → fix code ก่อน
- ❌ Network tab เจอ `.php` request → legacy ยังไม่หมด → ลบออก
- ❌ Red error บนหน้าจอ (Provider scope, null check, etc.) → fix ก่อน
- ❌ Snackbar ไม่ขึ้น / ขึ้นข้อความผิด → fix event/message
- ❌ Filter cascade ไม่ทำงาน (สลับ group → zone ไม่เปลี่ยน) → fix VM

---

## ปัญหาที่เคยเจอและแก้แล้ว

### Bug 1: Provider scope error
- **อาการ**: กดปุ่มเพิ่มพื้นที่เช่า → ขึ้น red error "Could not find Provider<AreaViewModel>"
- **สาเหตุ**: `MaterialPageRoute.builder` สร้าง subtree ใหม่ที่ไม่ inherit Provider จาก parent route
- **แก้**: ส่ง `viewModel` ผ่าน constructor ของ form page แทน → ใช้ `widget.viewModel` ตรงๆ
- **ไฟล์ที่แก้**: `lib/.../area/views/area_form_page.dart`
- **Regression test**: ดูหัวข้อ "Provider scope regression" ใน Human Test

### Bug 2: VM conflate group vs zone
- **อาการ**: `deleteZone` ลบ group, `fetchLocks` filter ด้วย group ser
- **สาเหตุ**: state เดียว `_zones` เก็บทั้ง group + zone, field `_selectedZoneSer` เก็บ group ser
- **แก้**: แยกเป็น `_groups` + `_zonesOfGroup`, `_selectedGroupSer` + `_selectedZoneSer`
- **ไฟล์ที่แก้**: `lib/.../area/viewmodels/area_view_model.dart`

### Bug 3: Duplicate review row ใน form
- **อาการ**: step 2 review แสดง row `ln` ซ้ำ 2 ครั้ง
- **สาเหตุ**: copy-paste error
- **แก้**: ลบ row ซ้ำออก
- **ไฟล์ที่แก้**: `lib/.../area/views/area_form_page.dart`

### Bug 4: Dead controllers
- **อาการ**: `_sn`, `_sw`, `_rentMaket`, `_typeId`, `_sname` ถูกสร้างแต่ไม่ render
- **สาเหตุ**: refactor ลด field แต่ลืมลบ controller
- **แก้**: ลบ controller ที่ไม่ใช้ออก
- **ไฟล์ที่แก้**: `lib/.../area/views/area_form_page.dart`

---

## ลำดับการทำงาน

1. ตรวจ AI Test ผ่านก่อน ([`area-pentest-ai.md`](./area-pentest-ai.md))
2. ทำ Human Test ตาม checklist นี้
3. ทั้งคู่ต้องผ่านก่อน merge

**จบเอกสาร** — ถ้ามีข้อสงสัยหรือพบ bug ที่ไม่อยู่ใน checklist นี้ กรุณาเพิ่มเข้าไปในหัวข้อ "ปัญหาที่เคยเจอและแก้แล้ว" เพื่อเป็น baseline สำหรับคนรุ่นต่อไป
