// ============================================================================
// general_data_footer.dart
// ============================================================================
// Footer — ปุ่ม "บันทึก" (เปลี่ยนเป็น tab แล้ว ไม่ต้องมี ก่อนหน้า/ถัดไป)
// ============================================================================

import 'package:flutter/material.dart';

import 'package:chaoperty/ChiangMai_Municipality/License_menu/license_fact_check_page/views/theme/license_fact_check_theme.dart';

class GeneralDataFooter extends StatelessWidget {
  final VoidCallback onSave;

  const GeneralDataFooter({
    super.key,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LaColors.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top border (1px line)
          Container(
            height: 1,
            color: LaColors.border,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: LaSpace.lg,
              vertical: LaSpace.md,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('บันทึก'),
                style: FilledButton.styleFrom(
                  backgroundColor: LaColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(LaRadius.md),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
