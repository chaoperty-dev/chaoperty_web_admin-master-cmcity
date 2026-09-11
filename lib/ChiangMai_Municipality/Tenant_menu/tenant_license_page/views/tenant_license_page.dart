// ============================================================================
// tenant_license_page.dart
// ============================================================================
// Main View — "ผู้ได้รับใบอนุญาต"
//
// ใช้งานได้ 2 รูปแบบ:
//   ✅ TenantLicensePage.create(...) — สร้าง + wrap Provider ให้อัตโนมัติ (แนะนำ)
//   ✅ TenantLicenseHost(...)       — alias
//
// IMPORTANT: ห้าม new TenantLicensePage() ตรงๆ เพราะ child widgets
// จะเรียก context.watch<TenantLicenseViewModel>() ซึ่งต้องการ Provider
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'tenant_license_detail_page.dart';

// Permit detail navigation receives UUID through TenantLicenseEvent.
import '../models/tenant_license_config.dart';
import '../models/tenant_license_event.dart';
import '../viewmodels/tenant_license_view_model.dart';
import 'theme/tenant_license_theme.dart';
import 'widgets/tenant_license_header.dart';
import 'widgets/tenant_license_pagination.dart';
import 'widgets/tenant_license_search_bar.dart';
import 'widgets/tenant_license_table.dart';
import 'widgets/tenant_license_zone_filter.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// Public API
/// ═══════════════════════════════════════════════════════════════════════
class TenantLicensePage extends StatefulWidget {
  final String? routeData;
  final int? serTitle;
  final String title;

  const TenantLicensePage._({
    this.routeData,
    this.serTitle,
    this.title = 'ผู้ได้รับใบอนุญาต',
  });

  /// Factory สร้าง Page พร้อม Provider (ใช้ใน AdminScaffold / Navigator)
  static Widget create({
    Key? key,
    String? routeData,
    int? serTitle,
    String title = 'ผู้ได้รับใบอนุญาต',
    TenantLicenseConfig? config,
  }) {
    final cfg = config ??
        TenantLicenseConfig(
          title: title,
          routeData: routeData,
          serTitle: serTitle,
        );
    return ChangeNotifierProvider<TenantLicenseViewModel>(
      create: (_) => TenantLicenseViewModel(config: cfg),
      child: _TenantLicensePageBody(
        title: title,
      ),
    );
  }

  @override
  State<TenantLicensePage> createState() => _TenantLicensePageState();
}

class _TenantLicensePageState extends State<TenantLicensePage> {
  @override
  Widget build(BuildContext context) {
    return TenantLicensePage.create(
      key: widget.key,
      routeData: widget.routeData,
      serTitle: widget.serTitle,
      title: widget.title,
    );
  }
}

/// Body จริง — ต้องอยู่ใต้ Provider เสมอ
class _TenantLicensePageBody extends StatefulWidget {
  final String title;

  const _TenantLicensePageBody({
    required this.title,
  });

  @override
  State<_TenantLicensePageBody> createState() => _TenantLicensePageBodyState();
}

class _TenantLicensePageBodyState extends State<_TenantLicensePageBody> {
  StreamSubscription<TenantLicenseEvent>? _sub;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<TenantLicenseViewModel>();
    _sub ??= vm.events.listen(_onEvent);
  }

  void _onEvent(TenantLicenseEvent event) {
    if (!mounted) return;
    switch (event) {
      case TenantLicenseErrorEvent(:final message):
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
      case TenantLicenseNavigateEvent(:final route, :final routeData):
        if (route == 'TenantPermitDetail' && routeData != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TenantLicenseDetailPage.create(
                routeData: routeData,
                title: 'ข้อมูลใบอนุญาต',
              ),
            ),
          );
        }
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
    final vm = context.watch<TenantLicenseViewModel>();
    return Scaffold(
      backgroundColor: LaColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LaSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TenantLicenseHeader(
                title: vm.title,
                subtitle: 'จัดการรายการใบอนุญาต — ตรวจสอบและค้นหาข้อมูล',
                totalCount: vm.total,
              ),
              const SizedBox(height: LaSpace.lg),
              const TenantLicenseZoneFilter(),
              const SizedBox(height: LaSpace.md),
              // Search + Pagination row
              const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: TenantLicenseSearchBar()),
                  SizedBox(width: LaSpace.md),
                  TenantLicensePagination(),
                ],
              ),
              const SizedBox(height: LaSpace.lg),
              const Expanded(
                child: SingleChildScrollView(
                  child: TenantLicenseTable(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Alias สำหรับเข้ากันได้กับ API เดิม
class TenantLicenseHost extends StatelessWidget {
  final String? routeData;
  final int? serTitle;
  final String title;

  const TenantLicenseHost({
    super.key,
    this.routeData,
    this.serTitle,
    this.title = 'ผู้ได้รับใบอนุญาต',
  });

  @override
  Widget build(BuildContext context) {
    return TenantLicensePage.create(
      routeData: routeData,
      serTitle: serTitle,
      title: title,
    );
  }
}
