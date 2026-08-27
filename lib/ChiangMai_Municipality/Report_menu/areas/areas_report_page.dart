// ============================================================================
// areas_report_page.dart
// ============================================================================
// Main Page — "รายงานพื้นที่เช่า"
// - แสดง columns checklist + drag & drop reorder
// - กดปุ่ม "ดาวน์โหลด Excel" → โหลด /areas/overview → สร้าง xlsx
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/areas_report_view_model.dart';
import '../customers/views/theme/customers_report_theme.dart';
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

class _AreasReportPageBody extends StatelessWidget {
  final String title;
  const _AreasReportPageBody({required this.title});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AreasReportViewModel>();

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
                subtitle: vm.totalArea != null
                    ? 'ทั้งหมด ${vm.totalArea} ล็อค'
                    : null,
                onDownload: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final err = await vm.exportToExcel();
                  if (err == null) {
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
                        content: Text('ส่งออกสำเร็จ: $err'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                isExporting: vm.isExporting,
              ),
              const SizedBox(height: CrSpace.lg),
              const AreasReportColumnPicker(),
              if (vm.errorMessage != null) ...[
                const SizedBox(height: CrSpace.md),
                Container(
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
                          vm.errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFB91C1C),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: vm.clearError,
                        child: const Icon(Icons.close,
                            size: 18, color: Color(0xFFB91C1C)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: CrSpace.lg),
              Container(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
