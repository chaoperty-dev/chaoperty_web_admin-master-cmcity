// ============================================================================
// registration_detail_page.dart
// ============================================================================
// Full-page detail route (2-step) — เปิดแบบเต็มจอเหมือน "สร้างคำขอ" ของ License_menu
// - Step 1: ข้อมูลลูกค้า
// - Step 2: ที่อยู่ / สัญญา / สถานะ
// - ปิดได้ด้วย Navigator.pop (back button ใน header)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Model/GetCustomer_Model.dart';
import '../viewmodels/registration_detail_view_model.dart';
import 'theme/registration_theme.dart';
import 'widgets/registration_detail_footer.dart';
import 'widgets/registration_detail_header.dart';
import 'widgets/registration_detail_step1.dart';
import 'widgets/registration_detail_step2.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// Public API
/// ═══════════════════════════════════════════════════════════════════════
class RegistrationDetailPage extends StatefulWidget {
  final String? routeData;

  const RegistrationDetailPage({super.key, this.routeData});

  /// Factory สร้าง Page พร้อม Provider (ใช้ใน Navigator.push)
  static Widget create({
    Key? key,
    CustomerModel? customer,
    String title = 'รายละเอียดทะเบียนลูกค้า',
  }) {
    return ChangeNotifierProvider<RegistrationDetailViewModel>(
      create: (_) {
        final vm = RegistrationDetailViewModel();
        if (customer != null) vm.loadCustomer(customer);
        return vm;
      },
      child: _RegistrationDetailPageBody(title: title),
    );
  }

  @override
  State<RegistrationDetailPage> createState() => _RegistrationDetailPageState();
}

class _RegistrationDetailPageState extends State<RegistrationDetailPage> {
  @override
  Widget build(BuildContext context) {
    return RegistrationDetailPage.create(key: widget.key);
  }
}

/// Body จริง — ต้องอยู่ใต้ Provider เสมอ
class _RegistrationDetailPageBody extends StatefulWidget {
  final String title;

  const _RegistrationDetailPageBody({required this.title});

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
    final subtitle = step == 1 ? 'ข้อมูลลูกค้า' : 'ที่อยู่และสถานะ';

    return Scaffold(
      backgroundColor: RgColors.surface,
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
              currentStep: step,
              totalSteps: total,
              onPrev: step > 1 ? vm.previousDetailStep : null,
              onNext: step < total ? vm.nextDetailStep : null,
              onSave: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('บันทึกรายละเอียด (placeholder)'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
