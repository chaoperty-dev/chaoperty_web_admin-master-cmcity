import 'package:flutter/material.dart';

import '../../models/payment_method_model.dart';
import '../../../views/theme/setting_page_theme.dart';
import 'payment_action_button.dart';
import 'payment_code_avatar.dart';
import 'payment_status_badge.dart';

class PaymentMethodCard extends StatelessWidget {
  final PaymentMethodModel item;
  final VoidCallback onEdit;

  const PaymentMethodCard({
    super.key,
    required this.item,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final payTypes = item.payTypes.isEmpty ? '-' : item.payTypes.join(', ');
    final system = item.paymentSystem.isEmpty ? '-' : item.paymentSystem;
    final description = item.description.isEmpty ? '-' : item.description;

    return Container(
      decoration: SetDecor.card(),
      padding: const EdgeInsets.all(SetSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.nameTh.isEmpty ? '-' : item.nameTh,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SetText.body.copyWith(
                    fontFamily: SetText.fontBold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: SetSpace.sm),
              PaymentCodeAvatar(code: item.code, size: 30),
              const SizedBox(width: SetSpace.sm),
              Flexible(
                child: Text(
                  item.code.isEmpty ? '-' : item.code,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: SetText.caption,
                ),
              ),
              const SizedBox(width: SetSpace.sm),
              PaymentStatusBadge(active: item.active),
            ],
          ),
          const Divider(height: SetSpace.lg, color: SetColors.border),
          _PaymentCardInfoLine(
            icon: Icons.settings_outlined,
            value: system,
          ),
          const SizedBox(height: 6),
          _PaymentCardInfoLine(
            icon: Icons.account_balance_wallet_outlined,
            value: payTypes,
          ),
          const SizedBox(height: 6),
          _PaymentCardInfoLine(
            icon: Icons.description_outlined,
            value: description,
            maxLines: 2,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PaymentActionButton(
                icon: Icons.edit_rounded,
                label: 'แก้ไข',
                color: const Color(0xFF2563EB),
                onTap: onEdit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentCardInfoLine extends StatelessWidget {
  final IconData icon;
  final String value;
  final int maxLines;

  const _PaymentCardInfoLine({
    required this.icon,
    required this.value,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => Tooltip(
        message: value,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(icon, size: 15, color: SetColors.textMuted),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                value,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: SetText.bodyMuted.copyWith(
                  fontSize: 12,
                  color: SetColors.textSecondary,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      );
}
