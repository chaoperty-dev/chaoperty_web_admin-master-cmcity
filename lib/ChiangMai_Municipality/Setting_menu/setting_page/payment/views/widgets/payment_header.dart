// ============================================================================
// payment_header.dart
// ============================================================================
// Header ของหน้า "การรับชำระ"
// - Eyebrow + Title + subtitle + count badge + ปุ่ม "เพิ่ม Payment"
// - ปุ่มจัดการ PayType / Bank / BankType
// ============================================================================

import 'package:flutter/material.dart';

import '../theme/payment_theme.dart';

class PaymentHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int? totalCount;
  final VoidCallback? onAdd;
  final VoidCallback? onAddPayType;
  final VoidCallback? onAddBank;
  final VoidCallback? onAddBankType;

  const PaymentHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.totalCount,
    this.onAdd,
    this.onAddPayType,
    this.onAddBank,
    this.onAddBankType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [PayColors.headerBg, PayColors.headerAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(PayRadius.lg),
        boxShadow: [
          BoxShadow(
            color: PayColors.primary.withOpacity(.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: PayColors.primary.withOpacity(.18),
                  borderRadius: BorderRadius.circular(PayRadius.md),
                  border: Border.all(
                    color: PayColors.primaryAccent.withOpacity(.35),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.payments_rounded,
                  color: PayColors.primaryAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: PaySpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'PAYMENT MANAGEMENT',
                      style: PayText.label.copyWith(
                        color: PayColors.primaryAccent.withOpacity(.9),
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: PayText.h1.copyWith(
                        color: PayColors.textInverse,
                        fontSize: 20,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: PayText.caption.copyWith(
                          color: Colors.white.withOpacity(.65),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (totalCount != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.08),
                    borderRadius: BorderRadius.circular(PayRadius.pill),
                    border: Border.all(
                      color: Colors.white.withOpacity(.18),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.format_list_numbered_rounded,
                        color: PayColors.primaryAccent,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$totalCount รายการ',
                        style: PayText.bodyMuted.copyWith(
                          color: Colors.white,
                          fontFamily: PayText.fontBold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: PaySpace.sm),
              ],
              if (onAdd != null) _AddButton(onPressed: onAdd!),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (onAddPayType != null)
                _GhostButton(
                  icon: Icons.category_outlined,
                  label: 'เพิ่ม PayType',
                  onPressed: onAddPayType!,
                ),
              if (onAddBank != null) ...[
                const SizedBox(width: PaySpace.sm),
                _GhostButton(
                  icon: Icons.account_balance_outlined,
                  label: 'เพิ่ม Bank',
                  onPressed: onAddBank!,
                ),
              ],
              if (onAddBankType != null) ...[
                const SizedBox(width: PaySpace.sm),
                _GhostButton(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'เพิ่ม BankType',
                  onPressed: onAddBankType!,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _AddButton({required this.onPressed});
  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
  bool _hover = false;
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: PayAnimations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _down
                ? PayColors.primaryDark
                : (_hover ? PayColors.primary : PayColors.primaryAccent),
            borderRadius: BorderRadius.circular(PayRadius.md),
            boxShadow: [
              if (_hover)
                BoxShadow(
                  color: PayColors.primary.withOpacity(.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                'เพิ่ม Payment',
                style: PayText.bodyMuted.copyWith(
                  color: Colors.white,
                  fontFamily: PayText.fontBold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GhostButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const _GhostButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });
  @override
  State<_GhostButton> createState() => _GhostButtonState();
}

class _GhostButtonState extends State<_GhostButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: PayAnimations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _hover
                ? Colors.white.withOpacity(.18)
                : Colors.white.withOpacity(.08),
            borderRadius: BorderRadius.circular(PayRadius.sm),
            border: Border.all(color: Colors.white.withOpacity(.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Text(
                widget.label,
                style: PayText.bodyMuted.copyWith(
                  color: Colors.white,
                  fontFamily: PayText.fontBold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
