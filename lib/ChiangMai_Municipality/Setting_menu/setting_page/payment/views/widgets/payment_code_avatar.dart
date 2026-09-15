import 'package:flutter/material.dart';

import '../../../views/theme/setting_page_theme.dart';

class PaymentCodeAvatar extends StatelessWidget {
  final String code;
  final double size;

  const PaymentCodeAvatar({
    super.key,
    required this.code,
    this.size = 38,
  });

  IconData get _icon {
    final value = code.toUpperCase();
    if (value == 'GBPAY_QR') return Icons.qr_code_2_rounded;
    if (value == 'GBPAY_CARD') return Icons.credit_card_rounded;
    if (value.contains('QR')) return Icons.qr_code_2_rounded;
    if (value.contains('BANK')) return Icons.account_balance_rounded;
    if (value.contains('CARD')) return Icons.credit_card_rounded;
    if (value.contains('CASH')) return Icons.payments_rounded;
    if (value.contains('GBPAY')) return Icons.account_balance_wallet_rounded;
    return Icons.payments_outlined;
  }

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: SetColors.primaryLight,
          borderRadius: BorderRadius.circular(SetRadius.md),
        ),
        child: Icon(
          _icon,
          size: size * .52,
          color: SetColors.primaryDark,
        ),
      );
}
