// ============================================================================
// customers_report_page.dart
// ============================================================================
// Main Page - รายงานลูกค้า (Export Excel)
// - เปิดหน้า: โหลด /customers/columns
// - ผู้ใช้เลือก columns ที่ต้องการ (default: ทั้งหมด)
// - กดปุ่ม "ดาวน์โหลด Excel" → โหลด /customers → สร้าง CSV →
//   บันทึก + เปิด Share dialog
//
// ✅ Body ใช้ Selector — rebuild เฉพาะเมื่อ field ที่ใช้เปลี่ยน
// ✅ Error banner แยก widget — ไม่ rebuild ทั้ง body
// ✅ Info banner แยก const widget
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/customers_report_view_model.dart';
import 'views/theme/customers_report_theme.dart';
import 'views/widgets/customers_report_header.dart';
import 'views/widgets/customers_report_column_picker.dart';
import 'views/widgets/customers_report_password_dialog.dart';

class CustomersReportPage extends StatelessWidget {
  final String title;
  const CustomersReportPage({
    super.key,
    this.title = 'รายงานลูกค้า',
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CustomersReportViewModel>(
      create: (_) => CustomersReportViewModel(),
      child: _CustomersReportPageBody(title: title),
    );
  }
}

/// Snapshot — body rebuild เฉพาะเมื่อ field ที่ header/error banner ใช้เปลี่ยน
class _BodyState {
  final int totalItems;
  final int selectedCount;
  final bool isExporting;
  final String phaseLabel;
  final String? errorMessage;

  const _BodyState({
    required this.totalItems,
    required this.selectedCount,
    required this.isExporting,
    required this.phaseLabel,
    required this.errorMessage,
  });

  @override
  bool operator ==(Object other) =>
      other is _BodyState &&
      other.totalItems == totalItems &&
      other.selectedCount == selectedCount &&
      other.isExporting == isExporting &&
      other.phaseLabel == phaseLabel &&
      other.errorMessage == errorMessage;

  @override
  int get hashCode => Object.hash(
        totalItems,
        selectedCount,
        isExporting,
        phaseLabel,
        errorMessage,
      );
}

class _CustomersReportPageBody extends StatelessWidget {
  final String title;
  const _CustomersReportPageBody({required this.title});

  @override
  Widget build(BuildContext context) {
    return Selector<CustomersReportViewModel, _BodyState>(
      selector: (_, vm) => _BodyState(
        totalItems: vm.totalItems,
        selectedCount: vm.selectedCount,
        isExporting: vm.isExporting,
        phaseLabel: vm.phaseLabel,
        errorMessage: vm.errorMessage,
      ),
      shouldRebuild: (a, b) => a != b,
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: CrColors.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(CrSpace.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomersReportHeader(
                    title: title,
                    subtitle: state.totalItems > 0
                        ? 'พบลูกค้าทั้งหมด ${state.totalItems} รายการ'
                        : null,
                    totalCount: state.totalItems,
                    selectedCount: state.selectedCount,
                    onDownload: () => _onDownload(context),
                    isExporting: state.isExporting,
                    phaseLabel: state.phaseLabel,
                  ),
                  const SizedBox(height: CrSpace.lg),
                  const CustomersReportColumnPicker(),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: CrSpace.md),
                    _ErrorBanner(message: state.errorMessage!),
                  ],
                  const SizedBox(height: CrSpace.lg),
                  const _InfoBanner(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onDownload(BuildContext context) async {
    final vm = context.read<CustomersReportViewModel>();
    final messenger = ScaffoldMessenger.of(context);

    final result = await CustomersReportPasswordDialog.show(context);
    if (result is PasswordCancel) return;

    final password = switch (result) {
      PasswordNoPassword() => null,
      PasswordWithValue(:final password) => password,
      _ => null,
    };

    final saved = await vm.exportToExcel(password: password);
    if (saved == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Export ล้มเหลว'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text('ส่งออกสำเร็จ: $saved'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CrSpace.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(CrRadius.md),
        border: Border.all(color: const Color(0xFFB91C1C)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFB91C1C), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFB91C1C),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          InkWell(
            onTap: () => context.read<CustomersReportViewModel>().clearError(),
            child: const Icon(Icons.close, size: 18, color: Color(0xFFB91C1C)),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CrSpace.md),
      decoration: CrDecor.card(),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: CrColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'ไฟล์ที่ดาวน์โหลดจะถูกบันทึกในโฟลเดอร์ชั่วคราวของแอป '
              'และสามารถแชร์ผ่านแอปอื่น ๆ ได้',
              style: CrText.bodyMuted.copyWith(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}