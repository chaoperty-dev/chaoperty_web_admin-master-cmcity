// ============================================================================
// registration_page.dart
// ============================================================================
// Main View — "ทะเบียน" (Tab เดียว: ทะเบียนลูกค้า)
//
// ใช้งานได้ 2 รูปแบบ (เหมือน License_menu):
//   ✅ RegistrationPage.create(...) — สร้าง + wrap Provider ให้อัตโนมัติ (แนะนำ)
//   ✅ RegistrationHost(...)       — alias
//
// IMPORTANT: ห้าม new RegistrationPage() ตรงๆ เพราะ child widgets
// จะเรียก context.watch<RegistrationViewModel>() ซึ่งต้องการ Provider
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../License_menu/license_contract_page/models/license_contract_result.dart';
import '../models/registration_config.dart';
import '../models/registration_event.dart';
import '../viewmodels/registration_view_model.dart';
import 'theme/registration_theme.dart';
import 'registration_detail_page.dart';
import 'widgets/add_custo_rg_screen.dart';
import 'widgets/registration_header.dart';
import 'widgets/registration_search_bar.dart';
import 'widgets/registration_table.dart';

class RegistrationPage extends StatefulWidget {
  final ValueChanged<LicenseContractResult>? onSave;

  const RegistrationPage._({super.key, this.onSave});

  /// Factory สร้าง Page พร้อม Provider (ใช้ใน AdminScaffold / Navigator)
  static Widget create({
    Key? key,
    String? routeData,
    int? serTitle,
    String title = 'ทะเบียน',
    ValueChanged<LicenseContractResult>? onSave,
    RegistrationConfig? config,
  }) {
    final cfg = config ??
        RegistrationConfig(
          title: title,
          routeData: routeData,
          serTitle: serTitle,
        );
    return ChangeNotifierProvider<RegistrationViewModel>(
      create: (_) => RegistrationViewModel(config: cfg),
      child: _RegistrationPageBody(
        title: title,
        onSave: onSave,
      ),
    );
  }

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  @override
  Widget build(BuildContext context) {
    return RegistrationPage.create(
      key: widget.key,
      onSave: widget.onSave,
    );
  }
}

/// Body จริง — ต้องอยู่ใต้ Provider เสมอ
class _RegistrationPageBody extends StatefulWidget {
  final String title;
  final ValueChanged<LicenseContractResult>? onSave;

  const _RegistrationPageBody({
    required this.title,
    this.onSave,
  });

  @override
  State<_RegistrationPageBody> createState() => _RegistrationPageBodyState();
}

class _RegistrationPageBodyState extends State<_RegistrationPageBody> {
  StreamSubscription<RegistrationEvent>? _sub;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<RegistrationViewModel>();
    _sub ??= vm.events.listen(_onEvent);
  }

  void _onEvent(RegistrationEvent event) {
    if (!mounted) return;
    final vm = context.read<RegistrationViewModel>();
    switch (event) {
      case RegistrationErrorEvent(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: RgColors.statusRejectedFg,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RgRadius.md),
            ),
          ),
        );
        break;
      case RegistrationNavigateEvent(:final routeData):
        // เปิดหน้า Detail แบบ fullscreen route
        final customer = vm.findCustomerByUuid(routeData ?? '');
        if (customer != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => RegistrationDetailPage.create(customer: customer),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ไม่พบข้อมูลลูกค้า (uuid: ${routeData ?? '-'})'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RgRadius.md),
              ),
            ),
          );
        }
        break;
    }
  }

  Future<void> _openAddCustomer() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AddCustoRgScreen(
          onSaveSuccess: (_) {
            // รีโหลดหลังบันทึก
            context.read<RegistrationViewModel>().refresh();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistrationViewModel>();
    return Container(
      color: RgColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(RgSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RegistrationHeader(
              title: vm.title,
              subtitle: 'จัดการทะเบียนลูกค้าและข้อมูลการเช่า',
              totalCount: vm.total,
              onAdd: _openAddCustomer,
            ),
            const SizedBox(height: RgSpace.lg),

            // Search row (มี dropdown เลือก field + search box)
            const RegistrationSearchBar(),
            const SizedBox(height: RgSpace.lg),
            const Expanded(
              child: SingleChildScrollView(
                child: RegistrationTable(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Alias สำหรับเข้ากันได้กับ API เดิม
class RegistrationHost extends StatelessWidget {
  final String? routeData;
  final int? serTitle;
  final String title;
  final ValueChanged<LicenseContractResult>? onSave;

  const RegistrationHost({
    super.key,
    this.routeData,
    this.serTitle,
    this.title = 'ทะเบียน',
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return RegistrationPage.create(
      routeData: routeData,
      serTitle: serTitle,
      title: title,
      onSave: onSave,
    );
  }
}
