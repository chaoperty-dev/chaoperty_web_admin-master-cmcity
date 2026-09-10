// ============================================================================
// rental_general_header.dart — Header card (slate gradient + emerald badge)
// ============================================================================

import 'package:flutter/material.dart';

import 'package:chaoperty/ChiangMai_Municipality/License_menu/license_fact_check_page/views/theme/license_fact_check_theme.dart';

class RentalGeneralHeader extends StatelessWidget {
  const RentalGeneralHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            LaColors.headerBg,
            LaColors.headerAccent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(LaRadius.lg),
        boxShadow: [
          BoxShadow(
            color: LaColors.primary.withOpacity(.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: LaColors.primary.withOpacity(.18),
              borderRadius: BorderRadius.circular(LaRadius.md),
              border: Border.all(
                color: LaColors.primaryAccent.withOpacity(.35),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: LaColors.primaryAccent,
              size: 22,
            ),
          ),
          const SizedBox(width: LaSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'RENTAL SETTINGS',
                  style: LaText.label.copyWith(
                    color: LaColors.primaryAccent.withOpacity(.9),
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ข้อมูลทั่วไป',
                  style: LaText.h1.copyWith(
                    color: LaColors.textInverse,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ตั้งค่าข้อมูลพื้นฐานของระบบ (พื้นที่, การเช่า, ค่าใช้จ่าย)',
                  style: LaText.caption.copyWith(
                    color: Colors.white.withOpacity(.65),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
