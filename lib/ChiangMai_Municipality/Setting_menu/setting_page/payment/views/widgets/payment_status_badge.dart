import 'package:flutter/material.dart';

import '../../../views/theme/setting_page_theme.dart';

class PaymentStatusBadge extends StatelessWidget {
  final bool active;

  const PaymentStatusBadge({super.key, required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? SetColors.primaryDark : SetColors.textSecondary;
    final background = active ? SetColors.primaryLight : SetColors.surfaceMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(SetRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.check_circle_rounded : Icons.pause_circle_outline,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            active ? 'เปิดใช้งาน' : 'ปิดใช้งาน',
            style: SetText.label.copyWith(
              color: color,
              fontSize: 10,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
