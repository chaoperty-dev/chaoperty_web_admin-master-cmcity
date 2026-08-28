// ============================================================================
// areas_report_page.dart
// ============================================================================
// Main Page — "รายงานพื้นที่เช่า"
// - แสดง columns checklist + drag & drop reorder
// - กดปุ่ม "ดาวน์โหลด Excel" → โหลด /areas/overview → สร้าง xlsx
//
// ✅ Body ใช้ Selector — rebuild เฉพาะเมื่อ field ที่ header/error banner ใช้เปลี่ยน
// ✅ Error banner แยก widget — ไม่ rebuild ทั้ง body
// ✅ Info banner แยก const widget
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/areas_report_view_model.dart';
import '../customers/views/theme/customers_report_theme.dart';
import '../customers/views/widgets/customers_report_password_dialog.dart';
import 'views/widgets/areas_report_header.dart';
import 'views/widgets/areas_report_column_picker.dart';

class AreasReportPage extends StatelessWidget {
  final String title;
  const AreasReportPage({
    super.key,
    this.title = 'รายงานพื้นที่เช่า',
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AreasReportViewModel>(
      create: (_) => AreasReportViewModel(),
      child: _AreasReportPageBody(title: title),
    );
  }
}

/// Snapshot — body rebuild เฉพาะเมื่อ field ที่ header/error banner ใช้เปลี่ยน
class _BodyState {
  final int? totalArea;
  final bool isExporting;
  final String? errorMessage;

  const _BodyState({
    required this.totalArea,
    required this.isExporting,
    required this.errorMessage,
  });

  @override
  bool operator ==(Object other) =>
      other is _BodyState &&
      other.totalArea == totalArea &&
      other.isExporting == isExporting &&
      other.errorMessage == errorMessage;

  @override
  int get hashCode =>
      Object.hash(totalArea, isExporting, errorMessage);
}

class _AreasReportPageBody extends StatelessWidget {
  final String title;
  const _AreasReportPageBody({required this.title});

  @override
  Widget build(BuildContext context) {
    return Selector<AreasReportViewModel, _BodyState>(
      selector: (_, vm) => _BodyState(
        totalArea: vm.totalArea,
        isExporting: vm.isExporting,
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
                  AreasReportHeader(
                    title: title,
                    subtitle: state.totalArea != null
                        ? 'ทั้งหมด ${state.totalArea} ล็อค'
                        : null,
                    onDownload: () => _onDownload(context),
                    isExporting: state.isExporting,
                  ),
                  const SizedBox(height: CrSpace.lg),
                  const AreasReportColumnPicker(),
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
    final vm = context.read<AreasReportViewModel>();
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
          const Icon(Icons.error_outline,
              color: Color(0xFFB91C1C), size: 18),
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
            onTap: () => context.read<AreasReportViewModel>().clearError(),
            child: const Icon(Icons.close,
                size: 18, color: Color(0xFFB91C1C)),
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
          Icon(Icons.info_outline_rounded,
              size: 18, color: CrColors.textMuted),
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