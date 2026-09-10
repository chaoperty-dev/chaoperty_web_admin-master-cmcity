// ============================================================================
// general_data_header.dart
// ============================================================================
// Header — ปุ่ม Back + Title + Tab bar (แทน Step indicator เดิม)
// 2 tabs: "ข้อมูลทั่วไป" / "รูปภาพโซน"
// ============================================================================

import 'package:flutter/material.dart';

import 'package:chaoperty/ChiangMai_Municipality/License_menu/license_fact_check_page/views/theme/license_fact_check_theme.dart';

class GeneralDataTabBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final ValueChanged<int> onStepChanged;
  final VoidCallback onBack;
  final String title;

  const GeneralDataTabBar({
    super.key,
    required this.title,
    required this.currentStep,
    required this.totalSteps,
    required this.onStepChanged,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;
    final tabs = [
      _TabInfo(
        icon: Icons.tune_rounded,
        label: 'ข้อมูลทั่วไป',
        subtitle: 'พื้นที่ / ชื่อสถานที่ / การแจ้งเตือน',
      ),
      _TabInfo(
        icon: Icons.collections_rounded,
        label: 'รูปภาพโซน',
        subtitle: 'อัปโหลด / ลบ / ค้นหาโซน',
      ),
    ];

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row: Back + Title + Step indicator
          Padding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 12 : 20,
              isMobile ? 10 : 16,
              isMobile ? 12 : 20,
              isMobile ? 6 : 12,
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
                if (!isMobile)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.10),
                      borderRadius: BorderRadius.circular(LaRadius.pill),
                      border: Border.all(
                        color: Colors.white.withOpacity(.20),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timeline_rounded,
                          color: LaColors.textInverse,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Step $currentStep/$totalSteps',
                          style: LaText.caption.copyWith(
                            color: Colors.white,
                            fontFamily: LaText.fontBold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Tab bar
          Padding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 8 : 12,
              0,
              isMobile ? 8 : 12,
              isMobile ? 8 : 12,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.08),
                borderRadius: BorderRadius.circular(LaRadius.pill),
                border: Border.all(
                  color: Colors.white.withOpacity(.12),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(3),
              child: Row(
                children: List.generate(tabs.length, (i) {
                  final tab = tabs[i];
                  final selected = (i + 1) == currentStep;
                  return Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(LaRadius.pill),
                      onTap: () => onStepChanged(i + 1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 6 : 10,
                          vertical: isMobile ? 6 : 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              selected ? LaColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(LaRadius.pill),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: LaColors.primary.withOpacity(.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              tab.icon,
                              size: isMobile ? 14 : 16,
                              color: selected
                                  ? Colors.white
                                  : Colors.white.withOpacity(.75),
                            ),
                            SizedBox(width: isMobile ? 4 : 6),
                            Flexible(
                              child: Text(
                                tab.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: LaText.caption.copyWith(
                                  color: selected
                                      ? Colors.white
                                      : Colors.white.withOpacity(.75),
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontSize: isMobile ? 11 : 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabInfo {
  final IconData icon;
  final String label;
  final String subtitle;
  const _TabInfo({
    required this.icon,
    required this.label,
    required this.subtitle,
  });
}
