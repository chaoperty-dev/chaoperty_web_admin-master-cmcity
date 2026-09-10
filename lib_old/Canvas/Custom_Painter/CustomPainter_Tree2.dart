import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';

//Add this CustomPaint widget to the Widget Tree

//Copy this CustomPainter code to the Bottom of the File
class RPSCustomPainter_Tree2 extends CustomPainter {
  final color_s;

  RPSCustomPainter_Tree2(this.color_s);

  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(size.width * 0.7943202, size.height * 0.7891068);
    path_0.lineTo(size.width * 0.7135117, size.height * 0.6678688);
    path_0.lineTo(size.width * 0.7494557, size.height * 0.6678688);
    path_0.cubicTo(
        size.width * 0.7494825,
        size.height * 0.6678688,
        size.width * 0.7495094,
        size.height * 0.6678688,
        size.width * 0.7495228,
        size.height * 0.6678688);
    path_0.cubicTo(
        size.width * 0.7643479,
        size.height * 0.6678688,
        size.width * 0.7763617,
        size.height * 0.6558517,
        size.width * 0.7763617,
        size.height * 0.6410299);
    path_0.cubicTo(
        size.width * 0.7763617,
        size.height * 0.6352730,
        size.width * 0.7745500,
        size.height * 0.6299421,
        size.width * 0.7714669,
        size.height * 0.6255741);
    path_0.lineTo(size.width * 0.6970897, size.height * 0.5034807);
    path_0.lineTo(size.width * 0.7248008, size.height * 0.5034807);
    path_0.cubicTo(
        size.width * 0.7248276,
        size.height * 0.5034807,
        size.width * 0.7248511,
        size.height * 0.5034807,
        size.width * 0.7248679,
        size.height * 0.5034807);
    path_0.cubicTo(
        size.width * 0.7396930,
        size.height * 0.5034807,
        size.width * 0.7517068,
        size.height * 0.4914636,
        size.width * 0.7517068,
        size.height * 0.4766418);
    path_0.cubicTo(
        size.width * 0.7517068,
        size.height * 0.4713042,
        size.width * 0.7501501,
        size.height * 0.4663357,
        size.width * 0.7474662,
        size.height * 0.4621555);
    path_0.lineTo(size.width * 0.6837205, size.height * 0.3460404);
    path_0.cubicTo(
        size.width * 0.6886186,
        size.height * 0.3411792,
        size.width * 0.6916514,
        size.height * 0.3344427,
        size.width * 0.6916514,
        size.height * 0.3269982);
    path_0.cubicTo(
        size.width * 0.6916514,
        size.height * 0.3216607,
        size.width * 0.6900948,
        size.height * 0.3166921,
        size.width * 0.6874109,
        size.height * 0.3125120);
    path_0.lineTo(size.width * 0.5234924, size.height * 0.01392267);
    path_0.cubicTo(size.width * 0.5187788, size.height * 0.005334228,
        size.width * 0.5097610, 0, size.width * 0.4999648, 0);
    path_0.cubicTo(
        size.width * 0.4901686,
        0,
        size.width * 0.4811541,
        size.height * 0.005337583,
        size.width * 0.4764371,
        size.height * 0.01392267);
    path_0.lineTo(size.width * 0.3044234, size.height * 0.3272666);
    path_0.cubicTo(
        size.width * 0.2998608,
        size.height * 0.3355833,
        size.width * 0.3000218,
        size.height * 0.3456882,
        size.width * 0.3048528,
        size.height * 0.3538505);
    path_0.cubicTo(
        size.width * 0.3060203,
        size.height * 0.3558232,
        size.width * 0.3074293,
        size.height * 0.3575979,
        size.width * 0.3090061,
        size.height * 0.3591747);
    path_0.lineTo(size.width * 0.2516112, size.height * 0.4637289);
    path_0.cubicTo(
        size.width * 0.2470486,
        size.height * 0.4720456,
        size.width * 0.2472096,
        size.height * 0.4821505,
        size.width * 0.2520406,
        size.height * 0.4903128);
    path_0.cubicTo(
        size.width * 0.2568749,
        size.height * 0.4984786,
        size.width * 0.2656546,
        size.height * 0.5034840,
        size.width * 0.2751388,
        size.height * 0.5034840);
    path_0.lineTo(size.width * 0.3028500, size.height * 0.5034840);
    path_0.lineTo(size.width * 0.2275602, size.height * 0.6270670);
    path_0.cubicTo(
        size.width * 0.2225111,
        size.height * 0.6353535,
        size.width * 0.2223300,
        size.height * 0.6457167,
        size.width * 0.2270804,
        size.height * 0.6541743);
    path_0.cubicTo(
        size.width * 0.2318309,
        size.height * 0.6626319,
        size.width * 0.2407783,
        size.height * 0.6678688,
        size.width * 0.2504806,
        size.height * 0.6678688);
    path_0.lineTo(size.width * 0.2864212, size.height * 0.6678688);
    path_0.lineTo(size.width * 0.2046633, size.height * 0.7905359);
    path_0.cubicTo(
        size.width * 0.1991747,
        size.height * 0.7987688,
        size.width * 0.1986648,
        size.height * 0.8093567,
        size.width * 0.2033347,
        size.height * 0.8180861);
    path_0.cubicTo(
        size.width * 0.2080047,
        size.height * 0.8268120,
        size.width * 0.2170997,
        size.height * 0.8322603,
        size.width * 0.2269966,
        size.height * 0.8322603);
    path_0.lineTo(size.width * 0.4183343, size.height * 0.8322603);
    path_0.lineTo(size.width * 0.4183343, size.height * 0.9731645);
    path_0.cubicTo(
        size.width * 0.4183343,
        size.height * 0.9879862,
        size.width * 0.4314686,
        size.height * 1.000003,
        size.width * 0.4462904,
        size.height * 1.000003);
    path_0.lineTo(size.width * 0.5536459, size.height * 1.000003);
    path_0.cubicTo(
        size.width * 0.5684677,
        size.height * 1.000003,
        size.width * 0.5793676,
        size.height * 0.9879862,
        size.width * 0.5793676,
        size.height * 0.9731645);
    path_0.lineTo(size.width * 0.5793676, size.height * 0.8322603);
    path_0.lineTo(size.width * 0.7729397, size.height * 0.8322603);
    path_0.cubicTo(
        size.width * 0.7729598,
        size.height * 0.8322603,
        size.width * 0.7729867,
        size.height * 0.8322603,
        size.width * 0.7730068,
        size.height * 0.8322603);
    path_0.cubicTo(
        size.width * 0.7878319,
        size.height * 0.8322603,
        size.width * 0.7998457,
        size.height * 0.8202432,
        size.width * 0.7998457,
        size.height * 0.8054215);
    path_0.cubicTo(
        size.width * 0.7998423,
        size.height * 0.7992821,
        size.width * 0.7977858,
        size.height * 0.7936291,
        size.width * 0.7943202,
        size.height * 0.7891068);
    path_0.close();
    path_0.moveTo(size.width * 0.4720121, size.height * 0.9463222);
    path_0.lineTo(size.width * 0.4720121, size.height * 0.8322570);
    path_0.lineTo(size.width * 0.5256898, size.height * 0.8322570);
    path_0.lineTo(size.width * 0.5256898, size.height * 0.9463222);
    path_0.lineTo(size.width * 0.4720121, size.height * 0.9463222);
    path_0.close();
    path_0.moveTo(size.width * 0.4797148, size.height * 0.2869446);
    path_0.cubicTo(
        size.width * 0.4607330,
        size.height * 0.2936442,
        size.width * 0.4257083,
        size.height * 0.3060035,
        size.width * 0.3745433,
        size.height * 0.3110761);
    path_0.lineTo(size.width * 0.4999681, size.height * 0.08260673);
    path_0.lineTo(size.width * 0.6046867, size.height * 0.2733574);
    path_0.cubicTo(
        size.width * 0.5664078,
        size.height * 0.2671576,
        size.width * 0.5218720,
        size.height * 0.2720658,
        size.width * 0.4797148,
        size.height * 0.2869446);
    path_0.close();

    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;
    paint_0_fill.color = Color(0xff000000).withOpacity(1.0);
    canvas.drawPath(path_0, paint_0_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
