import 'dart:async';

import 'package:flutter/foundation.dart';

import '../ChiangMai_Municipality/List_CMM/Register_CMM/AuthService.dart';
import '../ChiangMai_Municipality/unity/SecurePrefs_helper.dart';

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

  /// ออกจากระบบ — ลบ token และ notify GoRouter redirect ไป /login
  Future<void> signOut() async {
    // ลบ auth keys ทั้งหมดจาก SecurePrefs
    await Future.wait([
      SecurePrefs.removeEncrypted(SecurePrefsType.authAccessToken),
      SecurePrefs.removeEncrypted(SecurePrefsType.authRefreshToken),
      SecurePrefs.removeEncrypted(SecurePrefsType.authTokenType),
      SecurePrefs.removeEncrypted(SecurePrefsType.authUserUuid),
      SecurePrefs.removeEncrypted(SecurePrefsType.authUserEmail),
      SecurePrefs.removeEncrypted(SecurePrefsType.authUserTel),
      SecurePrefs.removeEncrypted(SecurePrefsType.authUserTax),
      SecurePrefs.removeEncrypted(SecurePrefsType.authUserId),
      SecurePrefs.removeEncrypted(SecurePrefsType.authUserObject),
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
