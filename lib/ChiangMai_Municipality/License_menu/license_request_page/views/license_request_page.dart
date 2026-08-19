// ============================================================================
// license_request_page.dart
// ============================================================================
// Main View — "คำขอต่อสัญญา" (Tab แรก)
//
// ใช้งานได้ 2 รูปแบบ:
//   ✅ LicenseRequestPage.create(...) — สร้าง + wrap Provider ให้อัตโนมัติ (แนะนำ)
//   ✅ LicenseRequestHost(...)       — alias
//
// IMPORTANT: ห้าม new LicenseRequestPage() ตรงๆ เพราะ child widgets
// จะเรียก context.watch<LicenseRequestViewModel>() ซึ่งต้องการ Provider
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../license_contract_page/models/license_contract_result.dart';
import '../../license_contract_page/views/license_contract_page.dart';
import '../models/license_request_config.dart';
import '../models/license_request_event.dart';
import '../viewmodels/license_request_view_model.dart';
import 'theme/license_request_theme.dart';
import 'widgets/license_request_header.dart';
import 'widgets/license_request_pagination.dart';
import 'widgets/license_request_search_bar.dart';
import 'widgets/license_request_table.dart';
import 'widgets/license_request_zone_filter.dart';
import 'license_request_detail_page.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// Public API
/// ═══════════════════════════════════════════════════════════════════════
class LicenseRequestPage extends StatefulWidget {
  final String? routeData;
  final int? serTitle;
  final String title;
  final ValueChanged<LicenseContractResult>? onSave;
  final LicenseRequestConfig? config;

  const LicenseRequestPage({
    super.key,
    this.routeData,
    this.serTitle,
    this.title = 'คำขอต่อสัญญา',
    this.onSave,
    this.config,
  });

  /// Factory สร้าง Page พร้อม Provider (ใช้ใน AdminScaffold / Navigator)
  static Widget create({
    Key? key,
    String? routeData,
    int? serTitle,
    String title = 'คำขอต่อสัญญา',
    ValueChanged<LicenseContractResult>? onSave,
    LicenseRequestConfig? config,
  }) {
    return LicenseRequestPage(
      key: key,
      routeData: routeData,
      serTitle: serTitle,
      title: title,
      onSave: onSave,
      config: config,
    );
  }

  @override
  State<LicenseRequestPage> createState() => _LicenseRequestPageState();
}

class _LicenseRequestPageState extends State<LicenseRequestPage> {
  late LicenseRequestViewModel _vm;

  @override
  void initState() {
    super.initState();
    final cfg = widget.config ??
        LicenseRequestConfig(
          title: widget.title,
          routeData: widget.routeData,
          serTitle: widget.serTitle,
        );
    _vm = LicenseRequestViewModel(config: cfg);
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LicenseRequestViewModel>.value(
      value: _vm,
      child: _LicenseRequestPageBody(
        title: widget.title,
        onSave: widget.onSave,
      ),
    );
  }
}

/// Body จริง — ต้องอยู่ใต้ Provider เสมอ
class _LicenseRequestPageBody extends StatefulWidget {
  final String title;
  final ValueChanged<LicenseContractResult>? onSave;

  const _LicenseRequestPageBody({
    required this.title,
    this.onSave,
  });

  @override
  State<_LicenseRequestPageBody> createState() =>
      _LicenseRequestPageBodyState();
}

class _LicenseRequestPageBodyState extends State<_LicenseRequestPageBody> {
  StreamSubscription<LicenseRequestEvent>? _sub;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<LicenseRequestViewModel>();
    _sub ??= vm.events.listen(_onEvent);
  }

  void _onEvent(LicenseRequestEvent event) {
    if (!mounted) return;
    switch (event) {
      case LicenseRequestErrorEvent(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: LrColors.statusRejectedFg,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(LrRadius.md),
            ),
          ),
        );
        break;
      case LicenseRequestOpenCreatePopupEvent():
        _openCreatePopup();
        break;
      case LicenseRequestNavigateEvent(:final routeData):
        // เปิด full-page detail route (เต็มจอ)
        final title = context.read<LicenseRequestViewModel>().title;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LicenseRequestDetailPage.create(
              routeData: routeData,
              title: title,
            ),
            fullscreenDialog: true,
          ),
        );
        break;
    }
  }

  Future<void> _openCreatePopup() async {
    // เปิดเป็น full-page แทน dialog
    final result = await Navigator.of(context).push<LicenseContractResult>(
      MaterialPageRoute(
        builder: (_) => LicenseContractPage.create(),
        fullscreenDialog: true,
      ),
    );
    if (!mounted) return;
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('บันทึกคำขอสำเร็จ'),
          backgroundColor: LrColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LrRadius.md),
          ),
        ),
      );
      context.read<LicenseRequestViewModel>().refresh();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseRequestViewModel>();
    return Container(
      color: LrColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(LrSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LicenseRequestHeader(
              title: vm.title,
              subtitle: 'จัดการคำขอต่อสัญญาเช่าและติดตามสถานะ',
              totalCount: vm.total,
              onCreate: vm.onCreateRequest,
            ),
            const SizedBox(height: LrSpace.lg),
            const LicenseRequestZoneFilter(),
            const SizedBox(height: LrSpace.md),
            // Search + Pagination row (pagination inline)
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: LicenseRequestSearchBar()),
                SizedBox(width: LrSpace.md),
                LicenseRequestPagination(),
              ],
            ),
            const SizedBox(height: LrSpace.lg),
            // ─── Scroll แนวตั้ง (หลาย row) — table ปรับขนาดตาม parent ───
            const Expanded(
              child: SingleChildScrollView(
                child: LicenseRequestTable(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Alias สำหรับเข้ากันได้กับ API เดิม
class LicenseRequestHost extends StatelessWidget {
  final String? routeData;
  final int? serTitle;
  final String title;
  final ValueChanged<LicenseContractResult>? onSave;

  const LicenseRequestHost({
    super.key,
    this.routeData,
    this.serTitle,
    this.title = 'คำขอต่อสัญญา',
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return LicenseRequestPage.create(
      routeData: routeData,
      serTitle: serTitle,
      title: title,
      onSave: onSave,
    );
  }
}
