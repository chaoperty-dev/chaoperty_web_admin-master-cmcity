// ============================================================================
// access_rights_page.dart
// ============================================================================
// Main View — "สิทธิ์การเข้าถึง" (หน้าใหม่ใน setting_page)
//
// ใช้งานได้ 2 รูปแบบ (เหมือน LicenseRequestPage):
//   ✅ AccessRightsPage.create(...) — สร้าง + wrap Provider ให้อัตโนมัติ
//   ✅ AccessRightsHost(...)       — alias
//
// IMPORTANT: ห้าม new AccessRightsPage() ตรงๆ เพราะ child widgets
// จะเรียก context.watch<AccessRightsViewModel>() ซึ่งต้องการ Provider
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/access_rights_config.dart';
import '../models/access_rights_event.dart';
import '../services/access_rights_service.dart';
import '../viewmodels/access_rights_view_model.dart';
import 'theme/access_rights_theme.dart';
import 'widgets/access_rights_header.dart';
import 'widgets/access_rights_pagination.dart';
import 'widgets/access_rights_search_bar.dart';
import 'widgets/access_rights_table.dart';
import 'widgets/access_rights_user_dialog.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// Public API
/// ═══════════════════════════════════════════════════════════════════════
class AccessRightsPage extends StatefulWidget {
  const AccessRightsPage._();

  /// Factory สร้าง Page พร้อม Provider (ใช้ใน setting_page)
  static Widget create({
    String? routeData,
    String title = 'สิทธิ์การเข้าถึง',
    AccessRightsConfig? config,
  }) {
    final cfg = config ?? AccessRightsConfig(title: title, routeData: routeData);
    return ChangeNotifierProvider<AccessRightsViewModel>(
      create: (_) => AccessRightsViewModel(
        config: cfg,
        service: AccessRightsService(),
      ),
      child: const _AccessRightsPageBody(),
    );
  }

  @override
  State<AccessRightsPage> createState() => _AccessRightsPageState();
}

class _AccessRightsPageState extends State<AccessRightsPage> {
  @override
  Widget build(BuildContext context) {
    return AccessRightsPage.create();
  }
}

/// Body จริง — ต้องอยู่ใต้ Provider เสมอ
class _AccessRightsPageBody extends StatefulWidget {
  const _AccessRightsPageBody();

  @override
  State<_AccessRightsPageBody> createState() => _AccessRightsPageBodyState();
}

class _AccessRightsPageBodyState extends State<_AccessRightsPageBody> {
  StreamSubscription<AccessRightsEvent>? _sub;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<AccessRightsViewModel>();
    _sub ??= vm.events.listen(_onEvent);
  }

  void _onEvent(AccessRightsEvent event) {
    if (!mounted) return;
    switch (event) {
      case AccessRightsErrorEvent(:final message):
        _showSnack(message, ArColors.statusRejectedFg);
        break;
      case AccessRightsSuccessEvent(:final message):
        _showSnack(message, ArColors.primary);
        break;
      case AccessRightsOpenCreateEvent():
        _openCreateDialog();
        break;
      case AccessRightsOpenEditEvent(:final userUuid):
        _openEditDialog(userUuid);
        break;
      case AccessRightsOpenSignatureEvent(:final userUuid):
        _openSignatureDialog(userUuid);
        break;
    }
  }

  void _showSnack(String message, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ArRadius.md),
        ),
      ),
    );
  }

  Future<void> _openCreateDialog() async {
    final vm = context.read<AccessRightsViewModel>();
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          AccessRightsUserDialog(mode: ArUserDialogMode.create, viewModel: vm),
    );
  }

  Future<void> _openEditDialog(String userUuid) async {
    final vm = context.read<AccessRightsViewModel>();
    final user = await vm.reloadUser(userUuid);
    if (user == null || !mounted) return;
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AccessRightsUserDialog(
        mode: ArUserDialogMode.edit,
        initial: user,
        viewModel: vm,
      ),
    );
  }

  Future<void> _openSignatureDialog(String userUuid) async {
    final vm = context.read<AccessRightsViewModel>();
    final user = await vm.reloadUser(userUuid);
    if (user == null || !mounted) return;
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AccessRightsSignatureDialog(user: user, viewModel: vm),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AccessRightsViewModel>();
    // ✅ ต้องมี Scaffold — ScaffoldMessenger.showSnackBar assert ว่ามี descendant Scaffold
    return Scaffold(
      backgroundColor: ArColors.surface,
      body: Padding(
        padding: const EdgeInsets.all(ArSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AccessRightsHeader(
              title: vm.title,
              subtitle: 'จัดการผู้ใช้งาน ตำแหน่ง และสิทธิ์การเข้าถึงระบบ',
              totalCount: vm.total,
              onBack: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              onCreate: vm.onCreate,
            ),
            const SizedBox(height: ArSpace.lg),
            const _AccessRightsToolbar(),
            const SizedBox(height: ArSpace.lg),
            const Expanded(
              child: SingleChildScrollView(
                child: AccessRightsTable(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccessRightsToolbar extends StatelessWidget {
  const _AccessRightsToolbar();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AccessRightsViewModel>();
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < kAccessRightsMobileBreakpoint;
        final compact = constraints.maxWidth < 720;
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AccessRightsSearchBar(),
              const SizedBox(height: ArSpace.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!mobile) ...[
                    _AccessRightsViewModeToggle(
                      mode: vm.viewMode,
                      onChanged: vm.setViewMode,
                    ),
                    const Spacer(),
                  ],
                  const AccessRightsPagination(),
                ],
              ),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(child: AccessRightsSearchBar()),
            const SizedBox(width: ArSpace.md),
            _AccessRightsViewModeToggle(
              mode: vm.viewMode,
              onChanged: vm.setViewMode,
            ),
            const SizedBox(width: ArSpace.md),
            const AccessRightsPagination(),
          ],
        );
      },
    );
  }
}

class _AccessRightsViewModeToggle extends StatelessWidget {
  final AccessRightsViewMode mode;
  final ValueChanged<AccessRightsViewMode> onChanged;

  const _AccessRightsViewModeToggle({
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: ArColors.surfaceMuted,
        borderRadius: BorderRadius.circular(ArRadius.pill),
        border: Border.all(color: ArColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ViewModeButton(
            icon: Icons.grid_view_rounded,
            label: 'การ์ด',
            active: mode == AccessRightsViewMode.card,
            onTap: () => onChanged(AccessRightsViewMode.card),
          ),
          _ViewModeButton(
            icon: Icons.table_rows_rounded,
            label: 'ตาราง',
            active: mode == AccessRightsViewMode.table,
            onTap: () => onChanged(AccessRightsViewMode.table),
          ),
        ],
      ),
    );
  }
}

class _ViewModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ViewModeButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? ArColors.primaryDark : ArColors.textSecondary;
    return Material(
      color: active ? ArColors.cardBg : Colors.transparent,
      borderRadius: BorderRadius.circular(ArRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ArRadius.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontFamily: ArText.fontBold,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Alias สำหรับเข้ากันได้กับ API ทั่วไป
class AccessRightsHost extends StatelessWidget {
  final String? routeData;
  final String title;

  const AccessRightsHost({
    super.key,
    this.routeData,
    this.title = 'สิทธิ์การเข้าถึง',
  });

  @override
  Widget build(BuildContext context) {
    return AccessRightsPage.create(routeData: routeData, title: title);
  }
}
