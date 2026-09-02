// ============================================================================
// favorite_menu_service.dart
// ============================================================================
// Service — pin/favorite เมนู navigation ของ user
//
// Backend:
// - GET  {domain_v2}/admin/roles/tree   → roles tree (รวม assigned menus)
//     field "pin" / "favorite" จะถูกเพิ่มทีหลัง (ตอนนี้ frontend ใช้ route เป็น id)
// - POST {domain_v2}/admin/roles/pin    body: {role_id, favorite: bool}
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

  // Roles tree endpoint (เราใช้ตัวเดียวกับ AuthService)
  static String get _rolesTreeUrl => '${MyConstant().domain_v2}/admin/roles/tree';
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

  /// GET /admin/roles/tree → extract รายการ pin routes ของ role ปัจจุบัน
  /// ปัจจุบัน backend ไม่มี field pin/favorite ใน tree → return empty set
  /// เมื่อ backend เพิ่ม field จริง → extract ตรงนี้
  ///
  /// Strategy รองรับอนาคต:
  /// - ดูทุก role ใน data[] ที่ assigned == true
  /// - ถ้ามี field "favorite_routes" / "pinned_routes" → union ทั้งหมด
  /// - ถ้ามี field "pinned_ids" / "favorite_ids" → ใช้ตามนั้น (backend จะส่ง id จริง)
  static Future<Set<String>> fetchPinnedRoutes() async {
    final token = await AuthTokenStore.read();
    if (token == null) return <String>{};
    try {
      final headers = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final response =
          await http.get(Uri.parse(_rolesTreeUrl), headers: headers);
      if (response.statusCode != 200) return <String>{};
      final jsonRes = jsonDecode(response.body);
      final data = jsonRes is Map ? jsonRes['data'] : null;
      if (data is! List) return <String>{};

      final pinned = <String>{};
      for (final roleRaw in data) {
        if (roleRaw is! Map) continue;
        // assigned == true = user มี role นี้
        final assigned = roleRaw['assigned'] == true;
        if (!assigned) continue;
        // รองรับหลาย key ที่ backend อาจใช้
        for (final key in ['favorite_routes', 'pinned_routes', 'favorites']) {
          final v = roleRaw[key];
          if (v is List) {
            for (final item in v) {
              if (item is String && item.isNotEmpty) pinned.add(item);
            }
          }
        }
        for (final key in ['favorite_ids', 'pinned_ids']) {
          final v = roleRaw[key];
          if (v is List) {
            for (final item in v) {
              final s = item?.toString();
              if (s != null && s.isNotEmpty) pinned.add(s);
            }
          }
        }
      }
      if (pinned.isNotEmpty) await _writeCache(pinned);
      return pinned;
    } catch (e) {
      print('[FavoriteMenuService] fetchPinnedRoutes error: $e');
      return <String>{};
    }
  }

  /// Toggle pin สำหรับ role (POST /admin/roles/pin)
  /// Body ตามตัวอย่าง user ส่ง: `{ "role_id": 6, "favorite": true }`
  /// - คืน true ถ้า server ตอบ 2xx
  static Future<bool> setPin({
    required int roleId,
    required bool favorite,
  }) async {
    final token = await AuthTokenStore.read();
    if (token == null) return false;
    try {
      final response = await http.post(
        Uri.parse(_pinUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'role_id': roleId, 'favorite': favorite}),
      );
      final ok = response.statusCode == 200 || response.statusCode == 201;
      if (!ok) {
        print(
            '[FavoriteMenuService] setPin status=${response.statusCode} body=${response.body}');
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
    final ok = await setPin(roleId: roleId, favorite: nowPinned);
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