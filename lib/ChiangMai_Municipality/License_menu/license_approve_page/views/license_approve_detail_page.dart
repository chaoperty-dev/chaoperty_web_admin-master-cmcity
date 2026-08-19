// ============================================================================
// license_approve_detail_page.dart
// ============================================================================
// Full-page detail route (2-step) — เปิดแบบเต็มจอเหมือน "สร้างคำขอ" ของ request
//
// Step 1: ตรวจสอบคำขอ (read-only info card)
// Step 2: Timeline ลำดับขั้นตอนการอนุมัติ (read-only, ไม่มี logic
//         สำหรับ "บันทึก/ส่งคำร้องขออนุมัติ")
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/license_approve_detail_step2_view_model.dart';
import '../viewmodels/license_approve_detail_view_model.dart';
import 'theme/license_approve_theme.dart';
import 'widgets/approve_detail_footer.dart';
import 'widgets/approve_detail_header.dart';
import 'widgets/approve_detail_step1.dart';
import 'widgets/approve_detail_step2.dart';

class LicenseApproveDetailPage extends StatefulWidget {
  final String? routeData;
  final String title;

  const LicenseApproveDetailPage({
    super.key,
    this.routeData,
    this.title = 'อนุมัติคำขอ',
  });

  static Widget create({
    Key? key,
    String? routeData,
    String title = 'อนุมัติคำขอ',
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LicenseApproveDetailViewModel>(
          create: (_) => LicenseApproveDetailViewModel(),
        ),
        ChangeNotifierProvider<LicenseApproveDetailStep2ViewModel>(
          create: (_) => LicenseApproveDetailStep2ViewModel(),
        ),
      ],
      child: _LicenseApproveDetailPageBody(
        title: title,
        routeData: routeData,
      ),
    );
  }

  @override
  State<LicenseApproveDetailPage> createState() =>
      _LicenseApproveDetailPageState();
}

class _LicenseApproveDetailPageState extends State<LicenseApproveDetailPage> {
  @override
  Widget build(BuildContext context) {
    return LicenseApproveDetailPage.create(
      key: widget.key,
      routeData: widget.routeData,
      title: widget.title,
    );
  }
}

class _LicenseApproveDetailPageBody extends StatefulWidget {
  final String title;
  final String? routeData;

  const _LicenseApproveDetailPageBody({
    required this.title,
    this.routeData,
  });

  @override
  State<_LicenseApproveDetailPageBody> createState() =>
      _LicenseApproveDetailPageBodyState();
}

class _LicenseApproveDetailPageBodyState
    extends State<_LicenseApproveDetailPageBody> {
  @override
  void initState() {
    super.initState();
    // โหลดข้อมูลคำขอจาก uuid ที่ส่งมา (routeData) หลัง frame แรก
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final uuid = widget.routeData ?? '';
      if (uuid.isNotEmpty) {
        context.read<LicenseApproveDetailViewModel>().loadByUuid(uuid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseApproveDetailViewModel>();
    final step = vm.currentDetailStep;
    final total = vm.totalDetailSteps;
    final subtitle = step == 1 ? 'ตรวจสอบคำขอ' : 'ลำดับขั้นตอนการอนุมัติ';

    return Scaffold(
      backgroundColor: LaColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ApproveDetailHeader(
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
                  ? const ApproveDetailStep1()
                  : ApproveDetailStep2(
                      requestUuid: widget.routeData,
                    ),
            ),
            ApproveDetailFooter(
              // Step 2 เป็น read-only timeline → ไม่แสดงปุ่ม Save
              readOnly: step == total,
              currentStep: step,
              totalSteps: total,
              onNext: step < total ? vm.nextDetailStep : null,
              onSave: null,
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
