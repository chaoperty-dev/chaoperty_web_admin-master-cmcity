// ============================================================================
// registration_page.dart
// ============================================================================
// Main View — "ทะเบียน" (Tab เดียว: ทะเบียนลูกค้า)
//
// ใช้งานได้ 2 รูปแบบ (เหมือน License_menu):
//   ✅ RegistrationPage.create(...) — สร้าง + wrap Provider ให้อัตโนมัติ (แนะนำ)
//   ✅ RegistrationHost(...)       — alias
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Bureau_Registration/Add_Custo_Screen.dart' as legacy
    show Add_Custo_Screen;
import '../models/registration_config.dart';
import '../models/registration_event.dart';
import '../viewmodels/registration_view_model.dart';
import 'theme/registration_theme.dart';
import 'registration_detail_page.dart';
import 'widgets/registration_add_page.dart';
import 'widgets/registration_header.dart';
import 'widgets/registration_pagination.dart';
import 'widgets/registration_search_bar.dart';
import 'widgets/registration_table.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage._();

  /// Factory สร้าง Page พร้อม Provider (ใช้ใน AdminScaffold / Navigator)
  static Widget create({
    Key? key,
    String? routeData,
    int? serTitle,
    String title = 'ทะเบียน',
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
      child: _RegistrationPageBody(title: title),
    );
  }

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  @override
  Widget build(BuildContext context) {
    return RegistrationPage.create(key: widget.key);
  }
}

/// Body จริง — ต้องอยู่ใต้ Provider เสมอ
class _RegistrationPageBody extends StatefulWidget {
  final String title;
  const _RegistrationPageBody({required this.title});

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
            backgroundColor: LaColors.statusRejectedFg,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(LaRadius.md),
            ),
          ),
        );
        break;
      case RegistrationNavigateEvent(:final routeData):
        Navigator.of(context).push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => RegistrationDetailPage.create(
              routeData: routeData,
              title: 'รายละเอียดทะเบียนลูกค้า',
            ),
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

  Future<void> _openAddCustomer() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => RegistrationAddPage.create(
          onSaveSuccess: (_) {
            // รีโหลดหลังบันทึก
            context.read<RegistrationViewModel>().refresh();
          },
        ),
      ),
    );
  }

  // Suppress unused import warning for legacy Add_Custo_Screen
  // (เก็บไว้ในกรณีที่ต้องการ fallback — ขณะนี้ใช้ RegistrationAddPage แทน)
  // ignore: unused_element
  void _legacyAdd() {
    legacy.Add_Custo_Screen;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistrationViewModel>();
    return Container(
      color: LaColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(LaSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RegistrationHeader(
              title: vm.title,
              subtitle: 'จัดการทะเบียนลูกค้าและข้อมูลการเช่า',
              totalCount: vm.total,
              onAdd: _openAddCustomer,
            ),
            const SizedBox(height: LaSpace.lg),
            // Search + Pagination row (pagination inline, ยืด/หุบอัตโนมัติ)
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: RegistrationSearchBar()),
                SizedBox(width: LaSpace.md),
                RegistrationPagination(),
              ],
            ),
            const SizedBox(height: LaSpace.lg),
            const Expanded(
              child: RegistrationTable(),
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

  const RegistrationHost({
    super.key,
    this.routeData,
    this.serTitle,
    this.title = 'ทะเบียน',
  });

  @override
  Widget build(BuildContext context) {
    return RegistrationPage.create(
      routeData: routeData,
      serTitle: serTitle,
      title: title,
    );
  }
}
