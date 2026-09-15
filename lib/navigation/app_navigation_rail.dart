import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../ChiangMai_Municipality/unity/auth_token_store.dart';
import '../Constant/Myconstant.dart';
import '../router/auth_state_notifier.dart';
import 'models/navigation_menu_model.dart';
import 'services/favorite_menu_service.dart';
import 'services/menu_access_service.dart';
import 'services/navigation_menu_service.dart';
import 'widgets/favorites_section.dart';

/// Custom NavigationRail ด้านซ้าย — responsive + โหลดเมนูจาก JSON
/// - Desktop (≥ 1100px): แสดง sidebar 240px (persistent)
/// - Tablet/Mobile (< 1100px): ไม่แสดง (ให้ AppShell จัดการ Drawer + hamburger)
class AppNavigationRail extends StatefulWidget {
  const AppNavigationRail({super.key});

  @override
  State<AppNavigationRail> createState() => _AppNavigationRailState();
}

class _AppNavigationRailState extends State<AppNavigationRail> {
  static const _kDesktopBreakpoint = 1100;
  static const double _kWidth = 240;

  // สีตามภาพตัวอย่าง
  // ✅ theme: เรียบหรูเทา + navy (สีหลักระบบ) เฉพาะตำแหน่ง active
  static const Color _primary = Color(0xFF1E40AF);
  static const Color _activeBg = Color(0xFFEFF6FF);
  static const Color _activeFg = Color(0xFF1E40AF);
  static const Color _pinMuted = Color(0xFFD1D5DB);
  static const Color _border = Color(0xFFE5E7EB);

  bool get _isWideScreen =>
      MediaQuery.sizeOf(context).width >= _kDesktopBreakpoint;

  String get _location => GoRouterState.of(context).matchedLocation;

  Future<NavigationMenuModel?>? _menuFuture;
  final Map<String, bool> _expandedGroups = {};
  String _userDisplayName = '';
  String _userEmail = '';

  /// สถานะลายเซ็นของ user ปัจจุบัน — null = กำลังโหลด, true = มี, false = ยังไม่มี
  bool? _hasSignature;

  /// การ์ดบัญชีด้านล่าง — กางเพื่อโชว์ปุ่มออกจากระบบ
  bool _accountExpanded = false;

  // ⭐ favorites state
  Set<String> _pinnedRoutes = <String>{};
  Set<String> _allowedPermissions = <String>{};
  int? _currentRoleId;
  Map<String, int> _routeRoleIds = <String, int>{};

  @override
  void initState() {
    super.initState();
    _menuFuture = _loadMenu();
    _loadUserName();
    _loadSignatureStatus();
  }

  /// ✍️ GET /admin/know → เช็คว่า user ปัจจุบันมีลายเซ็นหรือยัง
  /// - มี signature_uuid → _hasSignature = true (โชว์ ✓)
  /// - ไม่มี → false (โชว์ ⚠️ warning)
  Future<void> _loadSignatureStatus() async {
    try {
      final headers = await MyHeaders.build();
      final url = Uri.parse('${MyConstant().domain_v1}/admin/know');
      final response = await http.get(url, headers: headers);
      if (response.statusCode != 200) {
        if (mounted) setState(() => _hasSignature = false);
        return;
      }
      final jsonRes = jsonDecode(response.body);
      final data = jsonRes is Map ? jsonRes['data'] : null;
      String? uuid;
      if (data is Map) {
        uuid = data['signature_uuid']?.toString();
        if (uuid == null || uuid.isEmpty) {
          final sigs = data['signatures'];
          if (sigs is List && sigs.isNotEmpty) {
            final first = sigs.first;
            if (first is Map) uuid = first['uuid']?.toString();
          }
        }
      }
      if (!mounted) return;
      setState(
          () => _hasSignature = (uuid != null && uuid.isNotEmpty));
    } catch (_) {
      if (mounted) setState(() => _hasSignature = false);
    }
  }

  Future<NavigationMenuModel?> _loadMenu() async {
    final menu = await NavigationMenuService.loadFiltered();
    if (!mounted) return menu;
    // allowed permissions = union ของ permission ใน items + children
    final perms = <String>{};
    for (final it in menu.items) {
      if (it.permission != null) perms.add(it.permission!);
      for (final c in it.children) {
        if (c.permission != null) perms.add(c.permission!);
      }
    }
    setState(() => _allowedPermissions = perms);
    // โหลด favorites หลังเมนูพร้อม (ต้องการ allowed perms)
    _loadFavorites();
    return menu;
  }

  Future<void> _loadFavorites() async {
    // 1) cache ก่อน → render ได้ทันที
    final cached = await FavoriteMenuService.readCachedRoutes();
    if (!mounted) return;
    setState(() => _pinnedRoutes = cached);

    // 2) โหลดสิทธิ์เมนูทั้งหมดในคราวเดียว
    //    - pinnedRoutes + routeRoleIds + primaryRoleId มาจาก tree ก้อนเดียวกัน
    //    - service อ่าน cache (AuthRolesTreeStore) ก่อน → ปกติไม่ยิงเน็ตเลย
    final access = await MenuAccessService.load();
    if (!mounted) return;
    setState(() {
      if (access.pinnedRoutes.isNotEmpty || cached.isEmpty) {
        _pinnedRoutes = access.pinnedRoutes;
      }
      _routeRoleIds = access.routeRoleIds;
      _currentRoleId = access.primaryRoleId;
    });
  }

  Future<void> _loadUserName() async {
    var name = '';
    var email = '';
    try {
      final userJson = await AuthUserStore.read();
      if (userJson != null && userJson.isNotEmpty) {
        final user = jsonDecode(userJson) as Map<String, dynamic>?;
        if (user != null) {
          final profile =
              (user['profile'] as Map?)?.cast<String, dynamic>() ?? const {};
          final fname = user['fname'] ??
              user['first_name'] ??
              profile['full_name'] ??
              '';
          final lname = user['lname'] ?? user['last_name'] ?? '';
          final name_ = user['name'] ?? '';
          email = user['email']?.toString() ?? '';

          if (fname.toString().isNotEmpty || lname.toString().isNotEmpty) {
            name =
                '${fname.toString().trim()} ${lname.toString().trim()}'.trim();
          } else if (name_.toString().isNotEmpty) {
            name = name_.toString().trim();
          }
        }
      }
      if (email.isEmpty) {
        email = (await AuthEmailStore.read()) ?? '';
      }
      // fallback: ไม่มีชื่อ → ใช้ email แทน
      if (name.isEmpty && email.isNotEmpty) name = email;
    } catch (_) {}

    if (mounted) {
      setState(() {
        _userDisplayName = name;
        _userEmail = email;
      });
    }
  }

  void _go(String route) => context.go(route);

  /// อักษรย่อสำหรับอวาตาร — เอาตัวแรกของคำแรก + คำสุดท้าย (สูงสุด 2 ตัว)
  String _avatarInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'))..removeWhere((e) => e.isEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  bool _isRouteActive(String route) => _location == route;

  bool _isGroupActive(NavigationItemModel group) {
    return group.children.any((child) => _isRouteActive(child.route));
  }

  /// สร้าง TextStyle ที่ force ไม่มี underline (แก้เส้นใต้สีเหลืองบน Flutter web)
  static TextStyle _noUnderlineTextStyle({
    required double fontSize,
    FontWeight? fontWeight,
    required Color color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      decoration: TextDecoration.none,
      decorationThickness: 0,
      height: 1.2,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isWideScreen) return const SizedBox.shrink();

    return FutureBuilder<NavigationMenuModel?>(
      future: _menuFuture,
      builder: (context, snapshot) {
        final menu = snapshot.data;
        if (menu == null) {
          return Container(
            width: _kWidth,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: _border, width: 1)),
            ),
            child: const SafeArea(
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          );
        }

        // sub-menu เริ่มหุบ — ไม่ auto-expand เมื่อ active

        return Container(
          width: _kWidth,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(right: BorderSide(color: _border, width: 1)),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          menu.header.icon ?? Icons.bolt_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        menu.header.title,
                        style: _noUnderlineTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── ⭐ Favorites box (คงที่ — ไม่ scroll ตามเมนู) ──
                FavoritesSection(
                  menu: menu,
                  pinnedRoutes: _pinnedRoutes,
                  allowedPermissions: _allowedPermissions,
                  activeRoute: _location,
                  onTapRoute: _go,
                  onRemoveRoute: _togglePin,
                ),

                // ── Menu list ──
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      for (int i = 0; i < menu.items.length; i++) ...[
                        if (i > 0) const SizedBox(height: 4),
                        _buildMenuItem(menu.items[i]),
                      ],
                    ],
                  ),
                ),

                // ── Footer: การ์ดบัญชี — กดกางเพื่อเห็นออกจากระบบ ──
                // ✍️ ยังไม่มีลายเซ็น → การ์ดออกโทนเหลืองเตือน
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _hasSignature == false
                        ? const Color(0xFFFFFBEB) // amber-50
                        : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _hasSignature == false
                          ? const Color(0xFFFDE68A) // amber-200
                          : _border,
                    ),
                  ),
                  child: Material(
                    // ✅ InkWell ต้องมี Material ancestor
                    type: MaterialType.transparency,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── แถวบัญชี (กดกาง/หุบ) ──
                        InkWell(
                        onTap: () => setState(
                            () => _accountExpanded = !_accountExpanded),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
                          child: Row(
                            children: [
                              // อวาตารอักษรย่อ + badge ลายเซ็นมุมล่างขวา
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: const Color(0xFF1E40AF),
                                    child: Text(
                                      _avatarInitials(_userDisplayName),
                                      style: _noUnderlineTextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  // ✍️ verified badge เกาะมุมอวาตาร
                                  if (_hasSignature != null)
                                    Positioned(
                                      right: -2,
                                      bottom: -2,
                                      child: Tooltip(
                                        message: _hasSignature!
                                            ? 'มีลายเซ็นในระบบแล้ว'
                                            : 'ยังไม่มีลายเซ็น — ไปที่ จัดการข้อมูลส่วนตัว เพื่อเพิ่ม',
                                        child: Container(
                                          padding: const EdgeInsets.all(1),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            _hasSignature!
                                                ? Icons.verified
                                                : Icons.warning_amber_rounded,
                                            size: 13,
                                            color: _hasSignature!
                                                ? const Color(0xFF16A34A)
                                                : const Color(0xFFB45309),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _userDisplayName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: _noUnderlineTextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF111827),
                                      ),
                                    ),
                                    if (_userEmail.isNotEmpty)
                                      Text(
                                        _userEmail,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: _noUnderlineTextStyle(
                                          fontSize: 11,
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 2),
                              AnimatedRotation(
                                turns: _accountExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 180),
                                child: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // ── เมนูกาง: ออกจากระบบ ──
                      AnimatedCrossFade(
                        firstChild: const SizedBox(width: double.infinity),
                        secondChild: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Divider(height: 1, color: _border),
                            const SizedBox(height: 4),
                            _LogoutButton(
                              onTap: () => _handleLogout(context),
                            ),
                          ],
                        ),
                        crossFadeState: _accountExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 180),
                      ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ออกจากระบบ'),
        content: const Text('คุณต้องการออกจากระบบหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('ออกจากระบบ',
                style: TextStyle(color: Color(0xFFDC2626))),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthStateNotifier>().signOut();
    }
  }

  /// ⭐ toggle pin สำหรับ route (optimistic + sync)
  /// role_id เอาจาก map ของเมนูนั้นก่อน — ไม่มีค่อย fallback เป็น role แรก
  Future<void> _togglePin(String route) async {
    final roleId = _routeRoleIds[route] ?? _currentRoleId;
    if (roleId == null) {
      // ไม่มี role id → toggle cache เฉยๆ (fallback)
      final current = {..._pinnedRoutes};
      if (current.contains(route)) {
        current.remove(route);
      } else {
        current.add(route);
      }
      setState(() => _pinnedRoutes = current);
      return;
    }
    final next = await FavoriteMenuService.toggleRoute(route, roleId: roleId);
    if (!mounted) return;
    setState(() {
      if (next) {
        _pinnedRoutes.add(route);
      } else {
        _pinnedRoutes.remove(route);
      }
    });
  }

  Widget _buildMenuItem(NavigationItemModel item) {
    if (item.isGroup) {
      final expanded = _expandedGroups[item.label] ?? item.expandedByDefault;
      final groupActive = _isGroupActive(item);

      return _MenuGroup(
        icon: item.icon ?? Icons.folder_outlined,
        activeIcon: item.activeIcon ?? item.icon ?? Icons.folder,
        label: item.label,
        isActive: groupActive,
        expanded: expanded,
        onToggle: () => setState(() {
          _expandedGroups[item.label] = !expanded;
        }),
        children: item.children
            .map(
              (child) => _SubMenuItem(
                label: child.label,
                isActive: _isRouteActive(child.route),
                onTap: () => _go(child.route),
                route: child.route,
                isPinned: _pinnedRoutes.contains(child.route),
                onTogglePin: () => _togglePin(child.route),
              ),
            )
            .toList(),
      );
    }

    final route = item.route;
    return _MenuItem(
      icon: item.icon ?? Icons.circle_outlined,
      activeIcon: item.activeIcon ?? item.icon ?? Icons.circle,
      label: item.label,
      isActive: route != null && _isRouteActive(route),
      onTap: () {
        if (route != null) _go(route);
      },
      route: route,
      isPinned: route != null && _pinnedRoutes.contains(route),
      onTogglePin: route == null ? null : () => _togglePin(route),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Widgets ช่วย
// ═══════════════════════════════════════════════════════════════════════

class _MenuItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final String? route;
  final bool isPinned;
  final VoidCallback? onTogglePin;

  const _MenuItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.route,
    this.isPinned = false,
    this.onTogglePin,
  });

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final showStar = _hover || widget.isPinned;
    final fg = widget.isActive
        ? _AppNavigationRailState._activeFg
        : const Color(0xFF6B7280);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Stack(
        children: [
          Material(
        color: widget.isActive
            ? _AppNavigationRailState._activeBg
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  widget.isActive ? widget.activeIcon : widget.icon,
                  size: 20,
                  color: fg,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    style: _AppNavigationRailState._noUnderlineTextStyle(
                      fontSize: 14,
                      fontWeight:
                          widget.isActive ? FontWeight.w600 : FontWeight.w500,
                      color: fg,
                    ),
                  ),
                ),
                if (widget.onTogglePin != null)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 120),
                    opacity: showStar ? 1.0 : 0.0,
                    child: InkWell(
                      onTap: widget.onTogglePin,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          widget.isPinned
                              ? Icons.push_pin_rounded
                              : Icons.push_pin_outlined,
                          size: 16,
                          // ✅ UX: pin ที่ปักไว้ = เทาอ่อน — hover ถึงเข้ม
                          color: widget.isPinned && !_hover
                              ? _AppNavigationRailState._pinMuted
                              : _AppNavigationRailState._activeFg,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
          ),
          // ✅ UX: leading indicator — แถบ navy ซ้าย ชี้ตาตำแหน่งปัจจุบัน
          if (widget.isActive)
            Positioned(
              left: 0,
              top: 8,
              bottom: 8,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  color: _AppNavigationRailState._activeFg,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> children;

  const _MenuGroup({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.expanded,
    required this.onToggle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // หัวกลุ่ม
        Material(
          color: isActive
              ? _AppNavigationRailState._activeBg
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    isActive ? activeIcon : icon,
                    size: 20,
                    color: isActive
                        ? _AppNavigationRailState._activeFg
                        : const Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: _AppNavigationRailState._noUnderlineTextStyle(
                        fontSize: 14,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w500,
                        color: isActive
                            ? _AppNavigationRailState._activeFg
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: isActive
                          ? _AppNavigationRailState._activeFg
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // sub-menu (animated expand/collapse)
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(left: 12, top: 2, bottom: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
          crossFadeState:
              expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

class _SubMenuItem extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final String route;
  final bool isPinned;
  final VoidCallback onTogglePin;

  const _SubMenuItem({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.route,
    this.isPinned = false,
    required this.onTogglePin,
  });

  @override
  State<_SubMenuItem> createState() => _SubMenuItemState();
}

class _SubMenuItemState extends State<_SubMenuItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final showStar = _hover || widget.isPinned;
    final fg = widget.isActive
        ? _AppNavigationRailState._activeFg
        : const Color(0xFF6B7280);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Stack(
        children: [
          Material(
        color: widget.isActive
            ? _AppNavigationRailState._activeBg
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // bullet
                Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.only(left: 6, right: 14),
                  decoration: BoxDecoration(
                    color: widget.isActive
                        ? _AppNavigationRailState._activeFg
                        : const Color(0xFF9CA3AF),
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.label,
                    style: _AppNavigationRailState._noUnderlineTextStyle(
                      fontSize: 13,
                      fontWeight:
                          widget.isActive ? FontWeight.w600 : FontWeight.w400,
                      color: fg,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 120),
                  opacity: showStar ? 1.0 : 0.0,
                  child: InkWell(
                    onTap: widget.onTogglePin,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        widget.isPinned
                            ? Icons.push_pin_rounded
                            : Icons.push_pin_outlined,
                        size: 14,
                        // ✅ UX: pin ที่ปักไว้ = เทาอ่อน — hover ถึงเข้ม
                        color: widget.isPinned && !_hover
                            ? _AppNavigationRailState._pinMuted
                            : _AppNavigationRailState._activeFg,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
          ),
          // ✅ UX: leading indicator ของ sub-item
          if (widget.isActive)
            Positioned(
              left: 0,
              top: 6,
              bottom: 6,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  color: _AppNavigationRailState._activeFg,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatefulWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    // ✅ UX: ปกติ = เทาเรียบ ไม่แย่งสายตา (logout เป็น action ถี่น้อย)
    //    hover ค่อยเป็นแดง — แจ้งความเสี่ยงตอนกำลังจะกด
    final fg = _hover ? const Color(0xFFDC2626) : const Color(0xFF4B5563);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        color: _hover ? const Color(0xFFFEF2F2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  Icons.logout,
                  size: 18,
                  color: fg,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'ออกจากระบบ',
                    style: _AppNavigationRailState._noUnderlineTextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
