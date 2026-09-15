// ============================================================================
// menu_access_service.dart
// ============================================================================
// Service กลางสำหรับสิทธิ์เมนู — รวมการอ่าน /admin/roles/tree ไว้ที่เดียว
//
// ปัญหาที่แก้:
//   เดิมมี 3 ที่ยิง GET /admin/roles/tree แยกกันเอง:
//     - AuthService.fetchRolesTree()          (ตอน poller + ตอน login)
//     - FavoriteMenuService.fetchPinnedRoutes()   (ตอน rail/drawer initState)
//     - FavoriteMenuService.fetchRouteRoleIds()   (ตอน rail/drawer initState)
//   → ตอน login ยิง 4 รอบทั้งที่ payload ก้อนเดียวกัน
//
// วิธีแก้:
//   1) อ่านจาก AuthRolesTreeStore (cache ที่ AuthService เขียนไว้) ก่อน
//      ไม่มีค่อยยิงเน็ต — ปกติแล้วจะมี เพราะ login/tryAutoLogin เขียนให้แล้ว
//   2) in-flight dedupe — ถ้ากำลังโหลดอยู่ คืน Future เดิม ไม่ยิงซ้อน
//      (rail กับ drawer เรียกพร้อมกันตอน breakpoint เปลี่ยน ก็ยิงครั้งเดียว)
//   3) parse ครั้งเดียว ได้ครบ pinnedRoutes + routeRoleIds + primaryRoleId
//   4) cache ผูกกับ "เนื้อหา JSON" — login ใหม่เขียน tree ใหม่ → parse ใหม่เอง
//      (ไม่ต้องให้ AuthService เรียก invalidate() → เลี่ยง circular import)
//      เนื้อหาเดิม → คืนผลที่ parse ไว้เลย ไม่เดิน tree ซ้ำ
// ============================================================================

import 'dart:convert';

import '../../ChiangMai_Municipality/List_CMM/Register_CMM/AuthService.dart';
import '../../ChiangMai_Municipality/unity/auth_token_store.dart';
import '../models/navigation_menu_model.dart';
import 'navigation_menu_service.dart';

/// ผลลัพธ์จากการ parse roles/tree ครั้งเดียว
class MenuAccess {
  /// route ที่ user ปักพิน (favorite == true ใน tree)
  final Set<String> pinnedRoutes;

  /// route → role_id (ใช้ตอน POST /admin/roles/pin)
  final Map<String, int> routeRoleIds;

  /// role_id แรกที่ assigned == true (fallback ตอน pin)
  final int? primaryRoleId;

  const MenuAccess({
    required this.pinnedRoutes,
    required this.routeRoleIds,
    required this.primaryRoleId,
  });

  static const MenuAccess empty = MenuAccess(
    pinnedRoutes: {},
    routeRoleIds: {},
    primaryRoleId: null,
  );
}

class MenuAccessService {
  /// JSON ต้นทางที่ parse ไปแล้ว — เทียบเพื่อรู้ว่า tree เปลี่ยนหรือยัง
  static String? _srcJson;

  /// ผลที่ parse แล้ว
  static MenuAccess? _parsed;

  /// กันยิงซ้อน — ถ้ากำลังโหลดอยู่ คืน Future เดิม
  static Future<MenuAccess>? _inflight;

  /// อ่านสิทธิ์เมนูทั้งหมด (pinned + role ids)
  ///
  /// เรียกซ้ำได้บ่อยเท่าที่ต้องการ — จะยิงเน็ตก็ต่อเมื่อ cache ไม่มีจริงๆ
  static Future<MenuAccess> load() {
    final running = _inflight;
    if (running != null) return running;

    final future = _run();
    _inflight = future;
    future.whenComplete(() {
      // เคลียร์เฉพาะถ้ายังเป็น future ตัวนี้อยู่ (กัน race กับรอบใหม่)
      if (identical(_inflight, future)) _inflight = null;
    });
    return future;
  }

  static Future<MenuAccess> _run() async {
    final json = await _readTreeJson();
    if (json == null || json.isEmpty) {
      _srcJson = null;
      _parsed = null;
      return MenuAccess.empty;
    }

    // tree เนื้อหาเดิม → คืนผลที่ parse ไว้เลย ไม่ต้องเดินใหม่
    final cached = _parsed;
    if (cached != null && _srcJson == json) return cached;

    final menu = await NavigationMenuService.load();
    final access = parseTree(json, menu);

    _srcJson = json;
    _parsed = access;
    return access;
  }

  /// อ่าน tree JSON — cache ก่อน แล้วค่อยเน็ต
  static Future<String?> _readTreeJson() async {
    final cached = await AuthRolesTreeStore.read();
    if (cached != null && cached.isNotEmpty) return cached;

    // ไม่มี cache → ยิงเน็ตครั้งเดียว (AuthService จะ save cache ให้เอง)
    await AuthService.fetchRolesTree();
    return AuthRolesTreeStore.read();
  }
}

/// เดิน roles/tree ครั้งเดียว → เก็บทุกอย่างที่ต้องใช้ในคราวเดียว
///
/// แยกเป็น top-level function (pure) เพื่อให้เทสง่าย และไม่ผูกกับ state ของ service
MenuAccess parseTree(String treeJson, NavigationMenuModel menu) {
  final List<dynamic> data;
  try {
    final decoded = jsonDecode(treeJson);
    if (decoded is! List) return MenuAccess.empty;
    data = decoded;
  } catch (_) {
    return MenuAccess.empty;
  }

  // ── 1) เดิน tree: เก็บ code→role_id, favorite codes ──
  final codeToId = <String, int>{};
  final favoriteCodes = <String>{};
  int? primaryRoleId;

  void walk(List<dynamic> list) {
    for (final raw in list) {
      if (raw is! Map) continue;

      final code = raw['code']?.toString() ?? '';
      final id = raw['role_id'] ?? raw['id'];
      final idInt = id is int ? id : int.tryParse('$id');

      if (code.isNotEmpty && idInt != null) codeToId[code] = idInt;
      if (code.isNotEmpty && raw['favorite'] == true) favoriteCodes.add(code);
      if (raw['assigned'] == true) primaryRoleId ??= idInt;

      final kids = raw['children'];
      if (kids is List && kids.isNotEmpty) walk(kids);
    }
  }

  walk(data);

  // ── 2) จับคู่กับเมนู: route → role_id และ route ที่ปักพิน ──
  final routeRoleIds = <String, int>{};
  final pinnedRoutes = <String>{};

  int? roleIdOf(String? permission) =>
      permission == null ? null : codeToId[permission];

  bool isFavorite(String? permission) =>
      permission != null && favoriteCodes.contains(permission);

  for (final item in menu.items) {
    final parentRoleId = roleIdOf(item.permission);
    final parentFavorite = isFavorite(item.permission);
    final parentRoute = item.route;

    // เมนูบนสุด (ไม่ใช่กลุ่ม) — ใช้ role_id + favorite ของตัวเอง
    if (!item.isGroup) {
      if (parentRoute != null && parentRoute.isNotEmpty) {
        if (parentRoleId != null) routeRoleIds[parentRoute] = parentRoleId;
        if (parentFavorite) pinnedRoutes.add(parentRoute);
      }
    }

    // sub-menu — แต่ละตัวมี permission ของตัวเองได้ (ไม่ระบุ = สืบทอดจากกลุ่ม)
    for (final child in item.children) {
      if (child.route.isEmpty) continue;

      final childRoleId = roleIdOf(child.permission) ?? parentRoleId;
      if (childRoleId != null) routeRoleIds[child.route] = childRoleId;

      // กลุ่มถูกปักพิน → ปักทุก sub-route; หรือ sub-menu ถูกปักพินเอง
      if (parentFavorite || isFavorite(child.permission)) {
        pinnedRoutes.add(child.route);
      }
    }
  }

  return MenuAccess(
    pinnedRoutes: pinnedRoutes,
    routeRoleIds: routeRoleIds,
    primaryRoleId: primaryRoleId,
  );
}
