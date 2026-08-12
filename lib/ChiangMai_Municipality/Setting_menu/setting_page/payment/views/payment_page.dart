// ============================================================================
// payment_page.dart
// ============================================================================
// Main View — "การรับชำระ" (หน้าใหม่ใน setting_page)
//
// ใช้งานได้ 2 รูปแบบ (เหมือน LicenseRequestPage / AccessRightsPage / AreaPage):
//   ✅ PaymentPage.create(...) — สร้าง + wrap Provider ให้อัตโนมัติ
//   ✅ PaymentHost(...)       — alias
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/payment_config.dart';
import '../models/payment_event.dart';
import '../models/payment_payment_model.dart';
import '../services/payment_service.dart';
import '../viewmodels/payment_view_model.dart';
import 'theme/payment_theme.dart';
import 'widgets/payment_bank_dialog.dart';
import 'widgets/payment_banktype_dialog.dart';
import 'widgets/payment_form_dialog.dart';
import 'widgets/payment_header.dart';
import 'widgets/payment_pagination.dart';
import 'widgets/payment_paytype_dialog.dart';
import 'widgets/payment_search_bar.dart';
import 'widgets/payment_slip_dialog.dart';
import 'widgets/payment_table.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage._({super.key});

  static Widget create({
    String? routeData,
    String title = 'การรับชำระ',
    PaymentConfig? config,
  }) {
    final cfg = config ?? PaymentConfig(title: title, routeData: routeData);
    return ChangeNotifierProvider<PaymentViewModel>(
      create: (_) => PaymentViewModel(
        config: cfg,
        service: PaymentService(),
      ),
      child: const _PaymentPageBody(),
    );
  }

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    return PaymentPage.create();
  }
}

class _PaymentPageBody extends StatefulWidget {
  const _PaymentPageBody();

  @override
  State<_PaymentPageBody> createState() => _PaymentPageBodyState();
}

class _PaymentPageBodyState extends State<_PaymentPageBody> {
  StreamSubscription<PaymentEvent>? _sub;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<PaymentViewModel>();
    _sub ??= vm.events.listen(_onEvent);
  }

  void _onEvent(PaymentEvent event) {
    if (!mounted) return;
    switch (event) {
      case PaymentErrorEvent(:final message):
        _showSnack(message, PayColors.statusRejectedFg);
        break;
      case PaymentSuccessEvent(:final message):
        _showSnack(message, PayColors.primary);
        break;
      case PaymentOpenAddEvent():
        _openAddDialog();
        break;
      case PaymentOpenEditEvent(:final paymentSer):
        _openEditDialog(paymentSer);
        break;
      case PaymentOpenSlipEvent(:final paymentSer):
        _openSlipDialog(paymentSer);
        break;
      case PaymentOpenAddPayTypeEvent():
        _openAddPayTypeDialog();
        break;
      case PaymentOpenAddBankEvent():
        _openAddBankDialog();
        break;
      case PaymentOpenAddBankTypeEvent():
        _openAddBankTypeDialog();
        break;
    }
  }

  void _showSnack(String message, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PayRadius.md),
        ),
      ),
    );
  }

  Future<void> _openAddDialog() async {
    final vm = context.read<PaymentViewModel>();
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          PaymentFormDialog(mode: PaymentDialogMode.create, viewModel: vm),
    );
  }

  Future<void> _openEditDialog(String ser) async {
    final vm = context.read<PaymentViewModel>();
    final PaymentPaymentModel? p = vm.payments
        .where((e) => e.ser == ser)
        .firstOrNull;
    if (p == null) return;
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PaymentFormDialog(
        mode: PaymentDialogMode.edit,
        initial: p,
        viewModel: vm,
      ),
    );
  }

  Future<void> _openSlipDialog(String ser) async {
    final vm = context.read<PaymentViewModel>();
    final PaymentPaymentModel? p = vm.payments
        .where((e) => e.ser == ser)
        .firstOrNull;
    if (p == null) return;
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PaymentSlipDialog(payment: p, viewModel: vm),
    );
  }

  Future<void> _openAddPayTypeDialog() async {
    final vm = context.read<PaymentViewModel>();
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PaymentPayTypeDialog(viewModel: vm),
    );
  }

  Future<void> _openAddBankDialog() async {
    final vm = context.read<PaymentViewModel>();
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PaymentBankDialog(viewModel: vm),
    );
  }

  Future<void> _openAddBankTypeDialog() async {
    final vm = context.read<PaymentViewModel>();
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PaymentBankTypeDialog(viewModel: vm),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PaymentViewModel>();
    return Container(
      color: PayColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(PaySpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PaymentHeader(
              title: vm.title,
              subtitle: 'จัดการช่องทางการรับชำระ ประเภท และธนาคาร',
              totalCount: vm.payments.length,
              onAdd: vm.onAdd,
              onAddPayType: vm.onAddPayType,
              onAddBank: vm.onAddBank,
              onAddBankType: vm.onAddBankType,
            ),
            const SizedBox(height: PaySpace.lg),
            const Row(
              children: [
                Expanded(child: PaymentSearchBar()),
                SizedBox(width: PaySpace.md),
                PaymentPagination(),
              ],
            ),
            const SizedBox(height: PaySpace.md),
            const Expanded(child: PaymentTable()),
          ],
        ),
      ),
    );
  }
}

class PaymentHost extends StatelessWidget {
  final String? routeData;
  final String title;
  const PaymentHost({
    super.key,
    this.routeData,
    this.title = 'การรับชำระ',
  });

  @override
  Widget build(BuildContext context) {
    return PaymentPage.create(routeData: routeData, title: title);
  }
}
