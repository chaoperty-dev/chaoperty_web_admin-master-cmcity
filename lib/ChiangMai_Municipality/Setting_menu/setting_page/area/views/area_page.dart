// ============================================================================
// area_page.dart
// ============================================================================
// Main View — "ตั้งค่าพื้นที่เช่า"
// 3 แท็บ:
//   1. จัดการหมวดพื้นที่ (group)
//   2. จัดการโซน (zone)
//   3. จัดการพื้นที่ (area/lock)
//
// ✅ ปุ่ม "จัดการ [entity] ▼" — รวม เพิ่ม/แก้ไข/ลบ เป็นปุ่มเดียว (popup menu)
// ✅ header ปุ่ม disable ตาม selection logic
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/area_area_model.dart';
import '../models/area_config.dart';
import '../models/area_event.dart';
import '../models/area_zone_model.dart';
import '../services/area_service.dart';
import '../viewmodels/area_view_model.dart';
import 'area_form_page.dart';
import 'area_group_form_page.dart';
import 'area_zone_form_page.dart';
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

  /// Factory สร้าง Page พร้อม Provider
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

class _AreaPageBody extends StatefulWidget {
  const _AreaPageBody();

  @override
  State<_AreaPageBody> createState() => _AreaPageBodyState();
}

class _AreaPageBodyState extends State<_AreaPageBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  StreamSubscription<AreaEvent>? _sub;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

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

  // ─── Navigate: Area (lock) ───
  Future<void> _openAddAreaPage({AreaAreaModel? area}) async {
    final vm = context.read<AreaViewModel>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AreaFormPage.create(
          viewModel: vm,
          mode: area == null ? AreaFormMode.create : AreaFormMode.edit,
          initial: area,
        ),
      ),
    );
  }

  Future<void> _confirmDeleteArea(AreaAreaModel area) async {
    final vm = context.read<AreaViewModel>();
    final label = area.lncode.isNotEmpty ? area.lncode : area.ln;
    final ok = await _confirmDanger(
      title: 'ยืนยันการลบพื้นที่',
      body: 'ต้องการลบ "$label" หรือไม่?',
      confirmLabel: 'ลบพื้นที่',
    );
    if (ok == true) {
      await vm.deleteArea(area);
    }
  }

  // ─── Navigate: Group ───
  Future<void> _openAddGroupPage() async {
    final vm = context.read<AreaViewModel>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AreaGroupFormPage.create(viewModel: vm),
      ),
    );
  }

  Future<void> _openEditGroupPage({AreaZoneModel? group}) async {
    final vm = context.read<AreaViewModel>();
    final g = group ?? vm.selectedGroup;
    if (g == null || g.ser.isEmpty || g.ser == '0') {
      _showSnack('กรุณาเลือกหมวดก่อน', AeaColors.statusRejectedFg);
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AreaGroupFormPage.create(viewModel: vm, initial: g),
      ),
    );
  }

  Future<void> _confirmDeleteGroup({AreaZoneModel? group}) async {
    final vm = context.read<AreaViewModel>();
    final g = group ?? vm.selectedGroup;
    if (g == null || g.ser.isEmpty || g.ser == '0') {
      _showSnack('กรุณาเลือกหมวดก่อน', AeaColors.statusRejectedFg);
      return;
    }
    final ok = await _confirmDanger(
      title: 'ยืนยันการลบหมวด',
      body: 'ต้องการลบหมวด "${g.zn}" หรือไม่?',
      confirmLabel: 'ลบหมวด',
    );
    if (ok == true) {
      await vm.deleteGroup(ser: g.ser, name: g.zn);
    }
  }

  // ─── Navigate: Zone ───
  Future<void> _openAddZonePage() async {
    final vm = context.read<AreaViewModel>();
    final gs = vm.selectedGroupSer;
    if (gs == null || gs == '0') {
      _showSnack('กรุณาเลือกหมวดก่อน', AeaColors.statusRejectedFg);
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AreaZoneFormPage.create(
          viewModel: vm,
          groupSer: gs,
          groupName: vm.selectedGroupName,
        ),
      ),
    );
  }

  Future<void> _openEditZonePage({AreaZoneModel? zone}) async {
    final vm = context.read<AreaViewModel>();
    final z = zone ?? vm.selectedZone;
    if (z == null || z.ser.isEmpty) {
      _showSnack('กรุณาเลือกโซนก่อน', AeaColors.statusRejectedFg);
      return;
    }
    final gs = vm.selectedGroupSer ?? '';
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AreaZoneFormPage.create(
          viewModel: vm,
          groupSer: gs,
          groupName: vm.selectedGroupName,
          initial: z,
        ),
      ),
    );
  }

  Future<void> _confirmDeleteZone({AreaZoneModel? zone}) async {
    final vm = context.read<AreaViewModel>();
    final z = zone ?? vm.selectedZone;
    if (z == null || z.ser.isEmpty) {
      _showSnack('กรุณาเลือกโซนก่อน', AeaColors.statusRejectedFg);
      return;
    }
    final ok = await _confirmDanger(
      title: 'ยืนยันการลบโซน',
      body: 'ต้องการลบโซน "${z.zn}" หรือไม่?',
      confirmLabel: 'ลบโซน',
    );
    if (ok == true) {
      await vm.deleteZone(ser: z.ser, name: z.zn);
    }
  }

  // ─── Confirm dialog (custom Danger style) ────────────────────────────
  Future<bool?> _confirmDanger({
    required String title,
    required String body,
    required String confirmLabel,
    String cancelLabel = 'ยกเลิก',
  }) {
    return showDialog<bool>(
      context: context,
      // ✅ ใช้ dialogCtx แทน outer context — showDialog default ใช้ rootNavigator
      // ถ้าใช้ context ของ area_page มันจะ pop area_page (เด้งไป setting hub) ไม่ใช่ dialog
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: AeaColors.surface,
            borderRadius: BorderRadius.circular(AeaRadius.lg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .14),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header: gradient red + icon badge ──
              Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AeaColors.statusRejectedFg, Color(0xFFC62828)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AeaRadius.lg),
                    topRight: Radius.circular(AeaRadius.lg),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(AeaRadius.md),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: .30),
                        ),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AeaSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: AeaText.fontBold,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'การดำเนินการนี้ไม่สามารถยกเลิกได้',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .85),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // ── Body ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 14),
                child: Text(
                  body,
                  style: AeaText.body.copyWith(fontSize: 14, height: 1.5),
                ),
              ),
              // ── Actions ──
              Container(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: _DangerBtn(
                        label: cancelLabel,
                        icon: Icons.close_rounded,
                        primary: false,
                        onTap: () => Navigator.of(dialogCtx).pop(false),
                      ),
                    ),
                    const SizedBox(width: AeaSpace.sm),
                    Expanded(
                      child: _DangerBtn(
                        label: confirmLabel,
                        icon: Icons.delete_sweep_outlined,
                        primary: true,
                        onTap: () => Navigator.of(dialogCtx).pop(true),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AreaViewModel>();

    return Container(
      color: AeaColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AeaSpace.lg, AeaSpace.lg, AeaSpace.lg, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AreaHeader(
                  title: vm.title,
                  subtitle: 'จัดการหมวด โซน และรายการพื้นที่เช่า',
                  totalCount: vm.areaCount,
                  onBack: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                const SizedBox(height: AeaSpace.md),
                _TabBarHeader(controller: _tab),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AeaSpace.lg, AeaSpace.md, AeaSpace.lg, AeaSpace.lg),
              child: TabBarView(
                controller: _tab,
                children: [
                  _AreaTab(
                    onAdd: () => _openAddAreaPage(),
                    onEdit: (a) => _openAddAreaPage(area: a),
                    onDelete: _confirmDeleteArea,
                  ),
                  _GroupTab(
                    onAdd: _openAddGroupPage,
                    onEdit: (g) => _openEditGroupPage(group: g),
                    onDelete: (g) => _confirmDeleteGroup(group: g),
                  ),
                  _ZoneTab(
                    onAdd: _openAddZonePage,
                    onEdit: (z) => _openEditZonePage(zone: z),
                    onDelete: (z) => _confirmDeleteZone(zone: z),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TabBar (3 tabs header)
// ============================================================================
class _TabBarHeader extends StatelessWidget {
  final TabController controller;
  const _TabBarHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AeaRadius.md),
        border: Border.all(color: AeaColors.border),
      ),
      child: TabBar(
        controller: controller,
        labelColor: AeaColors.primaryDark,
        unselectedLabelColor: AeaColors.textSecondary,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(AeaRadius.md),
          color: AeaColors.primary.withValues(alpha: .12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontFamily: AeaText.fontBold,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: AeaText.fontRegular,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.map_outlined, size: 20),
            text: 'พื้นที่เช่า',
            iconMargin: EdgeInsets.only(bottom: 6),
          ),
          Tab(
            icon: Icon(Icons.layers_outlined, size: 20),
            text: 'หมวดพื้นที่',
            iconMargin: EdgeInsets.only(bottom: 6),
          ),
          Tab(
            icon: Icon(Icons.place_outlined, size: 20),
            text: 'โซน',
            iconMargin: EdgeInsets.only(bottom: 6),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Manage button — popup menu (เพิ่ม/แก้ไข/ลบ) รวมเป็นปุ่มเดียว
// ============================================================================
class _ManageMenu extends StatefulWidget {
  final String label;
  final bool canEdit;
  final bool canDelete;
  final VoidCallback onAdd;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ManageMenu({
    required this.label,
    required this.canEdit,
    required this.canDelete,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_ManageMenu> createState() => _ManageMenuState();
}

class _ManageMenuState extends State<_ManageMenu> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: PopupMenuButton<String>(
        tooltip: widget.label,
        offset: const Offset(0, 40),
        onSelected: (v) {
          if (v == 'add') widget.onAdd();
          if (v == 'edit') widget.onEdit();
          if (v == 'delete') widget.onDelete();
        },
        itemBuilder: (_) => [
          const PopupMenuItem(
            value: 'add',
            child: Row(children: [
              Icon(Icons.add_rounded, size: 16, color: AeaColors.primary),
              SizedBox(width: 8),
              Text('เพิ่มใหม่', style: TextStyle(fontSize: 13)),
            ]),
          ),
          PopupMenuItem(
            value: 'edit',
            enabled: widget.canEdit,
            child: Row(children: [
              Icon(Icons.edit_outlined,
                  size: 16,
                  color:
                      widget.canEdit ? AeaColors.primary : AeaColors.textMuted),
              const SizedBox(width: 8),
              Text('แก้ไข',
                  style: TextStyle(
                      fontSize: 13,
                      color: widget.canEdit
                          ? AeaColors.textPrimary
                          : AeaColors.textMuted)),
            ]),
          ),
          PopupMenuItem(
            value: 'delete',
            enabled: widget.canDelete,
            child: Row(children: [
              Icon(Icons.delete_outline_rounded,
                  size: 16,
                  color: widget.canDelete
                      ? AeaColors.statusRejectedFg
                      : AeaColors.textMuted),
              const SizedBox(width: 8),
              Text('ลบ',
                  style: TextStyle(
                      fontSize: 13,
                      color: widget.canDelete
                          ? AeaColors.textPrimary
                          : AeaColors.textMuted)),
            ]),
          ),
        ],
        child: AnimatedContainer(
          duration: AeaAnimations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _hover
                  ? [AeaColors.primaryDark, AeaColors.primary]
                  : [AeaColors.primary, AeaColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(AeaRadius.md),
            boxShadow: [
              BoxShadow(
                color: AeaColors.primary.withOpacity(_hover ? .35 : .25),
                blurRadius: _hover ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.tune_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: AeaText.fontBold,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 16, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Common: search bar + view mode toggle row
// ============================================================================
class _Toolbar extends StatelessWidget {
  final AreaViewMode mode;
  final ValueChanged<AreaViewMode> onModeChange;
  const _Toolbar({required this.mode, required this.onModeChange});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(child: AreaSearchBar()),
        const SizedBox(width: AeaSpace.md),
        _ViewModeToggle(mode: mode, onChanged: onModeChange),
        const SizedBox(width: AeaSpace.md),
        const AreaPagination(),
      ],
    );
  }
}

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

// ============================================================================
// Tab 1 — จัดการหมวดพื้นที่
// ============================================================================
class _GroupTab extends StatelessWidget {
  final VoidCallback onAdd;
  final void Function(AreaZoneModel) onEdit;
  final void Function(AreaZoneModel) onDelete;
  const _GroupTab({
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AreaViewModel>();
    final sel = vm.selectedGroup;
    final canEditDelete = sel != null && sel.ser.isNotEmpty && sel.ser != '0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'เลือกหมวดเพื่อจัดการ — เพิ่มได้โดยไม่ต้องเลือก, แก้ไข/ลบต้องเลือกก่อน',
                style: AeaText.caption,
              ),
            ),
            const SizedBox(width: AeaSpace.md),
            _ManageMenu(
              label: 'จัดการหมวด',
              canEdit: canEditDelete,
              canDelete: canEditDelete,
              onAdd: onAdd,
              onEdit: () {
                if (canEditDelete) onEdit(sel);
              },
              onDelete: () {
                if (canEditDelete) onDelete(sel);
              },
            ),
          ],
        ),
        const SizedBox(height: AeaSpace.md),
        Expanded(child: _GroupList(onEdit: onEdit, onDelete: onDelete)),
      ],
    );
  }
}

class _GroupList extends StatelessWidget {
  final void Function(AreaZoneModel)? onEdit;
  final void Function(AreaZoneModel)? onDelete;
  const _GroupList({this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AreaViewModel>();
    final groups = vm.groups;
    if (groups.isEmpty) {
      return Container(
        decoration: AeaDecor.card(),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(40),
        child: const Text('ยังไม่มีหมวด', style: AeaText.bodyMuted),
      );
    }
    return Container(
      decoration: AeaDecor.card(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AeaSpace.md, vertical: AeaSpace.sm),
            decoration: const BoxDecoration(
              color: AeaColors.surfaceMuted,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AeaRadius.lg),
                topRight: Radius.circular(AeaRadius.lg),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text('ชื่อหมวด', style: AeaText.tableHeader),
                ),
                SizedBox(
                  width: 110,
                  child: Text('จำนวนโซน',
                      style: AeaText.tableHeader, textAlign: TextAlign.right),
                ),
                SizedBox(
                  width: 180,
                  child: Text('จัดการ',
                      style: AeaText.tableHeader, textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AeaColors.border),
          Expanded(
            child: ListView.separated(
              itemCount: groups.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                color: AeaColors.border,
              ),
              itemBuilder: (_, i) {
                final g = groups[i];
                final isSel = vm.selectedGroupSer == g.ser;
                final base = i.isEven ? Colors.white : AeaColors.surfaceMuted;
                final hoverBg = AeaColors.primary.withOpacity(.06);
                // ✅ "ทั้งหมด" (ser=0) ห้าม edit/delete inline
                final allowActions = g.ser != '0';
                return AnimatedContainer(
                  duration: AeaAnimations.fast,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AeaSpace.md, vertical: AeaSpace.md),
                  color: isSel ? AeaColors.primaryLight.withOpacity(.4) : base,
                  child: Row(
                    children: [
                      // ✅ selectable text portion (InkWell ครอบเฉพาะส่วนนี้)
                      Expanded(
                        child: InkWell(
                          onTap: () => vm.onGroupChanged(g.ser, g.zn),
                          hoverColor: hoverBg,
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                margin:
                                    const EdgeInsets.only(right: AeaSpace.sm),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? AeaColors.primary
                                      : AeaColors.textMuted,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Text(g.zn.isEmpty ? '-' : g.zn,
                                    style: AeaText.body),
                              ),
                              SizedBox(
                                width: 110,
                                child: Text(
                                  g.qty.isEmpty ? '-' : g.qty,
                                  style: AeaText.bodyMuted.copyWith(
                                    fontFamily: AeaText.fontBold,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // ✅ action pills (อยู่นอก InkWell → คลิกไม่ trigger เลือกแถว)
                      SizedBox(
                        width: 180,
                        child: allowActions
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _RowPillAction(
                                    icon: Icons.edit_outlined,
                                    bg: AeaColors.statusApprovedBg,
                                    fg: AeaColors.statusApprovedFg,
                                    label: 'แก้ไข',
                                    onTap: () => onEdit?.call(g),
                                  ),
                                  const SizedBox(width: 6),
                                  _RowPillAction(
                                    icon: Icons.delete_outline_rounded,
                                    bg: AeaColors.statusInfoBg,
                                    fg: AeaColors.statusInfoFg,
                                    label: 'ลบ',
                                    onTap: () => onDelete?.call(g),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Tab 2 — จัดการโซน
// ============================================================================
class _ZoneTab extends StatelessWidget {
  final VoidCallback onAdd;
  final void Function(AreaZoneModel) onEdit;
  final void Function(AreaZoneModel) onDelete;
  const _ZoneTab({
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AreaViewModel>();
    final zoneSel = vm.selectedZoneSer != null;
    final sel = vm.selectedZone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── group filter dropdown ──
        Container(
          decoration: AeaDecor.card(),
          padding: const EdgeInsets.symmetric(
              horizontal: AeaSpace.md, vertical: AeaSpace.sm),
          child: Row(
            children: [
              const Icon(Icons.filter_list_rounded,
                  size: 18, color: AeaColors.primaryDark),
              const SizedBox(width: AeaSpace.sm),
              const SizedBox(
                width: 110,
                child: Text('หมวด:', style: AeaText.bodyMuted),
              ),
              Expanded(child: _GroupDropdownInline()),
              const SizedBox(width: AeaSpace.md),
              _ManageMenu(
                label: 'จัดการโซน',
                canEdit: zoneSel,
                canDelete: zoneSel,
                onAdd: onAdd,
                onEdit: () {
                  if (zoneSel && sel != null) onEdit(sel);
                },
                onDelete: () {
                  if (zoneSel && sel != null) onDelete(sel);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AeaSpace.md),
        Expanded(child: _ZoneList(onEdit: onEdit, onDelete: onDelete)),
      ],
    );
  }
}

class _GroupDropdownInline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AreaViewModel>();
    final groups = vm.groups;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AeaRadius.sm),
        border: Border.all(color: AeaColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: vm.selectedGroupSer,
          hint: const Text('เลือกหมวด', style: AeaText.body),
          items: groups
              .map((g) => DropdownMenuItem<String>(
                    value: g.ser,
                    child: Text(g.zn, style: AeaText.body),
                  ))
              .toList(),
          onChanged: (v) {
            final name =
                groups.where((g) => g.ser == v).map((g) => g.zn).firstOrNull;
            vm.onGroupChanged(v, name);
          },
        ),
      ),
    );
  }
}

class _ZoneList extends StatelessWidget {
  final void Function(AreaZoneModel)? onEdit;
  final void Function(AreaZoneModel)? onDelete;
  const _ZoneList({this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AreaViewModel>();
    final groupSel = vm.selectedGroupSer != null && vm.selectedGroupSer != '0';
    if (!groupSel) {
      return Container(
        decoration: AeaDecor.card(),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(40),
        child: const Text('กรุณาเลือกหมวดก่อน', style: AeaText.bodyMuted),
      );
    }
    final zones = vm.zones.where((z) => z.ser != '0').toList();
    if (zones.isEmpty) {
      return Container(
        decoration: AeaDecor.card(),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(40),
        child: const Text('หมวดนี้ยังไม่มีโซน', style: AeaText.bodyMuted),
      );
    }
    return Container(
      decoration: AeaDecor.card(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AeaSpace.md, vertical: AeaSpace.sm),
            decoration: const BoxDecoration(
              color: AeaColors.surfaceMuted,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AeaRadius.lg),
                topRight: Radius.circular(AeaRadius.lg),
              ),
            ),
            child: const Row(
              children: [
                Expanded(child: Text('ชื่อโซน', style: AeaText.tableHeader)),
                SizedBox(
                  width: 80,
                  child: Text('จำนวนพื้นที่',
                      style: AeaText.tableHeader, textAlign: TextAlign.right),
                ),
                SizedBox(
                  width: 180,
                  child: Text('จัดการ',
                      style: AeaText.tableHeader, textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AeaColors.border),
          Expanded(
            child: ListView.separated(
              itemCount: zones.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: AeaColors.border),
              itemBuilder: (_, i) {
                final z = zones[i];
                final isSel = vm.selectedZoneSer == z.ser;
                return AnimatedContainer(
                  duration: AeaAnimations.fast,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AeaSpace.md, vertical: AeaSpace.md),
                  color: isSel ? AeaColors.primaryLight.withOpacity(.4) : null,
                  child: Row(
                    children: [
                      // ✅ selectable text portion (InkWell เฉพาะส่วนนี้)
                      Expanded(
                        child: InkWell(
                          onTap: () => vm.onZoneChanged(z.ser, z.zn),
                          hoverColor: AeaColors.primary.withOpacity(.06),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                margin:
                                    const EdgeInsets.only(right: AeaSpace.sm),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? AeaColors.primary
                                      : AeaColors.textMuted,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Text(z.zn.isEmpty ? '-' : z.zn,
                                    style: AeaText.body),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // ✅ จำนวนพื้นที่ (areas_count) — count จาก lock ทั้งหมดในโซนนี้
                      SizedBox(
                        width: 80,
                        child: Text(
                          z.areasCount.toString(),
                          textAlign: TextAlign.right,
                          style: AeaText.bodyMuted.copyWith(
                            fontFamily: AeaText.fontBold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      // ✅ action pills (อยู่นอก InkWell → คลิกไม่ trigger เลือกแถว)
                      SizedBox(
                        width: 180,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _RowPillAction(
                              icon: Icons.edit_outlined,
                              bg: AeaColors.statusApprovedBg,
                              fg: AeaColors.statusApprovedFg,
                              label: 'แก้ไข',
                              onTap: () => onEdit?.call(z),
                            ),
                            const SizedBox(width: 6),
                            _RowPillAction(
                              icon: Icons.delete_outline_rounded,
                              bg: AeaColors.statusInfoBg,
                              fg: AeaColors.statusInfoFg,
                              label: 'ลบ',
                              onTap: () => onDelete?.call(z),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Tab 1 — จัดการพื้นที่
// ============================================================================
class _AreaTab extends StatelessWidget {
  final VoidCallback onAdd;
  final void Function(AreaAreaModel) onEdit;
  final void Function(AreaAreaModel) onDelete;
  const _AreaTab({
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AreaViewModel>();
    final sel = vm.selectedArea;
    final hasSel = sel != null && sel.ser.isNotEmpty;
    // ✅ canDelete เช็ค isOccupied ป้องกันลบพื้นที่ที่มีผู้เช่า
    final canDelete = sel?.isOccupied == false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Row 1: filter card — dropdowns + popup "จัดการพื้นที่ ▼" อยู่ในการ์ดเดียวกัน ──
        AreaZoneFilter(
          trailing: _ManageMenu(
            label: 'จัดการพื้นที่',
            canEdit: hasSel,
            canDelete: canDelete,
            onAdd: onAdd,
            onEdit: () {
              if (sel != null && sel.ser.isNotEmpty) onEdit(sel);
            },
            onDelete: () {
              if (sel != null && !sel.isOccupied) onDelete(sel);
            },
          ),
        ),
        const SizedBox(height: AeaSpace.md),
        // ── Row 2: search + view-mode + pagination ──
        const _ToolbarAreaFilters(),
        const SizedBox(height: AeaSpace.md),
        Expanded(
          child: SingleChildScrollView(
            child: AreaTable(
              onEdit: onEdit,
              onDelete: onDelete,
              onRowTap: (a) => vm.onAreaChanged(a.ser),
            ),
          ),
        ),
      ],
    );
  }
}

class _ToolbarAreaFilters extends StatelessWidget {
  const _ToolbarAreaFilters();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AreaViewModel>();
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AeaSpace.md, vertical: AeaSpace.sm),
      decoration: AeaDecor.card(),
      child: Row(
        children: [
          const Expanded(child: AreaSearchBar()),
          const SizedBox(width: AeaSpace.md),
          _ViewModeToggle(mode: vm.viewMode, onChanged: vm.setViewMode),
          const SizedBox(width: AeaSpace.md),
          const AreaPagination(),
        ],
      ),
    );
  }
}

// ============================================================================
// _RowPillAction — pill-style inline button (shared by _GroupList + _ZoneList)
// ============================================================================
class _RowPillAction extends StatefulWidget {
  final IconData icon;
  final Color bg;
  final Color fg;
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  const _RowPillAction({
    required this.icon,
    required this.bg,
    required this.fg,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  State<_RowPillAction> createState() => _RowPillActionState();
}

class _RowPillActionState extends State<_RowPillAction> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final disabled = !widget.enabled;
    return MouseRegion(
      cursor:
          disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: disabled ? null : (_) => setState(() => _hover = true),
      onExit: disabled ? null : (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: disabled ? null : widget.onTap,
        child: Opacity(
          opacity: disabled ? .45 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: widget.bg,
              borderRadius: BorderRadius.circular(AeaRadius.pill),
              boxShadow: (_hover && !disabled)
                  ? [
                      BoxShadow(
                        color: widget.fg.withValues(alpha: .28),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : const [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 14, color: widget.fg),
                const SizedBox(width: 5),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.fg,
                    fontSize: 12,
                    fontFamily: AeaText.fontBold,
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

class _DangerBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback onTap;
  const _DangerBtn({
    required this.label,
    required this.icon,
    required this.primary,
    required this.onTap,
  });
  @override
  State<_DangerBtn> createState() => _DangerBtnState();
}

class _DangerBtnState extends State<_DangerBtn> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    if (widget.primary) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _hover
                    ? [const Color(0xFFC62828), AeaColors.statusRejectedFg]
                    : [AeaColors.statusRejectedFg, const Color(0xFFC62828)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AeaRadius.md),
              boxShadow: [
                BoxShadow(
                  color: AeaColors.statusRejectedFg
                      .withValues(alpha: _hover ? .45 : .30),
                  blurRadius: _hover ? 14 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, size: 17, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: AeaText.fontBold,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: _hover ? AeaColors.surfaceMuted : Colors.white,
            borderRadius: BorderRadius.circular(AeaRadius.md),
            border: Border.all(
              color: _hover ? AeaColors.textSecondary : AeaColors.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 17,
                color: _hover ? AeaColors.textPrimary : AeaColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color:
                      _hover ? AeaColors.textPrimary : AeaColors.textSecondary,
                  fontFamily: AeaText.fontBold,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Alias
// ============================================================================
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
