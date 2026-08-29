// ============================================================================
// license_submit_approval_page.dart
// ============================================================================
// Main View — "คำขอต่อสัญญา" (Tab แรก)
//
// ใช้งานได้ 2 รูปแบบ:
//   ✅ LicenseSubmitApprovalPage.create(...) — สร้าง + wrap Provider ให้อัตโนมัติ (แนะนำ)
//   ✅ LicenseSubmitApprovalHost(...)       — alias
//
// IMPORTANT: ห้าม new LicenseSubmitApprovalPage() ตรงๆ เพราะ child widgets
// จะเรียก context.watch<LicenseSubmitApprovalViewModel>() ซึ่งต้องการ Provider
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../license_contract_page/models/license_contract_result.dart';
import 'package:go_router/go_router.dart';
import '../models/license_submit_approval_config.dart';
import '../models/license_submit_approval_event.dart';
import '../viewmodels/license_submit_approval_view_model.dart';
import 'theme/license_submit_approval_theme.dart';
import 'widgets/license_submit_approval_header.dart';
import 'widgets/license_submit_approval_pagination.dart';
import 'widgets/license_submit_approval_search_bar.dart';
import 'widgets/license_submit_approval_table.dart';
import 'widgets/license_submit_approval_zone_filter.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// Public API
/// ═══════════════════════════════════════════════════════════════════════
class LicenseSubmitApprovalPage extends StatefulWidget {
  final ValueChanged<LicenseContractResult>? onSave;

  const LicenseSubmitApprovalPage._({super.key, this.onSave});

  /// Factory สร้าง Page พร้อม Provider (ใช้ใน AdminScaffold / Navigator)
  static Widget create({
    Key? key,
    String? routeData,
    int? serTitle,
    String title = 'ส่งคำร้องขออนุมัติ',
    ValueChanged<LicenseContractResult>? onSave,
    LicenseSubmitApprovalConfig? config,
  }) {
    final cfg = config ??
        LicenseSubmitApprovalConfig(
          title: title,
          routeData: routeData,
          serTitle: serTitle,
        );
    return ChangeNotifierProvider<LicenseSubmitApprovalViewModel>(
      create: (_) => LicenseSubmitApprovalViewModel(config: cfg),
      child: _LicenseSubmitApprovalPageBody(
        title: title,
        onSave: onSave,
      ),
    );
  }

  @override
  State<LicenseSubmitApprovalPage> createState() =>
      _LicenseSubmitApprovalPageState();
}

class _LicenseSubmitApprovalPageState extends State<LicenseSubmitApprovalPage> {
  @override
  Widget build(BuildContext context) {
    return LicenseSubmitApprovalPage.create(
      key: widget.key,
      onSave: widget.onSave,
    );
  }
}

/// Body จริง — ต้องอยู่ใต้ Provider เสมอ
class _LicenseSubmitApprovalPageBody extends StatefulWidget {
  final String title;
  final ValueChanged<LicenseContractResult>? onSave;

  const _LicenseSubmitApprovalPageBody({
    required this.title,
    this.onSave,
  });

  @override
  State<_LicenseSubmitApprovalPageBody> createState() =>
      _LicenseSubmitApprovalPageBodyState();
}

class _LicenseSubmitApprovalPageBodyState
    extends State<_LicenseSubmitApprovalPageBody> {
  StreamSubscription<LicenseSubmitApprovalEvent>? _sub;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<LicenseSubmitApprovalViewModel>();
    _sub ??= vm.events.listen(_onEvent);
  }

  void _onEvent(LicenseSubmitApprovalEvent event) {
    if (!mounted) return;
    switch (event) {
      case LicenseSubmitApprovalErrorEvent(:final message):
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
      case LicenseSubmitApprovalNavigateEvent(:final routeData):
        // ✅ GoRouter push — URL เปลี่ยนเป็น '/submit-approval/<uuid>'
        final title = context.read<LicenseSubmitApprovalViewModel>().title;
        context.push(
          routeData == null || routeData.isEmpty
              ? '/submit-approval'
              : '/submit-approval/${Uri.encodeComponent(routeData)}',
          extra: {'title': title},
        );
        break;
      case LicenseSubmitApprovalNavigateDetailEvent(
          :final paymentUuid,
          :final title
        ):
        // ✅ GoRouter push — URL เปลี่ยนเป็น '/submit-approval/<uuid>'
        context.push(
          paymentUuid == null || paymentUuid.isEmpty
              ? '/submit-approval'
              : '/submit-approval/${Uri.encodeComponent(paymentUuid)}',
          extra: {'title': title},
        );
        break;
      case LicenseSubmitApprovalCreatedEvent():
      case LicenseSubmitApprovalPaidEvent():
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
    return Container(
      color: LaColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(LaSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const LicenseSubmitApprovalHeader(
              subtitle:
                  'ส่งคำร้องขออนุมัติค่าธรรมเนียมใบอนุญาต — ตรวจสอบและบันทึกผลการอนุมัติ',
            ),
            const SizedBox(height: LaSpace.lg),
            const LicenseSubmitApprovalZoneFilter(),
            const SizedBox(height: LaSpace.md),
            // Search + Pagination row (pagination inline)
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: LicenseSubmitApprovalSearchBar()),
                SizedBox(width: LaSpace.md),
                LicenseSubmitApprovalPagination(),
              ],
            ),
            const SizedBox(height: LaSpace.lg),
            // ─── Scroll แนวตั้ง — table ปรับขนาดตาม parent ───
            Expanded(
              child: SingleChildScrollView(
                child: const LicenseSubmitApprovalTable(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Alias สำหรับเข้ากันได้กับ API เดิม
class LicenseSubmitApprovalHost extends StatelessWidget {
  final String? routeData;
  final int? serTitle;
  final String title;
  final ValueChanged<LicenseContractResult>? onSave;

  const LicenseSubmitApprovalHost({
    super.key,
    this.routeData,
    this.serTitle,
    this.title = 'ส่งคำร้องขออนุมัติ',
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return LicenseSubmitApprovalPage.create(
      routeData: routeData,
      serTitle: serTitle,
      title: title,
      onSave: onSave,
    );
  }
}
