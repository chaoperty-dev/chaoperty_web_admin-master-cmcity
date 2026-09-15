import 'package:flutter/material.dart';

import '../../viewmodels/payment_method_view_model.dart';
import '../../../views/theme/setting_page_theme.dart';

class PaymentViewToggle extends StatelessWidget {
  final PaymentMethodViewMode mode;
  final ValueChanged<PaymentMethodViewMode> onChanged;

  const PaymentViewToggle({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: SetColors.surfaceMuted,
          borderRadius: BorderRadius.circular(SetRadius.pill),
          border: Border.all(color: SetColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _button(
              Icons.view_agenda_outlined,
              'การ์ด',
              PaymentMethodViewMode.card,
            ),
            _button(
              Icons.table_rows_outlined,
              'ตาราง',
              PaymentMethodViewMode.table,
            ),
          ],
        ),
      );

  Widget _button(IconData icon, String label, PaymentMethodViewMode value) {
    final selected = mode == value;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(SetRadius.pill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? SetColors.cardBg : Colors.transparent,
          borderRadius: BorderRadius.circular(SetRadius.pill),
          boxShadow: selected
              ? [const BoxShadow(color: Color(0x14000000), blurRadius: 4)]
              : const [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? SetColors.primary : SetColors.textMuted,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: SetText.bodyMuted.copyWith(
                color: selected ? SetColors.primary : SetColors.textSecondary,
                fontFamily: selected ? SetText.fontBold : SetText.fontRegular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
