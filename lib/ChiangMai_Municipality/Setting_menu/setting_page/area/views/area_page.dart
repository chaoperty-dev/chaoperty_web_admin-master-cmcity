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
    final ok = await _confirm('ยืนยันการลบพื้นที่', 'ต้องการลบ "$label" หรือไม่?');
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

  Future<void> _openEditGroupPage() async {
    final vm = context.read<AreaViewModel>();
    final g = vm.selectedGroup;
    if (g == null || g.ser.isEmpty || g.ser == '0') {
      _showSnack('กรุณาเลือกหมวดก่อน', AeaColors.statusRejectedFg);
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) =>
            AreaGroupFormPage.create(viewModel: vm, initial: g),
      ),
    );
  }

  Future<void> _confirmDeleteGroup() async {
    final vm = context.read<AreaViewModel>();
    final g = vm.selectedGroup;
    if (g == null || g.ser.isEmpty || g.ser == '0') {
      _showSnack('กรุณาเลือกหมวดก่อน', AeaColors.statusRejectedFg);
      return;
    }
    final ok = await _confirm('ยืนยันการลบหมวด', 'ต้องการลบหมวด "${g.zn}" หรือไม่?');
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

  Future<void> _openEditZonePage() async {
    final vm = context.read<AreaViewModel>();
    final z = vm.selectedZone;
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

  Future<void> _confirmDeleteZone() async {
    final vm = context.read<AreaViewModel>();
    final z = vm.selectedZone;
    if (z == null || z.ser.isEmpty) {
      _showSnack('กรุณาเลือกโซนก่อน', AeaColors.statusRejectedFg);
      return;
    }
    final ok = await _confirm('ยืนยันการลบโซน', 'ต้องการลบโซน "${z.zn}" หรือไม่?');
    if (ok == true) {
      await vm.deleteZone(ser: z.ser, name: z.zn);
    }
  }

  // ─── Confirm dialog helper ───
  Future<bool?> _confirm(String title, String body) async {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body),
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
                  _GroupTab(
                    onAdd: _openAddGroupPage,
                    onEdit: _openEditGroupPage,
                    onDelete: _confirmDeleteGroup,
                  ),
                  _ZoneTab(
                    onAdd: _openAddZonePage,
                    onEdit: _openEditZonePage,
                    onDelete: _confirmDeleteZone,
                  ),
                  _AreaTab(
                    onAdd: () => _openAddAreaPage(),
                    onEdit: (a) => _openAddAreaPage(area: a),
                    onDelete: _confirmDeleteArea,
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
      decoration: AeaDecor.card(),
      child: TabBar(
        controller: controller,
        labelColor: AeaColors.primary,
        unselectedLabelColor: AeaColors.textSecondary,
        indicator: UnderlineTabIndicator(
          borderSide:
              const BorderSide(color: AeaColors.primary, width: 2.5),
          insets: const EdgeInsets.symmetric(horizontal: 24),
        ),
        labelStyle: AeaText.body.copyWith(
          fontFamily: AeaText.fontBold,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        unselectedLabelStyle: AeaText.body.copyWith(fontSize: 13),
        tabs: const [
          Tab(icon: Icon(Icons.layers_outlined, size: 16), text: 'หมวดพื้นที่'),
          Tab(icon: Icon(Icons.place_outlined, size: 16), text: 'โซน'),
          Tab(icon: Icon(Icons.map_outlined, size: 16), text: 'พื้นที่เช่า'),
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
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _GroupTab({
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AreaViewModel>();
    final sel = vm.selectedGroup;
    final canEditDelete =
        sel != null && sel.ser.isNotEmpty && sel.ser != '0';

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
              onEdit: onEdit,
              onDelete: onDelete,
            ),
          ],
        ),
        const SizedBox(height: AeaSpace.md),
        Expanded(child: _GroupList()),
      ],
    );
  }
}

class _GroupList extends StatelessWidget {
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
            padding:
                const EdgeInsets.symmetric(horizontal: AeaSpace.md, vertical: AeaSpace.sm),
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
                  child: Text('ชื่อหมวด',
                      style: AeaText.tableHeader),
                ),
                SizedBox(
                  width: 110,
                  child: Text('จำนวนโซน',
                      style: AeaText.tableHeader, textAlign: TextAlign.right),
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
                return InkWell(
                  onTap: () {
                    vm.onGroupChanged(g.ser, g.zn);
                  },
                  hoverColor: hoverBg,
                  child: AnimatedContainer(
                    duration: AeaAnimations.fast,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AeaSpace.md, vertical: AeaSpace.md),
                    color: isSel
                        ? AeaColors.primaryLight.withOpacity(.4)
                        : base,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: AeaSpace.sm),
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
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ZoneTab({
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AreaViewModel>();
    final groupSel = vm.selectedGroupSer != null && vm.selectedGroupSer != '0';
    final zoneSel = vm.selectedZoneSer != null;

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
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ],
          ),
        ),
        const SizedBox(height: AeaSpace.md),
        Expanded(child: _ZoneList()),
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
            final name = groups
                .where((g) => g.ser == v)
                .map((g) => g.zn)
                .firstOrNull;
            vm.onGroupChanged(v, name);
          },
        ),
      ),
    );
  }
}

class _ZoneList extends StatelessWidget {
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
                return InkWell(
                  onTap: () => vm.onZoneChanged(z.ser, z.zn),
                  hoverColor: AeaColors.primary.withOpacity(.06),
                  child: AnimatedContainer(
                    duration: AeaAnimations.fast,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AeaSpace.md, vertical: AeaSpace.md),
                    color: isSel
                        ? AeaColors.primaryLight.withOpacity(.4)
                        : null,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: AeaSpace.sm),
                          decoration: BoxDecoration(
                            color: isSel
                                ? AeaColors.primary
                                : AeaColors.textMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                            child:
                                Text(z.zn.isEmpty ? '-' : z.zn, style: AeaText.body)),
                      ],
                    ),
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
// Tab 3 — จัดการพื้นที่
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: _ToolbarAreaFilters()),
            const SizedBox(width: AeaSpace.md),
            _ManageMenu(
              label: 'จัดการพื้นที่',
              canEdit: false,
              canDelete: false,
              onAdd: onAdd,
              onEdit: () {},
              onDelete: () {},
            ),
          ],
        ),
        const SizedBox(height: AeaSpace.md),
        Expanded(
          child: SingleChildScrollView(
            child: AreaTable(
              onEdit: onEdit,
              onDelete: onDelete,
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
