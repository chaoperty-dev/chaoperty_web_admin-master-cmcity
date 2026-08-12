// ============================================================================
// approve_detail_step2.dart
// ============================================================================
// Step 2 — หน้าอนุมัติคำขอ (กระชับ ผู้ใช้ scroll น้อยที่สุด)
// - Header
// - Signature card (ขนาดเล็ก อยู่ในบรรทัดเดียว)
// - PDF Preview 3 อัน (เรียงในแถวเดียว horizontal scroll)
// - ปุ่ม "บันทึก / อนุมัติ" ในหน้าเลย ไม่ต้อง scroll ลงไป footer
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/license_approve_detail_step2_view_model.dart';
import '../theme/license_approve_theme.dart';
import 'step2/step2_pdf_preview.dart';
import 'step2/step2_signature_card.dart';

class ApproveDetailStep2 extends StatefulWidget {
  const ApproveDetailStep2({super.key});

  @override
  State<ApproveDetailStep2> createState() => _ApproveDetailStep2State();
}

class _ApproveDetailStep2State extends State<ApproveDetailStep2> {
  late final LicenseApproveDetailStep2ViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = LicenseApproveDetailStep2ViewModel()..init();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final uuid = await _vm.getStoredRequestUuid();
    if (uuid != null && uuid.isNotEmpty) {
      await _vm.loadAll(uuid);
    } else {
      _vm.loadAll(null);
    }
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  // ===========================================================================
  // Approve flow
  // ===========================================================================

  Future<void> _onApprove() async {
    if (!_vm.canConfirm) {
      _showSnack('ไม่พบลายเซ็นผู้อนุมัติ', isError: true);
      return;
    }

    final uuid = await _vm.getStoredRequestUuid();
    if (uuid == null || uuid.isEmpty) {
      _showSnack('ไม่พบ UUID คำขอ', isError: true);
      return;
    }

    final result = await _vm.approveNow(requestUuid: uuid);
    if (!mounted) return;

    if (result.success) {
      _showSuccessDialog();
    } else {
      _showSnack(result.message ?? 'บันทึกไม่สำเร็จ', isError: true);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: LaColors.cardBg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LaRadius.lg)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Padding(
            padding: const EdgeInsets.all(LaSpace.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: LaColors.statusApprovedBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_rounded,
                      size: 36, color: LaColors.statusApprovedFg),
                ),
                const SizedBox(height: LaSpace.md),
                const Text('อนุมัติสำเร็จ', style: LaText.h2),
                const SizedBox(height: LaSpace.sm),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(LaRadius.sm),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: LaColors.primary,
                        borderRadius: BorderRadius.circular(LaRadius.sm),
                      ),
                      alignment: Alignment.center,
                      child: const Text('รับทราบ',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: LaText.fontBold,
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            isError ? LaColors.statusRejectedFg : LaColors.statusApprovedFg,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ===========================================================================
  // Build
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LicenseApproveDetailStep2ViewModel>.value(
      value: _vm,
      child: Consumer<LicenseApproveDetailStep2ViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && vm.reviewDetail == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return Column(
            children: [
              // ─── Header (sticky) ───
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: LaSpace.lg, vertical: LaSpace.sm),
                color: LaColors.primaryLight.withOpacity(.25),
                child: Row(
                  children: [
                    const Icon(Icons.task_alt_rounded,
                        size: 18, color: LaColors.primaryDark),
                    const SizedBox(width: LaSpace.sm),
                    const Expanded(
                      child: Text('บันทึกการอนุมัติ',
                          style: LaText.h2),
                    ),
                    const SizedBox(width: LaSpace.sm),
                    _approveButton(),
                  ],
                ),
              ),

              // ─── เนื้อหา (scroll ได้ แต่สั้น) ───
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(LaSpace.md),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: const [
                          // Signature card (ขนาดกระชับ)
                          Step2SignatureCard(),
                          SizedBox(height: LaSpace.md),

                          // PDF Preview 3 อัน
                          Step2PdfPreviewSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// ปุ่ม "บันทึก / อนุมัติ" (ขนาดเล็ก อยู่ใน header)
  Widget _approveButton() {
    return Consumer<LicenseApproveDetailStep2ViewModel>(
      builder: (context, vm, _) {
        final canApprove = vm.canConfirm && !vm.isApproving;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(LaRadius.sm),
            onTap: canApprove ? _onApprove : null,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: LaSpace.md, vertical: LaSpace.xs),
              decoration: BoxDecoration(
                gradient: canApprove
                    ? const LinearGradient(
                        colors: [LaColors.primary, LaColors.primaryDark],
                      )
                    : null,
                color: canApprove ? null : LaColors.surfaceMuted,
                borderRadius: BorderRadius.circular(LaRadius.sm),
                boxShadow: canApprove
                    ? [
                        BoxShadow(
                          color: LaColors.primary.withOpacity(.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (vm.isApproving)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    Icon(Icons.check_circle_rounded,
                        size: 14,
                        color: canApprove
                            ? Colors.white
                            : LaColors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    vm.isApproving ? 'กำลังบันทึก...' : 'บันทึก',
                    style: LaText.caption.copyWith(
                      color:
                          canApprove ? Colors.white : LaColors.textMuted,
                      fontFamily: LaText.fontBold,
                      fontSize: 13,
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
