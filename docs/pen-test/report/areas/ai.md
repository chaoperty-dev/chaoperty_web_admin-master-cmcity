# Pen Test (AI) — รายงานพื้นที่เช่า (AreasReport) — `/report/areas`

> **เอกสารนี้คืออะไร** — automated test scope สำหรับ top-level menu `/report/areas` (AreasReportPage — ส่งออกภาพรวมพื้นที่เช่าเป็น xlsx)
>
> **Human test** → [`human.md`](./human.md)
>
> **หมายเหตุ**: เมนูนี้ใช้ `customers_report_password_dialog.dart` ร่วมกับ `/report/customers` — test ของ `PasswordValidator` ครอบคลุมทั้ง 2 เมนู ดู [`../customers/ai.md`](../customers/ai.md) สำหรับ password validator tests

---

## ภาพรวม

- **Status**: ❌ **No automated tests yet** (TBD)
- **Primary folder**: `lib/ChiangMai_Municipality/Report_menu/areas/` (10 dart files)
- **API version**: v2 ✅
- **Files of interest**:
  - `services/areas_report_service.dart` — `AreasReportService`, `AreasReportItem`, `AreasReportColumn`, `AreasReportResult` (มี `total_area`, `total_leased`, `total_vacant`)
  - `services/areas_report_exporter.dart` — `AreasReportExporter` interface
  - `services/areas_report_exporter_io.dart` — IO (mobile/desktop) export
  - `services/areas_report_exporter_web.dart` — Web export (Blob + download)
  - `viewmodels/areas_report_view_model.dart` — `AreasReportViewModel` (load/export)
  - `areas_report_page.dart` — main page (ใช้ `Selector` body rebuild + Error banner)
  - `views/widgets/areas_report_column_picker.dart` — column checklist
  - `views/widgets/areas_report_preview.dart` — preview table
  - `views/widgets/areas_report_header.dart` — page header
  - **Reused**: `../customers/views/widgets/customers_report_password_dialog.dart` (PasswordValidator + dialog)

---

## สิ่งที่ต้องเตรียม

- ✅ ติดตั้ง fvm + Flutter 3.38.3
- ✅ อยู่ที่ root ของโปรเจกต์
- ✅ Login admin + token ยังไม่หมดอายุ

---

## วิธีรัน (เมื่อเขียน test แล้ว)

> **ยังไม่มี test files** — section นี้จะ activate เมื่อ test ถูกเขียน

```bash
# คาดว่าจะมี test file ในอนาคต:
fvm flutter test test/areas_report_models_test.dart test/areas_report_view_model_test.dart
```

---

## Testable scenarios (TBD — ต้องเขียน)

### Model Factories
- [ ] `AreasReportItem` from JSON — parse `subzone`, `zone`, `lock`, `requester`, `customer_no`, `customer_tel`, `sdate`, `ldate`, `status`
- [ ] `AreasReportItem.getBy(field)` returns value by field name
- [ ] `AreasReportResult` — parse `data.date`, `data.announcement_uuid`, `data.total_area`, `data.total_leased`, `data.total_vacant`, `data.items[]`
- [ ] `AreasReportColumn` from JSON

### ViewModel CRUD
- [ ] `AreasReportViewModel.fetchColumns()` — bootstrap from service
- [ ] `AreasReportViewModel.fetchOverview()` — populate items + totals
- [ ] `AreasReportViewModel.export()` — call exporter (IO/Web) + emit events
- [ ] State flags: `isExporting`, `phaseLabel`, `errorMessage`
- [ ] Error path: service throws → emit error event

### Widget tests (pumpWidget + Provider)
- [ ] `AreasReportPage` initial loading state
- [ ] Column picker toggle + drag/drop reorder
- [ ] Preview table render with selected columns
- [ ] Password dialog — same widget as customers (ดู [`../customers/ai.md`](../customers/ai.md))
- [ ] Error banner widget — separate from body (Selector pattern)
- [ ] Export button states — disabled / exporting / done

### Exporter
- [ ] `AreasReportExporter` (IO) — write xlsx bytes to file
- [ ] `AreasReportExporter` (Web) — Blob + download
- [ ] Password AES round-trip — encrypted xlsx opens with correct password

---

## Pattern template — ใช้เป็น guide ตอนเขียน

อ้างอิง [`../../../test/area_view_model_test.dart`](../../../test/area_view_model_test.dart):

```dart
class FakeAreasReportService extends AreasReportService {
  AreasReportResult? _seed;
  void seedResult(AreasReportResult r) => _seed = r;

  @override
  Future<AreasReportResult> fetchOverview({bool forceRefresh = false}) async {
    return _seed ?? const AreasReportResult();
  }

  @override
  Future<List<AreasReportColumn>> fetchColumns({bool forceRefresh = false}) async {
    return AreasReportService.defaultColumns();
  }
}

void main() {
  group('AreasReportViewModel', () {
    late FakeAreasReportService svc;
    late AreasReportViewModel vm;

    setUp(() async {
      svc = FakeAreasReportService()
        ..seedResult(AreasReportResult(
          date: '2026-09-02',
          announcementUuid: 'a1',
          totalArea: 100,
          totalLeased: 80,
          totalVacant: 20,
          items: [
            AreasReportItem(
              subzone: 'A',
              zone: 'Z1',
              lock: 'L1',
              requester: 'บริษัท A',
              customerNo: 'C001',
              customerTel: '053-111',
              sdate: '2026-01-01',
              ldate: '2026-12-31',
              status: 'ใช้งาน',
            ),
          ],
        ));
      vm = AreasReportViewModel(service: svc);
      await vm.load();
    });

    test('load populates overview + totals', () {
      expect(vm.totalArea, 100);
      expect(vm.totalLeased, 80);
      expect(vm.totalVacant, 20);
      expect(vm.items.length, 1);
    });

    test('export sets isExporting then done', () async {
      expect(vm.isExporting, false);
      final future = vm.export(password: '@ChaoCmcity');
      // race-condition safe assert via events stream
      await future;
      expect(vm.isExporting, false);
    });
  });
}
```

---

## API endpoints ที่ใช้ (v2 ✅)

> ดูจาก `areas_report_service.dart` — verified v2

| Method | Endpoint | ใช้ทำอะไร |
|---|---|---|
| GET | `/admin/reports/areas/columns` | โหลด columns list (9 default) |
| GET | `/admin/reports/areas/overview?fields=...` | โหลด overview + totals + items |

> **Note**: `overview` ใช้ fixed fields query (`subzone,zone,lock,requester,customer_no,customer_tel,sdate,ldate,status`) — ไม่ dynamic ตาม column picker

---

## เกณฑ์ Pass / Fail (เมื่อมี test)

### Pass
- ✅ exit code `0`
- ✅ output ลงท้ายด้วย `All tests passed!`
- ✅ ทุก test pass (ไม่มี failed/skipped)

### Fail
- ❌ exit code != `0`
- ❌ มี test fail/skipped

**ถ้า AI Test fail → ห้าม merge — fix ก่อน**

---

## ลำดับการทำงาน

1. เขียน `test/areas_report_models_test.dart` (model factories + parser)
2. เขียน `test/areas_report_view_model_test.dart` (CRUD + totals + events)
3. เขียน widget test สำหรับ column picker + preview + error banner
4. เขียน exporter test (IO + Web branches + AES round-trip)
5. รัน `fvm flutter test test/areas_report_*` จน pass
6. Update `human.md` หัวข้อ Backend verification เมื่อ test stable
