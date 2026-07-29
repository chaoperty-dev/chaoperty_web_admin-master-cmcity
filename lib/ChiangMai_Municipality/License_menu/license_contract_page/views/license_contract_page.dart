// ============================================================================
// license_contract_page.dart
// ============================================================================
// Main View — "หน้าสร้างสัญญา" (Step 1: ผู้เช่า)
//
// ใช้งานได้ 2 รูปแบบ (เหมือน license_request_page):
//   ✅ Fullpage: LicenseContractPage.create(config: ...) — wrap Provider ให้อัตโนมัติ
//   ✅ Fullpage: const LicenseContractPage(config: ...)  — auto-create VM ของตัวเอง
//
// IMPORTANT: ห้าม new LicenseContractPage() ตรงๆ เพราะ child widgets
// จะเรียก context.watch<LicenseContractViewModel>() ซึ่งต้องการ Provider
// ============================================================================

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Model/Properties_Model.dart';
import '../models/license_contract_config.dart';
import '../models/license_contract_event.dart';
import '../models/license_contract_result.dart';
import '../viewmodels/billing_view_model.dart';
import '../viewmodels/license_contract_view_model.dart';
import 'theme/license_contract_theme.dart';
import 'widgets/announcement_card.dart';
import 'widgets/area_info_card.dart';
import 'widgets/billing_table.dart';
import 'widgets/footer_actions.dart';
import 'widgets/form_contract_section.dart';
import 'widgets/form_person_section.dart';
import 'widgets/form_shop_section.dart';
import 'widgets/header_bar.dart';
import 'widgets/section_title.dart';
import 'widgets/zone_dropdown_row.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// Public API
/// ═══════════════════════════════════════════════════════════════════════
class LicenseContractPage extends StatefulWidget {
  /// Callback เมื่อบันทึกสำเร็จ
  final ValueChanged<LicenseContractResult>? onSave;

  /// Config (ใช้ตอนสร้าง ViewModel เอง)
  final LicenseContractConfig? config;

  const LicenseContractPage({
    super.key,
    this.onSave,
    this.config,
  });

  /// Factory สร้าง Page พร้อม Provider
  static Widget create({
    Key? key,
    bool readOnly = false,
    List<PropertiesModel>? properties,
    List<String>? initialPersonValues,
    List<String>? initialShopValues,
    List<String>? initialShopSubValues,
    List<Map<String, dynamic>>? initialCidValues,
    String? announcementMessage,
    String title = 'ผู้เช่า',
    ValueChanged<LicenseContractResult>? onSave,
    LicenseContractConfig? config,
  }) {
    final cfg = config ??
        LicenseContractConfig(
          readOnly: readOnly,
          properties: properties,
          initialPersonValues: initialPersonValues,
          initialShopValues: initialShopValues,
          initialShopSubValues: initialShopSubValues,
          initialCidValues: initialCidValues,
          announcementMessage: announcementMessage,
          title: title,
        );
    return ChangeNotifierProvider<LicenseContractViewModel>(
      create: (_) => LicenseContractViewModel(config: cfg),
      child: _LicenseContractPageBody(
        config: cfg,
        onSave: onSave,
      ),
    );
  }

  @override
  State<LicenseContractPage> createState() => _LicenseContractPageState();
}

/// Auto-create VM ถ้าไม่มี Provider (backward compatibility)
class _LicenseContractPageState extends State<LicenseContractPage> {
  StreamSubscription<LicenseContractEvent>? _sub;
  LicenseContractViewModel? _ownedVm;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ownedVm ??= _tryAdoptExistingVm() ?? _createOwnedVm();
    _sub ??= _ownedVm!.events.listen(_onEvent);
  }

  LicenseContractViewModel? _tryAdoptExistingVm() {
    try {
      return context.read<LicenseContractViewModel>();
    } catch (_) {
      return null;
    }
  }

  LicenseContractViewModel _createOwnedVm() {
    final cfg = widget.config ??
        const LicenseContractConfig(
          title: 'ผู้เช่า',
          readOnly: false,
        );
    return LicenseContractViewModel(config: cfg);
  }

  void _onEvent(LicenseContractEvent event) {
    if (!mounted) return;
    switch (event) {
      case LicenseContractErrorEvent(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: LcColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(LcRadius.md),
            ),
          ),
        );
        break;
      case LicenseContractSavedEvent(:final result):
        widget.onSave?.call(result);
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(result);
        }
        break;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _ownedVm?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = _ownedVm ?? context.watch<LicenseContractViewModel>();
    return _LicenseContractBody(vm: vm, onSave: widget.onSave);
  }
}

/// Body จริง — ต้องอยู่ใต้ Provider เสมอ
class _LicenseContractPageBody extends StatefulWidget {
  final LicenseContractConfig config;
  final ValueChanged<LicenseContractResult>? onSave;

  const _LicenseContractPageBody({
    required this.config,
    this.onSave,
  });

  @override
  State<_LicenseContractPageBody> createState() =>
      _LicenseContractPageBodyState();
}

class _LicenseContractPageBodyState extends State<_LicenseContractPageBody> {
  StreamSubscription<LicenseContractEvent>? _sub;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<LicenseContractViewModel>();
    _sub ??= vm.events.listen(_onEvent);
  }

  void _onEvent(LicenseContractEvent event) {
    if (!mounted) return;
    switch (event) {
      case LicenseContractErrorEvent(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: LcColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(LcRadius.md),
            ),
          ),
        );
        break;
      case LicenseContractSavedEvent(:final result):
        widget.onSave?.call(result);
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(result);
        }
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
    final vm = context.watch<LicenseContractViewModel>();
    return _LicenseContractBody(vm: vm, onSave: widget.onSave);
  }
}

/// Shared body — ใช้ทั้ง factory และ direct constructor
class _LicenseContractBody extends StatelessWidget {
  final LicenseContractViewModel vm;
  final ValueChanged<LicenseContractResult>? onSave;
  const _LicenseContractBody({required this.vm, this.onSave});

  @override
  Widget build(BuildContext context) {
    final mediaWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: LcColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HeaderBar(
              title: vm.title,
              subtitle: vm.currentPage == 1
                  ? 'กรอกข้อมูลผู้เช่า ร้านค้า และรายละเอียดสัญญา'
                  : 'ระบุรายละเอียดค่าบริการ',
              currentStep: vm.currentPage,
              totalSteps: vm.totalPages,
            ),
            Expanded(
              child: _Body(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(LcSpace.lg),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: vm.currentPage == 1
                          ? _buildStep1(context, vm, mediaWidth)
                          : _buildStep2(context, vm),
                    ),
                  ),
                ),
              ),
            ),
            FooterActions(
              readOnly: vm.readOnly,
              currentPage: vm.currentPage,
              totalPages: vm.totalPages,
              onNext: () {
                if (vm.validateForNext()) vm.nextPage();
              },
              onSave: vm.submit,
              onCancel: () {
                if (vm.currentPage > 1) {
                  vm.previousPage();
                } else if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1(
      BuildContext context, LicenseContractViewModel vm, double mediaWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ZoneDropdownRow(),
        const SizedBox(height: LcSpace.lg),
        if (vm.selectedLn != null) ...[
          const AreaInfoCard(),
          const SizedBox(height: LcSpace.lg),
        ],
        Container(
          decoration: LcDecor.card(),
          padding: const EdgeInsets.all(LcSpace.lg),
          child: mediaWidth < 1100
              // Mobile/tablet: stack vertically
              ? const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionTitle(icon: Icons.person, title: 'ข้อมูลผู้เช่า'),
                    FormPersonSection(),
                    SizedBox(height: LcSpace.lg),
                    AnnouncementCard(),
                    SizedBox(height: LcSpace.lg),
                    SectionTitle(icon: Icons.store, title: 'ข้อมูลร้านค้า'),
                    FormShopSection(),
                    SizedBox(height: LcSpace.lg),
                    SectionTitle(
                        icon: Icons.receipt_long, title: 'ข้อมูลสัญญา'),
                    FormContractSection(),
                  ],
                )
              // Desktop: 2 columns
              : const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionTitle(
                              icon: Icons.person, title: 'ข้อมูลผู้เช่า'),
                          FormPersonSection(),
                        ],
                      ),
                    ),
                    SizedBox(width: LcSpace.lg),
                    SizedBox(
                      width: 1,
                      height: 400,
                      child: ColoredBox(color: LcColors.border),
                    ),
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnnouncementCard(),
                          SizedBox(height: LcSpace.lg),
                          SectionTitle(
                              icon: Icons.store, title: 'ข้อมูลร้านค้า'),
                          FormShopSection(),
                          SizedBox(height: LcSpace.lg),
                          SectionTitle(
                              icon: Icons.receipt_long, title: 'ข้อมูลสัญญา'),
                          FormContractSection(),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  /// Step 2 — หน้ารายละเอียดค่าบริการ (BillingTable)
  Widget _buildStep2(BuildContext context, LicenseContractViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ─── Section title ───
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: LcSpace.md, vertical: LcSpace.sm),
          decoration: BoxDecoration(
            color: LcColors.primaryLight.withOpacity(.25),
            borderRadius: BorderRadius.circular(LcRadius.md),
          ),
          child: const Row(
            children: [
              Icon(Icons.receipt_long_rounded,
                  size: 18, color: LcColors.primaryDark),
              SizedBox(width: 8),
              Text(
                'รายละเอียดค่าบริการ',
                style: LcText.h2,
              ),
            ],
          ),
        ),
        const SizedBox(height: LcSpace.md),

        // ─── Card: BillingTable (MVVM via Provider) ───
        Container(
          decoration: LcDecor.card(),
          padding: const EdgeInsets.all(LcSpace.md),
          child: ChangeNotifierProvider<BillingViewModel>(
            create: (_) => BillingViewModel(
              cidSdate: vm.cidSdate,
              cidLdate: vm.cidLdate,
              cidZser: vm.cidZser,
            )..load(),
            child: BillingTable(
              onRowsChanged: (rows) {
                // Optional: callback เมื่อ rows เปลี่ยน
                // vm.setBillingRows(rows);
              },
            ),
          ),
        ),

        const SizedBox(height: LcSpace.md),

        // ─── info row ───
        const Row(
          children: [
            Icon(Icons.info_outline_rounded,
                size: 14, color: LcColors.textMuted),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'เมื่อกรอกค่าบริการครบ กดปุ่ม "บันทึก" ด้านล่างเพื่อบันทึกสัญญา',
                style: LcText.caption,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Body ที่ห่อ ScrollConfiguration — แยกเพื่อให้ main View สั้น
class _Body extends StatelessWidget {
  final Widget child;
  const _Body({required this.child});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        },
      ),
      child: child,
    );
  }
}
