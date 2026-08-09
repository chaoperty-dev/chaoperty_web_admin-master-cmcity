import 'dart:convert';

import 'package:flutter/services.dart';

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

  /// รีเซ็ต cache (ใช้เมื่อต้องการ reload)
  static void clearCache() => _cached = null;
}
