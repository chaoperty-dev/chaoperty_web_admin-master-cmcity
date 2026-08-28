// ============================================================================
// payment_detail_step1.dart
// ============================================================================
// Step 1 — ตรวจสอบรายการรับชำระ
// Layout แบบ 2 คอลัมน์ (icon + label + value) เหมือน fact_check
// Render PaymentDetail ที่โหลดจาก VM (uuid ถูกส่งมาตอนกด เรียกดู จาก list page)
// ============================================================================

import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show immutable;

import '../../../../unity/FormatPhone.dart';
import '../../models/license_payment_attachment.dart';
import '../../models/license_payment_detail_model.dart';
import '../../models/license_prepayment_model.dart' hide formatMoney;
import '../../services/license_payment_detail_service.dart';
import '../theme/license_payment_theme.dart';
import '../../viewmodels/license_payment_detail_view_model.dart';
import 'receipt_entry_stepper_dialog.dart';

// ─── Cross-module: ใช้ข้อมูลคำขอจาก license_request_page (read-only) ───
import '../../../license_attach_page/views/widgets/request_detail_zone_row.dart';
import '../../../license_attach_page/views/widgets/request_detail_section_title.dart';
import '../../../license_request_page/viewmodels/license_request_detail_step1_view_model.dart';
import '../../../license_request_page/views/widgets/request_detail_person_section.dart';
import '../../../license_request_page/views/widgets/request_detail_shop_section.dart';
import '../../../license_request_page/views/widgets/request_detail_contract_section.dart';

class PaymentDetailStep1 extends StatelessWidget {
  const PaymentDetailStep1({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          // ─── ดึง requestUuid จาก PaymentDetailViewModel (ส่งต่อให้ Tab 2) ───
          final uuid = context.select<LicensePaymentDetailViewModel, String?>(
            (v) => v.requestUuid,
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Segmented tabs (สไตล์เดียวกับ attach_detail_step1) ───
              const _PaymentSegmentedTabs(),
              // ─── TabBarView: 2 แท็บ ───
              Expanded(
                child: TabBarView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Tab 1: ข้อมูลการชำระ (เนื้อหาเดิม)
                    const _PaymentInfoTab(),
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
// Segmented Tabs — sliding indicator (สไตล์เดียวกับ attach_detail_step1)
// =============================================================================
class _PaymentSegmentedTabs extends StatelessWidget {
  const _PaymentSegmentedTabs();

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
                      // ─── Sliding indicator ───
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
                      // ─── Tab labels ───
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
                              icon: Icons.payments_outlined,
                              label: 'ข้อมูลการชำระ',
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
// Tab Label — icon + label ใช้ index เพื่อเปลี่ยนสีตาม active
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
// Tab 1: ข้อมูลการชำระ (เนื้อหาเดิม — summary + prepayment + status + footer)
// =============================================================================
/// Snapshot ของ VM fields ที่ _PaymentInfoTab ใช้ → ให้ Selector เทียบกับ deep equality
@immutable
class _PaymentInfoSnapshot {
  final bool isLoading;
  final PaymentDetail? detail;
  final String? errorMessage;
  final PrepaymentData? prepayment;
  final RequestPaymentsResponse? payments;

  const _PaymentInfoSnapshot({
    required this.isLoading,
    required this.detail,
    required this.errorMessage,
    required this.prepayment,
    required this.payments,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _PaymentInfoSnapshot &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage &&
        identical(other.detail, detail) &&
        identical(other.prepayment, prepayment) &&
        identical(other.payments, payments);
  }

  @override
  int get hashCode => Object.hash(
        isLoading,
        errorMessage,
        detail,
        prepayment,
        payments,
      );
}

class _PaymentInfoTab extends StatelessWidget {
  const _PaymentInfoTab();

  @override
  Widget build(BuildContext context) {
    // ✅ Selector — rebuild เฉพาะเมื่อ fields ที่ UI ใช้เปลี่ยน
    return Selector<LicensePaymentDetailViewModel, _PaymentInfoSnapshot>(
      selector: (_, vm) => _PaymentInfoSnapshot(
        isLoading: vm.isLoading,
        detail: vm.detail,
        errorMessage: vm.errorMessage,
        prepayment: vm.prepayment,
        payments: vm.payments,
      ),
      shouldRebuild: (a, b) => a != b,
      builder: (context, snap, _) {
        // ใช้ context.read สำหรับ action callbacks (onProceed)
        final vm = context.read<LicensePaymentDetailViewModel>();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(LaSpace.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── Loading / Error / Data ───
                  if (snap.isLoading && snap.detail == null)
                    const _LoadingBlock()
                  else if (snap.errorMessage != null && snap.detail == null)
                    _ErrorBlock(message: snap.errorMessage!)
                  else if (snap.detail == null)
                    _EmptyBlock(uuid: snap.detail?.uuid)
                  else
                    _PaymentSummaryCard(detail: snap.detail!),

                  const SizedBox(height: LaSpace.lg),

                  // ─── Prepayment (การจ่ายล่วงหน้า) ───
                  if (snap.prepayment != null) ...[
                    _PrepaymentCard(
                      prepayment: snap.prepayment!,
                      payments: snap.payments?.data ?? const [],
                      onProceed: (item) => _handleProceed(context, item, vm),
                    ),
                    const SizedBox(height: LaSpace.lg),
                  ],

                  // ─── สถานะการชำระ (จาก GET .../payments) ───
                  if (snap.payments != null) ...[
                    _PaymentStatusCard(
                      payments: snap.payments!,
                      details: snap.prepayment?.details ?? const [],
                    ),
                    const SizedBox(height: LaSpace.lg),
                  ],

                  // ─── Footer note ───
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
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// Tab 2: ข้อมูลคำขอ (placeholder)
// =============================================================================
// =============================================================================
// Tab 2: ข้อมูลคำขอ — โหลดผ่าน LicenseRequestDetailStep1ViewModel
// ใช้ widgets เดียวกับ attach_detail_step1 (read-only mode)
// =============================================================================
class _RequestInfoTab extends StatefulWidget {
  /// UUID ของ Request (ส่งต่อมาจาก parent เพื่อโหลด review data)
  final String? requestUuid;

  const _RequestInfoTab({this.requestUuid});

  @override
  State<_RequestInfoTab> createState() => _RequestInfoTabState();
}

class _RequestInfoTabState extends State<_RequestInfoTab> {
  // ★ ใช้ VM เดียวกับ license_request_page (import ข้าม module)
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
// Loading state สำหรับ Tab 2 (ข้อมูลคำขอ)
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

// =============================================================================
// Error state สำหรับ Tab 2 (ข้อมูลคำขอ)
// =============================================================================
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
// Summary card — 2 columns (info item pattern)
// ============================================================================

class _PaymentSummaryCard extends StatelessWidget {
  final PaymentDetail detail;
  const _PaymentSummaryCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    final d = detail;
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header row: status + uuid ───
          Row(
            children: [
              _StatusBadge(label: d.statusLabel),
              const Spacer(),
              _PillIcon(
                icon: Icons.tag_rounded,
                text: 'UUID: ${_short(d.uuid)}',
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
                      value: d.paymentNo,
                    ),
                    _InfoItem(
                      icon: Icons.calendar_today_rounded,
                      label: 'วันที่สิ้นสุด',
                      value: _formatDate(d.paidAt),
                    ),
                    _InfoItem(
                      icon: Icons.location_on_rounded,
                      label: 'บริเวณ / โซน',
                      value: d.payType,
                    ),
                    _InfoItem(
                      icon: Icons.numbers_rounded,
                      label: 'รหัสพื้นที่',
                      value: d.methodName,
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
                      value: d.payerName,
                    ),
                    _InfoItem(
                      icon: Icons.phone_rounded,
                      label: 'เบอร์โทร',
                      value: formatPhoneNumber(d.clientTel),
                      mono: true,
                    ),
                    _InfoItem(
                      icon: Icons.confirmation_number_rounded,
                      label: 'เลขประจำตัวผู้เสียภาษี',
                      value: d.clientTax,
                      mono: true,
                    ),
                    _InfoItem(
                      icon: Icons.place_rounded,
                      label: 'ที่อยู่',
                      value: d.clientAddr,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
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

  String _short(String uuid) {
    if (uuid.isEmpty) return '-';
    if (uuid.length <= 12) return uuid;
    return '${uuid.substring(0, 8)}…';
  }
}

// ============================================================================
// _handleProceed — สร้าง draft (ถ้ายังไม่มี) แล้วเปิด popup stepper 3 สเตป
//   Step 1: เลือกช่องทางรับเงิน (optional)
//   Step 2: แนบรูปสลิป (optional)
//   Step 3: บันทึกการรับชำระ (amount + receipt_no + book_no + date)
// ============================================================================

Future<void> _handleProceed(
  BuildContext context,
  PrepaymentItem item,
  LicensePaymentDetailViewModel vm,
) async {
  // 1) หา payment ที่ผูกกับ debtLineUuid นี้ (ถ้ามี)
  PaymentDetail? payment;
  for (final p in vm.payments?.data ?? const []) {
    if (p.debtLineUuid == item.uuid) {
      payment = p;
      break;
    }
  }

  // 2) ถ้ายังไม่มี → เปิด popup ที่ step 1 (เลือก external/internal)
  //    **Dialog จะยิง POST /v2/payments หลังเลือก system (internal) + method เสร็จ**
  //    ไม่ยิงล่วงหน้า เพราะต้องรู้ payment_system + payment_method_id ก่อน
  if (payment == null || payment.uuid.isEmpty) {
    // ─── ดึง defaults จากประวัติ (GET /v2/requests/{uuid}/payments) ───
    //    - paymentSystem: external/internal (most recent)
    //    - paymentMethodId: เฉพาะกรณี internal (most recent ที่มี)
    String? defaultPaymentSystem;
    String? defaultMethodId;
    final history = vm.payments?.data ?? const <PaymentDetail>[];
    for (final h in history) {
      final sys = h.paymentSystem.trim();
      if (sys.isNotEmpty) {
        defaultPaymentSystem = sys;
      }
      final mid = (h.paymentMethodId ?? '').trim();
      if (mid.isNotEmpty) {
        defaultMethodId = mid;
      }
      if (defaultPaymentSystem != null) break; // ใช้ most recent พอ
    }

    if (!context.mounted) return;
    final result = await showReceiptEntryStepperDialog(
      context: context,
      payment:
          const PaymentDetail(), // ยังไม่มี — dialog จะสร้างเองตอนไป step 3
      defaultAmount: item.totalAmount,
      initialStep: 1,
      paymentSystem: defaultPaymentSystem ?? 'external',
      defaultMethodId: defaultMethodId,
      requestUuid: vm.requestUuid,
      debtLineUuid: item.uuid,
      payType: vm.payTypeOf(item),
    );
    if (!context.mounted) return;
    // รีโหลดเสมอหลังปิด dialog (อาจอัปโหลดหลักฐานแล้ว แม้ไม่ได้กดยืนยัน step 3)
    await vm.reload();
    if (!context.mounted) return;
    if (result != null) _showSuccessSnack(context, result);
    return;
  }

  // 3) มี payment อยู่แล้ว → เปิด popup ที่ step 3 เลย
  //    (ข้าม step 1/2 เพราะ draft/method ถูกสร้างมาแล้ว)
  if (!context.mounted) return;
  final result = await showReceiptEntryStepperDialog(
    context: context,
    payment: payment,
    defaultAmount: item.totalAmount,
    initialStep: 2, // skip system picker — method/system มาจาก payment แล้ว
    paymentSystem: payment.paymentSystem,
  );
  if (!context.mounted) return;
  // รีโหลดเสมอหลังปิด dialog (เผื่อผู้ใช้อัปโหลดรูปใน step 2 แล้วปิดโดยไม่ยืนยัน)
  await vm.reload();
  if (!context.mounted) return;
  if (result != null) _showSuccessSnack(context, result);
}

void _showSuccessSnack(BuildContext context, PaymentDetail result) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'บันทึกการรับชำระเรียบร้อย: '
        '${result.paymentNo.isNotEmpty ? result.paymentNo : result.uuid}',
      ),
      backgroundColor: LaColors.statusApprovedFg,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// เปิด dialog upload จาก _PaymentStatusRow
/// (payment มีอยู่แล้ว — เปิดเฉพาะ step 2 ให้ user แนบรูป โดยไม่ต้องเลือก system ใหม่)
Future<void> _openUploadDialog(
  BuildContext context,
  PaymentDetail payment,
) async {
  if (!context.mounted) return;
  final vm = context.read<LicensePaymentDetailViewModel>();
  final result = await showReceiptEntryStepperDialog(
    context: context,
    payment: payment,
    defaultAmount: payment.amount,
    initialStep: 2, // ข้าม step 1 — system/method มาจาก payment แล้ว
    paymentSystem: payment.paymentSystem,
  );
  if (!context.mounted) return;
  await vm.reload(); // รีโหลด list หลังปิด dialog (เผื่ออัปโหลดสำเร็จ)
  if (!context.mounted) return;
  if (result != null) _showSuccessSnack(context, result);
}

// ============================================================================
// Prepayment card — รายการที่ต้องชำระ (from GET .../prepayment)
// ============================================================================

class _PrepaymentCard extends StatelessWidget {
  final PrepaymentData prepayment;
  final List<PaymentDetail> payments;
  final void Function(PrepaymentItem item) onProceed;
  const _PrepaymentCard({
    required this.prepayment,
    this.payments = const [],
    required this.onProceed,
  });

  /// สถานะของแต่ละรายการที่ต้องชำระ (join กับรายการชำระ)
  /// - มี payment ที่ status=paid + amount_received → ชำระแล้ว
  /// - มี payment + มี latest_attachment           → หลักฐานแล้ว รอชืนยัน
  /// - มี payment (draft/อื่นๆ)                    → รอชำระ
  /// - ไม่มี payment เลย                          → ยังไม่ทำรายการ
  PaymentDetail? paymentOf(PrepaymentItem item) {
    for (final p in payments) {
      if (p.debtLineUuid == item.uuid) return p;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final items = prepayment.details;
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ───
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: LaColors.primaryLight,
                  borderRadius: BorderRadius.circular(LaRadius.sm),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    size: 18, color: LaColors.primaryDark),
              ),
              const SizedBox(width: LaSpace.sm),
              Text('รายการที่ต้องชำระ', style: LaText.h2),
              if (items.isNotEmpty) ...[
                const SizedBox(width: LaSpace.sm),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: LaColors.primaryLight,
                    borderRadius: BorderRadius.circular(LaRadius.pill),
                  ),
                  child: Text(
                    '${items.length} รายการ',
                    style: LaText.caption.copyWith(
                      color: LaColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              // ✅ จำกัดความกว้าง — กัน overflow ตอนจอแคบ
              Flexible(
                child: _PillIcon(
                  icon: Icons.tag_rounded,
                  text: 'Prepay: ${_short(prepayment.uuid ?? '')}',
                  muted: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: LaSpace.md),

          if (prepayment.requestUuid != null &&
              prepayment.requestUuid!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: LaSpace.md),
              child: _InfoItem(
                icon: Icons.link_rounded,
                label: 'Request UUID',
                value: prepayment.requestUuid,
                mono: true,
              ),
            ),

          // ─── รายการ (ตารางบนจอกว้าง / การ์ดบนจอแคบ) ───
          if (items.isEmpty)
            Container(
              padding: const EdgeInsets.all(LaSpace.lg),
              decoration: LaDecor.softCard(),
              child: const Center(
                child: Text('ไม่พบรายการที่ต้องชำระ', style: LaText.bodyMuted),
              ),
            )
          else
            _PrepaymentList(
              items: items,
              paymentOf: paymentOf,
              onProceed: onProceed,
            ),

          const SizedBox(height: LaSpace.md),

          // ─── Grand total ───
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: LaSpace.md, vertical: LaSpace.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  LaColors.primaryLight,
                  LaColors.primaryLight.withOpacity(.5),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(LaRadius.md),
              border: Border.all(color: LaColors.primary.withOpacity(.18)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: LaColors.primaryDark,
                    borderRadius: BorderRadius.circular(LaRadius.sm),
                  ),
                  child: const Icon(Icons.summarize_rounded,
                      size: 18, color: Colors.white),
                ),
                const SizedBox(width: LaSpace.sm),
                Text('รวมทั้งสิ้น', style: LaText.body),
                const Spacer(),
                Text(
                  prepayment.grandTotalDisplay,
                  style: LaText.h2.copyWith(
                    color: LaColors.primaryDark,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _short(String uuid) {
    if (uuid.isEmpty) return '-';
    if (uuid.length <= 12) return uuid;
    return '${uuid.substring(0, 8)}…';
  }
}

/// จุดตัดเปลี่ยนจากตารางเป็นการ์ด (px) — จอแคบกว่านี้ใช้การ์ดแทน
const double _prepayBreakpoint = 700;

class _PrepaymentList extends StatelessWidget {
  final List<PrepaymentItem> items;
  final PaymentDetail? Function(PrepaymentItem) paymentOf;
  final void Function(PrepaymentItem) onProceed;
  const _PrepaymentList({
    required this.items,
    required this.paymentOf,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _prepayBreakpoint) {
          // ─── จอแคบ: แสดงเป็นการ์ดแถวละ 1 รายการ ───
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(height: LaSpace.sm),
                _PrepaymentItemCard(
                  item: items[i],
                  payment: paymentOf(items[i]),
                  onProceed: onProceed,
                ),
              ],
            ],
          );
        }
        // ─── จอกว้าง: แสดงเป็นตาราง ───
        return _PrepaymentTable(
          items: items,
          paymentOf: paymentOf,
          onProceed: onProceed,
        );
      },
    );
  }
}

class _PrepaymentTable extends StatelessWidget {
  final List<PrepaymentItem> items;
  final PaymentDetail? Function(PrepaymentItem) paymentOf;
  final void Function(PrepaymentItem) onProceed;
  const _PrepaymentTable({
    required this.items,
    required this.paymentOf,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LaDecor.softCard(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row
          Container(
            color: LaColors.surfaceMuted,
            padding: const EdgeInsets.symmetric(
                horizontal: LaSpace.md, vertical: LaSpace.sm),
            child: Row(
              children: [
                Expanded(
                    flex: 3, child: Text('รายการ', style: LaText.tableHeader)),
                Expanded(
                    flex: 2, child: Text('สถานะ', style: LaText.tableHeader)),
                Expanded(
                    flex: 1, child: Text('หน่วย', style: LaText.tableHeader)),
                Expanded(
                    flex: 1, child: Text('งวด', style: LaText.tableHeader)),
                Expanded(
                    flex: 1, child: Text('จำนวน', style: LaText.tableHeader)),
                Expanded(
                    flex: 2, child: Text('วันที่', style: LaText.tableHeader)),
                Expanded(
                    flex: 2,
                    child: Text('รวม',
                        style: LaText.tableHeader, textAlign: TextAlign.right)),
                const SizedBox(width: 20),
                const SizedBox(width: 150),
              ],
            ),
          ),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: LaColors.border),
            _PrepaymentRow(
              item: items[i],
              payment: paymentOf(items[i]),
              onProceed: onProceed,
            ),
          ],
        ],
      ),
    );
  }
}

class _PrepaymentRow extends StatelessWidget {
  final PrepaymentItem item;
  final PaymentDetail? payment;
  final void Function(PrepaymentItem) onProceed;
  const _PrepaymentRow({
    required this.item,
    required this.payment,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    final date = (item.sdate ?? '').isNotEmpty || (item.ldate ?? '').isNotEmpty
        ? '${formatPrepayDate(item.sdate)} - ${formatPrepayDate(item.ldate)}'
        : '-';
    final shortUuid =
        item.uuid.length > 8 ? '${item.uuid.substring(0, 8)}…' : item.uuid;
    // ─── derive state จาก payment ───
    final hasPayment = payment != null && payment!.uuid.isNotEmpty;
    final hasAttachment = hasPayment &&
        payment!.latestAttachment != null &&
        payment!.latestAttachment!.uuid.isNotEmpty;
    final isPaid = hasPayment && payment!.status.toLowerCase() == 'paid';
    final statusText = !hasPayment
        ? 'ยังไม่ทำรายการ'
        : isPaid
            ? 'รออนุมัติ'
            : hasAttachment
                ? 'หลักฐานแล้ว รอชืนยัน'
                : (payment!.statusLabel.isNotEmpty
                    ? payment!.statusLabel
                    : 'รอชำระ');
    final hasButton = !isPaid;
    final buttonLabel = !hasPayment
        ? 'ทำรายการ'
        : hasAttachment
            ? 'รอบันทึกการชำระ'
            : 'ทำรายการต่อ';
    return InkWell(
      onTap: () => onProceed(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: LaSpace.md, vertical: LaSpace.sm),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: LaColors.primaryLight,
                      borderRadius: BorderRadius.circular(LaRadius.sm),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      size: 16,
                      color: LaColors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: LaSpace.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item.expname, style: LaText.tableCell),
                        if (item.uuid.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              children: [
                                const Text('รหัส ', style: LaText.caption),
                                Text(shortUuid,
                                    style: LaText.caption.copyWith(
                                      fontFamily: 'monospace',
                                      color: LaColors.textMuted,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(flex: 2, child: _statusCell(statusText, hasAttachment)),
            Expanded(flex: 1, child: Text(item.unit, style: LaText.tableCell)),
            Expanded(
                flex: 1,
                child: Text(item.term ?? '-', style: LaText.tableCell)),
            Expanded(
                flex: 1, child: Text(item.qty ?? '-', style: LaText.tableCell)),
            Expanded(flex: 2, child: Text(date, style: LaText.tableCell)),
            Expanded(
              flex: 2,
              child: Text(
                item.totalDisplay,
                style: LaText.tableCell.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                  color: LaColors.primaryDark,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 20),
            SizedBox(
              width: 150,
              child: Align(
                alignment: Alignment.centerLeft,
                child: hasButton
                    ? _ActionButton(
                        label: buttonLabel,
                        pendingAttachment: hasAttachment,
                        onPressed: () => onProceed(item),
                      )
                    : Text('-',
                        style: LaText.tableCell.copyWith(
                          color: LaColors.textMuted,
                        )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusCell(String text, bool hasAttachment) {
    if (hasAttachment) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: LaColors.statusApprovedFg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: LaText.tableCell.copyWith(
                color: LaColors.statusApprovedFg,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
    return Text(text, style: LaText.tableCell);
  }
}

class _PrepaymentItemCard extends StatelessWidget {
  final PrepaymentItem item;
  final PaymentDetail? payment;
  final void Function(PrepaymentItem) onProceed;
  const _PrepaymentItemCard({
    required this.item,
    required this.payment,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    final date = (item.sdate ?? '').isNotEmpty || (item.ldate ?? '').isNotEmpty
        ? '${formatPrepayDate(item.sdate)} - ${formatPrepayDate(item.ldate)}'
        : '-';
    final shortUuid =
        item.uuid.length > 8 ? '${item.uuid.substring(0, 8)}…' : item.uuid;
    // ─── derive state จาก payment ───
    final hasPayment = payment != null && payment!.uuid.isNotEmpty;
    final hasAttachment = hasPayment &&
        payment!.latestAttachment != null &&
        payment!.latestAttachment!.uuid.isNotEmpty;
    final isPaid = hasPayment && payment!.status.toLowerCase() == 'paid';
    final hasButton = !isPaid;
    final buttonLabel = !hasPayment
        ? 'ทำรายการ'
        : hasAttachment
            ? 'รอบันทึกการชำระ'
            : 'ทำรายการต่อ';
    return InkWell(
      onTap: () => onProceed(item),
      borderRadius: BorderRadius.circular(LaRadius.md),
      child: Container(
        decoration: LaDecor.softCard(),
        padding: const EdgeInsets.all(LaSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: LaColors.primaryLight,
                    borderRadius: BorderRadius.circular(LaRadius.sm),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    size: 16,
                    color: LaColors.primaryDark,
                  ),
                ),
                const SizedBox(width: LaSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.expname, style: LaText.body),
                      if (item.uuid.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            children: [
                              const Text('รหัส ', style: LaText.caption),
                              Text(shortUuid,
                                  style: LaText.caption.copyWith(
                                    fontFamily: 'monospace',
                                    color: LaColors.textMuted,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: LaSpace.sm),
                Text(
                  item.totalDisplay,
                  style: LaText.body.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                    color: LaColors.primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: LaSpace.sm),
            Row(
              children: [
                Expanded(
                  child: _MiniField(label: 'หน่วย', value: item.unit),
                ),
                Expanded(
                  child: _MiniField(label: 'งวด', value: item.term ?? '-'),
                ),
                Expanded(
                  child: _MiniField(label: 'จำนวน', value: item.qty ?? '-'),
                ),
              ],
            ),
            const SizedBox(height: LaSpace.sm),
            Row(
              children: [
                Expanded(child: _MiniField(label: 'วันที่', value: date)),
                const SizedBox(width: LaSpace.sm),
                hasButton
                    ? _ActionButton(
                        label: buttonLabel,
                        pendingAttachment: hasAttachment,
                        onPressed: () => onProceed(item),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: LaColors.statusApprovedBg.withOpacity(.4),
                          borderRadius: BorderRadius.circular(LaRadius.pill),
                          border: Border.all(
                            color: LaColors.statusApprovedFg.withOpacity(.5),
                          ),
                        ),
                        child: Text(
                          'รออนุมัติ',
                          style: LaText.caption.copyWith(
                            color: LaColors.statusApprovedFg,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniField extends StatelessWidget {
  final String label;
  final String value;
  const _MiniField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: LaSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: LaText.label),
          const SizedBox(height: 2),
          Text(
            value,
            style: LaText.tableCell,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Payment status card — สถานะรายการชำระ (จาก GET .../payments)
// ============================================================================

class _PaymentStatusCard extends StatelessWidget {
  final RequestPaymentsResponse payments;
  final List<PrepaymentItem> details;
  const _PaymentStatusCard({
    required this.payments,
    this.details = const [],
  });

  @override
  Widget build(BuildContext context) {
    final items = payments.data;
    final paidCount =
        items.where((e) => e.status.toLowerCase() == 'paid').length;

    // ─── join ชื่อรายการ (expname) จาก prepayment detail ───
    // payment.debtLineUuid → prepayment detail.uuid → expname
    final nameByLine = <String, String>{};
    for (final d in details) {
      if (d.uuid.isNotEmpty) nameByLine[d.uuid] = d.expname;
    }

    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ───
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: LaColors.statusInfoBg,
                  borderRadius: BorderRadius.circular(LaRadius.sm),
                ),
                child: const Icon(Icons.receipt_long_rounded,
                    size: 18, color: LaColors.statusInfoFg),
              ),
              const SizedBox(width: LaSpace.sm),
              Text('สถานะการชำระ', style: LaText.h2),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration:
                    LaDecor.pill(LaColors.surfaceMuted, LaColors.textSecondary),
                child: Text(
                  'ชำระแล้ว $paidCount / ${items.length}',
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

          if (items.isEmpty)
            Container(
              padding: const EdgeInsets.all(LaSpace.lg),
              decoration: LaDecor.softCard(),
              child: const Center(
                child: Text('ไม่พบรายการชำระ', style: LaText.bodyMuted),
              ),
            )
          else
            ...items.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: LaSpace.sm),
                  child: _PaymentStatusRow(
                    payment: p,
                    itemName: nameByLine[p.debtLineUuid] ?? '',
                  ),
                )),
        ],
      ),
    );
  }
}

class _PaymentStatusRow extends StatefulWidget {
  final PaymentDetail payment;
  final String itemName;
  const _PaymentStatusRow({
    required this.payment,
    this.itemName = '',
  });

  @override
  State<_PaymentStatusRow> createState() => _PaymentStatusRowState();
}

class _PaymentStatusRowState extends State<_PaymentStatusRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.payment;
    final itemName = widget.itemName;
    final hasAttachment =
        p.latestAttachment != null && p.latestAttachment!.uuid.isNotEmpty;
    final isPaid = p.status.toLowerCase() == 'paid';
    // priority: paid > attached > statusLabel
    final statusText = isPaid
        ? p.statusLabel
        : (hasAttachment ? 'หลักฐานแล้ว รอชืนยัน' : p.statusLabel);
    final showAttachedBadge = !isPaid && hasAttachment;
    return Container(
      decoration: LaDecor.softCard(),
      padding: const EdgeInsets.all(LaSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── responsive layout: row (จอกว้าง) | column (จอแคบ) ─ ───
          LayoutBuilder(
            builder: (ctx, c) {
              final isNarrow = c.maxWidth < 480;
              final iconBox = Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: hasAttachment
                      ? LaColors.statusApprovedBg
                      : LaColors.statusInfoBg,
                  borderRadius: BorderRadius.circular(LaRadius.sm),
                ),
                child: Icon(
                  hasAttachment
                      ? Icons.cloud_done_rounded
                      : Icons.payments_outlined,
                  size: 18,
                  color: hasAttachment
                      ? LaColors.statusApprovedFg
                      : LaColors.statusInfoFg,
                ),
              );
              final content = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          p.paymentNo.isNotEmpty ? p.paymentNo : '-',
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
                    '${itemName.isNotEmpty ? itemName : '-'}  •  '
                    '${_formatSystem(p.paymentSystem)}  •  ${formatMoney(p.amount)}',
                    style: LaText.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hasAttachment)
                    Text(
                      'UUID: ${_shortUuid(p.uuid)}',
                      style: LaText.caption.copyWith(
                        color: LaColors.textMuted,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              );
              final actions = Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  showAttachedBadge
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: LaColors.statusApprovedBg.withOpacity(.45),
                            borderRadius: BorderRadius.circular(LaRadius.pill),
                            border: Border.all(
                              color: LaColors.statusApprovedFg.withOpacity(.55),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: LaColors.statusApprovedFg,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                statusText,
                                style: LaText.caption.copyWith(
                                  color: LaColors.statusApprovedFg,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _StatusBadge(label: statusText),
                  if (hasAttachment) ...[
                    _AttachmentViewButton(attachment: p.latestAttachment!),
                  ] else ...[
                    _UploadButton(
                      payment: p,
                      onUpload: () => _openUploadDialog(context, p),
                    ),
                  ],

                  if (isPaid)
                    _ReceiptViewButton(
                      payment: p,
                      onTap: () => context
                          .read<LicensePaymentDetailViewModel>()
                          .gotoReceipt(p.uuid),
                    ),
                  // if (isPaid) _ApprovalActions(payment: p),  ← ซ่อนไว้ก่อน
                ],
              );

              // ─── เลือก layout ตามความกว้าง ───
              if (isNarrow) {
                // จอแคบ: icon + content บน, actions ล่าง
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: actions,
                    ),
                  ],
                );
              }
              // จอกว้าง: row เดิม
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
            _StatusDetailGrid(payment: p),
          ],
        ],
      ),
    );
  }

  String _formatSystem(String s) {
    final v = (s).toLowerCase();
    if (v == 'internal') return 'ในระบบ';
    if (v == 'external') return 'ภายนอก';
    return s.isEmpty ? '-' : s;
  }

  String _shortUuid(String u) {
    if (u.isEmpty) return '-';
    if (u.length <= 12) return u;
    return '${u.substring(0, 8)}…${u.substring(u.length - 4)}';
  }
}

/// รายละเอียดเพิ่มเติมของ payment (โชว์เมื่อ expand)
class _StatusDetailGrid extends StatelessWidget {
  final PaymentDetail payment;
  const _StatusDetailGrid({required this.payment});

  @override
  Widget build(BuildContext context) {
    final p = payment;
    final items = <(IconData, String, String)>[
      (
        Icons.payments_outlined,
        'จำนวนรับชำระ',
        p.amountReceived != null ? formatMoney(p.amountReceived!) : '-'
      ),
      (
        Icons.event_available_rounded,
        'วันที่ชำระ',
        (p.paidAt?.isNotEmpty ?? false) ? _fmtDate(p.paidAt!) : '-'
      ),
      (
        Icons.tag_rounded,
        'ประเภท',
        p.paymentSystem.isNotEmpty ? p.paymentSystem : '-'
      ),
      (
        Icons.fingerprint_rounded,
        'วิธีชำระ',
        (p.paymentMethodId?.isNotEmpty ?? false) ? p.paymentMethodId! : '-'
      ),
      // (
      //   Icons.person_outline_rounded,
      //   'ผู้ชำระ',
      //   (p.payerName?.isNotEmpty ?? false) ? p.payerName! : '-'
      // ),
      // (Icons.phone_outlined, 'โทร', p.clientTel.isNotEmpty ? p.clientTel : '-'),
      (
        Icons.numbers_rounded,
        'รหัสรายการตั้งหนี้',
        p.debtLineUuid.isNotEmpty ? _shortUuidFull(p.debtLineUuid) : '-'
      ),
      (
        Icons.link_rounded,
        'สร้างเมื่อ',
        (p.createdAt?.isNotEmpty ?? false) ? _fmtDate(p.createdAt!) : '-'
      ),
      (
        Icons.access_time_rounded,
        'อัพโหลดเมื่อ',
        (p.latestAttachment?.uploadedAt?.isNotEmpty ?? false)
            ? _fmtDate(p.latestAttachment!.uploadedAt!)
            : '-'
      ),
    ];
    return LayoutBuilder(
      builder: (ctx, c) {
        // 2-3 cols ตามความกว้าง
        final cols = c.maxWidth >= 700 ? 3 : (c.maxWidth >= 460 ? 2 : 1);
        return Wrap(
          spacing: LaSpace.md,
          runSpacing: LaSpace.sm,
          children: items
              .map((it) => SizedBox(
                    width: (c.maxWidth - LaSpace.md * (cols - 1)) / cols,
                    child: _DetailCell(
                      icon: it.$1,
                      label: it.$2,
                      value: it.$3,
                    ),
                  ))
              .toList(),
        );
      },
    );
  }

  String _fmtDate(String s) {
    try {
      final dt = DateTime.parse(s);
      return DateFormat('dd-MM-yyyy HH:mm').format(dt);
    } catch (_) {
      return s;
    }
  }

  String _shortUuidFull(String u) =>
      u.length <= 16 ? u : '${u.substring(0, 8)}…${u.substring(u.length - 6)}';
}

/// cell เล็กๆ: icon + label + value
class _DetailCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailCell({
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: LaText.caption.copyWith(color: LaColors.textMuted),
              ),
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

/// ปุ่มเล็ก ๆ สำหรับดูหลักฐานที่แนบ — คลิกแล้วเปิด dialog รูปเต็ม
class _AttachmentViewButton extends StatefulWidget {
  final PaymentAttachment attachment;
  const _AttachmentViewButton({required this.attachment});

  @override
  State<_AttachmentViewButton> createState() => _AttachmentViewButtonState();
}

class _AttachmentViewButtonState extends State<_AttachmentViewButton> {
  Uint8List? _bytes;
  bool _loading = false;

  Future<void> _open(BuildContext context) async {
    final navigator = Navigator.of(context);
    Uint8List? bytes = _bytes;
    if (bytes == null) {
      setState(() => _loading = true);
      try {
        bytes = await LicensePaymentDetailService()
            .previewPaymentAttachment(attachmentUuid: widget.attachment.uuid);
        if (!mounted) return;
        setState(() {
          _bytes = bytes;
          _loading = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() => _loading = false);
        return;
      }
    }
    if (bytes == null) return;
    await navigator.push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        barrierDismissible: true,
        pageBuilder: (_, __, ___) => Scaffold(
          backgroundColor: Colors.transparent,
          body: GestureDetector(
            onTap: navigator.pop,
            child: Center(
              child: InteractiveViewer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(LaRadius.sm),
                  child: Image.memory(bytes!),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'ดูหลักฐานที่แนบ',
      child: InkWell(
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(LaRadius.pill),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: LaColors.statusApprovedBg.withOpacity(.4),
            shape: BoxShape.circle,
            border:
                Border.all(color: LaColors.statusApprovedFg.withOpacity(.55)),
          ),
          alignment: Alignment.center,
          child: _loading
              ? const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 1.6),
                )
              : const Icon(Icons.image_outlined,
                  size: 14, color: LaColors.statusApprovedFg),
        ),
      ),
    );
  }
}

/// ปุ่ม "ดูใบเสร็จ" — โหลด GET /v2/payments/{uuid}/receipt แล้วไป Step 2
class _ReceiptViewButton extends StatelessWidget {
  final PaymentDetail payment;
  final VoidCallback onTap;
  const _ReceiptViewButton({
    required this.payment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'ดูใบเสร็จ',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LaRadius.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: LaColors.primaryDark,
            borderRadius: BorderRadius.circular(LaRadius.sm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.receipt_long_rounded,
                  size: 14, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                'ดูใบเสร็จ',
                style: LaText.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ปุ่ม "อัพโหลดหลักฐาน" — เปิด dialog stepper ที่ step 2
/// ใช้ตอน payment ยังไม่มี attachment (status = draft หรือ หลักฐานยังไม่แนบ)
class _UploadButton extends StatelessWidget {
  final PaymentDetail payment;
  final Future<void> Function() onUpload;
  const _UploadButton({
    required this.payment,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'อัพโหลดหลักฐาน',
      child: InkWell(
        onTap: () => onUpload(),
        borderRadius: BorderRadius.circular(LaRadius.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: LaColors.primaryDark.withOpacity(.08),
            borderRadius: BorderRadius.circular(LaRadius.sm),
            border: Border.all(
              color: LaColors.primaryDark.withOpacity(.55),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.cloud_upload_outlined,
                size: 14,
                color: LaColors.primaryDark,
              ),
              SizedBox(width: 4),
              Text(
                'อัพโหลด',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: LaColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ปุ่มอนุมัติ / ปฏิเสธ — placeholder (UI ก่อน, API ยังไม่ต่อ)
// ignore: unused_element
class _ApprovalActions extends StatelessWidget {
  final PaymentDetail payment;
  const _ApprovalActions({required this.payment});

  void _snack(BuildContext context, String label, Color color) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '$label (ยังไม่ได้ต่อ API) — '
          '${payment.paymentNo.isNotEmpty ? payment.paymentNo : payment.uuid}',
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LaRadius.md),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─── อนุมัติ ───
        InkWell(
          onTap: () => _snack(context, 'อนุมัติ', LaColors.statusApprovedFg),
          borderRadius: BorderRadius.circular(LaRadius.sm),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: LaColors.statusApprovedBg.withOpacity(.25),
              borderRadius: BorderRadius.circular(LaRadius.sm),
              border: Border.all(
                color: LaColors.statusApprovedFg.withOpacity(.55),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline_rounded,
                    size: 14, color: LaColors.statusApprovedFg),
                const SizedBox(width: 4),
                Text(
                  'อนุมัติ',
                  style: LaText.caption.copyWith(
                    color: LaColors.statusApprovedFg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),
        // ─── ปฏิเสธ ───
        InkWell(
          onTap: () => _snack(context, 'ปฏิเสธ', LaColors.statusRejectedFg),
          borderRadius: BorderRadius.circular(LaRadius.sm),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: LaColors.statusRejectedBg.withOpacity(.25),
              borderRadius: BorderRadius.circular(LaRadius.sm),
              border: Border.all(
                color: LaColors.statusRejectedFg.withOpacity(.55),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cancel_outlined,
                    size: 14, color: LaColors.statusRejectedFg),
                const SizedBox(width: 4),
                Text(
                  'ปฏิเสธ',
                  style: LaText.caption.copyWith(
                    color: LaColors.statusRejectedFg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Sub widgets
// ============================================================================

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

class _ActionButton extends StatelessWidget {
  final String label;
  final bool pendingAttachment;
  final VoidCallback onPressed;
  const _ActionButton({
    required this.label,
    required this.pendingAttachment,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (pendingAttachment) {
      // ─── แนบหลักฐานแล้ว รอชืนยัน → outlined เขียว ───
      return InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(LaRadius.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: LaColors.statusApprovedBg.withOpacity(.4),
            borderRadius: BorderRadius.circular(LaRadius.sm),
            border: Border.all(color: LaColors.statusApprovedFg, width: 1.4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.cloud_done_rounded,
                  size: 14, color: LaColors.statusApprovedFg),
              SizedBox(width: 4),
              Text(
                'รอบันทึกการชำระ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: LaColors.statusApprovedFg,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isStart = label == 'ทำรายการ';
    if (isStart) {
      // ─── filled primary (เริ่มใหม่) ───
      return InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(LaRadius.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: LaColors.primaryDark,
            borderRadius: BorderRadius.circular(LaRadius.sm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.payments_rounded, size: 14, color: Colors.white),
              SizedBox(width: 4),
              Text(
                'ทำรายการ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ─── outlined (ทำรายการต่อ) ───
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(LaRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(LaRadius.sm),
          border: Border.all(color: LaColors.primaryDark, width: 1.4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'ทำรายการต่อ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: LaColors.primaryDark,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.arrow_forward_rounded,
                size: 14, color: LaColors.primaryDark),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  const _StatusBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final s = label.toLowerCase();
    Color fg;
    if (s.contains('อนุมัติ') ||
        s.contains('approved') ||
        s.contains('pass') ||
        s.contains('ชำระแล้ว') ||
        s.contains('เสร็จ')) {
      fg = LaColors.statusApprovedFg;
    } else if (s.contains('ปฏิเสธ') ||
        s.contains('reject') ||
        s.contains('cancel') ||
        s.contains('ยกเลิก')) {
      fg = LaColors.statusRejectedFg;
    } else if (s.contains('รอ') ||
        s.contains('pending') ||
        s.contains('progress') ||
        s.contains('กำลัง')) {
      fg = LaColors.statusPendingFg;
    } else {
      fg = LaColors.statusNeutralFg;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: fg.withOpacity(.1),
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
          AutoSizeText(
            label.isEmpty ? '-' : label,
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
          Flexible(
            // ✅ หดได้
            child: AutoSizeText(
              text,
              minFontSize: 11,
              maxFontSize: 12,
              maxLines: 1,
              overflow: TextOverflow.ellipsis, // ✅ กัน overflow
              style: LaText.caption.copyWith(
                color: fg,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
          Text('กำลังโหลดรายการรับชำระ...', style: LaText.bodyMuted),
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
          TextButton(
            onPressed: () =>
                context.read<LicensePaymentDetailViewModel>().reload(),
            child: const Text('ลองใหม่'),
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
                ? 'ไม่พบข้อมูลรายการ (uuid: ${uuid!.substring(0, uuid!.length.clamp(0, 8))})'
                : 'ไม่พบข้อมูลรายการ',
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
