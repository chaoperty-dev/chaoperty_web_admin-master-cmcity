# UX/UI Audit — chaoperty-admin-cmcity

> วิจารณ์ UX/UI จาก active code (ตัด commented/dead legacy ออก)
>
> ดู implementation จริงใน [lib/main.dart](../lib/main.dart), [lib/navigation/](../lib/navigation/), [lib/ChiangMai_Municipality/](../lib/ChiangMai_Municipality/)

---

## 1. ข้อดี (Strengths) ✅

### 🏗️ Layout & Navigation

| # | เรื่อง | ที่ไหน |
|---|---|---|
| U1 | **Responsive shell แบ่งชัด** — Desktop ≥1100px ใช้ NavigationRail 240px (ถาวร) · Mobile/Tablet ใช้ Drawer + hamburger | [lib/navigation/app_shell.dart:30-55](../lib/navigation/app_shell.dart) |
| U2 | **Breakpoint คิดดี** — 1100px (ไม่ใช่ default 600) เพราะ iPad portrait ใช้ drawer แทน rail | [app_shell.dart:21-22](../lib/navigation/app_shell.dart) |
| U3 | **Fade transition 250ms** ทุกหน้าใน shell — navigation ลื่น ไม่กระตุก | [lib/router/app_router.dart:81-93](../lib/router/app_router.dart) |
| U4 | **Path URL strategy** — `/area` shareable + bookmarkable (vs hash) | [main.dart:55](../lib/main.dart) |
| U5 | **Version footer** per menu (`MenuVersionFooter`) — dev/debug visibility | [app_shell.dart:60-70](../lib/navigation/app_shell.dart) |
| U6 | **Favorites section** ใน sidebar — เก็บเมนูที่ใช้บ่อย (`favorite_menu_service`) | [app_shell.dart:14](../lib/navigation/app_shell.dart) |
| U7 | **Menu config from JSON** (`navigation_menu.json`) — non-dev เปลี่ยน menu visibility ได้ | [assets/menu/navigation_menu.json](../assets/menu/navigation_menu.json) |

### 🔐 Auth flow

| # | เรื่อง | ที่ไหน |
|---|---|---|
| U8 | **Privacy gate ก่อน login** — modal PDF preview + ปุ่ม ปฏิเสธ/ยอมรับ ตาม PDPA | [Login_page_cmm.dart:80-117](../lib/ChiangMai_Municipality/List_CMM/Register_CMM/Login_page_cmm.dart) |
| U9 | **Inline validation** — email regex + required field ทันทีที่พิมพ์ | [Login_page_cmm.dart:179-189](../lib/ChiangMai_Municipality/List_CMM/Register_CMM/Login_page_cmm.dart) |
| U10 | **Loading state บนปุ่ม login** — `CircularProgressIndicator` ในปุ่ม (ไม่ block ทั้งหน้า) | [Login_page_cmm.dart:304-308](../lib/ChiangMai_Municipality/List_CMM/Register_CMM/Login_page_cmm.dart) |
| U11 | **Snackbar feedback** เมื่อ login fail — `'เข้าสู่ระบบไม่สำเร็จ'` | [Login_page_cmm.dart:133-135](../lib/ChiangMai_Municipality/List_CMM/Register_CMM/Login_page_cmm.dart) |

### 🌍 i18n & locale

| # | เรื่อง | ที่ไหน |
|---|---|---|
| U12 | **Multi-locale (th/en/lo)** + th_TH default | [main.dart:104-108](../lib/main.dart) |
| U13 | **Custom `Translate.TranslateAndSetText`** — consistent font + size per locale | [Login_page_cmm.dart:309-316](../lib/ChiangMai_Municipality/List_CMM/Register_CMM/Login_page_cmm.dart) |
| U14 | **Multiple Thai fonts** (Sarabun, THSarabunNew, Angsana, LINESeed) — เลือกตาม use case | [pubspec.yaml:222-313](../pubspec.yaml) |

### 📋 List/Form patterns

| # | เรื่อง | ที่ไหน |
|---|---|---|
| U15 | **`.create()` factory** ทุก page → wrap Provider ให้อัตโนมัติ | [registration_page.dart:33-50](../lib/ChiangMai_Municipality/Registration_menu/registration_page/views/registration_page.dart) |
| U16 | **`Stream<Event>` pattern** — VM broadcast event → view `listen()` (sealed class exhaustive) | [area_view_model.dart:36-38](../lib/ChiangMai_Municipality/Setting_menu/setting_page/area/viewmodels/area_view_model.dart) |
| U17 | **Config object** (`AreaConfig`, `RegistrationConfig`) — params ผ่าน VM constructor ไม่ hard-code | [area_config.dart](../lib/ChiangMai_Municipality/Setting_menu/setting_page/area/models/area_config.dart) |
| U18 | **Pagination built-in** ทุก list (perPage=50) — client-side slicing | pattern ทั่ว menu |

### 🛡️ Defensive UX

| # | เรื่อง | ที่ไหน |
|---|---|---|
| U19 | **Rotation guard** — height <500px แสดง "กรุณาหมุนเป็นแนวตั้ง" (ปกป้อง UI ที่ออกแบบ portrait-only) | [main.dart:120-130](../lib/main.dart) |
| U20 | **Token expiry auto-redirect** — polling 5 นาทีตรวจ, 401 → logout + redirect `/login` | [auth_state_notifier.dart:22-37](../lib/router/auth_state_notifier.dart) |
| U21 | **Material wrap** ใน shell — กัน "No Material widget found" error | [app_shell.dart:43-44](../lib/navigation/app_shell.dart) |

---

## 2. ข้อเสีย (Weaknesses) ⚠️

### 🔴 UX-blocking (กระทบ flow หลัก)

| # | ปัญหา | ผลกระทบ |
|---|---|---|
| **W1** | **ShellRoute ทำลาย state ทุกครั้งที่สลับเมนู** — `child` ถูกสร้างใหม่, VM state หายหมด (scroll position, search text, filter) — ผู้ใช้ต้องพิมพ์/เลื่อน/กรองใหม่ทุกครั้ง | ใช้งานน่ารำคาญมาก โดยเฉพาะเปิด 3-4 เมนูสลับกัน | [app_shell.dart:23-25](../lib/navigation/app_shell.dart) |
| **W2** | **ไม่มี skeleton/shimmer loading** — list page แสดง blank จนกว่า API จะตอบ (1-3s บน 3G) | User งงว่า app ค้างหรือไม่ |
| **W3** | **Error feedback generic** — `'เข้าสู่ระบบไม่สำเร็จ'` เหมือนกันหมด (password ผิด / network down / server 500) | User แก้ปัญหาไม่ได้ — ต้อง guess |
| **W4** | **ไม่มี empty state ที่ดี** — 0 row = blank table หรือ text "ไม่พบข้อมูล" เฉยๆ (ไม่มี CTA "เพิ่มรายการใหม่") | ผู้ใช้ใหม่งง — ไม่รู้ว่าต้องทำอะไร |

### 🟠 ข้อเสียทั่วไป

| # | ปัญหา |
|---|---|
| W5 | **Toast/Snackbar เด้งครั้งเดียว** — ถ้า user ไม่อยู่หน้าจอตอนนั้น พลาด message สำคัญ (เช่น save success/fail) — ควรมี notification center |
| W6 | **Modal/dialog ซ้อนกันได้** — login → privacy modal → ไม่มี dismiss-on-outside-tap guard |
| W7 | **Search debounce ไม่มี** — พิมพ์ทุก key ยิง filter/listener (ใน registration test เห็น pattern นี้) |
| W8 | **ไม่มี confirm dialog ก่อน destructive action** — delete row อาจไม่มี confirmation (ต้องดู per-menu) |
| W9 | **Form validation error message บาง field เป็นภาษาอังกฤษ** (เช่น `'รูปแบบอีเมลไม่ถูกต้อง เช่น: you@email.com'` — สลับภาษาในข้อความเดียว) | [Login_page_cmm.dart:187](../lib/ChiangMai_Municipality/List_CMM/Register_CMM/Login_page_cmm.dart) |
| W10 | **ไม่มี tooltips/help icon** ใน field ที่ซับซ้อน (เช่น เลขบัตร 13 หลัก + checksum, rent format) |
| W11 | **Pagination แค่ "หน้า X / Y"** — ไม่มี "go to page", ไม่มี keyboard shortcut |
| W12 | **Dropdown ใช้ 3 libs พร้อมกัน** (`dropdown_button2`, `dropdown_plus`, `animated_custom_dropdown`, `chips_choice`) — UX ไม่สม่ำเสมอระหว่าง menu |

### 🟡 A11y / i18n / minor

| # | ปัญหา |
|---|---|
| W13 | **ไม่มี semantic labels** ที่ชัดเจน — screen reader อ่านยาก (Material default บางส่วน แต่ custom widgets ไม่ครอบคลุม) |
| W14 | **Contrast ไม่ได้ตรวจ WCAG** — primary green + purple ใน login อาจ contrast ต่ำในบางพื้นที่ |
| W15 | **Font scaling ไม่ได้ทดสอบ** — user เปลี่ยน system font size 1.5x → layout อาจ break (table row height ไม่ auto-scale) |
| W16 | **Touch target < 48dp** ในบาง icon-only button (close, edit row icon) |
| W17 | **ภาษาลาว (lo_LA)** declared แต่ยังไม่มี translation จริง — สลับแล้วเห็น key fallback |
| W18 | **Date format hardcoded TH** (`dd/MM/yyyy`) — ผู้ใช้ en ควรเห็น `MM/dd/yyyy` |
| W19 | **Number/currency format hardcoded** — ไม่ใช้ `intl.NumberFormat.currency()` ตาม locale |
| W20 | **ไม่มี dark mode** — Material รองรับ แต่โปรเจกต์ไม่มี `ThemeData.dark()` |

---

## 3. จุดที่ต้องปรับปรุง (Improvements) 🔧

### P0 — Quick wins (สัปดาห์นี้)

| # | ปรับปรุง | Effort |
|---|---|---|
| I1 | **Error message specific** — map `401 → 'อีเมลหรือรหัสผ่านไม่ถูกต้อง'`, `network → 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ กรุณาลองใหม่'`, `500 → 'เซิร์ฟเวอร์ขัดข้อง กรุณาติดต่อเจ้าหน้าที่'` | S |
| I2 | **Loading skeleton** — `shimmer_from: ^0.0.x` หรือ custom gray boxes ตรง table row | S |
| I3 | **Empty state with CTA** — "ไม่พบข้อมูล + ปุ่ม เพิ่มรายการใหม่" (เฉพาะเมนูที่ add ได้) | S |
| I4 | **Search debounce** — wrap search listener ด้วย `Timer(Duration(milliseconds: 300))` | S |
| I5 | **Destructive confirm** — `showDialog<bool>` ก่อน delete (template helper) | S |

### P1 — UX quality

| # | ปรับปรุง | Effort |
|---|---|---|
| I6 | **StatefulShellRoute** แทน ShellRoute — cache VM state ต่อ branch (scroll/search/pagination คงอยู่เมื่อสลับเมนู) | M |
| I7 | **Notification center** — เก็บ SnackBar/toast ใน list, แสดงใน header bell icon | M |
| I8 | **Dropdown consolidation** — เลือก lib เดียว (`dropdown_button2` fork อยู่แล้ว) + ลบ `dropdown_plus`, `animated_custom_dropdown` | M |
| I9 | **Confirm modal pattern** — `Future<bool> showConfirm(context, title, body)` helper รวมศูนย์ | S |
| I10 | **Theme tokens** — รวม color/spacing/font ใน `lib/Style/theme.dart` (ตอนนี้กระจายในไฟล์ต่างๆ) | M |

### P2 — Polish

| # | ปรับปรุง | Effort |
|---|---|---|
| I11 | **Skeleton** สำหรับ detail page + form | S |
| I12 | **A11y audit** — ใส่ `Semantics(label: ...)` ใน custom widgets | M |
| I13 | **Dark mode** — `ThemeData.dark()` + `themeMode` toggle ใน setting | L |
| I14 | **Locale-aware formatting** — `intl.NumberFormat.simpleCurrency(locale: 'th_TH')` | S |
| I15 | **Form error message all-TH** — remove English fallback ใน error text | S |
| I16 | **Help icon (?)** ใน field ที่ต้องการ context (เลขบัตร, rent) | S |
| I17 | **Go to page input** + keyboard nav (`Ctrl+G` shortcut) | S |

### P3 — Long-term

| # | ปรับปรุง |
|---|---|
| I18 | **i18n เต็มรูป** — translate ทุก hardcoded string (ปัจจุบัน ~70% inline Thai) → `arb` files |
| I19 | **Storybook / widget catalog** — design system isolated |
| I20 | **User feedback widget** — floating "ส่ง feedback" ปุ่ม |
| I21 | **Onboarding tour** สำหรับ user ใหม่ (แต่ละ role เห็น flow ต่างกัน) |
| I22 | **Accessibility audit tooling** — `flutter_test` golden + a11y linter |

---

## 4. ตัวอย่างการปรับปรุง (Concrete Patterns) 🛠

### Pattern A: Specific error feedback

```dart
// lib/utility/error_mapper.dart
class ErrorMapper {
  static String thaiMessage(Object error, [StackTrace? stack]) {
    if (error is http.ClientException) return 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ กรุณาตรวจสอบอินเทอร์เน็ต';
    if (error is TimeoutException) return 'การเชื่อมต่อใช้เวลานานเกินไป';
    if (error is HttpException) {
        final code = error.statusCode;
        if (code == 401) return 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
        if (code == 403) return 'คุณไม่มีสิทธิ์เข้าถึง';
        if (code == 404) return 'ไม่พบข้อมูลที่ต้องการ';
        if (code == 500) return 'เซิร์ฟเวอร์ขัดข้อง กรุณาติดต่อเจ้าหน้าที่';
      }
    return 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง';
  }
}
```

### Pattern B: Loading skeleton

```dart
// lib/widgets/list_skeleton.dart
class ListSkeleton extends StatelessWidget {
  final int rows;
  const ListSkeleton({super.key, this.rows = 8});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: rows,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFE5E7EB),
              radius: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12, color: const Color(0xFFE5E7EB)),
                  const SizedBox(height: 6),
                  Container(height: 10, width: 120, color: const Color(0xFFF3F4F6)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Pattern C: Empty state with CTA

```dart
// lib/widgets/empty_state.dart
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? ctaLabel;
  final VoidCallback? onCta;
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.ctaLabel,
    this.onCta,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: const Color(0xFF9CA3AF)),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center),
            ],
            if (ctaLabel != null && onCta != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(onPressed: onCta, child: Text(ctaLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
```

### Pattern D: Confirm dialog helper

```dart
// lib/widgets/confirm_dialog.dart
Future<bool> showConfirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'ยืนยัน',
  String cancelLabel = 'ยกเลิก',
  bool danger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(cancelLabel)),
        ElevatedButton(
          style: danger ? ElevatedButton.styleFrom(backgroundColor: Colors.red) : null,
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
```

### Pattern E: StatefulShellRoute (replace ShellRoute)

```dart
// lib/router/app_router.dart — แทน ShellRoute ด้วย StatefulShellRoute.indexedStack
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) =>
      AppShell(navigationShell: navigationShell),
  branches: [
    StatefulShellBranch(routes: [GoRoute(path: '/contract', ...)]),
    StatefulShellBranch(routes: [GoRoute(path: '/payment', ...)]),
    // ... 8 branches
  ],
)
// แล้วใน AppShell ใช้ navigationShell.currentIndex + navigationShell.goBranch(i)
```

### Pattern F: Search debounce

```dart
// lib/utility/debouncer.dart
class Debouncer {
  final Duration delay;
  Timer? _timer;
  Debouncer({this.delay = const Duration(milliseconds: 300)});
  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }
  void dispose() => _timer?.cancel();
}

// usage:
final _searchDebouncer = Debouncer();
onChanged: (v) {
  _searchDebouncer(() => vm.setSearch(v));
}
```

---

## 5. UX Heuristic Score (Nielsen 10)

| # | Heuristic | Score (1-5) | Note |
|---|---|---|---|
| H1 | Visibility of system status | 3 | loading มี, แต่ไม่มี skeleton / progress สำหรับ list |
| H2 | Match between system and real world | 4 | ภาษาไทย, icons คุ้นเคย, layout สมเหตุสมผล |
| H3 | User control and freedom | 2 | back navigation OK, แต่ undo ไม่มี, state หายเมื่อสลับเมนู |
| H4 | Consistency and standards | 3 | dropdown ใช้หลาย lib, error message ไม่สม่ำเสมอ |
| H5 | Error prevention | 3 | confirm dialog บางส่วน, ไม่มี unsaved-changes guard |
| H6 | Recognition rather than recall | 3 | breadcrumb มี, แต่ help/tooltip ขาด |
| H7 | Flexibility and efficiency of use | 2 | ไม่มี keyboard shortcut, ไม่มี bulk action |
| H8 | Aesthetic and minimalist design | 4 | clean, Material design, ไม่ cluttered |
| H9 | Help users recognize, diagnose, recover from errors | 2 | error message generic, ไม่ชี้ทางแก้ |
| H10 | Help and documentation | 1 | ไม่มี in-app help, ไม่มี onboarding |

**Average**: 2.7 / 5 — **ต้องปรับปรุง** โดยเฉพาะ H3, H7, H9, H10

---

## 6. Priority Matrix

```
High Impact │ I6 (StatefulShell)   I1 (error msg)
            │ I3 (empty state)     I2 (skeleton)
            │─────────────────────│────────────────
Low Impact  │ I11 (detail skel)    I15 (TH error)
            │ I14 (currency fmt)   I16 (help icon)
            └─────────────────────┴────────────────
              Low Effort               High Effort
```

**ทำก่อน**: I1, I2, I3, I5, I6, I11 (P0+P1 high impact)

---

## 7. เกณฑ์ Pass / Fail (UX)

### Definition of Done — ทุก menu page
- [ ] Loading state มี skeleton หรือ indicator ที่ชัดเจน
- [ ] Empty state มีข้อความ + CTA (ถ้า add ได้)
- [ ] Error state แยกตาม status code (401/403/500/network)
- [ ] Snackbar ไม่หายไปก่อน user เห็น (≥3s duration หรือ in-app notification)
- [ ] Destructive action มี confirm dialog
- [ ] Form error message เป็นภาษาไทยล้วน
- [ ] A11y: semantic label ครอบ custom widget
- [ ] State คงอยู่เมื่อสลับ branch (StatefulShellRoute)

### ตัวชี้วัด
- **Bounce rate** — user ออกจากหน้า login / list ภายใน 5s ควร <10%
- **Task completion** — flow สำคัญ (login → CRUD → logout) <2 นาที
- **Error recovery** — user แก้ error สำเร็จใน 1 attempt >80%

---

## 8. เครื่องมือช่วย audit

```bash
# 1. หา hardcoded Thai/English strings ในไฟล์ UI
grep -rn "Text('" lib/ChiangMai_Municipality --include="*_page.dart" --include="*_screen.dart" | head -30

# 2. หา pages ที่ไม่มี error handling
grep -L "catch\|ErrorEvent" lib/ChiangMai_Municipality --include="*_page.dart" -r

# 3. หา widgets ที่ไม่มี Semantics
grep -L "Semantics(" lib/ChiangMai_Municipality --include="*.dart" -r

# 4. หา setState ที่อาจบ่งบอก state management ไม่ดี
grep -rn "setState(" lib/ChiangMai_Municipality --include="*_page.dart" | wc -l

# 5. List package ใช้บ่อย (overlap/consolidation candidates)
grep -rh "import 'package:dropdown" lib/ --include="*.dart" | sort -u
```

---

**จบเอกสาร** — อัปเดตเมื่อ:
- I1-I6 แก้เสร็จ → bump H-score
- เพิ่ม feature ใหม่ → verify ตาม DoD checklist
- เพิ่ม lib ใหม่ → check overlap กับ UI kit เดิม