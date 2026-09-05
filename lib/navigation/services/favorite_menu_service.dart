// ============================================================================
// favorite_menu_service.dart
// ============================================================================
// Service — pin/favorite เมนู navigation ของ user
//
// Backend:
// - GET  {domain_v2}/admin/roles/tree   → roles tree (รวม assigned menus)
//     node ไหน "favorite": true = เมนูที่ user ปักพิน (ทั้ง top-level และ children)
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
import 'navigation_menu_service.dart';

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

  /// GET /admin/roles/tree → routes ที่ user ปักพิน (favorite == true)
  /// - เดิน tree ทุก node (top-level + children) เก็บ code ของ node ที่ favorite
  /// - แปลง code → route ผ่าน navigation_menu.json (permission == code)
  /// - group ที่ถูกปักพิน → รวม route ของ children ทั้งกลุ่ม
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

      final favCodes = _collectFavoriteCodes(data);
      if (favCodes.isEmpty) return <String>{};
      final pinned = await _codesToRoutes(favCodes);
      if (pinned.isNotEmpty) await _writeCache(pinned);
      return pinned;
    } catch (e) {
      print('[FavoriteMenuService] fetchPinnedRoutes error: $e');
      return <String>{};
    }
  }

  /// GET /admin/roles/tree → Map<route, role_id> ไว้ใช้ toggle pin
  /// - tree: code → role_id (recursive ทุก node)
  /// - menu asset: route → permission code
  /// - รวมเป็น route → role_id เพื่อ POST /admin/roles/pin ให้ถูก role
  static Future<Map<String, int>> fetchRouteRoleIds() async {
    final token = await AuthTokenStore.read();
    if (token == null) return <String, int>{};
    try {
      final headers = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final response =
          await http.get(Uri.parse(_rolesTreeUrl), headers: headers);
      if (response.statusCode != 200) return <String, int>{};
      final jsonRes = jsonDecode(response.body);
      final data = jsonRes is Map ? jsonRes['data'] : null;
      if (data is! List) return <String, int>{};

      // 1) tree: code → role_id
      final codeToId = <String, int>{};
      void walk(List list) {
        for (final raw in list) {
          if (raw is! Map) continue;
          final code = raw['code']?.toString() ?? '';
          final id = raw['role_id'] ?? raw['id'];
          final idInt = id is int ? id : int.tryParse('$id');
          if (code.isNotEmpty && idInt != null) codeToId[code] = idInt;
          final kids = raw['children'];
          if (kids is List && kids.isNotEmpty) walk(kids);
        }
      }

      walk(data);
      if (codeToId.isEmpty) return <String, int>{};

      // 2) menu asset: route → permission code → role_id
      final menu = await NavigationMenuService.load();
      final routeToId = <String, int>{};
      for (final item in menu.items) {
        final itemId = item.permission == null ? null : codeToId[item.permission];
        if (itemId != null && item.route != null && item.route!.isNotEmpty) {
          routeToId[item.route!] = itemId;
        }
        for (final c in item.children) {
          final cid = c.permission == null ? null : codeToId[c.permission];
          if (cid != null && c.route.isNotEmpty) routeToId[c.route] = cid;
        }
      }
      return routeToId;
    } catch (e) {
      print('[FavoriteMenuService] fetchRouteRoleIds error: $e');
      return <String, int>{};
    }
  }

  /// เดิน tree แบบ recursive — รวม code ของทุก node ที่ favorite == true
  static Set<String> _collectFavoriteCodes(List nodes) {
    final codes = <String>{};
    void walk(List list) {
      for (final raw in list) {
        if (raw is! Map) continue;
        if (raw['favorite'] == true) {
          final code = raw['code']?.toString() ?? '';
          if (code.isNotEmpty) codes.add(code);
        }
        final kids = raw['children'];
        if (kids is List && kids.isNotEmpty) walk(kids);
      }
    }

    walk(nodes);
    return codes;
  }

  /// แปลง favorite codes → routes จากเมนู asset (permission == code)
  static Future<Set<String>> _codesToRoutes(Set<String> codes) async {
    final menu = await NavigationMenuService.load();
    final routes = <String>{};
    for (final item in menu.items) {
      if (item.permission != null && codes.contains(item.permission)) {
        if (item.isGroup) {
          // group ถูกปักพิน → pin ทุก route ในกลุ่ม
          for (final c in item.children) {
            if (c.route.isNotEmpty) routes.add(c.route);
          }
        } else if (item.route != null && item.route!.isNotEmpty) {
          routes.add(item.route!);
        }
      }
      for (final c in item.children) {
        if (c.permission != null &&
            codes.contains(c.permission) &&
            c.route.isNotEmpty) {
          routes.add(c.route);
        }
      }
    }
    return routes;
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