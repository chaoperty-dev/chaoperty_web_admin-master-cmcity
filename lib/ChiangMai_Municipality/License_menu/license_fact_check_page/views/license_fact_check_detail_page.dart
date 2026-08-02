// ============================================================================
// license_fact_check_detail_page.dart
// ============================================================================
// Full-page detail route (2-step) — เปิดแบบเต็มจอเหมือน "สร้างคำขอ"
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/license_fact_check_detail_view_model.dart';
import 'theme/license_fact_check_theme.dart';
import 'widgets/fact_check_detail_footer.dart';
import 'widgets/fact_check_detail_header.dart';
import 'widgets/fact_check_detail_step1.dart';
import 'widgets/fact_check_detail_step2.dart';

class LicensefactcheckDetailPage extends StatefulWidget {
  final String? routeData;
  final String title;

  const LicensefactcheckDetailPage({
    super.key,
    this.routeData,
    this.title = 'ตรวจสอบข้อเท็จจริง',
  });

  static Widget create({
    Key? key,
    String? routeData,
    String title = 'ตรวจสอบข้อเท็จจริง',
  }) {
    return ChangeNotifierProvider<LicensefactcheckDetailViewModel>(
      create: (_) => LicensefactcheckDetailViewModel(),
      child: _LicensefactcheckDetailPageBody(
        title: title,
        routeData: routeData,
      ),
    );
  }

  @override
  State<LicensefactcheckDetailPage> createState() =>
      _LicensefactcheckDetailPageState();
}

class _LicensefactcheckDetailPageState
    extends State<LicensefactcheckDetailPage> {
  @override
  Widget build(BuildContext context) {
    return LicensefactcheckDetailPage.create(
      key: widget.key,
      routeData: widget.routeData,
      title: widget.title,
    );
  }
}

class _LicensefactcheckDetailPageBody extends StatefulWidget {
  final String title;
  final String? routeData;

  const _LicensefactcheckDetailPageBody({
    required this.title,
    this.routeData,
  });

  @override
  State<_LicensefactcheckDetailPageBody> createState() =>
      _LicensefactcheckDetailPageBodyState();
}

class _LicensefactcheckDetailPageBodyState
    extends State<_LicensefactcheckDetailPageBody> {
  @override
  void initState() {
    super.initState();
    // โหลดข้อมูลคำขอจาก uuid ที่ส่งมา (routeData) หลัง frame แรก
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final uuid = widget.routeData ?? '';
      if (uuid.isNotEmpty) {
        context.read<LicensefactcheckDetailViewModel>().loadByUuid(uuid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicensefactcheckDetailViewModel>();
    final step = vm.currentDetailStep;
    final total = vm.totalDetailSteps;
    final subtitle = step == 1 ? 'ตรวจสอบข้อเท็จจริง' : 'สรุปผลการตรวจสอบ';

    return Scaffold(
      backgroundColor: LaColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FactCheckDetailHeader(
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
                  ? const FactCheckDetailStep1()
                  : const FactCheckDetailStep2(),
            ),
            FactCheckDetailFooter(
              readOnly: false,
              currentStep: step,
              totalSteps: total,
              onNext: step < total ? vm.nextDetailStep : null,
              onSave: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('บันทึกผลการตรวจสอบข้อเท็จจริง (placeholder)'),
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
