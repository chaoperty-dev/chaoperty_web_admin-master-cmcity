// ============================================================================
// license_verify_page.dart
// ============================================================================
// Main View — "คำขอต่อสัญญา" (Tab แรก)
//
// ใช้งานได้ 2 รูปแบบ:
//   ✅ LicenseVerifyPage.create(...) — สร้าง + wrap Provider ให้อัตโนมัติ (แนะนำ)
//   ✅ LicenseVerifyHost(...)       — alias
//
// IMPORTANT: ห้าม new LicenseVerifyPage() ตรงๆ เพราะ child widgets
// จะเรียก context.watch<LicenseVerifyViewModel>() ซึ่งต้องการ Provider
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/license_verify_result.dart';
import '../models/license_verify_config.dart';
import '../models/license_verify_event.dart';
import '../viewmodels/license_verify_view_model.dart';
import 'theme/license_verify_theme.dart';
import 'widgets/verify_header.dart';
import 'widgets/verify_pagination.dart';
import 'widgets/verify_search_bar.dart';
import 'widgets/verify_table.dart';
import 'widgets/verify_zone_filter.dart';
import 'license_verify_detail_page.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// Public API
/// ═══════════════════════════════════════════════════════════════════════
class LicenseVerifyPage extends StatefulWidget {
  final ValueChanged<LicenseVerifyResult>? onSave;

  const LicenseVerifyPage._({super.key, this.onSave});

  /// Factory สร้าง Page พร้อม Provider (ใช้ใน AdminScaffold / Navigator)
  static Widget create({
    Key? key,
    String? routeData,
    int? serTitle,
    String title = 'ตรวจสอบหลักฐาน',
    ValueChanged<LicenseVerifyResult>? onSave,
    LicenseVerifyConfig? config,
  }) {
    final cfg = config ??
        LicenseVerifyConfig(
          title: title,
          routeData: routeData,
          serTitle: serTitle,
        );
    return ChangeNotifierProvider<LicenseVerifyViewModel>(
      create: (_) => LicenseVerifyViewModel(config: cfg),
      child: _LicenseVerifyPageBody(
        title: title,
        onSave: onSave,
      ),
    );
  }

  @override
  State<LicenseVerifyPage> createState() => _LicenseVerifyPageState();
}

class _LicenseVerifyPageState extends State<LicenseVerifyPage> {
  @override
  Widget build(BuildContext context) {
    return LicenseVerifyPage.create(
      key: widget.key,
      onSave: widget.onSave,
    );
  }
}

/// Body จริง — ต้องอยู่ใต้ Provider เสมอ
class _LicenseVerifyPageBody extends StatefulWidget {
  final String title;
  final ValueChanged<LicenseVerifyResult>? onSave;

  const _LicenseVerifyPageBody({
    required this.title,
    this.onSave,
  });

  @override
  State<_LicenseVerifyPageBody> createState() => _LicenseVerifyPageBodyState();
}

class _LicenseVerifyPageBodyState extends State<_LicenseVerifyPageBody> {
  StreamSubscription<LicenseVerifyEvent>? _sub;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<LicenseVerifyViewModel>();
    _sub ??= vm.events.listen(_onEvent);
  }

  void _onEvent(LicenseVerifyEvent event) {
    if (!mounted) return;
    switch (event) {
      case LicenseVerifyErrorEvent(:final message):
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
      case LicenseVerifyNavigateEvent(:final routeData):
        // เปิด full-page detail route (เต็มจอ)
        final title = context.read<LicenseVerifyViewModel>().title;
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
    final vm = context.watch<LicenseVerifyViewModel>();
    return Container(
      color: LaColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(LaSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VerifyHeader(
              title: vm.title,
              subtitle: 'ตรวจสอบหลักฐานใบอนุญาต — การตรวจสอบเอกสารที่เกี่ยวข้อง',
              totalCount: vm.total,
            ),
            const SizedBox(height: LaSpace.lg),
            const VerifyZoneFilter(),
            const SizedBox(height: LaSpace.md),
            // Search + Pagination row
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: VerifySearchBar()),
                SizedBox(width: LaSpace.md),
                VerifyPagination(),
              ],
            ),
            const SizedBox(height: LaSpace.lg),
            const Expanded(
              child: SingleChildScrollView(
                child: VerifyTable(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Alias สำหรับเข้ากันได้กับ API เดิม
class LicenseVerifyHost extends StatelessWidget {
  final String? routeData;
  final int? serTitle;
  final String title;
  final ValueChanged<LicenseVerifyResult>? onSave;

  const LicenseVerifyHost({
    super.key,
    this.routeData,
    this.serTitle,
    this.title = 'ตรวจสอบหลักฐาน',
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return LicenseVerifyPage.create(
      routeData: routeData,
      serTitle: serTitle,
      title: title,
      onSave: onSave,
    );
  }
}
