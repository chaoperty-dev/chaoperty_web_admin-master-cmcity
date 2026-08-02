// ============================================================================
// rental_general_section_row.dart — Row label + value (ใช้สำหรับ Row 1, 2, 3)
// ============================================================================

import 'package:flutter/material.dart';

import 'package:chaoperty/ChiangMai_Municipality/License_menu/license_fact_check_page/views/theme/license_fact_check_theme.dart';

class RentalGeneralSectionRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final double labelFlex;
  final double valueFlex;

  const RentalGeneralSectionRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.labelFlex = 1,
    this.valueFlex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: labelFlex.toInt(),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: Text(label, style: LaText.bodyMuted),
            ),
          ),
          Expanded(
            flex: valueFlex.toInt(),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: LaColors.border, width: 1),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: Text(
                      value,
                      style: LaText.body,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
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
