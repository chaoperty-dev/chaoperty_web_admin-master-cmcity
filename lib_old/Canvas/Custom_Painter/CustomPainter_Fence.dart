import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//Add this CustomPaint widget to the Widget Tree

//Copy this CustomPainter code to the Bottom of the File
class RPSCustomPainter_Fence extends CustomPainter {
  final color_s;

  RPSCustomPainter_Fence(this.color_s);

  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(size.width, size.height * 0.2691953);
    path_0.cubicTo(
        size.width,
        size.height * 0.3167988,
        size.width * 0.9613965,
        size.height * 0.3554023,
        size.width * 0.9137930,
        size.height * 0.3554023);
    path_0.cubicTo(
        size.width * 0.8661895,
        size.height * 0.3554023,
        size.width * 0.8275859,
        size.height * 0.3167988,
        size.width * 0.8275859,
        size.height * 0.2691953);
    path_0.cubicTo(
        size.width * 0.8275859,
        size.height * 0.2215918,
        size.width * 0.8661895,
        size.height * 0.1829883,
        size.width * 0.9137930,
        size.height * 0.1829883);
    path_0.cubicTo(size.width * 0.9613965, size.height * 0.1829883, size.width,
        size.height * 0.2215918, size.width, size.height * 0.2691953);

    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;
    paint_0_fill.color = Colors.deepPurple[200]!.withOpacity(1.0);
    canvas.drawPath(path_0, paint_0_fill);

    Path path_1 = Path();
    path_1.moveTo(size.width * 0.1379316, size.height * 0.5967773);
    path_1.lineTo(size.width * 0.2413789, size.height * 0.5967773);
    path_1.lineTo(size.width * 0.2413789, size.height * 0.4933281);
    path_1.lineTo(size.width * 0.1379316, size.height * 0.4933281);
    path_1.close();

    Paint paint_1_fill = Paint()..style = PaintingStyle.fill;
    paint_1_fill.color = Color(0xff493a2d).withOpacity(1.0);
    canvas.drawPath(path_1, paint_1_fill);

    Path path_2 = Path();
    path_2.moveTo(size.width * 0.2413789, size.height * 0.5967773);
    path_2.lineTo(size.width * 0.3448281, size.height * 0.5967773);
    path_2.lineTo(size.width * 0.3448281, size.height * 0.4933281);
    path_2.lineTo(size.width * 0.2413789, size.height * 0.4933281);
    path_2.close();

    Paint paint_2_fill = Paint()..style = PaintingStyle.fill;
    paint_2_fill.color = Colors.deepPurple[200]!.withOpacity(1.0);
    canvas.drawPath(path_2, paint_2_fill);

    Path path_3 = Path();
    path_3.moveTo(size.width * 0.3448281, size.height * 0.5967773);
    path_3.lineTo(size.width * 0.4482754, size.height * 0.5967773);
    path_3.lineTo(size.width * 0.4482754, size.height * 0.4933281);
    path_3.lineTo(size.width * 0.3448281, size.height * 0.4933281);
    path_3.close();

    Paint paint_3_fill = Paint()..style = PaintingStyle.fill;
    paint_3_fill.color = Color(0xff493a2d).withOpacity(1.0);
    canvas.drawPath(path_3, paint_3_fill);

    Path path_4 = Path();
    path_4.moveTo(size.width * 0.4482754, size.height * 0.5967773);
    path_4.lineTo(size.width * 0.5517246, size.height * 0.5967773);
    path_4.lineTo(size.width * 0.5517246, size.height * 0.4933281);
    path_4.lineTo(size.width * 0.4482754, size.height * 0.4933281);
    path_4.close();

    Paint paint_4_fill = Paint()..style = PaintingStyle.fill;
    paint_4_fill.color = Colors.deepPurple[200]!.withOpacity(1.0);
    canvas.drawPath(path_4, paint_4_fill);

    Path path_5 = Path();
    path_5.moveTo(size.width * 0.5517246, size.height * 0.5967773);
    path_5.lineTo(size.width * 0.6551719, size.height * 0.5967773);
    path_5.lineTo(size.width * 0.6551719, size.height * 0.4933281);
    path_5.lineTo(size.width * 0.5517246, size.height * 0.4933281);
    path_5.close();

    Paint paint_5_fill = Paint()..style = PaintingStyle.fill;
    paint_5_fill.color = Color(0xff493a2d).withOpacity(1.0);
    canvas.drawPath(path_5, paint_5_fill);

    Path path_6 = Path();
    path_6.moveTo(size.width * 0.6551719, size.height * 0.5967773);
    path_6.lineTo(size.width * 0.7586211, size.height * 0.5967773);
    path_6.lineTo(size.width * 0.7586211, size.height * 0.4933281);
    path_6.lineTo(size.width * 0.6551719, size.height * 0.4933281);
    path_6.close();

    Paint paint_6_fill = Paint()..style = PaintingStyle.fill;
    paint_6_fill.color = Colors.deepPurple[200]!.withOpacity(1.0);
    canvas.drawPath(path_6, paint_6_fill);

    Path path_7 = Path();
    path_7.moveTo(size.width * 0.7586211, size.height * 0.5967773);
    path_7.lineTo(size.width * 0.8620684, size.height * 0.5967773);
    path_7.lineTo(size.width * 0.8620684, size.height * 0.4933281);
    path_7.lineTo(size.width * 0.7586211, size.height * 0.4933281);
    path_7.close();

    Paint paint_7_fill = Paint()..style = PaintingStyle.fill;
    paint_7_fill.color = Color(0xff493a2d).withOpacity(1.0);
    canvas.drawPath(path_7, paint_7_fill);

    Path path_8 = Path();
    path_8.moveTo(size.width * 0.1379316, size.height * 0.4933281);
    path_8.lineTo(size.width * 0.2413789, size.height * 0.4933281);
    path_8.lineTo(size.width * 0.2413789, size.height * 0.3898809);
    path_8.lineTo(size.width * 0.1379316, size.height * 0.3898809);
    path_8.close();

    Paint paint_8_fill = Paint()..style = PaintingStyle.fill;
    paint_8_fill.color = Colors.deepPurple[200]!.withOpacity(1.0);
    canvas.drawPath(path_8, paint_8_fill);

    Path path_9 = Path();
    path_9.moveTo(size.width * 0.2413789, size.height * 0.4933281);
    path_9.lineTo(size.width * 0.3448281, size.height * 0.4933281);
    path_9.lineTo(size.width * 0.3448281, size.height * 0.3898809);
    path_9.lineTo(size.width * 0.2413789, size.height * 0.3898809);
    path_9.close();

    Paint paint_9_fill = Paint()..style = PaintingStyle.fill;
    paint_9_fill.color = Color(0xff493a2d).withOpacity(1.0);
    canvas.drawPath(path_9, paint_9_fill);

    Path path_10 = Path();
    path_10.moveTo(size.width * 0.3448281, size.height * 0.4933281);
    path_10.lineTo(size.width * 0.4482754, size.height * 0.4933281);
    path_10.lineTo(size.width * 0.4482754, size.height * 0.3898809);
    path_10.lineTo(size.width * 0.3448281, size.height * 0.3898809);
    path_10.close();

    Paint paint_10_fill = Paint()..style = PaintingStyle.fill;
    paint_10_fill.color = Colors.deepPurple[200]!.withOpacity(1.0);
    canvas.drawPath(path_10, paint_10_fill);

    Path path_11 = Path();
    path_11.moveTo(size.width * 0.4482754, size.height * 0.4933281);
    path_11.lineTo(size.width * 0.5517246, size.height * 0.4933281);
    path_11.lineTo(size.width * 0.5517246, size.height * 0.3898809);
    path_11.lineTo(size.width * 0.4482754, size.height * 0.3898809);
    path_11.close();

    Paint paint_11_fill = Paint()..style = PaintingStyle.fill;
    paint_11_fill.color = Color(0xff493a2d).withOpacity(1.0);
    canvas.drawPath(path_11, paint_11_fill);

    Path path_12 = Path();
    path_12.moveTo(size.width * 0.5517246, size.height * 0.4933281);
    path_12.lineTo(size.width * 0.6551719, size.height * 0.4933281);
    path_12.lineTo(size.width * 0.6551719, size.height * 0.3898809);
    path_12.lineTo(size.width * 0.5517246, size.height * 0.3898809);
    path_12.close();

    Paint paint_12_fill = Paint()..style = PaintingStyle.fill;
    paint_12_fill.color = Colors.deepPurple[200]!.withOpacity(1.0);
    canvas.drawPath(path_12, paint_12_fill);

    Path path_13 = Path();
    path_13.moveTo(size.width * 0.6551719, size.height * 0.4933281);
    path_13.lineTo(size.width * 0.7586211, size.height * 0.4933281);
    path_13.lineTo(size.width * 0.7586211, size.height * 0.3898809);
    path_13.lineTo(size.width * 0.6551719, size.height * 0.3898809);
    path_13.close();

    Paint paint_13_fill = Paint()..style = PaintingStyle.fill;
    paint_13_fill.color = Color(0xff493a2d).withOpacity(1.0);
    canvas.drawPath(path_13, paint_13_fill);

    Path path_14 = Path();
    path_14.moveTo(size.width * 0.7586211, size.height * 0.4933281);
    path_14.lineTo(size.width * 0.8620684, size.height * 0.4933281);
    path_14.lineTo(size.width * 0.8620684, size.height * 0.3898809);
    path_14.lineTo(size.width * 0.7586211, size.height * 0.3898809);
    path_14.close();

    Paint paint_14_fill = Paint()..style = PaintingStyle.fill;
    paint_14_fill.color = Colors.deepPurple[200]!.withOpacity(1.0);
    canvas.drawPath(path_14, paint_14_fill);

    Path path_15 = Path();
    path_15.moveTo(size.width * 0.1379316, size.height * 0.7864316);
    path_15.lineTo(size.width * 0.2413789, size.height * 0.7864316);
    path_15.lineTo(size.width * 0.2413789, size.height * 0.6829844);
    path_15.lineTo(size.width * 0.1379316, size.height * 0.6829844);
    path_15.close();

    Paint paint_15_fill = Paint()..style = PaintingStyle.fill;
    paint_15_fill.color = Color(0xff493a2d).withOpacity(1.0);
    canvas.drawPath(path_15, paint_15_fill);

    Path path_16 = Path();
    path_16.moveTo(size.width * 0.2413789, size.height * 0.7864316);
    path_16.lineTo(size.width * 0.3448281, size.height * 0.7864316);
    path_16.lineTo(size.width * 0.3448281, size.height * 0.6829844);
    path_16.lineTo(size.width * 0.2413789, size.height * 0.6829844);
    path_16.close();

    Paint paint_16_fill = Paint()..style = PaintingStyle.fill;
    paint_16_fill.color = Colors.deepPurple[200]!.withOpacity(1.0);
    canvas.drawPath(path_16, paint_16_fill);

    Path path_17 = Path();
    path_17.moveTo(size.width * 0.3448281, size.height * 0.7864316);
    path_17.lineTo(size.width * 0.4482754, size.height * 0.7864316);
    path_17.lineTo(size.width * 0.4482754, size.height * 0.6829844);
    path_17.lineTo(size.width * 0.3448281, size.height * 0.6829844);
    path_17.close();

    Paint paint_17_fill = Paint()..style = PaintingStyle.fill;
    paint_17_fill.color = Color(0xff493a2d).withOpacity(1.0);
    canvas.drawPath(path_17, paint_17_fill);

    Path path_18 = Path();
    path_18.moveTo(size.width * 0.4482754, size.height * 0.7864316);
    path_18.lineTo(size.width * 0.5517246, size.height * 0.7864316);
    path_18.lineTo(size.width * 0.5517246, size.height * 0.6829844);
    path_18.lineTo(size.width * 0.4482754, size.height * 0.6829844);
    path_18.close();

    Paint paint_18_fill = Paint()..style = PaintingStyle.fill;
    paint_18_fill.color = Colors.deepPurple[200]!.withOpacity(1.0);
    canvas.drawPath(path_18, paint_18_fill);

    Path path_19 = Path();
    path_19.moveTo(size.width * 0.5517246, size.height * 0.7864316);
    path_19.lineTo(size.width * 0.6551719, size.height * 0.7864316);
    path_19.lineTo(size.width * 0.6551719, size.height * 0.6829844);
    path_19.lineTo(size.width * 0.5517246, size.height * 0.6829844);
    path_19.close();

    Paint paint_19_fill = Paint()..style = PaintingStyle.fill;
    paint_19_fill.color = Color(0xff493a2d).withOpacity(1.0);
    canvas.drawPath(path_19, paint_19_fill);

    Path path_20 = Path();
    path_20.moveTo(size.width * 0.6551719, size.height * 0.7864316);
    path_20.lineTo(size.width * 0.7586211, size.height * 0.7864316);
    path_20.lineTo(size.width * 0.7586211, size.height * 0.6829844);
    path_20.lineTo(size.width * 0.6551719, size.height * 0.6829844);
    path_20.close();

    Paint paint_20_fill = Paint()..style = PaintingStyle.fill;
    paint_20_fill.color = Colors.deepPurple[200]!.withOpacity(1.0);
    canvas.drawPath(path_20, paint_20_fill);

    Path path_21 = Path();
    path_21.moveTo(size.width * 0.7586211, size.height * 0.7864316);
    path_21.lineTo(size.width * 0.8620684, size.height * 0.7864316);
    path_21.lineTo(size.width * 0.8620684, size.height * 0.6829844);
    path_21.lineTo(size.width * 0.7586211, size.height * 0.6829844);
    path_21.close();

    Paint paint_21_fill = Paint()..style = PaintingStyle.fill;
    paint_21_fill.color = Color(0xff493a2d).withOpacity(1.0);
    canvas.drawPath(path_21, paint_21_fill);

    Path path_22 = Path();
    path_22.moveTo(size.width * 0.1379316, size.height * 0.6829844);
    path_22.lineTo(size.width * 0.2413789, size.height * 0.6829844);
    path_22.lineTo(size.width * 0.2413789, size.height * 0.5795352);
    path_22.lineTo(size.width * 0.1379316, size.height * 0.5795352);
    path_22.close();

    Paint paint_22_fill = Paint()..style = PaintingStyle.fill;
    paint_22_fill.color = Colors.deepPurple[200]!.withOpacity(1.0);
    canvas.drawPath(path_22, paint_22_fill);

    Path path_23 = Path();
    path_23.moveTo(size.width * 0.2413789, size.height * 0.6829844);
    path_23.lineTo(size.width * 0.3448281, size.height * 0.6829844);
    path_23.lineTo(size.width * 0.3448281, size.height * 0.5795352);
    path_23.lineTo(size.width * 0.2413789, size.height * 0.5795352);
    path_23.close();

    Paint paint_23_fill = Paint()..style = PaintingStyle.fill;
    paint_23_fill.color = Color(0xff493a2d).withOpacity(1.0);
    canvas.drawPath(path_23, paint_23_fill);

    Path path_24 = Path();
    path_24.moveTo(size.width * 0.3448281, size.height * 0.6829844);
    path_24.lineTo(size.width * 0.4482754, size.height * 0.6829844);
    path_24.lineTo(size.width * 0.4482754, size.height * 0.5795352);
    path_24.lineTo(size.width * 0.3448281, size.height * 0.5795352);
    path_24.close();

    Paint paint_24_fill = Paint()..style = PaintingStyle.fill;
    paint_24_fill.color = Colors.deepPurple[200]!.withOpacity(1.0);
    canvas.drawPath(path_24, paint_24_fill);

    Path path_25 = Path();
    path_25.moveTo(size.width * 0.4482754, size.height * 0.6829844);
    path_25.lineTo(size.width * 0.5517246, size.height * 0.6829844);
    path_25.lineTo(size.width * 0.5517246, size.height * 0.5795352);
    path_25.lineTo(size.width * 0.4482754, size.height * 0.5795352);
    path_25.close();

    Paint paint_25_fill = Paint()..style = PaintingStyle.fill;
    paint_25_fill.color = Color(0xff493a2d).withOpacity(1.0);
    canvas.drawPath(path_25, paint_25_fill);

    Path path_26 = Path();
    path_26.moveTo(size.width * 0.5517246, size.height * 0.6829844);
    path_26.lineTo(size.width * 0.6551719, size.height * 0.6829844);
    path_26.lineTo(size.width * 0.6551719, size.height * 0.5795352);
    path_26.lineTo(size.width * 0.5517246, size.height * 0.5795352);
    path_26.close();

    Paint paint_26_fill = Paint()..style = PaintingStyle.fill;
    paint_26_fill.color = Colors.deepPurple[200]!.withOpacity(1.0);
    canvas.drawPath(path_26, paint_26_fill);

    Path path_27 = Path();
    path_27.moveTo(size.width * 0.6551719, size.height * 0.6829844);
    path_27.lineTo(size.width * 0.7586211, size.height * 0.6829844);
    path_27.lineTo(size.width * 0.7586211, size.height * 0.5795352);
    path_27.lineTo(size.width * 0.6551719, size.height * 0.5795352);
    path_27.close();

    Paint paint_27_fill = Paint()..style = PaintingStyle.fill;
    paint_27_fill.color = Color(0xff493a2d).withOpacity(1.0);
    canvas.drawPath(path_27, paint_27_fill);

    Path path_28 = Path();
    path_28.moveTo(size.width * 0.7586211, size.height * 0.6829844);
    path_28.lineTo(size.width * 0.8620684, size.height * 0.6829844);
    path_28.lineTo(size.width * 0.8620684, size.height * 0.5795352);
    path_28.lineTo(size.width * 0.7586211, size.height * 0.5795352);
    path_28.close();

    Paint paint_28_fill = Paint()..style = PaintingStyle.fill;
    paint_28_fill.color = Colors.deepPurple[200]!.withOpacity(1.0);
    canvas.drawPath(path_28, paint_28_fill);

    Path path_29 = Path();
    path_29.moveTo(size.width * 0.9137930, size.height * 0.3560547);
    path_29.cubicTo(
        size.width * 0.8942930,
        size.height * 0.3560547,
        size.width * 0.8765176,
        size.height * 0.3490898,
        size.width * 0.8620684,
        size.height * 0.3377617);
    path_29.lineTo(size.width * 0.8620684, size.height * 0.8209160);
    path_29.lineTo(size.width * 0.9655176, size.height * 0.8209160);
    path_29.lineTo(size.width * 0.9655176, size.height * 0.3377617);
    path_29.cubicTo(
        size.width * 0.9510684,
        size.height * 0.3490898,
        size.width * 0.9332930,
        size.height * 0.3560547,
        size.width * 0.9137930,
        size.height * 0.3560547);

    Paint paint_29_fill = Paint()..style = PaintingStyle.fill;
    paint_29_fill.color = Color(0xffBDC3C7).withOpacity(1.0);
    canvas.drawPath(path_29, paint_29_fill);

    Path path_30 = Path();
    path_30.moveTo(size.width * 0.1724141, size.height * 0.2691953);
    path_30.cubicTo(
        size.width * 0.1724141,
        size.height * 0.3167988,
        size.width * 0.1338105,
        size.height * 0.3554023,
        size.width * 0.08620703,
        size.height * 0.3554023);
    path_30.cubicTo(size.width * 0.03860352, size.height * 0.3554023, 0,
        size.height * 0.3167988, 0, size.height * 0.2691953);
    path_30.cubicTo(
        0,
        size.height * 0.2215918,
        size.width * 0.03860352,
        size.height * 0.1829883,
        size.width * 0.08620703,
        size.height * 0.1829883);
    path_30.cubicTo(
        size.width * 0.1338105,
        size.height * 0.1829883,
        size.width * 0.1724141,
        size.height * 0.2215918,
        size.width * 0.1724141,
        size.height * 0.2691953);

    Paint paint_30_fill = Paint()..style = PaintingStyle.fill;
    paint_30_fill.color = Colors.deepPurple[200]!.withOpacity(1.0);
    canvas.drawPath(path_30, paint_30_fill);

    Path path_31 = Path();
    path_31.moveTo(size.width * 0.08620703, size.height * 0.3560547);
    path_31.cubicTo(
        size.width * 0.06670703,
        size.height * 0.3560547,
        size.width * 0.04893164,
        size.height * 0.3490898,
        size.width * 0.03448242,
        size.height * 0.3377617);
    path_31.lineTo(size.width * 0.03448242, size.height * 0.8209160);
    path_31.lineTo(size.width * 0.1379316, size.height * 0.8209160);
    path_31.lineTo(size.width * 0.1379316, size.height * 0.3377617);
    path_31.cubicTo(
        size.width * 0.1234824,
        size.height * 0.3490898,
        size.width * 0.1057070,
        size.height * 0.3560547,
        size.width * 0.08620703,
        size.height * 0.3560547);

    Paint paint_31_fill = Paint()..style = PaintingStyle.fill;
    paint_31_fill.color = Color(0xffBDC3C7).withOpacity(1.0);
    canvas.drawPath(path_31, paint_31_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
