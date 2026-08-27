// ============================================================================
// customers_report_page.dart
// ============================================================================
// Main Page — รายงานลูกค้า (Export Excel)
// - เปิดหน้า: โหลด /customers/columns
// - ผู้ใช้เลือก columns ที่ต้องการ (default: ทั้งหมด)
// - กดปุ่ม "ดาวน์โหลด Excel" → โหลด /customers → สร้าง CSV →
//   บันทึก + เปิด Share dialog
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

class _CustomersReportPageBody extends StatelessWidget {
  final String title;
  const _CustomersReportPageBody({required this.title});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CustomersReportViewModel>();

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
                subtitle: vm.totalItems > 0
                    ? 'พบลูกค้าทั้งหมด ${vm.totalItems} รายการ'
                    : null,
                totalCount: vm.totalItems,
                selectedCount: vm.selectedCount,
                onDownload: () async {
                  final messenger = ScaffoldMessenger.of(context);

                  // ✅ ถาม password ก่อน export (optional — กดข้ามได้)
                  final result =
                      await CustomersReportPasswordDialog.show(context);

                  // ถ้า cancel → ไม่ export
                  if (result is PasswordCancel) return;

                  final password = switch (result) {
                    PasswordNoPassword() => null,
                    PasswordWithValue(:final password) => password,
                    _ => null,
                  };

                  final err = await vm.exportToExcel(password: password);
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
              CustomersReportColumnPicker(),
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
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFB91C1C),
                        size: 18,
                      ),
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
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: Color(0xFFB91C1C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: CrSpace.lg),
              // Info
              Container(
                padding: const EdgeInsets.all(CrSpace.md),
                decoration: CrDecor.card(),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: CrColors.textMuted,
                    ),
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
