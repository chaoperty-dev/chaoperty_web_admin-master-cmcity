// ============================================================================
// general_data_header.dart
// ============================================================================
// Header — ปุ่ม Back + Title (แบบแท็บเดียว)
// ============================================================================

import 'package:flutter/material.dart';

import 'package:chaoperty/ChiangMai_Municipality/License_menu/license_fact_check_page/views/theme/license_fact_check_theme.dart';

class GeneralDataHeader extends StatelessWidget {
  final VoidCallback onBack;
  final String title;

  const GeneralDataHeader({
    super.key,
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            LaColors.headerBg,
            LaColors.headerAccent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(LaRadius.lg),
          bottomRight: Radius.circular(LaRadius.lg),
        ),
        boxShadow: [
          BoxShadow(
            color: LaColors.primary.withOpacity(.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        isMobile ? 12 : 20,
        isMobile ? 10 : 16,
        isMobile ? 12 : 20,
        isMobile ? 12 : 16,
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'กลับ',
            onPressed: onBack,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: LaColors.textInverse,
              size: isMobile ? 18 : 22,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(.10),
              padding: EdgeInsets.all(isMobile ? 8 : 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(LaRadius.sm),
              ),
            ),
          ),
          SizedBox(width: isMobile ? 8 : LaSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isMobile)
                  Text(
                    'RENTAL GENERAL',
                    style: LaText.label.copyWith(
                      color: LaColors.primaryAccent.withOpacity(.9),
                      letterSpacing: 1.6,
                      fontSize: 10,
                    ),
                  ),
                if (!isMobile) const SizedBox(height: 2),
                Text(
                  title,
                  style: LaText.h1.copyWith(
                    color: LaColors.textInverse,
                    fontSize: isMobile ? 16 : 20,
                  ),
                  maxLines: 1,
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

