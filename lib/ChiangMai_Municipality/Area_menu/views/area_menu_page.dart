// ============================================================================
// area_menu_page.dart
// ============================================================================
// Main View — "คำขอต่อสัญญา" (Tab แรก)
//
// ใช้งานได้ 2 รูปแบบ:
//   ✅ AreaMenuPage.create(...) — สร้าง + wrap Provider ให้อัตโนมัติ (แนะนำ)
//   ✅ AreaMenuHost(...)       — alias
//
// IMPORTANT: ห้าม new AreaMenuPage() ตรงๆ เพราะ child widgets
// จะเรียก context.watch<AreaMenuViewModel>() ซึ่งต้องการ Provider
// ============================================================================

import 'dart:async';

import 'package:chaoperty/ChiangMai_Municipality/License_menu/license_contract_page/models/license_contract_result.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/area_menu_event.dart';
import '../viewmodels/area_menu_view_model.dart';
import 'theme/area_menu_theme.dart';
import 'widgets/area_menu_card_grid.dart';
import 'widgets/area_menu_header.dart';
import 'widgets/area_menu_pagination.dart';
import 'widgets/area_menu_search_bar.dart';
import 'widgets/area_menu_table.dart';
import 'widgets/area_menu_zone_filter.dart';
import 'area_menu_detail_page.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// Public API
/// ═══════════════════════════════════════════════════════════════════════
class AreaMenuPage extends StatefulWidget {
  final ValueChanged<LicenseContractResult>? onSave;

  const AreaMenuPage._({super.key, this.onSave});

  /// Factory สร้าง Page พร้อม Provider (ใช้ใน AdminScaffold / Navigator)
  static Widget create({
    Key? key,
    String? routeData,
    int? serTitle,
    String title = 'พื้นที่เช่า',
    ValueChanged<LicenseContractResult>? onSave,
    bool readOnly = false,
  }) {
    return ChangeNotifierProvider<AreaMenuViewModel>(
      create: (_) => AreaMenuViewModel(
        title: title,
        routeData: routeData,
        readOnly: readOnly,
      ),
      child: _AreaMenuPageBody(
        title: title,
        onSave: onSave,
      ),
    );
  }

  @override
  State<AreaMenuPage> createState() => _AreaMenuPageState();
}

class _AreaMenuPageState extends State<AreaMenuPage> {
  @override
  Widget build(BuildContext context) {
    return AreaMenuPage.create(
      key: widget.key,
      onSave: widget.onSave,
    );
  }
}

/// Body จริง — ต้องอยู่ใต้ Provider เสมอ
class _AreaMenuPageBody extends StatefulWidget {
  final String title;
  final ValueChanged<LicenseContractResult>? onSave;

  const _AreaMenuPageBody({
    required this.title,
    this.onSave,
  });

  @override
  State<_AreaMenuPageBody> createState() => _AreaMenuPageBodyState();
}

class _AreaMenuPageBodyState extends State<_AreaMenuPageBody> {
  StreamSubscription<AreaMenuEvent>? _sub;

  /// โหมดการแสดงผล: false = ตาราง (Table), true = การ์ด (Card grid)
  /// Default = การ์ด (ตามกฎ "ถ้าจอเริ่มไม่พอ ให้ดีฟอลเป็นแบบ การ์ด")
  bool _useGrid = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<AreaMenuViewModel>();
    _sub ??= vm.events.listen(_onEvent);
  }

  void _onEvent(AreaMenuEvent event) {
    if (!mounted) return;
    switch (event) {
      case AreaMenuErrorEvent(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: LaColors.statusRejectedFg,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(LaRadius.md),
            ),
          ),
        );
        break;
      case AreaMenuNavigateEvent(:final routeData):
        // เปิด full-page detail route (เต็มจอ)
        final title = context.read<AreaMenuViewModel>().title;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AreaMenuDetailPage.create(
              routeData: routeData,
              title: title,
            ),
            fullscreenDialog: true,
          ),
        );
        break;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AreaMenuViewModel>();
    return Container(
      color: LaColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(LaSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AreaMenuHeader(
              title: vm.title,
              subtitle: 'จำแนกพื้นที่เช่าตามโซนและประเภทพื้นที่เช่า',
              totalCount: vm.total,
            ),
            const SizedBox(height: LaSpace.lg),
            const AreaMenuZoneFilter(),
            const SizedBox(height: LaSpace.md),
            // Search + Pagination (+ View toggle เฉพาะจอ ≥1100)
            LayoutBuilder(
              builder: (context, c) {
                final canToggle = c.maxWidth >= 1100;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: AreaMenuSearchBar()),
                    const SizedBox(width: LaSpace.md),
                    const AreaMenuPagination(),
                    if (canToggle) ...[
                      const SizedBox(width: LaSpace.sm),
                      _ViewModeToggle(
                        useGrid: _useGrid,
                        onChanged: (v) => setState(() => _useGrid = v),
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: LaSpace.lg),
            // Layout: จอ < 1100 บังคับการ์ด, จอ ≥ 1100 เลือกได้
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final canTable = c.maxWidth >= 1100;
                  final useGrid = canTable ? _useGrid : true;
                  return useGrid
                      ? const AreaMenuCardGrid()
                      : SingleChildScrollView(
                          child: const AreaMenuTable(),
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Alias สำหรับเข้ากันได้กับ API เดิม
class AreaMenuHost extends StatelessWidget {
  final String? routeData;
  final int? serTitle;
  final String title;
  final ValueChanged<LicenseContractResult>? onSave;

  const AreaMenuHost({
    super.key,
    this.routeData,
    this.serTitle,
    this.title = 'พื้นที่เช่า',
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AreaMenuPage.create(
      routeData: routeData,
      serTitle: serTitle,
      title: title,
      onSave: onSave,
    );
  }
}

// ============================================================================
// Internal — Segmented toggle สำหรับสลับโหมด Table / Card
// (ใช้เฉพาะจอ ≥1100px — จอแคบ default การ์ดเลย ซ่อน UI การเลือก)
// ============================================================================
class _ViewModeToggle extends StatelessWidget {
  final bool useGrid;
  final ValueChanged<bool> onChanged;
  const _ViewModeToggle({
    required this.useGrid,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(color: LaColors.border, width: 1),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SegmentBtn(
            icon: Icons.grid_view_rounded,
            label: 'การ์ด',
            selected: useGrid,
            onTap: () => onChanged(true),
          ),
          _SegmentBtn(
            icon: Icons.table_rows_outlined,
            label: 'ตาราง',
            selected: !useGrid,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _SegmentBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SegmentBtn({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: LrAnimations.fast,
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? LaColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(LaRadius.sm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : LaColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: LaText.fontBold,
                  fontSize: 12,
                  color: selected ? Colors.white : LaColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}