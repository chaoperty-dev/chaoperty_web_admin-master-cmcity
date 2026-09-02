# Pen Test (AI) — หน้า "ตั้งค่าพื้นที่เช่า" (full CRUD v2)

> **เอกสารนี้คืออะไร** — checklist ทดสอบอัตโนมัติสำหรับฟีเจอร์ **ตั้งค่าพื้นที่เช่า** (Area / Group / Zone) ที่ migrate จาก PHP API เก่าไปใช้ v2 API ทั้งหมด
>
> **ใครรัน** — `flutter test` (CI หรือ local) — ไม่ต้องเปิดแอป
>
> **สำหรับ manual UI test** → ดู [`area-pentest-human.md`](./area-pentest-human.md)

---

## ภาพรวม

- ใช้ `flutter_test` framework
- **ไม่ยิง HTTP จริง** — ใช้ `FakeAreaService extends AreaService` (in-memory stub)
- รัน **36 tests** ใช้เวลา < 30 วินาที
- ถ้ามี regression → fail ทันที
- ต้องผ่านก่อน merge / release

### Baseline
- commit: `2f91a0f` (HEAD) "test(area): unit tests + manual pen test checklist"

---

## สิ่งที่ต้องเตรียม

- ✅ ติดตั้ง [fvm](https://fvm.app/) + Flutter 3.38.3
- ✅ อยู่ที่ root ของโปรเจกต์ (`d:\NEW\CMM\chaoperty`)
- ✅ มีไฟล์ `test/area_models_test.dart` และ `test/area_view_model_test.dart`

---

## วิธีรัน

```bash
# จาก root ของโปรเจกต์
fvm flutter test test/area_models_test.dart test/area_view_model_test.dart
```

**ผลที่คาดหวัง**:
- exit code `0`
- output ลงท้ายด้วย `All tests passed!`
- จำนวน tests: `+36` (17 model + 19 viewmodel)

---

## ขอบเขตที่ครอบคลุม

### A. Model Factories — `test/area_models_test.dart` (17 tests)

#### `AreaZoneModel.fromGroup()` — สร้าง row หมวด
- [ ] สร้าง row หมวดจาก JSON ครบทุก field (ser, zn, qty, img, data_update)
- [ ] ใช้ค่า default เมื่อ JSON ขาด field (zn='', qty='0', img='0', data_update='')
- [ ] เมื่อ JSON ไม่มี ser → fallback เป็น `"0"`
- [ ] ในกรณี group, `rser` เท่ากับ `ser` (backward compat)
- [ ] ในกรณี group, `groupSer` เป็น null (ไม่มี parent)

#### `AreaZoneModel.fromZone()` — สร้าง row โซน
- [ ] สร้าง row โซน + เก็บ `groupSer` เป็น FK ชี้ parent
- [ ] `rser` เท่ากับ `groupSer` (backward compat กับของเก่า)
- [ ] เมื่อ `group_ser` หายไป → default `"0"`

#### `AreaZoneModel.fromJson()` — auto-route
- [ ] JSON มี key `group_ser` → ใช้ `fromZone`
- [ ] JSON ไม่มี key `group_ser` → ใช้ `fromGroup`

#### `AreaZoneModel.isAll` — sentinel detection
- [ ] `ser='0'` + `zn='ทั้งหมด'` → `true`
- [ ] `ser!='0'` → `false` (แม้ zn จะเป็น "ทั้งหมด" ก็ตาม)
- [ ] `zn` เป็นอย่างอื่น → `false` (แม้ ser จะเป็น "0" ก็ตาม)

#### `AreaAreaModel.fromJson` — payload parser
- [ ] parse payload ครบ (ser, ln, sn, sname, sw, lncode, area, rent, rent_maket, zone, zn, type_id, type_name, rser, cid, cname, stype, quantity)
- [ ] รองรับ snake_case alias `rent_maket` → `rentMaket`
- [ ] รองรับ zone alias: `zone_ser` → zone, `zser` → zone
- [ ] ใช้ค่า default เมื่อ JSON ขาด field (rent='0', zone='0', quantity='0', etc.)

#### `AreaAreaModel.isOccupied`
- [ ] `cid` ว่าง/null → `false` (พื้นที่ว่าง)
- [ ] `cid` เป็น string ว่าง `''` → `false`
- [ ] `cid` เป็น string ที่มีอักขระ (trim แล้วยังเหลือ) → `true`

#### `AreaAreaModel.toJson` — round-trip
- [ ] `fromJson(toJson(x))` ให้ผลเทียบเท่า `x` (เฉพาะ field ที่ serialize)

---

### B. ViewModel CRUD — `test/area_view_model_test.dart` (19 tests)

ใช้ `FakeAreaService extends AreaService` (in-memory, ไม่ยิง HTTP)

#### Bootstrap & Cascade
- [ ] ตอน construct → โหลดกลุ่มอัตโนมัติ + แทรก sentinel "ทั้งหมด" เป็น item แรก
- [ ] `selectedGroupSer` default = `'0'` (sentinel)
- [ ] `onGroupChanged(ser, name)` → reset `_selectedZoneSer = null` + โหลด zones ของ group นั้น
- [ ] `onGroupChanged('0', 'ทั้งหมด')` → zones list ว่าง (sentinel ไม่มีโซนย่อย)
- [ ] `onZoneChanged(ser, name)` → เก็บ zone ser จริง + `selectedZone` lookup ได้
- [ ] หลัง `onZoneChanged`, `selectedZoneName` ตรงกับที่ส่งเข้าไป

#### CRUD: Group (หมวด)
- [ ] `addGroup(zn:, qty:)` สำเร็จ → emit `AreaSuccessEvent("เพิ่มหมวดสำเร็จ")` + row ใหม่ใน `vm.groups`
- [ ] `addGroup` fail (service คืน false) → emit `AreaErrorEvent` + ไม่เพิ่ม row
- [ ] `updateGroup(ser:, zn:)` → emit success event + row อัปเดตชื่อใน `vm.groups`
- [ ] `deleteGroup(ser:)` ของกลุ่มที่ **ไม่ได้เลือกอยู่** → ลบ row ออก + ค่าที่เลือกอยู่ไม่เปลี่ยน
- [ ] `deleteGroup(ser:)` ของกลุ่มที่ **เลือกอยู่** → reset กลับเป็น sentinel `('0', 'ทั้งหมด')` + zones ว่าง

#### CRUD: Zone (โซน)
- [ ] `addZone(groupSer:, zn:)` ซ้ำกับที่มีอยู่ → return `false` + emit `AreaErrorEvent("...อยู่ในหมวดนี้แล้ว")`
- [ ] `addZone` สำเร็จ (ชื่อไม่ซ้ำ) → return `true` + row ใหม่ปรากฏใน `vm.zones`
- [ ] `updateZone(ser:, zn:)` → row ใน `vm.zones` เปลี่ยนชื่อ
- [ ] `deleteZone(ser:)` → row หายจาก `vm.zones`

#### CRUD: Lock (Area / พื้นที่เช่า)
- [ ] `addArea(zone:, ln:, lncode:, area:, rent:)` → row ใหม่ปรากฏใน `vm.areas` (filter ตาม zone ที่เลือก)
- [ ] `updateArea(ser:, rent:)` → row ใน `vm.areas` เปลี่ยน rent
- [ ] `deleteArea(area)` → row หายจาก `vm.areas`

#### Filter / Search
- [ ] `fetchLocks` filter ตาม `zone_ser` — `areaCount` ตรงกับจำนวน row ที่ filter
- [ ] `setSearch("A-001")` + `executeSearch()` → areas เหลือเฉพาะ row ที่ match
- [ ] `setSearch("zzz-nothing")` → areas ว่าง
- [ ] Sort ตาม `lncode.padLeft(8)` — ผลลัพธ์เรียง `['A-001', 'A-002', 'A-010']` (ไม่ใช่ `'A-001', 'A-010', 'A-002'`)

---

## เกณฑ์ Pass / Fail

### Pass (พร้อม merge/release)
- ✅ exit code = `0`
- ✅ output ลงท้ายด้วย `All tests passed!`
- ✅ ไม่มี test ไหนขึ้น `+1 -1` (failed/skipped)
- ✅ จำนวน tests รวม = **36**

### Fail (ต้องแก้ก่อน merge)
- ❌ exit code != `0`
- ❌ มี test fail หรือ skipped
- ❌ จำนวน tests ไม่ครบ 36

**ถ้า AI Test fail → ห้ามทำ Human Test ต่อ — fix code ก่อน**

---

## ลำดับการทำงาน

1. รัน AI Test ก่อน (ไฟล์นี้)
2. ผ่านแล้วค่อยไปทำ Human Test ([`area-pentest-human.md`](./area-pentest-human.md))
3. ทั้งคู่ต้องผ่านก่อน merge
