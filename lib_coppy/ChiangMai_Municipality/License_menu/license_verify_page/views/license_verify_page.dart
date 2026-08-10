// ============================================================================
// license_verify_page.dart
// ============================================================================
// Main View — "คำขอต่อสัญญา" (Tab แรก)
//
// ใช้งานได้ 2 รูปแบบ:
//   ✅ LicenseverifyPage.create(...) — สร้าง + wrap Provider ให้อัตโนมัติ (แนะนำ)
//   ✅ LicenseverifyHost(...)       — alias
//
// IMPORTANT: ห้าม new LicenseverifyPage() ตรงๆ เพราะ child widgets
// จะเรียก context.watch<LicenseverifyViewModel>() ซึ่งต้องการ Provider
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../license_contract_page/models/license_contract_result.dart';
import '../models/license_verify_config.dart';
import '../models/license_verify_event.dart';
import '../viewmodels/license_verify_view_model.dart';
import 'theme/license_verify_theme.dart';
import 'widgets/license_verify_header.dart';
import 'widgets/license_verify_pagination.dart';
import 'widgets/license_verify_search_bar.dart';
import 'widgets/license_verify_table.dart';
import 'widgets/license_verify_zone_filter.dart';
import 'license_verify_detail_page.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// Public API
/// ═══════════════════════════════════════════════════════════════════════
class LicenseverifyPage extends StatefulWidget {
  final ValueChanged<LicenseContractResult>? onSave;

  const LicenseverifyPage._({super.key, this.onSave});

  /// Factory สร้าง Page พร้อม Provider (ใช้ใน AdminScaffold / Navigator)
  static Widget create({
    Key? key,
    String? routeData,
    int? serTitle,
    String title = 'ตรวจสอบหลักฐาน',
    ValueChanged<LicenseContractResult>? onSave,
    LicenseverifyConfig? config,
  }) {
    final cfg = config ??
        LicenseverifyConfig(
          title: title,
          routeData: routeData,
          serTitle: serTitle,
        );
    return ChangeNotifierProvider<LicenseverifyViewModel>(
      create: (_) => LicenseverifyViewModel(config: cfg),
      child: _LicenseverifyPageBody(
        title: title,
        onSave: onSave,
      ),
    );
  }

  @override
  State<LicenseverifyPage> createState() => _LicenseverifyPageState();
}

class _LicenseverifyPageState extends State<LicenseverifyPage> {
  @override
  Widget build(BuildContext context) {
    return LicenseverifyPage.create(
      key: widget.key,
      onSave: widget.onSave,
    );
  }
}

/// Body จริง — ต้องอยู่ใต้ Provider เสมอ
class _LicenseverifyPageBody extends StatefulWidget {
  final String title;
  final ValueChanged<LicenseContractResult>? onSave;

  const _LicenseverifyPageBody({
    required this.title,
    this.onSave,
  });

  @override
  State<_LicenseverifyPageBody> createState() => _LicenseverifyPageBodyState();
}

class _LicenseverifyPageBodyState extends State<_LicenseverifyPageBody> {
  StreamSubscription<LicenseverifyEvent>? _sub;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<LicenseverifyViewModel>();
    _sub ??= vm.events.listen(_onEvent);
  }

  void _onEvent(LicenseverifyEvent event) {
    if (!mounted) return;
    final title = context.read<LicenseverifyViewModel>().title;
    switch (event) {
      case LicenseverifyErrorEvent(:final message):
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
      case LicenseverifyNavigateEvent(:final routeData):
        // เปิด full-page detail route (เต็มจอ)
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LicenseverifyDetailPage.create(
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
    final vm = context.watch<LicenseverifyViewModel>();
    return Container(
      color: LaColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(LaSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LicenseverifyHeader(
              title: vm.title,
              subtitle:
                  'ตรวจสอบหลักฐานใบอนุญาต — ตรวจสอบความถูกต้องก่อนอนุมัติ',
              totalCount: vm.total,
            ),
            const SizedBox(height: LaSpace.lg),
            const LicenseverifyZoneFilter(),
            const SizedBox(height: LaSpace.md),
            // Search + Pagination row
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: LicenseverifySearchBar()),
                SizedBox(width: LaSpace.md),
                LicenseverifyPagination(),
              ],
            ),
            const SizedBox(height: LaSpace.lg),
            const Expanded(
              child: SingleChildScrollView(
                child: LicenseverifyTable(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Alias สำหรับเข้ากันได้กับ API เดิม
class LicenseverifyHost extends StatelessWidget {
  final String? routeData;
  final int? serTitle;
  final String title;
  final ValueChanged<LicenseContractResult>? onSave;

  const LicenseverifyHost({
    super.key,
    this.routeData,
    this.serTitle,
    this.title = 'อนุมัติคำขอ',
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return LicenseverifyPage.create(
      routeData: routeData,
      serTitle: serTitle,
      title: title,
      onSave: onSave,
    );
  }
}
