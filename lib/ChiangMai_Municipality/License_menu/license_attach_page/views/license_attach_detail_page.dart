// ============================================================================
// license_attach_detail_page.dart
// ============================================================================
// Full-page detail route (2-step) — เปิดแบบเต็มจอเหมือน "สร้างคำขอ"
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/license_attach_detail_view_model.dart';
import 'theme/license_attach_theme.dart';
import 'widgets/attach_detail_footer.dart';
import 'widgets/attach_detail_header.dart';
import 'widgets/attach_detail_step1.dart';
import 'widgets/attach_detail_step2.dart';

class LicenseAttachDetailPage extends StatefulWidget {
  final String? routeData;
  final String title;

  const LicenseAttachDetailPage({
    super.key,
    this.routeData,
    this.title = 'แนบหลักฐาน',
  });

  static Widget create({
    Key? key,
    String? routeData,
    String title = 'แนบหลักฐาน',
  }) {
    return ChangeNotifierProvider<LicenseAttachDetailViewModel>(
      create: (_) => LicenseAttachDetailViewModel(requestUuid: routeData),
      child: _LicenseAttachDetailPageBody(
        title: title,
        routeData: routeData,
      ),
    );
  }

  @override
  State<LicenseAttachDetailPage> createState() =>
      _LicenseAttachDetailPageState();
}

class _LicenseAttachDetailPageState extends State<LicenseAttachDetailPage> {
  @override
  Widget build(BuildContext context) {
    return LicenseAttachDetailPage.create(
      key: widget.key,
      routeData: widget.routeData,
      title: widget.title,
    );
  }
}

class _LicenseAttachDetailPageBody extends StatefulWidget {
  final String title;
  final String? routeData;

  const _LicenseAttachDetailPageBody({
    required this.title,
    this.routeData,
  });

  @override
  State<_LicenseAttachDetailPageBody> createState() =>
      _LicenseAttachDetailPageBodyState();
}

class _LicenseAttachDetailPageBodyState
    extends State<_LicenseAttachDetailPageBody> {
  @override
  void initState() {
    super.initState();
    // โหลดข้อมูล checklist ทันทีที่เปิดหน้า — เพื่อให้ step 1 เห็น banner ประวัติการบันทึก
    // (ไม่ต้องรอให้ user เข้า step 2 ก่อน)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LicenseAttachDetailViewModel>().loadChecklist();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseAttachDetailViewModel>();
    final step = vm.currentDetailStep;
    final total = vm.totalDetailSteps;
    final subtitle = step == 1 ? 'เลือกเอกสารที่จะแนบ' : 'สรุปการแนบเอกสาร';

    return Scaffold(
      backgroundColor: LaColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AttachDetailHeader(
              title: widget.title,
              subtitle: subtitle,
              currentStep: step,
              totalSteps: total,
              onBack: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
            Expanded(
              child: step == 1
                  ? AttachDetailStep1(requestUuid: vm.requestUuid)
                  : const AttachDetailStep2(),
            ),
            AttachDetailFooter(
              readOnly: false,
              currentStep: step,
              totalSteps: total,
              showSaveButton: step == 1
                  ? true
                  : (vm.shouldShowSaveButton && !vm.isLocked),
              onNext: step < total
                  ? () {
                      // ignore: avoid_print
                      print(
                        'Next clicked — Request UUID: ${vm.requestUuid}',
                      );
                      // refresh parent VM ก่อนขึ้น step 2
                      // — เพื่อให้ step 2 เห็นไฟล์ที่อัปโหลด/ลบ ใน step 1
                      // (ไม่งั้น mergedAttachments จะ stale จนกว่าจะออกแล้วเข้าใหม่)
                      vm.loadChecklist();
                      vm.nextDetailStep();
                    }
                  : null,
              onSave: () async {
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                if (vm.isSubmitting) return;

                messenger.showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('กำลังบันทึก...'),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );

                final result = await vm.submitChecklist();

                if (!mounted) return;
                if (result == null) return;

                if (result.success) {
                  final noText = result.checklistNo != null
                      ? '\nเลขที่: ${result.checklistNo}'
                      : '';
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        result.message != null && result.message!.isNotEmpty
                            ? 'บันทึกสำเร็จ: ${result.message}$noText'
                            : 'บันทึกสำเร็จ (HTTP ${result.statusCode})$noText',
                      ),
                      backgroundColor: Colors.green.shade700,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                  if (navigator.canPop()) {
                    // ✅ คืน true → list page จะ refresh ข้อมูล
                    navigator.pop(true);
                  }
                } else {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'บันทึกไม่สำเร็จ (HTTP ${result.statusCode}): '
                        '${result.message ?? '-'}',
                      ),
                      backgroundColor: Colors.red.shade700,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
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
