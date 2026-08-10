// ============================================================================
// next_step_button.dart
// ============================================================================
// ปุ่ม "ถัดไป" — gradient + hover/press animation
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/license_contract_theme.dart';
import '../../viewmodels/license_contract_view_model.dart';

class NextStepButton extends StatefulWidget {
  const NextStepButton({super.key});

  @override
  State<NextStepButton> createState() => _NextStepButtonState();
}

class _NextStepButtonState extends State<NextStepButton> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.read<LicenseContractViewModel>();
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.all(LcSpace.sm),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: AnimatedScale(
            scale: _down ? 0.97 : (_hover ? 1.02 : 1.0),
            duration: LcAnimations.fast,
            curve: Curves.easeOut,
            child: GestureDetector(
              onTapDown: (_) => setState(() => _down = true),
              onTapCancel: () => setState(() => _down = false),
              onTapUp: (_) => setState(() => _down = false),
              onTap: vm.submit,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [LcColors.primaryAccent, LcColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(LcRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: LcColors.primary.withOpacity(_hover ? .50 : .35),
                      blurRadius: _hover ? 14 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ถัดไป',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: LcText.fontBold,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
