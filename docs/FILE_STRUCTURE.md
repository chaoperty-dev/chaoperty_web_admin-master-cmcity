# File Structure Summary — chaoperty-admin-cmcity

> สรุป folder/file ที่**ใช้งานจริง** (ตัด commented/dead/legacy ออก)
>
> วันที่: 2026-09-03

---

## 1. ภาพรวม (Grand Total)

| หมวด                        | Folders | Files      | Lines        |
| --------------------------- | ------- | ---------- | ------------ |
| **lib/** (application code) | ~180    | **1,380**  | **883,329**  |
| **test/**                   | 1       | **8**      | **1,680**    |
| **docs/**                   | 4       | **37**     | **7,770**    |
| **assets/**                 | 2       | 1          | 6 (JSON)     |
| **fonts/**                  | 1       | **49**     | —            |
| **images/**                 | ~70     | **657**    | —            |
| **downloadFile/**           | 1       | 1          | —            |
| **pubspec.yaml**            | —       | 1          | 487          |
| **รวม active**              | ~260    | **~2,131** | **~893,000** |

**Out of scope** (ไม่นับ):

- `lib_old/` — legacy code เก็บอ้างอิง
- `lib/_vendor/` + `vendor/` — local fork packages (19 + N files)
- `build/`, `.dart_tool/`, `.git/`, `web/build/`, `macos/`, `windows/`, `linux/`, `ios/`, `android/` — generated/build artifacts
- `find*.dart`, `tmp_fix.py`, `*_analyze.log`, `flutter_*.log` — debug scripts/logs
- `*.iml` (IDE files)
- 119 fully-commented `.dart` files (~280,000 lines ของ commented code ที่ไม่ใช้)

---

## 2. `lib/` — Application code (1,380 files, 883K lines)

### 2.1 Top-level distribution

| Folder                    | Files   | Lines   | สถานะ                                |
| ------------------------- | ------- | ------- | ------------------------------------ |
| `ChiangMai_Municipality/` | **565** | 17,677  | ✅ **Active (target architecture)**  |
| `Model/`                  | 137     | ~95K    | ⚠️ Legacy models (mixed active/dead) |
| `Model_copy/`             | 132     | ~85K    | ⚠️ Legacy duplicate                  |
| `Report/`                 | 50      | ~30K    | ⚠️ Legacy report templates           |
| `PDF/`                    | 48      | ~25K    | ✅ PDF templates                     |
| `PDF_coppy/`              | 42      | ~22K    | ⚠️ PDF duplicate                     |
| `Canvas/`                 | 31      | 45,448  | ⚠️ Canvas widgets (legacy)           |
| `Report_choice/`          | 29      | ~10K    | ⚠️ Report variant                    |
| `PeopleChao/`             | 29      | ~18K    | ⚠️ Legacy people module              |
| `PeopleChao_coppy/`       | 26      | ~15K    | ⚠️ Duplicate                         |
| `Account/`                | 23      | 162,167 | ⚠️ Mostly commented (1 active file)  |
| `Setting/`                | 22      | ~8K     | ⚠️ Legacy settings                   |
| `Man_PDF/`                | 16      | ~12K    | ✅ Manual PDF                        |
| `Man_PDF_copy/`           | 16      | ~10K    | ⚠️ Manual PDF duplicate              |
| `Report_cm/`              | 15      | ~10K    | ⚠️ Chiangmai report                  |
| `Style/`                  | 10      | ~3K     | ✅ Theme/colors (reusable)           |
| `Report_Dashboard/`       | 10      | ~6K     | ⚠️ Dashboard widgets                 |
| `ChaoArea/`               | 9       | 99,084  | ⚠️ Area module (legacy)              |
| `PDF_TP3/`, `PDF_TP9/`    | 9+8     | —       | ✅ PDF templates by version          |
| `Bureau_Registration/`    | 8       | 21,967  | ⚠️ Registration screens              |
| `navigation/`             | **7**   | 2,235   | ✅ **Active (sidebar/shell)**        |
| `Register/`               | 7       | ~5K     | ⚠️ Register screens                  |
| `PDF_TP4–10/`             | 7 each  | —       | ✅ PDF template variants             |
| `Home/`                   | 7       | ~4K     | ⚠️ Home dashboard                    |
| `Report_Ortorkor/`        | 6       | ~3K     | ⚠️ Ortorkor report                   |
| `Manage/`                 | 4       | ~2K     | ⚠️ Manage screens                    |
| `Beam/`                   | 4       | 543     | ⚠️ Beam payment (mostly commented)   |
| `Constant/`               | **3**   | 190     | ✅ **Active (MyConstant/MyHeaders)** |
| `APIS-V2/`                | 3       | 992     | ✅ Active (payment intents)          |
| `router/`                 | **2**   | 514     | ✅ **Active (GoRouter)**             |
| `Setting_NainaService/`   | 3       | ~1K     | ⚠️ Naina service widget              |
| `INSERT_Log/`             | 1       | ~200    | ⚠️ Logging helper                    |
| `CRC_16_Prompay/`         | 1       | 51      | ✅ CRC16 helper                      |

> ⚠️ = mostly legacy/commented — review before reuse
> ✅ = actively used

### 2.2 `lib/ChiangMai_Municipality/` — Active target architecture (565 files)

```
ChiangMai_Municipality/
├── License_menu/                          282 files, 21,420 lines  (active)
│   ├── license_announce_page/             (18 files)
│   ├── license_attach_page/               (45 files)
│   ├── license_contract_page/             (42 files)
│   ├── license_verify_page/               (37 files)
│   ├── license_approve_page/              (33 files)
│   ├── license_payment_page/              (28 files)
│   ├── license_submit_approval_request_page/ (25 files)
│   └── license_fact_check_page/           (25 files)
├── Setting_menu/                          71 files, 17,091 lines   (active)
├── Registration_menu/                     43 files, 11,788 lines   (active)
│   └── registration_page/{models,services,viewmodels,views,widgets}
├── Area_menu/                             22 files,  6,043 lines   (active)
├── Report_menu/                           25 files,  5,544 lines   (active)
├── Tenant_menu/                           18 files,  4,951 lines   (active)
├── Personal_information_menu/             18 files,  3,324 lines   (active)
├── unity/                                 49 files,  8,619 lines   (active — shared helpers)
│   ├── auth_token_store.dart              ← 🔐 sessionStorage/SecurePrefs
│   ├── SecurePrefs_helper.dart            ← 🔐 encrypted prefs
│   ├── EncryptText.dart                   ← 🔐 AES helper
│   ├── area_zones_api.dart                ← v2 API shared
│   ├── API_*.dart                         ← API helpers
│   ├── FormatDate/IDCard/Phone.dart       ← formatters
│   ├── EncryptTex.env                     ← ⚠️ env file
│   └── ...                                (40 more files)
├── PDF_CMM/                               18 files, 13,058 lines   (active PDF gen)
├── Make_contract_CMM/                      8 files, 17,400 lines   (legacy)
├── List_CMM/                               8 files,  2,506 lines   (login + setup)
│   └── Register_CMM/
│       ├── AuthService.dart               ← 🔐 login/auto-login
│       ├── Login_page_cmm.dart            ← 🔐 login UI
│       └── SetupPage.dart                 ← post-login redirect
└── Model/                                 20 files                (active — models)
```

> **License_menu** = ใหญ่สุด — 8 sub-menus × ~30-45 files each (models + services + viewmodels + views + widgets + theme)

### 2.3 Active sub-routes file count (License_menu detail)

| Sub-menu                                | Files | Notes              |
| --------------------------------------- | ----- | ------------------ |
| `license_attach_page/`                  | 45    | แนบเอกสารคำขอ      |
| `license_request_page/`                 | 42    | คำขอใบอนุญาต       |
| `license_verify_page/`                  | 37    | ตรวจสอบเอกสาร      |
| `license_approve_page/`                 | 33    | อนุมัติคำร้อง      |
| `license_contract_page/`                | 29    | (alt path)         |
| `license_payment_page/`                 | 28    | ชำระค่าธรรมเนียม   |
| `license_submit_approval_request_page/` | 25    | ส่งคำร้องขออนุมัติ |
| `license_fact_check_page/`              | 25    | ตรวจสอบข้อเท็จจริง |
| `license_announce_page/`                | 18    | ประกาศคำขอ         |

### 2.4 `lib/navigation/` — Sidebar/shell (7 files, 2,235 lines) ✅

```
navigation/
├── app_shell.dart                    ← responsive shell (Rail/Drawer)
├── app_navigation_rail.dart           ← desktop sidebar
├── menu_version.dart                 ← version footer
├── models/
│   └── navigation_menu_model.dart
├── services/
│   ├── navigation_menu_service.dart
│   └── favorite_menu_service.dart
└── widgets/
    └── favorites_section.dart
```

### 2.5 `lib/router/` — Routing (2 files, 514 lines) ✅

```
router/
├── app_router.dart       ← 15 GoRoute + FadeTransition + ShellRoute
└── auth_state_notifier.dart  ← polling 5 min
```

### 2.6 `lib/Constant/` — API config (3 files, 190 lines) ✅

```
Constant/
├── Myconstant.dart      ← 4 base URLs (domain/v1/v2/v3)
├── api_cache.dart
└── global_http.dart     ← ⚠️ placeholder HMAC secret (unused)
```

### 2.7 `lib/APIS-V2/` — V2 payment intents (3 files, 992 lines) ✅

```
APIS-V2/
├── payment-intents.dart          ← Stripe-like intents
├── payment-intents-upslip.dart
├── payment-qr-session.dart
└── Model-v2/
    └── payment-IntentsModel.dart
```

### 2.8 Active .env / config files

| File                                              | Purpose                                                                               |
| ------------------------------------------------- | ------------------------------------------------------------------------------------- |
| `lib/ChiangMai_Municipality/unity/EncryptTex.env` | ⚠️ SECRET_KEY for AES (hardcoded key — see [SECURITY_AUDIT.md](SECURITY_AUDIT.md) R1) |
| `assets/menu/navigation_menu.json`                | 15 menu routes (source of truth)                                                      |
| `pubspec.yaml`                                    | 487 lines — Flutter deps + local fork overrides                                       |

---

## 3. `test/` — Unit tests (8 files, 1,680 lines)

| File                               | Lines | Coverage                                  |
| ---------------------------------- | ----- | ----------------------------------------- |
| `area_models_test.dart`            | ~150  | AreaGroup/Zone/Area fromJson + edge cases |
| `area_view_model_test.dart`        | ~250  | FakeAreaService + pagination/CRUD/events  |
| `registration_menu_test.dart`      | ~286  | VM + widgets (14 tests)                   |
| `customers_report_test.dart`       | ~300  | PasswordValidator + AES + model           |
| `menu_models_test.dart`            | ~200  | ReceiptModel + AreaItem                   |
| `menu_permission_filter_test.dart` | ~180  | navigation_menu.json permission filter    |
| `routes_test.dart`                 | ~150  | GoRouter + asset sync                     |
| `widget_test.dart`                 | ~80   | Generic smoke                             |

**Coverage**: 4/15 menus tested (area-config, registration, customers-report, profile-manage implicit)
**Pattern**: `FakeXxxService extends XxxService` + `await Future<void>.delayed(Duration.zero)` × 2

---

## 4. `docs/` — Documentation (37 .md files, 7,770 lines)

```
docs/
├── README.md                                    ← (outdated Flutter default)
├── STACK.md                                     ← Quick stack reference
├── STACK_SUMMARY.md                             ← Detailed stack breakdown
├── SECURITY_AUDIT.md                            ← Security scan
├── UX_UI_AUDIT.md                               ← UX/UI critique
├── FILE_STRUCTURE.md                            ← (this file)
└── pen-test/                                    ← 33 .md files
    ├── README.md                                ← master index (15 menus)
    ├── area/{ai,human}.md
    ├── tenant/{ai,human}.md
    ├── registration/{ai,human}.md
    ├── profile-manage/{ai,human}.md
    ├── setting/{ai,human}.md
    ├── setting/area-config/{ai,human}.md
    ├── license/
    │   ├── announce/{ai,human}.md
    │   ├── contract/{ai,human}.md
    │   ├── attach/{ai,human}.md
    │   ├── payment/{ai,human}.md
    │   ├── verify/{ai,human}.md
    │   ├── fact-check/{ai,human}.md
    │   ├── submit-approval/{ai,human}.md
    │   └── approve/{ai,human}.md
    └── report/
        ├── customers/{ai,human}.md
        └── areas/{ai,human}.md
```

**Total**: 33 (pen-test) + 5 (root) + 1 (legacy README) = **37 files**

---

## 5. `assets/` (1 file)

| File                               | Purpose                                      |
| ---------------------------------- | -------------------------------------------- |
| `assets/menu/navigation_menu.json` | 15 menu routes — source of truth for sidebar |

---

## 6. `fonts/` (49 files)

Thai fonts (active):

- `Sarabun-{Regular,Medium,SemiBold,Bold,Light}.ttf` (5)
- `THSarabunNew.ttf`
- `Angsana_new.ttf`
- `LINESeedSansTH_{XBd,Rg}.ttf` (2)

(40 commented fonts in pubspec — Sarabun-Medium, Angsana variants, etc.)

---

## 7. `images/` (657 files in ~70 dirs)

Active dirs:

- `LogoBank/` — bank logos
- `card/` — card icons
- `html/` — html assets
- `TP1/`, `TP2/`, `TP3/`, `TP3/B1_PDF_Ama.pdf`, `TP4/`, `TP4/B1_PDF_Choice.pdf`, `TP4/B1_PDF_Ortor.pdf`, `TP4_1/`, `TP5/`, `TP6/`, `TP7/`

---

## 8. Vendored local forks (ไม่นับเป็น app code)

| Path                       | Package               | Files | Lines  |
| -------------------------- | --------------------- | ----- | ------ |
| `lib/_vendor/protect/`     | protect fork          | 19    | ~2,200 |
| `vendor/dropdown_button2/` | dropdown_button2 fork | 35+   | ~5,000 |

---

## 9. ไฟล์ที่ใช้บ่อย (high-traffic files)

ดูจากการ import ใน dependency graph — top referenced:

| File                                                                | Purpose                      |
| ------------------------------------------------------------------- | ---------------------------- |
| `lib/ChiangMai_Municipality/unity/auth_token_store.dart`            | sessionStorage + SecurePrefs |
| `lib/ChiangMai_Municipality/unity/SecurePrefs_helper.dart`          | encrypted SharedPreferences  |
| `lib/ChiangMai_Municipality/unity/EncryptText.dart`                 | AES encrypt/decrypt          |
| `lib/ChiangMai_Municipality/List_CMM/Register_CMM/AuthService.dart` | login + auto-login           |
| `lib/Constant/Myconstant.dart`                                      | API base URLs                |
| `lib/ChiangMai_Municipality/unity/area_zones_api.dart`              | shared v2 zone API           |
| `lib/navigation/app_shell.dart`                                     | responsive shell             |
| `lib/router/app_router.dart`                                        | 15 GoRoutes                  |

---

## 10. Out of scope (ไม่ใช้ / deprecated)

| Path                                                                                         | สถานะ                                                                                               |
| -------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| `lib_old/`                                                                                   | Legacy code — เก็บอ้างอิง ไม่ build                                                                 |
| `lib/Account/`                                                                               | 23/24 files fully commented (162K lines ของ dead code)                                              |
| `lib/AdminScaffold/AdminScaffold.dart`                                                       | Fully commented (replaced by go_router shell)                                                       |
| `lib/AdminScaffold/AdminScaffold_coppy.dart`                                                 | Fully commented                                                                                     |
| `lib/Beam/*.dart`                                                                            | Mostly commented (only 1 active file)                                                               |
| `lib/Canvas/`                                                                                | Legacy canvas widgets — 31 files, mostly commented                                                  |
| `lib/ChaoArea/`                                                                              | Legacy area module (replaced by Area_menu + ChiangMai_Municipality/Setting_menu/setting_page/area/) |
| `lib/PDF_coppy/`                                                                             | PDF duplicate (replaced by PDF/)                                                                    |
| `lib/Model_copy/`                                                                            | Model duplicate (replaced by ChiangMai_Municipality/Model)                                          |
| `lib/PeopleChao_coppy/`                                                                      | Duplicate                                                                                           |
| `lib/Man_PDF_copy/`                                                                          | Manual PDF duplicate                                                                                |
| `lib/Report_choice/`, `lib/Report_Ortorkor/`, `lib/Report_cm/`, `lib/Report_Dashboard/`      | Legacy report variants                                                                              |
| `lib/Manage/`                                                                                | Legacy manage screens                                                                               |
| `lib/Register/`                                                                              | Legacy register screens                                                                             |
| `lib/Setting/`                                                                               | Legacy settings UI (replaced by Setting_menu + ChiangMai_Municipality/Setting_menu)                 |
| `lib/Setting_NainaService/`                                                                  | Naina service widget — unused                                                                       |
| `lib/INSERT_Log/`                                                                            | Insert log helper — unused                                                                          |
| `lib/Bureau_Registration/`                                                                   | Legacy registration screens (replaced by Registration_menu)                                         |
| `lib/PeopleChao/`, `lib/PeopleChao_coppy/`                                                   | Legacy people module                                                                                |
| `lib/Home/`                                                                                  | Legacy home dashboard                                                                               |
| `lib/Make_contract_CMM/`                                                                     | Legacy make-contract                                                                                |
| `find*.dart`, `tmp_fix.py`                                                                   | Debug scripts                                                                                       |
| `*analyze.log`, `flutter_*.log`, `*.png`                                                     | Debug logs/screenshots                                                                              |
| `lib/_vendor/`, `vendor/`                                                                    | Local forks (3rd-party source — count separately)                                                   |
| `build/`, `.dart_tool/`, `.git/`, `web/`, `macos/`, `windows/`, `linux/`, `ios/`, `android/` | Build artifacts                                                                                     |

---

## 11. ตัวเลขสรุป (Final Scoreboard)

```
ACTIVE CODE
═══════════════════════════════════════════════
lib/              1,380 files    883,329 lines
test/                 8 files      1,680 lines
docs/                37 files      7,770 lines
assets/menu/          1 file          6 lines
fonts/               49 files             —
images/             657 files             —
───────────────────────────────────────────────
TOTAL ACTIVE     ~2,131 files  ~893,000 lines
═══════════════════════════════════════════════

DEAD/LEGACY (ไม่นับ)
═══════════════════════════════════════════════
lib_old/              ? files    ~? lines
lib/Account/          23 files    ~162K lines  (commented)
lib/Beam/             ~3 files   ~2K lines   (commented)
lib/AdminScaffold/    2 files    ~13K lines  (commented)
lib/_vendor/          19 files   ~2.2K lines  (fork)
vendor/              ~35 files   ~5K lines   (fork)
find*.dart etc.      ~10 files   debug
───────────────────────────────────────────────
TOTAL DEAD         ~90 files    ~190K lines
═══════════════════════════════════════════════
```

**สรุป**: โปรเจกต์มี **active code ~893K lines** ใน **~2,100 ไฟล์** + **legacy/dead ~190K lines** ใน **~90 ไฟล์** (ตัดออกได้ ลด bloat ~18%)

---

**จบเอกสาร** — อัปเดตเมื่อ:

- เพิ่ม menu ใหม่ → bump ChiangMai_Municipality count
- ลบ legacy folder → mark "deprecated → can delete"
- เพิ่ม test → update test/ table
- เพิ่ม doc → update docs/ tree
