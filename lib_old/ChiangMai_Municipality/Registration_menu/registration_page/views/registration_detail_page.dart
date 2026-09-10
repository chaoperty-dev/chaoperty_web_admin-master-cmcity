// ============================================================================
// registration_detail_page.dart
// ============================================================================
// Full-page detail route (2-step) — เปิดแบบเต็มจอเหมือน "สร้างคำขอ" ของ request
// - มี Provider ของตัวเอง (ไม่ผูกกับ list page)
// - ปิดได้ด้วย Navigator.pop (back button ใน header)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/registration_detail_view_model.dart';
import 'theme/registration_theme.dart';
import 'widgets/registration_detail_footer.dart';
import 'widgets/registration_detail_header.dart';
import 'widgets/registration_detail_step1.dart';
import 'widgets/registration_detail_step2.dart';
import 'widgets/registration_edit_page.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// Public API
/// ═══════════════════════════════════════════════════════════════════════

/// Full-page detail route — เปิดแบบเต็มจอ
/// ใช้เหมือน "หน้าสร้างคำขอ" ของ license_request_page (push MaterialPageRoute
/// fullscreenDialog: true)
class RegistrationDetailPage extends StatefulWidget {
  /// uuid ของรายการที่จะแสดง (optional — ถ้ามีให้ preload)
  final String? routeData;

  /// Title ที่จะแสดงใน header
  final String title;

  const RegistrationDetailPage({
    super.key,
    this.routeData,
    this.title = 'ตรวจสอบหลักฐาน',
  });

  /// Factory สร้าง Page พร้อม Provider (ใช้ใน Navigator.push)
  static Widget create({
    Key? key,
    String? routeData,
    String title = 'ตรวจสอบหลักฐาน',
  }) {
    return ChangeNotifierProvider<RegistrationDetailViewModel>(
      create: (_) => RegistrationDetailViewModel(),
      child: _RegistrationDetailPageBody(
        title: title,
        routeData: routeData,
      ),
    );
  }

  @override
  State<RegistrationDetailPage> createState() => _RegistrationDetailPageState();
}

class _RegistrationDetailPageState extends State<RegistrationDetailPage> {
  @override
  Widget build(BuildContext context) {
    return RegistrationDetailPage.create(
      key: widget.key,
      routeData: widget.routeData,
      title: widget.title,
    );
  }
}

/// Body จริง — ต้องอยู่ใต้ Provider เสมอ
class _RegistrationDetailPageBody extends StatefulWidget {
  final String title;
  final String? routeData;

  const _RegistrationDetailPageBody({
    required this.title,
    this.routeData,
  });

  @override
  State<_RegistrationDetailPageBody> createState() =>
      _RegistrationDetailPageBodyState();
}

class _RegistrationDetailPageBodyState
    extends State<_RegistrationDetailPageBody> {
  @override
  void initState() {
    super.initState();
    final uuid = widget.routeData;
    if (uuid != null && uuid.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<RegistrationDetailViewModel>().loadCustomer(uuid);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistrationDetailViewModel>();
    final step = vm.currentDetailStep;
    final total = vm.totalDetailSteps;
    final subtitle =
        step == 1 ? 'ข้อมูลร้านค้าและผู้ติดต่อ' : 'ข้อมูลส่วนบุคคลและที่อยู่';

    return Scaffold(
      backgroundColor: LaColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RegistrationDetailHeader(
              title: widget.title,
              subtitle: subtitle,
              currentStep: step,
              totalSteps: total,
              onBack: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              actions: [
                _EditButton(
                  onTap: () {
                    final customer = vm.customer;
                    if (customer == null) return;
                    // ใช้ ser เป็น key หลัก (API V2 ไม่มี uuid)
                    final key = customer.ser?.toString() ??
                        customer.uuid?.toString() ??
                        '';
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (_) => RegistrationEditPage.create(
                          uuid: key,
                          onSaveSuccess: () {
                            // reload หลังบันทึก
                            if (widget.routeData != null) {
                              vm.loadCustomer(widget.routeData!);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            Expanded(
              child: vm.loading
                  ? const Center(child: CircularProgressIndicator())
                  : step == 1
                      ? RegistrationDetailStep1(customer: vm.customer)
                      : RegistrationDetailStep2(customer: vm.customer),
            ),
            RegistrationDetailFooter(
              readOnly: true,
              currentStep: step,
              totalSteps: total,
              onNext: step < total ? vm.nextDetailStep : null,
              onSave: null,
              onCancel: () {
                if (step > 1) {
                  vm.previousDetailStep();
                } else {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// ปุ่ม "แก้ไข" ใน header (gradient green pill)
class _EditButton extends StatefulWidget {
  final VoidCallback onTap;
  const _EditButton({required this.onTap});

  @override
  State<_EditButton> createState() => _EditButtonState();
}

class _EditButtonState extends State<_EditButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _hover
                  ? [LaColors.primaryDark, LaColors.primaryDark]
                  : [LaColors.primary, LaColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(LaRadius.md),
            boxShadow: _hover
                ? [
                    BoxShadow(
                      color: LaColors.primary.withOpacity(.35),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_rounded, size: 16, color: Colors.white),
              SizedBox(width: 6),
              Text(
                'แก้ไข',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: LaText.fontBold,
                  fontSize: 13,
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
