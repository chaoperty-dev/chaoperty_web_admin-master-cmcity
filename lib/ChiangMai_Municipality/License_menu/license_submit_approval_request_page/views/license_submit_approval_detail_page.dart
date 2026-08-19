// ============================================================================
// license_submit_approval_detail_page.dart
// ============================================================================
// Full-page detail route (2-step) — เปิดแบบเต็มจอเหมือน "สร้างคำขอ" ของ request
// - มี Provider ของตัวเอง (ไม่ผูกกับ list page)
// - ปิดได้ด้วย Navigator.pop (back button ใน header)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/license_submit_approval_detail_view_model.dart';
import '../viewmodels/license_submit_approval_rounds_view_model.dart';
import 'theme/license_submit_approval_theme.dart';
import 'widgets/submit_approval_detail_footer.dart';
import 'widgets/submit_approval_detail_header.dart';
import 'widgets/submit_approval_detail_step1.dart';
import 'widgets/submit_approval_detail_step2.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// Public API
/// ═══════════════════════════════════════════════════════════════════════

/// Full-page detail route — เปิดแบบเต็มจอ
class LicenseSubmitApprovalDetailPage extends StatefulWidget {
  /// uuid ของรายการที่จะแสดง (optional)
  final String? routeData;

  /// Title ที่จะแสดงใน header
  final String title;

  const LicenseSubmitApprovalDetailPage({
    super.key,
    this.routeData,
    this.title = 'ส่งคำร้องขออนุมัติ',
  });

  /// Factory สร้าง Page พร้อม Provider (ใช้ใน Navigator.push)
  static Widget create({
    Key? key,
    String? routeData,
    String title = 'ส่งคำร้องขออนุมัติ',
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LicenseSubmitApprovalDetailViewModel>(
          create: (_) => LicenseSubmitApprovalDetailViewModel(),
        ),
        ChangeNotifierProvider<LicenseSubmitApprovalRoundsViewModel>(
          create: (_) => LicenseSubmitApprovalRoundsViewModel(),
        ),
      ],
      child: _LicenseSubmitApprovalDetailPageBody(
        title: title,
        routeData: routeData,
      ),
    );
  }

  @override
  State<LicenseSubmitApprovalDetailPage> createState() =>
      _LicenseSubmitApprovalDetailPageState();
}

class _LicenseSubmitApprovalDetailPageState extends State<LicenseSubmitApprovalDetailPage> {
  @override
  Widget build(BuildContext context) {
    return LicenseSubmitApprovalDetailPage.create(
      key: widget.key,
      routeData: widget.routeData,
      title: widget.title,
    );
  }
}

/// Body จริง — ต้องอยู่ใต้ Provider เสมอ
class _LicenseSubmitApprovalDetailPageBody extends StatefulWidget {
  final String title;
  final String? routeData;

  const _LicenseSubmitApprovalDetailPageBody({
    required this.title,
    this.routeData,
  });

  @override
  State<_LicenseSubmitApprovalDetailPageBody> createState() =>
      _LicenseSubmitApprovalDetailPageBodyState();
}

class _LicenseSubmitApprovalDetailPageBodyState
    extends State<_LicenseSubmitApprovalDetailPageBody> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseSubmitApprovalDetailViewModel>();
    final step = vm.currentDetailStep;
    final total = vm.totalDetailSteps;
    final subtitle = step == 1 ? 'ตรวจสอบรายส่งคำร้องขออนุมัติ' : 'บันทึกส่งคำร้องขออนุมัติ';

    return Scaffold(
      backgroundColor: LaColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SubmitApprovalDetailHeader(
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
                  ? SubmitApprovalDetailStep1(requestUuid: widget.routeData)
                  : SubmitApprovalDetailStep2(requestUuid: widget.routeData),
            ),
            SubmitApprovalDetailFooter(
              readOnly: false,
              currentStep: step,
              totalSteps: total,
              onNext: step < total ? vm.nextDetailStep : null,
              onSave: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('บันทึกส่งคำร้องขออนุมัติ (placeholder)'),
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
