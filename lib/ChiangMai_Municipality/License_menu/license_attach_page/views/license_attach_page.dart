// ============================================================================
// license_attach_page.dart
// ============================================================================
// Main View — "คำขอต่อสัญญา" (Tab แรก)
//
// ใช้งานได้ 2 รูปแบบ:
//   ✅ LicenseAttachPage.create(...) — สร้าง + wrap Provider ให้อัตโนมัติ (แนะนำ)
//   ✅ LicenseAttachHost(...)       — alias
//
// IMPORTANT: ห้าม new LicenseAttachPage() ตรงๆ เพราะ child widgets
// จะเรียก context.watch<LicenseAttachViewModel>() ซึ่งต้องการ Provider
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../license_contract_page/models/license_contract_result.dart';
import '../models/license_attach_config.dart';
import '../models/license_attach_event.dart';
import '../viewmodels/license_attach_view_model.dart';
import 'theme/license_attach_theme.dart';
import 'widgets/license_attach_header.dart';
import 'widgets/license_attach_pagination.dart';
import 'widgets/license_attach_search_bar.dart';
import 'widgets/license_attach_table.dart';
import 'widgets/license_attach_zone_filter.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// Public API
/// ═══════════════════════════════════════════════════════════════════════
class LicenseAttachPage extends StatefulWidget {
  final ValueChanged<LicenseContractResult>? onSave;

  const LicenseAttachPage._({super.key, this.onSave});

  /// Factory สร้าง Page พร้อม Provider (ใช้ใน AdminScaffold / Navigator)
  static Widget create({
    Key? key,
    String? routeData,
    int? serTitle,
    String title = 'อนุมัติคำขอ',
    ValueChanged<LicenseContractResult>? onSave,
    LicenseAttachConfig? config,
  }) {
    final cfg = config ??
        LicenseAttachConfig(
          title: title,
          routeData: routeData,
          serTitle: serTitle,
        );
    return ChangeNotifierProvider<LicenseAttachViewModel>(
      create: (_) => LicenseAttachViewModel(config: cfg),
      child: _LicenseAttachPageBody(
        title: title,
        onSave: onSave,
      ),
    );
  }

  @override
  State<LicenseAttachPage> createState() => _LicenseAttachPageState();
}

class _LicenseAttachPageState extends State<LicenseAttachPage> {
  @override
  Widget build(BuildContext context) {
    return LicenseAttachPage.create(
      key: widget.key,
      onSave: widget.onSave,
    );
  }
}

/// Body จริง — ต้องอยู่ใต้ Provider เสมอ
class _LicenseAttachPageBody extends StatefulWidget {
  final String title;
  final ValueChanged<LicenseContractResult>? onSave;

  const _LicenseAttachPageBody({
    required this.title,
    this.onSave,
  });

  @override
  State<_LicenseAttachPageBody> createState() =>
      _LicenseAttachPageBodyState();
}

class _LicenseAttachPageBodyState extends State<_LicenseAttachPageBody> {
  StreamSubscription<LicenseAttachEvent>? _sub;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<LicenseAttachViewModel>();
    _sub ??= vm.events.listen(_onEvent);
  }

  void _onEvent(LicenseAttachEvent event) {
    if (!mounted) return;
    switch (event) {
      case LicenseAttachErrorEvent(:final message):
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
      case LicenseAttachNavigateEvent(:final route, :final routeData):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('นำทางไป: $route (uuid: ${routeData ?? '-'})'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(LaRadius.md),
            ),
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
    final vm = context.watch<LicenseAttachViewModel>();
    return Container(
      color: LaColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(LaSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LicenseAttachHeader(
              title: vm.title,
              subtitle: 'แนบหลักฐานใบอนุญาต — อัปโหลดเอกสารที่เกี่ยวข้อง',
              totalCount: vm.total,
            ),
            const SizedBox(height: LaSpace.lg),
            const LicenseAttachZoneFilter(),
            const SizedBox(height: LaSpace.md),
            // Search + Pagination row
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: LicenseAttachSearchBar()),
                SizedBox(width: LaSpace.md),
                LicenseAttachPagination(),
              ],
            ),
            const SizedBox(height: LaSpace.lg),
            const Expanded(
              child: SingleChildScrollView(
                child: LicenseAttachTable(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Alias สำหรับเข้ากันได้กับ API เดิม
class LicenseAttachHost extends StatelessWidget {
  final String? routeData;
  final int? serTitle;
  final String title;
  final ValueChanged<LicenseContractResult>? onSave;

  const LicenseAttachHost({
    super.key,
    this.routeData,
    this.serTitle,
    this.title = 'อนุมัติคำขอ',
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return LicenseAttachPage.create(
      routeData: routeData,
      serTitle: serTitle,
      title: title,
      onSave: onSave,
    );
  }
}
