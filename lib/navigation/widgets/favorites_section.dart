// ============================================================================
// favorites_section.dart
// ============================================================================
// "กล่องเมนูโปรด" — render เหนือ regular menu list
// - แสดงเฉพาะ item ที่ user pin (route ตรงกับ pinnedRoutes)
// - แต่ละ row: icon + label + ⭐ ขวา (tap → onRemove)
// - ถ้า list ว่าง → return SizedBox.shrink()
// - permission safety: filter ตาม allowed ก่อน render (กัน permission bypass)
// ============================================================================

import 'package:flutter/material.dart';

import '../models/navigation_menu_model.dart';

/// Item 1 row ในกล่องเมนูโปรด
class _FavoriteEntry {
  final String label;
  final String route;
  final IconData icon;
  const _FavoriteEntry({
    required this.label,
    required this.route,
    required this.icon,
  });
}

class FavoritesSection extends StatelessWidget {
  final NavigationMenuModel menu;
  final Set<String> pinnedRoutes;
  final Set<String> allowedPermissions;
  final void Function(String route) onTapRoute;
  final void Function(String route) onRemoveRoute;
  final String? activeRoute;

  const FavoritesSection({
    super.key,
    required this.menu,
    required this.pinnedRoutes,
    required this.allowedPermissions,
    required this.onTapRoute,
    required this.onRemoveRoute,
    this.activeRoute,
  });

  /// รวม leaf items (ทั้ง top-level item และ group children) แล้ว filter:
  /// - route ต้องอยู่ใน pinnedRoutes
  /// - permission (ถ้ามี) ต้องอยู่ใน allowedPermissions
  List<_FavoriteEntry> _buildEntries() {
    final out = <_FavoriteEntry>[];
    for (final item in menu.items) {
      if (item.isGroup) {
        for (final child in item.children) {
          if (!pinnedRoutes.contains(child.route)) continue;
          // permission: child ถ้ามี → check; ถ้า null → inherit จาก group
          final perm = child.permission ?? item.permission;
          if (perm != null && !allowedPermissions.contains(perm)) continue;
          out.add(_FavoriteEntry(
            label: child.label,
            route: child.route,
            icon: child.icon ?? item.icon ?? Icons.circle_outlined,
          ));
        }
      } else {
        final route = item.route;
        if (route == null) continue;
        if (!pinnedRoutes.contains(route)) continue;
        if (item.permission != null &&
            !allowedPermissions.contains(item.permission)) {
          continue;
        }
        out.add(_FavoriteEntry(
          label: item.label,
          route: route,
          icon: item.icon ?? Icons.circle_outlined,
        ));
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final entries = _buildEntries();
    if (entries.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // header label
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 2, 4, 6),
            child: Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: Color(0xFF1E40AF),
                ),
                const SizedBox(width: 6),
                Text(
                  'เมนูโปรด',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E40AF),
                    decoration: TextDecoration.none,
                    decorationThickness: 0,
                    letterSpacing: 0.4,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          // rows
          for (final entry in entries)
            _FavoriteRow(
              entry: entry,
              isActive: activeRoute == entry.route,
              onTap: () => onTapRoute(entry.route),
              onRemove: () => onRemoveRoute(entry.route),
            ),
        ],
      ),
    );
  }
}

class _FavoriteRow extends StatelessWidget {
  final _FavoriteEntry entry;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteRow({
    required this.entry,
    required this.isActive,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? const Color(0xFFDBEAFE) : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            children: [
              Icon(
                entry.icon,
                size: 16,
                color: const Color(0xFF1E40AF),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.w500,
                    color: const Color(0xFF1E40AF),
                    decoration: TextDecoration.none,
                    decorationThickness: 0,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: Color(0xFF1E40AF),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}