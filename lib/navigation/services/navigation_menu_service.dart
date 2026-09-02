import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../ChiangMai_Municipality/List_CMM/Register_CMM/AuthService.dart';
import '../models/navigation_menu_model.dart';

/// Service โหลดเมนู navigation จาก assets/menu/navigation_menu.json
class NavigationMenuService {
  static const String _assetPath = 'assets/menu/navigation_menu.json';

  static NavigationMenuModel? _cached;

  /// โหลดเมนูจาก JSON (cache ครั้งแรก)
  static Future<NavigationMenuModel> load() async {
    if (_cached != null) return _cached!;

    final raw = await rootBundle.loadString(_assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _cached = NavigationMenuModel.fromJson(json);
    return _cached!;
  }

  /// โหลดเมนูแล้วกรองตามสิทธิ์ (assigned codes จาก /admin/roles/tree)
  /// - item: แสดงเฉพาะเมื่อ permission ว่าง หรืออยู่ในสิทธิ์
  /// - group: กรองทั้งกลุ่ม + กรองซับเมนูเป็นรายตัว
  ///   (ซับเมนูที่ไม่ระบุ permission จะสืบทอดจากกลุ่มแม่)
  /// - กลุ่มที่กรองแล้วไม่เหลือซับเมนู → ซ่อนทั้งกลุ่ม
  /// - ไม่มีสิทธิ์เลย → เมนูว่าง (secure default)
  static Future<NavigationMenuModel> loadFiltered() async {
    final menu = await load();
    final allowed = (await AuthService.getMenuPermissions()).toSet();

    if (allowed.isEmpty) {
      debugPrint('[Menu] no permissions — menu hidden');
      return NavigationMenuModel(header: menu.header, items: const []);
    }

    debugPrint('[Menu] allowed(${allowed.length}) = ${allowed.join(',')}');
    final items = <NavigationItemModel>[];
    for (final item in menu.items) {
      // เมนูบนสุด: ไม่ผ่านสิทธิ์ → ซ่อนทั้งอัน (รวมทุกซับเมนูข้างใน)
      if (item.permission != null && !allowed.contains(item.permission)) {
        debugPrint('[Menu] HIDE "${item.label}" — perm="${item.permission}" '
            'ไม่อยู่ใน allowed');
        continue;
      }
      debugPrint('[Menu] show "${item.label}" (perm=${item.permission})');
      if (item.isGroup) {
        final kids = item.children
            .where((c) =>
                c.permission == null ||
                allowed.contains(c.permission))
            .toList();
        if (kids.isEmpty) continue; // กลุ่มไม่เหลือซับเมนู → ซ่อน
        items.add(item.copyWithChildren(kids));
      } else {
        items.add(item);
      }
    }
    debugPrint('[Menu] ${items.length}/${menu.items.length} items shown '
        '(perms: ${allowed.join(',')})');
    return NavigationMenuModel(header: menu.header, items: items);
  }

  /// รีเซ็ต cache (ใช้เมื่อต้องการ reload)
  static void clearCache() => _cached = null;
}
