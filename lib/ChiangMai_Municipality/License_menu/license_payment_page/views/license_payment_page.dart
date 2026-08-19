// ============================================================================
// license_payment_page.dart
// ============================================================================
// Main View — "คำขอต่อสัญญา" (Tab แรก)
//
// ใช้งานได้ 2 รูปแบบ:
//   ✅ LicensePaymentPage.create(...) — สร้าง + wrap Provider ให้อัตโนมัติ (แนะนำ)
//   ✅ LicensePaymentHost(...)       — alias
//
// IMPORTANT: ห้าม new LicensePaymentPage() ตรงๆ เพราะ child widgets
// จะเรียก context.watch<LicensePaymentViewModel>() ซึ่งต้องการ Provider
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../license_contract_page/models/license_contract_result.dart';
import '../models/license_payment_config.dart';
import '../models/license_payment_event.dart';
import '../viewmodels/license_payment_view_model.dart';
import 'theme/license_payment_theme.dart';
import 'widgets/license_payment_header.dart';
import 'widgets/license_payment_pagination.dart';
import 'widgets/license_payment_search_bar.dart';
import 'widgets/license_payment_table.dart';
import 'widgets/license_payment_zone_filter.dart';
import 'license_payment_detail_page.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// Public API
/// ═══════════════════════════════════════════════════════════════════════
class LicensePaymentPage extends StatefulWidget {
  final ValueChanged<LicenseContractResult>? onSave;

  const LicensePaymentPage._({super.key, this.onSave});

  /// Factory สร้าง Page พร้อม Provider (ใช้ใน AdminScaffold / Navigator)
  static Widget create({
    Key? key,
    String? routeData,
    int? serTitle,
    String title = 'การรับชำระ',
    ValueChanged<LicenseContractResult>? onSave,
    LicensePaymentConfig? config,
  }) {
    final cfg = config ??
        LicensePaymentConfig(
          title: title,
          routeData: routeData,
          serTitle: serTitle,
        );
    return ChangeNotifierProvider<LicensePaymentViewModel>(
      create: (_) => LicensePaymentViewModel(config: cfg),
      child: _LicensePaymentPageBody(
        title: title,
        onSave: onSave,
      ),
    );
  }

  @override
  State<LicensePaymentPage> createState() => _LicensePaymentPageState();
}

class _LicensePaymentPageState extends State<LicensePaymentPage> {
  @override
  Widget build(BuildContext context) {
    return LicensePaymentPage.create(
      key: widget.key,
      onSave: widget.onSave,
    );
  }
}

/// Body จริง — ต้องอยู่ใต้ Provider เสมอ
class _LicensePaymentPageBody extends StatefulWidget {
  final String title;
  final ValueChanged<LicenseContractResult>? onSave;

  const _LicensePaymentPageBody({
    required this.title,
    this.onSave,
  });

  @override
  State<_LicensePaymentPageBody> createState() =>
      _LicensePaymentPageBodyState();
}

class _LicensePaymentPageBodyState extends State<_LicensePaymentPageBody> {
  StreamSubscription<LicensePaymentEvent>? _sub;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<LicensePaymentViewModel>();
    _sub ??= vm.events.listen(_onEvent);
  }

  void _onEvent(LicensePaymentEvent event) {
    if (!mounted) return;
    switch (event) {
      case LicensePaymentErrorEvent(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: LaColors.statusRejectedFg,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(LaRadius.md),
            ),
          ),
        );
        break;
      case LicensePaymentNavigateEvent(:final routeData):
        // เปิด full-page detail route (เต็มจอ)
        final title = context.read<LicensePaymentViewModel>().title;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LicensePaymentDetailPage.create(
              routeData: routeData,
              title: title,
            ),
            fullscreenDialog: true,
          ),
        );
        break;
      case LicensePaymentNavigateDetailEvent(
          :final paymentUuid, :final title
        ):
        // เปิดหน้า Detail ของ Payment detail
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LicensePaymentDetailPage.create(
              routeData: paymentUuid,
              title: title,
            ),
            fullscreenDialog: true,
          ),
        );
        break;
      case LicensePaymentCreatedEvent():
      case LicensePaymentPaidEvent():
        // แสดง snackbar success — viewmodel จะ refresh list อัตโนมัติ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('ดำเนินการสำเร็จ'),
            backgroundColor: LaColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicensePaymentViewModel>();
    return Container(
      color: LaColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(LaSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LicensePaymentHeader(
              title: vm.title,
              subtitle:
                  'รับชำระค่าธรรมเนียมใบอนุญาต — ตรวจสอบและบันทึกการชำระเงิน',
              totalCount: vm.total,
            ),
            const SizedBox(height: LaSpace.lg),
            const LicensePaymentZoneFilter(),
            const SizedBox(height: LaSpace.md),
            // Search + Pagination row (pagination inline)
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: LicensePaymentSearchBar()),
                SizedBox(width: LaSpace.md),
                LicensePaymentPagination(),
              ],
            ),
            const SizedBox(height: LaSpace.lg),
            // ─── Scroll แนวตั้ง — table ปรับขนาดตาม parent ───
            Expanded(
              child: SingleChildScrollView(
                child: const LicensePaymentTable(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Alias สำหรับเข้ากันได้กับ API เดิม
class LicensePaymentHost extends StatelessWidget {
  final String? routeData;
  final int? serTitle;
  final String title;
  final ValueChanged<LicenseContractResult>? onSave;

  const LicensePaymentHost({
    super.key,
    this.routeData,
    this.serTitle,
    this.title = 'การรับชำระ',
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return LicensePaymentPage.create(
      routeData: routeData,
      serTitle: serTitle,
      title: title,
      onSave: onSave,
    );
  }
}
