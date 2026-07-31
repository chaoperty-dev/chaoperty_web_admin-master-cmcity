// ============================================================================
// license_fact_check_page.dart
// ============================================================================
// Main View — "คำขอต่อสัญญา" (Tab แรก)
//
// ใช้งานได้ 2 รูปแบบ:
//   ✅ LicensefactcheckPage.create(...) — สร้าง + wrap Provider ให้อัตโนมัติ (แนะนำ)
//   ✅ LicensefactcheckHost(...)       — alias
//
// IMPORTANT: ห้าม new LicensefactcheckPage() ตรงๆ เพราะ child widgets
// จะเรียก context.watch<LicensefactcheckViewModel>() ซึ่งต้องการ Provider
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../license_contract_page/models/license_contract_result.dart';
import '../models/license_fact_check_config.dart';
import '../models/license_fact_check_event.dart';
import '../viewmodels/license_fact_check_view_model.dart';
import 'theme/license_fact_check_theme.dart';
import 'widgets/license_fact_check_header.dart';
import 'widgets/license_fact_check_pagination.dart';
import 'widgets/license_fact_check_search_bar.dart';
import 'widgets/license_fact_check_table.dart';
import 'widgets/license_fact_check_zone_filter.dart';
import 'license_fact_check_detail_page.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// Public API
/// ═══════════════════════════════════════════════════════════════════════
class LicensefactcheckPage extends StatefulWidget {
  final ValueChanged<LicenseContractResult>? onSave;

  const LicensefactcheckPage._({super.key, this.onSave});

  /// Factory สร้าง Page พร้อม Provider (ใช้ใน AdminScaffold / Navigator)
  static Widget create({
    Key? key,
    String? routeData,
    int? serTitle,
    String title = 'ตรวจสอบข้อเท็จจริง',
    ValueChanged<LicenseContractResult>? onSave,
    LicensefactcheckConfig? config,
  }) {
    final cfg = config ??
        LicensefactcheckConfig(
          title: title,
          routeData: routeData,
          serTitle: serTitle,
        );
    return ChangeNotifierProvider<LicensefactcheckViewModel>(
      create: (_) => LicensefactcheckViewModel(config: cfg),
      child: _LicensefactcheckPageBody(
        title: title,
        onSave: onSave,
      ),
    );
  }

  @override
  State<LicensefactcheckPage> createState() => _LicensefactcheckPageState();
}

class _LicensefactcheckPageState extends State<LicensefactcheckPage> {
  @override
  Widget build(BuildContext context) {
    return LicensefactcheckPage.create(
      key: widget.key,
      onSave: widget.onSave,
    );
  }
}

/// Body จริง — ต้องอยู่ใต้ Provider เสมอ
class _LicensefactcheckPageBody extends StatefulWidget {
  final String title;
  final ValueChanged<LicenseContractResult>? onSave;

  const _LicensefactcheckPageBody({
    required this.title,
    this.onSave,
  });

  @override
  State<_LicensefactcheckPageBody> createState() =>
      _LicensefactcheckPageBodyState();
}

class _LicensefactcheckPageBodyState extends State<_LicensefactcheckPageBody> {
  StreamSubscription<LicensefactcheckEvent>? _sub;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<LicensefactcheckViewModel>();
    _sub ??= vm.events.listen(_onEvent);
  }

  void _onEvent(LicensefactcheckEvent event) {
    if (!mounted) return;
    switch (event) {
      case LicensefactcheckErrorEvent(:final message):
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
      case LicensefactcheckNavigateEvent(:final routeData):
        // เปิด full-page detail route (เต็มจอ)
        final title = context.read<LicensefactcheckViewModel>().title;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LicensefactcheckDetailPage.create(
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
    final vm = context.watch<LicensefactcheckViewModel>();
    return Container(
      color: LaColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(LaSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LicensefactcheckHeader(
              title: vm.title,
              subtitle:
                  'ตรวจสอบข้อเท็จจริงใบอนุญาต — ยืนยันข้อมูลก่อนอนุมัติขั้นสุดท้าย',
              totalCount: vm.total,
            ),
            const SizedBox(height: LaSpace.lg),
            const LicensefactcheckZoneFilter(),
            const SizedBox(height: LaSpace.md),
            // Search + Pagination row
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: LicensefactcheckSearchBar()),
                SizedBox(width: LaSpace.md),
                LicensefactcheckPagination(),
              ],
            ),
            const SizedBox(height: LaSpace.lg),
            const Expanded(
              child: SingleChildScrollView(
                child: LicensefactcheckTable(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Alias สำหรับเข้ากันได้กับ API เดิม
class LicensefactcheckHost extends StatelessWidget {
  final String? routeData;
  final int? serTitle;
  final String title;
  final ValueChanged<LicenseContractResult>? onSave;

  const LicensefactcheckHost({
    super.key,
    this.routeData,
    this.serTitle,
    this.title = 'ตรวจสอบข้อเท็จจริง',
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return LicensefactcheckPage.create(
      routeData: routeData,
      serTitle: serTitle,
      title: title,
      onSave: onSave,
    );
  }
}
