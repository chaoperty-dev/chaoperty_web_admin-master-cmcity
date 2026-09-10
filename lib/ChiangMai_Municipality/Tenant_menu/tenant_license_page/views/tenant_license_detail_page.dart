// ============================================================================
// tenant_license_detail_page.dart
// ============================================================================
// Full-page permit detail — 2 แท็บ (ข้อมูลใบอนุญาต / ประวัติการดำเนินการ)
// สไตล์ segmented control เดียวกับ attach_detail_step1
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tenant_permit_models.dart';
import '../viewmodels/tenant_license_detail_view_model.dart';
import 'theme/tenant_license_theme.dart';
import 'widgets/tenant_license_detail_header.dart';
import 'widgets/tenant_license_detail_step1.dart';
import 'widgets/tenant_license_detail_step2.dart';
import '../../../License_menu/license_submit_approval_request_page/views/widgets/submit_approval_detail_footer.dart';

class TenantLicenseDetailPage extends StatefulWidget {
  final String? routeData;
  final String title;
  final TenantPermitListItem? tenant;

  const TenantLicenseDetailPage({
    super.key,
    this.routeData,
    this.title = 'ข้อมูลใบอนุญาต',
    this.tenant,
  });

  static Widget create({
    Key? key,
    String? routeData,
    String title = 'ข้อมูลใบอนุญาต',
    TenantPermitListItem? tenant,
  }) {
    final permitUuid = routeData ?? tenant?.uuid ?? '';
    return ChangeNotifierProvider<TenantLicenseDetailViewModel>(
      create: (_) => TenantLicenseDetailViewModel(permitUuid: permitUuid),
      child: _TenantLicenseDetailPageBody(
        title: title,
        permitUuid: permitUuid,
      ),
    );
  }

  @override
  State<TenantLicenseDetailPage> createState() =>
      _TenantLicenseDetailPageState();
}

class _TenantLicenseDetailPageState extends State<TenantLicenseDetailPage> {
  @override
  Widget build(BuildContext context) {
    return TenantLicenseDetailPage.create(
      key: widget.key,
      routeData: widget.routeData,
      title: widget.title,
      tenant: widget.tenant,
    );
  }
}

class _TenantLicenseDetailPageBody extends StatelessWidget {
  final String title;
  final String permitUuid;

  const _TenantLicenseDetailPageBody({
    required this.title,
    required this.permitUuid,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TenantLicenseDetailViewModel>();
    final permit = vm.permit;
    return Scaffold(
      backgroundColor: LaColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TenantLicenseDetailHeader(
              title: title,
              subtitle: 'ข้อมูลใบอนุญาตและข้อมูลส่วนตัว',
              currentStep: vm.currentDetailStep,
              totalSteps: vm.totalDetailSteps,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: vm.isLoading && permit == null
                  ? const Center(child: CircularProgressIndicator())
                  : vm.error != null && permit == null
                      ? _ErrorState(message: vm.error!, onRetry: vm.retry)
                      : permit == null
                          ? const Center(child: Text('ไม่พบข้อมูลใบอนุญาต'))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: vm.currentDetailStep == 1
                                      ? TenantLicenseDetailStep1(permit: permit)
                                      : TenantLicenseDetailStep2(permit: permit),
                                ),
                                SubmitApprovalDetailFooter(
                                  readOnly: false,
                                  currentStep: vm.currentDetailStep,
                                  totalSteps: vm.totalDetailSteps,
                                  onNext: vm.currentDetailStep < vm.totalDetailSteps
                                      ? vm.nextDetailStep
                                      : null,
                                  onCancel: vm.currentDetailStep > 1
                                      ? vm.previousDetailStep
                                      : () => Navigator.of(context).maybePop(),
                                ),
                              ],
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: unused_element
class _TenantDetailFooter extends StatelessWidget {
  const _TenantDetailFooter();

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final isLast = controller.index >= 2;
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: LaSpace.lg,
            vertical: LaSpace.md,
          ),
          decoration: const BoxDecoration(
            color: LaColors.surfaceMuted,
            border: Border(top: BorderSide(color: LaColors.border)),
          ),
          child: Row(
            children: [
              Icon(
                isLast ? Icons.task_alt_rounded : Icons.edit_note_rounded,
                size: 14,
                color: LaColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                isLast ? 'โหมดดูอย่างเดียว' : 'กรอกข้อมูลให้ครบถ้วนก่อนกดถัดไป',
                style: LaText.caption,
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: controller.index == 0
                    ? () => Navigator.of(context).maybePop()
                    : () => controller.animateTo(controller.index - 1),
                icon: Icon(
                  controller.index == 0
                      ? Icons.close_rounded
                      : Icons.arrow_back_rounded,
                  size: 16,
                ),
                label: Text(controller.index == 0 ? 'ยกเลิก' : 'ย้อนกลับ'),
              ),
              if (!isLast) ...[
                const SizedBox(width: LaSpace.sm),
                FilledButton.icon(
                  onPressed: () => controller.animateTo(controller.index + 1),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: const Text('ถัดไป'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// Legacy tab widgets retained for old routes.
// ============================================================================
// ignore: unused_element
class _PermitTabBar extends StatelessWidget {
  final bool mobile;
  const _PermitTabBar({required this.mobile});

  @override
  Widget build(BuildContext context) {
    final tabController = DefaultTabController.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(LaSpace.lg, LaSpace.md, LaSpace.lg, 0),
      height: mobile ? 44 : 48,
      decoration: BoxDecoration(
        color: LaColors.surfaceMuted,
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(color: LaColors.border, width: 1),
      ),
      child: AnimatedBuilder(
        animation: tabController,
        builder: (context, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final selectedIndex = tabController.index;
              final tabWidth = (constraints.maxWidth - 8) / 2;
              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    top: 4,
                    bottom: 4,
                    left: 4 + (selectedIndex * tabWidth),
                    width: tabWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: LaColors.cardBg,
                        borderRadius: BorderRadius.circular(LaRadius.sm),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.06),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TabBar(
                    controller: tabController,
                    indicator: const BoxDecoration(),
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: LaColors.primaryDark,
                    unselectedLabelColor: LaColors.textSecondary,
                    labelStyle: LaText.body.copyWith(
                      fontFamily: LaText.fontBold,
                      fontWeight: FontWeight.w700,
                      fontSize: mobile ? 13 : 14,
                      height: 1.0,
                    ),
                    unselectedLabelStyle: LaText.body.copyWith(
                      fontFamily: LaText.fontBold,
                      fontWeight: FontWeight.w600,
                      fontSize: mobile ? 13 : 14,
                      height: 1.0,
                    ),
                    dividerColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    tabs: [
                      Tab(
                        height: double.infinity,
                        iconMargin: EdgeInsets.zero,
                        child: _PermitTabLabel(
                          icon: Icons.description_outlined,
                          label: 'ข้อมูลใบอนุญาต',
                          index: 0,
                          mobile: mobile,
                        ),
                      ),
                      Tab(
                        height: double.infinity,
                        iconMargin: EdgeInsets.zero,
                        child: _PermitTabLabel(
                          icon: Icons.person_outline_rounded,
                          label: 'ข้อมูลส่วนตัว',
                          index: 1,
                          mobile: mobile,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _PermitTabLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool mobile;
  const _PermitTabLabel({
    required this.icon,
    required this.label,
    required this.index,
    required this.mobile,
  });

  @override
  Widget build(BuildContext context) {
    final tabController = DefaultTabController.of(context);
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        final isActive = tabController.index == index;
        final color = isActive ? LaColors.primaryDark : LaColors.textSecondary;
        return Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: mobile ? 14 : 16, color: color),
              SizedBox(width: mobile ? 4 : 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontFamily: LaText.fontBold,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                    fontSize: mobile ? 12 : 13,
                    height: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// Error state
// ============================================================================
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 48, color: LaColors.statusRejectedFg),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: LaText.bodyMuted),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('ลองใหม่'),
          ),
        ],
      ),
    );
  }
}
