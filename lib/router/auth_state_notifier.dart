import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../ChiangMai_Municipality/List_CMM/Register_CMM/AuthService.dart';
import '../ChiangMai_Municipality/unity/SecurePrefs_helper.dart';
import '../ChiangMai_Municipality/unity/auth_token_store.dart';
import '../Constant/Myconstant.dart';

/// Notifier สำหรับ GoRouter — แจ้งเตือนเมื่อ auth state เปลี่ยน
///
/// ใช้วิธี polling (เช็ค token ทุก 1 วินาที) เพราะ AuthService เดิม
/// เป็น static class ไม่มี stream — ไม่ต้องแก้ LoginPage
class AuthStateNotifier extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _initialized = false;
  Timer? _poller;

  /// สถานะ login ปัจจุบัน
  bool get isLoggedIn => _isLoggedIn;

  /// เริ่ม polling เช็ค auth state ทุก 5 นาที
  void startPolling() {
    if (_poller != null) return;
    _poller = Timer.periodic(const Duration(minutes: 5), (_) => _check());
    // เช็คครั้งแรกทันที
    _check();
  }

  Future<void> _check() async {
    final loggedIn = await AuthService.tryAutoLogin();
    if (loggedIn != _isLoggedIn || !_initialized) {
      _isLoggedIn = loggedIn;
      _initialized = true;
      notifyListeners();
    }
  }

  /// ออกจากระบบ — revoke token ที่ backend แล้วลบ local
  /// 1) POST /admin/auth/logout → 200 = server ลบ token แล้ว
  /// 2) clearAllAuthStores() + ลบ legacy keys
  /// 3) notify router → redirect /login
  Future<void> signOut() async {
    final token = await AuthTokenStore.read();
    if (token != null) {
      try {
        final headers = await MyHeaders.build();
        final uri = Uri.parse(
          '${MyConstant().domain_v2}/admin/auth/logout',
        );
        final response = await http
            .post(uri, headers: headers)
            .timeout(const Duration(seconds: 10));
        if (kDebugMode) {
          debugPrint('🚪 [signOut] status=${response.statusCode} body=${response.body}');
        }
      } catch (e) {
        // network down → clear local ต่อ ไม่ block logout
        if (kDebugMode) debugPrint('🚪 [signOut] revoke failed: $e');
      }
    }

    // ลบ auth data ทั้งหมด (sessionStorage บนเว็บ / SecurePrefs บน native)
    await clearAllAuthStores();
    await Future.wait([
      SecurePrefs.removeEncrypted(SecurePrefsType.authRefreshToken),
      SecurePrefs.removeEncrypted(SecurePrefsType.authTokenType),
      SecurePrefs.removeEncrypted(SecurePrefsType.authUserTel),
      SecurePrefs.removeEncrypted(SecurePrefsType.authUserTax),
      SecurePrefs.removeEncrypted(SecurePrefsType.authUserId),
    ]);
    markLoggedOut();
  }

  /// เรียกเมื่อ logout เพื่อให้ router refresh
  void markLoggedOut() {
    if (_isLoggedIn) {
      _isLoggedIn = false;
      notifyListeners();
    }
  }

  /// เรียกเมื่อ login สำเร็จ (เผื่ออยาก trigger ทันที)
  void markLoggedIn() {
    if (!_isLoggedIn) {
      _isLoggedIn = true;
      _initialized = true;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _poller?.cancel();
    _poller = null;
    super.dispose();
  }
}
