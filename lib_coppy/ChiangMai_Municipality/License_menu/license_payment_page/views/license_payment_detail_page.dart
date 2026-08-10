// ============================================================================
// license_payment_detail_page.dart
// ============================================================================
// Full-page detail route (2-step) — เปิดแบบเต็มจอเหมือน "สร้างคำขอ" ของ request
// - มี Provider ของตัวเอง (ไม่ผูกกับ list page)
// - ปิดได้ด้วย Navigator.pop (back button ใน header)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/license_payment_detail_view_model.dart';
import 'theme/license_payment_theme.dart';
import 'widgets/payment_detail_footer.dart';
import 'widgets/payment_detail_header.dart';
import 'widgets/payment_detail_step1.dart';
import 'widgets/payment_detail_step2.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// Public API
/// ═══════════════════════════════════════════════════════════════════════

/// Full-page detail route — เปิดแบบเต็มจอ
class LicensePaymentDetailPage extends StatefulWidget {
  /// uuid ของรายการที่จะแสดง (optional)
  final String? routeData;

  /// Title ที่จะแสดงใน header
  final String title;

  const LicensePaymentDetailPage({
    super.key,
    this.routeData,
    this.title = 'การรับชำระ',
  });

  /// Factory สร้าง Page พร้อม Provider (ใช้ใน Navigator.push)
  static Widget create({
    Key? key,
    String? routeData,
    String title = 'การรับชำระ',
  }) {
    return ChangeNotifierProvider<LicensePaymentDetailViewModel>(
      create: (_) => LicensePaymentDetailViewModel(),
      child: _LicensePaymentDetailPageBody(
        title: title,
        routeData: routeData,
      ),
    );
  }

  @override
  State<LicensePaymentDetailPage> createState() =>
      _LicensePaymentDetailPageState();
}

class _LicensePaymentDetailPageState extends State<LicensePaymentDetailPage> {
  @override
  Widget build(BuildContext context) {
    return LicensePaymentDetailPage.create(
      key: widget.key,
      routeData: widget.routeData,
      title: widget.title,
    );
  }
}

/// Body จริง — ต้องอยู่ใต้ Provider เสมอ
class _LicensePaymentDetailPageBody extends StatefulWidget {
  final String title;
  final String? routeData;

  const _LicensePaymentDetailPageBody({
    required this.title,
    this.routeData,
  });

  @override
  State<_LicensePaymentDetailPageBody> createState() =>
      _LicensePaymentDetailPageBodyState();
}

class _LicensePaymentDetailPageBodyState
    extends State<_LicensePaymentDetailPageBody> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicensePaymentDetailViewModel>();
    final step = vm.currentDetailStep;
    final total = vm.totalDetailSteps;
    final subtitle = step == 1 ? 'ตรวจสอบรายการรับชำระ' : 'บันทึกการรับชำระ';

    return Scaffold(
      backgroundColor: LaColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PaymentDetailHeader(
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
                  ? const PaymentDetailStep1()
                  : const PaymentDetailStep2(),
            ),
            PaymentDetailFooter(
              readOnly: false,
              currentStep: step,
              totalSteps: total,
              onNext: step < total ? vm.nextDetailStep : null,
              onSave: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('บันทึกการรับชำระ (placeholder)'),
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
