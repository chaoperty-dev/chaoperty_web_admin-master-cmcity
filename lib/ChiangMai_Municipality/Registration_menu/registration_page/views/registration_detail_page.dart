// ============================================================================
// registration_detail_page.dart
// ============================================================================
// Full-page detail route (2-step) — เปิดแบบเต็มจอเหมือน "สร้างคำขอ" ของ request
// - มี Provider ของตัวเอง (ไม่ผูกกับ list page)
// - ปิดได้ด้วย Navigator.pop (back button ใน header)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/registration_detail_view_model.dart';
import 'theme/registration_theme.dart';
import 'widgets/registration_detail_footer.dart';
import 'widgets/registration_detail_header.dart';
import 'widgets/registration_detail_step1.dart';
import 'widgets/registration_detail_step2.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// Public API
/// ═══════════════════════════════════════════════════════════════════════

/// Full-page detail route — เปิดแบบเต็มจอ
/// ใช้เหมือน "หน้าสร้างคำขอ" ของ license_request_page (push MaterialPageRoute
/// fullscreenDialog: true)
class RegistrationDetailPage extends StatefulWidget {
  /// uuid ของรายการที่จะแสดง (optional — ถ้ามีให้ preload)
  final String? routeData;

  /// Title ที่จะแสดงใน header
  final String title;

  const RegistrationDetailPage({
    super.key,
    this.routeData,
    this.title = 'ตรวจสอบหลักฐาน',
  });

  /// Factory สร้าง Page พร้อม Provider (ใช้ใน Navigator.push)
  static Widget create({
    Key? key,
    String? routeData,
    String title = 'ตรวจสอบหลักฐาน',
  }) {
    return ChangeNotifierProvider<RegistrationDetailViewModel>(
      create: (_) => RegistrationDetailViewModel(),
      child: _RegistrationDetailPageBody(
        title: title,
        routeData: routeData,
      ),
    );
  }

  @override
  State<RegistrationDetailPage> createState() =>
      _RegistrationDetailPageState();
}

class _RegistrationDetailPageState extends State<RegistrationDetailPage> {
  @override
  Widget build(BuildContext context) {
    return RegistrationDetailPage.create(
      key: widget.key,
      routeData: widget.routeData,
      title: widget.title,
    );
  }
}

/// Body จริง — ต้องอยู่ใต้ Provider เสมอ
class _RegistrationDetailPageBody extends StatefulWidget {
  final String title;
  final String? routeData;

  const _RegistrationDetailPageBody({
    required this.title,
    this.routeData,
  });

  @override
  State<_RegistrationDetailPageBody> createState() =>
      _RegistrationDetailPageBodyState();
}

class _RegistrationDetailPageBodyState
    extends State<_RegistrationDetailPageBody> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistrationDetailViewModel>();
    final step = vm.currentDetailStep;
    final total = vm.totalDetailSteps;
    final subtitle =
        step == 1 ? 'ตรวจสอบหลักฐานที่ผู้เช่าส่งมา' : 'สรุปผลการตรวจสอบ';

    return Scaffold(
      backgroundColor: LaColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RegistrationDetailHeader(
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
                  ? const RegistrationDetailStep1()
                  : const RegistrationDetailStep2(),
            ),
            RegistrationDetailFooter(
              readOnly: false,
              currentStep: step,
              totalSteps: total,
              onNext: step < total ? vm.nextDetailStep : null,
              onSave: () {
                // TODO: ส่งข้อมูลบันทึก — รอ service จริง
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('บันทึกผลการตรวจสอบ (placeholder)'),
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
