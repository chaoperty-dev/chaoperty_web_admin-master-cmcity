# Security Audit — chaoperty-admin-cmcity

> สแกน active code เท่านั้น (ตัด commented/dead ออก)
>
> Baseline: `6d1a298` (HEAD) · วันที่: 2026-09-02

---

## 1. จุดดี (Strengths) ✅

| # | เรื่อง | ที่ไหน |
|---|---|---|
| S1 | **Bearer token centralization** — `MyHeaders.build()` ทุก call ใช้ header เดียวกัน | [lib/Constant/Myconstant.dart:7-16](../lib/Constant/Myconstant.dart) |
| S2 | **sessionStorage on web** — token ตายเมื่อปิด tab (ลด XSS long-lived exposure) | [lib/ChiangMai_Municipality/unity/auth_token_store.dart:25-33](../lib/ChiangMai_Municipality/unity/auth_token_store.dart) |
| S3 | **Path URL strategy** — ไม่มี hash (`/area` แทน `/#/area`) → token ไม่หลุดผ่าน URL | [lib/main.dart:55](../lib/main.dart) |
| S4 | **Auto-logout on token invalid** — `tryAutoLogin()` ยิง `/admin/roles/tree` ตรวจ, 401 → clearAllAuthStores() | [lib/ChiangMai_Municipality/List_CMM/Register_CMM/AuthService.dart:145-162](../lib/ChiangMai_Municipality/List_CMM/Register_CMM/AuthService.dart) |
| S5 | **Native encryption** — SecurePrefs (AES via `protect`) ใช้บน mobile/desktop | [lib/ChiangMai_Municipality/unity/SecurePrefs_helper.dart:39-55](../lib/ChiangMai_Municipality/unity/SecurePrefs_helper.dart) |
| S6 | **Safari private fallback** — sessionStorage throw → fall through to SecurePrefs แทนที่จะ crash | [lib/.../auth_token_store.dart:30-32](../lib/ChiangMai_Municipality/unity/auth_token_store.dart) |
| S7 | **Permission gating per route** — `navigation_menu.json` มี `permission` field → GoRouter redirect | [lib/router/app_router.dart:103-121](../lib/router/app_router.dart) |
| S8 | **Bearer over cookie** — ไม่ auto-send credentials (CSRF-immune โดย design) | [lib/Constant/Myconstant.dart:13](../lib/Constant/Myconstant.dart) |
| S9 | **Service pattern try/catch** — services ไม่ throw, return empty + `debugPrint` | [lib/.../area/services/area_service.dart:67-71](../lib/ChiangMai_Municipality/Setting_menu/setting_page/area/services/area_service.dart) |
| S10 | **ChangeNotifier scope** — VM ต่อ page, ไม่มี global mutable state | pattern ทั่ว `**/viewmodels/*.dart` |

---

## 2. จุดเสี่ยง (Risks) ⚠️

### 🔴 CRITICAL (ต้องแก้ก่อน release)

| # | ปัญหา | ผลกระทบ | ที่ไหน |
|---|---|---|---|
| **R1** | **AES key hardcoded ใน source** — `_keyString = 'my32lengthdzentricchaoperty2023s'` คนที่มี repo = decrypt ได้ทุก SecurePrefs (รวม auth tokens) | Total compromise ของ auth data | [lib/ChiangMai_Municipality/unity/EncryptText.dart:5](../lib/ChiangMai_Municipality/unity/EncryptText.dart) |
| **R2** | **`.env` file committed ใน repo** — duplicate hardcoded key, defeats env-var concept | Same as R1 + secret rotation ไม่ได้ | [lib/ChiangMai_Municipality/unity/EncryptTex.env](../lib/ChiangMai_Municipality/unity/EncryptTex.env) |
| **R3** | **PII เก็บ plain SharedPreferences** — `fname`, `lname`, `email`, `position`, `permission` เขียนลง SharedPreferences ตรงๆ (ไม่ผ่าน SecurePrefs) | XSS บน web → อ่าน `localStorage` ได้ทันที | [lib/.../AuthService.dart:248-262](../lib/ChiangMai_Municipality/List_CMM/Register_CMM/AuthService.dart) |
| **R4** | **`menuPermission` plain-text ใน prefs** — comma-separated role codes, drive sidebar visibility | Client-side privilege manipulation (read-only, แต่ information disclosure) | [lib/.../AuthService.dart:106](../lib/ChiangMai_Municipality/List_CMM/Register_CMM/AuthService.dart) |
| **R5** | **Email logged plaintext บน login** — `body = {email: $email, password: ***}` เข้า browser console | XSS → ขโมย email (PII), รู้ว่า user นี้ login เมื่อไหร่ | [lib/.../AuthService.dart:22](../lib/ChiangMai_Municipality/List_CMM/Register_CMM/AuthService.dart) |
| **R6** | **Response body logged on failure** — `body = ${response.body}` log response ดิบจาก server | Stack trace / error details / internal structure จาก PHP หลุด | [lib/.../AuthService.dart:69](../lib/ChiangMai_Municipality/List_CMM/Register_CMM/AuthService.dart) |

### 🟠 HIGH (ควรแก้ใน sprint ถัดไป)

| # | ปัญหา | ผลกระทบ |
|---|---|---|
| R7 | **ไม่มี request timeout** — `http.get/post` ไม่ตั้ง `.timeout()` | Slowloris / DoS — request ค้างได้นาน |
| R8 | **ไม่มี certificate pinning** — TLS validation default | MITM ถ้า device ติด malicious CA |
| R9 | **Auto-login poll ทุก 5 นาที** — ยิง `/admin/roles/tree` ตลอด (main.dart line 24) | Bandwidth waste + activity pattern disclosure |
| R10 | **`enableAppLogs = true`** global — verbose log เปิดใน prod build (ไม่มี kDebugMode guard) | Performance + log leakage บน release |
| R11 | **`mysql1` ^0.20.0 ใน pubspec** — DB driver ฝั่ง client (ไม่ใช้ในโค้ด) | Supply-chain attack surface (build-time risk) |
| R12 | **`global_http.dart` placeholder secret** — `"YOUR_SECRET_KEY_HERE"` ค้างในไฟล์ (code review precedent) | Dev confuse — คิดว่ามี HMAC signing ทั้งที่ไม่มี |
| R13 | **ID card checksum ไม่ validate** — `formatThaiIdCard` strip non-digits แต่ไม่ตรวจ 13-digit checksum | รับ invalid ID ตั้งแต่ UI (กัน typo ไม่ได้) |

### 🟡 MEDIUM (backlog)

| # | ปัญหา |
|---|---|
| R14 | **ไม่มี login rate limit UI** — brute force login ได้เรื่อยๆ |
| R15 | **`roles/tree` โหลดใหม่ทุกครั้ง** — ไม่มี ETag/304 handling |
| R16 | **No input sanitization ที่ UI layer** — rely entirely on backend |
| R17 | **`debugPrint` 488 occurrences** — release build ยัง print (no kDebugMode guard) |
| R18 | **Rotation guard bypass-able** — `MediaQuery.height < 500` spoof ได้ด้วย DevTools |

---

## 3. จุดที่ต้องปรับปรุง (Improvements) 🔧

### P0 — ทำทันที (ก่อน next release)

```dart
// 1. ย้าย key ออกจาก source — ใช้ flutter_dotenv runtime
// lib/ChiangMai_Municipality/unity/EncryptText.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

final _key = encrypt.Key.fromUtf8(
  dotenv.env['SPERFER_SECRET_KEY'] ?? (throw StateError('Missing SPERFER_SECRET_KEY'))
);
final _iv = encrypt.IV.fromLength(16);
// + ลบไฟล์ EncryptTex.env ออกจาก git (.gitignore)
```

```dart
// 2. Per-install salt — เก็บใน keychain (native) / IndexedDB (web)
// lib/ChiangMai_Municipality/unity/encrypt_text_v2.dart
class KeyManager {
  static Future<Uint8List> getOrCreateSalt() async {
    if (kIsWeb) {
      // IndexedDB (already there) — มี fallback SharedPreferences
    } else {
      // flutter_secure_storage: Android Keystore / iOS Keychain
    }
  }
}
```

```dart
// 3. Guard log calls — ไม่หลุด prod
// lib/ChiangMai_Municipality/List_CMM/Register_CMM/AuthService.dart
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  debugPrint('🌐 [AuthService.login] URL = $_loginUrl');
  debugPrint('   body = {email: ${email.hashCode}, password: ***}'); // hash แทน plaintext
}
```

```dart
// 4. Encrypt legacy prefs ทั้งหมด — ผ่าน AuthUserStore
// lib/.../AuthService.dart:227 _persistLegacyPrefs
// แทน prefs.setString('email', ...) → เก็บใน AuthUserStore (มี encrypt อยู่แล้ว)
// legacy code ที่อ่าน 'fname'/'lname' → migrate ไปอ่านจาก AuthUserStore
```

### P1 — Sprint ถัดไป

- เพิ่ม `.timeout(Duration(seconds: 15))` ใน `MyHeaders.build()` (สร้าง `http.Client` with timeout)
- ตรวจ 13-digit checksum ใน `formatThaiIdCard` → `isValidThaiId(String)`
- เปลี่ยน `enableAppLogs = true` → guard ด้วย `kDebugMode`
- ลบ `mysql1` ออกจาก pubspec (ไม่ใช้)
- ลบ `global_http.dart` (ใช้แทนด้วยอันจริง หรือลบทิ้ง)
- เปลี่ยน `print()` ทุกตัวใน AuthService.dart → `debugPrint` + `kDebugMode` guard

### P2 — Quarter หน้า

- ใช้ `flutter_secure_storage` เก็บ key (Android Keystore / iOS Keychain)
- Implement `/admin/auth/refresh` flow (token refresh ก่อนหมดอายุ)
- ETag / cache validation สำหรับ `roles/tree`
- Login throttling UI (disable button 3s หลัง fail, exponential backoff)
- แยก error model — log only `errorCode`, never raw body
- Encrypt `menuPermission` ด้วย salt เดียวกับ SecurePrefs (หรือ derive จาก `AuthRolesTreeStore`)

### P3 — Long-term

- ย้ายไป OAuth 2.0 PKCE (ถ้า backend support)
- CSP `<meta>` ใน `web/index.html` — restrict script-src, frame-ancestors
- Subresource Integrity (SRI) สำหรับ CDN assets
- `dart pub outdated` + Dependabot ใน CI
- Security checklist ใน PR template (require secrets review + log audit)

---

## 4. แนวทางการแก้ (Concrete Fix Pattern) 🛠

### Pattern A: Encrypted secret loading

```dart
// lib/Constant/secrets.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Secrets {
  static String get sperferKey {
    final v = dotenv.env['SPERFER_SECRET_KEY'];
    if (v == null || v.length < 32) {
      throw StateError('SPERFER_SECRET_KEY missing or too short');
    }
    return v;
  }

  static String get apiBaseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'https://cmcity-test-api.chaoperties.com/api/v2';
  }
}
```

`.env.example` (commit), `.env` (gitignored):
```bash
SPERFER_SECRET_KEY=<32-char random, rotate per env>
API_BASE_URL=https://cmcity-test-api.chaoperties.com/api/v2
```

### Pattern B: Per-install salt

```dart
// lib/ChiangMai_Municipality/unity/encrypt_text_v2.dart
class EncryptedPrefs {
  static Future<encrypt.Key> _getKey() async {
    final salt = await KeyManager.getOrCreateSalt(); // 32 bytes
    final derived = await deriveKey(salt, passphrase: 'chaoperty-v1');
    return encrypt.Key(derived);
  }

  static Future<void> setEncrypted(String key, String value) async {
    final aesKey = await _getKey();
    final iv = encrypt.IV.fromSecureRandom(16); // random IV ต่อ entry
    final encrypter = encrypt.Encrypter(encrypt.AES(aesKey));
    final ct = encrypter.encrypt(value, iv: iv);
    await _writeRaw(key, '${iv.base64}:${ct.base64}');
  }
}
```

### Pattern C: Safe logging

```dart
// lib/utility/safe_log.dart
import 'package:flutter/foundation.dart';

void safeLog(String tag, String message, {Object? error, StackTrace? stack}) {
  if (!kDebugMode) return;
  // scrub email/token patterns
  final scrubbed = message
      .replaceAll(RegExp(r'[\w.-]+@[\w.-]+'), '***@***')
      .replaceAll(RegExp(r'Bearer\s+\S+'), 'Bearer ***');
  debugPrint('$tag $scrubbed');
  if (error != null) debugPrint('$tag error: ${error.runtimeType}');
}
```

### Pattern D: Thai ID checksum

```dart
// lib/ChiangMai_Municipality/unity/FormatIDCard.dart
bool isValidThaiId(String? raw) {
  if (raw == null) return false;
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.length != 13) return false;
  var sum = 0;
  for (var i = 0; i < 12; i++) {
    sum += int.parse(digits[i]) * (13 - i);
  }
  final check = (11 - (sum % 11)) % 10;
  return check == int.parse(digits[12]);
}
```

---

## 5. เกณฑ์ Pass / Fail

### ก่อน Production release (P0)
- [ ] R1-R6 ทุกข้อ ✅ (hardcoded key, .env, plain prefs, log leakage)
- [ ] `fvm flutter analyze` clean
- [ ] `fvm flutter test` ผ่าน
- [ ] Manual pen-test: login flow ไม่มี email/token ใน DevTools console

### ทุก PR (mandatory)
- [ ] ไม่มี `print(` ใน production code (ใช้ `debugPrint` + `kDebugMode` guard)
- [ ] ไม่มี secret/key ใน source (ใช้ env)
- [ ] ไม่มี PII ใน SharedPreferences ตรงๆ (ผ่าน SecurePrefs เท่านั้น)
- [ ] ไม่มี new `http.get/post` ที่ไม่ผ่าน `MyHeaders.build()` (Bearer mandatory)

---

## 6. เครื่องมือช่วยตรวจ

```bash
# 1. หา hardcoded secrets
grep -rn "= '.*';" lib/ --include="*.dart" | grep -iE "key|secret|token|password"

# 2. หา print() ใน production path
grep -rn "^\s*print(" lib/ --include="*.dart" | grep -v "kDebugMode"

# 3. หา SharedPreferences.set* ในไฟล์ที่ไม่ใช่ SecurePrefs_helper
grep -rn "SharedPreferences.getInstance" lib/ --include="*.dart" | grep -v SecurePrefs_helper

# 4. Check unused deps
fvm flutter pub deps --no-dev | grep -E "^├─|^│  ├─" | grep -v "used"
```

---

**จบเอกสาร** — อัปเดตเมื่อ:
- R1-R6 แก้เสร็จ → flip เป็น ✅
- เพิ่ม endpoint ใหม่ → audit Bearer header
- เพิ่ม lib ใหม่ → audit license + known CVEs