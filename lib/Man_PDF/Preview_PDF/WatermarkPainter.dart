import 'package:flutter/cupertino.dart';

class WatermarkPainter extends CustomPainter {
  final String text;
  const WatermarkPainter(this.text);

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    const double angle = -0.4; // ~ -22°
    canvas.save();
    canvas.rotate(angle);

    final style = const TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.bold,
      color: Color.fromRGBO(0, 0, 0, 0.05),
    );

    // เว้นระยะห่างแบบคงที่ วาดให้ครอบคลุมทั้งหน้าจอ
    for (double y = -size.height; y < size.height * 2; y += 180) {
      for (double x = -size.width; x < size.width * 2; x += 360) {
        textPainter.text = TextSpan(text: text, style: style);
        textPainter.layout();
        textPainter.paint(canvas, Offset(x, y));
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
