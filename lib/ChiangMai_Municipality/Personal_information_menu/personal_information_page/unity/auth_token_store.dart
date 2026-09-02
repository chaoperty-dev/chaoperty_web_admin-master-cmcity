// ============================================================================
// auth_token_store.dart
// ============================================================================
// Auth data store with platform split (pentest hardening):
// - Web (iOS Safari / Android Chrome / desktop): sessionStorage
//   -> auth data dies when tab closes, short attack window
//   -> fallback to SecurePrefs if sessionStorage is blocked
//      (iOS Safari private mode can throw on setItem)
// - Native (Windows / Android / iOS apps): SecurePrefs (encrypted prefs)
//
// Why not localStorage on web: token lives ~30 days, readable by any XSS
// payload for the whole lifetime. sessionStorage limits exposure to the
// open tab session.
//
// Why not httpOnly cookie: would require backend change + dropping the
// "Authorization: Bearer" header pattern used across all API calls.
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

import 'SecurePrefs_helper.dart';

Future<void> _save(String webKey, SecurePrefsType type, String value) async {
  if (kIsWeb) {
    try {
      html.window.sessionStorage[webKey] = value;
      return;
    } catch (_) {
      // Safari private mode etc. -> fall through to SecurePrefs
    }
  }
  await SecurePrefs.setEncrypted(type, value);
}

Future<String?> _read(String webKey, SecurePrefsType type) async {
  if (kIsWeb) {
    try {
      final v = html.window.sessionStorage[webKey];
      if (v != null && v.isNotEmpty) return v;
    } catch (_) {}
  }
  return SecurePrefs.getDecrypted(type);
}

Future<void> _clear(String webKey, SecurePrefsType type) async {
  if (kIsWeb) {
    try {
      html.window.sessionStorage.remove(webKey);
    } catch (_) {}
  }
  await SecurePrefs.removeEncrypted(type);
}

/// Access token
class AuthTokenStore {
  static const String _webKey = 'cmm_at';

  static Future<void> save(String token) =>
      _save(_webKey, SecurePrefsType.authAccessToken, token);

  static Future<String?> read() =>
      _read(_webKey, SecurePrefsType.authAccessToken);

  static Future<void> clear() =>
      _clear(_webKey, SecurePrefsType.authAccessToken);
}

/// User object (PII: name, email, permissions, approve flow)
class AuthUserStore {
  static const String _webKey = 'cmm_user';

  static Future<void> save(String json) =>
      _save(_webKey, SecurePrefsType.authUserObject, json);

  static Future<String?> read() =>
      _read(_webKey, SecurePrefsType.authUserObject);

  static Future<void> clear() =>
      _clear(_webKey, SecurePrefsType.authUserObject);
}

/// Roles tree (menu permissions)
class AuthRolesTreeStore {
  static const String _webKey = 'cmm_roles';

  static Future<void> save(String json) =>
      _save(_webKey, SecurePrefsType.authRolesTree, json);

  static Future<String?> read() =>
      _read(_webKey, SecurePrefsType.authRolesTree);

  static Future<void> clear() => _clear(_webKey, SecurePrefsType.authRolesTree);
}

/// User uuid
class AuthUuidStore {
  static const String _webKey = 'cmm_uuid';

  static Future<void> save(String value) =>
      _save(_webKey, SecurePrefsType.authUserUuid, value);

  static Future<String?> read() => _read(_webKey, SecurePrefsType.authUserUuid);

  static Future<void> clear() => _clear(_webKey, SecurePrefsType.authUserUuid);
}

/// User email
class AuthEmailStore {
  static const String _webKey = 'cmm_email';

  static Future<void> save(String value) =>
      _save(_webKey, SecurePrefsType.authUserEmail, value);

  static Future<String?> read() =>
      _read(_webKey, SecurePrefsType.authUserEmail);

  static Future<void> clear() => _clear(_webKey, SecurePrefsType.authUserEmail);
}

/// Clear every auth item at once (logout).
Future<void> clearAllAuthStores() async {
  await Future.wait([
    AuthTokenStore.clear(),
    AuthUserStore.clear(),
    AuthRolesTreeStore.clear(),
    AuthUuidStore.clear(),
    AuthEmailStore.clear(),
  ]);
}
