import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../ChiangMai_Municipality/unity/SecurePrefs_helper.dart';
import '../router/auth_state_notifier.dart';
import 'models/navigation_menu_model.dart';
import 'services/navigation_menu_service.dart';

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
  static const Color _primary = Color(0xFF1E40AF);
  static const Color _border = Color(0xFFE5E7EB);

  bool get _isWideScreen =>
      MediaQuery.sizeOf(context).width >= _kDesktopBreakpoint;

  String get _location => GoRouterState.of(context).matchedLocation;

  Future<NavigationMenuModel?>? _menuFuture;
  final Map<String, bool> _expandedGroups = {};
  String _userDisplayName = '';

  @override
  void initState() {
    super.initState();
    _menuFuture = NavigationMenuService.load();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final name = await _getUserDisplayName();
    if (mounted) {
      setState(() => _userDisplayName = name);
    }
  }

  Future<String> _getUserDisplayName() async {
    try {
      final userJson =
          await SecurePrefs.getDecrypted(SecurePrefsType.authUserObject);
      if (userJson != null && userJson.isNotEmpty) {
        final user = jsonDecode(userJson) as Map<String, dynamic>?;
        if (user != null) {
          final fname = user['fname'] ?? user['first_name'] ?? '';
          final lname = user['lname'] ?? user['last_name'] ?? '';
          final name = user['name'] ?? '';
          final email = user['email'] ?? '';

          String raw = '';
          if (fname.toString().isNotEmpty || lname.toString().isNotEmpty) {
            raw =
                '${fname.toString().trim()} ${lname.toString().trim()}'.trim();
          } else if (name.toString().isNotEmpty) {
            raw = name.toString().trim();
          } else if (email.toString().isNotEmpty) {
            raw = email.toString().trim();
          }

          return _maskName(raw);
        }
      }

      final email =
          await SecurePrefs.getDecrypted(SecurePrefsType.authUserEmail);
      if (email != null && email.isNotEmpty) return _maskName(email);

      return '';
    } catch (e) {
      return '';
    }
  }

  /// ปิดชื่อบางส่วนด้วย ****
  /// - ถ้ามีช่องว่าง: แสดงคำแรกเต็มที่ + คำที่เหลือเป็น ****
  /// - ถ้าไม่มีช่องว่าง: แสดงครึ่งแรก + ****
  String _maskName(String raw) {
    if (raw.isEmpty) return raw;
    final parts = raw.split(RegExp(r'\s+'))..removeWhere((e) => e.isEmpty);
    if (parts.length > 1) {
      return '${parts.first} ****';
    }
    final half = (raw.length / 2).ceil();
    return '${raw.substring(0, half)}****';
  }

  void _go(String route) => context.go(route);

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

        // ขยายกลุ่มอัตโนมัติเมื่อมี child ถูกเลือก
        for (final item in menu.items.where((i) => i.isGroup)) {
          if (_isGroupActive(item)) {
            _expandedGroups[item.label] = true;
          }
        }

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

                // ── Footer: User + Logout ──
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_userDisplayName.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDBEAFE),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.person_outline,
                                  size: 18,
                                  color: Color(0xFF1E40AF),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ผู้ใช้งาน',
                                      style: _noUnderlineTextStyle(
                                        fontSize: 11,
                                        color: const Color(0xFF9CA3AF),
                                      ),
                                    ),
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
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      _LogoutButton(
                        onTap: () => _handleLogout(context),
                      ),
                    ],
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
              ),
            )
            .toList(),
      );
    }

    return _MenuItem(
      icon: item.icon ?? Icons.circle_outlined,
      activeIcon: item.activeIcon ?? item.icon ?? Icons.circle,
      label: item.label,
      isActive: item.route != null && _isRouteActive(item.route!),
      onTap: () {
        if (item.route != null) _go(item.route!);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Widgets ช่วย
// ═══════════════════════════════════════════════════════════════════════

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? const Color(0xFFDBEAFE) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: 20,
                color: isActive
                    ? const Color(0xFF1E40AF)
                    : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: _AppNavigationRailState._noUnderlineTextStyle(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? const Color(0xFF1E40AF)
                        : const Color(0xFF6B7280),
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
          color: isActive ? const Color(0xFFDBEAFE) : Colors.transparent,
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
                        ? const Color(0xFF1E40AF)
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
                            ? const Color(0xFF1E40AF)
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
                          ? const Color(0xFF1E40AF)
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

class _SubMenuItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SubMenuItem({
    required this.label,
    required this.isActive,
    required this.onTap,
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // bullet
              Container(
                width: 5,
                height: 5,
                margin: const EdgeInsets.only(left: 6, right: 14),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF1E40AF)
                      : const Color(0xFF9CA3AF),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  label,
                  style: _AppNavigationRailState._noUnderlineTextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive
                        ? const Color(0xFF1E40AF)
                        : const Color(0xFF6B7280),
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

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFEE2E2),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const Icon(
                Icons.logout,
                size: 18,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'ออกจากระบบ',
                  style: _AppNavigationRailState._noUnderlineTextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFDC2626),
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
