// ============================================================================
// favorite_menu_service.dart
// ============================================================================
// Service — pin/favorite เมนู navigation ของ user
//
// Backend:
// - POST {domain_v2}/admin/roles/pin    body: {role_id, favorite: bool}
// - GET  {domain_v2}/admin/roles/tree   → ย้ายไป MenuAccessService แล้ว
//   (เดิม service นี้ยิงเอง ทำให้ตอน login ยิงซ้ำหลายรอบ)
//
// Frontend cache (SharedPreferences key 'menuFavoriteRoutes'):
// - CSV ของ route paths ที่ user pin (เช่น "/contract,/payment")
// - ใช้ render เมนูโปรดทันทีก่อน API ตอบ
//
// Permission safety:
// - ตอน render favorites box ต้อง intersect กับ allowed permissions ของ user
//   (เหมือน NavigationMenuService.loadFiltered)
// ============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Constant/Myconstant.dart';
import '../../ChiangMai_Municipality/unity/auth_token_store.dart';

class FavoriteMenuService {
  static const String _cacheKey = 'menuFavoriteRoutes';

  static String get _pinUrl => '${MyConstant().domain_v2}/admin/roles/pin';

  /// อ่าน pinned routes จาก local cache (CSV ใน SharedPreferences)
  /// - return empty set ถ้า cache ว่าง/parse error
  static Future<Set<String>> readCachedRoutes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey) ?? '';
      if (raw.isEmpty) return <String>{};
      return raw
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toSet();
    } catch (_) {
      return <String>{};
    }
  }

  /// เก็บ pinned routes ลง cache (CSV)
  static Future<void> _writeCache(Set<String> routes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, routes.join(','));
    } catch (_) {
      // ignore — cache write ไม่ critical
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // NOTE: fetchPinnedRoutes() และ fetchRouteRoleIds() ถูกถอดออกแล้ว
  //   เดิม 2 ตัวนี้ยิง GET /admin/roles/tree แยกกันเอง (payload ก้อนเดียวกัน)
  //   ทำให้ตอน login ยิงซ้ำ ใช้ MenuAccessService.load() แทน — อ่าน cache ก่อน
  //   และ parse tree ครั้งเดียวได้ครบทั้ง pinned routes + route_role_ids
  // ────────────────────────────────────────────────────────────────────────

  /// Toggle pin สำหรับ role (POST /admin/roles/pin)
  /// Body ตามตัวอย่าง user ส่ง: `{ "role_id": 6, "favorite": true }`
  /// - คืน true ถ้า server ตอบ 2xx
  static Future<bool> _setPin({
    required int roleId,
    required bool favorite,
  }) async {
    final token = await AuthTokenStore.read();
    if (token == null) return false;
    try {
      final body = jsonEncode({'role_id': roleId, 'favorite': favorite});
      print('[FavoriteMenuService] 📤 POST $_pinUrl');
      print('[FavoriteMenuService] 📦 body=$body');
      final response = await http.post(
        Uri.parse(_pinUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );
      final ok = response.statusCode == 200 || response.statusCode == 201;
      if (!ok) {
        print(
            '[FavoriteMenuService] ❌ setPin status=${response.statusCode} body=${response.body}');
      } else {
        print(
            '[FavoriteMenuService] ✅ setPin status=${response.statusCode} role_id=$roleId favorite=$favorite');
      }
      return ok;
    } catch (e) {
      print('[FavoriteMenuService] setPin error: $e');
      return false;
    }
  }

  /// Optimistic toggle — อัปเดต cache ทันที แล้ว sync ขึ้น server
  /// คืน final state (true = pinned หลัง toggle)
  static Future<bool> toggleRoute(
    String route, {
    required int roleId,
  }) async {
    final current = await readCachedRoutes();
    final next = {...current};
    bool nowPinned;
    if (next.contains(route)) {
      next.remove(route);
      nowPinned = false;
    } else {
      next.add(route);
      nowPinned = true;
    }
    // optimistic write
    await _writeCache(next);
    // sync to server
    final ok = await _setPin(roleId: roleId, favorite: nowPinned);
    if (!ok) {
      // rollback ถ้า server fail
      await _writeCache(current);
      return current.contains(route);
    }
    return nowPinned;
  }

  /// ล้าง cache (ใช้ตอน logout)
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
    } catch (_) {}
  }
}