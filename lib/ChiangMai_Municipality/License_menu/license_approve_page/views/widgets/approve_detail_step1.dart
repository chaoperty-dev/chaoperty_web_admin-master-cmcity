// ============================================================================
// approve_detail_step1.dart
// ============================================================================
// Step 1 — ตรวจสอบคำขอ
// - แสดง "ข้อมูลเบื้องต้น" ของคำขอ (uuid / ชื่อลูกค้า / lease / zone / สถานะ)
// - แสดง "ขั้นตอนการส่งคำร้องขออนุมัติ" (read-only current step card)
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../unity/FormatPhone.dart';
import '../../../../Model/Review_Model.dart';
import '../theme/license_approve_theme.dart';
import '../../models/license_approve_detail_extended.dart';
import '../../viewmodels/license_approve_detail_view_model.dart';

// ─── Cross-module: ใช้ข้อมูลคำขอจาก license_request_page (read-only) ───
import '../../../license_attach_page/views/widgets/request_detail_zone_row.dart';
import '../../../license_attach_page/views/widgets/request_detail_section_title.dart';
import '../../../license_request_page/viewmodels/license_request_detail_step1_view_model.dart';
import '../../../license_request_page/views/widgets/request_detail_person_section.dart';
import '../../../license_request_page/views/widgets/request_detail_shop_section.dart';
import '../../../license_request_page/views/widgets/request_detail_contract_section.dart';

class ApproveDetailStep1 extends StatefulWidget {
  const ApproveDetailStep1({super.key});

  @override
  State<ApproveDetailStep1> createState() => _ApproveDetailStep1State();
}

class _ApproveDetailStep1State extends State<ApproveDetailStep1> {
  @override
  Widget build(BuildContext context) {
    // ✅ context.select — rebuild เฉพาะตอน requestUuid เปลี่ยน
    final uuid = context.select<LicenseApproveDetailViewModel, String?>(
      (vm) => vm.requestUuid,
    );

    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Segmented tabs ───
              const _ApproveSegmentedTabs(),
              // ─── TabBarView: 2 แท็บ ───
              Expanded(
                child: TabBarView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Tab 1: ข้อมูลการอนุมัติ (เนื้อหาเดิม)
                    const _ApproveInfoTab(),
                    // Tab 2: ข้อมูลคำขอ
                    _RequestInfoTab(requestUuid: uuid),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// =============================================================================
// Segmented Tabs — sliding indicator
// =============================================================================
class _ApproveSegmentedTabs extends StatelessWidget {
  const _ApproveSegmentedTabs();

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
                            MaterialStateProperty.all(Colors.transparent),
                        tabs: const [
                          Tab(
                            height: double.infinity,
                            iconMargin: EdgeInsets.zero,
                            child: _TabLabel(
                              icon: Icons.check_circle_rounded,
                              label: 'ข้อมูลการอนุมัติ',
                              index: 0,
                            ),
                          ),
                          Tab(
                            height: double.infinity,
                            iconMargin: EdgeInsets.zero,
                            child: _TabLabel(
                              icon: Icons.info_outline_rounded,
                              label: 'ข้อมูลคำขอ',
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

// =============================================================================
// Tab Label
// =============================================================================
class _TabLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  const _TabLabel({
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

// =============================================================================
// Tab 1: ข้อมูลการอนุมัติ (เนื้อหาเดิม)
// =============================================================================

/// Snapshot ของ VM fields ที่ _ApproveInfoTab ใช้ → ให้ Selector เทียบกับ deep equality
@immutable
class _ApproveInfoSnapshot {
  final bool isLoading;
  final String? loadError;
  final ReviewModel? currentRequest;
  final String? requestUuid;
  final List<ApprovalStepV2> currentSteps;
  final bool isLoadingApproval;
  final String? approvalError;

  const _ApproveInfoSnapshot({
    required this.isLoading,
    required this.loadError,
    required this.currentRequest,
    required this.requestUuid,
    required this.currentSteps,
    required this.isLoadingApproval,
    required this.approvalError,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _ApproveInfoSnapshot &&
        other.isLoading == isLoading &&
        other.loadError == loadError &&
        identical(other.currentRequest, currentRequest) &&
        other.requestUuid == requestUuid &&
        identical(other.currentSteps, currentSteps) &&
        other.isLoadingApproval == isLoadingApproval &&
        other.approvalError == approvalError;
  }

  @override
  int get hashCode => Object.hash(
        isLoading,
        loadError,
        currentRequest,
        requestUuid,
        currentSteps,
        isLoadingApproval,
        approvalError,
      );
}

class _ApproveInfoTab extends StatelessWidget {
  const _ApproveInfoTab();

  @override
  Widget build(BuildContext context) {
    // ✅ Selector — rebuild เฉพาะเมื่อ fields ที่ UI ใช้เปลี่ยน
    //    actingStepUuid/isActing ถูก Consumer ใน _StepCard subscribe แยก
    return Selector<LicenseApproveDetailViewModel, _ApproveInfoSnapshot>(
      selector: (_, vm) => _ApproveInfoSnapshot(
        isLoading: vm.isLoading,
        loadError: vm.loadError,
        currentRequest: vm.currentRequest,
        requestUuid: vm.requestUuid,
        currentSteps: vm.currentSteps,
        isLoadingApproval: vm.isLoadingApproval,
        approvalError: vm.approvalError,
      ),
      shouldRebuild: (a, b) => a != b,
      builder: (context, snap, _) {
        // ใช้ context.read เพื่อ pass VM ให้ _RoundsSection (สำหรับ actions)
        final vm = context.read<LicenseApproveDetailViewModel>();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(LaSpace.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── Header band ───
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: LaSpace.md, vertical: LaSpace.sm),
                    decoration: BoxDecoration(
                      color: LaColors.primaryLight.withOpacity(.25),
                      borderRadius: BorderRadius.circular(LaRadius.md),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            size: 18, color: LaColors.primaryDark),
                        SizedBox(width: 8),
                        Text('ตรวจสอบคำขอ', style: LaText.h2),
                      ],
                    ),
                  ),
                  const SizedBox(height: LaSpace.md),

                  // ─── Loading / Error / Data ───
                  if (snap.isLoading)
                    const _LoadingBlock()
                  else if (snap.loadError != null)
                    _ErrorBlock(message: snap.loadError!)
                  else if (snap.currentRequest == null)
                    _EmptyBlock(uuid: snap.requestUuid)
                  else
                    _RequestSummaryCard(model: snap.currentRequest!),

                  const SizedBox(height: LaSpace.lg),

                  // ─── Section: ขั้นตอนการส่งคำร้องขออนุมัติ (read-only) ───
                  _RoundsSection(vm: vm),

              const SizedBox(height: LaSpace.lg),

              const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 14, color: LaColors.textMuted),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'ตรวจสอบคำขอให้ครบถ้วนก่อนกด "ถัดไป"',
                      style: LaText.caption,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }
}

// =============================================================================
// Tab 2: ข้อมูลคำขอ (read-only)
// =============================================================================
class _RequestInfoTab extends StatefulWidget {
  final String? requestUuid;
  const _RequestInfoTab({this.requestUuid});

  @override
  State<_RequestInfoTab> createState() => _RequestInfoTabState();
}

class _RequestInfoTabState extends State<_RequestInfoTab> {
  late final LicenseRequestDetailStep1ViewModel _vm;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _vm = LicenseRequestDetailStep1ViewModel().init();
    _loadReviewData();
  }

  Future<void> _loadReviewData() async {
    final uuid = widget.requestUuid?.trim();
    if (uuid == null || uuid.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'ไม่พบ UUID ของคำขอ';
        });
      }
      return;
    }
    try {
      await _vm.loadFromUuid(uuid);
      if (mounted) {
        setState(() {
          _isLoading = _vm.isLoading;
          _errorMessage = _vm.errorMessage;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'เกิดข้อผิดพลาด: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LicenseRequestDetailStep1ViewModel>.value(
      value: _vm,
      child: Builder(
        builder: (context) {
          if (_isLoading) {
            return const _RequestInfoLoadingState();
          }
          if (_errorMessage != null) {
            return _RequestInfoErrorState(
              message: _errorMessage!,
              onRetry: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _loadReviewData();
              },
            );
          }
          return const _RequestInfoBody();
        },
      ),
    );
  }
}

// =============================================================================
// Loading / Error states
// =============================================================================
class _RequestInfoLoadingState extends StatelessWidget {
  const _RequestInfoLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: LaSpace.xxl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(LaColors.primary),
              ),
            ),
            SizedBox(height: LaSpace.md),
            Text('กำลังโหลดข้อมูลคำขอ…', style: LaText.bodyMuted),
          ],
        ),
      ),
    );
  }
}

class _RequestInfoErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _RequestInfoErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(LaSpace.lg),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: LaColors.statusRejectedFg,
            ),
            const SizedBox(height: LaSpace.md),
            Text(
              message,
              style: LaText.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: LaSpace.md),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: LaColors.primary,
                foregroundColor: LaColors.textInverse,
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('ลองอีกครั้ง'),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Body ของ Tab 2 (อยู่ใต้ Provider)
// =============================================================================
class _RequestInfoBody extends StatelessWidget {
  const _RequestInfoBody();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(LaSpace.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Title bar ───
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: LaSpace.md, vertical: LaSpace.sm),
                decoration: BoxDecoration(
                  color: LaColors.primaryLight.withOpacity(.25),
                  borderRadius: BorderRadius.circular(LaRadius.md),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.assignment_rounded,
                      size: 18,
                      color: LaColors.primaryDark,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ข้อมูลคำขอ',
                        style: LaText.h2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LaSpace.md),

              // ─── Zone row (read-only) ───
              const RequestDetailZoneRow(),
              const SizedBox(height: LaSpace.md),

              // ─── Form card (2 columns) ───
              Container(
                decoration: LaDecor.card(),
                padding: const EdgeInsets.all(LaSpace.lg),
                child: LayoutBuilder(
                  builder: (ctx, c) {
                    final isNarrow = c.maxWidth < 1100;
                    if (isNarrow) {
                      return const Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          RequestDetailSectionTitle(
                            icon: Icons.person,
                            title: 'ข้อมูลผู้เช่า',
                          ),
                          RequestDetailPersonSection(),
                          SizedBox(height: 16),
                          RequestDetailSectionTitle(
                            icon: Icons.store,
                            title: 'ข้อมูลร้านค้า',
                          ),
                          RequestDetailShopSection(),
                          SizedBox(height: 16),
                          RequestDetailSectionTitle(
                            icon: Icons.receipt_long,
                            title: 'ข้อมูลสัญญา',
                          ),
                          RequestDetailContractSection(),
                        ],
                      );
                    }
                    return const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RequestDetailSectionTitle(
                                icon: Icons.person,
                                title: 'ข้อมูลผู้เช่า',
                              ),
                              RequestDetailPersonSection(),
                            ],
                          ),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RequestDetailSectionTitle(
                                icon: Icons.store,
                                title: 'ข้อมูลร้านค้า',
                              ),
                              RequestDetailShopSection(),
                              SizedBox(height: 16),
                              RequestDetailSectionTitle(
                                icon: Icons.receipt_long,
                                title: 'ข้อมูลสัญญา',
                              ),
                              RequestDetailContractSection(),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: LaSpace.md),
              // ─── Info row ───
              const Row(
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: 14,
                    color: LaColors.textMuted,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'โหมดดูข้อมูลอย่างเดียว ไม่สามารถแก้ไขได้',
                      style: LaText.caption,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Sub widgets
// ============================================================================

class _RequestSummaryCard extends StatelessWidget {
  final ReviewModel model;
  const _RequestSummaryCard({required this.model});

  @override
  Widget build(BuildContext context) {
    final nr = model.newRequest;
    final client = model.client;

    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header row: status + uuid ───
          Row(
            children: [
              _StatusBadge(label: model.statusLabel ?? model.status ?? '-'),
              const Spacer(),
              _PillIcon(
                icon: Icons.tag_rounded,
                text: 'UUID: ${_short(model.uuid)}',
                muted: true,
              ),
            ],
          ),
          const SizedBox(height: LaSpace.lg),

          // ─── Grid 2 columns ───
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoColumn(
                  title: 'ข้อมูลคำขอ',
                  items: [
                    _InfoItem(
                      icon: Icons.receipt_long_rounded,
                      label: 'เลขที่สัญญา',
                      value: nr?.leaseNumber,
                    ),
                    _InfoItem(
                      icon: Icons.calendar_today_rounded,
                      label: 'วันที่สิ้นสุด',
                      value: _formatDate(nr?.ldate),
                    ),
                    _InfoItem(
                      icon: Icons.location_on_rounded,
                      label: 'บริเวณ / โซน',
                      value: _joinZones(nr),
                    ),
                    _InfoItem(
                      icon: Icons.numbers_rounded,
                      label: 'รหัสพื้นที่',
                      value: nr?.ln,
                      mono: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: LaSpace.lg),
              Expanded(
                child: _InfoColumn(
                  title: 'ข้อมูลลูกค้า',
                  items: [
                    _InfoItem(
                      icon: Icons.person_rounded,
                      label: 'ชื่อผู้ติดต่อ',
                      value: client?.cname ?? client?.scname,
                    ),
                    _InfoItem(
                      icon: Icons.phone_rounded,
                      label: 'เบอร์โทร',
                      value: formatPhoneNumber(client?.tel ?? ''),
                      mono: true,
                    ),
                    _InfoItem(
                      icon: Icons.confirmation_number_rounded,
                      label: 'เลขประจำตัวผู้เสียภาษี',
                      value: client?.tax,
                      mono: true,
                    ),
                    _InfoItem(
                      icon: Icons.place_rounded,
                      label: 'ที่อยู่',
                      value: client?.addr1,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ─── Footer note ───
          const SizedBox(height: LaSpace.lg),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: LaSpace.md, vertical: LaSpace.sm),
            decoration: BoxDecoration(
              color: LaColors.surfaceMuted,
              borderRadius: BorderRadius.circular(LaRadius.sm),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 14, color: LaColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: AutoSizeText(
                    'ข้อมูลด้านบนเป็น "ภาพรวมคำขอ" '
                    'สำหรับตรวจสอบเบื้องต้น — รายละเอียดเพิ่มเติมจะแสดงใน Step ถัดไป',
                    style: LaText.caption,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _short(String? uuid) {
    if (uuid == null || uuid.isEmpty) return '-';
    if (uuid.length <= 12) return uuid;
    return '${uuid.substring(0, 8)}…';
  }

  String? _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }

  String? _joinZones(NewRequestModel? nr) {
    if (nr == null) return null;
    final parts = <String>[
      if ((nr.subzone ?? '').isNotEmpty) nr.subzone!,
      if ((nr.zn ?? '').isNotEmpty) nr.zn!,
    ];
    if (parts.isEmpty) return null;
    return parts.join(' / ');
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  const _StatusBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final s = label.toLowerCase();
    Color bg, fg;
    if (s.contains('อนุมัติ') || s.contains('approved') || s.contains('pass')) {
      bg = LaColors.statusApprovedBg;
      fg = LaColors.statusApprovedFg;
    } else if (s.contains('ปฏิเสธ') ||
        s.contains('reject') ||
        s.contains('cancel') ||
        s.contains('ยกเลิก')) {
      bg = LaColors.statusRejectedBg;
      fg = LaColors.statusRejectedFg;
    } else if (s.contains('รอ') ||
        s.contains('pending') ||
        s.contains('progress')) {
      bg = LaColors.statusPendingBg;
      fg = LaColors.statusPendingFg;
    } else {
      bg = LaColors.statusNeutralBg;
      fg = LaColors.statusNeutralFg;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(LaRadius.pill),
        border: Border.all(color: fg.withOpacity(.25)),
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
          AutoSizeText(
            label,
            minFontSize: 11,
            maxFontSize: 12,
            maxLines: 1,
            style: TextStyle(
              fontFamily: LaText.fontBold,
              fontWeight: FontWeight.w700,
              color: fg,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillIcon extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool muted;
  const _PillIcon({required this.icon, required this.text, this.muted = false});

  @override
  Widget build(BuildContext context) {
    final fg = muted ? LaColors.textSecondary : LaColors.textPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: LaColors.surfaceMuted,
        borderRadius: BorderRadius.circular(LaRadius.pill),
        border: Border.all(color: LaColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 6),
          AutoSizeText(
            text,
            minFontSize: 11,
            maxFontSize: 12,
            maxLines: 1,
            style: LaText.caption.copyWith(
              color: fg,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String title;
  final List<_InfoItem> items;
  const _InfoColumn({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: LaText.label.copyWith(
            color: LaColors.primaryDark,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: LaSpace.sm),
        for (final item in items) ...[
          item,
          const SizedBox(height: LaSpace.sm),
        ],
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool mono;
  const _InfoItem({
    required this.icon,
    required this.label,
    this.value,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    final v = (value ?? '').trim();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: LaColors.primary.withOpacity(.08),
            borderRadius: BorderRadius.circular(LaRadius.sm),
          ),
          child: Icon(icon, size: 16, color: LaColors.primaryDark),
        ),
        const SizedBox(width: LaSpace.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: LaText.caption),
              const SizedBox(height: 2),
              AutoSizeText(
                v.isEmpty ? '-' : v,
                minFontSize: 12,
                maxFontSize: 14,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: mono ? 'monospace' : LaText.fontRegular,
                  fontSize: 13,
                  color: v.isEmpty ? LaColors.textMuted : LaColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.symmetric(vertical: LaSpace.xxl),
      child: const Column(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          SizedBox(height: LaSpace.md),
          Text('กำลังโหลดข้อมูลคำขอ...', style: LaText.bodyMuted),
        ],
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  final String message;
  const _ErrorBlock({required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.lg),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: LaColors.statusRejectedFg),
          const SizedBox(width: LaSpace.sm),
          Expanded(
            child: Text(
              message,
              style: LaText.body.copyWith(color: LaColors.statusRejectedFg),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  final String? uuid;
  const _EmptyBlock({this.uuid});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.xxl),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: LaColors.primary.withOpacity(.10),
              borderRadius: BorderRadius.circular(LaRadius.lg),
            ),
            child: const Icon(Icons.inbox_rounded,
                size: 36, color: LaColors.primary),
          ),
          const SizedBox(height: LaSpace.md),
          Text(
            uuid != null && uuid!.isNotEmpty
                ? 'ไม่พบข้อมูลคำขอ (uuid: ${uuid!.substring(0, uuid!.length.clamp(0, 8))})'
                : 'ไม่พบข้อมูลคำขอ',
            style: LaText.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: LaSpace.sm),
          const Text(
            'ตรวจสอบว่า uuid ถูกต้อง หรือกด "ย้อนกลับ" เพื่อเลือกรายการใหม่',
            style: LaText.bodyMuted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Rounds section — ขั้นตอนการส่งคำร้องขออนุมัติ (read-only current step card)
// - แสดง step ปัจจุบัน (isCurrent=true) จาก approval detail
// - ไม่มีปุ่ม "เพิ่มการร้องขออนุมัติ" / "อนุมัติ" / "ปฏิเสธ" (read-only)
// ============================================================================

class _RoundsSection extends StatelessWidget {
  final LicenseApproveDetailViewModel vm;
  const _RoundsSection({required this.vm});

  @override
  Widget build(BuildContext context) {
    final steps = vm.currentSteps;
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header band (ไม่มีปุ่ม "เพิ่มการร้องขออนุมัติ") ───
          Row(
            children: [
              const Icon(Icons.folder_open_rounded,
                  color: LaColors.primaryDark),
              const SizedBox(width: LaSpace.sm),
              const Text('ขั้นตอนการส่งคำร้องขออนุมัติ',
                  style: LaText.h2),
              const SizedBox(width: LaSpace.sm),
              if (steps.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: LaColors.primary.withOpacity(.10),
                    borderRadius: BorderRadius.circular(LaRadius.pill),
                  ),
                  child: Text(
                    '${steps.length} ขั้น',
                    style: const TextStyle(
                      color: LaColors.primaryDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: LaSpace.md),
          _ErrorBanner(vm: vm),
          // ─── Content ───
          if (vm.isLoadingApproval && steps.isEmpty)
            const _RoundsLoading()
          else if (steps.isEmpty)
            const _RoundsEmpty()
          else
            _StepCard(step: _findCurrent(steps)),
        ],
      ),
    );
  }

  ApprovalStepV2? _findCurrent(List<ApprovalStepV2> steps) {
    for (final s in steps) {
      if (s.isCurrent) return s;
    }
    return steps.first;
  }
}

class _StepCard extends StatelessWidget {
  final ApprovalStepV2? step;
  const _StepCard({this.step});

  static const _pendingBg = LaColors.statusPendingBg;
  static const _pendingFg = LaColors.statusPendingFg;

  String _short(String uuid) {
    if (uuid.isEmpty) return '-';
    if (uuid.length <= 8) return uuid;
    return uuid.substring(0, 8);
  }

  @override
  Widget build(BuildContext context) {
    if (step == null) return const _RoundsEmpty();
    final s = step!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LaRadius.lg),
        border: Border.all(color: _pendingFg.withOpacity(.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _pendingFg.withOpacity(.15),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── Top accent bar ───
          Container(
            height: 3,
            decoration: const BoxDecoration(
              color: _pendingFg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(LaRadius.lg),
                topRight: Radius.circular(LaRadius.lg),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                LaSpace.lg, LaSpace.md, LaSpace.lg, LaSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ─── Header row: icon + step name + status ───
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _pendingBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.hourglass_top_rounded,
                        color: _pendingFg,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: LaSpace.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              AutoSizeText(
                                'ขั้นที่ ${s.stepOrder ?? '-'}',
                                minFontSize: 16,
                                maxFontSize: 20,
                                style: LaText.h2,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _pendingBg,
                                  borderRadius:
                                      BorderRadius.circular(LaRadius.pill),
                                ),
                                child: Text(
                                  s.statusLabel ??
                                      (s.status.isEmpty
                                          ? 'รอดำเนินการ'
                                          : s.status),
                                  style: const TextStyle(
                                    color: _pendingFg,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              if (s.isCurrent) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: LaColors.primary.withOpacity(.15),
                                    borderRadius:
                                        BorderRadius.circular(LaRadius.pill),
                                  ),
                                  child: const Text(
                                    'ขั้นปัจจุบัน',
                                    style: TextStyle(
                                      color: LaColors.primaryDark,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.stepName.isEmpty
                                ? 'กำลังดำเนินการ'
                                : s.stepName,
                            style: const TextStyle(
                              color: _pendingFg,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: LaSpace.md),
                // ─── Bottom stats row: position + uuid ───
                Row(
                  children: [
                    Icon(Icons.badge_outlined,
                        size: 14, color: LaColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      s.positionName.isEmpty ? '-' : s.positionName,
                      style: LaText.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      '#${_short(s.uuid)}',
                      style: const TextStyle(
                        color: LaColors.textMuted,
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ─── Toolbar: อนุมัติ / ปฏิเสธ / refresh ───
          if (s.isCurrent || s.canAct)
            Consumer<LicenseApproveDetailViewModel>(
              builder: (ctx, vm, _) {
                final isActing =
                    vm.isActing && vm.actingStepUuid == s.uuid;
                return Container(
                  decoration: const BoxDecoration(
                    color: LaColors.surfaceMuted,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(LaRadius.lg),
                      bottomRight: Radius.circular(LaRadius.lg),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: LaSpace.lg, vertical: LaSpace.sm),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ToolbarButton(
                          label: 'อนุมัติ',
                          icon: Icons.check_rounded,
                          fg: Colors.white,
                          bg: LaColors.statusApprovedFg,
                          isLoading: isActing,
                          onTap: isActing
                              ? null
                              : () => _onApprove(ctx, vm, s),
                        ),
                      ),
                      const SizedBox(width: LaSpace.sm),
                      Expanded(
                        child: _ToolbarButton(
                          label: 'ปฏิเสธ',
                          icon: Icons.close_rounded,
                          fg: LaColors.statusRejectedFg,
                          bg: LaColors.statusRejectedBg,
                          isLoading: false,
                          onTap: isActing
                              ? null
                              : () => _onReject(ctx, vm, s),
                        ),
                      ),
                      const SizedBox(width: LaSpace.sm),
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: LaColors.border),
                          borderRadius: BorderRadius.circular(LaRadius.md),
                        ),
                        child: InkWell(
                          onTap: vm.isLoadingApproval
                              ? null
                              : vm.reloadApprovalDetail,
                          borderRadius:
                              BorderRadius.circular(LaRadius.md),
                          child: Icon(
                            Icons.refresh_rounded,
                            size: 16,
                            color: vm.isLoadingApproval
                                ? LaColors.textMuted
                                : LaColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _onApprove(
    BuildContext context,
    LicenseApproveDetailViewModel vm,
    ApprovalStepV2 step,
  ) async {
    final remark = await _showRemarkDialog(
      context,
      title: 'อนุมัติ',
      hint: 'หมายเหตุ (ไม่บังคับ)',
      accent: LaColors.statusApprovedFg,
      confirmLabel: 'อนุมัติ',
    );
    if (remark == null) return;
    if (!context.mounted) return;
    final ok = await vm.approveStep(step: step);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'อนุมัติสำเร็จ'
            : (vm.actionError ?? 'อนุมัติไม่สำเร็จ')),
        backgroundColor: ok
            ? LaColors.statusApprovedFg
            : LaColors.statusRejectedFg,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _onReject(
    BuildContext context,
    LicenseApproveDetailViewModel vm,
    ApprovalStepV2 step,
  ) async {
    final remark = await _showRemarkDialog(
      context,
      title: 'ไม่อนุมัติ',
      hint: 'เหตุผล (จำเป็นต้องระบุ)',
      accent: LaColors.statusRejectedFg,
      confirmLabel: 'ปฏิเสธ',
      requireRemark: true,
    );
    if (remark == null || remark.isEmpty) return;
    if (!context.mounted) return;
    final ok = await vm.rejectStep(step: step, remark: remark);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'ปฏิเสธสำเร็จ'
            : (vm.actionError ?? 'ปฏิเสธไม่สำเร็จ')),
        backgroundColor: ok
            ? LaColors.statusApprovedFg
            : LaColors.statusRejectedFg,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

Future<String?> _showRemarkDialog(
  BuildContext context, {
  required String title,
  required String hint,
  required Color accent,
  required String confirmLabel,
  bool requireRemark = false,
}) async {
  final ctrl = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: ctrl,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(null),
          child: const Text('ยกเลิก'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: accent),
          onPressed: () {
            final txt = ctrl.text.trim();
            if (requireRemark && txt.isEmpty) return;
            Navigator.of(ctx).pop(txt);
          },
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  ctrl.dispose();
  return result;
}

class _ToolbarButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color fg;
  final Color bg;
  final bool isLoading;
  final VoidCallback? onTap;
  const _ToolbarButton({
    required this.label,
    required this.icon,
    required this.fg,
    required this.bg,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(LaRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LaRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(fg),
                  ),
                )
              else
                Icon(icon, color: fg, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundsLoading extends StatelessWidget {
  const _RoundsLoading();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: LaSpace.xxl),
      alignment: Alignment.center,
      child: const Column(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          SizedBox(height: LaSpace.md),
          Text('กำลังโหลดข้อมูลการร้องขออนุมัติ...', style: LaText.bodyMuted),
        ],
      ),
    );
  }
}

class _RoundsEmpty extends StatelessWidget {
  const _RoundsEmpty();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: LaSpace.xxl),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: LaColors.primary.withOpacity(.10),
              borderRadius: BorderRadius.circular(LaRadius.lg),
            ),
            child: const Icon(Icons.folder_off_rounded,
                size: 36, color: LaColors.primary),
          ),
          const SizedBox(height: LaSpace.md),
          const Text('ยังไม่มีการร้องขออนุมัติ', style: LaText.h2),
          const SizedBox(height: LaSpace.sm),
          const Text(
            'ไม่พบขั้นตอนการอนุมัติสำหรับคำขอนี้',
            style: LaText.bodyMuted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final LicenseApproveDetailViewModel vm;
  const _ErrorBanner({required this.vm});
  @override
  Widget build(BuildContext context) {
    final err = vm.approvalError;
    if (err == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: LaSpace.md),
      child: Container(
        padding: const EdgeInsets.all(LaSpace.sm),
        decoration: BoxDecoration(
          color: LaColors.statusRejectedBg.withOpacity(.5),
          borderRadius: BorderRadius.circular(LaRadius.md),
          border: Border.all(color: LaColors.statusRejectedFg.withOpacity(.25)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: LaColors.statusRejectedFg, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                err,
                style: LaText.caption.copyWith(
                  color: LaColors.statusRejectedFg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}