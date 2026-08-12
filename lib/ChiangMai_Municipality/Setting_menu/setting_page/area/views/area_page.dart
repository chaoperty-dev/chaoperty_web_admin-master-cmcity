// ============================================================================
// area_page.dart
// ============================================================================
// Main View — "จัดการ Area" (หน้าใหม่ใน setting_page)
// สไตล์ license_payment — header + zone filter + search + pagination + table
//
// ใช้งานได้ 2 รูปแบบ:
//   ✅ AreaPage.create(...) — สร้าง + wrap Provider ให้อัตโนมัติ
//   ✅ AreaHost(...)       — alias
//
// IMPORTANT: ห้าม new AreaPage() ตรงๆ เพราะ child widgets
// จะเรียก context.watch<AreaViewModel>() ซึ่งต้องการ Provider
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/area_area_model.dart';
import '../models/area_config.dart';
import '../models/area_event.dart';
import '../services/area_service.dart';
import '../viewmodels/area_view_model.dart';
import 'area_form_page.dart';
import 'area_zone_page.dart';
import 'theme/area_theme.dart';
import 'widgets/area_header.dart';
import 'widgets/area_pagination.dart';
import 'widgets/area_search_bar.dart';
import 'widgets/area_table.dart';
import 'widgets/area_zone_filter.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// Public API
/// ═══════════════════════════════════════════════════════════════════════
class AreaPage extends StatefulWidget {
  const AreaPage._({super.key});

  /// Factory สร้าง Page พร้อม Provider (ใช้ใน setting_page)
  static Widget create({
    Key? key,
    String? routeData,
    String title = 'ตั้งค่าพื้นที่เช่า',
    AreaConfig? config,
  }) {
    final cfg = config ?? AreaConfig(title: title, routeData: routeData);
    return ChangeNotifierProvider<AreaViewModel>(
      create: (_) => AreaViewModel(
        config: cfg,
        service: AreaService(),
      ),
      child: const _AreaPageBody(),
    );
  }

  @override
  State<AreaPage> createState() => _AreaPageState();
}

class _AreaPageState extends State<AreaPage> {
  @override
  Widget build(BuildContext context) {
    return AreaPage.create();
  }
}

/// Body จริง — ต้องอยู่ใต้ Provider เสมอ
class _AreaPageBody extends StatefulWidget {
  const _AreaPageBody();

  @override
  State<_AreaPageBody> createState() => _AreaPageBodyState();
}

class _AreaPageBodyState extends State<_AreaPageBody> {
  StreamSubscription<AreaEvent>? _sub;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<AreaViewModel>();
    _sub ??= vm.events.listen(_onEvent);
  }

  void _onEvent(AreaEvent event) {
    if (!mounted) return;
    switch (event) {
      case AreaErrorEvent(:final message):
        _showSnack(message, AeaColors.statusRejectedFg);
        break;
      case AreaSuccessEvent(:final message):
        _showSnack(message, AeaColors.primary);
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
          borderRadius: BorderRadius.circular(AeaRadius.md),
        ),
      ),
    );
  }

  // ─── Navigate to full-page route ───
  Future<void> _openAddAreaPage({AreaAreaModel? area}) async {
    final vm = context.read<AreaViewModel>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AreaFormPage.create(
          viewModel: vm,
          mode: area == null ? AreaFormMode.create : AreaFormMode.edit,
          initial: area,
          preselectedZoneSer: vm.selectedZoneSer,
        ),
      ),
    );
  }

  Future<void> _openAddZonePage() async {
    final vm = context.read<AreaViewModel>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AreaZonePage.create(viewModel: vm),
      ),
    );
  }

  Future<void> _confirmDeleteZone(String? zoneSer) async {
    final vm = context.read<AreaViewModel>();
    if (zoneSer == null || zoneSer == '0') {
      _showSnack('กรุณาเลือกโซนก่อน', AeaColors.statusRejectedFg);
      return;
    }
    final zoneName = vm.selectedZoneName ?? '';
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ยืนยันการลบโซน'),
        content: Text('ต้องการลบโซน "$zoneName" หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('ยืนยัน'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await vm.deleteZone(zoneSer: zoneSer, zoneName: zoneName);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AreaViewModel>();
    final canDeleteZone =
        vm.selectedZoneSer != null && vm.selectedZoneSer != '0';

    return Container(
      color: AeaColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Top section — มี padding ซ้าย/ขวา (AeaSpace.lg) ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AeaSpace.lg, AeaSpace.lg, AeaSpace.lg, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AreaHeader(
                  title: vm.title,
                  subtitle: 'จัดการโซน และรายการ พื้นที่เช่า',
                  totalCount: vm.areaCount,
                  actionLabel: 'สร้างพื้นที่เช่า',
                  actionIcon: Icons.add_rounded,
                  onAction: () => _openAddAreaPage(),
                  onBack: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                const SizedBox(height: AeaSpace.lg),
                AreaZoneFilter(
                  onAddZone: _openAddZonePage,
                  onDeleteZone: canDeleteZone ? _confirmDeleteZone : (s) {},
                ),
                const SizedBox(height: AeaSpace.md),
                // Search + View toggle + Pagination row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(child: AreaSearchBar()),
                    const SizedBox(width: AeaSpace.md),
                    _ViewModeToggle(
                      mode: vm.viewMode,
                      onChanged: vm.setViewMode,
                    ),
                    const SizedBox(width: AeaSpace.md),
                    const AreaPagination(),
                  ],
                ),
                const SizedBox(height: AeaSpace.lg),
              ],
            ),
          ),
          // ── Table — มี padding ซ้าย/ขวา (AeaSpace.lg) ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AeaSpace.lg),
              child: SingleChildScrollView(
                child: AreaTable(
                  onEdit: (area) => _openAddAreaPage(area: area),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Alias สำหรับเข้ากับ API ทั่วไป
class AreaHost extends StatelessWidget {
  final String? routeData;
  final String title;

  const AreaHost({
    super.key,
    this.routeData,
    this.title = 'จัดการ Area',
  });

  @override
  Widget build(BuildContext context) {
    return AreaPage.create(routeData: routeData, title: title);
  }
}

// ============================================================================
// View-mode toggle (table / card)
// ============================================================================
class _ViewModeToggle extends StatelessWidget {
  final AreaViewMode mode;
  final ValueChanged<AreaViewMode> onChanged;
  const _ViewModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AeaColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AeaRadius.pill),
        border: Border.all(color: AeaColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleBtn(
            icon: Icons.grid_view_rounded,
            label: 'การ์ด',
            active: mode == AreaViewMode.card,
            onTap: () => onChanged(AreaViewMode.card),
          ),
          _ToggleBtn(
            icon: Icons.table_rows_rounded,
            label: 'ตาราง',
            active: mode == AreaViewMode.table,
            onTap: () => onChanged(AreaViewMode.table),
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ToggleBtn({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  State<_ToggleBtn> createState() => _ToggleBtnState();
}

class _ToggleBtnState extends State<_ToggleBtn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AeaAnimations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.active
                ? Colors.white
                : (_hover ? Colors.white.withOpacity(.6) : Colors.transparent),
            borderRadius: BorderRadius.circular(AeaRadius.pill),
            boxShadow: widget.active
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 14,
                color:
                    widget.active ? AeaColors.primary : AeaColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: AeaText.fontBold,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: widget.active
                      ? AeaColors.primary
                      : AeaColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
