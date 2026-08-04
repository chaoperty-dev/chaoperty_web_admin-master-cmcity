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
              onNext: step < total
                  ? () {
                      // ignore: avoid_print
                      print(
                        'Next clicked — Request UUID: ${vm.requestUuid}',
                      );
                      vm.nextDetailStep();
                    }
                  : null,
              onSave: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('บันทึกการแนบเอกสาร (placeholder)'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
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
