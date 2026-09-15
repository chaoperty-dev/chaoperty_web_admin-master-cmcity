import 'package:flutter/material.dart';

import '../../../views/theme/setting_page_theme.dart';

class PaymentErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const PaymentErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: SetText.body),
            const SizedBox(height: SetSpace.sm),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('ลองใหม่'),
            ),
          ],
        ),
      );
}

class PaymentEmptyState extends StatelessWidget {
  final bool hasSearch;
  final VoidCallback onAction;

  const PaymentEmptyState({
    super.key,
    required this.hasSearch,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.payments_outlined,
              size: 48,
              color: SetColors.textMuted,
            ),
            const SizedBox(height: SetSpace.md),
            Text(
              hasSearch
                  ? 'ไม่พบช่องทางการรับชำระ'
                  : 'ยังไม่มีช่องทางการรับชำระ',
              style: SetText.h2,
            ),
            const SizedBox(height: SetSpace.sm),
            OutlinedButton.icon(
              onPressed: onAction,
              icon: Icon(hasSearch ? Icons.close_rounded : Icons.refresh),
              label: Text(hasSearch ? 'ล้างคำค้นหา' : 'โหลดข้อมูลใหม่'),
            ),
          ],
        ),
      );
}
