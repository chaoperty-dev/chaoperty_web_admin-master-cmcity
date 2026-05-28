import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

class _FloatingLanternDot extends StatelessWidget {
  const _FloatingLanternDot({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(seconds: 3),
      curve: Curves.easeInOut,
      builder: (context, t, _) {
        // ใช้ math.sin() แทน sinSync
        final dy = math.sin(t * 2 * math.pi) * 2.0;

        return Transform.translate(
          offset: Offset(0, -dy),
          child: Container(
            width: 8,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC76D),
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFE08A).withOpacity(.55),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
