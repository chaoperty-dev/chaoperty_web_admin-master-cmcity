// ============================================================================
// license_approve_page.dart
// ============================================================================
// Main View — "อนุมัติคำขอ" (Tab หลัก: ข้อมูลที่ต้องอนุมัติ + อนุมัติรายการทั้งหมด)
//
// ใช้งานได้ 2 รูปแบบ:
//   ✅ LicenseApprovePage.create(...) — สร้าง + wrap Provider ให้อัตโนมัติ (แนะนำ)
//   ✅ LicenseApproveHost(...)       — alias
//
// IMPORTANT: ห้าม new LicenseApprovePage() ตรงๆ เพราะ child widgets
// จะเรียก context.watch<LicenseApproveViewModel>() ซึ่งต้องการ Provider
//
// Tab structure (independent — คนละ VM + คนละ search/pagination):
//   Tab 1: ข้อมูลที่ต้องอนุมัติ (pending list — outer VM, search/pagination 1)
//   Tab 2: อนุมัติรายการทั้งหมด (bulk grid + approve — own VM, search/pagination 2)
// ทั้ง 2 แท็บแยก state อิสระ — เปลี่ยนแท็บ filter/search ไม่กระทบกัน
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../license_contract_page/models/license_contract_result.dart';
import '../models/license_approve_config.dart';
import '../models/license_approve_event.dart';
import '../viewmodels/license_approve_view_model.dart';
import 'theme/license_approve_theme.dart';
import 'widgets/approve_bulk_page_summary.dart';
import 'widgets/license_approve_header.dart';
import 'widgets/license_approve_pagination.dart';
import 'widgets/license_approve_search_bar.dart';
import 'widgets/license_approve_table.dart';
import 'widgets/license_approve_zone_filter.dart';
import 'license_approve_detail_page.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// Public API
/// ═══════════════════════════════════════════════════════════════════════
class LicenseApprovePage extends StatefulWidget {
  final ValueChanged<LicenseContractResult>? onSave;
  final String? routeData;
  final int? serTitle;
  final String title;
  final LicenseApproveConfig? config;

  const LicenseApprovePage._({
    super.key,
    this.onSave,
    this.routeData,
    this.serTitle,
    this.title = 'อนุมัติคำขอ',
    this.config,
  });

  /// Factory สร้าง Page พร้อม Provider (ใช้ใน AdminScaffold / Navigator)
  static Widget create({
    Key? key,
    String? routeData,
    int? serTitle,
    String title = 'อนุมัติคำขอ',
    ValueChanged<LicenseContractResult>? onSave,
    LicenseApproveConfig? config,
  }) {
    return LicenseApprovePage._(
      key: key,
      routeData: routeData,
      serTitle: serTitle,
      title: title,
      onSave: onSave,
      config: config,
    );
  }

  @override
  State<LicenseApprovePage> createState() => _LicenseApprovePageState();
}

class _LicenseApprovePageState extends State<LicenseApprovePage> {
  late final LicenseApproveConfig _cfg;
  late final LicenseApproveViewModel _vm;

  @override
  void initState() {
    super.initState();
    _cfg = widget.config ??
        LicenseApproveConfig(
          title: widget.title,
          routeData: widget.routeData,
          serTitle: widget.serTitle,
        );
    // สร้าง outer VM ครั้งเดียว — ใช้สำหรับ Header (total) + Tab 1 (filter/search/pagination/table)
    _vm = LicenseApproveViewModel(config: _cfg);
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LicenseApproveViewModel>.value(
      value: _vm,
      child: _LicenseApprovePageBody(
        title: widget.title,
        onSave: widget.onSave,
        config: _cfg,
      ),
    );
  }
}

/// Body จริง — ต้องอยู่ใต้ Provider เสมอ
class _LicenseApprovePageBody extends StatefulWidget {
  final String title;
  final ValueChanged<LicenseContractResult>? onSave;
  final LicenseApproveConfig config;

  const _LicenseApprovePageBody({
    required this.title,
    required this.config,
    this.onSave,
  });

  @override
  State<_LicenseApprovePageBody> createState() =>
      _LicenseApprovePageBodyState();
}

class _LicenseApprovePageBodyState extends State<_LicenseApprovePageBody>
    with SingleTickerProviderStateMixin {
  StreamSubscription<LicenseApproveEvent>? _sub;

  late final TabController _tabController;
  static const _tabs = <_ApproveTab>[
    _ApproveTab(key: 'pending', label: 'ข้อมูลที่ต้องอนุมัติ'),
    _ApproveTab(key: 'bulk', label: 'อนุมัติรายการทั้งหมด'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ Subscribe เฉพาะ outer VM (Tab 1 + Header) — Tab 2 มี VM ของตัวเอง
    final vm = context.read<LicenseApproveViewModel>();
    _sub ??= vm.events.listen(_onEvent);
  }

  void _onEvent(LicenseApproveEvent event) {
    if (!mounted) return;
    switch (event) {
      case LicenseApproveErrorEvent(:final message):
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
      case LicenseApproveNavigateEvent(:final routeData):
        final title = context.read<LicenseApproveViewModel>().title;
        // ✅ Path-style — URL เปลี่ยนเป็น /approve/<uuid>
        if (routeData == null || routeData.isEmpty) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => LicenseApproveDetailPage.create(
                routeData: routeData,
                title: title,
              ),
              fullscreenDialog: true,
            ),
          );
        } else {
          context.push(
            '/approve/${Uri.encodeComponent(routeData)}',
            extra: {'title': title},
          );
        }
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Body ไม่ watch VM — total ถูก watch ภายใน header ผ่าน context.select
    return Container(
      color: LaColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(LaSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LicenseApproveHeader(
              title: widget.title,
              subtitle: 'อนุมัติคำขอใบอนุญาต — รอตรวจสอบและอนุมัติ',
            ),
            const SizedBox(height: LaSpace.lg),
            // ─── TabBar (2 แท็บ) ───
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(LaRadius.md),
                border: Border.all(color: LaColors.border),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: LaColors.primaryDark,
                unselectedLabelColor: LaColors.textSecondary,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(LaRadius.md),
                  color: LaColors.primary.withOpacity(.10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(4),
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(
                  fontFamily: LaText.fontBold,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: LaText.fontRegular,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                tabs: _tabs
                    .map((t) => Tab(
                          icon: Icon(
                            t.key == 'pending'
                                ? Icons.fact_check_outlined
                                : Icons.done_all_rounded,
                            size: 18,
                          ),
                          text: t.label,
                          iconMargin: const EdgeInsets.only(bottom: 4),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: LaSpace.lg),
            // ─── TabBarView — แต่ละแท็บมี controls + VM ของตัวเอง ───
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  const _ApproveTab1Content(),
                  // Tab 2 — รับ config เดียวกัน → สร้าง VM อิสระภายใน
                  _ApproveTab2Content(config: widget.config),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// _ApproveTab1Content — Tab 1 (ใช้ outer VM)
//   ZoneFilter + SearchBar + Pagination + Table
// ─────────────────────────────────────────────────────────────────────
class _ApproveTab1Content extends StatelessWidget {
  const _ApproveTab1Content();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LicenseApproveZoneFilter(),
        SizedBox(height: LaSpace.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: LicenseApproveSearchBar()),
            SizedBox(width: LaSpace.md),
            LicenseApprovePagination(),
          ],
        ),
        SizedBox(height: LaSpace.lg),
        Expanded(
          child: SingleChildScrollView(child: LicenseApproveTable()),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// _ApproveTab2Content — Tab 2 (มี VM ของตัวเอง — แยก state จาก Tab 1)
//   Own VM + ZoneFilter + SearchBar + Pagination + Bulk grid
// ─────────────────────────────────────────────────────────────────────
class _ApproveTab2Content extends StatefulWidget {
  final LicenseApproveConfig config;
  const _ApproveTab2Content({required this.config});

  @override
  State<_ApproveTab2Content> createState() => _ApproveTab2ContentState();
}

class _ApproveTab2ContentState extends State<_ApproveTab2Content> {
  late final LicenseApproveViewModel _vm;
  StreamSubscription<LicenseApproveEvent>? _sub;

  @override
  void initState() {
    super.initState();
    // ✅ สร้าง VM อิสระจาก config เดียวกับ Tab 1 — แยก state สิ้นเชิง
    _vm = LicenseApproveViewModel(config: widget.config);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // subscribe VM events (ทำครั้งเดียว)
    _sub ??= _vm.events.listen(_onEvent);
  }

  void _onEvent(LicenseApproveEvent event) {
    if (!mounted) return;
    switch (event) {
      case LicenseApproveErrorEvent(:final message):
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
      case LicenseApproveNavigateEvent(:final routeData):
        // ✅ Path-style — URL เปลี่ยนเป็น /approve/<uuid>
        if (routeData == null || routeData.isEmpty) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => LicenseApproveDetailPage.create(
                routeData: routeData,
                title: _vm.title,
              ),
              fullscreenDialog: true,
            ),
          );
        } else {
          context.push(
            '/approve/${Uri.encodeComponent(routeData)}',
            extra: {'title': _vm.title},
          );
        }
        break;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LicenseApproveViewModel>.value(
      value: _vm,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LicenseApproveZoneFilter(),
          SizedBox(height: LaSpace.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: LicenseApproveSearchBar()),
              SizedBox(width: LaSpace.md),
              LicenseApprovePagination(),
            ],
          ),
          SizedBox(height: LaSpace.lg),
          Expanded(child: ApproveBulkPageSummary()),
        ],
      ),
    );
  }
}

/// Tab descriptor สำหรับ approval page
class _ApproveTab {
  final String key;
  final String label;
  const _ApproveTab({required this.key, required this.label});
}

/// Alias สำหรับเข้ากันได้กับ API เดิม
class LicenseApproveHost extends StatelessWidget {
  final String? routeData;
  final int? serTitle;
  final String title;
  final ValueChanged<LicenseContractResult>? onSave;

  const LicenseApproveHost({
    super.key,
    this.routeData,
    this.serTitle,
    this.title = 'อนุมัติคำขอ',
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return LicenseApprovePage.create(
      routeData: routeData,
      serTitle: serTitle,
      title: title,
      onSave: onSave,
    );
  }
}
