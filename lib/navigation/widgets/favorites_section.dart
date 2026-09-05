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

class FavoritesSection extends StatefulWidget {
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

  @override
  State<FavoritesSection> createState() => _FavoritesSectionState();
}

class _FavoritesSectionState extends State<FavoritesSection> {
  /// เกินกี่รายการถึงหุบได้
  static const int _collapseAfter = 2;

  bool _expanded = false;

  /// รวม leaf items (ทั้ง top-level item และ group children) แล้ว filter:
  /// - route ต้องอยู่ใน pinnedRoutes
  /// - permission (ถ้ามี) ต้องอยู่ใน allowedPermissions
  List<_FavoriteEntry> _buildEntries(
    NavigationMenuModel menu,
    Set<String> pinnedRoutes,
    Set<String> allowedPermissions,
  ) {
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
    final entries = _buildEntries(
      widget.menu,
      widget.pinnedRoutes,
      widget.allowedPermissions,
    );
    if (entries.isEmpty) return const SizedBox.shrink();

    final collapsible = entries.length > _collapseAfter;
    final visible =
        collapsible && !_expanded ? entries.take(_collapseAfter) : entries;

    return Material(
      type: MaterialType.transparency,
      child: Container(
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
          // header label — เกิน 2 รายการ → กดหุบ/กางได้
          InkWell(
            onTap: collapsible
                ? () => setState(() => _expanded = !_expanded)
                : null,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 2, 4, 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.push_pin_rounded,
                    size: 14,
                    color: Color(0xFF1E40AF),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'เมนูโปรด',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E40AF),
                      decoration: TextDecoration.none,
                      decorationThickness: 0,
                      letterSpacing: 0.4,
                      height: 1.2,
                    ),
                  ),
                  if (collapsible) ...[
                    const SizedBox(width: 4),
                    Text(
                      '${entries.length}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E40AF).withValues(alpha: .7),
                        decoration: TextDecoration.none,
                        decorationThickness: 0,
                        height: 1.2,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (collapsible)
                    AnimatedRotation(
                      turns: _expanded ? 0 : -.5,
                      duration: const Duration(milliseconds: 180),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: Color(0xFF1E40AF),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // rows — ตอนหุบโชว์แค่ _collapseAfter ตัวแรก
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final entry in visible)
                  _FavoriteRow(
                    entry: entry,
                    isActive: widget.activeRoute == entry.route,
                    onTap: () => widget.onTapRoute(entry.route),
                    onRemove: () => widget.onRemoveRoute(entry.route),
                  ),
              ],
            ),
          ),
        ],
      ),
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
                    Icons.push_pin_rounded,
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