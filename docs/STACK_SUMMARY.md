# Stack Summary — chaoperty-admin-cmcity

> สรุป tech stack **ที่ใช้งานจริง** ในโปรเจกต์ (ไม่รวม dep ที่ commented / legacy / unused)

---

## 1. Platform

| Item | Value |
|---|---|
| Framework | Flutter 3.38.3 (ผ่าน **fvm**) |
| Language | Dart `>=3.0.5 <4.0.0` |
| Build targets ที่ใช้ | **web (หลัก)**, android, ios, windows, linux, macos |
| Build flags | `--dart-define=BROWSER_IMAGE_DECODING_ENABLED=false --no-tree-shake-icons --base-href /<path>/` |

---

## 2. State management & routing

| Concern | Library | Pattern |
|---|---|---|
| State | `provider` 6.x | `ChangeNotifier` + `MultiProvider` (top-level ใน `main.dart`) |
| Routing | `go_router` 12.0.0 | `ShellRoute` + `CustomTransitionPage` (FadeTransition 250ms) |
| URL strategy | `flutter_web_plugins/url_strategy` | `PathUrlStrategy()` — `/area` แทน `/#/area` |
| Boot polling | `Timer.periodic` 5 นาที | `AuthStateNotifier.startPolling()` → แจ้ง router refresh ตอน login/logout |

**ไฟล์หลัก**:
- [lib/main.dart](../lib/main.dart) — bootstrap, providers, router init
- [lib/router/app_router.dart](../lib/router/app_router.dart) — 15 GoRoute entries + AppRoute constants
- [lib/router/auth_state_notifier.dart](../lib/router/auth_state_notifier.dart) — auth change → notify router

---

## 3. Layered architecture (MVVM)

แต่ละ menu ใช้ pattern เดียวกัน — ดูตัวอย่างที่ `lib/ChiangMai_Municipality/Setting_menu/setting_page/area/`:

```
menu_folder/
├── models/         # data classes (immutable, fromJson)
├── services/       # API calls (Bearer auth + http 1.2.1)
├── viewmodels/     # ChangeNotifier + Stream<Event> + business logic
└── views/          # Widgets — ฟัง events ผ่าน Stream.listen()
```

**Convention**:
- `Config` class — params สำหรับ VM (`title`, `routeData`, `readOnly`)
- `sealed class XxxEvent` — `XxxErrorEvent`, `XxxSuccessEvent` (exhaustive switch)
- `XxxViewModel extends ChangeNotifier` — exposes `events => _controller.stream` (broadcast)
- `.create({routeData, title})` factory ใน views สำหรับ go_router

---

## 4. HTTP layer

| Concern | Library / Path |
|---|---|
| HTTP client | `http` ^1.2.1 (force-override ใน pubspec) |
| Headers | `lib/Constant/Myconstant.dart` → `MyHeaders.build()` (Bearer token) |
| Token storage | `lib/Chiangmai_Municipality/unity/auth_token_store.dart` |

**API base URLs** (4 versions — ปนกันใน codebase):

```dart
String domain    = 'https://chaoperties.com/cmcity/chao_api';   // PHP legacy
String domain_v1 = 'https://cmcity-test-api.chaoperties.com/api/v1';
String domain_v2 = 'https://cmcity-test-api.chaoperties.com/api/v2';  // target ปัจจุบัน
String domain_v3 = 'https://cmcity-test-api.chaoperties.com';
```

**Service pattern** (ดู [lib/.../area/services/area_service.dart](../lib/ChiangMai_Municipality/Setting_menu/setting_page/area/services/area_service.dart)):
- รับ `MyConstant().domain_v2` เป็น base
- ทุก call → `MyHeaders.build()` → `http.{get,post,put,delete}`
- Return `bool` (mutation) หรือ typed model (read) — ไม่ throw, ใช้ `try/catch` + `debugPrint` แล้วคืน empty

---

## 5. Auth & secure storage

| Concern | Implementation |
|---|---|
| Token save/read | `AuthTokenStore.save/read/clear` — web ใช้ `sessionStorage`, native ใช้ `SecurePrefs` |
| Encryption | `protect` package (local fork ที่ `lib/_vendor/protect`) |
| User object | `AuthUserStore` (encrypted JSON) |
| Roles tree | `AuthRolesTreeStore` (เก็ด menu permissions) |
| Logout cleanup | `clearAllAuthStores()` + ลบ refresh/tokenType/tel/tax/id |
| Refresh trigger | `AuthStateNotifier` polling 5 นาที + `markLoggedIn()/markLoggedOut()` |

**Pentest hardening note** (จาก comment ใน `auth_token_store.dart`):
- Web → `sessionStorage` (token ตายเมื่อปิด tab — กัน XSS long-lived token)
- Native → encrypted SharedPreferences
- Fallback: `sessionStorage` throw (Safari private) → SecurePrefs

---

## 6. Navigation

- Source of truth: [assets/menu/navigation_menu.json](../assets/menu/navigation_menu.json) — 15 menu entries
- โหลดโดย `lib/ChiangMai_Municipality/navigation/` → drive sidebar
- แต่ละ menu → GoRoute ใน `app_router.dart` → pageBuilder `.create(routeData, title)`

**15 routes** (พร้อม permission gate):

| Route | Permission |
|---|---|
| `/area`, `/contract/:data` | `area_manager`, `LICENSE_REQUEST` |
| `/tenant`, `/tenant/:data` | `CURRENT_TENANTS` |
| `/announce` | `LICENSE_REQUEST_ANNOUNCEMENT` |
| `/payment`, `/payment/:data` | `FEE_PAYMENT` |
| `/attach`, `/attach/:data` | `REQUEST_DOCUMENT_ATTACHMENT` |
| `/verify`, `/verify/:data` | `REQUEST_DOCUMENT_REVIEW` |
| `/fact-check`, `/fact-check/:data` | `FACT_VERIFICATION` |
| `/submit-approval`, `/submit-approval/:data` | `SUBMIT_APPROVAL_REQUEST` |
| `/approve`, `/approve/:data` | `APPROVE_REQUEST` |
| `/registration` | `TENANT_REGISTRY` |
| `/report/customers`, `/report/areas` | `REGISTRY_REPORT`, `RENTAL_AREA_REPORT` |
| `/setting` | `setting` |
| `/profile/manage` | `profile` |
| `/login`, `/setup` | (pre-shell) |

---

## 7. i18n

- `flutter_localizations` — delegates: Material + Widgets + MonthYearPicker
- Locales: `en_US`, `th_TH` (default), `lo_LA`

---

## 8. UI libs ที่ใช้จริง

| ใช้ทำอะไร | Package |
|---|---|
| Sidebar / layout shell | `flutter_admin_scaffold` + custom `AdminScaffold/` |
| Tables (legacy + area-locks) | `data_tables`, `expandable_datatable`, `responsive_table`, `listview_ex` |
| Dropdown | `dropdown_button2` (local fork — `subtitle1` → `titleMedium`) + `dropdown_plus` + `animated_custom_dropdown` + `chips_choice` |
| Forms / stepper | `im_stepper`, `cupertino_stepper`, `step_progress` |
| Text | `auto_size_text`, `marquee`, `slide_switcher` |
| Cards / dialogs | `panara_dialogs`, `popup_menu_plus`, `my_popup_menu`, `bottom_sheet`, `side_sheet` |
| Date picker | `month_year_picker`, `table_calendar`, `time_range_picker`, `custom_rating_bar` |
| Chat (admin chat) | `flutter_chat_bubble`, `chat_bubbles` |
| Kanban / drag | `drag_and_drop_lists`, `infinite_canvas` |
| Carousel | `carousel_slider` |
| Indicator / progress | `percent_indicator`, `scrollview_observer` |
| Charts | `syncfusion_flutter_charts` |
| Calendar widget | `syncfusion_flutter_calendar` |
| Color picker | `flutter_colorpicker` |
| Search bar | `scroll_pos`, custom `search_bar.dart` |
| Responsive grid | `responsive_grid_list` |

---

## 9. PDF / Doc / Print

| Lib | ใช้ทำอะไร |
|---|---|
| `pdf` ^3.8.4 | generate PDF (ใบเสร็จ, สัญญา, ใบอนุญาต) |
| `pdfx` ^2.4.0 / `pdf_render` | viewer (PDF preview) |
| `syncfusion_flutter_pdf` | complex PDF templates |
| `syncfusion_flutter_pdfviewer` | in-app viewer |
| `printing` ^5.11.0 | web print dialog |
| `excel` / `excel_dart` / `syncfusion_flutter_xlsio` | export xlsx |
| `csv` ^5.1.1 | CSV import/export |
| `file_saver` | save to disk |

Output folders: `lib/PDF/`, `lib/PDF_TP2/`–`lib/PDF_TP10/` (template variants), `lib/PDF_Market/`

---

## 10. Camera / Files / OCR

| Lib | ใช้ทำอะไร |
|---|---|
| `image_picker` + `image_picker_web` | upload รูปภาพ + signature |
| `file_picker` ^5.2.2 | upload เอกสาร |
| `image` ^4.0.17 / `fast_image_resizer` | resize/compress |
| `cached_network_image` | image caching (web ❌ — `image_downloader_web` ใช้แทน) |
| `simple_barcode_scanner` | scan barcode/QR |
| `flutter_tesseract_ocr` | OCR สำหรับอ่านบัตรประชาชน / เอกสาร |
| `widgets_to_image` / `screenshot` | capture widget เป็นรูป |
| `image_downloader_web` / `web_image_downloader` | download รูปบน web |

---

## 11. Signature / Webview / QR

| Lib | ใช้ทำอะไร |
|---|---|
| `syncfusion_flutter_signaturepad` | pad ลายเซ็น (Syncfusion) |
| `hand_signature` ^3.0.1 | pad ลายเซ็น (alternative — finger-draw) |
| `webview_flutter` + `flutter_inappwebview` + `webviewx` | in-app webview (Beam payment + OAuth flows) |
| `qr_flutter` + `pretty_qr_code` | generate QR |
| `syncfusion_flutter_barcodes` | generate barcode |
| `pointer_interceptor` | webview focus on web |

**Special integration**: `lib/Beam/` — GBPrimePay QR payment + slip upload + `Beam_apiPassw.dart` (password-protected webview).

---

## 12. Networking utilities

| Lib | ใช้ทำอะไร |
|---|---|
| `http` ^1.2.1 | REST (force-overridden — translator pin เดิม ^0.13) |
| `pretty_qr_code` | QR generation |
| `dart_ipify` / `get_ip_address` | public IP detection |
| `universal_html` ^2.0.8 | DOM access ใน Flutter web (sessionStorage) |
| `mime` ^1.0.4 | MIME type detection |
| `crypto` ^3.0.2 | hashing (AES helpers) |
| `intl` ^0.20.2 | date/number/currency formatting |

---

## 13. Local forks (vendored)

ใช้ `dependency_overrides` ใน [pubspec.yaml](../pubspec.yaml) — **ต้องไม่ลบ**:

| Package | Path | เหตุผล |
|---|---|---|
| `protect` | `lib/_vendor/protect` | spinCount 100000 → 10000 (~30s → ~3s encrypt บน web) |
| `dropdown_button2` | `vendor/dropdown_button2` | 1.9.4: `subtitle1` → `titleMedium` (subtitle1 ถูกลบใน Flutter ใหม่) |
| `http` | ^1.2.1 (force) | translator 0.1.7 pin ^0.13 แต่ base API เหมือนกัน |
| `uuid` | ^4.1.0 (force) | webviewx pin ^3 แต่ใช้แค่ `Uuid().v4()` |

**Why outside `lib/` for dropdown_button2**: path dep ใน `lib/_vendor` ทำให้ Dart claim packageUri ซ้ำซ้อน (`lib/`) → language-version mismatch.

---

## 14. Assets

| Type | Path |
|---|---|
| Menu config | `assets/menu/` |
| Fonts (Thai) | `fonts/Sarabun-*`, `THSarabunNew`, `Angsana_new`, `LINESeedSansTH_*` |
| Images | `images/` + subdirs `TP1`–`TP7`, `LogoBank/`, `card/`, `html/` |
| Encrypted env | `lib/ChiangMai_Municipality/unity/EncryptTex.env` |

---

## 15. Tests

7 test files ใน `test/` — รันด้วย `fvm flutter test`:

| File | Coverage |
|---|---|
| `area_models_test.dart` | AreaGroup / AreaZone / AreaArea fromJson + edge cases |
| `area_view_model_test.dart` | `FakeAreaService extends AreaService` — 19 tests, pagination/CRUD/events |
| `registration_menu_test.dart` | VM + widgets (14 tests, 4 groups) |
| `customers_report_test.dart` | PasswordValidator, AES, CustomerReport model (20+ tests) |
| `menu_models_test.dart` | cross-cutting ReceiptModel + AreaItem |
| `menu_permission_filter_test.dart` | navigation_menu.json permission filtering |
| `routes_test.dart` | router + asset sync |

**Test pattern**:
1. `FakeXxxService extends XxxService` — thin stub
2. `await Future<void>.delayed(Duration.zero)` × 2 รอ async bootstrap
3. `vm.events.listen(...)` + `await Future<void>.delayed(...)` ก่อน assert event
4. `pumpWidget` + `ChangeNotifierProvider<XxxViewModel>.value(value: vm)`

---

## 16. Build & dev workflow

```bash
# Run dev (web)
fvm flutter run -d chrome --web-browser-flag "--disable-web-security"

# Build web (template)
fvm flutter build web --dart-define=BROWSER_IMAGE_DECODING_ENABLED=false \
  --web-browser-flag=--disable-web-security --no-tree-shake-icons \
  --base-href /cmcity_test/

# Test
fvm flutter test test/area_models_test.dart test/area_view_model_test.dart

# Analyze
fvm flutter analyze
```

**Lint**: `analysis_options.yaml` → `package:flutter_lints/flutter.yaml` (default).

---

## 17. Backend integration

| Backend | Path |
|---|---|
| **v2 API (target)** | `https://cmcity-test-api.chaoperties.com/api/v2` |
| v1 API | `https://cmcity-test-api.chaoperties.com/api/v1` |
| v3 API | `https://cmcity-test-api.chaoperties.com` |
| PHP legacy | `https://chaoperties.com/cmcity/chao_api/*.php` (24 endpoints ยังค้าง — ดู [pen-test/README.md](pen-test/README.md)) |
| GBPrimePay | webview in-app (Beam module) |

**Migration status**: 4 pure v2 · 7 v2-effective · 5 mixed · 2 pure PHP (`/tenant`, `/license/payment`).

---

## 18. Permission gating

`navigation_menu.json` มี `permission` field ต่อ menu — filter ผ่าน `test/menu_permission_filter_test.dart` pattern → drive sidebar visibility + GoRouter redirect.

Permission strings:
- `area_manager`, `CURRENT_TENANTS`, `LICENSE_ISSUANCE_PROCESS` (group)
- `LICENSE_REQUEST_ANNOUNCEMENT`, `LICENSE_REQUEST`, `REQUEST_DOCUMENT_ATTACHMENT`
- `FEE_PAYMENT`, `REQUEST_DOCUMENT_REVIEW`, `FACT_VERIFICATION`
- `SUBMIT_APPROVAL_REQUEST`, `APPROVE_REQUEST`
- `TENANT_REGISTRY`, `REGISTRY_REPORT`, `RENTAL_AREA_REPORT`
- `reports` (group), `setting`, `profile`

---

## 19. Special platforms

- **Rotate screen guard** (`_RotateDeviceScreen` ใน `main.dart`): ถ้า height < 500px → แสดงจอ "กรุณาหมุนเป็นแนวตั้ง" (UI ออกแบบ portrait-only)
- **Tree-shake icons** --no-tree-shake-icons (icon set ใหญ่ — กัน prod crash)
- **Image decoding** `--dart-define=BROWSER_IMAGE_DECODING_ENABLED=false` (กัน Security Capture Screen bug)

---

## 20. Out of scope / explicitly excluded

ไม่ได้กล่าวถึงในเอกสารนี้:
- Commented deps ใน pubspec (cupertino_icons, ftpconnect, esc_pos_utils_plus, kanban_board, font_awesome_flutter, iconsax, usb_device, etc.)
- `lib_old/` — legacy code (เก็บไว้อ้างอิง)
- `find*.dart`, `tmp_fix.py`, `*_analyze.log` — debug scripts/logs
- Local vendor source files (ดูเฉพาะ dependency_overrides ใน pubspec)
- `mysql1` ^0.20.0 — ติดตั้งไว้ แต่ app ไม่ใช้ (client-only — ไม่ควรต่อ DB ตรง)

---

**จบเอกสาร** — ถ้าเพิ่ม lib ใหม่ → อัปเดต section ที่เกี่ยวข้อง + flag ใน PR description