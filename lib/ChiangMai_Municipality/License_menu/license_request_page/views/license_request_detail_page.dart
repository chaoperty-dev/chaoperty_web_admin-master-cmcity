// ============================================================================
// license_request_detail_page.dart
// ============================================================================
// Full-page detail route (2-step) — เปิดแบบเต็มจอเหมือน "สร้างคำขอ"
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/license_request_detail_step2_view_model.dart';
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
    // ✅ MultiProvider ที่ root — Providers เป็น ancestor ของทุก widget
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LicenseRequestDetailViewModel>(
          create: (_) => LicenseRequestDetailViewModel(),
        ),
        ChangeNotifierProvider<LicenseRequestDetailStep2ViewModel>(
          create: (_) => LicenseRequestDetailStep2ViewModel(),
        ),
      ],
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
        // ✅ Providers มาจาก root (MultiProvider) — ไม่ต้อง wrap ซ้ำ
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
                  ? RequestDetailStep1(requestUuid: widget.routeData)
                  : RequestDetailStep2(requestUuid: widget.routeData),
            ),
            RequestDetailFooter(
              readOnly: false,
              currentStep: step,
              totalSteps: total,
              onNext: step < total ? vm.nextDetailStep : null,
              onSave: step == total
                  ? () async {
                      // ✅ Step 2: เรียก submit() บน ViewModel
                      final vm2 = context
                          .read<LicenseRequestDetailStep2ViewModel>();
                      final err = await vm2.submit();
                      if (!mounted) return;
                      if (err == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('บันทึกสำเร็จ'),
                            backgroundColor: LrColors.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(err),
                            backgroundColor: LrColors.statusRejectedFg,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  : null,
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
