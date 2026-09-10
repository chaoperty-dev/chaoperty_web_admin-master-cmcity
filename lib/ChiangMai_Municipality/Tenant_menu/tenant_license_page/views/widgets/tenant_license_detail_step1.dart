import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../models/tenant_permit_models.dart';
import '../../viewmodels/tenant_license_detail_view_model.dart';
import '../../../../License_menu/license_verify_page/models/license_verify_checklist_model.dart';
import '../../../../License_menu/license_verify_page/viewmodels/license_verify_detail_view_model.dart';
import '../../../../License_menu/license_verify_page/views/widgets/verify_detail_footer.dart';
import '../../../../License_menu/license_verify_page/views/widgets/verify_detail_step2.dart';
import '../../../../License_menu/license_payment_page/viewmodels/license_payment_detail_view_model.dart';
import '../../../../License_menu/license_payment_page/views/widgets/payment_detail_footer.dart';
import '../../../../License_menu/license_payment_page/views/widgets/payment_detail_header.dart';
import '../../../../License_menu/license_payment_page/views/widgets/payment_detail_step2.dart';
import '../theme/tenant_license_theme.dart';
import 'tenant_license_detail_personal.dart';

// Payment receipt viewer reuses the canonical payment detail screen.

/// Step 1 — ข้อมูลใบอนุญาต (redesigned)
/// - Hero gradient card: permit no + status + validity
/// - Section cards with responsive info grid
/// - Document rows with PDF preview in-app
/// - Payment rows with amount highlight
class _Step1Tabs extends StatelessWidget {
  const _Step1Tabs();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: LaSpace.md),
      height: 44,
      decoration: BoxDecoration(
        color: LaColors.surfaceMuted,
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(color: LaColors.border, width: 1),
      ),
      child: Builder(
        builder: (context) {
          final controller = DefaultTabController.of(context);
          return AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final selectedIndex = controller.index;
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
                        controller: controller,
                        indicator: const BoxDecoration(),
                        indicatorSize: TabBarIndicatorSize.label,
                        labelColor: LaColors.primaryDark,
                        unselectedLabelColor: LaColors.textSecondary,
                        labelStyle: LaText.body.copyWith(
                          fontFamily: LaText.fontBold,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          height: 1.0,
                        ),
                        unselectedLabelStyle: LaText.body.copyWith(
                          fontFamily: LaText.fontBold,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          height: 1.0,
                        ),
                        dividerColor: Colors.transparent,
                        splashFactory: NoSplash.splashFactory,
                        overlayColor:
                            WidgetStateProperty.all(Colors.transparent),
                        tabs: const [
                          Tab(
                            height: double.infinity,
                            iconMargin: EdgeInsets.zero,
                            child: _Step1TabLabel(
                              icon: Icons.description_outlined,
                              label: 'ข้อมูลใบอนุญาต',
                              index: 0,
                            ),
                          ),
                          Tab(
                            height: double.infinity,
                            iconMargin: EdgeInsets.zero,
                            child: _Step1TabLabel(
                              icon: Icons.person_outline_rounded,
                              label: 'ข้อมูลส่วนตัว',
                              index: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _Step1TabLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;

  const _Step1TabLabel({
    required this.icon,
    required this.label,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final isActive = controller.index == index;
        final color = isActive ? LaColors.primaryDark : LaColors.textSecondary;
        return Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontFamily: LaText.fontBold,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 13,
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

class TenantLicenseDetailStep1 extends StatelessWidget {
  final TenantPermitDetail permit;

  const TenantLicenseDetailStep1({super.key, required this.permit});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Step1Tabs(),
          Expanded(
            child: TabBarView(
              physics: const BouncingScrollPhysics(),
              children: [
                _Step1LicenseTab(permit: permit),
                TenantLicenseDetailPersonal(permit: permit),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Step1LicenseTab extends StatelessWidget {
  final TenantPermitDetail permit;

  const _Step1LicenseTab({required this.permit});

  static String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'issued':
        return 'ออกใบอนุญาตแล้ว';
      case 'pending':
        return 'รอดำเนินการ';
      case 'failed':
        return 'ดำเนินการไม่สำเร็จ';
      default:
        return status.isEmpty ? 'ไม่ระบุ' : status;
    }
  }

  static String _value(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty || text == 'null' ? '-' : text;
  }

  static String _date(dynamic value) {
    final text = _value(value);
    if (text == '-') return text;
    try {
      final date = DateTime.parse(text).toLocal();
      return '${date.day.toString().padLeft(2, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-${date.year + 543}';
    } catch (_) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailVm = context.watch<TenantLicenseDetailViewModel>();
    final payments =
        detailVm.payments.isNotEmpty ? detailVm.payments : permit.payments;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(LaSpace.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StatusBanner(permit: permit),
              const SizedBox(height: LaSpace.md),
              // _PermitHero(permit: permit),
              // const SizedBox(height: LaSpace.lg),
              _AttachRequestOverviewCard(permit: permit),
              // const SizedBox(height: LaSpace.lg),
              // LayoutBuilder(builder: (context, constraints) {
              //   final twoColumn = constraints.maxWidth >= 900;
              //   final holderSection = _SectionBlock(
              //     icon: Icons.person_outline_rounded,
              //     title: 'ข้อมูลผู้ถือใบอนุญาต',
              //     color: LaColors.primary,
              //     child: _InfoGrid(items: [
              //       _Entry('ชื่อผู้ถือ', _value(permit.customer['cname'] ?? permit.customerName)),
              //       _Entry('ชื่อร้าน', _value(permit.customer['scname'])),
              //       _Entry('เลขประจำตัวผู้เสียภาษี', _value(permit.customer['tax'] ?? permit.customer['taxno']), mono: true),
              //       _Entry('เบอร์โทร', _value(permit.customer['tel']), mono: true),
              //       _Entry('สัญชาติ', _value(permit.customer['national'])),
              //       _Entry('ที่อยู่', _address(permit), fullWidth: true),
              //     ]),
              //   );
              //   final areaSection = _SectionBlock(
              //     icon: Icons.location_on_outlined,
              //     title: 'พื้นที่และสัญญา',
              //     color: LaColors.statusInfoFg,
              //     child: _InfoGrid(items: [
              //       _Entry('บริเวณ', _value(permit.details['subzone'])),
              //       _Entry('โซน', _value(permit.details['zn'] ?? permit.zoneId)),
              //       _Entry('รหัสพื้นที่', _value(permit.details['ln'] ?? permit.lockCode), mono: true),
              //       _Entry('ขนาดพื้นที่', _value(permit.details['qty'])),
              //       _Entry('วันที่เริ่มต้น', _date(permit.details['sdate'] ?? permit.validFrom), mono: true),
              //       _Entry('วันที่สิ้นสุด', _date(permit.details['ldate'] ?? permit.validUntil), mono: true),
              //     ]),
              //   );
              //   return twoColumn
              //       ? Row(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Expanded(child: holderSection),
              //             const SizedBox(width: LaSpace.lg),
              //             Expanded(child: areaSection),
              //           ],
              //         )
              //       : Column(
              //           children: [
              //             holderSection,
              //             const SizedBox(height: LaSpace.lg),
              //             areaSection,
              //           ],
              //         );
              // }),
              const SizedBox(height: LaSpace.lg),
              _SectionBlock(
                icon: Icons.description_outlined,
                title: 'เอกสารระบบ',
                color: LaColors.statusPendingFg,
                child: Column(
                  children: [
                    _DocumentRow(
                      permitUuid: permit.uuid,
                      icon: Icons.workspace_premium_rounded,
                      iconColor: LaColors.statusApprovedFg,
                      iconBg: LaColors.statusApprovedBg,
                      title: 'ใบอนุญาต',
                      subtitle: _value(
                          permit.document['document_no'] ?? permit.permitNo),
                      path: 'preview/vendor-license',
                    ),
                    const SizedBox(height: LaSpace.sm),
                    _DocumentRow(
                      permitUuid: permit.uuid,
                      icon: Icons.request_page_rounded,
                      iconColor: LaColors.statusInfoFg,
                      iconBg: LaColors.statusInfoBg,
                      title: 'คำขอใบอนุญาต',
                      subtitle: 'เอกสารคำขอที่เกี่ยวข้อง',
                      path: 'preview/request-vendor-license',
                    ),
                    const SizedBox(height: LaSpace.sm),
                    _DocumentRow(
                      permitUuid: permit.uuid,
                      icon: Icons.article_rounded,
                      iconColor: LaColors.statusPendingFg,
                      iconBg: LaColors.statusPendingBg,
                      title: 'บันทึกข้อความ',
                      subtitle: 'บันทึกข้อความราชการ',
                      path: 'preview/memo-vendor-license',
                    ),
                  ],
                ),
              ),

              if (payments.isNotEmpty) ...[
                const SizedBox(height: LaSpace.lg),
                _PaymentStatusCard(
                  permitUuid: permit.uuid,
                  payments: payments,
                ),
              ],

              if (permit.attachments.isNotEmpty) ...[
                const SizedBox(height: LaSpace.lg),
                _SectionBlock(
                  icon: Icons.attach_file_rounded,
                  title: 'เอกสารที่แนบ',
                  color: LaColors.statusInfoFg,
                  child: _AttachmentsTable(
                    permitUuid: permit.uuid,
                    requestUuid: permit.requestUuid,
                    checklist: permit.checklist,
                    attachments: permit.attachments,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Permit overview card — copied from attach_detail_step1
// ============================================================================
class _AttachRequestOverviewCard extends StatelessWidget {
  final TenantPermitDetail permit;

  const _AttachRequestOverviewCard({required this.permit});

  @override
  Widget build(BuildContext context) {
    final status =
        permit.status.trim().isEmpty ? 'กำลังรอตรวจสอบ' : permit.status;
    final zone = [
      _value(permit.details['subzone']),
      _value(permit.details['zn'] ?? permit.zoneId),
    ].where((value) => value != '-').join(' / ');

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: LaDecor.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _AttachOverviewStatus(
                label: _Step1LicenseTab._statusLabel(status),
              ),
              const Spacer(),
              _AttachOverviewPill(
                icon: Icons.tag_rounded,
                label: 'รหัสรายการ: ${_short(permit.uuid)}',
                copyValue: permit.uuid,
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 650;
              final request = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _AttachOverviewHeading('ข้อมูลพื้นที่'),
                  const SizedBox(height: 6),
                  _AttachOverviewInfo(
                    icon: Icons.location_on_rounded,
                    label: 'บริเวณ / โซน',
                    value: zone,
                  ),
                  const SizedBox(height: 5),
                  _AttachOverviewInfo(
                    icon: Icons.tag_rounded,
                    label: 'รหัสพื้นที่',
                    value: _value(permit.details['ln'] ?? permit.lockCode),
                  ),
                ],
              );
              final customer = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _AttachOverviewHeading('ข้อมูลผู้เช่า'),
                  const SizedBox(height: 6),
                  _AttachOverviewInfo(
                    icon: Icons.person_rounded,
                    label: 'ชื่อผู้ติดต่อ',
                    value:
                        _value(permit.customer['cname'] ?? permit.customerName),
                  ),
                  const SizedBox(height: 5),
                  _AttachOverviewInfo(
                    icon: Icons.badge_outlined,
                    label: 'เลขประจำตัวผู้เสียภาษี',
                    value: _value(
                        permit.customer['tax'] ?? permit.customer['taxno']),
                  ),
                ],
              );
              return narrow
                  ? Column(
                      children: [request, const SizedBox(height: 12), customer],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: request),
                        const SizedBox(width: 32),
                        Expanded(child: customer),
                      ],
                    );
            },
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: LaColors.surfaceMuted,
              borderRadius: BorderRadius.circular(LaRadius.sm),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 14, color: LaColors.textMuted),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'ข้อมูลด้านบนเป็น "ภาพรวมใบอนุญาต" สำหรับตรวจสอบเบื้องต้น',
                    style: LaText.caption,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _value(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty || text == 'null' ? '-' : text;
  }

  static String _short(String value) =>
      value.length <= 12 ? value : '${value.substring(0, 8)}…';
}

class _AttachOverviewHeading extends StatelessWidget {
  final String text;

  const _AttachOverviewHeading(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: LaText.label.copyWith(
          color: LaColors.primaryDark,
          letterSpacing: .8,
        ),
      );
}

class _AttachOverviewInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _AttachOverviewInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: LaColors.primaryLight,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 15, color: LaColors.primaryDark),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: LaText.caption),
                Text(
                  value.isEmpty ? '-' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LaText.tableCell.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      );
}

class _AttachOverviewPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String copyValue;

  const _AttachOverviewPill({
    required this.icon,
    required this.label,
    required this.copyValue,
  });

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: copyValue));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('คัดลอกรหัสรายการแล้ว'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Tooltip(
        message: 'คัดลอกรหัสรายการ',
        child: InkWell(
          onTap: copyValue.isEmpty ? null : () => _copy(context),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: LaColors.surfaceMuted,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: LaColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 13, color: LaColors.textSecondary),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: LaText.caption.copyWith(
                    color: LaColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _AttachOverviewStatus extends StatelessWidget {
  final String label;

  const _AttachOverviewStatus({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: LaColors.statusPendingBg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: LaColors.statusPendingFg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(label,
                style: LaText.label.copyWith(color: LaColors.statusPendingFg)),
          ],
        ),
      );
}

// ============================================================================
// Status banner + overview card — สไตล์เดียวกับ verify_detail_step1
// ============================================================================
class _StatusBanner extends StatelessWidget {
  final TenantPermitDetail permit;

  const _StatusBanner({required this.permit});

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 700;
    final palette = StatusPalette.of(permit.status);
    final statusPill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: LaDecor.pill(palette.bg, palette.fg),
      child: Text(
        _Step1LicenseTab._statusLabel(permit.status),
        style: LaText.caption.copyWith(
          color: palette.fg,
          fontFamily: LaText.fontBold,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? LaSpace.sm : LaSpace.md,
        vertical: LaSpace.sm,
      ),
      decoration: BoxDecoration(
        color: LaColors.statusApprovedFg.withOpacity(.08),
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(
          color: LaColors.statusApprovedFg.withOpacity(.35),
          width: 1,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const Text('สถานะใบอนุญาต', style: LaText.caption),
              Text(
                permit.permitNo.isEmpty ? '-' : permit.permitNo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LaText.tableCell.copyWith(fontWeight: FontWeight.w700),
              ),

              //  _HeroStat('มีผลถึง', _shortDate(permit.validUntil)),
              Text(
                'มีผล: ${_Step1LicenseTab._date(permit.validFrom)} ถึง ${_Step1LicenseTab._date(permit.validUntil)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LaText.caption,
              ),
            ],
          );

          if (constraints.maxWidth < 500) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      // decoration: BoxDecoration(
                      //   color: palette.bg,
                      //   borderRadius: BorderRadius.circular(LaRadius.sm),
                      // ),
                      child: const Icon(
                        Icons.verified_outlined,
                        color: LaColors.primaryDark,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: LaSpace.sm),
                    Expanded(child: details),
                  ],
                ),
                const SizedBox(height: LaSpace.sm),
                // Align(alignment: Alignment.centerRight, child: statusPill),
              ],
            );
          }

          return Row(
            children: [
              Container(
                width: 30,
                height: 30,
                // decoration: BoxDecoration(
                //   color: palette.bg,
                //   borderRadius: BorderRadius.circular(LaRadius.sm),
                // ),
                child: const Icon(
                  Icons.verified_outlined,
                  color: LaColors.primaryDark,
                  size: 16,
                ),
              ),
              const SizedBox(width: LaSpace.sm),
              Expanded(child: details),
              const SizedBox(width: LaSpace.sm),
              // statusPill,
            ],
          );
        },
      ),
    );
  }
}

class _PermitHero extends StatelessWidget {
  final TenantPermitDetail permit;

  const _PermitHero({required this.permit});

  @override
  Widget build(BuildContext context) {
    final palette = StatusPalette.of(permit.status);
    final shopName = _Step1LicenseTab._value(permit.customer['scname']);

    return Container(
      padding: const EdgeInsets.all(LaSpace.xl),
      decoration: LaDecor.card(radius: LaRadius.lg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 620;
          final identity = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: LaColors.primaryLight,
                  borderRadius: BorderRadius.circular(LaRadius.md),
                ),
                child: const Icon(
                  Icons.verified_outlined,
                  color: LaColors.primaryDark,
                  size: 30,
                ),
              ),
              const SizedBox(width: LaSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('เลขที่ใบอนุญาต', style: LaText.caption),
                    const SizedBox(height: 2),
                    Text(
                      _Step1LicenseTab._value(permit.permitNo),
                      style: LaText.h1.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'ผู้ถือ: ${_Step1LicenseTab._value(permit.customerName)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LaText.bodyMuted,
                    ),
                    Text(
                      'ร้าน: $shopName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LaText.bodyMuted,
                    ),
                  ],
                ),
              ),
            ],
          );

          final stats = Wrap(
            spacing: LaSpace.xl,
            runSpacing: LaSpace.md,
            children: [
              _HeroStat(
                'สถานะ',
                _Step1LicenseTab._statusLabel(permit.status),
                pillColor: palette,
              ),
              _HeroStat('มีผลถึง', _shortDate(permit.validUntil)),
              if (permit.issuedBy.isNotEmpty)
                _HeroStat('ออกโดย', permit.issuedBy),
              if (permit.failureMessage.isNotEmpty)
                _HeroStat(
                  'ข้อผิดพลาด',
                  permit.failureMessage,
                  pillColor: StatusPalette.of('failed'),
                ),
            ],
          );

          return narrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    identity,
                    const SizedBox(height: LaSpace.lg),
                    stats
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: identity),
                    const SizedBox(width: LaSpace.xl),
                    Flexible(child: stats),
                  ],
                );
        },
      ),
    );
  }

  String _shortDate(String value) {
    if (value.isEmpty) return '-';
    try {
      final date = DateTime.parse(value).toLocal();
      return '${date.day.toString().padLeft(2, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-${date.year + 543}';
    } catch (_) {
      return '-';
    }
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final StatusPalette? pillColor;

  const _HeroStat(this.label, this.value, {this.pillColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: LaText.label),
        const SizedBox(height: 3),
        pillColor == null
            ? Text(
                value,
                style: LaText.tableCell.copyWith(
                  fontFamily: LaText.fontBold,
                  fontWeight: FontWeight.w700,
                ),
              )
            : Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: LaDecor.pill(pillColor!.bg, pillColor!.fg),
                child: Text(
                  value,
                  style: LaText.caption.copyWith(
                    color: pillColor!.fg,
                    fontFamily: LaText.fontBold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
      ],
    );
  }
}

// ============================================================================
// Section + info grid
// ============================================================================
class _SectionBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget child;

  const _SectionBlock({
    required this.icon,
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(LaRadius.md),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(title, style: LaText.h2.copyWith(color: color)),
            ],
          ),
        ),
        const SizedBox(height: LaSpace.sm),
        Container(
          decoration: LaDecor.card(),
          padding: const EdgeInsets.all(LaSpace.lg),
          child: child,
        ),
      ],
    );
  }
}

class _Entry {
  final String label;
  final String value;
  final bool mono;
  final bool fullWidth;

  const _Entry(this.label, this.value,
      {this.mono = false, this.fullWidth = false});
}

class _InfoGrid extends StatelessWidget {
  final List<_Entry> items;

  const _InfoGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 14,
      children: [
        for (final item in items)
          SizedBox(
            width: item.fullWidth ? double.infinity : 300,
            child: _EntryTile(item),
          ),
      ],
    );
  }
}

class _EntryTile extends StatelessWidget {
  final _Entry item;

  const _EntryTile(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: LaColors.surface,
        borderRadius: BorderRadius.circular(LaRadius.sm),
        border: Border.all(color: LaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.label, style: LaText.caption),
          const SizedBox(height: 2),
          Text(
            item.value,
            maxLines: item.fullWidth ? 4 : 2,
            overflow: TextOverflow.ellipsis,
            style: LaText.tableCell.copyWith(
              fontWeight: FontWeight.w600,
              fontFamily: item.mono ? 'monospace' : LaText.fontRegular,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentsTable extends StatelessWidget {
  final String permitUuid;
  final String requestUuid;
  final Map<String, dynamic> checklist;
  final List<Map<String, dynamic>> attachments;

  const _AttachmentsTable({
    required this.permitUuid,
    required this.requestUuid,
    required this.checklist,
    required this.attachments,
  });

  Future<void> _openChecklist(BuildContext context) async {
    if (checklist.isEmpty) return;

    final preview = LicenseverifyChecklistPreview.fromSavedJson({
      ...checklist,
      if (!checklist.containsKey('request_uuid') ||
          checklist['request_uuid'] == null ||
          checklist['request_uuid'].toString().trim().isEmpty)
        'request_uuid': requestUuid,
    });

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => LicenseverifyDetailViewModel(
            requestUuid: preview.requestUuid,
            initialChecklist: preview,
          ),
          child: const _TenantChecklistPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 700;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.folder_open_rounded,
                size: 18, color: LaColors.primaryDark),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'เอกสารทั้งหมด (${attachments.length} รายการ)',
                style: LaText.h2.copyWith(fontSize: mobile ? 13 : 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _TenantViewButton(
              onTap: checklist.isEmpty ? null : () => _openChecklist(context),
              label: 'เรียกดูเอกสารเช็กลิสต์',
              icon: Icons.visibility_outlined,
              loading: false,
            ),
          ],
        ),
        const SizedBox(height: LaSpace.sm),
        if (!mobile) const _AttachmentColumnHeader(),
        if (!mobile) const Divider(height: 1, color: LaColors.border),
        for (var i = 0; i < attachments.length; i++) ...[
          _AttachmentRow(
            permitUuid: permitUuid,
            attachment: attachments[i],
            index: i,
            mobile: mobile,
          ),
          if (i < attachments.length - 1)
            const Divider(height: 1, color: LaColors.border),
        ],
      ],
    );
  }
}

class _TenantViewButton extends StatefulWidget {
  final VoidCallback? onTap;
  final String label;
  final IconData icon;
  final bool loading;

  const _TenantViewButton({
    required this.onTap,
    required this.label,
    required this.icon,
    required this.loading,
  });

  @override
  State<_TenantViewButton> createState() => _TenantViewButtonState();
}

class _TenantViewButtonState extends State<_TenantViewButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (enabled) setState(() => _hover = true);
      },
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _hover ? LaColors.primary : LaColors.surfaceMuted,
            borderRadius: BorderRadius.circular(LaRadius.pill),
            border: Border.all(
              color: _hover ? LaColors.primary : LaColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 13,
                height: 13,
                child: widget.loading
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : Icon(
                        widget.icon,
                        size: 13,
                        color: _hover ? Colors.white : LaColors.textSecondary,
                      ),
              ),
              const SizedBox(width: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: LaText.fontBold,
                  fontSize: 11,
                  color: _hover ? Colors.white : LaColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TenantChecklistPage extends StatelessWidget {
  const _TenantChecklistPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LaColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [LaColors.headerBg, LaColors.headerAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: LaColors.primary.withOpacity(.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'กลับไปหน้ารายละเอียด',
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: LaColors.textInverse),
                  ),
                  const SizedBox(width: LaSpace.sm),
                  const Icon(Icons.fact_check_rounded,
                      color: LaColors.primaryAccent),
                  const SizedBox(width: LaSpace.sm),
                  const Expanded(
                    child: Text(
                      'สรุปการแนบเอกสาร',
                      style: TextStyle(
                        color: LaColors.textInverse,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(child: VerifyDetailStep2()),
            VerifyDetailFooter(
              readOnly: true,
              currentStep: 2,
              totalSteps: 2,
              onCancel: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentColumnHeader extends StatelessWidget {
  const _AttachmentColumnHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: LaSpace.sm),
      color: LaColors.surfaceMuted,
      child: const Row(
        children: [
          Expanded(
              flex: 3, child: Text('ชื่อเอกสาร', style: LaText.tableHeader)),
          Expanded(
              flex: 2, child: Text('วันที่ตรวจสอบ', style: LaText.tableHeader)),
          Expanded(
              flex: 2, child: Text('ผู้ตรวจสอบ', style: LaText.tableHeader)),
          Expanded(flex: 2, child: Text('สถานะ', style: LaText.tableHeader)),
          SizedBox(width: 92, child: Text('', style: LaText.tableHeader)),
        ],
      ),
    );
  }
}

class _AttachmentPreviewDialog extends StatefulWidget {
  final String title;
  final String fileName;
  final String fileType;
  final String status;
  final Uint8List bytes;

  const _AttachmentPreviewDialog({
    required this.title,
    required this.fileName,
    required this.fileType,
    required this.status,
    required this.bytes,
  });

  @override
  State<_AttachmentPreviewDialog> createState() =>
      _AttachmentPreviewDialogState();
}

class _AttachmentPreviewDialogState extends State<_AttachmentPreviewDialog> {
  final TransformationController _transformController =
      TransformationController();

  bool get _isPdf =>
      widget.fileType.toLowerCase().contains('pdf') ||
      widget.fileName.toLowerCase().contains('.pdf');

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = _isPdf ? const Color(0xFFE53935) : LaColors.primary;
    final soft = _isPdf ? const Color(0xFFFFEBEE) : LaColors.primaryLight;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 900),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Material(
            color: LaColors.surface,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [soft.withOpacity(.6), soft.withOpacity(.3)],
                    ),
                    border: Border(
                      bottom: BorderSide(color: primary.withOpacity(.2)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: primary.withOpacity(.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: primary.withOpacity(.4)),
                        ),
                        child: Icon(
                          _isPdf
                              ? Icons.picture_as_pdf_outlined
                              : Icons.image_outlined,
                          color: primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: LaColors.textPrimary,
                                )),
                            Text(widget.fileName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: LaText.caption),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: primary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _isPdf ? 'PDF' : 'IMAGE',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(widget.status, style: LaText.caption),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'ปิด',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _isPdf
                      ? SfPdfViewer.memory(widget.bytes)
                      : Container(
                          color: const Color(0xFF1A1A2E),
                          alignment: Alignment.center,
                          child: InteractiveViewer(
                            transformationController: _transformController,
                            minScale: .5,
                            maxScale: 5,
                            child:
                                Image.memory(widget.bytes, fit: BoxFit.contain),
                          ),
                        ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                  color: LaColors.surfaceMuted,
                  child: Row(
                    children: [
                      Icon(Icons.touch_app_rounded, size: 12, color: primary),
                      const SizedBox(width: 4),
                      Text(
                        _isPdf ? 'ดับเบิ้ลแท็ปเพื่อซูม' : 'ลาก/นิ้วเพื่อซูม',
                        style: LaText.caption.copyWith(color: primary),
                      ),
                      const Spacer(),
                      Text(widget.fileName, style: LaText.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AttachmentRow extends StatefulWidget {
  final String permitUuid;
  final Map<String, dynamic> attachment;
  final int index;
  final bool mobile;

  const _AttachmentRow({
    required this.permitUuid,
    required this.attachment,
    required this.index,
    required this.mobile,
  });

  @override
  State<_AttachmentRow> createState() => _AttachmentRowState();
}

class _AttachmentRowState extends State<_AttachmentRow> {
  bool _loading = false;

  String _text(String key) {
    final text = widget.attachment[key]?.toString().trim() ?? '';
    return text.isEmpty || text == 'null' ? '-' : text;
  }

  String _date(String key) {
    final value = _text(key);
    if (value == '-') return value;
    try {
      final date = DateTime.parse(value).toLocal();
      return '${date.day.toString().padLeft(2, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-${date.year + 543}';
    } catch (_) {
      return '-';
    }
  }

  Future<void> _open() async {
    final uuid = _text('uuid');
    if (_loading || uuid == '-') return;
    setState(() => _loading = true);
    final bytes = await context
        .read<TenantLicenseDetailViewModel>()
        .service
        .fetchPermitAttachmentBytes(
          permitUuid: widget.permitUuid,
          attachmentUuid: uuid,
        );
    if (!mounted) return;
    setState(() => _loading = false);
    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เปิดไฟล์แนบไม่สำเร็จ')),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(.55),
      builder: (_) => _AttachmentPreviewDialog(
        title: _text('document_name'),
        fileName: _text('file_name'),
        fileType: _text('file_type'),
        status: _text('status_label') == '-'
            ? _text('status')
            : _text('status_label'),
        bytes: bytes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _text('document_name');
    final file = _text('file_name');
    final status =
        _text('status_label') == '-' ? _text('status') : _text('status_label');
    final approved = status == 'approved' || status == 'ผ่าน';
    final statusColor =
        approved ? LaColors.statusApprovedFg : LaColors.statusPendingFg;

    final details = Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: LaColors.statusInfoBg,
            borderRadius: BorderRadius.circular(LaRadius.sm),
          ),
          child: const Icon(Icons.description_outlined,
              size: 18, color: LaColors.statusInfoFg),
        ),
        const SizedBox(width: LaSpace.sm),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      LaText.tableCell.copyWith(fontFamily: LaText.fontBold)),
              Text(file,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LaText.caption),
            ],
          ),
        ),
        if (!widget.mobile) ...[
          Expanded(
            flex: 2,
            child: Text(
              _date('reviewed_at'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LaText.caption,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _text('reviewer'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LaText.caption,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              status,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LaText.caption.copyWith(
                color: statusColor,
                fontFamily: LaText.fontBold,
              ),
            ),
          ),
        ],
        SizedBox(
          width: widget.mobile ? 42 : 92,
          child: _TenantViewButton(
            onTap: _loading ? null : _open,
            label: widget.mobile ? '' : 'เรียกดู',
            icon: Icons.visibility_outlined,
            loading: _loading,
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LaSpace.sm),
      child: widget.mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                details,
                const SizedBox(height: LaSpace.xs),
                Text('สถานะ: $status',
                    style: LaText.caption.copyWith(color: statusColor)),
              ],
            )
          : details,
    );
  }
}

// Legacy simple list retained for old callers.
class _SimpleList extends StatelessWidget {
  final List<String> rows;

  const _SimpleList({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 5, color: LaColors.textMuted),
                const SizedBox(width: 8),
                Expanded(child: Text(row, style: LaText.tableCell)),
              ],
            ),
          ),
      ],
    );
  }
}

// ============================================================================
// Payment status card — สไตล์เดียวกับ license payment detail
// ============================================================================
class _PaymentStatusCard extends StatelessWidget {
  final String permitUuid;
  final List<Map<String, dynamic>> payments;

  const _PaymentStatusCard({
    required this.permitUuid,
    required this.payments,
  });

  @override
  Widget build(BuildContext context) {
    final paidCount = payments.where((payment) {
      final status = payment['status']?.toString().toLowerCase() ?? '';
      return status == 'paid' || status.contains('ชำระ');
    }).length;

    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: LaColors.statusInfoBg,
                  borderRadius: BorderRadius.circular(LaRadius.sm),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  size: 18,
                  color: LaColors.statusInfoFg,
                ),
              ),
              const SizedBox(width: LaSpace.sm),
              const Text('สถานะการชำระ', style: LaText.h2),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: LaDecor.pill(
                  LaColors.surfaceMuted,
                  LaColors.textSecondary,
                ),
                child: Text(
                  'ชำระแล้ว $paidCount / ${payments.length}',
                  style: LaText.caption.copyWith(
                    color: LaColors.textSecondary,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: LaSpace.md),
          if (payments.isEmpty)
            Container(
              padding: const EdgeInsets.all(LaSpace.lg),
              decoration: LaDecor.softCard(),
              child: const Center(
                child: Text('ไม่พบรายการชำระ', style: LaText.bodyMuted),
              ),
            )
          else
            for (final payment in payments)
              Padding(
                padding: const EdgeInsets.only(bottom: LaSpace.sm),
                child: _PaymentStatusRow(
                  permitUuid: permitUuid,
                  payment: payment,
                ),
              ),
        ],
      ),
    );
  }
}

class _PaymentStatusRow extends StatefulWidget {
  final String permitUuid;
  final Map<String, dynamic> payment;

  const _PaymentStatusRow({
    required this.permitUuid,
    required this.payment,
  });

  @override
  State<_PaymentStatusRow> createState() => _PaymentStatusRowState();
}

class _PaymentStatusRowState extends State<_PaymentStatusRow> {
  bool _expanded = false;

  String _text(String key) {
    final text = widget.payment[key]?.toString().trim() ?? '';
    return text.isEmpty || text == 'null' ? '-' : text;
  }

  String _statusLabel() {
    final status = _text('status').toLowerCase();
    if (status == 'paid' || status.contains('ชำระ')) return 'ชำระแล้ว';
    if (status.contains('cancel') || status.contains('ยกเลิก')) return 'ยกเลิก';
    if (status.contains('pending') || status.contains('รอ'))
      return 'รอดำเนินการ';
    return _text('status');
  }

  @override
  Widget build(BuildContext context) {
    final status = _statusLabel();
    final isPaid = status == 'ชำระแล้ว';

    return Container(
      decoration: LaDecor.softCard(),
      padding: const EdgeInsets.all(LaSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 480;
              final iconBox = Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isPaid
                      ? LaColors.statusApprovedBg
                      : LaColors.statusInfoBg,
                  borderRadius: BorderRadius.circular(LaRadius.sm),
                ),
                child: Icon(
                  isPaid ? Icons.cloud_done_rounded : Icons.payments_outlined,
                  size: 18,
                  color: isPaid
                      ? LaColors.statusApprovedFg
                      : LaColors.statusInfoFg,
                ),
              );
              final content = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _text('payment_no'),
                          style: LaText.h2.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => setState(() => _expanded = !_expanded),
                        borderRadius: BorderRadius.circular(LaRadius.pill),
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Icon(
                            _expanded
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            size: 18,
                            color: LaColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_text('payment_method_name')}  •  ${_text('amount')} บาท',
                    style: LaText.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'ใบเสร็จ: ${_text('receipt_document_no')}',
                    style: LaText.caption.copyWith(color: LaColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
              final actions = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PaymentStatusBadge(label: status),
                  const SizedBox(width: 6),
                  if (isPaid)
                    _ReceiptViewButton(
                      permitUuid: widget.permitUuid,
                      paymentUuid: _text('uuid'),
                    ),
                ],
              );

              if (narrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        iconBox,
                        const SizedBox(width: LaSpace.sm),
                        Expanded(child: content),
                      ],
                    ),
                    const SizedBox(height: LaSpace.sm),
                    Align(alignment: Alignment.centerLeft, child: actions),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  iconBox,
                  const SizedBox(width: LaSpace.sm),
                  Expanded(child: content),
                  const SizedBox(width: LaSpace.sm),
                  actions,
                ],
              );
            },
          ),
          if (_expanded) ...[
            const SizedBox(height: LaSpace.sm),
            const Divider(height: 1),
            const SizedBox(height: LaSpace.sm),
            _PaymentDetailGrid(payment: widget.payment),
          ],
        ],
      ),
    );
  }
}

class _PaymentStatusBadge extends StatelessWidget {
  final String label;

  const _PaymentStatusBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final approved = label == 'ชำระแล้ว';
    final fg = approved ? LaColors.statusApprovedFg : LaColors.statusPendingFg;
    final bg = approved ? LaColors.statusApprovedBg : LaColors.statusPendingBg;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(LaRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: LaText.caption.copyWith(
              color: fg,
              fontFamily: LaText.fontBold,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentDetailGrid extends StatelessWidget {
  final Map<String, dynamic> payment;

  const _PaymentDetailGrid({required this.payment});

  String _text(String key) {
    final text = payment[key]?.toString().trim() ?? '';
    return text.isEmpty || text == 'null' ? '-' : text;
  }

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, String)>[
      (
        Icons.payments_outlined,
        'จำนวนรับชำระ',
        '${_text('amount_received')} บาท'
      ),
      (Icons.event_available_rounded, 'วันที่ชำระ', _text('paid_at')),
      (Icons.info_outline_rounded, 'สถานะ', _text('status')),
      (Icons.fingerprint_rounded, 'วิธีชำระ', _text('payment_method_name')),
      (
        Icons.receipt_long_rounded,
        'เลขที่ใบเสร็จ',
        _text('receipt_document_no')
      ),
      (Icons.access_time_rounded, 'สร้างเมื่อ', _text('created_at')),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700
            ? 3
            : constraints.maxWidth >= 460
                ? 2
                : 1;
        return Wrap(
          spacing: LaSpace.md,
          runSpacing: LaSpace.sm,
          children: [
            for (final item in items)
              SizedBox(
                width: (constraints.maxWidth - LaSpace.md * (columns - 1)) /
                    columns,
                child: _PaymentDetailCell(
                  icon: item.$1,
                  label: item.$2,
                  value: item.$3,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PaymentDetailCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PaymentDetailCell({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: LaColors.textMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: LaText.caption.copyWith(color: LaColors.textMuted)),
              Text(
                value,
                style: LaText.tableCell.copyWith(fontFamily: 'monospace'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReceiptViewButton extends StatefulWidget {
  final String permitUuid;
  final String paymentUuid;

  const _ReceiptViewButton({
    required this.permitUuid,
    required this.paymentUuid,
  });

  @override
  State<_ReceiptViewButton> createState() => _ReceiptViewButtonState();
}

class _ReceiptViewButtonState extends State<_ReceiptViewButton> {
  bool _loading = false;

  Future<void> _open() async {
    if (_loading || widget.paymentUuid.isEmpty || widget.paymentUuid == '-') {
      return;
    }
    // Receipt screen needs payment UUID only. Avoid constructor load because
    // its request-level endpoints require request UUID and return 404 here.
    final paymentVm = LicensePaymentDetailViewModel();
    setState(() => _loading = true);
    await paymentVm.loadReceipt(uuid: widget.paymentUuid);
    if (!mounted) {
      paymentVm.dispose();
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: paymentVm,
          child: const _TenantReceiptPage(),
        ),
      ),
    );
    paymentVm.dispose();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'ดูใบเสร็จ',
      child: _TenantViewButton(
        onTap: _loading ? null : _open,
        label: 'เรียกดู',
        icon: Icons.receipt_long_rounded,
        loading: _loading,
      ),
    );
  }
}

class _TenantReceiptPage extends StatelessWidget {
  const _TenantReceiptPage();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicensePaymentDetailViewModel>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            PaymentDetailHeader(
              title: 'ใบเสร็จรับเงิน',
              subtitle: 'รายละเอียดการชำระเงิน',
              currentStep: 2,
              totalSteps: 2,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: PaymentDetailStep2(),
            ),
            PaymentDetailFooter(
              readOnly: true,
              currentStep: 2,
              totalSteps: 2,
              onCancel: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: unused_element
class _ReceiptDialog extends StatelessWidget {
  final Map<String, dynamic> receipt;

  const _ReceiptDialog({required this.receipt});

  String _text(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty || text == 'null' ? '-' : text;
  }

  Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  @override
  Widget build(BuildContext context) {
    final data =
        _map(receipt['data']).isNotEmpty ? _map(receipt['data']) : receipt;
    final receiptInfo = _map(data['receipt']);
    final payment = _map(data['payment']);
    final vendor = _map(data['vendor']);
    final location = _map(data['location']);
    final totals = _map(_map(data['entries'])['totals']);

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 760),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(LaSpace.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long_rounded,
                      color: LaColors.primaryDark),
                  const SizedBox(width: LaSpace.sm),
                  const Expanded(
                    child: Text('ใบเสร็จรับเงิน', style: LaText.h2),
                  ),
                  IconButton(
                    tooltip: 'ปิด',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const Divider(),
              _ReceiptBlock(
                title: 'ข้อมูลใบเสร็จ',
                items: [
                  (
                    'เลขที่ใบเสร็จ',
                    _text(receiptInfo['receipt_no'] ??
                        receiptInfo['receiptNo'] ??
                        payment['receipt_document_no'])
                  ),
                  (
                    'วันที่',
                    _text(receiptInfo['date'] ??
                        receiptInfo['book_date'] ??
                        payment['paid_at'])
                  ),
                  (
                    'วิธีชำระ',
                    _text(data['method'] is Map
                        ? _map(data['method'])['name_th']
                        : payment['payment_method_name'])
                  ),
                  (
                    'ยอดรวม',
                    '${_text(totals['grand'] ?? payment['amount'])} บาท'
                  ),
                ],
              ),
              const SizedBox(height: LaSpace.md),
              _ReceiptBlock(
                title: 'ข้อมูลผู้ชำระ',
                items: [
                  ('ชื่อผู้ชำระ', _text(vendor['cname'])),
                  ('ชื่อร้าน', _text(vendor['scname'])),
                  (
                    'เลขประจำตัวผู้เสียภาษี',
                    _text(vendor['tax'] ?? vendor['taxno'])
                  ),
                  ('เบอร์โทร', _text(vendor['tel'])),
                ],
              ),
              const SizedBox(height: LaSpace.md),
              _ReceiptBlock(
                title: 'ข้อมูลพื้นที่',
                items: [
                  ('บริเวณ', _text(location['subzone'])),
                  ('โซน', _text(location['zn'])),
                  ('รหัสพื้นที่', _text(location['ln'])),
                  ('วันที่เริ่มต้น', _text(location['sdate'])),
                  ('วันที่สิ้นสุด', _text(location['ldate'])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptBlock extends StatelessWidget {
  final String title;
  final List<(String, String)> items;

  const _ReceiptBlock({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: LaText.h2),
        const SizedBox(height: LaSpace.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 600 ? 2 : 1;
            return Wrap(
              spacing: LaSpace.lg,
              runSpacing: LaSpace.sm,
              children: [
                for (final item in items)
                  SizedBox(
                    width: (constraints.maxWidth - (columns - 1) * LaSpace.lg) /
                        columns,
                    child: _PaymentDetailCell(
                      icon: Icons.info_outline_rounded,
                      label: item.$1,
                      value: item.$2,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PaymentsTable extends StatelessWidget {
  final List<Map<String, dynamic>> payments;

  const _PaymentsTable({required this.payments});

  String _text(Map<String, dynamic> payment, String key) {
    final text = payment[key]?.toString().trim() ?? '';
    return text.isEmpty || text == 'null' ? '-' : text;
  }

  String _paymentNo(Map<String, dynamic> payment) {
    final paymentNo = _text(payment, 'payment_no');
    final receiptNo = _text(payment, 'receipt_document_no');
    if (receiptNo == '-') return paymentNo;
    if (paymentNo == '-') return receiptNo;
    return '$paymentNo / $receiptNo';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 620;
        if (narrow) {
          return Column(
            children: [
              for (var i = 0; i < payments.length; i++) ...[
                _PaymentCompactCard(
                  paymentNo: _paymentNo(payments[i]),
                  method: _text(payments[i], 'payment_method_name'),
                  date: _text(payments[i], 'paid_at'),
                  amount: _text(payments[i], 'amount'),
                ),
                if (i < payments.length - 1)
                  const Divider(height: LaSpace.lg, color: LaColors.border),
              ],
            ],
          );
        }

        return Column(
          children: [
            const _PaymentHeaderRow(),
            const Divider(height: 1, color: LaColors.border),
            for (var i = 0; i < payments.length; i++) ...[
              _PaymentDataRow(
                paymentNo: _paymentNo(payments[i]),
                method: _text(payments[i], 'payment_method_name'),
                date: _text(payments[i], 'paid_at'),
                amount: _text(payments[i], 'amount'),
              ),
              if (i < payments.length - 1)
                const Divider(height: LaSpace.lg, color: LaColors.border),
            ],
          ],
        );
      },
    );
  }
}

class _PaymentHeaderRow extends StatelessWidget {
  const _PaymentHeaderRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: LaSpace.sm, vertical: 10),
      decoration: BoxDecoration(
        color: LaColors.surfaceMuted,
        borderRadius: BorderRadius.circular(LaRadius.sm),
      ),
      child: const Row(
        children: [
          Expanded(
              flex: 3, child: Text('เลขที่ชำระ', style: LaText.tableHeader)),
          Expanded(flex: 2, child: Text('วิธี', style: LaText.tableHeader)),
          Expanded(flex: 2, child: Text('วันที่', style: LaText.tableHeader)),
          Expanded(
            flex: 2,
            child: Text('ยอด',
                style: LaText.tableHeader, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

class _PaymentDataRow extends StatelessWidget {
  final String paymentNo;
  final String method;
  final String date;
  final String amount;

  const _PaymentDataRow({
    required this.paymentNo,
    required this.method,
    required this.date,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LaSpace.sm, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              paymentNo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: LaText.tableCell.copyWith(fontFamily: LaText.fontBold),
            ),
          ),
          Expanded(
              child: Text(method,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: LaText.tableCell)),
          Expanded(
              child: Text(date,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: LaText.tableCell)),
          Expanded(
            flex: 2,
            child: Text(
              '$amount บาท',
              textAlign: TextAlign.right,
              style: LaText.tableCell.copyWith(
                fontFamily: LaText.fontBold,
                fontWeight: FontWeight.w700,
                color: LaColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentCompactCard extends StatelessWidget {
  final String paymentNo;
  final String method;
  final String date;
  final String amount;

  const _PaymentCompactCard({
    required this.paymentNo,
    required this.method,
    required this.date,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LaSpace.md),
      decoration: LaDecor.softCard(color: LaColors.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_outlined,
                  size: 18, color: LaColors.statusApprovedFg),
              const SizedBox(width: LaSpace.sm),
              Expanded(
                  child: Text(paymentNo,
                      style: LaText.tableCell
                          .copyWith(fontFamily: LaText.fontBold))),
              Text('$amount บาท',
                  style: LaText.tableCell.copyWith(
                      fontFamily: LaText.fontBold,
                      color: LaColors.primaryDark)),
            ],
          ),
          const SizedBox(height: LaSpace.sm),
          Row(
            children: [
              Expanded(child: _PaymentDetail(label: 'วิธี', value: method)),
              Expanded(child: _PaymentDetail(label: 'วันที่', value: date)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentDetail extends StatelessWidget {
  final String label;
  final String value;

  const _PaymentDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: LaText.caption),
        Text(value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: LaText.tableCell),
      ],
    );
  }
}

// ============================================================================
// Document row with in-app PDF preview
// ============================================================================
class _DocumentRow extends StatefulWidget {
  final String permitUuid;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String path;

  const _DocumentRow({
    required this.permitUuid,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.path,
  });

  @override
  State<_DocumentRow> createState() => _DocumentRowState();
}

class _DocumentRowState extends State<_DocumentRow> {
  bool _loading = false;

  Future<void> _open() async {
    if (_loading) return;
    setState(() => _loading = true);
    final service = context.read<TenantLicenseDetailViewModel>().service;
    final bytes = await service.fetchPermitBytes(
      permitUuid: widget.permitUuid,
      path: widget.path,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เปิดเอกสารไม่สำเร็จ')),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 794),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  color: LaColors.headerBg,
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf_rounded,
                          size: 18, color: LaColors.statusRejectedFg),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                      ),
                    ],
                  ),
                ),
                Expanded(child: SfPdfViewer.memory(bytes)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: LaColors.surface,
        borderRadius: BorderRadius.circular(LaRadius.sm),
        border: Border.all(color: LaColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: widget.iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(widget.icon, color: widget.iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title,
                    style: LaText.body.copyWith(fontFamily: LaText.fontBold)),
                Text(widget.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LaText.caption),
              ],
            ),
          ),
          const SizedBox(width: LaSpace.sm),
          _TenantViewButton(
            onTap: _loading ? null : _open,
            label: 'เรียกดู',
            icon: Icons.visibility_outlined,
            loading: _loading,
          ),
        ],
      ),
    );
  }
}
