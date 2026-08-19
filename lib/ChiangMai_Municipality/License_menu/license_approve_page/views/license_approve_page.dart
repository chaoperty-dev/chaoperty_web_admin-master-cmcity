// ============================================================================
// license_approve_page.dart
// ============================================================================
// Main View — "คำขอต่อสัญญา" (Tab แรก)
//
// ใช้งานได้ 2 รูปแบบ:
//   ✅ LicenseApprovePage.create(...) — สร้าง + wrap Provider ให้อัตโนมัติ (แนะนำ)
//   ✅ LicenseApproveHost(...)       — alias
//
// IMPORTANT: ห้าม new LicenseApprovePage() ตรงๆ เพราะ child widgets
// จะเรียก context.watch<LicenseApproveViewModel>() ซึ่งต้องการ Provider
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../license_contract_page/models/license_contract_result.dart';
import '../models/license_approve_config.dart';
import '../models/license_approve_event.dart';
import '../viewmodels/license_approve_view_model.dart';
import 'theme/license_approve_theme.dart';
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

  LicenseApprovePage._({
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
    // สร้าง VM ครั้งเดียวใน initState — ใช้ ChangeNotifierProvider.value
    // เพื่อให้ filter state (zone/sub-zone/status) คงอยู่ตอน rebuild
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
      ),
    );
  }
}

/// Body จริง — ต้องอยู่ใต้ Provider เสมอ
class _LicenseApprovePageBody extends StatefulWidget {
  final String title;
  final ValueChanged<LicenseContractResult>? onSave;

  const _LicenseApprovePageBody({
    required this.title,
    this.onSave,
  });

  @override
  State<_LicenseApprovePageBody> createState() =>
      _LicenseApprovePageBodyState();
}

class _LicenseApprovePageBodyState extends State<_LicenseApprovePageBody> {
  StreamSubscription<LicenseApproveEvent>? _sub;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
        // เปิด full-page detail route (เต็มจอ)
        final title = context.read<LicenseApproveViewModel>().title;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LicenseApproveDetailPage.create(
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
    final vm = context.watch<LicenseApproveViewModel>();
    return Container(
      color: LaColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(LaSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LicenseApproveHeader(
              title: vm.title,
              subtitle: 'อนุมัติคำขอใบอนุญาต — รอตรวจสอบและอนุมัติ',
              totalCount: vm.total,
            ),
            const SizedBox(height: LaSpace.lg),
            const LicenseApproveZoneFilter(),
            const SizedBox(height: LaSpace.md),
            // Search + Pagination row (pagination inline)
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: LicenseApproveSearchBar()),
                SizedBox(width: LaSpace.md),
                LicenseApprovePagination(),
              ],
            ),
            const SizedBox(height: LaSpace.lg),
            // ─── Scroll แนวตั้ง — table ปรับขนาดตาม parent ───
            const Expanded(
              child: SingleChildScrollView(
                child: LicenseApproveTable(),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
