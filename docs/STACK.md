# Stack — chaoperty-admin-cmcity

> Quick reference. รายละเอียดเชิงลึกดู [STACK_SUMMARY.md](STACK_SUMMARY.md)

---

## Core

| | |
|---|---|
| Framework | Flutter 3.38.3 (fvm) |
| Dart | `>=3.0.5 <4.0.0` |
| State | `provider` 6.x · `ChangeNotifier` |
| Routing | `go_router` 12.0.0 · `ShellRoute` · `PathUrlStrategy()` |
| HTTP | `http` 1.2.1 (force-override) |
| Persistence | `shared_preferences` (+ `protect` encrypt) |
| Auth | `AuthStateNotifier` polling 5 นาที + `MyHeaders.build()` Bearer |
| i18n | `flutter_localizations` · en/th/lo |

---

## Layered architecture

```
menu_folder/
├── models/        → data classes (immutable, fromJson)
├── services/      → REST calls (Bearer + http)
├── viewmodels/    → ChangeNotifier + Stream<Event>
└── views/         → Widgets + .create({routeData, title})
```

Convention: `sealed class XxxEvent` (exhaustive switch), `.create()` factory ใน views, services ไม่ throw — `try/catch` + `debugPrint` + return empty.

---

## API endpoints

```dart
String domain    = 'https://chaoperties.com/cmcity/chao_api';      // PHP legacy
String domain_v1 = 'https://cmcity-test-api.chaoperties.com/api/v1';
String domain_v2 = 'https://cmcity-test-api.chaoperties.com/api/v2'; // target
String domain_v3 = 'https://cmcity-test-api.chaoperties.com';
```

Migration status: 4 pure v2 · 7 v2-effective · 5 mixed · 2 pure PHP (`/tenant`, `/license/payment`) · **24 PHP endpoints ค้าง**

---

## Routes (15)

| Route | Permission |
|---|---|
| `/area` | `area_manager` |
| `/tenant` | `CURRENT_TENANTS` |
| `/contract/:data` | `LICENSE_REQUEST` |
| `/announce` | `LICENSE_REQUEST_ANNOUNCEMENT` |
| `/attach/:data` | `REQUEST_DOCUMENT_ATTACHMENT` |
| `/payment/:data` | `FEE_PAYMENT` |
| `/verify/:data` | `REQUEST_DOCUMENT_REVIEW` |
| `/fact-check/:data` | `FACT_VERIFICATION` |
| `/submit-approval/:data` | `SUBMIT_APPROVAL_REQUEST` |
| `/approve/:data` | `APPROVE_REQUEST` |
| `/registration` | `TENANT_REGISTRY` |
| `/report/customers` | `REGISTRY_REPORT` |
| `/report/areas` | `RENTAL_AREA_REPORT` |
| `/setting` | `setting` |
| `/profile/manage` | `profile` |

Pre-shell: `/login`, `/setup`

---

## Auth storage

| Platform | Storage | Why |
|---|---|---|
| Web | `sessionStorage` | token ตายตอนปิด tab (กัน XSS long-lived) |
| Native | `SecurePrefs` (encrypted) | fallback เมื่อ sessionStorage throw (Safari private) |

`AuthTokenStore` / `AuthUserStore` / `AuthRolesTreeStore` / `AuthUuidStore` / `AuthEmailStore` → `clearAllAuthStores()` ตอน logout.

---

## Local forks (vendored)

| Package | Path | เหตุผล |
|---|---|---|
| `protect` | `lib/_vendor/protect` | spinCount 100k → 10k (~30s → ~3s encrypt) |
| `dropdown_button2` | `vendor/dropdown_button2` | `subtitle1` → `titleMedium` (Flutter ใหม่ลบ subtitle1) |
| `http` ^1.2.1 | force-override | translator 0.1.7 pin ^0.13 (base API เหมือนกัน) |
| `uuid` ^4.1.0 | force-override | webviewx pin ^3 (ใช้แค่ `Uuid().v4()`) |

---

## Libs (จัดกลุ่มตามที่ใช้จริง)

**UI shell**: `flutter_admin_scaffold` · `side_sheet` · `bottom_sheet`

**Tables/lists**: `data_tables` · `expandable_datatable` · `responsive_table` · `listview_ex`

**Dropdowns**: `dropdown_button2` (forked) · `dropdown_plus` · `animated_custom_dropdown` · `chips_choice`

**Forms**: `im_stepper` · `cupertino_stepper` · `step_progress` · `fl_pin_code`

**Date/calendar**: `month_year_picker` · `table_calendar` · `time_range_picker`

**Dialog/menu**: `panara_dialogs` · `popup_menu_plus` · `my_popup_menu`

**Chat**: `flutter_chat_bubble` · `chat_bubbles`

**Charts**: `syncfusion_flutter_charts` · `syncfusion_flutter_calendar`

**Misc UI**: `carousel_slider` · `drag_and_drop_lists` · `infinite_canvas` · `percent_indicator` · `scrollview_observer` · `marquee` · `slide_switcher` · `auto_size_text` · `flutter_colorpicker` · `custom_rating_bar`

---

## PDF / Doc / Print

`pdf` · `pdfx` · `pdf_render` · `syncfusion_flutter_pdf` · `syncfusion_flutter_pdfviewer` · `printing` · `excel` · `excel_dart` · `syncfusion_flutter_xlsio` · `csv` · `file_saver`

Templates: `lib/PDF/`, `lib/PDF_TP2/`–`lib/PDF_TP10/`, `lib/PDF_Market/`, `lib/PDF_Ortorkor/`

---

## Camera / Files / OCR

`image_picker` · `image_picker_web` · `file_picker` · `image` · `fast_image_resizer` · `cached_network_image` · `simple_barcode_scanner` · `flutter_tesseract_ocr` · `widgets_to_image` · `screenshot` · `image_downloader_web` · `web_image_downloader`

---

## Signature / Webview / QR

**Signature**: `syncfusion_flutter_signaturepad` · `hand_signature`

**Webview**: `webview_flutter` · `flutter_inappwebview` · `webviewx` · `pointer_interceptor`

**QR/Barcode**: `qr_flutter` · `pretty_qr_code` · `syncfusion_flutter_barcodes`

**Payment integration**: `lib/Beam/` (GBPrimePay QR + slip upload) + `flutter_gbprimepay_qrcode`

---

## Networking utils

`http` · `crypto` · `mime` · `intl` · `universal_html` (web DOM) · `dart_ipify` · `get_ip_address`

---

## Tests (7 ไฟล์)

`area_models_test` · `area_view_model_test` · `registration_menu_test` · `customers_report_test` · `menu_models_test` · `menu_permission_filter_test` · `routes_test`

Pattern: `FakeXxxService extends XxxService` → `await Future<void>.delayed(Duration.zero)` × 2 → `vm.events.listen(...)` + `await Future<void>.delayed(...)` ก่อน assert → `pumpWidget` + `ChangeNotifierProvider<XxxViewModel>.value`.

---

## Build & dev

```bash
# dev
fvm flutter run -d chrome --web-browser-flag "--disable-web-security"

# build web
fvm flutter build web \
  --dart-define=BROWSER_IMAGE_DECODING_ENABLED=false \
  --web-browser-flag=--disable-web-security \
  --no-tree-shake-icons \
  --base-href /cmcity_test/

# test
fvm flutter test test/area_models_test.dart test/area_view_model_test.dart

# analyze
fvm flutter analyze
```

Lint: `package:flutter_lints/flutter.yaml` (default)

---

## Special handling

- **Portrait-only** — `_RotateDeviceScreen` แสดงเมื่อ `MediaQuery.height < 500`
- **Tree-shake icons OFF** — `--no-tree-shake-icons` (icon set ใหญ่)
- **Image decoding OFF** — `BROWSER_IMAGE_DECODING_ENABLED=false` (กัน Security Capture Screen bug)

---

## Out of scope (ไม่ใช้)

commented deps · `lib_old/` · debug scripts (`find*.dart`, `*analyze.log`) · `mysql1` (client-only, ไม่ควรต่อ DB ตรง)