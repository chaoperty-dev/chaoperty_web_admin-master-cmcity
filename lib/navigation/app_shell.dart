import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../ChiangMai_Municipality/unity/SecurePrefs_helper.dart';
import '../router/auth_state_notifier.dart';
import 'app_navigation_rail.dart';
import 'models/navigation_menu_model.dart';
import 'services/navigation_menu_service.dart';

/// Layout หลักของแอปหลังล็อกอิน — responsive
/// - Desktop (≥ 1100px): Row(NavigationRail 240px, Content) — โชว์ sidebar ถาวร
/// - Tablet/Mobile (< 1100px): Scaffold(drawer: MobileDrawer, body: Content) — ใช้ hamburger เปิด drawer
///
/// เพิ่ม breakpoint จาก 600 → 1100 เพราะ iPad/iPad mini จะใช้ drawer แทน sidebar ถาวร
/// (sidebar 240px กินพื้นที่เยอะเกินไปบน tablet portrait)
///
/// ✅ ใช้ ShellRoute ธรรมดา (ไม่ใช่ StatefulShellRoute) แล้ว render child ตรง ๆ
/// ทุกครั้งที่สลับเมนู child จะถูกสร้างใหม่ → state ของหน้าก่อนหน้าหายไปทั้งหมด
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const double _kMobileBreakpoint = 1100;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= _kMobileBreakpoint;

        if (isWideScreen) {
          return Row(
            children: [
              const AppNavigationRail(),
              Expanded(
                child: Material(
                  type: MaterialType.transparency,
                  child: child,
                ),
              ),
            ],
          );
        } else {
          return _MobileLayout(child: child);
        }
      },
    );
  }
}

/// Layout สำหรับ Mobile — AppBar + Drawer + Content (wrap Material)
class _MobileLayout extends StatelessWidget {
  final Widget child;

  const _MobileLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Chaoperty',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE5E7EB)),
        ),
      ),
      drawer: const _MobileDrawer(),
      // Wrap content ด้วย Material เพื่อหลีกเลี่ยง error "No Material widget found"
      body: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );
  }
}

/// Drawer สำหรับ Mobile — โหลดเมนูจาก JSON
class _MobileDrawer extends StatefulWidget {
  const _MobileDrawer();

  @override
  State<_MobileDrawer> createState() => _MobileDrawerState();
}

class _MobileDrawerState extends State<_MobileDrawer> {
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

          if (fname.toString().isNotEmpty || lname.toString().isNotEmpty) {
            return '${fname.toString().trim()} ${lname.toString().trim()}'
                .trim();
          }
          if (name.toString().isNotEmpty) return name.toString().trim();
          if (email.toString().isNotEmpty) return email.toString().trim();
        }
      }

      final email =
          await SecurePrefs.getDecrypted(SecurePrefsType.authUserEmail);
      if (email != null && email.isNotEmpty) return email;

      return '';
    } catch (e) {
      return '';
    }
  }

  void _closeAndGo(BuildContext context, String route) {
    Navigator.of(context).pop();
    context.go(route);
  }

  String get _location => GoRouterState.of(context).matchedLocation;

  bool _isRouteActive(String route) => _location == route;

  bool _isGroupActive(NavigationItemModel group) {
    return group.children.any((child) => _isRouteActive(child.route));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<NavigationMenuModel?>(
      future: _menuFuture,
      builder: (context, snapshot) {
        final menu = snapshot.data;

        return Drawer(
          backgroundColor: Colors.white,
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E40AF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          menu?.header.icon ?? Icons.bolt_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        menu?.header.title ?? 'Chaoperty',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── เมนู ───────────────────
                const SizedBox(height: 8),

                if (menu == null)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int i = 0; i < menu.items.length; i++) ...[
                          if (i > 0)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child:
                                  Divider(height: 1, color: Color(0xFFE5E7EB)),
                            ),
                          _buildMenuItem(context, menu.items[i]),
                        ],
                      ],
                    ),
                  ),

                // ── Footer: User + Logout ──
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Divider(height: 1, color: Color(0xFFE5E7EB)),
                      const SizedBox(height: 12),
                      if (_userDisplayName.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.account_circle_outlined,
                                size: 20,
                                color: Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _userDisplayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      _DrawerLogoutButton(
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
    Navigator.of(context).pop(); // ปิด Drawer

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

  Widget _buildMenuItem(BuildContext context, NavigationItemModel item) {
    if (item.isGroup) {
      final groupActive = _isGroupActive(item);
      final expanded = _expandedGroups[item.label] ?? item.expandedByDefault;

      if (groupActive && !expanded) {
        _expandedGroups[item.label] = true;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DrawerMenuItem(
            icon: item.icon ?? Icons.folder_outlined,
            activeIcon: item.activeIcon ?? item.icon ?? Icons.folder,
            label: item.label,
            isActive: groupActive,
            trailing: AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.keyboard_arrow_down,
                  size: 18, color: Color(0xFF6B7280)),
            ),
            onTap: () => setState(() {
              _expandedGroups[item.label] = !expanded;
            }),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(left: 32, top: 2, bottom: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: item.children
                    .map(
                      (child) => _DrawerSubItem(
                        label: child.label,
                        isActive: _isRouteActive(child.route),
                        onTap: () => _closeAndGo(context, child.route),
                      ),
                    )
                    .toList(),
              ),
            ),
            crossFadeState:
                expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      );
    }

    return _DrawerMenuItem(
      icon: item.icon ?? Icons.circle_outlined,
      activeIcon: item.activeIcon ?? item.icon ?? Icons.circle,
      label: item.label,
      isActive: item.route != null && _isRouteActive(item.route!),
      onTap: () {
        if (item.route != null) _closeAndGo(context, item.route!);
      },
    );
  }
}

/// Item เมนูหลักใน Drawer
class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Widget? trailing;

  const _DrawerMenuItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? const Color(0xFFDBEAFE) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: ListTile(
        leading: Icon(
          isActive ? activeIcon : icon,
          color: isActive ? const Color(0xFF1E40AF) : const Color(0xFF6B7280),
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF1E40AF) : const Color(0xFF374151),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

/// Sub-item เมนูใน Drawer (indent)
class _DrawerSubItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerSubItem({
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
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF1E40AF)
                      : const Color(0xFF9CA3AF),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? const Color(0xFF1E40AF)
                      : const Color(0xFF6B7280),
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerLogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _DrawerLogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFEE2E2),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.logout,
                size: 20,
                color: Color(0xFFDC2626),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'ออกจากระบบ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDC2626),
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
