// ============================================================================
// tenant_license_detail_page.dart
// ============================================================================
// Full-page detail route (2-step) — เปิดแบบเต็มจอเหมือน license_payment
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/tenant_license_detail_view_model.dart';
import 'theme/tenant_license_theme.dart';
import 'widgets/tenant_license_detail_footer.dart';
import 'widgets/tenant_license_detail_header.dart';
import 'widgets/tenant_license_detail_step1.dart';
import 'widgets/tenant_license_detail_step2.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// Public API
/// ═══════════════════════════════════════════════════════════════════════

class TenantLicenseDetailPage extends StatefulWidget {
  final String? routeData;
  final String title;
  final dynamic tenant;

  const TenantLicenseDetailPage({
    super.key,
    this.routeData,
    this.title = 'ข้อมูลผู้เช่า',
    this.tenant,
  });

  /// Factory สร้าง Page พร้อม Provider (ใช้ใน Navigator.push)
  static Widget create({
    Key? key,
    String? routeData,
    String title = 'ข้อมูลผู้เช่า',
    dynamic tenant,
  }) {
    return ChangeNotifierProvider<TenantLicenseDetailViewModel>(
      create: (_) => TenantLicenseDetailViewModel(),
      child: _TenantLicenseDetailPageBody(
        title: title,
        routeData: routeData,
        tenant: tenant,
      ),
    );
  }

  @override
  State<TenantLicenseDetailPage> createState() =>
      _TenantLicenseDetailPageState();
}

class _TenantLicenseDetailPageState extends State<TenantLicenseDetailPage> {
  @override
  Widget build(BuildContext context) {
    return TenantLicenseDetailPage.create(
      key: widget.key,
      routeData: widget.routeData,
      title: widget.title,
      tenant: widget.tenant,
    );
  }
}

/// Body จริง — ต้องอยู่ใต้ Provider เสมอ
class _TenantLicenseDetailPageBody extends StatefulWidget {
  final String title;
  final String? routeData;
  final dynamic tenant;

  const _TenantLicenseDetailPageBody({
    required this.title,
    this.routeData,
    this.tenant,
  });

  @override
  State<_TenantLicenseDetailPageBody> createState() =>
      _TenantLicenseDetailPageBodyState();
}

class _TenantLicenseDetailPageBodyState
    extends State<_TenantLicenseDetailPageBody> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TenantLicenseDetailViewModel>();
    final step = vm.currentDetailStep;
    final total = vm.totalDetailSteps;
    final subtitle = step == 1 ? 'ตรวจสอบข้อมูลผู้เช่า' : 'จัดการสัญญาเช่า';

    return Scaffold(
      backgroundColor: LaColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TenantLicenseDetailHeader(
              title: widget.title,
              subtitle: subtitle,
              currentStep: step,
              totalSteps: total,
              onBack: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
            Expanded(
              child: step == 1
                  ? TenantLicenseDetailStep1(tenant: widget.tenant)
                  : const TenantLicenseDetailStep2(),
            ),
            TenantLicenseDetailFooter(
              readOnly: false,
              currentStep: step,
              totalSteps: total,
              onNext: step < total ? vm.nextDetailStep : null,
              onSave: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('บันทึกข้อมูลผู้เช่า (placeholder)'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              onCancel: () {
                if (step > 1) {
                  vm.previousDetailStep();
                } else {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
