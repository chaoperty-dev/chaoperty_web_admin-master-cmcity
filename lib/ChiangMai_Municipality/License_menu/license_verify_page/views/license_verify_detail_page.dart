// ============================================================================
// license_verify_detail_page.dart
// ============================================================================
// Full-page detail route (2-step) — เปิดแบบเต็มจอเหมือน "สร้างคำขอ"
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/license_verify_detail_view_model.dart';
import 'theme/license_verify_theme.dart';
import 'widgets/verify_detail_footer.dart';
import 'widgets/verify_detail_header.dart';
import 'widgets/verify_detail_step1.dart';
import 'widgets/verify_detail_step2.dart';

class LicenseverifyDetailPage extends StatefulWidget {
  final String? routeData;
  final String title;

  const LicenseverifyDetailPage({
    super.key,
    this.routeData,
    this.title = 'แนบหลักฐาน',
  });

  static Widget create({
    Key? key,
    String? routeData,
    String title = 'แนบหลักฐาน',
  }) {
    return ChangeNotifierProvider<LicenseverifyDetailViewModel>(
      create: (_) => LicenseverifyDetailViewModel(requestUuid: routeData),
      child: _LicenseverifyDetailPageBody(
        title: title,
        routeData: routeData,
      ),
    );
  }

  @override
  State<LicenseverifyDetailPage> createState() =>
      _LicenseverifyDetailPageState();
}

class _LicenseverifyDetailPageState extends State<LicenseverifyDetailPage> {
  @override
  Widget build(BuildContext context) {
    return LicenseverifyDetailPage.create(
      key: widget.key,
      routeData: widget.routeData,
      title: widget.title,
    );
  }
}

class _LicenseverifyDetailPageBody extends StatefulWidget {
  final String title;
  final String? routeData;

  const _LicenseverifyDetailPageBody({
    required this.title,
    this.routeData,
  });

  @override
  State<_LicenseverifyDetailPageBody> createState() =>
      _LicenseverifyDetailPageBodyState();
}

class _LicenseverifyDetailPageBodyState
    extends State<_LicenseverifyDetailPageBody> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseverifyDetailViewModel>();
    final step = vm.currentDetailStep;
    final total = vm.totalDetailSteps;
    final subtitle = step == 1
        ? 'ตรวจสอบอนุมัติหลักฐาน/เอกสารคำขออนุญาต'
        : 'สรุปการแนบเอกสารหลักฐาน';

    return Scaffold(
      backgroundColor: LaColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VerifyDetailHeader(
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
                  ? VerifyDetailStep1(requestUuid: vm.requestUuid)
                  : const VerifyDetailStep2(),
            ),
            VerifyDetailFooter(
              readOnly: step == 2,
              currentStep: step,
              totalSteps: total,
              onNext: step < total
                  ? () {
                      // ignore: avoid_print
                      print(
                        'Next clicked — Request UUID: ${vm.requestUuid}',
                      );
                      vm.nextDetailStep();
                    }
                  : null,
              onSave: step == 2
                  ? null
                  : () async {
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
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              result.message != null &&
                                      result.message!.isNotEmpty
                                  ? 'บันทึกสำเร็จ: ${result.message}'
                                  : 'บันทึกสำเร็จ (HTTP ${result.statusCode})',
                            ),
                            backgroundColor: Colors.green.shade700,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        if (navigator.canPop()) {
                          navigator.pop();
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
