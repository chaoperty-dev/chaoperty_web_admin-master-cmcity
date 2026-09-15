import 'package:flutter/material.dart';

import '../../../views/theme/setting_page_theme.dart';

class PaymentActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const PaymentActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<PaymentActionButton> createState() => _PaymentActionButtonState();
}

class _PaymentActionButtonState extends State<PaymentActionButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final foreground = _hover ? Colors.white : widget.color;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _hover ? widget.color : widget.color.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(SetRadius.pill),
            border: Border.all(
              color:
                  _hover ? widget.color : widget.color.withValues(alpha: .25),
            ),
            boxShadow: [
              if (_hover)
                BoxShadow(
                  color: widget.color.withValues(alpha: .28),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 13, color: foreground),
              const SizedBox(width: 5),
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: SetText.fontBold,
                  fontSize: 11,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
