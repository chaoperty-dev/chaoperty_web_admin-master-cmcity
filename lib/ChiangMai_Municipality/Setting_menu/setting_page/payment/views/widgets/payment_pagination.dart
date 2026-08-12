// ============================================================================
// payment_pagination.dart
// ============================================================================
// Pagination pill — แสดงจำนวนรายการ
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/payment_theme.dart';
import '../../viewmodels/payment_view_model.dart';

class PaymentPagination extends StatelessWidget {
  const PaymentPagination({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PaymentViewModel>();
    final total = vm.filtered.length;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(
          horizontal: PaySpace.sm, vertical: PaySpace.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(PayRadius.md),
        border: Border.all(color: PayColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: PayColors.surfaceMuted,
              borderRadius: BorderRadius.circular(PayRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.list_alt_rounded,
                    size: 14, color: PayColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  'ทั้งหมด $total รายการ',
                  style: PayText.bodyMuted
                      .copyWith(fontFamily: PayText.fontBold, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
