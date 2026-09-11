// ============================================================================
// submit_approval_detail_step1.dart
// ============================================================================
// Step 1 — ตรวจสอบรายส่งคำร้องขออนุมัติ
// - แสดง "ข้อมูลเบื้องต้น" ของคำร้อง (uuid / สถานะ / lease / zone / ลูกค้า)
// - โหลดผ่าน LicenseSubmitApprovalDetailService.fetchSubmitApprovalDetail(uuid)
// - UI structure พอร์ตมาจาก FactCheckDetailStep1 (เฉพาะส่วน "ข้อมูลเบื้องต้น"
//   — ไม่รวม "รอบตรวจ / Inspection Rounds")
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/license_submit_approval_theme.dart';
import '../../viewmodels/license_submit_approval_detail_view_model.dart';
import '../../models/license_submit_approval_detail_model.dart';
import '../../services/license_submit_approval_detail_service.dart';
import 'submit_approval_rounds_section.dart';

// ─── Cross-module: ใช้ข้อมูลคำขอจาก license_request_page (read-only) ───
import '../../../license_attach_page/views/widgets/request_detail_zone_row.dart';
import '../../../license_attach_page/views/widgets/request_detail_section_title.dart';
import '../../../license_request_page/viewmodels/license_request_detail_step1_view_model.dart';
import '../../../license_request_page/views/widgets/request_detail_person_section.dart';
import '../../../license_request_page/views/widgets/request_detail_shop_section.dart';
import '../../../license_request_page/views/widgets/request_detail_contract_section.dart';

class SubmitApprovalDetailStep1 extends StatefulWidget {
  final String? requestUuid;
  const SubmitApprovalDetailStep1({super.key, this.requestUuid});

  @override
  State<SubmitApprovalDetailStep1> createState() =>
      _SubmitApprovalDetailStep1State();
}

class _SubmitApprovalDetailStep1State extends State<SubmitApprovalDetailStep1> {
  final _service = LicenseSubmitApprovalDetailService();

  SubmitApprovalDetail? _detail;
  bool _isLoading = false;
  String? _loadError;
  String? _loadedUuid;

  @override
  void initState() {
    super.initState();
    _loadIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadIfNeeded();
  }

  Future<void> _loadIfNeeded() async {
    final uuid = widget.requestUuid;
    // ignore: avoid_print
    print(
        '🔵 [Step1._loadIfNeeded] uuid=$uuid  loadedUuid=$_loadedUuid  hasDetail=${_detail != null}');
    if (uuid == null || uuid.isEmpty) return;
    if (_loadedUuid == uuid && _detail != null) return;

    setState(() {
      _isLoading = true;
      _loadError = null;
      _loadedUuid = uuid;
    });

    try {
      final detail = await _service.fetchSubmitApprovalDetail(uuid: uuid);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Touch VM so it rebuilds when step changes
    context.watch<LicenseSubmitApprovalDetailViewModel>();

    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Segmented tabs ───
              const _SubmitApprovalSegmentedTabs(),
              // ─── TabBarView: 2 แท็บ ───
              Expanded(
                child: TabBarView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Tab 1: ข้อมูลการส่งคำร้อง (เนื้อหาเดิม)
                    // ⚠️ ห้าม const! ต้อง recreate instance ทุกครั้ง parent rebuild
                    // เพื่อให้ TabBarView rebuild tab นี้ตาม state ของ parent
                    _SubmitApprovalInfoTab(),
                    // Tab 2: ข้อมูลคำขอ
                    _RequestInfoTab(requestUuid: widget.requestUuid),
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
class _SubmitApprovalSegmentedTabs extends StatelessWidget {
  const _SubmitApprovalSegmentedTabs();

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
                              icon: Icons.send_rounded,
                              label: 'ข้อมูลการส่งคำร้อง',
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
// Tab 1: ข้อมูลการส่งคำร้อง (เนื้อหาเดิม)
// =============================================================================
class _SubmitApprovalInfoTab extends StatelessWidget {
  const _SubmitApprovalInfoTab();

  @override
  Widget build(BuildContext context) {
    // Touch VM so it rebuilds when step changes
    context.watch<LicenseSubmitApprovalDetailViewModel>();
    final step1State =
        context.findAncestorStateOfType<_SubmitApprovalDetailStep1State>();

    if (step1State == null) {
      return const SizedBox.shrink();
    }

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
                    Icon(Icons.send_rounded,
                        size: 18, color: LaColors.primaryDark),
                    SizedBox(width: 8),
                    Text('ตรวจสอบรายส่งคำร้องขออนุมัติ', style: LaText.h2),
                  ],
                ),
              ),
              const SizedBox(height: LaSpace.md),

              // ─── Loading / Error / Data ───
              if (step1State._isLoading)
                const _LoadingBlock()
              else if (step1State._loadError != null)
                _ErrorBlock(message: step1State._loadError!)
              else if (step1State._detail == null ||
                  step1State._detail!.uuid.isEmpty)
                _EmptyBlock(uuid: step1State.widget.requestUuid)
              else
                _RequestSummaryCard(model: step1State._detail!),

              const SizedBox(height: LaSpace.lg),

              // ─── Main action — เริ่มส่งการร้องขออนุมัติ (startRound API) ───
              // ผูกกับ model.approvalPending:
              // - false → แสดงปุ่ม (ยังไม่เคยส่ง)
              // - true  → แสดงสถานะ "ส่งแล้ว" (เคยส่งจาก API แล้ว)
              SubmitApprovalRoundsSection(
                requestUuid: step1State.widget.requestUuid,
                hasPendingApproval: step1State._detail!.approvalPending,
                submittedAt: step1State._detail!.submittedAt,
              ),

              const SizedBox(height: LaSpace.lg),

              // ─── Footer info ───
              const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 14, color: LaColors.textMuted),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'ตรวจสอบรายการให้ครบถ้วนก่อนกด "เริ่มส่งคำร้องขออนุมัติ"',
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
// Sub widgets — พอร์ตมาจาก fact_check_detail_step1.dart
// ============================================================================

class _RequestSummaryCard extends StatelessWidget {
  final SubmitApprovalDetail model;
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
              _StatusBadge(label: model.statusLabel),
              const Spacer(),
              _PillIcon(
                icon: Icons.tag_rounded,
                text: 'รหัสรายการ: ${_short(model.uuid)}',
                muted: true,
              ),
            ],
          ),
          const SizedBox(height: LaSpace.lg),

          // ─── Grid 2 columns (matches approve_detail_step1.dart pattern) ───
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoColumn(
                  title: 'ข้อมูลพื้นที่',
                  items: [
                    // [HIDDEN per user request] — keep commented for reference
                    // _InfoItem(
                    //   icon: Icons.receipt_long_rounded,
                    //   label: 'เลขที่สัญญา',
                    //   value: nr?.leaseNumber,
                    // ),
                    // _InfoItem(
                    //   icon: Icons.calendar_today_rounded,
                    //   label: 'วันที่สิ้นสุด',
                    //   value: _formatDate(nr?.ldate),
                    // ),
                    _InfoItem(
                      icon: Icons.location_on_rounded,
                      label: 'บริเวณ / โซน',
                      value: _joinZones(nr),
                    ),
                    _InfoItem(
                      icon: Icons.numbers_rounded,
                      label: 'รหัสพื้นที่',
                      value: nr.ln,
                      mono: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: LaSpace.lg),
              Expanded(
                child: _InfoColumn(
                  title: 'ข้อมูลผู้ขอ',
                  items: [
                    _InfoItem(
                      icon: Icons.person_rounded,
                      label: 'ชื่อ-นามสกุล',
                      value: client.cname,
                    ),
                    // [HIDDEN per user request] — keep commented for reference
                    // _InfoItem(
                    //   icon: Icons.phone_rounded,
                    //   label: 'เบอร์โทร',
                    //   value: formatPhoneNumber(client?.tel ?? ''),
                    //   mono: true,
                    // ),
                    _InfoItem(
                      icon: Icons.confirmation_number_rounded,
                      label: 'เลขประจำตัวผู้เสียภาษี',
                      value: client.tax,
                      mono: true,
                    ),
                    // [HIDDEN per user request] — keep commented for reference
                    // _InfoItem(
                    //   icon: Icons.location_on_outlined,
                    //   label: 'ที่อยู่',
                    //   value: client?.addr1,
                    // ),
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
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 14, color: LaColors.textMuted),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'ข้อมูลด้านบนเป็น "ภาพรวมคำขอ" '
                    'สำหรับตรวจสอบเบื้องต้น',
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

  // [HIDDEN per user request] วันที่ส่งคำร้อง field commented out
  // String? _formatDate(String? raw) {
  //   if (raw == null || raw.isEmpty) return null;
  //   try {
  //     final dt = DateTime.parse(raw);
  //     return DateFormat('dd/MM/yyyy').format(dt);
  //   } catch (_) {
  //     return raw;
  //   }
  // }

  String? _joinZones(NewRequest? nr) {
    if (nr == null) return null;
    final parts = <String>[
      if (nr.subzone.isNotEmpty && nr.subzone != '-') nr.subzone,
      if (nr.zn.isNotEmpty && nr.zn != '-') nr.zn,
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
          Text('กำลังโหลดข้อมูลคำร้อง...', style: LaText.bodyMuted),
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
                ? 'ไม่พบข้อมูลคำร้อง (uuid: ${uuid!.substring(0, uuid!.length.clamp(0, 8))})'
                : 'ไม่พบข้อมูลคำร้อง',
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
