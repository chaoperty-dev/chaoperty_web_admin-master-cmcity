// ============================================================================
// rental_general_stat_chip.dart — Stat pill chip
// ============================================================================

import 'package:flutter/material.dart';

import 'package:chaoperty/ChiangMai_Municipality/License_menu/license_fact_check_page/views/theme/license_fact_check_theme.dart';

class RentalGeneralStatChip extends StatelessWidget {
  final String text;
  final Color? tone;
  final Color? background;

  const RentalGeneralStatChip({
    super.key,
    required this.text,
    this.tone,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final fg = tone ?? LaColors.primaryDark;
    final bg = background ?? LaColors.primaryLight.withOpacity(.5);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: LaSpace.md, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: fg.withOpacity(.25), width: 1),
      ),
      child: Text(
        text,
        style: LaText.body.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
