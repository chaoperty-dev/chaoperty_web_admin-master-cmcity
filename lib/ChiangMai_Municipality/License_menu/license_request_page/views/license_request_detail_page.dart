// ============================================================================
// license_request_detail_page.dart
// ============================================================================
// Full-page detail route (2-step) — เปิดแบบเต็มจอเหมือน "สร้างคำขอ"
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/license_request_detail_view_model.dart';
import 'theme/license_request_theme.dart';
import 'widgets/request_detail_footer.dart';
import 'widgets/request_detail_header.dart';
import 'widgets/request_detail_step1.dart';
import 'widgets/request_detail_step2.dart';

class LicenseRequestDetailPage extends StatefulWidget {
  final String? routeData;
  final String title;

  const LicenseRequestDetailPage({
    super.key,
    this.routeData,
    this.title = 'คำขอต่อสัญญา',
  });

  static Widget create({
    Key? key,
    String? routeData,
    String title = 'คำขอต่อสัญญา',
  }) {
    return ChangeNotifierProvider<LicenseRequestDetailViewModel>(
      create: (_) => LicenseRequestDetailViewModel(),
      child: _LicenseRequestDetailPageBody(
        title: title,
        routeData: routeData,
      ),
    );
  }

  @override
  State<LicenseRequestDetailPage> createState() =>
      _LicenseRequestDetailPageState();
}

class _LicenseRequestDetailPageState extends State<LicenseRequestDetailPage> {
  @override
  Widget build(BuildContext context) {
    return LicenseRequestDetailPage.create(
      key: widget.key,
      routeData: widget.routeData,
      title: widget.title,
    );
  }
}

class _LicenseRequestDetailPageBody extends StatefulWidget {
  final String title;
  final String? routeData;

  const _LicenseRequestDetailPageBody({
    required this.title,
    this.routeData,
  });

  @override
  State<_LicenseRequestDetailPageBody> createState() =>
      _LicenseRequestDetailPageBodyState();
}

class _LicenseRequestDetailPageBodyState
    extends State<_LicenseRequestDetailPageBody> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseRequestDetailViewModel>();
    final step = vm.currentDetailStep;
    final total = vm.totalDetailSteps;
    final subtitle = step == 1 ? 'ตรวจสอบคำขอ' : 'บันทึกการดำเนินการ';

    return Scaffold(
      backgroundColor: LrColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RequestDetailHeader(
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
                  ? const RequestDetailStep1()
                  : const RequestDetailStep2(),
            ),
            RequestDetailFooter(
              readOnly: false,
              currentStep: step,
              totalSteps: total,
              onNext: step < total ? vm.nextDetailStep : null,
              onSave: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('บันทึกการดำเนินการ (placeholder)'),
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
