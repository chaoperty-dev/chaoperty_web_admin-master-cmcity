// ============================================================================
// registration_detail_page.dart
// ============================================================================
// Full-page detail route (2-step) — เปิดแบบเต็มจอเหมือน "สร้างคำขอ" ของ License_menu
// - Step 1: ข้อมูลลูกค้า
// - Step 2: ที่อยู่ / สัญญา / สถานะ
// - ปิดได้ด้วย Navigator.pop (back button ใน header)
//
// ✅ โหลด customer จาก API GET /v1/admin/c-customers/{uuid}
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Model/GetCustomer_Model.dart';
import '../registration_page/services/registration_service.dart';
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
  ///
  /// ใช้ได้ 2 แบบ:
  /// - ส่ง `customer` (object) → โหลดจาก in-memory (legacy/quick)
  /// - ส่ง `uuid` → ดึงใหม่จาก GET /v1/admin/c-customers/{uuid}
  static Widget create({
    Key? key,
    CustomerModel? customer,
    String? uuid,
    String title = 'รายละเอียดทะเบียนลูกค้า',
    RegistrationService? service,
  }) {
    return ChangeNotifierProvider<RegistrationDetailViewModel>(
      create: (_) {
        final vm = RegistrationDetailViewModel(service: service);
        if (uuid != null && uuid.isNotEmpty) {
          // โหลด async — notifyListeners() จะ trigger rebuild
          vm.loadCustomerByUuid(uuid);
        } else if (customer != null) {
          vm.loadCustomer(customer);
        }
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
  Future<void> _confirmDelete(BuildContext context) async {
    final vm = context.read<RegistrationDetailViewModel>();
    final uuid = vm.customer?.uuid?.toString();
    if (uuid == null || uuid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ไม่พบ UUID ของลูกค้ารายนี้'),
          backgroundColor: RgColors.statusRejectedFg,
        ),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text(
          'ลบทะเบียนลูกค้า "'
          '${vm.customer?.sname ?? vm.customer?.cname ?? '-'}'
          '"?\n\nการลบไม่สามารถกู้คืนได้',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: RgColors.statusRejectedFg,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (!context.mounted) return;

    try {
      await RegistrationService().deleteCustomer(uuid);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ลบทะเบียนสำเร็จ'),
          backgroundColor: RgColors.statusApprovedFg,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ลบไม่สำเร็จ: $e'),
          backgroundColor: RgColors.statusRejectedFg,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistrationDetailViewModel>();
    final step = vm.currentDetailStep;
    final total = vm.totalDetailSteps;
    final subtitle = step == 1 ? 'ข้อมูลลูกค้า' : 'ที่อยู่และสถานะ';

    Widget body;
    if (vm.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (vm.error != null && vm.customer == null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(RgSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: RgColors.statusRejectedFg, size: 48),
              const SizedBox(height: RgSpace.md),
              Text(vm.error!, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    } else if (vm.customer == null) {
      body = const Center(child: Text('ไม่พบข้อมูลลูกค้า'));
    } else {
      body = step == 1
          ? const RegistrationDetailStep1()
          : const RegistrationDetailStep2();
    }

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
            Expanded(child: body),
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
              onDelete: vm.customer != null ? () => _confirmDelete(context) : null,
            ),
          ],
        ),
      ),
    );
  }
}
