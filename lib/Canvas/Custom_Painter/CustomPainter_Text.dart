import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';

//Add this CustomPaint widget to the Widget Tree

//Copy this CustomPainter code to the Bottom of the File
class RPSCustomPainter_Text extends CustomPainter {
  final color_s;
  final Text_s;

  RPSCustomPainter_Text(this.color_s, this.Text_s);

  @override
  void paint(Canvas canvas, Size size) {
    // Layer 1

    Paint paint_fill_0 = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255)
      ..style = PaintingStyle.fill
      ..strokeWidth = size.width * 0.00
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    Path path_0 = Path();

    canvas.drawPath(path_0, paint_fill_0);

    // Layer 1

    Paint paint_stroke_0 = Paint()
      ..color = const Color.fromARGB(255, 33, 150, 243)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.00
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    canvas.drawPath(path_0, paint_stroke_0);

    // Text Layer 1

    canvas.save();
    final pivot_3871585420167 = Offset(size.width * 0.00, size.height * 0.24);
    canvas.translate(pivot_3871585420167.dx, pivot_3871585420167.dy);
    canvas.rotate(0.0);
    canvas.translate(-pivot_3871585420167.dx, -pivot_3871585420167.dy);
    TextPainter tp_3871585420167 = TextPainter(
      text: TextSpan(
          text: """$Text_s""",
          style: TextStyle(
            fontSize: size.width * 0.13,
            fontWeight: FontWeight.bold,
            color: Color(0xff000000),
            fontStyle: FontStyle.italic,
            decoration: TextDecoration.none,
          )),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    )..layout(maxWidth: size.width * 1.02, minWidth: size.width * 1.02);
    tp_3871585420167.paint(canvas, pivot_3871585420167);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
