import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ChiangMaiBackground extends StatelessWidget {
  const ChiangMaiBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ChiangMaiPainter(),
      size: Size.infinite,
    );
  }
}

class _ChiangMaiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _drawSkyGradient(canvas, size);
    _drawMountains(canvas, size);
    _drawChediSilhouette(canvas, size);
    _drawLantern(
        canvas, size, Offset(size.width * 0.22, size.height * 0.28), 26, 38);
    _drawLantern(
        canvas, size, Offset(size.width * 0.35, size.height * 0.22), 22, 32);
    _drawLantern(
        canvas, size, Offset(size.width * 0.68, size.height * 0.18), 28, 42);
  }

  // ---------- Sky ----------
  void _drawSkyGradient(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomCenter,
      colors: [
        // Colors.white,
        // Colors.grey.shade100,
        // Colors.grey.shade200,
        ////-------------------------------->
        // Color(0xFFEDE7F6), // lavender
        // Color(0xFFD1C4E9), // soft purple gray
        // Color(0xFFFFF8E1), // cream
        ////-------------------------------->
        Color(0xFF8E44AD), // ม่วงเข้ม
        Color(0xFFBB8FCE), // ม่วงอ่อน
        Color(0xFFF5B041), // ทองอมส้ม
      ],
      stops: [0.0, 0.6, 1.0],
    ).createShader(rect);

    final paint = Paint()
      ..shader = shader
      ..style = PaintingStyle.fill;

    canvas.drawRect(rect, paint);

    // haze เบา ๆ ที่ด้านล่าง เพื่อให้อ่านข้อความง่ายขึ้น
    final haze = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, size.height * 0.6),
        Offset(0, size.height),
        [Colors.white.withOpacity(0.0), Colors.white.withOpacity(0.20)],
      );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.55, size.width, size.height * 0.45),
      haze,
    );
  }

  // ---------- Mountains (Doi Suthep layers) ----------
  void _drawMountains(Canvas canvas, Size size) {
    final back = Path()
      ..moveTo(0, size.height * 0.62)
      ..cubicTo(size.width * 0.18, size.height * 0.52, size.width * 0.33,
          size.height * 0.66, size.width * 0.48, size.height * 0.58)
      ..cubicTo(size.width * 0.66, size.height * 0.48, size.width * 0.80,
          size.height * 0.62, size.width, size.height * 0.56)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final mid = Path()
      ..moveTo(0, size.height * 0.70)
      ..cubicTo(size.width * 0.20, size.height * 0.62, size.width * 0.36,
          size.height * 0.76, size.width * 0.52, size.height * 0.66)
      ..cubicTo(size.width * 0.70, size.height * 0.58, size.width * 0.84,
          size.height * 0.72, size.width, size.height * 0.66)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final front = Path()
      ..moveTo(0, size.height * 0.80)
      ..cubicTo(size.width * 0.22, size.height * 0.72, size.width * 0.42,
          size.height * 0.86, size.width * 0.58, size.height * 0.78)
      ..cubicTo(size.width * 0.75, size.height * 0.70, size.width * 0.88,
          size.height * 0.82, size.width, size.height * 0.78)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
        back, Paint()..color = const Color(0xFF5E3370).withOpacity(0.45));
    canvas.drawPath(
        mid, Paint()..color = const Color(0xFF4A275F).withOpacity(0.55));
    canvas.drawPath(
        front, Paint()..color = const Color(0xFF351A4A).withOpacity(0.70));
  }

  // ---------- Chedi silhouette ----------
  void _drawChediSilhouette(Canvas canvas, Size size) {
    final cx = size.width * 0.80; // center x
    final baseY = size.height * 0.70; // base y
    final w = size.width * 0.12; // overall width
    final h = size.height * 0.24; // overall height

    final p = Path();

    // base platform
    p.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, baseY), width: w, height: h * 0.12),
      const Radius.circular(4),
    ));

    // stacked bodies (trapezoids)
    final levels = [
      _trap(cx, baseY - h * 0.10, w * 0.90, w * 0.70, h * 0.12),
      _trap(cx, baseY - h * 0.22, w * 0.70, w * 0.50, h * 0.10),
      _trap(cx, baseY - h * 0.32, w * 0.50, w * 0.32, h * 0.09),
      _trap(cx, baseY - h * 0.40, w * 0.32, w * 0.18, h * 0.08),
    ];
    for (final t in levels) {
      p.addPath(t, Offset.zero);
    }

    // bell section
    final bell = Path()
      ..moveTo(cx - w * 0.12, baseY - h * 0.48)
      ..quadraticBezierTo(cx, baseY - h * 0.62, cx + w * 0.12, baseY - h * 0.48)
      ..quadraticBezierTo(cx, baseY - h * 0.38, cx - w * 0.12, baseY - h * 0.48)
      ..close();
    p.addPath(bell, Offset.zero);

    // spire
    p.moveTo(cx, baseY - h * 0.62);
    p.lineTo(cx - w * 0.02, baseY - h * 0.84);
    p.lineTo(cx + w * 0.02, baseY - h * 0.84);
    p.close();

    // small finial (จุกยอด)
    p.addOval(Rect.fromCircle(
        center: Offset(cx, baseY - h * 0.86), radius: w * 0.015));

    // draw
    final body = Paint()..color = const Color(0xFF2B123D).withOpacity(0.85);
    canvas.drawPath(p, body);

    // highlight ขอบทองอ่อน ๆ
    final stroke = Paint()
      ..color = const Color(0xFFFFE08A).withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(p, stroke);
  }

  Path _trap(double cx, double cy, double topW, double botW, double h) {
    // trapezoid centered at (cx, cy) with height h
    final p = Path()
      ..moveTo(cx - topW / 2, cy - h / 2)
      ..lineTo(cx + topW / 2, cy - h / 2)
      ..lineTo(cx + botW / 2, cy + h / 2)
      ..lineTo(cx - botW / 2, cy + h / 2)
      ..close();
    return p;
  }

  // ---------- Yi Peng lanterns ----------
  void _drawLantern(
      Canvas canvas, Size size, Offset center, double w, double h) {
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: w, height: h),
      const Radius.circular(6),
    );

    // soft glow
    final glowPaint = Paint()
      ..color = const Color(0xFFFFE08A).withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center, w, glowPaint);

    // body
    final bodyPaint = Paint()..color = const Color(0xFFFFC76D);
    canvas.drawRRect(bodyRect, bodyPaint);

    // top/bottom rim
    final rimPaint = Paint()..color = const Color(0xFF8E5A00);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: center.translate(0, -h * 0.38),
            width: w * 0.92,
            height: h * 0.12),
        const Radius.circular(4),
      ),
      rimPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: center.translate(0, h * 0.38),
            width: w * 0.92,
            height: h * 0.12),
        const Radius.circular(4),
      ),
      rimPaint,
    );

    // inner flame
    final flame = Paint()..color = const Color(0xFFFFF3B0);
    canvas.drawOval(
      Rect.fromCenter(
          center: center.translate(0, h * 0.10),
          width: w * 0.20,
          height: h * 0.28),
      flame,
    );

    // tiny string
    final line = Paint()
      ..color = const Color(0xFF6D3E00)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
        center.translate(0, h * 0.44), center.translate(0, h * 0.60), line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
