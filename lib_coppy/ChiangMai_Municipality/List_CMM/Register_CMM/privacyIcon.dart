import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PrivacyIcon extends StatefulWidget {
  const PrivacyIcon({super.key});

  @override
  State<PrivacyIcon> createState() => _PrivacyIconState();
}

class _PrivacyIconState extends State<PrivacyIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Icon(
        Icons.temple_buddhist,
        color: Colors.grey[600],
        size: 40,
        semanticLabel: "Privacy & PDPA",
      ),
    );
  }
}
